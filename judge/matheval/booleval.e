-- booleval.e


--/topic Boolean Algebra
--/info
--Logical operators
--
--See booleval.e for source (you must explicitly include this file to 
--use boolean algebra).
--
--Boolean algebra functionality is included in the file booleval.e,
--which must be explicitly included to be used.  It is not a part
--of the core matheval library.
--

include matheval.e as m
include parseval.e as p
include ppeval.e as pp
include std/wildcard.e

integer AND, OR, CONSTANT, INVALID, LIKE, EQUALTO, GREATER, LESS,
	GOE, LOE, BETWEEN, POLYNOMIAL, VAR, DATA, NOT, NOTEQUAL, IN, RPAR, LPAR, IF,
	NOTEQUAL_SQL

--/topic Boolean Algebra
--/const Not
--/desc { NOT, constant, {} }
--
--Logical not operator.  Returns /ONE if
--ARG1 is /ZERO, or /ZERO if ARG1 is a /CONSTANT.  Otherwise
--it evaluates ARG1 and returns {NOT, ARG1, {}}.
--
function Not( sequence a, sequence b )
	b = m:call_op( a )
--    b = call_func( Operation[a[FUNC]], a[ARG1..ARG2] )
	if b[FUNC] = CONSTANT then
		if equal( b, m:ZERO ) then
			return m:ONE
		else
			return m:ZERO
		end if
	end if
	return m:eval_addons( NOT, b, {} )
--    return { NOT, b, {}}
end function

--/topic Boolean Algebra
--/const Or
--/desc { OR, expr1, expr2 }
--
--If both /b expr1 and /b expr2 are /ZERO, then /ZERO is
--returned.  If at least one of /b expr1 or /b expr2 is a
--nonzero /CONSTANT, then returns /ONE.
--
function Or( sequence a, sequence b )
	sequence x
	x = m:GetArgs( a, b )

	if find( m:ONE, x) then
		return m:ONE
	elsif equal(x[1], m:ZERO) and equal(x[2], m:ZERO) then
		return m:ZERO
	elsif x[1][FUNC] = CONSTANT and x[1][ARG1][1] then
		return m:ONE
	elsif x[2][FUNC] = CONSTANT and x[2][ARG1][1] then
		return m:ONE
	else
		return m:eval_addons( OR, x[1], x[2] )
--        return OR & x
	end if
	
end function

--/topic Boolean Algebra
--/const And
--/desc { And, expr1, expr2 }
--
--If both /b expr1 and /b expr2 are nonzero constants, then /ONE is
--returned.  If at least one of /b expr1 or /b expr2 is 
--/ZERO, then returns /ZERO.
--

function And( sequence a, sequence b )
	sequence x
	
	x = m:GetArgs( a, b )

	if find( m:ZERO, x ) then
		return m:ZERO
	end if
	
	if x[1][FUNC] = CONSTANT and x[2][FUNC] = CONSTANT then
		if x[1][ARG1][1] and x[2][ARG1][1] then
			return m:ONE
		else
			return m:ZERO
		end if
	end if

	return m:eval_addons( AND, x[1], x[2] )    
--    return AND & x
end function

--/topic Boolean Algebra
--/const Like
--/desc { LIKE, expr1, expr2 }
--
--Compares objects.  If the objects are identical, it will return /ONE.
--Like's main purpose, however, is for comparing strings, including
--with wildcards (see Euphoria documentation on /b wildcard_match for
--details).  A string is represented as a DATA object, with the string
--itself being the value of ARG1.
--
function Like( sequence a, sequence b )
	sequence x

	x = m:GetArgs( a, b )

	if equal(x[1], x[2]) then
		return m:ONE
	elsif x[1][FUNC] = DATA and x[2][FUNC] = DATA then
		if is_match( x[2][ARG1], x[1][ARG1] )  then
			return m:ONE
		else
			return m:ZERO
		end if
	end if
	
	return m:eval_addons( LIKE, x[1], x[2] )
--    return LIKE & x
end function

--/topic Boolean Algebra
--/const EqualTo
--/desc { EQUALTO, expr1, expr2 }
--Similar to /Like, but without wildcards.  Returns /ONE if
--/b expr1 is equal to /b expr2 by comparing ARG1 of each if
--either both are /CONSTANT or one is a /CONSTANT and the other
--is /DATA.
--
function EqualTo( sequence a, sequence b )
	sequence x, funcs

	x = m:GetArgs( a, b )
	funcs = x[1][FUNC] & x[2][FUNC]
   
	if equal(x[1], x[2]) then
		return m:ONE
	elsif funcs[1] = funcs[2] and find( funcs[1],{CONSTANT, DATA}) then
		return m:ZERO
	elsif find( CONSTANT, funcs ) and find( DATA, funcs ) then
	-- 3/11/03: data and a constant can be compared

		if equal( x[1][ARG1], x[2][ARG1] ) then

			return m:ONE
		else
			return m:ZERO
		end if
	end if

	return m:eval_addons( EQUALTO, x[1], x[2] )    
   
end function

--/topic Boolean Algebra
--/const NotEqual
--/desc { NOTEQUAL, expr1, expr2 }
--
--Converse of /EqualTo.  Returns /ZERO if
--/b expr1 is equal to /b expr2 by comparing ARG1 of each if
--either both are /CONSTANT or one is a /CONSTANT and the other
--is /DATA.
--
--This inequality may be expressed in two ways:
--/code
--   expr1 != expr2
--   expr1 <> expr2
--/endcode
function NotEqual( sequence a, sequence b )
	sequence x

	x = m:GetArgs( a, b )

	a = EqualTo( x[1], x[2] )
	if a[FUNC] = EQUALTO then
		return m:eval_addons( NOTEQUAL, a[ARG1], a[ARG2] )
--        a[FUNC] = NOTEQUAL
--        return a
	else
		x = Not( a, {} )
		if x[FUNC] != CONSTANT then
			x = m:eval_addons( NOTEQUAL, x[ARG1], x[ARG2] )
		end if
		return x
	end if
end function

--/topic Boolean Algebra
--/const Greater
--/desc { GREATER, expr1, expr2 }
--
--Returns /ONE if /b expr1 and /b expr2 are both /CONSTANT and
--expr1[ARG1] > expr2[ARG2].  If one expression is /CONSTANT and
--the other is /DATA, returns /ZERO.
--
function Greater( sequence a, sequence b )
	sequence x

	x = m:GetArgs( a, b )
	
	if x[1][FUNC] = CONSTANT and x[2][FUNC] = CONSTANT then
		if x[1][ARG1][1] > x[2][ARG1][1] then
			return m:ONE
		else
			return m:ZERO
		end if
	elsif find(x[1], {CONSTANT, DATA}) and find(x[2], {CONSTANT,DATA}) then
		return m:ZERO
	end if
	
	return m:eval_addons( GREATER, x[1], x[2] )
--    return GREATER & x
end function

--/topic Boolean Algebra
--/const GreaterOrEqual
--/desc { GOE, expr1, expr2 }
--
--Returns /ONE if /b expr1 and /b expr2 are both /CONSTANT and
--expr1[ARG1] >= expr2[ARG2]. 
--
function GreaterOrEqual( sequence a, sequence b )
	sequence x
	
	x = Greater( a, b )
	if equal( x, m:ONE ) then
		return x
	elsif equal( x, m:ZERO ) then
		x = EqualTo( a, b )
		if equal( x, m:ZERO ) then
			return x
		end if
	end if
	
	x = EqualTo( a, b )
	if find( x, {ZERO, m:ONE} ) then
		return x
	end if

	return m:eval_addons( GOE, x[ARG1], x[ARG2] )	 
--    return GOE & x
end function

--/topic Boolean Algebra
--/const Less
--/desc { GREATER, expr1, expr2 }
--
--Returns /ONE if /b expr1 and /b expr2 are both /CONSTANT and
--expr1[ARG1] < expr2[ARG2].  If one expression is /CONSTANT and
--the other is /DATA, returns /ZERO.
--
function Less( sequence a, sequence b )
	sequence x
	x = m:GetArgs( a, b )
	
	if x[1][FUNC] = CONSTANT and x[2][FUNC] = CONSTANT then
		if x[1][ARG1][1] < x[2][ARG1][1] then
			return m:ONE
		else
			return m:ZERO
		end if
	elsif find(x[1], {CONSTANT, DATA}) and find(x[2], {CONSTANT,DATA}) then
		return m:ZERO
	end if
	
	return m:eval_addons( LESS, x[1], x[2] )

end function

--/topic Boolean Algebra
--/const LessOrEqual
--/desc { GREATER, expr1, expr2 }
--
--Returns /ONE if /b expr1 and /b expr2 are both /CONSTANT and
--expr1[ARG1] <= expr2[ARG2].  If one expression is /CONSTANT and
--the other is /DATA, returns /ZERO.
--
function LessOrEqual( sequence a, sequence b )
	sequence x
	
	x = Less( a, b )
	if equal( x, m:ONE ) then
		return x
	elsif equal( x, m:ZERO ) then
		x = EqualTo( a, b )
		if equal( x, m:ZERO ) then
			return x
		end if
	end if
	
	x = EqualTo( a, b )
	if find( x, {m:ZERO, m:ONE} ) then
		return x
	end if
	return m:eval_addons( LOE, x[ARG1], x[ARG2] )
--    return LOE & x
end function

--/topic Boolean Algebra
--/const Between
--/desc { BETWEEN, expr1, {expr2,expr3} }
--
--Returns /ONE if /b expr2 <= /b expr1 <= /b expr3, assuming that
--all are /CONSTANT.
--
function Between( sequence a, sequence b )
	sequence x
	-- a >= b[1] and a <= b[2]
	x = m:GetArgs( a, m:ONE )
	a = x[1]
	
	x = GreaterOrEqual( a, b[1] )
	if equal( x, m:ONE) then
		x = LessOrEqual( a, b[2] )
		if equal( x, m:ONE ) then
			return ONE
		elsif equal( x, m:ZERO ) then
			return m:ZERO
		end if
	elsif equal( x, m:ZERO ) then
		return m:ZERO
	end if
	return m:eval_addons( BETWEEN, a, b )	 
--    return {BETWEEN, a, b }
end function

--/topic Boolean Algebra
--/const In
--/desc { IN, expr1, expr2 }
--Both /b expr1 and /b expr2 must be /DATA.  /b expr2 should
--be a /i compound /DATA object:
--
-- { DATA, {expr1, expr2, ...}, {}}
--
--Each expression will be evaluated, and if one is identical to /b expr1
--then the return value will be /ONE.
--

function In( sequence a, sequence b )
	sequence x
	object o

	x = m:GetArgs( a, b )

	a = x[1]
	b = x[2]
	
	if not find( b[FUNC], {DATA,CONSTANT}) or a[FUNC] = VAR then
		return m:eval_addons( IN, a, b )
	else

		x = b
		if m:is_compound(b) then
			x = x[ARG1]
			for i = 1 to length(x) do
				if equal(a, m:Evaluate( x[i] )) then
					return m:ONE
				end if

			end for
			
			return m:ZERO

		else
			x = x[ARG1]
		end if

		if a[FUNC] = DATA then
			o = a[ARG1]
		elsif a[FUNC] = CONSTANT then
			o = a[ARG1][1]
		end if
		
		if find( o, x ) then
			return m:ONE
		else
			return m:ZERO
		end if
	end if
end function


function CIn( sequence expr, integer tok )
	integer first, last, len
	sequence args, valid_args

	len = length(expr)

	first = tok + 1
	if first > len then
		return {{INVALID, "Missing arguments for IN()", {}}}
	elsif tok = 1 or expr[tok-1][FUNC] != VAR  then
		return {{INVALID, "LHS of IN() must be a variable",{}}}
	end if

	-- arguments can be constants, variables or DATA (strings)
	valid_args = { CONSTANT, DATA, VAR }

	if not find( expr[first][FUNC], valid_args) then
		return {{INVALID, "Arguments to IN() must be constants, variables or strings",{}}}
	end if

	return expr[1..tok-2] & { {IN, expr[tok-1], expr[tok+1]} } & expr[tok+2..len]
end function

function CNotEqual( sequence expr, integer tok )
	sequence func
	func = expr[tok]
	if tok = 1 then
		return {{ INVALID, "!= : Cannot find lhs arg", {}}}
	elsif tok = length(expr) then
		return {{ INVALID, "!= : Cannot find rhs arg", {}}}
	else
		if p:CheckCollapsed( {expr[tok-1], expr[tok+1]} ) then
			func = {NOTEQUAL, expr[tok-1], expr[tok+1] }
		else
			return p:SyntaxError("NOTEQUAL")
		end if
	end if
	
	return expr[1..tok-2] & {func} & expr[tok+2..length(expr)]
end function

function CNot( sequence expr, integer tok )
	sequence func
	func = expr[tok]
	if tok = length( expr ) then
		return {{ INVALID, "NOT: Cannot find arg"}}
	else
		if p:CheckCollapsed( { expr[tok+1] } ) then
			func[ARG1] = expr[tok + 1]
		else
			return p:SyntaxError("NOT")
		end if
	end if
	
	return expr[1..tok-1] & {func} & expr[tok+2..length(expr)]
end function

function CAnd( sequence expr, integer tok )
	sequence func
	func = expr[tok]
	
	if tok = 1 then
		return {{ INVALID, "AND: Cannot find lhs arg", {}}}
	elsif tok = length(expr) then
		return {{ INVALID, "AND: Cannot find rhs arg", {}}}
	else
		if p:CheckCollapsed( {expr[tok-1], expr[tok+1]} ) then
			func = {AND, expr[tok-1], expr[tok+1] }
		else
			return p:SyntaxError("AND")
		end if
	end if
	
	return expr[1..tok-2] & {func} & expr[tok+2..length(expr)]
end function

function COr( sequence expr, integer tok )
	sequence func
	func = expr[tok]
	
	if tok = 1 then
		return {{ INVALID, "OR: Cannot find lhs arg", {}}}
	elsif tok = length(expr) then
		return {{ INVALID, "OR: Cannot find rhs arg", {}}}
	else
		if p:CheckCollapsed( {expr[tok-1], expr[tok+1]} ) then
			func = {OR, expr[tok-1], expr[tok+1] }
		else
			return p:SyntaxError("OR")
		end if
	end if
	
	return expr[1..tok-2] & {func} & expr[tok+2..length(expr)]
end function

function CLike( sequence expr, integer tok )
	sequence func
	func = expr[tok]
	if tok = 1 then
		return {{ INVALID, "LIKE: Cannot find lhs arg", {}}}
	elsif tok = length(expr) then
		return {{ INVALID, "LIKE: Cannot find rhs arg", {}}}
	else
		if p:CheckCollapsed( {expr[tok-1], expr[tok+1]} ) then
			func = {LIKE, expr[tok-1], expr[tok+1] }
		else
			return p:SyntaxError("LIKE")
		end if
	end if
	
	return expr[1..tok-2] & {func} & expr[tok+2..length(expr)]
end function

function CEqualTo( sequence expr, integer tok )
	sequence func
	func = expr[tok]
	
	if tok = 1 then
		return {{ INVALID, "EUQALTO: Cannot find lhs arg", {}}}
	elsif tok = length(expr) then
		return {{ INVALID, "EQUALTO: Cannot find rhs arg", {}}}
	else
		if p:CheckCollapsed( {expr[tok-1], expr[tok+1]} ) then
			func = {EQUALTO, expr[tok-1], expr[tok+1] }
		else
			return p:SyntaxError("EQUALTO")
		end if
	end if
	
	return expr[1..tok-2] & {func} & expr[tok+2..length(expr)]
end function

function CGreater( sequence expr, integer tok )
	sequence func
	func = expr[tok]
	
	if tok = 1 then
		return {{ INVALID, "> : Cannot find lhs arg", {}}}
	elsif tok = length(expr) then
		return {{ INVALID, "> : Cannot find rhs arg", {}}}
	else
		if p:CheckCollapsed( {expr[tok-1], expr[tok+1]} ) then
			func = {GREATER, expr[tok-1], expr[tok+1] }
		else
			return p:SyntaxError("GREATER")
		end if
	end if
	
	return expr[1..tok-2] & {func} & expr[tok+2..length(expr)]
end function

function CLess( sequence expr, integer tok )
	sequence func
	func = expr[tok]
	if tok = 1 then
		return {{ INVALID, "< : Cannot find lhs arg", {}}}
	elsif tok = length(expr) then
		return {{ INVALID, "< : Cannot find rhs arg", {}}}
	else
		if p:CheckCollapsed( {expr[tok-1], expr[tok+1]} ) then
			func = {LESS, expr[tok-1], expr[tok+1] }
		else
			return p:SyntaxError("<")
		end if
	end if
	
	return expr[1..tok-2] & {func} & expr[tok+2..length(expr)]
end function

function CGoe( sequence expr, integer tok )
	sequence func
	func = expr[tok]
	
	if tok = 1 then
		return {{ INVALID, ">= : Cannot find lhs arg", {}}}
	elsif tok = length(expr) then
		return {{ INVALID, ">= : Cannot find rhs arg", {}}}
	else
		if p:CheckCollapsed( {expr[tok-1], expr[tok+1]} ) then
			func = {GOE, expr[tok-1], expr[tok+1] }
		else
			return p:SyntaxError(">=")
		end if
	end if
	
	return expr[1..tok-2] & {func} & expr[tok+2..length(expr)]
end function

function CLoe( sequence expr, integer tok )
	sequence func
	func = expr[tok]
	if tok = 1 then
		return {{ INVALID, "<= : Cannot find lhs arg", {}}}
	elsif tok = length(expr) then
		return {{ INVALID, "<= : Cannot find rhs arg", {}}}
	else
		if p:CheckCollapsed( {expr[tok-1], expr[tok+1]} ) then
			func = {LOE, expr[tok-1], expr[tok+1] }
		else
			return p:SyntaxError("<= ")
		end if
	end if
	
	return expr[1..tok-2] & {func} & expr[tok+2..length(expr)]
end function

function CBetween( sequence expr, integer tok )
	sequence func
	func = expr[tok]
	if tok = 1 then
		return {{ INVALID, "BETWEEN: Cannot find lhs arg", {}}}
	elsif tok = length(expr) or expr[tok+1][FUNC] != AND then
		return {{ INVALID, "BETWEEN: Invalid or missing rhs arg", {}}}
	else
		if p:CheckCollapsed( {expr[tok-1], expr[tok+1]} ) then
			func = {BETWEEN, expr[tok-1], expr[tok+1][ARG1..ARG2] }
		else
			return p:SyntaxError("BETWEEN")
		end if
	end if
	
	return expr[1..tok-2] & {func} & expr[tok+2..length(expr)]
end function

function PPNot( sequence a, sequence b )
	return "(NOT " & call_func( pp:PPEXP[ a[FUNC] ], a[ARG1..ARG2] ) 
		& ")"
end function

function PPOr( sequence a, sequence b )
	return "(" & call_func( pp:PPEXP[ a[FUNC] ], a[ARG1..ARG2] ) &
		" OR " & call_func( pp:PPEXP[ b[FUNC] ], b[ARG1..ARG2] )
		& ")"
end function

function PPAnd( sequence a, sequence b )

	return "(" & call_func( pp:PPEXP[ a[FUNC] ], a[ARG1..ARG2] ) &
		" AND " & call_func( pp:PPEXP[ b[FUNC] ], b[ARG1..ARG2] )
		& ")"
end function

function PPEqualTo( sequence a, sequence b )
	return "(" & call_func( pp:PPEXP[ a[FUNC] ], a[ARG1..ARG2] ) &
		" = " & call_func( pp:PPEXP[ b[FUNC] ], b[ARG1..ARG2] )
		& ")"
end function

function PPNotEqual( sequence a, sequence b )
	return "(" & call_func( pp:PPEXP[ a[FUNC] ], a[ARG1..ARG2] ) &
		" != " & call_func( pp:PPEXP[ b[FUNC] ], b[ARG1..ARG2] )
		& ")"
end function

function PPNotEqualSQL( sequence a, sequence b )
	return "(" & call_func( pp:PPEXP[ a[FUNC] ], a[ARG1..ARG2] ) &
		" <> " & call_func( pp:PPEXP[ b[FUNC] ], b[ARG1..ARG2] )
		& ")"
end function

function PPGreater( sequence a, sequence b )
	return "(" & call_func( pp:PPEXP[ a[FUNC] ], a[ARG1..ARG2] ) &
		" > " & call_func( pp:PPEXP[ b[FUNC] ], b[ARG1..ARG2] )
		& ")"
end function

function PPLess( sequence a, sequence b )
	return "(" & call_func( pp:PPEXP[ a[FUNC] ], a[ARG1..ARG2] ) &
		" < " & call_func( pp:PPEXP[ b[FUNC] ], b[ARG1..ARG2] )
		& ")"
end function

function PPGoe( sequence a, sequence b )
	return "(" & call_func( pp:PPEXP[ a[FUNC] ], a[ARG1..ARG2] ) &
		" >= " & call_func( pp:PPEXP[ b[FUNC] ], b[ARG1..ARG2] ) & ")"
end function

function PPLoe( sequence a, sequence b )
	return "(" & call_func( pp:PPEXP[ a[FUNC] ], a[ARG1..ARG2] ) &
		" <= " & call_func( pp:PPEXP[ b[FUNC] ], b[ARG1..ARG2] ) & ")"
end function

function PPBetween( sequence a, sequence b )
	return "(" & call_func( pp:PPEXP[ a[FUNC] ], a[ARG1..ARG2] ) &
		" BETWEEN " & call_func( pp:PPEXP[ b[1][FUNC] ], b[1][ARG1..ARG2] )
		& " AND " & call_func( pp:PPEXP[ b[2][FUNC] ], b[2][ARG1..ARG2] )
		& ")"
end function

function PPLike( sequence a, sequence b )
	return "(" & call_func( pp:PPEXP[ a[FUNC] ], a[ARG1..ARG2] ) &
		" LIKE " & call_func( pp:PPEXP[ b[FUNC] ], b[ARG1..ARG2] ) & ")"
end function


function PPIn( sequence a, sequence b )
	sequence p
	p = "(" & call_func( pp:PPEXP[ a[FUNC] ], a[m:ARG1..m:ARG2] ) & " IN( "
	for i = 1 to length(b) do
		if i > 1 then
			p &= ", "
		end if
		p &= call_func( pp:PPEXP[ b[i][FUNC] ], b[i][ARG1..ARG2] )
	end for
	p &= ")"
	return p
end function

procedure boolean_init()
	CONSTANT = m:resolve_math_ref( "CONSTANT" )
	INVALID = m:resolve_math_ref( "INVALID" )
	VAR = m:resolve_math_ref( "VAR" )
	POLYNOMIAL = m:resolve_math_ref( "POLYNOMIAL" )
	DATA = m:resolve_math_ref( "DATA" )
	LPAR = m:resolve_math_ref( "LPAR" )
	RPAR = m:resolve_math_ref( "RPAR" )
	
	NOT = m:reg_math_func( "NOT", routine_id("Not") )
	OR = m:reg_math_func( "OR", routine_id("Or") )
	AND = m:reg_math_func( "AND", routine_id("And") )
	LIKE = m:reg_math_func( "LIKE", routine_id("Like") )
	EQUALTO = m:reg_math_func( "EQUALTO", routine_id("EqualTo"))
	NOTEQUAL = m:reg_math_func( "NOTEQUAL", routine_id("NotEqual"))
	NOTEQUAL_SQL = m:reg_math_func( "NOTEQUAL_SQL", routine_id("NotEqual"))
	GREATER = m:reg_math_func( "GREATER", routine_id("Greater"))
	LESS = m:reg_math_func( "LESS", routine_id("Less"))
	GOE = m:reg_math_func( "GOE", routine_id("GreaterOrEqual"))
	LOE = m:reg_math_func( "LOE", routine_id("LessOrEqual"))
	BETWEEN = m:reg_math_func( "BETWEEN", routine_id("Between"))
	IN = m:reg_math_func( "IN", routine_id("In"))
	
	p:reg_parse_func( "NOT", "NOT", routine_id("CNot"), 1, 5 )
	p:reg_parse_func( "OR", "OR", routine_id("COr"), 2, 6)
	p:reg_parse_func( "AND", "AND", routine_id("CAnd"), 2, 6)
	p:reg_parse_func( "LIKE", "LIKE", routine_id("CLike"), 2, 6)
	p:reg_parse_func( "EQUALTO", "=", routine_id("CEqualTo"), 2, 5)
	p:reg_parse_func( "GREATER", ">", routine_id("CGreater"), 2, 5)
	p:reg_parse_func( "LESS", "<", routine_id("CLess"), 2, 5)
	p:reg_parse_func( "GOE", ">=", routine_id("CGoe"), 2, 5)
	p:reg_parse_func( "LOE", "<=", routine_id("CLoe"), 2, 5)
	p:reg_parse_func( "BETWEEN", "BETWEEN", routine_id("CBetween"), 2, 5)
	p:reg_parse_func( "NOTEQUAL", "!=", routine_id("CNotEqual"), 2, 5)
	p:reg_parse_func( "NOTEQUAL_SQL", "<>", routine_id("CNotEqual"), 2, 5)
	p:reg_parse_func( "IN", "IN", routine_id("CIn"), 2, 5)
	
	m:pretty_print( NOT, routine_id("PPNot"))
	m:pretty_print( OR, routine_id("PPOr"))
	m:pretty_print( AND, routine_id("PPAnd"))
	m:pretty_print( LIKE, routine_id("PPLike"))
	m:pretty_print( EQUALTO, routine_id("PPEqualTo"))
	m:pretty_print( GREATER, routine_id("PPGreater"))
	m:pretty_print( LESS, routine_id("PPLess"))
	m:pretty_print( GOE, routine_id("PPGoe"))
	m:pretty_print( LOE, routine_id("PPLoe"))
	m:pretty_print( BETWEEN, routine_id("PPBetween"))
	m:pretty_print( IN, routine_id("PPIn"))
	m:pretty_print( NOTEQUAL, routine_id("PPNotEqual"))
	m:pretty_print( NOTEQUAL_SQL, routine_id("PPNotEqualSQL"))
end procedure
m:add_math_init( routine_id("boolean_init") )
