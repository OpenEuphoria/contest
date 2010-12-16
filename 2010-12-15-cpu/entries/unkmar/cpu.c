#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LINE_LENGTH 16483
#define BUFFER_LENGTH 16383
int main(int argc, char *argv[]) {

	int linecount = 0;
	char line[LINE_LENGTH];
	char *code[BUFFER_LENGTH];

//load program
	while (fgets(line, sizeof(line), stdin) != NULL) {
		int valid = 0;
		line[strlen(line)-1] = '\0';
		if (strlen(line) > 2)
			if ((
					('9' >= line[0] && line[0] >= '0') && 
					('9' >= line[1] && line[1] >= '0') && 
					('9' >= line[2] && line[2] >= '0')) ||
				(line[0] == '?' && 
				 line[1] == '?' && 
				 '9' >= line[2] && 
				 line[2] >= '0')
				)
				valid++;
		if (strlen(line) > 1) {
			if (line[0] == '?' && '9' >= line[1] && line[1] >= '0')
				valid++;
			if (valid) {
				code[linecount] = malloc(3);
				memcpy(code[linecount], line, 3);
//				printf("%3d '%s'\n", linecount, line);
				linecount++;
			}
		}
	}
//program loaded
//	printf("%d\n", sizeof(code));

//execute code
	int ip = 0;			// Instruction pointer
	long long r[10]; 	// registers
	long long m[1000];	// memory
	int a;				// address
	char *x;			// current code
	int p1, p2;			// code parameters

	m[0] = -1;
	for (ip=0; linecount > ip; ip++) {
		x = code[ip];
		p1= x[1] - '0';
		p2= x[2] - '0';
		switch ((int)x[0]) {
			case '1':
				// Halt
				ip = linecount;
				break;
			case '2':
				// Assign p2 to register p1
				r[p1] = p2;
				break;
			case '3':
				// Add p2 to register p1
				r[p1] += p2;
				break;
			case '4':
				// Multiply p2 by register p1
				r[p1] *= p2;
				break;
			case '5':
				// Copy register p2 to register p1
				r[p1] = r[p2];
				break;
			case '6':
				// Add register p2 to register p1
				r[p1] += r[p2];
				break;
			case '7':
				// Multiply register p2 by register p1
				r[p1] *= r[p2];
				break;
			case '8':
				// Pop regsiter p1 from memory specifed at register p2
				a = (int)r[p2];
				r[p1] = m[a];
				break;
			case '9':
				// Push register p1 to memory specifed at register p2
				a = (int)r[p2];
				m[a] = r[p1];
				break;
			case '0':
				if (r[p2]) {
					ip = r[p1] - 1;
				}
				break;
			case '?':
				if (x[1] == '?') {
					printf("%d ", r[p2]);
				} else {
					printf("%d\n", r[p1]);
				}
				break;
			default:
				break;
		}
	}



//free code
	int loop = 0;
	for (loop = 0; linecount > loop; loop++) {
//		printf("%3d '%s'\n", loop, code[loop]);
		free(code[loop]);
	}

	return 0;
}
