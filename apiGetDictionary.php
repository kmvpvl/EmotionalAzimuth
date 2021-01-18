<?php
require_once('classEA.php');
$dict = new EmotionalDictionary();
echo '{"result":';
$res = '"OK"';
try {
    $res .= ', "data" : ';
    $u = $dict->getUnassignedLexemesTopN();
    $res .= json_encode($u);
} catch (Exception $e) {
    $res = '"FAIL", "description" : "' . $e->getMessage() . '"';  
}
echo $res . '}';
?>