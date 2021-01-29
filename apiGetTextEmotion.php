<?php
echo '{"result":';
try {
    require_once('classEA.php');
    $res = '"OK"';
    $res .= ', "data" : ';
    $t = $_POST["text"];
    $tx = new EmotionalText($t, $lang);
    $res .= json_encode($tx);
} catch (EAException | phpMorphy_Exception | Exception $e) {
    $res = '"FAIL", "description" : "' . $e->getMessage() . '"';  
}
echo $res . '}';
?>