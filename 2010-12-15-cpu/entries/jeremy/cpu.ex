--
-- User: jeremy_c
--

include std/console.e
include std/io.e

sequence 
	register = repeat(0, 10),
	ram = -1 & repeat(0, 999)

enum 
	OP_GOTO = 0,     -- 0ds
	OP_HALT,         -- 100
	OP_SET,          -- 2dn
	OP_ADD,          -- 3dn
	OP_MUL,          -- 4ds
	OP_SET_FROM_REG, -- 5ds
	OP_ADD_FROM_REG, -- 6ds
	OP_MUL_FROM_REG, -- 7ds
	OP_FROM_RAM,     -- 8da
	OP_TO_RAM,       -- 9sa
	OP_PRINT_NL,     -- ?d
	OP_PRINT         -- ??d

function parse(sequence filename)
	sequence lines = read_lines(filename)
	integer i = 1
	
	while i <= length(lines) do
		if not length(lines[i]) then
			lines = remove(lines, i)
			continue
		end if
		
		lines[i] -= '0'
		if equal(lines[i][1 .. 2], { 15, 15 }) then
			lines[i][1] = OP_PRINT
		elsif lines[i][1] = 15 then
			lines[i][1] = OP_PRINT_NL
			lines[i] &= ' '
		end if
		
		i += 1
	end while
	
	return lines
end function

procedure execute(sequence program)
	integer fp = 1
	
	while fp <= length(program) do
		sequence cmd = program[fp]
		
		integer op = cmd[1], a = cmd[2] + 1, b = cmd[3] + 1

		switch op do
			case OP_HALT then
				return
			
			case OP_GOTO then
				if register[b] != 0 then
					fp = register[a] + 1
					continue
				end if
				
			case OP_SET then
				register[a] = b - 1
				
			case OP_ADD then
				register[a] += b - 1
				
			case OP_MUL then
				register[a] *= b - 1
				
			case OP_SET_FROM_REG then
				register[a] = register[b]
	
			case OP_ADD_FROM_REG then
				register[a] += register[b]
	
			case OP_MUL_FROM_REG then
				register[a] *= register[b]
	
			case OP_FROM_RAM then
				register[a] = ram[register[b] + 1]
				
			case OP_TO_RAM then
				ram[register[b] + 1] = register[a]

			case OP_PRINT_NL then
				? register[a]
				
			case OP_PRINT then
				writef("[] ", register[b])
				
			case else
				printf(2, "***ERROR*** Invalid instruction %d on line %d\n", { cmd[1], fp })
				abort(1)
		end switch
		
		fp += 1
	end while
end procedure

sequence cmds = command_line()
if length(cmds) != 3 then
	printf(1, "Usage: %s program-file\n", { cmds[2] })
end if

execute(parse(cmds[3]))
