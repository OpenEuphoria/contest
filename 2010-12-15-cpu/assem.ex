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
sequence comments
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
comments = repeat( "", length( progtext ) )

-- Remove all excess white space, blank lines and comments.
j = 1
while j <= length(progtext) do
	progtext[j] = match_replace("\t", progtext[j],  " ")
	progtext[j] = trim(progtext[j])
	p = find(';', progtext[j])
	if p then
		comments[j] = trim( progtext[j][p..$] )
		progtext[j] = trim(progtext[j][1 .. p-1])
	end if
	if length(progtext[j]) = 0 then
		progtext = remove(progtext, j )
		comments = remove(comments, j )
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
				comments = remove(comments, j )
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


-- calculate the number of bits for label fixups
integer 
	fixup_bits_needed  = floor( 2 + log( j ) / log( 2 ) ),
	fixup_instr_needed = (1+fixup_bits_needed) * 2

sequence fixup_string = "2[1]0\n2[2]1\n"
for i = 0 to fixup_bits_needed do
	if i < fixup_bits_needed then
		fixup_string &= "3[1]0\n6[2][2]\n"
	else
		fixup_string &= "3[1]0"
	end if
end for

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
		if vals[i] >= startpos then
			vals[i] += delta
			map:put(labels, keys[i], vals[i])
		end if
	end for
-- display ("DEBUG adjusted labels from [1] by [2]", {startpos, delta})
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

function label_name( integer pc )
	sequence pairs = map:pairs( labels )
	for i = 1 to length( pairs ) do
		if pairs[i][2] = pc then
			return "\tlabel: " & pairs[i][1]
		end if
	end for
	return ""
end function

-- we'll go back and patch these up
sequence label_fixups = {}

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
			
			for i = 1 to length(operands) do
				operands[i] = trim(operands[i])
			end for
			
			if length( operands ) = 2 then
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
					
					else
						bad_code("Illegal second operand length", oper, progtext[j])
					end if
					
					
				elsif length(operands[1]) = 4 then
					machcode &= '9'
					
					if not find(operands[2][1], RegStart) then
						bad_code("expecting a Register in second operand", oper, progtext[j])
					end if
					machcode &= operands[2][2]
					if operands[1][1] = '[' and 
					operands[1][4] = ']' and 
					find(operands[1][2], RegStart) 
					then
						machcode &= operands[1][3]
					else
						bad_code("Illegal first operand", oper, progtext[j])
					end if
					
					
					
				else
					bad_code("Illegal first operand length", oper, progtext[j])
				end if
			elsif length( operands ) = 3 then
				if not find(operands[1][1], RegStart) then
					bad_code("expecting a Register in first operand", oper, progtext[j])
				end if
				
				if not map:has( labels, operands[2] ) then
					bad_code("expecting a Label in second operand", oper, progtext[j] )
				end if
				
				if not find(operands[3][1], RegStart) then
					bad_code("expecting a Register in third operand", oper, progtext[j])
				end if
				adjust_label_locs( fixup_instr_needed, j )
				label_fixups = append( label_fixups, { length( machcode ) + 1, operands[2], operands[3][2] } )
				machcode &= text:format( fixup_string, { {operands[1][2]}, {operands[3][2]}})
				progtext = splice( progtext, repeat( "", fixup_instr_needed ), j )
				comments = splice( comments, repeat( "", fixup_instr_needed ), j )
				j += fixup_instr_needed
			else
				bad_code("requires two or three operands", oper, progtext[j])
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
	
	machcode &= sprintf("\t\t; %s\t%s%s\t\t%s\n", {oper, progtext[j], label_name( j ), comments[j] })
	j += 1
end while

sequence fixup_epilog = {}
procedure do_label_fixups()
	for i = 1 to length( label_fixups ) do
		
		integer strpos = label_fixups[i][1] + 8
		sequence label_name = label_fixups[i][2]
		integer helper = label_fixups[i][3]
		
		integer loc = map:get( labels, label_fixups[i][2] )
		fixup_epilog &= sprintf("fixup: label %s at %d\n", { label_name, loc } )
		integer bit = 0
		integer sum = 0
		while bit <= fixup_bits_needed do
			if and_bits( loc, power( 2, bit ) ) then
				machcode[strpos] = '6'
				machcode[strpos+2] = helper
				sum += power( 2, bit )
				fixup_epilog &= sprintf("\tadd %d -> %d\n", { power( 2, bit ), sum } )
			end if
			strpos += 8
			bit += 1
		end while
		
	end for
end procedure
do_label_fixups()

puts(1, machcode)
puts(1, "100\n" )
printf(1, "Code size: %d\n,Label Bits: %d (%d)\n", { length( progtext ), fixup_bits_needed, power( 2, fixup_bits_needed )})
puts(1, fixup_epilog )
display (map:pairs(labels))
