include std/map.e
include std/cmdline.e
include std/console.e
include std/math.e
include std/error.e

constant lcd_digits = `
      --   --        --   --   --   --   --   --  
  |     |    | |  | |    |       | |  | |  | |  | 
  |     |    | |  | |    |       | |  | |  | |  | 
      --   --   --   --   --        --   --       
  |  |       |    |    | |  |    | |  |    | |  | 
  |  |       |    |    | |  |    | |  |    | |  | 
      --   --        --   --        --        --  
`

constant blanks = `
                         
                         
                         
                         
                         
                         
                         
`
constant known_digits = "1234567890"
constant cmd = command_line()
object numbers_in
sequence outlines
integer pos
integer op

constant
	max_in_len = 5,
	lcd_width  = 5,
	lcd_height = 7,
	max_out_len = max_in_len * lcd_width + 1,
	next_lcd_seg = lcd_width * length(known_digits) + 1,
	$	
if length(cmd) < 3 then
	crash("Need at least one set of digits to process!")
end if

numbers_in = cmd[3..$]
for i = 1 to length(numbers_in) label "NUMIN" do
	outlines = blanks
	op = 1
	for j = 1 to math:min({max_in_len, length(numbers_in[i])}) do
		pos = find(numbers_in[i][j], known_digits)
		if not pos then
			continue "NUMIN"
		end if
		pos = (pos - 1) * lcd_width + 1
		for k = 1 to lcd_height do
			outlines[op .. op + lcd_width - 1] = lcd_digits[pos .. pos + lcd_width - 1]
			op += max_out_len
			pos += next_lcd_seg
		end for
		op -= (lcd_height * max_out_len) - lcd_width
	end for
	
	display(outlines)
end for
