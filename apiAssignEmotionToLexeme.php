<?php
require_once('classEA.php');
if (!isset($_POST["lexeme"]) || !isset($_POST["lang"]) || !isset($_POST["emotion"])) http_response_code(400);
//var_dump($_POST);
$arr = [];
$arr += $_POST + $_POST["emotion"];
unset($arr["emotion"]);
//var_dump($arr);
$el = new EmotionalLexeme(null, null, $arr);
//var_dump($el);
$dict = new EmotionalDictionary();
$dict->add($el);
?>
