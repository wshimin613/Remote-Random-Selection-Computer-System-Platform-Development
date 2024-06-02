#include <stdio.h>
#include <stdlib.h>

int main() {
	int ID = system("for /f \"tokens=3\" %a in ('C:\\users\\public\\query') do echo %a");
	system("C:\\Windows\\System32\\logoff.exe ID");
	return 0;
}
