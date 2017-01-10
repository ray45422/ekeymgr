<?php
class Table{
	var $titles;
	var $title_count;
	var $isClosed = false;
	function Table($titles){
		$this->titles = $titles;
		$this->title_count = count($titles);
		echo '<table class="table table-striped table-bordered table-hover">';
		echo '<thread>';
		echo '<tr>';
		foreach ($titles as $title) {
			echo '<th>'.$title.'</th>';
		}
		echo '</tr>';
		echo '</thread>';
		echo '<tbody>';
	}
	function __destruct(){
		if(!$this->isClosed){
			$this->close();
		}
	}
	function add($list){
		echo '<tr>';
		echo '<th>'.$list[0].'</th>';
		for ($i=1; $i < $this->title_count; $i++){
			echo '<td>'.$list[$i].'</td>';
		}
		echo '</tr>';
	}
	function close(){
		echo '</tbody>';
		echo '</table>';
		$this->isClosed = true;
	}
}
class Container{
	var $isClosed = false;
	function Container(){
		echo '<div class="container">';
	}
	function __destruct(){
		if(!$this->isClosed){
			$this->close();
		}
	}
	function add(...$list){
		foreach ($list as $value) {
			echo $value;
		}
	}
	function close(){
		echo '</div>';
		$this->isClosed = true;
	}
}
class Panel{
	var $isClosed = false;
	function Panel(){
		echo '<div class="panel panel-default">';
	}
	function __destruct(){
		if(!$this->isClosed){
			$this->close();
		}
	}
	function setHeader($head){
		echo '<div class="panel-heading">';
		echo $head;
		echo '</div>';
	}
	function add(...$list){
		foreach($list as $value){
			echo '<div class="panel-body">';
			echo $value;
			echo '</div>';
		}
	}
	function close(){
		echo '</div>';
		$this->isClosed = true;
	}
}
class ListGroup{
	var $isClosed = false;
	function List(){
		echo '<ul class="list-group">';
	}
	function __destruct(){
		if(!$this->isClosed){
			$this->close();
		}
	}
	function add(...$list){
		foreach($list as $value){
			echo '<li class="list-group-item">';
			echo $value;
			echo '</li>';
		}
	}
	function close(){
		echo '</ul>';
	}
}
class Pagination{
	var $address;
	var $page;
	var $pages;
	var $links = 9;
	var $hlinks = 4;
	var $isClose = false;
	function Pagination($address, $page, $pages){
		$this->address = $address;
		$this->page = $page;
		$this->pages = $pages;
		echo '<nav>';
		echo '<ul class="pagination">';
		echo '<li>'.makelink("1", $address, "page=1");
		echo '<li';
		if($page == 1){
			echo ' class="disabled">';
			echo '<span aria-hidden="true">«</span>';
		}else{
			echo '>';
			echo makelink("«", $address, "page=".($page-1));
		}
		echo '</li>';
		$this->pagegen();
		echo '<li';
		if($page == $pages){
			echo ' class="disabled">';
			echo '<span aria-hidden="true">»</span>';
		}else{
			echo '>';
			echo makelink("»", $address, "page=".($page+1));
		}
		echo '</li>';
		echo '<li>'.makelink($pages, $address, "page=".$pages);
		$this->close();
	}
	function pagegen(){
		$start = $this->page - $this->hlinks + 1;
		$end = $start + $this->links-1;
		if($start < 1){
			$diff = 1 - $start;
			$start = 1;
			$end += $diff;
		}
		if($end > $this->pages){
			$diff = $this->pages - $end;
			$end = $this->pages;
			$start += $diff;
		}
		if($start < 1){
			$start = 1;
		}
		for($i = $start; $i <= $end; $i++){
			echo '<li';
			if($i == $this->page){
				echo ' class="active"';
			}
			echo '>';
			echo makelink($i, $this->address, "page=".$i);
			echo '</li>';
		}
	}
	function close(){
		echo '</ul>';
		echo '</nav>';
	}
}
function makelink($title, $address, ...$params){
	$parameter = concat_params($params);
	return '<a href="'.$address.$parameter.'">'.$title.'</a>';
}
function concat_params($params){
	$parameter = '';
	if(count($params) !== 0){
		$parameter = '?'.$params[0];
		for ($i=1; $i < count($params); $i++) {
			$parameter .= '&'.$params[$i];
		}
		return $parameter;
	}
}
?>
