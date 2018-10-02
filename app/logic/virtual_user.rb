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

    def self.create_home(username)
        # `/usr/bin/sudo -u vmail /usr/local/bin/vmaildir.sh create #{username}`
        # exit_code = $?.exitstatus
        # if exit_code != 0
        #     raise ApiErrors::AlreadyExists.new("Home directory for user #{username} already exists")
        # end
    end

    def self.rename_home(old_username, new_username)
        # `/usr/bin/sudo -u vmail /usr/local/bin/vmaildir.sh rename #{old_username} #{new_username}`
        # exit_code = $?.exitstatus
        # if exit_code != 0
        #     raise ApiErrors::CannotUpdate.new("Problem renaming home directory for user #{old_username} to #{new_username}")
        # end
    end

    def self.remove_home(username)
        # `/usr/bin/sudo -u vmail /usr/local/bin/vmaildir.sh delete #{username}`
        # exit_code = $?.exitstatus
        # if exit_code != 0
        #     raise ApiErrors::CannotDelete.new("Home directory for user #{username} does not exist")
        # end
    end

end
