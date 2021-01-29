<?php
echo '{"result":';
try {
    require_once('classEA.php');
    $res = '"OK"';
    $lex = $_POST["lexeme"];
    $lang = $_POST["lang"];
    $res .= ', "data" : ';
    if ($eDict) $u = $eDict->getLexeme($lex, $lang);
    $res .= json_encode($u);
} catch (EAException | phpMorphy_Exception | Exception $e) {
    $res = '"FAIL", "description" : "' . $e->getMessage() . '"';  
}
echo $res . '}';
?>