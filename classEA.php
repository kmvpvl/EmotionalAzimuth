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
        var_dump($settings);
		
		$this->dblink = new mysqli($host, $user, $password, $database);
		if ($this->dblink->connect_errno) throw new EAException("Unable connect to database (`" . $host . "` - `" . $database . "`): " . $this->dblink->connect_errno . " - " . $this->dblink->connect_error);
		$this->dblink->set_charset("utf-8");
		$this->dblink->query("set names utf8");
		$this->dblink->query("SET @@session.time_zone='+00:00';");
    }
    function __destruct() {
		$this->dblink->close();
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
    function getLexeme($lexeme, $lang) {
        $el = new EmotionalLexeme($lexeme, $lang);
        if (!array_key_exists($el->index, $this->eLexemes)) return false;
        return $this->eLexemes[$el->index];
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
    function __construct($text) {
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
class EmotionalLexeme {
    protected $src;
    protected $normal;
    protected $lang;
    public $emotion;
    public $ignore = false;
    function __construct($_src, $lang) {
        $this->src = $_src;
        $this->lang = $lang;
        unset($emotion);
        $this->normalize();
        $this->calcEmotionIndex();
    }
    protected function normalize() {
        $this->normal = $this->src;
    }

    protected function calcEmotionIndex() {
        
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
class EmotionalVector {
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
            'len' => $this->length()
        );
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
        foreach ($this->coords as $key => $value) {
            $ret += pow($this->$key, 2);
        }
        return sqrt($ret);
    }

    public function normalize() {
        $l = $this->length();
        foreach ($this->coords as $key => $value) {
            $this->$key /= $l;
        }
    }
}
?>