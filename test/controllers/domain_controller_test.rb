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
#          Prefix Verb   URI Pattern                                            Controller#Action
# routing_domains GET    /email-management/1.0/domains/routing(.:format)        domain#routing {:format=>:json}
#         domains GET    /email-management/1.0/domains(.:format)                domain#index {:format=>:json}
#                 POST   /email-management/1.0/domains(.:format)                domain#create {:format=>:json}
#          domain PATCH  /email-management/1.0/domain/:id(.:format)             domain#update {:format=>:json, :id=>/[[:graph:]]+/}
#                 PUT    /email-management/1.0/domain/:id(.:format)             domain#update {:format=>:json, :id=>/[[:graph:]]+/}
#                 DELETE /email-management/1.0/domain/:id(.:format)             domain#destroy {:format=>:json, :id=>/[[:graph:]]+/}

require 'test_helper'

class DomainControllerTest < ActionDispatch::IntegrationTest

    def setup
        @admin_headers = {"Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials('root', 'changeme')}
        @user_headers = {"Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials('user1', 'changeme')}
    end

    test "domain controller routing" do
        assert_equal '/email-management/1.0/domains', domains_path, "Domains path not correct."
        assert_equal '/email-management/1.0/domains/routing', routing_domains_path, "Domains routing path not correct."
        assert_equal '/email-management/1.0/domain/xyzzy.com', domain_path('xyzzy.com'), "Domain path with domain not correct."

        assert_routing({ method: :get, path: domains_path }, controller: 'domain', action: 'index', format: :json)
        assert_routing({ method: :post, path: domains_path }, controller: 'domain', action: 'create', format: :json)
        assert_routing({method: :get, path: routing_domains_path}, controller: 'domain', action: 'routing', format: :json)
        assert_routing({ method: :put, path: domain_path('xyzzy.com') }, controller: 'domain', action: 'update', format: :json, id: 'xyzzy.com')
        assert_routing({ method: :delete, path: domain_path('xyzzy.com') }, controller: 'domain', action: 'destroy', format: :json, id: 'xyzzy.com')
    end

    test 'non admin index fail' do
        get domains_url
        assert_response :unauthorized
        get domains_url, headers: @user_headers
        assert_response :forbidden
    end

    test 'get index' do
        get domains_url, headers: @admin_headers
        assert_response :success
        assert_equal 'application/json', @response.content_type, "Response content type was not JSON"
        domain_list = JSON.parse(@response.body)
        assert_not_nil domain_list
        assert_equal 2, domain_list.count, "Domain list did not contain the expected number of entries."
        assert_includes domain_list, 'sample.com', "Domain list did not contain sample.com."
        assert_includes domain_list, 'test.subdomain.mydomain.com', "Domain list did not contain test.subdomain.mydomain.com."
    end

    test 'get routing index' do
        get routing_domains_url, headers: @admin_headers
        assert_response :success
        assert_equal 'application/json', @response.content_type, "Response content type was not JSON"
        domain_list = JSON.parse(@response.body)
        assert_not_nil domain_list
        assert_equal 2, domain_list.count, "Domain list did not contain the expected number of entries."
        domain_list.each do |item|
            if item[:name] == 'sample.com'
                assert_equal 'sample_default', item[:default_recipient], "Default recipient not set when expected."
            else
                assert_nil item[:default_recipient], "Default recipient is set when not expected."
            end
        end
    end

    test 'basic create' do
        post domains_url, params: { name: 'sci.xyzzy.net' }, headers: @admin_headers, as: :json
        assert_response :created
        result = HostedDomain.find 'sci.xyzzy.net'
        assert_not_nil result, "Did not find the expected domain."
    end

    test 'create validation failure' do
        post domains_url, params: { name: '' }, headers: @admin_headers, as: :json
        assert_response :unprocessable_entity
    end

    test 'create already exists' do
        post domains_url, params: { name: 'sample.com' }, headers: @admin_headers, as: :json
        assert_response :conflict
    end

    test 'basic update' do
        put domain_url('sample.com'), params: { name: 'sample.net' }, headers: @admin_headers, as: :json
        assert_response :success
        domain = HostedDomain.find 'sample.net'
        assert_not_nil domain, "Did not find the expected domain."
    end

    test 'no updated attributes' do
        put domain_url('sample.com'), params: {}, headers: @admin_headers, as: :json
        assert_response :success
        put domain_url('sample.com'), params: { name: 'sample.com' }, headers: @admin_headers, as: :json
        assert_response :success
    end

    test 'update cannot update does not exist' do
        put domain_url('sample.net'), params: { name: 'sample2.net' }, headers: @admin_headers, as: :json
        assert_response :not_found
    end

    test 'update cannot update target exists' do
        put domain_url('sample.com'), params: { name: 'test.subdomain.mydomain.com' }, headers: @admin_headers, as: :json
        assert_response :conflict
    end

    test 'basic destroy' do
        delete domain_url('sample.com'), headers: @admin_headers
        assert_response :success
        assert_raises ActiveRecord::RecordNotFound do
            HostedDomain.find 'sample.com'
        end
    end

    test 'destroy does not exist' do
        delete domain_url('xyzzy.com'), headers: @admin_headers
        assert_response :conflict
    end

end
