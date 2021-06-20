<?php
error_reporting(E_ERROR | E_STRICT);
if (!isset($_POST["username"]) || !isset($_POST["password"])) {
    http_response_code(401);
    die ("Unathorized request!");
}

require_once("classEA.php");
function prepareJsonResponseData($callback, $object){
    header('Content-Type: application/json');
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
	$eaUser = new EAUser($_POST['username'], $_POST['password']);
    $eaUser->authorize();
} catch (Exception | EAException $e) {
	http_response_code(401);
	die ($e->getMessage());
}
?>