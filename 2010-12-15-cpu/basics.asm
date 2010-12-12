; Basic tests

	; Each register can be set and read
	set R0, 9
	outl R0
	set R1, 8
	outl R1
	set R2, 7
	outl R2
	set R3, 6
	outl R3
	set R4, 5
	outl R4
	set R5, 4
	outl R5
	set R6, 3
	outl R6
	set R7, 2
	outl R7
	set R8, 1
	outl R8
	set R9, 2
	outl R9

	; Add instruction works
	set R0, 1
	add R0, 4
	outl R0

	; Multiply instruction
	set R0, 2
	mul R0, 9
	outl R0

	; Add two registers
	set R0, 2
	set R1, 2
	add R0, R1
	outl R0

	; Multiply two registers
	set R0, 2
	set R1, 6
	mul R0, R1
	outl R0

	; Setting and getting RAM works
	set R0, 5
	set R1, 1
	set [R0], R1
	set R2, [R1]
	outl R2

	; Ram addess 0 is -1
	set R0, 0
	set R1, [R0]
	outl R1

	; ?? prints "#SPACE"
	set R0, 1
	set R1, 2
	outs R0
	outl R1

	; Goto on zero does not jump
	set R0, zero_jumps_bad
	set R1, 0
	jmpz R0, R1

zero_didnt_jump_good:
	set R0, 3
	outs R0
	outs R0
	outl R0

	; Goto on one does jump
	set R0, one_jumps
	set R1, 1
	jmpz R0, R1

one_didnt_jump_bad:
	set R9, 8
	outs R9
	outs R9
	outl R9
	halt

one_jumps:
	set R0, 3
	outs R0
	outs R0
	outl R0
	halt

zero_jumps_bad:
	set R9, 9
	outl R9
	outl R9
	outl R9
	halt

; vim ts=2, sw=2

