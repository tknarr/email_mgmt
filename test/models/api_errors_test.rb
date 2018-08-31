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

require 'test_helper'
require 'api_errors'

class ApiErrorsTest < ActiveSupport::TestCase

    test 'basic creation' do
        e = ApiErrors::ServerError.new
        assert_not_nil e
        assert_equal 500, e.http_status, "HTTP status code is not correct."
        assert_equal 'Internal server error', e.message, "Message is not correct."
        assert_equal 'Internal server error', e.to_s, "to_s result is not correct."
    end

    test 'creation with child' do
        e = ApiErrors::ServerError.new('Custom message', ApiErrors::BadRequest.new('Child error'))
        assert_not_nil e
        assert_equal 'Custom message', e.message, "Message is not correct."
        assert_not_nil e.child
        assert_not_nil e.cause
        assert_kind_of ApiErrors::BadRequest, e.child, "Child class is not correct."
        assert_equal 'Child error', e.child.message, "Child message is not correct."
    end

    test 'raise as an exception' do
        assert_raises ApiErrors::ServerError do
            raise ApiErrors::ServerError
        end
        assert_raises ApiErrors::ServerError do
            raise ApiErrors::ServerError, 'Custom message'
        end
        assert_raises ApiErrors::ServerError do
            raise ApiErrors::ServerError.new('Custom message', ApiErrors::BadRequest.new('Child error'))
        end
    end

end
