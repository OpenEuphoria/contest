------------------------------------------
-- heber_cpu.ex 
-- by heber 
-- 14/12/2010
--
-- A certain computer emulator
--
-- usage:
--      eui heber_cpu.ex basics.cpu
------------------------------------------
include std/io.e

sequence cmd = command_line()
-- handy new function does all the file handling for me :-)
sequence source= read_lines(cmd[$])
sequence registers = repeat(0,10)
sequence ram = {-1} & repeat(0,999)

integer lines=0


loop with entry do

        -- the lines are substracted 48 to convert ascii characters to integers
	-- this is ok since we now that no instruction number will be bigger than 9. The "xyz"
	-- is added so that the program wont crash with empty lines
	-- a side efect to this is that empty lines can be used instead of
	-- nop instructions
	sequence func = source[lines]-48 & "xyz"

	-- func_two and func_three are precalculated so it should be faster
	-- it also reduces token count. Would have precalculated registers[func_two+1]
	-- and registers[func_three+1] but there is no easy way as sometimes a instruction is 
	-- only 2 numbers (?d) and sometimes the second value is bigger than 9 (??d)...
	-- it causes overflow problems
	-- the solution would probably aument token count
	integer func_two=func[2]
	integer func_three=func[3]

	switch func[1] do
		-- no need to check the other numbers because its just 
		-- a halt function and takes no parameters		
		case 1 then
			exit
		-- the registers are cero based so they need to be added one to be 
		-- compatible with euphoria sequences
		case 2 then
			registers[func_two+1]=func_three
		case 3 then
			registers[func_two+1]+=func_three
		case 4 then
			registers[func_two+1]*=func_three
		case 5 then
		       registers[func_two+1]=registers[func_three+1]	
		case 6 then
			registers[func_two+1]+=registers[func_three+1]
		case 7 then
			registers[func_two+1]*=registers[func_three+1]
		-- the registers are cero based so they are added one... 
		-- but the ram is also cero based so the values in the registers
		-- need to be added one to convert to euphoria sequences	
		case 8 then 
			registers[func_two+1]=ram[registers[func_three+1]+1]
		case 9 then
			ram[registers[func_three+1]+1]=registers[func_two+1]
			
		case 0 then 
			-- the lines and registers
			-- are added one... no need to explain again
			if registers[func_three+1] then
				lines=registers[func_two+1]
			end if
		case 15 then
			-- if the seccond intruction number is 15 just add a space
			-- otherwise add a newline.
			-- The ? sign is 15 because we substracted 48 above
			if func_two=15 then
				printf(1,"%d ",registers[func_three+1])
			else    printf(1,"%d\n",registers[func_two+1])
			end if
		-- if a function number isnt recognized it just ignores it
		case else 
	end switch
	entry
	 lines+=1
until lines >  length(source) end loop

