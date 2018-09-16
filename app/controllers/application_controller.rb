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

require 'api_errors'

class ApplicationController < ActionController::API
    include ActionController::HttpAuthentication::Basic::ControllerMethods
    rescue_from ApiErrors::BaseError, with: :render_error
    before_action :authenticate
    before_action :require_admin

    @admin = false
    @current_username = nil

    def initialize
        super
    end

    def current_username
        @current_username
    end

    def admin?
        @admin
    end

    # @return [Boolean]
    def is_current_user?(username)
        username == current_username
    end

    private

    def authenticate
        authenticate_or_request_with_http_basic("Email Management") do |username, password|
            @admin = false
            @current_username = nil
            begin
                user = MailUser.find(username)
            rescue
                user = nil
            end
            result = user&.authenticate(password)
            # Don't allow alias users to log in
            result = false if user.acct_type == 'A'
            if result
                @current_username = user.username
                @admin = user.admin != 0
            end
            result
        end
    end

    def require_admin
        render status: :forbidden, json: {message: "Administrator access only"} unless @admin
    end

    # @param e [ApiErrors::BaseError]
    def render_error(e)
        render status: e.http_status, json: e, serializer: ApiErrors::Serializer
    end

end
