<?php
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Headers: *");
        $seat = $_REQUEST['seat'];
        $seatIP = $_REQUEST['seatIP'];
        $username = $_REQUEST['username'];
        $usestatus = shell_exec("sudo /bin/sh /root/script/min/single_scan.sh $seat $seatIP $username");

        // $usestatus=1;
        echo $usestatus;
?>