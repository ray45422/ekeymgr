<?php
$pages = array(
	'index.php' => 'Home',
	'users.php' => 'Users',
	'keys.php' => 'Keys',
	'logs.php' => 'Logs',
	'services.php' => 'Services',
	'rooms.php' => 'Rooms');
?>

<nav class="navbar navbar-expand-lg fixed-top navbar-light bg-light">
	<a class="navbar-brand" href="./index.php">ekeymgr panel</a>
	<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarCollapse" aria-controls="navbarCollapse" aria-expanded="false" aria-label="Toggle navigation">
		<span class="navbar-toggler-icon"></span>
	</button>
	<div id="navbarCollapse" class="collapse navbar-collapse">
		<ul class="navbar-nav mr-auto">
			<?php
			$path = $_SERVER['PHP_SELF'];
			foreach($pages as $key => $val){
				echo '<li class="nav-item';
				if(strpos($path,$key) !== false){
					echo ' active';
				}
				echo '"><a class="nav-link" href="./';
				echo $key;
				echo '">';
				echo $val;
				echo '</a></li>'.PHP_EOL;
			}
			echo PHP_EOL;
			?>
		</ul>
		<ul class="navbar-nav navbar-right"><li class="nav-item"><a class="nav-link" href="./logout.php">Logout</a></li></p>
	</div>
</nav>
