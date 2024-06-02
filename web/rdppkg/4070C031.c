#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int c, char *argv[]) {
	char var[10];
	char value[] = "0";
	char cmd[500] = "start /min cmd.exe /c \"ping 1.1.1.1 -n 1 & del ";
	strcat(cmd,argv[0]);
	strcat(cmd,"\"" );

	FILE *fp = popen("C:\\Windows\\System32\\curl.exe -s http://120.114.141.1/DaaS/php/get_userconflict.php?seat=PC12-2^&seatIP=192.168.31.24^&username=4070C031", "r");
	while (fgets(var, 10, fp) != NULL)
	{
		printf("%s\n", "connecting．．．");
	}
	pclose(fp);

	if( value[0] == var[0] ){
		system("start mstsc /admin /v:120.114.141.1:14372");
	}else{
		printf("%s\n", "Sorry,This PC is currently being used");
		system("pause");
	}
	
	FILE *fw = popen("C:\\Windows\\System32\\curl.exe -s http://120.114.141.1/DaaS/php/del_firewall.php?userIP=120.114.140.35^&userport=14372^&vmip=192.168.31.24^&username=4070C031", "r");
	pclose(fw);
	system(cmd);
	return 0;
}
