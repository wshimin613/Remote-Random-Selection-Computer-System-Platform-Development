<?php 

// if(isset($_POST['download'])) {}
// shell_exec("sudo /bin/sh openctrl.sh 4040C003 PC1-1 1");
require('auth.php');
require('config.php');
$account = str_replace("'","''",$_REQUEST['account']);
$db = new mysqli("localhost", "$DBUSER", "$DBPWD", "$DBNAME");
$result=$db->query('set names utf-8');
$Q="select IP,port from userinfo where username='${account}';";
$result=$db->query($Q);
// $num=$result->num_rows;
$item=$result->fetch_row();
$data=json_encode($item);
echo $data;

// for ($i=0;$i<$num;$i++) {
// 	$item=$result->fetch_row();
//     echo $item[0]. .;
// }

?>