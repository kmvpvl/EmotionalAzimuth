<?php
require_once('classEA.php');
$lex = $_POST["lexeme"];
$lang = $_POST["lang"];
$dict = new EmotionalDictionary();
echo '{"result":';
$res = '"OK"';
try {
    $res .= ', "data" : ';
    $u = $dict->getLexeme($lex, $lang);
    $res .= json_encode($u);
} catch (Exception $e) {
    $res = '"FAIL", "description" : "' . $e->getMessage() . '"';  
}
echo $res . '}';
?>