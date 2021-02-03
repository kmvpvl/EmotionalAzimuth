<?php
$users_xml = simplexml_load_file(dirname(__FILE__) . '/users.xml');
var_dump($users_xml);
if (!$users_xml) throw new EAException("Users.xml not found!");
$found = $users_xml->xpath("//user[@id='" . "te" . "']");
$u = null;
if (!$found) {
    $u = $users_xml->addChild("user");
    var_dump($users_xml);
    var_dump($u);
    $u->addAttribute("id", "te");
    $u->addAttribute("md5", "$");
    $u->addAttribute("roles", "read;save_draft");
    $users_xml->asXML(dirname(__FILE__) . '/users.xml');
} else {
    $u = $found[0];
}
//if ((string) $u["md5"] != $this->_hash) throw new EAException("Password incorrect! " . $this->_hash);
?>