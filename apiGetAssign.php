<?php
require_once("prepareResponse.php");
echo prepareJsonResponseData(function($u){
    $a = new EAAssign($u, $_POST['data']['id']);
    return $a;
}, $eaUser);
?>