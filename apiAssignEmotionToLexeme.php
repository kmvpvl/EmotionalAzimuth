<?php
require_once('classEA.php');
if (!isset($_POST["lexeme"])) http_response_code(400);
//var_dump($_POST);
$arr = [];
$arr += $_POST["lexeme"] + $_POST["lexeme"]["emotion"];
unset($arr["emotion"]);
try {
    //var_dump($arr);
    $el = new EmotionalLexeme(null, null, $arr);
    //var_dump($el);
    $dict = new EmotionalDictionary();
    $dict->add($el);
} catch (Exception | EAException $e) {
	http_response_code(400);
    echo 'Caught exception: ',  $e->getMessage(), "\n";
}
?>
