<?php
class Table{
	var $titles;
	var $title_count;
	function Table($titles){
		$this->titles = $titles;
		$this->title_count = count($titles);
		echo '<div class="container">';
		echo '<table class="table table-striped table-borderd">';
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
		echo '</tbody>';
		echo '</table>';
		echo '</div>';
	}
	function add($list){
		echo '<tr>';
		echo '<th scope="row">'.$list[0].'</th>';
		for ($i=1; $i < $this->title_count; $i++){
			echo '<td>'.$list[$i].'</td>';
		}
		echo '</tr>';
	}
}
?>
