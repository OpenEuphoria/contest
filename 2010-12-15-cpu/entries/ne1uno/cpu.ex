/*remove comment for contest run
ne1uno update 12/14 removed unneeded

 certain cpu machine code interpreter
 openeuphoria eu4 2nd Contest 
 Deadline is 7PM EST December 15th 2010.  

 token counter not ignoring comments?

 no way to turn on/off type_check from commandline?
to be fair for all entries, add without type_check
uncomment 'without warning' or use -W none  if interpreted

without warning
without type_check
*/
include std/io.e

sequence
	reg = repeat(0, 10),
	ram = { -1 } & repeat(0, 999),
	lines = command_line(),
	lc

lines = read_lines(lines[3])

integer c = 1, a, m, n

loop do
	lc = lines[c]
	if lc[1] = '?' then
		a = 10
		if lc[2] = '?' then
			a += 1
			n = lc[3] - 47
		else
			m = lc[2] - 47
		end if
	else
		a = lc[1] - 48
		m = lc[2] - 47
		n = lc[3] - 47
	end if
	switch a do
		case 11 then printf(1, "%d ", reg[n])
		case 10 then printf(1, "%d\n", reg[m])
		case 2 then reg[m] = n - 1
		case 5 then reg[m] = reg[n]
		case 3 then reg[m] += n - 1
		case 9 then ram[reg[n] + 1] = reg[m]
		case 8 then reg[m] = ram[reg[n] + 1]
		case 6 then reg[m] += reg[n]
		case 4 then reg[m] *= n - 1
		case 0 then
			if reg[n] then
				if reg[m] then
					c = reg[m] + 1
					continue
				end if
			end if
		case 7 then reg[m] *= reg[n]
		case 1 then exit
	end switch
	c += 1
	until c > length(lines)
end loop
