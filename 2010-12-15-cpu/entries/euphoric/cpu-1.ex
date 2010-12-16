-- include std/console.e
include std/io.e
include std/text.e

-- read in a CPU-source text and execute

/*
	100	 halt
	2dn	 set register d to n
	3dn	 add n to register d
	4dn	 multiply d by n
	5ds	 set register d to the value of register s
	6ds	 add the value of register s to register d
	7ds	 multiply register d by the value of register s
	8da	 set register d to the value in RAM whose address is in register a
	9sa	 set the value in RAM whose address is in register a to that of register s
	0ds	 goto the location in register d unless register s contains 0
	?d	 print the value of register d with a trailing newline
	??d	 print the value of register d with a trailing space
*/

sequence
	registers = repeat(0,10),
	RAM = repeat(-1,1000),
	command = command_line(),
	sample_program = read_lines( cmds[3] )
-- 	sample_program = read_lines( "5and10.cpu" )

integer
	code,
	line = 1,
	lines = length( sample_program ),
	r1, r2, p1, p2,
	QM = '?'-'0'

while line <= lines do

	command = sample_program[line][1..3] - '0'
	code = command[1]
	p1 = command[2]
	p2 = command[3]

	r1 = p1 + 1
	r2 = p2 + 1
		
-- 	puts(1,"\nDealing with '" & sprint(command) & "'")
	
	switch code do
		case 1 then
			exit
			
		case 2 then
			registers[r1] = p2
		
		case 3 then
			registers[r1] += p2
			
		case 4 then
			registers[r1] *= p2
			
		case 5 then
			registers[r1] = registers[r2]
		
		case 6 then
			registers[r1] += registers[r2]
			
		case 7 then
			registers[r1] *= registers[r2]
		
		case 8 then
			registers[r1] = RAM[registers[r2]+1]
			
		case 9 then
			RAM[registers[r1]+1] = registers[r2]
			
		case 0 then
			if registers[r2] != 0 then
				line = registers[r1]
			end if
			
		case 15 then
			if command[2] = QM then
				print(1,registers[r2])
				puts(1," ")
			else
				print(1,registers[r1])
				puts(1,"\n")
			end if
			
	end switch
	
	line += 1
	
end while

-- maybe_any_key()
