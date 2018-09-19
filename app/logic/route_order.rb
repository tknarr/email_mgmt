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

module RouteOrder

    # Compares in the way the primary index of the mail routing table will.
    # Used for sorting fixtures to match the database order.
    #
    # @param a [MailRouting]
    # @param b [MailRouting]
    # @return [Integer]
    def self.key_compare(a, b)
        if (a.address_user < b.address_user) || (a.address_user == b.address_user && a.address_domain < b.address_domain)
            -1
        elsif (a.address_user > b.address_user) || (a.address_user == b.address_user && a.address_domain > b.address_domain)
            1
        else
            0
        end
    end

    # Compares in the way the routes should be listed with normal users first sorted by domain then user,
    # then user@* sorted by user, then *@domain sorted by domain, and *@* last
    #
    # @param a [MailRouting]
    # @param b [MailRouting]
    # @return [Integer]
    def self.entry_compare(a, b)
        category_a = categorize_address(a.address_user, a.address_domain)
        category_b = categorize_address(b.address_user, b.address_domain)

        if category_a != category_b
            if category_a < category_b
                -1
            elsif category_a > category_b
                1
            end
        else
            entry_primitive_compare a, b
        end
    end

    # Helper to ategorize a user,domain pair, returning:
    # 0 -> normal user
    # 1 -> user@*
    # 2 -> *@domain
    # 3 -> *@*
    #
    # @param user [String]
    # @param domain [String]
    # @return [Integer]
    def self.categorize_address(user, domain)
        if user == '*'
            if domain == '*'
                3
            else
                2
            end
        elsif domain == '*' then
            1
        else
            0
        end
    end

    # Helper for entry comparison of normal users.
    def self.entry_primitive_compare(a, b)
        if (a.address_domain < b.address_domain) || (a.address_domain == b.address_domain && a.address_user < b.address_user)
            -1
        elsif (a.address_domain > b.address_domain) || (a.address_domain == b.address_domain && a.address_user > b.address_user)
            1
        else
            0
        end
    end

    # Sort a list of routing entries by entry ordering as defined for entry_compare
    #
    # @param routing_list [Array<MailRouting]
    # @return [Array<MailRouting>]
    def self.entry_sort(routing_list)
        categories = [[], [], [], []]
        # Split entries into categories in category order
        routing_list.each do |entry|
            category = categorize_address(entry.address_user, entry.address_domain)
            categories[category] << entry
        end
        # Sort categories, each one is in entry order within the category. *@* doesn't need
        # sorted, there's only one possible value.
        for i in 0..2 do
            categories[i].sort! do |a, b|
                entry_primitive_compare a, b
            end
        end
        categories[0].concat categories[1], categories[2], categories[3]
    end

end
