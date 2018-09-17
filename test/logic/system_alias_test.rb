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
require 'system_alias'

class SystemAliasTest < ActiveSupport::TestCase

    test 'read system aliases success' do
        aliases = SystemAlias.get_aliases file_fixture('system_aliases_test').to_s
        assert_equal 3, aliases.count, 'Aliases hash did not contain expected number of items.'
        assert_equal 1, aliases['testuser1'].count, 'Test user 1 did not contain just one target.'
        assert_equal 'singletarget', aliases['testuser1'][0], 'Test user 1 did not have the correct target.'
        assert_equal 3, aliases['testuser2'].count, 'Test user 2 did not contain the expected number of targets.'
        assert_equal 1, aliases['finaluser'].count, 'Final test user did not contain just one target.'
    end

    test 'do sync normal outcome' do
        alias_users = SystemAlias.do_sync file_fixture('sync_aliases_normal').to_s
        assert_not_empty alias_users, "Alias users list was empty when expected to have entries."
        assert_equal 12, alias_users.count, "Alias users list did not contain the expected number of items."
    end

    test 'merge aliases' do
        aliases = SystemAlias.get_aliases file_fixture('system_aliases_normal').to_s
        alias_users = MailUser.where acct_type: 'A'
        results = SystemAlias.merge_aliases aliases, alias_users
        assert_not_empty results, "Merged aliases list was empty."
        assert_equal 14, results.count, "Merged alias list did not contain the expected number of items."
    end

    test 'get merged aliases' do
        results = SystemAlias.get_merged_aliases file_fixture('system_aliases_normal').to_s
        assert_not_empty results, "Merged aliases list was empty."
        assert_equal 14, results.count, "Merged alias list did not contain the expected number of items."
    end

end
