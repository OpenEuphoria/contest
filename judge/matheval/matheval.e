
global constant MATHEVAL_VERSION = {2,0}

--Introduction
----------------------------

--/topic Introduction
--/info
--<h2>Matheval v2.0<br></h2>
--by Matt Lewis<br>
--<a href="mailto:mattlewis@users.sf.net">mattlewis@users.sf.net</a><br>
--<a href="http://sf.net/projects/matheval">http://sf.net/projects/matheval</a><br>
--<h3>What is matheval?</h3>
--Matheval is a library designed for evaluating mathematical expressions.  It can
--parse an expression from clear text and convert into its internal format.  (See /Expressions
--for more detail.)  My inspiriation for creating matheval comes from such packages as
--Maple or Mathematica.  I wanted to be able to do some of those sorts of things
--from within Euphoria.  
--
--Matheval will do some symbolic evaluation, including simplifying algebraic expressions.
--Variables can be created and can hold any value, including entire expressions,
--so some very powerful tasks can be accomplished using matheval.  The library has also
--been designed to be flexible enough to be extended fairly easily.
--
--Matheval can be used as a drop in component
--for an app that needs to do calculations based on user input, when the calculations 
--themselves are not known until runtime.  An example of this is what I've done in
--EuSQL.  Matheval is used to do any math, text manipulation and 
--the conditional checking needed in SQL WHERE clauses, which was why booleval.e
--was created.  It allows EuSQL to evaluate a boolean expression of any complexity,
--without any foreknowledge of what the variables or values or conditions will be.
--
--New as of v1.6, matheval has some scripting features, allowing more complex
--algorithms to be evaluated entirely within matheval.
--/code
--The MIT License
--
--Copyright (c) 2009 Matt Lewis
--
--Permission is hereby granted, free of charge, to any person obtaining a copy of this 
--software and associated documentation files (the "Software"), to deal in the Software 
--without restriction, including without limitation the rights to use, copy, modify, merge, 
--publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons 
--to whom the Software is furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all copies or 
--substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
--INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
--PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
--FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
--OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
--DEALINGS IN THE SOFTWARE.
--/endcode
--I'd like to thank:
--/li Art Adamson for his /b matrix.e file.
--/li Matthew Belmonte for fisher.c (an algorithm to perform an F-Test), which I've ported to Euphoria (see /b rgrseval.e).
--/li Gabrial Boehme for print.e, which I've turned into /b sprint.e
--
--/code
--Files:
-- * matheval.e        Main include file
-- * parseval.e        Core include file for parsing expressions
-- * ppeval.e          Core include file for printing expressions
-- * misceval.e        Core include file
-- * symeval.e         Core include file for algebraic manipulation
-- * sprint.e          Core include file for source code output
-- * booleval.e        Boolean algebra
-- * scripteval.e      Scripting with matheval
-- * datetimeval.e     Dates and times
-- * grapheval.e       Graph matheval expressions
-- * mtrxeval.e        Matrix operations
-- * matrix.e          included by mtrxeval.e
-- * calceval.e        Calculus
-- * stateqns.e        Some statistical formulae
-- * rgrseval.e        Linear regression (uses stateqns.e)
-- * solveval.e        Solving simple equations (not very well)
-- * mathdemo.ex       Simple command line interactive demo
-- * mathscript.ex     Runs matheval script files
-- * normal.txt        Script file that calulates cumulative normal probabilities
-- * normdemo.txt      Uses normal.mes to calculate some probabilities
--/endcode
--

--Changes
--------------------------------

--/topic Changes
--/info
--The history of matheval
--/code
--
-- Version 2.0.0
-- * Requires Euphoria v4.0
-- * IN() in booleval.e now handles CONSTANTs as parameters
--
-- Version 1.65.3
-- * Fixed STR parsing
--
-- Version 1.65.2
-- * Returns zero if a null passed to any of the GetDatePart functions
-- * Added comparisons for dates.  Comparison with a null value is always false.
--
-- Version 1.65.1
-- * Fixed bug when parsing an empty string ("")
--
-- Version 1.65
-- * Added datetimeval.e
--* Added /UPPER and /LOWER to texteval.e
--
-- Version 1.64
--* Added parsing, pretty print for /MATRIX, /TRANSPOSE
--* Added /SCRIPT operator to allow running files
--* Initialization in solveval was incorrect ( /NOT pretty print initialization
--  should have been for /EQUALS )
--* Added '<>' (not equals) to booleval.e
--
-- Version 1.63
--  * Fixed mtrxeval.e, rgrseval.e, stateqns.e to initialize properly
--
-- Version 1.62
-- * Fixed grapheval.e to initialize VAR and CONSTANT
-- * IN properly evaluates if first argument is a variable
--
-- Version 1.61
-- * texteval.e allows string manipulation
--
-- Version 1.6
--* scripteval.e allows /Scripting ( /IF, /BLOCK, /FOR, /GOTO, /LABEL, /EXIT)
--
-- Version 1.52
--* Added /get_math_ref()
--* Can get matheval sequence in "source code format" using /pp_source().
-- * Enhanced polynomial recognition.
-- * Enhanced pretty print routines (multiply, add, polynomial)
-- * Will multiply out polynomials and variables of where variables don't match
--
-- Version 1.51
-- * Fixed error in factorial calculations for any value over 11.
-- * Minor bugfixes and improvements to parseval.e and ppeval.e
--
-- Version 1.5
-- * Booleval.e for evaluating boolean logic
-- * Improved simplification routines in symeval.e
--
-- Version 1.4
-- * Improved simplifying routines in symeval.e.  
-- * Will expand expressions within an exponent fairly quickly now.  
-- * Tries to use polynomial multiplication.
--
-- Version 1.3
-- * A 'cumulative graphing feature, ie, growth/chaos functions.
--
-- Version 1.2
--* Change modularization method.  Added /reg_math_func, /resolve_math_func,
--  /add_to_func, /eval_addons.  Allows applications to add functions easier.
-- * Able to create polynomials and do some simplification.  Added 
--   distributive property.  Still need to work on polynomials
--   recognizing 3*x^2 as part of a polynomial.
--
-- Version 1.11
-- * Fixed bug in SetVar.  Didn't set var equal to the evaluation of
--   the parameter.  Also allow x:=x to reset x.  
-- * Changed grapheval.e to use a default value for dx if an invalid value is supplied.
--
-- Version 1.1
-- * Changed variable handling.  Variables are now allowed to have numbers
--   and underscores in them, but must not start with a number.  Also,
--   variables can now begin with same characters as built in functions.
-- * Included dummy functions for increased modular design.
--/endcode
--

--/topic Extensions
--/info
--Adding to matheval
--
--Matheval is designed to allow user libraries to be added in a modular fashion.
--Several things need to be defined and initialized in order for additions
--to matheval to work properly.  It must have a unique name and a function
--for evaluations.  It may or may not have a parse or a pretty print routine
--(matrices have neither).
--
--Its evaluation function is responsible for evaluating itself as well as
--its arguments (see /GetArgs).  It should handle all applicable cases
--for argument types, and if it cannot handle the types presented, should
--call /eval_addons() to allow additional extensions.  Likewise, to add
--support for a new matheval type to existing functions or operators, you
--should supply an evaluation function to be registered with /add_to_func()
--so that matheval will know how to deal with your new type.
--
--A matheval object is a sequence with three elements.  The first is an integer,
--and identifies the object or function type.  The second and third are the
--arguments or data for the object.  If the object only needs one argument or 
--data element, the last element should be an empty sequence.  Constants are
--defined to reference the elements of a matheval object:
--/code
--FUNC = 1
--ARG1 = 2
--ARG2 = 3
--/endcode
--For instance, matheval does not have support for complex numbers, and even
--if you add a COMPLEX matheval object, ADD would not know how to add any
--expression containing complex numbers.
--
--Evaluation functions should take two arguments (ARG1 and ARG2).  If applicable,
--it should then call /GetArgs, to make sure that the arguments have been fully
--evaluated.  Then it should deal with the arguments as appropriate, or call 
--/eval_addons() if it cannot.  It is not considered and error if no operations
--are possible.  For instance, consider the case where the expression "x+y" is
--evaluated, but either (or both) x or y has not been assigned a value.  See
--/reg_math_func() for an example evaluation function.
--
--The initialization procedure for an added file should do two things.  It should
--register the additions and also resolve any references that it needs, since
--these are never declared as global.  You will probably always need to resolve
--/b CONSTANT, and other simple functions like /b ADD or /b SUBTRACT.  Take a look
--at any matheval file for an example initializtion function.  Following is the
--initialization routine for booleval.e:
--/code
--procedure boolean_init()
--	-- need these references
--    CONSTANT = resolve_math_ref( "CONSTANT" )
--    INVALID = resolve_math_ref( "INVALID" )
--    VAR = resolve_math_ref( "VAR" )
--    POLYNOMIAL = resolve_math_ref( "POLYNOMIAL" )
--    DATA = resolve_math_ref( "DATA" )
--    LPAR = resolve_math_ref( "LPAR" )
--    RPAR = resolve_math_ref( "RPAR" )
--    
--    -- register the functions being added
--    NOT = reg_math_func( "NOT", routine_id("Not") )
--    OR = reg_math_func( "OR", routine_id("Or") )
--    AND = reg_math_func( "AND", routine_id("And") )
--    LIKE = reg_math_func( "LIKE", routine_id("Like") )
--    EQUALTO = reg_math_func( "EQUALTO", routine_id("EqualTo"))
--    NOTEQUAL = reg_math_func( "NOTEQUAL", routine_id("NotEqual"))
--    GREATER = reg_math_func( "GREATER", routine_id("Greater"))
--    LESS = reg_math_func( "LESS", routine_id("Less"))
--    GOE = reg_math_func( "GOE", routine_id("GreaterOrEqual"))
--    LOE = reg_math_func( "LOE", routine_id("LessOrEqual"))
--    BETWEEN = reg_math_func( "BETWEEN", routine_id("Between"))
--    IN = reg_math_func( "IN", routine_id("In"))
--    
--    -- register the parsing routines
--    reg_parse_func( "NOT", "NOT", routine_id("CNot"), 1, 5 )
--    reg_parse_func( "OR", "OR", routine_id("COr"), 2, 6)
--    reg_parse_func( "AND", "AND", routine_id("CAnd"), 2, 6)
--    reg_parse_func( "LIKE", "LIKE", routine_id("CLike"), 2, 6)
--    reg_parse_func( "EQUALTO", "=", routine_id("CEqualTo"), 2, 5)
--    reg_parse_func( "GREATER", ">", routine_id("CGreater"), 2, 5)
--    reg_parse_func( "LESS", "<", routine_id("CLess"), 2, 5)
--    reg_parse_func( "GOE", ">=", routine_id("CGoe"), 2, 5)
--    reg_parse_func( "LOE", "<=", routine_id("CLoe"), 2, 5)
--    reg_parse_func( "BETWEEN", "BETWEEN", routine_id("CBetween"), 2, 5)
--    reg_parse_func( "NOTEQUAL", "!=", routine_id("CNotEqual"), 2, 5)
--    reg_parse_func( "IN", "IN", routine_id("CIn"), 2, 5)
--
--	-- register the pretty print routines
--    m:pretty_print( NOT, routine_id("PPNot"))
--    m:pretty_print( OR, routine_id("PPOr"))
--    m:pretty_print( AND, routine_id("PPAnd"))
--    m:pretty_print( LIKE, routine_id("PPLike"))
--    m:pretty_print( EQUALTO, routine_id("PPEqualTo"))
--    m:pretty_print( GREATER, routine_id("PPGreater"))
--    m:pretty_print( LESS, routine_id("PPLess"))
--    m:pretty_print( GOE, routine_id("PPGoe"))
--    m:pretty_print( LOE, routine_id("PPLoe"))
--    m:pretty_print( BETWEEN, routine_id("PPBetween"))
--    m:pretty_print( IN, routine_id("PPIn"))
--
--end procedure
--add_math_init( routine_id("boolean_init") )
--/endcode

without warning
without type_check

include std/text.e

--/topic Extensions
--/func matheval_seq( object expr )
--
--Returns true (1) if /b expr is a sequence with length 3, and
--the first element is an integer, and the last two elements are
--both sequences.
global function matheval_seq( object expr )

	if sequence(expr) and length(expr) = 3 and integer(expr[1]) and
			sequence(expr[2]) and sequence(expr[3]) then
		return 1
	else
		return 0
	end if
end function


include std/wildcard.e

-- Keeps the routine_id's for the operations
global sequence Operation, OpRef, OpEx
global atom ADD_PP
sequence init_func
ADD_PP = 0
init_func = {}

Operation = {}
OpRef = {}
OpEx = {}

--/topic Extensions
--/proc add_math_init( integer id )
--
--Adds the specified procedure to the list of initialization routines
--to be called from /matheval_init().
global procedure add_math_init( integer id )
	--init_func = prepend(init_func, id)
	init_func = append(init_func, id)
end procedure 

--/topic Extensions
--/func reg_math_func( object ref, atom r_id )
--
--Should be called from within a file's initialization routine.  It 
--returns the id of the object.  /b r_id is the routine id for the
--function to be called by evaluate.  Following is the evaluation
--function for /b /FLOOR.
--/code
--ex:
--	function Floor( sequence a, sequence b )
--	    a = call_op( a )
--	        
--	    if a[FUNC] = CONSTANT then
--	        return { CONSTANT, { floor(a[ARG1][1]) }, {} }
--	    else
--	        return eval_addons( FLOOR, a, b )
--	    end if
--	    
--	end function
--/endcode
global function reg_math_func( object ref, atom r_id )
	OpRef &= { ref }
	Operation &= r_id
	OpEx &= {{}}
	return length( OpRef )
end function

--/topic Extensions
--/func resolve_math_ref( object ref )
--
--Returns the id for the matheval object /b ref.
--/code
--ex:
--
--	ADD = resolve_math_ref( "ADD" )
--/endcode
global function resolve_math_ref( object ref )
	return find( ref, OpRef )
end function


--/topic Extensions
--/func resolve_math_func( object ref )
--
--Returns the routine id for the evaluation function of
--the matheval object /b ref.
--/code
--ex:
--
--	ADD_rid = resolve_math_func( "ADD" )
--/endcode
global function resolve_math_func( object ref )
	integer id
	id = resolve_math_ref( ref )
	if id then
		id = Operation[id]
	end if
	return id
end function

--/topic Extensions
--/func get_math_ref( integer id )
--
--Returns the name of the matheval type, given its registered id.
global function get_math_ref( integer id )
	return OpRef[id]
end function

--/topic Extensions
--/func math_func_count()
--
--Returns the number of matheval objects registered.
global function math_func_count()
	return length( OpRef )
end function

--/topic Extensions
--/proc add_to_func( integer id, integer r_id )
--
--Used to dynamically add functionality to other matheval operations.
--For example, if you created a new data type (a complex number, for
--instance) you could specify how existing operations treat that 
--type without modifying the code within the operation's evaluation
--functions.
global procedure add_to_func( integer id, integer r_id )
	OpEx[id] &= r_id
end procedure

--/topic Extensions
--/func eval_addons( integer from, sequence a, sequence b )
--
--Used to evaluate any additional operations that may have been
--set by /add_to_func().  This should be called from within the 
--evaluation routine of every matheval type.
global function eval_addons( integer from, sequence a, sequence b )
	sequence op, adds, result
	
	adds = OpEx[from]
	op = { from, a, b }
	
	for i = 1 to length( adds ) do
		result = call_func( adds[i], op )
		if not equal( op, result ) then
			return result
		end if
	end for
	
	return op
end function

--/topic Extensions
--/proc pretty_print( integer func, integer rid )
--
--Registers a pretty print function so that the matheval type
--can be pretty printed.  The function should return formatted
--text.  It should call the pretty print routines for its
--argument[s] using call_func.  The routine id of the function
--is available through the global sequence PPEXP, using the
--value of FUNC as index.  Here is what the pretty print routine
--for /ADD looks like: 
--/code
--ex:
--	function PPAdd( sequence a, sequence b )
--	    return "(" & call_func( PPEXP[a[FUNC]], {a[ARG1], a[ARG2]} ) & " + " &
--	        call_func( PPEXP[b[FUNC]], {b[ARG1], b[ARG2]}) & ")"
--	end function
--/endcode
--/b NOTE: This procedure is located within matheval, and will conflict with
--the pretty_print() defined in the version of  misc.e that comes with 
--Euphoria 2.4 and later.  It is advised to include matheval into a namespace 
--if you call pretty_print (and will need to include misc.e into a namespace
--if you call misc:pretty_print().
global procedure pretty_print( integer func, integer rid )
	if not ADD_PP then
		return
	end if
	call_proc( ADD_PP, {func, rid})
end procedure



include misceval.e

global constant
FUNC = 1,
ARG1 = 2,
ARG2 = 3

--/topic Extensions
--/func call_op( sequence obj )
--
--Calls the evaluation routine for the matheval object /b obj,
--returning the result.
global function call_op( sequence obj )
	return call_func( Operation[obj[FUNC]], obj[ARG1..ARG2] )
end function

--/topic Extensions
--/func make_first( sequence x, integer op )
--
--This function is useful from inside of evaluation routines, where
--/b x is the sequence {ARG1, ARG2}.  If you know that one of the
--objects is of type /b op, and would like to have it be the first,
--make_first() will swap the order of /b x if required.  This is 
--convenient, because the order of arguments does not change the
--result of many operations (they are commutative).

global function make_first( sequence x, integer op )
	if x[1][FUNC] = op then
		return x
	end if
	return { x[2], x[1] }
end function


integer CONSTANT, ADD, SUBTRACT, MULTIPLY, DIVIDE, EXPONENT, POLYNOMIAL,
	SIN, COS, TAN, VAR, INVALID, FLOOR, DATA, FACTORIAL, SETEQUAL, LPAR,
	RPAR, COMMA, SQRT

						-- Format expected for each type:
--CONSTANT = 1,           -- {CONSTANT, num, {} }
--ADD = 2,                -- {ADD, arg1, arg2}    arg1 + arg2
--SUBTRACT = 3,           -- {SUBTRACT, arg1, arg2} arg1 - arg2
--MULTIPLY = 4,           -- {MULTIPLY, arg1, arg2} arg1 * arg2
--DIVIDE = 5,             -- {DIVIDE, arg1, arg2} arg1 / arg2 arg2 != 0
--EXPONENT = 6,           -- {EXPONENT, arg1, arg2} arg1 ^ arg2
--POLYNOMIAL = 7,         -- {POLYNOMIAL, var, a_n}
						-- var is variable name, a_n = {a_0, ... a_n}
--DERIVATIVE = 8,         -- {DERIVATIVE, var, function}
--DERIVATIVE_X = 9,       -- {DERIVATIVE_X, {var, value}, function}
--ANTIDERIVATIVE = 10,    -- {ANTIDERIVATIVE, var, function}
--INTEGRATE = 11,         -- {INTEGRATE, {var, lower, upper, increment}, function}
--EQUALS = 12,            -- {EQUALS, LHS, RHS}
--ROOT = 13,              -- {ROOT, arg1, arg2} arg1 root arg2
--FACTORIAL = 14,         -- {FACTORIAL, arg1, {} } arg1!
--NORMAL = 15,            -- {NORMAL, Z, {} } Z ~ N(0,1)
--SIN = 16,               -- {SIN, arg1, {} } sin( arg1 )
--COS = 17,               -- {COS, arg1, {} } cos( arg1 )
--TAN = 18,               -- {TAN, arg1, {} } tan( arg1 )
--ASIN = 19,              -- {ASIN, arg1, {} } asin( arg1 )
--ACOS = 20,              -- {ACOS, arg1, {} } acos( arg1 )
--ATAN = 21,              -- {ATAN, arg1, {} } atan( arg1 )
--VAR = 22,               -- {VAR, "varName", {} } "varName" all letters
--INVALID = 23,           -- {INVALID, "error desc", {} }
--LPAR = 24,              -- RIGHT NOW JUST USED IN PARSING
--RPAR = 25,              -- RIGHT NOW JUST USED IN PARSING
--MATRIX = 26,            -- {MATRIX, { type }, { matrix }}type(0=column, 1=row)
--TRANSPOSE = 27,         -- {TRANSPOSE, {MATRIX}, {}}
--SETEQUAL = 28,          -- {SETEQUAL, {var}, {arg2} }
--FLOOR = 29,             -- {FLOOR, {val}, {}}
--GRAPH = 30,             -- {GRAPH, {function,"varName"},{lbx,ubx,dx,lby,uby}}
						--   GRAPH Returns scaled coords
						--   when dx <= 0, will use default value of
						--   (ubx - lbx) / 100
--RANGE = 31,             -- {RANGE, {function,"varName"},{lbx,ubx,dx,lby,uby}}
						--   RANGE Returns raw coords
						--   See GRAPH for use of dx.
						--   values of lby, uby are not used
--DATA = 32,              -- {DATA, {},{} } 
--CGRAPH = 33             -- {CGRAPH, {function,"varName"},{lbx,ubx,dx,lby,uby}}





global integer PATTERN, EVALUATE, PPEX, MATRIXOP, SUBSTITUTE, SIMPLIFY

sequence VarVals
-- This stores all matheval variable information
atom tol

VarVals = {{},{}}
tol = .0001
-- The tol is mainly used in PP routines for rounding to integer values.
-- Use GetTol() and SetTol() to manipulate tolerance.

--/topic Expressions
--/func Evaluate( expression )
--
--Evaluates a matheval sequence. Performs as many operations as possible, returning the result.
global function Evaluate( sequence expression )
	sequence test
	test = {}
	while not equal(test, expression) do
		test = expression
		expression = call_func( Operation[expression[FUNC]], 
					  {expression[ARG1], expression[ARG2]} )
	end while				   
	--return call_func(SIMPLIFY,{expression})
	return expression
end function
EVALUATE = routine_id("Evaluate")

--/topic Extensions
--/func is_compound( sequence expr )
--
--Determines whether or not expr is a compound /DATA sequence:
--/code
-- { DATA, { {CONSTANT, {5}, {}}, ...}, {} }
--/endcode
--If true, returns the number of matheval sequences contained
--within the /DATA.

global function is_compound( sequence expr )

	if expr[FUNC] != DATA then
		return 0
	end if
	expr = expr[ARG1]

	for i = 1 to length(expr) do
		if not matheval_seq( expr[i] ) then
			return 0
		end if
	end for
	return length(expr)
end function

--/topic Expressions
--/const GetTol()
--/ret Tolerance
-- The tolerance is primarily used for pretty print routines, to correctly
-- return integer values.
global function GetTol()
	return tol
end function  

--/topic Expressions
--/proc SetTol( tolerance )
--/desc set the tolerance for pretty print
-- The tolerance is primarily used for pretty print routines, to correctly
-- return integer values.

global procedure SetTol( atom a )
	tol = a
end procedure

-- var = "VARNAME".  If var exists, returns value assigned.
-- Otherwise returns the var in matheval format.

--/topic Algebra
--/func GetVar( varname )
--/ret Assigned value of variable
-- var should be the name of the variable.  If the variable has not
-- been defined, GetVar will return a matheval VAR sequence, with 
-- the specified name, and a coefficient of 1.
global function GetVar( sequence var )
	integer ix
	var = upper( var )
	ix = find( var, VarVals[1])
	if ix then
		return VarVals[2][ix]
	else
		return { VAR, var, {1}}
	end if
end function

--/topic Algebra
--/func GetVarList()
--
--Returns an associative list where the first list is the name of
--all currently known variables, and the second list contains the
--corresponding values of all the variables.
global function GetVarList()
	return VarVals
end function

function String( object a )
	if atom(a) then
		return 0
	end if
	
	for i = 1 to length(a) do
		if sequence(a[i]) then
			return 0
		end if
	end for
	return 1
end function

global sequence ZERO, ONE, TWO

--/topic Arithmetic
--/const ZERO
--
--Shorthand for 0 as a matheval constant.


--/topic Arithmetic
--/const ONE
--
--Shorthand for 1 as a matheval constant.


--/topic Arithmetic
--/const TWO
--
--Shorthand for 2 as a matheval constant.

include parseval.e

sequence temp_vars
temp_vars = {{},{}}
global procedure RestoreVars()

	VarVals = temp_vars
	temp_vars = { {}, {}}
end procedure

global procedure StoreVars()
	temp_vars = VarVals
	VarVals = { {}, {}}
end procedure
include symeval.e

-- optional 1.5
include ppeval.e

--/topic Extensions
--/func GetArgs( sequence a, sequence b )
-- This is the main function for recursively dealing with arguments.
-- Most ops pass their arguments to GetArgs(), which in turn evaluates
-- the arguments as far as possible (ie, constants or undefined vars).
-- Then it passes the values back to the original caller.

global function GetArgs( sequence a, sequence b )
	sequence x
	x = { a, b }
	
	for i = 1 to 2 do
		x[i] = call_func( Operation[x[i][FUNC]], { x[i][ARG1], x[i][ARG2] } )
	end for
	
	return x
end function
global constant GETARGS = routine_id( "GetArgs" )

--/topic Arithmetic
--/const Constant
--/desc { CONSTANT, { val }, { } }
function Constant(sequence a, sequence b )
	return {CONSTANT, a, b }
end function
--Operation[CONSTANT] = routine_id( "Constant" )
CONSTANT = reg_math_func( "CONSTANT", routine_id("Constant"))



--/topic Arithmetic
--/const Addition
--/desc { ADD, ARG1, ARG2 }
--/ret Sum of ARG1 and ARG2
function Add( sequence a, sequence b )
	sequence x
	
	x = call_func( GETARGS, { a, b } )
	if equal( x[1], ZERO ) then
		return x[2]
	elsif equal( x[2], ZERO ) then
		return x[1]
	elsif x[1][FUNC] = CONSTANT and x[2][FUNC]= CONSTANT then
		return {CONSTANT, x[1][ARG1] + x[2][ARG1], {} }
		-- We're just adding constants
	elsif x[1][FUNC]= VAR and equal(x[1][FUNC..ARG1], x[2][FUNC..ARG1]) then
		return { VAR, x[1][ARG1], x[1][ARG2] + x[2][ARG2]}
		-- We're adding like terms

-- Need to put this into the matrix include and use add_to_func()
--    elsif
--        x[1][FUNC] = MATRIX or x[2][FUNC] = MATRIX then
--        return call_func( MATRIXOP , { ADD, x[1], x[2] })
	elsif equal( x[1], x[2] ) then
		return { MULTIPLY, TWO, x[1] }
	else
		-- We can't simplify and more: probably a var and a constant...
		return eval_addons( ADD, x[1], x[2] )
	end if
	
end function
--Operation[ADD] = routine_id( "Add" )
ADD = reg_math_func( "ADD", routine_id( "Add" ) )

--/topic Arithmetic
--/const Subtraction
--/desc { SUBTRACT, ARG1, ARG2 }
--/ret Difference of ARG1 and ARG2
function Subtract( sequence a, sequence b )
	sequence x
	x = call_func( GETARGS, { a, b } )
	
	if x[1][FUNC] = CONSTANT and x[2][FUNC] = CONSTANT then
		return {CONSTANT, x[1][ARG1] - x[2][ARG1], {} }
	elsif x[1][FUNC]= VAR and equal(x[1][FUNC..ARG1], x[2][FUNC..ARG1]) then
		return { VAR, x[1][ARG1], x[1][ARG2] - x[2][ARG2]}

-- Move to matrix...
--    elsif x[1][FUNC] = MATRIX or x[2][FUNC] = MATRIX then
--        return call_func( MATRIXOP, { SUBTRACT, x[1], x[2]} )
	else
		return eval_addons( SUBTRACT, x[1], x[2] )
		-- We can't simplify any more.
	end if
	
end function
--Operation[SUBTRACT] = routine_id( "Subtract" )
SUBTRACT = reg_math_func( "SUBTRACT", routine_id( "Subtract" ))

--/topic Arithmetic
--/const Multiplication
--/desc { MULTIPLY, ARG1, ARG2 }
--/ret Product of ARG1, ARG2 }
function Multiply( sequence a, sequence b )
	sequence x, y, polys, maxlen, prod, p1, p2
	atom coeff
	x = call_func( GETARGS, { a, b } )
	
	if x[1][FUNC] = CONSTANT and x[2][FUNC] = CONSTANT then
	
		return {CONSTANT, x[1][ARG1] * x[2][ARG1], {} }

	elsif (x[1][FUNC] = VAR and x[2][FUNC] = CONSTANT) or
		  (x[2][FUNC] = VAR and x[1][FUNC] = CONSTANT) then
		if x[1][FUNC] = VAR then
			x = { x[2], x[1] }
			-- We have x = { cons, var }
		end if
		return {VAR, x[2][ARG1], x[1][ARG1] * x[2][ARG2] }
		
	elsif x[1][FUNC] = VAR and equal(x[1][FUNC..ARG1], x[2][FUNC..ARG1]) then
		-- same variable -- we'll square it
		return {EXPONENT, {VAR, x[1][ARG1], x[1][ARG2] * x[2][ARG2]}, {CONSTANT, {2}, {}}}
	
	elsif (x[1][FUNC] = VAR and x[2][FUNC] = POLYNOMIAL) or 
		  (x[2][FUNC] = VAR and x[1][FUNC] = POLYNOMIAL) then

		if equal( x[1][ARG1], x[2][ARG1]) then
		-- same var's
			if x[1][FUNC] = VAR then
				x = { x[2], x[1] }
				-- make sure we have { POLYNOMIAL, VAR }
			end if
			
			x[1][ARG2] = 0 & x[1][ARG2] * x[2][ARG2][1]
			-- This increases the power of each term and multiplies by the
			-- coefficient
			return x[1]
		else
		-- var, poly, different var's
			x = make_first( x, VAR )

			prod = ZERO 
			for i = 1 to length(x[2][ARG2]) do
				prod = { ADD, Multiply( {VAR, x[1][ARG1], x[1][ARG2] * x[2][ARG2][i]}, 
					{ EXPONENT, { VAR, x[2][ARG1], {1}}, {CONSTANT, {i-1}, {}}}),
					prod}
			end for
			return prod
		end if
		
	elsif find(x[1][FUNC], {EXPONENT, MULTIPLY})
			and x[2][FUNC] = POLYNOMIAL then	
		
		if x[1][FUNC] = POLYNOMIAL then
			x = { x[2], x[1] }
		end if
		
		if x[1][FUNC] = MULTIPLY and
				find(x[1][ARG1][FUNC], {CONSTANT, VAR}) and
				find(x[1][ARG2][FUNC], {CONSTANT, VAR}) and
				x[1][ARG1][FUNC] != x[1][ARG1][FUNC] then
			
			if x[1][ARG1] = CONSTANT then
				x[1] = { x[1][ARG2], x[1][ARG1] }
			end if	 
			
			coeff = x[1][ARG1][ARG1][1]
			x[1] = x[1][ARG2]
			
		else
			coeff = 0
		end if
	
	
		if x[1][ARG1][FUNC] = VAR and 
				equal(x[1][ARG1][ARG1], x[2][ARG1]) and
				equal(x[1][ARG2], CONSTANT) and 
				integer(x[1][ARG2][ARG1][1]) and
				x[1][ARG2][ARG1][1] > 0 then
			
			x[2][ARG2] = coeff * prepend( x[2][ARG2], 
						 repeat( 0, x[1][ARG2][ARG1][1]))
			return x[2]
				
		end if
		
		if coeff then
			x[1] ={ MULTIPLY,{CONSTANT, {coeff}, {}} , x[1] }
		end if
	
	elsif x[1][FUNC] = POLYNOMIAL and x[2][FUNC] = POLYNOMIAL then
		if equal( x[1][ARG1], x[2][ARG1]) then
		-- same var
			maxlen = {}
			polys = {}
			
			if length( x[1][ARG2] ) > length( x[2][ARG2] ) then
				x = { x[2], x[1] }
			end if
			
			polys = repeat( x[2][ARG2], length(x[1][ARG2]))
			coeff = length(polys)+length(polys[1])
			
			for i = 1 to length(polys) do
				polys[i] = repeat(0, i-1 ) &  x[1][ARG2][i] * x[2][ARG2] &
						   repeat(0, coeff-i)
			end for
			
			for i = 2 to length(polys) do
				polys[i] += polys[i-1]
			end for
			
			x[1][ARG2] = polys[length(polys)]
			return x[1]
		else
		-- different vars...
			p1 = x[1]
			p2 = x[2]
			prod = ZERO

			for i = 1 to length(x[1][ARG2]) do
				for j = 1 to length(x[2][ARG2]) do
					prod = { ADD,
								Multiply( {CONSTANT, { p1[ARG2][i] * p2[ARG2][j] }, {}},
									Multiply( 
										{ EXPONENT, {VAR, p1[ARG1], {1} }, {CONSTANT, {i-1}, {}} },
										{ EXPONENT, {VAR, p2[ARG1], {1} }, {CONSTANT, {j-1}, {}} })),
								prod}

				end for
			end for
			return prod
		end if		 
		
	elsif (x[1][FUNC] = CONSTANT and x[2][FUNC] = POLYNOMIAL) or 
		  (x[2][FUNC] = CONSTANT and x[1][FUNC] = POLYNOMIAL) then
		if x[1][FUNC] = CONSTANT then
			x = { x[2], x[1] }
			-- make sure we have { POLYNOMIAL, CONSTANT }
		end if
		x[1][ARG2] *= x[2][ARG1][1]
		return x[1]
		
	elsif equal( x[1], ONE) then
		return x[2]
	elsif equal( x[2], ONE) then
		return x[1]
		
	elsif equal( x[1], ZERO) or equal(x[2],0) then
		return ZERO
		
--    elsif x[1][FUNC] = MATRIX and x[2][FUNC] = CONSTANT then
--        return { MATRIX, x[1][ARG1], x[1][ARG2] * x[2][ARG1][1] }
--    elsif x[2][FUNC] = MATRIX and x[1][FUNC] = CONSTANT then
--        return { MATRIX, x[2][ARG1], x[2][ARG2] * x[1][ARG1][1] }
--    elsif find( MATRIX, {x[1][FUNC], x[2][FUNC]}) then
--        return call_func( MATRIXOP, { MULTIPLY, x[1], x[2] } )
	
	elsif x[1][FUNC] = ADD or x[2][FUNC] = ADD then
	-- Distributive property...
		-- Switch them if need be...

		if x[1][FUNC] != ADD then
			x = {x[2], x[1]}
		end if
		
		return call_func( Operation[ADD], {
			{ MULTIPLY,  x[1][ARG1], x[2] },
			{ MULTIPLY,  x[1][ARG2], x[2]  }} )
	
	elsif (x[1][FUNC] = EXPONENT and x[2][FUNC] = EXPONENT) 
	and    x[1][ARG1][FUNC] = VAR 
	and    equal(x[1][ARG1][FUNC..ARG1], x[2][ARG1][FUNC..ARG1])
	then	  
		
		return { EXPONENT, x[1][ARG1][FUNC..ARG1] & {x[1][ARG1][ARG2] *
							x[2][ARG1][ARG2]} ,
							Add( x[1][ARG2], x[2][ARG2] ) }
		
	end if
	
	return eval_addons( MULTIPLY, x[1], x[2] )
	-- We can't simplify any more.
	
end function
--Operation[MULTIPLY] = routine_id( "Multiply" )
MULTIPLY = reg_math_func( "MULTIPLY", routine_id( "Multiply" ))

--/topic Arithmetic
--/const Division
--/desc { DIVIDE, ARG1, ARG2 }
--/ret Quotient of ARG1 divided by ARG2
function Divide( sequence a, sequence b)
	sequence x
	x = call_func( GETARGS, { a, b } )
	
	if equal( x[2], {CONSTANT, {0}, {}}) then
		return {INVALID, "Division by zero", {} }
	end if
	
	if equal( x[1], {CONSTANT, {0}, {}}) then
		return {CONSTANT, {0}, {}}
	end if
	
	if x[1][FUNC] = CONSTANT and x[2][FUNC] = CONSTANT then
		
		return {CONSTANT, x[1][ARG1] / x[2][ARG1], {} }
		
	elsif x[1][FUNC]= VAR and equal(x[1][FUNC..ARG1], x[2][FUNC..ARG1]) then
		
		return { CONSTANT,	x[1][ARG2] / x[2][ARG2], {} }
--    elsif x[1][FUNC] = MATRIX and x[2][FUNC] = CONSTANT then
--        return { MATRIX, x[1][ARG1], x[1][ARG2] / x[2][ARG1][1] }
	else
		return eval_addons( DIVIDE, x[1], x[2] )
		-- We can't simplify any more.
	end if
	
end function
--Operation[DIVIDE] = routine_id( "Divide" )
DIVIDE = reg_math_func( "DIVIDE", routine_id( "Divide" ))

--/topic Arithmetic
--/const Exponentiation
--/desc { EXPONENT, ARG1, ARG2 }
--/ret ARG1 ^ ARG2
function Exponent( sequence a, sequence b)
	sequence x
	x = call_func( GETARGS, { a, b } )
	
	if equal(x[2], ONE ) then
		return x[1]
	elsif equal(x[1], ZERO ) then
		return ZERO
	elsif equal(x[2], {CONSTANT, {0}, {}}) then
		return ONE
	elsif x[1][FUNC] = CONSTANT and x[2][FUNC] = CONSTANT then
		if x[1][ARG1][1] < 0 and x[2][ARG1][1] < 1 then
				if IsEven(power(x[2][ARG1][1], -1)) then
				-- Can't compute without complex numbers!
				return {INVALID, "^ Answer requires complex numbers", {} }
				
			end if
		end if
		return {CONSTANT, power(x[1][ARG1], x[2][ARG1]), {} }
--    elsif x[1][FUNC] = MATRIX then
--        return call_func( MATRIXOP, { EXPONENT, x[1], x[2] } )
		
	else
		return eval_addons( EXPONENT, x[1], x[2] )
		-- We can't simplify any more.
	end if
	
end function
--Operation[EXPONENT] = routine_id( "Exponent" )
EXPONENT = reg_math_func( "EXPONENT", routine_id( "Exponent" ))

--/topic Algebra
--/const Variable
--/desc {VAR, "VARNAME", { coeff } }
--/ret Assigned value of variable
-- Variables can hold any valid matheval value, including other variables,
-- constants, or even complex expressions.
function Var( sequence a, sequence b )
	integer ix
	sequence val
	ix = find( a, VarVals[1] )
	if not ix then
		return {VAR, a, b}
	elsif b[1] = 1 then
		val = VarVals[2][ix]
		return call_func( Operation[val[FUNC]],{val[ARG1], val[ARG2]} )
	else		
		return call_func( Operation[MULTIPLY], {VarVals[2][ix], {CONSTANT, b, {} } })
	end if
	
end function
--Operation[VAR] = routine_id( "Var" )
VAR = reg_math_func( "VAR", routine_id( "Var" ))

--/topic Algebra
--/const Polynomial
--/desc { POLYNOMIAL, "VARNAME", { a0, a1, a2, ... } }
-- ARG2 is a sequence of the coefficients:
-- Example:
--/code
--          { POLYNOMIAL, "X", {1,0,2,0,3} }
--          is the same as
--          3X^4 + 2X^2 + 1
--/endcode
function Polynomial( sequence a, sequence b)
	sequence var, terms, func
	
	var = GetVar( a )
	
	if equal( var, {VAR, a, {1}}) then
		return eval_addons(POLYNOMIAL, a, b)
		-- variable not defined...cannot expand
	else	
		terms = {}
		for ix = 1 to length( b ) do
			terms &= {{ MULTIPLY, {CONSTANT, {b[ix]}, {}}, 
						{EXPONENT, var, {CONSTANT,{ix-1},{}}}}}
		end for
		func = terms[1]
		terms = terms[2..length(terms)]
		while length(terms) do
			func = {ADD, terms[1], func}
			terms = terms[2..length(terms)]
		end while
		return func
	end if

end function
--Operation[POLYNOMIAL] = routine_id( "Polynomial" )
POLYNOMIAL = reg_math_func( "POLYNOMIAL", routine_id("Polynomial"))

--/topic Trigonometry
--/info
--Trig functions
--


--/topic Trigonometry
--/const Sin
--/desc { SIN, ARG1, { } }
--/ret Sine of ARG1
function Sin( sequence a, sequence b )
	
	if a[FUNC] != CONSTANT then
		a = call_func( Operation[a[FUNC]], { a[ARG1], a[ARG2] } )
	end if
	
	if a[FUNC] = CONSTANT then
		return { CONSTANT, sin(a[ARG1]), {} }
	else
		return eval_addons( SIN, a, b )
	end if
end function
--Operation[SIN] = routine_id( "Sin" )
SIN = reg_math_func("SIN", routine_id( "Sin" ) )

--/topic Trigonometry
--/const Cos
--/desc { COS, ARG1, { } }
--/ret Cosine of ARG1
function Cos( sequence a, sequence b )
	
	if a[FUNC] != CONSTANT then
		a = call_func( Operation[a[FUNC]], { a[ARG1], a[ARG2] } )
	end if
	
	if a[FUNC] = CONSTANT then
		return { CONSTANT, cos(a[ARG1]), {} }
	else
		return eval_addons( COS, a, b )
	end if
end function
--Operation[COS] = routine_id( "Cos" )
COS = reg_math_func( "COS", routine_id( "Cos" )) 

--/topic Trigonometry
--/const Tan
--/desc { TAN, ARG1, { } }
--/ret Tangent of ARG1
function Tan( sequence a, sequence b )
	atom x
	if a[FUNC] != CONSTANT then
		a = call_func( Operation[a[FUNC]], { a[ARG1], a[ARG2] } )
	end if
	
	if a[FUNC] = CONSTANT then
		x = cos( a[ARG1][1] )
		if x > .0001 or x < -.0001 then 	 
		   -- This makes sure tan is defined here
		   
			return { CONSTANT, tan(a[ARG1]), {} }
		else
			return { INVALID, "Tan not defined", {} }
		end if
	else
		return eval_addons( TAN, a, b )
	end if
end function
--Operation[TAN] = routine_id( "Tan" )
TAN = reg_math_func( "TAN", routine_id("Tan"))

-- Factorial look up table
constant 
FACTORIAL_LU = { 1, 2, 6, 24, 120, 720, 5040, 40320,
				 362880, 3628800, 39916800,
				 479001600, 6227020800, 87178291200,
				 1307674368000, 20922789888000,
				 355687428096000 }
						  
--/topic Arithmetic
--/const Factorial
--/desc { FACTORIAL, ARG1, { } }
--/ret Factorial of ARG1
-- /Parse uses standard /b x /b ! notation for the factorial of x.
--The maximum value of /b x is 17 due to the fact that Euphoria
--only provides 15 digits of accuracy.
function Factorial( sequence a, sequence b)
	atom x
	if a[FUNC] = CONSTANT then
		x = a[ARG1][1]
		if x > length( FACTORIAL_LU ) then
			return { INVALID, "'!' Number too large", {}}
		elsif x < 0 then
			return { INVALID, "'!' Number must be non-negative", {}}
		elsif not integer(x) then
			return {INVALID, "'!' Number must be non-negative integer", {}}
		else
			return { CONSTANT, { FACTORIAL_LU[x]}, {}}
		end if
	end if
	return eval_addons( FACTORIAL, a, b )
end function
--Operation[FACTORIAL] = routine_id("Factorial")
FACTORIAL = reg_math_func( "FACTORIAL", routine_id( "Factorial" ) )

--/topic Expressions
--/const Invalid
--/desc { INVALID, "ERR MSG", { } }
-- /Invalid is used by Matheval to send back error messages to the user.
function Invalid( sequence a, sequence b )
	return { INVALID, a, b }
end function
--Operation[INVALID] = routine_id( "Invalid" )
INVALID = reg_math_func( "INVALID", routine_id( "Invalid" ) )

LPAR = reg_math_func( '(', 0 )
RPAR = reg_math_func( ')', 0 )
COMMA = reg_math_func( ",", 0 )

--/topic Functions
--/const Floor
--/desc { FLOOR, ARG1, { } }
--/ret Greatest integer less than ARG1.
-- /Parse uses floor( ARG1 ) for the floor function.
function Floor( sequence a, sequence b )
	if a[FUNC] = CONSTANT then
		return { CONSTANT, { floor(a[ARG1][1]) }, {} }
	else
		a = call_func( EVALUATE, { a } )
	end if
		
	if a[FUNC] = CONSTANT then
		return { CONSTANT, { floor(a[ARG1][1]) }, {} }
	else
		return eval_addons( FLOOR, a, b )
	end if
	
end function
--Operation[FLOOR] = routine_id( "Floor" )  
FLOOR = reg_math_func( "FLOOR", routine_id( "Floor" ) )

function Sqrt( sequence a, sequence b )
	sequence x
	x = call_op(a)
	
	if x[FUNC] = CONSTANT and x[ARG1][1] > 0 then
		return { CONSTANT, { sqrt(x[ARG1][1]) }, {}}
	end if
	
	return eval_addons( SQRT, a, b)
end function
SQRT = reg_math_func( "SQRT", routine_id("Sqrt"))

--/topic Expressions
--/const Data
--/desc { DATA, ARG1, ARG2 }
--Data is a way to pass data in an arbitrary format.  This is used
--by /Graph and /Range to pass values, as well as by boolean evaluators
--to compare strings.
function Data( sequence a, sequence b)
	return {DATA, a, b}
end function
--Operation[DATA] = routine_id( "Data" )
DATA = reg_math_func( "DATA", routine_id( "Data" ))

-- expression = matheval sequence.  Evaluates sequence as far
-- as possible (ie, constants, undefined vars).

--/topic Algebra
--/const ClearVar( sequence var )
--
-- If var = "VARNAME", then variable "VARNAME"'s value is cleared. 
-- If var = {}, then all variables are cleared.
global procedure ClearVar( sequence var )
	integer ix, l
	if not length( var ) then
		VarVals = {{},{}}
		return
	end if
	ix = find( var, VarVals[1])
	if ix then
		l = length(VarVals[1])
		VarVals[1] = VarVals[1][1..ix-1] & VarVals[1][ix+1..l]
		VarVals[2] = VarVals[2][1..ix-1] & VarVals[2][ix+1..l]
	end if
end procedure


--/topic Algebra
--/proc SetVar( sequence var, object val )
--/desc Set a var's value.
--/code
-- var = "VARNAME"
-- val = atom               : var is set to a constant
--     = 'string'           : var set to parsed value of val
--     = matheval sequence  : var set to sequence (NOTE: There is
--                            no error checking done to make sure
--                            that sequence is correct.)
--     = "varname"          : var is reset (taken out of VarVals)
--/endcode
global procedure SetVar( sequence var, object val )
	integer ix 
	
	var = upper(var)
	
	-- Make sure syntax is correct
	for i=1 to length(var) do
		if (var[i] < 'A' or var[i] > 'Z' ) then
			if not find( var[i], "_[]") then
				if i > 1 then
					if var[i] < '0' or var[i] > '9' then
						return
					end if
				end if
			end if
		end if
	end for
	
	-- Handle value (does it need parsing? etc)
	if atom(val) then
		val = { {CONSTANT, {val}, {} } }
	elsif String( val ) then
		val = { Parse( val ) }
	else
		val = { val }
	end if
	
	-- Reset var if val = "varname"
	if atom(val[1][FUNC]) and val[1][FUNC] = VAR 
			and equal(val[1][ARG1],var)  then
		ClearVar( var )
		return
	end if
	-- Look var up in table
	ix = find( var, VarVals[1])
	
	-- Already exists, so update the value
	if ix then
		VarVals[2][ix] = val[1]
	else
	-- New var.  Add to end of list.
		VarVals[1] &= { var }
		VarVals[2] &=  val 
	end if

   
end procedure

--/topic Algebra
--/func SetEqual( sequence a, sequence b)
--{ SETEQUAL, ARG1, ARG2 }
-- Set Variable in ARG1 equal to ARG2.  Use ':=' when passed to /Parse.
--To clear the value of a variable, use:
--/code
-- "variable_name := variable_name"
--/endcode
--
function SetEqual( sequence a, sequence b)
	sequence x

	if a[FUNC] = VAR then
		if equal(a,b) then
			ClearVar(a[ARG1])
			return a
		else
			x = { a, call_func( Operation[b[FUNC]], b[ARG1..ARG2] ) }
			SetVar( x[1][ARG1], x[2] )
			return x[2]
		end if
	else
		return { INVALID, "':=' must have a variable on LHS", {} }
	end if
end function
SETEQUAL = reg_math_func( "SETEQUAL", routine_id( "SetEqual") )

--/topic Expressions
--/proc matheval_init()
--
--This routine must be called after matheval files are included.  Multiple
--calls may be made, and each initialization routine will be called only
--once.
global procedure matheval_init()
	
	ZERO = { CONSTANT, {0}, {}}
	ONE = {CONSTANT, {1}, {}}
	TWO = {CONSTANT, {2}, {}}
	
	for i = 1 to length( init_func ) do
		call_proc( init_func[i], {} )
	end for
	init_func = {}
end procedure




--/topic Arithmetic
--/info
--Doing arithmetic
--

--/topic Expressions
--/info
--Using matheval expressions
--
--Matheval stores everything as a matheval sequence, which is nothing more than
--a three element sequence.  The first element (you can use the global constant
--FUNC) identifies the type of matheval sequence.  The second and third elements
--(which can be referred to as ARG1 and ARG2) are the arguments or data for the matheval
--sequence.  They are always sequences (see /matheval_seq)
--
--Some matheval sequences use only ARG1, and others use both, depending on what
--they represent.  A typical binary operator, like multiplication, uses both,
--and in fact, both ARG1 and ARG2 are matheval sequences themselves.  Even
--normal numbers are represented as matheval sequences (see /CONSTANT).
--
--There are multiple ways to build matheval sequences.  You can do it manually,
--within code, or you can use /Parse() to turn a string into a matheval 
--sequence.  For example:
--/code
--  x = Parse( "X + Y" )
--  -- x = { ADD, { VAR, "X", {1}}, { VAR, "Y", {1} }
--/endcode 
--It is important to note that /Parse() is case /i insensitive, except for 
--text within quotes.
--
--The various matheval types are described in this documentation as constants, which
--is slightly misleading.  They are not true constants, but instead are values assigned
--at runtime during initialization (see /matheval_init, /add_math_init).  They are always
--stored as local variables.  In order to use them in your own code, you will need to
--declare them and make calls to /resolve_math_ref to define them.  This is done in order
--to make matheval more easily extendible and modular.
--
--The documentation for these 'constants' will often say that they return a value.  This is
--meant to convey that they are either a /b matheval function or a /b matheval operator that 
--return some sort of value based on their arguments when they are evaluated (see /Evaluate,
--/Evaluate_s).



