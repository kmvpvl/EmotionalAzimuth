<?php
error_reporting(E_ALL | E_STRICT);

// first we include phpmorphy library
//Users/kmvpvl/Documents/phpmorphy/libs/phpmorphy/src
require_once (dirname(__FILE__) . '/../phpmorphy/libs/phpmorphy/src/common.php');
require_once ('classEA.php');
$dict = new EmotionalDictionary();
//var_dump($dict);

// set some options
$opts = array(
	// storage type, follow types supported
	// PHPMORPHY_STORAGE_FILE - use file operations(fread, fseek) for dictionary access, this is very slow...
	// PHPMORPHY_STORAGE_SHM - load dictionary in shared memory(using shmop php extension), this is preferred mode
	// PHPMORPHY_STORAGE_MEM - load dict to memory each time when phpMorphy intialized, this useful when shmop ext. not activated. Speed same as for PHPMORPHY_STORAGE_SHM type
	'storage' => PHPMORPHY_STORAGE_FILE,
	// Enable prediction by suffix
	'predict_by_suffix' => true, 
	// Enable prediction by prefix
	'predict_by_db' => true,
	// TODO: comment this
	'graminfo_as_text' => true,
);

// Path to directory where dictionaries located
$dir = dirname(__FILE__) . '/../phpmorphy/libs/phpmorphy/dicts';
$lang = 'ru_RU';

// Create phpMorphy instance
try {
	$morphy = new phpMorphy($dir, $lang, $opts);
} catch(phpMorphy_Exception $e) {
	die('Error occured while creating phpMorphy instance: ' . PHP_EOL . $e);
}

// All words in dictionary in UPPER CASE, so don`t forget set proper locale via setlocale(...) call
// $morphy->getEncoding() returns dictionary encoding
$t = "Неверие в пандемию коронавируса столь же опасно, как и неверие в Бога. Об этом во время проповеди после литургии в храме Христа Спасителя заявил Патриарх Московский и всея Руси Кирилл. Трансляцию вел телеканал «Союз».";

$t .= "Есть люди, которые ни во что не верят — ни в болезнь, ни в опасность и пренебрегают предписаниями медиков, сказал патриарх. Однако в мире существуют не только «эти глупые люди», но и множество других, которые и в Бога не верят, отметил он.";

$t .= "Очень опасно, когда люди не верят в Бога, смертельно опасно. Так же, как сегодня опасно, если люди не верят в распространение инфекции и не предохраняют себя от этой инфекции», — заявил патриарх Кирилл.";

$t .= "Он попросил прихожан соблюдать все необходимые требования: носить маски, соблюдать социальную дистанцию и «делать очень многое, к чему мы не привыкли». «Потому что наша неосторожность может послужить причиной страшного заболевания», — сказал предстоятель церкви.";

$t .= "Патриарх Кирилл назвал COVID сигналом от Господа и последним звонком.";

//$t .= "Патриарх Кирилл в декабре попросил клириков и прихожан сдать плазму крови для борьбы с пандемией коронавируса. Он отметил, что переливание плазмы крови — один из наиболее эффективных методов лечения COVID-19 для тяжелобольных пациентов. «Для этих людей данная процедура является иногда последней надеждой на исцеление. Помочь им в этом — наш долг христианской любви», — заявил патриарх.";

//$t .= "В Русской православной церкви (РПЦ) также посоветовали быстрее привиться от COVID-19. По словам митрополита Илариона, побочные эффекты прививки «минимальны» и не сравнимы «с теми мучениями, которые испытывают» заразившиеся.";
//$t = "Мать - Евгения Яковлевна, прекрасная хозяйка, очень заботливая и любящая, жила исключительно жизнью детей и мужа. Но, при этом, страстно любила театр, хотя и посещала его нечасто. В ранней молодости она была отдана в таганрогский частный пансион благородных девиц, где обучалась танцам и хорошим манерам. Евгения Яковлевна оказывала огромное влияние на формирование характеров своих детей, воспитывая в них отзывчивость, уважение и сострадание к слабым, угнетённым, любовь к природе и миру. Антон Павлович Чехов впоследствии говорил, что \"талант в нас со стороны отца, а душа - со стороны матери\".";
echo ($t . "\n");
$sentences = EmotionalText::parseText($t);
foreach ($sentences as $sentence) {
	$words = EmotionalText::parseSentence($sentence);
	$prev_noun = "";
	$prev_adj = "";
	$prev_part = "";
	$prev_adv = "";
	foreach($words as $word) {
		$word = trim(mb_strtoupper($word));
		$part_of_speech = $morphy->getPartOfSpeech($word);
		if (!$word) continue;
		if (!$part_of_speech) continue;
		//echo '+', $word, '+';
		if (in_array('СОЮЗ', $part_of_speech)
		|| in_array('ПРЕДЛ', $part_of_speech)
		) continue;
		if (in_array('С', $part_of_speech)) {
			if ($prev_noun) {
				$dict->add(new EmotionalLexeme($prev_noun, $lang));
				echo $prev_noun, "\n";   
			}
			$prev_noun = $morphy->castFormByGramInfo($word,'С',array('ЕД','ИМ'),TRUE)[0];
			if ($prev_adj) {
				$dict->add(new EmotionalLexeme($prev_adj." ".$prev_noun, $lang));
				echo $prev_adj, " ", $prev_noun, "\n";   
				$prev_noun = "";
				$prev_part = "";
				$prev_adj = "";
			}
			continue;
		}
		if (in_array('П', $part_of_speech)) {
			if ($prev_adj) {
				if ($prev_noun) {
					$dict->add(new EmotionalLexeme($prev_adj." ".$prev_noun, $lang));
					echo $prev_adj, " ", $prev_noun, "\n";   
					$prev_noun = "";
					$prev_part = "";
					$prev_adj = "";
				} else {
					$dict->add(new EmotionalLexeme($prev_adj, $lang));
					echo $prev_adj, "\n";   
				}
			}
			$prev_adj = $prev_part?$prev_part:"".$morphy->castFormByGramInfo($word,'П',array('ЕД','ИМ'),TRUE)[0];
			continue;
		}
		if (in_array('КР_ПРИЛ', $part_of_speech)) {
			if ($prev_adj) {
				if ($prev_noun) {
					$dict->add(new EmotionalLexeme($prev_adj." ".$prev_noun, $lang));
					echo $prev_adj, " ", $prev_noun, "\n";   
					$prev_noun = "";
					$prev_part = "";
					$prev_adj = "";
				} else {
					$dict->add(new EmotionalLexeme($prev_adj, $lang));
					echo $prev_adj, "\n";   
				}
			}
			$prev_adj = $prev_part?$prev_part:"".$morphy->castFormByGramInfo($word,'П',array('ЕД','ИМ'),TRUE)[0];
			if ($prev_noun) {
				$dict->add(new EmotionalLexeme($prev_adj." ".$prev_noun, $lang));
				echo $prev_adj, " ", $prev_noun, "\n";   
				$prev_noun = "";
				$prev_part = "";
				$prev_adj = "";
			}
			continue;
		}
		if (in_array('ПРИЧАСТИЕ', $part_of_speech) ) {
			if ($prev_adj) {
				if ($prev_noun) {
					$dict->add(new EmotionalLexeme($prev_adj." ".$prev_noun, $lang));
					echo $prev_adj, " ", $prev_noun, "\n";   
					$prev_noun = "";
					$prev_part = "";
					$prev_adj = "";
				} else {
					$dict->add(new EmotionalLexeme($prev_adj, $lang));
					echo $prev_adj, "\n";   
				}
			}
			$prev_adj = $prev_part?$prev_part:"".$morphy->castFormByGramInfo($word,'ПРИЧАСТИЕ',array('ЕД','ИМ'),TRUE)[0];
			if ($prev_noun) {
				$dict->add(new EmotionalLexeme($prev_adj." ".$prev_noun, $lang));
				echo $prev_adj, " ", $prev_noun, "\n";   
				$prev_noun = "";
				$prev_part = "";
				$prev_adj = "";
			}
			continue;
		}
		if (in_array('Н', $part_of_speech)) {
			$prev_adv = $morphy->castFormByGramInfo($word,'Н',array(),TRUE)[0];
			$dict->add(new EmotionalLexeme($prev_part?$prev_part.' ':"".$prev_adv, $lang));
			echo $prev_part?$prev_part.' ':"", $prev_adv, "\n";   
			$prev_part = "";
			continue;
		}
		if (in_array('Г', $part_of_speech)) {
			$prev_verb = $morphy->castFormByGramInfo($word,'ИНФИНИТИВ',array(),TRUE)[0];
			$dict->add(new EmotionalLexeme($prev_part?$prev_part.' ':"".$prev_verb, $lang));
			echo $prev_part?$prev_part.' ':"", $prev_verb, "\n";   
			$prev_part = "";
			continue;
		}
		if (in_array('ЧАСТ', $part_of_speech)) {
			$prev_part = $word;
			//echo $prev_part, "\n";   
			continue;
		}
	}
}
echo "----------\n";
//var_dump($morphy->getBaseForm('ДЕТЕЙ'));
//var_dump($morphy->getGramInfo('СТОЛЬ'));
//var_dump($morphy->getGramInfo('ПОБОЧНЫЙ'));
//var_dump($morphy->castFormByGramInfo('КРАСНЫХ','П',array('МН','ИМ'),TRUE));

#$dict->add(new EmotionalLexeme("ЗАРАЗИВШИЙСЯ МУЧЕНИЕ"), new EmotionalVector(null,
#    $joy = -1.0,     $trust = -1.0,   $fear = 1.0,    $surprise = 0.0, 
#    $sadness = 1.0, $disgust = 1.0,  $anger = 1.0,   $anticipation = 1.0
#));
#$dict->getLexeme('ИСПЫТЫВАТЬ')->emotion = new EmotionalVector(null,
#    $joy = 0.0,     $trust = -1.0,   $fear = 1.0,    $surprise = 1.0, 
#    $sadness = 1.0, $disgust = 0.0,  $anger = 0.0,   $anticipation = 1.0
#);
#var_dump($dict);
/*foreach ($dict->eLexemes as $key=>$val) {
	echo bin2hex($key), "=>", $val->normal, "\n\r";
}*/
//unset($dict->eLexemes[hex2bin('d41d8cd98f00b204e9800998ecf8427e')]);
?>