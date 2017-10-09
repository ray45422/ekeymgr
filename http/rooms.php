<?php
if(basename($_SERVER['PHP_SELF']) !== 'rooms.php'){
	die();
}
include('php/login.php');
$title = '部屋管理';
include('resources/head.php');
include_once('php/db_login.php');
include_once('php/utils');
if(isset($_GET["roomid"])){
	$room_id = htmlentities($_GET["auth_id"]);
	room_detail();
}else{
	room_table();
}
function room_table(){
	$mysqli = db_connect();
	$query = 'SELECT rooms.room_name,rooms.ip_address,rooms.room_id FROM rooms';
	if($result = $mysqli->query($query)){
		$titles = ["部屋名","状態"];
		$container = new Container();
		$table = new Table($titles);
		while($row = $result->fetch_array()){
			$ip_address = $row["ip_address"];
			socket_clear_error();
			if($ip_address === "NULL"){
				$row[1] = "Unavailable";
			}else if($socket = socket_create(AF_INET,SOCK_STREAM,SOL_TCP)){
				if(!socket_set_option($socket, SOL_SOCKET, SO_REUSEADDR, 1)){
					die();
				}
				$timeout = array("sec" => 2, "usec" => 0);
				if(!socket_set_option($socket, SOL_SOCKET, SO_RCVTIMEO, $timeout)){
					die();
				}
				if(!socket_set_option($socket, SOL_SOCKET, SO_SNDTIMEO, $timeout)){
					die();
				}
				if(!socket_connect($socket, $ip_address, 1756)){
					$row[1] = "Unavailable";
					$query = 'UPDATE rooms SET ip_address=NULL WHERE rooms.room_id='.$row["room_id"];
					$mysqli->query($query);
				}else{
					socket_send($socket, "status", 6, MSG_EOF);
					socket_recv($socket, $msg, 255, MSG_WAITALL);
					socket_close($socket);
					if(substr($msg, 0, 1) === "0"){
						$row[1] = substr($msg,9);
					}else{
						$row[1] = "Error";
					}
					$table->add($row);
				}
			}
		}
		$table->close();
		$container->close();
	}else{
		echo 'a';
	}
}
include('resources/foot.php');
?>
