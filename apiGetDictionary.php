<?php
require_once('classEA.php');
$dict = new EmotionalDictionary();
echo '{"result":';
$res = '"OK"';
try {
    $res .= ', "data" : ';
    //var_dump($dict->lexemes);
    $res .= json_encode($dict->lexemes, JSON_THROW_ON_ERROR);
} catch (Exception $e) {
    $res = '"FAIL", "description" : "' . $e->getMessage() . '"';  
}
echo $res . '}';
?>