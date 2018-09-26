
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `acct_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `acct_types` (
  `code` char(1) NOT NULL,
  `description` varchar(50) DEFAULT NULL,
  `abbreviation` varchar(10) DEFAULT NULL,
  `home_root` varchar(50) DEFAULT NULL,
  `uid` varchar(20) DEFAULT NULL,
  `gid` varchar(20) DEFAULT NULL,
  `transport` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ar_internal_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `hosted_domains`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hosted_domains` (
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `mail_routing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mail_routing` (
  `address_user` varchar(50) NOT NULL,
  `address_domain` varchar(50) NOT NULL,
  `recipient` varchar(50) NOT NULL,
  PRIMARY KEY (`address_user`,`address_domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `mail_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mail_users` (
  `username` varchar(50) NOT NULL,
  `password_digest` varchar(200) NOT NULL,
  `change_attempts` int(11) DEFAULT '0',
  `acct_type` char(1) NOT NULL,
  `admin` int(11) DEFAULT '0',
  PRIMARY KEY (`username`),
  KEY `acct_type` (`acct_type`),
  CONSTRAINT `mail_users_ibfk_1` FOREIGN KEY (`acct_type`) REFERENCES `acct_types` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `v_passwd`;
/*!50001 DROP VIEW IF EXISTS `v_passwd`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `v_passwd` (
  `username` tinyint NOT NULL,
  `password` tinyint NOT NULL,
  `acct_type` tinyint NOT NULL,
  `uid` tinyint NOT NULL,
  `gid` tinyint NOT NULL,
  `home` tinyint NOT NULL,
  `transport` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;
/*!50003 DROP FUNCTION IF EXISTS `resolveAddress` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`email_mgmt`@`localhost` FUNCTION `resolveAddress`( user VARCHAR(50), domain VARCHAR(100) ) RETURNS varchar(50) CHARSET utf8
    READS SQL DATA
    DETERMINISTIC
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
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50001 DROP TABLE IF EXISTS `v_passwd`*/;
/*!50001 DROP VIEW IF EXISTS `v_passwd`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`email_mgmt`@`localhost` SQL SECURITY INVOKER */
/*!50001 VIEW `v_passwd` AS select `u`.`username` AS `username`,`u`.`password_digest` AS `password`,`u`.`acct_type` AS `acct_type`,ifnull(`a`.`uid`,`u`.`username`) AS `uid`,ifnull(`a`.`gid`,`u`.`username`) AS `gid`,if((`a`.`home_root` is not null),concat(`a`.`home_root`,`u`.`username`),'') AS `home`,`a`.`transport` AS `transport` from (`mail_users` `u` join `acct_types` `a`) where (`u`.`acct_type` = `a`.`code`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;



