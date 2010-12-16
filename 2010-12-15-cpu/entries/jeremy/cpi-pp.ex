include std/io.e
include std/text.e
include std/filesys.e

integer comment_char = ';' - '0'
sequence
	cmds = command_line(),
	program = read_lines(cmds[4]) - '0',
	func_name = filebase(cmds[4])

sequence core = format(`
include cpu.e

without warning += ( not_reached )

public function [](object r1={}, object r2={}, object r3={}, object r4={}, object r5={})
	integer jump

	if integer(r1) then cpu:r1 = r1 end if
	if integer(r2) then cpu:r2 = r2 end if
	if integer(r3) then cpu:r3 = r3 end if
	if integer(r4) then cpu:r4 = r4 end if
	if integer(r5) then cpu:r5 = r5 end if

	goto "1"
	label "jump"
	switch jump do

`, { func_name })

constant stmts = {
	`label "[1]" 	if cpu:r[3] then jump = cpu:r[2] + 1 goto "jump" end if`,
	`label "[1]" 	return cpu:r0`,
	`label "[1]" 	cpu:r[2] = [3]`,
	`label "[1]" 	cpu:r[2] += [3]`,
	`label "[1]" 	cpu:r[2] *= [3]`,
	`label "[1]" 	cpu:r[2] = cpu:r[3]`,
	`label "[1]" 	cpu:r[2] += cpu:r[3]`,
	`label "[1]" 	cpu:r[2] *= cpu:r[3]`,
	`label "[1]" 	cpu:r[2] = cpu:ram[[]cpu:r[3] + 1]`,
	`label "[1]" 	cpu:ram[[]cpu:r[3] + 1] = cpu:r[2]`,
	`label "[1]" 	printf(1, "%d ", cpu:r[3])`,
	`label "[1]" 	? cpu:r[2]`
}

integer i = 1

while i <= length(program) do
	-- Ignore blank lines and lines that begin with ;
	if length(program[i]) < 3 or program[i][1] = comment_char then
		program = remove(program, i)
		continue
	end if

	object stmt = program[i], op = stmt[1]
	if equal(stmt[1..2], { 15, 15 }) then
		op = 10
	elsif op = 15 then
		op = 11
	end if

	program[i] = format("\t" & stmts[op + 1], i & stmt[2..3])
	core &= format("\t\tcase [1] then goto \"[1]\"\n", i)

	i += 1
end while

core &= `
		case else return cpu:r0
	end switch

	return cpu:r0

`

write_lines(cmds[6], { core } & program & { "\nend function" })
