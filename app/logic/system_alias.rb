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

end
