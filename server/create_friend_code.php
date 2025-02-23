<?php
define("ERROR_MSG", "Error");
$BD_PATH = "../../bd/off/users/";

if (!isset($_GET["secret"])) {
	exit(ERROR_MSG);
}

$secret = $_GET["secret"];

$fi = new FilesystemIterator($BD_PATH, FilesystemIterator::SKIP_DOTS);
$fc = iterator_count($fi) + 1;

$path = $BD_PATH . $fc . ".json";
$content = '{"secret": "' . $secret . '"}';
file_put_contents($path, $content);

echo $fc;
?>