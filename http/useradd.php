<?php
if(basename($_SERVER['PHP_SELF']) !== 'useradd.php'){
	die();
}
$title = '新規ユーザー登録';
include('php/login.php');
include_once('php/db_utils.php');
include_once('php/db_login.php');
include_once('php/utils.php');
global $user_id, $user_name, $disp_name;
if($_SERVER['REQUEST_METHOD'] === 'POST'){
	function post(){
		global $user_id, $user_name, $disp_name;
		$user_id = '';
		$user_name = '';
		$disp_name = '';
		$result = '';
		if(isset($_POST['user_id'])){
			$user_id = $_POST['user_id'];
		}
		if(isset($_POST['user_name'])){
			$user_name = $_POST['user_name'];
		}
		if(isset($_POST['disp_name'])){
			$disp_name = $_POST['disp_name'];
		}
		if($user_id === ''){
			return 'IDを入力してください';
		}
		if(preg_match('/^[0-9A-Za-z\-\._]+$/', $user_id) !== 1){
			return 'IDに使用できない文字が含まれています';
		}
		if(userExists($user_id)){
			return 'そのIDはすでに使用されています';
		}
		
		if($user_name === ''){
			return 'ユーザー名を入力してください';
		}
		if($disp_name === ''){
			return '表示名を入力してください';
		}
		if(preg_match('/^[0-9A-Za-z\-\._]+$/', $disp_name) !== 1){
			return '表示名に使用できない文字が含まれています';
		}
		if(!userAdd($user_id, $user_name, $disp_name)){
			return '登録に失敗しました。';
		}
		if(isset($_POST['passwd'], $_POST['passwd_confirm'])){
			$passwd = $_POST['passwd'];
			$passwd_confirm = $_POST['passwd_confirm'];
			if($passwd !== $passwd_confirm){
				return 'パスワードが一致しません';
			}
			if(!updateWebPassword($user_id,$passwd)){
				$result .= '<p align="center">管理ページ利用権限の付加に失敗しました</p>';
			}
		}
		if($roomList = getRooms()){
			foreach($roomList as $i => $roomName){
				if(isset($_POST['room_'.$i])){
					if(!allowRoomUser($i, $user_id, true)){
						$result .= '<p align="center">部屋の利用権限に付加に失敗しました</p>';
					}
				}
			}
		}
		$title = 'ユーザー登録完了';
		include('resources/head.php');
		echo $result;
		include('resouces/foot.php');
		exit();
	}
	$title = post();
}
include('resources/head.php');
?>
<style>
label {
	margin-bottom: 0rem;
}
</style>
<form action="./useradd.php" method="post">
<label for="user_id">ユーザーID</label>
<div class="input-group input_width">
	<input name="user_id" id="user_id" class="form-control" pattern="^[0-9A-Za-z\-._]+$" value="<?php echo $user_id; ?>" required />
</div>
<p class="text-info">ログインなどに使用するIDです(半角英数字とハイフン、アンダースコア、ピリオド)</p>
<label for="passwd">パスワード</label>
<div class="input-group input_width">
	<input name="passwd" id="passwd" class="form-control" type="password" />
</div>
<label for="passwd_confirm">パスワード確認用</label>
<div class="input-group  input_width">
	<input name="passwd_confirm" id="passwd_confirm" class="form-control" type="password" />
</div>
<p class="text-info">管理画面にログインするためのパスワードです(空にするとログインできなくできます)</p>
<label for="user_name">ユーザー名</label>
<div class="input-group input_width">
	<input name="user_name" id="user_name" class="form-control" value="<?php echo $user_name; ?>" required />
</div>
<p class="text-info">識別用の名前です。ログの表示などに使われます。</p>
<label for="disp_name">表示名</label>
<div class="input-group input_width">
	<input name="disp_name" id="disp_name" class="form-control"  pattern="^[0-9A-Za-z\-._]+$" value="<?php echo $disp_name; ?>" required />
</div>
<p class="text-info">LCDなどに表示される名前です。(半角英数字とハイフン、アンダースコア、ピリオド)</p>
<label>部屋選択</label>
<div class="card input_width">
	<?php
	if($roomList = getRooms()){
		foreach($roomList as $i => $roomName){
			if(!is_numeric($i))continue;
			$checked = '';
			if(isset($_POST['room_' . $i])){
				$checked = ' checked="checked"';
			}
			echo '<p class="card-text"><input type="checkbox" name="room_' . $i . '"' . $checked . '>';
			echo $roomName;
			echo '</p>';
		}
	}
	?>
</div>
<p class="text-info">ユーザーが操作可能にしたい部屋にチェックを付けます。
<div>
	<button class="btn btn-default" type="submit">決定</button>
</div>
</form>
<?php
include('resources/foot.php');
?>
