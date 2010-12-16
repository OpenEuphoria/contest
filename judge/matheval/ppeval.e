-- PPEVAL.E 
-- version 2.00 2008.07.14
-- Matt Lewis matthewwalkerlewis@yahoo.com
-- Pretty Print routines for matheval.
--

--/topic PPeval Changes
--/parent Changes
--/info
--
--/code
-- Version 2.00
-- * Updated to work with Euphoria v4.0
--
-- Version 1.12
-- * Remove parenthesis from RHS of /SetEqual
-- * Added /pp_source()
-- * Multiply and Add are smarter about parenthesis, and look better
-- * Fixed bug for polynomial where negative sign on first printed
--   coefficient was dropped
--
-- Version 1.11
-- * Trig functions don't add an extra set of parenthesis.
-- * Fixed tolerance bug for negative constants.
--
-- Version 1.1
-- * Minor changes to spacing for readability.
--/endcode

include matheval.e as m
include std/text.e
include std/pretty.e

global sequence PPEXP
atom tol
tol = m:GetTol()
PPEXP = repeat( 0, 50)

integer ADD, SUBTRACT, MULTIPLY, CONSTANT, EXPONENT, INVALID, DIVIDE,
    SETEQUAL, FLOOR, SIN, COS, TAN, FACTORIAL, VAR, POLYNOMIAL, EQUALS,
    DATA, SQRT


function PPConstant( sequence a, sequence b )
    atom x
    
    x = remainder( a[1], 1)

    if tol and x then
        if x > 0 then
            if x < tol then
                a[1] -= x
            elsif 1-x < tol then
                a[1] += 1-x
            end if
        else
            if -x < tol then
                a[1] -= x
            elsif 1+x < tol then
                a[1] -= 1+x
            end if
        
        end if
    end if
    
    return sprint( a[1] )
end function

function PPAdd( sequence a, sequence b )
	integer ix
	a = call_func( PPEXP[a[m:FUNC]], {a[m:ARG1], a[m:ARG2]} ) 
	b = call_func( PPEXP[b[m:FUNC]], {b[m:ARG1], b[m:ARG2]})
	if a[1] = '(' then
		a = a[2..length(a)-1]
	end if
	
	if b[1] = '(' then
		b = b[2..length(b)-1]
	end if

	ix = 1
	while ix < length(b) and b[ix] = 32 do
		ix += 1
	end while
	
	if b[ix] = '-' then
		b = b[ix..length(b)]
		
		if b[2] != 32 then
			b = b[1] & 32 & b[2..length(b)]
		end if
		return "(" & a & 32 & b & ")"
	end if
    return "(" & a & " + " & b & ")"
end function

function PPSubtract( sequence a, sequence b )
    return "(" & call_func( PPEXP[a[m:FUNC]], {a[m:ARG1], a[m:ARG2]} ) & " - " &
        call_func( PPEXP[b[m:FUNC]], {b[m:ARG1], b[m:ARG2]}) & ")"
end function

function PPMultiply( sequence a, sequence b )
	integer len
	a = call_func( PPEXP[a[m:FUNC]], a[ARG1..ARG2] )
	b = call_func( PPEXP[b[m:FUNC]], b[ARG1..ARG2])
	
	len = length(a)
	if match("((", a) = 1 and equal(a[len-1..len], "))") then
		a = a[2..len-1]
	end if
	
	len = length(b)
	if find("((", b) = 1 and equal(b[len-1..len], "))") then
		b = b[2..len-1]
	end if
		
	if a[1] = '(' and b[1] = '(' then
		return '(' & a & 32 & b & ')'
	else
		return "(" & a & " * " & b & ")"	
	end if
    
end function

function PPData( sequence a, sequence b )
    return "{" & pretty_sprint( a ) & "}"
end function

function PPDivide( sequence a, sequence b )
    return "(" & call_func( PPEXP[a[m:FUNC]], {a[m:ARG1], a[m:ARG2]} ) & " / " &
        call_func( PPEXP[b[m:FUNC]], {b[m:ARG1], b[m:ARG2]}) & ")"
end function

function PPExponent( sequence a, sequence b )
    return "(" & call_func( PPEXP[a[m:FUNC]], {a[m:ARG1], a[m:ARG2]} ) & "^" &
        call_func( PPEXP[b[m:FUNC]], {b[m:ARG1], b[m:ARG2]}) & ")"
end function

function PPPolynomial( sequence a, sequence b )
    sequence p, sign
    p = "("
    for i = length(b) to 1 by -1 do
        if b[i] then
        -- This term is non-zero
            if b[i] > 0 then
                sign = " + "
            else
                sign = " - "
            end if
            
            if i > 1 then
                
                if length(p) > 1 or find('-', sign) then
                    p &= sign
                end if
                
                if b[i] < 0 then
                    b[i] = -b[i]
                end if
                
                if b[i] = 1 then
                    p &= a
                else
                    p &= sprint(b[i]) & a
                end if
                
                if i > 2 then
                    p &= "^" & sprint(i-1)
                end if
                
            else
                
                if b[i] < 0 then
                    b[i] = -b[i]
                end if
                
                p &= sign & sprint(b[i])
                
            end if
        end if
    end for
    return p & ")"
end function

function PPVar( sequence a, sequence b )
    sequence x
    if not b[1] then
        return "0"
    else
        if b[1] = 1 then
            return a
        else
            return sprint(b[1]) & a
        end if
    end if
end function

function PPInvalid( sequence a, sequence b)
    return "(" & a & ")"
end function


function PPSetEqual( sequence a, sequence b)
	b = call_func( PPEXP[b[m:FUNC]], b[ARG1..ARG2] )
	if b[1] = '(' then
		b = b[2..length(b)-1]
	end if
    return call_func( PPEXP[a[m:FUNC]], {a[m:ARG1], a[m:ARG2]}) & " := " & b
end function


function trigpp( sequence a, sequence f )
	a = call_func( PPEXP[a[m:FUNC]], {a[m:ARG1], a[m:ARG2]})
	if find('(', a) = 1 then
		return f & a
	end if
    return f & "(" & a & ")"
end function

function PPSin( sequence a, sequence b )
	return trigpp( a, "sin" )
--	b = call_func( PPEXP[a[m:FUNC]], {a[m:ARG1], a[m:ARG2]})
--	if find('(', b) = 1 then
--		return "cos" & b
--	end if
--    return "sin(" & b & ")"
--    return "sin(" & call_func( PPEXP[a[m:FUNC]], {a[m:ARG1], a[m:ARG2]}) & ")"
end function

function PPCos( sequence a, sequence b )
	return trigpp( a, "cos" )
	
--	b = call_func( PPEXP[a[m:FUNC]], {a[m:ARG1], a[m:ARG2]})
--	if find('(', b) = 1 then
--		return "cos" & b
--	end if
--    return "cos(" & b & ")"
end function

function PPTan( sequence a, sequence b )
	return trigpp( a, "tan" )
--    return "tan(" & call_func( PPEXP[a[m:FUNC]], {a[m:ARG1], a[m:ARG2]}) & ")"
end function

function PPSqrt( sequence a, sequence b )
	return trigpp( a, "sqrt" )
--    return "tan(" & call_func( PPEXP[a[m:FUNC]], {a[m:ARG1], a[m:ARG2]}) & ")"
end function

function PPFactorial( sequence a, sequence b )
    return call_func( PPEXP[a[m:FUNC]], { a[m:ARG1], a[m:ARG2]} ) & "!"
end function

function PPFloor( sequence a, sequence b )
    if a[m:FUNC] = CONSTANT then
        return "floor(" & call_func( PPEXP[a[m:FUNC]], {a[m:ARG1], a[m:ARG2]} ) & ")"
    else    
        return "floor" & call_func( PPEXP[a[m:FUNC]], {a[m:ARG1], a[m:ARG2]} ) 
    end if
end function

--/topic Expressions
--/const PPExp( expression )
--/desc Pretty Print
--/ret String representation of a matheval sequence

global function PPExp( sequence f )
    sequence x
    atom i
    tol = m:GetTol()
    x = call_func(PPEXP[f[m:FUNC]], { f[m:ARG1], f[m:ARG2] } )
    
    -- We take out the last level of parenthesis, since they're never
    -- needed for clarity.
    i = match("==", x)
    if i then
        if x[length(x)] = ')' then
            x = x[1..i+2] & x[i+4..length(x)-1]
        end if
        
        if x[1] = '(' then
            x = x[2..i-3] & x[i-1..length(x)]
        end if
        
    elsif x[1] = '(' then
    
        x = x[2..length(x)-1]
    
    end if
    
    return x
end function


global function PPVarDef( sequence var )
    atom ix
    return PPExp( m:GetVar( var ) )
    
end function

procedure add_pp( integer func, integer rid )
    integer x
    
    x = func - length( PPEXP )
    if x > 0 then
        PPEXP &= repeat( 0, x )
    end if
    
    PPEXP[func] = rid
    
end procedure
ADD_PP = routine_id( "add_pp" )

sequence PRETTY_SOURCE = PRETTY_DEFAULT
PRETTY_SOURCE[DISPLAY_ASCII] = 2
PRETTY_SOURCE[LINE_BREAKS] = 0
sequence source
procedure pp_level( sequence expr, integer level )
	sequence str
	
	str = ""
	if m:matheval_seq( expr ) then
		source &= {repeat( '\t', level ) & "{ " & m:get_math_ref( expr[m:FUNC] ) & "," }
		pp_level( expr[m:ARG1], level + 1 )
		source[length(source)] &= ","
		pp_level( expr[m:ARG2], level + 1 )
		source[length(source)] &= "}"
	else

		source &= {repeat( '\t', level ) & pretty_sprint(expr, PRETTY_SOURCE)}
	end if

end procedure

--/topic Expressions
--/func pp_source( sequence expr )
--
--Returns a string representing the matheval expression in source code
--form.  The string will be broken into lines, with each line a separate
--sequence.  Each line will be indented using tabs, so that m:ARG1 and 
--ARG2 have one more tab than the m:FUNC for a matheval sequence:
--/code
--  X + 2 =>
--  { POLYNOMIAL,
--      "X",
--      {2,1}}
--/endcode
global function pp_source( sequence expr )
	source = ""
	pp_level( expr, 0 )
	return source
end function

procedure init_pp()
    ADD = m:resolve_math_ref( "ADD" )
    SUBTRACT = m:resolve_math_ref( "SUBTRACT" )
    MULTIPLY = m:resolve_math_ref( "MULTIPLY" )
    CONSTANT = m:resolve_math_ref( "CONSTANT" )
    EXPONENT = m:resolve_math_ref( "EXPONENT" )
    INVALID = m:resolve_math_ref( "INVALID" )
    DIVIDE = m:resolve_math_ref( "DIVIDE" )
    FLOOR = m:resolve_math_ref( "FLOOR" )
    SIN = m:resolve_math_ref( "SIN" )
    COS = m:resolve_math_ref( "COS" )
    TAN = m:resolve_math_ref( "TAN" )
    SETEQUAL = m:resolve_math_ref( "SETEQUAL" )
    FACTORIAL = m:resolve_math_ref( "FACTORIAL" )
    VAR = m:resolve_math_ref( "VAR" )
    POLYNOMIAL = m:resolve_math_ref( "POLYNOMIAL" )
    DATA = m:resolve_math_ref( "DATA" )
    SQRT = m:resolve_math_ref( "SQRT" )
    
    PPEXP[SUBTRACT] = routine_id( "PPSubtract" )
    PPEXP[MULTIPLY] = routine_id( "PPMultiply" )
    PPEXP[ADD] = routine_id( "PPAdd" )
    PPEXP[DIVIDE] = routine_id( "PPDivide" )
    PPEXP[EXPONENT] = routine_id( "PPExponent" )
    PPEXP[POLYNOMIAL] = routine_id( "PPPolynomial" )
    PPEXP[VAR] = routine_id( "PPVar" )
    PPEXP[INVALID] = routine_id( "PPInvalid" )
--    PPEXP[EQUALS] = routine_id( "PPEquals" )
    PPEXP[SETEQUAL] = routine_id( "PPSetEqual" )
--    PPEXP[DERIVATIVE] = routine_id( "PPDerivative" )
    PPEXP[SIN] = routine_id( "PPSin" )
    PPEXP[COS] = routine_id( "PPCos" )
    PPEXP[TAN] = routine_id( "PPTan" )
    PPEXP[FACTORIAL] = routine_id("PPFactorial")
    PPEXP[FLOOR] = routine_id("PPFloor")
--    PPEXP[GRAPH] = routine_id( "PPGraph" )
    PPEX = routine_id("PPExp")
--    PPEXP[CGRAPH] = routine_id( "PPCGraph" )
    PPEXP[CONSTANT] = routine_id( "PPConstant" )
    PPEXP[DATA] = routine_id( "PPData" )
    PPEXP[SQRT] = routine_id( "PPSqrt" )
end procedure
m:add_math_init( routine_id( "init_pp" ) )

