-- Translates cpu code into euphoria code, then runs the result

object
	cmd = command_line(),
	name = cmd[3],
	c_name = name & ".c",
	exe_name = name & "2c"

ifdef WINDOWS then
	exe_name &= ".exe"
end ifdef

cmd = machine_func( 22, name ) & machine_func( 22, exe_name )

if sequence( cmd[2] ) and compare( cmd[1][4..$-1], cmd[2][4..$-1] ) < 0 then
	goto "execute"
end if

integer
	fn = open( name, "r" ),
	lines = 0
sequence
	cpu = ""

-- This is a lookup table for each op.  Each line is a fixed width, so we can easily 
-- grab just the code we want.  Putting it into a single string saves tokens.
-- NB: the first line is short to avoid having to add 1 to each index in the calculations.
--        1         2         3         4         5         6         7         8      *  9
--23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
constant CODE = `
-- BAD                                                                           -- 1
-- BAD                                                                            -- 2
-- BAD                                                                            -- 3
-- BAD                                                                            -- 4
-- BAD                                                                            -- 5
-- BAD                                                                            -- 6
-- BAD                                                                            -- 7
-- BAD                                                                            -- 8
-- BAD                                                                            -- 9
-- BAD                                                                            --10
-- BAD                                                                            --11
-- BAD                                                                            --12
-- BAD                                                                            --13
-- BAD                                                                            --14
-- BAD                                                                            --15
-- BAD                                                                            --16
-- BAD                                                                            --17
-- BAD                                                                            --18
-- BAD                                                                            --19
-- BAD                                                                            --20
-- BAD                                                                            --21
-- BAD                                                                            --22
-- BAD                                                                            --23
-- BAD                                                                            --24
-- BAD                                                                            --25
-- BAD                                                                            --26
-- BAD                                                                            --27
-- BAD                                                                            --28
-- BAD                                                                            --29
-- BAD                                                                            --30
-- BAD                                                                            --31
-- BAD                                                                            --32
-- BAD                                                                            --33
-- BAD                                                                            --34
-- BAD                                                                            --35
-- BAD                                                                            --36
-- BAD                                                                            --37
-- BAD                                                                            --38
-- BAD                                                                            --39
-- BAD                                                                            --40
-- BAD                                                                            --41
-- BAD                                                                            --42
-- BAD                                                                            --43
-- BAD                                                                            --44
-- BAD                                                                            --45
-- BAD                                                                            --46
-- BAD                                                                            --47
-- BAD                                                                            --48
L%d: next_label = %d + 1; /*%s*/jump_label = reg%s; test_label = reg%s;  goto jnz;// 0
L%d: exit( 0 );                                                                   // 1
L%d: /*%d %s*/ reg%s = %s;                                                        // 2
L%d: /*%d %s*/ reg%s += %s;                                                       // 3
L%d: /*%d %s*/ reg%s *= %s;                                                       // 4
L%d: /*%d %s*/ reg%s = reg%s;                                                     // 5
L%d: /*%d %s*/ reg%s += reg%s;                                                    // 6
L%d: /*%d %s*/ reg%s *= reg%s;                                                    // 7
L%d: /*%d %s*/ reg%s = ram[reg%s];                                                // 8
L%d: /*%d %s*/ next_label = reg%s; ram[reg%s] = next_label;                       // 9
                                                                                  --10
                                                                                  --11
                                                                                  --12
                                                                                  --13
                                                                                  --14
L%d: /*%d %s*/ printf( "%%d\n", reg%s );                                          //15
L%d: /*%d %s %s*/ printf( "%%d ", reg%s );                                        //16

`

integer line_start
-- Read in the file.  Since we use "with entry", before the condition is evaluated,
-- control jumps to the "entry" block, reading in the line.  This is a common idiom
-- with while loops to allow us to initialize the data without repeating code.
while sequence( cmd ) with entry do
	-- This calculation could be done in one, but this is actually more efficient,
	-- since no temp variables are created.  We also save tokens on parentheses.
	line_start  = cmd[1]
	line_start += cmd[2] = '?'
	line_start *= 87
	cpu &= sprintf( CODE[line_start .. line_start+86], lines & lines & cmd )
	lines += 1
entry
	cmd = gets( fn )
end while

-- We need to add a final halt statement to the end to prevent hitting the jump switch.
-- Then we build a switch that has a case for each line label.  Jumps set the test_label,
-- next_label and jump_label variables and goto our switch.  The switch variable and 
-- all of the cases are integers, for maximum switch performance.  As long as the code is
-- less than 1025 instructions, we'll end up using the fast version of the switch.  Otherwise,
-- the switch will end up using find() for looking up the jump addresses, which is slower,
-- but works in more general cases.
cpu &= sprintf( `
L%d:
exit( 0 );

jnz:

if( !test_label ){
	jump_label = next_label;
}
switch( jump_label ){

`, lines)

-- Here we build the cases.  Note that we're using integer cases, but
-- we have to use literal strings with goto.
for i = 0 to lines do
	cpu &= sprintf( "\tcase %d: goto L%d;\n", i & i )
end for

-- We add the extra ",1" to the end of open to tell euphoria to close the file
-- as soon as the handle has been dereferenced.  Since it's put into a temp
-- variable, it's cleaned up once the printf is finished.  If we didn't close
-- the file, we couldn't run it with the system_exec call below.
printf( open( c_name, "w", 1), `
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
int main(){
int reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9;
int test_label, jump_label, next_label;
int ram[1000];

reg0 = 0;
reg1 = 0;
reg2 = 0;
reg3 = 0;
reg4 = 0;
reg5 = 0;
reg6 = 0;
reg7 = 0;
reg8 = 0;
reg9 = 0;
test_label = 0;
jump_label = 0;
next_label = 0;
memset( ram, 0, sizeof( int ) * 1000 );
ram[0] = -1;
%s
}
return 0;
}

`, {cpu} )

ifdef WINDOWS then
	constant cc = "wcc386"
elsedef
	constant cc = "gcc"
end ifdef
cmd = sprintf("%s \"%s\" -o \"%s\" -O3", { cc, c_name, exe_name } )
puts( 1, cmd & "\n" )
system_exec( cmd )

label "execute"
system_exec( sprintf( "\"./%s\"", {exe_name} ) )
