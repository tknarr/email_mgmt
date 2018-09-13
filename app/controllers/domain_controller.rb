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

class DomainController < ApplicationController

    def index
        begin
            domain_list = HostedDomain.all
            domain_name_list = []
            domain_list.each do |domain_entry|
                domain_name_list << domain_entry.name
            end
            render status: :ok, json: domain_name_list
        rescue => e
            raise ApiErrors::ServerError.new(nil, e)
        end
    end

    def routing
        begin
            domain_list = HostedDomain.all_routing
            render status: :ok, json: domain_list
        rescue => e
            raise ApiErrors::ServerError.new(nil, e)
        end
    end

    def create
        begin
            domain =HostedDomain.create!(name: params[:name])
            render status: :created, json: domain
        rescue ActiveRecord::RecordInvalid => e
            raise ApiErrors::ValidationFailure.new("Validation failure", e)
        rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordNotUnique => e
            raise ApiErrors::AlreadyExists.new("Domain #{params[:name]} already exists", e)
        rescue => e
            raise ApiErrors::ServerError.new(nil, e)
        end
    end

    def update
        begin
            domain = HostedDomain.find(params[:id])
            updated_attributes = {}
            updated_attributes[:name] = params[:name] unless params[:name].blank? || params[:name] == domain.name
            domain.update!(updated_attributes) unless updated_attributes.empty?
            render status: :ok, json: domain
        rescue ActiveRecord::RecordNotFound => e
            raise ApiErrors::NotFound.new("Domain #{params[:id]} does not exist", e)
        rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordNotUnique, ActiveRecord::RecordNotSaved => e
            raise ApiErrors::CannotUpdate.new("Cannot update #{params[:id]} to #{params[:name]}", e)
        end
    end

    def destroy
        begin
            domain = HostedDomain.find(params[:id])
            domain&.destroy!
            head :ok
        rescue ActiveRecord::StaleObjectError => e
            raise ApiErrors::CannotDelete.new("Domain #{params[:id]} could not be deleted", e)
        rescue ActiveRecord::RecordNotDestroyed => e
            raise ApiErrors::CannotDelete.new("Domain #{params[:id]} could not be deleted", e)
        rescue ActiveRecord::RecordNotFound => e
            raise ApiErrors::CannotDelete.new("Domain #{params[:id]} could not be deleted", e)
        rescue => e
            raise ApiErrors::ServerError.new(nil, e)
        end
    end

end
