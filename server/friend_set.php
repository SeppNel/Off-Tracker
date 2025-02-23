<?php
define("ERROR_MSG", "Error");
require_once("../lib/json_decode.php");
require_once("../lib/json_encode.php");

$USERS_PATH = "../../bd/off/users/";
$TRADES_PATH = "../../bd/off/trades/";

function validateFriendCode($fc){
	$nonValidChars = ["&", "|", ";", ">", "$", "`", "(", "{", ".", "/"];

	//Prevent shell injection
	foreach ($nonValidChars as $c) {
		if(strpos($fc, $c) !== false){
			exit(ERROR_MSG);
		}
	}
}


$json = file_get_contents('php://input');
$data = json_decode($json);

$fc = $data->friend_code;
$secret = $data->secret;

$userFile = file_get_contents($USERS_PATH . $fc . '.json');
$userData = json_decode($userFile);

if ($secret != $userData->secret){
    exit(ERROR_MSG);
}

$wants = $data->wants;
$has = $data->has;

if($wants == []){
    exit();
}

$newData = [
	"friend_code" => $fc,
    "wants" => $wants,
    "has" => $has,
    "version" => 1
];

$path = $TRADES_PATH . $fc . ".json";
file_put_contents($path, json_encode($newData));

echo "OK";
?>