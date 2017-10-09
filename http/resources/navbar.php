<?php
$pages = array(
	'index.php' => 'Home',
	'users.php' => 'Users',
	'keys.php' => 'Keys',
	'logs.php' => 'Logs',
	'services.php' => 'Services',
	'rooms.php' => 'Rooms');
?>
<nav class="navbar navbar-default navbar-static-top">
	<div class="container">
		<div class="navbar-header">
			<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
				<span class="sr-only">Toggle navigation</span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="./index.html">ekeymgr panel</a>
		</div>
		<div id="navbar" class="navbar-collapse collapse">
			<ul class="nav navbar-nav">
				<?php
				$path = $_SERVER['PHP_SELF'];
				foreach($pages as $key => $val){
					echo '<li';
					if(strpos($path,$key) !== false){
						echo ' class="active"';
					}
					echo '><a href="./';
					echo $key;
					echo '">';
					echo $val;
					echo '</a></li>';
				}
				?>
			</ul>
		</div>
	</div>
</nav>
