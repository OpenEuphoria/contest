--****
-- == CPU Interface
--
-- This program is an example of using the pre-processor now
-- built into Euphoria 4.0. For a more simplistic, direct
-- approach to using the pre-processor, please see cpu-pp-direct.ex
--
-- This version of the program allows you to include CPU (cpi) files
-- directly in Euphoria and call them from your Euphoria application.
--
-- CPU instruction set:
--
-- |=Op  |=Desiption
-- | 100 | halt
-- | 2dn | set register ##d## to ##n##
-- | 3dn | add ##n## to register ##d##
-- | 4dn | multiply register ##d## by ##n##
-- | 5ds | set register ##d## to the value of register ##s##
-- | 6ds | add the value of register ##s## to register ##d##
-- | 7ds | multiply register ##d## by the value of register ##s##
-- | 8da | set register ##d## to the value in RAM whose address is in register ##a##
-- | 9sa | set the value in RAM whose address is in register ##a## to that of register ##s##
-- | 0ds | goto the location in register ##d## unless register ##s## contains 0
-- | ?d  | print the value of register ##d## with a trailing newline
-- | ??d | print the value of register ##d## with a trailing space
--

namespace cpu

include std/stack.e

stack cpu_stk = stack:new()

--****
-- === Registers
--
-- Registers are zero based index, r0 - r9
--
-- r0 is special for this case as it will be used as the
-- return value for all function calls.
--

public integer r0=0, r1=0, r2=0, r3=0, r4=0, r5=0, r6=0, r7=0, r8=0, r9=0

--**
-- === Ram
--
-- Ram on the Euphoria side is 1-1000 but in the CPU files, 0-999. Ram location
-- zero is initialized to -1 to aid in loop structures and to provide subtraction
-- abilities in the CPU scripts. All other ram locations are initialized to zero.
--

public sequence ram = -1 & repeat(0, 999)

--****
-- === CPU State Methods
--

--**
-- Reset the CPU's internal state
--

public procedure reset()
	r0 = 0
	r1 = 0
	r2 = 0
	r3 = 0
	r4 = 0
	r5 = 0
	r6 = 0
	r7 = 0
	r8 = 0
	r9 = 0

	ram = -1 & repeat(0, 999)
end procedure

--**
-- Push the current state of the CPU onto the CPU
-- state stack
--

public procedure push_state()
	stack:push(cpu_stk, { r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, ram })
end procedure

--**
-- Pop the current state of the CPU from the CPU
-- state stack
--

public procedure pop_state()
	sequence state = stack:pop(cpu_stk)

	r0 = state[1]
	r1 = state[2]
	r2 = state[3]
	r3 = state[4]
	r4 = state[5]
	r5 = state[6]
	r6 = state[7]
	r7 = state[8]
	r8 = state[9]
	r9 = state[10]
	ram = state[11]
end procedure
