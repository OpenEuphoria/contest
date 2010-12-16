--a certain computer - updated to remove 'advanced' features!

include std/io.e
include std/get.e
include std/console.e

/*
Contest defs

Program instructions
100 	halt
2dn 	set register d to n
3dn 	add n to register d
4dn 	multiply d by n
5ds 	set register d to the value of register s
6ds 	add the value of register s to register d
7ds 	multiply register d by the value of register s
8da 	set register d to the value in RAM whose address is in register a
9sa 	set the value in RAM whose address is in register a to that of register s
0ds 	goto the location in register d unless register s contains 0
?d 	print the value of register d with a trailing newline
??d 	print the value of register d with a trailing space

10 registers, 0 based
1000 memory locations, 0 based, 
RAM address 0 initialised to -1

program not held in emulator RAM (as far as I can tell), 

*/


--global ram and register - makes it easier
sequence RAM = repeat(0, 1_000)
RAM[1] = -1
sequence REG = repeat(0, 10)
integer COUNTER,                        --program counter
        ADDR                            --ram address
object  PROGRAM                        --the certain computer program

integer DEBUG = 0

--program structure
--load certain computer program into a seqence
--each line contains an instruction, and any comments
--start running it (!)

-------------------------------------------------------------------------------------
global function strtoval(object str)
-------------------------------------------------------------------------------------
sequence conv
atom val

--safeguard, if a real value is passed
if atom(str) then return str end if

conv = value(str)
if conv[1] = GET_SUCCESS then
    val = conv[2]
else val = 0
end if

return val
end function


--------------------------------------------------------
procedure certain_program_crash()
--------------------------------------------------------
puts(1, "A machine level exception has occured. I might tell you where one day.")
abort(0)
end procedure


--------------------------------------------------------
procedure debug_cpu()
--------------------------------------------------------

if DEBUG = 0 then return end if

clear_screen()
position(1,1)

for i = 0 to 9 do
        printf(1, "%d %d\n", {i, REG[i+1]})
end for

printf(1, "%-5d %s\n\n", {COUNTER-1, PROGRAM[COUNTER]})         --zero based line?

any_key()

end procedure


--------------------------------------------------------
procedure pd(sequence instruction)
--?d 	print the value of register d with a trailing newline
--??d 	print the value of register d with a trailing space
--------------------------------------------------------
integer d

if instruction[2] = '?' then
        d = strtoval(instruction[3..$])
        if d < 10 then
                printf(1, "%d ", {REG[d+1]})
        end if
else
        d = strtoval(instruction[2..2])
        printf(1, "%d\n", {REG[d+1]})
end if


end procedure

--------------------------------------------------------
procedure _0ds(sequence instruction)
--0ds 	goto the location in register d unless register s contains 0
--------------------------------------------------------
integer d,s

d = strtoval(instruction[2..2])
s = strtoval(instruction[3..3])    

if d > 9 or s > 9 then
        certain_program_crash()
end if

if REG[s+1] != 0 then
        COUNTER = REG[d+1]
end if

end procedure

--------------------------------------------------------
procedure _9sa(sequence instruction)
--9sa 	set the value in RAM whose address is in register a to that of register s
--------------------------------------------------------
integer s,a

s = strtoval(instruction[2..2])
a = strtoval(instruction[3..3])    

if s > 9 or a > 9 then
        certain_program_crash()
end if

if integer(REG[s+1]) then
        RAM[REG[a+1] + 1] = REG[s+1]
else
        puts(1, "Oops, not a certain computer integer type!")                
        abort(0)       
end if


end procedure

--------------------------------------------------------
procedure _8da(sequence instruction)
--8da 	set register d to the value in RAM whose address is in register a
--------------------------------------------------------
integer d,a

d = strtoval(instruction[2..2])
a = strtoval(instruction[3..3])   

if d > 9 or a > 9 then
        certain_program_crash()
end if

REG[d+1] = RAM[REG[a+1] + 1]

end procedure

--------------------------------------------------------
procedure _7ds(sequence instruction)
--7ds 	multiply register d by the value of register s
--------------------------------------------------------
integer d,s

d = strtoval(instruction[2..2])
s = strtoval(instruction[3..3])    

if d > 9 or s > 9 then
        certain_program_crash()
end if

REG[d+1] = REG[d+1] * REG[s+1]

end procedure


--------------------------------------------------------
procedure _6ds(sequence instruction)
--6ds 	add the value of register s to register d
--------------------------------------------------------
integer d,s

d = strtoval(instruction[2..2])
s = strtoval(instruction[3..3])    

if d > 9 or s > 9 then
        certain_program_crash()
end if

REG[d+1] += REG[s+1]

end procedure

--------------------------------------------------------
procedure _5ds(sequence instruction)
--5ds 	set register d to the value of register s
--------------------------------------------------------
integer d,s

d = strtoval(instruction[2..2])
s = strtoval(instruction[3..3])    

if d > 9 or s > 9 then
        certain_program_crash()
end if

REG[d+1] = REG[s+1]

end procedure

--------------------------------------------------------
procedure _4dn(sequence instruction)
--4dn 	multiply d by n, and leave the result in reg d
--------------------------------------------------------
integer d, n

d = strtoval(instruction[2..2])
n = strtoval(instruction[3..3])   

if d > 9 then
        certain_program_crash()
end if

REG[d+1] = REG[d+1] * n

end procedure

--------------------------------------------------------
procedure _3dn(sequence instruction)
--------------------------------------------------------
integer d, n

d = strtoval(instruction[2..2])
n = strtoval(instruction[3..3])    

if d > 9 then
        certain_program_crash()
end if

REG[d+1] += n

end procedure

--------------------------------------------------------
procedure _2dn(sequence instruction)
--2dn set register d to n
--------------------------------------------------------
integer d, n

d = strtoval(instruction[2..2])
n = strtoval(instruction[3..3])    

if d > 9 then
        certain_program_crash()
end if

REG[d+1] = n                    --remmember sequences are 1 based, the reg is 0 based
        
end procedure

--------------------------------------------------------
procedure run_program()
--------------------------------------------------------

COUNTER = 1

while 1 do
        debug_cpu()
        if length(PROGRAM[COUNTER]) > 0 then 
                switch PROGRAM[COUNTER][1] do
                        case '1' then
                                --puts(1, "Halted\n")
                                return
                        case '2' then
                                --2dn set register d to n
                                _2dn(PROGRAM[COUNTER])
                        case '3' then
                                --3dn add n to register d
                                _3dn(PROGRAM[COUNTER])
                        case '4' then
                                --4dn 	multiply d by n
                                _4dn(PROGRAM[COUNTER])
                        case '5' then
                                --5ds 	set register d to the value of register s
                                _5ds(PROGRAM[COUNTER])
                        case '6' then
                                --6ds 	add the value of register s to register d
                                _6ds(PROGRAM[COUNTER])
                        case '7' then
                                --7ds 	multiply register d by the value of register s
                                _7ds(PROGRAM[COUNTER])
                        case '8' then
                                --8da 	set register d to the value in RAM whose address is in register a
                                _8da(PROGRAM[COUNTER])
                        case '9' then
                                --9sa 	set the value in RAM whose address is in register a to that of register s
                                _9sa(PROGRAM[COUNTER])
                        case '0' then
                                --0ds 	goto the location in register d unless register s contains 0
                                _0ds(PROGRAM[COUNTER])
                        case '?' then
                                --?d 	print the value of register d with a trailing newline
                                --??d 	print the value of register d with a trailing space
                                pd(PROGRAM[COUNTER])
                end switch
        end if

        COUNTER += 1 
        if COUNTER > length(PROGRAM) then
                puts(1, "\n\ngone past end!\n")
                exit
        end if


end while

end procedure

--------------------------------------------------------
procedure main()
--------------------------------------------------------
sequence cmdLine = command_line()

--get program name
if length(cmdLine) < 3 then
        puts(1, "No certain computer program!\n")
        return
end if

for i =1 to length(cmdLine) do
        if match(cmdLine[i], "-d") then
                DEBUG = 1
        end if
end for

PROGRAM = read_lines(cmdLine[$])
if not sequence(PROGRAM) then
        puts(1, "No program to run!\n")
        return
end if       

--now have our program, start running it
run_program()

end procedure
main()
