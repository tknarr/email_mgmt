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

class SystemAliasController < ApplicationController

    def index
        begin
            aliases = SystemAlias.get_aliases
            render status: :ok, json: aliases
        rescue => e
            raise ApiErrors::ServerError.new(nil, e)
        end
    end

    def merged_index
        begin
            alias_users = SystemAlias.get_merged_aliases
            render status: :ok, json: alias_users
        rescue => e
            raise ApiErrors::ServerError.new(nil, e)
        end
    end

    def sync
        begin
            # NOTE alias users currently not supported
            # alias_users = SystemAlias.do_sync
            # render status: :ok, json: alias_users
            raise ApiErrors::NotImplemented.new("Sync Aliases not implemented")
        rescue ApiErrors::BaseError => e
            raise e
        rescue => e
            raise ApiErrors::ServerError.new(nil, e)
        end
    end

end
