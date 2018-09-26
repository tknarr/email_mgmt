/*
    email_mgmt
    Copyright (C) 2018 Silverglass Technical
    Author: Todd Knarr <tknarr@silverglass.org>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

-- Script should be run as the MySQL root/admin user

CREATE DATABASE email;

CREATE USER email_mgmt@localhost IDENTIFIED BY 'changeme';
REVOKE ALL PRIVILEGES, GRANT OPTION ON *.* FROM email_mgmt@localhost;
GRANT DELETE, EXECUTE, INSERT, SELECT, UPDATE, USAGE
    ON email.*
    TO email_mgmt@localhost;

CREATE USER email_mgmt_admin@localhost IDENTIFIED BY 'changeme';
REVOKE ALL PRIVILEGES, GRANT OPTION ON *.* FROM email_mgmt_admin@localhost;
GRANT ALTER, ALTER ROUTINE, CREATE, CREATE ROUTINE, CREATE VIEW, DELETE,
      DROP, EXECUTE, INDEX, INSERT, LOCK TABLES, REFERENCES, RELOAD, SELECT,
      SHOW VIEW, UPDATE, USAGE
    ON email.*
    TO email_mgmt_admin@localhost;
