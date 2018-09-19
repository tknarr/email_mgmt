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
#          Prefix Verb   URI Pattern                                                  Controller#Action
#          routes GET    /email-management/1.0/routes(.:format)                       route#index {:format=>:json}
#                 POST   /email-management/1.0/routes(.:format)                       route#create {:format=>:json}
#           route PATCH  /email-management/1.0/route/:username/:domain_name(.:format) route#update {:format=>:json, :username=>/([[:alnum:]_]+|\*)/, :domain_name=>/[[:graph:]]+/}
#                 PUT    /email-management/1.0/route/:username/:domain_name(.:format) route#update {:format=>:json, :username=>/([[:alnum:]_]+|\*)/, :domain_name=>/[[:graph:]]+/}
#                 DELETE /email-management/1.0/route/:username/:domain_name(.:format) route#destroy {:format=>:json, :username=>/([[:alnum:]_]+|\*)/, :domain_name=>/[[:graph:]]+/}

require 'test_helper'

class RouteControllerTest < ActionDispatch::IntegrationTest

    def setup
        @admin_headers = { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials('root', 'changeme') }
        @user_headers = { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials('user1', 'changeme') }
    end

    test "mail routing controller routing" do
        assert_equal '/email-management/1.0/routes', routes_path, "Routes path not correct."
        assert_equal '/email-management/1.0/route/xyzzy/abc.com', route_path(username: 'xyzzy', domain_name: 'abc.com'),
                     "Routes path with username and domain not correct."

        assert_routing({ method: :get, path: routes_path }, controller: 'route', action: 'index', format: :json)
        assert_routing({ method: :post, path: routes_path }, controller: 'route', action: 'create', format: :json)
        assert_routing({ method: :put, path: route_path(username: 'xyzzy', domain_name: 'abc.com') },
                       controller: 'route', action: 'update', format: :json, username: 'xyzzy', domain_name: 'abc.com')
        assert_routing({ method: :delete, path: route_path(username: 'xyzzy', domain_name: 'abc.com') },
                       controller: 'route', action: 'destroy', format: :json, username: 'xyzzy', domain_name: 'abc.com')
    end

    test 'non admin index fail' do
        get routes_url
        assert_response :unauthorized
        get routes_url, headers: @user_headers
        assert_response :forbidden
    end

    test 'get index' do
        expected = [
            { 'address_user' => '*', 'address_domain' => '*', 'recipient' => 'postmaster' },
            { 'address_user' => '*', 'address_domain' => 'sample.com', 'recipient' => 'sample_default' },
            { 'address_user' => 'root', 'address_domain' => '*', 'recipient' => 'root' },
            { 'address_user' => 'user1', 'address_domain' => 'xyzzy.com', 'recipient' => 'user1' },
        ]
        get routes_url, headers: @admin_headers
        assert_response :success
        assert_equal 'application/json', @response.content_type, "Response content type was not JSON"
        route_list = JSON.parse(@response.body)
        assert_not_empty route_list
        assert_equal 4, route_list.count, "Route list did not contain the expected number of entries."
        assert_equal expected, route_list, "Route list was not as expected."
    end

    test 'get ordered index' do
        expected = [
            { 'address_user' => 'user1', 'address_domain' => 'xyzzy.com', 'recipient' => 'user1' },
            { 'address_user' => 'root', 'address_domain' => '*', 'recipient' => 'root' },
            { 'address_user' => '*', 'address_domain' => 'sample.com', 'recipient' => 'sample_default' },
            { 'address_user' => '*', 'address_domain' => '*', 'recipient' => 'postmaster' },
        ]
        get routes_url, params: { ordered: 'yes' }, headers: @admin_headers
        assert_response :success
        assert_equal 'application/json', @response.content_type, "Response content type was not JSON"
        route_list = JSON.parse(@response.body)
        assert_not_empty route_list
        assert_equal 4, route_list.count, "Route list did not contain the expected number of entries."
        assert_equal expected, route_list, "Route list was not as expected."
    end

    test 'get ordered index wrong ordered value' do
        expected = [
            { 'address_user' => '*', 'address_domain' => '*', 'recipient' => 'postmaster' },
            { 'address_user' => '*', 'address_domain' => 'sample.com', 'recipient' => 'sample_default' },
            { 'address_user' => 'root', 'address_domain' => '*', 'recipient' => 'root' },
            { 'address_user' => 'user1', 'address_domain' => 'xyzzy.com', 'recipient' => 'user1' },
        ]
        get routes_url, params: { ordered: 'bogus' }, headers: @admin_headers
        assert_response :success
        assert_equal 'application/json', @response.content_type, "Response content type was not JSON"
        route_list = JSON.parse(@response.body)
        assert_not_empty route_list
        assert_equal 4, route_list.count, "Route list did not contain the expected number of entries."
        assert_equal expected, route_list, "Route list was not as expected."
    end

    test 'basic create' do
        post routes_url, params: { address_user: 'xyzzy', address_domain: 'sample.com', recipient: 'root' }, headers: @admin_headers, as: :json
        assert_response :created
        result = MailRouting.find(['xyzzy', 'sample.com'])
        assert_not_nil result, "Did not find the expected route."
    end

    test 'create validation failure' do
        post routes_url, params: { address_user: '', address_domain: 'sample.com', recipient: 'root' }, headers: @admin_headers, as: :json
        assert_response :unprocessable_entity
        post routes_url, params: { address_user: 'xyzzy', address_domain: '', recipient: 'root' }, headers: @admin_headers, as: :json
        assert_response :unprocessable_entity
        post routes_url, params: { address_user: 'xyzzy', address_domain: 'sample.com', recipient: '' }, headers: @admin_headers, as: :json
        assert_response :unprocessable_entity
    end

    test 'create already exists' do
        post routes_url, params: { address_user: 'root', address_domain: '*', recipient: 'root' }, headers: @admin_headers, as: :json
        assert_response :conflict
    end

    test 'basic update' do
        put route_url(username: '*', domain_name: 'sample.com'), params: { address_user: 'xyzzy', address_domain: 'sample.com', recipient: 'root' },
            headers: @admin_headers, as: :json
        assert_response :success
        result = MailRouting.find(['xyzzy', 'sample.com'])
        assert_not_nil result, "Did not find the expected route."
    end

    test 'no updated attributes' do
        put route_url(username: '*', domain_name: 'sample.com'), params: {}, headers: @admin_headers, as: :json
        assert_response :success
        put route_url(username: '*', domain_name: 'sample.com'), params: { domain_name: 'sample.com' }, headers: @admin_headers, as: :json
        assert_response :success
    end

    test 'update cannot update does not exist' do
        put route_url(username: 'xyzzy', domain_name: 'sample.net'), params: { address_user: 'xyzzy', address_domain: 'sample.com', recipient: 'root' },
            headers: @admin_headers, as: :json
        assert_response :not_found
    end

    test 'update cannot update target exists' do
        put route_url(username: '*', domain_name: 'sample.com'), params: { address_user: 'root', address_domain: '*', recipient: 'xyzzy' },
            headers: @admin_headers, as: :json
        assert_response :conflict
    end

    test 'basic destroy' do
        delete route_url(username: '*', domain_name: 'sample.com'), headers: @admin_headers
        assert_response :success
        assert_raises ActiveRecord::RecordNotFound do
            MailRouting.find(['*', 'sample.com'])
        end
    end

    test 'destroy does not exist' do
        delete route_url(username: 'xyzzy', domain_name: 'abc.com'), headers: @admin_headers
        assert_response :conflict
    end

end
