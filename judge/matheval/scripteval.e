
include matheval.e as m
include parseval.e as p
include ppeval.e as pp
include symeval.e as s
include booleval.e as b

integer IF, BLOCK, FOR, WHILE, INVALID, EXIT, GOTO, CONSTANT, DATA, VAR,
	LABEL, COMMENT

--/topic Scripting
--/info
--Loops, if-then, etc
--
--By including scripteval.e, complex algorithms may be evaluated using
--matheval, including function and procedure calls by assigning a /BLOCK
--to a variable.

--/topic Scripting
--/const IF
--/desc { IF, condition, { true, false, [else] } }
--
--Conditional calculation.  If /i condition is /ZERO, then /i false is calculated.
--If /i condition is a non-zero /CONSTANT, then /i true is calculated.  You may
--optionally specify /i else, which will be called if /i condition does not
--evaluate to a constant.
function If( sequence a, sequence b )
	sequence expr
	a = m:call_op( a )
	if equal( a, m:ZERO ) then
		return m:call_op( b[2] )
	end if
	
	if a[m:FUNC] = CONSTANT then
		return m:call_op( b[1] )
	end if
	
	expr = m:eval_addons( IF, a, b )
	if expr[m:FUNC] = IF and length(b) = 3 then
		return m:call_op( b[3] )
	end if
	return expr
end function

sequence scope_ids, scope_exits, scope_stack
integer cur_scope
cur_scope = 0
scope_stack = repeat( 0, 10 )
scope_ids = repeat( -1, 10 )
scope_exits = repeat( 0, 10 )

-- generate a new loop id
function new_scope()
	integer ix
	ix = find(-1, scope_ids )
	if not ix then
		ix = length(scope_ids) + 1
		scope_ids &= repeat( -1, 10 )
		scope_exits &= repeat( 0, 10 )
	end if
	
	cur_scope += 1
	if cur_scope > length( scope_stack ) then
		scope_stack &= scope_stack
	end if
	
	scope_stack[cur_scope] = ix
	
	scope_ids[ix] = ix
	return ix
end function

procedure exit_scope( integer levels )
	for i = 1 to levels do
		scope_exits[scope_stack[cur_scope]] = 1
		cur_scope -= 1
		if not cur_scope then
			return
		end if
	end for
end procedure

procedure clear_scope( integer scope )
	scope_ids[scope] = -1
	scope_exits[scope] = 0
end procedure

--/topic Scripting
--/const For
--/desc { FOR, { variable, start, condition, increment operation }, expr }
--
--A for loop for matheval.  It is similar in operation to a C-style for-loop.
--ARG1 is a 4 element sequence.  /b expr will be evaluated as long as 
--/b condition is true.  The statement:
--/code
--  "FOR(X, 1, X<=10, X+1,Y:=Y+1)"
--/endcode
--...would parse to:
--/code
--  { FOR,
--      { "X", ONE, { LTOE, {VAR, "X", {1}}, {POLYNOMIAL, "X", {1,1}},
--      { SETEQUALTO, 
--          {VAR, "Y", {1}},
--          { POLYNOMIAL, "Y", {1,1}}}}
--/endcode
--A single command or expression or a /BLOCK of commands or expressions may be 
--executed by FOR.  The value of a FOR loop is the value of the last expression
--evaluated in the block of code, or the block of code itself, if it was never
--evaluated.
function For( sequence a, sequence b )
	sequence var, Continue, increment, test, block
	integer for_flag
	
	for_flag = new_scope()
	var = a[1]
	Continue = a[3]
	increment = a[4]
	block = b
	m:SetVar( var, a[2] )
	test = m:call_op( Continue )
	while compare( test, m:ZERO ) and not scope_exits[for_flag] do
		block = m:call_op( b )
		test = m:call_op( increment )
		m:SetVar( var, test )
		test = m:call_op( Continue )
	end while
	
	clear_scope( for_flag )

	return block 
end function

--/topic Scripting
--/const BLOCK
--/desc { BLOCK, { [expr1], ... }, {} }
--
--A set of statements to be evaluated sequentially.  Blocks may
--contain other blocks.  To parse a block, all expressions should
--be within parenthesis and separated by commas:
--/code
--  "BLOCK( X:=1, FOR( I, 1, I<=5, I+1, X:=X*I))"
--/endcode
--The value of a block of expressions will be the last expression
--evaluated.
function Block( sequence a, sequence b )
	integer block_id, block_ptr, len, Goto
	sequence last, expr
	
	block_id = new_scope()
	block_ptr = 1
	len = length(a)
	last = a

	while block_ptr <= len and not scope_exits[block_id] do

		last = m:call_op( a[block_ptr] )
		if last[m:FUNC] = GOTO then
			Goto = find( { LABEL, last[m:ARG1], {} }, a )
			if not Goto then
				if cur_scope = 1 then

					last = { INVALID, "Missing label " & a[block_ptr][m:ARG1], {} }
				end if
				exit_scope(1)
				exit
			end if
			block_ptr = Goto
--			last = call_op( expr )
		else
			block_ptr += 1
		end if
	end while
	clear_scope( block_id )
	return last
end function

--/topic Scripting
--/const LABEL
--/desc { LABEL, label, {}}
--
--A target for /GOTO from within a /BLOCK.  The proper syntax when parsing is:
--/code
--   LABEL("THIS LABEL")
--/endcode
--Note that labels are /i case /i sensitive, and must be strings (/DATA) only.

function Label( sequence a, sequence b )
	return { LABEL, a, b }
end function

--/topic Scripting
--/const GOTO
--/desc { GOTO, labelname, {} }
--
--Allows the evaluation of a block of expressions to jump to a label within
--the same block or within a parent block:
--/code
--  BLOCK(
--         X := 1
--         LABEL("start"),
--         X := X + 1,
--         IF( X < 5, GOTO("start"), EXIT(1) )
--        )
--/endcode
--The labelname may be any expression, but note that labels are /i case /i sensitive.
--If an invalid label name is supplied, the result will be an /INVALID value, and the 
--block will exit.  When the label is not in the current /BLOCK, it will exit the
--current scope and look for the label there, until all blocks have been exited.
function Goto( sequence a, sequence b )
	a = m:call_op( a )
	return {GOTO, a, b}
end function

--/topic Scripting
--/const EXIT
--/desc { EXIT, levels, {}}
--Exit from a block of expressions or a loop.  EXIT allows multiple levels of
--escape from loops or blocks.  The correct format is:
--/code
--  "EXIT(levels)"
--/endcode
--/i levels can be any valid matheval expression.  If /i levels does not evaluate
--to a /CONSTANT, or if it is less than or equal to zero, no exit will occur.
function Exit( sequence a, sequence b )
	integer levels
	levels = 0
	a = call_op( a )
	if a[m:FUNC] = CONSTANT then
		levels = a[m:ARG1][1]
	end if
	if levels > 0 then
		exit_scope( levels )
	end if
	return {CONSTANT, {levels},{}}
end function

--/topic Scripting
--/const COMMENT
--
--Comments are removed during parsing, along with the next token.  If 
--the comment has any whitespace, it should be in quotes:
--/code
--  -- "This is a comment"
--/endcode

function Comment( sequence a, sequence b )
	return { COMMENT, a, b }
end function

function CComment( sequence expr, integer tok )

	if tok = length(expr) then
		return expr[1..length(expr)-1]
	end if
	return expr[1..tok-1] & expr[tok+2..length(expr)]
end function

function CBlock( sequence expr, integer tok )
	sequence block

	if tok = length(expr) then
		return {{ BLOCK, {ZERO}, {}}}
	end if
	
	block = expr[tok+1]
	
	if not m:is_compound( block ) then
		block = {block}
	else
		block = block[m:ARG1]
	end if
	
	return expr[1..tok-1] & {{BLOCK, block,{}}} & expr[tok+2..length(expr)]	
end function

function CExit( sequence expr, integer tok )
	if tok = length(expr) then
		return {{INVALID, "Missing levels parameter for EXIT", {}}}
	end if
	return expr[1..tok-1] & {{EXIT, expr[tok+1],{}}} & expr[tok+2..length(expr)]
end function

function CLabel( sequence expr, integer tok )

	if tok = length(expr) then
		return {{INVALID, "LABEL: Missing label name", {}}}
	end if
	return expr[1..tok-1] & {{LABEL, expr[tok+1],{}}} & expr[tok+2..length(expr)]
end function

function CGoto( sequence expr, integer tok )
	if tok = length(expr) then
		return {{INVALID, "Missing label for GOTO", {}}}
	end if
	return expr[1..tok-1] & {{GOTO, expr[tok+1],{}}} & expr[tok+2..length(expr)]
end function

function CFor( sequence expr, integer tok )
	sequence arg, element, arg1, arg2

	if tok = length(expr) then
		return {{INVALID, "Missing arguments for FOR-loop",{}}}
	end if
	
	arg = expr[tok+1]
	
	if arg[m:FUNC] != DATA or m:is_compound( arg ) != 5 then
		return SyntaxError( "FOR" )
	end if
	
	-- parse ARG1
	arg1 = repeat( {}, 4 )
	arg = arg[m:ARG1]
	element = arg[1]
	
	if element[m:FUNC] != VAR then
		return SyntaxError( "FOR" )
	end if
	arg[1] = element[m:ARG1]
	
	arg1 = arg[1..4]
	arg2 = arg[5]

	return expr[1..tok-1] & {{FOR, arg1, arg2}} & expr[tok+2..length(expr)]
end function

function CIf( sequence expr, integer tok )
	sequence data
	integer args

	if tok = length(expr) or expr[tok+1][m:FUNC] != DATA then
		return { {INVALID, "Missing arguments for IF()", {}}}
	end if
	data = expr[tok+1]
	args = m:is_compound( data )
	if not args then
		return { {INVALID, "Missing arguments for IF()",{}}}
	elsif args = 1 then
		return {{INVALID, "Missing TRUE and FALSE branches for IF",{}}}
	elsif args = 2 then
		return {{INVALID, "Missing FALSE branch for IF",{}}}
	elsif args > 4 then
		return {{INVALID, "Too many arguments for IF",{}}}
	end if
	
	expr[tok] = {IF, data[m:ARG1][1], data[m:ARG1][2..args]}
	
	return expr[1..tok] & expr[tok+2..length(expr)]
end function

function PPBlock( sequence a, sequence b )
	sequence p
	p = "BLOCK( "
	for i = 1 to length(a) do
		if i > 1 then
			p &= ", "
		end if
		p &= call_func( pp:PPEXP[a[i][m:FUNC]], a[i][m:ARG1..m:ARG2] )
	end for
	
	p &= " )"
	return p
end function

function PPExit( sequence a, sequence b )
	return "EXIT( " & call_func( pp:PPEXP[a[m:FUNC]], a[m:ARG1..m:ARG2] ) & " )"
end function

function PPLabel( sequence a, sequence b )
	return "LABEL( " & call_func( pp:PPEXP[a[m:FUNC]], a[m:ARG1..m:ARG2] ) & " )"
end function

function PPGoto( sequence a, sequence b )
	return "GOTO( " & call_func( pp:PPEXP[a[m:FUNC]], a[m:ARG1..m:ARG2] ) & " )"
end function

function PPFor( sequence a, sequence b )
	sequence p
	
	p = "FOR( " & a[1]
	for i = 2 to 4 do
		p &= ", "
		p &= call_func( pp:PPEXP[a[2][m:FUNC]], a[2][m:ARG1..m:ARG2] )
	end for
	p &= ") "
	p &= call_func( pp:PPEXP[b[m:FUNC]], b[m:ARG1..m:ARG2] )
	return p
end function

function PPIf( sequence a, sequence b )

	return "IF( " & call_func(pp:PPEXP[a[m:FUNC]], a[m:ARG1..m:ARG2] ) & ", " &
		call_func(pp:PPEXP[b[1][m:FUNC]],  b[1][m:ARG1..m:ARG2]  ) & ", " &
		call_func(pp:PPEXP[b[2][m:FUNC]],  b[2][m:ARG1..m:ARG2]  ) & " )"
	
end function


procedure script_init()
	CONSTANT = m:resolve_math_ref( "CONSTANT" )
	DATA = m:resolve_math_ref( "DATA" )
	INVALID = m:resolve_math_ref( "INVALID" )
	VAR = m:resolve_math_ref( "VAR" )
	
    IF = m:reg_math_func( "IF", routine_id("If"))
    FOR = m:reg_math_func( "FOR", routine_id("For"))
    BLOCK = m:reg_math_func( "BLOCK", routine_id("Block"))
    EXIT = m:reg_math_func( "EXIT", routine_id("Exit"))
    LABEL = m:reg_math_func( "LABEL", routine_id("Label"))
    GOTO = m:reg_math_func( "GOTO", routine_id("Goto"))
    COMMENT = m:reg_math_func( "COMMENT", routine_id("Comment"))
    
    s:set_simplify( IF, 0 )
    s:set_simplify( FOR, 0 )
    s:set_simplify( BLOCK, 0 )
    
	p:reg_parse_func( "IF", "IF", routine_id("CIf"), 2,  2 )
    p:reg_parse_func( "FOR", "FOR", routine_id("CFor"), 2, 2 )
    p:reg_parse_func( "BLOCK", "BLOCK", routine_id("CBlock"), 1, 2 )
    p:reg_parse_func( "EXIT", "EXIT", routine_id("CExit"), 1, 2 )        
    p:reg_parse_func( "LABEL", "LABEL", routine_id("CLabel"), 1, 2 )
    p:reg_parse_func( "GOTO", "GOTO", routine_id("CGoto"), 1, 2 )
    p:reg_parse_func( "COMMENT", "--", routine_id("CComment"), 1, 1 )
    
    m:pretty_print( IF, routine_id("PPIf"))
    m:pretty_print( FOR, routine_id("PPFor"))
    m:pretty_print( BLOCK, routine_id("PPBlock"))
    m:pretty_print( EXIT, routine_id("PPExit"))
    m:pretty_print( LABEL, routine_id("PPLabel"))
    m:pretty_print( GOTO, routine_id("PPGoto"))
    
end procedure
m:add_math_init( routine_id("script_init") )
