<?php
if(basename($_SERVER['PHP_SELF']) !== 'keys.php'){
	die();
}
include('php/login.php');
$title = "認証情報管理";
include('resources/head.php');
include_once('php/db_login.php');
include_once('php/utils.php');
if(isset($_GET["authid"])){
	$auth_id = htmlentities($_GET["authid"]);
	if(isset($_GET["valid"])){
		$status = htmlentities($_GET["valid"]);
		set_key_valid($auth_id, $status);
	}else{
		key_detail($auth_id);
	}
}else{
	key_table();
}
function key_detail($auth_id){
	$mysqli = db_connect();
	$query = 'SELECT auth_id,user_id,service_name,valid_flag FROM authdata,services WHERE services.service_id=authdata.service_id AND authdata.auth_id='.$auth_id;
	if($result = $mysqli->query($query)){
		$titles = ["#","所有者","認証方法","状態"];
		$container = new Container();
		$table = new Table($titles);
		$row = $result->fetch_array();
		$row[1] = makelink($row[1], "users.html", "userid=".$row[1]);
		if($row[3] == 0){
			$row[3] = "無効";
		}else{
			$row[3] = "有効";
		}
		$row[3] = makelink($row[3], "keys.html", "authid=".$row["auth_id"], "valid=".(1-$row["valid_flag"]));
		$table->add($row);
		$table->close();
	}else{
		die();
	}
	$query = 'SELECT timestamp,auth_timestamp.timestamp_id FROM auth_timestamp LEFT JOIN validated_timestamp ON (auth_timestamp.timestamp_id=validated_timestamp.timestamp_id) WHERE auth_timestamp.auth_id='.$auth_id;
	if($result = $mysqli->query($query)){
		$row = $result->fetch_row();
		if(count($row) <> 0){
			$panel = new Panel();
			$panel->setHeader('<strong>有効期限</strong>');
			$list = new ListGroup();
			$link = makelink($row[0],"valtime.html","edit","timeid=".$row[1]);
			$list->add($link);
			$list->close();
			$panel->close();
		}
	}
	$query = 'SELECT days,start_time,end_time,auth_timestamp_scheduled.timestamp_scheduled_id FROM auth_timestamp_scheduled LEFT JOIN validated_timestamp_scheduled ON (auth_timestamp_scheduled.timestamp_scheduled_id=validated_timestamp_scheduled.timestamp_scheduled_id) WHERE auth_timestamp_scheduled.auth_id='.$auth_id;
	if($result = $mysqli->query($query)){
		if($result->num_rows <> 0){
			echo '<br>';
			$panel = new Panel();
			$panel->setHeader('<strong>有効期間</strong>');
			$titles = ["","日","月","火","水","木","金","土","開始時間","終了時間"];
			$table = new Table($titles);
			while($row = $result->fetch_row()){
				$list = array("");
				$list = array_pad($list,10,"");
				if(count($row) <> 0){
					$list[0] = makelink("編集","valtimesch.html","edit","timeschid=".$row[3]);
					for ($i=0; $i<strlen($row[0]); $i++) {
						$list[$row[0][$i]] = "x";
					}
					$list[8] = $row[1];
					$list[9] = $row[2];
				}
				$table->add($list);
			}
			$table->close();
			$panel->close();
		}
	}
	$container->close();
}
function key_table(){
	if(isset($_GET["page"])){
		$page = htmlentities($_GET["page"]);
	}else{
		$page = 1;
	}
	$keys_per_page = 30;
	$keys = 0;
	$pages = 1;
	$mysqli = db_connect();
	$query = 'SELECT COUNT(authdata.auth_id) FROM authdata';
	if($result = $mysqli->query($query)){
		$row = $result->fetch_row();
		$keys = $row[0];
		$pages = ceil($keys / $keys_per_page);
		if($pages < 1){
			$pages = 1;
		}
	}else{
		die();
	}
	if($page < 1 || $page > $pages){
		$page = 1;
	}
	$query = 'SELECT auth_id,user_id,service_name,valid_flag FROM authdata,services WHERE services.service_id=authdata.service_id AND authdata.auth_id LIMIT '.$keys_per_page.' OFFSET '.(($page-1) * $keys_per_page);
	if($result = $mysqli->query($query)){
		$titles = ["#","所有者","認証方法","状態"];
		$container = new Container();
		$pagination = new Pagination("keys.html",$page,$pages);
		$table = new Table($titles);
		while($row = $result->fetch_array()){
			$row[0] = makelink("#".$row[0], "keys.html", "authid=".$row[0]);
			$row[1] = makelink($row[1], "users.html", "userid=".$row[1]);
			if($row[3] == 0){
				$row[3] = "無効";
			}else{
				$row[3] = "有効";
			}
			$row[3] = makelink($row[3], "keys.html", "authid=".$row["auth_id"], "valid=".(1-$row["valid_flag"]));
			$table->add($row);
		}
		$table->close();
		$pagination = new Pagination("keys.html",$page,$pages);
		$container->close();
	}
}
function set_key_valid($auth_id, $status){
	if(!isset($address)){
		$address = "./keys.html";
	}
	$mysqli = db_connect();
	$middle = '';
	if($status === '0'){
		$middle = '\'0\'';
	}else if($status == '1'){
		$middle = '\'1\'';
	}else{
		die();
	}
	$query = 'UPDATE authdata SET valid_flag='.$middle.' WHERE authdata.auth_id='.$auth_id;
	if($mysqli->query($query)){
		header('Location:'.$_SERVER['HTTP_REFERER']);
	}
}
include('resources/foot.php');
?>
