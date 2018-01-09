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
	var $start;
	var $end;
	var $address;
	var $page;
	var $pages;
	var $links = 9;
	var $hlinks = 4;
	var $isClose = false;
	function Pagination($address, $page, $pages){
		$start = $page - $this->hlinks + 1;
		$end = $start + $this->links-1;
		if($start < 1){
			$diff = 1 - $start;
			$start = 1;
			$end += $diff;
		}
		if($end > $pages){
			$diff = $pages - $end;
			$end = $pages;
			$start += $diff;
		}
		if($start < 1){
			$start = 1;
		}
		$this->start = $start;
		$this->end = $end;
		$this->address = $address;
		$this->page = $page;
		$this->pages = $pages;
		$this->pagegen();
	}
	
	function pageLink($title, $page, $active = false, $disable = false){
		echo maketag('li', makeAttribute('class', 'page-item', $active?'active':'', $disable?'disabled':''));
		if($page == '' || $disable){
			echo maketag('span', makeAttribute('class', 'page-link'));
			echo $title;
			echo '</span>';
		}else{
			echo maketag('a', makeAttribute('class', 'page-link'), makeAttribute('href', "$this->address?page=$page"));
			echo $title;
			echo '</a>';
		}
		echo '</li>';
	}
	function pagegen(){
		$start = $this->start;
		$end = $this->end;
		$page = $this->page;
		$pages = $this->pages;
		echo '<nav>';
		echo '<ul class="pagination">';
		$this->pageLink('1', 1);
		$this->pageLink('«', $page - 1, false, $page == 1);
		for($i = $start; $i <= $end; $i++){
			$this->pageLink($i, $i, $page === $i);
		}
		$this->pageLink('»', $page + 1, false, $page == $pages);
		$this->pageLink($pages, $pages);
		$this->close();
	}
	function close(){
		echo '</ul>';
		echo '</nav>';
	}
}
function makeAttribute($attributeName, ...$values){
	return $attributeName . '="' . implode(' ', $values) . '"';
}
function maketag($tagName, ...$attributes){
	$result = "<$tagName";
	foreach($attributes as $value){
		$result .=  ' ' . $value;
	}
	$result .= '>';
	return $result;
}
function makelink($title, $address, ...$params){
	$parameter = concat_params($params);
	$href = 'href="' . $address . $parameter . '"';
	return maketag("a", $href) . $title . '</a>';
}
function concat_params($params){
	return '?' . implode('&', $params);
}
function hashGenerate($data){
	for($i = 0; $i < 3; $i++){
		$data = strtoupper(hash('sha256', $data));
	}
	return $data.'V1';
}
?>
