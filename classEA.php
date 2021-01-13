<?php
class EAException extends Exception {

}
class EmotionalDictionary {
    protected $eLexemes;
    function __construct() {
        $myfile = fopen("dict.bin", "r") or die("Unable to open file!");
        $str = fread($myfile, filesize("dict.bin"));
        $this->eLexemes = unserialize($str);
        fclose($myfile);
        //$this->eLexemes = array();
    }
    function add(EmotionalLexeme $eL, ?EmotionalVector $v=null) {
        $this->eLexemes[$eL->index()] = $eL;
        if (!is_null($v)) $eL->emotion = new EmotionalVector($v);

    }
    function save() {
        $myfile = fopen("dict.bin", "w") or die("Unable to open file!");
        fwrite($myfile, serialize($this->eLexemes));
        fclose($myfile);
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
    public $emotion;
    function __construct($_src) {
        $this->src = $_src;
        unset($emotion);
        $this->normalize();
        $this->calcEmotionIndex();
    }
    protected function normalize() {

    }

    protected function calcEmotionIndex() {
        
    }
    public function index(){
        return md5($this->normal, true);
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