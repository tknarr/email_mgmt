# == Schema Information
#
# Table name: mail_routing
#
#  address_user   :string(50)       not null, primary key
#  address_domain :string(50)       not null, primary key
#  recipient      :string(50)       not null
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

class MailRouting < ApplicationRecord
    self.table_name = 'mail_routing'
    self.primary_keys = :address_user, :address_domain
    validates_presence_of :address_user, :address_domain, :recipient

end
