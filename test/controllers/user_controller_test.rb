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
#    passwd_users GET    /email-management/1.0/users/passwd(.:format)                 user#passwd {:format=>:json}
#           users GET    /email-management/1.0/users(.:format)                        user#index {:format=>:json}
#                 POST   /email-management/1.0/users(.:format)                        user#create {:format=>:json}
#            user PATCH  /email-management/1.0/user/:id(.:format)                     user#update {:format=>:json, :id=>/[[:alnum:]_]+/}
#                 PUT    /email-management/1.0/user/:id(.:format)                     user#update {:format=>:json, :id=>/[[:alnum:]_]+/}
#                 DELETE /email-management/1.0/user/:id(.:format)                     user#destroy {:format=>:json, :id=>/[[:alnum:]_]+/}
#    current_user GET    /email-management/1.0/user(.:format)                         user#current {:format=>:json}
# update_password POST   /email-management/1.0/password(.:format)                     user#update_password {:format=>:json}

require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest

    def setup
        @admin_headers = { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials('root', 'changeme') }
        @user_username = 'user1'
        @user_headers = { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials('user1', 'changeme') }
        @newpwd_headers = { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials('user1', 'dumbpassword') }
    end

    test "user controller routing" do
        assert_equal '/email-management/1.0/users', users_path, "Users path not correct."
        assert_equal '/email-management/1.0/users/passwd', passwd_users_path, "Passwd view path not correct."
        assert_equal '/email-management/1.0/user/xyzzy', user_path('xyzzy'), "User path with user not correct."
        assert_equal '/email-management/1.0/user', current_user_path, "Current user path not correct."
        assert_equal '/email-management/1.0/password', update_password_path, "Password update path not correct."

        assert_routing({ method: :get, path: users_path }, controller: 'user', action: 'index', format: :json)
        assert_routing({ method: :post, path: users_path }, controller: 'user', action: 'create', format: :json)
        assert_routing({ method: :delete, path: user_path('xyzzy') }, controller: 'user', action: 'destroy', format: :json, id: 'xyzzy')
        assert_routing({ method: :get, path: current_user_path }, controller: 'user', action: 'current', format: :json)
        assert_routing({ method: :post, path: update_password_path }, controller: 'user', action: 'update_password', format: :json)
    end

    test 'non admin index fail' do
        get users_url
        assert_response :unauthorized
        get users_url, headers: @user_headers
        assert_response :forbidden
    end

    test 'get index' do
        get users_url, headers: @admin_headers
        assert_response :success
        assert_equal 'application/json', @response.content_type, "Response content type was not JSON"
        user_list = JSON.parse(@response.body)
        assert_not_nil user_list
        assert_equal 3, user_list.count, "User list did not contain the expected number of entries."
        assert_equal 'root', user_list[0]['username'], "User list did not contain root."
        assert_equal 'sample_default', user_list[1]['username'], "User list did not contain sample_default."
    end

    test 'get passwd view' do
        get passwd_users_url, headers: @admin_headers
        assert_response :success
        assert_equal 'application/json', @response.content_type, "Response content type was not JSON"
        user_list = JSON.parse(@response.body)
        assert_not_nil user_list
        assert_equal 3, user_list.count, "User list did not contain the expected number of entries."
    end

    test 'basic create' do
        post users_url, params: { username: 'xyzzy', password: '*', acct_type: 'V' }, headers: @admin_headers, as: :json
        assert_response :created
        result = MailUser.find 'xyzzy'
        assert_not_nil result, "Did not find the expected user."
    end

    test 'create validation failure' do
        post users_url, params: { username: '', password: '*', acct_type: 'V' }, headers: @admin_headers, as: :json
        assert_response :unprocessable_entity
        post users_url, params: { username: 'xyzzy', password: '', acct_type: 'V' }, headers: @admin_headers, as: :json
        assert_response :unprocessable_entity
        post users_url, params: { username: 'xyzzy', password: nil, acct_type: 'V' }, headers: @admin_headers, as: :json
        assert_response :unprocessable_entity
        post users_url, params: { username: 'xyzzy', password: '*', acct_type: '' }, headers: @admin_headers, as: :json
        assert_response :unprocessable_entity
    end

    test 'create already exists' do
        post users_url, params: { username: 'root', password: '*', acct_type: 'R' }, headers: @admin_headers, as: :json
        assert_response :conflict
    end

    test 'basic update' do
        put user_url('sample_default'), params: { username: 'xyzzy', password: '*', acct_type: 'V' }, headers: @admin_headers, as: :json
        assert_response :success
        user = MailUser.find 'xyzzy'
        assert_not_nil user, "Did not find the expected user."
    end

    test 'no updated attributes' do
        put user_url('sample_default'), params: {}, headers: @admin_headers, as: :json
        assert_response :success
        put user_url('sample_default'), params: { name: 'sample_default' }, headers: @admin_headers, as: :json
        assert_response :success
    end

    test 'update cannot update does not exist' do
        put user_url('xyzzy'), params: { username: 'abc', password: '*', acct_type: 'S' }, headers: @admin_headers, as: :json
        assert_response :not_found
    end

    test 'update cannot update target exists' do
        put user_url('sample_default'), params: { username: 'root', password: '*', acct_type: 'S' }, headers: @admin_headers, as: :json
        assert_response :conflict
    end

    test 'basic destroy' do
        delete user_url('sample_default'), headers: @admin_headers
        assert_response :success
        assert_raises ActiveRecord::RecordNotFound do
            MailUser.find 'sample_default'
        end
    end

    test 'destroy does not exist' do
        delete user_url('xyzzy'), headers: @admin_headers
        assert_response :conflict
    end

    test 'get current user admin' do
        get current_user_url, headers: @admin_headers
        assert_response :success
        assert_equal 'application/json', @response.content_type, "Response content type was not JSON"
        user = JSON.parse(@response.body)
        assert_not_empty user
        assert_equal 'root', user['username']
        assert_equal 1, user['admin']
    end

    test 'get current user regular' do
        get current_user_url, headers: @user_headers
        assert_response :success
        assert_equal 'application/json', @response.content_type, "Response content type was not JSON"
        user = JSON.parse(@response.body)
        assert_not_empty user
        assert_equal 'user1', user['username']
        assert_equal 0, user['admin']
    end

    test 'update password' do
        user = MailUser.find(@user_username)
        old_digest = user.password_digest
        post update_password_url, params: {current_password: 'changeme', new_password: 'dumbpassword'}, headers: @user_headers, as: :json
        assert_response :success
        user = MailUser.find(@user_username)
        new_digest = user.password_digest
        assert_not_equal old_digest, new_digest
    end

    test 'update password bad password' do
        post update_password_url, params: {current_password: 'wrong', new_password: 'dumbpassword'}, headers: @user_headers, as: :json
        assert_response :forbidden
    end

end
