/*
User: mattlewis

Speed: 0.023325s per iteration

Score: 58

Bonus Points:
	1:  Used Euphoria v4
	1:  Followed spec
	1:  Numbers can be scaled from 1..

4.0 Features:
	$ as end of list marker
	assign on declare
	backtick unescaped quote
	call function declared after point of use
	case fallthru
	declare default parameter value
	declare in middle of block
	declare in smaller scope
	default namespace declared
	delete()
	elsifdef
	enum
	enum type
	head() built-in sequence op
	ifdef
	ignore function return
	labeled loop
	labeled loop exit
	left line padding on unescaped, multiline quote
	multi-line / block comment
	replace() built-in sequence op
	switch / case
	tail() built-in sequence op
	used default namespace
	use default parameter value
	with inline X
	without inline

4.0 Methods:
	cmdline:parse
	console:any_key
	console:display
	convert:int_to_bits
	convert:to_number
	map:get
	map:has
	math:max
	math:or_all
	regex:find_replace
	regex:new
	search:begins
	search:find_all_but
	search:find_any
	search:find_replace
	stdget:value
	stdseq:apply
	stdseq:breakup
	stdseq:columnize
	stdseq:combine
	stdseq:join
	stdseq:series
	stdseq:transmute
	stdseq:vslice
	text:upper
	types:t_digit
	types:t_xdigit
	utils:iff

INFORMATION:
	222:  Lines of code (according to coverage metrics)
	225:  Lines of code including ifdef'd out lines
	  5:  Extra Features!
			Accept Decimal, Hex, Octal, Binary, Floating Point or Scientific Notation
			Print any combination of Decimal, Hex, Octal, Binary, Floating Point, Scientific Notation
			Optional line wrapping
			Optional formatting that uses Underscores instead of minus signs, and shorter characters for easier to read numbers
			Run with "-d JEREMY" for extra fun!
*/

namespace lcd

ifdef MAXIMUM_INLINING then
	with inline 100_000
elsifdef NO_INLINING then
	without inline
end ifdef

include std/cmdline.e
include std/console.e
include std/convert.e
include std/get.e
include std/map.e
include std/math.e
include std/regex.e
include std/search.e
include std/sequence.e
include std/text.e
include std/types.e
include std/utils.e

enum type digits
	ZERO  = 247,
	ONE   = 36,
	TWO   = 93,
	THREE = 109,
	FOUR  = 46,
	FIVE  = 107,
	SIX   = 123,
	SEVEN = 37,
	EIGHT = 255,
	NINE  = 239,
	HEX_A = 125,
	HEX_B = 122,
	HEX_C = 88,
	HEX_D = 124,
	HEX_E = 95,
	HEX_F = 27,
	OCTAL_O = 120,
	HEX_X = 62,
	MINUS = 8,
	DECIMAL_POINT = 16,
	$
end type

sequence DIGITS = repeat( 0, 255 )
DIGITS['0'] = ZERO
DIGITS['1'] = ONE
DIGITS['2'] = TWO
DIGITS['3'] = THREE
DIGITS['4'] = FOUR
DIGITS['5'] = FIVE
DIGITS['6'] = SIX
DIGITS['7'] = SEVEN
DIGITS['8'] = EIGHT
DIGITS['9'] = NINE
DIGITS['a'] = HEX_A
DIGITS['b'] = HEX_B
DIGITS['c'] = HEX_C
DIGITS['d'] = HEX_D
DIGITS['e'] = HEX_E
DIGITS['f'] = HEX_F
DIGITS['o'] = OCTAL_O
DIGITS['x'] = HEX_X
DIGITS['A'] = HEX_A
DIGITS['B'] = HEX_B
DIGITS['C'] = HEX_C
DIGITS['D'] = HEX_D
DIGITS['E'] = HEX_E
DIGITS['F'] = HEX_F
DIGITS['X'] = HEX_X
DIGITS['-'] = MINUS
DIGITS['.'] = DECIMAL_POINT

sequence CHARS = stdseq:series( 1, 1, 256 )

integer horizontal_character = '-'
export procedure main()
	sequence opts = {
						{ 0, "binary", "binary output", { ONCE, NO_PARAMETER } },
						{ 0, "decimal", "decimal output (default)", { ONCE, NO_PARAMETER } },
						{ 0, "float", "floating point", { ONCE, NO_PARAMETER } },
						{ 0, "hex", "hexadecimal output", { ONCE, NO_PARAMETER } },
						{ 0, "octal", "octal output", { ONCE, NO_PARAMETER } },
						{ 0, "pretty", "nicer output using underscores and more compact digits", { ONCE, NO_PARAMETER } },
						{ 0, "scientific", "scientific notation output", { ONCE, NO_PARAMETER } },
						{ "w", 0, "character width (minimum 3)", { ONCE, HAS_PARAMETER, "width" } },
						{ 0, "wrap",  "maximum characters per line", { ONCE, HAS_PARAMETER, "characters" } },
						{ 0,   0, "at least one number must be supplied", { MANDATORY } },
						$
					}
	
	map:map params = cmdline:cmd_parse( 
				opts, 
				{ NO_AT_EXPANSION, HELP_RID, { `
_______________________________Display LCD style numbers!
                               Right on your console!
                               Hex formats:    #123 0x123 (Note: you may need to escape the #-style)
                               Octal formats:  @123 0o123
                               Binary formats: !101 0b101 (Note: you may need to escape the !-style` }})
	
	-- internally, we use the stroke length, not full width
	integer width = math:max( 3 & convert:to_number( map:get( params, "w", "1" ) ) ) - 2
	integer wrap = convert:to_number( map:get( params, "wrap", "0" ) )
	wrap = utils:iff( wrap, math:max( wrap & (width+2)), wrap )
	integer hex            = map:has( params, "hex" )
	integer octal          = map:get( params, "octal" )
	integer binary         = map:get( params, "binary" )
	integer scientific     = map:get( params, "scientific" )
	integer floating_point = map:get( params, "float" )
	integer decimal        = map:has( params, "decimal" ) 
							 or not 
							 math:or_all(hex & octal & binary & scientific & floating_point )
	integer pretty         = map:get( params, "pretty" )
	object numbers         = map:get( params, cmdline:OPT_EXTRAS )
	
	-- we're done with it...free up the memory!
	delete( params )
	
	numbers = stdseq:apply( numbers, routine_id( "lcd:validate" ), { decimal, hex, octal, binary, scientific, floating_point } )
	numbers = stdseq:combine( numbers, stdseq:COMBINE_UNSORTED )
	if atom( numbers ) or find( 0, numbers ) then
		abort( 1 )
	end if
	
	calculate_grid_metrics( width, pretty )
	apply( numbers, routine_id("lcd:display"), { width, wrap } )
	
	ifdef JEREMY then
		-- He LOVES this!
		console:any_key()
	end ifdef
end procedure

enum 
	DECIMAL_RADIX,
	HEX_RADIX,
	OCTAL_RADIX,
	BINARY_RADIX,
	SCIENTIFIC_NOTATION,
	FLOATING_POINT,
	$

public type t_hex( object h )
	if atom( h ) then
		return 0
	end if
	
	if search:begins( "0x", h ) then
		return types:t_xdigit( tail( h, length( h ) - 2 ) )
		
	elsif length(h) and equal( head( h ),  "#") then
		return types:t_xdigit( tail( h ) )
	end if
	
	return 0
end type

function all_octal_chars( sequence c )
	if t_digit( c ) then
		return not search:find_any( "89", c )
	else
		return 0
	end if
end function

type t_octal( object o )
	if atom( o ) then
		return 0
	end if
	
	if search:begins( "0o", o ) then
		return all_octal_chars( tail( o, length( o ) - 2 ) )
	elsif search:begins( "@", o ) then
		return all_octal_chars( tail( o ) )
	else
		return 0
	end if
	
end type

type t_binary( object b )
	if atom( b ) then
		return 0
	end if
	
	if search:begins( "0b", b ) then
		b = tail( b, length(b) - 2 )
		regex:regex binary = regex:new( "1" )
		b = regex:find_replace( binary, b, "0" )
		return not length( search:find_all_but( '0', b ) )
		
	elsif search:begins( "!", b ) then
		b = tail( b )
		b = search:find_replace( '0', b, '1' )
		return not length( search:find_all_but( '1', tail( b ) ) )
	else
		return 0
	end if
end type

type t_number( object n )
	if atom( n ) then
		return 0
	end if
	sequence v = stdget:value( n, 1, GET_LONG_ANSWER )
	if v[1] != GET_SUCCESS then
		return 0
	else
		return v[3] = length( n )
	end if
end type

function validate( sequence data, object radix )
	
	if not (types:t_digit( data ) or t_hex( data ) or t_octal( data ) or t_binary( data ) or t_number( data ) ) then
		console:display( "not digits: [1]", { data } )
		return 0
	end if
	
	sequence numbers = {}
	if search:begins( "0x", data ) then
		data = replace( data, "#", 1, 2 )
		
	elsif search:begins( "0o", data ) then
		data = replace( data, "@", 1, 2 )
		
	elsif search:begins( "0b", data ) then
		data = replace( data, "!", 1, 2 )
		
	end if
	
	data = stdget:value( data )
	atom number = data[2]
	
	if radix[DECIMAL_RADIX] then
		numbers = append( numbers, sprintf( "%d", number ) )
	end if
	
	if radix[HEX_RADIX] then
		numbers = append( numbers, sprintf( "0x%x", number ) )
	end if
	
	if radix[OCTAL_RADIX] then
		numbers = append( numbers, sprintf( "0o%o", number ) )
	end if
	
	if radix[BINARY_RADIX] then
		sequence bits = stdseq:reverse( convert:int_to_bits( number ) )
		bits = tail( bits, math:max( 1 & ( length( bits ) - find( 1, bits ) + 1 ) ) )
		numbers = append( numbers, sprintf( "0b%s", { '0' + bits } ) )
	end if
	
	if radix[SCIENTIFIC_NOTATION] then
		sequence sn = sprintf( "%e", number )
		numbers = append( numbers, search:match_replace( "+", sn, "" ) )
	end if
	
	if radix[FLOATING_POINT] then
		numbers = append( numbers, sprintf( "%f", number ) )
	end if
	
	return numbers
end function

--**
-- Builds the list of digits and outputs to STDOUT.
function display( sequence number, object specs )
	integer lines = specs[1]
	integer wrap  = specs[2]
	sequence digits = repeat( 0, length( number ) )
	
	number = stdseq:transmute( number, CHARS, DIGITS )
	
	for i = 1 to length( number ) do
		digits[i] = draw( number[i], lines )
	end for
	
	if wrap then
		integer wrap_chars = floor( wrap / (lines+2) )
		digits = stdseq:breakup( digits, wrap_chars, BK_LEN )
		
		sequence trans = {}
		sequence blank = repeat(' ', LINES_GRID )
		for i = 1 to length( digits[1] ) do
			trans = append( trans, 
					stdseq:combine( 
						stdseq:vslice( digits, i, { blank } ), 
						COMBINE_UNSORTED ) )
		end for
		digits = trans
	end if
	
	digits = stdseq:columnize( digits )
	
	for j = 1 to length( digits ) do
		console:display( stdseq:join( digits[j]  ) )
	end for
	return 1
end function

enum
	TOP = 0,
	TOP_LEFT,
	TOP_RIGHT,
	MIDDLE,
	BOTTOM_LEFT,
	BOTTOM_RIGHT,
	BOTTOM

integer 
	CHAR_LINE_LENGTH,
	H_LINE_TOP,
	H_LINE_MIDDLE,
	H_LINE_BOTTOM,
	V_LINE_TOP,
	V_LINE_MIDDLE,
	COL_LEFT,
	COL_RIGHT,
	LINES_GRID,
	COLS_GRID,
	$
	

function horizontal( sequence grid, integer y, integer character = horizontal_character )
	grid[y][2..COLS_GRID-1] = character
	return grid
end function

function vertical( sequence grid, integer x, integer y )
	for yy = y to y + CHAR_LINE_LENGTH - 1 do
		grid[yy][x] = '|'
	end for
	return grid
end function

--**
-- Returns a sequence of grid metrics based on the size of the characters.
procedure calculate_grid_metrics( integer size, integer pretty  )
	CHAR_LINE_LENGTH = size
	H_LINE_TOP    = 1
	V_LINE_TOP    = 2
	COL_RIGHT = size + 2
	COL_LEFT  = 1
	COLS_GRID  = size + 2
	
	if pretty then
		horizontal_character = '_'
		H_LINE_MIDDLE = size + 1
		V_LINE_MIDDLE = size + 2
		H_LINE_BOTTOM = size * 2 + 1
		LINES_GRID = size * 2 + 2
	else
		H_LINE_MIDDLE = size + 2
		V_LINE_MIDDLE = size + 3
		H_LINE_BOTTOM = size * 2 + 3
		LINES_GRID = size * 2 + 4
	end if
	
end procedure

--**
-- Draws a character with the specified width
function draw( integer character, integer width )
	
	sequence grid = repeat( repeat( ' ', COLS_GRID + 1 ), LINES_GRID )
	
	for i = 0 to 6 label "bitmask" do
		if and_bits( character, power( 2, i ) ) then
			switch i do
			case TOP then
				grid = horizontal( grid, H_LINE_TOP )
			
			case MIDDLE then
				grid = horizontal( grid, H_LINE_MIDDLE )
			
			case BOTTOM then
				grid = horizontal( grid, H_LINE_BOTTOM )
				
			case TOP_LEFT then
				grid = vertical( grid, COL_LEFT, V_LINE_TOP )
				
			case TOP_RIGHT then
				grid = vertical( grid, COL_RIGHT, V_LINE_TOP )
				
			case BOTTOM_LEFT then
				grid = vertical( grid, COL_LEFT, V_LINE_MIDDLE )
				
			case BOTTOM_RIGHT then
				fallthru -- go to the next one!
			
			case -1 then
				grid = vertical( grid, COL_RIGHT, V_LINE_MIDDLE )
			
			case else
				exit "bitmask"
			end switch
		end if
	end for
	
	return grid
end function



lcd:main()
