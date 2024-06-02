<?php
    //require('auth.php');
    require("config.php");
    $mysqli = new mysqli("localhost", $DBUSER, $DBPWD, $DBNAME);

    $Q = "select username from userinfo where status = '1';";
    $result = $mysqli->query($Q);
    $num = $result->num_rows;

    for ( $i=0; $i<$num; $i++ ){
        $row = $result->fetch_row();
        $return = $return . $row[0] . ',';
    }
    echo $return;
?>