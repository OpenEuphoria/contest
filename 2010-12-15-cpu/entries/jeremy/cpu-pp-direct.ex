include std/io.e
include std/text.e

sequence core = `
-- individual integer registers for speed
integer jump=0, r0=0, r1=0, r2=0, r3=0, r4=0, r5=0, r6=0, r7=0, r8=0, r9=0
sequence ram = -1 & repeat(0, 999)
goto "1"
label "jump"
switch jump do

`
constant stmts = {
	`label "[1]" 	if r[3] then jump = r[2] + 1 goto "jump" end if`, -- 0ds jnz
	`label "[1]" 	abort(0)`,                                    -- 100 halt
	`label "[1]" 	r[2] = [3]`,                                  -- 2dn set
	`label "[1]" 	r[2] += [3]`,                                 -- 3dn add
	`label "[1]" 	r[2] *= [3]`,                                 -- 4dn mul
	`label "[1]" 	r[2] = r[3]`,                                 -- 5ds setr
	`label "[1]" 	r[2] += r[3]`,                                -- 6ds addr
	`label "[1]" 	r[2] *= r[3]`,                                -- 7ds mulr
	`label "[1]" 	r[2] = ram[[]r[3] + 1]`,                      -- 8da stor
	`label "[1]" 	ram[[]r[3] + 1] = r[2]`,                      -- 9da load
	`label "[1]" 	printf(1, "%d ", r[3])`,                      -- ??r prts
	`label "[1]" 	? r[2]`                                       -- ?r  prtl
}

sequence cmds = command_line(), program = read_lines(cmds[4]) - '0'

for i = 1 to length(program) do
	object stmt = program[i], op = stmt[1] + 1
	if match("", stmt) = 1 then
		op = 11
	elsif op = 16 then
		op = 12
	end if
	program[i] = format(stmts[op], i & stmt[2 .. 3])
	core &= format("\tcase [1] then goto \"[1]\"\n", i)
end for

core &= `
	case else abort(0)
end switch

`
write_lines(cmds[6], { core } & program)
