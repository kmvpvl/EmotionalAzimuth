-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Feb 02, 2021 at 08:00 AM
-- Server version: 10.5.8-MariaDB
-- PHP Version: 7.4.13

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
DROP PROCEDURE IF EXISTS `getDraftDictionaryTopN`$$
CREATE DEFINER=`ea`@`localhost` PROCEDURE `getDraftDictionaryTopN` (IN `_user` VARCHAR(250), IN `_lexeme_first_letters` VARCHAR(250), IN `_lang` VARCHAR(5), IN `_assigned` BOOLEAN, IN `N` INT)  NO SQL
    SQL SECURITY INVOKER
select `dictionary`.`id`, `dictionary`.`lexeme`, `dictionary`.`lang`, `draft`.`user`, `draft`.`stopword`, `draft`.`joy`, `draft`.`trust`, `draft`.`fear`, `draft`.`surprise`, `draft`.`sadness`, `draft`.`disgust`, `draft`.`anger`, `draft`.`anticipation`
from `dictionary` 
left join (select * from `dictionary_draft` where `dictionary_draft`.`user` = `_user`) as `draft`

on `dictionary`.`lexeme` = `draft`.`lexeme` and `dictionary`.`lang` = `draft`.`lang`
where if (`draft`.`stopword` is null, 0, 1) = `_assigned` and `dictionary`.`lang` like `_lang` and (`dictionary`.`lexeme` like concat(`_lexeme_first_letters`, '%') or `dictionary`.`lexeme` like concat('% ', `_lexeme_first_letters`, '%'))

LIMIT `N`$$

DROP PROCEDURE IF EXISTS `getDraftLexemeFromDictionary`$$
CREATE DEFINER=`ea`@`localhost` PROCEDURE `getDraftLexemeFromDictionary` (IN `_user` VARCHAR(250), IN `_lexeme` VARCHAR(250), IN `_lang` VARCHAR(5))  NO SQL
    SQL SECURITY INVOKER
select * from `dictionary_draft` where `dictionary_draft`.`lexeme` like `_lexeme` and `dictionary_draft`.`lang` like `_lang` and `dictionary_draft`.`user` like `_user`$$

DROP PROCEDURE IF EXISTS `getLexemeFromDictionary`$$
CREATE DEFINER=`ea`@`localhost` PROCEDURE `getLexemeFromDictionary` (IN `_lexeme` VARCHAR(250), IN `_lang` VARCHAR(5))  NO SQL
    SQL SECURITY INVOKER
select * from `dictionary` where `dictionary`.`lexeme` like `_lexeme` and `dictionary`.`lang` like `_lang`$$

DROP PROCEDURE IF EXISTS `getStatistics`$$
CREATE DEFINER=`ea`@`localhost` PROCEDURE `getStatistics` ()  NO SQL
    SQL SECURITY INVOKER
begin 
set @remain_dict = (select count(id) from `dictionary` where `dictionary`.`stopword` is null);
set @all_dict = (select count(id) from `dictionary`);
select @all_dict as `all_dict`, @remain_dict as `remain_dict`;
end$$

DROP PROCEDURE IF EXISTS `getUnassignedDictionaryTopN`$$
CREATE DEFINER=`ea`@`localhost` PROCEDURE `getUnassignedDictionaryTopN` (IN `N` INT)  NO SQL
    SQL SECURITY INVOKER
select * from `dictionary` where `dictionary`.`stopword` is null LIMIT N$$

--
-- Functions
--
DROP FUNCTION IF EXISTS `addDraftLexemeToDictionary`$$
CREATE DEFINER=`ea`@`localhost` FUNCTION `addDraftLexemeToDictionary` (`_user` VARCHAR(250), `_lexeme` VARCHAR(250), `_lang` VARCHAR(5), `_ignore` BOOLEAN, `_emotion` VARCHAR(250)) RETURNS BIGINT(20) UNSIGNED NO SQL
    SQL SECURITY INVOKER
BEGIN
set @id = (select `dictionary_draft`.`id` from `dictionary_draft` where `dictionary_draft`.`lang` like `_lang` and `dictionary_draft`.`lexeme` like `_lexeme` and `dictionary_draft`.`user` like `_user`);
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
insert into `dictionary_draft` (`user`, `lang`, `lexeme`) VALUES (`_user`, `_lang`, `_lexeme`); 
set @id = LAST_INSERT_ID();
end if;
if `_ignore` is not null THEN
update `dictionary_draft` set `dictionary_draft`.`stopword`=`_ignore` where `dictionary_draft`.`id`=@id;
end if;
if `_emotion` IS NOT NULL THEN
update `dictionary_draft` 
set `dictionary_draft`.`joy`= @joy, 
`dictionary_draft`.`trust` = @trust, 
`dictionary_draft`.`fear`=@fear, 
`dictionary_draft`.`surprise`=@surprise,
`dictionary_draft`.`sadness`=@sadness,
`dictionary_draft`.`disgust`=@disgust, 
`dictionary_draft`.`anger`=@anger, `dictionary_draft`.`anticipation`=@anticipation
where `dictionary_draft`.`id` = @id;
end if;
return (@id);
END$$

DROP FUNCTION IF EXISTS `addLexemeToDictionary`$$
CREATE DEFINER=`ea`@`localhost` FUNCTION `addLexemeToDictionary` (`_lexeme` VARCHAR(250), `_lang` VARCHAR(5), `_ignore` BOOLEAN, `_emotion` VARCHAR(250)) RETURNS BIGINT(20) UNSIGNED NO SQL
    SQL SECURITY INVOKER
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

DROP FUNCTION IF EXISTS `resetDraft`$$
CREATE DEFINER=`ea`@`localhost` FUNCTION `resetDraft` (`_lexeme` VARCHAR(250), `_lang` VARCHAR(5), `_user` VARCHAR(250)) RETURNS BIGINT(20) NO SQL
    SQL SECURITY INVOKER
BEGIN
set @id = (select `dictionary_draft`.`id` from `dictionary_draft` where `dictionary_draft`.`lang` like `_lang` and `dictionary_draft`.`lexeme` like `_lexeme` and `dictionary_draft`.`user` like `_user`);
if @id is not null THEN
update `dictionary_draft` set `dictionary_draft`.`stopword`=null where `dictionary_draft`.`id`=@id;
return @id;
else 
return null;
end if;
end$$

DROP FUNCTION IF EXISTS `resetLexeme`$$
CREATE DEFINER=`ea`@`localhost` FUNCTION `resetLexeme` (`_lexeme` VARCHAR(250), `_lang` VARCHAR(5)) RETURNS BIGINT(20) NO SQL
    SQL SECURITY INVOKER
BEGIN
set @id = (select `dictionary`.`id` from `dictionary` where `dictionary`.`lang` like `_lang` and `dictionary`.`lexeme` like `_lexeme`);
if @id is not null THEN
update `dictionary` set `dictionary`.`stopword`=null where `dictionary`.`id`=@id;
return @id;
else 
return null;
end if;
end$$

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
) ENGINE=InnoDB AUTO_INCREMENT=319 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `dictionary`
--

INSERT INTO `dictionary` (`id`, `created`, `lang`, `lexeme`, `stopword`, `joy`, `trust`, `fear`, `surprise`, `sadness`, `disgust`, `anger`, `anticipation`, `changed`) VALUES
(1, '2021-01-26 14:52:25', 'ru_RU', 'СВЕЖИЙ КЛАДБИЩЕ', 0, 0, 0, 0.3, 0, 0, 0, 0, 0, '2021-01-28 13:43:49'),
(2, '2021-01-26 14:52:25', 'ru_RU', 'ГЛИНЯНЫЙ НАСЫПЬ', NULL, 0, 0.2, 0, 0, 0, 0, 0.5, 0, '2021-01-28 08:35:55'),
(3, '2021-01-26 14:52:25', 'ru_RU', 'СТОИТЬ', 1, 0, 0, 0, 0, 0, 0, 0, 0, '2021-01-29 06:48:02'),
(4, '2021-01-26 14:52:25', 'ru_RU', 'НОВЫЙ КРЕСТ', 1, 0, 0, 0, 0, 0, 0, 0, 0, '2021-01-29 06:48:13'),
(5, '2021-01-26 14:52:25', 'ru_RU', 'КРЕПКИЙ ДУБ', 0, 0, 0.1, 0, 0, 0, 0, 0, 0, '2021-01-29 06:49:51'),
(6, '2021-01-26 14:52:25', 'ru_RU', 'ТЯЖЕЛЫЙ', 0, 0, 0, 0.1, 0, 0, 0, 0, 0, '2021-01-29 06:50:46'),
(7, '2021-01-26 14:52:25', 'ru_RU', 'ГЛАДКИЙ АПРЕЛЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(8, '2021-01-26 14:52:25', 'ru_RU', 'ДЕНЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(9, '2021-01-26 14:52:25', 'ru_RU', 'СЕРЫЙ ПАМЯТНИК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(10, '2021-01-26 14:52:25', 'ru_RU', 'ПРОСТОРНЫЙ КЛАДБИЩЕ', 0, 0, 0, 0.2, 0, 0, 0, 0, 0, '2021-02-01 07:45:18'),
(11, '2021-01-26 14:52:25', 'ru_RU', 'УЕЗДНЫЙ ЕЩЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(12, '2021-01-26 14:52:25', 'ru_RU', 'ДАЛЁКИЙ', 0, 0, 0, 0.1, 0, 0.1, 0, 0, 0, '2021-01-29 06:51:22'),
(13, '2021-01-26 14:52:25', 'ru_RU', 'ГОЛЫЙ ДЕРЕВО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(14, '2021-01-26 14:52:25', 'ru_RU', 'ХОЛОДНЫЙ ВЕТЕР', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(15, '2021-01-26 14:52:25', 'ru_RU', 'ЗВЕНЕТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(16, '2021-01-26 14:52:25', 'ru_RU', 'ФАРФОРОВЫЙ ВЕНОК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(17, '2021-01-26 14:52:25', 'ru_RU', 'ПОДНОЖИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(18, '2021-01-26 14:52:25', 'ru_RU', 'КРЕСТ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(19, '2021-01-26 14:52:25', 'ru_RU', 'ДОВОЛЬНЫЙ КРЕСТ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(20, '2021-01-26 14:52:25', 'ru_RU', 'БОЛЬШОЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(21, '2021-01-26 14:52:25', 'ru_RU', 'ВЫПУКЛЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(22, '2021-01-26 14:52:25', 'ru_RU', 'ФАРФОРОВЫЙ МЕДАЛЬОН', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(23, '2021-01-26 14:52:25', 'ru_RU', 'МЕДАЛЬОН', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(24, '2021-01-26 14:52:25', 'ru_RU', 'ФОТОГРАФИЧЕСКИЙ ПОРТРЕТ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(25, '2021-01-26 14:52:25', 'ru_RU', 'РАДОСТНЫЙ ГИМНАЗИСТКА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(26, '2021-01-26 14:52:25', 'ru_RU', 'ПОРАЗИТЕЛЬНЫЙ ЖИВОЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(27, '2021-01-26 14:52:25', 'ru_RU', 'ГЛАЗ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(28, '2021-01-26 14:52:25', 'ru_RU', 'ОЛЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(29, '2021-01-26 14:52:25', 'ru_RU', 'ЭТО ДЕВОЧКА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(30, '2021-01-26 14:52:25', 'ru_RU', 'НЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(31, '2021-01-26 14:52:25', 'ru_RU', 'КОРИЧНЕВЫЙ ТОЛПА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(32, '2021-01-26 14:52:25', 'ru_RU', 'ГИМНАЗИЧЕСКИЙ ПЛАТЬИЦЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(33, '2021-01-26 14:52:25', 'ru_RU', 'ТОГО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(34, '2021-01-26 14:52:25', 'ru_RU', 'ЧИСЛО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(35, '2021-01-26 14:52:25', 'ru_RU', 'БЫЛО БОГАТЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(36, '2021-01-26 14:52:25', 'ru_RU', 'СЧАСТЛИВЫЙ ДЕВОЧКА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(37, '2021-01-26 14:52:25', 'ru_RU', 'СПОСОБНЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(38, '2021-01-26 14:52:25', 'ru_RU', 'ОЧЕНЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(39, '2021-01-26 14:52:25', 'ru_RU', 'ШАЛОВЛИВЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(40, '2021-01-26 14:52:25', 'ru_RU', 'БЕСПЕЧНЫЙ НАСТАВЛЕНИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(41, '2021-01-26 14:52:25', 'ru_RU', 'ДЕЛАТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(42, '2021-01-26 14:52:25', 'ru_RU', 'КЛАССНЫЙ ДАМА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(43, '2021-01-26 14:52:25', 'ru_RU', 'ЗАТЕМ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(44, '2021-01-26 14:52:25', 'ru_RU', 'СТАТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(45, '2021-01-26 14:52:25', 'ru_RU', 'ГОД', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(46, '2021-01-26 14:52:25', 'ru_RU', 'НЕЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(47, '2021-01-26 14:52:25', 'ru_RU', 'ТОНКИЙ ТАЛИЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(48, '2021-01-26 14:52:25', 'ru_RU', 'СТРОЙНЫЙ НОЖКА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(49, '2021-01-26 14:52:25', 'ru_RU', 'ХОРОШО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(50, '2021-01-26 14:52:25', 'ru_RU', 'УЖ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(51, '2021-01-26 14:52:25', 'ru_RU', 'ВСЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(52, '2021-01-26 14:52:25', 'ru_RU', 'ГРУДЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(53, '2021-01-26 14:52:25', 'ru_RU', 'ФОРМА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(54, '2021-01-26 14:52:25', 'ru_RU', 'ОЧАРОВАНИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(55, '2021-01-26 14:52:25', 'ru_RU', 'НИКОГДА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(56, '2021-01-26 14:52:25', 'ru_RU', 'ЕЩЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(57, '2021-01-26 14:52:25', 'ru_RU', 'ЧЕЛОВЕЧЕСКИЙ СЛОВО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(58, '2021-01-26 14:52:25', 'ru_RU', 'СЛЫТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(59, '2021-01-26 14:52:25', 'ru_RU', 'ПРИЧЕСЫВАЛИТЬСЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(60, '2021-01-26 14:52:25', 'ru_RU', 'ТЩАТЕЛЬНЫЙ ПОДРУГА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(61, '2021-01-26 14:52:25', 'ru_RU', 'ЧИСТОПЛОТНЫЙ БЫЛЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(62, '2021-01-26 14:52:25', 'ru_RU', 'СЛЕДИТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(63, '2021-01-26 14:52:25', 'ru_RU', 'СДЕРЖАННЫЙ ДВИЖЕНИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(64, '2021-01-26 14:52:25', 'ru_RU', 'ЧЕРНИЛЬНЫЙ ПЯТНО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(65, '2021-01-26 14:52:25', 'ru_RU', 'РАСКРАСНЕВШИЙСЯ ПАЛЕЦ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(66, '2021-01-26 14:52:25', 'ru_RU', 'ЛИЦО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(67, '2021-01-26 14:52:25', 'ru_RU', 'РАСТРЕПАННЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(68, '2021-01-26 14:52:25', 'ru_RU', 'ЗАГОЛИВШИЙСЯ ВОЛОС', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(69, '2021-01-26 14:52:25', 'ru_RU', 'ПАДЕНИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(70, '2021-01-26 14:52:25', 'ru_RU', 'БЕГ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(71, '2021-01-26 14:52:25', 'ru_RU', 'ЗАБОТА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(72, '2021-01-26 14:52:25', 'ru_RU', 'НЕЗАМЕТНЫЙ УСИЛИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(73, '2021-01-26 14:52:25', 'ru_RU', 'ОТЛИЧАТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(74, '2021-01-26 14:52:25', 'ru_RU', 'ПРИШЛЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(75, '2021-01-26 14:52:25', 'ru_RU', 'ПОСЛЕДНИЙ ГОД', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(76, '2021-01-26 14:52:25', 'ru_RU', 'ВСЕЯТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(77, '2021-01-26 14:52:25', 'ru_RU', 'ГИМНАЗИЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(78, '2021-01-26 14:52:25', 'ru_RU', 'ИЗЯЩЕСТВО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(79, '2021-01-26 14:52:25', 'ru_RU', 'НАРЯДНОСТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(80, '2021-01-26 14:52:25', 'ru_RU', 'ЛОВКОСТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(81, '2021-01-26 14:52:25', 'ru_RU', 'ЯСНЫЙ БЛЕСК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(82, '2021-01-26 14:52:25', 'ru_RU', 'БАЛ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(83, '2021-01-26 14:52:25', 'ru_RU', 'МЕЩЕРСКИЙ КОНЁК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(84, '2021-01-26 14:52:25', 'ru_RU', 'СТОЛЬКО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(85, '2021-01-26 14:52:25', 'ru_RU', 'ПОЧЕМУ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(86, '2021-01-26 14:52:25', 'ru_RU', 'МЛАДШИЙ КЛАСС', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(87, '2021-01-26 14:52:25', 'ru_RU', 'НЕЗАМЕТНЫЙ ДЕВУШКА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(88, '2021-01-26 14:52:25', 'ru_RU', 'УПРОЧИТЬСЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(89, '2021-01-26 14:52:25', 'ru_RU', 'НЕЗАМЕТНЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(90, '2021-01-26 14:52:25', 'ru_RU', 'ГИМНАЗИЧЕСКИЙ СЛАВА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(91, '2021-01-26 14:52:25', 'ru_RU', 'ПОСЛАТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(92, '2021-01-26 14:52:25', 'ru_RU', 'ВЕТРЕНЫЙ ТОЛК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(93, '2021-01-26 14:52:25', 'ru_RU', 'ПОКЛОННИК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(94, '2021-01-26 14:52:25', 'ru_RU', 'БЕЗУМНЫЙ НЕЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(95, '2021-01-26 14:52:25', 'ru_RU', 'ГИМНАЗИСТ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(96, '2021-01-26 14:52:25', 'ru_RU', 'БЫ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:25'),
(97, '2021-01-26 14:52:26', 'ru_RU', 'ИЗМЕНЧИВЫЙ ШЕНШИН', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(98, '2021-01-26 14:52:26', 'ru_RU', 'ПОКУШАТЬСЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(99, '2021-01-26 14:52:26', 'ru_RU', 'ОБРАЩЕНИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(100, '2021-01-26 14:52:26', 'ru_RU', 'САМОУБИЙСТВО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(101, '2021-01-26 14:52:26', 'ru_RU', 'ПОСЛЕДНИЙ ЗИМА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(102, '2021-01-26 14:52:26', 'ru_RU', 'СОВСЕМ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(103, '2021-01-26 14:52:26', 'ru_RU', 'СОЙТИ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(104, '2021-01-26 14:52:26', 'ru_RU', 'МЕЩЕРСКИЙ УМ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(105, '2021-01-26 14:52:26', 'ru_RU', 'ГОВОРИТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(106, '2021-01-26 14:52:26', 'ru_RU', 'ВЕСЕЛИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(107, '2021-01-26 14:52:26', 'ru_RU', 'БЫТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(108, '2021-01-26 14:52:26', 'ru_RU', 'СНЕЖНЫЙ ЗИМА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(109, '2021-01-26 14:52:26', 'ru_RU', 'СОЛНЕЧНЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(110, '2021-01-26 14:52:26', 'ru_RU', 'РАНО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(111, '2021-01-26 14:52:26', 'ru_RU', 'ОПУСКАТЬСЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(112, '2021-01-26 14:52:26', 'ru_RU', 'МОРОЗНЫЙ СОЛНЦЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(113, '2021-01-26 14:52:26', 'ru_RU', 'ВЫСОКИЙ ЕЛЬНИК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(114, '2021-01-26 14:52:26', 'ru_RU', 'СНЕЖНЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(115, '2021-01-26 14:52:26', 'ru_RU', 'ГИМНАЗИЧЕСКИЙ САД', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(116, '2021-01-26 14:52:26', 'ru_RU', 'НЕИЗМЕННЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(117, '2021-01-26 14:52:26', 'ru_RU', 'ПОГОЖИЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(118, '2021-01-26 14:52:26', 'ru_RU', 'ЛУЧИСТЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(119, '2021-01-26 14:52:26', 'ru_RU', 'ЗАВТРА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(120, '2021-01-26 14:52:26', 'ru_RU', 'ОБЕЩАЮЩИЙ МОРОЗ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(121, '2021-01-26 14:52:26', 'ru_RU', 'СОЛНЦЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(122, '2021-01-26 14:52:26', 'ru_RU', 'ГУЛЯНИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(123, '2021-01-26 14:52:26', 'ru_RU', 'СОБОРНЫЙ УЛИЦА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(124, '2021-01-26 14:52:26', 'ru_RU', 'КАТОК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(125, '2021-01-26 14:52:26', 'ru_RU', 'ГОРОДСКОЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(126, '2021-01-26 14:52:26', 'ru_RU', 'САД', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(127, '2021-01-26 14:52:26', 'ru_RU', 'РОЗОВЫЙ ВЕЧЕР', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(128, '2021-01-26 14:52:26', 'ru_RU', 'МУЗЫКА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(129, '2021-01-26 14:52:26', 'ru_RU', 'СТОРОНА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(130, '2021-01-26 14:52:26', 'ru_RU', 'СКОЛЬЗЯЩИЙ КАТОК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(131, '2021-01-26 14:52:26', 'ru_RU', 'ТОЛПА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(132, '2021-01-26 14:52:26', 'ru_RU', 'КАЗАТЬСЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(133, '2021-01-26 14:52:26', 'ru_RU', 'МЕЩЕРСКИЙ ОЛЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(134, '2021-01-26 14:52:26', 'ru_RU', 'БЕЗЗАБОТНЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(135, '2021-01-26 14:52:26', 'ru_RU', 'ВОТ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(136, '2021-01-26 14:52:26', 'ru_RU', 'БОЛЬШОЙ ПЕРЕМЕНА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(137, '2021-01-26 14:52:26', 'ru_RU', 'НОСИТЬСЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(138, '2021-01-26 14:52:26', 'ru_RU', 'ВИХРЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(139, '2021-01-26 14:52:26', 'ru_RU', 'СБОРНЫЙ ЗАЛ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(140, '2021-01-26 14:52:26', 'ru_RU', 'ГОНЯЮЩИЙСЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(141, '2021-01-26 14:52:26', 'ru_RU', 'БЛАЖЕННЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(142, '2021-01-26 14:52:26', 'ru_RU', 'ВИЗЖАЩИЙ ПЕРВОКЛАССНИЦА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(143, '2021-01-26 14:52:26', 'ru_RU', 'ПОЗВАТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(144, '2021-01-26 14:52:26', 'ru_RU', 'НЕОЖИДАННЫЙ НАЧАЛЬНИЦА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(145, '2021-01-26 14:52:26', 'ru_RU', 'ОСТАНОВИТЬСЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(146, '2021-01-26 14:52:26', 'ru_RU', 'СДЕЛАТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(147, '2021-01-26 14:52:26', 'ru_RU', 'РАЗБЕГ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(148, '2021-01-26 14:52:26', 'ru_RU', 'ГЛУБОКИЙ ВЗДОХ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(149, '2021-01-26 14:52:26', 'ru_RU', 'БЫСТРЫЙ УЖ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(150, '2021-01-26 14:52:26', 'ru_RU', 'ПРИВЫЧНЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(151, '2021-01-26 14:52:26', 'ru_RU', 'ЖЕНСКИЙ ДВИЖЕНИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(152, '2021-01-26 14:52:26', 'ru_RU', 'ОПРАВИТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(153, '2021-01-26 14:52:26', 'ru_RU', 'ВОЛОС', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(154, '2021-01-26 14:52:26', 'ru_RU', 'УГОЛОК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(155, '2021-01-26 14:52:26', 'ru_RU', 'ПЕРЕДНИК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(156, '2021-01-26 14:52:26', 'ru_RU', 'ПЛЕЧО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(157, '2021-01-26 14:52:26', 'ru_RU', 'ПОБЕЖАЛЫЙ ГЛАЗ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(158, '2021-01-26 14:52:26', 'ru_RU', 'НАВЕРХ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(159, '2021-01-26 14:52:26', 'ru_RU', 'МОЛОЖАВЫЙ НАЧАЛЬНИЦА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(160, '2021-01-26 14:52:26', 'ru_RU', 'СЕДОЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(161, '2021-01-26 14:52:26', 'ru_RU', 'СИДЕТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(162, '2021-01-26 14:52:26', 'ru_RU', 'СПОКОЙНЫЙ ВЯЗАНИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(163, '2021-01-26 14:52:26', 'ru_RU', 'РУКА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(164, '2021-01-26 14:52:26', 'ru_RU', 'ПИСЬМЕННЫЙ СТОЛ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(165, '2021-01-26 14:52:26', 'ru_RU', 'ЦАРСКИЙ ПОРТРЕТ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(166, '2021-01-26 14:52:26', 'ru_RU', 'ЗДРАВСТВОВАТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(167, '2021-01-26 14:52:26', 'ru_RU', 'СКАЗАТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(168, '2021-01-26 14:52:26', 'ru_RU', 'МЕЩЕРСКИЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(169, '2021-01-26 14:52:26', 'ru_RU', 'ФРАНЦУЗСКИЙ ГЛАЗ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(170, '2021-01-26 14:52:26', 'ru_RU', 'СОЖАЛЕНИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(171, '2021-01-26 14:52:26', 'ru_RU', 'СЛУШАТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(172, '2021-01-26 14:52:26', 'ru_RU', 'ОТВЕТИТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(173, '2021-01-26 14:52:26', 'ru_RU', 'ПОВЕДЕНИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(174, '2021-01-26 14:52:26', 'ru_RU', 'МЕЩЕРСКИЙ СТОЛ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(175, '2021-01-26 14:52:26', 'ru_RU', 'ЯСНЫЙ НЕЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(176, '2021-01-26 14:52:26', 'ru_RU', 'ЖИВОЙ ВЫРАЖЕНИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(177, '2021-01-26 14:52:26', 'ru_RU', 'ПРИСЕСТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(178, '2021-01-26 14:52:26', 'ru_RU', 'ЛЁГКИЙ ЛИЦО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(179, '2021-01-26 14:52:26', 'ru_RU', 'ГРАЦИОЗНЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(180, '2021-01-26 14:52:26', 'ru_RU', 'УМЕЛЫЙ МЕНЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(181, '2021-01-26 14:52:26', 'ru_RU', 'ПЛОХОЙ СОЖАЛЕНИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(182, '2021-01-26 14:52:26', 'ru_RU', 'УБЕДИТЬСЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(183, '2021-01-26 14:52:26', 'ru_RU', 'НАЧАЛЬНИЦА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(184, '2021-01-26 14:52:26', 'ru_RU', 'НИТКА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(185, '2021-01-26 14:52:26', 'ru_RU', 'ЛАКИРОВАННЫЙ ПОЛ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(186, '2021-01-26 14:52:26', 'ru_RU', 'КЛУБОК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(187, '2021-01-26 14:52:26', 'ru_RU', 'ПОСМОТРЕТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(188, '2021-01-26 14:52:26', 'ru_RU', 'ПОДНЯТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(189, '2021-01-26 14:52:26', 'ru_RU', 'ЛЮБОПЫТСТВО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(190, '2021-01-26 14:52:26', 'ru_RU', 'МЕЩЕРСКИЙ ГЛАЗ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(191, '2021-01-26 14:52:26', 'ru_RU', 'ПРОСТРАННЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(192, '2021-01-26 14:52:26', 'ru_RU', 'НРАВИТЬСЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(193, '2021-01-26 14:52:26', 'ru_RU', 'НЕОБЫКНОВЕННЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(194, '2021-01-26 14:52:26', 'ru_RU', 'ЧИСТЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(195, '2021-01-26 14:52:26', 'ru_RU', 'БОЛЬШОЙ КАБИНЕТ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(196, '2021-01-26 14:52:26', 'ru_RU', 'ХОРОШО ДЕНЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(197, '2021-01-26 14:52:26', 'ru_RU', 'ТЕПЛО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(198, '2021-01-26 14:52:26', 'ru_RU', 'БЛЕСТЯЩИЙ ГОЛЛАНДКА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(199, '2021-01-26 14:52:26', 'ru_RU', 'СВЕЖЕСТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(200, '2021-01-26 14:52:26', 'ru_RU', 'ЛАНДЫШ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(201, '2021-01-26 14:52:26', 'ru_RU', 'МОЛОДОЙ ЦАРЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(202, '2021-01-26 14:52:26', 'ru_RU', 'ВЕСЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(203, '2021-01-26 14:52:26', 'ru_RU', 'НАПИСАВШИЙ РОСТ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(204, '2021-01-26 14:52:26', 'ru_RU', 'БЛИСТАТЕЛЬНЫЙ ЗАЛ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(205, '2021-01-26 14:52:26', 'ru_RU', 'РОВНЫЙ ПРОБОР', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(206, '2021-01-26 14:52:26', 'ru_RU', 'АККУРАТНЫЙ МОЛОЧНАЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(207, '2021-01-26 14:52:26', 'ru_RU', 'ГОФРИРОВАННЫЙ ВОЛОС', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(208, '2021-01-26 14:52:26', 'ru_RU', 'ВЫЖИДАТЕЛЬНЫЙ НАЧАЛЬНИЦА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(209, '2021-01-26 14:52:26', 'ru_RU', 'МОЛЧАТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(210, '2021-01-26 14:52:26', 'ru_RU', 'НЕ ДЕВОЧКА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(211, '2021-01-26 14:52:26', 'ru_RU', 'ВТАЙНЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(212, '2021-01-26 14:52:26', 'ru_RU', 'ПРОСТО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(213, '2021-01-26 14:52:26', 'ru_RU', 'ВЕСЕЛО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(214, '2021-01-26 14:52:26', 'ru_RU', 'МЕЩЕРСКИЙ ЖЕНЩИНА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(215, '2021-01-26 14:52:26', 'ru_RU', 'МНОГОЗНАЧИТЕЛЬНЫЙ НАЧАЛЬНИЦА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(216, '2021-01-26 14:52:26', 'ru_RU', 'МАТОВЫЙ ЛИЦО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(217, '2021-01-26 14:52:26', 'ru_RU', 'СЛЕГКА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(218, '2021-01-26 14:52:26', 'ru_RU', 'ЗААЛЕТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(219, '2021-01-26 14:52:26', 'ru_RU', 'ЭТО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(220, '2021-01-26 14:52:26', 'ru_RU', 'НЕ МЕНЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(221, '2021-01-26 14:52:26', 'ru_RU', 'ХОРОШИЙ ВОЛОС', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(222, '2021-01-26 14:52:26', 'ru_RU', 'ТРОНУТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(223, '2021-01-26 14:52:26', 'ru_RU', 'МЕЩЕРСКИЙ РУКА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(224, '2021-01-26 14:52:26', 'ru_RU', 'КРАСИВЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(225, '2021-01-26 14:52:26', 'ru_RU', 'УБРАВШИЙ ГОЛОВА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(226, '2021-01-26 14:52:26', 'ru_RU', 'НЕ ПРИЧЕСКА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(227, '2021-01-26 14:52:26', 'ru_RU', 'НЕ ГРЕБЕНЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(228, '2021-01-26 14:52:26', 'ru_RU', 'НЕ РОДИТЕЛЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(229, '2021-01-26 14:52:26', 'ru_RU', 'ТУФЕЛЬКА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(230, '2021-01-26 14:52:26', 'ru_RU', 'ПОВТОРЯТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(231, '2021-01-26 14:52:26', 'ru_RU', 'УПУСКАТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(232, '2021-01-26 14:52:26', 'ru_RU', 'СОВЕРШЕННЫЙ ВИД', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(233, '2021-01-26 14:52:26', 'ru_RU', 'ГИМНАЗИСТКА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(234, '2021-01-26 14:52:26', 'ru_RU', 'ТУТ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(235, '2021-01-26 14:52:26', 'ru_RU', 'МЕЩЕРСКИЙ ПРОСТОТА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(236, '2021-01-26 14:52:26', 'ru_RU', 'ВДРУГ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(237, '2021-01-26 14:52:26', 'ru_RU', 'ВЕЖЛИВЫЙ СПОКОЙСТВИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(238, '2021-01-26 14:52:26', 'ru_RU', 'ПЕРЕБИТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(239, '2021-01-26 14:52:26', 'ru_RU', 'ПРОСТИТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(240, '2021-01-26 14:52:26', 'ru_RU', 'ОШИБАТЬСЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(241, '2021-01-26 14:52:26', 'ru_RU', 'ЗНАТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(242, '2021-01-26 14:52:26', 'ru_RU', 'ДРУГ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(243, '2021-01-26 14:52:26', 'ru_RU', 'СОСЕД', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(244, '2021-01-26 14:52:26', 'ru_RU', 'ПАПА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(245, '2021-01-26 14:52:26', 'ru_RU', 'БРАТ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(246, '2021-01-26 14:52:26', 'ru_RU', 'АЛЕКСЕЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(247, '2021-01-26 14:52:26', 'ru_RU', 'МИХАЙЛО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(248, '2021-01-26 14:52:26', 'ru_RU', 'ПРОШЛОЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(249, '2021-01-26 14:52:26', 'ru_RU', 'ЛЕТО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(250, '2021-01-26 14:52:26', 'ru_RU', 'ДЕРЕВНЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(251, '2021-01-26 14:52:26', 'ru_RU', 'МЕСЯЦ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(252, '2021-01-26 14:52:26', 'ru_RU', 'РАЗГОВОР', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(253, '2021-01-26 14:52:26', 'ru_RU', 'КАЗАЧИЙ ОФИЦЕР', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(254, '2021-01-26 14:52:26', 'ru_RU', 'НЕКРАСИВЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(255, '2021-01-26 14:52:26', 'ru_RU', 'ПЛЕБЕЙСКИЙ ВИД', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(256, '2021-01-26 14:52:26', 'ru_RU', 'НИЧЕГО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(257, '2021-01-26 14:52:26', 'ru_RU', 'НИЧЕГО ОЛЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(258, '2021-01-26 14:52:26', 'ru_RU', 'ЗАСТРЕЛИТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(259, '2021-01-26 14:52:26', 'ru_RU', 'МЕЩЕРСКИЙ ПЛАТФОРМА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(260, '2021-01-26 14:52:26', 'ru_RU', 'ВОКЗАЛ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(261, '2021-01-26 14:52:26', 'ru_RU', 'БОЛЬШОЙ ТОЛПА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(262, '2021-01-26 14:52:26', 'ru_RU', 'ПРИБЫВШИЙ НАРОД', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(263, '2021-01-26 14:52:26', 'ru_RU', 'НЕВЕРОЯТНЫЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(264, '2021-01-26 14:52:26', 'ru_RU', 'ОШЕЛОМИВШИЙ НАЧАЛЬНИЦА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(265, '2021-01-26 14:52:26', 'ru_RU', 'ПРИЗНАНИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(266, '2021-01-26 14:52:26', 'ru_RU', 'ПОДТВЕРДИТЬСЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(267, '2021-01-26 14:52:26', 'ru_RU', 'СОВЕРШЕННЫЙ ОФИЦЕР', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(268, '2021-01-26 14:52:26', 'ru_RU', 'ЗАЯВИТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(269, '2021-01-26 14:52:26', 'ru_RU', 'СУДЕБНЫЙ СЛЕДОВАТЕЛЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(270, '2021-01-26 14:52:26', 'ru_RU', 'ЗАВЛЕЧЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(271, '2021-01-26 14:52:26', 'ru_RU', 'ПОКЛЯСТЬСЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(272, '2021-01-26 14:52:26', 'ru_RU', 'БЛИЗКИЙ ЖЕНА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(273, '2021-01-26 14:52:26', 'ru_RU', 'УБИЙСТВО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(274, '2021-01-26 14:52:26', 'ru_RU', 'НОВОЧЕРКАССК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(275, '2021-01-26 14:52:26', 'ru_RU', 'БРАК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(276, '2021-01-26 14:52:26', 'ru_RU', 'ДАТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(277, '2021-01-26 14:52:26', 'ru_RU', 'ИЗДЕВАТЕЛЬСТВО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(278, '2021-01-26 14:52:26', 'ru_RU', 'СТРАНИЧКА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(279, '2021-01-26 14:52:26', 'ru_RU', 'ГДЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(280, '2021-01-26 14:52:26', 'ru_RU', 'ГОВОРИТЬСЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(281, '2021-01-26 14:52:26', 'ru_RU', 'ДНЕВНИК', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-26 14:52:26'),
(282, '2021-01-29 07:58:27', 'ru_RU', 'ПОКУПАТЕЛЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:27'),
(283, '2021-01-29 07:58:27', 'ru_RU', 'СОВЕРШИТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:27'),
(284, '2021-01-29 07:58:27', 'ru_RU', 'СДЕЛКА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:27'),
(285, '2021-01-29 07:58:27', 'ru_RU', 'ПРЕДСТАВИТЕЛЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:27'),
(286, '2021-01-29 07:58:27', 'ru_RU', 'ЛОНДОНСКИЙ РУССКАЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:27'),
(287, '2021-01-29 07:58:27', 'ru_RU', 'ПОЭТОМУ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:27'),
(288, '2021-01-29 07:58:27', 'ru_RU', 'ГРУППА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:27'),
(289, '2021-01-29 07:58:27', 'ru_RU', 'ПРЕДПОЛАГАТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:27'),
(290, '2021-01-29 07:58:27', 'ru_RU', 'ИЗДАНИЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:27'),
(291, '2021-01-29 07:58:27', 'ru_RU', 'НОВОЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:27'),
(292, '2021-01-29 07:58:27', 'ru_RU', 'ВЛАДЕЛЕЦ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:27'),
(293, '2021-01-29 07:58:28', 'ru_RU', 'ПОРТРЕТ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(294, '2021-01-29 07:58:28', 'ru_RU', 'РУССКИЙ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(295, '2021-01-29 07:58:28', 'ru_RU', 'ПИСАТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(296, '2021-01-29 07:58:28', 'ru_RU', 'ДОСТАТЬСЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(297, '2021-01-29 07:58:28', 'ru_RU', 'ПОЛОТНО', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(298, '2021-01-29 07:58:28', 'ru_RU', 'РУССКОЯЗЫЧНЫЙ КОЛЛЕКЦИОНЕР', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(299, '2021-01-29 07:58:28', 'ru_RU', 'ИТОГОВЫЙ СТОИМОСТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(300, '2021-01-29 07:58:28', 'ru_RU', 'КАРТИНА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(301, '2021-01-29 07:58:28', 'ru_RU', 'ДОРОГОЙ ПОРТРЕТ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(302, '2021-01-29 07:58:28', 'ru_RU', 'ПРОДАВШИЙ ИСТОРИЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(303, '2021-01-29 07:58:28', 'ru_RU', 'ПОБИТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(304, '2021-01-29 07:58:28', 'ru_RU', 'АУКЦИОННЫЙ РЕКОРД', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(305, '2021-01-29 07:58:28', 'ru_RU', 'РАБОТА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(306, '2021-01-29 07:58:28', 'ru_RU', 'МАСТЕР', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(307, '2021-01-29 07:58:28', 'ru_RU', 'РАНЕЕ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(308, '2021-01-29 07:58:28', 'ru_RU', 'ДОРОГА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(309, '2021-01-29 07:58:28', 'ru_RU', 'СЧИТАТЬСЯ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(310, '2021-01-29 07:58:28', 'ru_RU', 'БОТТИЧЕЛЛИ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(311, '2021-01-29 07:58:28', 'ru_RU', 'МАДОННА', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(312, '2021-01-29 07:58:28', 'ru_RU', 'РОКФЕЛЛЕР', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(313, '2021-01-29 07:58:28', 'ru_RU', 'МЛАДЕНЕЦ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(314, '2021-01-29 07:58:28', 'ru_RU', 'ЮНЫЙ ИОАНН', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:28'),
(315, '2021-01-29 07:58:29', 'ru_RU', 'КРЕСТИТЕЛЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:29'),
(316, '2021-01-29 07:58:29', 'ru_RU', 'КУПИТЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:29'),
(317, '2021-01-29 07:58:29', 'ru_RU', 'МИЛЛИОН', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 07:58:29'),
(318, '2021-01-29 11:01:21', 'ru_RU', 'ГЛИНЯННЫЙ НАСЫПЬ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2021-01-29 11:01:21');

-- --------------------------------------------------------

--
-- Table structure for table `dictionary_draft`
--

DROP TABLE IF EXISTS `dictionary_draft`;
CREATE TABLE IF NOT EXISTS `dictionary_draft` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `user` varchar(250) NOT NULL,
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
  UNIQUE KEY `lexeme` (`lexeme`,`lang`,`user`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `dictionary_draft`
--

INSERT INTO `dictionary_draft` (`id`, `created`, `user`, `lang`, `lexeme`, `stopword`, `joy`, `trust`, `fear`, `surprise`, `sadness`, `disgust`, `anger`, `anticipation`, `changed`) VALUES
(1, '2021-02-01 07:53:27', 'pavel', 'ru_RU', 'ХОЛОДНЫЙ ВЕТЕР', 0, 0, 0, 0.2, 0, 0, 0, 0, 0, '2021-02-01 11:58:06'),
(2, '2021-02-01 08:08:41', 'pavel', 'ru_RU', 'ГОЛЫЙ ДЕРЕВО', 0, 0, 0, 0, 0, 0, 0.2, 0, 0, '2021-02-01 08:08:41'),
(3, '2021-02-02 07:42:04', 'pavel', 'ru_RU', 'АККУРАТНЫЙ МОЛОЧНАЯ', 0, 0, 0.2, 0, 0, 0, 0, 0, 0, '2021-02-02 07:42:04');
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
