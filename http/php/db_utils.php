<?php
include_once('db_login.php');
function getHashedPassword($user_id){
	$mysqli = db_connect();
	$user_id = $_SERVER['PHP_AUTH_USER'];
	$query = "SELECT id FROM authdata,services WHERE services.service_name='Web' AND services.service_id=authdata.service_id AND authdata.user_id='$user_id'";
	$result = $mysqli->query($query);
	if($result === false || $result->num_rows != 1){
		return false;
	}
	$row = $result->fetch_assoc();
	return $row['id'];
}
function isValidatedPassword($user_id, $password){
	return password_verify($password, getHashedPassword($user_id));
}
function registarKey($user_id, $service_name, $password, $isEnable = true){
	$isEnable = $isEnable?'1':'0';
	$mysqli = db_connect();
	$query = "INSERT INTO authdata VALUES(NULL, '$user_id', (SELECT service_id FROM services WHERE services.service_name = '$service_name'), '$password', '$isEnable')";
	$result = $mysqli->query($query);
	return $result;
}
function registarFeliCa($user_id, $felica_id){
	$hashedID = hashGenerate($felica_id);
	return registarKey($user_id, 'FeliCa', $hashedID);
}
function updateWebPassword($user_id, $password){
	$mysqli = db_connect();
	$hashedPasswd = password_hash($password, PASSWORD_DEFAULT);
	$query = "INSERT INTO authdata VALUES((SELECT auth_id FROM (SELECT auth_id FROM authdata,services WHERE user_id='$user_id' AND services.service_name='Web' AND services.service_id=authdata.service_id) AS tmp) , '$user_id', (SELECT service_id FROM services WHERE services.service_name = 'Web'), '$hashedPasswd', '1') ON DUPLICATE KEY UPDATE id='$hashedPasswd'";
	return $mysqli->query($query);
}
function userExists($user_id){
	$mysqli = db_connect();
	$query = "SELECT user_id FROM users WHERE users.user_id='$user_id'";
	if($result = $mysqli->query($query)){
		if($result->num_rows === 1){
			return true;
		}
	}
	return false;
}
function userAdd($user_id, $user_name, $disp_name){
	if(userExists($user_id)){
		return false;
	}
	$mysqli = db_connect();
	$query = "INSERT INTO users VALUES (NULL, '$user_id', '$user_name', '$disp_name')";
	return $mysqli->query($query);
}
function userDelete($user_id){
	$mysqli = db_connect();
	$user_id = htmlentities($user_id);
	$user_id = htmlspecialchars($user_id);
	$query = "DELETE FROM users WHERE users.user_id='$user_id'";
	return $mysqli->query($query);
}
function getRooms($room_id = false){
	$mysqli = db_connect();
	$query = "SELECT * FROM rooms";
	$where = ' ';
	if(is_int($room_id)){
		$where .= "rooms.room_id = '$room_id'";
	}
	if($result = $mysqli->query($query . $where)){
		$array = array();
		while($row = $result->fetch_assoc()){
			$array[$row['room_id']] = $row['room_name'];
			$array['ip_address'][$row['room_id']] = $row['ip_address'];
		}
		return $array;
	}
	return false;
}
function getServices($service_id = false){
	$mysqli = db_connect();
	$query = "SELECT service_id,service_name FROM services";
	$where = ' ';
	if(is_int($service_id)){
		$where .= "services.service_id = '$service_id'";
	}
	if($result = $mysqli->query($query . $where)){
		$array = array();
		while($row = $result->fetch_assoc()){
			$array[$row['service_id']] = $row['service_name'];
		}
		return $array;
	}
	return false;
}
function allowRoomUser($room_id, $user_id, $isAllow){
	if(!is_bool($isAllow)){
		return false;
	}
	$mysqli = db_connect();
	$query = '';
	if($isAllow){
		$query = "INSERT INTO rooms_users (room_id, user_id) VALUES('$room_id', '$user_id')";
	}else{
		$query = "DELETE FROM rooms_users WHERE rooms_users.room_id = '$room_id' AND rooms_users.user_id = '$user_id'";
	}
	return $mysqli->query($query);
}
function sendMessageToClient($room_id, $message){
	$ip_address = getRooms($room_id)['ip_address'][$room_id];
	if($ip_address === false)return false;
	$socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
	if($socket === false)return false;
	if(!socket_set_option($socket, SOL_SOCKET, SO_REUSEADDR, 1))return false;
	$timeout = array("sec" => 2, "usec" => 0);
	if(!socket_set_option($socket, SOL_SOCKET, SO_RCVTIMEO, $timeout))return false;
	if(!socket_set_option($socket, SOL_SOCKET, SO_SNDTIMEO, $timeout))return false;
	if(!socket_connect($socket, $ip_address, 1756))return false;
	socket_send($socket, $message, strlen($message), MSG_EOF);
	socket_recv($socket, $msg, 255, MSG_WAITALL);
	socket_close($socket);
	return $msg;
}
?>
