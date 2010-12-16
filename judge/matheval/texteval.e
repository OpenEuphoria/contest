
include matheval.e as m
include parseval.e as p
include ppeval.e as pp
include symeval.e as s
include booleval.e as b

include std/wildcard.e
include std/text.e
include std/get.e

integer LEFT, RIGHT, MID, CONCAT, LEN, STR, VAL, UPPER, LOWER

integer INVALID, CONSTANT, DATA, VAR


--/topic Text Operations
--/const UPPER
--
--Converts to upper case.
function Upper( sequence a, sequence b )
    a = m:call_op( a )
    if a[FUNC] != DATA then
        return eval_addons( UPPER, a, b )
    end if

    return {DATA, upper(a[ARG1]), {}}
end function

--/topic Text Operations
--/const LOWER
--
--Converts to lower case.
function Lower( sequence a, sequence b )
    a = m:call_op( a )
    if a[FUNC] != DATA then
        return eval_addons( LOWER, a, b )
    end if

    return {DATA, lower(a[ARG1]), {}}
end function

--/topic Text Operations
--/info
--Manipulating strings
--
--By including texteval.e, you can access string manipulation functions.

--/topic Text Operations
--/const STR
--
--Converts a CONSTANT to a DATA string:
--/code
-- {CONSTANT, {1}, {}} ->  {DATA, "1", {}}
--/endcode


function Str( sequence a, sequence b )
    a = m:call_op( a )
    if a[FUNC] != CONSTANT then
        return eval_addons( STR, a, b )
    end if

    return {DATA, sprint(a[ARG1][1]), {}}
end function

--/topic Text Operations
--/const VAL
--
--Converts a DATA string to a CONSTANT:
--/code
-- {DATA, "1", {}} -> {CONSTANT, {1}, {}}
--/endcode

function Val( sequence a, sequence b )
    a = m:call_op(a)

    if not find(a[FUNC], {DATA,CONSTANT}) then
        return eval_addons( VAL, a, b )
    end if

    if a[FUNC] = CONSTANT then
        return a
    end if
    b = value(a[ARG1])

    return { CONSTANT, {b[2]}, {}}
end function

--/topic Text Operations
--/const LEFT( data, chars )
--
--Returns the first /i chars elements of /i data
--
--/code
--  LEFT("1234567", 4 )  -> "1234"
--/endcode

function Left( sequence a, sequence b )
    sequence x
    integer left
    x = GetArgs( a, b )
    a = x[1]
    b = x[2]
    
    if a[FUNC] = DATA and b[FUNC] = CONSTANT then
        left = b[ARG1][1]
        if length(a[ARG1]) < left then
            return {INVALID, sprintf("Error in LEFT: ARG2 = %d, length only %d", {left, length(a[ARG1])}),{}}
        end if
        a[ARG1] = a[ARG1][1..left]
        return a
    end if
    return eval_addons( LEFT, a, b )
end function

--/topic Text Operations
--/const RIGHT( data, chars )
--
--Returns the last /i chars elements of /i data
--
--/code
--  RIGHT("1234567", 4 )  -> "4567"
--/endcode
function Right( sequence a, sequence b )
    sequence x
    integer right, len
    x = GetArgs( a, b )
    a = x[1]
    b = x[2]
    
    if a[FUNC] = DATA and b[FUNC] = CONSTANT then
        right = b[ARG1][1]
        len = length(a[ARG1])
        if len < right then
            return {INVALID, sprintf("Error in RIGHT: ARG2 = %d, length only %d", {right, len}),{}}
        end if
        right -= 1
        a[ARG1] = a[ARG1][len-right..len]
        return a
    end if
    return eval_addons( RIGHT, a, b )
end function

--/topic Text Operations
--/const MID( data, start, chars )
--
--Returns /i chars elements of /i data starting with element /i start.
--
--/code
--  MID("1234567", 3, 2 )  -> "34"
--/endcode
function Mid( sequence a, sequence b )
    sequence x
    integer str_start, str_len, len
    
    a = m:call_op( a )
    
    for i = 1 to 2 do
        b[i] = m:call_op( b[i] )
    end for

    if a[FUNC] = DATA and b[1][FUNC] = CONSTANT and b[2][FUNC] = CONSTANT then
        str_start = b[1][ARG1][1]
        str_len = b[2][ARG1][1] - 1
        x = a[ARG1]
        len = length(x)
        if str_start > len then
            return {{INVALID, sprintf("Error in MID: start value of %d > length of string (%d)",{str_start,len}),{}}}
        elsif str_len + str_start > len then
            return {{INVALID, sprintf("Error in MID: end of string (%d) < end value (%d)",{len,str_len+str_start}),{}}}
        elsif str_len < -1 then
            return {{INVALID, "Error in MID: negative string length",{}}}
        end if

        a[ARG1] = x[str_start..str_start+str_len]
        return a
    end if
    
    return eval_addons( MID, a, b )
end function

--/topic Text Operations
--/const LEN( data )
--
--Returns the length of data.
--
--/code
--  LENFT("1234567")  -> 7
--/endcode

function Len( sequence a, sequence b )

    a = m:call_op( a )

    if a[FUNC] = DATA then
        return {CONSTANT, {length(a[ARG1])}, {}}
    end if

    return eval_addons( LEN, a, b )
end function

--/topic Text Operations
--/const &
--
--Concatenates strings:
--/code
--  "1234" & "5678" ->  "12345678"
--/endcode

function Concat( sequence a, sequence b )
    sequence x

    x = GetArgs( a, b )
    a = x[1]
    b = x[2]
    
    if a[FUNC] = DATA and b[FUNC] = DATA then
        a[ARG1] &= b[ARG1]
        return a
    end if

    return eval_addons( CONCAT, a, b )
end function

function CUpper( sequence expr, integer tok )
    if tok = length( expr ) then
        return {{INVALID, "Missing argument for UPPER()", {}}}
    end if

    expr[tok][ARG1] = expr[tok+1]
    return expr[1..tok] & expr[tok+2..length(expr)] 
end function

function CLower( sequence expr, integer tok )
    if tok = length( expr ) then
        return {{INVALID, "Missing argument for LOWER()", {}}}
    end if

    expr[tok][ARG1] = expr[tok+1]
    return expr[1..tok] & expr[tok+2..length(expr)] 
end function

function CStr( sequence expr, integer tok )
    if tok = length( expr ) or (not CheckCollapsed({expr[tok+1]}))  then
        return {{INVALID, "Missing argument for STR()", {}}}
    end if

    expr[tok][ARG1] = expr[tok+1]
    return expr[1..tok] & expr[tok+2..length(expr)] 
end function

function CVal( sequence expr, integer tok )
    if tok = length( expr ) then
        return {{INVALID, "Missing argument for VAL()", {}}}
    end if

    expr[tok][ARG1] = expr[tok+1]
    return expr[1..tok] & expr[tok+2..length(expr)] 
end function

function CLeft( sequence expr, integer tok )
    sequence data
    integer args

    if tok = length(expr) or not find( expr[tok+1][m:FUNC], { DATA, VAR }) then
        return { {INVALID, "Missing arguments for LEFT()", {}}}
    end if
    
    data = expr[tok+1]
    args = m:is_compound( data )
    if not args then
        return { {INVALID, "Missing arguments for LEFT()",{}}}
    elsif args = 1 then
        return {{INVALID, "Missing string length for LEFT()",{}}}
    elsif args > 2 then
        return {{INVALID, "Too many arguments for LEFT()",{}}}
    end if
    
    expr[tok] = {LEFT, data[m:ARG1][1], data[m:ARG1][2]}
    
    return expr[1..tok] & expr[tok+2..length(expr)]
end function

function CRight( sequence expr, integer tok )
    sequence data
    integer args

    if tok = length(expr) or expr[tok+1][m:FUNC] != DATA then
        return { {INVALID, "Missing arguments for RIGHT()", {}}}
    end if
    
    data = expr[tok+1]
    args = m:is_compound( data )
    if not args then
        return { {INVALID, "Missing arguments for RIGHT()",{}}}
    elsif args = 1 then
        return {{INVALID, "Missing string length for RIGHT()",{}}}
    elsif args > 2 then
        return {{INVALID, "Too many arguments for RIGHT()",{}}}
    end if
    
    expr[tok] = {RIGHT, data[m:ARG1][1], data[m:ARG1][2]}
    
    return expr[1..tok] & expr[tok+2..length(expr)]
end function

function CMid( sequence expr, integer tok )
    sequence data
    integer args

    if tok = length(expr) or expr[tok+1][m:FUNC] != DATA then
        return { {INVALID, "Missing arguments for MID()", {}}}
    end if
    
    data = expr[tok+1]
    args = m:is_compound( data )
    if not args then
        return { {INVALID, "Missing arguments for MID()",{}}}
    elsif args = 1 then
        return {{INVALID, "Missing string start and length for MID()",{}}}
    elsif args = 2 then
        return {{INVALID, "Missing string length for MID()",{}}}
    elsif args > 3 then
        return {{INVALID, "Too many arguments for MID()",{}}}
    end if
    
    expr[tok] = {MID, data[m:ARG1][1], data[m:ARG1][2..3]}
    
    return expr[1..tok] & expr[tok+2..length(expr)]
end function

function CLen( sequence expr, integer tok )

    if tok = length(expr) then
        return {{INVALID, "Missing RHS for LEN()",{}}}
    end if


    if CheckCollapsed( {expr[tok+1]} ) then
        if not find(expr[tok+1][FUNC], {DATA, VAR}) then
            return {{INVALID, "RHS of LEN() must be either Variable or Literal String",{}}}
        end if
        expr[tok] = {LEN, expr[tok+1], {}}
        return expr[1..tok] & expr[tok+2..length(expr)]
    end if
    return SyntaxError( "LEN" )
end function

function CConcat( sequence expr, integer tok )

    if tok = 1 then
        return {{INVALID, "Missing RHS for &", {}}}
    elsif tok = length(expr) then
        return {{INVALID, "Missing LHS for &", {}}}
    end if

    expr[tok] = { CONCAT, expr[tok-1], expr[tok+1] }
    return expr[1..tok-2] & {expr[tok]} & expr[tok+2..length(expr)]

end function

function PPUpper( sequence a, sequence b )
    return sprintf("UPPER( %s )", {call_func( pp:PPEXP[a[m:FUNC]], a[m:ARG1..m:ARG2])})
end function

function PPLower( sequence a, sequence b )
    return sprintf("LOWER( %s )", {call_func( pp:PPEXP[a[m:FUNC]], a[m:ARG1..m:ARG2])})
end function

function PPStr( sequence a, sequence b )
    return sprintf("STR( %s )", {call_func( pp:PPEXP[a[m:FUNC]], a[m:ARG1..m:ARG2])})
end function

function PPVal( sequence a, sequence b )
    return sprintf("VAL( %s )", {call_func( pp:PPEXP[a[m:FUNC]], a[m:ARG1..m:ARG2])})
end function

function PPLeft( sequence a, sequence b )
    return sprintf("LEFT( %s, %s)", {call_func( pp:PPEXP[a[m:FUNC]], a[m:ARG1..m:ARG2]),
        call_func( pp:PPEXP[b[m:FUNC]], b[m:ARG1..m:ARG2])})
end function

function PPRight( sequence a, sequence b )
    return sprintf("RIGHT( %s, %s)", {call_func( pp:PPEXP[a[m:FUNC]], a[m:ARG1..m:ARG2]),
        call_func( pp:PPEXP[b[m:FUNC]], b[m:ARG1..m:ARG2])})
end function

function PPMid( sequence a, sequence b )
    return sprintf("MID( %s, %s, %s)", {call_func( pp:PPEXP[a[m:FUNC]], a[m:ARG1..m:ARG2]),
        call_func( pp:PPEXP[b[1][m:FUNC]], b[1][m:ARG1..m:ARG2]),
        call_func( pp:PPEXP[b[2][m:FUNC]], b[2][m:ARG1..m:ARG2])})
end function

function PPLen( sequence a, sequence b )
    return sprintf("LEN( %s )", {call_func( pp:PPEXP[a[m:FUNC]], a[m:ARG1..m:ARG2])})
end function

function PPConcat( sequence a, sequence b )
    return sprintf(" %s & %s ", {call_func( pp:PPEXP[a[m:FUNC]], a[m:ARG1..m:ARG2]),
        call_func( pp:PPEXP[b[m:FUNC]], b[m:ARG1..m:ARG2])})
end function

procedure text_init()
    CONSTANT = m:resolve_math_ref( "CONSTANT" )
    DATA = m:resolve_math_ref( "DATA" )
    INVALID = m:resolve_math_ref( "INVALID" )
    VAR = m:resolve_math_ref( "VAR" )
	
	UPPER = m:reg_math_func( "UPPER", routine_id("Upper"))
	LOWER = m:reg_math_func( "LOWER", routine_id("Lower"))
    STR = m:reg_math_func( "STR", routine_id("Str"))
    VAL = m:reg_math_func( "VAL", routine_id("Val"))
    LEFT = m:reg_math_func( "LEFT", routine_id("Left"))
    RIGHT = m:reg_math_func( "RIGHT", routine_id("Right"))
    LEN = m:reg_math_func( "LEN", routine_id("Len"))
    MID = m:reg_math_func( "MID", routine_id("Mid"))
    CONCAT = m:reg_math_func( "CONCAT", routine_id("Concat"))
	
	s:set_simplify( UPPER, 0 )
	s:set_simplify( LOWER, 0 )
    s:set_simplify( STR, 0 )
    s:set_simplify( VAL, 0 )
    s:set_simplify( LEFT, 0 )
    s:set_simplify( RIGHT, 0 )
    s:set_simplify( LEN, 0 )
    s:set_simplify( MID, 0 )
    s:set_simplify( CONCAT, 0 )

	p:reg_parse_func( "UPPER", "UPPER", routine_id("CUpper"), 1, 2 )
	p:reg_parse_func( "LOWER", "LOWER", routine_id("CLower"), 1, 2 )
    p:reg_parse_func( "STR", "STR", routine_id("CStr"), 1, 2 )
    p:reg_parse_func( "VAL", "VAL", routine_id("CVal"), 1, 2 )
    p:reg_parse_func( "LEFT", "LEFT", routine_id("CLeft"), 2, 2 )
    p:reg_parse_func( "RIGHT", "RIGHT", routine_id("CRight"), 2, 2 )
    p:reg_parse_func( "LEN", "LEN", routine_id("CLen"), 1, 2 )
    p:reg_parse_func( "MID", "MID", routine_id("CMid"), 2, 2 )
    p:reg_parse_func( "CONCAT", "&", routine_id("CConcat"), 2, 3 )

	m:pretty_print( UPPER, routine_id("PPUpper"))
	m:pretty_print( LOWER, routine_id("PPLower"))
    m:pretty_print( STR, routine_id("PPStr"))
    m:pretty_print( VAL, routine_id("PPVal"))
    m:pretty_print( LEFT, routine_id("PPLeft"))
    m:pretty_print( RIGHT, routine_id("PPRight"))
    m:pretty_print( MID, routine_id("PPMid"))
    m:pretty_print( CONCAT, routine_id("PPConcat"))
    m:pretty_print( LEN, routine_id("PPLen"))
    
end procedure
m:add_math_init( routine_id("text_init") )
