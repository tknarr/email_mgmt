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
#             Prefix Verb   URI Pattern                                                  Controller#Action
#    account_types GET    /email-management/1.0/account_types(.:format)                account_type#index {:format=>:json}

require 'test_helper'

class AccountTypeControllerTest < ActionDispatch::IntegrationTest

    def setup
        @admin_headers = { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials('root', 'changeme') }
        @user_headers = { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials('user1', 'changeme') }
    end

    test "account type controller routing" do
        assert_equal '/email-management/1.0/account_types', account_types_path, "Users path not correct."

        assert_routing({ method: :get, path: account_types_path }, controller: 'account_type', action: 'index', format: :json)
    end

    test 'get index admin' do
        get account_types_url, headers: @admin_headers
        assert_response :success
        assert_equal 'application/json', @response.content_type, "Response content type was not JSON"
        account_type_list = JSON.parse(@response.body)
        assert_not_nil account_type_list
        assert_equal 4, account_type_list.count, "Account type list did not contain the expected number of entries."
    end

    test 'get index not admin' do
        get account_types_url, headers: @user_headers
        assert_response :success
        assert_equal 'application/json', @response.content_type, "Response content type was not JSON"
        account_type_list = JSON.parse(@response.body)
        assert_not_nil account_type_list
        assert_equal 4, account_type_list.count, "Account type list did not contain the expected number of entries."
    end

end
