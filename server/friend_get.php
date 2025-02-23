<?php
define("ERROR_MSG", "Error");
$BD_PATH = "../../bd/off/trades/";

function validateFriendCode($fc){
	$nonValidChars = ["&", "|", ";", "\n", ">", "$", "`", "(", "{", ".", "/"];

	//Prevent shell injection
	foreach ($nonValidChars as $c) {
		if(strpos($fc, $c) !== false){
			exit(ERROR_MSG);
		}
	}
}

if (!isset($_GET["friend_code"])) {
	exit(ERROR_MSG);
}

$fc = $_GET["friend_code"];
validateFriendCode($fc);

$path = $BD_PATH . $fc . ".json";

if (!file_exists($path)) {
	exit(ERROR_MSG);
}

$json = file_get_contents($path);
echo $json;
?>