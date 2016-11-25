<?php
if(isset($_GET["userid"])){
	$user_id = htmlentities($_GET["userid"]);
	user_detail($user_id);
}else{
	user_table();
}
function user_detail($user_id){
	include('db_login.php');
	$mysqli = db_connect();
	$query = 'SELECT * FROM users WHERE users.user_id=\''.$user_id.'\'';
	if($result = $mysqli->query($query)){
		include('utils.php');
		$titles = ["id","名前","表示名"];
		$table = new Table($titles);
		while($row = $result->fetch_row()){
			$table->add($row);
		}
	}
}
function user_table(){
	include('db_login.php');
	$mysqli = db_connect();
	$query = 'SELECT * FROM users';
	if($result = $mysqli->query($query)){
		include('utils.php');
		$titles = ["id","名前","表示名"];
		$table = new Table($titles);
		while($row = $result->fetch_row()){
			$row[0] = makelink($row[0], "users.html", "userid=".$row[0]);
			$table->add($row);
		}
	}
}
?>
