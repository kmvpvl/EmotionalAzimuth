<?php
require_once("prepareResponse.php");
echo prepareJsonResponseData(function($u){
    $a = $u->getAssigns();
    return ['currentUser'=>$u,
        'assigns'=>$a
    ];
}, $eaUser);
?>