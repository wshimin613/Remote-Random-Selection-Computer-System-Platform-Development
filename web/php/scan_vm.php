<?php
    //require('auth.php');
    require('config.php');
    $db = new mysqli("localhost", "$DBUSER", "$DBPWD", "$DBNAME");
    $res = $db->query('set names utf-8');

    $Q = "select vm_ip from vm where vm_status='0'";
    $res = $db->query("$Q");

    $num = $res->num_rows;
    for ( $i=0; $i<$num; $i++ ){
        $row = $res->fetch_array();
        $vm_status = shell_exec("sudo /bin/bash /root/script/RDPclass/nc.sh $row[0] 2> /dev/null");
        if ( $vm_status ){
            $arr[$i] = $row[0];
            echo $arr[$i];
        }
    }
?>
