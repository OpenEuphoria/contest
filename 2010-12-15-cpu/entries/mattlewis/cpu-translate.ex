-- Translates cpu code into euphoria code, then runs the result

object
	cmd = command_line()
integer
	fn = open( cmd[3], "r" ),
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
label "%d" next_label = %d + 1 /*%s*/jump_label = reg%s test_label = reg%s  goto "jnz"
label "%d" abort( 0 )                                                             -- 1
label "%d" /*%d %s*/ reg%s = %s                                                   -- 2
label "%d" /*%d %s*/ reg%s += %s                                                  -- 3
label "%d" /*%d %s*/ reg%s *= %s                                                  -- 4
label "%d" /*%d %s*/ reg%s = reg%s                                                -- 5
label "%d" /*%d %s*/ reg%s += reg%s                                               -- 6
label "%d" /*%d %s*/ reg%s *= reg%s                                               -- 7
label "%d" /*%d %s*/ reg%s = ram[reg%s+1]                                         -- 8
label "%d" /*%d %s*/ next_label = reg%s ram[reg%s+1] = next_label                 -- 9
                                                                                  --10
                                                                                  --11
                                                                                  --12
                                                                                  --13
                                                                                  --14
label "%d" /*%d %s*/ ? reg%s                                                      --15
label "%d" /*%d %s %s*/ printf(1, "%%d ", reg%s )                                 --16

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
label "%d"
abort( 0 )
label "jnz"

if not test_label then
	jump_label = next_label
end if
switch jump_label do

`, lines)

-- Here we build the cases.  Note that we're using integer cases, but
-- we have to use literal strings with goto.
for i = 0 to lines do
	cpu &= sprintf( "\tcase %d then goto \"%d\"\n", i & i )
end for

-- We add the extra ",1" to the end of open to tell euphoria to close the file
-- as soon as the handle has been dereferenced.  Since it's put into a temp
-- variable, it's cleaned up once the printf is finished.  If we didn't close
-- the file, we couldn't run it with the system_exec call below.
printf( open( "cpu-translate-code.ex", "w", 1), `
integer 
	reg0 = 0,
	reg1 = 0,
	reg2 = 0,
	reg3 = 0,
	reg4 = 0,
	reg5 = 0,
	reg6 = 0,
	reg7 = 0,
	reg8 = 0,
	reg9 = 0
sequence ram = -1 & repeat( 0, 999 )
integer 
	test_label = 0,
	jump_label = 0,
	next_label = 0
%s
end switch

`, {cpu} )

system_exec( "eui cpu-translate-code.ex" )
