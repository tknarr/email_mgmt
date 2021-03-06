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

class HostedDomainTest < ActiveSupport::TestCase

    test 'retrieve all domains' do
        domain_list = HostedDomain.all
        assert_equal hosted_domains.count, domain_list.count, "Domain list doesn't contain expected initial number of elements."
        i = 0
        hosted_domains.each { |hosted_domain|
            assert_equal hosted_domain, domain_list[i], "Domain list entry #{i} does not match #{hosted_domain.name}"
            i += 1
        }
    end

    test 'retrieve all domains with default recipient' do
        domain_list = HostedDomain.all_routing
        assert_equal hosted_domains.count, domain_list.count, "Domain list doesn't contain expected initial number of elements."
        domain_list.each do |item|
            if item.name == 'sample.com'
                assert_equal 'sample_default', item.default_recipient, "Default recipient not set when expected."
            else
                assert_nil item.default_recipient, "Default recipient is set when not expected."
            end
        end
    end

end
