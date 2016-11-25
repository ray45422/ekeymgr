<?php
include('db_login.php');

$mysqli = db_connect();
$query = 'SELECT auth_id,user_id,service_name,id,valid_flag FROM authdata,services WHERE services.service_id=authdata.service_id';
if($result = $mysqli->query($query)){
	include('utils.php');
	$titles = ["#","所有者","認証方法","id","状態"];
	$table = new Table($titles);
	while($row = $result->fetch_row()){
		//$row[1] = '<a href="users.html?userid='.$row[1].'">'.$row[1].'</a>';
		$row[1] = makelink($row[1], "users.html", "userid=".$row[1]);
		if($row[4] == 0){
			$row[4] = "無効";
		}else{
			$row[4] = "有効";
		}
		$table->add($row);
	}
}
?>
