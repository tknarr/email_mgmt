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

require 'test_helper'

class MailUserTest < ActiveSupport::TestCase

    test 'retrieve all users' do
        user_list = MailUser.all
        assert_equal mail_users.count, user_list.count, "User list doesn't contain expected initial number of elements."
        user_list.each do |user|
            assert_equal mail_users(user.username.to_sym), user, "User #{user.username} does not match."
        end
    end

end
