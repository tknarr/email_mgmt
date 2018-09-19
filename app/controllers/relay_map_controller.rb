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
#           Prefix Verb   URI Pattern                                                  Controller#Action
#    relay_domains GET    /email-management/1.0/relay_map/domains(.:format)            relay_map#domains
# relay_recipients GET    /email-management/1.0/relay_map/recipients(.:format)         relay_map#recipients

class RelayMapController < ApplicationController
    skip_before_action :authenticate
    skip_before_action :require_admin
    before_action :require_token

    def domains
        begin
            result_text = ''
            domain_list = HostedDomain.all.order(:name)
            domain_list.each do |domain_entry|
                result_text << domain_entry.name << "\tOK\n"
            end
            render status: :ok, plain: result_text
        rescue => e
            raise ApiErrors::ServerError.new(nil, e)
        end
    end

    def recipients
        begin
            result_lines = []
            # Collect list of domain names for wildcard expansion later
            domain_name_list = []
            begin
                domain_list = HostedDomain.order(:name)
                domain_list.each do |domain_entry|
                    domain_name_list << domain_entry.name
                end
            rescue => e
                raise ApiErrors::ServerError.new(nil, e)
            end
            # Pull non-wildcard user routing entries, expand wildcard domains where needed and output
            route_list = MailRouting.where.not(address_user: '*').order(:address_user, :address_domain)
            route_list.each do |route_entry|
                username = route_entry.address_user
                domain = route_entry.address_domain
                if domain == '*'
                    domain_name_list.each do |domain_name|
                        result_lines << "#{username}@#{domain_name}\tOK"
                    end
                else
                    result_lines << "#{username}@#{domain}\tOK"
                end
            end
            # Pull wildcard user routing entries and output them, expanding wildcard domains where needed
            route_list = MailRouting.where(address_user: '*').order(:address_user, :address_domain)
            route_list.each do |route_entry|
                domain_name = route_entry.address_domain
                # Skip the *@* wildcard at the moment
                unless domain_name == '*'
                    result_lines << "@#{domain_name}\tOK"
                end
            end
            # Now handle the *@* wildcard if any
            route_list = MailRouting.where(address_user: '*', address_domain: '*')
            unless route_list.empty?
                # Generate wildcard domain lines for every domain we host that doesn't already have one
                domain_name_list.each do |domain_name|
                    line = "@#{domain_name}\tOK"
                    unless result_lines.include? line
                        result_lines << line
                    end
                end
            end
            result_text = ''
            result_lines.each do |line|
                result_text << "#{line}\n"
            end
            render status: :ok, plain: result_text
        rescue => e
            raise ApiErrors::ServerError.new(nil, e)
        end
    end

    private

    def require_token
        token = params[:token]
        unless !token.blank? && token == Settings.backup_mx_token
            head status: :forbidden
        end
    end

end
