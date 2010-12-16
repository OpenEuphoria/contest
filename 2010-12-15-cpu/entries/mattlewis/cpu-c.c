#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int* read( const char* name ){
	FILE *in;
	long file_size;
	char c;
	int *code;
	int pc;
	
	in = fopen( name, "r" );
	fseek( in, 0, SEEK_END );
	file_size = ftell( in );
	code = (int*)malloc( sizeof( int ) * file_size );  // way too much, but whatever
	
	pc = -1;
	fseek( in, 0, SEEK_SET );
	while( (c = fgetc( in )) != EOF ){
		if( c == '?' ){
			c = fgetc( in );
			if( c == '?' ){
				code[++pc] = 10;
				code[++pc] = fgetc( in ) - '0';
			}
			else{
				code[++pc] = 11;
				code[++pc] = c - '0';
				
			}
			code[++pc] = 0;
		}
		else{
			code[++pc] = c - '0';
			code[++pc] = fgetc( in ) - '0';
			code[++pc] = fgetc( in ) - '0';
			
		}
		
		// now read until EOL
		do{
			c = fgetc( in );
		}while( c != EOF && c != '\n' );
	}
	fclose( in );
	code[pc] = 1; // add a halt at the end for good measure...
	return code;
}

int main( int argc, const char* argv[] ){
	int reg[10];
	int ram[1000];
	int *code;
	int *base;
	
	memset( reg, 0, sizeof(int) * 10 );
	memset( ram, 0, sizeof(int) * 100 );
	ram[0] = -1;
	
	code = read( argv[1] );
	base = code;
	while( 1 ){
		switch( *code ){
			case 0:
				if( reg[code[2]] ){
					code = base + (reg[code[1]] * 3);
				}
				else{
					code += 3;
				}
				break;
			case 1:
				fflush( stdout );
				return 0;
			case 2:
				reg[code[1]] = code[2];
				code += 3;
				break;
			case 3:
				reg[code[1]] += code[2];
				code += 3;
				break;
			case 4:
				reg[code[1]] *= code[2];
				code += 3;
				break;
			case 5:
				reg[code[1]] = reg[code[2]];
				code += 3;
				break;
			case 6:
				reg[code[1]] += reg[code[2]];
				code += 3;
				break;
			case 7:
				reg[code[1]] *= reg[code[2]];
				code += 3;
				break;
			case 8:
				reg[code[1]] = ram[reg[code[2]]];
				code += 3;
				break;
			case 9:
				ram[reg[code[2]]] = reg[code[1]];
				code += 3;
				break;
			case 10:
				printf("%d ", reg[code[1]] );
				code += 3;
				break;
			case 11:
				printf("%d\n", reg[code[1]] );
				
				code += 3;
				break;
		}
	}
	return 0;
}
