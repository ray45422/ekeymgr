<?php
include('db_login.php');

$connection = mysqli_connect($db_host, $db_username, $db_password);
if(!$connection){
	die("Could not connect to the database:<br />". mysqli_connect_error());
}
$db_select = mysqli_select_db($connection, $db_database);
if(!$db_select){
	die("Could not select the database:<br />". mysqli_error($connection));
}
?>
