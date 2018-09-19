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
require 'route_order'

class RouteOrderTest < ActiveSupport::TestCase

    def setup
        @user1_d1 = { address_user: 'user1', address_domain: 'sample.com', recipient: 'root' }
        @user2_d1 = { address_user: 'user2', address_domain: 'sample.com', recipient: 'root' }
        @user1_d2 = { address_user: 'user1', address_domain: 'xyzzy.com', recipient: 'root' }
        @user2_d2 = { address_user: 'user2', address_domain: 'xyzzy.com', recipient: 'root' }
        @user1_wc = { address_user: 'user1', address_domain: '*', recipient: 'root' }
        @user2_wc = { address_user: 'user2', address_domain: '*', recipient: 'root' }
        @wc_dom1 = { address_user: '*', address_domain: 'sample.com', recipient: 'root' }
        @wc_dom2 = { address_user: '*', address_domain: 'xyzzy.com', recipient: 'root' }
        @catchall = { address_user: '*', address_domain: '*', recipient: 'root' }
    end

    test 'key compare equality' do
        user_dom = MailRouting.new @user1_d1
        user_wc = MailRouting.new @user1_wc
        wc_dom = MailRouting.new @wc_dom1
        catchall = MailRouting.new @catchall

        assert_equal 0, RouteOrder.key_compare(user_dom, user_dom), "a@a == a@a failed."
        assert_equal 0, RouteOrder.key_compare(user_wc, user_wc), "a@* == a@* failed."
        assert_equal 0, RouteOrder.key_compare(wc_dom, wc_dom), "*@a == *@a failed."
        assert_equal 0, RouteOrder.key_compare(catchall, catchall), "*@* == *@* failed."
    end

    test 'key compare normal users diff in user' do
        entry1 = MailRouting.new @user1_d1
        entry2 = MailRouting.new @user2_d1

        assert_equal (-1), RouteOrder.key_compare(entry1, entry2), "a < b failed."
        assert_equal 1, RouteOrder.key_compare(entry2, entry1), "a > b failed."
    end

    test 'key compare normal users diff in domain' do
        entry1 = MailRouting.new @user1_d1
        entry2 = MailRouting.new @user1_d2

        assert_equal (-1), RouteOrder.key_compare(entry1, entry2), "a < b failed."
        assert_equal 1, RouteOrder.key_compare(entry2, entry1), "a > b failed."
    end

    test 'key compare normal users diff in user and domain' do
        user1_d1 = MailRouting.new @user1_d1
        user1_d2 = MailRouting.new @user1_d2
        user2_d1 = MailRouting.new @user2_d1
        user2_d2 = MailRouting.new @user2_d2

        assert_equal (-1), RouteOrder.key_compare(user1_d1, user2_d2), "1@1 < 2@2 failed."
        assert_equal (-1), RouteOrder.key_compare(user1_d2, user2_d1), "1@2 < 2@1 failed."

        assert_equal 1, RouteOrder.key_compare(user2_d2, user1_d1), "2@2 > 1@1 failed."
        assert_equal 1, RouteOrder.key_compare(user2_d1, user1_d2), "2@1 > 1@2 failed."
    end

    test 'key compare user@* entries' do
        entry1 = MailRouting.new @user1_wc
        entry2 = MailRouting.new @user2_wc

        assert_equal (-1), RouteOrder.key_compare(entry1, entry2), "a < b failed."
        assert_equal 1, RouteOrder.key_compare(entry2, entry1), "a > b failed."
    end

    test 'key compare *@domain entries' do
        entry1 = MailRouting.new @wc_dom1
        entry2 = MailRouting.new @wc_dom2

        assert_equal (-1), RouteOrder.key_compare(entry1, entry2), "a < b failed."
        assert_equal 1, RouteOrder.key_compare(entry2, entry1), "a > b failed."
    end

    test 'key compare normal user to user@*' do
        user1_d1 = MailRouting.new @user1_d1
        user2_d1 = MailRouting.new @user2_d1
        user1_wc = MailRouting.new @user1_wc
        user2_wc = MailRouting.new @user2_wc

        assert_equal 1, RouteOrder.key_compare(user1_d1, user1_wc), "1@1 > 1@* failed."
        assert_equal 1, RouteOrder.key_compare(user2_d1, user1_wc), "2@1 > 1@* failed."
        assert_equal (-1), RouteOrder.key_compare(user1_d1, user2_wc), "1@1 < 2@* failed."
        assert_equal 1, RouteOrder.key_compare(user2_d1, user2_wc), "2@1 > 2@* failed."

        assert_equal (-1), RouteOrder.key_compare(user1_wc, user1_d1), "1@* < 1@1 failed."
        assert_equal (-1), RouteOrder.key_compare(user1_wc, user2_d1), "1@* < 2@1 failed."
        assert_equal 1, RouteOrder.key_compare(user2_wc, user1_d1), "2@* > 1@1 failed."
        assert_equal (-1), RouteOrder.key_compare(user2_wc, user2_d1), "2@* < 2@1 failed."
    end

    test 'key compare normal user to *@domain' do
        user1_d1 = MailRouting.new @user1_d1
        user1_d2 = MailRouting.new @user1_d2
        wc_d1 = MailRouting.new @wc_dom1
        wc_d2 = MailRouting.new @wc_dom2

        assert_equal 1, RouteOrder.key_compare(user1_d1, wc_d1), "1@1 > *@1 failed."
        assert_equal 1, RouteOrder.key_compare(user1_d1, wc_d2), "1@1 > *@2 failed."
        assert_equal 1, RouteOrder.key_compare(user1_d2, wc_d1), "1@2 > *@1 failed."
        assert_equal 1, RouteOrder.key_compare(user1_d2, wc_d2), "1@2 > *@2 failed."

        assert_equal (-1), RouteOrder.key_compare(wc_d1, user1_d1), "*@1 < 1@1 failed."
        assert_equal (-1), RouteOrder.key_compare(wc_d2, user1_d1), "*@2 < 1@1 failed."
        assert_equal (-1), RouteOrder.key_compare(wc_d1, user1_d2), "*@1 < 1@2 failed."
        assert_equal (-1), RouteOrder.key_compare(wc_d2, user1_d2), "*@2 < 1@2 failed."
    end

    test 'key compare normal user to catchall' do
        user1_d1 = MailRouting.new @user1_d1
        catchall = MailRouting.new @catchall

        assert_equal 1, RouteOrder.key_compare(user1_d1, catchall), "1@1 > *@* failed."
        assert_equal (-1), RouteOrder.key_compare(catchall, user1_d1), "*@* < 1@1 failed."
    end

    test 'key compare user@* to *@domain' do
        user1_wc = MailRouting.new @user1_wc
        wc_dom1 = MailRouting.new @wc_dom1

        assert_equal 1, RouteOrder.key_compare(user1_wc, wc_dom1), "1@* > *@1 failed."
        assert_equal (-1), RouteOrder.key_compare(wc_dom1, user1_wc), "*@1 < 1@* failed."
    end

    test 'key compare user@* to catchall' do
        user1_wc = MailRouting.new @user1_wc
        catchall = MailRouting.new @catchall

        assert_equal 1, RouteOrder.key_compare(user1_wc, catchall), "1@* > *@* failed."
        assert_equal (-1), RouteOrder.key_compare(catchall, user1_wc), "*@* < 1@* failed."
    end

    test 'key compare *@domain to catchall' do
        wc_dom1 = MailRouting.new @wc_dom1
        catchall = MailRouting.new @catchall

        assert_equal 1, RouteOrder.key_compare(wc_dom1, catchall), "*@1 > *@* failed."
        assert_equal (-1), RouteOrder.key_compare(catchall, wc_dom1), "*@* < *@1 failed."
    end

    test 'entry compare equality' do
        user_dom = MailRouting.new @user1_d1
        user_wc = MailRouting.new @user1_wc
        wc_dom = MailRouting.new @wc_dom1
        catchall = MailRouting.new @catchall

        assert_equal 0, RouteOrder.entry_compare(user_dom, user_dom), "a@a == a@a failed."
        assert_equal 0, RouteOrder.entry_compare(user_wc, user_wc), "a@* == a@* failed."
        assert_equal 0, RouteOrder.entry_compare(wc_dom, wc_dom), "*@a == *@a failed."
        assert_equal 0, RouteOrder.entry_compare(catchall, catchall), "*@* == *@* failed."
    end

    test 'entry compare normal users diff in user' do
        entry1 = MailRouting.new @user1_d1
        entry2 = MailRouting.new @user2_d1

        assert_equal (-1), RouteOrder.entry_compare(entry1, entry2), "a < b failed."
        assert_equal 1, RouteOrder.entry_compare(entry2, entry1), "a > b failed."
    end

    test 'entry compare normal users diff in domain' do
        entry1 = MailRouting.new @user1_d1
        entry2 = MailRouting.new @user1_d2

        assert_equal (-1), RouteOrder.entry_compare(entry1, entry2), "a < b failed."
        assert_equal 1, RouteOrder.entry_compare(entry2, entry1), "a > b failed."
    end

    test 'entry compare normal users diff in user and domain' do
        user1_d1 = MailRouting.new @user1_d1
        user1_d2 = MailRouting.new @user1_d2
        user2_d1 = MailRouting.new @user2_d1
        user2_d2 = MailRouting.new @user2_d2

        assert_equal (-1), RouteOrder.entry_compare(user1_d1, user2_d2), "1@1 < 2@2 failed."
        assert_equal 1, RouteOrder.entry_compare(user1_d2, user2_d1), "1@2 > 2@1 failed."

        assert_equal 1, RouteOrder.entry_compare(user2_d2, user1_d1), "2@2 > 1@1 failed."
        assert_equal (-1), RouteOrder.entry_compare(user2_d1, user1_d2), "2@1 < 1@2 failed."
    end

    test 'entry compare user@* entries' do
        entry1 = MailRouting.new @user1_wc
        entry2 = MailRouting.new @user2_wc

        assert_equal (-1), RouteOrder.entry_compare(entry1, entry2), "a < b failed."
        assert_equal 1, RouteOrder.entry_compare(entry2, entry1), "a > b failed."
    end

    test 'entry compare *@domain entries' do
        entry1 = MailRouting.new @wc_dom1
        entry2 = MailRouting.new @wc_dom2

        assert_equal (-1), RouteOrder.entry_compare(entry1, entry2), "a < b failed."
        assert_equal 1, RouteOrder.entry_compare(entry2, entry1), "a > b failed."
    end

    test 'entry compare normal user to user@*' do
        user1_d1 = MailRouting.new @user1_d1
        user2_d1 = MailRouting.new @user2_d1
        user1_wc = MailRouting.new @user1_wc
        user2_wc = MailRouting.new @user2_wc

        assert_equal (-1), RouteOrder.entry_compare(user1_d1, user1_wc), "1@1 < 1@* failed."
        assert_equal (-1), RouteOrder.entry_compare(user2_d1, user1_wc), "2@1 < 1@* failed."
        assert_equal (-1), RouteOrder.entry_compare(user1_d1, user2_wc), "1@1 < 2@* failed."
        assert_equal (-1), RouteOrder.entry_compare(user2_d1, user2_wc), "2@1 < 2@* failed."

        assert_equal 1, RouteOrder.entry_compare(user1_wc, user1_d1), "1@* > 1@1 failed."
        assert_equal 1, RouteOrder.entry_compare(user1_wc, user2_d1), "1@* > 2@1 failed."
        assert_equal 1, RouteOrder.entry_compare(user2_wc, user1_d1), "2@* > 1@1 failed."
        assert_equal 1, RouteOrder.entry_compare(user2_wc, user2_d1), "2@* > 2@1 failed."
    end

    test 'entry compare normal user to *@domain' do
        user1_d1 = MailRouting.new @user1_d1
        user1_d2 = MailRouting.new @user1_d2
        wc_d1 = MailRouting.new @wc_dom1
        wc_d2 = MailRouting.new @wc_dom2

        assert_equal (-1), RouteOrder.entry_compare(user1_d1, wc_d1), "1@1 < *@1 failed."
        assert_equal (-1), RouteOrder.entry_compare(user1_d1, wc_d2), "1@1 < *@2 failed."
        assert_equal (-1), RouteOrder.entry_compare(user1_d2, wc_d1), "1@2 < *@1 failed."
        assert_equal (-1), RouteOrder.entry_compare(user1_d2, wc_d2), "1@2 < *@2 failed."

        assert_equal 1, RouteOrder.entry_compare(wc_d1, user1_d1), "*@1 > 1@1 failed."
        assert_equal 1, RouteOrder.entry_compare(wc_d2, user1_d1), "*@2 > 1@1 failed."
        assert_equal 1, RouteOrder.entry_compare(wc_d1, user1_d2), "*@1 > 1@2 failed."
        assert_equal 1, RouteOrder.entry_compare(wc_d2, user1_d2), "*@2 > 1@2 failed."
    end

    test 'entry compare normal user to catchall' do
        user1_d1 = MailRouting.new @user1_d1
        catchall = MailRouting.new @catchall

        assert_equal (-1), RouteOrder.entry_compare(user1_d1, catchall), "1@1 < *@* failed."
        assert_equal 1, RouteOrder.entry_compare(catchall, user1_d1), "*@* > 1@1 failed."
    end

    test 'entry compare user@* to *@domain' do
        user1_wc = MailRouting.new @user1_wc
        wc_dom1 = MailRouting.new @wc_dom1

        assert_equal (-1), RouteOrder.entry_compare(user1_wc, wc_dom1), "1@* < *@1 failed."
        assert_equal 1, RouteOrder.entry_compare(wc_dom1, user1_wc), "*@1 > 1@* failed."
    end

    test 'entry compare user@* to catchall' do
        user1_wc = MailRouting.new @user1_wc
        catchall = MailRouting.new @catchall

        assert_equal (-1), RouteOrder.entry_compare(user1_wc, catchall), "1@* < *@* failed."
        assert_equal 1, RouteOrder.entry_compare(catchall, user1_wc), "*@* > 1@* failed."
    end

    test 'entry compare *@domain to catchall' do
        wc_dom1 = MailRouting.new @wc_dom1
        catchall = MailRouting.new @catchall

        assert_equal (-1), RouteOrder.entry_compare(wc_dom1, catchall), "*@1 < *@* failed."
        assert_equal 1, RouteOrder.entry_compare(catchall, wc_dom1), "*@* > *@1 failed."
    end

    test 'categorize address' do
        assert_equal 0, RouteOrder.categorize_address('user', 'domain'), "Categorize normal user failed."
        assert_equal 1, RouteOrder.categorize_address('user', '*'), "Categorize user@* failed."
        assert_equal 2, RouteOrder.categorize_address('*', 'domain'), "Categorize *@domain failed."
        assert_equal 3, RouteOrder.categorize_address('*', '*'), "Categorize catchall failed."
    end

    test 'entry primitive compare equality' do
        user_dom = MailRouting.new @user1_d1

        assert_equal 0, RouteOrder.entry_primitive_compare(user_dom, user_dom), "a@a == a@a failed."
    end

    test 'entry primitive compare normal users diff in user' do
        entry1 = MailRouting.new @user1_d1
        entry2 = MailRouting.new @user2_d1

        assert_equal (-1), RouteOrder.entry_primitive_compare(entry1, entry2), "a < b failed."
        assert_equal 1, RouteOrder.entry_primitive_compare(entry2, entry1), "a > b failed."
    end

    test 'entry primitive compare normal users diff in domain' do
        entry1 = MailRouting.new @user1_d1
        entry2 = MailRouting.new @user1_d2

        assert_equal (-1), RouteOrder.entry_primitive_compare(entry1, entry2), "a < b failed."
        assert_equal 1, RouteOrder.entry_primitive_compare(entry2, entry1), "a > b failed."
    end

    test 'entry primitive compare normal users diff in user and domain' do
        user1_d1 = MailRouting.new @user1_d1
        user1_d2 = MailRouting.new @user1_d2
        user2_d1 = MailRouting.new @user2_d1
        user2_d2 = MailRouting.new @user2_d2

        assert_equal (-1), RouteOrder.entry_primitive_compare(user1_d1, user2_d2), "1@1 < 2@2 failed."
        assert_equal 1, RouteOrder.entry_primitive_compare(user1_d2, user2_d1), "1@2 > 2@1 failed."

        assert_equal 1, RouteOrder.entry_primitive_compare(user2_d2, user1_d1), "2@2 > 1@1 failed."
        assert_equal (-1), RouteOrder.entry_primitive_compare(user2_d1, user1_d2), "2@1 < 1@2 failed."
    end

    test 'entry sort' do
        expected = [
            MailRouting.new(@user1_d1),
            MailRouting.new(@user2_d1),
            MailRouting.new(@user1_d2),
            MailRouting.new(@user2_d2),
            MailRouting.new(@user1_wc),
            MailRouting.new(@user2_wc),
            MailRouting.new(@wc_dom1),
            MailRouting.new(@wc_dom2),
            MailRouting.new(@catchall),

        ]
        routing_list = [
            MailRouting.new(@catchall),
            MailRouting.new(@wc_dom2),
            MailRouting.new(@user2_d2),
            MailRouting.new(@wc_dom1),
            MailRouting.new(@user2_wc),
            MailRouting.new(@user1_d2),
            MailRouting.new(@user1_wc),
            MailRouting.new(@user2_d1),
            MailRouting.new(@user1_d1),
        ]
        assert_equal expected, RouteOrder.entry_sort(routing_list), "Entry sort failed."
    end

end
