DROP FUNCTION IF EXISTS resolveAddress;
DROP VIEW IF EXISTS v_passwd;
DROP TABLE IF EXISTS mail_routing;
DROP TABLE IF EXISTS mail_users;
DROP TABLE IF EXISTS hosted_domains;
DROP TABLE IF EXISTS acct_types;

CREATE TABLE acct_types (
    code         CHAR(1)     NOT NULL PRIMARY KEY,
    description  VARCHAR(50),
    abbreviation VARCHAR(10),
    home_root    VARCHAR(50) NOT NULL,
    uid          VARCHAR(20),
    gid          VARCHAR(20),
    transport    VARCHAR(100)
);

CREATE TABLE hosted_domains (
    name VARCHAR(50) NOT NULL PRIMARY KEY
);

CREATE TABLE mail_users (
    username        VARCHAR(50)  NOT NULL PRIMARY KEY,
    password_digest VARCHAR(200) NOT NULL,
    change_attempts INT          DEFAULT 0,
    acct_type       CHAR(1)      NOT NULL,
    admin           INT          DEFAULT 0,
    FOREIGN KEY (acct_type) REFERENCES acct_types (code)
);

CREATE TABLE mail_routing (
    address_user   VARCHAR(50) NOT NULL,
    address_domain VARCHAR(50) NOT NULL,
    recipient      VARCHAR(50) NOT NULL,
    PRIMARY KEY (address_user, address_domain)
);

CREATE SQL SECURITY INVOKER VIEW v_passwd AS
    SELECT u.username                        AS username,
           u.password_digest                 AS password,
           u.acct_type                       AS acct_type,
           IFNULL( a.uid, u.username )       AS uid,
           IFNULL( a.gid, u.username )       AS gid,
           CONCAT( a.home_root, u.username ) AS home,
           a.transport                       AS transport
    FROM mail_users AS u, acct_types AS a
    WHERE u.acct_type = a.code;

DELIMITER //
CREATE FUNCTION resolveAddress( user VARCHAR(50), domain VARCHAR(100) )
    RETURNS VARCHAR(50)
DETERMINISTIC
READS SQL DATA
    SQL SECURITY INVOKER
    BEGIN
        DECLARE r VARCHAR(50);
        DECLARE d VARCHAR(50);

        DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET @garbage = 1;

        SELECT name
            INTO d
            FROM hosted_domains
            WHERE name = domain;
        IF d IS NULL
        THEN
            RETURN r;
        END IF;

        SELECT recipient
            INTO r
            FROM mail_routing
            WHERE address_user = user AND address_domain = domain;
        IF r IS NULL
        THEN
            SELECT recipient
                INTO r
                FROM mail_routing
                WHERE address_user = user AND address_domain = '*';
        END IF;
        IF r IS NULL
        THEN
            SELECT recipient
                INTO r
                FROM mail_routing
                WHERE address_user = '*' AND address_domain = domain;
        END IF;
        IF r IS NULL
        THEN
            SELECT recipient
                INTO r
                FROM mail_routing
                WHERE address_user = '*' AND address_domain = '*';
        END IF;

        RETURN r;
    END
//
DELIMITER ;
