<?php
class EAException extends Exception {

}
class EmotionalDictionary {
    protected $dblink;
    function __construct() {
		$settings = parse_ini_file("settings.ini", true);
        $host = "";
        $database = "";
        $user = "";
        $password = "";
		
		if (array_key_exists("database", $settings)) {
			if (array_key_exists("host", $settings["database"])) $host = $settings["database"]["host"];
			if (array_key_exists("database", $settings["database"])) $database = $settings["database"]["database"];
			if (array_key_exists("user", $settings["database"])) $user = $settings["database"]["user"];
			if (array_key_exists("password", $settings["database"])) $password = $settings["database"]["password"];
        } else throw new EAException ("database settings are absent"); 
        //var_dump($settings);
		
		$this->dblink = new mysqli($host, $user, $password, $database);
		if ($this->dblink->connect_errno) throw new EAException("Unable connect to database (`" . $host . "` - `" . $database . "`): " . $this->dblink->connect_errno . " - " . $this->dblink->connect_error);
		$this->dblink->set_charset("utf-8");
		$this->dblink->query("set names utf8");
		$this->dblink->query("SET @@session.time_zone='+00:00';");
    }
    function __destruct() {
		$this->dblink->close();
    }
    function getUnassignedLexemesTopN(int $N = 10) {
	    $x = $this->dblink->query("call getUnassignedDictionaryTopN(" . $N . ")");
        if ($this->dblink->errno) throw new EAException("Could not get lexemes from dictionary: " . $this->dblink->errno . " - " . $this->dblink->error);
        if (!$x) throw new EAException("Could not get lexemes from dictionary: lexemes are absent");
        $z = array();
        while ($y = $x->fetch_assoc()) {
            //var_dump($y);
            $z[] = new EmotionalLexeme(null, null, $y);
        };
        $this->dblink->next_result();
        return $z;
    }
    function add(EmotionalLexeme $eL, ?EmotionalVector $v=null) {
	    $this->dblink->query("select addLexemeToDictionary('" . $eL->normal . "', '" . $eL->lang . "')");
	    if ($this->dblink->errno) throw new EAException("Could not create lexeme in dictionary: " . $this->dblink->errno . " - " . $this->dblink->error);
#        if (!is_null($v)) $eL->emotion = new EmotionalVector($v);
#        if (!array_key_exists($eL->index, $this->eLexemes) || is_null($this->eLexemes[$eL->index]->emotion)) {
#            $this->eLexemes[$eL->index] = $eL;
#        } else {
#            var_dump($this->eLexemes[$eL->index]);
#            throw new EAException('Lexeme already exists with not null EmotionalVector. Use update method to update emotion');
#        }
    }
    function getLexeme($lexeme, $lang): ?EmotionalLexeme {
        $el = new EmotionalLexeme($lexeme, $lang);
	    $x = $this->dblink->query("call getLexemeFromDictionary('" . $el->normal . "', '" . $el->lang . "')");
        if ($this->dblink->errno) throw new EAException("Could not get lexeme from dictionary: " . $this->dblink->errno . " - " . $this->dblink->error);
        if (!$x) throw new EAException("Could not get lexeme from dictionary: lexeme is absent");
        $y = $x->fetch_assoc();
        if (!$y) throw new EAException("Could not get lexeme from dictionary: lexeme is absent");
        //var_dump($y);
        $el->ignore = $y["stopword"];
        $ev = new EmotionalVector();
        $ev->fillByArray($y);
        if (!is_null($ev->length())) $el->emotion = $ev;
        $this->dblink->next_result();
        return $el;
    }
    function __get($name) {
        switch($name) {
            case 'lexemes':
                return $this->eLexemes;
            break;
            default:
                throw new Exception("Unknown property: '".$name."'");
        }
    }
}
class EmotionalText {
    protected $text;
    protected $eLexemes;
    function __construct(string $text) {
        $this->text = $text;
        $this->eLexemes = array();
    }
    static function parseSentence($sentence) {
        return preg_split('/[,.\(\)\-\—:;"_»«\p{Zs}]+/imu', $sentence);
//        return preg_split('/[,.\-:;"_\s]{1,}/i', $sentence);
    }
    static function parseText($text){
        return preg_split('/[.|!|?]\s/i', $text);
    }

}
class EmotionalLexeme implements JsonSerializable {
    protected $src;
    protected $normal;
    protected $lang;
    protected $lexeme_id;
    public $emotion;
    public $ignore;
    function __construct(?string $_src=null, ?string $lang=null, $arr=null) {
        if (!is_null($arr) && is_array($arr)) {
            $this->lexeme_id = $arr["id"];
            $this->src = $arr["lexeme"];
            $this->lang = $arr["lang"];
            $this->ignore = $arr["stopword"];
            $ev = new EmotionalVector();
            $ev->fillByArray($arr);
            //var_dump($ev);
            if (is_null($ev->length())) {
                $this->emotion = null;
            } else {
                $this->emotion = $ev;
            }
        } else {
            $this->src = $_src;
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
            'ignore' => $this->ignore,
            'emotion' => $this->emotion
        ];
    }
    
    function __get($name) {
        switch ($name) {
            case 'normal':
                return $this->normal;
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
            $this->coords[$k] = $arr[$k];
        }
    }
}
?>