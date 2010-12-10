-- User: cklester
-- ? points

-- point count:
-- +1 (per spec)
-- +1 (Eu4.0)
-- +1 (clever 1x1 solution)
-- +1 (clever 2x2 solution)
-- +1 (features:option to scale digit '1' or not)
-- +1 (features:option to clear screen)
-- +? (Eu4.0 constructs)
-- +? (Eu4.0 std lib methods)

-- lcdc.ex
-- LCD on the Console program

include std/get.e
include std/console.e
include std/io.e
include std/graphics.e

include euphoric.e

object
	width = "3",
	TEMP
	
integer
	trim_ones = 0,
	verbose = 0,
	SCRN_WIDTH = 79

-- clear_screen()

procedure show_help()
	puts(1,`
usage: eui lcd.ex # [-w SCALE] [-1] [-v] [-s] [-c]
where # is a number
SCALE is an optional scaling parameter indicating width of characters
-1 is optional parameter to not expand width of digit 1
-v is optional parameter to display extra information
-s is optional parameter to clear the screen first
-c is optional parameter to use GREEN for LCD color`

	)
end procedure

procedure main()
sequence
	comline = command_line(),
	number,
	digits

integer
	too_big,
	show_help_txt = 0,
	colorize = 0,
	i = find("-h",comline)
	
	if i then
		show_help_txt = 1
		comline = remove(comline,i)
	end if
	
-- I know I should have used std/cmdline.e, but I don't know how, yet.

	i = find("-w",comline)
	if i then
		width = comline[i+1]
		comline = comline[1..i-1] & comline[i+2..$]
	end if
	
	i = find("-s",comline)
	if i then
		clear_screen()
		comline = remove(comline,i)
	end if

	i = find("-c",comline)
	if i then
		colorize = 1
		comline = remove(comline,i)
	end if
	
	i = find("-1",comline)
	if i then
		trim_ones = 1
		comline = remove(comline,i)
	end if
	
	i = find("-v",comline)
	if i then
		verbose = 1
		comline = remove(comline,i)
	end if
	
	if length(comline) = 2 then -- provide a default number
		comline &= { "1234567890" }
		show_help_txt = 1		-- shows help just in case
	end if

	TEMP = value( width )
	width = TEMP[2]
	
	if length(comline) > 3 or width < 1 then
		puts(1,"Error on command line.\n")
		show_help()
		abort(0)
	end if
	
	number = comline[$]
	
	digits = lcd(number,width,trim_ones)

	if verbose then
		puts(1,number)
		printf(1," (scale: %dx%d)\n",digits[2..3])
	end if

	too_big = length(digits[1][1]) > SCRN_WIDTH
	if too_big then
		for t=1 to length( digits[1] ) do
			digits[1][t] = digits[1][t][1..SCRN_WIDTH]
		end for
	end if

	if colorize then
		text_color(BRIGHT_GREEN)
	end if
	
	if digits[2] = 1 then
		for t=1 to length(digits[1][1]) do
			text_color( digits[1][1][t] )
			puts(1,"-")
		end for
	else
		write_lines( 1, digits[1] )
	end if
	text_color(WHITE)
	
	-- it would be easy to just print the remaining LCD characters
	-- on subsequent lines, but that's for another time or somebody else. :)	
	if too_big then
		text_color(RED)
		puts(1,"\n\nNumber was too big to display completely.")
		text_color(WHITE)
	end if

	if show_help_txt then
		puts(1,"\n\n")
		show_help()
	end if
end procedure

main()

-- if you run this from your editor,
-- it will display an example and show help
-- it will pause so as to not flash away :)
puts(1,"\n\n")
cursor(NO_CURSOR)
maybe_any_key( "*** Press any key to quit. ***" )
cursor(UNDERLINE_CURSOR)

-- there's a bug on the commandline processing:
-- try this: eui lcdc 1234567890 -s -c
-- then
-- try this: eui lcdc 1234567890 -c -s
-- they should do the same thing
-- but the second one doesn't clear the screen! WHY?!!?
