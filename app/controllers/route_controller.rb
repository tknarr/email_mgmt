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
#           route GET    /email-management/1.0/route/:username/:domain_name(.:format) route#show {:format=>:json, :username=>/([[:alnum:]_.]+|\*)/, :domain_name=>/[[:graph:]]+/}
#                 PATCH  /email-management/1.0/route/:username/:domain_name(.:format) route#update {:format=>:json, :username=>/([[:alnum:]_.]+|\*)/, :domain_name=>/[[:graph:]]+/}
#                 PUT    /email-management/1.0/route/:username/:domain_name(.:format) route#update {:format=>:json, :username=>/([[:alnum:]_.]+|\*)/, :domain_name=>/[[:graph:]]+/}
#                 DELETE /email-management/1.0/route/:username/:domain_name(.:format) route#destroy {:format=>:json, :username=>/([[:alnum:]_.]+|\*)/, :domain_name=>/[[:graph:]]+/}

class RouteController < ApplicationController

  def index
      begin
          routing_list = MailRouting.all
          render status: :ok, json: routing_list
      rescue => e
          raise ApiErrors::ServerError.new(nil, e)
      end
  end

  def create
      begin
          route = MailRouting.create!(address_user: params[:address_user], address_domain: params[:address_domain], recipient: params[:recipient])
          render status: :created, json: route
      rescue ActiveRecord::RecordInvalid => e
          raise ApiErrors::ValidationFailure.new("Validation failure", e)
      rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordNotUnique => e
          raise ApiErrors::AlreadyExists.new("Route #{params[:username]}@#{params[:domain_name]} already exists", e)
      rescue ApiErrors::BaseError => e
          raise e
      rescue => e
          raise ApiErrors::ServerError.new(nil, e)
      end
  end

  def update
      begin
          route = MailRouting.find([params[:username], params[:domain_name]])
          updated_attributes = {}
          [:address_user, :address_domain, :recipient].each do |key|
              updated_attributes[key] = params[key] unless params[key].blank? || params[key] == route[key]
          end
          route.update!(updated_attributes) unless updated_attributes.empty?
          render status: :ok, json: route
      rescue ActiveRecord::RecordNotFound => e
          raise ApiErrors::NotFound.new("Route for #{params[:username]}@#{params[:domain_name]} does not exist", e)
      rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordNotUnique, ActiveRecord::RecordNotSaved => e
          raise ApiErrors::CannotUpdate.new("Cannot update route for #{params[:username]}@#{params[:domain_name]}", e)
      rescue ApiErrors::BaseError => e
          raise e
      rescue => e
          raise ApiErrors::ServerError.new(nil, e)
      end
  end

  def destroy
      begin
          route =  MailRouting.find([params[:username], params[:domain_name]])
          route&.destroy!
          head :ok
      rescue ActiveRecord::StaleObjectError => e
          raise ApiErrors::CannotDelete.new("Route #{params[:username]}@#{params[:domain_name]} could not be deleted", e)
      rescue ActiveRecord::RecordNotDestroyed => e
          raise ApiErrors::CannotDelete.new("Route #{params[:username]}@#{params[:domain_name]} could not be deleted", e)
      rescue ActiveRecord::RecordNotFound => e
          raise ApiErrors::CannotDelete.new("Route #{params[:username]}@#{params[:domain_name]} could not be deleted", e)
      rescue ApiErrors::BaseError => e
          raise e
      rescue => e
          raise ApiErrors::ServerError.new(nil, e)
      end
  end

end
