<?php
error_reporting(E_ERROR | E_STRICT);
if (!isset($_POST["username"]) || !isset($_POST["password"])) {
    http_response_code(401);
    die ("Unathorized request!");
}
$user = null;
$user = new EAUser($_POST["username"], $_POST["password"]);
$user->authorize();

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
            $this->stopword = ("" == $arr["stopword"]?null:$arr["stopword"]);
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
        if (!$l) return;
        foreach ($this->coords as $key => $value) {
            $this->$key /= $l;
        }
    }
    public function normalize2() {
        $l = 0;
        foreach ($this->coords as $key => $value) {
            if ($this->$key > $l) $l = $this->$key;
        }
        if (!$l) return;
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