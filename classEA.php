<?php
error_reporting(E_ERROR | E_STRICT);
if (!isset($_POST["username"]) || !isset($_POST["password"]) || !isset($_POST["language"]) || !isset($_POST["timezone"])) {
    http_response_code(401);
    die ("Unathorized request!");
}
$user = null;
$user = new EAUser($_POST["username"], $_POST["password"]);
$user->authorize();

require_once (dirname(__FILE__) . '/../phpmorphy/libs/phpmorphy/src/common.php');
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

$morphy = null;
$eDict = null;
$morphy = new phpMorphy($dir, $lang, $opts);
$eDict = new EmotionalDictionary();

final class EAException extends Exception {

}
class EAUser {
    protected $_hash;
    protected $username;
    function __construct($username, $password) {
        $this->username = $username;
        $this->_hash = md5($username . $password);
    }
    function authorize() {
        $users_xml = simplexml_load_file(dirname(__FILE__) . '/users.xml');
        if (!$users_xml) throw new EAException("Users.xml not found!");
        $found = $users_xml->xpath("//user[@id='" . $this->username . "']");
        $u = null;
        if (!$found) {
            $u = $users_xml->addChild("user");
            $u->addAttribute("id", $this->username);
            $u->addAttribute("md5", $this->_hash);
            $u->addAttribute("roles", "read;save_draft");
            $users_xml->asXML(dirname(__FILE__) . '/users.xml');
        } else {
            $u = $found[0];
        }
        if ((string) $u["md5"] != $this->_hash) throw new EAException("Password incorrect! " . $this->_hash);
        return $u;
    }
    function hasRole($rolename) {
        $xml_user = $this->authorize();
        $roles = (string) $xml_user["roles"];
        $roles_arr = explode(";", $roles);
        if (!in_array($rolename, $roles_arr)) throw new EAException("User ".$this->username." has no ".$rolename." role!");
        return true;
    }
    function __get($name) {
        switch ($name) {
            case 'name':
                return $this->username;
                break;
            
            default:
                # code...
                break;
        }
    }
}
class EmotionalDictionary {
    protected $dblink;
    function __construct() {
		$settings = parse_ini_file("settings.ini", true);
        $host = "";
        $database = "";
        $user = "";
        $password = "";
        $port = "";
		
		if (array_key_exists("database", $settings)) {
			if (array_key_exists("host", $settings["database"])) $host = $settings["database"]["host"];
			if (array_key_exists("database", $settings["database"])) $database = $settings["database"]["database"];
			if (array_key_exists("user", $settings["database"])) $user = $settings["database"]["user"];
			if (array_key_exists("password", $settings["database"])) $password = $settings["database"]["password"];
			if (array_key_exists("port", $settings["database"])) $port = $settings["database"]["port"];
        } else throw new EAException ("database settings are absent"); 
        //var_dump($settings);
		
		$this->dblink = new mysqli($host, $user, $password, $database, $port);
		if ($this->dblink->connect_errno) throw new EAException("Unable connect to database (`" . $host . "` - `" . $database . "`): " . $this->dblink->connect_errno . " - " . $this->dblink->connect_error);
		$this->dblink->set_charset("utf-8");
		$this->dblink->query("set names utf8");
		$this->dblink->query("SET @@session.time_zone='+00:00';");
    }
    function __destruct() {
		$this->dblink->close();
    }
    function getLexemesTopN(string $first_letters, string $lang, bool $stopword, int $draft_count, int $N = 10) {
        global $user;
        if (!is_null($user)) $user->hasRole("editor");
	    $x = $this->dblink->query("call getDictionaryTopN('" . $first_letters . "', '" . $lang . "', " . ($stopword?1:0) . ", " . $draft_count . ", " . $N . ")");
        if ($this->dblink->errno) throw new EAException("Could not get lexemes from dictionary: " . $this->dblink->errno . " - " . $this->dblink->error);
        if (!$x) throw new EAException("Could not get lexemes from dictionary: lexemes are absent");
        $z = array();
        while ($y = $x->fetch_assoc()) {
            //var_dump($y);
            $z[$y["id"]] = new EmotionalLexeme(null, null, $y);
        };
        $this->dblink->next_result();
        return $z;
    }
    function getUnassignedDraftLexemesTopN($_first_letters, $_lang, $_assigned, int $N = 10) {
        global $user;
        if (!is_null($user)) {
            $user->hasRole("read");
            $sql = "call getDraftDictionaryTopN('" . $user->name . "', '" . $_first_letters . "', '" . $_lang . "', " . ($_assigned? 1: 0) . ", " . $N . ")";
            $x = $this->dblink->query($sql);
            if ($this->dblink->errno) throw new EAException("Could not get draft lexemes from dictionary: " . $this->dblink->errno . " - " . $this->dblink->error . " - sql: " . $sql);
            if (!$x) throw new EAException("Could not get draft lexemes from dictionary: lexemes are absent");
            $z = array();
            while ($y = $x->fetch_assoc()) {
                //var_dump($y);
                $z[] = new EmotionalLexeme(null, null, $y);
            };
            $this->dblink->next_result();
            return $z;
        } else {
            return null;
        }
    }
    function add(EmotionalLexeme $eL) {
        global $user;
        if (!is_null($user)) $user->hasRole("read") && $user->hasRole("save_dictionary");
	    $this->dblink->query("select addLexemeToDictionary('" . $eL->normal . "', '" . $eL->lang . "', " . (is_null($eL->stopword) ? "null" : $eL->stopword) . ", " . (is_null($eL->emotion)?"null" : "'".json_encode($eL->emotion)."'") . ");");
        if ($this->dblink->errno) throw new EAException("Could not create lexeme in dictionary: " . $this->dblink->errno . " - " . $this->dblink->error);
        return $this->getLexeme($eL->normal, $eL->lang);
    }
    function addDraft(EmotionalLexeme $eL) {
        global $user;
        if (!is_null($user)) {
            $user->hasRole("read") && $user->hasRole("save_draft");

	        $this->dblink->query("select addDraftLexemeToDictionary('" . $user->name . "', '" . $eL->normal . "', '" . $eL->lang . "', " . (is_null($eL->stopword) ? "null" : $eL->stopword) . ", " . (is_null($eL->emotion)?"null" : "'".json_encode($eL->emotion)."'") . ");");
            if ($this->dblink->errno) throw new EAException("Could not create draft lexeme in dictionary: " . $this->dblink->errno . " - " . $this->dblink->error);
            return $this->getDraftLexeme($eL->normal, $eL->lang);
        } else {
            throw new EAException("Could not get draft lexeme from dictionary: user is null");
        }
    }
    function getLexeme($lexeme, $lang): ?EmotionalLexeme {
        global $user;
        if (!is_null($user)) $user->hasRole("read");
        $el = new EmotionalLexeme($lexeme, $lang);
	    $x = $this->dblink->query("call getLexemeFromDictionary('" . $el->normal . "', '" . $el->lang . "')");
        if ($this->dblink->errno) throw new EAException("Could not get lexeme from dictionary: " . $this->dblink->errno . " - " . $this->dblink->error);
        if (!$x) throw new EAException("Could not get lexeme from dictionary: lexeme is absent");
        $y = $x->fetch_assoc();
        if (!$y) throw new EAException("Could not get lexeme from dictionary: lexeme is absent");
        //var_dump($y);
        $el->stopword = $y["stopword"];
        $ev = new EmotionalVector();
        $ev->fillByArray($y);
        if (!is_null($ev->length())) $el->emotion = $ev;
        $this->dblink->next_result();
        return $el;
    }
    function getAllDrafts($lexeme, $lang): array {
        global $user;
        $ret = array();
        if (!is_null($user)) {
            $user->hasRole("editor");
            $x = $this->dblink->query("call getAllDrafts('" . $lexeme . "', '" . $lang . "')");
            if ($this->dblink->errno) throw new EAException("Could not get draft lexeme from dictionary: " . $this->dblink->errno . " - " . $this->dblink->error);
            if (!$x) throw new EAException("Could not get drafts lexeme from dictionary drafts: lexeme is absent");
            while ($y = $x->fetch_assoc()) {
                $el = new EmotionalLexeme(null, null, $y);
                $el->stopword = $y["stopword"];
                $ev = new EmotionalVector();
                $ev->fillByArray($y);
                if (!is_null($ev->length())) $el->emotion = $ev;
                $ret[(string)$y["user"]] = $el;
            };
            $this->dblink->next_result();
        }
        return $ret;
    }
    function getDraftLexeme($lexeme, $lang): ?EmotionalLexeme {
        global $user;
        if (!is_null($user)) {
            $user->hasRole("read");
            $el = new EmotionalLexeme($lexeme, $lang);
            $x = $this->dblink->query("call getDraftLexemeFromDictionary('". $user->name ."', '" . $el->normal . "', '" . $el->lang . "')");
            if ($this->dblink->errno) throw new EAException("Could not get draft lexeme from dictionary: " . $this->dblink->errno . " - " . $this->dblink->error);
            if (!$x) throw new EAException("Could not get draft lexeme from dictionary: lexeme is absent");
            $y = $x->fetch_assoc();
            if (!$y) throw new EAException("Could not get draft lexeme from dictionary: lexeme is absent");
            //var_dump($y);
            $el->stopword = $y["stopword"];
            $ev = new EmotionalVector();
            $ev->fillByArray($y);
            if (!is_null($ev->length())) $el->emotion = $ev;
            $this->dblink->next_result();
            return $el;
        } else {
            return null;
        }
    }
    function __get($name) {
        global $user;
        if (!is_null($user)) $user->hasRole("read");
        switch($name) {
            case 'lexemes':
                return $this->eLexemes;
            break;
            case 'statistics':
                $x = $this->dblink->query("call getStatistics()");
                if ($this->dblink->errno) throw new EAException("Could not get statistics: " . $this->dblink->errno . " - " . $this->dblink->error);
                if (!$x) throw new EAException("Could not get statistics");
                $a = $x->fetch_assoc();
                if (!$a) throw new EAException("Could not get statistics");
                $this->dblink->next_result();
                $x = $this->dblink->use_result();
                $depth = array();
                while ($y = $x->fetch_assoc()) {
                    $depth[] = $y;
                }
                $this->dblink->next_result();
                $x = $this->dblink->use_result();
                $users = array();
                while ($y = $x->fetch_assoc()) {
                    $users[] = $y;
                }
                return ["overal"=>$a, "depth"=>$depth, "users"=>$users];
            break;
            default:
                throw new Exception("Unknown property: '".$name."'");
        }
    }
}
class EmotionalText implements JsonSerializable {
    protected $text;
    public $sentences;
    public $emotion;
    public $lexemes;
    public $lang;
    function __construct(string $text, $lang) {
        global $morphy;
        $this->text = trim($text);
        $this->lang = $lang;
        $this->emotion = new EmotionalVector();
        $x = EmotionalText::parseText($text);
        
        if (sizeof($x) > 1) {
            $this->sentences = array();
            foreach ( $x as $s) {
                if (trim($s)) {
                    $et = new EmotionalText($s, $lang);
                    $this->sentences[] = $et;
                    $this->emotion->add($et->emotion);
                }
            }
        } else {
            $this->lexemes = array();
            $words = EmotionalText::parseSentence($text);
            $prev_noun = "";
            $prev_adj = "";
            $prev_part = "";
            $prev_adv = "";
            foreach($words as $word) {
                $word = trim(mb_strtoupper($word));
                $part_of_speech = $morphy->getPartOfSpeech($word);
                if (!$word) continue;
                if (!$part_of_speech) continue;
                //var_dump($word);
                //var_dump($part_of_speech);
                //echo '+', $word, '+';
                if (in_array('СОЮЗ', $part_of_speech)
                || in_array('ПРЕДЛ', $part_of_speech)
                ) continue;
                if (in_array('ЧАСТ', $part_of_speech)) {
                    $prev_part = $word;
                    //echo $prev_part, "\n";   
                    continue;
                }
                if (in_array('С', $part_of_speech)) {
                    if ($prev_noun) {
                        $this->revealLexeme(new EmotionalLexeme($prev_noun, $lang));
                        //echo $prev_noun, "\n";   
                    }
                    $prev_noun = $morphy->castFormByGramInfo($word,'С',array('ЕД','ИМ'),TRUE)[0];
                    if ($prev_adj) {
                        $this->revealLexeme(new EmotionalLexeme($prev_adj." ".$prev_noun, $lang));
                        //echo $prev_adj, " ", $prev_noun, "\n";   
                        $prev_noun = "";
                        $prev_part = "";
                        $prev_adj = "";
                    }
                    continue;
                }
                if (in_array('П', $part_of_speech)) {
                    if ($prev_adj) {
                        if ($prev_noun) {
                            $this->revealLexeme(new EmotionalLexeme($prev_adj." ".$prev_noun, $lang));
                            //echo $prev_adj, " ", $prev_noun, "\n";   
                            $prev_noun = "";
                            $prev_part = "";
                            $prev_adj = "";
                        } else {
                            $this->revealLexeme(new EmotionalLexeme($prev_adj, $lang));
                            //echo $prev_adj, "\n";   
                        }
                    }
                    $prev_adj = $prev_part?$prev_part:"".$morphy->castFormByGramInfo($word,'П',array('ЕД','ИМ'),TRUE)[0];
                    continue;
                }
                if (in_array('КР_ПРИЛ', $part_of_speech)) {
                    if ($prev_adj) {
                        if ($prev_noun) {
                            $this->revealLexeme(new EmotionalLexeme($prev_adj." ".$prev_noun, $lang));
                            //echo $prev_adj, " ", $prev_noun, "\n";   
                            $prev_noun = "";
                            $prev_part = "";
                            $prev_adj = "";
                        } else {
                            $this->revealLexeme(new EmotionalLexeme($prev_adj, $lang));
                            //echo $prev_adj, "\n";   
                        }
                    }
                    $prev_adj = $prev_part?$prev_part:"".$morphy->castFormByGramInfo($word,'П',array('ЕД','ИМ'),TRUE)[0];
                    if ($prev_noun) {
                        $this->revealLexeme(new EmotionalLexeme($prev_adj." ".$prev_noun, $lang));
                        //echo $prev_adj, " ", $prev_noun, "\n";   
                        $prev_noun = "";
                        $prev_part = "";
                        $prev_adj = "";
                    }
                    continue;
                }
                if (in_array('ПРИЧАСТИЕ', $part_of_speech) ) {
                    if ($prev_adj) {
                        if ($prev_noun) {
                            $this->revealLexeme(new EmotionalLexeme($prev_adj." ".$prev_noun, $lang));
                            //echo $prev_adj, " ", $prev_noun, "\n";   
                            $prev_noun = "";
                            $prev_part = "";
                            $prev_adj = "";
                        } else {
                            $this->revealLexeme(new EmotionalLexeme($prev_adj, $lang));
                            //echo $prev_adj, "\n";   
                        }
                    }
                    $prev_adj = $prev_part?$prev_part:"".$morphy->castFormByGramInfo($word,'ПРИЧАСТИЕ',array('ЕД','ИМ'),TRUE)[0];
                    if ($prev_noun) {
                        $this->revealLexeme(new EmotionalLexeme($prev_adj." ".$prev_noun, $lang));
                        //echo $prev_adj, " ", $prev_noun, "\n";   
                        $prev_noun = "";
                        $prev_part = "";
                        $prev_adj = "";
                    }
                    continue;
                }
                if (in_array('Н', $part_of_speech)) {
                    $prev_adv = $morphy->castFormByGramInfo($word,'Н',array(),TRUE)[0];
                    $this->revealLexeme(new EmotionalLexeme($prev_part?$prev_part.' ':"".$prev_adv, $lang));
                    //echo $prev_part?$prev_part.' ':"", $prev_adv, "\n";   
                    $prev_part = "";
                    continue;
                }
                if (in_array('Г', $part_of_speech)) {
                    $prev_verb = $morphy->castFormByGramInfo($word,'ИНФИНИТИВ',array(),TRUE)[0];
                    $this->revealLexeme(new EmotionalLexeme($prev_part?$prev_part.' ':"".$prev_verb, $lang));
                    //echo $prev_part?$prev_part.' ':"", $prev_verb, "\n";   
                    $prev_part = "";
                    continue;
                }
            }
        }
    }
    static function parseSentence($sentence) {
        return preg_split('/[,.\(\)\-\—:;"_»«\p{Zs}]+/imu', $sentence);
//        return preg_split('/[,.\-:;"_\s]{1,}/i', $sentence);
    }
    static function parseText($text){
        return preg_split('/[.|!|?]\s/i', $text);
    }
    protected function revealLexeme(EmotionalLexeme $el){
        global $eDict;
        if ($eDict) $eel = $eDict->add($el);
        $this->lexemes[] = $eel;
        if (!is_null($eel) && !is_null($eel->emotion) && !is_null($eel->stopword) && !$eel->stopword) $this->emotion->add($eel->emotion);

    }
    public function jsonSerialize() {
        return [
            "text" => $this->text,
            "emotion" => $this->emotion,
            "sentences" => $this->sentences,
            "lexemes" => $this->lexemes
        ];
    }
}
class EmotionalLexeme implements JsonSerializable {
    protected $src;
    protected $normal;
    protected $lang;
    protected $lexeme_id;
    public $emotion;
    public $stopword;
    function __construct(?string $_src=null, ?string $lang=null, $arr=null) {
        if (!is_null($arr) && is_array($arr)) {
            $this->lexeme_id = $arr["id"];
            $this->src = $arr["lexeme"];
            //var_dump($this->src);
            $this->lang = $arr["lang"];
            $this->stopword = $arr["stopword"];
            $ev = new EmotionalVector();
            $ev->fillByArray($arr);
            //var_dump($ev);
            if (is_null($ev->length())) {
                $this->emotion = null;
            } else {
                $this->emotion = $ev;
            }
        } else {
            $this->src = trim($_src);
            $this->lang = $lang;
            $this->emotion = null;
        }
        $this->normalize();
        $this->calcEmotionIndex();
    }
    protected function normalize() {
        $this->normal = $this->src;
    }

    protected function calcEmotionIndex() {
        
    }
    public function jsonSerialize() {
        return [
            'id' => $this->lexeme_id,
            'lexeme' => $this->normal,
            'lang' => $this->lang,
            'stopword' => $this->stopword,
            'emotion' => $this->emotion
        ];
    }
    
    function __get($name) {
        switch ($name) {
            case 'normal':
                return $this->normal;
                break;
            
            case 'id':
                return $this->lexeme_id;
                break;

            case 'index':
                return md5($this->normal, true);
                break;

            case 'lang':
                return $this->lang;
                break;
            default:
                # code...
                break;
        }
    }

}
class EmotionalColors {
    protected $basecolors = array(
        'joy' => 0xedc500, 
        'trust' => 0x7abd0d,
        'fear' => 0x007b33,
        'surprise' => 0x0080ab,
        'sadness' => 0x1f6dad,
        'disgust' => 0x7b4ea3,
        'anger' => 0xdc0047,
        'anticipation' => 0xe87200
    );
}
class EmotionalVector  implements JsonSerializable {
    protected $coords = array(
        'joy' => 0.0,
        'trust' => 0.0,
        'fear' => 0.0,
        'surprise' => 0.0,
        'sadness' => 0.0,
        'disgust' => 0.0,
        'anger' => 0.0,
        'anticipation' => 0.0
    );
    function __construct(?EmotionalVector $v = null, ?float $joy=null, ?float $trust=null,
        ?float $fear=null, ?float $surprise=null, ?float $sadness=null, 
        ?float $disgust=null, ?float $anger=null, ?float $anticipation=null 
    ) {
        if (!is_null($v)) {
            foreach ($this->coords as $key => $value) {
                $this->coords[$key] = $v->$key;
            }
            return;
        }
        foreach ($this->coords as $k=>$c){
            $this->coords[$k] = $$k;
        }
    }
    function __debugInfo() {
        return array(
            'coords' => $this->coords,
            'length' => $this->length()
        );
    }
    public function jsonSerialize() {
        return $this->coords;
    }
    function __get($name) {
        if (array_key_exists($name, $this->coords)) {
            return $this->coords[$name];
        }
    }
    function __set($name, $value) {
        if (array_key_exists($name, $this->coords)) {
            if (!is_numeric($value)) throw new EAException('Couldn\'t set value, because it\'s not numeric');
            $this->coords[$name] = $value;
        } else {
            throw new EAException('Couldn\'t set value, because it\'s unknown axis');
        }
    }
    public function add(EmotionalVector $b) {
        foreach ($this->coords as $key => $value) {
            $this->$key += $b->$key;
        }
    }
    public function scalarMult(float $k) {
        foreach ($this->coords as $key => $value) {
            $this->$key *= $k;
        }
    }
    public function mult(EmotionalVector $b) {
    }
    public function length() {
        $ret = 0.0;
        $all_is_null = true;
        foreach ($this->coords as $key => $value) {
            $all_is_null = $all_is_null && is_null($value);
            $ret += pow($this->$key, 2);
        }
        return ($all_is_null? null : sqrt($ret));
    }

    public function normalize() {
        $l = $this->length();
        foreach ($this->coords as $key => $value) {
            $this->$key /= $l;
        }
    }
    public function fillByArray($arr) {
        //var_dump($arr);
        foreach ($this->coords as $k=>$c){
            $this->coords[$k] = floatval($arr[$k]);
        }
    }
}
?>