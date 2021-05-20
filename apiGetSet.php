<?php
require_once("prepareResponse.php");
echo prepareJsonResponseData(function($u){
    $s = new EASet($u, $_POST['data']['id']);
    return $s;
}, $eaUser);
?>