<?php
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Headers: *");

        $userIP = $_REQUEST['userIP'];
        $userport = $_REQUEST['userport'];
        $vmip = $_REQUEST['vmip'];
        $username = $_REQUEST['username'];
        
        exec("sudo /bin/sh /root/script/min/del_firewall.sh $userIP $userport $vmip");
        exec("sudo /root/script/min/login.sh ${vmip} ${username}");
?>