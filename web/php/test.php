<?php
    require('config.php');
    $db = new mysqli("localhost", "$DBUSER", "$DBPWD", "$DBNAME");
    $res = $db->query('set names utf-8');
	$username = $_REQUEST['username'];
	$userIP = getip();

	// 如果使用者 status = 1 ，則會直接跳到下載檔案，不會再次開啟新的機器。
	/***
	$Q = "select IP,port,vmip from userinfo where status='1' and username='${username}'";
	$res = $db->query("$Q");
	if ( $res ){
		$row = $res->fetch_array();
		$userIP = $row[0];
		$userport = $row[1];
		$vmip = $row[2];
	}***/

    $i = 0;
    do{
        $i = 0;
        $userport = rand(10000,30000);
		$Q = "select port from userinfo where port=$userport;";
		$res = $db->query("$Q");
		if( $res->num_rows == 1 ){
			$userport = rand(10000,30000);
			$i = 1;
		}
    }while ( $i == 1 );

	function getip(){
		//取得IP
		if(!empty($_SERVER['HTTP_CLIENT_IP'])){
			$myip = $_SERVER['HTTP_CLIENT_IP'];
		}else if(!empty($_SERVER['HTTP_X_FORWARDED_FOR'])){
			$myip = $_SERVER['HTTP_X_FORWARDED_FOR'];
		}else{
			$myip = $_SERVER['REMOTE_ADDR'];
		} 
		return $myip;
	}

	// 尋找使用者有無使用紀錄
	$Q = "select * from userinfo where username='${username}';";
	$res = $db->query("$Q");
    // status 0. 沒有使用 1. 使用中 2. 實體機開機中 3. 虛擬機開機中 4. 確認機器中 5. 機器開啟錯誤
    // 判斷使用者有無使用紀錄， 1. 有使用紀錄 2. 無使用紀錄
    if ( $res->num_rows == 1 ){
		$Q = "update userinfo set status=4 where username='${username}'";
		$res1 = $db->query("$Q");
		exec("sudo /bin/sh /root/script/min/open2.sh");
		$row = $res->fetch_array();
		$vm = $row[3];
		$vmIP = $row[4];
		$Q = "select * from pre_open where vm='${vm}'";
		$res = $db->query("$Q");
		
		if ( $res->num_rows == 1 ){
			$Q = "update vm set vm_status='1' where vm='${vm}'";
			$res = $db->query("$Q");
			//將被選的電腦移除預備機的表中
			$Q = "delete from pre_open where vm='${vm}'";
			$res = $db->query("$Q");

			$Q = "update userinfo set IP='${userIP}', port='${userport}', vm='${vm}', vmip='${vmIP}', status=3 where username='${username}'";
			$res = $db->query("$Q");

			echo '上次使用電腦可用';
			//直接連線
			exec("sudo /bin/sh /root/script/min/openconnect.sh $username $userIP $userport $vm $vmIP");
		}
		else {
			echo '有使用紀錄，上次電腦不能用，判斷有沒有預備機<br/>';
			//執行迴圈找機器
			$i=0;
			$j=0;
			while( $i == 0 ){
				exec("sudo /bin/sh /root/script/min/open2.sh");
				$Q = "select * from pre_open";
				$res = $db->query("$Q");
				$row = $res->fetch_array();
				$vm = $row[1];
				$vmIP = $row[3];
				$Q = "update vm set vm_status='1' where vm='${vm}'";
				$res = $db->query("$Q");
				$Q = "delete from pre_open where vm='${vm}'";
				$res = $db->query("$Q");
				$Q = "update userinfo set IP='${userIP}',port='${userport}',vm='${vm}',vmIP='${vmIP}',status=3 where username='${username}'";
				$res = $db->query("$Q");

				$Q = "select vm_status from vm where vm='${vm}' and vm_status='1'";
				$res1 = $db->query("$Q");

				$Q = "select status from userinfo where vm='${vm}' and username!='${username}' and (status='1' or status='2' or status='3')";
				$res2 = $db->query("$Q");
				if ( ($res1->num_rows && $res2->num_rows) ||  $vm == '' ){
					echo "重選";
					$i=0;
					$j=$j+1;
					if ( $j == 2 ){
						echo '有使用紀錄，上次電腦不能用，預備機不能用，自動尋找新連線';
						exec("sudo /bin/sh /root/script/min/autocreate2.sh $username $userIP $userport");
						$i=5;
					}
				}
				else {
					echo "有使用紀錄，上次電腦不能用，預備機可用，直接連線";
					exec("sudo /bin/sh /root/script/min/openconnect.sh $username $userIP $userport $vm $vmIP");
					$i=1;
				}
			}
			/***$Q = "select * from pre_open";
			$res = $db->query("$Q");
			if( $res->num_rows ){
				echo '有使用紀錄，上次電腦不能用，有預備機<br/>';
				$row = $res->fetch_array();
				$vm = $row[1];
				$vmIP = $row[3];

				$Q = "update vm set vm_status='1' where vm='${vm}'";
				$res = $db->query("$Q");
				//將被選的電腦移除預備機的表中
				$Q = "delete from pre_open where vm='$vm'";
				$res = $db->query("$Q");

				//$status = shell_exec("sudo /bin/sh /root/script/min/single_scan.sh $vm $vmIP");
				if ( $status == 0 ){
					echo '有使用紀錄，預備機可用，直接連線';
					//更新使用者資料，狀態為1才不會讓pre_open重複
					$Q = "update userinfo set IP='${userIP}',port='${userport}',vm='${vm}',vmIP='${vmIP}',status=1 where username='${username}'";
					$res = $db->query("$Q");
					//將被選的電腦移除預備機的表中
					$Q = "delete from pre_open where vm='$vm'";
					$res = $db->query("$Q");
					//直接連線
					exec("sudo /bin/sh /root/script/min/openconnect.sh $username $userIP $userport $vm $vmIP");
				}
			}
			// 2021.10.11，測試 ok
			else {
				echo '有使用紀錄，上次電腦不能用，沒有預備機，自動尋找新連線<br/>';
				exec("echo 'sudo /bin/sh /root/script/min/autocreate2.sh $username $userIP $userport' |at now");
			}***/
		}
	}
	// 2021.10.09，測試 ok
	else {
		echo '沒有使用紀錄，判斷有沒有預備機<br/>';
		$Q = "insert into userinfo (username,IP,port,status) values('${username}','${userIP}',${userport},4);";
		$res = $db->query("$Q");

		//執行迴圈找機器
		$i=0;
		$j=0;
		while( $i == 0 ){
			exec("sudo /bin/sh /root/script/min/open2.sh");
			$Q = "select * from pre_open";
			$res = $db->query("$Q");
			$row = $res->fetch_array();
			$vm = $row[1];
			$vmIP = $row[3];
			$Q = "update vm set vm_status='1' where vm='${vm}'";
			$res = $db->query("$Q");
			$Q = "delete from pre_open where vm='${vm}'";
			$res = $db->query("$Q");
			$Q = "update userinfo set IP='${userIP}',port='${userport}',vm='${vm}',vmIP='${vmIP}',status=3 where username='${username}'";
			$res = $db->query("$Q");

			$Q = "select vm_status from vm where vm='${vm}' and vm_status='1'";
			$res1 = $db->query("$Q");

			$Q = "select status from userinfo where vm='${vm}' and username!='${username}' and (status='1' or status='2' or status='3')";
			$res2 = $db->query("$Q");
			if ( ($res1->num_rows && $res2->num_rows) ||  $vm == '' ){
				echo "重選";
				$i=0;
				$j=$j+1;
				if ( $j == 2 ){
					echo '預備機不能用，自動尋找新連線';
					exec("sudo /bin/sh /root/script/min/autocreate2.sh $username $userIP $userport");
					$i=5;
				}
			}
			else {
				echo "預備機可用，直接連線";
				exec("sudo /bin/sh /root/script/min/openconnect.sh $username $userIP $userport $vm $vmIP");
				$i=1;
			}
		}
	}


		
		// $Q = "select * from pre_open";
		// $res = $db->query("$Q");
		// if( $res->num_rows ){
		// 	echo '沒有紀錄，有預備機<br/>';
		// 	$row = $res->fetch_array();
		// 	$vm = $row[1];
		// 	$vmIP = $row[3];

		// 	$Q = "update vm set vm_status='1' where vm='${vm}'";
		// 	$res = $db->query("$Q");
			
		// 	$status = shell_exec("sudo /bin/sh /root/script/min/single_scan.sh $vm $vmIP");
		// 	if( $status == 0 ){
		// 		echo '預備機可用，直接連線';
		// 		//更新使用者資料，狀態為1才不會讓pre_open重複
		// 		$Q = "update userinfo set IP='${userIP}',port='${userport}',vm='${vm}',vmIP='${vmIP}',status=1 where username='${username}'";
		// 		$res = $db->query("$Q");
		// 		//將被選的電腦移除預備機的表中
		// 		$Q = "delete from pre_open where vm='$vm'";
		// 		$res = $db->query("$Q");
		// 		//直接連線
		// 		exec("sudo /bin/sh /root/script/min/openconnect.sh $username $userIP $userport $vm $vmIP");
		// 	}
		// 	else {
		// 		echo '預備機不能用';
		// 	}
		// }
		// else {
		// 	echo '預備機不能用，自動尋找新連線';
		// 	exec("echo 'sudo /bin/sh /root/script/min/autocreate2.sh $username $userIP $userport' |at now");
		// }


	// 重複點擊按鈕
	// $status = shell_exec("sudo /bin/flock -xn /root/script/min/open.lock -c /root/script/min/open2.sh; echo $?");
	// $d = new \DateTime();
	// //1毫秒=1000微秒，u表示的是微秒(格式化结果是6位)，除以1000即可得到毫秒
	// echo '當前時間:'.$d->format( 'Y-m-d H:i:s.u' );
?>




