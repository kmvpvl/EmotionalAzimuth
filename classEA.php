<?php
class JsonDateTime extends DateTime implements JsonSerializable {
    function __construct(DateTime $dt) {
		parent::__construct($dt->format("r"));
	}
    function jsonSerialize(){
        return $this->format(DateTime::RFC1036);
    }
}
abstract class EAAbstract implements JsonSerializable {
    protected $id = null;
    protected $data = null;
    protected $user = null;
    function __construct(?EAUser $user){
        $this->user = $user;
    }
    function arrayToObject(array $array) {
        foreach($array as $key=>$val) {
            if (property_exists($this, $key) && !$this->$key) $this->$key = $val;
        }
    }

    function toDataArray(array $arr) {
        foreach ($arr as $key => $value) {
            $d = DateTime::createFromFormat('Y-m-d H:i:s', $value, $this->user->timezone);
            if ($d !== false) {
                $arr[$key] = new JsonDateTime($d);
            }
        }
        $this->data = $arr;
        $this->id = $arr['id'];
    }

    function jsonSerialize(){
        if (!$this->data) return null;
        return $this->data;
    }
}
final class EAException extends Exception {

}
class EAAssessment extends EAAbstract implements JsonSerializable {
    function __construct(EAUser $user, ?int $id=null, ?array $arr=null){
        EAAbstract::__construct($user);
        $this->toDataArray($arr);
    }
    function save(){
        $sql = "call saveAssessment(".$this->assign_id.", ".$this->lexeme_id.
        ", ".$this->joy.
        ", ".$this->trust.
        ", ".$this->fear.
        ", ".$this->surprise.
        ", ".$this->sadness.
        ", ".$this->disgust.
        ", ".$this->anger.
        ", ".$this->anticipation.
        ")";
        $x = $this->user->dblink->query($sql);
        if ($this->user->dblink->errno || !$x) throw new EAException("Unexpected error while assign found: " . $this->user->dblink->errno . " - " . $this->user->dblink->error);
        $y = $x->fetch_assoc();
        if (!$y) throw new EAException("The assign not found!");
        $x->free_result();
        $this->user->dblink->next_result();
        $this->toDataArray($y);
    }
    function __get($name){
        if (key_exists($name, $this->data)) return $this->data[$name];
        return null;
    }
}
class EAAssign extends EAAbstract implements JsonSerializable {
    function __construct(EAUser $user, ?int $id=null, ?array $arr = null){
        EAAbstract::__construct($user);
        if ($id) {
            $sql = "call getAssignInfo(".$id.")";
            $x = $this->user->dblink->query($sql);
            if ($this->user->dblink->errno || !$x) throw new EAException("Unexpected error while assign found: " . $this->user->dblink->errno . " - " . $this->user->dblink->error);
            $y = $x->fetch_assoc();
            if (!$y) throw new EAException("The assign not found!");
            $x->free_result();
            $this->user->dblink->next_result();
            $this->toDataArray($y);
        } else {
            if (!$arr) throw new EAException('Could not create EAAssign \'cause neither \'id\' nor \'array\'');
            $this->toDataArray($arr);
        }
    }
    function doStartStop(bool $start){
        $sql = "call ".($start?"startAssign":"stopAssign")."(".$this->id.")";
        $x = $this->user->dblink->query($sql);
        if ($this->user->dblink->errno || !$x) throw new EAException("Unexpected error while assign found: " . $this->user->dblink->errno . " - " . $this->user->dblink->error);
        $y = $x->fetch_assoc();
        if (!$y) throw new EAException("The assign not found!");
        $x->free_result();
        $this->user->dblink->next_result();
        $this->toDataArray($y);
    }
    function getAllAssessments(){
        $sql = "call getAssessmentsByAssignID(".$this->id.")";
        $x = $this->user->dblink->query($sql);
        if ($this->user->dblink->errno || !$x) throw new EAException("Unexpected error while load assignment's assessments: " . $this->user->dblink->errno . " - " . $this->user->dblink->error);
        
        $this->data["assessments"] = [];
        while ($y = $x->fetch_assoc()) {
            $l = new EAAssessment($this->user, null, $y);
            $this->data["assessments"][$y["lexeme_id"]] = $l;
        }
        $x->free_result();
        $this->user->dblink->next_result();
    }
}
class EASet extends EAAbstract implements JsonSerializable {
    /**
     * 
     */
    function __construct(EAUser $user, ?int $id=null){
        EAAbstract::__construct($user);
        if ($id){
            $sql = "call getSetInfo(".$id.")";
            $x = $this->user->dblink->query($sql);
            if ($this->user->dblink->errno || !$x) throw new EAException("Unexpected error while set found: " . $this->user->dblink->errno . " - " . $this->user->dblink->error);
            $y = $x->fetch_assoc();
            if (!$y) throw new EAException("The set not found!");
            $x->free_result();
            $this->user->dblink->next_result();
            $this->toDataArray($y);

            $sql = "call getLexemesBySetId(".$this->id.")";
            $x = $this->user->dblink->query($sql);
            if ($this->user->dblink->errno || !$x) throw new EAException("Unexpected error while load set's lexemes: " . $this->user->dblink->errno . " - " . $this->user->dblink->error);
            
            $this->data["lexemes"] = [];
            while ($y = $x->fetch_assoc()) {
                $l = new EALexeme($this->user, null, $y);
                $this->data["lexemes"][$y["id"]] = $l;
            }
            $x->free_result();
            $this->user->dblink->next_result();

        } else {
            //new set
        }
    }
}
class EALexeme extends EAAbstract implements JsonSerializable {
    function __construct(EAUser $user, ?int $id=null, ?array $arr=null){
        $this->user = $user;
        EAAbstract::__construct($user);
        if ($id) {
            //load from db
        } else {
            if ($arr) {
                //already loaded from db
                $this->toDataArray($arr);
            } else {
                //new Lexeme
            }
        }
    }
}
class EAUser extends EAAbstract implements JsonSerializable {
    protected $_hash;
    protected $username;
    protected $dblink;
    protected $timezone;
    function __construct(string $username, string $password) {
        $this->timezone = new DateTimeZone('+0400');
        EAAbstract::__construct($this);
        $this->username = $username;
        $this->_hash = md5($username . $password);
		// finding and parsing  settings.ini for database settings & folders settings
		$settings = parse_ini_file("settings.ini", true);
		if (!$settings) new EAException("Settings INI-file not found!");
        // connecting to database
        $host = "localhost";
        $database = "ea";
        $dbuser = "";
        $dbpassword = "";
		$port = "3306";
		
		if (array_key_exists("database", $settings)) {
			if (array_key_exists("host", $settings["database"])) $host = $settings["database"]["host"];
			if (array_key_exists("database", $settings["database"])) $database = $settings["database"]["database"];
			if (array_key_exists("user", $settings["database"])) $dbuser = $settings["database"]["user"];
			if (array_key_exists("password", $settings["database"])) $dbpassword = $settings["database"]["password"];
			if (array_key_exists("port", $settings["database"])) $port = $settings["database"]["port"];
		} else throw new EAException ("database settings are absent"); 
		
		$this->dblink = new mysqli($host, $dbuser, $dbpassword, $database, $port);
		if ($this->dblink->connect_errno) throw new EAException("Unable connect to database (" . $host . " - " . $database . " - ".$port."): " . $this->dblink->connect_errno . " - " . $this->dblink->connect_error);
		$this->dblink->set_charset("utf-8");
		$this->dblink->query("set names utf8");
		if (!is_null($this->timezone)) $this->dblink->query("SET @@session.time_zone='" . $this->timezone->getName() . "';");
        $sql = "call getUserByName('".$username."')";
        $x = $this->dblink->query($sql);
	    if ($this->dblink->errno || !$x) throw new EAException("Unexpected error while user found: " . $this->dblink->errno . " - " . $this->dblink->error);
		$y = $x->fetch_assoc();
        if (!$y) throw new EAException("User not found!");
		$x->free_result();
		$this->dblink->next_result();
        $this->toDataArray($y);
    }
    function authorize():void {
        if ((string) $this->data["hash"] != $this->_hash) throw new EAException("Password incorrect! " . $this->_hash);
    }
    function hasRole(string $rolename):bool {
        if (!$this->data) $this->authorize();
        $roles = (string) $this->data["roles"];
        $roles_arr = explode(";", $roles);
        if (!in_array($rolename, $roles_arr)) throw new EAException("User ".$this->username." has no ".$rolename." role!");
        return true;
    }
    function getAssigns(): array{
        $ret = [];
        if (!$this->data) $this->authorize();
        $sql = "call getAssignsOnUser(".$this->id.")";
        $x = $this->dblink->query($sql);
	    if ($this->dblink->errno || !$x) throw new EAException("Unexpected error while get user's assigns: " . $this->dblink->errno . " - " . $this->dblink->error);
		while ($y = $x->fetch_assoc()) {
            $ret[$y['id']] = new EAAssign($this, null, $y);
        }
		$x->free_result();
		$this->dblink->next_result();
        return $ret;
    }
    function __get(string $name) {
        switch ($name) {
            case 'name':
                return $this->username;
            default:
                return $this->$name;
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