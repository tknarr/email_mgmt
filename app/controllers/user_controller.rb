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
#            user PATCH  /email-management/1.0/user/:id(.:format)                     user#update {:format=>:json, :id=>/[[:alnum:]_.]+/}
#                 PUT    /email-management/1.0/user/:id(.:format)                     user#update {:format=>:json, :id=>/[[:alnum:]_.]+/}
#                 DELETE /email-management/1.0/user/:id(.:format)                     user#destroy {:format=>:json, :id=>/[[:alnum:]_.]+/}
#    current_user GET    /email-management/1.0/user(.:format)                         user#current {:format=>:json}
# update_password POST   /email-management/1.0/password(.:format)                     user#update_password {:format=>:json}

class UserController < ApplicationController
    skip_before_action :require_admin, only: [:current, :update_password]

    def index
        begin
            user_list = MailUser.all
            render status: :ok, json: user_list
        rescue => e
            raise ApiErrors::ServerError.new(nil, e)
        end
    end

    def passwd
        begin
            user_list = VPasswd.all
            render status: :ok, json: user_list
        rescue => e
            raise ApiErrors::ServerError.new(nil, e)
        end
    end

    def create
        begin
            if Rails.env.production?
                VirtualUser.create_home params[:username]
            end
            # Force locked password digest for alias users
            user = if params[:acct_type] == 'A'
                       MailUser.create!(username: params[:username], password_digest: 'x', acct_type: params[:acct_type])
                   else
                       MailUser.create!(username: params[:username], password: params[:password], acct_type: params[:acct_type])
                   end
            render status: :created, json: user
        rescue ActiveRecord::RecordInvalid => e
            raise ApiErrors::ValidationFailure.new("Validation failure", e)
        rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordNotUnique => e
            raise ApiErrors::AlreadyExists.new("User #{params[:username]} already exists", e)
        rescue ApiErrors::BaseError => e
            raise e
        rescue => e
            raise ApiErrors::ServerError.new(nil, e)
        end
    end

    def update
        begin
            user = MailUser.find params[:id]
            updated_attributes = {}
            [:username, :password, :acct_type, :change_attempts, :admin].each do |key|
                updated_attributes[key] = params[key] unless params[key].blank? || params[key] == user[key]
            end
            # Don't allow changing the username or admin flag of the current user
            if is_current_user?(params[:id])
                updated_attributes.delete(:username)
                updated_attributes.delete(:admin)
            end
            # Don't allow password or account type changes for alias users
            if user.acct_type == 'A'
                updated_attributes.delete(:password)
                updated_attributes.delete(:acct_type)
                updated_attributes.delete(:admin)
            end
            user.update!(updated_attributes) unless updated_attributes.empty?
            if Rails.env.production? && updated_attributes[:username]
                VirtualUser.rename_home params[:id], updated_attributes[:username]
            end
            render status: :ok, json: user
        rescue ActiveRecord::RecordNotFound => e
            raise ApiErrors::NotFound.new("User #{params[:id]} does not exist", e)
        rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordNotSaved => e
            raise ApiErrors::CannotUpdate.new("Cannot update user #{params[:id]}", e)
        rescue ApiErrors::BaseError => e
            raise e
        rescue => e
            raise ApiErrors::ServerError.new(nil, e)
        end
    end

    def destroy
        begin
            user = MailUser.find params[:id]
            # Don't allow deleting the current user
            if is_current_user?(params[:id])
                raise ApiErrors::CannotDelete.new("Current user could not be deleted")
            end
            user&.destroy!
            if Rails.env.production?
                VirtualUser.remove_home params[:id]
            end
            head :ok
        rescue ActiveRecord::StaleObjectError => e
            raise ApiErrors::CannotDelete.new("User #{params[:id]} could not be deleted", e)
        rescue ActiveRecord::RecordNotDestroyed => e
            raise ApiErrors::CannotDelete.new("User #{params[:id]} could not be deleted", e)
        rescue ActiveRecord::RecordNotFound => e
            raise ApiErrors::CannotDelete.new("User #{params[:id]} could not be deleted", e)
        rescue ApiErrors::BaseError => e
            raise e
        rescue => e
            raise ApiErrors::ServerError.new(nil, e)
        end
    end

    def current
        begin
            user = MailUser.find current_username
            render status: :ok, json: user
        rescue ActiveRecord::RecordNotFound => e
            raise ApiErrors::NotFound.new("User #{current_username} not found", e)
        rescue ApiErrors::BaseError => e
            raise e
        rescue => e
            raise ApiErrors::ServerError.new(nil, e)
        end
    end

    def update_password
        begin
            user = MailUser.find current_username
            if user.authenticate(params[:current_password]) && user.change_attempts < 5
                user.password = params[:new_password]
                user.change_attempts = 0
                user.save!
                head :ok
            else
                user.change_attempts += 1
                user.save!
                raise ApiErrors::AuthenticationFailure.new("Invalid password for #{current_username}")
            end
        rescue ActiveRecord::RecordNotFound => e
            raise ApiErrors::NotFound.new("User #{current_username} not found", e)
        rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
            raise ApiErrors::ValidationFailure.new("Cannot update password for user #{current_username}", e)
        rescue ApiErrors::BaseError => e
            raise e
        rescue => e
            raise ApiErrors::ServerError.new(nil, e)
        end
    end

end
