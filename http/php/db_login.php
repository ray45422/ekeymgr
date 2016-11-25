<?php
function db_connect(){
	$db_host='localhost';
	$db_database='ekeymgr';
	$db_username='ekeymgr';
	$db_password='ekeymgr';
	$mysqli = new mysqli($db_host, $db_username, $db_password, $db_database);
	if($mysqli->connect_error){
		die("Could not connect to the database:<br />". $mysqli->connect_error);
	}else{
		$mysqli->set_charset("utf8");
	}
	return $mysqli;
}
?>
