--
-- LCD Printer
--
-- Speed: 0.022700
--
-- Score: 14
--
-- Bonus Points:
--   (1) followed spec
--   (1) used 4.0
--   (1) optional scaling
--
-- 4.0 features:
--   (1) assign on create
--   (1) default method parameters
--   (1) 0b# syntax
--   (1) ignore return value
--
-- 4.0 methods:
--   (1) iff
--   (1) columnize
--   (1) mapping
--   (1) series
--   (1) to_number
--   (1) map:get
--   (1) cmd_parse
--

include std/cmdline.e
include std/convert.e
include std/map.e
include std/sequence.e
include std/utils.e

constant digits = {
	{0b010,0b101,0b000,0b101,0b010},{0b000,0b001,0b000,0b001,0b000},
	{0b010,0b001,0b010,0b100,0b010},{0b010,0b001,0b010,0b001,0b010},
	{0b000,0b101,0b010,0b001,0b000},{0b010,0b100,0b010,0b001,0b010},
	{0b010,0b100,0b010,0b101,0b010},{0b010,0b001,0b000,0b001,0b000},
	{0b010,0b101,0b010,0b101,0b010},{0b010,0b101,0b010,0b001,0b000}}

procedure print_part(integer ch, integer digit, integer multiplier)
	puts(1, iff(and_bits(digit, 0b100), ch, ' '))
	puts(1, repeat(iff(and_bits(digit, 0b010), ch, ' '), multiplier))
	puts(1, iff(and_bits(digit, 0b001), ch, ' '))
	puts(1, ' ')
end procedure

procedure print_key(integer ch, sequence key, integer mult, integer vert_mult = 1)
	for j = 1 to vert_mult do
		for i = 1 to length(key) do
			print_part(ch, key[i], mult)
		end for
		puts(1, '\n')
	end for
end procedure

procedure print_sequence(sequence nums, integer mult = 2)
	nums = columnize(mapping(nums, series(0, 1, 9), digits))
	print_key('-', nums[1], mult)
	print_key('|', nums[2], mult, mult)
	print_key('-', nums[3], mult)
	print_key('|', nums[4], mult, mult)
	print_key('-', nums[5], mult)
end procedure

constant opts = cmd_parse({{ "w", 0, "set width", { HAS_PARAMETER }}}),
	cmds = map:get(opts, OPT_EXTRAS)

for i = 1 to length(cmds) do
	print_sequence(cmds[i] - '0', to_number(map:get(opts, "w", "2")))
end for
