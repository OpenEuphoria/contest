include std/io.e

object
i = 1,
register = repeat(0,999),
ram = -1 & register,
program = command_line()
program = read_lines(program[3])&49
while 1 do
	sequence t = program[i]&"100"
	integer a2 = t[2], r2 = register[a2], r3 = register[t[3]], z3 = t[3]-'0'
	switch t[1] do
		case '0' then
			if r3 then
				i = r2
			end if
		case '1' then
			exit
		case '2' then
			r2 = z3
		case '3' then
			r2 += z3
		case '4' then
			r2 *= z3
		case '5' then
			r2 = r3
		case '6' then
			r2 += r3
		case '7' then
			r2 *= r3
		case '8' then
			r2 = ram[r3+1]
		case '9' then
			ram[r3+1] = r2
		case '?' then
			if a2 = '?' then
				writef("[] ", r3)
			else
				? r2
			end if
	end switch
	register[a2] = r2
	i += 1
end while
