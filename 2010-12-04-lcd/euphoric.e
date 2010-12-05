-- lcd.e
-- library for turning normal digits into LCD digits

include std/graphics.e
include std/text.e

sequence
	chars,
	digits = {
				" -     -  -     -  - --  -  - ",
				"| |  |  |  || ||  |    || || |",
				"       -  -  -  -  -     -  - ",
				"| |  ||    |  |  || |  || |  |",
				" -     -  -     -  -     -  - "
			},
	-- for scaling below 3 (tricky!):
	-- how do you distinguish the value of 1x1 characters? COLOR! (Still using LCD character)
	colors = {
				BRIGHT_BLUE,	-- starting with 0
				GREEN,
				BRIGHT_CYAN,
				BRIGHT_RED,
				BRIGHT_MAGENTA,
				BROWN,
				BRIGHT_WHITE,
				GRAY,
				YELLOW,
				BRIGHT_GREEN	-- all the way to 9
			},
	-- how do you distinguish the value of 1x1 characters? New symbols! (Still using LCD characters)
	digits2 = { {"| "," -"},{" |"," |"},{"- "," -"},{"-|","-|"},{"--"," |"},{" -","- "},{"| ","|-"},{"-|"," |"},{"--","--"},{"||"," |"} }
			
integer
	charw = 3,
	charh = length(digits)
	
chars = repeat( repeat( repeat( 0, charw ), charh ), 10)

-- this sets up the mapping for the standard 3x5 digits
for t=1 to length(digits) do
integer spot
	for x=1 to 10 do
		spot = (charw*x) - (charw - 1)
		chars[x][t] = digits[t][spot..spot+(charw-1)]
	end for
end for
     
function get_char( integer i, integer x = charw, integer y = charh, integer trim_one = 1 )
sequence char

	if x = charw and y = charh then
		return chars[i+1]
	end if

	switch x do
	 case 1 then
		char = {colors[i+1]}
		
	case 2 then
		char = digits2[ i+1 ]
		
	case else
	
		integer c
	
		char = chars[i+1]
		c = x - charw
		
		-- scale width
		if i = 1 and trim_one then
			c = 0
		end if

		for t=1 to charh do
			char[t] = splice( char[t], repeat( char[t][2], c ), 2 )
		end for
		
		-- scale height
		c = ( y - charh ) / 2
		for t=1 to c do
			char = insert(char,char[2],3)
			char = insert(char,char[$-1],length(char))
		end for
		
	end switch
	
	return char
end function

function add_digit( sequence s, sequence c, integer x = 0, integer y = 0 )
	for h=1 to length(c) do
		s[h] &= c[h]
	end for
	return s
end function

public function lcd( object s, integer sx, integer trim_ones = 0 )
sequence str
integer sy

	-- returns a write_lines()able string of LCD characters
	if atom(s) then
		s = sprint(s)
	end if
	
	sy = floor( ( sx / charw ) * charh ) + 1
	
	if integer(sy/2) then
		sy+=1
-- 		sy-=1 -- try this setting for shorter digits
	end if
	
	if sx = 1 or sx = 2 then
		sy = sx
	end if

	s -= '0'
	str = repeat( {}, sy )
	for t=1 to length(s) do
		str = add_digit( str, get_char( s[t], sx, sy, trim_ones ) )
	end for

	return {str,sx,sy}
end function
