-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: May 27, 2021 at 05:27 AM
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

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `getAssessmentsByAssignID`$$
CREATE DEFINER=`ea`@`localhost` PROCEDURE `getAssessmentsByAssignID` (IN `_assign_id` BIGINT)  READS SQL DATA
    SQL SECURITY INVOKER
select `assessments`.`id`
,`lexemes`.`id` as `lexeme_id`
,`lexemes`.`lexeme`, `lexemes`.`lang`
,`assessments`.`joy`
,`assessments`.`trust`
,`assessments`.`fear`
,`assessments`.`surprise`
,`assessments`.`sadness`
,`assessments`.`disgust`
,`assessments`.`anger`
,`assessments`.`anticipation`
,`assessments`.`created`
,`assessments`.`changed`
from `refs`
left join `lexemes` on `lexemes`.`id`=`refs`.`lexeme_id`
left join `assigns` on `assigns`.`set_id`=`refs`.`set_id`
left join `assessments` on `assessments`.`assign_id`=`assigns`.`id` 
and `assessments`.`lexeme_id`=`lexemes`.`id`
where `assigns`.`id`=`_assign_id`$$

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

DROP PROCEDURE IF EXISTS `import`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `import` ()  NO SQL
BEGIN
set @i = 54;
WHILE @i < 107 DO
	set @id=(select `lexemes`.`id`
    from `lexemes`
    where `lexemes`.`id`=@i);
    if @id is NOT null THEN
    	 insert into `refs` (`refs`.`set_id`, `refs`.`lexeme_id`) values(3, @i);
       -- select @i;
    end if;
    	set @i = @i + 1;
END WHILE;
END$$

DROP PROCEDURE IF EXISTS `saveAssessment`$$
CREATE DEFINER=`ea`@`localhost` PROCEDURE `saveAssessment` (IN `_assign_id` BIGINT, IN `_lexeme_id` BIGINT, IN `_joy` FLOAT, IN `_trust` FLOAT, IN `_fear` FLOAT, IN `_surprise` FLOAT, IN `_sadness` FLOAT, IN `_disgust` FLOAT, IN `_anger` FLOAT, IN `_anticipation` FLOAT)  MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
select `assessments`.`id` into @id
from `assessments` 
WHERE `assessments`.`assign_id`=`_assign_id` and `assessments`.`lexeme_id`=`_lexeme_id`;
if @id is null THEN
insert into `assessments` 
(`assessments`.`assign_id`, `assessments`.`lexeme_id` 
,`assessments`.`joy`
,`assessments`.`trust`
,`assessments`.`fear`
,`assessments`.`surprise`
,`assessments`.`sadness`
,`assessments`.`disgust`
,`assessments`.`anger`
,`assessments`.`anticipation`
)
VALUES(`_assign_id`, `_lexeme_id` 
,`_joy`
,`_trust`
,`_fear`
,`_surprise`
,`_sadness`
,`_disgust`
,`_anger`
,`_anticipation`
);
set @id=LAST_INSERT_ID();
else 
update `assessments` 
set 
 `assessments`.`joy`=`_joy`
,`assessments`.`trust`=`_trust`
,`assessments`.`fear`=`_fear`
,`assessments`.`surprise`=`_surprise`
,`assessments`.`sadness`=`_sadness`
,`assessments`.`disgust`=`_disgust`
,`assessments`.`anger`=`_anger`
,`assessments`.`anticipation`=`_anticipation`
where `assessments`.`id`=@id;
end if;
select `assessments`.`id`
,`lexemes`.`id` as `lexeme_id`
,`lexemes`.`lexeme`, `lexemes`.`lang`
,`assessments`.`joy`
,`assessments`.`trust`
,`assessments`.`fear`
,`assessments`.`surprise`
,`assessments`.`sadness`
,`assessments`.`disgust`
,`assessments`.`anger`
,`assessments`.`anticipation`
,`assessments`.`created`
,`assessments`.`changed`
from `refs`
left join `lexemes` on `lexemes`.`id`=`refs`.`lexeme_id`
left join `assigns` on `assigns`.`set_id`=`refs`.`set_id`
left join `assessments` on `assessments`.`assign_id`=`assigns`.`id`
and `assessments`.`lexeme_id`=`lexemes`.`id`
where `assessments`.`id`=@id;
END$$

DROP PROCEDURE IF EXISTS `startAssign`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `startAssign` (IN `_assign_id` BIGINT)  NO SQL
BEGIN
select `assigns`.`start_date` into @start_date 
from `assigns` where `assigns`.id=`_assign_id`;

IF @start_date is null THEN
update `assigns` set `assigns`.`start_date`=CURRENT_TIMESTAMP()
where `assigns`.`id`=`_assign_id`;
end IF;
select `assigns`.*, `sets`.`name` as set_name, `persons`.`fullname` as author  
from `assigns`
left join `sets` on `sets`.`id`=`assigns`.`set_id`
left join `persons` on `persons`.`id`=`sets`.`author_id`
where `assigns`.`id`=`_assign_id`;
END$$

DROP PROCEDURE IF EXISTS `stopAssign`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `stopAssign` (IN `_assign_id` BIGINT)  NO SQL
BEGIN
DECLARE CUSTOM_EXCEPTION CONDITION FOR SQLSTATE '45000';
select `assigns`.`start_date`, `assigns`.`finish_date` into @start_date, @finish_date
from `assigns` where `assigns`.id=`_assign_id`;

IF @start_date is null THEN
	SIGNAL CUSTOM_EXCEPTION
    SET MESSAGE_TEXT = 'Start date is null!';
END IF;

IF @finish_date is null THEN
update `assigns` set `assigns`.`finish_date`=CURRENT_TIMESTAMP() 
WHERE `assigns`.id=`_assign_id`;
ELSE
	SIGNAL CUSTOM_EXCEPTION
    SET MESSAGE_TEXT = 'Assign was finished earlier';
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
-- Table structure for table `assessments`
--

DROP TABLE IF EXISTS `assessments`;
CREATE TABLE IF NOT EXISTS `assessments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `lexeme_id` bigint(20) NOT NULL,
  `assign_id` bigint(20) NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `joy` float NOT NULL,
  `trust` float NOT NULL,
  `fear` float NOT NULL,
  `surprise` float NOT NULL,
  `sadness` float NOT NULL,
  `disgust` float NOT NULL,
  `anger` float NOT NULL,
  `anticipation` float NOT NULL,
  `changed` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `lexeme_id` (`lexeme_id`),
  KEY `assign_id` (`assign_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `assigns`
--

DROP TABLE IF EXISTS `assigns`;
CREATE TABLE IF NOT EXISTS `assigns` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `person_id` bigint(20) NOT NULL,
  `set_id` bigint(20) NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `changed` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `due_date` datetime NOT NULL,
  `start_date` datetime DEFAULT NULL,
  `finish_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `person_id` (`person_id`),
  KEY `set_id` (`set_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `assigns`
--

INSERT INTO `assigns` (`id`, `person_id`, `set_id`, `created`, `changed`, `due_date`, `start_date`, `finish_date`) VALUES
(1, 1, 1, '2021-05-11 14:23:24', '2021-05-27 05:14:54', '2021-05-17 17:23:11', '2021-05-26 15:23:36', NULL),
(2, 1, 2, '2021-05-26 09:50:55', '2021-05-27 05:14:50', '2021-05-27 13:50:05', '2021-05-26 16:13:01', NULL),
(3, 1, 3, '2021-05-26 09:50:55', '2021-05-26 16:40:21', '2021-05-27 13:50:05', NULL, NULL),
(4, 2, 2, '2021-05-27 05:14:35', '2021-05-27 05:14:35', '2021-05-31 09:13:45', NULL, NULL),
(5, 2, 3, '2021-05-27 05:14:35', '2021-05-27 05:14:35', '2021-05-31 09:13:45', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `langs`
--

DROP TABLE IF EXISTS `langs`;
CREATE TABLE IF NOT EXISTS `langs` (
  `lang` varchar(5) NOT NULL,
  PRIMARY KEY (`lang`)
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
CREATE TABLE IF NOT EXISTS `lexemes` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `lexeme` varchar(250) NOT NULL,
  `lang` varchar(5) NOT NULL,
  `stopword` tinyint(1) NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `changed` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `lexeme` (`lexeme`,`lang`) USING BTREE,
  KEY `lang` (`lang`)
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `lexemes`
--

INSERT INTO `lexemes` (`id`, `lexeme`, `lang`, `stopword`, `created`, `changed`) VALUES
(1, 'призрачный шанс', 'ru-RU', 0, '2021-05-11 09:28:35', '2021-05-11 09:28:35'),
(2, 'долгожданный малыш', 'ru-RU', 0, '2021-05-11 09:28:35', '2021-05-11 09:28:35'),
(3, 'важное дело', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(4, 'важная задача', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(5, 'важно знать', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(6, 'важное изменение', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(7, 'важный набор', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(8, 'важное понимание', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(9, 'важное развитие', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(10, 'важная сфера', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(11, 'важнее того', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(12, 'важная характеристика', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(13, 'благодатный мировой', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(14, 'благоденствие', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(15, 'благополучный', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(16, 'благополучный капитал', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(17, 'благополучный мир', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(18, 'благополучный удар', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(19, 'благополучная франция', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(20, 'бриться', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(21, 'взаимовлияние', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(22, 'взаимодействие', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(23, 'взаимоотношение', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(24, 'взаимопроникаемый том', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(25, 'взаимопроникновение', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(26, 'взаимосвязанный', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(27, 'взаимосвязанный мир', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(28, 'взаймы', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(29, 'властная иерархия', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(30, 'властный институт', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(31, 'власть', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(32, 'врач', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(33, 'втайне', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(34, 'выбравший стратегию', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(35, 'гарантия', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(36, 'гарвард', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(37, 'гарлем', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(38, 'гармоничное мироустройство', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(39, 'гармоничное состояние', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(40, 'гармоничная эра', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(41, 'гармония', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(42, 'где', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(43, 'годовая зарплата', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(44, 'вовремя', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(45, 'гражданская свобода', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(46, 'грациозный', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(47, 'динамичный', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(48, 'динамичная картина', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(49, 'динамичный процесс', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(50, 'друг', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(51, 'дружелюбное сотрудничество', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(52, 'единство', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(53, 'единое человечество', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(54, 'авось', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(55, 'агрессивный идеология', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(56, 'антидемократический направление', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(57, 'антидемократический режим', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(58, 'апокалипсический сценарий', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(59, 'бить', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(60, 'болезненный', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(61, 'болезнь', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(62, 'болеть', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(63, 'болотная дичь', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(64, 'болото', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(65, 'брехня', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(67, 'бросать', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(68, 'бросить', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(69, 'будить', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(70, 'взволновавшийся генерал', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(72, 'впалый череп', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(73, 'враг', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(74, 'втоптать', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(75, 'вцепиться', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(76, 'гадкий', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(77, 'гадкая рожа', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(78, 'газ', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(79, 'газета', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(80, 'гаишник', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(81, 'гнетущий', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(82, 'гнусное предательство', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(83, 'гнусная улыбочка', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(84, 'голод', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(85, 'дисгармония', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(86, 'дрянь', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(87, 'дряхлеть', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(88, 'дубовый крест', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(89, 'думать', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(90, 'дурак', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(91, 'дурной генерал', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(92, 'дурная книжка', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(93, 'дуть', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(94, 'дух', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(95, 'единоборство', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(96, 'единственный выход', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(97, 'единственный собственник', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(98, 'единственный способ', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(99, 'издевательство', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(100, 'двоякое чувство', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(101, 'европейская экспансия', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(102, 'беспощадный работник', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(104, 'восточная культура', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(105, 'большой кабинет', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00'),
(106, 'верный конец', 'ru-RU', 0, '2021-05-25 20:00:00', '2021-05-25 20:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `persons`
--

DROP TABLE IF EXISTS `persons`;
CREATE TABLE IF NOT EXISTS `persons` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
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
  `location` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `lang` (`lang`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `persons`
--

INSERT INTO `persons` (`id`, `name`, `created`, `changed`, `fullname`, `hash`, `lang`, `roles`, `email`, `telegram`, `birthdate`, `location`) VALUES
(1, 'pavel', '2021-05-11 09:29:43', '2021-05-13 16:48:43', 'Комов Павел', '2812c4759afcf88f1a1d3c123102a273', 'ru-RU', '', '', '', NULL, NULL),
(2, 'Komo-pet', '2021-05-13 18:30:37', '2021-05-27 05:20:47', 'Комов Петр', '5f6bb7eeca844a43bc54446ae9d8a91a', 'ru-RU', '', '', '', NULL, NULL),
(3, 'Galina', '2021-05-27 05:22:23', '2021-05-27 05:22:23', NULL, '7ed6c3577dbd5de3df4b7ad5481e85a0', 'ru-RU', '', '', '', NULL, NULL),
(4, 'MIRA', '2021-05-27 05:22:23', '2021-05-27 05:22:23', NULL, 'c55871d0aa2880aec4682de5d7d84f77', 'ru-RU', '', '', '', NULL, NULL),
(5, 'dandelion_chan', '2021-05-27 05:23:13', '2021-05-27 05:23:13', NULL, '9415dcff7fdef3bd21eab07959c44403', NULL, '', '', '', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `refs`
--

DROP TABLE IF EXISTS `refs`;
CREATE TABLE IF NOT EXISTS `refs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `set_id` bigint(20) NOT NULL,
  `lexeme_id` bigint(20) NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `changed` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `set_id` (`set_id`),
  KEY `lexeme_id` (`lexeme_id`)
) ENGINE=InnoDB AUTO_INCREMENT=143 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `refs`
--

INSERT INTO `refs` (`id`, `set_id`, `lexeme_id`, `created`, `changed`) VALUES
(1, 1, 1, '2021-05-11 14:21:52', '2021-05-11 14:21:52'),
(2, 1, 2, '2021-05-11 14:21:52', '2021-05-11 14:21:52'),
(3, 2, 3, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(4, 2, 4, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(5, 2, 5, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(6, 2, 6, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(7, 2, 7, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(8, 2, 8, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(9, 2, 9, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(10, 2, 10, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(11, 2, 11, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(12, 2, 12, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(13, 2, 13, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(14, 2, 14, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(15, 2, 15, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(16, 2, 16, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(17, 2, 17, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(18, 2, 18, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(19, 2, 19, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(20, 2, 20, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(21, 2, 21, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(22, 2, 22, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(23, 2, 23, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(24, 2, 24, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(25, 2, 25, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(26, 2, 26, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(27, 2, 27, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(28, 2, 28, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(29, 2, 29, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(30, 2, 30, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(31, 2, 31, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(32, 2, 32, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(33, 2, 33, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(34, 2, 34, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(35, 2, 35, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(36, 2, 36, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(37, 2, 37, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(38, 2, 38, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(39, 2, 39, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(40, 2, 40, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(41, 2, 41, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(42, 2, 42, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(43, 2, 43, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(44, 2, 44, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(45, 2, 45, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(46, 2, 46, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(47, 2, 47, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(48, 2, 48, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(49, 2, 49, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(50, 2, 50, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(51, 2, 51, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(52, 2, 52, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(53, 2, 53, '2021-05-26 09:42:35', '2021-05-26 09:42:35'),
(93, 3, 54, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(94, 3, 55, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(95, 3, 56, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(96, 3, 57, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(97, 3, 58, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(98, 3, 59, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(99, 3, 60, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(100, 3, 61, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(101, 3, 62, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(102, 3, 63, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(103, 3, 64, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(104, 3, 65, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(105, 3, 67, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(106, 3, 68, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(107, 3, 69, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(108, 3, 70, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(109, 3, 72, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(110, 3, 73, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(111, 3, 74, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(112, 3, 75, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(113, 3, 76, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(114, 3, 77, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(115, 3, 78, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(116, 3, 79, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(117, 3, 80, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(118, 3, 81, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(119, 3, 82, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(120, 3, 83, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(121, 3, 84, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(122, 3, 85, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(123, 3, 86, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(124, 3, 87, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(125, 3, 88, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(126, 3, 89, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(127, 3, 90, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(128, 3, 91, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(129, 3, 92, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(130, 3, 93, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(131, 3, 94, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(132, 3, 95, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(133, 3, 96, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(134, 3, 97, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(135, 3, 98, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(136, 3, 99, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(137, 3, 100, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(138, 3, 101, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(139, 3, 102, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(140, 3, 104, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(141, 3, 105, '2021-05-26 09:49:36', '2021-05-26 09:49:36'),
(142, 3, 106, '2021-05-26 09:49:36', '2021-05-26 09:49:36');

-- --------------------------------------------------------

--
-- Table structure for table `sets`
--

DROP TABLE IF EXISTS `sets`;
CREATE TABLE IF NOT EXISTS `sets` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(250) NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `changed` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `author_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `author_id` (`author_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `sets`
--

INSERT INTO `sets` (`id`, `name`, `created`, `changed`, `author_id`) VALUES
(1, 'Test set', '2021-05-11 14:19:03', '2021-05-20 05:50:36', 2),
(2, 'set_anticip_joy_admit_fear', '2021-05-26 09:02:44', '2021-05-26 12:16:11', 2),
(3, 'set_fury_disgust_sad_surprise', '2021-05-26 09:02:44', '2021-05-26 12:15:56', 2);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `assessments`
--
ALTER TABLE `assessments`
  ADD CONSTRAINT `assessments_ibfk_2` FOREIGN KEY (`lexeme_id`) REFERENCES `lexemes` (`id`),
  ADD CONSTRAINT `assessments_ibfk_3` FOREIGN KEY (`assign_id`) REFERENCES `assigns` (`id`);

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
