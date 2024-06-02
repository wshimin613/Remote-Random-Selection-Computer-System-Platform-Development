<?php
    require('auth.php');
    require("config.php");
    $mysqli = new mysqli("localhost", $DBUSER, $DBPWD, $DBNAME);
    $username = $_REQUEST['username'];
    $Q = "select status from userinfo where username='$username' and (status='1' or status='2' or status='3' or status='4');";
    $result = $mysqli->query($Q);
    $num = $result->num_rows;

    if ( $num ){
        $row = $result->fetch_row();
        $status=shell_exec("ps -aux | grep 'sudo /bin/sh /root/script/min' | grep -v grep");
        if ($status){
            //正在執行腳本
            echo '1';
        }
        else {
            if ( $row[0] == '1' ){
                // 執行完，下載頁面
                echo '2';
            }
            else {
                // 狀況回報，機器故障或程序問題則可重啟機器
                echo '3';
            }
        }
    }
    else {
        //沒有東西
        echo '0';
    }
?>