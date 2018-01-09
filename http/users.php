<?php
if(basename($_SERVER['PHP_SELF']) !== 'users.php'){
	die();
}
include('php/login.php');
$title = 'ユーザー管理';
include('resources/head.php');
include_once('php/db_login.php');
include_once('php/utils.php');
if(isset($_GET["userid"])){
	if(isset($_GET["edit"])){
		echo $_GET["edit"];
	}
	$user_id = htmlentities($_GET["userid"]);
	user_detail($user_id);
}else{
	user_table();
}
function user_detail($user_id){
	$mysqli = db_connect();
	$query = 'SELECT * FROM users WHERE users.user_id=\''.$user_id.'\'';
	if($result = $mysqli->query($query)){
		?>
		<style>
		.buttons {
			margin-bottom: 20px;
			float: right;
		}
		</style>
		<div class="buttons">
			<?php
			if($user_id === $_SERVER['PHP_AUTH_USER']){?>
			<a href="./passwd.php?userid=<?php echo $user_id; ?>" class="btn btn-primary">パスワード変更</a>
			<?php } ?>
			<a href="./keyadd.php?userid=<?php echo $user_id; ?>" class="btn btn-primary">新規鍵登録</a>
			<a href="./userdel.php?userid=<?php echo $user_id;?>" class="btn btn-danger">ユーザー削除</a>
		</div>
		<?php
		$titles = ["id","名前","表示名"];
		$table = new Table($titles);
		while($row = $result->fetch_row()){
			$table->add($row);
		}
		$table->close();
	}else{
		die();
	}
	$query = 'SELECT auth_id,service_name,valid_flag FROM authdata,services WHERE services.service_id=authdata.service_id AND authdata.user_id=\''.$user_id.'\'';
	if($result = $mysqli->query($query)){
		$titles = ["#","認証方法","状態"];
		$table = new Table($titles);
		while($row = $result->fetch_array()){
			$row[0] = makelink("#".$row[0], "keys.php", "authid=".$row[0]);
			if($row[2] === '0'){
				$row[2] = "無効";
			}else if($row[2] === '1'){
				$row[2] = "有効";
			}
			$row[2] = makelink($row[2], "keys.php", "authid=".$row["auth_id"], "valid=".(1-$row["valid_flag"]));
			$table->add($row);
		}
		$table->close();
	}else{
		die();
	}
	$query = 'SELECT logs.time,logs.auth_id,logs.is_lock,rooms.room_name FROM logs,users,authdata,rooms WHERE  authdata.auth_id = logs.auth_id AND authdata.user_id = users.user_id AND logs.room_id=rooms.room_id AND users.user_id=\''.$user_id.'\' ORDER BY logs.log_id DESC LIMIT 5';
	if($result = $mysqli->query($query)){
		$titles = ["日時","認証ID","状態","部屋名"];
		$panel = new Panel();
		$panel->setHeader('<strong>直近の利用</strong>');
		$table = new Table($titles);
		while($row = $result->fetch_array()){
			$row[1] = makelink("#".$row[1], "keys.php", "authid=".$row[1]);
			if($row[2] == 0){
				$row[2] = "open";
			}else{
				$row[2] = "close";
			}
			$table->add($row);
		}
		$panel->close();
	}else{
		echo 'a';
	}
}
function user_table(){
	if(isset($_GET["page"])){
		$page = htmlentities($_GET["page"]);
	}else{
		$page = 1;
	}
	$users_per_page = 30;
	$users = 0;
	$pages = 1;
	$mysqli = db_connect();
	$query = 'SELECT COUNT(users.user_idn) FROM users';
	if($result = $mysqli->query($query)){
		$row = $result->fetch_row();
		$users = $row[0];
		$pages = ceil($users / $users_per_page);
		if($pages < 1){
			$pages = 1;
		}
	}else{
		die();
	}
	if($page < 1 || $page > $pages){
		$page = 1;
	}
	$query = 'SELECT user_id,user_name,disp_name FROM users WHERE users.user_idn LIMIT '.$users_per_page.' OFFSET '.(($page-1) * $users_per_page);
	if($result = $mysqli->query($query)){
		echo '<div align="right"><a class="btn btn-primary" href="./useradd.php">新規ユーザー登録</a></div>';
		$pagination = new Pagination("users.php",$page,$pages);
		$titles = ["id","名前","表示名"];
		$table = new Table($titles);
		while($row = $result->fetch_row()){
			$row[0] = makelink($row[0], "users.php", "userid=".$row[0]);
			$table->add($row);
		}
		$table->close();
	}
}
include('resources/foot.php');
?>
