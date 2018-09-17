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

module ApiErrors

    class Serializer < ActiveModel::Serializer
        attributes :message, :child
    end

    class BaseError < RuntimeError
        include ActiveModel::Serialization

        # @return [Integer]
        attr_reader :http_status

        # @return [String, Nil]
        attr_reader :message

        # @return [BaseError, Nil]
        attr_reader :child

        # @param http_status [Integer,Symbol]
        # @param msg [String, Nil]
        # @param child [StandardError, Nil]
        def initialize(http_status, msg, child = nil)
            super(msg)
            @http_status = Rack::Utils::status_code(http_status)
            @message = msg || superclass.message
            @child = child
        end

        # @return [StandardError]
        def cause
            child
        end

        # @return [String]
        def to_s
            message
        end

    end

    class ServerError < BaseError
        def initialize(msg = nil, child = nil)
            super(:server_error, msg || "Internal server error", child)
        end
    end

    class BadRequest < BaseError
        def initialize(msg = nil, child = nil)
            super(:bad_request, msg || "Bad request", child)
        end
    end

    class NotFound < BaseError
        def initialize(msg = nil, child = nil)
            super(:not_found, msg || "Not found", child)
        end
    end

    class CannotCreate < BaseError
        def initialize(msg = nil, child = nil)
            super(:conflict, msg || "Cannot create", child)
        end
    end

    class AlreadyExists < BaseError
        def initialize(msg = nil, child = nil)
            super(:conflict, msg || "Already exists", child)
        end
    end

    class CannotDelete < BaseError
        def initialize(msg = nil, child = nil)
            super(:conflict, msg || "Cannot delete", child)
        end
    end

    class ValidationFailure < BaseError
        def initialize(msg = nil, child = nil)
            super(:unprocessable_entity, msg || "Validation failure", child)
        end
    end

    class CannotUpdate < BaseError
        def initialize(msg = nil, child = nil)
            super(:conflict, msg || "Cannot update", child)
        end
    end

    class NoChange < BaseError
        def initialize(msg = nil, child = nil)
            super(:no_content, msg || "No change", child)
        end
    end

    class AuthenticationFailure < BaseError
        def initialize(msg = nil, child = nil)
            super(:forbidden, msg || "Authentication failed", child)
        end
    end

    class InvalidArguments < BaseError
        def initialize(msg = nil, child = nil)
            super(:unprocessable_entity, msg || "Invalid arguments", child)
        end
    end

    class AliasConflict < BaseError
        def initialize(msg = nil, child = nil)
            super(:conflict, msg || "Alias conflicts with non-alias user", child)
        end
    end

end
