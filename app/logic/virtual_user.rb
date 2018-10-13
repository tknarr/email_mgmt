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

class VirtualUser

    def self.maildir(username)
        begin
            entry = VPasswd.find username
            raise ApiError::ServerError.new("No home directory for #{username}") if entry.home.blank?
            raise ApiError::ServerError.new("User #{username} is not a virtual user") if entry.acct_type != 'V'
            return entry.home
        rescue ActiveRecord::RecordNotFound
            raise ApiErrors::ServerError.new("No home directory entry for #{username}")
        end
    end

    def self.create_home(username, allow_existing = false)
        homedir = maildir(username)
        if Dir.exist? homedir
            return if allow_existing

            raise ApiErrors::AlreadyExists.new("Home directory for user #{username} already exists")
        end

        begin
            Dir.mkdir homedir, 0o770
        rescue StandardError => e
            raise ApiErrors::ServerError.new("Error creating directory for #{username}: " + e.to_s)
        end
    end

    def self.rename_home(old_username, new_username)
        old_homedir = maildir(old_username)
        new_homedir = maildir(new_username)
        unless Dir.exist? old_homedir
            raise ApiErrors::NotFound.new("Home directory for user #{old_username} does not exist")
        end
        if Dir.exist? new_homedir
            raise ApiErrors::AlreadyExists.new("Home directory for user #{new_username} already exists")
        end

        begin
            File.rename old_homedir, new_homedir
        rescue StandardError => e
            raise ApiErrors::CannotUpdate.new("Error renaming home directory for user #{old_username} to #{new_username}: " + e.to_s)
        end
    end

    def self.remove_home(username)
        homedir = maildir(username)
        unless Dir.exist? homedir
            raise ApiErrors::NotFound.new("Home directory for user #{username} does not exist")
        end

        index = 0
        suffix = '.deleted_'
        deleted_dirname = homedir + '.deleted'
        while File.exist? deleted_dirname
            index += 1
            raise ApiErrors::ServerError.new("Error finding safe name for deleted home directory for #{username}") if index > 5000
            deleted_dirname = homedir + suffix + index.to_s
        end

        begin
            File.rename homedir, deleted_dirname
        rescue StandardError => e
            raise ApiErrors::ServerError.new("Error deleting home directory for user #{username}: " + e.to_s)
        end
    end

end
