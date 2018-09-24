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
#            Prefix     Verb   URI Pattern                                                  Controller#Action
#   system_aliases_sync GET    /email-management/1.0/system_aliases/sync(.:format)          system_alias#sync {:format=>:json}
# system_aliases_merged GET    /email-management/1.0/system_aliases/merged(.:format)        system_alias#merged_index {:format=>:json}
#        system_aliases GET    /email-management/1.0/system_aliases(.:format)               system_alias#index {:format=>:json}

require 'test_helper'

class SystemAliasControllerTest < ActionDispatch::IntegrationTest

    def setup
        @admin_headers = { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials('root', 'changeme') }
        @user_headers = { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials('user1', 'changeme') }
    end

    test "system alias controller routing" do
        assert_equal '/email-management/1.0/system_aliases', system_aliases_path, "System aliases path not correct."
        assert_equal '/email-management/1.0/system_aliases/sync', system_aliases_sync_path, "System aliases sync path not correct."

        assert_routing({ method: :get, path: system_aliases_path }, controller: 'system_alias', action: 'index', format: :json)
        assert_routing({ method: :get, path: system_aliases_sync_path }, controller: 'system_alias', action: 'sync', format: :json)
    end

    test 'non admin index fail' do
        get system_aliases_url
        assert_response :unauthorized
        get system_aliases_url, headers: @user_headers
        assert_response :forbidden
    end

    test 'get index' do
        get system_aliases_url, headers: @admin_headers
        assert_response :success
        assert_equal 'application/json', @response.content_type, "Response content type was not JSON"
        alias_list = JSON.parse(@response.body)
        assert_not_nil alias_list
        assert alias_list.count > 0, "Alias list did not contain any entries."
    end

    test 'non admin merged index fail' do
        get system_aliases_merged_url
        assert_response :unauthorized
        get system_aliases_url, headers: @user_headers
        assert_response :forbidden
    end

    test 'get merged index' do
        get system_aliases_merged_url, headers: @admin_headers
        assert_response :success
        assert_equal 'application/json', @response.content_type, "Response content type was not JSON"
        alias_list = JSON.parse(@response.body)
        assert_not_nil alias_list
        assert alias_list.count > 0, "Merged alias list did not contain any entries."
    end

    test 'non admin sync fail' do
        get system_aliases_sync_url
        assert_response :unauthorized
        get system_aliases_sync_url, headers: @user_headers
        assert_response :forbidden
    end

    # NOTE alias users not supported
    # test 'do sync' do
    #     get system_aliases_sync_url, headers: @admin_headers
    #     assert_response :success
    #     assert_equal 'application/json', @response.content_type, "Response content type was not JSON"
    #     user_list = JSON.parse(@response.body)
    #     assert_not_nil user_list
    #     assert user_list.count > 0, "Alias user list did not contain any entries."
    # end

end
