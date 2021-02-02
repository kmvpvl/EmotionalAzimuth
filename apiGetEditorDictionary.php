<?php
echo '{"result":';
try {
    require_once('classEA.php');
    $res = '"OK"';
    $res .= ', "data" : ';
    if ($eDict) {
        $u = $eDict->getLexemesTopN($_POST["first_letters"], $lang, $_POST["ignore"], $_POST["draft_count"]);
        $d = array();
        foreach ($u as $lex) {
            $d[$lex->id] = $eDict->getAllDrafts($lex->normal, $lex->lang);
        }
        $res .= json_encode(['lexemes' => $u, 'drafts' => $d]);
    }
} catch (EAException | phpMorphy_Exception | Exception $e) {
    $res = '"FAIL", "description" : "' . $e->getMessage() . '"';  
}
echo $res . '}';
?>