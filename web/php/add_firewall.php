<?php
    require('auth.php');
    require("config.php");
    $username = $_REQUEST['username'];
    $mysqli = new mysqli("localhost", $DBUSER, $DBPWD, $DBNAME);
    
    $Q = "select IP,port,vmip from userinfo where username='$username';";
    $result = $mysqli->query($Q);
    $row = $result->fetch_row();

    $firewall=shell_exec("sudo /sbin/iptables-save | grep 'PREROUTING' | grep $row[0] | grep $row[1] | grep $row[2]");

    if ( !$firewall ){
        exec("sudo /sbin/iptables -t nat -A PREROUTING -i eno1 -s $row[0] -p tcp -m tcp --dport $row[1] -j DNAT --to-destination $row[2]:3389");
    }
?>
