<?php
include('db_login.php');

$mysqli = new mysqli($db_host, $db_username, $db_password, $db_database);
if($mysqli->connect_error){
	die("Could not connect to the database:<br />". $mysqli->connect_error);
}else{
	$mysqli->set_charset("utf8");
}
//$query = "SELECT * FROM logs";
$query = 'SELECT logs.log_id,logs.time,users.user_name,logs.is_lock,logs.room_id FROM logs,users,authdata WHERE authdata.auth_id = logs.auth_id AND authdata.user_id = users.user_id ORDER BY logs.log_id DESC LIMIT 20';
if($result = $mysqli->query($query)){
	include('table.php');
	$titles = ["#","日時","利用者","状態","部屋名"];
	$table = new Table($titles);
	while($row = $result->fetch_row()){
		if($row[3] == 0){
			$row[3] = "open";
		}else{
			$row[3] = "close";
		}
		$table->add($row);
	}
}
?>
