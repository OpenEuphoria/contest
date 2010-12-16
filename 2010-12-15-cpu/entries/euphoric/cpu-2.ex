-- cklester #1

include std/io.e
include std/text.e
include std/cmdline.e

sequence
	registers = repeat(0,10),
	RAM = repeat(-1,1000),
	command,
	cmd = command_line(),
	sample_program = read_lines( cmd[3] )

integer
	code,
	line = 1,
	lines = length( sample_program ),
	r1, r2, p2, reg1, reg2

while line <= lines do

	command = sample_program[line] - '0'
	code = command[1]
	p2 = command[3]

	r1 = command[2] + 1
	r2 = p2 + 1
	
	reg1 = registers[r1]
	if r2 > 0 then
		reg2 = registers[r2]
	end if
	
	switch code do
			
		case 2 then
			reg1 = p2
		
		case 3 then
			reg1 += p2
			
		case 4 then
			reg1 *= p2
			
		case 5 then
			reg1 = reg2
		
		case 6 then
			reg1 += reg2
			
		case 7 then
			reg1 *= reg2
		
		case 8 then
			reg1 = RAM[reg2+1]
			
		case 9 then
			RAM[reg1+1] = reg2
			
		case 0 then
			if reg2 != 0 then
				line = reg1
			end if
			
		case 15 then
			if command[2] = 15 then
				printf(1,"%d ",{reg2})
			else
				printf(1,"%d\n",{reg1})
			end if
		
		case else
			exit
			
	end switch

	registers[r1] = reg1
		
	line += 1
	
end while
