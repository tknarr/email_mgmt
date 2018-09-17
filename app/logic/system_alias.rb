#-----
# email_mgmt
# Copyright (C) 2018 Silverglass Technical
# Author: Todd Knarr <tknarr@silverglass.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#-----

module SystemAlias

    # @param fname [String]
    # @return [Hash<String, Array<String>>]
    def self.get_aliases(fname = '/etc/aliases')
        aliases = {}
        File.foreach(fname) do |line|
            l = line.strip
            # Skip blank or comment lines
            next if l.blank? || l[0] == '#'
            username_targets = l.split ':'
            # Skip if the line doesn't have two fields
            next if username_targets.blank? || username_targets.count != 2
            username = username_targets[0].strip
            # Skip if the line's username is blank
            next if username.blank?
            target_string = username_targets[1].strip
            # Skip if no target usernames
            next if target_string.blank?
            targets = []
            target_usernames = target_string.split ','
            target_usernames.each do |u|
                target = u.strip
                targets << target unless target.blank?
            end
            aliases[username] = targets unless targets.count == 0
        end
        aliases
    end

    # @param fname [String]
    # @return [Array<Hash<Symbol, String>>]
    def self.get_merged_aliases(fname = '/etc/aliases')
        aliases = get_aliases fname
        alias_users = MailUser.where acct_type: 'A'
        merge_aliases aliases, alias_users
    end

    # @param fname [String]
    # @return [Array<Hash<Symbol, String>>]
    def self.do_sync(fname = '/etc/aliases')
        aliases_create = []
        aliases_remove = []

        aliases = get_aliases fname
        alias_users = MailUser.where acct_type: 'A'

        # Scan aliases and record which ones don't exist and need created. If a regular user exists
        # with the same name we ignore the conflict, normally it's only for root but it's legitimate
        # to have a real system user in the mail system whose mail is redirected at the mail-server
        # level to another username.
        aliases.each_key do |alias_name|
            begin
                alias_user = MailUser.find alias_name
            rescue ActiveRecord::RecordNotFound
                alias_user = nil
            end
            aliases_create << alias_name if alias_user.nil?
        end
        # Scan all existing alias users and remove any that don't exist in the current system aliases and
        # don't have a mail routing entry pointing to them.
        alias_users&.each do |alias_user|
            alias_recipients = MailRouting.where recipient: alias_user.username
            aliases_remove << alias_user.username unless aliases.has_key?(alias_user.username) || !alias_recipients.blank?
        end

        # Create alias users for system aliases that don't currently have one
        aliases_create.each do |alias_name|
            begin
                MailUser.create!(username: alias_name, password_digest: 'x', acct_type: 'A')
            rescue ActiveRecord::RecordInvalid => e
                raise ApiErrors::AliasConflict.new("Problem creating new alias user #{alias_name}", e)
            end
        end
        # Delete alias users for system aliases that don't currently exist
        aliases_remove.each do |alias_name|
            begin
                MailUser.find(alias_name).destroy!
            rescue ActiveRecord::RecordNotDestroyed => e
                raise ApiErrors::AliasConflict.new("Problem destroying removed alias user #{alias_name}", e)
            rescue ActiveRecord::RecordNotFound => e
                raise ApiErrors::AliasConflict.new("Alias user #{alias_name} not found when removing alias user.")
            end
        end

        alias_users = MailUser.where acct_type: 'A'
        merge_aliases aliases, alias_users
    end

    # @param system_aliases [Hash<String, Array<String>>]
    # @param alias_users [Array<MailUser>]
    # @return [Array<Hash<Symbol, String>>]
    def self.merge_aliases(system_aliases, alias_users)
        results = []
        alias_usernames = []
        # Scan mail users filling in data, including data from matching system alias if any.
        # Record the usernames as we go for faster lookup later.
        alias_users&.each do |alias_user|
            alias_data = {
                username: alias_user.username,
                account_type: 'Alias user',
                system_alias: '',
                targets: [],
            }
            if system_aliases&.has_key? alias_user.username
                alias_data[:system_alias] = alias_user.username
                alias_data[:targets] = system_aliases[alias_user.username]
            end
            alias_usernames << alias_user.username
            results << alias_data
        end
        # Now scan the system aliases for any that don't have a matching mail user entry
        # and add them, leaving the mail user username blank.
        system_aliases&.each do |alias_username, targets|
            unless alias_usernames.include? alias_username
                alias_data = {
                    username: '',
                    account_type: 'System alias',
                    system_alias: alias_username,
                    targets: targets,
                }
                results << alias_data
            end
        end
        results
    end

end
