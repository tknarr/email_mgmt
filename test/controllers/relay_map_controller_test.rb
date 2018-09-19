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

# == Route Map
#
#           Prefix Verb   URI Pattern                                                  Controller#Action
#    relay_domains GET    /email-management/1.0/relay_map/domains(.:format)            relay_map#domains
# relay_recipients GET    /email-management/1.0/relay_map/recipients(.:format)         relay_map#recipients

require 'test_helper'

class RelayMapControllerTest < ActionDispatch::IntegrationTest

    test 'get domains' do
        expected_results = [
            "sample.com\tOK\n",
            "test.subdomain.mydomain.com\tOK\n"
        ]
        get relay_domains_url, params: { token: 'mytoken' }
        assert_response :success
        assert_equal 'text/plain', @response.content_type, "Response content type was not plain text"
        entries = @response.body.lines
        assert_equal 2, entries.count
        assert_equal expected_results, entries, "Result were not as expected."
    end

    test 'get recipients' do
        expected_results = [
            "root@sample.com\tOK\n",
            "root@test.subdomain.mydomain.com\tOK\n",
            "user1@xyzzy.com\tOK\n",
            "@sample.com\tOK\n",
            "@test.subdomain.mydomain.com\tOK\n",
        ]
        get relay_recipients_url, params: { token: 'mytoken' }
        assert_response :success
        assert_equal 'text/plain', @response.content_type, "Response content type was not plain text"
        entries = @response.body.lines
        assert_equal 5, entries.count
        assert_equal expected_results, entries, "Result were not as expected."
    end

end
