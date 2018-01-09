<?php
if(basename($_SERVER['PHP_SELF']) !== 'keyadd.php'){
	die();
}
$title = '新規鍵登録';
include('php/login.php');
include_once('php/db_utils.php');
include_once('php/db_login.php');
include_once('php/utils.php');
include('resources/head.php');;
if($_SERVER['REQUEST_METHOD'] === 'POST'){
	global $user_id, $service_name, $felica_id, $password, $password_confirm;
	function registar(){
		global $user_id, $service_name, $felica_id, $password, $password_confirm;
		switch($service_name){
			case "FeliCa":
				return registarFeliCa($user_id, $felica_id);
			case "Web":
				return updateWebPassword($user_id, $password);
			default:
				$hashedID = hashGenerate($password);
				return registarKey($user_id, $service_name, $hashedID);
		}
	}
	function post(){
		global $user_id, $service_name, $felica_id, $password, $password_confirm;
		if(isset($_POST['service_name'], $_POST['user_id'])){
			$user_id = $_POST['user_id'];
			$service_name = $_POST['service_name'];
			if(isset($_POST['felica_id'])){
				$felica_id = $_POST['felica_id'];
			}else if(isset($_POST['password'], $_POST['password_confirm'])){
				$password = $_POST['password'];
				$password_confirm = $_POST['password_confirm'];
				if($password !== $password_confirm){
					return '<p align="center">同じパスワードを入力してください</p>';
				}
			}else{
				return '<p align="center">必要な情報が足りていません</p>';
			}
		}else{
			return '<p align="center">必要な情報が足りていません</p>';
		}
		if(registar()){
			return '<p align="center">登録完了</p>';
		}else{
			return '<p align="center">登録失敗</p>';
		}
	}
	echo post();
	include('resources/foot.php');
	exit();
}
if(isset($_GET['userid'])){
	$user_id = htmlentities($_GET['userid']);
	if(!userExists($user_id)){
		echo '<p align="center">ユーザーが存在しません</p>';
		include('resources/foot.php');
		exit();
	}
	?>
	<style>
		.password_input {
			width: 18rem;
		}
		.message {
			color: red;
			margin-bottom: 0rem;
		}
		.submit_button {
			margin-top: 1rem;
		}
		label {
			margin-bottom: 0rem;
		}
	</style>
	<div id="testApp">
		<p align="center">
			<label for="service">認証メソッドを選択してください:</label>
			<select id="service" name="service" v-model="selectedService" v-on:change="changeService">
				<option disabled="disabled" value="">選択してください</option>
			<?php
			$services = getServices();
			foreach($services as $service_id=>$service_name){
				?>
				<option><?php echo $service_name; ?></option>
				<?php
			}
			?>
			</select>
		</p>
		<form v-if="selectedService === 'FeliCa'" action="./keyadd.php" method="post">
			<label for="felica_id">FeliCaID</label>
			<div class="input-group password_input">
				<input name="felica_id" class="form-control" v-model="felicaId" v-on:input="checkFeliCa" />
				<input name="user_id" type="hidden" value="<?php echo $user_id; ?>" />
				<input name="service_name" type="hidden" v-model="serviceName" />
			</div>
			<p class="text-info">FeliCaのIDを入力してください(半角16進数小文字16桁)</p>
			<p><button class="btn btn-default" v-bind:disabled="isButtonDisabled">決定</button></p>
		</form>
		<form v-else-if="selectedService!==''" action="./keyadd.php" method="post">
			<label for="password">パスワード</label>
			<div :class="['input-group', 'password_input']">
				<input name="password" type="password" class="form-control" v-model="password" v-on:input="checkPassword" />
			</div>
			<label for="password_confirm">パスワード確認用</label>
			<div :class="['input-group', 'password_input']">
				<input name="password_confirm" type="password" class="form-control" v-model="passwordConfirm" v-on:input="checkPassword" />
			</div>
			<input name="user_id" type="hidden" value="<?php echo $user_id; ?>" />
			<input name="service_name" type="hidden" v-model="serviceName" />
			<p class="message" v-show="showMessage">パスワードが一致していません</p>
			<p><button class="btn btn-default submit_button" v-bind:disabled="isButtonDisabled">決定</button></p>
		</form>
		<div>

		</div>
	</div>
	<script type="text/javascript">
	var app = new Vue({
		el: '#testApp',
		data: {
			felicaId: "",
			password: "",
			passwordConfirm: "",
			isButtonDisabled: true,
			selectedService: "",
			isFeliCa: false,
			showMessage: false,
			serviceName: ""
		},
		methods: {
			checkPassword: function(){
				if(this.passwordConfirm !== ''){
					this.showMessage = this.password !== this.passwordConfirm;
				}
				if(this.password !== '' && this.passwordConfirm !== ''){
					this.isButtonDisabled = this.showMessage;
				}else{
					this.isButtonDisabled = true;
				}
			},
			checkFeliCa: function(){
				this.isButtonDisabled = !(this.felicaId !== '' && this.felicaId.length == 16);
			},
			changeService: function(){
					this.isButtonDisabled = true;
				this.serviceName = this.selectedService;
		}
		}
	})
	</script>
	<?php
}else{
	?>
	<p align="center">ユーザーが指定されていません</p>
	<?php
}
include('resources/foot.php');
?>
