<?php
require_once('classEA.php');
if (!isset($_POST["lexeme"])) http_response_code(400);
$dict = new EmotionalDictionary();
$lexeme = $_POST["lexeme"];
if (!array_key_exists($lexemeIndex, $dict))
?>
<>