<?php
echo '{"result":';
try {
    require_once('classEA.php');
    $res = '"OK"';
    $res .= ', "data" : ';
    if ($eDict) {
        $u = $eDict->getUnassignedDraftLexemesTopN($_POST["first_letters"], $lang, $_POST["stopword"]);
        $toc = $eDict->getDraftTOC($_POST["first_letters"], $lang, $_POST["stopword"]);
        $res .= json_encode(['lexemes' => $u, 'toc' => $toc]);
    }
} catch (EAException | phpMorphy_Exception | Exception $e) {
    $res = '"FAIL", "description" : "' . $e->getMessage() . '"';  
}
echo $res . '}';
?>