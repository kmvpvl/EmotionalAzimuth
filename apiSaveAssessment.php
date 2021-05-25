<?php
require_once("prepareResponse.php");
echo prepareJsonResponseData(function($u){
    $a = new EAAssessment($u, null, $_POST['data']);
    $a->save();
    return $a;
}, $eaUser);
?>