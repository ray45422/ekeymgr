<?php
if(basename($_SERVER['PHP_SELF']) !== 'userdel.php'){
	die();
}
$title = 'ユーザー削除';
include('php/login.php');
include_once('php/db_utils.php');
include_once('php/db_login.php');
include_once('php/utils.php');
include('resources/head.php');
function post(){
	if(isset($_POST['userid'])){
		$user_id = htmlentities($_POST['userid']);
		$user_id = htmlspecialchars($user_id);
		if(userExists($user_id)){
			if(userDelete($user_id)){
				?>
				<p align="center">成功しました</p>
				<?php
			}
		}else{
			?>
			<p align="center">ユーザーが存在しません</p>
			<?php
		}
	}else{
		?>
		<p align="center">ユーザーが指定されていません</p>
		<?php
	}
	include('resources/foot.php');
}
if($_SERVER['REQUEST_METHOD'] === 'POST'){
	post();
	exit();
}
if(!isset($_GET['userid'])){?>
	<p align="center">ユーザーIDが指定されていません</p>
<?php
}else{
	$user_id = htmlentities($_GET['userid']);?>
	<p align="center">ユーザーID:<?php echo $user_id; ?></p>
	<p align="center">削除しますか？</p>
	<form action="./userdel.php" method="post" align="center">
		<input name="userid" hidden="hidden" value="<?php echo $user_id; ?>" />
		<button class="btn btn-danger" type="submit">削除</button>
	</form>
<?php
}
include('resources/foot.php');
?>
