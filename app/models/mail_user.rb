# == Schema Information
#
# Table name: mail_users
#
#  username        :string(50)       not null, primary key
#  password_digest :string(200)      not null
#  change_attempts :integer          default(0)
#  acct_type       :string(1)        not null
#  admin           :integer          default(0)
#
# Indexes
#
#  acct_type  (acct_type)
#
# Foreign Keys
#
#  mail_users_ibfk_1  (acct_type => acct_types.code)
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

class MailUser < ApplicationRecord
    has_secure_password
    validates_presence_of :username, :password_digest, :acct_type

    def as_json(options = nil)
        super((options || {}).merge(except: %i[password password_digest]))
    end

end
