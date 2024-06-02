#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int c, char *argv[]) {
        char var[10];
        char value[] = "0";

        FILE *fp = popen("curl -s http://120.114.141.1/DaaS/php/get_userconflict.php?seat=PC4-1^&seatIP=192.168.31.7^&username=4070C004", "r");
        while (fgets(var, 10, fp) != NULL)
        {
                printf("%s\n", "connecting．．．");
        }
        pclose(fp);

        if( value[0] == var[0] ){
                system("remmina -c rdp://120.114.141.1:29997");
        }else{
                printf("%s\n", "Sorry,This PC is currently being used");
                system("pause");
        }

        FILE *fw = popen("curl -s http://120.114.141.1/DaaS/php/del_firewall.php?userIP=120.114.140.34^&userport=29997^&vmip=192.168.31.7^&username=4070C004", "r");
        pclose(fw);
        system(cmd);
        return 0;
}
