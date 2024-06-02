#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int c, char *argv[]) {
        char var[10];
        char value[] = "0";
        char cmd[500] = "lxterminal -e bash -c \"ping 1.1.1.1 -n 1 & del ";
        strcat(cmd,argv[0]);
        strcat(cmd,"\"");

        FILE *fp = popen("curl -s \"http://120.114.141.1/DaaS/php/get_userconflict.php?seat=PC1-1&seatIP=192.168.31.1&username=4070C031\"", "r");
        while (fgets(var, 10, fp) != NULL)
        {
                //printf("%s\n", "connecting...");
                system("lxterminal -e bash -c \"echo connecting...\"");
        }
        pclose(fp);

        if( value[0] == var[0] ){
                system("remmina -c rdp://120.114.141.1:16918");
        }else{
                //printf("%s\n", "Sorry,This PC is currently being used");
                system("lxterminal -e bash -c \"echo 'Sorry,This PC is currently being used'\"");
                fgetc(stdin);
        }

        FILE *fw = popen("curl -s \"http://120.114.141.1/DaaS/php/del_firewall.php?userIP=120.114.99.174&userport=16918&vmip=192.168.31.1&username=4070C031\"", "r");
        pclose(fw);
        system(cmd);

        return 0;
}
