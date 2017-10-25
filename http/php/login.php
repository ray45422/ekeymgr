<?php
if(!function_exists('unauthorized')){
	function unauthorized(){
		header("WWW-Authenticate: Basic realm=\"ekeymgr login\"");
		header("HTTP/1.0 401 Unauthorized");
		$title = "";
		include('resources/head.php');
		include('php/utils.php');
		$container = new Container();
		echo "ログインしてください";
		#echo password_hash($_SERVER['PHP_AUTH_PW'], PASSWORD_DEFAULT);
		$container->close();
		include('resources/foot.php');
		exit();
	}
}
if(!isset($_SERVER['PHP_AUTH_USER']) && !isset($_SERVER['PHP_AUTH_PW'])){
	unauthorized();
} else {
	include_once('php/db_utils.php');
	$user = $_SERVER['PHP_AUTH_USER'];
	$passwd = $_SERVER['PHP_AUTH_PW'];
	if(!isValidatedPassword($user, $passwd)){
		unauthorized();
	}
}
?>
