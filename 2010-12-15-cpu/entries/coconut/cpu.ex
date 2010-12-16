/*

OBJECT: cpu contest
SUBMISSION #: 1
AUTHOR: Jacques Deschênes

** machine codes **
100  halt 
2dn  set register d to n 
3dn  add n to register d 
4dn  multiply d by n 
5ds  set register d to the value of register s 
6ds  add the value of register s to register d 
7ds  multiply register d by the value of register s 
8da  set register d to the value in RAM whose address is in register a 
9sa  set the value in RAM whose address is in register a to that of register s 
0ds  goto the location in register d unless register s contains 0 
?d  print the value of register d with a trailing newline 
??d  print the value of register d with a trailing space 

** machine configuration **

Ram is 1,000 bytes long and should store a Euphoria integer 
Ram, registers and goto are all 0 based index 
Ram address 0 should be initialized in Euphoria to -1. This will enable much easier looping structures and the ability to subtract. 
There is no requirement to handle invalid instructions, registers or ram addresses, it's OK to let the program crash 
??d should print a trailing space 

*/




enum type opcode 
  JNZ=0,    -- jump if not zero 
  HALT,     -- halt execution
  SETI,     -- set register immediate
  ADDI,     -- add register immediate
  MULI,     -- multiply register immediate
  RCPY,     -- copy register
  RADD,     -- add register to register
  RMUL,     -- multiply register to register 
  RLOAD,    -- load register 
  RSTOR,    -- store register 
  PRN=15    -- print 
end type


  
sequence registers=repeat(0,10),
         ram=repeat(0,1_000), 
         program={}
ram[1]=-1
integer pc=0 -- program counter

-- load program
integer fh
sequence cmd_line
object line

cmd_line=command_line()
--if length(cmd_line)<3 then abort(1) end if
fh = open(cmd_line[3],"r")
line=gets(fh)
while sequence(line) do
  if length(line)>=3 then -- every line should be terminate by a new_line character
    program = append(program,line[1..3]-'0')
  end if
  line=gets(fh)
end while
close(fh)

with trace
--execute program
opcode op
integer a, b
--trace(1)
while pc < length(program) do
  op=program[pc+1][1]
  a=program[pc+1][2]
  b=program[pc+1][3]
  pc += 1
  switch op do
    case JNZ then
      if registers[b+1] then pc=registers[a+1] end if
    case HALT then
      exit
    case SETI then
      registers[a+1]=b
    case ADDI then  
      registers[a+1] += b
    case MULI then
      registers[a+1] *= b
    case RCPY then
      registers[a+1]=registers[b+1]
    case RADD then
      registers[a+1] += registers[b+1]
    case RMUL then
      registers[a+1]*= registers[b+1]
    case RLOAD then --? program[pc] & ram[1]
      registers[a+1]=ram[registers[b+1]+1]
    case RSTOR then
      ram[registers[b+1]+1]=registers[a+1]
    case PRN then
      if a=PRN then
        printf(1,"%d ",registers[b+1])
      else
        printf(1,"%d\n",registers[a+1])
      end if     
  end switch
end while
abort(0)




