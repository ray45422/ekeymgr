<?php
include('db_login.php');

$mysqli = new mysqli($db_host, $db_username, $db_password, $db_database);
if($mysqli->connect_error){
	die("Could not connect to the database:<br />". $mysqli->connect_error);
}else{
	$mysqli->set_charset("utf8");
}
$query = "SELECT * FROM logs";
if($result = $mysqli->query($query)){
	while($row = $result->fetch_assoc()){
		echo "id:".$row["log_id"]." time:".$row["time"]." authId:".$row["auth_id"]."</br>";
	}
}
include('table.php');
$titles = ["#","日時","利用者","状態"];
$table = new Table($titles);
?>
