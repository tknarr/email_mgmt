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

class AccountTypeController < ApplicationController
    skip_before_action :require_admin

    def index
        begin
            type_list = AcctType.all
            render status: :ok, json: type_list
        rescue => e
            raise ApiErrors::ServerError.new(nil, e)
        end
    end

end
