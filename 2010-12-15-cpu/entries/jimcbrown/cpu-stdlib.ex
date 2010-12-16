include std/io.e
include std/sequence.e

function hackmore(sequence s, object ignored)
	if s[1] = '?' then
		if s[2] = '?' then
			s[1] = ':'
		else
			s = prepend(s, ';')
		end if
	end if
	s[2] -= '/'
	s[3] -= '/'
	return s
end function

object
i = 1,
register = repeat(0, 10),
ram = -1 & repeat(0, 999),
program = apply(read_lines(fetch(command_line(), {3})), routine_id("hackmore"))
while i <= length(program) do
	sequence t = program[i]
	integer a2 = t[2], a3 = t[3]
	switch t[1] do
		case '0' then
			if register[a3] then
				i = register[a2]
			end if
		case '1' then
			exit
		case '2' then
			register[a2] = a3-1
		case '3' then
			register[a2] += a3-1
		case '4' then
			register[a2] *= a3-1
		case '5' then
			register[a2] = register[a3]
		case '6' then
			register[a2] += register[a3]
		case '7' then
			register[a2] *= register[a3]
		case '8' then
			register[a2] = ram[register[a3]+1]
		case '9' then
			ram[register[a3]+1] = register[a2]
		case ':' then
			writef("[3]", register[a3])
		case ';' then
			? register[a3]
		case else
			program = 1
	end switch
	i += 1
end while
