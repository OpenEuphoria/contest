-- cpu.ex by Derek Parnell
-- 15/December/2010

-- Notes: 
--  (1) Does not use the standard library (no 'includes')
--  (2) Emphasis on fast execution speed.

constant EOL = {'\n', -1}
constant EOF = -1
constant digits = "0123456789"
enum
	BRNZ = '0',
	HALT,
	SETI,
	ADDI,
	MULI,
	SETR,
	ADDR,
	MULR,
	LOAD,
	STOR,
	OUTP = '?',
	$
constant valid_ops = {
	BRNZ,
	HALT,
	SETI,
	ADDI,
	MULI,
	SETR,
	ADDR,
	MULR,
	LOAD,
	STOR,
	OUTP,
	$}

/* 
	This function will get the program source code from a file, whose name
	is on the command line, and load it in to the code-space. 
	
	The source code is transformed into a faster format for execution.
*/ 
function load_program()
	integer fh
	integer ip
	integer a,b,c
	sequence cmds
	sequence program
	
	-- Initialize the code-space. 
	-- All locations are set to EOF, which is the value returned by getc() when
	-- end-of-file is found. This means that as the program is executing, when it gets
	-- to a point after the last line, it will automatically halt.
	--
	-- The initial size is arbitary, but must be a multiple of three. 
	program = repeat(EOF, 3000) -- Reserve space for a thousand-instruction program.
	
	-- Point to just before the 'first' place in the code-space where the next instruction
	-- will be stored.
	ip = 0
	
	-- Get the command line. Assumes at least one file name is present.
	cmds = command_line()
	
	-- Open the named file. Assume it exists and is readable.
	fh = open(cmds[3], "r")
	
	-- Load the program into the code space, stop when we reach EOF.
	while c != EOF with entry do
	
		-- Test for a valid opcode
		a = find(c, valid_ops) 
		
		if a then
			-- It is valid, so process the rest of the instruction.
			
			-- Point to the next program storage location and store the opcode.
			ip += 1
			program[ip] = c
			
			-- Get the next two byte of the instruction.  Assume it is a valid syntax.
			a = getc(fh)
			b = getc(fh)
			
			-- There is ALWAYS some silly exception and the OUTP instruction is
			-- that exception for this cpu. All other instructions are exactly
			-- three bytes long, but this one can be two or three! Dumb, no?
			
			if c != OUTP then
				/* Good, a standard instruction format ... OPCODE DIGIT DIGIT.
				
				   N.B. We don't store the ASCII value of the digits here, but
				   the real value of the digit plus 1. Thus '0' is stored as 1,
				   '4' as 5, etc ... This is because the CPU uses 0-based indexing
				   but Euphoria uses 1-based so when the instruction refers to
				   Register 0, we need to access regs[1]. We do that conversion 
				   here so we don't have to repeatedly do it during execution
				   of loops.
				   
				   Also note that we assume valid syntax. If the source is invalid
				   it will cause the program to crash with an out-of-bounds error
				   as it will attempt to reference regs[0] or RAM[0] at some point.
				*/ 
				
				-- Store the next digit
				ip += 1
				program[ip] = find(a, digits)
				
				-- Store the next digit
				ip += 1
				program[ip] = find(b, digits)
				
			else
				/* Ok, it's that exception opcode.
				   The format is either OUTP DIGIT or OUTP OUTP DIGIT.
				*/
				
				if a != OUTP then
					-- Second format. This means output is followed by a newline.
					
					-- Store the next digit
					ip += 1
					program[ip] = find(a, digits)
					
					-- Store the output delimiter (newline)
					ip += 1
					program[ip] = '\n'
					
				else
					-- First format. This means output is followed by a space.
					
					-- Store the next digit
					ip += 1
					program[ip] = find(b, digits)
					
					-- Store the output delimiter (space)
					ip += 1
					program[ip] = ' '
				end if
			end if
		else
			b = c	-- Just in case we have an empty line.
		end if
		
		-- Skip over anything else on the same line and get to the next source code line.
		
		-- N.B. We test 'b' here because it is theoretically possible that the previous
		-- instruction was the 'OUTP DIGIT' syntax and thus we have read in the
		-- end-of-line into 'b' for that instruction.
		if b != '\n' then
			-- Scan for the next end-of-line (or end-of-file) marker.
			while not find(getc(fh), EOL) do
			end while
		end if
		
		-- If this is a VERY long program, we need to extend the code space when we
		-- are nearing the end of the current allocation. Again, the amount is
		-- arbitary but needs to be a multiple of three.
		
		if ip > length(program) - 2 then
			program &= repeat(EOF, 3000) -- Add room for another 1000 instructions.
		end if
		
	entry
		-- Get the first byte of an instruction.
		c = getc(fh)

	end while
	
	-- Close the source code file.
	close(fh)
	
	-- Return the entire code space, which now contains the 'machine' code.
	return program[1..ip]
end function

procedure run_cpu(sequence program)
	sequence RAM
	sequence regs
	integer newpc
	integer ip
	integer opcode
	integer opA
	integer opB

	/* Boot the system.
		-- Set all RAM locations to 0 except the first location. That needs to be -1
		-- Set all regisiters to zero.
		-- Set the instruction pointer (ip) to the start of the code space.
	*/
	
	RAM = -1 & repeat(0, 999) -- Exactly 1000 addressable RAM locations, 0 - 999
	regs = {0,0,0,0,0,0,0,0,0,0} -- Exactly ten registers, R0 to R9
	ip = 1
	
	-- Start execution.
	while opcode != EOF with entry do
		
		-- Get the two operands for the current instruction.
		opA = program[ip+1]
		opB = program[ip+2]

		-- Advance the instruction pointer. 
		-- Each intruction is exactly three elements in the code-space.
		ip += 3
		
		-- Execute the current opcode ...
		switch opcode do
		
			case BRNZ then
				-- The value in Reg[B] is non-zero we need to branch somewhere. The
				-- address of the branch target is in Reg[A]. This is a 0-based index
				-- into the code space, in terms of instructions. For example, a
				-- value of 24 means we need to branch to the 24th instruction
				-- in the program. Now as each instruction takes up three elements
				-- in the code space, we need to multiply the Reg[A] value by three
				-- and add 1 to get the Euphoria index into the code space.
				
				if regs[opB] then
					opB = regs[opA]
					-- This seems like a long method of multiplying by 3 but
					-- doing it this way avoids using temporary values which
					-- Euphoria would then need to dereference.
					newpc = opB
					newpc += opB
					newpc += opB
					newpc += 1
					
					-- Set the instruction pointer. Assumes a valid location.
					-- If this is not valid, the program will crash with an
					-- out of bounds error.
					ip = newpc 
				end if
				
			case HALT then
				-- Ignore any operands; just stop.
				exit
				
			case SETI then
				-- The value in B is stored in Reg[A]
				
				opB -= 1 -- Fix up the value (was a 1-based index)
				regs[opA] = opB
				
			case ADDI then
				-- The value in B is added to Reg[A]
				
				opB -= 1 -- Fix up the value (was a 1-based index)
				opB += regs[opA] -- Done this way to avoid dereferencing temporary values.
				regs[opA] = opB
			
			case MULI then
				-- The value in Reg[A] is multiplied by B
				
				opB -= 1 -- Fix up the value (was a 1-based index)
				opB *= regs[opA] -- Done this way to avoid dereferencing temporary values.
				regs[opA] = opB
			
			case SETR then
				-- The value in Reg[B] is stored in Reg[A]
				
				opB = regs[opB] -- Done this way to avoid dereferencing temporary values.
				regs[opA] = opB
			
			case ADDR then
				-- The value in Reg[B] is added to Reg[A]
				
				opB = regs[opB] -- Done this way to avoid dereferencing temporary values.
				opB += regs[opA]
				regs[opA] = opB
			
			case MULR then
				-- The value in Reg[A] is multiplied by Reg[B]
				
				opB = regs[opB] -- Done this way to avoid dereferencing temporary values.
				opB *= regs[opA]
				regs[opA] = opB
			
			case LOAD then
				-- The value of some RAM location is stored in Reg[A]. The RAM
				-- address is in Reg[B].
				
				-- N.B. Assumes a valid RAM address. Will crash if invalid.
				opB = regs[opB] -- Done this way to avoid dereferencing temporary values.
				opB += 1 -- convert to 1-based indexing.
				regs[opA] = RAM[opB]
			
			case STOR then
				-- The value of some RAM location is replaced by Reg[A]. The RAM
				-- address is in Reg[B].
				
				-- N.B. Assumes a valid RAM address. Will crash if invalid.
				opB = regs[opB] -- Done this way to avoid dereferencing temporary values.
				opB += 1 -- convert to 1-based indexing.
				RAM[opB] = regs[opA]
			
			case OUTP then
				-- Outputs the value in Reg[A] to the console. Follows the output
				-- with whatever is in B - either a space or newline.
				
				printf(1, "%d%s", {regs[opA], opB})
				
			case EOF then
				-- We only get here if the program does not have a HALT instruction.
				exit
			
		end switch
	
	entry
		-- Grab the next opcode to execute.
		opcode = program[ip]
		
	end while
end procedure

-- Run the emulator.
run_cpu( load_program() )
