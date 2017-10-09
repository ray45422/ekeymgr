<?php
if(!function_exists('unauthorized')){
	function unauthorized(){
		header("WWW-Authenticate: Basic realm=\"ekeymgr login\"");
		header("HTTP/1.0 401 Unauthorized");
		echo "ログインしてください";
		exit();
	}
}
if(!isset($_SERVER['PHP_AUTH_USER'])){
	unauthorized();
} else {
	include_once('db_login.php');
	$mysqli = db_connect();
	$user_id = $_SERVER['PHP_AUTH_USER'];
	$query = "SELECT id FROM authdata,services WHERE services.service_name=\"Web\" AND services.service_id=authdata.service_id AND authdata.user_id=\"$user_id\"";
	$result = $mysqli->query($query);
	$row = $result->fetch_assoc();
	if(!password_verify($_SERVER['PHP_AUTH_PW'], $row['id'])){
		unauthorized();
	}
}
?>
