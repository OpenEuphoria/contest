-- parseval.e
-- version 1.15 6/23/03
-- Matt Lewis  matthewwalkerlewis@yahoo.com 
-- http://www14.brinkster.com/matthewlewis
--
-- Parsing routines for matheval.e
--


-- To add a function, make sure it exists in the constant,
-- Functions (the position/value of the function should be then
-- same as in OperationIds found in matheval.e.  The function must then
-- be put into the precedence table.  If it doesn't fit with a given
-- category, it's fine to add a new one.  Tokens are collapsed from
-- 'top' to 'bottom' (as viewed in this file).  Finally, a CFunc must 
-- be added to the file, with the routine_id for the function added
-- to the appropriate slot in ColTok, so the parser knows which function
-- to call.  This is where error checking, to make sure correct arguments
-- have been passed, is done.  See existing functions for details.
-- 

--/topic Parseval Changes
--/parent Changes
--/info
--
--/code
-- Version 2.00
-- * Updated to work with Euphoria v4.0
--
-- Version 1.15
-- * Added parse_simplify() to control whether /Parse() calls /Simplify()
-- * Will multipy RHS of SetEqual if not already done
--
-- Version 1.14
-- * Fixed bug parsing /cos: unary, not binary
-- * Recognizes variables typed in lowercase.
-- * Improved parentheses error checking
--
-- Version 1.13
-- * Added Comma parsing: Turns a list into DATA.
--
-- Version 1.12
-- * Entire expression not converted to uppercase.  Only uppercased when
--   not inside quotes.
--
-- Version 1.11
-- * Added error checking.  If invalid expression, entire expression
--   is returned as invalid.
--
-- Version 1.1
-- * Changed variable handling.  Variables are now allowed to have numbers
--   and underscores in them, but must not start with a number.  Also,
--   variables can now begin with same characters as built in functions.
--/endcode

--/topic Expressions
--/func Parse( sequence string )
--/desc Turns a string into a matheval sequence
--/ret Parsed matheval sequence
-- String is a string such as "X+1", which /Parse will return as a
-- simplified matheval sequence.  After /Parse parses the string,
-- is passes the result to /Simplify.


include std/wildcard.e
include std/get.e
include std/text.e

include matheval.e as m

global sequence UNARY, BINARY, NONARY
UNARY = {}
BINARY = {}
NONARY = {}

integer ADD, SUBTRACT, MULTIPLY, CONSTANT, EXPONENT, INVALID, DIVIDE,
    SETEQUAL, FLOOR, SIN, COS, TAN, FACTORIAL, VAR, LPAR, RPAR, DATA,
    COMMA, SQRT


sequence Functions, Precedence
Functions = {}
Precedence = repeat( {}, 6)

constant  
OTHER = 0,
NUMBER = 1,
LETTER = 2,
PAREN = 3,
WHITESPACE = 4, 
QUOTE = 5

sequence ColTok
ColTok = repeat( 0, length(Functions))

--/topic Extensions
--/proc reg_parse_func( object ref, object func, integer r_id, integer args, integer precedence )
--/info
--
--Matheval needs to be told how to parse a new function or operator.
--This requires that matheval know the reference name (/resolve_math_ref),
--function or operator name, the routine id for the parse function, the
--number of arguments and the precedence.  This is done by calling
--reg_parse_func().  The call for ADD looks like this:
--/code
--reg_parse_func( "ADD", "+", routine_id("CAdd"), 2, 5 )
--/endcode
--The parsing function's job is to 'collapse' the token and
--its arguments into one token, and is responsible for checking
--for errors, such as an incorrect number of arguments being
--supplied (e.g., for "1*2+" CAdd should return an error, since it
--would expect another token after it.
--
--Here is what CAdd() looks like:
--/code
--function CAdd( sequence expr, atom tok )
--    sequence func
--    func = expr[tok]
--    if tok = 1 then
--        return expr[2..length(expr)]
--    elsif tok = length(expr) then
--        return {{ INVALID, "+ Cannot find right arg", {}}}
--    elsif expr[tok+1][m:FUNC] = SUBTRACT then
--        
--        return call_func(ColTok[SUBTRACT], 
--            { expr[1..tok-1] & expr[tok+1..length(expr)], tok})
--    else
--        if CheckCollapsed( {expr[tok-1], expr[tok+1]} ) then
--            func = {func[m:FUNC], expr[tok-1], expr[tok+1] }
--        else
--            return SyntaxError("+")
--        end if
--    end if
--    return expr[1..tok-2] & {func} & expr[tok+2..length(expr)]
--end function
--/endcode
--/b expr is the entire expression being parsed, and /b tok is the index to
--the token that CAdd() needs to parse.  The routine first checks to make
--sure that there are tokens on either side of it. Since "+1" is really valid,
--it is not flagged as an error, but rather ignored.  Errors should be flagged
--by returning the /INVALID token, with m:ARG1 as a description of the error.


global procedure reg_parse_func( object ref, object func, integer r_id,
            integer args, integer precedence )
    integer id, len
    sequence blank
    
    id = m:resolve_math_ref( ref )
    
    len = length(Functions) - m:math_func_count()
    if len < 0 then
        blank = repeat( {}, -len )
        Functions &= blank
        ColTok &= blank
    end if
    
    if args = 1 then
        UNARY &= id
    elsif args then
        BINARY &= id
    else
    	NONARY &= id
    end if
    
    --Functions[id] = ref
    Functions[id] = func
    ColTok[id] = r_id
    if precedence then
    	if precedence > length(Precedence) then
    		Precedence &= {{}}
    	end if
        Precedence[precedence] &= id
    end if
end procedure

function IsLetter( atom a )
    return (a >= 'A' and a <= 'Z') or ( a >= 'a' and a <= 'z' ) or
    	a = '_' or a = '[' or a = ']'
end function
        
function IsNumber( atom a )
    return (a >= '0' and a <= '9') or ( a = '.' ) 
end function

function IsParen( atom a )
    return find(a, "()" )
end function

function IsWhiteSpace( atom a )
    return find( a, " \t\n\r")
end function 

function IsQuote( atom a )
    return a = '"'
end function


function GetType( atom a )
    if IsLetter( a ) then
        return LETTER
    elsif IsNumber( a ) then
        return NUMBER
    elsif IsParen( a ) then
        return PAREN
    elsif IsWhiteSpace( a ) then
        return WHITESPACE
    elsif IsQuote( a ) then
        return QUOTE
    else
        return OTHER
    end if
end function



-- This will check to see if we've collapsed a token already
function IsCollapsed( sequence func )
    if func[m:FUNC] = VAR then
        if length(func[m:ARG2]) then
            return 1
        else 
            return 0
        end if
    elsif func[m:FUNC] = CONSTANT then
        if length(func[m:ARG1])  then
            return 1
        else 
            return 0
        end if
    elsif func[m:FUNC] = DATA then
    	return 1
    elsif find(func[m:FUNC], BINARY ) then
    -- This is for functions which require 2 args
        if length(func[m:ARG1]) and length(func[m:ARG2]) then
            return 1
        else
            return 0
        end if
    elsif find(func[m:FUNC], UNARY ) then
    -- This is for functions which require 1 arg
        if length(func[m:ARG1]) then
            return 1
        end if
    elsif find(func[m:FUNC], NONARY ) then
    	return 1
    end if
    return 0
end function


-- Makes sure we parse the tokens in the proper order to ensure that
-- we get a correct result
function GetPrecedence( atom level, sequence expr )
    atom ix, jx

    for func = 1 to length(Precedence[level]) do
        for tok = 1 to length( expr ) do
            if sequence(expr[tok]) and find( expr[tok][m:FUNC], Precedence[level] ) 
                and not IsCollapsed(expr[tok]) then
                -- This is the next one we'll collapse
                return tok
            end if

        end for
    end for
    
    return 0 
end function

--/topic Extensions
--/func CollapseToken( sequence expr, atom tok)
--
-- Used to collapse tokens, and adds some error checking to make sure that there is a 
-- routine for the token.  This should be used within parsing routines to ensure
--that tokens are fully collapsed (parsed) before they are made into an argument
--for another token.
global function CollapseToken( sequence expr, atom tok)
    if ColTok[expr[tok][m:FUNC]] = -1 then
        expr[tok] = { INVALID, "Invalid/Unsupported operator or function", {} }
        -- this should never actually happen, except in debugging
    end if
    return call_func( ColTok[expr[tok][m:FUNC]], { expr, tok } )
end function

-- Collapses all tokens.  First dives into each level of parenthesis
-- recursively and collapses tokens in order based on precedence levels.
function Collapse( sequence expr )
    integer ix, jx, count, last_right

    ix = 1

    while ix do        
        ix = find( Functions[LPAR], expr)
        count = 1

        if not ix then
        	ix = find( Functions[RPAR], expr)
        	if ix then
        		return {{INVALID, "Unmatched right parenthesis in expression",{}}}
        	end if
        end if
        if ix then
            
            jx = ix + 1
            while count and jx <= length(expr) do
                if equal( expr[jx], Functions[LPAR] ) then
                    count += 1
                elsif equal( expr[jx], Functions[RPAR]) then
                	last_right = jx
                    count -= 1
                end if
                jx += 1
            end while

            if count < 0 then
            	return {{INVALID, "Unmatched right parenthesis in expression",{}}}
            elsif count then
            	return {{INVALID, "Unmatched left parenthesis in expression",{}}}
            end if

            expr = expr[1..ix-1] & Collapse(expr[ix+1..last_right-1]) & 
            		expr[last_right+1..length(expr)]

        end if
    end while
    -- No more parenthesis to deal with
    -- Now we'll collapse from left to right

    jx = 1
    while jx <= length(expr) do
        if atom( expr[jx] ) then
            expr = expr[1..jx-1] & expr[jx+1..length(expr)]
        else
            jx += 1
        end if
    end while
    -- Strip out left over right parens...

    
    jx = 1
    while jx <= length(Precedence) do
        ix = GetPrecedence( jx, expr )
        -- This will find the index of any tokens at the stated 
        -- precedence level...
        if ix then
            expr = CollapseToken( expr, ix )
        else
            jx += 1        
        end if
        
        -- If we have left overs, where no operator was entered,
        -- such as "sin x cos x", we'll multiply these together
        -- to become "(sin x)*(cos x)"
        if jx > length(Precedence) and not ix then
            while length( expr ) > 1 do
                if length(expr) = 2 then
                    expr = { {MULTIPLY, expr[1], expr[2]}}
                else
                    expr = { {MULTIPLY, expr[1], expr[2]}} & expr[3..length(expr)]
                end if
            end while
        end if
    end while
    
    return expr
end function

function TokenizeConstant( sequence expr, sequence val, 
        integer pos1, integer pos2)
    if not val[1] then
        expr = expr[1..pos1-1] & {{CONSTANT, { val[2] },{}}} &
            expr[pos1 + pos2..length(expr)]
    else
        expr = {{INVALID, "Unknown number format", {} }} 
    end if
    return expr
end function

--/topic Expressions
--/proc parse_simplify( integer on )
--
--Changes the behavior of /Parse().  If /b on is zero, then parsed
--expressions are not simplified (see /Simplify) before returning.
--Expressions are simplified by default.

integer simplify_on
simplify_on = 1
global procedure parse_simplify( integer on )
	simplify_on = on
end procedure

-- This funciton takes a 'string' containing an expression,
-- and returns a sequence in matheval format.
global function Parse( sequence expr )
    sequence word, p
    atom ix, jx, char, chartype
    integer quotes
    quotes = 0
    
    -- Changed to upper() on demand
    -- Leave text in quotes lowercase
    --expr = upper( expr )
    
    -- We'll assume that two blocks of parenthesis mean to
    -- multiply the contents, so we'll insert an '*'
    ix = match(")(", expr)
    while ix do
        expr = expr[1..ix] & "*" & expr[ix+1..length(expr)]
        ix = match(")(", expr)
    end while
    
    -- ix is the index for the beginning of our prospective token
    -- jx is the offset from the beginning of the current
    --    prospective token to the current position
    ix = 1
    jx = 0
    
    word = {{},{}}                         
    while ix + jx <= length( expr ) do
    -- first we tokenize the string
            
            if ix+jx <= length(expr) then
                char = expr[ix + jx]
            end if
            
            chartype = GetType( char )
            if chartype = LETTER and not quotes then
                char = upper( char )
            end if
      
            if length(word[1]) and chartype != QUOTE then
                -- we need to check what we've gotten so far

                if chartype != word[2][1] and 
                not (quotes) then
                    -- looks like we may be at the end of the token!
                    
                    if word[2][1] = LETTER and chartype = NUMBER then
                        -- vars are allowed to have letters, numbers and
                        -- underscores, as long as they start with a letter
                        -- or underscore
                        
                        word[1] &= char
                        word[2] &= chartype
                        jx += 1
                    elsif find(word[1], Functions) then
                        -- we've got a function!
                        -- we'll tokenize it
                        expr = expr[1..ix-1] & 
                            {{ find(word[1], Functions), {},{}}} &
                            expr[ix+jx..length(expr)]
                        
                        word = { {}, {} }
                        ix += 1
                        jx = 0  
                               
                    elsif word[2][1] = NUMBER then

                        p = value( word[1] )
                        expr = TokenizeConstant(expr, p, ix, jx)
                        
                        word = { {}, {} }
                        ix += 1
                        jx = 0  
                    else
                        expr = expr[1..ix-1] & {{VAR,  word[1], {}}}
                               & expr[ix+jx..length(expr)]
                        
                        word = { {}, {} }
                        ix += 1
                        jx = 0  
                    end if
                else
                    -- Add the character and it's type to the word
                    -- and move the index over one.
                    
                    word[1] = append( word[1], char )
                    word[2] = append( word[2], chartype )
                    
                    jx += 1
                end if                
            elsif chartype = WHITESPACE then
                -- this is our first char, so we'll just
                -- delete the whitespace
                expr = expr[1..ix-1] & expr[ix+1..length(expr)]
                
            elsif chartype = QUOTE then

                if quotes then

                    quotes = 0
                    expr = expr[1..ix-1] & {{ DATA, 
                        word[1][2..length(word[1])], {}}}
                        & expr[ix+jx+1..length(expr)]
                    word = {{},{}}
                    ix += 1
                    jx = 0
                else

                    quotes = 1
                    word[1] &= '"'
                    word[2] &= QUOTE
                    jx += 1
                end if
                
            else
                if chartype = PAREN then
                -- for now, we just skip over parenthesis
                    ix += 1
                elsif char = ',' then

                	expr[ix] = { COMMA, {}, {} }
                	ix += 1
                else
                    word[1] &= char
                    word[2] &= chartype
                    jx += 1
                end if
            end if
            
            -- We tokenize anything left over.
            -- This is the same code as above, so we should
            -- probably proceduralize this later...
            if ix+jx > length(expr) and length(word[1]) then
                if word[2][1] = NUMBER then
                    p = value( word[1] )
                    expr = TokenizeConstant(expr, p, ix, jx)

                elsif find(word[1], Functions) then
                -- We're at the end, and the word matches a function
                    expr = expr[1..ix-1] & {{ find(word[1], Functions), {},{}}}
                else
                -- The word doesn't match a function, so it must be
                -- a variable
                    expr = expr[1..ix-1] & {{VAR,  word[1] , {}}}
                end if
            ix += 1
            jx = 0
            end if
    
    end while

    -- now we need to go back through and fill in all the arguments
    -- of the tokens with adjacent tokens as necessary

    expr = Collapse( expr )

	if simplify_on then
		expr = call_func( SIMPLIFY, {expr[1]})
	else
	
		expr = expr[1]
	end if
    return expr 
end function


--/topic Extensions
--/func CheckCollapsed( sequence toks )
-- Make sure that everything in the passed tokens is collapsed properly
-- toks  = { tok1, ... }
global function CheckCollapsed( sequence toks )
    for i = 1 to length( toks ) do
        if not IsCollapsed(toks[i]) then
            return 0
        end if
    end for
    return 1
end function

--/topic Extensions
--/func SyntaxError( sequence func )
--A generic func to take care of situation where there is
--incorrect syntax for a token (ie, wrong args).
global function SyntaxError( sequence func )
? 1/0
    return {{ INVALID, "'" & func & "' syntax error", {} }} 
end function


-- Following is the code which collapses each argument.
-- Each func knows how many args are needed for each matheval
-- function, and it checks to make sure they are there, and if
-- so, collapses (or nests) them into the current token.  If there
-- is an error, the entire expression is passed back as an INVALID,
-- listing a syntax error.

function CAdd( sequence expr, atom tok )
    sequence func
    func = expr[tok]
    if tok = 1 then
        return expr[2..length(expr)]
    elsif tok = length(expr) then
        return {{ INVALID, "+ Cannot find right arg", {}}}
    elsif expr[tok+1][m:FUNC] = SUBTRACT then
        
        return call_func(ColTok[SUBTRACT], 
            { expr[1..tok-1] & expr[tok+1..length(expr)], tok})
    else
        if CheckCollapsed( {expr[tok-1], expr[tok+1]} ) then
            func = {func[m:FUNC], expr[tok-1], expr[tok+1] }
        else
            return SyntaxError("+")
        end if
    end if
    return expr[1..tok-2] & {func} & expr[tok+2..length(expr)]
end function

function CSubtract( sequence expr, atom tok )
    sequence func
    func = expr[tok]
    if tok = 1 and expr[tok+1][m:FUNC] = CONSTANT then
        -- must be negation...
        func = { {CONSTANT, {-expr[tok+1][m:ARG1][1]}, {}} }
        return func & expr[3..length(expr)]
    elsif tok = 1 then
        func = { {CONSTANT, {-1}, {}}, {MULTIPLY, {}, {}}}
        return Collapse(func & expr[2..length(expr)])
    elsif tok = length(expr) then
        return {{ INVALID, "- Cannot find right arg", {}}}
    else
        if CheckCollapsed( {expr[tok-1], expr[tok+1]} ) then
            func = {func[m:FUNC], expr[tok-1], expr[tok+1] }
        else
            return SyntaxError("-")
        end if
    end if
    return expr[1..tok-2] & {func} & expr[tok+2..length(expr)]
end function

function CMultiply( sequence expr, atom tok )
    sequence func
    
    func = expr[tok]

    if tok = 1 then
        return {{ INVALID, "* Cannot find left arg", {}}}
    elsif tok = length(expr) then
        return {{ INVALID, "* Cannot find right arg", {}}}
    else
        
        if CheckCollapsed( {expr[tok-1], expr[tok+1]}) then
            func = {func[m:FUNC], expr[tok-1], expr[tok+1] }
        else

            return SyntaxError( "*" )
        end if
        
    end if
    
    return expr[1..tok-2] & {func} & expr[tok+2..length(expr)]
end function

function CDivide( sequence expr, atom tok )
    sequence func
    func = expr[tok]
    if tok = 1 then
        return { {INVALID, "/ Cannot find left arg", {}}}
    elsif tok = length(expr) then
        return { {INVALID, "/ Cannot find right arg", {}}}
    else
        if CheckCollapsed( {expr[tok-1], expr[tok+1]}) then
            func =  {func[m:FUNC], expr[tok-1], expr[tok+1] }
        else
            return SyntaxError( "/")
        end if
    end if
    return expr[1..tok-2] & {func} & expr[tok+2..length(expr)]
end function

function CVar( sequence expr, atom tok )
    sequence func
    
    func = expr[tok]
    
    if tok = 1 or atom(expr[tok-1]) then
        func[m:ARG2] = {1}
        expr[1] = func
    else
        if expr[tok-1][m:FUNC] = CONSTANT then 
            func[m:ARG2] = expr[tok-1][m:ARG1]
            expr = expr[1..tok-2] & {func} & expr[tok+1..length(expr)]
        else
            func[m:ARG2] = {1}
            expr[tok] = func
        end if
    end if
    return expr
end function

function CExponent( sequence expr, atom tok )
    sequence func
    
    func = expr[tok]
    
    if tok = 1 or atom(expr[tok-1]) then
        return { {INVALID, "'^' Cannot find right arg", {}}}
    elsif tok = length(expr) or atom(expr[tok+1]) then
        return {{INVALID, "'^' Cannot find left arg", {}}}
    else
        if CheckCollapsed( {expr[tok-1], expr[tok+1]}) then
            func = { EXPONENT, expr[tok-1], expr[tok+1]}
            if func[m:ARG1][m:FUNC] = VAR and func[m:ARG1][m:ARG2][1] != 1 then
                func = {MULTIPLY, {CONSTANT, func[m:ARG1][m:ARG2], {}}, 
                         {EXPONENT, {func[m:ARG1][m:FUNC],func[m:ARG1][m:ARG1], {1}},
                                func[m:ARG2] }}
            -- this way we separate out the var's coefficient
            -- outside of the exponentiation
            end if
            if tok = 2 then
                    expr = {func} & expr[tok+2..length(expr)]
            else
                expr = expr[1..tok-2] & {func} & expr[tok+2..length(expr)]
            end if
        else
            return SyntaxError( "^" )
        end if
    end if 
        
    return expr
end function                                        



function CSetEqual( sequence expr, atom tok )
	sequence mult
	
--	if tok = 2 and length(expr) > 3 then
--		-- can this simply be multiplied out?
--		mult = { MULTIPLY, expr[3], expr[4] }
--		tok = 5
--		while tok <= length(expr) do
--			mult = { MULTIPLY, mult, expr[tok] }
--			tok += 1
--		end while
--		expr = expr[1..2] & {mult}
--		tok = 2
--	end if
    
    if not (tok >= 2 and length(expr) >= tok + 1) then
        return {{INVALID, "':=' Missing RHS or LHS", {}}}
    elsif expr[tok-1][m:FUNC] != VAR then
        return {{ INVALID, ":= LHS must be a variable", {} }}
    elsif CheckCollapsed( {expr[tok-1], expr[tok+1]} ) then
        return expr[1..tok-2] & {{ SETEQUAL, expr[tok-1], expr[tok+1]}} &
        	expr[tok+2..length(expr)]
    else
        return SyntaxError( ":=" )
    end if
end function



function CSin( sequence expr, atom tok )
    if tok = length(expr) then
        return {{ INVALID, "'sin' missing argument",{}}}
    elsif CheckCollapsed( {expr[tok+1]} ) then
        
        return expr[1..tok-1] & {{SIN, expr[tok+1], {}}} & 
                expr[tok+2..length(expr)]
    else
        return SyntaxError( "sin" )
    end if
end function

function CCos( sequence expr, atom tok )

    if tok = length(expr) then
        return {{ INVALID, "'cos' missing argument",{}}}
    elsif CheckCollapsed( {expr[tok+1]} ) then
    
        return expr[1..tok-1] & {{COS, expr[tok+1], {}}} & 
                expr[tok+2..length(expr)]
    
    else
        return SyntaxError( "cos" )
    end if
end function

function CTan( sequence expr, atom tok )
    if tok = length(expr) then
        return {{ INVALID, "'tan' missing argument",{}}}
    elsif CheckCollapsed( {expr[tok+1]}) then
        
        return expr[1..tok-1] & {{TAN, expr[tok+1], {}}} & 
                expr[tok+2..length(expr)]
    else
        return SyntaxError("tan")
    end if
end function

function CFactorial( sequence expr, atom tok )
    if tok = 1 then
        return {{ INVALID, "'!' missing argument", {}}}
    elsif CheckCollapsed( {expr[tok-1]}) then
        
        return expr[1..tok-2] & {{FACTORIAL, expr[tok-1], {} }} & 
                expr[tok+1..length(expr)]
    else
        return SyntaxError("!")
    end if
end function

function CFloor( sequence expr, atom tok )

    if tok = length( expr ) then
        return {{ INVALID, "'floor' missing argument", {} } }
    elsif CheckCollapsed( {expr[tok+1]} ) then
        
        return expr[1..tok-1] & { {FLOOR, expr[tok+1], {}}} &
               expr[tok+2..length(expr)]
    else
        return SyntaxError( "floor" )
    end if
end function

function CSqrt( sequence expr, atom tok )

    if tok = length( expr ) then
        return {{ INVALID, "'SQRT' missing argument", {} } }
    elsif CheckCollapsed( {expr[tok+1]} ) then
        
        return expr[1..tok-1] & { {SQRT, expr[tok+1], {}}} &
               expr[tok+2..length(expr)]
    else
        return SyntaxError( "sqrt" )
    end if
end function

function CConstant( sequence expr, atom tok )
    return expr
end function

function CComma( sequence expr, atom tok )
    -- turn stuff into DATA
    sequence data, token
    integer compound

    if tok = 1 or tok = length(expr) then
        return SyntaxError(",")
    end if

    data = {DATA, {}, {}}
    token = expr[tok-1]

    if is_compound(token) then
        data = token
    else
        data[m:ARG1] = {token}
    end if

    token = expr[tok+1]
    if is_compound(token) then
        data[m:ARG1] &= {token[m:ARG1]}
    else
        data[m:ARG1] &= {token}
    end if

    return expr[1..tok-2] & {data} & expr[tok+2..length(expr)]    
end function


procedure init_parse()

	CONSTANT = m:resolve_math_ref("CONSTANT")
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
    LPAR = m:resolve_math_ref( '(' )
    RPAR = m:resolve_math_ref( ')' )
    DATA = m:resolve_math_ref( "DATA" )
	COMMA = m:resolve_math_ref( "," )
	SQRT = m:resolve_math_ref( "SQRT" )
	
    UNARY  &= { SIN, COS, TAN, FLOOR, FACTORIAL, CONSTANT }
    BINARY &= { ADD, SUBTRACT, MULTIPLY, DIVIDE, EXPONENT, SETEQUAL }


    --reg_parse_func( "CONSTANT", "", routine_id("CConstant"), 0, 0 )
    reg_parse_func( "ADD", "+", routine_id("CAdd"), 2, 5 )
    reg_parse_func( "SUBTRACT", "-", routine_id("CSubtract"), 2, 5 )
    reg_parse_func( "MULTIPLY", "*", routine_id("CMultiply"), 2, 3 )
    reg_parse_func( "DIVIDE", "/", routine_id("CDivide"), 2, 3 )
    reg_parse_func( "EXPONENT", "^", routine_id("CExponent"), 2, 2 )
    reg_parse_func( "FACTORIAL", "!", routine_id("CFactorial"), 1, 2 )
    reg_parse_func( "SETEQUAL", ":=", routine_id("CSetEqual"), 2, 7 )
    reg_parse_func( "FLOOR", "FLOOR", routine_id("CFloor"), 1, 3 )
    reg_parse_func( "SQRT", "SQRT", routine_id("CSqrt"), 1, 2 )
    reg_parse_func( "SIN", "SIN", routine_id("CSin"), 1, 3 )
    reg_parse_func( "COS", "COS", routine_id("CCos"), 1, 5 )
    reg_parse_func( "TAN", "TAN", routine_id("CTan"), 1, 5 )
    reg_parse_func( '(', '(', 0, 2, 5 )
    reg_parse_func( ')', ')', 0, 2, 5 )
    reg_parse_func( ",", ",", routine_id("CComma"), 2, 8 )

    reg_parse_func( "VAR", "", routine_id("CVar"), 1, 1 )
    
end procedure

m:add_math_init( routine_id("init_parse") )
