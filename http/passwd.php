<?php
if(basename($_SERVER['PHP_SELF']) !== 'passwd.php'){
	die();
}
$title = 'パスワード変更';
include('php/login.php');
include_once('php/db_utils.php');
include_once('php/db_login.php');
include_once('php/utils.php');
if($_SERVER['REQUEST_METHOD'] === 'POST'){
	function post(){
		$user = $_SERVER['PHP_AUTH_USER'];
		$passwd1 = $_SERVER['PHP_AUTH_PW'];
		$passwd2 = $_POST['current_password'];
		$newpasswd1 = $_POST['new_password'];
		$newpasswd2 = $_POST['new_password_confirmation'];
		if($passwd1 !== $passwd2){
			return "現在設定されているパスワードと違います";
		}
		if($newpasswd1 !== $newpasswd2){
			return "同じパスワードを入力してください";
		}
		if(!isValidatedPassword($user, $passwd1)){
			return "現在設定されているパスワードと違います";
		}
		if(updateWebPassword($user, $newpasswd1)){
			return "パスワードを変更しました";
		}else{
			return "パスワードの変更に失敗しました";
		}
	}
	$title = post();
}
include('resources/head.php');
?>
<style>
.input-group1 {
	margin-bottom: 20px;
}
.input-group {
	width: 300px;
}
.message {
	margin-bottom: 0px;
	color: red;
}
.submit-button {
	margin-top: 20px;
}
</style>
<form action="./passwd.php" method="post" id="passwordUpdateForm">
<div class="input-group input-group1">
	<label for="current_password">現在のパスワード</label>
	<input name="current_password" type="password" class="form-control" v-model="currentPasswd" v-on:keyup="checkInput" />
</div>
<div class="input-group">
	<label for="new_password">新しいパスワード</label>
	<input name="new_password" type="password" class="form-control" v-model="newPasswd" v-on:keyup="checkInput" />
</div>
<div class="input-group">
	<label for="new_password_confirmation">新しいパスワードを再入力</label>
	<input name="new_password_confirmation" type="password" class="form-control" v-model="newPasswdConfirm" v-on:keyup="checkInput" />
</div>
<p class="message" v-show="showMessage">パスワードが一致していません</p>
<div>
	<button class="btn btn-default submit-button" type="submit" v-bind:disabled="isButtonDisable">決定</button>
</div>
</form>
<script type="text/javascript">
var app = new Vue({
	el: '#passwordUpdateForm',
	data: {
		currentPasswd: "",
		newPasswd: "",
		newPasswdConfirm: "",
		showMessage: false,
		isButtonDisable: true
	},
	methods: {
		checkInput: function(){
			if(this.newPasswdConfirm !== ''){
				this.showMessage = this.newPasswd !== this.newPasswdConfirm;
			}
			if(this.currentPasswd != "" && this.newPasswd != "" && this.newPasswdConfirm != ""){
				this.isButtonDisable = this.showMessage;
			}else{
				this.isButtonDisable = true;
			}

		}
	}
})
</script>
<?php
include('resources/foot.php');
?>
