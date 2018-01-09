<?php
if(basename($_SERVER['PHP_SELF']) !== 'services.php'){
	die();
}
include_once('php/login.php');
$title = '認証方法管理';
include('resources/head.php');
include_once('php/db_login.php');
include_once('php/utils.php');
include('resources/foot.php');
?>
