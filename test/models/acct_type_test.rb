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

class AcctTypeTest < ActiveSupport::TestCase

    def setup
        @acct_type_xlate = { 'A' => :alias, 'R' => :root, 'V' => :virtual, 'S' => :system }
    end

    test 'retrieve seeded account types' do
        acct_type_list = AcctType.all
        assert_equal acct_types.count, acct_type_list.count, "Account type list doesn't contain expected initial number of elements."
        acct_type_list.each do |acct_type|
            assert_equal acct_types(@acct_type_xlate[acct_type.code]), acct_type, "Record for account type #{acct_type.code} does not match."
        end
    end

end
