<?php
echo '{"result":';
try {
    require_once('classEA.php');
    $res = '"OK"';
    $res .= ', "data" : ';
    if ($eDict) {
        $u = $eDict->getUnassignedDraftLexemesTopN($_POST["first_letters"], $_POST["toc"], $lang, $_POST["stopword"]);
        $toc = $eDict->getDraftTOC($lang, $_POST["stopword"]);
        $res .= json_encode(['lexemes' => $u, 'toc' => $toc]);
    }
} catch (EAException | phpMorphy_Exception | Exception $e) {
    $res = '"FAIL", "description" : "' . $e->getMessage() . '"';  
}
echo $res . '}';
?>