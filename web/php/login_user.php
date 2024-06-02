<?php
    require("auth.php");
    require("config.php");
    $mysqli = new mysqli("localhost", $DBUSER, $DBPWD, $DBNAME);
    $Q = "select username from userinfo where status='1' or status='2' or status='3' or status='4';";
    $result = $mysqli->query($Q);
    $num = $result->num_rows;
    for ( $i=0; $i<$num; $i++ ){
        $row = $result->fetch_row();
        $m=($i+1)%2;
        if ( $m != 0) {
            $username = $username . $row[0];
        }
        else {
            $username = $username . ',  ' . $row[0]."<br/>";
        }
    }
    echo $username;
?>
