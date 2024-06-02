<?php
    // require("auth.php");
    $username = $_REQUEST['username'];
    $mysqli = new mysqli("localhost", "root", "2727175#356", "GFDO");
    $Q = "select unum from member where unum='$username';";
    $result = $mysqli->query($Q);
    $num = $result->num_rows;
    if ($num){
        echo 'admin';
    }
    else {
        echo 'user';
    }
?>