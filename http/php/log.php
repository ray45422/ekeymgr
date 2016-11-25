<?php
include('db_login.php');

$mysqli = db_connect();
//$query = "SELECT * FROM logs";
$query = 'SELECT logs.log_id,logs.time,users.user_name,logs.is_lock,rooms.room_name,users.user_id FROM logs,users,authdata,rooms WHERE authdata.auth_id = logs.auth_id AND authdata.user_id = users.user_id AND logs.room_id=rooms.room_id ORDER BY logs.log_id DESC LIMIT 20';
if($result = $mysqli->query($query)){
	include('utils.php');
	$titles = ["#","日時","利用者","状態","部屋名"];
	$table = new Table($titles);
	while($row = $result->fetch_array()){
		//$row[2] = makelink($row[2], "users.html", "userid=".$row["user_id"]);
		$row[2] = makelink($row[2], "users.html", "userid=".$row["user_id"]);
		if($row[3] == 0){
			$row[3] = "open";
		}else{
			$row[3] = "close";
		}
		$table->add($row);
	}
}
?>
