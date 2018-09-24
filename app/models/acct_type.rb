# == Schema Information
#
# Table name: acct_types
#
#  code         :string(1)        not null, primary key
#  description  :string(50)
#  abbreviation :string(10)
#  home_root    :string(50)
#  uid          :string(20)
#  gid          :string(20)
#  transport    :string(100)
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

class AcctType < ApplicationRecord
    self.primary_key = :code
    validates_presence_of :code, :description

end
