
include matheval.e as m
include parseval.e as p
include ppeval.e as pp
include std/text.e
include std/get.e

integer CONSTANT, NOW, DATE_TIME, DATA, VAR, INVALID, GET_YEAR, GET_DAY, GET_MONTH, GET_HOUR, 
	GET_MINUTE, GET_SECOND, GET_DATE, GET_TIME,  EQUALTO, GREATER, LESS,
	GOE, LOE, NOTEQUAL

sequence date_order, date_part, NULL

function Now( sequence a, sequence b )
	sequence d
	d = date()
	d[1] += 1900

	return {DATA, d[1..6], {}}
end function

function is_eu_date_time( object o )
	if atom(o) then
		return 0
	elsif length(o) != 6 then
		return 0
	else
		for i = 1 to 6 do
			if not integer(o[i]) then
				return 0
			end if
		end for
		return 1
	end if
end function

constant DIGITS = "01234556789", WHITE_SPACE = " \t\n\r"
function text_to_date_time( sequence text )
	sequence date_time, v
	integer ix, jx, dx, len, ws
	
	date_time = repeat( 0, 6 )
	if not length(text) then
		return date_time
	end if
	
	ix = 1
	jx = 0
	dx = 1
	len = length(text)
	
	while ix <= len do
		ws = find( text[ix], WHITE_SPACE )
		if not ws then
			exit
		end if
		ix += 1
	end while
	
	jx = ix
	while ix <= len do
		while ix <= len and find( text[ix], DIGITS )do
			ix += 1
		end while
		date_time[dx] = text[jx..ix-1]
		dx += 1
		
		while ix <= len and not find( text[ix], DIGITS ) do
			ix += 1
		end while
		jx = ix
	end while
	
	for i = 1 to 6 do
		if atom(date_time[i]) then
			exit
		end if
		v = value( date_time[i] )
		date_time[i] = v[2]
	end for
	
	return date_time
end function

function Date_Time( sequence a, sequence b )
	if matheval_seq( a ) then
		a = m:call_op( a )
		if a[m:FUNC] = DATA then
			a = text_to_date_time( a[m:ARG1] )
			
		end if
	end if
	return m:eval_addons( DATA, a, b )
end function

function GetDatePart( sequence a, sequence b )
	integer ix
	ix = b[1]
	
	a = m:call_op( a )
	if a[m:FUNC] = DATA and is_eu_date_time( a[m:ARG1] ) then
		return {CONSTANT, {a[m:ARG1][ix]}, {} }
	elsif a[m:FUNC] = DATA and equal( a[m:ARG1], {} ) then
		return {CONSTANT, {0}, {} }
	end if
	
	return m:eval_addons( date_order[ix], a, b )
end function

function Get_Date( sequence a, sequence b )
	a = m:call_op( a )
	if a[m:FUNC] = DATA and is_eu_date_time( a[m:ARG1] ) then
		a[m:ARG1][4..$] = 0
		return a
	elsif equal( a, NULL ) then
		return { DATA, repeat( 0, 6 ), "" }		
	end if
	return m:eval_addons( GET_DATE, a, b )
end function

function Get_Time( sequence a, sequence b )
	a = m:call_op( a )
	if a[m:FUNC] = DATA and is_eu_date_time( a[m:ARG1] ) then
		a[m:ARG1][1..3] = 0
		return a
	elsif equal( a, NULL) then
		return { DATA, repeat( 0, 6 ), "" }
	end if
	return m:eval_addons( GET_TIME, a, b )
end function

function Compare_Dates( integer op, sequence a, sequence b )
	integer c, a_d, b_d

	if a[m:FUNC] = DATA and is_eu_date_time( a[m:ARG1] ) then
		a_d = 1
	else
		a_d = 0
	end if
	
	if b[m:FUNC] = DATA and is_eu_date_time( b[m:ARG1] ) then
		b_d = 1
	else
		b_d = 0
	end if
	
	if a_d and b_d then

		c = compare( a[m:ARG1], b[m:ARG1] )
		if op = EQUALTO then
			return { CONSTANT, { c = 0 }, {} }
		elsif op = GREATER then
			return { CONSTANT, { c = 1 }, {} }
		elsif op = LESS then
			return { CONSTANT, { c = -1 }, {} }
		elsif op = GOE then
			return { CONSTANT, { c >= 0 }, {} }
		elsif op = LOE then
			return { CONSTANT, { c <= 0 }, {} }
		elsif op = NOTEQUAL then
			return { CONSTANT, { c != 0 }, {} }
		end if
	
	elsif a_d and equal( b, NULL) 
	or b_d and equal( a, NULL) then
		return ZERO
	end if

	return { op, a, b }
end function


function CGet_Date( sequence expr, atom tok )
	integer ix, func

	func = expr[tok][m:FUNC]
	ix = find( func, date_order )
    if tok = length(expr) then
        return {{ INVALID, "'GET_DATE' missing argument",{}}}
    elsif CheckCollapsed( {expr[tok+1]} ) then
        
        return expr[1..tok-1] & {{func, expr[tok+1], {ix}}} & 
                expr[tok+2..length(expr)]
    else
        return SyntaxError( GET_DATE )
    end if
end function

function CGet_Time( sequence expr, atom tok )
	integer ix, func

	func = expr[tok][m:FUNC]
	ix = find( func, date_order )
    if tok = length(expr) then
        return {{ INVALID, "'GET_TIME' missing argument",{}}}
    elsif CheckCollapsed( {expr[tok+1]} ) then
        
        return expr[1..tok-1] & {{func, expr[tok+1], {ix}}} & 
                expr[tok+2..length(expr)]
    else
        return SyntaxError( GET_TIME )
    end if
end function

function CGetDatePart( sequence expr, atom tok )
	integer ix, func
	func = expr[tok][m:FUNC]
	ix = find( func, date_order )
    if tok = length(expr) then
        return {{ INVALID, sprintf("'%s' missing argument", {date_part[ix]} ),{}}}
    elsif CheckCollapsed( {expr[tok+1]} ) then
        
        return expr[1..tok-1] & {{func, expr[tok+1], {ix}}} & 
                expr[tok+2..length(expr)]
    else
        return SyntaxError( date_part[ix] )
    end if
end function

function PPGetDatePart( sequence a, sequence b )
	integer ix
	ix = b[1]
	return upper( date_part[ix] ) & "( " & call_func(pp:PPEXP[a[m:FUNC]], a[2..3] ) & " )"
end function

function CNow( sequence expr, atom tok )
	return expr
end function


function CDate_Time( sequence expr, atom tok )

    if tok = length(expr) then
        return {{ INVALID, "'date_time' missing argument",{}}}
    elsif CheckCollapsed( {expr[tok+1]} ) then
        
        return expr[1..tok-1] & {{DATE_TIME, expr[tok+1], {}}} & 
                expr[tok+2..length(expr)]
    else
        return SyntaxError( "date_time" )
    end if
end function

function PPNow( sequence a, sequence b )
	return "NOW()"
end function

function PPDate_Time( sequence a, sequence b )
	return "DATE_TIME( " & call_func(pp:PPEXP[a[m:FUNC]], a[2..3] ) & " )"
end function

function PPGet_Date( sequence a, sequence b )
	return "GET_DATE( " & call_func(pp:PPEXP[a[m:FUNC]], a[2..3] ) & " )"
end function

function PPGet_Time( sequence a, sequence b )
	return "GET_TIME( " & call_func(pp:PPEXP[a[m:FUNC]], a[2..3] ) & " )"
end function

procedure date_init()
	CONSTANT = m:resolve_math_ref( "CONSTANT" )
	DATA = m:resolve_math_ref( "DATA" )
	INVALID = m:resolve_math_ref( "INVALID" )
	EQUALTO = m:resolve_math_ref( "EQUALTO" )
	GREATER = m:resolve_math_ref( "GREATER" )
	LESS = m:resolve_math_ref( "LESS" )
	GOE = m:resolve_math_ref( "GOE" )
	LOE = m:resolve_math_ref( "LOE" )
	NOTEQUAL = m:resolve_math_ref( "NOTEQUAL" )
	NULL = {DATA, "", "" }
	add_to_func( EQUALTO, routine_id("Compare_Dates") )
	add_to_func( GREATER, routine_id("Compare_Dates") )
	add_to_func( LESS, routine_id("Compare_Dates") )
	add_to_func( GOE, routine_id("Compare_Dates") )
	add_to_func( LOE, routine_id("Compare_Dates") )
	add_to_func( NOTEQUAL, routine_id("Compare_Dates") )
	
	NOW = m:reg_math_func( "NOW", routine_id("Now"))
	DATE_TIME = m:reg_math_func( "DATE_TIME", routine_id("Date_Time"))
	GET_YEAR = m:reg_math_func( "GET_YEAR", routine_id("GetDatePart"))
	GET_MONTH = m:reg_math_func( "GET_MONTH", routine_id("GetDatePart"))
	GET_DAY = m:reg_math_func( "GET_DAY", routine_id("GetDatePart"))
	GET_HOUR = m:reg_math_func( "GET_HOUR", routine_id("GetDatePart"))
	GET_MINUTE = m:reg_math_func( "GET_MINUTE", routine_id("GetDatePart"))
	GET_SECOND = m:reg_math_func( "GET_SECOND", routine_id("GetDatePart"))
	GET_DATE = m:reg_math_func( "GET_DATE", routine_id("Get_Date"))
	GET_TIME = m:reg_math_func( "GET_TIME", routine_id("Get_Time"))
	
	m:pretty_print( NOW, routine_id("PPNow"))
	m:pretty_print( DATE_TIME, routine_id("PPDate_Time"))
	m:pretty_print( GET_YEAR, routine_id("PPGetDatePart"))
	m:pretty_print( GET_MONTH, routine_id("PPGetDatePart"))
	m:pretty_print( GET_DAY, routine_id("PPGetDatePart"))
	m:pretty_print( GET_HOUR, routine_id("PPGetDatePart"))
	m:pretty_print( GET_MINUTE, routine_id("PPGetDatePart"))
	m:pretty_print( GET_SECOND, routine_id("PPGetDatePart"))
	m:pretty_print( GET_DATE, routine_id("PPGet_Date"))
	m:pretty_print( GET_TIME, routine_id("PPGet_Time"))
	
	p:reg_parse_func( "NOW", "NOW", routine_id("CNow"), 0,  1 )
	p:reg_parse_func( "DATE_TIME", "DATE_TIME", routine_id("CDate_Time"), 1,  1 )
	p:reg_parse_func( "GET_YEAR", "GET_YEAR", routine_id("CGetDatePart"), 1,  1 )
	p:reg_parse_func( "GET_MONTH", "GET_MONTH", routine_id("CGetDatePart"), 1,  1 )
	p:reg_parse_func( "GET_DAY", "GET_DAY", routine_id("CGetDatePart"), 1,  1 )
	p:reg_parse_func( "GET_HOUR", "GET_HOUR", routine_id("CGetDatePart"), 1,  1 )
	p:reg_parse_func( "GET_MINUTE", "GET_MINUTE", routine_id("CGetDatePart"), 1,  1 )
	p:reg_parse_func( "GET_SECOND", "GET_SECOND", routine_id("CGetDatePart"), 1,  1 )
	p:reg_parse_func( "GET_TIME", "GET_TIME", routine_id("CGet_Time"), 1,  1 )
	p:reg_parse_func( "GET_DATE", "GET_DATE", routine_id("CGet_Date"), 1,  1 )
	set_simplify( NOW, 0 )
	

	
	date_order = { GET_YEAR, GET_MONTH, GET_DAY, GET_HOUR, GET_MINUTE, GET_SECOND }
	date_part = { "get_year", "get_month", "get_day", "get_hour", "get_minute", "get_second" }
end procedure
m:add_math_init( routine_id("date_init") )
