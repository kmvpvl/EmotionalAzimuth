<?php
if (!isset($_POST["lexeme"])) http_response_code(400);
$arr = [];
$arr += $_POST["lexeme"] + $_POST["lexeme"]["emotion"];
unset($arr["emotion"]);
try {
    require_once('classEA.php');
    $el = new EmotionalLexeme(null, null, $arr);
    //var_dump($el);
    if ($eDict) {
        $eDict = new EmotionalDictionary();
        $eDict->addDraft($el);
    }
} catch (EAException | phpMorphy_Exception | Exception $e) {
	http_response_code(400);
    echo 'Caught exception: ',  $e->getMessage(), "\n";
}
?>
