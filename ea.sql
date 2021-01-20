-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 20, 2021 at 09:49 AM
-- Server version: 10.4.17-MariaDB
-- PHP Version: 8.0.0

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
DROP PROCEDURE IF EXISTS `getLexemeFromDictionary`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getLexemeFromDictionary` (IN `_lexeme` VARCHAR(250), IN `_lang` VARCHAR(5))  NO SQL
select * from `dictionary` where `dictionary`.`lexeme` like `_lexeme` and `dictionary`.`lang` like `_lang`$$

DROP PROCEDURE IF EXISTS `getUnassignedDictionaryTopN`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getUnassignedDictionaryTopN` (IN `N` INT)  NO SQL
select * from `dictionary` where `dictionary`.`stopword` is null LIMIT N$$

--
-- Functions
--
DROP FUNCTION IF EXISTS `addLexemeToDictionary`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `addLexemeToDictionary` (`_lexeme` VARCHAR(250), `_lang` VARCHAR(5), `_ignore` BOOLEAN, `_emotion` VARCHAR(250)) RETURNS BIGINT(20) UNSIGNED NO SQL
BEGIN
set @id = (select `dictionary`.`id` from `dictionary` where `dictionary`.`lang` like `_lang` and `dictionary`.`lexeme` like `_lexeme`);
if `_emotion` IS NOT NULL THEN
select json_extract(`_emotion`, '$.joy') INTO @joy;
select json_extract(`_emotion`, '$.trust') INTO @trust;
select json_extract(`_emotion`, '$.fear') INTO @fear;
select json_extract(`_emotion`, '$.surprise') INTO @surprise;
select json_extract(`_emotion`, '$.sadness') INTO @sadness;
select json_extract(`_emotion`, '$.disgust') INTO @disgust;
select json_extract(`_emotion`, '$.anger') INTO @anger;
select json_extract(`_emotion`, '$.anticipation') INTO @anticipation;
end if;
if @id is null THEN
insert into `dictionary` (`lang`, `lexeme`) VALUES (`_lang`, `_lexeme`); 
set @id = LAST_INSERT_ID();
end if;
if `_ignore` is not null THEN
update `dictionary` set `dictionary`.`stopword`=`_ignore` where `dictionary`.`id`=@id;
ELSE
update `dictionary` set `dictionary`.`stopword`=null where `dictionary`.`id`=@id;
end if;
if `_emotion` IS NOT NULL THEN
update `dictionary` 
set `dictionary`.`joy`= @joy, 
`dictionary`.`trust` = @trust, 
`dictionary`.`fear`=@fear, 
`dictionary`.`surprise`=@surprise,
`dictionary`.`sadness`=@sadness,
`dictionary`.`disgust`=@disgust, 
`dictionary`.`anger`=@anger, `dictionary`.`anticipation`=@anticipation
where `dictionary`.`id` = @id;
end if;
return (@id);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `dictionary`
--

DROP TABLE IF EXISTS `dictionary`;
CREATE TABLE IF NOT EXISTS `dictionary` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `lang` varchar(5) DEFAULT NULL,
  `lexeme` varchar(250) NOT NULL,
  `stopword` tinyint(1) DEFAULT NULL,
  `joy` float DEFAULT NULL,
  `trust` float DEFAULT NULL,
  `fear` float DEFAULT NULL,
  `surprise` float DEFAULT NULL,
  `sadness` float DEFAULT NULL,
  `disgust` float DEFAULT NULL,
  `anger` float DEFAULT NULL,
  `anticipation` float DEFAULT NULL,
  `changed` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `lexeme` (`lexeme`,`lang`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `dictionary`
--

INSERT INTO `dictionary` (`id`, `created`, `lang`, `lexeme`, `stopword`, `joy`, `trust`, `fear`, `surprise`, `sadness`, `disgust`, `anger`, `anticipation`, `changed`) VALUES
(1, '2021-01-14 18:21:35', 'ru_RU', 'КРАСНЫЙ ФОНАРЬ', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, 1, '2021-01-18 07:26:02'),
(3, '2021-01-14 18:21:35', 'ru_RU', 'КРАСНЫЙ', NULL, 0, 0, 0, 1, 0, 0, 0, 1, '2021-01-20 07:17:17'),
(4, '2021-01-14 18:21:35', 'ru_RU', 'КРАСНЫЙ ТРЯПКА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2021-01-18 07:24:05'),
(6, '2021-01-14 18:24:04', 'ru_RU', 'ПОЛОТЕНЦЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:22:02'),
(7, '2021-01-14 19:02:40', 'ru_RU', 'НЕВЕРИЕ', NULL, 0, 0, 0.8, 0, 0, 0, 0, 0, '2021-01-20 08:19:13'),
(8, '2021-01-14 19:02:40', 'ru_RU', 'ПАНДЕМИЯ', NULL, 0, 0, 0.6, 0, 1, 1, 0, 0, '2021-01-20 08:34:02'),
(9, '2021-01-14 19:02:40', 'ru_RU', 'СТОЛЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:02:40'),
(10, '2021-01-14 19:02:40', 'ru_RU', 'ОПАСНЫЙ КОРОНАВИРУС', NULL, 0, 1, 1, 0, 0, 1, 0, 0, '2021-01-20 08:32:44'),
(12, '2021-01-14 19:11:24', 'ru_RU', 'ВРЕМЯ', NULL, 0, 0, 0, 0, 0.4, 0, 0, 0, '2021-01-20 08:33:03'),
(13, '2021-01-14 19:11:24', 'ru_RU', 'ПРОПОВЕДЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(14, '2021-01-14 19:11:24', 'ru_RU', 'ЛИТУРГИЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(15, '2021-01-14 19:11:24', 'ru_RU', 'ХРАМ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(16, '2021-01-14 19:11:24', 'ru_RU', 'ХРИСТОС', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(17, '2021-01-14 19:11:24', 'ru_RU', 'ЗАЯВИТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(18, '2021-01-14 19:11:24', 'ru_RU', 'СПАСИТЕЛЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(19, '2021-01-14 19:11:24', 'ru_RU', 'ПАТРИАРХ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(20, '2021-01-14 19:11:24', 'ru_RU', 'МОСКОВСКИЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(21, '2021-01-14 19:11:24', 'ru_RU', 'РУСЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(22, '2021-01-14 19:11:24', 'ru_RU', 'ТРАНСЛЯЦИЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(23, '2021-01-14 19:11:24', 'ru_RU', 'ТЕЛЕКАНАЛ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(24, '2021-01-14 19:11:24', 'ru_RU', 'БЫТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(25, '2021-01-14 19:11:24', 'ru_RU', 'СОЮЗ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(26, '2021-01-14 19:11:24', 'ru_RU', 'НЕ ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(27, '2021-01-14 19:11:24', 'ru_RU', 'ЧЕЛОВЕК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(28, '2021-01-14 19:11:24', 'ru_RU', 'БОЛЕЗНЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(29, '2021-01-14 19:11:24', 'ru_RU', 'ПРЕНЕБРЕГАТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(30, '2021-01-14 19:11:24', 'ru_RU', 'ОПАСНОСТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(31, '2021-01-14 19:11:24', 'ru_RU', 'ПРЕДПИСАНИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(32, '2021-01-14 19:11:24', 'ru_RU', 'СКАЗАТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(33, '2021-01-14 19:11:24', 'ru_RU', 'МЕДИК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(34, '2021-01-14 19:11:24', 'ru_RU', 'СУЩЕСТВОВАТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(35, '2021-01-14 19:11:24', 'ru_RU', 'МИР', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(36, '2021-01-14 19:11:24', 'ru_RU', 'НЕ ЧЕЛОВЕК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(37, '2021-01-14 19:11:24', 'ru_RU', 'МНОЖЕСТВО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(38, '2021-01-14 19:11:24', 'ru_RU', 'ОТМЕТИТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(39, '2021-01-14 19:11:24', 'ru_RU', 'ОЧЕНЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(40, '2021-01-14 19:11:24', 'ru_RU', 'ОПАСНЫЙ БОГ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(41, '2021-01-14 19:11:24', 'ru_RU', 'СМЕРТЕЛЬНЫЙ БОГ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(42, '2021-01-14 19:11:24', 'ru_RU', 'СЕГОДНЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(43, '2021-01-14 19:11:24', 'ru_RU', 'ОПАСНЫЙ ЧЕЛОВЕК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(44, '2021-01-14 19:11:24', 'ru_RU', 'РАСПРОСТРАНЕНИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(45, '2021-01-14 19:11:24', 'ru_RU', 'ИНФЕКЦИЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(46, '2021-01-14 19:11:24', 'ru_RU', 'ПОПРОСИТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(47, '2021-01-14 19:11:24', 'ru_RU', 'КИРИЛЛ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(48, '2021-01-14 19:11:24', 'ru_RU', 'ВСЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(49, '2021-01-14 19:11:24', 'ru_RU', 'ПРИХОЖАНИН', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(50, '2021-01-14 19:11:24', 'ru_RU', 'НЕОБХОДИМЫЙ ТРЕБОВАНИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(51, '2021-01-14 19:11:24', 'ru_RU', 'МАСКА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(52, '2021-01-14 19:11:24', 'ru_RU', 'СОЦИАЛЬНЫЙ ДИСТАНЦИЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(53, '2021-01-14 19:11:24', 'ru_RU', 'ПОТОМУ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(54, '2021-01-14 19:11:24', 'ru_RU', 'МОЧЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(55, '2021-01-14 19:11:24', 'ru_RU', 'НЕОСТОРОЖНОСТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(56, '2021-01-14 19:11:24', 'ru_RU', 'ПРИЧИНА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(57, '2021-01-14 19:11:24', 'ru_RU', 'СТРАШНЫЙ ЗАБОЛЕВАНИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(58, '2021-01-14 19:11:24', 'ru_RU', 'ПРЕДСТОЯТЕЛЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(59, '2021-01-14 19:11:24', 'ru_RU', 'ЦЕРКОВЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(60, '2021-01-14 19:11:24', 'ru_RU', 'НАЗВАТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(61, '2021-01-14 19:11:24', 'ru_RU', 'СИГНАЛ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(62, '2021-01-14 19:11:24', 'ru_RU', 'ГОСПОДИН', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24'),
(63, '2021-01-14 19:11:24', 'ru_RU', 'ПОСЛЕДНИЙ ЗВОНОК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-14 19:11:24');
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
