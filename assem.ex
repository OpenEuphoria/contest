-- cpu assembler

include std/io.e
include std/map.e
include std/cmdline.e
include std/console.e
include std/text.e
include std/search.e
include std/sequence.e

constant cmd_opts = {
	{0,0,0,0,0}
	}
	
object opts

opts = cmd_parse(cmd_opts)

object progtext = {}
object progfiles = map:get(opts, EXTRAS)
constant RegStart = "Rr"
constant Digits   = "0123456789"

sequence operands
object labloc
sequence machcode = {}
integer j
integer p


for i = 1 to length( progfiles ) do
	progtext &= io:read_lines(progfiles[i])
end for

-- Remove all excess white space, blank lines and comments.
j = 1
while j <= length(progtext) do
	progtext[j] = match_replace("\t", progtext[j],  " ")
	progtext[j] = trim(progtext[j])
	p = find(';', progtext[j])
	if p then
		progtext[j] = trim(progtext[j][1 .. p-1])
	end if
	if length(progtext[j]) = 0 then
		progtext = remove(progtext, j, j)
	else
		j += 1
	end if
end while

-- Build label index
object labels = map:new()
j = 1
while j <= length(progtext) do
	p = find(':', progtext[j])
	if p then
		sequence curlabel
		curlabel = trim(progtext[j][1 .. p-1])
		if length(curlabel) > 0 then
			progtext[j] = trim(progtext[j][p+1 .. $])
			map:put(labels, curlabel, j-1)
			if length(progtext[j]) = 0 then
				progtext = remove(progtext, j, j)
			else
				j += 1
			end if
		else
			j += 1
		end if
	else
		j += 1
	end if
end while

-- display (progtext)
-- display (map:pairs(labels))
	
procedure bad_code(sequence mesg, sequence oper, sequence operands)
	printf(2, "ERROR: %s (%s %s)\n", {mesg, oper, operands})
	abort(1)
end procedure

procedure adjust_label_locs(integer delta, integer startpos)
	sequence keys
	sequence vals
	
	if delta = 0 then
		return
	end if
	
	keys = map:keys(labels)
	vals = map:values(labels)
	
	for i = 1 to length(keys) do
		if vals[i] > startpos then
			vals[i] += delta
			map:put(labels, keys[i], vals[i])
		end if
	end for
-- display ("DEBUG adjusted labels")
-- display (map:pairs(labels))
		
end procedure

procedure load_label_loc(sequence operands)
	integer labloc
	integer adjloc
	
	machcode &= '2'
	machcode &= operands[1][2]
	labloc = map:get(labels, operands[2], -1)
	if labloc = -1 then
		bad_code("Unknown label in second operand", "set", progtext[j])
	end if
	adjloc = floor(labloc / 9)
	adjust_label_locs(adjloc, j)
	if j < labloc then
		labloc += adjloc
	end if
	progtext[j] &= sprintf( " (%d)", labloc)
	while labloc > 9 do
		machcode &= "9\n"
		labloc -= 9
		machcode &= '3'
		machcode &= operands[1][2]
	end while
	machcode &= sprintf("%d", labloc)
end procedure

j = 1
while j <= length(progtext) do
	sequence oper
	
	p = find(' ', progtext[j])
	if p then
		oper = progtext[j][1 .. p-1]
		progtext[j] = trim(progtext[j][p+1 .. $])
	else
		oper = progtext[j]
		progtext[j] = ""
	end if
	
	switch oper do
		case "add" then
			operands = stdseq:split(progtext[j], ',')
			if length(operands) < 2 or length(operands) > 3 then
				bad_code("requires two or three operands", oper, progtext[j])
			end if
			for i = 1 to length(operands) do
				operands[i] = trim(operands[i])
			end for
			
			if length(operands[1]) = 2 then
				if not find(operands[1][1], RegStart) then
					bad_code("expecting a Register in first operand", oper, progtext[j])
				end if
			else
				bad_code("Illegal first operand length", oper, progtext[j])
			end if
			
			if length(operands) = 2 then
				
				if length(operands[2]) = 2 then
					if find(operands[2][1], RegStart) then
						machcode &= '6'
						machcode &= operands[1][2]
						machcode &= operands[2][2]
					else
						bad_code("expecting a Register in second operand", oper, progtext[j])
					end if
				elsif length(operands[2]) = 1 then
					if find(operands[2][1], Digits) then
						machcode &= '3'
						machcode &= operands[1][2]
						machcode &= operands[2][1]
					else
						bad_code("expecting a digit in second operand", oper, progtext[j])
					end if
				else
					bad_code("Illegal second operand length", oper, progtext[j])
				end if
			else
			end if			
		
		case "set" then
			integer adjloc

			operands = stdseq:split(progtext[j], ',')
			if length(operands) != 2 then
				bad_code("requires two operands", oper, progtext[j])
			end if
			for i = 1 to length(operands) do
				operands[i] = trim(operands[i])
			end for
			
			if length(operands[1]) = 2 then
				if not find(operands[1][1], RegStart) then
					bad_code("expecting a Register in first operand", oper, progtext[j])
				end if
				
				if length(operands[2]) = 2 then
					if find(operands[2][1], RegStart) then
						machcode &= '5'
						machcode &= operands[1][2]
						machcode &= operands[2][2]
					else
						load_label_loc(operands)
						
					end if
				elsif length(operands[2]) = 1 then
					if find(operands[2][1], Digits) then
						machcode &= '2'
						machcode &= operands[1][2]
						machcode &= operands[2][1]
					else
						bad_code("expecting a digit in second operand", oper, progtext[j])
					end if
					
				elsif length(operands[2]) = 4 then
					if operands[2][1] = '[' and 
					   operands[2][4] = ']' and 
					   find(operands[2][2], RegStart) 
					then
						machcode &= '8'
						machcode &= operands[1][2]
						machcode &= operands[2][3]
					else
						load_label_loc(operands)
						
					end if
				elsif length(operands[2]) > 0 then
					load_label_loc(operands)
				else
					bad_code("Illegal second operand length", oper, progtext[j])
				end if
				
				
			elsif length(operands[1]) = 4 then
				machcode &= '9'
				if operands[1][1] = '[' and 
				   operands[1][4] = ']' and 
				   find(operands[1][2], RegStart) 
				then
					machcode &= operands[1][3]
				end if
				
				if not find(operands[2][1], RegStart) then
					bad_code("expecting a Register in second operand", oper, progtext[j])
				end if
				machcode &= operands[2][2]
				
			else
				bad_code("Illegal first operand length", oper, progtext[j])
			end if
		
		case "jmpz" then
			operands = stdseq:split(progtext[j], ',')
			if length(operands) != 2 then
				bad_code("requires two operands", oper, progtext[j])
			end if
			for i = 1 to length(operands) do
				operands[i] = trim(operands[i])
			end for
			machcode &= '0'
			if length(operands[1]) = 2 then
				if find(operands[1][1], RegStart) then
					machcode &= operands[1][2]
				else
					bad_code("expecting a Register in first operand", oper, progtext[j])
				end if
			else
				bad_code("Illegal first operand length", oper, progtext[j])
			end if
			
			if length(operands[2]) = 2 then
				if find(operands[2][1], RegStart) then
					machcode &= operands[2][2]
				else
					bad_code("expecting a Register in second operand", oper, progtext[j])
				end if
			else
				bad_code("Illegal second operand length", oper, progtext[j])
			end if
			
			
		case "mul" then
			operands = stdseq:split(progtext[j], ',')
			if length(operands) < 2 or length(operands) > 3 then
				bad_code("requires two or three operands", oper, progtext[j])
			end if
			for i = 1 to length(operands) do
				operands[i] = trim(operands[i])
			end for
			
			if length(operands[1]) = 2 then
				if not find(operands[1][1], RegStart) then
					bad_code("expecting a Register in first operand", oper, progtext[j])
				end if
			else
				bad_code("Illegal first operand length", oper, progtext[j])
			end if
			
			if length(operands) = 2 then
				
				if length(operands[2]) = 2 then
					if find(operands[2][1], RegStart) then
						machcode &= '7'
						machcode &= operands[1][2]
						machcode &= operands[2][2]
					else
						bad_code("expecting a Register in second operand", oper, progtext[j])
					end if
				elsif length(operands[2]) = 1 then
					if find(operands[2][1], Digits) then
						machcode &= '4'
						machcode &= operands[1][2]
						machcode &= operands[2][1]
					else
						bad_code("expecting a digit in second operand", oper, progtext[j])
					end if
				else
					bad_code("Illegal second operand length", oper, progtext[j])
				end if
			else
			end if			
		
		
		case "outl" then
			if length(progtext[j]) = 2 then
				if find(progtext[j][1], RegStart) then
					machcode &= '?'
					machcode &= progtext[j][2]
				else
					bad_code("expecting a Register", oper, progtext[j])
				end if
			else
				bad_code("Illegal operand length", oper, progtext[j])
			end if
			
		case "outs" then
			if length(progtext[j]) = 2 then
				if find(progtext[j][1], RegStart) then
					machcode &= "??"
					machcode &= progtext[j][2]
				else
					bad_code("expecting a Register", oper, progtext[j])
				end if
			else
				bad_code("Illegal operand length", oper, progtext[j])
			end if
			
		
		case "nop" then
			machcode &= "300"
			
		case "halt" then
			machcode &= "100"
			
		case else
			printf(1, "Unknown operation '%s'\n ", {oper})
			abort(1)
	end switch
	
	machcode &= sprintf("\t\t; %s\t%s\n", {oper, progtext[j]})
	j += 1
end while

puts(1, machcode)