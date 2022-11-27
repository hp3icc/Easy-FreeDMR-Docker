
USE hbmon;

--
-- Table structure for table `Clients`
--

DROP TABLE IF EXISTS `Clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Clients` (
  `int_id` int(11) NOT NULL,
  `dmr_id` tinyblob NOT NULL,
  `callsign` varchar(10) NOT NULL,
  `host` varchar(15) DEFAULT NULL,
  `options` varchar(300) DEFAULT NULL,
  `opt_rcvd` tinyint(1) NOT NULL DEFAULT 0,
  `mode` tinyint(1) NOT NULL DEFAULT 4,
  `logged_in` tinyint(1) NOT NULL DEFAULT 0,
  `modified` tinyint(1) NOT NULL DEFAULT 0,
  `psswd` blob DEFAULT NULL,
  `last_seen` int(11) NOT NULL,
  PRIMARY KEY (`int_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `last_heard`
--

DROP TABLE IF EXISTS `last_heard`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `last_heard` (
  `date_time` datetime NOT NULL,
  `qso_time` decimal(5,2) DEFAULT NULL,
  `qso_type` varchar(20) NOT NULL,
  `system` varchar(50) NOT NULL,
  `tg_num` int(11) NOT NULL,
  `dmr_id` int(11) NOT NULL,
  PRIMARY KEY (`dmr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lstheard_log`
--

DROP TABLE IF EXISTS `lstheard_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lstheard_log` (
  `date_time` datetime NOT NULL,
  `qso_time` decimal(5,2) DEFAULT NULL,
  `qso_type` varchar(20) NOT NULL,
  `system` varchar(50) NOT NULL,
  `tg_num` int(11) NOT NULL,
  `dmr_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `peer_ids`
--

DROP TABLE IF EXISTS `peer_ids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `peer_ids` (
  `id` int(11) NOT NULL,
  `callsign` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subscriber_ids`
--

DROP TABLE IF EXISTS `subscriber_ids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscriber_ids` (
  `id` int(11) NOT NULL,
  `callsign` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `talkgroup_ids`
--

DROP TABLE IF EXISTS `talkgroup_ids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `talkgroup_ids` (
  `id` int(11) NOT NULL,
  `callsign` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tg_count`
--

DROP TABLE IF EXISTS `tg_count`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tg_count` (
  `date` datetime NOT NULL,
  `tg_num` int(11) NOT NULL,
  `qso_count` int(11) NOT NULL,
  `qso_time` decimal(7,2) NOT NULL,
  PRIMARY KEY (`tg_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_count`
--

DROP TABLE IF EXISTS `user_count`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_count` (
  `date` datetime NOT NULL,
  `tg_num` int(11) NOT NULL,
  `dmr_id` int(11) NOT NULL,
  `qso_time` decimal(7,2) NOT NULL,
  UNIQUE KEY `tg_num` (`tg_num`,`dmr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
