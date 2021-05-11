<?php
require_once("classEA.php");
function prepareJsonResponseData($callback, $object){
    $ret = [];
    try {
        $ret["data"] = $callback($object);
        $ret["result"] = "OK";
    } catch (\Exception $e) {
        $ret["result"] = "FAIL";
        $ret["description"] = $e->getMessage();
    }
    return json_encode($ret, JSON_HEX_APOS | JSON_HEX_QUOT);
}

try {
	$ea = new EAUser($_POST['username'], $_POST['password']);
} catch (Exception | EAException $e) {
	http_response_code(401);
	die ($e->getMessage());
}
?>