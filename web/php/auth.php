<?php
    $auth = $_REQUEST['auth'];
    if ( $auth != true ){
        header("location: ../index.html");
        die("尚未登入");
    }
?>