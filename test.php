<?php
error_reporting(E_ALL | E_STRICT);

// first we include phpmorphy library
//Users/kmvpvl/Documents/phpmorphy/libs/phpmorphy/src
require_once (dirname(__FILE__) . '/../phpmorphy/libs/phpmorphy/src/common.php');
require_once ('classEA.php');

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

$t .= "Патриарх Кирилл в декабре попросил клириков и прихожан сдать плазму крови для борьбы с пандемией коронавируса. Он отметил, что переливание плазмы крови — один из наиболее эффективных методов лечения COVID-19 для тяжелобольных пациентов. «Для этих людей данная процедура является иногда последней надеждой на исцеление. Помочь им в этом — наш долг христианской любви», — заявил патриарх.";

$t .= "В Русской православной церкви (РПЦ) также посоветовали быстрее привиться от COVID-19. По словам митрополита Илариона, побочные эффекты прививки «минимальны» и не сравнимы «с теми мучениями, которые испытывают» заразившиеся.";
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
				echo $prev_noun, "\n";   
			}
			$prev_noun = $morphy->castFormByGramInfo($word,'С',array('ЕД','ИМ'),TRUE)[0];
			if ($prev_adj) {
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
					echo $prev_adj, " ", $prev_noun, "\n";   
					$prev_noun = "";
					$prev_part = "";
					$prev_adj = "";
				} else {
					echo $prev_adj, "\n";   
				}
			}
			$prev_adj = $prev_part?$prev_part:"".$morphy->castFormByGramInfo($word,'П',array('ЕД','ИМ'),TRUE)[0];
			continue;
		}
		if (in_array('КР_ПРИЛ', $part_of_speech)) {
			if ($prev_adj) {
				if ($prev_noun) {
					echo $prev_adj, " ", $prev_noun, "\n";   
					$prev_noun = "";
					$prev_part = "";
					$prev_adj = "";
				} else {
					echo $prev_adj, "\n";   
				}
			}
			$prev_adj = $prev_part?$prev_part:"".$morphy->castFormByGramInfo($word,'П',array('ЕД','ИМ'),TRUE)[0];
			if ($prev_noun) {
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
					echo $prev_adj, " ", $prev_noun, "\n";   
					$prev_noun = "";
					$prev_part = "";
					$prev_adj = "";
				} else {
					echo $prev_adj, "\n";   
				}
			}
			$prev_adj = $prev_part?$prev_part:"".$morphy->castFormByGramInfo($word,'ПРИЧАСТИЕ',array('ЕД','ИМ'),TRUE)[0];
			if ($prev_noun) {
				echo $prev_adj, " ", $prev_noun, "\n";   
				$prev_noun = "";
				$prev_part = "";
				$prev_adj = "";
			}
			continue;
		}
		if (in_array('Н', $part_of_speech)) {
			$prev_adv = $morphy->castFormByGramInfo($word,'Н',array(),TRUE)[0];
			echo $prev_part?$prev_part.' ':"", $prev_adv, "\n";   
			$prev_part = "";
			continue;
		}
		if (in_array('Г', $part_of_speech)) {
			$prev_verb = $morphy->castFormByGramInfo($word,'ИНФИНИТИВ',array(),TRUE)[0];
			echo $prev_part?$prev_part.' ':"", $prev_verb, "\n";   
			$prev_part = "";
			continue;
		}
		if (in_array('ЧАСТ', $part_of_speech)) {
			$prev_part = $word;
			//echo $prev_part, "\n";   
			continue;
		}
		//$all = $morphy->getAllForms($word);

		// $base = $morphy->getBaseForm($word, phpMorphy::NORMAL); // normal behaviour
		// $base = $morphy->getBaseForm($word, phpMorphy::IGNORE_PREDICT); // don`t use prediction
		// $base = $morphy->getBaseForm($word, phpMorphy::ONLY_PREDICT); // always predict word

		//$is_predicted = $morphy->isLastPredicted(); // or $morphy->getLastPredictionType() == phpMorphy::PREDICT_BY_NONE
		//$is_predicted_by_db = $morphy->getLastPredictionType() == phpMorphy::PREDICT_BY_DB;
		//$is_predicted_by_suffix = $morphy->getLastPredictionType() == phpMorphy::PREDICT_BY_SUFFIX;

		//        $word = iconv('utf-8', $morphy->getEncoding(), $word);
  //      $collection = $morphy->findWord($word);
		// or var_dump($morphy->getAllFormsWithGramInfo($word)); for debug

	/*    if(false === $collection) { 
			echo $word, " NOT FOUND\n";
			continue;
		} else {
		}

		echo $is_predicted ? '-' : '+', $word, "\n";
		echo 'lemmas: ', implode(', ', $base), "\n";
		echo 'all: ', implode(', ', $all), "\n";
		echo 'poses: ', implode(', ', $part_of_speech), "\n";
		
		echo "\n";
		// $collection collection of paradigm for given word

		// TODO: $collection->getByPartOfSpeech(...);
		foreach($collection as $paradigm) {
			// TODO: $paradigm->getBaseForm();
			// TODO: $paradigm->getAllForms();
			// TODO: $paradigm->hasGrammems(array('', ''));
			// TODO: $paradigm->getWordFormsByGrammems(array('', ''));
			// TODO: $paradigm->hasPartOfSpeech('');
			// TODO: $paradigm->getWordFormsByPartOfSpeech('');

			
			echo "lemma: ", $paradigm[0]->getWord(), "\n";
			foreach($paradigm->getFoundWordForm() as $found_word_form) {
				echo
					$found_word_form->getWord(), ' ',
					$found_word_form->getPartOfSpeech(), ' ',
					'(', implode(', ', $found_word_form->getGrammems()), ')',
					"\n";
			}
			echo "\n";
			
			foreach($paradigm as $word_form) {
				// TODO: $word_form->getWord();
				// TODO: $word_form->getFormNo();
				// TODO: $word_form->getGrammems();
				// TODO: $word_form->getPartOfSpeech();
				// TODO: $word_form->hasGrammems(array('', ''));
			}
		}


		$prev_adj = "";
		$prev_gramminfo = "";
		if ('' != $word) {
			//echo '+'.$word.'+';
			$base = $morphy->getBaseForm($word);
			if ($base) {
				foreach ($base as $baseword) {

					$gramminfos = $morphy->getGramInfo($baseword);
					foreach ($gramminfos as $r) {
						foreach ($r as $gramminfo) {
							switch ($gramminfo['pos']) {
								case 'С':
									if (in_array('ИМ', $gramminfo['grammems']) && !in_array('ДФСТ', $gramminfo['grammems'])) {
										// именительный падеж существительного
										if (1) {
											echo $prev_adj, ' ', $baseword;
											var_dump($gramminfo);
											$prev_adj = "";
										}
									}
									break;
								case 'П':
									if (in_array('ИМ', $gramminfo['grammems']) && !in_array('ДФСТ', $gramminfo['grammems'])) {
										// именительный падеж прилагательного
											echo '-П-', $baseword;
											$prev_adj = $baseword;
										}
									break;
								default:
									//$prev_adj = "";
							}
						}
					}
				}
			}
			else {
				//echo '\'-' . $word . '-\' is not recognized';
			}
			//echo "--\n";
			}
		*/
	}
}
echo '----------';
//var_dump($morphy->getBaseForm('ДЕТЕЙ'));
//var_dump($morphy->getGramInfo('СТОЛЬ'));
//var_dump($morphy->getGramInfo('ПОБОЧНЫЙ'));
//var_dump($morphy->castFormByGramInfo('КРАСНЫХ','П',array('МН','ИМ'),TRUE));
$dict = new EmotionalDictionary();
$dict->add(new EmotionalLexeme("КРАСНЫЙ ФОНАРЬ"), new EmotionalVector(null,
    $joy = 0.0,     $trust = -1.0,   $fear = 0.0,    $surprise = 0.0, 
    $sadness = 0.0, $disgust = 0.0, $anger = 0.0,   $anticipation = 1.0
));
$dict->save();
var_dump($dict);
?>