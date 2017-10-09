<?php
if(basename($_SERVER['PHP_SELF']) !== 'logs.php'){
	die();
}
include('php/db_login.php');
$title = "入退室ログ";
include('resources/head.php');
include('php/utils.php');
if(isset($_GET["page"])){
	$page = htmlentities($_GET["page"]);
}else{
	$page = 1;
}
log_table($page);
function log_table($page){
	$logs_per_page = 30;
	$logs = 0;
	$pages = 1;
	$mysqli = db_connect();
	$query = 'SELECT COUNT(logs.log_id) FROM logs';
	if($result = $mysqli->query($query)){
		$row = $result->fetch_row();
		$logs = $row[0];
		$pages = ceil($logs / $logs_per_page);
		if($pages < 1){
			$pages = 1;
		}
	}else{
		die();
	}
	if($page < 1 || $page > $pages){
		$page = 1;
	}
	//$query = "SELECT * FROM logs";
	$query = 'SELECT logs.log_id,logs.time,users.user_name,logs.auth_id,logs.is_lock,rooms.room_name,users.user_id FROM logs,users,authdata,rooms WHERE authdata.auth_id = logs.auth_id AND authdata.user_id = users.user_id AND logs.room_id=rooms.room_id ORDER BY logs.log_id DESC LIMIT '.$logs_per_page.' OFFSET '.(($page-1) * $logs_per_page);
	if($result = $mysqli->query($query)){
		$container = new Container();
		$pagination = new Pagination("logs.html",$page,$pages);
		$titles = ["#","日時","利用者","認証ID","状態","部屋名"];
		$table = new Table($titles);
		while($row = $result->fetch_array()){
			//$row[2] = makelink($row[2], "users.html", "userid=".$row["user_id"]);
			$row[2] = makelink($row[2], "users.html", "userid=".$row["user_id"]);
			$row[3] = makelink("#".$row[3], "keys.html", "authid=".$row[3]);
			if($row[4] == 0){
				$row[4] = "open";
			}else{
				$row[4] = "close";
			}
			$table->add($row);
		}
		$table->close();
		$pagination = new Pagination("logs.html",$page,$pages);
		$container->close();
	}
}
include('resources/foot.php');
?>
