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

class MailRoutingTest < ActiveSupport::TestCase

    test 'retrieve all routing entries' do
        expected = mail_routing.to_a.sort! do |a, b|
            RouteOrder.key_compare a, b
        end
        routing_list = MailRouting.all
        assert_equal expected.count, routing_list.count, "Routing list doesn't contain expected initial number of elements."
        i = 0
        routing_list.each do |entry|
            assert_equal expected[i], entry, "Routing list entry #{i} does not match #{entry.address_user}@#{entry.address_domain}"
            i += 1
        end
    end

end
