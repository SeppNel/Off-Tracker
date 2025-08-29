<?php
define("ERROR_MSG", "Error");
require_once("../lib/json_decode.php");
require_once("../lib/json_encode.php");

$USERS_PATH = "/home/steam/web_secrets/off/users/";
$TRADES_PATH = "../../bd/off/trades/";

function validateFriendCode($fc){
	if (!preg_match('/^[0-9]+$/', $fc)) {
        exit(ERROR_MSG);
    }
}

function validateArrayOfNumbers($arr) {
    // Must be an array
    if (!is_array($arr)) {
        exit(ERROR_MSG);
    }

    foreach ($arr as $val) {
        // Must be an integer (no strings, no floats)
        if (!is_int($val)) {
            exit(ERROR_MSG);
        }
    }
}

$json = file_get_contents('php://input');
$data = json_decode($json);

$fc = $data->friend_code;
validateFriendCode($fc);
$secret = $data->secret;

$userFile = @file_get_contents($USERS_PATH . $fc . '.json');
if ($json === false){
	exit(ERROR_MSG);
}
$userData = json_decode($userFile);

if ($secret != $userData->secret){
    exit(ERROR_MSG);
}

$wants = $data->wants;
validateArrayOfNumbers($wants);
$has = $data->has;
validateArrayOfNumbers($has);

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