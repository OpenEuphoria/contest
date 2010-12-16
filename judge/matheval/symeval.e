-- symeval.e
-- Matt Lewis (matthewwalkerlewis@yahoo.com)
-- http://www14.brinkster.com/matthewlewis
--
-- Version 1.1

--/topic Algebra
--/info
--Using variables and doing algebra
--
--Variables in matheval are very powerful.  They can hold any matheval expression
--as their value.  This means that in addition to constants, they can hold functions 
--and even other variables, which can in turn hold any matheval expression.
--
--Variables may be assigned values using either /SetVar() or through parsing and
--evaluating the ':=' operator.  To clear the value of a variable, set it equal
--to itself ('x:=x'), or use /ClearVar().  To determine the value of a variable,
--call /Evaluate().
--/code
--ex:
--    sequence f, y
--
--    -- f(x) = x + 1
--   f = /Evaluate( /Parse( "f:=x+1") )
--
--    -- output a pretty print of f
--   printf(1, "F(X) = %s\n", { /PPExp( f ) } )
--
--    for x = 1 to 5 do
--       /SetVar( "X", x )
--
--        -- y = f(x)
--       y = /Evaluate( f )
--       printf(1, "F(%d) = %s\n", {x, /PPExp(y)} )
--    end for
--/endcode

--/topic Symeval Changes
--/parent Changes
--/info
--
--/code
-- Version 1.11
-- * Improved polynomial recognition for cases like: (x-1)*3
--
-- Version 1.1
--* Improved simplification to recognize cases like (x/y)*y = x
--/endcode

integer ADD, SUBTRACT, MULTIPLY, CONSTANT, EXPONENT, TRANSPOSE, INVALID,
    POLYNOMIAL, VAR, DIVIDE, SETEQUAL


global integer EVALUATE_S, MAKEPOLYNOMIAL

include std/convert.e
include matheval.e as m
include misceval.e as mi
include parseval.e as p

sequence no_simplify
no_simplify = {{},{}}

--/topic Extensions
--/proc set_simplify( integer ref, integer simp )
--
--This can be called to identify expression types that should not be
--simplified (i.e., scripting commands).
global procedure set_simplify( integer ref, integer simp )
	integer ix
	ix = find(ref, no_simplify[1])
	if not ix then
		no_simplify[1] &= ref
		no_simplify[2] &= simp
	else
		no_simplify[2][ix] = simp
	end if
end procedure

function CompactExpr( sequence expr, integer func )

    while length(expr) > 1 do  
        expr[1] = { func, expr[1], expr[2] }
        expr = {expr[1]} & expr[3..length(expr)]
    end while
    
    expr = expr[1]
    
    return expr
end function

function ExpandAddition( sequence expr )
    integer ix
    
    expr = { expr }
    ix = 1
    
    while ix <= length(expr) do
        if expr[ix][FUNC] = ADD then
            expr = expr[1..ix-1] & {expr[ix][ARG1]} & {expr[ix][ARG2]} & 
                expr[ix+1..length(expr)]
        
        elsif expr[ix][FUNC] = SUBTRACT then
            expr = expr[1..ix-1] & {expr[ix][ARG1]} & {expr[ix][ARG2]} & 
                expr[ix+1..length(expr)]
            
            if expr[ix+1][FUNC] = CONSTANT then
                expr[ix+1][ARG1] *= -1
            
            elsif expr[ix+1][FUNC] = VAR then
                expr[ix+1][ARG2] *= -1
            
            else
                expr[ix+1] = { MULTIPLY, {CONSTANT, {-1},{}}, expr[ix+1] }
            end if
        else
            ix += 1
        end if
    end while      
    
    return expr
end function



function ExpandMult( sequence expr )
    integer ix, jx
    atom exp
    sequence term, bits
    ix = 1
    
    if m:matheval_seq( expr ) then
        expr = { expr }
    end if
    
    while ix <= length(expr) do
        if expr[ix][FUNC] = MULTIPLY then 
            expr[ix] = { expr[ix][ARG1], expr[ix][ARG2] } 
            for i = 1 to 2 do
                term = ExpandMult( expr[ix][i] )
                expr[ix] &= term
            end for
            
            jx = 3
            while jx <= length(expr[ix]) do
                if not m:matheval_seq( expr[ix][jx] ) then
                    expr[ix] = expr[ix][1..jx-1] & 
                        expr[ix][jx][1..length(expr[ix][jx])] &
                        expr[ix][jx+1..length(expr[ix])]
                end if
                jx += 1
            end while
            
            expr[ix] = expr[ix][3..length(expr[ix])]

		elsif expr[ix][FUNC] = DIVIDE then

			expr[ix] = { expr[ix][ARG1], expr[ix][ARG2] }

			
			term = ExpandMult( expr[ix][1] )
			-- when there's actually something to expand,
			-- then will be added layer of sequences...
			if not m:matheval_seq(term[1]) then
				for i = 1 to length(term) do
					expr[ix] &= term[i]
				end for
			else
				expr[ix] &= term
			end if


            term = ExpandMult( expr[ix][2] )

            for i = 1 to length(term) do
            	expr[ix] &= {{EXPONENT, term[i], {CONSTANT,{-1},{}}}}
            end for

            expr[ix] = expr[ix][3..length(expr[ix])]

        elsif 0 and expr[ix][FUNC] = EXPONENT 
        and expr[ix][ARG2][FUNC] = CONSTANT 
        and not find( expr[ix][ARG1][FUNC], {CONSTANT, VAR} & p:UNARY ) then       
        
            exp = expr[ix][ARG2][ARG1][1]
            
            if integer(exp) and exp >= 1 then
                -- expr[ix] = repeat(expr[ix][ARG1], exp )
                bits = int_to_bits( exp, 32 )
                jx = 1
                expr[ix] = expr[ix][ARG1]
                
                term =  expr[ix] 
                expr[ix] = {}
                
                while find(1, bits[jx..32]) do
                    if bits[jx] then
                        expr[ix] &= {term}
                    end if
                    term = m:Evaluate( {MULTIPLY, term, term } )
                    
                    jx += 1
                end while  
                
                --for i = 1 to length( expr[ix] ) do
                --    expr &= ExpandAddition( expr[ix][i] )
                --end for
                --expr[ix] = ONE
                --expr = {expr}
                --expr[ix] = {call_func( MAKEPOLYNOMIAL, { expr[ix] } )}
            end if
        --else    
        --    ix += 1
        end if
        ix += 1
    end while
    
    return expr
end function


-- returns a list of all variables used in an expression
-- NOTE: this will not find variables 'embedded' within
--       other variables
global function ListVars( sequence expr )
    sequence vars
    integer ix, jx
    vars = {}    
    
    if expr[FUNC] = VAR then
        return {expr[ARG1]}
    elsif expr[FUNC] = POLYNOMIAL then
        return { expr[ARG1] }
    else
        if matheval_seq( expr[ARG1] ) then
            vars = ListVars( expr[ARG1] )
        end if
        if matheval_seq( expr[ARG2] ) then
            vars &= ListVars( expr[ARG2] )
        end if
    end if
    
    ix = 1
    while ix <= length( vars ) do
        jx = find( vars[ix],vars[ix+1..length(vars)] )
        if jx or not length(vars[ix]) then
            vars = vars[1..ix+jx-1] & vars[ix+jx+1..length(vars)]
        else
            ix += 1
        end if
    end while
    
    return vars
end function

function MakeDegree( sequence poly, integer degree )
    integer d
    d = degree - length(poly[ARG2])
    if d > 0 then
        poly[ARG2] &= repeat( 0, d )
    end if
    return poly
end function

function PosCoef( sequence poly )
    integer pos
    
    pos = 0
    
    for i = 1 to length(poly[ARG2]) do
        if poly[ARG2][i] then
            pos += 1
        end if
    end for
    
    return pos
end function

function max_coef( sequence coef )
	integer max
	max = 0
	for i = 1 to length(coef) do
		if coef[i] then
			max = i
		end if
	end for
	return coef[1..max]
end function

-- Try to transform an expression into a polynomial
--POLYNOMIAL = 7,         -- {POLYNOMIAL, var, a_n}
                          -- var is variable name, a_n = {a_0, ... a_n}
global function MakePolynomial( sequence expr )
    integer ex, ix, vx
    atom const
    sequence poly, vars, reduce, temp, orig
    
    orig = expr
    
    const = 0
    vars = ListVars( expr )
    if not length(vars) then
        return expr
    end if
    
    -- each variable could have it's own polynomial
    poly = repeat( {POLYNOMIAL, "", { 0 }}, length(vars))
    for i = 1 to length( poly ) do
        poly[i][ARG1] =  vars[i]
    end for
    
    ix = 1
    expr = ExpandAddition( expr )

    while ix <= length( expr ) do
        if expr[ix][FUNC] = VAR then
            -- it's a variable, so we'll add it to its polynomial
            vx = find(expr[ix][ARG1], vars )
            ex = 2       
            
            -- make sure its at least degree 1 (ex-1)
            poly[vx] = MakeDegree( poly[vx], ex )
            poly[vx][ARG2][ex] += expr[ix][ARG2][1]
            
            expr = expr[1..ix-1] & expr[ix+1..length(expr)]
            
        elsif expr[ix][FUNC] = EXPONENT and expr[ix][ARG1][FUNC] = VAR and 
              expr[ix][ARG2][FUNC] = CONSTANT and 
              integer(expr[ix][ARG2][ARG1][1]) and expr[ix][ARG2][ARG1][1] then
        -- x ^ a_n
            
            -- find the var we're working with  
            vx = find(expr[ix][ARG1][ARG1], vars )
            
            -- determine the exponent degree
            ex = expr[ix][ARG2][ARG1][1] + 1

			if ex > 0 then
	            poly[vx] = MakeDegree( poly[vx], ex )
	            poly[vx][ARG2][ex] += expr[ix][ARG1][ARG2][1]				
	            expr = mi:RemoveOne( expr, ix )
	        else
--
--	        	-- negative exponent??
--	        	for i = 0 to ex by -1 do
--		        	poly[vx][ARG2] = poly[vx][ARG2][2..length(poly[vx][ARG2])] & 0	        		
--	        	end for
--

				ix += 1
			end if            

            
            
        elsif expr[ix][FUNC] = CONSTANT then
            const += expr[ix][ARG1][1]
            expr = expr[1..ix-1] & expr[ix+1..length(expr)]
            
        elsif expr[ix][FUNC] = POLYNOMIAL then
            -- find the var we're working with
            vx = find(expr[ix][ARG1], vars )
            
            ex = length( expr[ix][ARG2] )
            
            -- make sure both are same length, so we can add the 
            -- coefficients together
            poly[vx] = MakeDegree( poly[vx], ex )
            expr[ix] = MakeDegree( expr[ix], length(poly[vx][ARG2]) )
            
            poly[vx][ARG2] += expr[ix][ARG2]
            expr = mi:RemoveOne( expr, ix )
            
        elsif expr[ix][FUNC] = MULTIPLY then           
            -- this checks for case like 3x^2 (not (3x)^2)
            
            temp = expr[ix][ARG1][FUNC] & expr[ix][ARG2][FUNC]
            if find( EXPONENT, temp) and find( CONSTANT, temp ) then
                
                temp = expr[ix][ARG1..ARG2]
                
                -- make sure the constant is in temp[1]
                -- and the exponentiation is in temp[2]
                if temp[1][FUNC] != CONSTANT then
                    temp = {temp[2] , temp[1]  }
                end if
                
                -- only concerned with x ^ a where a is pos int
                if temp[2][ARG1][FUNC] = VAR and
                        temp[2][ARG2][FUNC] = CONSTANT and 
                        integer(temp[2][ARG2][ARG1][1]) and
                        temp[2][ARG2][ARG1][1] > 0 then
                    
                    ex = temp[2][ARG2][ARG1][1] + 1
                    vx = find( temp[2][ARG1][ARG1] , vars )
                    
                    poly[vx] = MakeDegree( poly[vx], ex )
                    poly[vx][ARG2][ex] += temp[1][ARG1][1]
                    
                    expr = mi:RemoveOne( expr, ix )
                
                else
                    ix += 1
                end if
            elsif find( CONSTANT, temp ) and find( POLYNOMIAL, temp ) then
            -- a polynomial * a constant...multiply it out...
            	temp = make_first( expr[ix][ARG1..ARG2], POLYNOMIAL )

            	temp[1][ARG2] *= temp[2][ARG1][1]

            	ex = length(temp[1][ARG2] )
            	vx = find( temp[1][ARG1], vars )
            	poly[vx] = MakeDegree( poly[vx], ex )

            	for i = 1 to ex do
	            	poly[vx][ARG2][i] += temp[1][ARG2][i]            		
            	end for

				expr = mi:RemoveOne( expr, ix )

            else
                ix += 1
            end if
        else
            ix += 1
        end if    
        
    end while
    
    -- put the constant in the first polynomial
    poly[1][ARG2][1] += const
    poly[1][ARG2] = max_coef( poly[1][ARG2] )
    reduce = {}
    for i = 1 to length( poly ) do
        if PosCoef( poly[i] ) <= 1 then
            -- this isn't a real polynomial, so we'll reduce it to 
            -- whatever it really is
            ix = 1
            while ix <= length(poly[i][ARG2]) do
                if poly[i][ARG2][ix] then
                    if ix = 1 then
                        -- just a constant
                        reduce &= {{CONSTANT, {poly[i][ARG2][ix]}, {} }}
                            
                    else
                        if ix > 2 then
                            -- we'll reduce this to a variable with an exponent
                            if poly[i][ARG2][ix] = 1 then
                                reduce &= {{EXPONENT, {VAR, poly[i][ARG1], {1}},
                                                            {CONSTANT, {ix-1},{}} }}
                            else
                                reduce &= {{MULTIPLY,{CONSTANT, {poly[i][ARG2][ix]},{}},
                                                {EXPONENT, {VAR, poly[i][ARG1], {1}},
                                                            {CONSTANT, {ix-1},{}} }}}
                            end if
                        else
                            reduce &= {{VAR, poly[i][ARG1], {poly[i][ARG2][ix]}}}
                        end if
                            
                    end if
                end if
                ix += 1
            end while
        else
            reduce &= {poly[i]}
        end if
    end for
    
    expr &= reduce
    
    while length(expr) > 1 do
        expr = { {ADD, expr[1], expr[2]} } & expr[3..length(expr)]
    end while

	if length(expr) then
		return expr[1]
	else
		return {CONSTANT, {1},{}}
	end if    

end function
MAKEPOLYNOMIAL = routine_id("MakePolynomial")


function NextFunc( sequence expr, integer func )
    integer ix
    
    ix = 1
    
    while ix <= length(expr) do
        if expr[ix][FUNC] = func then
            return ix
        end if
        ix += 1
    end while
    
    return 0
end function


function MultiplyOut( sequence expr )
    integer func, ix, jx, kx
    sequence rest, temprest, bits, term
    object exp
    
    if find( ZERO, expr ) then
        return ZERO
    end if
    
    
    ix = 2
    -- move exponents to the front...
    while ix <= length(expr) do
        if expr[ix][FUNC] = EXPONENT and expr[ix][ARG1][FUNC] = VAR then
            expr = {expr[ix]} & mi:RemoveOne( expr, ix )
        end if     
        ix += 1
    end while
    
    ix = 1

    while ix <= length(expr) do
        func = expr[ix][FUNC]
        rest = expr[ix+1..length(expr)] 
        
        -- First we handle variables with exponents, since they can suck up 
        -- extra variables
        if func = EXPONENT then
        
            if expr[ix][ARG1][FUNC] = VAR then
            
                jx = 1
                while jx <= length( rest ) do
                    if rest[jx][FUNC] = VAR then
                    -- we found a variable match
                        if equal(expr[ix][ARG1][ARG1], rest[jx][ARG1]) then
                            expr[ix][ARG2] = {ADD, expr[ix][ARG2], ONE}
                            expr[ix+jx] = {CONSTANT, expr[ix+jx][ARG2], {}}
                            rest[jx] = expr[ix+jx]
                            jx += 1
						else
                          	jx += 1
                        end if
                        
                    elsif rest[jx][FUNC] = EXPONENT then
                    -- there's another var with exponent
                            expr[ix][ARG2] = {ADD, expr[ix][ARG2], rest[jx][ARG2]}
                            expr = RemoveOne( expr, ix+jx )
                            rest = RemoveOne( rest, jx )
                            
                    else
                        jx += 1
                    end if
                end while
                expr[ix][ARG2] = call_func(SIMPLIFY, {expr[ix][ARG2]} )
                
            elsif expr[ix][ARG2][FUNC] = CONSTANT 
            and not find( expr[ix][ARG1][FUNC], {CONSTANT, VAR} & p:UNARY ) 
            then
                -- Expand something within an exponent       
                exp = expr[ix][ARG2][ARG1][1]
            
                if integer(exp) and exp >= 1 then
                    
                    -- we'll have a maximum of 32 operations, so big
                    -- exponents will be handled efficiently
                    bits = int_to_bits( exp, 32 )
                    jx = 1
                    expr[ix] = expr[ix][ARG1]
                    
                    -- term will hold the value for the exponent we're 
                    -- currently working on
                    
                    term =  MakePolynomial(expr[ix] )
                    expr[ix] = ONE
                    
                    -- this operation would be equivalent to:
                    -- term[1] = expr[ix] ^ (2^0)
                    -- term[2] = expr[ix] ^ (2^1)
                    -- term[3] = expr[ix] ^ (2^2)
                    -- ...
                    -- term *= bits  (we're only concerned where bits[i]=1)
                    -- and multiply out the non-zero 'term' elements
                    --
                    -- expr[ix] ^ 13 = -- 13 = {1,0,1,1}
                    --   expr[ix] ^ 1 * expr[ix] ^ 4 * expr[ix] ^ 8
                    while find(1, bits[jx..32]) do
                        
                        if bits[jx] then
                            expr[ix] = Evaluate( {MULTIPLY, expr[ix],term })
                        end if
                        term = Evaluate( {MULTIPLY, term, term } )
                    
                        jx += 1
                    end while  
                end if
                
            end if    
            
        elsif func = CONSTANT then
            
            jx = 1
            while jx do
                jx = NextFunc( rest, CONSTANT )
                if jx then
                    expr[ix] = {CONSTANT, expr[ix][ARG1] * rest[jx][ARG1],{}}
                    expr = expr[1..ix+jx-1] & expr[ix+jx+1..length(expr)]
                    rest = rest[1..jx-1] & rest[jx+1..length(rest)]
                end if
            end while
            
            jx = 1
            while jx do
                jx = NextFunc( rest, VAR)
                if jx then
                    expr[ix] = {VAR, rest[jx][ARG1], 
                                expr[ix][ARG1] * rest[jx][ARG2]}
                    expr = expr[1..ix+jx-1] & expr[ix+jx+1..length(expr)]
                    rest = rest[1..jx-1] & rest[jx+1..length(rest)]
                end if
            end while
            
            jx = 1
            while jx do
                jx = NextFunc( rest, POLYNOMIAL)
                if jx then
                    expr[ix] = {POLYNOMIAL, rest[jx][ARG1], 
                                expr[ix][ARG1][1] * rest[jx][ARG2]}
                    expr = expr[1..ix+jx-1] & expr[ix+jx+1..length(expr)]
                    rest = rest[1..jx-1] & rest[jx+1..length(rest)]
                end if
            end while
            
        elsif func = VAR then
            
            jx = 1
            while jx do
                jx = NextFunc( rest, CONSTANT )
                if jx then
                    expr[ix] = {VAR, expr[ix][ARG1], 
                                rest[jx][ARG1][1] * expr[ix][ARG2]}
                    expr = expr[1..ix+jx-1] & expr[ix+jx+1..length(expr)]
                    rest = rest[1..jx-1] & rest[jx+1..length(rest)]
                end if
            end while
            
            jx = 1
            temprest = rest
            while jx do
                jx = NextFunc( rest, VAR )
                if jx then
                
                    if equal(expr[ix][ARG1], rest[jx][ARG1]) then
                        
                        expr[ix] =  { EXPONENT,
                                    {VAR, expr[ix][ARG1], 
                                    rest[jx][ARG2][1] * expr[ix][ARG2]},
                                    TWO }
                                    
                        expr = mi:RemoveOne( expr, ix + jx )
                        --expr = expr[1..ix+jx-1] & expr[ix+jx+1..length(expr)]
                        
                        ix -= 1
                        exit
                    else
                        rest = rest[1..jx-1] & rest[jx+1..length(rest)]
                    end if
                end if
            end while
            rest = temprest
            
            jx = 1
            temprest = rest
            while jx do
                jx = NextFunc( rest, POLYNOMIAL )
                if jx then
                    if equal(expr[ix][ARG1], rest[jx][ARG1]) then
						-- polynomial of same variable                        
                        rest[jx][ARG2] = expr[ix][ARG2][1] * 
                                        prepend( rest[jx][ARG2], 0 )
                        
                        expr = {rest[jx]} & expr[2..ix+jx-1] & 
                                expr[ix+jx+1..length(expr)]
                        
                        rest = rest[1..jx-1] & rest[jx+1..length(rest)]
                                
                        temprest = rest
                    else
                        rest = rest[1..jx-1] & rest[jx+1..length(rest)]
                    end if
                end if
            end while
            rest = temprest
    
        end if
        
        -- should we try to multiply out among polynomials here?
--        rest = expr[ix]
--        jx = NextFunc( rest, POLYNOMIAL )
--        while jx do
--        	-- poly vx var
--        	-- poly vs const?
--        	-- poly vs poly
--        	kx = 1
--        	
--        	while kx <= length(rest) do
--        		func = rest[kx]
--
--        		if func = VAR then
--        			term = { VAR, 
--        		elsif func = POLYNOMIAL then
--        			
--        		elsif func = CONSTANT then
--        			
--        		end if
--        	end for
--        	
--        	jx = NextFun( rest, POLYNOMIAL )
--        end while
        
        ix += 1
    end while

	-- anything to the zero goes to one...
	for i = 1 to length(expr) do
		if expr[i][FUNC] = EXPONENT and equal(expr[i][ARG2], ZERO) then
			expr[i] = ONE
		end if
	end for
    
    ix = find(ONE, expr )
    while ix do
        expr = mi:RemoveOne(expr, ix)
        ix = find(ONE, expr )
    end while
    
    
    expr = CompactExpr( expr, MULTIPLY )
    
    return expr
end function

function LikeTerms( sequence expr )
    integer ix, jx, func
    sequence add, sum, term
    
    expr = ExpandAddition( expr )
    
    for i = 1 to length(expr) do
    -- see if we can simplify any of the addends
        if expr[i][FUNC] = MULTIPLY then
            
            term = ExpandMult( expr[i] )
            term = term[1]
            for j = 1 to length(term) do
                    term[j] = call_func(SIMPLIFY, { term[j] } )
            end for
            
            expr[i] = CompactExpr( term, MULTIPLY )
        elsif expr[i][FUNC] = EXPONENT then
            expr[i] = MultiplyOut( {expr[i]} )
        end if
    
    end for
    
    ix = 1
    while ix < length(expr) do
        -- now we add together like terms
        jx = find( expr[ix], expr[ix+1..length(expr)] )
        if jx then
            
--            expr[ix] = call_func(Operation[ADD], { expr[ix], expr[ix+jx]} )
			expr[ix] = m:call_op( {ADD, expr[ix], expr[ix+jx] })
            expr = expr[1..ix+jx-1] & expr[ix+jx+1..length(expr)]
        
        else
            func = expr[ix][FUNC]
            jx = 1
            while ix + jx <= length(expr) do

                if func = expr[ix+jx][FUNC] then
                    
                    add = {ADD, expr[ix], expr[ix+jx]}
--                    sum = call_func( Operation[ADD], { add[2], add[3] } )
					sum = m:call_op( ADD & add[2..3] )
                    -- This may cause problems if variables
                    -- have values.
                    
                    if not equal( add, sum ) then
                        expr[ix] = sum
                        expr = expr[1..ix+jx-1] & expr[ix+jx+1..length(expr)]
                    else
                        jx += 1
                    end if
                else
                    jx += 1
                end if
                
            end while
            
            ix += 1
        end if
        
    end while
    
    expr = CompactExpr( expr, ADD )
    return MakePolynomial( expr )
    
end function

--/topic Algebra
--/func Simplify( sequence expr )
--/ret Algebraically simplified matheval sequence.
-- Simplify attempts to put the expression (which is a matheval sequence)
-- into an algebraically simplified form by multiplying out, grouping 
-- and adding like terms and putting variables into polynomials.
--/code
--ex:
--        (X / Y) * Y     ==> X
--         X + 1 + 3 + X   ==> 2X + 4
--         X*X^2         ==> X^3
--/endcode


global function Simplify( sequence expr )
    integer ix, jx
    sequence term

	ix = find( expr[FUNC], no_simplify[1] )
	if ix then
		if not no_simplify[2][ix] then
			return expr
		end if
	end if
	
	StoreVars()
	if expr[FUNC] = SETEQUAL then
		expr = { SETEQUAL, expr[ARG1], Simplify( expr[ARG2] ) }
	else
		expr = m:Evaluate( expr )
	end if
	
	m:RestoreVars()

    expr = LikeTerms( expr )
    expr = ExpandAddition( expr )
    
    -- Now we look for stuff like multiplication / division
    ix = 1
    term = {}
    for i = 1 to length(expr) do    
        term = ExpandMult( {expr[i]} )
        
        if not equal(term[1][FUNC], EXPONENT ) then
            term = term[1]
        end if
        
        if not equal(term, expr[i]) 
        or term[FUNC] = EXPONENT then
        -- There was something to expand!
            expr[i] = MultiplyOut( term )
        end if
        
    end for
    
    expr = CompactExpr( expr, ADD )
    expr = LikeTerms( expr )
    
    return expr
end function
SIMPLIFY = routine_id( "Simplify" )

--/topic Algebra
--/func Evaluate_s( expression )
--
--Calls /Evaluate() and then /Simplify().
global function Evaluate_s( sequence expression )
    sequence test
    test = {}
    while not equal(test, expression) do
        test = expression
--        expression = call_func( Operation[expression[FUNC]], 
--                      {expression[ARG1], expression[ARG2]} )
			expression = m:call_op( expression )
    end while                  
    return Simplify( expression )
end function
EVALUATE_S = routine_id( "Evaluate_s" )

global function FactorPolynomial( sequence expr )
    sequence factors
    integer m, ix
    
    factors = {}
    m = min_pos_ix( expr[ARG2] )
    
    -- factor out any var's we can...
    -- ie x^2+x -> x(x+1)
    if m > 1 then
        if m > 2 then
            factors &= {{ EXPONENT, {VAR, expr[ARG1], {1}},
                        {CONSTANT, {m-1}}}}
        else
            factors &= {{VAR, expr[ARG1], {1}}}
        end if
        
        expr[ARG2] = expr[ARG2][m..length(expr[ARG2])]
    end if
    
    expr = CompactExpr( {expr} & factors , MULTIPLY )
    return expr
end function

procedure symbolic_init()
    ADD = m:resolve_math_ref( "ADD" )
    VAR = m:resolve_math_ref( "VAR" )
    SUBTRACT = m:resolve_math_ref( "SUBTRACT" )
    MULTIPLY = m:resolve_math_ref( "MULTIPLY" )
    CONSTANT = m:resolve_math_ref( "CONSTANT" )
    EXPONENT = m:resolve_math_ref( "EXPONENT" )
    INVALID = m:resolve_math_ref( "INVALID" )
    POLYNOMIAL = m:resolve_math_ref( "POLYNOMIAL" )
    DIVIDE = m:resolve_math_ref( "DIVIDE" )
    SETEQUAL = m:resolve_math_ref( "SETEQUAL" )
end procedure
m:add_math_init( routine_id("symbolic_init" ))
