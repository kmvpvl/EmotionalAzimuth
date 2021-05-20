-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: May 20, 2021 at 05:39 AM
-- Server version: 10.5.8-MariaDB
-- PHP Version: 7.4.15

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ea`
--
CREATE DATABASE IF NOT EXISTS `ea` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `ea`;

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `getAssignInfo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getAssignInfo` (IN `_assign_id` BIGINT)  NO SQL
select `assigns`.*, `sets`.`name` as set_name, `persons`.`fullname` as author  
from `assigns`
left join `sets` on `sets`.`id`=`assigns`.`set_id`
left join `persons` on `persons`.`id`=`sets`.`author_id`
where `assigns`.`id`=`_assign_id`$$

DROP PROCEDURE IF EXISTS `getAssignsOnUser`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getAssignsOnUser` (IN `_user_id` BIGINT)  NO SQL
select `assigns`.*, `sets`.`name` as set_name, `persons`.`fullname` as author  
from `assigns`
left join `sets` on `sets`.`id`=`assigns`.`set_id`
left join `persons` on `persons`.`id`=`sets`.`author_id`
where `assigns`.`person_id`=`_user_id`$$

DROP PROCEDURE IF EXISTS `getLexemesBySetId`$$
CREATE DEFINER=`ea`@`localhost` PROCEDURE `getLexemesBySetId` (IN `_set_id` BIGINT)  READS SQL DATA
    SQL SECURITY INVOKER
BEGIN
select `lexemes`.* 
from `refs`
left JOIN `lexemes` on `lexemes`.`id`=`refs`.`lexeme_id`
where `refs`.`set_id`=`_set_id` and `lexemes`.`stopword` <> 1;
END$$

DROP PROCEDURE IF EXISTS `getSetInfo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getSetInfo` (IN `_set_id` BIGINT)  NO SQL
select `sets`.*, `persons`.`name` as `author_name`, `persons`.`fullname` as `author_fullname`
from `sets`
left join `persons` on `persons`.`id`=`sets`.`author_id`
where `sets`.`id`=`_set_id`$$

DROP PROCEDURE IF EXISTS `getUserByName`$$
CREATE DEFINER=`ea`@`localhost` PROCEDURE `getUserByName` (IN `_name` VARCHAR(250))  READS SQL DATA
    SQL SECURITY INVOKER
select * from `persons` where `persons`.`name` = `_name`$$

DROP PROCEDURE IF EXISTS `startAssign`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `startAssign` (IN `_assign_id` BIGINT)  NO SQL
BEGIN
select `assigns`.`start_date` into @start_date 
from `assigns` where `assigns`.id=`_assign_id`;

IF @start_date is null THEN
update `assigns` set `assigns`.`start_date`=CURRENT_TIMESTAMP();
end IF;
select `assigns`.*, `sets`.`name` as set_name, `persons`.`fullname` as author  
from `assigns`
left join `sets` on `sets`.`id`=`assigns`.`set_id`
left join `persons` on `persons`.`id`=`sets`.`author_id`
where `assigns`.`id`=`_assign_id`;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `assesments`
--

DROP TABLE IF EXISTS `assesments`;
CREATE TABLE `assesments` (
  `id` bigint(20) NOT NULL,
  `lexeme_id` bigint(20) NOT NULL,
  `person_id` bigint(20) NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `joy` float NOT NULL,
  `trust` float NOT NULL,
  `fear` float NOT NULL,
  `surprise` float NOT NULL,
  `sadness` float NOT NULL,
  `disgust` float NOT NULL,
  `anger` float NOT NULL,
  `anticipation` float NOT NULL,
  `changed` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `assigns`
--

DROP TABLE IF EXISTS `assigns`;
CREATE TABLE `assigns` (
  `id` bigint(20) NOT NULL,
  `person_id` bigint(20) NOT NULL,
  `set_id` bigint(20) NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `changed` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `due_date` datetime NOT NULL,
  `start_date` datetime DEFAULT NULL,
  `finish_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `assigns`
--

INSERT INTO `assigns` (`id`, `person_id`, `set_id`, `created`, `changed`, `due_date`, `start_date`, `finish_date`) VALUES
(1, 1, 1, '2021-05-11 14:23:24', '2021-05-19 18:12:33', '2021-05-17 17:23:11', '2021-05-19 22:12:33', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `langs`
--

DROP TABLE IF EXISTS `langs`;
CREATE TABLE `langs` (
  `lang` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `langs`
--

INSERT INTO `langs` (`lang`) VALUES
('en-US'),
('ru-RU');

-- --------------------------------------------------------

--
-- Table structure for table `lexemes`
--

DROP TABLE IF EXISTS `lexemes`;
CREATE TABLE `lexemes` (
  `id` bigint(20) NOT NULL,
  `lexeme` varchar(250) NOT NULL,
  `lang` varchar(5) NOT NULL,
  `stopword` tinyint(1) NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `changed` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `lexemes`
--

INSERT INTO `lexemes` (`id`, `lexeme`, `lang`, `stopword`, `created`, `changed`) VALUES
(1, 'призрачный шанс', 'ru-RU', 0, '2021-05-11 09:28:35', '2021-05-11 09:28:35'),
(2, 'долгожданный малыш', 'ru-RU', 0, '2021-05-11 09:28:35', '2021-05-11 09:28:35');

-- --------------------------------------------------------

--
-- Table structure for table `persons`
--

DROP TABLE IF EXISTS `persons`;
CREATE TABLE `persons` (
  `id` bigint(20) NOT NULL,
  `name` varchar(250) NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `changed` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `fullname` varchar(250) DEFAULT NULL,
  `hash` varchar(36) DEFAULT NULL,
  `lang` varchar(5) DEFAULT NULL,
  `roles` varchar(1024) NOT NULL,
  `email` varchar(250) NOT NULL,
  `telegram` varchar(250) NOT NULL,
  `birthdate` date DEFAULT NULL,
  `location` varchar(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `persons`
--

INSERT INTO `persons` (`id`, `name`, `created`, `changed`, `fullname`, `hash`, `lang`, `roles`, `email`, `telegram`, `birthdate`, `location`) VALUES
(1, 'pavel', '2021-05-11 09:29:43', '2021-05-13 16:48:43', 'Комов Павел', '2812c4759afcf88f1a1d3c123102a273', 'ru-RU', '', '', '', NULL, NULL),
(2, 'Komo-pet', '2021-05-13 18:30:37', '2021-05-13 18:30:37', 'Комов Петр', NULL, 'ru-RU', '', '', '', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `refs`
--

DROP TABLE IF EXISTS `refs`;
CREATE TABLE `refs` (
  `id` bigint(20) NOT NULL,
  `set_id` bigint(20) NOT NULL,
  `lexeme_id` bigint(20) NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `changed` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `refs`
--

INSERT INTO `refs` (`id`, `set_id`, `lexeme_id`, `created`, `changed`) VALUES
(1, 1, 1, '2021-05-11 14:21:52', '2021-05-11 14:21:52'),
(2, 1, 2, '2021-05-11 14:21:52', '2021-05-11 14:21:52');

-- --------------------------------------------------------

--
-- Table structure for table `sets`
--

DROP TABLE IF EXISTS `sets`;
CREATE TABLE `sets` (
  `id` bigint(20) NOT NULL,
  `name` varchar(250) NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `changed` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `author_id` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `sets`
--

INSERT INTO `sets` (`id`, `name`, `created`, `changed`, `author_id`) VALUES
(1, 'test set', '2021-05-11 14:19:03', '2021-05-13 18:31:02', 2);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `assesments`
--
ALTER TABLE `assesments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `person_id` (`person_id`),
  ADD KEY `lexeme_id` (`lexeme_id`);

--
-- Indexes for table `assigns`
--
ALTER TABLE `assigns`
  ADD PRIMARY KEY (`id`),
  ADD KEY `person_id` (`person_id`),
  ADD KEY `set_id` (`set_id`);

--
-- Indexes for table `langs`
--
ALTER TABLE `langs`
  ADD PRIMARY KEY (`lang`);

--
-- Indexes for table `lexemes`
--
ALTER TABLE `lexemes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `lexeme` (`lexeme`,`lang`) USING BTREE,
  ADD KEY `lang` (`lang`);

--
-- Indexes for table `persons`
--
ALTER TABLE `persons`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `lang` (`lang`);

--
-- Indexes for table `refs`
--
ALTER TABLE `refs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `set_id` (`set_id`),
  ADD KEY `lexeme_id` (`lexeme_id`);

--
-- Indexes for table `sets`
--
ALTER TABLE `sets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `author_id` (`author_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `assesments`
--
ALTER TABLE `assesments`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `assigns`
--
ALTER TABLE `assigns`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `lexemes`
--
ALTER TABLE `lexemes`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `persons`
--
ALTER TABLE `persons`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `refs`
--
ALTER TABLE `refs`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `sets`
--
ALTER TABLE `sets`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `assesments`
--
ALTER TABLE `assesments`
  ADD CONSTRAINT `assesments_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `persons` (`id`),
  ADD CONSTRAINT `assesments_ibfk_2` FOREIGN KEY (`lexeme_id`) REFERENCES `lexemes` (`id`);

--
-- Constraints for table `assigns`
--
ALTER TABLE `assigns`
  ADD CONSTRAINT `assigns_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `persons` (`id`),
  ADD CONSTRAINT `assigns_ibfk_2` FOREIGN KEY (`set_id`) REFERENCES `sets` (`id`);

--
-- Constraints for table `lexemes`
--
ALTER TABLE `lexemes`
  ADD CONSTRAINT `lexemes_ibfk_1` FOREIGN KEY (`lang`) REFERENCES `langs` (`lang`);

--
-- Constraints for table `persons`
--
ALTER TABLE `persons`
  ADD CONSTRAINT `persons_ibfk_1` FOREIGN KEY (`lang`) REFERENCES `langs` (`lang`);

--
-- Constraints for table `refs`
--
ALTER TABLE `refs`
  ADD CONSTRAINT `refs_ibfk_1` FOREIGN KEY (`lexeme_id`) REFERENCES `lexemes` (`id`),
  ADD CONSTRAINT `refs_ibfk_2` FOREIGN KEY (`set_id`) REFERENCES `sets` (`id`);

--
-- Constraints for table `sets`
--
ALTER TABLE `sets`
  ADD CONSTRAINT `sets_ibfk_1` FOREIGN KEY (`author_id`) REFERENCES `persons` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
