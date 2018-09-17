# == Schema Information
#
# Table name: hosted_domains
#
#  name :string(50)       not null, primary key
#

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

class HostedDomain < ApplicationRecord
    validates_presence_of :name

    # Returns all domains as objects containing the domain name and the default
    # recipient (or nil if none).
    def self.all_routing
        find_by_sql(
            'SELECT name, mail_routing.recipient AS default_recipient' \
                ' FROM hosted_domains' \
                ' LEFT JOIN mail_routing on name = mail_routing.address_domain AND mail_routing.address_user = \'*\''
        )
    end

end
