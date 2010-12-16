
--Introduction 
-----------------------------

global constant EUSQL_VERSION = {0,79,3}

--/makedoc title EuSQL Documentation

--/topic introduction
--/desc EuSQL.e v0.79.3
--/info
--/b EuSQL v0.79.3 by Matt Lewis
--<br>
--<a href="mailto:mattlewis@users.sourceforge.net">mattlewis@users.sourceforge.net</a>
--<br>
--/lit'<a href="http://eusql.sourceforge.net">http://eusql.sourceforge.net</a>'
--
--OVERVIEW
--
--This is an attempt to bring some added power to EDS by turning EDS files into Relational
--Databases.  EuSQL implements a fairly large subset of standard SQL.  
--
--/b "EuSQL requires Euphoria 4.0 or later."
--
--EuSQL will run on any platform that runs Euphoria.  There is no platform specific code
--in EuSQL.
--
--LICENSE AND DISCLAIMER
--
--The MIT License
--
--Copyright (c) 2007 Matt Lewis
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
--/code
--FILES INCLUDED
--
--Main Library files:
--  eusql.e      :  Main include file
--  eusql.htm    :  You're reading it.
--  hlist.e      :  Hybrid associative list routines by Jiri Babor.  Used by EuSQL.
--  sprint.e     :  Adopted from Gabriel Boehme's print.e
--
--Matheval files (used for comparisons and calculations by EuSQL): 
--  matheval.e   :  Main matheval lib file.
--  booleval.e   :  Evaluates boolean expressions.
--  ppeval.e     :  Formats matheval sequences for display. 
--  misceval.e   :  Used by matheval.e 
--  parseval.e   :  Parses mathematical and logical expressions
--  scripteval.e :  More complex operators
--  texteval.e   :  Text manipulation
--  datetimeval.e:  Date and time functions
--
--Demo Files:
--  archive.edb  :  RDS's archive of user contributions
--  sql.ex       :  Demo that creates sql.edb from archive.edb
--  sqldemo.ex   :  Demo that runs several queries on sql.edb
--  print.e      :  Gabriel Boehme's smart print routines (used in the demo)
--
--/endcode
--

-- Change History
----------

--/topic Change History
--/info
--Summary of changes made to the library
--/code
--v0.79.3
-- 7/27/09
--          * Fixed invalid field detection for insert queries
--          * /get_next_autonumber() did not use table name case 
--            insensitively.
--          * Better error checking for attempting to create 
--            duplicate fields in a table.
--
--v0.79.2
-- 12/15/08
--          * Fixed aggregate function parse bug
--
--v0.79.1
-- 7/14/08
--          * Now requires Euphoria v4.0 due to usage of text.e
--
--v0.79.0
-- 6/25/08
--          * Now requires Euphoria v4.0 due to usage of sequence.e
--
--v0.78.2
-- 4/14/08
--          * Clarified error message to specify a table error rather than a field
--            error.
--         * Fixed /drop_table and DROP TABLE queries
--          * Fixed return value for run_create_table
--          * Fixed parsing error in WHERE clauses without spaces around
--            inequality operators (<>)
--          * Fixed parsing error for INSERT query where the values used
--            a function
--          * Returns no records when there are no records and an aggregate
--            function is used in the query (except for COUNT)
--         * /GET_DATE and /GET_TIME were never implemented.  Also added
--            comparisons for dates and times.
--          * Wouldn't return records that had all null fields.
--         * Fixed an indexing error in /insert_record2()
--         * Added /set_next_autonumber
--         * Added /eusql_field_types() (CK Lester)
--         * Added /get_schema()
--         * Fixed bug in executing insert statement with a select and parameters
--         * Fixed bug in /reindex if non-indexed field were passed
--         * Fixed outer join handling when multiple outer joins
--
--v0.78.1
-- 9/26/06
--          * Bug fixes for parsing and executing aggregate functions
--          * Fixed short circuit error in is_eu_boolean and is_eu_autonumber
--         * Added /get_sql_keyword()
--          * Added error checking for correct number of insert fields
--
--v0.78.0
-- 4/18/06
--          * Added BOOLEAN, DATE_TIME data type
--         * Added functions to deal with DATE_TIMEs: see /Dates
--          * Fixed bugs relating to self joins and unjoined tables
--          * Uses matheval v1.65 (datetimeval.e, upper, lower)
--
--v0.77.3
-- 12/05/05
--         * Fixed /create_field() so that it updates existing records
--         * Implemented /drop_field()
--          * Fixed bug that could cause a crash when malformed, multiple joins 
--            in sql statement
--          * Better determination of calculated fields' datatypes
--         * Added checks for valid field and index names in /create_index()
--          * Uses matheval v1.64 (added <> operator for 'not equal to')
--          * Fixed bug that could cause joins with where clauses to fail
--         * Fixed docs for /get_next_autonumber()
--          * Text inside of single quotes wasn't processed correctly
--          * Improved error message when incorrect field is specified
--          * Optimized simple case of "SELECT COUNT(*) FROM TABLE_NAME"
--          * Fixed an indexing bug that wouldn't properly update an index
--            when all records for a certain value were deleted
--
--v0.77.2
-- 8/15/05
--         * Fixed indexing bug in /insert_record2()
--          * Fixed bug for queries on tables with no fields
--
--v0.77.1
-- 1/4/05
--          * Fixed bugs with SELECT COUNT(*)
--          * Fixed some INSERT and UPDATE bugs
--          * Uses matheval v1.63
--
--v0.77.0
-- 9/10/04
--          * Can alias a table and perform self joins
--          * CREATE DATABASE, INDEX sql added
--          * Uses matheval v1.62 (bug fixes)
--
--v0.76.8
-- 8/03/04
--          * Fixed bug with update queries where only one field would be updated
--          * Fixed bug where duplicate literals were not parsed correctly
--         * Fixed bug in /insert_record2() (did the earlier bug creep back in?)
--         * Fixed bug in /update_record2() for updating an index
--          * Fixed parsing bug for SELECT COUNT(*) queries
--v0.76.7
-- 6/1/04
--          * Properly handles semicolons at the end of a SQL statement
--          * Bug fixes
--v0.76.6
-- 3/16/04
--         * Fixed bug in /insert_record2()
--v0.76.5
-- 1/30/04
--          * Fixed bug with UPDATE queries
-- v0.76.4
-- 1/27/04
--         * /insert_record2() optimized to update indices at the end, rather than
--            for each individual record
--          * Bug fixes:
--            + Updated parse_delete() to add the correct number of elements
--              to query[QN_VALUES] (4)
--            + Incorrect definition of EUSQL_CONCAT
--            + EUSQL_MULTIPLY was conflicting with EUSQL_ASTERISK, and broke
--              'SELECT * FROM TABLE'-type functionality
--            + Fixed indexing errors when deleting records
--            + Fixed some parsing errors introduced into other query types by
--              modifications to SELECT parsing
-- v0.76.3
-- 12/04/03
--          * Bug fixes:
--            + Parameter and matheval variable handling
--            + Parser was missing <=, >= and incorrectly parsing quoted literals
--            + ORDER BY didn't properly take into account non-displayed fields
--            + UPDATE query wouldn't update with an atom value
--           + /select_current() didn't always change the current table
--          * Uses matheval v1.61
--            + Added scripteval.e to use matheval's IF() operator
--            + Added texteval.e for string manipulation
--          * Calculated fields for queries (arithmetic, IF, text operations)
--
-- v0.76.2
--11/17/03
--          * Optimized and fixed bugs in select queries, parameter handling
--
-- v0.76.1
--10/27/03
--         * /insert_record() and /insert_record2() will call /blank_record() 
--            if an atom is passed for the blank record.
--          * Better parsing of INSERT queries.  No longer have to prepend the
--            table name to each field to be inserted.
--         * Added /validate_field2() for easier field validation.
--         * Can change the way EuSQL opens databases using /eusql_exclusive().
--
-- v0.76
--10/08/03
--         * /insert_record2() returns sequence with error codes for records
--          * Fixed insert bug when a parameter's value had not been set.
--
-- v0.75
--8/4/03
--         * Fixed /delete_record() bugs
--          * Added AUTONUMBER datatype
--
-- v0.74
--4/21/03
--         * Major optimization for /SELECT queries
--          * Changed order of precedence for boolean logic so that it makes more sense
--            (fewer parenthesis are needed)
--         * /IN() keyword now works in where clauses
--         * /create_db() didn't update db_list
--         * Bug fixes to /DELETE, /UPDATE parsing and execution
--         * /rename_table() added
-- v0.73 
--4/10/03
--          * Improved error checking and reporting in several places
--          * Fixed bug where eusql missed fields with the same name as a table
--          * update and delete functions now update indices
--          * Fixes to boolean evaluation
--         * Can now use IS [NOT] NULL in /WHERE clauses
--         * More parameter bug fixes--/UPDATE queries
--         * Other /UPDATE query bug fixes
--          * Fixed bugs regarding parameters--values not being set and read properly
-- v0.72
--1/16/03
--          * Fixed several bugs regarding outer joins
-- v0.71
--11/22/02
--          * Select now uses indices, dramatic speed increase
--          * Outer joins working
--          * Can alias an aggregate function: SUM(TABLE1.FIELD1) AS FIELD1
-- v0.7
--4/19/02
--          * Literals now case sensitive.
--          * Condition and single, multiple join work now.
--          * Need to test multiple conditionals with joins.
--          * Indices are being created, but not sure if correct,
--            since they're not used anywhere else.
-- v0.62
--6/14/01
--          * added matheval:booleval for comparison and calculations
-- v0.61
--5/2/01
--         * /create_index(): need to allow queries to do this, too
--         * /get_record2(): Retrieve a record based on non-key values.
--            Also had to add index_wild() to hlist.e to search on 
--            wildcard values.
-- v0.6
--3/6/01
--         * Added /CREATE, /DROP TABLE queries.
--          * Modularized parsing routines.
-- v0.5
--3/2/01
--          * Added API commands to update, insert, retrieve records, get the
--            structure of a table's records, create tables and fields,
--            select current database, table
--          * When create_table and create_field are used, TABLEDEF is
--            automatically updated.
--          * "SELECT *" now returns 'flat' records
--          * Fixed bug regarding condition handling.  Can now use conditions
--            with "SELECT *"
--          * Initial support for datatypes -- they're stored, but not
--            actually used for verification yet
--         * Fixed bug with /UPDATE queries
-- v0.4
--2/8/01:
--         * Better error handling.  Added /get_sql_err() for 
--            more verbose error reporting.
--          * Many bug fixes.
--         * /DELETE queries supported.  Returns keys of deleted records.
--         * /UNION queries supported.
--          * "SELECT *" supported.
--         * /INSERT queries supported.
--         * /UPDATE queries supported.
-- v0.3a
--11/2/00: 
--         * Column functions /COUNT, /SUM, /AVG, /GROUP BY
--         * Added support for /SELECT /DISTINCT to get unique values
--          * field struct converted to uppercase in table_list()
--          * Changed from absolute referencing of compiled query to using
--            constants to allow flexibility in sequence structure.
--/endcode

-- API
----------

--/topic API
--/info
--Important notes on using the EuSQL API
--
--All functions return sequences when no errors occur.  They will return the integer EUSQL_ERR
--code on errors (see /Errors for details).  The only exception to this is for action queries 
--(UPDATE/INSERT/DELETE) when the action could not be performed.  Error status is returned on 
--a record by record basis as described in the SQL syntax entry for each type of query.  Also
--note that you may pass empty sequences for db_name and table_name, and EuSQL will use the 
--current database and table.
--
--It is important to distinguish between a field index and an index created 
--on a table for query purposes.  When a function requires a /b "field index", it is not 
--asking for the name of an index created for that field.  The required parameter is 
--actually the necessary subscript that would be used to refer to the field as a part
--of the record if the record were stored in a sequence.
--If the structure of the table were:
--<ul>
--/li ID
--/li NAME.FIRST
--/li NAME.LAST
--/li EMAIL
--
--Then the record as a sequence would be:
--
-- { ID, { NAME.FIRST, NAME.LAST }, EMAIL }
--
--So the corresponding indices would be:
--<table border=1>
--<tr><td>Field</td><td>Index</td></tr>
--<tr><td>ID</td><td>{1}</td></tr>
--<tr><td>NAME</td><td>{2}</TD></TR>
--<TR><TD>NAME.FIRST</TD><TD>{2,1}</TD></TR>
--<TR><TD>NAME.LAST</TD><TD>{2,2}</TD></TR>
--<TR><TD>EMAIL</TD><TD>{3}</TD></TR>
--</table>
--</ul>

-- Queries
----------

--/topic Queries
--/info
--These functions are used for executing SQL statements.

-- Data
----------

--/topic Data
--/info
--Functions for manipulating records.
--

-- DB Management
-----------

--/topic DB Management
--/info
--Navigation, creation and deletion of databases and tables

-- Utilities
-----------

--/topic Utilities
--/info
--Helper routines used by the library that may be useful




without warning

include std/eds.e
include std/wildcard.e
include std/sort.e
include std/text.e
include std/get.e
include std/pretty.e
include std/sequence.e

include euslibs/hlist.e as h
include matheval/matheval.e as m
include matheval/parseval.e as p
include matheval/booleval.e as b
include matheval/scripteval.e
include matheval/texteval.e
include matheval/datetimeval.e

include euslibs/sprint.e as euslib

m:matheval_init()
constant
CONSTANT = m:resolve_math_ref( "CONSTANT" ), 
DATA = m:resolve_math_ref( "DATA" ), 
INVALID = m:resolve_math_ref( "INVALID" ),
EQUALTO = m:resolve_math_ref( "EQUALTO" ),
LESS = m:resolve_math_ref( "LESS" ),
GREATER = m:resolve_math_ref( "GREATER" ),
LOE = m:resolve_math_ref( "LOE" ),
GOE = m:resolve_math_ref( "GOE" ),
LIKE = m:resolve_math_ref( "LIKE" ),
AND = m:resolve_math_ref( "AND" ),
OR = m:resolve_math_ref( "OR" ),
NOT = m:resolve_math_ref( "NOT" ),
VAR = m:resolve_math_ref( "VAR" ),
IF = m:resolve_math_ref( "IF" ),
CONCAT = m:resolve_math_ref( "CONCAT" ),
NOW = m:resolve_math_ref( "NOW" ),
UPPER = m:resolve_math_ref( "UPPER" ),
LOWER = m:resolve_math_ref( "LOWER" )


global constant
EUSQL_OK = 0,
EUSQL_FAIL = 1,
EUSQL_ERR_WHERE = 2,
EUSQL_ERR_FIELD = 3,
EUSQL_ERR_JOIN = 4,
EUSQL_ERR_TABLE = 5,
EUSQL_ERR_SYNTAX = 6,
EUSQL_ERR_INDEXEXISTS = 7,
EUSQL_ERR_DUPLICATE = 8,
EUSQL_ERR_NORECORD = 9

global constant
EUSQL_ERR_MSG =  {
				"OPERATION FAILED",
				"ERROR IN 'WHERE' CLAUSE",
				"INVALID FIELD",
				"JOIN ERROR",
				"INVALID TABLE",
				"SYNTAX ERROR",
				"INDEX EXISTS",
				"DUPLICATE VALUE NOT ALLOWED",
				"NO RECORDS WERE RETURNED"
				}
				
constant
EUSQL_ASTERISK = "*",
EUSQL_NULL = {},
EUSQL_WORDS =  {  "SELECT", 	-- 1
				"UNION",
				"FROM",
				"DISTINCT",
				"DISTINCTROW",	-- 5
				"AS",
				"WHERE",
				"INNER",
				"RIGHT",
				"LEFT", 		-- 10
				"JOIN",
				"ON",
				"AND",
				"OR",
				"LIKE", 		-- 15
				"<",
				">",
				"=",
				"<=",
				">=",			-- 20
				"BETWEEN",
				"INSERT",
				"INTO",
				"DELETE",
				",",			-- 25
				"ORDER",
				"BY",
				"DESC",
				"NULL",
				"IS",			-- 30
				"NOT",
				"COUNT",
				"SUM",
				"GROUP",
				"(",			-- 35
				")",
				"AVG",
				";",
				"UPDATE",
				"UNION",		-- 40
				"VALUES",
				"SET",
				"INTEGER",
				"ATOM",
				"TEXT", 		-- 45
				"SEQUENCE",
				"BINARY",
				"OBJECT",
				"CREATE",
				"DROP", 		-- 50
				"TABLE",
				"INDEX",
				"UNIQUE",
				"IN",
				"MAX",			-- 55
				"MIN",
				"AUTONUMBER",
				"+",
				"-",
--				"*",			-- ~60
				"/",			-- 60
				"IF",
				"MID",
				"LEN",
				"&",			-- 65
				"STR",
				"VAL",
				"DATABASE",
				"<>",
				"BOOLEAN",      -- 70
				"TRUE",
				"FALSE",
				"DATE_TIME",
				"NOW",
				"GET_YEAR",     -- 75
				"GET_MONTH",
				"GET_DAY",
				"GET_HOUR",
				"GET_MINUTE",
				"GET_SECOND",   -- 80
				"UPPER",
				"LOWER",
				"GET_DATE",
				"GET_TIME"

			}

--/topic Utilities
--/func get_sql_keyword( sequence word )
--
--Returns the code for the specified keyword.
global function get_sql_keyword( sequence word )
    return find( word, EUSQL_WORDS )
end function

global constant 		   
EUSQL_EU_INTEGER = get_sql_keyword( "INTEGER" ),
EUSQL_EU_ATOM = get_sql_keyword( "ATOM" ),
EUSQL_EU_TEXT = get_sql_keyword( "TEXT" ),
EUSQL_EU_SEQUENCE = get_sql_keyword( "SEQUENCE" ),
EUSQL_EU_BINARY = get_sql_keyword( "BINARY" ),
EUSQL_EU_OBJECT = get_sql_keyword( "OBJECT" ),
EUSQL_AUTONUMBER = get_sql_keyword( "AUTONUMBER" ),
EUSQL_EU_BOOLEAN = get_sql_keyword( "BOOLEAN" ),
EUSQL_EU_DATE_TIME = get_sql_keyword( "DATE_TIME" ),

EUSQL_DATE_TIME = EUSQL_EU_DATE_TIME  -- it's a dup, but this one is used as a function

constant
EUSQL_EU_DATATYPE = { EUSQL_EU_INTEGER, EUSQL_EU_ATOM, EUSQL_EU_TEXT,
	EUSQL_EU_SEQUENCE, EUSQL_EU_BINARY, EUSQL_EU_OBJECT, EUSQL_AUTONUMBER, 
	EUSQL_EU_BOOLEAN, EUSQL_EU_DATE_TIME }

constant
EUSQL_FROM = get_sql_keyword( "FROM" ),
EUSQL_SELECT = get_sql_keyword( "SELECT" ),
EUSQL_AS = get_sql_keyword( "AS" ),
EUSQL_WHERE = get_sql_keyword( "WHERE" ),
EUSQL_EQUAL = get_sql_keyword( "=" ),
EUSQL_GREATER = get_sql_keyword( ">" ),
EUSQL_LESS = get_sql_keyword( "<" ),
EUSQL_GTOE = get_sql_keyword( ">=" ),
EUSQL_LTOE = get_sql_keyword( "<=" ),
EUSQL_NOTE =get_sql_keyword( "<>" ),
EUSQL_LIKE = get_sql_keyword( "LIKE" ),
EUSQL_NULL_WORD = get_sql_keyword( "NULL" ),
EUSQL_IS = get_sql_keyword( "IS" ),
EUSQL_NOT = get_sql_keyword( "NOT" ),
EUSQL_OR = get_sql_keyword( "OR" ),
EUSQL_BETWEEN = get_sql_keyword( "BETWEEN" ),
EUSQL_IN = get_sql_keyword( "IN" ),

EUSQL_JOIN = get_sql_keyword( "JOIN" ),
EUSQL_INNER = get_sql_keyword( "INNER" ),
EUSQL_ON = get_sql_keyword( "ON" ),
EUSQL_AND = get_sql_keyword( "AND" ),
EUSQL_RIGHT = get_sql_keyword( "RIGHT" ),
EUSQL_LEFT = get_sql_keyword( "LEFT" ),

EUSQL_COMMA = get_sql_keyword( "," ),
EUSQL_ORDER = get_sql_keyword( "ORDER" ),
EUSQL_BY = get_sql_keyword( "BY" ),
EUSQL_DESC = get_sql_keyword( "DESC" ),
EUSQL_DISTINCT = get_sql_keyword( "DISTINCT" ),
EUSQL_LPAR = get_sql_keyword( "(" ),
EUSQL_RPAR = get_sql_keyword( ")" ),
EUSQL_SEMICOLON = get_sql_keyword( ";" ),

EUSQL_MID = get_sql_keyword( "MID" ),
EUSQL_LEN = get_sql_keyword( "LEN" ),
EUSQL_CONCAT = get_sql_keyword( "&" ),
EUSQL_STR = get_sql_keyword( "STR" ),
EUSQL_VAL = get_sql_keyword( "VAL" ),
EUSQL_UPPER = get_sql_keyword( "UPPER" ),
EUSQL_LOWER = get_sql_keyword( "LOWER" ),

EUSQL_COUNT = get_sql_keyword( "COUNT" ),
EUSQL_SUM = get_sql_keyword( "SUM" ),
EUSQL_GROUP = get_sql_keyword( "GROUP" ),
EUSQL_AVG = get_sql_keyword( "AVG" ),
EUSQL_MAX = get_sql_keyword( "MAX" ),
EUSQL_MIN = get_sql_keyword( "MIN" ),

EUSQL_GET_YEAR = get_sql_keyword( "GET_YEAR" ),
EUSQL_GET_MONTH = get_sql_keyword( "GET_MONTH" ),
EUSQL_GET_DAY = get_sql_keyword( "GET_DAY" ),
EUSQL_GET_DATE = get_sql_keyword( "GET_DATE" ),
EUSQL_GET_TIME = get_sql_keyword( "GET_TIME" ),
EUSQL_GET_HOUR = get_sql_keyword( "GET_HOUR" ),
EUSQL_GET_MINUTE = get_sql_keyword( "GET_MINUTE" ),
EUSQL_GET_SECOND = get_sql_keyword( "GET_SECOND" ),

EUSQL_INSERT = get_sql_keyword( "INSERT" ),
EUSQL_DELETE = get_sql_keyword( "DELETE" ),
EUSQL_UPDATE = get_sql_keyword( "UPDATE" ),
EUSQL_UNION = get_sql_keyword( "UNION" ),
EUSQL_VALUES = get_sql_keyword( "VALUES" ),
EUSQL_INTO = get_sql_keyword( "INTO" ),
EUSQL_DROP = get_sql_keyword( "DROP" ),
EUSQL_CREATE = get_sql_keyword( "CREATE" ),
EUSQL_TABLE = get_sql_keyword( "TABLE" ),
EUSQL_INDEX = get_sql_keyword( "INDEX" ),
EUSQL_UNIQUE = get_sql_keyword( "UNIQUE" ),
EUSQL_SET = get_sql_keyword( "SET" ),
EUSQL_DATABASE = get_sql_keyword( "DATABASE" ),

EUSQL_ADD = get_sql_keyword( "+" ),
EUSQL_SUBTRACT = get_sql_keyword( "-" ),
EUSQL_MULTIPLY = get_sql_keyword( "*" ),
EUSQL_DIVIDE = get_sql_keyword( "/" ),
EUSQL_IF = get_sql_keyword( "IF" ),

EUSQL_NOW = get_sql_keyword( "NOW" ),

EUSQL_TRUE = get_sql_keyword( "TRUE" ),
EUSQL_FALSE = get_sql_keyword( "FALSE" ),
TRUE_FALSE = { EUSQL_TRUE, EUSQL_FALSE, "FALSE", "TRUE" },

EUSQL_FIELD_VALUE = {-1},
EUSQL_FIELD_PARAM = {-2},
EUSQL_FIELD_CALC  = {-3},

EUSQL_MATH_AND = resolve_math_ref( "AND" ),
EUSQL_MATH_OR = resolve_math_ref( "OR" ),

EUSQL_FUNCTIONS = {EUSQL_LEN, EUSQL_MID, EUSQL_IF, EUSQL_LPAR, 
	EUSQL_STR, EUSQL_VAL, EUSQL_NOW, EUSQL_DATE_TIME, 
	EUSQL_GET_YEAR, EUSQL_GET_MONTH, EUSQL_GET_DAY, 
	EUSQL_GET_DATE, EUSQL_GET_TIME,
	EUSQL_GET_HOUR, EUSQL_GET_MINUTE, EUSQL_GET_SECOND,
	EUSQL_UPPER, EUSQL_LOWER},

AGG_LABEL = {
			  { 
			  EUSQL_GROUP,
			  EUSQL_SUM,
			  EUSQL_COUNT ,
			  EUSQL_AVG,
			  EUSQL_MAX,
			  EUSQL_MIN
			  },
			  { 		
			  "GROUP BY ",
			  "SUM OF ",
			  "COUNT OF ",
			  "AVG OF ",
			  "MAX OF ",
			  "MIN OF "
			  }
			 },

Q_COUNT = 13,

QN_TABLE = 1,
QN_INDICES = 2,
QN_NAMES = 3,
QN_ORDER = 4,
QN_WHERE = 5,
QN_JOINS = 6,
QN_ORDERING = 7,
QN_DISTINCT = 8,
QN_AGGREGATES = 9,
QN_VALUES = 10,
QN_DATATYPES = 11,
QN_FIELD_INDEX = 12,
QN_TABLE_ALIAS = 13,

QS_TABLE = {},
QS_INDICES = {},
QS_NAMES = {},
QS_ORDER = {},
QS_WHERE = { {} },
QS_JOINS = { },
QS_ORDERING = {},
QS_DISTINCT = 0,
QS_AGGREGATES = {},
QS_VALUES = { 0, {}, {}, {}, {}, {} },
QS_DATATYPES = {},
QS_FIELD_INDEX = {},
QS_TABLE_ALIAS = {},

Q_STRUCT = { QS_TABLE, QS_INDICES, QS_NAMES, QS_ORDER, QS_WHERE, QS_JOINS,
			 QS_ORDERING, QS_DISTINCT, QS_AGGREGATES, QS_VALUES, QS_DATATYPES,
			 QS_FIELD_INDEX, QS_TABLE_ALIAS }

global constant
SYSTEM_TABLES = {
					"TABLEDEF",
					"INDEXDEF"
				}



integer CUSTOM_COMPARE, PARSE_MAIN, GET_RECORD, last_table, expr_count,
	forward_reindex_table
sequence order_by, AGG_FUNC, param_table, current_table,
	current_db, db_list, parse_routines, store_current, table_wheres, join_wheres,
	table_records, from_tables, alias_tables, extended_error

store_current = {"",""}

parse_routines = repeat( 0, length( EUSQL_WORDS ) )

AGG_FUNC = repeat( 0, length( EUSQL_WORDS ) )
current_table = ""
current_db = ""
db_list = {}

expr_count = 1

extended_error = {}
order_by = {{},{}}
param_table = { {}, {} }

integer use_index
use_index = 0
global procedure with_index( integer ok )
	use_index = ok
end procedure

function is_datatype( object d )
	return find(d, EUSQL_EU_DATATYPE) 
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

function is_eu_atom( object o )
	return atom(o)
end function

function is_eu_boolean( object o )
	if sequence( o ) then
		return 0
	end if
	return ( o = 1 or o = 0 )
end function

function is_autonumber( object o )
	if sequence( o ) then
		return 0
	end if
	return o = floor(o)
end function

function is_eu_integer( object o )
	return integer(o)
end function

sequence text_char
text_char = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
text_char &= lower( text_char ) &
			" 1234567890!@#$%^&*`~()-=_+[]\\{}|;\':\",./<>?\n\t\r"

function is_eu_text( object o )
	if not sequence(o) then
		return 0
	end if
	
	for i = 1 to length( o ) do
		if not integer(o[i]) or o[i] < 0 or o[i] > 255 then
			return 0
		end if
--        if not find( o[i], text_char ) then
--            --? {o[i],o}
--            puts(1,o[i]) ? o[i]
--            return 0
--        end if
	end for
	
	return 1
end function

function is_eu_binary( object o )
	object a
	if not sequence( o ) then
		return 0
	end if
	for i = 1 to length( o ) do
		a = o[i]
		if sequence(a) or a>255 or a < 0 then
			return 0
		end if
	end for
	
	return 1
end function

function is_eu_sequence( object o )
	return sequence(o)
end function

function is_eu_object( object o )
	return 1
end function

constant DATATYPE_RID = {
					{	EUSQL_EU_ATOM,
						EUSQL_EU_INTEGER,
						EUSQL_EU_TEXT,
						EUSQL_EU_BINARY,
						EUSQL_EU_SEQUENCE,
						EUSQL_EU_OBJECT,
						EUSQL_AUTONUMBER,
						EUSQL_EU_BOOLEAN,
						EUSQL_EU_DATE_TIME
					},
					{	routine_id( "is_eu_atom" ),
						routine_id( "is_eu_integer" ),
						routine_id( "is_eu_text" ),
						routine_id( "is_eu_binary" ),
						routine_id( "is_eu_sequence" ),
						routine_id( "is_eu_object" ),
						routine_id( "is_autonumber" ),
						routine_id( "is_eu_boolean" ),
						routine_id( "is_eu_date_time" )
					}
				}

--/topic Utilities
--/func type_check( object o, integer datatype )
--
global function type_check( object o, integer datatype )
	if equal( o, {}) then 
		return 1
	end if
	return call_func( DATATYPE_RID[2][find( datatype, DATATYPE_RID[1] )],
		{o} )
end function

--/topic Errors
--/func get_sql_err( integer errnum )
--/info
--Use this to get a text representation of the error returned.  It also includes any 
--extended error information beyond the standard error.
global function get_sql_err( integer errnum )
	return "EuSQL Error: " & EUSQL_ERR_MSG[errnum] & "\n" & extended_error
end function

integer ferr
ferr = 1

--Errors
--------------------------------------------

--/topic Errors
--/info
--Trapping and using EuSQL error information
--When everything works, EuSQL returns a sequence.  If there is a problem, a positive integer 
--error code is returned.  Following is the descriptions of errors:
--
--<ul>
--/li EUSQL_FAIL = 1
--/li EUSQL_ERR_WHERE = 2
--/li EUSQL_ERR_FIELD = 3
--/li EUSQL_ERR_JOIN = 4
--/li EUSQL_ERR_TABLE = 5
--/li EUSQL_ERR_SYNTAX = 6
--</ul>
--
--The best method for retrieving error information is through the function /get_sql_err(), 
--which returns extended error information, as  well as the standard error message (see 
--description in API).  It is recommended that you call /get_sql_err() rather than accessing 
--EUSQL_ERR_MSG (see below), since you'll get a more detailed description of the error.
--
--EuSQL has predefined error strings, which can be accessed through EUSQL_ERR_MSG:
--
--/code
--global constant
--EUSQL_ERR_MSG =  {
--                "EuSQL Error: OPERATION FAILED",
--                "EuSQL Error: ERROR IN 'WHERE' CLAUSE",
--                "EuSQL Error: INVALID FIELD",
--                "EuSQL Error: JOIN ERROR",
--                "EuSQL Error: INVALID TABLE",
--                "EuSQL Error: SYNTAX ERROR"
--                }
--
--ex:
--
--object sql
--sql = "SELECT ID FROM EMPLOYEES;"
--sql = /parse_sql( sql )
--if atom(sql) then
--  puts(1, get_sql_err( sql ) )
--  abort(1)
--end if
--/endcode
--


--/topic Errors
--/proc eusql_err_out( integer fn )
--/info
--Redirects EuSQL typecheck errors.  If fn is positive, then errors are output
--to file number fn.  If fn is negative, then -fn is the routine id of a user
--specified callback procedure.  EuSQL will call this procedure if a typecheck
--fails.  The parameter will be the integer EUSQL_ERR_ code.  When the callback
--procedure returns, the typecheck will fail unless typechecking was previously
--turned off using /eusql_true_typecheck().  The default value is 1, which ouputs
--error messages to the console.
global procedure eusql_err_out( integer out )
	ferr = out
end procedure


--/topic Errors
--/proc eusql_true_typecheck( integer new_setting )
--/info
--Indicates whether typechecks for variables of type /EUSQLRESULT will return
--a value of zero.  This is independent of any calls to 'with type' or 'without type'.
--new_setting should be a boolean value.  If set to 0, /EUSQLRESULT typechecks 
--that fail will not crash if typechecking is on.

integer true_typecheck
true_typecheck = 1
global procedure eusql_true_typecheck( integer new )
	true_typecheck = new
end procedure

--/topic Errors
--/type EUSQLRESULT( object e )
--/desc User defined type
--/info
--Variables of type EUSQLRESULT are sequences, unless there is an error, at
--which point the variable will contain a positive integer.  If 'with type' is specified,
--typechecking will fail, and the error will be output to either
--a user specified routine or to the output stream specified by /eusql_err_out().
--If you call /eusql_true_typecheck( 0 ), then your program will not crash when
--a EUSQLRESULT is an integer.  EuSQL will pass control back to you.  If 'without type'
--is specified, EuSQL will not automatically catch errors.
global type EUSQLRESULT( object e )
	if sequence(e) then
		return 1
	end if

	if ferr >= 0 then
		puts( ferr, get_sql_err( e ) )
	else
		call_proc( -ferr, { get_sql_err( e ) } )
	end if
	if true_typecheck then
		return 0
	end if
	return 1
end type

-- Used by custom_sort to sort records
function custom_compare( sequence a, sequence b )
	integer c, ob
	
	-- we have [possibly] multiple sorting keys
	for i = 1 to length( order_by[1] ) do
		ob = order_by[1][i]
		--if ob < 0 then ob = -ob end if
		c = compare(a[ob],b[ob])
		if c then
			return c * order_by[2][i]
		end if
	end for
	return 0
end function
CUSTOM_COMPARE = routine_id( "custom_compare" )

-- custom_sort function for groups
function group_by( sequence a, sequence b )
	integer c, ob
	
	for i = 1 to length( order_by ) do
		ob = order_by[i]
		c = compare(a[ob],b[ob])
		if c then
			return c
		end if
	end for
	return 0
end function
constant GROUP_BY = routine_id("group_by")

function abs_val( object o )
	return o * ( (o >= 0) - (o < 0) )
end function

--/topic Utilities
--/func tokenize( sequence text, integer separator )
--/info
--Tokenizes a sequence based on a separator.  Used to tokenize a field to be passed to 
--validate_field().
-- tokenize function by F Dowling
-- (check the archives at www.rapideuphoria.com)
global function tokenize(sequence n, integer tokenSeperator)
		-- tokenizes a string into a sequence of tokens
		sequence current, result
		result = {}
		current = {}
		for i = 1 to length(n) do
				if (n[i] = tokenSeperator) then
						if (length(current) > 0) then
								result = append(result,current)
								current = {}
						end if
				else
						current = append( current, n[i] )
--						current &= n[i] 					   
				end if
		end for
		if (length(current) > 0) then
				result = append(result,current)
		end if
		return result
end function

-- replaces all instances of a with b in s
global function replace_all(sequence s, object a, object b)
	sequence t
	integer n,m

	if atom(a) then
		a = {a}
	elsif length(a) = 0 then
		return s
	end if

	if atom(b) then
		b = {b}
	end if

	-- Create a buffer big enough to cater for worst case replacement.
	m = (floor(length(s) / length(a)) + 1) * length(b)
	if m < length(s) then
		m = length(s)
	end if
	t = repeat(0, m)

	m = 1
	while 1 do
		n = match(a, s)
		if n then
			t[m..m+n-2] = s[1..n-1]
			m += (n-1)
			t[m..m+length(b)-1] = b
			m += (length(b))
			s = s[n+length(a) .. length(s)]
		else
			t[m..m+length(s)-1] = s
			m += (length(s))
			exit
		end if
	end while

	return t[1..m-1]
end function

-- removes all instances of a from text
function remove_all( sequence text, object a )
	integer ix
	
	if atom(a) then
		a = {a}
	end if
	
	ix = match( a, text )
	while ix do
		text = text[1..ix-1] & text[ix+length(a)..length(text)]
		ix = match( a, text )
	end while
	
	return text
end function

-- sequence must be sorted
function fast_find(object key, sequence s)
	-- return *key* index, or zero if key not found

	integer lo, hi, mid, c
	
	if length(s) >= 100 then
	
		lo = 1
		hi = length(s)
		while lo <= hi do
			mid = floor((lo + hi) / 2)
			c = compare(key, s[mid])
			if c < 0 then		-- key < s[mid]
				hi = mid - 1
			elsif c > 0 then	-- key > s[mid]
				lo = mid + 1
			else				-- key = s[mid]
				return mid
			end if
		end while
		return 0
	end if

	return find(key, s) 			-- unsorted, or short sorted list
end function -- index


-- return the intersection of two [sorted] sequences
function intersect_seq( sequence s1, sequence s2 )
	sequence I
	integer ix, jx, len2, len1

	len1 = length(s1)
	len2 = length(s2)
	if len1 > len2 then
		I = s1
		s1 = s2
		s2 = I
		len1 = len2
	end if

	I = repeat( {}, len1)
	jx = 0	  
	for i = 1 to length( s1 ) do
	
		ix = find(s1[i], s2 )
		if ix then
			jx += 1
			I[jx] = s1[i]
			--s2 = s2[ix..length(s2)]          
		end if
	end for
	return I[1..jx]
	

end function


function union_seq( sequence s1, sequence s2 )
	sequence U
	integer ix, jx, len2
	
	U = s2
	len2 = length( s2 )
	jx = 1
	
	for i = 1 to length(s1) do
		ix = fast_find( s1[i], s2[jx..len2] )
		jx += ix
		if not ix then
			U = append( U, s1[i] )
		end if
		
		if jx > len2 then
			exit
		end if
	end for
	
	return sort(U)
end function

-- eliminate the items in each list not in the intersection
-- of the list keys
function intersect_list( sequence l1, sequence l2 )
	sequence I1, I2, I
	
	-- get the intersection of the list keys
	I = intersect_seq( l1[1], l2[1] )
	
	I1 = repeat( {}, length( I ) )
	I2 = I1
	
	
	for i = 1 to length( I1 ) do
		-- get the data (record keys) using the list index
		I1[i] = fetch_list( l1, I[i] )
		I2[i] = fetch_list( l2, I[i] )
	end for
	
	return {{ I, I1}, {I, I2 }}
	
end function

function union_list( sequence l1, sequence l2 )
	sequence U1, U2
	integer ix
	
	U1 = union_seq( l1[1], l2[1] )
	U2 = repeat({}, length(U1))
	
	for i = 1 to length( U1 ) do
		ix = find( U1[i], l1[1] )
		
		if ix then
			U2[i] = l1[2][ix]
		else
			ix = find( U1[i], l2[1] )
			U2[i] = l2[2][ix]
		end if
	end for
	
	return { U1, U2 }
	
end function

-- slice out one element of a sequence
function remove_one( sequence s, integer ix )
	return s[1..ix-1] & s[ix+1..length(s)]
end function

function parameterize_token( sequence tok )
	return replace_all( upper(tok), " ", "_" )
end function

--/topic Queries
--/func get_parameter( sequence param )
--/info
--Returns the value of a parameter.
global function get_parameter( sequence param )
	integer ix
	ix = h:index( param_table, param )
	if not ix then
		return {}
	else
		return param_table[2][ix]
	end if
end function

--/topic Queries
--/proc set_parameter( sequence param_name, object param_value )
--/info
--Sets the value of a parameter to be used by a query.  Parameters must be enclosed in square 
--brackets ( [param1] ) when declared in a SQL statement, but the brackets must be omitted 
--when calling set_parameter.
global procedure set_parameter( sequence param, object val )
	integer ix
	
	param = parameterize_token( param )
	ix = h:index( param_table, param )
	
	if sequence( val ) then
		val = {DATA, val, {} }
	end if
	m:SetVar( '[' & param & ']', val )

	if ix then
		param_table = h:set_list( param_table, param, val )
	else
		param_table = h:insert( param_table, param, val )
	end if
end procedure


--/topic Queries
--/proc init_params()
--/info
--Initialize EuSQL parameters and store as Matheval variables.
global procedure init_params()
	integer ix
	ClearVar("")
	for i = 1 to length( param_table[1] ) do
		m:SetVar( '[' & param_table[1][i] & ']', param_table[2][i] )
	end for
	m:SetVar( "[EUSQL_NULL]", {DATA, {},{}})
	m:SetVar( "TRUE", {CONSTANT, {1}, {}})
	m:SetVar( "FALSE", {CONSTANT, {0}, {}})
end procedure

--/topic Queries
--/proc clear_params()
--/info
--Deletes all parameters previously set.

global procedure clear_params()
	param_table = { {}, {} }
	init_params()
end procedure

--/topic Utilities
--/func blank_field( sequence record_struct )
--/info
--Pass the result of /get_record_struct() to blank_field, and it will return a sequence with
--the correct structure, but with all empty sequences.
global function blank_field( sequence field )
	sequence blank
	
	blank = repeat( {}, length( field ) )
	for i = 1 to length( field ) do
		blank[i] = blank_field( field[i][2] )
	end for
	
	return blank
end function




--/topic DB Management
--/func select_table( sequence table )
--/info
--Change the current table.

global function select_table( sequence table_name )
	integer ok
	
	if db_select_table( table_name ) != DB_OK then
		extended_error = "Could not open table: \'" & table_name & "\'"
		return EUSQL_ERR_TABLE
	end if
	
	current_table = table_name
	
	return current_table
	
end function

--/topic DB Management
--/func select_db( sequence db )
--/info
--Change the current database.
global function select_db( sequence db_name )
	integer ok
	
	if db_select( db_name, exclusive_flag ) != DB_OK then
		extended_error = "Could not open database: \'" & db_name & "\'"
		return EUSQL_FAIL
	end if
	
	current_db = db_name
	if not find( db_name, db_list ) then
		db_list = append( db_list, db_name )
--		db_list &= { db_name }
	end if
	
	return current_db
	
end function

--/topic DB Management
--/func select_current( sequence db_name, sequence table_name )
--/info
--Change the current database and table.  An empty sequence for either parameter will use the 
--current setting.
global function select_current( sequence db_name, sequence table_name )
	object ok
	
	if length( db_name ) then -- and not equal( current_db, db_name ) then
		ok = select_db( db_name )
		if atom( ok ) then
			return ok
		end if
		current_db = db_name
	end if
	
	table_name = upper(table_name)
	
	if length( table_name ) then -- and not equal( current_table, table_name ) then
		ok = select_table( table_name )
		if atom( ok ) then
			return ok
		end if
		current_table = table_name
	end if
	
	return { current_db, current_table }
	
end function

integer current_flag
current_flag = 0
global procedure save_current()
	if length( current_db ) or length( current_table ) then
		store_current = append( store_current, { current_db, current_table })
		current_flag = 1
	else
		current_flag = 0
	end if
end procedure

global procedure restore_current()
	object ok
	integer len
	len = length( store_current )
	if len then
		if current_flag then
			ok = store_current[len]
			ok = select_current( ok[1], ok[2] )
		end if
		store_current = store_current[1..len-1]
	end if
end procedure


integer exclusive_flag
exclusive_flag = DB_LOCK_EXCLUSIVE

--/topic DB Management
--/proc eusql_exclusive( integer flag )
--
--Sets the mode with which EuSQL will open databases.  Valid values are:
--<ul>
--/li DB_LOCK_EXCLUSIVE (default)
--/li DB_LOCK_NO
--/LI DB_LOCK_SHARED
--</ul>
--See the database.e documentation that comes with Euphoria for more details on
--using the different modes.
global procedure eusql_exclusive( integer flag )
	exclusive_flag = flag
end procedure

--/topic DB Management
--/func open_db( sequence db_name )
--
--Opens a EuSQL database.  The default is to open the database with the
--EDS flag DB_LOCK_EXCLUSIVE.  To open databases with DB_LOCK_NO, use
--/eusql_exclusive().  Note that you should use the full cannonical
-- path to your database.


global function open_db( sequence db_name )
	atom ok
	sequence record
	
	ok = db_open( db_name, exclusive_flag )
	
	if ok != DB_OK then
		extended_error = "Couldn't open database: \'" & db_name & "\'"
		return EUSQL_FAIL
	end if
	
	-- new v0.75
	-- check for system tables
	ok = db_select_table( "TABLEDEF" )
	if ok != DB_OK then
		db_close()
		extended_error = db_name & " is not a valid EuSQL database"
		return EUSQL_FAIL
	end if
	
	ok = db_find_key( "TABLEDEF" )
	if ok < 1 then
		db_close()
		extended_error = "System tables are corrupted. Cannot find TABLEDEF in " & db_current_table() & "."
		return EUSQL_FAIL
	end if
	
	record = db_record_data( ok )

	if length(record) < 3 then
		db_close()
		extended_error = "System tables are corrupted. Record length < 3."
		return EUSQL_FAIL		
	end if

	if length(record) = 3 then
		-- add the AUTOINCREMENT field to TABLEDEF and update the other records

		record[1] = append( record[1], {"AUTOINCREMENT", "" })
--		record[2][1] &= {{5}}
--		record[2][2] &= EUSQL_EU_SEQUENCE
--		record[3] &= 0
		record[2][1] = append( record[2][1], {5} )
		record[2][2] = append( record[2][1], EUSQL_EU_SEQUENCE )
		record[3] = append( record[3], 0 )
		record = append( record, repeat( 0, length(record[2][1]) ))
		db_replace_data(ok, record)


		for i = 1 to db_table_size() do
			record = db_record_data( i )
			if length(record) = 3 then
				record = append( record, repeat( 0, length(record[2][1]) ))
				db_replace_data( i, record)

			end if
		end for
	end if
	
	if not find( db_name, db_list ) then
--		db_list &= { db_name }
		db_list = append( db_list, db_name )
	end if
	current_db = db_name
	
	return current_db
end function

--/topic DB Management
--/proc close_db( sequence db_name )
--/info
--Closes the specified database.
global procedure close_db( sequence db_name )
	integer ix
	object ok
	
	ix = find( db_name, db_list )
	if	ix then
		ok = select_db( db_name )
		db_close( )
		db_list = db_list[1..ix-1] & db_list[ix+1..length(db_list)]
	else

		ok = db_select( db_name )
		db_close()
	end if
	
end procedure

--/topic Utilities
--/func validate_field( sequence field, sequence struct ) 
--/info
--<ul>
--/li /b field is the tokenized version of a field name
--/li /b struct is from /get_record_struct()
--</ul>
--Returns the index of the field if valid.
--/code
--ex:
--  -- Assume a table "PERSON":
--  --      NAME.FIRST
--  --      NAME.LAST
--  --      EMAIL
--
--  field = tokenize( "NAME.FIRST", '.' )
--  struct = get_record_struct( my_db, "PERSON" )
--  field_index = validate_field( field, struct )
--
--  --  field_index = {1,1}
--
--/endcode

-- get the index of the field, and return it in a sequence
global function validate_field( sequence field, sequence struct )
	integer ix, jx
	sequence ss
	
	ix = 1
	ss = {}
	jx = 1
	
	field = upper(field)

	if equal(field, {EUSQL_ASTERISK}) then
		return { 0 } 
	end if
	
	while ix <= length( field ) and jx <= length( struct ) do
			
		if equal( struct[jx][1], field[ix] ) then
--			ss &= jx
			ss = append( ss, jx )
			
			-- Jump into substructure
			struct = struct[jx][2]
			jx = 1
			ix += 1
		else
			jx += 1
		end if
		
	end while
	
	-- catch instances where field name is too long...
	if ix <= length( field ) then
		ss = {}
	end if
	
	if length(ss) then
		return ss
	else
		extended_error = ""
		for i = 1 to length(field) do
			extended_error &= field[i]

			if i != length(field) then
				extended_error &= '.'
			end if
		end for
		return EUSQL_ERR_FIELD
	end if
	
end function

--/topic Utilities
--/func get_record_struct( sequence db_name, sequence table_name )
--/info
--Returns the TABLEDEF definition of the structure of the tables records.
global function get_record_struct( sequence db_name, sequence table_name)
	object ok
	save_current()
	table_name = upper(table_name)
	ok = select_current( db_name, "TABLEDEF" )
	if atom(ok) then
		restore_current()
		return ok
	end if
	ok = db_select_table( "TABLEDEF" )
	ok = db_find_key( table_name )
	if ok < 0 then
		restore_current()
		extended_error = "Table " & table_name & " not referenced in TABLEDEF (" & sprint(ok) & ")"
		return EUSQL_ERR_TABLE
	end if
	
	ok = db_record_data( ok )

	restore_current()
	return ok[1]
end function

--/topic Utilities
--/func validate_field2( sequence db_name, sequence table_name, sequence field_name )
--
--Returns the field index the field for /b field_name in table /b table_name in 
--the open database /b db_name.  This function calls /get_record_struct(), /tokenize() and 
--/validate_field() for you.  If you need to call this multiple times, it will be
--faster to store a local copy of the results from /get_record_struct() and /tokenize()
--and pass them directly to /validate_field().
--/code
--ex:
--  -- Assume a table "PERSON":
--  --      NAME.FIRST
--  --      NAME.LAST
--  --      EMAIL
--
--  field_index = validate_field( my_db, "PERSON", "NAME.FIRST" )
--
--  --  field_index = {1,1}
--
--/endcode
global function validate_field2( sequence db_name, sequence table_name, sequence field_name )
	object ok
	sequence struct
	
	ok = get_record_struct( db_name, table_name )
	if atom(ok) then
		return ok
	end if
	struct = ok
	
	field_name = tokenize( upper( field_name ), '.' )
	
	return validate_field( field_name, struct )

end function

-- tables in format:
--  1: case sensitive table names
--  2: field structure
--  3: case insensitive table names
--  4: info
function table_list()
	sequence tables
	integer ix
	object ok
	
	save_current()
	
	tables = db_table_list() 
	tables = { tables, tables, upper(tables), tables }
	ok = select_table( "TABLEDEF" )
	for i = 1 to length( tables[1] ) do
		--if not equal( tables[1][i], "TABLEDEF" ) then
			
			ix = db_find_key( tables[1][i] )
			tables[4][i] = db_record_data( ix )
			if ix < 0 then
				extended_error = "Invalid table: " & tables[1][i]
				return EUSQL_ERR_TABLE
			end if
			
			tables[2][i] = get_record_struct( "", tables[2][i] )
			
			if atom(tables[2][i]) then
				restore_current()
				return tables[2][i]
			end if
			ok = select_table("TABLEDEF")

		--end if
	end for
	
	-- add handling for values, parameters and calculated fields
	tables[1] &= { EUSQL_FIELD_VALUE, EUSQL_FIELD_PARAM, EUSQL_FIELD_CALC }
	tables[2] &= repeat({}, 3) 
	tables[3] &= { EUSQL_FIELD_VALUE, EUSQL_FIELD_PARAM, EUSQL_FIELD_CALC }

	restore_current()
	
	return tables
end function

global function get_tables( sequence db )
	object ok
	
	save_current()
	
	ok = select_db( db )
	if atom(ok) then
		restore_current()
		return ok
	end if
	
	ok = table_list()
	restore_current()
	if atom(ok) then
		return ok
	end if
	
	return ok[1]
end function

-- made these local to the file since should only be one
-- parse at a time
sequence tables, query
integer fx, ixs, aggregate_flag

-- figures out if there is an index for this field
-- if there is, it adds the index name to QN_FIELD_INDEX
-- if not, it adds a zero to QN_FIELD_INDEX
-- names/zeroes are added by 'fx' order
-- called by both include_field and add_field
procedure include_index( sequence field )
	integer tx, ix, ok
	sequence indexdef,	indices, tname
	object index

	tx = field[1]
	index = field[2]
	if tx > length( tables[4] ) then
		query[QN_FIELD_INDEX] = append( query[QN_FIELD_INDEX], 0 )
		return
	end if

	ok = find( index, tables[4][tx][2][1])

	if not ok or atom( tables[4][tx][3][ok] ) then
		query[QN_FIELD_INDEX] = append( query[QN_FIELD_INDEX], 0 )
		return
	end if

	tname = query[QN_TABLE][tx]
	tx = find(tname,tables[1])

	indexdef = tables[4][tx]
	indices = indexdef[2][1]
	indexdef = indexdef[3]

	ix = find( index, indices )
	if sequence( indexdef[ix] ) then
		query[QN_FIELD_INDEX] = append( query[QN_FIELD_INDEX], indexdef[ix] )
	else
		query[QN_FIELD_INDEX] = append( query[QN_FIELD_INDEX], 0 )
	end if

end procedure

-- field = { table, index }
procedure include_field( object field, sequence name )
	integer tx
	object ok
	tx = field[1]

	if not find( field[2], query[QN_INDICES][tx] ) or
	find(query[QN_TABLE][tx], {EUSQL_FIELD_VALUE, EUSQL_FIELD_PARAM, EUSQL_FIELD_CALC}) then
		-- Need to add the field to the query, but use a
		-- negative 'order' value so we can take it out
		-- of the final output
		query[QN_INDICES][tx] &= { field[2] }
--		query[QN_NAMES][tx] &= { name }
--		query[QN_ORDER][tx] &= -fx
		query[QN_NAMES][tx] = append( query[QN_NAMES][tx], name )
		query[QN_ORDER][tx] = append( query[QN_ORDER][tx], -fx )
		-- find out if there's an index for this field and if so,
		-- log it in QN_FIELD_INDEX
		-- tables[4] has TABLEDEF info
		-- {{field,...},{index name}}

		include_index( field )		  
		fx += 1
	end if

end procedure

function get_field_name(sequence sql )
	sequence field
	
	if ixs+1 < length( sql ) and (equal(sql[ixs+1], EUSQL_AS) or (aggregate_flag and
		equal(sql[ixs+1], EUSQL_RPAR) and equal(sql[ixs+2], EUSQL_AS) )) then
		-- alias for a field
		--query[QN_NAMES][tx] &= {sql[ixs+2]}
		
		if aggregate_flag then
			sql = remove_one( sql, ixs+1)
		end if			  

		field = sql[ixs+2]
		-- get rid of the AS NAME
		sql = remove_one( sql, ixs+1)
		sql = remove_one( sql, ixs+1)
		
		ixs += 2
	else
		-- just store the name as is
		-- query[QN_NAMES][tx] &= { sql[ixs] }
		field = sql[ixs]
	end if
	
	return field
end function

integer sequence_inside_expr
sequence_inside_expr = 0

function alias_to_tx( sequence alias )
	integer tx, ax, ix
	ax = find( alias, query[QN_TABLE_ALIAS] )
	if ax then
		-- already properly aliased in query...
		tx = ax
	else
		ix = find( alias, query[QN_TABLE] )
		if not ix then
			-- new alias that hasn't been recorded yet
			ax = find( alias, alias_tables )
			if not ax then
				extended_error = sprintf("Unknown table alias: \'%s\'\n",{alias})
				return EUSQL_ERR_TABLE
			end if

			ix = find( from_tables[ax], query[QN_TABLE] )
			if ix and ( length(query[QN_TABLE_ALIAS]) = 0 ) then
				-- a table that hasn't been referred to, yet, so
				-- we'll use it for the alias
				query[QN_TABLE_ALIAS][ix] = alias
				tx = ix
			elsif ix then
				-- found the table, but has another alias, so have to 
				-- add the table to the query...
				query[QN_TABLE] = append( query[QN_TABLE], from_tables[ax] )
				query[QN_TABLE_ALIAS] = append( query[QN_TABLE_ALIAS], alias_tables[ax] )
				query[QN_INDICES] = append( query[QN_INDICES], {} )
				query[QN_NAMES] = append( query[QN_NAMES], {} )
				query[QN_ORDER] = append( query[QN_ORDER], {} )
				query[QN_WHERE][2] = append( query[QN_WHERE][2], {} )
				tx = length(query[QN_TABLE])
			else
				-- invalid alias
				extended_error = sprintf("Unknown table alias: \'%s\'\n",{alias})
				return EUSQL_ERR_TABLE
			end if
		else
			-- alias is a real table name...
			if not length(query[QN_TABLE_ALIAS][ix]) then
				query[QN_TABLE_ALIAS][ix] = alias
				tx = ix
			else
				-- error...table requires an alias
				extended_error = sprintf("TABLE \'%s\' requires an alias\n", {alias})
				return EUSQL_ERR_TABLE
			end if
			
		end if

	end if
	return {tx}
end function

function parse_field( sequence sql )
	sequence curtok, field, lhs, tf
	integer tx, ix, jx
	object ok

	curtok = sql[ixs]

	field = curtok
	
	ix = 0
	
	if curtok[1] = '\'' then
		field = sprintf("EXPR%d",expr_count)
		expr_count += 1
		ok = curtok[2..length(curtok)-1]
		
		tx = find( EUSQL_FIELD_VALUE, query[QN_TABLE] )
		ix = 1
		
	elsif find(curtok[1], ".01234567890-" ) then
		
		ok = value( curtok )
		ok = ok[2]
					
		if sequence_inside_expr then
			field = curtok
		else
			field = get_field_name( sql )
		end if
						
		if equal( curtok, field ) then
			field = "EXPR" & sprint( expr_count )
			expr_count += 1
		end if
						
		tx = find( EUSQL_FIELD_VALUE, query[QN_TABLE] )
		
		ix = 1
	elsif curtok[1] = '[' 
	and curtok[length(curtok)] = ']' then
		-- parameter
		curtok = curtok[2..length(curtok)-1]
		ok = parameterize_token( curtok )
		field = curtok
						
		tx = find( EUSQL_FIELD_PARAM, query[QN_TABLE] )
		ix = 1
	end if
	
	if ix then
		return {tx, ok, field }
	end if
	

	ok = alias_to_tx( curtok )
	if sequence(ok) then
		tx = ok[1]
	else
		tx = 0
	end if
--	tx = find(curtok, upper(query[QN_TABLE]) )
	
	-- 10/27/03: fix to handle INSERT queries properly
	-- so you don't have to prepend the table name to
	-- the fields
	if (not tx or length(query[QN_VALUES][4])) and query[QN_VALUES][1] = EUSQL_INSERT then

		--tx = find( query[QN_VALUES][4], query[QN_TABLE] )
		-- change to use table aliases...
		ok = alias_to_tx( query[QN_VALUES][4] )
		if atom(ok) then
			return ok
		end if
		tx = ok[1]

		tf = tokenize( field, '.' )
		ok = validate_field( tf, tables[2][tx])
		if atom(ok) and length(tf) > 1 then
			ok = validate_field( tf[2..length(tf)], tables[2][tx] )
		end if
		
		if sequence(ok) then
			return {tx, ok, field}
		end if
	end if
	
	-- this misses fields that have the same name as a table...
	if tx and ixs > 1 and find(sql[ixs-1],{EUSQL_FROM, EUSQL_INTO, EUSQL_COMMA}) then
		if find( sql[ixs], tables[1] ) then
			sql[ixs] = {tx}
			ok = {}
		else
			ok = EUSQL_ERR_FIELD
			extended_error = sprintf("Invalid Field: '%s'", {sql[ixs]})
			return ok
		end if
	else
		
		field = tokenize( curtok, '.' )
		-- check for valid table
--		tx = find( field[1], tables[3] )
		ok = alias_to_tx( field[1] )
		if sequence(ok) then
			tx = ok[1]
		else
			tx = 0
		end if

		-- 4/9/03: added to catch fields with same name as a table
		if length(field) = 1 or not tx then
		-- table name not in front

			-- first check in known tables
			tx = 1

			for ft = 1 to length(alias_tables) do
--				tx = find( alias_tables[ft], query[QN_TABLE] )
				ok = alias_to_tx(alias_tables[ft])
				if sequence(ok) then
					tx = ok[1]
				else
					tx = 0
				end if
								
				if tx then

					ok = validate_field( field, tables[2][tx] )

					if sequence(ok) then
						return { tx, ok, curtok }
					end if
				end if
			end for
			
			ix = ixs
			jx = find( EUSQL_FROM, sql[ix..length(sql)] )
			if not jx then
			
				-- check for an alias
				ok = sql[ixs]
				for i = 1 to length( query[QN_NAMES] ) do
					tx = find( ok, query[QN_NAMES][i] )
					if tx then
						ok = {i, query[QN_INDICES][i][tx], ok, ixs }
						return ok
					end if
				end for

				extended_error = curtok
				return EUSQL_FAIL
			end if
			
			ix += jx
			curtok = sql[ix]
			tx = find( curtok, tables[3] )
			if not tx then
				extended_error = sprintf( "'%s' is not a valid field or table", {field[1]})
				return EUSQL_FAIL
			end if
			--tables[2][tx]
			ok = validate_field( field, tables[2][find(query[QN_TABLE][tx], tables[1])] )
		else
			ok = validate_field( field[2..length(field)], tables[2][find(query[QN_TABLE][tx], tables[1])] )
		end if
			
				
		if atom( ok ) then
		-- literal/parameter?
			if find(curtok, "['-1234567890") then					 
				field = {}
			else
				return ok
			end if
				
		else
			field = get_field_name( sql )
		end if
		
	end if
	
	return {tx, ok, field }
end function

function parse_literals( sequence sql )
	sequence curtok
	
	
	
	return sql
end function

function preprocess_sql( sequence sql )
	integer ix, ok, token, in_quote

	sql = append( sql, 32 )
	sql = replace_all( sql, "\n", " " )
	sql = replace_all( sql, "\r", " " )
	sql = replace_all( sql, "\t", " " )
	
	-- chop off the semicolon and any whitespace
	while find( sql[$], " \r\n\t;" ) do
		sql = sql[1..$-1]
	end while
	-- ensure proper spacing of equality operators for tokenization
	ix = 1
	in_quote = 0
	while ix <= length( sql ) do
		if sql[ix] = '\'' then
			in_quote = not in_quote
		elsif not in_quote and find(sql[ix], ";><=()+-*/" ) then
			if ix < length(sql) and find(sql[ix+1],"<>=;") then
				sql = sql[1..ix-1] & 32 & sql[ix..ix+1] & 32 & sql[ix+2..$]
				ix += 1
			else
				sql = sql[1..ix-1] & 32 & sql[ix] & 32 & sql[ix+1..$]
			end if
			ix += 1
		end if
		ix += 1
	end while
	
	-- Add spaces around commas, but only for commas outside of quotes
	ix = 1
	in_quote = 0
	while ix < length(sql) do
		if sql[ix] = '\'' then
			in_quote = 1 - in_quote
		elsif not in_quote and sql[ix] = ',' then
			sql = sql[1..ix-1] & " , " & sql[ix+1..$]
			ix += 2
		end if
		ix += 1
	end while
	
	sql = tokenize( sql, 32 )

	-- strings may have been improperly tokenized, so we
	-- put them back together, using quotes at the beginning
	-- or end of a field
	ix = 1
	while ix <= length( sql ) do

		if find(sql[ix][1], "'\"") and ((length(sql[ix])=1) or (not find(sql[ix][length(sql[ix])],"'\""))) then

			sql[ix][1] = '\''
			ok = 0
			while ix < length(sql) and not ok do
				sql = sql[1..ix-1] & {sql[ix] & 32 & sql[ix+1]} & 
					  sql[ix+2..$]
				if sql[ix][$] = '\'' then
					ok = 1
				end if 
			end while
			
		end if
		ix += 1
	end while
	
	-- parameters may have been improperly tokenized, so we
	-- put them back together, using brackets at the beginning
	-- or end of a field
	ix = 1
	while ix <= length( sql ) do
		if sql[ix][1] = '[' and sql[ix][length(sql[ix])] != ']' then
			ok = 0
			while not ok do
				sql = sql[1..ix-1] & {sql[ix] & 32 & sql[ix+1]} & 
					  sql[ix+2..length(sql)]
				if sql[ix][length(sql[ix])] = ']' then
					ok = 1
				end if 
			end while
		end if
		ix += 1
	end while
	
	-- change 'reserved words' into atoms based on EUSQL_WORDS
	for i = 1 to length( sql ) do
		-- anything in double *or* single quote should be 
		-- case sensitive
		if not find(sql[i][1], "\'\"") then
			sql[i] = upper( sql[i] )
			token = find( sql[i], EUSQL_WORDS )
			if token and not find( token, TRUE_FALSE ) then
				sql[i] = token
			end if
		end if
	end for

	return sql
end function

function get_datatype( integer tx, object index )
	object ok
	integer dt, ix
	sequence temp
	if query[QN_TABLE][tx][1] > 0 then

		ok = call_func(GET_RECORD,{ "", "TABLEDEF", 
						query[QN_TABLE][tx], "INFO", "" })

		if atom(ok) then
			dt = EUSQL_EU_OBJECT
		else

			temp = ok[1]

			ix = find( index, temp[1] )
			if not ix then
				dt = EUSQL_EU_OBJECT
			else
				dt = temp[2][ix]
			end if
		end if

	else

		-- not a normal field, need to refine this
		dt = EUSQL_EU_OBJECT
	end if
	return dt
end function

procedure add_field( integer tx, object index, sequence name )
	object ok
	sequence temp
	integer ix

	query[QN_INDICES][tx] = append( query[QN_INDICES][tx], index )
	query[QN_NAMES][tx] = append( query[QN_NAMES][tx],  name )
	query[QN_ORDER][tx] = append( query[QN_ORDER][tx], fx )

	-- store the datatype
	query[QN_DATATYPES] &= get_datatype( tx, index )
--	if query[QN_TABLE][tx][1] > 0 then
--
--		ok = call_func(GET_RECORD,{ "", "TABLEDEF", 
--						query[QN_TABLE][tx], "INFO", "" })
--
--		if atom(ok) then
--			query[QN_DATATYPES] = append( query[QN_DATATYPES], EUSQL_EU_OBJECT )
--		else
--
--			temp = ok
--			temp = temp[1]
--
--			ix = find( index, temp[1] )
--			if not ix then
--				query[QN_DATATYPES] = append(query[QN_DATATYPES], EUSQL_EU_OBJECT)
--			else
--				query[QN_DATATYPES] = append(query[QN_DATATYPES], temp[2][ix])
--			end if
--		end if
--
--	else
--
--		-- not a normal field, need to refine this
--		query[QN_DATATYPES] = append( query[QN_DATATYPES], EUSQL_EU_OBJECT )
--	end if
	ok = find( index, tables[4][2] )
	include_index( {tx,index} ) 	   
	fx += 1
end procedure


function index_to_order( integer tx, object index )
	integer ix
	
	-- do we need to do this?
	--if equal( EUSQL_FIELD_PARAM, query[QN_INDICES][tx] ) then
	--    index = index[2..length(index)-1
	--end if
	ix = find( index, query[QN_INDICES][tx] )
	
	if ix then
		ix = query[QN_ORDER][tx][ix]
	end if
	
	return ix
end function

function order_to_index( integer order )
	integer ix
	for i = 1 to length( query[QN_ORDER] ) do
		ix = find( order, query[QN_ORDER][i] )
		if ix then
			return query[QN_INDICES][i][ix]
		else
			ix = find(-order, query[QN_ORDER][i])
			if ix then
				return query[QN_INDICES][i][ix]
			end if
		end if
	end for
	
	return {}
end function


function flat_names( sequence struct, sequence index, sequence names )
	sequence flat, name
	integer ix

	flat = {}
	name = names
	for i = 1 to length( struct ) do
		
		if length( struct[i][2] ) then
			if i > 1 then
				names &= names & struct[i][1] & "."
			else
				names &= struct[i][1] & "."
			end if
			
			flat &= flat_names( struct[i][2], index, names )
			
		else
			flat &= { names & struct[i][1] }
		end if
		
		names = name
		
	end for
	
	return flat
end function

--/topic Utilities
--/func flat_field_names( sequence db, sequence table )
--/ret flattened version of column names
-- Names for fields with subfields are not returned.

global function flat_field_names( sequence db, sequence table )
	object ok
	
	ok = select_current( db, table )
	if atom(ok) then
		return ok
	end if

	ok = get_record_struct( db, table )
	if atom(ok) then
		return ok
	end if
	return flat_names( ok , {}, {} )
end function

--/topic Utilities
--/func eusql_field_types( sequence db, sequence table )
--/info
--Returns a sequence of field types for a table.
global function eusql_field_types( sequence db, sequence table )
object ok
sequence result
	ok = select_current( db, "TABLEDEF" )
	if atom(ok) then
		result = ok
	else
		-- now get the record from the table_def whose name is 'table'
		ok = db_find_key( upper( table ) )
		if ok > 0 then
			result = db_record_data(ok)
			result = result[2][$]
		else
			result = ok
		end if
	end if
	return result
end function

--/topic Utilities
--/func flat_record( sequence record, sequence struct )
--/info
--Returns the flattened version of the data of a record.  Data for fields with subfields 
--are not returned.
global function flat_record( sequence record, sequence struct )
	sequence flat
	flat = {}
	
	for i = 1 to length( struct ) do
		
		if length( struct[i][2] ) then
			flat &= flat_record( record[i], struct[i][2] )
		else
			flat &= { record[i] }
		end if
		
	end for
	
	return flat
end function


--/topic Utilities
--/func flat_index( sequence struct, sequence index )
--/info
--Returns a flattened version of indices for a record.  Indices for fields with subfields are 
--not returned.  'index' should be an empty sequence.
global function flat_index( sequence struct, sequence index )
	sequence flat
	integer ix
	
	flat = {}
	
	index = append( index, 0 )
	ix = length( index )
	
	for i = 1 to length( struct ) do
		
		index[ix] = i
		
		if length( struct[i][2] ) then
			
			flat &= flat_index( struct[i][2], index )
		else
			flat = append( flat, index )
		end if
	end for
	
	return flat
end function

--/topic Utilities
--/func seq_remove( object a, sequence b )
--
--Removes element a[b[1]][...]
global function seq_remove( object a, sequence b )
	integer len,  sub
	len = length(b)
	sub = b[1]

	if sub > len then
		return a
	
	elsif len = 1 then
		return a[1..sub-1] & a[sub+1..$]
	
	else
		a[sub] = seq_remove( a[sub], b[2..$] )
	end if
		
	return a
end function

--/topic Utilities
--/func seq_fetch( object a, sequence b )
--
-- return a[b...]
global function seq_fetch(object a, sequence b)
	
	for i = 1 to length(b) do
		if b[i] > length(a) then
			return {}
		end if
		a = a[b[i]]
		
	end for
	
	return a
end function

--/topic Utilities
--/func seq_store(object a, object b, object c)
--
--Store a in b at subcript c
global function seq_store(object a, object b, object c)
	integer len
	
	if atom(c) then
		c = {c}
	end if
	
	len = length(c)
	
	-- now it will insert a new element!
	if c[1] = -1 or length(b) + 1 = c[1] then
		return b & { a }
	elsif len > 1 then
		-- recursively go into the sequence
		
		b[c[1]] = seq_store(a, b[c[1]], c[2..len] )
		return b
	end if
	
	-- get the index
	c = c[1]
	
	if c then
		b[c] = a
	else
		b = a	 
	end if
	
	return b
end function


global function field_to_index( sequence db_name, sequence table_name,
		sequence field )
	
	object ok
	atom recnum
	sequence struct, record, index
	
	save_current()
	
	ok = get_record_struct( db_name, table_name )
	if atom(ok) then
		return ok
	end if
	struct = ok
	ok = validate_field( tokenize( field, '.' ), struct )
		
	if atom(ok) then
		return ok
	end if
		
	if equal(ok, {0} ) then
		index = flat_index( struct, {} )
	else		
		index = ok
	end if
	
	restore_current()
	return index
end function

--/topic Data
--/func get_record_mult_fields( sequence db_name, sequence table_name, object key, sequence field, sequence index )
--
--Retrieves multiple fields from a record.
global function get_record_mult_fields( sequence db_name, sequence table_name,
		object key, sequence field, sequence index )
	object ok
	atom recnum
	sequence struct, record, fields
	
	save_current()
	ok = select_current( db_name, table_name )
	
	
	if length( field ) then
		field = upper(field)
		for i = 1 to length(field) do
			ok = field_to_index( db_name, table_name, field[i] )
			if atom(ok) then
				restore_current()
				return ok
			end if
			
			index = append(index, ok)
		end for
	end if
	
	recnum = db_find_key( key )
	if recnum < 0 then
		restore_current()
		extended_error = "Record does not exist"
		return EUSQL_ERR_FIELD
	end if
	
	record = { key } & db_record_data( recnum )
	
	restore_current()
	fields = repeat({}, length(index))
	if length( index ) then
		for i = 1 to length( index ) do
			fields[i] = seq_fetch( record, index[i] )
		end for
		return fields
	else
		return { record }
	end if
	
end function

--/topic Data
--/func get_record( sequence db_name, sequence table_name, object key, sequence field, sequence index )
--/info
--Returns a field (or the whole field as a flat record) with primary key = key from table 
--table_name.  You may specify either the field name or the index (as returned by 
--validate_field()).  Data is returned as a sequence.  To get the actual value, take the
--first element of the data returned.  This is to allow error processing.
global function get_record( sequence db_name, sequence table_name,
		object key, sequence field, sequence index )

	if length( field ) then
		return get_record_mult_fields( db_name, table_name, key, {field}, {})
	else
		return get_record_mult_fields( db_name, table_name, key, {}, {index})
	end if
end function

function Get_Record( sequence db_name, sequence table_name,
		object key, sequence field, sequence index )
		return get_record( db_name, table_name, key, field, index )
end function
GET_RECORD = routine_id( "get_record" )


--/topic Utilities
--/func get_next_autonumber( sequence db, sequence table, sequence field, sequence index )
--
--Returns the value of the next AUTONUMBER that will be assigned 
--for the specified field.  You can either specify the name of the field in /b field, or
--the index of the field (as returned by /validate_field()) in /b index.
global function get_next_autonumber( sequence db, sequence table, sequence field, sequence index )
	object ok
	sequence fields, indices, auto
	integer ix
	table = upper( table )
	ok = get_record_mult_fields( db, "TABLEDEF", table, {"FIELDS","INFO.INDICES","AUTOINCREMENT"},{})
	if atom(ok) then
		return ok
	end if

	fields = ok[1]
	indices = ok[2]
	auto = ok[3]

	if length(index) then
		ok = index

	elsif length(field) then
		
		if atom(field[1]) then
			field = tokenize( field, '.' )
		end if
	
		ok = validate_field( field, fields )
		if atom(ok) then
			return ok
		end if
		
	else
		extended_error = "Missing field"
		return EUSQL_FAIL
		
	end if
	
	ix = find( ok, indices )
	if not ix then
		extended_error = "TABLEDEF entry for " & table & " may be corrupt"
		return EUSQL_FAIL
	end if
	
	return {auto[ix]+1} 
end function

--/topic Utilities
--/func get_field_datatype( sequence db, sequence table, sequence field )
--
--Returns the datatype for the field.  /b field can be either tokenized or untokenized.
global function get_field_datatype( sequence db, sequence table, sequence field )
	object ok
	sequence fields, indices, datatypes
	integer ix
	
	if not length(field) then
		return EUSQL_FAIL
	end if
	
	ok = get_record_mult_fields( db, "TABLEDEF", table, {"FIELDS","INFO.INDICES","INFO.DATATYPES"},{})
	if atom(ok) then
		return ok
	end if

	fields = ok[1]
	indices = ok[2]
	datatypes = ok[3]

	if atom(field[1]) then
		field = tokenize( field, '.' )
	end if

	ok = validate_field( field, fields )
	if atom(ok) then
		return ok
	end if

	ix = find( ok, indices )
	if not ix then
		extended_error = "TABLEDEF entry for " & table & " may be corrupt"
		return EUSQL_FAIL
	end if
	
	return {datatypes[ix]}
end function

--/topic Utilities
--/func blank_record( sequence db, sequence table )
--/info
--Returns an empty record for specified table where all fields are empty sequences.  This wraps
--blank_field() and get_record_struct() into one call.
global function blank_record( sequence db, sequence table )
	sequence record
	object ok
	save_current()
	record = {}
	
	ok = select_current( db, table )
	if atom(ok) then
		return ok
	end if
	
	table = upper(table)
	ok = get_record( "", "TABLEDEF", table, "FIELDS",{})
	if atom(ok) then
		return ok
	end if
	
	restore_current()
	return blank_field( ok[1] )
end function


constant 
VALID_WHERE = {
EUSQL_EQUAL, EUSQL_GREATER, EUSQL_LESS, EUSQL_GTOE, EUSQL_LTOE,
	EUSQL_LIKE, EUSQL_AND, EUSQL_BETWEEN ,EUSQL_OR, EUSQL_LPAR,
	EUSQL_RPAR, EUSQL_IN, EUSQL_NOT, EUSQL_ADD, EUSQL_SUBTRACT,
	EUSQL_MULTIPLY, EUSQL_DIVIDE, EUSQL_LEFT, EUSQL_RIGHT,
	EUSQL_LEN, EUSQL_MID, EUSQL_CONCAT, EUSQL_VAL, EUSQL_STR,
	EUSQL_IF, EUSQL_NOTE, EUSQL_NOW, EUSQL_DATE_TIME,
	EUSQL_GET_YEAR, EUSQL_GET_MONTH, EUSQL_GET_DAY, 
	EUSQL_GET_DATE, EUSQL_GET_TIME,
	EUSQL_GET_HOUR, EUSQL_GET_MINUTE, EUSQL_GET_SECOND,
	EUSQL_UPPER, EUSQL_LOWER
	},

VALID_BOOL = {	AND, OR, EQUALTO, GREATER, LESS, LIKE, GOE, LOE, NOT }


-- need to rethink this...doesn't seem to work...
function merge_bool( object b1, object b2 )
	sequence a

	if atom(b1) then
		return {CONSTANT, {b1},{}}
	elsif atom(b2) then
		return {CONSTANT, {b2},{}}
	end if
	
	if not length(b1) then
		return b2
	end if

	-- Both funcs should be same
	a = { b1[FUNC], {}, {} }
	
	if length(b1) and equal(b1[FUNC], CONSTANT) then
		return b1
	elsif length(b2) and equal(b2[FUNC], CONSTANT ) then
		return b2
	else
		
		-- the args should be symmetrical, since they're not
		-- constants, so we only need to check one
		if find( b1[ARG1][FUNC], VALID_BOOL ) then
			a[ARG1] = merge_bool( b1[ARG1], b2[ARG1] )
		else
			a[ARG1] = b1[ARG1]
		end if
		
		if find( b1[ARG2][FUNC], VALID_BOOL ) then
			a[ARG2] = merge_bool( b1[ARG2], b2[ARG2] )
		else
			a[ARG2] = b1[ARG2]
		end if
	end if
	
	return a
end function

-- insert the where condition into the query
function mathize_name( sequence name )
	name = replace_all( name, ' ', '_')
	name = replace_all( name, '.', '_')
	if name[1] = '\'' and name[length(name)] = '\'' then
		name[1] = '"'
		name[length(name)] = '"'
	end if
	return name
end function

-- don't need to worry about stuff that isn't toplevel, or part
-- of an AND operation, specifically, stuff that's downstream 
-- of an OR
function necessary_conditions( sequence expr )
	sequence necessary
	necessary = {}
	expr = {expr}
	while length(expr) do
		if expr[1][FUNC] = AND then
			expr &= expr[1][ARG1..ARG2]
		elsif expr[1][FUNC] != OR then
			necessary = append( necessary, expr[1] )
		end if
		expr = expr[2..length(expr)]
	end while
	return necessary
end function

function fields_in_expr( sequence expr, sequence fields )
	sequence the_fields
	the_fields = {} 
	--{order val, name}	
	expr = {expr}
	while length(expr) do
		if expr[1][FUNC] = VAR then
			for table = 1 to length(fields) do
				for f = 1 to length(fields[table]) do
					if equal(expr[1][ARG1], fields[table][f][2]) then
						the_fields = append( the_fields, fields[table][f] & table )
						exit
					end if
				end for
			end for
		else
			if matheval_seq( expr[1][ARG1] ) then
				expr = append( expr, expr[1][ARG1] )
			end if

			if matheval_seq( expr[1][ARG2] ) then
				expr = append( expr, expr[1][ARG2] )
			end if
		end if
		expr = expr[2..length(expr)]
	end while

	return the_fields
end function

function parse_where( sequence sql )
	sequence clause, fields, necessary, expr
	object token, ok
	integer tx

	clause = ""
	fields = repeat( {}, length( query[QN_TABLE] ))
	ixs += 1
	while ixs <= length(sql) do
		token = sql[ixs]
		if atom( token ) then
			if find( token, VALID_WHERE ) then
				clause &= EUSQL_WORDS[token] & 32
				if token = EUSQL_IN then

					ixs += 1
					while ixs < length(sql) and compare(sql[ixs], EUSQL_RPAR ) do
						clause &= " "
						if atom(sql[ixs]) then
							clause &= EUSQL_WORDS[sql[ixs]]
						else
							if sql[ixs][1] = '\'' then
								sql[ixs][1] = '"'
								sql[ixs][length(sql[ixs])] = '"'
							else
								-- just to make sure a field gets included if required
								ok = { parse_field(sql), mathize_name( sql[ixs] )}
							end if
							clause &= sql[ixs] 
						end if
						ixs += 1
					end while

					clause &= ") "
				end if
			elsif token = EUSQL_IS then

				if ixs = length(sql) or not equal(sql[ixs+1],EUSQL_NULL_WORD) then
					if match({EUSQL_NOT, EUSQL_NULL_WORD}, sql[ixs..ixs+2]) != 2 then
						extended_error = "Invalid WHERE clause: Expected NULL or NOT NULL after IS"
						return EUSQL_ERR_WHERE
					end if
				end if

				ixs += 1
				if sql[ixs] = EUSQL_NOT then
					clause &= " != "
					ixs += 1
				else
					clause &= " = "
				end if

				clause &= "[EUSQL_NULL]"

			elsif token = EUSQL_ORDER then
				ixs -= 1
				exit
			
			else
				extended_error = "Invalid WHERE clause: '" & 
								 EUSQL_WORDS[token] & "'"
				return EUSQL_ERR_WHERE
			end if
		else

			if token[1] = '"' then
					
			elsif token[1] = '\'' then
					token[1] = '"'
					token[length(token)] = '"'
			elsif not find( token, TRUE_FALSE ) then
				
				ok = value( token )
				if ok[1] != GET_SUCCESS then
					-- not a number.  need to find which field this is
					-- and possibly add to query, also store for later 
					-- reference so we know which fields need to be stored
					
					ok = { parse_field(sql), mathize_name( token )}
					if atom( ok[1] ) then
						extended_error = "Invalid field: " & token
						return EUSQL_ERR_FIELD
					end if
					tx = ok[1][1]
					include_field( ok[1], ok[1][2] )
					ok[1] = ok[1][2]
					fields[tx] = append( fields[tx], ok )
					token = ok[2]
				end if
			end if
			clause &= token & 32
		end if
		ixs += 1
	end while

	ok = Parse( clause )
	if ok[1] = INVALID then
		extended_error = "Error in clause: " & ok[2] & "\n" & clause
		return EUSQL_ERR_WHERE
	end if
	expr = ok
	
	necessary = necessary_conditions( ok )
	for i = 1 to length(necessary) do
		necessary[i] = { necessary[i], fields_in_expr( necessary[i], fields ) }
	end for

	ok = necessary
	necessary = repeat( "", length(query[QN_TABLE]) )
	for i = 1 to length( ok ) do
		for j = 1 to length(ok[i][2]) do
			necessary[ok[i][2][j][3]] = append( necessary[ok[i][2][j][3]], {ok[i][1], ok[i][2][j]} )
		end for
	end for

	-- format:  { expr, { {order val, name} } }  [3] ?= { necessary, fields(orderval,name)}
	query[QN_WHERE] = { expr, fields, necessary }

	return sql
end function

-- These constants are used in finding the most fitting data type
constant
DT = 	 {	EUSQL_EU_INTEGER, EUSQL_EU_ATOM, EUSQL_EU_TEXT, EUSQL_EU_BINARY, EUSQL_EU_SEQUENCE, 
			EUSQL_EU_OBJECT, EUSQL_AUTONUMBER, EUSQL_EU_DATE_TIME },
DT_CAT = {	2, 2, 3, 3, 3, 1, 2, 3 },
DT_LEVEL = {
				{EUSQL_EU_OBJECT},
				{EUSQL_EU_ATOM, EUSQL_EU_INTEGER, EUSQL_AUTONUMBER},
				{EUSQL_EU_SEQUENCE, EUSQL_EU_BINARY, EUSQL_EU_TEXT, EUSQL_EU_DATE_TIME}}

-- pass a sequence of datatypes, and get the best fit back
function datatype_lcd( sequence types )
	integer dt, dt2, cat, cat2, level, level2

	if not length(types) then
		return EUSQL_EU_OBJECT
	end if
	
	dt = types[1]
	if dt = EUSQL_EU_OBJECT then
		return dt
	end if
	
	cat = DT_CAT[ find( dt, DT ) ]
	level = find( dt, DT_LEVEL[cat] )
	for i = 2 to length(types) do
		dt2 = types[i]
		cat2 = DT_CAT[ find( dt2, DT ) ]
		level2 = find( dt2, DT_LEVEL[cat2] )
		
		if cat != cat2 then
			return EUSQL_EU_OBJECT
		end if
		
		if level > level2 then
			dt = dt2
			cat = cat2
			level = level2
		end if
		
	end for
	
	return dt
end function

function literal_datatype( object data )
	if integer(data) then
		return EUSQL_EU_INTEGER
	elsif atom( data ) then
		return EUSQL_EU_ATOM
		
	elsif is_eu_text( data ) then
		return EUSQL_EU_TEXT
	
	elsif is_eu_binary( data ) then
		return EUSQL_EU_BINARY
	
	else
		return EUSQL_EU_SEQUENCE
		
	end if
end function

-- This routine is now slightly misnamed.  It originally was used to
-- parse sequences in sql--i.e., non-EUSQL_WORDS, but it's been expanded
-- with the advent of calculated fields, since a function could show up
-- before an actual field name or literal value.

integer sequence_marker
sequence_marker = 0
sequence expr_types
expr_types = {}

function parse_sequence( sequence sql )
	object ok, curtok
	sequence field, add, expr
	integer tx, ix, parens, tf

	add = {}
	
	
	if ixs > 1 and equal(sql[ixs-1], EUSQL_AS) then
		return sql
	end if
	
	if atom(sql[ixs]) then
		-- it looks like a calculated field that starts with
		-- a function
		ok = {}
		add = {}
		sequence_inside_expr = 2
		if equal( query[QN_VALUES][1], EUSQL_UPDATE) then
			sequence_marker = ixs
			query[QN_VALUES][3] = append( query[QN_VALUES][3], fx - 1 )
		end if
		curtok = sql[ixs]
	else

		curtok = sql[ixs]
		
		-- convert true/false into "1"/"0"
		tf = find( curtok, TRUE_FALSE )
		if tf then
			 sql[ixs] = "1" - (tf-3)
			 curtok = sql[ixs]
		end if
		
		ok = parse_field( sql )

		if atom(ok) then
			return ok
		end if
						
		-- get the respective 'table' index
		tx = ok[1]
		field = ok[3]
		ok = ok[2]
	end if

	-- this goes into the values clause (if not inside an expr)
	-- stores the order
	if length(query[QN_VALUES][2])
	and query[QN_VALUES][2][1] and sequence_inside_expr != 1 then

		query[QN_VALUES][2][2] = append( query[QN_VALUES][2][2], fx)

	end if

	if sequence_marker and sequence(sql[ixs]) then

		add = {{tx,ok,field}}
	elsif atom(ok) then

		add = {{ tx, ok, field }}
		--add_field( tx, ok, field )
		if equal(query[QN_VALUES][1], EUSQL_UPDATE ) and equal(sql[ixs-1], EUSQL_EQUAL) then
			-- update table.name set ... field.name = <value>


			query[QN_VALUES][3] = append( query[QN_VALUES][3], fx - 1 )
			-- changed from -2 to -1  ^^^ 1/30/04
			
			sequence_marker = ixs
			sequence_inside_expr = 2

		end if			
	elsif equal( ok, {0} ) then

		-- add all fields for select "*"
		ok = tables[2][tx]
		ok = { flat_index( ok,{}), flat_names(ok,{},{}) }

		for i = 1 to length( ok[1] ) do
			add_field( tx, ok[1][i], ok[2][i] )
		end for

	elsif not length(ok) and compare( curtok, "''") then
		-- table

	elsif find(query[QN_VALUES][1], 
			{ EUSQL_SELECT, EUSQL_DELETE } ) then

		add = {{ tx, ok, field }}
		
	elsif find(query[QN_VALUES][1],
		{EUSQL_INSERT, EUSQL_UPDATE}) then

		add = {{ tx, ok, field }}

		
		if equal( sql[ixs-1], EUSQL_EQUAL ) then

			-- must be part of an update clause,
			-- so we'll add the orders to QN_VALUES
			-- i.e., set field.name = something
			query[QN_VALUES][3] = append( query[QN_VALUES][3], fx - 1 )

			-- this checks to see if we're setting a value using a
			-- calculation
			if ixs = length(sql) or find( sql[ixs+1], {EUSQL_COMMA, EUSQL_WHERE}) then
				-- nope, this was it, so go ahead and log it
				query[QN_VALUES][4] = append( query[QN_VALUES][4], fx)
			else
				-- it's a calculated field, so remember to add to query[QN_VALUES]
				sequence_marker = ixs
				sequence_inside_expr = 2
			end if
		end if
	else

		extended_error = "Unknown query type: " & curtok
		return EUSQL_ERR_SYNTAX
	end if

	if length(add) or sequence_inside_expr = 2 then

		if not sequence_inside_expr and ixs < length(sql) and 
		(find( sql[ixs+1], {EUSQL_FROM, EUSQL_COMMA, EUSQL_VALUES, EUSQL_AS, EUSQL_RPAR}) 
		or (query[QN_VALUES][1] = EUSQL_UPDATE and find( EUSQL_EQUAL, sql[ixs-1..ixs+1]))) then
			expr_types = {}
			for a = 1 to length(add) do
				add_field( add[a][1], add[a][2], add[a][3] )
			end for

		elsif sequence_inside_expr = 1 then
			add = add[1]
			if compare( query[QN_TABLE][add[1]][1], EUSQL_FIELD_VALUE ) then
				include_field( add[1..2], add[3] )
				expr_types &= get_datatype( add[1], add[2] )
			else
				-- literal??
				expr_count -= 1
				expr_types &= literal_datatype( add[2] )

			end if
			
		elsif sequence_inside_expr = 2 or sequence_inside_expr = 0 then

			-- it's an expression
			sequence_inside_expr = 1

			ix = ixs
			parens = 0
			while (ix < length(sql) and not find( sql[ix], {EUSQL_FROM, EUSQL_COMMA, EUSQL_VALUES, EUSQL_AS, EUSQL_WHERE})) or
			parens > 0 do
				if equal( sql[ix], EUSQL_LPAR ) then
					parens += 1
				elsif equal( sql[ix], EUSQL_RPAR ) then
					parens -= 1
				end if
				ix += 1
			end while
			if ix != ixs then
				ix -= 1
			end if
			
			parens = 0
			
			if length(add) then

				add = add[1]
				
				if query[QN_TABLE][add[1]][1] > 0 then
					include_field( add[1..2], add[3] )
					expr_types &= get_datatype( add[1], add[2] )
					expr = mathize_name(add[3])
				else
					expr_types &= literal_datatype( add[2] )
					expr_count -= 1
					expr = euslib:pretty_sprint( add[2] )
				end if
				add = ""

			else

				expr = EUSQL_WORDS[sql[ixs]]
			end if
			

			-- ...and it goes from ixs..ix
			ixs += 1
			while ixs <= ix do
				if equal( sql[ixs], EUSQL_ASTERISK ) then
					expr &= 32 & EUSQL_ASTERISK
				elsif sequence(sql[ixs]) then
					ok = parse_sequence(sql)
					if atom(ok) then
						return ok
					end if
					sql = ok
					if find(sql[ixs][1], "\"'") then
						ok = sql[ixs]
						if ok[1] = '\'' then
							ok[1] = '"'
							ok[length(ok)] = '"'
						end if
						expr &= 32 & ok
					else
						-- call mathize_name for fields, but not literals...
						if find(sql[ixs][1], "'\"0123456789.") then
							expr &= 32 & replace_all( sql[ixs], " ", "_" )
						else
							expr &= 32 & mathize_name( sql[ixs] )
						end if
					end if
					
					if length(add) then
						if compare( query[QN_TABLE][add[1]][1], EUSQL_FIELD_VALUE ) then
							query[QN_VALUES][5] &= {{ mathize_name( sql[ixs] ), {query[QN_TABLE_ALIAS][add[1]],add[2]} }}
							expr_types &= get_datatype( add[1], add[2] )
						else
							-- literal
							expr_count -= 1
							expr_types &= literal_datatype( add[2] )

						end if

						
					end if
				else
					expr &= 32 & EUSQL_WORDS[sql[ixs]]
				end if
				ixs += 1
			end while

			expr = Parse( expr )

			tx = find( EUSQL_FIELD_CALC, query[QN_TABLE] )
			
			if query[QN_VALUES][1] = EUSQL_SELECT then
				if ixs < length(sql) and equal(sql[ixs], EUSQL_AS) then
					if sequence( sql[ixs+1]) then
						add_field( tx, expr, sql[ixs+1])
						ixs += 1
					else
						sequence_inside_expr = 0
						extended_error = "Expected name after AS"
						return EUSQL_FAIL
					end if
				else
					add_field( tx, expr, sprintf("EXPR%d",expr_count ))
					
					-- now fix the data type:
					-- This may not be correct, because some functions could return
					-- anything...
					if expr[FUNC] != IF then
						query[QN_DATATYPES][$] = datatype_lcd( expr_types )
					end if		
					
					expr_count += 1
				end if
			elsif sequence_marker then

				add_field( tx, expr, sprintf("EXPR%d",expr_count ))
				expr_count += 1
			else

				include_field( {tx, expr}, sprintf("EXPR%d",expr_count	))
				expr_count += 1
			end if
			sequence_inside_expr = 0

			if sequence_marker then
				query[QN_VALUES][4] &= fx - 1
				sequence_marker = 0
			end if
			ixs = ix
			expr_types = {}
		end if

	end if


	return sql
end function

function parse_union( sequence sql )
	object ok
	sequence field
	
	query[QN_VALUES][1] = EUSQL_UNION
	field = query
	ok = call_func( PARSE_MAIN, { sql[ixs+1..length(sql)], 0 })
			
	if atom(ok) then
		return ok
	end if
			
	query = field
	query[QN_VALUES][2] = ok
			
	ixs = length( sql )
	
	return sql
end function


function parse_drop_table( sequence sql )
	object ok
	sequence tables
	
	if length(sql) < ixs + 1 then
		extended_error = "Missing table identifier for DROP TABLE"
		return EUSQL_ERR_SYNTAX
	end if
	
	if not equal( sql[ixs], EUSQL_TABLE ) then
		extended_error = "Expected TABLE"
		return EUSQL_ERR_SYNTAX
	end if
	
	ixs += 1
	
	if not sequence( sql[ixs] ) then
		extended_error = "Expected a table identifier"
		return EUSQL_ERR_SYNTAX
	end if
	tables = table_list()
	ok = find( sql[ixs], tables[3] )
	if not ok then
		extended_error = "Invalid table identifier"
		return EUSQL_ERR_SYNTAX
	end if
	add_field( ok, {1}, "PK" )
	
	query[QN_VALUES][2] = EUSQL_TABLE
	
	return sql
	
end function

function parse_drop_index( sequence sql )
	sequence name, indexed, table
	integer tx, max_rec, rec
	object ok
	
	
	if not equal( sql[ixs], EUSQL_INDEX ) then
		extended_error = "Expected INDEX"
		return EUSQL_ERR_SYNTAX
	end if
	
	ixs += 1
	
	if not sequence( sql[ixs] ) then
		extended_error = "Invalid index identifier"
		return EUSQL_ERR_SYNTAX
	end if
	name = sql[ixs]
	ok = select_table( "INDEXDEF" )
	if db_find_key( name ) < 0 then
		extended_error = sprintf( "Invalid index: \'%s\'", {name})
		return EUSQL_FAIL
	end if
	
	-- find the table to which the index belongs
	rec = 1
	ok = select_table( "TABLEDEF" )
	max_rec = db_table_size()
	tx = 0
	while rec <= max_rec do
		indexed = db_record_data( rec )
		indexed = indexed[3]
		if find( name, indexed ) then
			table = db_record_key( rec )
			tx = find( table, query[QN_TABLE] )
			exit
		end if
		rec += 1
	end while
	
	if not tx then
		tx = 1
	end if
	
	-- index name goes in QN_INDICES
	query[QN_INDICES][tx] = {name}
	query[QN_VALUES][2] = EUSQL_INDEX
	return sql
end function

function parse_drop( sequence sql )

	if ixs > length(sql) then
		return EUSQL_ERR_SYNTAX
	end if
	
	query[QN_VALUES][1] = EUSQL_DROP
	ixs += 1
	
	if equal(sql[ixs], EUSQL_TABLE ) then
		return parse_drop_table( sql )
	elsif equal(sql[ixs], EUSQL_INDEX ) then
		return parse_drop_index( sql )
	end if
	
	return EUSQL_ERR_SYNTAX
end function

function parse_create_table( sequence sql )
	object ok
	integer tx
	
	if atom(sql[ixs]) then
		extended_error = "Invalid table identifier: " & EUSQL_WORDS[sql[ixs]]
		return EUSQL_ERR_SYNTAX
	end if
	
	query[QN_VALUES][2] = EUSQL_TABLE
	query[QN_TABLE][1] = sql[ixs]
	tx = 1
	
	ixs += 1
	
	if equal( sql[length(sql)], EUSQL_SEMICOLON ) then
		sql = sql[1..length(sql)-1]
	end if
	
	while ixs <= length( sql ) do
		-- First the field
		if equal(sql[ixs], EUSQL_COMMA ) then
			ixs += 1
		end if
		
		if atom(sql[ixs]) then
			extended_error = "Invalid field identifier: " & EUSQL_WORDS[sql[ixs]]
			return EUSQL_ERR_SYNTAX
		end if
		
		query[QN_NAMES][tx] &= { sql[ixs] }
		
		-- now the datatype
		ixs += 1
		if not equal( sql[ixs], EUSQL_AS ) then
			extended_error = "Expected \'AS <DATATYPE>"
			return EUSQL_ERR_SYNTAX
		end if
		
		ixs += 1
		
		if not is_datatype( sql[ixs] ) then
			extended_error = "Invalid datatype"
			return EUSQL_ERR_SYNTAX
		end if
		
		query[QN_ORDER][tx] &= sql[ixs]
		
		query[QN_INDICES][tx] &= 0
		
		ixs += 1
		
	end while
	
	return sql
end function

-- CREATE [UNIQUE] INDEX <INDEX-NAME> ON <TABLE-NAME> (<COLUMN-NAME>)
function parse_create_index( sequence sql )
	object ok
	integer unique, fx, tx
	sequence name, table, field, findex, flat

	if sql[ixs-2] = EUSQL_UNIQUE then
		unique = 1
		ixs += 1
	else
		unique = 0
	end if

	
	if atom(sql[ixs]) then
		extended_error = "Missing index name for CREATE INDEX"
		return EUSQL_ERR_SYNTAX
	end if
	name = sql[ixs]
	
	ixs += 1
	if ixs > length(sql) or compare( sql[ixs], EUSQL_ON ) then
		extended_error = "Missing 'ON' in CREATE INDEX"
		return EUSQL_ERR_SYNTAX
	end if
	
	ixs += 1
	if ixs > length(sql) or atom( sql[ixs] ) then
		extended_error = "Missing table name in CREATE INDEX"
		return EUSQL_ERR_SYNTAX
	end if
	table = sql[ixs]
	-- verify table
	if atom( select_table( table ) ) then
		extended_error = sprintf( "Table \'%s\' does not exist", {table})
		return EUSQL_TABLE
	end if
	tx = find( table, query[QN_TABLE] )
	
	-- check for (
	ixs += 1
	if ixs > length(sql) or compare( sql[ixs], EUSQL_LPAR ) then
		extended_error =  "Missing \'(\' in CREATE INDEX"
		return EUSQL_ERR_SYNTAX
	end if
	
	-- check field	
	ixs += 1
	if ixs > length(sql) or atom( sql[ixs] ) then
		extended_error = "Missing field name in CREATE INDEX"
		return EUSQL_ERR_SYNTAX
	end if
	field = sql[ixs]
	ok = validate_field2( "", table, field)
	if atom(ok) then
		return ok
	end if
	findex = ok

	-- check for ')'
	ixs += 1
	if ixs > length(sql) or compare( sql[ixs], EUSQL_RPAR ) then
		extended_error = "Missing \')\' in CREATE INDEX"
		return EUSQL_ERR_SYNTAX
	end if
	
	-- now save the info in the query
	-- table goes in QN_TABLE
	-- Index name goes in QN_INDICES
	-- Field name goes in QN_NAMES
	query[QN_VALUES][2] = EUSQL_INDEX
	query[QN_VALUES][3] = unique
	query[QN_INDICES][tx] = { name }
	query[QN_NAMES][tx] = { field }
	
	return sql
end function

function parse_create_database( sequence sql )
	object db
	db = sql[ixs]
	if atom( db ) then
		extended_error = "Invalid database name"
		return EUSQL_FAIL
	end if
	ixs += 1
	query[QN_VALUES][2] = EUSQL_DATABASE
	query[QN_TABLE][1] = db
	query[QN_INDICES][1] = {db}
	return sql
end function

function parse_create( sequence sql )
	object ok, token
	integer tx
	
--	if length(sql) < ixs + 3 then
--		extended_error = "Incomplete CREATE statement"
--		return EUSQL_ERR_SYNTAX
--	end if
	
	ixs += 1
	query[QN_VALUES][1] = EUSQL_CREATE
	token = sql[ixs]
	ixs += 1
	if equal( token, EUSQL_TABLE ) then

		return parse_create_table( sql )
		
	elsif find( token, {EUSQL_INDEX, EUSQL_UNIQUE} ) then

		return parse_create_index( sql )
		
	elsif equal( token, EUSQL_DATABASE ) then
		
		return parse_create_database( sql )
	else
	
		extended_error = "Expected TABLE or INDEX"
		return EUSQL_ERR_SYNTAX
	end if
	
end function

function init_from_tables(sequence sql)
	integer fx, gx, tx
	-- scan for tables...

	from_tables = {}
	alias_tables = {}
	if find( query[QN_VALUES][1], {EUSQL_SELECT, EUSQL_DELETE}) then
		fx = find( EUSQL_FROM, sql )
		if not fx then
			extended_error = "Missing FROM clause"
			return EUSQL_FAIL
		end if
		gx = fx + 1
		while gx <= length(sql) and not find( sql[gx], {EUSQL_WHERE, EUSQL_GROUP, EUSQL_ORDER}) do
			if sequence(sql[gx]) and not find('.', sql[gx]) then

				from_tables = append( from_tables, sql[gx] )

				-- check for an alias...
				if gx + 1 < length(sql) and equal( sql[gx+1], EUSQL_AS ) then
					tx = find( sql[gx], tables[3] )

					gx += 2
				else
					tx = 0
				end if

				alias_tables = append( alias_tables, sql[gx] )
				if tx then
					-- need to patch the tables sequence to be able to use aliased 
					-- tables properly
					for i = 1 to length(tables) do
						tables[i] = append( tables[i], tables[i][tx] )
					end for
					
				end if
			end if
			gx += 1
		end while
	elsif query[QN_VALUES][1] = EUSQL_UPDATE then
		if length(sql) < 2 then
			extended_error = "Incomplete statement"
			return EUSQL_FAIL
		elsif atom(sql[2]) then
			extended_error = "Missing table to update"
			return EUSQL_FAIL
		end if
		from_tables = {sql[2]}
		alias_tables = from_tables
	end if
	return sql
end function

function parse_select( sequence sql )
	object ok
	sequence field
	integer fx, gx
	
	if query[QN_VALUES][1] then
		-- select clause is part of an update/insert
		field = query
				
		ok = call_func(PARSE_MAIN, { sql[ixs..length(sql)], 0 })
			
		if atom(ok) then
			return ok
		end if
			
		query = field
		query[QN_VALUES][2] = { EUSQL_SELECT, ok}
			
		ixs = length( sql )
				
	else
		-- just a regular select statement...
		query[QN_VALUES] = {EUSQL_SELECT, {}, {}, {}, {}}
		return init_from_tables(sql)
	end if
	
	return sql
end function 

function parse_delete( sequence sql )
	query[QN_VALUES] = { EUSQL_DELETE, {}, {}, {} }
	-- second element will denote the tables
	
	return init_from_tables(sql)
	
end function


function parse_insert( sequence sql )
	object ok
	sequence field
	integer tx, jx

	query[QN_VALUES] = { EUSQL_INSERT, {0, {}}, {}, {}, {} }
	--  1: Query Type
	--  2: Values / SELECT statement
	--  3: Blank field
	--  4: Table to be inserted
	--  5: Ordered field indices
	
	if length( sql ) < ixs + 4 then
		extended_error = "INSERT statement improperly formed"
		return EUSQL_ERR_SYNTAX
	end if

			
	if not equal( sql[ixs+1], EUSQL_INTO ) then
		extended_error = "Expected INSERT INTO"
		return EUSQL_ERR_SYNTAX
	end if
			
	ixs += 2
			
			
	-- figure which table is the target for the INSERT
	if not sequence(sql[ixs]) then
		extended_error = "Expected table name after INSERT INTO"
		return EUSQL_ERR_SYNTAX
	end if

	from_tables = {sql[ixs]}
	alias_tables = from_tables
	
	ok = parse_field( sql )
	
	if atom(ok) then
		extended_error = "Table name \'" & sql[ixs] & "\' not found"
		return EUSQL_ERR_TABLE
	end if
			

	tx = ok[1]
	query[QN_VALUES][4] = ok[3]
	
	-- add the fields    
	ixs += 1
			
	jx = 1
	while ixs <= length( sql ) and not 
	find( sql[ixs], {EUSQL_VALUES, EUSQL_SELECT}) do
		
		if sequence( sql[ixs] ) then
			ok = parse_field( sql )
			if atom( ok ) then
				return ok
			end if
					
			if ok[1] != tx then
				extended_error = sprintf( "Field \'%s\' not found in table \'%s\'",
					{ sql[ixs], query[QN_TABLE_ALIAS][tx]})
				return EUSQL_ERR_FIELD
			end if
					
			add_field( tx, ok[2], sql[ixs] )
			jx = 0
		end if
		ixs += 1
	end while
	
	-- we're just doing the whole thing...
	if jx then
		add_field( tx, {0}, "*" )
	end if
	
	query[QN_VALUES][3] = blank_field( tables[2][tx] )
	query[QN_VALUES][4] = query[QN_TABLE_ALIAS][tx]
			
	-- store the field indices in order
	field = { }
	for i = 1 to length( query[QN_ORDER][tx] ) do
		if query[QN_ORDER][tx][i] > 0 then
			field &= {{ query[QN_ORDER][tx][i],
				query[QN_INDICES][tx][i] }}
		end if
	end for
	
	
	field = sort(field)
	for i = 1 to length( field ) do
		field[i] = field[i][2]
	end for
			
	query[QN_VALUES][5] = field
			
	ixs -= 1
	return sql
end function

function parse_update( sequence sql )
	integer tx
	sequence name
	object ok
	if length(sql) < ixs + 2 or compare(sql[ixs+2], EUSQL_SET) or atom(sql[ixs+1]) then
		extended_error = "Cannot find table to update"
		return EUSQL_FAIL
	end if

	ok = alias_to_tx( sql[ixs+1] )
	if atom(ok) then
		return ok
	end if
	tx = ok[1]

	-- include the key up front...
	name = tables[2][tx][1][1]

	query[QN_VALUES] = { EUSQL_UPDATE, {},{},{}, {}, {} }	
	add_field( tx, {1}, "Key: " & query[QN_TABLE_ALIAS][tx]  )

	--include_field( {tx, {1}}, name )

	ixs += 2

	-- the fields and their updated values are parsed in
	-- parse_sequence()

	
	return init_from_tables(sql)
end function

function parse_values( sequence sql )
	query[QN_VALUES][2][1] = EUSQL_VALUES
	return sql
end function

-- should handle multiple joins
function parse_join( sequence sql )
	object ok, curtok
	integer tx, as_offset

	-- stored in query[QN_JOIN]
	--  1: type (inner, left, right)
	--  2: first field (query order)
	--  3: second field (query order)
	as_offset = 0

	if (ixs >= length(sql)-5) or (compare(sql[ixs+1], EUSQL_JOIN)) then

		-- could be RIGHT/LEFT text operation
		if ixs < length(sql) then
			if equal(sql[ixs+1], EUSQL_LPAR) then
				return parse_sequence( sql )
			end if
		end if

		return EUSQL_ERR_JOIN
	elsif atom(sql[ixs+2]) then
		extended_error = "Expected table name after join"
		return EUSQL_ERR_JOIN
	elsif equal(sql[ixs+3], EUSQL_AS ) and sequence( sql[ixs+4] ) and equal( sql[ixs+5], EUSQL_ON )  then
		-- this one is ok
		as_offset = 2
	elsif compare(sql[ixs+3], EUSQL_ON) then
		extended_error = "Expected 'ON' after table name"
		return EUSQL_ERR_JOIN
	elsif atom(sql[ixs+4]) or atom(sql[ixs+6]) or compare(sql[ixs+5],EUSQL_EQUAL) then
		extended_error = "Expected \"<field1> = <field2>\""
		return EUSQL_ERR_JOIN
	end if
	
	curtok = sql[ixs]
	--FROM Committee INNER JOIN kavb ON (Committee.Suffix = kavb.Suffix)
		-- first table will be at ixs-1
		-- second table will be at ixs+2
		-- ixs+3 = EUSQL_ON
		-- ixs+4 = table1.field1
		-- ixs+5 = EUSQL_EQUAL
		-- ixs+6 = table2.field2
		-- if ixs+7 = EUSQL_AND, then there are more.  we'll erase
		-- what we have and move ixs back one, so it will increment
		-- and find the next relationship

		-- ixs+3 = EUSQL_AS
		-- ixs+4 = alias
		-- ixs+5 = EUSQL_ON
		-- ixs+6 = table1.field1
		-- ixs+7 = EUSQL_EQUAL
		-- ixs+8 = table2.field2		

	ok = repeat(0,3)
	ok[1] = curtok

	-- move token pointer to the first field and parse
	ixs += 4  + as_offset
	ixs += equal( sql[ixs], EUSQL_LPAR )

	ok[2] = parse_field( sql )
			
	if atom( ok[2] ) then
		extended_error = "Error in join: " & sql[ixs]
		return EUSQL_ERR_FIELD
	end if
	
	-- make sure that the field is in the query
	tx = ok[2][1]
	include_field( ok[2], sql[ixs] ) 
	ok[2] = ok[2][2]
	ok[2] = abs_val( query[QN_ORDER][tx][find( ok[2], query[QN_INDICES][tx] )] )
	
	-- now handle second field
	ixs += 2 
	ok[3] = parse_field( sql)
	if atom( ok[3] ) then

		extended_error = "Error in join: " & sql[ixs]
		return EUSQL_ERR_FIELD
	end if
			
	tx = ok[3][1]
	include_field( ok[3], sql[ixs] )
	ok[3] = ok[3][2]
			
	ok[3] = abs_val( query[QN_ORDER][tx][find( ok[3], query[QN_INDICES][tx] )] )

	-- 1/16/03: Outer joins need to come first or selection will be wrong
	if ok[1] = EUSQL_INNER then
		query[QN_JOINS] &= { ok }
	else
		query[QN_JOINS] = prepend( query[QN_JOINS], ok )
	end if
	
	if ixs < length(sql) and equal(sql[ixs+1], EUSQL_RPAR) then
		ixs += 1
	end if
	-- this looks for an and clause and removes the previous table info
	-- and backs up to FROM
	if length(sql) > ixs and equal( sql[ixs+1], EUSQL_AND ) then
		ixs -= 7
		for i = 1 to 6 do
			sql = remove_one( sql, ixs )
		end for
	elsif length(sql) > ixs + 1 and equal( sql[ixs+2], EUSQL_JOIN) then

		-- multiple joins...
		ixs += 1
		ok = parse_join( sql )
		if atom(ok) then
			return ok
		end if
		sql = ok
		
	end if

	return sql
end function

function parse_distinct( sequence sql )
	query[QN_DISTINCT] = 1
	return sql
end function

function parse_group( sequence sql )
	object ok
	integer ix, tx
	
	-- need to parse the field and add the group by clause
	-- this is at the end of the SQL statement
	ixs += 2

	ok = parse_field( sql )
	if atom(ok) then
		extended_error = "Error in GROUP BY: " & sql[ixs]
		return EUSQL_ERR_FIELD
	end if

	tx = ok[1]
	ix = find( ok[2], query[QN_INDICES][tx] )
				
	if not ix then
		extended_error = "Error in GROUP BY: " & sql[ixs]
		return EUSQL_ERR_FIELD
	end if
				
	ix = query[QN_ORDER][tx][ix]
	query[QN_AGGREGATES] &= { {EUSQL_GROUP, ix} }

	-- 1/16/03: need to check for additional fields
	if ixs + 1 < length(sql) and sql[ixs+1] = EUSQL_COMMA then
		return parse_group( sql )
	end if

	return sql
end function

function parse_order( sequence sql )
	object ok, lhs
	sequence the_order
	integer tx, actual_order, ix

	-- get field name          
	ixs += 2

 
	for i = 1 to length(query[QN_NAMES]) do
		ok = query[QN_NAMES][i]
		ix = find( sql[ixs], query[QN_NAMES][i])
		if ix then
			tx = i
			exit
		end if
	end for

			
	if not ix then
		extended_error = "Error in Order: " & sql[ixs]
		return EUSQL_ERR_FIELD
	end if

	ok = query[QN_ORDER][tx][ix]
	if ok < 0 then
		extended_error = "Sorted fields must be included in query"
		return EUSQL_ERR_FIELD
	end if

	actual_order = ok
	for table = 1 to length(query[QN_ORDER]) do
		the_order = query[QN_ORDER][table]
		for field = 1 to length(the_order) do
			if the_order[field] < 0 and -the_order[field] < ok then
				actual_order -= 1
			end if
		end for
	end for
	
	query[QN_ORDERING][1] &= actual_order
			
	ixs += 1
	-- decide if we're descending or ascending
	if length(sql) >= ixs and equal( sql[ixs], EUSQL_DESC) then
		query[QN_ORDERING][2] &= -1
		tx = 2
	else
		query[QN_ORDERING][2] &= 1
		tx = 1
	end if
			
	ixs -= 3
	-- set up for additional order by...
	for i = 1 to tx do
		sql = remove_one( sql, ixs + 2)
	end for
					  
	if length(sql) > ixs+2 and equal( sql[ixs+2], EUSQL_COMMA ) then
		sql = remove_one( sql, ixs+2)
		ixs -= 1
	end if

	return sql
end function 

function parse_agg( sequence sql )
	integer agg, tx
	object ok
	agg = sql[ixs]
	ixs += 1

	if match( {EUSQL_LPAR,EUSQL_ASTERISK,EUSQL_RPAR}, sql[ixs..length(sql)]) = 1 then
		if not length(from_tables) then
			return EUSQL_ERR_SYNTAX
		elsif length(from_tables) > 1 then
			extended_error = "Ambiguous use of '*'"
			return EUSQL_ERR_SYNTAX
		end if
		tx = find( from_tables[1], tables[3] )
		add_field( tx, {1}, sprint(fx))
		ixs += 3
	else
		ok = parse_sequence( sql )
		if atom(ok) then
			return ok
		end if
		sql = ok
	end if
	

	query[QN_AGGREGATES] &= { {agg, fx-1 } }

--	if length( sql ) < ixs + 3 or not (equal(sql[ixs+1], EUSQL_LPAR ) 
--	and equal(sql[ixs+3], EUSQL_RPAR)) then
--	-- This clause is for COUNT, SUM, to make sure that the syntax
--	-- is correct.
--		extended_error = "Aggregate function incorrect."
--		return EUSQL_ERR_SYNTAX
--				
--	else
--		aggregate_flag = - sql[ixs]
--		ixs += 1
--	end if
	
	return sql
end function

function parse_now( sequence sql )
	integer tx
	tx = find( EUSQL_FIELD_CALC, query[QN_TABLE] )
	add_field( tx, {NOW,{},{}}, sprintf("EXPR%d",expr_count ))	
	return sql
end function

procedure set_parse( integer word, sequence name )
	parse_routines[word] = routine_id( "parse_" & name )
end procedure


set_parse( EUSQL_DROP, "drop" )
set_parse( EUSQL_CREATE, "create" )
set_parse( EUSQL_SELECT, "select" )
set_parse( EUSQL_INSERT, "insert" )
set_parse( EUSQL_UPDATE, "update" )
set_parse( EUSQL_DELETE, "delete" )
set_parse( EUSQL_GROUP, "group" )
set_parse( EUSQL_ORDER, "order" )
set_parse( EUSQL_WHERE, "where" )
set_parse( EUSQL_SUM, "agg" )
set_parse( EUSQL_COUNT, "agg" )
set_parse( EUSQL_AVG, "agg" )
set_parse( EUSQL_MAX, "agg" )
set_parse( EUSQL_MIN, "agg" )

set_parse( EUSQL_DISTINCT, "distinct" )
set_parse( EUSQL_VALUES, "values" )
set_parse( EUSQL_INNER, "join" )
set_parse( EUSQL_LEFT, "join" )
set_parse( EUSQL_RIGHT, "join" )
set_parse( EUSQL_UNION, "union" )
set_parse( EUSQL_NOW, "now" )

function abs_order_to_visible( integer fx )
	integer vis_order
	sequence qnorder, torder

	vis_order = fx
	qnorder = query[QN_ORDER]
	for i = 1 to length(query[QN_ORDER]) do
		torder = qnorder[i]
		for j = 1 to length(torder) do
			if torder[j] < 0 and -torder[j] < fx then
				vis_order -= 1
			end if
		end for
	end for
	return vis_order
end function

function parse_main( sequence sql, integer preprocess )
	object ok, curtok, lhs
	integer token, ix, jx, tx, t_val, t_param,
		t_calc, vis_order
	sequence field, the_order, subquery
	
	aggregate_flag = 0
	query = {}

	if preprocess then
		
		expr_count = 1
		sql = preprocess_sql(sql)
	
		if length(current_db) then
			-- make sure TABLEDEF exists
			ok = select_table( "TABLEDEF" )
			if atom( ok ) then
				return ok
			end if
			
			
			ok = table_list() 
			if atom(ok) then
				return ok
			end if
			
			tables = ok			
		else
			-- no db open, but we might have a create database call
			tables = {{""},{""}}
		end if
		
	end if

		-- v.03 Query is now defined using constants, to enable easier
		--      changes in the future to structure of compiled queries
	query = Q_STRUCT
	query[QN_TABLE] = tables[1] 
	query[QN_TABLE_ALIAS] = repeat( {}, length(tables[1]))
	lhs = repeat( {}, length( tables[1] ) )
	query[QN_INDICES] = lhs
	query[QN_NAMES] = lhs
	query[QN_ORDER] = lhs
	query[QN_WHERE] = { {}, lhs}
	query[QN_ORDERING] = repeat( {}, 2 )

	-- save indices for values, params, calcs
	t_val = length(query[QN_TABLE]) - 2
	t_param = t_val + 1
	t_calc = t_param + 1

	-- query structure:          
	--  QN_TABLE      : table names
	--  QN_INDICES    : indices of fields
	--  QN_NAMES      : field names
	--  QN_ORDER      : field order within returned records
	--  QN_WHERE      : conditions
	--      1: parsed matheval expression
	--      2: fields: {order val, name}
	--      3: necessary: {{ expr, { fields (order val, name) } }}
	--  QN_JOINS      : joins
	--      1: type (EUSQL_INNER, EUSQL_LEFT, EUSQL_RIGHT)
	--      2: first field (query order)
	--      3: second field (query order)
	--  QN_ORDERING   : ordering (ascending/descending)
	--  QN_DISTINCT   : 0 = multiple values allowed, 1 = distinct
	--  QN_AGGREGATES : aggregate functions (if any)
	--  QN_VALUES     : For DELETE, INSERT, UPDATE queries
	-- 		1: Query type (EUSQL_SELECT, EUSQL_DELETE, etc...)
	--		2: Values for SELECT queries
	-- 		3: EUSQL_UPDATE: field number (fx) of field to be updated
	-- 		4: EUSQL_UPDATE: field number (fx) of update value
	--      5: Fields that need to be have Vars set for calculations
	--  QN_DATATYPES
	--  QN_FIELD_INDEX: identify indexed fields and the names of the indexes
	
	fx = 1
	ixs = 1
	while ixs <= length(sql) do

		curtok = sql[ixs]

		if sequence( curtok ) or
		(find(curtok, EUSQL_FUNCTIONS) and (ixs > 1 and compare(sql[ixs-1], EUSQL_VALUES))) then 
			ok = parse_sequence( sql )
			if atom(ok) then
				return ok
			end if
			sql = ok
		else

			ix = parse_routines[curtok]
			if ix then
				ok = call_func( ix, { sql } )
				if atom(ok) then
					return ok
				end if
				sql = ok
			end if
		end if
		
		ixs += 1  
	end while

	-- only keep tables we need
	ixs = 1
	while ixs <= length( query[QN_TABLE] ) do
		if not length(query[QN_INDICES][ixs]) then

			query[QN_TABLE] = remove_one( query[QN_TABLE], ixs )
			query[QN_INDICES] = remove_one( query[QN_INDICES], ixs )
			query[QN_NAMES] = remove_one( query[QN_NAMES], ixs )
			query[QN_ORDER] = remove_one( query[QN_ORDER], ixs )
			query[QN_WHERE][2] = remove_one( query[QN_WHERE][2], ixs )
			query[QN_TABLE_ALIAS] = remove_one( query[QN_TABLE_ALIAS], ixs )
		else
			
			-- change to QN_ORDER value from QN_INDICES value
			ok = query[QN_WHERE][2]
			if length( ok ) >= ixs then
				ok = ok[ixs]
				for i = 1 to length( ok ) do
					ok[i][1] = query[QN_ORDER][ixs][
							  find(ok[i][1], query[QN_INDICES][ixs])]
				end for
				query[QN_WHERE][2][ixs] = ok
			end if
			ixs += 1
		end if
	end while

	if length( query[QN_AGGREGATES] ) then
		-- need to make sure that all visible fields are aggregated
		fx = 0
		ok = {}
		for i = 1 to length(query[QN_NAMES]) do
			ok &= query[QN_ORDER][i]
		end for
		
		for i = 1 to length( ok ) do
			if ok[i] > 0 then
				fx += 1
			end if
		end for
		if fx != length( query[QN_AGGREGATES] ) then

			extended_error = sprintf("Aggregate calculation--missing GROUP BY: %d fields, %d aggregate functions.",
				{fx, length(query[QN_AGGREGATES])})
			return EUSQL_ERR_SYNTAX
		end if
		
		-- now put them in order...
		
		ok = { {}, {} }
		field = query[QN_AGGREGATES]

		for i = 1 to length( field ) do
			field[i][2] = abs_order_to_visible(field[i][2])
			if field[i][1] = EUSQL_GROUP then
				ok[1] = append( ok[1], field[i] )
			else
				ok[2] = append( ok[2], field[i] )
			end if
		end for   
		query[QN_AGGREGATES] = ok[1] & ok[2]
	end if
	
	-- make sure that only the keys are returned
	-- and that the tables to be deleted are noted
	-- in QN_VALUES
	if query[QN_VALUES][1] = EUSQL_DELETE then

		ok = {}
		ix = 0
		for i = 1 to length( query[QN_ORDER] ) do
			for j = 1 to length( query[QN_ORDER][i] ) do
				
				if query[QN_ORDER][i][j] > 0 then
					if not find( i, ok ) then
						ok &= i
					end if
					
					if not equal( query[QN_INDICES][i][j], {1} ) then
						-- also need to fix QN_WHERE:
						for k = 1 to length( query[QN_WHERE][2][i] ) do
							if query[QN_WHERE][2][i][k][1] = query[QN_ORDER][i][j] then
								query[QN_WHERE][2][i][k][1] *= -1
							end if
						end for
						query[QN_ORDER][i][j] *= -1

					end if
					
				end if
			end for
		end for
		
		-- cover case where no fields were specified
		-- ie, "DELETE FROM TABLENAME"
		if not length( ok ) and length( query[QN_TABLE] ) = 1 then
				
				query[QN_INDICES][1] &= { {1} }
				query[QN_ORDER][1] &= { fx }
				
				field = ok
				-- add name of field
				ok = select_table( "TABLEDEF" )
				if atom(ok) then
					return ok
				end if
				
				ok = field
				
				ixs = db_find_key( query[QN_TABLE][1] )
				field = db_record_data( ixs )
				query[QN_NAMES][1] &= { field[1][1] }
				
				fx += 1
				
		end if

		-- only the keys will be returned
		for i = 1 to length( ok ) do

			if not find( {1}, query[QN_INDICES][i] ) then
				
				query[QN_INDICES][ok[i]] &= { {1} }
				query[QN_ORDER][ok[i]] &= { fx }
				
				field = ok
				-- add name of field
				ok = select_table( "TABLEDEF" )
				if atom(ok) then
					return ok
				end if
				
				ok = field
				
				ixs = db_find_key( query[QN_TABLE][ok[i]] )
				field = db_record_data( ixs )
				query[QN_NAMES][ok[i]] &= { field[1][1] }
				
				fx += 1
			end if
		end for
		
		query[QN_VALUES][2] = ok

	end if

--	if find( EUSQL_FIELD_CALC, query[QN_TABLE] ) then
--
--	end if
	
	-- clean up an insert query -- make sure keys are included
	-- and that we have the right number of values to insert
	if query[QN_VALUES][1] = EUSQL_INSERT then
		if query[QN_VALUES][2][1] = EUSQL_SELECT then
			subquery = query[QN_VALUES][2][2]
			ix = 0
			for i = 1 to length(subquery[QN_ORDER]) do
				for j = 1 to length(subquery[QN_ORDER][i]) do
					if subquery[QN_ORDER][i][j] > 0 then
						ix += 1
					end if
				end for
			end for
			if ix != length(query[QN_VALUES][5]) then
				extended_error = sprintf( "trying to insert %d values into %d fields",
					{ix, length(query[QN_VALUES][5])})
				return EUSQL_ERR_FIELD
			end if
		else
			-- real values...
			if length(query[QN_VALUES][2][2]) != length(query[QN_VALUES][5]) then
				extended_error = sprintf( "trying to insert %d values into %d fields",
					{length(query[QN_VALUES][2][2]), length(query[QN_VALUES][5])})
				return EUSQL_ERR_FIELD
			end if
		end if
	end if
   
	if query[QN_VALUES][1] = EUSQL_UPDATE then

		the_order = {{},{}}
		ix = 1
		for i = 1 to length(query[1]) do
			the_order[1] &= query[QN_ORDER][i]
		end for
		the_order[1] = sort(the_order[1])
		the_order[2] = the_order[1]

		-- the_order[2] holds the visible order
		for i = 1 to length(the_order[1]) do
			if the_order[1][i] > 0 then
				the_order[2][i] = ix
				ix += 1
			else
				the_order[2][i] = 0
			end if
		end for

		-- convert order to indices and put into tables
		field = repeat( repeat( {}, length( query[QN_TABLE] ) ), 2)


		-- loop through all fields saved in QN_VALUES
		-- i is an index into QN_VALUES
		for i = 1 to length( query[QN_VALUES][3] ) do
		
			-- search for the field in each table
			-- j is a table index
			for j = 1 to length( query[QN_ORDER] ) do

				ix = find(query[QN_VALUES][3][i], query[QN_ORDER][j] )
				
				if ix then
					ok = find( query[QN_ORDER][j][ix], the_order[1] )
					if the_order[2][ok] then
						
						field[1][j] = append( field[1][j],  query[QN_INDICES][j][ix] )
						
						-- this should really be the *visible* order, rather than the invisible...
						vis_order = query[QN_VALUES][4][i]
						for tablex = 1 to length(query[QN_ORDER]) do
							for fieldx = 1 to length(query[QN_ORDER][tablex]) do
								if query[QN_ORDER][tablex][fieldx] < 0 and
								  -query[QN_ORDER][tablex][fieldx] < query[QN_VALUES][4][i] then
								  
									vis_order -= 1
								
								end if
							end for
						end for
						field[2][j] &= vis_order
						exit
					end if
				end if
			end for
		end for

		query[QN_VALUES][3] = field[1]
		query[QN_VALUES][4] = field[2]
  
	end if
		
	
	return query
end function
PARSE_MAIN = routine_id( "parse_main" )

--/topic Queries
--/func parse_sql( sequence sql )
--/info
--sql must be a string.  This function will return a 'compiled' query, which can be passed 
--to run_query.  If there is an error, parse_sql will return an atom.  If a query will be run 
--multiple times (perhaps using different parameters each time), it is faster to parse the 
--statement once, and use run_query() than to use run_sql() each time.

global function parse_sql( sequence sql )
	extended_error = {}
	return parse_main( sql, 1)
end function

function agg_sum(sequence record, sequence calc, integer field)
	return record[field] + calc[field]
end function
AGG_FUNC[EUSQL_SUM] = routine_id("agg_sum")

function agg_count(sequence record, sequence calc, integer field)
	return calc[field] + 1
end function
AGG_FUNC[EUSQL_COUNT] = routine_id("agg_count")

function agg_avg(sequence record, sequence calc, integer field)
	return calc[field] & record[field]
end function
AGG_FUNC[EUSQL_AVG] = routine_id("agg_avg")

function agg_max( sequence record, sequence calc, integer field )
	if compare(record[field], calc[field]) = 1 then
		return record[field]
	else
		return calc[field]
	end if
end function
AGG_FUNC[EUSQL_MAX] = routine_id("agg_max")

function agg_min( sequence record, sequence calc, integer field )
	if record[field] < calc[field] then
		return record[field]
	else
		return calc[field]
	end if
end function
AGG_FUNC[EUSQL_MIN] = routine_id("agg_min")

sequence group_funcs
group_funcs = repeat(0, length(EUSQL_WORDS) )
				
function group_avg( sequence a )
	-- calculate the average of elements of s
	atom s
	
	s = 0
	for i = 2 to length( a ) do
		s += a[i]
	end for
	s /= length( a ) - 1
	
	return s
end function
group_funcs[EUSQL_AVG] = routine_id( "group_avg" )


function group_calc( sequence record, sequence funcs )
	-- do all group calcs that need to be done.
	integer field
	
	for i = 1 to length( funcs ) do
		field = funcs[i][2]
		record[field] = call_func( group_funcs[funcs[i][1]], { record[field] } )
	end for
	
	return record
end function

function order( sequence items, sequence order )
	sequence s
	integer l
	
	l = length( order )
	s = repeat( {}, l )
	
	for i = 1 to l do
		s[order[i]] = items[i]
	end for

	
	return s
end function

function order_visible( sequence items, sequence neg_order )
	sequence abs_order
	
--    abs_order = abs_val( neg_order )
--    items = order( items, abs_order )
	
	neg_order = sort(neg_order)
	for i = 1 to length( neg_order ) do
		if neg_order[i] < 0 then
			items = remove_one( items, -neg_order[i] )
		end if
	end for
	return items
	
end function

function condition( object b, sequence wheres )
	object a
	integer rel, x
	
	rel = wheres[1]
	a = wheres[2]
	
	if sequence(a) then
--        a = upper(a)
	end if
	
	if sequence(b) then
--        b = upper(b)
	end if
	
	if rel = EUSQL_EQUAL then 
		return equal( a, b )
	elsif rel = EUSQL_LIKE then
		if atom(b) then
			return 0
		end if
		
		return	is_match( a, b )
		
	elsif not ( atom(a) and atom(b) ) then
		return 0
	elsif rel = EUSQL_GREATER then
		return b > a
	elsif rel = EUSQL_LESS then
		return b < a
	elsif rel = EUSQL_GTOE then
		return b >= a
	elsif rel = EUSQL_LTOE then
		return b <= a
	end if
	
	return 0
end function


function get_field( object record, object index )
	
	-- in case there is a value that's a number
	if atom(index) then
		return index
	end if
	
	for i = 1 to length( index ) do
		if index[i] <= length(record) then
			record = record[index[i]]
		else
			record = {}
		end if
		
	end for
	return record
end function

-- used to determine what element a field is when only looking
-- at the fields from it's table--the absolute order is not correct
-- if some other fields from other tables come before it in the order
function abs_to_table_order( integer abs_order, sequence table_order )
	return find( abs_order, sort(table_order) )
end function


function get_fields( sequence index, sequence conditions, sequence c_fields,
		integer distinct, sequence order )
	sequence fields, record, field, wheres, pos_order, cx
	atom max
	integer lx, wx
	object ok
	
	-- only handle literal conditions here
	pos_order = sort( abs_val( order ) )
	cx = {}
	
	lx = length( index )
	max = db_table_size()
	wheres = { }
	fields = {}
	
	-- clear all matheval var's
	--ClearVar("")
	for i = 1 to max do
		ok = 1
		record = {db_record_key( i )} & db_record_data( i )
		field = {}	
		
		-- add the columns to the record
		for j = 1 to lx do
			--if equal(index[j], {0}) then
			--    field &= { record }
			--else            
				field &= {get_field( record, index[j] )}
			
			--end if
		end for
		
		-- check conditions
		-- set the vars with the data
		ClearVar( "" )
		if length( c_fields ) then

			for j = 1 to length( c_fields ) do
				wx = c_fields[j][1]
				wx = find(wx,order)
				ok = field[wx]

				SetVar( c_fields[j][2], ok )
			end for

			ok = Evaluate( conditions )
		
			if equal( ok, ZERO ) then
				ok = 0
			else
				if sequence(ok) and not length(ok) then
					ok = {1}
				end if
			end if
		
		else
			ok = ONE
		end if
			
		if not equal(ok,0) and not (distinct and find( field, fields )) then
			field = prepend( field, ok )--wheres )
			fields = append( fields, field )
		end if
	end for
	
	
	return fields
end function

function IsNull( object o )
	return equal( o, EUSQL_NULL )
end function

-- make sure record conforms to the joins
function join_ok( sequence fields, sequence joins, sequence order, 
		sequence conditions, sequence c_fields )
	object right, left, rhs, ok
	integer lhs, ix

	for i = 1 to length( joins ) do
		right = fields[joins[i][3]]
		left = fields[joins[i][2]]
		if joins[i][1] = EUSQL_INNER then  
			if not equal( left, right) then
				return 0
			end if
			
		elsif joins[i][1] = EUSQL_RIGHT then
			if ( not equal(left, right) and not IsNull( left ) ) then
				return 0
			end if
		elsif joins[i][1] = EUSQL_LEFT then
			if ( not equal(left, right) and not IsNull( right ) ) then
				return 0
			end if
		end if
	end for 

	-- need to check conditions?
	if length( conditions ) and not equal( conditions, ONE ) then
		--ClearVar("")
		for j = 1 to length( c_fields ) do
			ix = abs_val( c_fields[j][1] )
			ok = fields[ix]
			
		 
			SetVar( c_fields[j][2], ok )
		 
		end for
		ok = Evaluate( conditions )
			
		if equal( ok, ZERO ) then
			return 0
		end if
	end if
	
	return 1
end function


-- used to decide which table a field belongs to from within
-- a join.  'fields' gives the values of the place in the final
-- record for a field, and orders is the QN_ORDER element of
-- the compiled sql.
function order_to_table( sequence fields, sequence orders )
	sequence tables
	tables = repeat( 0, 2 )
	
	for i = 1 to 2 do
		for j = 1 to length( orders ) do
			if find( fields[i], orders[j] ) then
				tables[i] = j
				exit
			end if
		end for
	end for
	
	return tables
end function

function get_groups( sequence fields, sequence groups )
	sequence values
	values = {}

	if not length(groups) then
		
	end if

	for i = 1 to length( groups ) do
		values &= { fields[groups[i]] }
	end for
	
	return values
end function


function get_keys_as_index( integer tx )
	object ok
	atom recs
	sequence keys, list

	keys = table_records[tx][1]
	for i = 1 to length( keys ) do
		keys[i] = {{keys[i]}, {keys[i]}}
	end for
	return keys
	return repeat( keys, 2 )

-- old way....
--    ok = select_table( table_name )
	if atom(ok) then
		return ok
	end if
	
	recs = db_table_size()
	keys = repeat( {}, recs )
	
	for i = 1 to recs do
		keys[i] = {db_record_key( i )}
	end for
	keys = repeat( keys, 2 )

	return keys
	
end function

function check_condition( integer tx, sequence record, sequence expression )
	sequence wheres
	object ok
	integer ix

	wheres = table_wheres[tx]

	--ClearVar("")
	for j = 1 to length( wheres ) do
		ix = wheres[j][1]
		ok = record

		SetVar( wheres[j][2], ok )

	end for
	ok = Evaluate( expression )
			
	if equal( ok, ZERO ) then
		return 0
	end if

	return 1
end function

function load_record( integer tx, object key )
	integer ix

	ix = index(table_records[tx], key)
	if ix then
		return table_records[tx][2][ix]
	end if
	
	return repeat( EUSQL_NULL,	length(query[QN_INDICES][tx]) )
end function

sequence index_name, index_list

procedure store_index( sequence name, sequence list )
	integer ix

	ix = find( name, index_name )
	if ix then
		index_list[ix] = list
	else
		index_name = append( index_name, name )
		index_list = append( index_list, list )
	end if
end procedure

function recall_index( sequence name )
	integer ix

	ix = find(name, index_name )
	if ix then
		return index_list[ix]
	end if

	return 0
end function




function intersect_recursive( sequence a, sequence rec, integer levels )
	sequence r, result
	integer reslen
	reslen = 0
	result = repeat({}, length(rec))

	if levels > 1 then
		for i = 1 to length(rec) do
			r = rec[i]
			for j = 1 to length( r ) do
				r[j] = intersect_recursive( a, r[j], levels - 1 )
			end for
			rec[i] = r
		end for   
   
		return rec
	else
		for i = 1 to length(rec) do
			r = intersect_seq( a, rec[i][2] )
			if length(r) then
				reslen += 1
				result[reslen] = {rec[i][1], r}
			end if
		end for
	end if
	if reslen = 1 then
		return {result[1]}
	end if
	return result[1..reslen]
end function

-- indexed_keys will have a different form:
-- { val1, { val11, 0, { keys }},
--         { val12, { val121, 0, {keys}}}}
-- basically, the values are nested, rather than listed out,
-- so we can cut down drastically on the searching done
-- in build_pseudorecords()
function index_for_fields( integer tx, sequence fields )
	sequence all_index, fx, ix_list, all_ix, tname, alist, final_index, temp_index, alist2,
		next_index, last_index
	object iname, ok, key, akey, adata
	integer tfx, need_to_build, next_slot, max_slot, len, begin_index, end_index, ix
	atom recnum, ax

	tname = query[QN_TABLE][tx]

	if not length(fields) then
		-- should return the keys themselves...
		return get_keys_as_index(tx)
	end if
	len = length(fields)
	all_index = repeat( {{},{}}, len )
	
	final_index = all_index
	fx = all_index
	ix_list = {}
	all_ix = {}
	need_to_build = 0

	-- figure out which we need to build, and which we can load...
	for i = 1 to length(fields) do
		-- name of the index
		iname = query[QN_FIELD_INDEX][fields[i]]
		if sequence(iname) then
			-- load the index
			-- 4/17/03 now recalling an index already culled
			ok = recall_index( iname )
			if atom(ok) then

				iname = get_record_mult_fields("","INDEXDEF", iname, {"LIST"},{})
				iname = iname[1]

				-- now iname = { vals, keys }

				-- should cull this based on condition checking done in load_records
				if length(table_wheres[tx]) then
					--check_condition( tx, record, expression )

					-- alist = keys
					alist = iname[2]

					-- iterate through the keys
					for inum = 1 to length( alist ) do
						temp_index = {}
						for kx = 1 to length( alist[inum] ) do

							-- load_records has already done some checking on the records,
							-- and load_record will return nulls if we've already culled the record
							-- we're looking for
							adata = load_record( tx, alist[inum][kx])
							if not equal( adata, repeat( EUSQL_NULL, length(adata))) then
								temp_index = append( temp_index, alist[inum][kx] )
							end if
						end for

						-- add whatever records survived to the index
						if length( temp_index ) then
							all_index[i] = h:insert( all_index[i], iname[1][inum], temp_index )
						end if
					end for
				else
					all_index[i] = iname
				end if
			else
				all_index[i] = ok
			end if

		else
			tfx = find(fields[i],query[QN_ORDER][tx])
			if not tfx then
				tfx = find(-fields[i],query[QN_ORDER][tx])
			end if

			ok = recall_index( query[QN_NAMES][tx][tfx] )
			if sequence(ok) then
				all_index[i] = ok
			else
				need_to_build = 1

				ix_list = append( ix_list, tfx) --query[QN_ORDER][tx][tfx] )
				all_ix &= i
			end if
		end if
	end for


	-- builds individual indices
	-- this should be obsolete now
	ok = select_table( tname )
	if need_to_build then
		tname = query[QN_TABLE][tx]
			
		for i = 1 to length( ix_list ) do			 
			alist = all_index[all_ix[i]]			
			max_slot = length(alist[1])
			next_slot = max_slot +1
			alist[1] &= repeat({}, 100 )
			alist[2] &= repeat({}, 100 )
			max_slot += 100

			for j = 1 to length(table_records[tx][1]) do
				key = table_records[tx][2][j]

				-- 4/17/03 added brackets
				ok = {key[ix_list[i]]}

				-- ok is all fields--need to make only those in ix_list
				key = table_records[tx][1][j]
				--ok = get_record_mult_fields( "", tname, key, {}, ix_list)
				--ok = ok[1]

				-- ax = index( alist, ok ) -- ?
				ax = find( ok, alist[1] )
				
				if not ax or ax >= next_slot then

					--if length(ix_list) = 1 then
					--    ok = {ok}
					--end if

					alist[1][next_slot] = ok
					alist[2][next_slot] = {key}
					next_slot += 1
					if next_slot > max_slot then
						alist[1] &= repeat({},100)
						alist[2] &= repeat({},100)
						max_slot += 100
					end if
				else
					alist[2][ax] = append(alist[2][ax],key)
				end if

			end for
			alist[1] = alist[1][1..next_slot-1]
			alist[2] = alist[2][1..next_slot-1]
			all_index[all_ix[i]] = alist

		end for
	end if


	next_index = all_index[length(all_index)]
	final_index = repeat({},length(next_index[1]))

	for i = 1 to length(next_index[1]) do
		final_index[i] = {next_index[1][i], next_index[2][i]}
	end for
		
	last_index = final_index

	-- now to make them indices of indices...

	-- fx will be the index/pointer for all indices
	fx = repeat(1,len)
	ix = len-1

	while ix do
		next_index = {} --repeat( {}, length(all_index[ix][1]))
		for super_index = 1 to length(all_index[ix][1]) do
			-- need to use a recursive function...

			ok = { all_index[ix][1][super_index] }	&
				 intersect_recursive( all_index[ix][2][super_index], 
				 last_index, len-ix )
			if length(ok) > 1 then			  
				next_index = append(next_index, ok)
			end if
		end for
		last_index = next_index
		ix -= 1
	end while

	return last_index
end function


function score_tables( sequence score )
	integer max, ix, len
	sequence result

	len = length(score)

	result = {}

	while length(result) < len do
		ix = 0
		max = 0
		for i = 1 to len do
			if score[i] > max then
				max = score[i]
				ix = i
			end if			  
		end for

		if not ix then
			-- make sure each table is in result
			for i = 1 to len do
				if not find(i,result) then
					result &= i
				end if
			end for
		else
			result &= ix
			score[ix] = 0
		end if
	end while

	return result
end function

function field_order_val_to_table( object ord )
	integer flen, ix
	object tx
	if atom( ord ) then
		ord = {ord}
	end if

	flen = length(ord)
	tx = repeat(0,flen)
	for table = 1 to length( query[QN_TABLE] ) do
		for field = 1 to flen do

			if not tx[field] then
				ix = find( ord[field], query[QN_ORDER][table] )
				if not ix then
					ix = find( -ord[field], query[QN_ORDER][table] )
				end if

				if ix then
					tx[field] = table
				end if
			end if
		end for
	end for
	if flen = 1 then
		tx = tx[1]
	end if
	return tx
end function

-- to replace load_records
-- will call index_for_fields itself
function smart_load_records( )
	sequence load_order, score, criteria, criteria_order, indexed, tables, joins, jtx, aliases
	integer ix, table_count, tx, max, fx, jx, len, lx

	tables = query[QN_TABLE]
	aliases = query[QN_TABLE_ALIAS]
	
	load_order = {}
	ix = 0
	lx = 0
	while lx < length(tables) do
		if tables[ix+1][1] > 0 then
			ix += 1
		end if
		lx += 1
	end while
	table_count = lx
	len = lx

	score = repeat(repeat(0,table_count),2)
	indexed = query[QN_FIELD_INDEX]
	
	-- look at conditions and indices
	criteria = query[QN_WHERE][2]
	for i = 1 to length( criteria ) do
		if length(criteria[i]) then
			fx = criteria[i][1][1]
			tx = field_order_val_to_table( fx )
			if length(aliases[tx]) and not find( tx, load_order ) then
				score[1][tx] += 1
				if fx < 0 then
					fx = -fx
				end if
				if sequence(indexed[fx]) then
					score[2][tx] += 1
				end if
			end if
		end if
	end for

	-- now criteria_order is the order of tables by 
	-- [1]: # of fields in condition
	-- [2]: # of fields with an index
	criteria_order = {score_tables( score[1] ), score_tables( score[2] ) }
	
	-- first table we want will have indexed condition
	ix = 1
	jx = 1
	for i = 1 to len do
		ix = criteria_order[1][i]
		if score[1][ix] and score[2][ix] then
			load_order &= criteria_order[1][ix]
			exit
		end if
	end for

	-- if couldn't find anything, just use the one with the 
	-- most conditions
	-- maybe could change this do load by keys, since that could
	-- be faster...
	if not length(load_order) then
		if length( criteria_order[1] ) then
			load_order &= criteria_order[1][1]
		else
			return {}
		end if
		
	end if

	-- next we need to 'walk' the joins to see who may have either
	-- a key or an indexed field as part of the join
	
	-- stored in query[QN_JOIN]
	--  1: type (inner, left, right)
	--  2: first field (query order)
	--  3: second field (query order)
	--[4]: first table
	--[5]: second table
	joins = query[QN_JOINS]
	for i = 1 to length(joins) do
		joins[i] &= {field_order_val_to_table( joins[i][2]), 
				field_order_val_to_table( joins[i][3] )}
	end for

	-- flag to see if we added any tables on this pass
	jx = 1
	while jx and length(load_order) < len do
		jx = 0
		for i = 1 to len do
			if not find(i, load_order) then
				-- this one hasn't been put in line yet
				-- so check to see if it is joined with tables already
				-- in load_order, and whether the joined field is a key
				-- or is indexed
				for j = 1 to length(joins) do
					ix = find(i,joins[j][4..5])
					if ix and find(joins[j][6-ix], load_order) then
					-- make sure this join applies to this table and 
					-- one already in load_order
	
						if sequence( indexed[joins[j][ix+1]] ) then
						-- now, does the field have an index?
							load_order &= i
							jx = 1
							exit
						end if
					end if
				end for

			end if

		end for
	end while

	-- now load whatever else is left
	for i = 1 to len do
		if not find(i,load_order) and query[QN_TABLE][i][1] > 0 then
			load_order &= i
		end if
	end for

	return load_order
end function



function non_zero_match( sequence a, sequence b )
	integer all_good
	all_good = 1

	for i = 1 to length(a) do
		if a[i] and a[i] != b[i] then
			return 0
		end if
	end for

	return all_good
end function

-- this is specialized for build_pseudorecords
-- we're actually searching on the ix'th element of each
-- element of s
function b_search( object key, sequence s, integer ix )
	integer lo, hi, mid, c
	lo = 1
	hi = length(s)

	while lo <= hi do
		mid = floor((lo + hi) / 2)
		c = compare(key, s[mid][ix])
		if c < 0 then		-- key < s[mid]
			hi = mid - 1
		elsif c > 0 then	-- key > s[mid]
			lo = mid + 1
		else				-- key = s[mid]
			return mid
		end if
	end while
	return 0
end function


function join_recursive( sequence indexed_keys, sequence joins, sequence required )
	sequence the_list, the_join, link1, link2, temp_index
	integer table1, table2, first_required, second_required, good_join, loops

	if not length(joins) then
		return {indexed_keys}
	end if
	
	the_list = {}
	the_join = joins[1]
	
	if not length(required) then
		-- first time, have to figure out which tables are required
		-- start by assuming that they all are needed
		required = repeat( 1, length( indexed_keys ) )
		for i = 1 to length( joins ) do
			if joins[i][1] = EUSQL_RIGHT then
				required[joins[i][4]] = 0
			
			elsif joins[i][1] = EUSQL_LEFT then
				required[joins[i][5]] = 0
			end if
		end for
	end if
	
	if the_join[1] = EUSQL_RIGHT then
		table1 = the_join[5]
		table2 = the_join[4]
	else
		table1 = the_join[4]
		table2 = the_join[5]
	end if

	first_required  = required[table1]
	second_required = required[table2]
	
	link1 = indexed_keys[table1]
	link2 = indexed_keys[table2]
	temp_index = indexed_keys
	if length(link1) then
		
		for i = 1 to length( link1 ) do
	
			good_join = 0
			for j = 1 to length(link2) do
				-- Check the values of the two fields in the join to see if the
				-- records under consideration make a good join:
				if equal( link1[i][1], link2[j][1] ) then
	
					good_join = 1
					
					-- ???  what are we losing and what are we keeping?
					temp_index[table1] = link1[i][2..$]
					temp_index[table2] = link2[j][2..$]
					
					if length(joins) > 1 then
						the_list &= join_recursive( temp_index, joins[2..$], required)
						exit
					else
						the_list &= {temp_index}
						exit
					end if
				exit
				end if
			end for
	
			if not good_join and not second_required then
				-- it's an outer join, and since there's no good join, we have to
				-- include the first table with the null record of the second table
				temp_index[table1] = link1[i][2..$]
				temp_index[table2] = {}
				if length(joins) > 1 then
					the_list &= join_recursive( temp_index, joins[2..$], required)
				else
					the_list &= {temp_index}
				end if
			end if
		end for
		
	elsif not first_required and not second_required then
		if length(joins) > 1 then
			the_list &= join_recursive( temp_index, joins[2..$], required)
		else
			the_list &= {temp_index}
		end if
	end if
	return the_list

end function

-- 'main' is a sequence of indices that are grouped by the join values.
-- For each table that wasn't involved in a oin, this function strips 
-- out the a-list keys, leaving the a-list values, which are actually 
-- the db keys for the records.
function cross_product_recursive( sequence main, sequence index )
	sequence the_list, temp_item
	integer ix

	if not length(index) then
		return main
	end if

	the_list = {}

--	if length(index) = 1 then
		ix = index[1]

		for i = 1 to length(main) do
			temp_item = main[i]
			
			-- j loops through the tables
			for j = 1 to length(main[i][ix]) do
				
				temp_item[ix] = {main[i][ix][j][2]}
				the_list = append(the_list, temp_item)
				
			end for
		end for
		--return main & the_list
		the_list = cross_product_recursive( the_list, index[2..$] )
		return the_list
--	else

--		for i = 1 to length(main) do
--			if i = index[1] then
--				return cross_product_recursive( main, index[2..length(index)] )
--			end if
--		end for
--		
--		return the_list
--	end if

end function


-- this assumes that there's nothing in indexed_keys
-- it builds records from the raw indices recalled from
-- recall_index()
function build_pseudorecords( sequence indexed_keys, sequence load_order )

	sequence pseudo, joins, linked_index, joined_tables, indexed, unjoined_tables,
		blank_pseudo, temp_pseudo, rx, current_index, temp_index, lx, chunk
	integer table1, table2, fx, len, good_join, first_required, second_required,
		last_index, tx, last_pseudo, max_pseudo
	object temp_link, ok


	len = length(load_order)
	pseudo = {}
	linked_index = {}

	indexed = query[QN_FIELD_INDEX]

	-- stored in query[QN_JOIN]
	--  1: type (inner, left, right)
	--  2: first field (query order)
	--  3: second field (query order)
	--[4]: first table
	--[5]: second table

	joins = query[QN_JOINS]
	joined_tables = {}
	
	-- figure out which tables are involved in joins, plus add the names
	-- of the tables to 'joins':
	for i = 1 to length(joins) do
		joins[i] &= { field_order_val_to_table( joins[i][2] ), 
				      field_order_val_to_table( joins[i][3] )}

		for j = 1 to 2 do

			if atom(indexed[joins[i][j+3]]) then

				fx = find(joins[i][j+1], query[QN_ORDER][joins[i][j+3]])

				if not fx then
					fx = find(-joins[i][j+1], query[QN_ORDER][joins[i][j+3]])
				end if

				indexed[joins[i][j+1]] = query[QN_NAMES][joins[i][j+3]][fx]
			end if

			-- record all the tables in the join
			if not find( joins[i][j+3], joined_tables ) then
				joined_tables &= joins[i][j+3]
			end if
		end for
	end for

	unjoined_tables = {}
	for i = 1 to length(load_order) do
		if not find(i,joined_tables) then
			unjoined_tables &= i
		end if
	end for
	joins = sort( joins )
	linked_index = join_recursive( indexed_keys, joins, {} )
	
	-- now for unjoined tables...
	linked_index = cross_product_recursive( linked_index, unjoined_tables )    

	-- now do cross product of all linked keys...
	-- could probably optimize this with some quick multiplication
	chunk = repeat( {}, 100 )
	pseudo = chunk
	max_pseudo = length(pseudo)    
	last_pseudo = 0
	blank_pseudo = repeat( {}, len )

	for link = 1 to length(linked_index) do
		lx = repeat( 0, len )

		temp_index = linked_index[link]
		rx = repeat( 1, len )
		for i = 1 to len do
			if length(temp_index[i]) then
				lx[i] = length(temp_index[i][1])
			end if
		end for
		tx = len

		while tx do
			temp_pseudo = blank_pseudo
			for table = 1 to len do
				if lx[table] then
					temp_pseudo[table] = {temp_index[table][1][rx[table]]}
				end if
			end for
			
			last_pseudo += 1
			pseudo[last_pseudo] = temp_pseudo
			
			if last_pseudo = max_pseudo then
				max_pseudo += length(chunk)
				pseudo &= chunk
			end if
			rx[tx] += 1
			
			while tx and rx[tx] > lx[tx] do
				rx[tx..len] = 1
				tx -= 1
				if tx then
					rx[tx] += 1
				end if
			end while
			
			if tx then 
				tx = len
			end if
		end while
	end for
	
	return pseudo[1..last_pseudo]
end function

function get_keys( integer tx )
	object ok
	sequence keys

	ok = select_table( query[QN_TABLE][tx] )
	keys = repeat( {}, db_table_size())
	for i = 1 to length(keys) do
		keys[i] = db_record_key(i)
	end for

	return keys
end function


-- new and improved to take into account indices, conditions and joins better
procedure load_records( integer tx, sequence load_order )
	integer need_to_check, ix, jx, fx, kx, mkx, distinct, that_table, this_table, required,
		tix, mtix, rkx, mrkx
	sequence joins, indexed, condition_fields, join_fields, keys, join_type, this_index,
		that_index, key_list, the_where, removed_keys, record, field, index, index_name,
		index_no_join, saved_keys, rx, temp_records, this_index1, this_index2, temp_index1,
		temp_index2, condition_fieldsi
	atom recnum, t
	object ok

	indexed = query[QN_FIELD_INDEX]
	distinct = query[QN_DISTINCT]

	-- check for conditions
	condition_fields = {}
	the_where = query[QN_WHERE][1]

	ok = query[QN_WHERE][2]
	need_to_check = 0

	for i = 1 to length(ok) do
		if length(ok[i]) then
			fx = field_order_val_to_table( ok[i][1][1] )
			if tx = fx then
				condition_fields &= ok[i]
				fx = ok[i][1][1]
				if fx < 0 then
					fx = -fx
				end if
				if sequence( indexed[fx] ) then
					-- we can do condition testing here if
					-- the field is indexed
					need_to_check = 1
				end if
			elsif query[QN_TABLE][fx][1] < 0  then
				condition_fields &= ok[i]
			end if
		end if
	end for

	-- flag to indicate whether we need to run any conditions


	-- stored in query[QN_JOIN]
	--  1: type (inner, left, right)
	--  2: first field (query order)
	--  3: second field (query order)
	--[4]: first table
	--[5]: second table

	joins = query[QN_JOINS]
	for i = 1 to length(joins) do
		joins[i] &= {field_order_val_to_table( joins[i][2]), 
				field_order_val_to_table( joins[i][3] )}
	end for

	-- check for joins, index where other table already loaded
	ix = 1
	ok = {{},{}}
	keys = {}
	join_type = {}
	index_no_join = {}

	while ix <= length(joins) do
		jx = find( tx, joins[ix][4..5] )

		if jx
		and ( sequence(indexed[joins[ix][jx+1]]) 
			  or equal(order_to_index(joins[ix][jx+1]),{1}))
		and ( equal(order_to_index(joins[ix][4-jx]),{1}) 
			  or sequence(indexed[joins[ix][4-jx]]) ) then
			if find(tx, load_order) > find(joins[ix][6-jx], load_order) then
				-- other table is loaded already, and each is either primary key or indexed
				ix += 1
			else
				-- other table isn't loaded yet, but we should cull this index
				if sequence(indexed[joins[ix][jx+1]]) then
					index_no_join &= {indexed[joins[ix][jx+1]]}
				end if

				joins = joins[1..ix-1] & joins[ix+1..length(joins)]

			end if
		else
			joins = joins[1..ix-1] & joins[ix+1..length(joins)]
		end if
	end while

	for i = 1 to length(joins) do
		--    [this]   [other]
		-- 1: indexed  indexed
		-- 2: indexed  key
		-- 3: key      indexed
		-- 4: key      key

		jx = find( tx, joins[i][4..5] )

		
		-- join_type
		-- [1] this table has index
		-- [2] that table has index
		-- [3] treat as inner join

		if jx then
			that_table = joins[i][6-jx]
			join_type = sequence(indexed[joins[i][jx+1]]) & 
				sequence(indexed[joins[i][4-jx]]) &
				(joins[i][1] = EUSQL_INNER or (jx=4 and joins[i][1] = EUSQL_RIGHT) )

			-- load the indices if they exist, and check conditions
			if join_type[1] then
				index_name = indexed[joins[i][jx+1]]
				this_index = get_record_mult_fields( "", "INDEXDEF", 
					index_name, {"LIST"},{})

				this_index = this_index[1]

			else
				-- should be the keys, then
				key_list = get_keys(tx)
				for j = 1 to length( key_list ) do
					key_list[j] = {key_list[j]}
				end for
				this_index = repeat(key_list, 2 )
				fx = find( joins[i][jx+1], query[QN_ORDER][tx])
				if not fx then
					fx = find( -joins[i][jx+1], query[QN_ORDER][tx])
				end if
				index_name = query[QN_NAMES][tx][fx]
			end if

			-- don't bother if this is an outer join
			if joins[i][1] = EUSQL_INNER or (joins[i][1] = EUSQL_LEFT and
				jx = 2) or (joins[i][1] = EUSQL_RIGHT and jx = 1) then

				-- now check the conditions...
				for j = 1 to length(condition_fields) do
					fx = condition_fields[j][1]
					if fx < 0 then
						fx = -fx
					end if
					if fx = joins[i][jx+3] then
						-- this field is in the conditions...
						-- need to set parameters!
						for k = length(this_index[1]) to 1 by -1 do
							SetVar( condition_fields[j][2], this_index[1][k][1] )

							ok = Evaluate( the_where ) 

							if equal( ok, ZERO ) then
								this_index = h:delete( this_index, this_index[1][k] )
							end if
						end for
						ClearVar( condition_fields[j][2] )

					end if
				end for

			   if join_type[2] then
					ok = recall_index( indexed[joins[i][4-jx]] )
					if atom(ok) then
						that_index = get_record_mult_fields( "", "INDEXDEF", 
							indexed[joins[i][4-jx]], {"LIST"},{})

						that_index = that_index[1]
						-- need to cull stuff that is gone
						-- we were picking up way to much stuff
						record = that_index[1]
						key_list = that_index[2]
						for j = 1 to length(key_list) do
							field = key_list[j]
							for k = 1 to length(field) do
								if not find(field[k], table_records[that_table][1] ) then
									ok = h:fetch_list( that_index, record[j] )
									ix = find( field[k], ok )
									ok = ok[1..ix-1] & ok[ix+1..length(ok)]
									if length(ok) then
										that_index = h:set_list( that_index, record[j], ok )
									else
										that_index = h:delete( that_index, record[j] )
									end if
								end if
							end for
						end for
				
						that_index = that_index[1]
					else
						that_index = ok[1]
					end if
				else
					-- 'that' table is already loaded, so just grab the keys...
					that_index = table_records[joins[i][6-jx]][1]
					for j = 1 to length(that_index) do
						that_index[j] = {that_index[j]}
					end for
				end if

				-- get a list of keys based on the indices that we should add
				for j = 1 to length(this_index[1]) do

					if find( this_index[1][j], that_index ) then
						-- only add keys that aren't in already
						key_list = this_index[2][j]
						for k = 1 to length(key_list) do
							if not find(key_list[k], keys) then
								keys = append(keys, key_list[k])
							end if
						end for
					elsif join_type[3] then
					-- outer join
						key_list = this_index[2][j]
						for k = 1 to length(key_list) do
							ix = find(key_list[k], keys)
							if ix then
								keys = keys[1..ix-1] & keys[ix+1..length(keys)]
							end if
						end for
					end if
				end for
			else
			-- outside of an outer join, so just load all
				keys = get_keys(tx)    
			end if
		end if

		store_index( index_name, this_index )
	end for
	

	if not length(joins) then

		-- we may not have had any joins, but we can still check conditions...
		if need_to_check then

			-- now check the conditions...
			mrkx = 100
			rkx = 0
			removed_keys = repeat( 0, mrkx )

			for i = 1 to length(condition_fields) do
				condition_fieldsi = condition_fields[i]
				fx = condition_fieldsi[1]
				if fx < 0 then
					fx = -fx
				end if
				
				-- should be indexed or key...
				ok = order_to_index(fx)
				if sequence(indexed[fx]) or equal( ok, {1}) then

					--need_to_check = 0			 
 
				   -- this field is in the conditions...
					if compare( ok, {1}) then
						this_index = get_record_mult_fields( "", "INDEXDEF", indexed[fx],
							{"LIST"}, {})
						this_index = this_index[1]
					else
						this_index = get_keys( tx )
						for j = 1 to length(this_index) do
							this_index[j] = {this_index[j]}
						end for
						this_index = repeat(this_index,2)
					end if

					this_index1 = this_index[1]
					this_index2 = this_index[2]
					temp_index1 = repeat( 0, length(this_index1))
					temp_index2 = temp_index1
					tix = 0

					mrkx = length(removed_keys)
					
					for j = 1 to length(this_index1) do
						ok = this_index1[j][1]
						if sequence(ok) then
							ok = {DATA,ok,{}}
						end if
						SetVar( condition_fieldsi[2], ok )

						ok = Evaluate( the_where ) 
						
						if equal( ok, ZERO ) then
							rkx += 1
							if rkx > mrkx then
								removed_keys &= repeat(0, 100)
								mrkx += 100
							end if
							removed_keys[rkx] = this_index2[j]
							--removed_keys &= this_index[2][j]
							--this_index = h:delete( this_index, this_index[1][j] )
						else
							tix += 1
							temp_index1[tix] = this_index1[j]
							temp_index2[tix] = this_index2[j]
						end if
					end for
					ClearVar( condition_fieldsi[2] )

					
					this_index1 = temp_index1[1..tix]
					this_index2 = temp_index2[1..tix]
					removed_keys = removed_keys[1..rkx]

					-- add whatever survived to keys
					kx = length(keys)
					mkx = kx + 100
					keys &= repeat( 0, 100 )
					
					for j = 1 to length(this_index1) do
						key_list = this_index2[j]
						for k = 1 to length(key_list) do
							if not find(key_list[k], keys) and 
							not find(key_list[k], removed_keys) then
								kx += 1
								if kx > mkx then
									mkx += 100
									keys &= repeat( 0, 100 )
								end if
								keys[kx] = key_list[k]
								--keys = append(keys, key_list[k])
							end if
						end for
					end for
					keys = keys[1..kx]
					-- only check one index...probably faster
					exit
				end if
			end for
			keys = sort(keys)
		else
			-- this catches whether there were no conditions or if they weren't indexed...
			-- just load them all
			keys = get_keys( tx )
			if length(condition_fields) then
				need_to_check = 1
			end if
		end if
	end if
	
	index = query[QN_INDICES][tx]
	ok = select_table( query[QN_TABLE][tx] )

	-- now update table_records[tx]
	for i = 1 to length(keys) do

		-- should do a condition check here, as well...
		ok = keys[i]
		recnum = db_find_key( ok )
		record = {ok} & db_record_data( recnum )

		-- now check to make sure it's ok
		-- but only check if we didn't already look...
		if need_to_check then
			-- set the variables as required...

			for j = 1 to length( condition_fields ) do
				-- this doesn't do parameters, since they come from a different
				-- table...
				condition_fieldsi = condition_fields[j]
				ok = field_order_val_to_table( condition_fieldsi[1] )
				if ok = tx then
					ok = seq_fetch( record, order_to_index( condition_fieldsi[1] ))
					if sequence(ok) then
						ok = {DATA, ok, {}}
					end if
					SetVar( condition_fieldsi[2], ok )
				else
					-- don't let previous checks interfere with this evaluation
					ClearVar( condition_fieldsi[2] )
				end if
			end for

			ok = Evaluate( the_where )
			
			for j = 1 to length( condition_fields ) do
				ClearVar( condition_fields[j][2] )
			end for
			if compare(ok, ZERO) then

				field = {}

				-- keep only the stuff we need    
				for j = 1 to length(index) do
					field = append( field, get_field( record, index[j] ) )
				end for

				if not (distinct and find(field, table_records[tx][2])) then
					table_records[tx][1] &= {keys[i]}
					table_records[tx][2] &= {field}
				end if

			end if

		elsif compare( query[tx][QN_TABLE], EUSQL_FIELD_CALC ) then
			field = {}
			-- keep only the stuff we need    
			for j = 1 to length(index) do
				field = append( field, get_field( record, index[j] ) )
			end for

			if not (distinct and find(field, table_records[tx][2])) then
				table_records[tx][1] &= {keys[i]}
				table_records[tx][2] &= {field}
			end if
		else
			table_records[tx][1] = {{}}
			table_records[tx][2] = {{}}
		end if
	end for

	keys = table_records[tx][1]
	index = table_records[tx][2]

	-- now take care of additional indices for later
	for i = 1 to length( index_no_join ) do
		index_name = index_no_join[i]
		this_index = get_record_mult_fields( "", "INDEXDEF", index_name,
			{"LIST"}, {})
		this_index = this_index[1]

		-- get the index to the field in table_records[tx][2]
		fx = find(index_name, indexed)
		ix = find(fx, query[QN_ORDER][tx])
		if not ix then
			ix = find(-fx,query[QN_ORDER][tx])
		end if
		fx = ix

		-- cull this_index
		ix = 1
		record = this_index[1]
		key_list = this_index[2]
		that_index = this_index
		rx = repeat(0,length(that_index[1]))
		-- let's do this by the keys that we have
		for recordx = 1 to length(keys) do
			ix = find({index[recordx][fx]}, record )
			if ix then
				rx[ix] += 1
				that_index[2][ix][rx[ix]] = keys[recordx]
			end if
		end for
		ix = 0


		for j = 1 to length(rx) do
			if rx[j] then
				ix += 1
				this_index[1][ix] = that_index[1][j]
				this_index[2][ix] = that_index[2][j][1..rx[j]]
			end if
		end for
		
		this_index[1] = this_index[1][1..ix]
		this_index[2] = this_index[2][1..ix]
		store_index( index_name, this_index )
	end for

end procedure



-- convert a sequence of pseudo records into real records
-- records still need to be ordered
-- within each record will be the fields for the corresponding table
-- in the order of QN_INDICES, so need to put in order and run through
-- any where clause

function pseudo_to_records( sequence pseudo_list )
	sequence records, fields, record, this_pseudo, cur_field, num_fields,
		null_record
	object key
	integer len, kx, rx, mrx, good

	if not length(pseudo_list) then
		return ""
	end if

	mrx = 100
	rx = 0
	records = repeat( 0, mrx )

	-- fields will be an a_list for each table with the primary key as key
	-- and the fields for the table as record
	len = length( pseudo_list[1] )
	fields = repeat( {{},{}}, len )
	num_fields = fields
	for table = 1 to len do
		num_fields[table] = length(query[QN_INDICES][table])
	end for

	for pseudo = 1 to length( pseudo_list ) do
		good = 1
		this_pseudo = pseudo_list[pseudo]
		record = repeat({}, len )
		
		for table = 1 to len do
			null_record = repeat( "", num_fields[table] )
			key = this_pseudo[table]
			if length(key) then
				key = key[1]
				cur_field = fields[table]
				kx = h:index( cur_field, key )
				if not kx then
					cur_field = h:insert( cur_field, key, 
										load_record(table, key) )
					kx = h:index( cur_field, key )
					fields[table] = cur_field
				end if

-- 11/17/06: This causes problems if the record is actually all null.
--           Not sure if it's really required any more.  Comment out
--           and see what breaks. :(
--				-- 11/18/03: added this test because we're not checking
--				-- every single index in load_records, so some bogus
--				-- keys may have slipped in--this seems much faster
--				if compare( cur_field[2][kx], null_record ) then
					record[table] = cur_field[2][kx]
--				else
--					good = 0
--					exit
--				end if
			else
				-- need to add null fields
				record[table] = repeat( EUSQL_NULL, num_fields[table])
			end if
		end for
		
		if good then
			rx += 1
			if rx > mrx then
				records &= repeat( 0, 100 )
				mrx += 100
			end if
			records[rx] = record
		end if
	end for

	return records[1..rx]
end function

constant DIGITS = "01234556789", WHITE_SPACE = " \t\n\r"
--/topic Utilities
--/func text_to_date_time( sequence text )
--
--Converts a date-time in text format (YYYY-MM-DD HH:MM:SS) to the native DATE_TIME
--format.
global function text_to_date_time( sequence text )
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

function run_select( sequence sql )
	sequence recordset, field_order, field, rx, field_count, select, calc, groups, 
			group_calcs, field_order_neg, join_fields, indexed_keys, pseudo_records, 
			records, record, wheres, load_order
	integer qx, visible_fields, distinct, ix, last_table, len_table, add_record, 
		values_set
	object ok, t
	
	-- Check for simple case of "SELECT COUNT(*) FROM TABLE_NAME"
	if length(sql[QN_TABLE]) = 1 then
		if equal( sql[QN_AGGREGATES], {{32,1}} ) and length( sql[QN_INDICES] ) = 1 and
		equal(sql[QN_WHERE], {{},{{}}}) then
			-- This looks like a "SELECT COUNT(*) FROM TABLE_NAME", so just do a db_table_size()
			
			ok = db_select_table( sql[QN_TABLE][1] )
			if ok != DB_OK then
				extended_error = sql[QN_TABLE]
				return EUSQL_ERR_TABLE
			end if
			return { {"COUNT OF " & sql[QN_TABLE][1]}, { {db_table_size()} }, { EUSQL_EU_INTEGER } }
		end if
	end if

	values_set = 0
	query = sql
	index_name = {}
	index_list = {}

	init_params()

	field = {}
	field_order = {}
	field_count = {}
	
	distinct = sql[QN_DISTINCT]
	len_table = length( sql[QN_TABLE] )

	last_table = 0

	-- generate order list to use to put fields in order later
	for i = 1 to len_table do
		field &= sql[QN_NAMES][i]
		field_order &= sql[QN_ORDER][i]
		field_count &= length( sql[QN_NAMES][i] )
		if sql[QN_TABLE][i][1] > 0 then
			last_table = i
		end if
	end for
	table_records = repeat( repeat({},2), last_table )

	visible_fields = 0
	for i = 1 to length( field_order ) do
		if field_order[i] > 0 then
			visible_fields += 1
		end if
	end for
	

	-- save order with negatives so we can weed out
	-- invisible fields later
	field_order_neg = field_order
	field_order = abs_val( field_order )

	-- put column headings in query[1]
	field = order( field, field_order )
	recordset = {order_visible( field, field_order_neg) , {}}

	join_fields = repeat( {}, last_table )
	indexed_keys = join_fields

	for join = 1 to length( sql[QN_JOINS]) do
		ok = field_order_val_to_table( sql[QN_JOINS][join][2..3] )
		join_fields[ok[1]] &= sql[QN_JOINS][join][2]
		join_fields[ok[2]] &= sql[QN_JOINS][join][3]
	end for

	-- set up where clause testing
	-- format:  { expr, { {order val, name} } }

	ok = sql[QN_WHERE][2]
	wheres = {}
	table_wheres = ok

	for i = 1 to length(ok) do

		wheres &= ok[i]
		
		if length(ok[i]) and i <= last_table then
			-- store the index to the field with respect to where it appears
			-- in QN_ORDER
			for j = 1 to length(ok[i]) do

				table_wheres[i][j][1] = find( ok[i][j][1], query[QN_ORDER][i])
			end for
		end if
	end for
	join_wheres = sql[QN_WHERE][1]

	-- try to optimize the order in which we load the tables
	-- first get tables with indexed fields that are included
	-- in the WHERE clause
	-- then try to pick tables that are joined by indexed fields
	-- whenever a table is loaded, we try to use the index
	-- vs other tables to minimize the number of records we actually
	-- have to load.  This reduces time spent loading *and* building
	-- the indices in indexed_keys--next step is to save the
	-- indices used in load_records and reuse them in index_for_fields
	-- if possible, to save duplication of effort
	
	load_order = smart_load_records()
	for tablex = 1 to length(load_order) do

		load_records( load_order[tablex], load_order )
		indexed_keys[load_order[tablex]] = index_for_fields( load_order[tablex], 
			join_fields[load_order[tablex]] )

	end for
	
	pseudo_records = build_pseudorecords( indexed_keys, load_order )
	records = pseudo_to_records( pseudo_records )

	-- combine and order records, do calculated fields
	-- set the variables for calculated fields
	for recnum = 1 to length( records ) do

		record = {}

		for table = 1 to len_table do
			if sql[QN_TABLE][table][1] > 0 then
				record &= records[recnum][table]

		-- handle the values/params/calculated fields
			elsif equal( sql[QN_TABLE][table], EUSQL_FIELD_VALUE ) then

				select = sql[QN_INDICES][table]
				if not values_set then
					ok = sql[QN_NAMES][table]
					for i = 1 to length(select) do
						if sequence(select[i]) then
							SetVar( ok[i], {DATA, select[i], {}})
						else
							SetVar( ok[i], select[i] )
						end if
					end for
					values_set = 1
				end if
				for i = 1 to length(select) do
					if sequence(select[i]) and length(select[i]) = 3 and select[i][1] = DATA then
						select[i] = select[i][2]
					end if
				end for
				record &= select
			elsif equal( sql[QN_TABLE][table], EUSQL_FIELD_PARAM ) then
				select = sql[QN_INDICES][table]

				for j = 1 to length( select ) do
					ok = get_parameter( select[j] ) 
					if sequence(ok) and length(ok) = 3 and ok[1] = DATA then
						ok = ok[2]
					end if

					select[j] =  ok
					--record[table] = { {{1}} & select}
				end for
				record &= select

			elsif equal( sql[QN_TABLE][table], EUSQL_FIELD_CALC ) then
				ok = 1
				for tv = 1 to table - 1 do

					if not find( sql[QN_TABLE][tv], {EUSQL_FIELD_PARAM, EUSQL_FIELD_VALUE}) then
						select = sql[QN_NAMES][tv]
						for fv = 1 to length(select) do
							if sequence(record[ok]) then
								SetVar( mathize_name( select[fv]), {DATA, record[ok], {}})
							else
								SetVar( mathize_name( select[fv] ), record[ok] )
							end if
							ok += 1
						end for
					else
						ok += length(sql[QN_INDICES][tv])
					end if
				end for
				
				select = sql[QN_INDICES][table]
				
				for cf = 1 to length(select) do
					select[cf] = Evaluate( select[cf])
					if select[cf][1] = CONSTANT then
						select[cf] = select[cf][ARG1][1]						
					elsif select[cf][1] = DATA then
						select[cf] = select[cf][ARG1]
					else
						select[cf] = PPExp( select[cf] )
					end if
				end for
				record &= select				
			end if

		end for
		

		-- now put in order    
		record = order( record, field_order )

		if not (distinct and find(record, records)) then
			add_record = 1
			if length( join_wheres ) and not equal( join_wheres, ONE ) then
				--ClearVar("")
				for j = 1 to length( wheres ) do
					ix = abs_val( wheres[j][1] )
					ok = record[ix]

					if sequence(ok) then
						ok = {DATA, ok, {}}
					end if

					SetVar( wheres[j][2], ok )


				end for

				ok = Evaluate( join_wheres )
			
				if equal( ok, ZERO ) then
					add_record = 0
				end if
			end if
			if add_record then
				recordset[2] = append( recordset[2], order_visible( record, field_order_neg ))
			end if
		end if
	end for

	if length( sql[QN_AGGREGATES] ) then
		-- perform EUSQL_GROUP, EUSQL_COUNT, EUSQL_SUM, EUSQL_MAX and EUSQL_MIN
		-- first we'll need to sort the groups, and then do the
		-- calculations.

		order_by = {}		
		qx = 1
		-- rx holds the aggregate fields other than EUSQL_GROUP
		rx = {}
		group_calcs = {}
		select = sql[QN_AGGREGATES]
	   
		while qx <= length(select) do
			field = select[qx]
			if field[1] = EUSQL_GROUP then
				order_by &= field[2]
			else
				rx &= { field }
				if group_funcs[field[1]] then
					group_calcs &= { field }
				end if
			end if
			
			qx += 1
		end while  
		if length( recordset[2] ) then		
			for i = 1 to length( rx ) do
				recordset[1][rx[i][2]] = 
					AGG_LABEL[2][find(rx[i][1], AGG_LABEL[1])] & recordset[1][rx[i][2]]
			end for
			
			if length( order_by ) then
				recordset[2] = custom_sort( GROUP_BY, recordset[2] )
			end if
			-- now we need to do the calculations...
		   
			groups = repeat( get_groups( recordset[2][1], order_by ), 2 )
			calc = {}
			-- recordset[2] index
			qx = 0
			-- calc index
			ix = 0
	
			for i = 1 to length( recordset[2] ) do
				groups[1] = get_groups( recordset[2][i], order_by )
				
				if not equal( groups[1], groups[2] ) or not length(calc) then
					-- next group!       
					
					if length( group_calcs ) and ix then 
						-- do group calculations for things like avg
						calc[ix] = group_calc( calc[ix], group_calcs )
					end if
					
					calc &= {repeat( 0, visible_fields )}
					qx += 1
					ix += 1
					
					-- initialize the group values...
					for j = 1 to length( order_by ) do
						calc[ix][order_by[j]] = recordset[2][i][order_by[j]]
					end for
				   
					groups[2] = groups[1]
	
					for j = 1 to length(rx) do
						if rx[j][1] = EUSQL_MIN then
							calc[ix][rx[j][2]] = 1e300
						elsif rx[j][1] = EUSQL_MAX then
							calc[ix][rx[j][2]] = - 1e300
						end if
					end for
				end if
				
				-- do the calculations...
				for j = 1 to length( rx ) do
					calc[ix][rx[j][2]] = call_func( AGG_FUNC[rx[j][1]], 
						{ recordset[2][i], calc[ix], rx[j][2] } )
				end for
				
			end for
			
			-- need to calc the last group
			if length( group_calcs ) and ix then 
				-- do group calculations for things like avg
				calc[ix] = group_calc( calc[ix], group_calcs )
			end if
			
			recordset[2] = calc
		else
			-- no records
			calc = repeat( "", length(recordset[1]))
			for i = 1 to length(rx) do
				if rx[i][1] = EUSQL_COUNT then
					calc[rx[i][2]] = 0
				end if
			end for
			if find( 0, calc ) then
				-- should report a zero count (but not any other aggregates):
				recordset[2] = {calc}
			end if
			
		end if
	end if
		
	if length( sql[QN_ORDERING][1] ) then
	-- since we need to do special ordering for aggregates (GROUP BY),
	-- move this below that code...
		order_by = sql[QN_ORDERING]
		recordset[2] = custom_sort( CUSTOM_COMPARE, recordset[2] )
		order_by = {{},{}}
	end if
	
	return recordset & {sql[QN_DATATYPES]}
end function

--/topic Data
--/func delete_record( sequence db_name, sequence table_name, object key )
--/info
--Delete record with primary key 'key' from specified db/table.

global function delete_record( sequence db_name, sequence table_name,
		object key)
		
	object ok
	integer update_index, field_changed, field_num, ax, kx
	atom recnum, indexnum
	sequence record, datatypes, ix, index_exists, old_data, the_index, index_as_record
	
	save_current()
	ok = select_current( db_name, table_name )
	if atom(ok) then
		restore_current()
		return ok
	end if
	
	if not length(table_name) then
		table_name = current_table
	end if
	
	ok = db_find_key( key )
	if ok < 0 then
		restore_current()
		extended_error = "Could not delete record."
		return EUSQL_FAIL
	end if
	recnum = ok
	record = { key } & db_record_data( recnum )

	-- see if any of our fields have an index...
	update_index = 0

	ok = get_record_mult_fields( "", "TABLEDEF", table_name, {"INDEXED"},{})
	if atom(ok) then
		return ok
	end if

	index_exists = ok[1]
	for i = 1 to length(index_exists) do
		if sequence( index_exists[i] ) then
			update_index = 1
		end if
	end for

	ok = get_record( "", "TABLEDEF", table_name, "INFO.INDICES","")
	if atom(ok) then
		restore_current()
		return ok
	end if
	ix = ok[1]

	if update_index then
		ok = db_select_table( "INDEXDEF" )
		for i = 1 to length( index_exists ) do

			if sequence( index_exists[i] ) then

				-- load the index
				indexnum = db_find_key( index_exists[i] )
				index_as_record = db_record_data( indexnum )
				the_index = index_as_record[2]

				-- update the index
				-- ax should never be 0! (index alist keys are always wrapped in an extra sequence)
				ax = find( {seq_fetch(record, ix[i])}, the_index[1] )
				if ax then
					-- delete from old...
					if length( the_index[2][ax] ) = 1 then
						-- this was the only one...remove it
						kx = length(the_index[1])
						the_index[1] = the_index[1][1..ax-1] & the_index[1][ax+1..kx]
						the_index[2] = the_index[2][1..ax-1] & the_index[2][ax+1..kx]
					else
						kx = find( record[1], the_index[2][ax] )
						if kx then
							the_index[2][ax] = the_index[2][ax][1..kx-1] & 
								the_index[2][ax][kx+1..length(the_index[2][ax])]
						end if
					end if
					index_as_record[2] = the_index
					db_replace_data( indexnum, index_as_record )
				end if
			end if
		end for
	end if

	ok = db_select_table( table_name )
	db_delete_record( recnum )
	restore_current()
	return {}
end function

-- this updates an index single or multiple times, in order to batch 
-- large updates and speed the process
-- to add records, keys should be in add_key, and the new value should be in remove_key
-- however, adding records not implemented yet....
function update_index( sequence db_name, sequence index_name, sequence add_key, object remove_key )
	object the_val, ok, the_key
	atom indexnum
	integer j, ix, vx, kx
	sequence the_index, keys, vals

	save_current()
	ok = select_current( db_name, "INDEXDEF" )


	index_name = upper(index_name)
	ok = get_record_mult_fields( db_name, "INDEXDEF", index_name, { "LIST" }, {})
	if atom(ok) then
		restore_current()
		extended_error = "Could not access index '" & index_name & "'\n" & extended_error
		return ok
	end if
	ok = db_select_table("INDEXDEF")
	indexnum = db_find_key( index_name )
	the_index = db_record_data( indexnum )
	vals = the_index[2][1]
	keys = the_index[2][2]

	
	if length(add_key) then
		-- haven't done this yet...
		for i = 1 to length( add_key ) do
			the_val = remove_key[i]
			vx = find( the_val, vals )
			if vx then
				keys[vx] = sort( keys[vx] & add_key[i] )
			else
				ok = h:insert( {vals, keys}, the_val, sort(add_key[i]) )
				vals = ok[1]
				keys = ok[2]
			end if
		end for

	else
		for i = 1 to length(remove_key) do
			the_key = remove_key[i]
			
			-- find the entry in the index
			j = 1
			while j <= length(vals) do
				ix = find( the_key, keys[j])
				if ix then
					ok = length(vals)
					if length(keys[j]) = 1 then
						vals = vals[1..j-1] & vals[j+1..ok]
						keys = keys[1..j-1] & keys[j+1..$]
						exit
					else
						keys[j] = keys[j][1..ix-1] & keys[j][ix+1..$]
						exit
					end if
				end if
				j += 1
			end while
		end for

	end if

	-- now update the index...
	the_index[2] = { vals, keys }
	db_replace_data( indexnum, the_index )
	restore_current()
	return {}
end function



-- execute a compiled 'DELETE' query
-- if deleting many records, and indices exist, this is very slow
-- should consolidate that processing and do it within this routine
-- instead of many calls to delete_record()
function run_delete( sequence sql )
	sequence keys, table, title, dt, index_list, table_keys
	integer rec
	object ok

	-- need to get list of records to delete
	keys = run_select( sql )
	title = keys[1]
	dt = keys[3]
	keys = keys[2]
	
	-- then delete the records
	for x = 1 to length( sql[QN_VALUES][2] ) do
		table = sql[QN_TABLE][sql[QN_VALUES][2][x]]
		ok = get_record_mult_fields( "", "TABLEDEF", table, {"INDEXED"},{})
		if atom(ok) then
			return ok
		end if
		index_list = ok[1]

		ok = select_table( table )
		if atom(ok) then
			return ok
		end if
		table_keys = {}
		-- delete!
		for i = 1 to length( keys ) do

			-- this is very slow for many records when indices must 
			-- be updated--should create a proc to update an index,
			-- and allow for multiple changes with one call
			--ok = delete_record( "", table, keys[i][x] )
			rec = db_find_key( keys[i][x] )
			table_keys = append( table_keys, keys[i][x] )
			if rec > 0 then
				db_delete_record( rec )
			end if
			
		end for

		for i = 1 to length(index_list) do
			if sequence(index_list[i]) then
				ok = update_index( "", index_list[i], {}, table_keys )
			end if
		end for 	   
	end for
	
	-- return deleted keys
	return { title, keys, dt }
end function


-- puts the data into field structure

--/topic Utilities
--/func map_field( sequence field, sequence data, sequence index )
--<ul>
--/li /b field: blank structure of the record (see /blank_record() and /blank_field())
--/li /b data: sequence of fields
--/li /b index: sequence of field indices
--</ul>
--
--This is used by EuSQL to put field values into a structured EuSQL record.  For instance,
--if your table had the fields:
--<ul>
--/li NAME.FIRST
--/li NAME.LAST
--/li PHONE_NUMBER
--/li ADDRESS.STREET
--/li ADDRESS.COUNTRY
--</ul>
--And you wanted to insert data for John Smith, with phone number 555-1234, 
--living at 123 Main St, USA:
--/code
--  ok = map_field( {{ {}, {} }, {}, { {}, {}}},    -- the record structure without any data
--                   { "John", "Smith", "555-1234", -- the data to be stored
--                     "123 Main St", "USA" },
--                   {{1,1},{1,2},{2},{3,1},{3,2}}) -- the respective field indices for each
--                                                  -- field
--
--  ok = { {"John", "Smith"},"555-1234",{"123 Main St","USA"}}
--/endcode

global function map_field( sequence field, sequence data, sequence index )
	
	for i = 1 to length( data ) do
		for j = 1 to length( index ) do
			--field = seq_store( data[i], field, index[j] )
			
			-- used to be this.  should probably change back
			-- and modify insert routine
			field = seq_store( data[i][j], field, index[j] )
		end for
	end for
	
	return field
end function


--     key: key of record to update
--   field: indices of fields to update
--    data: data corresponding to the fields to update
-- replace: true = key is changing, false = key not changing


--/topic Data
--/func update_record2( sequence db_name, sequence table_name, object key, sequence index, sequence data, integer key_changing )
--/info
--Update a record.  
--<ul>
--/li /b key specifies which record is to be updated
--/li /b index specifies the field indices to update
--/li /b data is a sequence of field values to update
--/li /b key_changing should be 1 if the record key is to be changed, 0 otherwise
--</ul>
--This can be quicker than /update_record(), but the calling procedure must be 
--aware of whether any element of the primary key is changing.

global function update_record2( sequence db_name, sequence table_name, 
		object key, sequence field, sequence data, object replace )
	
	object ok
	atom recnum
	integer update_index, field_changed, field_num, ax, kx
	sequence record, datatypes, ix, index_exists, old_data, the_index, index_as_record
	
	save_current()
	ok = select_current( db_name, table_name )
	if atom(ok) then
		restore_current()
		return ok
	end if

	recnum = db_find_key( key )
	if recnum < 0 then	
		restore_current()
		extended_error = "No such record"
		return EUSQL_FAIL
	end if

	-- see if any of our fields have an index...
	update_index = 0
	index_exists = get_record_mult_fields( "", "TABLEDEF", table_name, {"INDEXED"},{})
	index_exists = index_exists[1]
	for i = 1 to length(index_exists) do
		if sequence( index_exists[i] ) then
			update_index = 1
		end if
	end for

	if sequence( replace ) then
		replace = 0
		for i = 1 to length( field ) do
			if field[i][1] = 1 then
				replace = 1
			end if
		end for
	end if
	
	ok = get_record( "", "TABLEDEF", table_name, "INFO.DATATYPES","")
	if atom(ok) then
		restore_current()
		return ok
	end if
	datatypes = ok[1]
	
	ok = get_record( "", "TABLEDEF", table_name, "INFO.INDICES","")
	if atom(ok) then
		restore_current()
		return ok
	end if
	ix = ok[1]
	
	ok = select_table( table_name )
	
	for i = 1 to length( data ) do
		if datatypes[find(field[i],ix)] = EUSQL_AUTONUMBER then
			restore_current()
			extended_error = "Cannot update field of type AUTONUMBER"
			return EUSQL_FAIL
		end if
		if not type_check( data[i], datatypes[find(field[i], ix)]) then
			restore_current()
			extended_error = "Data type mismatch.\nData = " &
				pretty_source(data[i]) &
				sprintf("\nexpected %s", {EUSQL_WORDS[datatypes[find(field[i], ix)]]})
			return EUSQL_FAIL
		end if
	end for
	

	record = { key } & db_record_data( recnum )
	old_data = record
	
	record = map_field(  record , { data }, field )
	
	if replace then
		
		ok = db_insert( record[1], record[2..length( record )] )
		
		if ok = DB_OK then
			
			recnum = db_find_key( key )
			db_delete_record( recnum )
		
		else
			restore_current()
			extended_error = "Couldn't update record"
			return EUSQL_FAIL
			
		end if
	else
		
		db_replace_data( recnum, record[2..length(record)] )
	end if

	-- need to update key / don't need to update key
	-- field didn't change
	-- field changed
	-- 4 cases

	-- field changed, need to update key: 
	--      remove key from old slot (possibly delete slot), add to new
	-- field changed, don't need to update key: 
	--      remove key from old slot (possibly delete slot), add to new
	-- field didn't change, need to update key: 
	--      just update the key in the index
	-- field didn't change, don't need to update key: 
	--      no action required

	if update_index then
		ok = db_select_table( "INDEXDEF" )
		for i = 1 to length( index_exists ) do
			-- did field change?

			if sequence( index_exists[i] ) then
				field_num = find(ix[i], field)
				if field_num then
					field_changed = 1
				else
					field_changed = 0
				end if

				-- load the index
				if field_changed or replace then
					recnum = db_find_key( index_exists[i] )
					index_as_record = db_record_data( recnum )
					the_index = index_as_record[2]
				end if

				-- update the index
				if field_changed then
					-- ax should never be 0! (index alist keys are always wrapped in an extra sequence)
					ax = find( {seq_fetch(old_data, field[field_num])}, the_index[1] )

					-- delete from old...
					if ax and length( the_index[2][ax] ) = 1 then
						-- this was the only one...remove it
						kx = length(the_index[1])
						the_index[1] = the_index[1][1..ax-1] & the_index[1][ax+1..kx]
						the_index[2] = the_index[2][1..ax-1] & the_index[2][ax+1..kx]
					else
						kx = find( old_data[1], the_index[2][ax] )
						the_index[2][ax] = the_index[2][ax][1..kx-1] & 
							the_index[2][ax][kx+1..length(the_index[2][ax])]
					end if
					
					-- and add to the new...
					ax = find( {seq_fetch(record, field[field_num])}, the_index[1] )
					if not ax then
						the_index = h:insert( the_index, {seq_fetch( record, field[field_num])}, {record[1]} )
					else
						the_index[2][ax] = sort( append( the_index[2][ax], record[1] ) )
					end if
				elsif replace then
					if field_num then
						ax = find( seq_fetch( record, field[field_num]), the_index[1] )
						kx = find( old_data[1], the_index[2][ax] )
					else
						-- this will happen if the field that's indexed isn't changed, but the
						-- key changes, so we have to update that side of things
						-- this seems like a slow way to do this.  could probably get the
						-- old indexed value from old_data, but too lazy right now...
						ax = 1
						kx = find( old_data[1], the_index[2][ax] )
						while not kx and ax < length(the_index[2]) do
							ax += 1
							kx = find( old_data[1], the_index[2][ax] )
						end while
					end if
					if kx then
						the_index[2][ax][kx] = record[1]
						the_index[2][ax] = sort(the_index[2][ax])						
					end if
				end if

				if field_changed or replace then
					index_as_record[2] = the_index
					db_replace_data( recnum, index_as_record )
				end if

			end if
		end for
	end if

	restore_current()
	return {}
end function

--/topic Data
--/func update_record( sequence db_name, sequence table_name, object key, sequence index, sequence data )
--/info
--Update a record.  'key' specifies which record is to be updated.  'index' specifies the
--field indices to update, and data is a sequence of field values to update.

global function update_record( sequence db_name, sequence table_name, 
		object key, sequence field, sequence data )
	
	sequence structure
	object ok
	
	save_current()
	
	if length( db_name ) then
		ok = select_db( db_name )
		if atom( ok ) then
			restore_current()
			return ok
		end if
	end if
	
	
	-- need to convert field names to indices
	ok = select_table( "TABLEDEF" )
	if atom( ok ) then
		restore_current()
		return ok
	end if
	
	ok = db_find_key( table_name )
	if ok < 0 then
		restore_current()
		extended_error = "No field structure defined for Table:\'" 
			& table_name & "\'"
		return EUSQL_FAIL
	end if
	
	structure = get_record_struct( db_name, table_name ) -- db_record_data( ok )
	
	for i = 1 to length( field ) do
		if atom(field[i][1]) then
			field[i] = tokenize(field[i], '.')
		end if		  
		ok = validate_field( field[i], structure )
		if atom(ok) then
			restore_current()
			extended_error = "Invalid field: \'" & euslib:pretty_sprint(field[i]) & "\'"
			return ok
		end if
		
		field[i] = ok
		
	end for
	
	restore_current()
	return update_record2( db_name, table_name, key, field, data, {} )
end function


function run_update( sequence sql )
	object ok
	sequence title, data, key, rec, replace_record, blank, retval, index, dt
	integer ix, recnum

	-- get the data
	ok = run_select( sql )
	if atom(ok) then
		return ok
	end if
	

	title = ok[1] & { "Status" }
	data = ok[2]
	dt = ok[3]
	retval = {}
	index = sql[QN_VALUES][3]
	-- which field is the key?

	key = repeat( {}, length( sql[QN_TABLE] ) )

	for i = 1 to length( sql[QN_TABLE] ) do
		ix = find( {1}, sql[QN_INDICES][i] )
		
		if ix then
			key[i] = sql[QN_ORDER][i][ix]
			if key[i] < 0 then
				ix += find( {1}, sql[QN_INDICES][i][ix+1..length(sql[QN_INDICES][i])])
				if not ix then
					key[i] = {}
				else
					key[i] = sql[QN_ORDER][i][ix]
				end if
			end if
		end if
		
	end for

	-- if any part of the key is being updated, we'll need to 
	-- delete and re-insert the record
	replace_record = repeat( 0, length( key ) )
	for i = 1 to length( replace_record ) do
		if sql[QN_TABLE][i][1] > 0 then
			
			for j = 1 to length( sql[QN_VALUES][3][i] ) do
				
				rec = sql[QN_VALUES][3][i][j]
				
				if rec[1] = 1 then
					replace_record[i] = 1
				end if
			end for
		end if
	end for
	
	data = repeat( data, 2 )
	
	-- cycle through each table to be updated
	for i = 1 to length( key ) do
		if atom(key[i]) and sql[QN_TABLE][i][1] > 1 then

			ok = select_table( sql[QN_TABLE][i] )
			
			if atom(ok) then
				return ok
			end if

			index = { sql[QN_VALUES][3][i], sql[QN_VALUES][4][i] }

			-- cycle through each record to be updated
			for j = 1 to length( data[1] ) do

				-- put the data into order for update_record2()
				rec = repeat( {}, length( index[1] ) )
				for l = 1 to length( index[1] ) do

					rec[l] = data[1][j][index[2][l]]
					
				end for
				
				-- update the record
				ok = update_record2( "", sql[QN_TABLE][i], 
					data[1][j][key[i]], index[1], rec, replace_record[i] )
					
				if atom(ok) then
				
					retval &= {{ data[1][j][key[i]], "Error: " & extended_error }}
						
				else
				
					retval &= {{ data[1][j][key[i]], "OK" }}
						
				end if
				
			end for
			
		end if
		
	end for
	
	return { { "Key", "Status" }, retval, dt }
end function

--/topic Data
--/func insert_record( sequence db_name, sequence table_name, object record_obj, sequence data, sequence field_index )
--/info
--Inserts a record into specified table.  
--<ul>
--/li /b db_name
--/li /b table_name
--/li /b record_obj tells insert_record() what the structure of the record is.  
--You can call /blank_record() to generate the record yourself.  This is recommended
--if you will be calling insert_record() multiple times.  If /b record_obj is an
--atom, insert_record() will call blank_record() for you.
--/li /b data is a sequence of field values
--/li /b index is a sequence of field indices, or the equivalent subscript that would be 
--used if the record were a sequence.
--<ul>
--If the structure of the table were:
--<ul>
--/li ID
--/li NAME.FIRST
--/li NAME.LAST
--/li EMAIL
--</ul>
--Then the record as a sequence would be:
--
-- { ID, { NAME.FIRST, NAME.LAST }, EMAIL }
--
--So the corresponding indices would be:
--<table border=1>
--<tr><td>Field</td><td>Index</td></tr>
--<tr><td>ID</td><td>{1}</td></tr>
--<tr><td>NAME</td><td>{2}</TD></TR>
--<TR><TD>NAME.FIRST</TD><TD>{2,1}</TD></TR>
--<TR><TD>NAME.LAST</TD><TD>{2,2}</TD></TR>
--<TR><TD>EMAIL</TD><TD>{3}</TD></TR>
--</table>
--</ul>
--</ul>


global function insert_record( sequence db_name, sequence table_name,
		object record_obj, sequence data, sequence field_index )
	
	object ok
	sequence datatypes, ix, list, mapped, auto, auto_data, auto_fi, record
	integer jx, kx
	object indexdef
	
	if length(data) != length(field_index) then
		extended_error = sprintf( "trying to insert %d values into %d fields",
			{length(data), length(field_index)})
		return EUSQL_FAIL
	end if
	
	save_current()
	
	table_name = upper( table_name )
	ok = select_current( db_name, table_name )
	if atom( ok ) then
		return ok
	end if
	
	ok = get_record( "", "TABLEDEF", table_name, "INFO.DATATYPES","")
	if atom(ok) then
		return ok
	end if
	datatypes = ok[1]

	ok = get_record( "", "TABLEDEF", table_name, "AUTOINCREMENT","")
	if atom(ok) then
		return ok
	end if
	auto = ok[1]	
	

	
	ok = get_record( "", "TABLEDEF", table_name, "INFO.INDICES","")
	if atom(ok) then
		return ok
	end if
	ix = ok[1]
	
	auto_data = ""
	auto_fi = ""
	for i = 1 to length(auto) do
		if datatypes[i] = EUSQL_AUTONUMBER then
			auto[i] += 1
			auto_data &= auto[i]
			auto_fi &= { ix[i] }
		end if
	end for
	
	if atom( record_obj ) then
		record = blank_record( db_name, table_name )
	else
		record = record_obj
	end if

	mapped = map_field( record, {data & auto_data}, field_index & auto_fi )
	
	ok = get_record( "", "TABLEDEF", table_name, "INDEXED", "" )
	if atom(ok) then
		restore_current()
		return ok
	end if
	indexdef = ok[1]
	
	ok = select_table( table_name )
	
	for i = 1 to length( data ) do
		jx = find( field_index[i], ix )
		
		if datatypes[jx] = EUSQL_AUTONUMBER then
			extended_error = "Cannot set the value of a field of type AUTONUMBER"
			restore_current()
			return EUSQL_FAIL
		end if
		
		if not type_check( data[i], datatypes[jx]) then
			extended_error = "Data type mismatch" 
			extended_error &= "\n" & sprint(i) & ": " & sprint(data[i])
			restore_current()
			return EUSQL_FAIL
		end if
		
		-- check for index on field
		if sequence(indexdef[jx])  then 
			list = get_record( "", "INDEXDEF", indexdef[jx], "LIST" ,"")
			list = list[1]
			kx = h:index( list, {data[i]} )
			
			  
			if kx then
				list = h:set_list( list, {data[i]}, sort(list[2][kx] & {mapped[1]}))
			else
				list = h:insert( list, {data[i]}, {mapped[1]} )
			end if

			ok = update_record2( "", "INDEXDEF", indexdef[jx], { {3} },
				{ list }, 0 )
			
		end if
	end for
	
	
	
	ok = db_insert( mapped[1], mapped[2..length(mapped)] )
	
	if ok != DB_OK then
		restore_current()
		if ok = DB_EXISTS_ALREADY then
			extended_error = "Duplicate primary key"
		else
			extended_error = "Could not insert record"
		end if

		return EUSQL_FAIL
	end if

	if length(auto_data) then
		-- need to update TABLEDEF
		ok = update_record2(db_name,"TABLEDEF",table_name,{{5}},{ auto }, 0 )
	end if
	
	restore_current()
	return {}
end function

--/topic Data
--/func insert_record2( sequence db_name, sequence table_name, object blank_record, sequence data, sequence index )
--/info
--insert_record2() is for inserting multiple records at a time.  It is much faster to do bulk 
--inserts this way than using insert_record() or multiple INSERT statements.  
--<ul>
--/li /b db_name
--/li /b table_name
--/li /b blank_record tells insert_record() what the structure of the record is.  
--You can call /blank_record() to generate the record yourself.  This is recommended
--if you will be calling insert_record() multiple times.  If /b blank_record is an
--atom, insert_record() will call blank_record() for you.
--/li /b data is a sequence of field values, where each top level element of /b data
--is a sequence of field values for each record that is to be inserted.
--/code
--   data = { { "Joe", 1, 6 },
--            { "Bob", 4, 2 },
--            ...etc...
--          }
--/endcode
--/li /b index is a sequence of field indices, or the equivalent subscript that would be 
--used if the record were a sequence.
--<ul>
--If the structure of the table were:
--<ul>
--/li ID
--/li NAME.FIRST
--/li NAME.LAST
--/li EMAIL
--</ul>
--Then the record as a sequence would be:
--
-- { ID, { NAME.FIRST, NAME.LAST }, EMAIL }
--
--So the corresponding indices would be:
--<table border=1>
--<tr><td>Field</td><td>Index</td></tr>
--<tr><td>ID</td><td>{1}</td></tr>
--<tr><td>NAME</td><td>{2}</TD></TR>
--<TR><TD>NAME.FIRST</TD><TD>{2,1}</TD></TR>
--<TR><TD>NAME.LAST</TD><TD>{2,2}</TD></TR>
--<TR><TD>EMAIL</TD><TD>{3}</TD></TR>
--</table>
--</ul>
--</ul>
--/code
--ex:
--EUSQLRESULT ok, void
---- suppose that MY_TABLE and YOUR_TABLE are in myDB.edb and yourDB.edb
---- both contain 2 fields: ID and NAME
---- and we'd like to copy all the records from MY_TABLE to YOUR_TABLE
--
---- get all the records from MY_TABLE
--void = open_db("myDB.edb")
--ok = run_sql("SELECT * FROM MY_TABLE")
--
---- now insert them into YOUR_TABLE
--void = open_db("yourDB.edb")
--ok = insert_record2( "myDB.edb", "YOUR_TABLE", blank_record("myDB.edb","YOUR_TABLE"),
--     ok[2], { {1}, {2} })
--/endcode
--insert_record2() now always returs a sequence containing the status for each
--of the records to be inserted.  Each status indicator will be a two-element
--sequence.  The first element will be a sequence if insertion worked, or 
--an atom if insertion failed.  If it failed, the second element will be
--a full error description as returned by get_sql_err().

global function insert_record2( sequence db_name, sequence table_name,
		object record_obj, sequence data, sequence field_index )
	
	object ok
	sequence datatypes, ix, list, mapped, auto, ax, autodata, autofi, results, record,
		index_list
	integer jx, kx
	object indexdef
	
	save_current()
	
	table_name = upper( table_name )
	ok = select_current( db_name, table_name )
	if atom( ok ) then
		return ok
	end if
	
	ok = get_record( "", "TABLEDEF", table_name, "INFO.DATATYPES","")
	if atom(ok) then
		return ok
	end if
	datatypes = ok[1]

	ok = get_record( "", "TABLEDEF", table_name, "AUTOINCREMENT","")
	if atom(ok) then
		return ok
	end if
	auto = ok[1]		
	
	ok = get_record( "", "TABLEDEF", table_name, "INFO.INDICES","")
	if atom(ok) then
		return ok
	end if
	ix = ok[1]

	ax = ""
	autofi = ""
	for i = 1 to length(auto) do
		if datatypes[i] = EUSQL_AUTONUMBER then
			ax &= i
			autofi &= {ix[i]}
		end if
	end for
	autodata = repeat( 0, length(ax))	 
	
	ok = get_record( "", "TABLEDEF", table_name, "INDEXED", "" )
	if atom(ok) then
		restore_current()
		return ok
	end if
	indexdef = ok[1]
	index_list = indexdef
	for i = 1 to length(index_list) do
		if sequence(index_list[i]) then
			index_list[i] = get_record( "", "INDEXDEF", indexdef[i], "LIST" ,"")
			index_list[i] = index_list[i][1]
		end if
	end for
	
	if atom( record_obj ) then
		record = blank_record( db_name, table_name )
	else
		record = record_obj
	end if

	results = repeat( {}, length(data) )
	
	ok = select_table( table_name )
	-- iterate through each record:
	for i = 1 to length( data ) do
	
		for k = 1 to length(ax) do
			auto[ax[k]] += 1
			autodata[k] = auto[ax[k]]
		end for
		mapped = map_field( record, {data[i] & autodata}, field_index & autofi )
		
		-- go through each field:
		for j = 1 to length( field_index ) do
			jx = find( field_index[j], ix )
		
			if datatypes[jx] = EUSQL_AUTONUMBER then
				if length(ax) then
					-- need to update TABLEDEF
					ok = update_record2(db_name,"TABLEDEF",table_name,{{5}},{ auto-1 }, 0 )
				end if
				results[i] = { EUSQL_FAIL, get_sql_err(EUSQL_FAIL) & ": Cannot set the value of a field of type AUTONUMBER" }


			elsif not type_check( data[i][j], datatypes[jx]) then
				if length(ax) then
					-- need to update TABLEDEF
					ok = update_record2(db_name,"TABLEDEF",table_name,{{5}},{ auto-1 }, 0 )
				end if
				extended_error = "Data type mismatch" 
				extended_error &= "\n Record #" & sprint(i) & ", Element #" & sprint(j) & 
					": \nShould be " & EUSQL_WORDS[datatypes[jx]] & "\n" & 
					sprint(data[i][j])
				results[i] = { EUSQL_FAIL, get_sql_err(EUSQL_FAIL) }
				
			end if
		end for
		
		if not length(results[i]) then
			ok = db_insert( mapped[1], mapped[2..length(mapped)] )


			if ok != DB_OK then
				if length(ax) then
					-- need to update TABLEDEF
					ok = update_record2(db_name,"TABLEDEF",table_name,{{5}},{ auto-1 }, 0 )
				end if	  
				extended_error = "Could not insert record"
				results[i] = { EUSQL_FAIL, get_sql_err( EUSQL_FAIL ) }


			else
				results[i] = { "OK", i }

				-- check for index on fields
--				for j = 1 to length(indexdef) do
				for j = 1 to length( field_index ) do

					jx = find( field_index[j], ix )
					if sequence(indexdef[jx])  then 
						--list = get_record( "", "INDEXDEF", indexdef[jx], "LIST" ,"")
						kx = h:index( index_list[jx], data[i][j] )			
						
						if kx then
							index_list[jx] = h:set_list( index_list[jx], {data[i][j]}, sort(index_list[jx][2][kx] & {mapped[1]}))
						else
							index_list[jx] = h:insert( index_list[jx], {data[i][j]}, {mapped[1]} )
						end if
					end if
				end for
								
			end if
		end if
		
	end for
	
	for i = 1 to length(index_list) do
		if sequence(index_list[i]) then
			ok = update_record2( "", "INDEXDEF", indexdef[i], { {3} }, {index_list[i]}, 0 )
		end if
	end for
	

	if length(ax) then
		-- need to update TABLEDEF
		ok = update_record2(db_name,"TABLEDEF",table_name,{{5}},{ auto }, 0 )
	end if
	
	restore_current()
	return results
end function

function insert_field( sequence struct, sequence field, integer datatype )
	object ok
	sequence datatypes, new_struct, index, fld_index, new_ix
	
	new_struct = struct
	index = {}
	fld_index = {}
	new_ix = {}
	
	if atom(field[1]) then
		field = tokenize(field, '.')
	end if
	
	datatypes = {{},{}}
	
	for i = 1 to length( field ) do
		
		for j = 1 to length( struct ) do
			if equal( struct[j][1], field[i] ) then
				index &= {j,2}
				fld_index &= j
				struct = struct[j][2]
				exit				 
			end if
		end for
		
		-- new field
		if length(index) < i*2 then
			index &= length( struct ) + 1
			fld_index &= length( struct ) + 1
			
			new_struct = seq_store( { field[i], {} }, new_struct, index )
			struct = { {field[i], {}} }
			new_ix &= { fld_index }
			
			index &= {2,-1}
			
			-- update datatypes
			if i < length(field) then
			-- we have more subfields...
			
				datatypes = h:insert( datatypes, fld_index[1..i], EUSQL_EU_SEQUENCE )  
				
				for k = i+1 to length(field) do
					
					new_struct = seq_store( {field[k],{}}, new_struct, index )
					new_ix &= { fld_index }
					
					index[length(index)] = length( seq_fetch( new_struct, index[1..length(index)-1] ) )
					
					index &= {2,-1}
					fld_index &= 1
					if k < length(field) then
					-- has more subfields
						datatypes = h:insert( datatypes, fld_index, 
											EUSQL_EU_SEQUENCE )
					else
					-- final subfield
						datatypes = h:insert( datatypes, fld_index, 
											datatype )
					end if
				end for
				return { new_struct, datatypes, new_ix }
			else
				datatypes = h:insert( datatypes, fld_index, datatype )
			end if
			
		end if
	end for
	if not length( new_ix ) then
		extended_error = sprintf("Duplicate field: '%s'", {join(field,'.')})
				return EUSQL_ERR_FIELD
	end if
	return { new_struct, datatypes, new_ix }
	
end function

--/topic DB Management
--/func rename_table( sequence db_name, sequence table_name, sequence new_name )
--
--Renames the table /i table_name to /i new_name and updates TABLEDEF and INDEXDEF
--with the new name.
global function rename_table( sequence db_name, sequence table_name, sequence new_name )
	object ok
	integer recnum
	sequence index, record

	new_name = upper( new_name )
	table_name = upper( table_name )
	if find( 32, new_name ) then
		extended_error = "Table names cannot contain spaces"
		return EUSQL_ERR_TABLE
	end if

	ok = select_current( db_name, table_name )
	if atom(ok) then
		return ok
	end if

	ok = select_current( db_name, new_name )
	if sequence(ok) then
		extended_error = new_name & " already exists"
		return EUSQL_ERR_TABLE
	end if

	-- rename the table
	db_rename_table( table_name, new_name )
	
	-- update TABLEDEF
	ok = db_select_table( "TABLEDEF" )
	recnum = db_find_key( table_name )
	if recnum < 1 then
		extended_error = "TABLEDEF is corrupted.  Cannot find " & table_name
		return EUSQL_FAIL
	end if
	record = db_record_data( recnum )
	db_delete_record( recnum )
	ok = db_insert( new_name, record )
	index = record[3]

	-- update INDEXDEF
	ok = db_select_table("INDEXDEF")
	for i = 1 to length( index ) do
		if sequence(index[i]) then
			recnum = db_find_key( index[i] )
			if recnum < 0 then
				extended_error = "INDEXDEF is corrupted.  Cannot find " & index[i]
				return EUSQL_FAIL
			end if
			record = db_record_data( recnum )
			record[1][1] = new_name
			db_replace_data( recnum, record )
		end if
	end for

	return new_name
end function

--/topic DB Management
--/func create_field( sequence db_name, sequence table_name, sequence field_name, integer datatype, integer build_index )
--/info
--You do not have to create a field before you can create a subfield.  EuSQL will automatically
--create a parent field for a subfield if it doesn't exist.  
--
--See /Datatypes for more information on available datatypes in eusql.
--
--build_index should be 1 if you wish to create an index (you cannot create an index for the
--primary key, although you can for subfields of a primary key), or 0 if not.

global function create_field( sequence db_name, sequence table_name,
		sequence field_name, integer datatype, integer build_index )
	object ok, data, new
	atom recnum
	integer ix
	sequence record, update, field, curtok, index, keys, datatypes,
		indexdef, auto

	save_current()
	ok = select_current( db_name, table_name )
	if atom(ok) then
		restore_current()
		return ok
	end if

	ok = select_table( "TABLEDEF" )
	if atom(ok) then
		restore_current()
		return ok
	end if
	
	table_name = upper(table_name)
	ok = get_record( db_name, "TABLEDEF", table_name, "", {2} )
	if atom(ok) then
		puts(1,"\nget_record('" & db_name & "','TABLEDEF','" & table_name & "','',{2}) FAILED!")
		restore_current()
		return ok
	end if
	
	record = ok[1]
	update = record
	
	ok = get_record( db_name, "TABLEDEF", table_name, "", {3} )
	
	if atom(ok) then
		restore_current()
		return ok
	end if
	-- datatypes[1] = info.indices
	-- datatypes[2] = info.datatypes
	datatypes = ok[1]

	ok = get_record( db_name, "TABLEDEF", table_name, "INDEXED", {} )
	if atom( ok ) then
		restore_current()
		extended_error = "Error accessing index cross reference"
		return ok
	end if
	indexdef = ok[1]

	ok = get_record( db_name, "TABLEDEF", table_name, "AUTOINCREMENT", {} )
	if atom( ok ) then
		restore_current()
		extended_error = "Error accessing AUTONUMBER reference"
		return ok
	end if
	auto = ok[1] & 0
	
	-- need to insert into tabledef
	field = tokenize( upper(field_name), '.' )
	
	
	ok = insert_field( record, field, datatype )
	if atom(ok) then
		restore_current()
		return ok
	end if
	index = ok[3][1]
	datatypes = h:merge( datatypes, ok[2])
	
	-- put indexed info into place
	for i = 1 to length(ok[3]) do
		ix = find( ok[3][i], datatypes[1] )
		indexdef = indexdef[1..ix-1] & 0 & indexdef[ix..length(indexdef)]
	end for
	
	ok = update_record2( "", "TABLEDEF", table_name, { {2}, {3,1}, {3,2},{4},{5} },
			{ ok[1], datatypes[1], datatypes[2], indexdef, auto }, 0 )
	
	if atom(ok) then
		restore_current()
		return ok
	end if

	
	-- need to update records
	ok = select_table( table_name )
	if atom(ok) then
		restore_current()
		return ok
	end if

  
	ix = db_table_size()
	keys = {}
	for i = 1 to ix do
		keys &= { db_record_key( i ) }
	end for
	
	extended_error = {}

	new = {}
	for i = 1 to length(keys) do
		-- first grab the full record
		if datatype = EUSQL_AUTONUMBER then
			new = i
		end if
		data = seq_store( new, {keys[i]} & db_record_data( i ), index )
		if index[1] = 1 then
			-- changed the key
			db_delete_record( i )
			ok = db_insert( data[1], data[2..$] )
			
		else
			db_replace_data( i, data[2..$] )
			
		end if
	end for
	
	if length(keys) and index[1] = 1 then

	end if
	
	restore_current()
	if length( extended_error ) then
		return EUSQL_ERR_FIELD
	end if
	
	return {}
end function

--/topic DB Management
--/func rename_field( sequence db_name, sequence table_name, sequence old_name, sequence new_name )
--/info
--Rename a field.
global function rename_field( sequence db_name, sequence table_name, sequence old_name, sequence new_name )

	return {}
end function

--/topic DB Management
--/func drop_field( sequence db_name, sequence table_name, sequence field_name, integer break_on_error )
--/info
--Deletes a field and any index associated with the field.  If you delete the primary key, then the next
--field in the record will become the primary key.  If the key changes (by dropping the primary key or a
--subfield of the primary key), some keys may not be unique.  If you do not want to lose any data, set
--/b break_on_error to 0, and the table will not be changed.  
global function drop_field( sequence db_name, sequence table_name, sequence field_name, integer break_on_error )
	sequence index_to_delete, index, record, tabledef, struct, removes, keys, new
	integer fx, reindex, tx
	object ok
	
	field_name = upper(field_name)
	table_name = upper(table_name)
	ok = select_current( db_name, table_name )
	if atom( ok ) then
		return ok
	end if
	
	-- not allowed to modify TABLEDEF or INDEXDEF!
	if not length(field_name) or find( table_name, {"TABLEDEF", "INDEXDEF"}) then
		return EUSQL_FAIL
	end if
	
	ok = validate_field2( db_name, table_name, field_name  )
	if atom( ok ) then
		return ok
	end if
	index = ok
	
	-- get the index and the TABLEDEF order for each field
	ok = select_table( "TABLEDEF" )
	ok = db_find_key( table_name )
	if ok <= 0 then
		extended_error = "Table '" & pretty_source( table_name ) & "' not found in TABLEDEF"
		return EUSQL_ERR_TABLE
	end if
	tx = ok
	tabledef = db_record_data( tx )

	-- update TABLEDEF


	-- update the records themselves
	ok = select_table( table_name )
	if index[1] = 1 then
		-- dropping the PK or a subfield of the PK
		record = {}
		for i = 1 to db_table_size() do
			record = append( record, prepend( db_record_data(1), db_record_key(1) ))
			db_delete_record( 1 )
		end for	
		
		-- make sure that there's something to put back...
		if length(record) and length(seq_remove(record[1], index)) then
			for i = 1 to length(record) do
				new = seq_remove( record[i], index )
				ok = db_insert( new[1], new[2..$] )
				
				-- only rollback the data if there was an error:
				if break_on_error and ok != DB_OK then
					-- duplicate key found!
					for j = 1 to db_table_size() do
						db_delete_record(1)
					end for
					
					for j = 1 to length(record) do
						ok = db_insert( record[j][1], record[j][2..$] )
					end for
					
					extended_error = "Duplicate key found: '" & pretty_source( new[1] ) & "'"
					return EUSQL_FAIL
					
				end if
			end for			
		end if

		-- have to reindex...
		ok = call_func( forward_reindex_table, { db_name, table_name })
	else
		for i = 1 to db_table_size() do
			record = prepend( db_record_data(i), db_record_key(i) )
			record = seq_remove( record, index )
			db_replace_data( i, record[2..$] )
		end for		
	end if

	-- first, remove it from the record struct...
	struct = {index[1]}
	for i = 2 to length(index) do
		struct &= 2
		struct &= index[i]
	end for
	removes = {}
	tabledef[1] = seq_remove( tabledef[1], struct )

	fx = find( index, tabledef[2][1] )

	-- this will also remove any subfields that were there...	
	while fx < length(tabledef[3]) and match( index, tabledef[2][1][fx] ) do
		tabledef[2][1] = tabledef[2][1][1..fx-1] & tabledef[2][1][fx+1..$]
		tabledef[2][2] = tabledef[2][2][1..fx-1] & tabledef[2][2][fx+1..$]
		
		if sequence( tabledef[3][fx] ) then
			-- have to delete an index...
			ok = select_table( "INDEXDEF" )
			ok = db_find_key( tabledef[3][fx] )
			if ok > 0 then
				db_delete_record( ok )
			end if
		end if
		tabledef[3] = tabledef[3][1..fx-1] & tabledef[3][fx+1..$]
		tabledef[4] = tabledef[4][1..fx-1] & tabledef[4][fx+1..$]
	end while

	ok = select_table( "TABLEDEF" )
	db_replace_data( tx, tabledef )

	return {}
end function

--/topic DB Management
--/func drop_table( sequence db_name, sequence table_name )
--/info
--Deletes a table and cleans up system tables to remove dropped table.
global function drop_table( sequence db_name, sequence table_name )
	object ok
	sequence t_list, index
	
	if length(db_name) then
		ok = select_db( db_name )
		if atom(ok) then
			return ok
		end if	
	end if
	
	table_name = upper( table_name )
	if find(table_name, SYSTEM_TABLES ) then
		extended_error = "Cannot drop system tables."
		return EUSQL_ERR_TABLE
	end if
	
	t_list = db_table_list()
	t_list = { t_list, upper(t_list) }
	
	ok = find( table_name, t_list[2] )
	if not ok then
		extended_error = "Could not delete table '" & table_name & "'.  " &
						 "Table does not exist."
		return EUSQL_ERR_TABLE
	end if
	
	-- delete any index on this table...
	ok = get_record_mult_fields( db_name, "TABLEDEF", table_name, {"INDEXED"}, {})
	if atom(ok) then
		extended_error = "Error updating INDEXDEF"
		return ok
	end if
	index = ok[1]
	ok = db_select_table("INDEXDEF")
	for i = 1 to length(index) do
		if sequence(index[i]) then
			ok = db_find_key( index[i] )
			if ok > 0 then
				db_delete_record( ok )
			end if
		end if
	end for

	ok = db_select_table( "TABLEDEF" )
	db_delete_table( table_name )
	ok = delete_record( "", "TABLEDEF", table_name )
	
	if atom(ok) then
		return ok
	end if
	
	return {}
	
end function

--/topic DB Management
--/func drop_index( sequence db_name, sequence index_name )
--/info
--Deletes an index and cleans up system tables.
global function drop_index( sequence db_name, sequence index_name )
	integer rec, max_rec, tx
	object ok
	sequence indexed

	ok = delete_record( db_name, "INDEXDEF", index_name )
	if atom(ok) then
		return ok
	end if
	
	-- find the table to which the index belongs
	rec = 1
	ok = select_table( "TABLEDEF" )
	max_rec = db_table_size()
	tx = 0
	while rec <= max_rec do
		indexed = db_record_data( rec )
		tx = find( index_name, indexed[3] )
		if tx then
			indexed[3][tx] = 0
			db_replace_data( rec, indexed )
			return {}
		end if
		rec += 1
	end while
end function

function reindex_(sequence db_name, sequence table_name, sequence ix_name, sequence struct,
	sequence field)
	sequence the_index, record, field_index
	object ok, key, data
	atom list, ix_key

	ok = select_table( "INDEXDEF" )
	ix_key = db_find_key( ix_name )
	if ix_key < 0 then
		extended_error = "Index must exist before reindexing"
		return EUSQL_FAIL
	end if
	record = db_record_data(ix_key)

	--struct = get_record_struct( "", table_name )
	field_index = validate_field( tokenize( record[1][2], '.' ), struct )
	the_index = { {}, {} }
	ok = select_table( table_name )
	for i = 1 to db_table_size() do
		key = db_record_key( i )
		
		data = {seq_fetch( {key} & db_record_data( i ), field_index )}

		list = h:index( the_index, data ) 
		if not list then
			the_index = h:insert( the_index, data, {key} )
		else
			the_index[2][list] = append(the_index[2][list], key )
		end if
			
	end for

	for i = 1 to length( the_index[2] ) do
		the_index[2][i] = sort( the_index[2][i] )
	end for

	record[2] = the_index
	ok = select_table( "INDEXDEF" )
	db_replace_data(ix_key, record)

	return {}

end function

--/topic DB Management, Data
--/func reindex(sequence db_name, sequence table_name, sequence ix_name)
--/info
--Rebuilds the specified index.
global function reindex(sequence db_name, sequence table_name, sequence ix_name)
	object ok
	sequence struct, field
	save_current()
	ix_name = upper(ix_name)
	struct = get_record_struct( db_name, table_name )
	ok = get_record("","INDEXDEF", ix_name,"IX.FIELD" , {})
	if atom(ok) then
		restore_current()
		return ok
	end if
	field = ok
	ok = reindex_(db_name, table_name, ix_name, struct, field[1])
	restore_current()
	return ok
end function

--/topic DB Management, Data
--/func reindex_table( sequence db_name, sequence table_name )
--
--Rebuilds all indices for the specified table.
global function reindex_table( sequence db_name, sequence table_name )
	object ok
	sequence index
	ok = ""
	
	-- get the list of indices for the table...
	index = ""
	
	-- now call reindex on them
	for i = 1 to length(index) do
		ok = reindex( db_name, table_name, index[i] )
		if atom(ok) then
			return ok
		end if
	end for
	
	return ok
end function
forward_reindex_table = routine_id("reindex_table")
--/topic DB Management
--/func create_index( sequence db_name, sequence table_name, sequence ix_name, sequence field, integer unique )
--/info
--Creates an index (stored in INDEXDEF) on a field in a table.  Each index must have a unique
--name (ix_name).  It is recommended that you create an index on any field that is likely
--to be used as a foreign key, as this will speed up queries.  The primary key itself may 
--not be indexed, however, subfields of the primary key may be indexed.
global function create_index( sequence db_name, sequence table_name, 
		sequence ix_name, sequence field, integer unique )
		
	object ok, key, data, list
	integer ix
	sequence struct, indices, indexdef, the_index

	save_current()
	table_name = upper( table_name )
	
	ok = select_current( db_name, table_name )
	-- make sure db/table exist
	if atom(ok) then
		restore_current()
		return ok
	end if
 	
 	if not length(ix_name) then
 		extended_error = "Missing index name"
 		return EUSQL_FAIL
 	end if
 	
	ix_name = upper( ix_name )
	ok = select_table( "INDEXDEF" )
	key = db_find_key( ix_name )
	if key > 0 then
		restore_current()
		extended_error = sprintf("INDEX name: \'%s\'", {ix_name})
		return EUSQL_ERR_INDEXEXISTS
	end if
	
	-- get field index: validate field exists and no index 
	-- on field already exists and reference index in TABLEDEF
 
	ok = get_record( "", "TABLEDEF", table_name, "INFO.INDICES", {} )
	if atom(ok) then
		restore_current()
		return ok
	end if
	indices = ok[1]
												   
	ok = get_record( "", "TABLEDEF", table_name, "INDEXED", {} )
	if atom(ok) then
		restore_current()
		extended_error = "Could not find index information on table " &
			table_name & "."
		return ok
	end if
	--indexdef = {ok[1],unique}
	indexdef = ok[1]
	
	struct = get_record_struct( "", table_name )
 
	ok = validate_field( tokenize(field,'.'), struct )
	if atom(ok) then
		restore_current()
		return ok
	end if
	
	if equal( ok, {1}) then
		extended_error = "Cannot create index for primary key"
		return EUSQL_FAIL
	end if
	
	ix = find( ok, indices )
	
	-- need to see if this field is indexed
	if sequence( indexdef[ix] ) then
		restore_current()
		extended_error = "Field " & field & " is already indexed under " &
			"index " & indexdef[ix]
		return EUSQL_ERR_INDEXEXISTS
	end if
	
	indexdef[ix] = ix_name
	ok = update_record2( "", "TABLEDEF", table_name, { {4} }, { indexdef }, 0)
	
	
	struct = blank_field( get_record_struct( "", "INDEXDEF" ))
	
--CREATE_INDEXDEF = "CREATE TABLE INDEXDEF NAME AS TEXT, IX.TABLE AS TEXT, " &
--    "IX.FIELD AS TEXT, LIST.VALS AS SEQUENCE, LIST.KEYS AS SEQUENCE"
	-- need to build the index...

	ok = insert_record( "", "INDEXDEF", struct, { ix_name, table_name,
		field, {}, {} }, { {1}, {2,1}, {2,2}, {3,1}, {3,2} })
	
	ok = reindex( db_name, table_name, ix_name )

	restore_current()
	return ok
end function

constant
TABLEDEF_STRUCT = 
				{ {
					{"TABLE",{}}, 
					{ "FIELDS", {} },
					{ "INFO", {
								{"INDICES", {}},
								{"DATATYPES", {}}
							   }
					},
					{ "INDEXED", {}},
					{ "AUTOINCREMENT", {}}
				  },
				  { {{1},{2},{3},{3,1},{3,2},{4},{5}},
					{EUSQL_EU_TEXT, EUSQL_EU_SEQUENCE, EUSQL_EU_SEQUENCE, 
					 EUSQL_EU_SEQUENCE, EUSQL_EU_SEQUENCE, EUSQL_EU_SEQUENCE,
					 EUSQL_EU_SEQUENCE}
				  },
				  {0,0,0,0,0,0,0},
				  {0,0,0,0,0,0,0}
				}

--/topic DB Management
--/func create_table( sequence db_name, sequence table_name )
--/info
--Creates a table and generates an entry in TABLEDEF.
global function create_table( sequence db_name, sequence table_name )
	object ok
	sequence record

	table_name = upper(table_name)
	
	ok = select_current( db_name, table_name )
	
	if atom(ok) then
		if ok != EUSQL_ERR_TABLE then
			return ok
		else
			extended_error = ""
		end if
	end if
	
	ok = db_create_table( table_name )
	ok = select_table( "TABLEDEF" )
	
	if atom(ok) then
		
		ok = create_table( "", "TABLEDEF" )
		
		if atom(ok) then
			return ok
		end if
		
		ok = db_insert( "TABLEDEF", TABLEDEF_STRUCT )
	
		if ok != DB_OK then
			extended_error = "Could not create table."
			return EUSQL_ERR_TABLE
		end if
	end if
	
	if not equal(table_name, "TABLEDEF" ) then
		record = blank_field( get_record_struct( "", "TABLEDEF" ) )
		ok = insert_record( "", "TABLEDEF", record, {table_name},{{1}})
		if atom(ok) then
			return ok
		end if
		
	end if
	
	return table_name
end function

function run_insert( sequence sql )
	object data, ok
	sequence blank, table, field, index, title
	integer tx, f_len
	
	table = sql[QN_VALUES][4]
	ok = select_table( table )
	if atom(ok) then
		extended_error = "Could not access table \'" & table & "\'"
		return ok
	end if
	
	-- grab the indices for the data
	tx = find( table, sql[QN_TABLE] )
	
	title = sql[QN_NAMES][tx] & {"Insert Status"}
	f_len = length( title ) - 1
	
	blank = sql[QN_VALUES][3]
	index = sql[QN_VALUES][5]
	
	
	if sql[QN_VALUES][2][1] = EUSQL_VALUES then

		data = sql[QN_VALUES][2][2]
		
		-- convert parameters if need be
		tx = find( EUSQL_FIELD_PARAM, sql[QN_TABLE] )
		if tx then
			field = sql[QN_INDICES][tx]
			
			for i = 1 to length( field ) do
				ok = get_parameter( field[i] )
				if sequence( ok ) and  length( ok ) = 3 
				and equal(ok[1], DATA) then
					field[i] = ok[2]
				else
					field[i] = ok
				end if
			end for
			
			sql[QN_INDICES][tx] = field
			
		end if
		
		-- do the calculated fields...
		tx = find( EUSQL_FIELD_CALC, sql[QN_TABLE] )
		if tx then
			-- evaluate
			for i = 1 to length(sql[QN_INDICES][tx]) do
				 ok = Evaluate( sql[QN_INDICES][tx][i] )
				 if ok[m:FUNC] = DATA then
				 	ok = ok[m:ARG1]
				 elsif ok[m:FUNC] = CONSTANT then
				 	ok = ok[m:ARG1][1]
				 end if
				 sql[QN_INDICES][tx][i] = ok
			end for

		end if
		-- this is so order_to_index() works
		query = sql 
		field = blank
		
		
		for i = 1 to length( data ) do
			-- since these are values, the data is actually stored in 
			-- QN_INDICES:
			data[i] = order_to_index( data[i] )
			if sql[QN_DATATYPES][i] = EUSQL_EU_DATE_TIME and not is_eu_date_time( data[i] ) then
				data[i] = text_to_date_time( data[i] )				
			end if
		end for
		
		ok = insert_record( "", table, field, data, index )
		
		if atom(ok) then
			data &= { get_sql_err(ok) }
		else
			data &= { "OK" }
		end if
		
		data = { data }
		
	else
		ok = run_select( sql[QN_VALUES][2][2] )
		
		if atom(ok) then
			return ok
		end if

		data = ok
		-- convert any date_time values
		for i = 1 to length(data[3]) do
			if data[3][i] = EUSQL_EU_DATE_TIME then
				for j = 1 to length(data[2]) do
					data[2][j][i] = text_to_date_time( data[2][j][i] )
				end for
			end if
		end for
		
		data = ok[2]
		
		ok = select_table( table )
		
		if atom(ok) then
			return ok
		end if
		
		for i = 1 to length( data ) do
			ok = insert_record( "", table, blank, data[i], index )
			
			if atom(ok) then
				data[i] &= {"ERROR"}
			else
				data[i] &= {"OK"}
			end if
			
		end for
	end if
	
	return { title, data, repeat( EUSQL_EU_OBJECT, length(title)) }
end function

-- execute a compiled union query
function run_union( sequence sql )
	sequence title, records
	object ok
	
	ok = run_select( sql )
	if atom(ok) then
		return ok
	end if
	
	title = ok[1]
	records = ok[2]
	
	if sql[QN_VALUES][1] = EUSQL_UNION then
		ok = run_union( sql[QN_VALUES][2] )
		if atom(ok) then
			return ok
		end if
		
		records &= ok[2]
	end if
	
	return { title, records, sql[QN_DATATYPES] }
end function

function run_create_table( sequence sql )
	object ok
	sequence fields, datatypes, indices, table
	
	
	-- need to check for create index
	table = sql[QN_TABLE][1]
	ok = create_table( "", table )
	
	if atom(ok) then
		return ok
	end if
	
	fields = sql[QN_NAMES][1]
	datatypes = sql[QN_ORDER][1]
	indices = sql[QN_INDICES][1]
	
	for i = 1 to length( fields ) do
		ok = create_field( "", table, fields[i], datatypes[i], indices[i] )
		if atom(ok) then
			return ok
		end if
		fields[i] = {fields[i]}
	end for
	
	return {{table}, fields, {EUSQL_EU_OBJECT}}
	
end function

function run_create_index( sequence sql )

	return create_index( "", sql[QN_TABLE][1], sql[QN_INDICES][1][1], sql[QN_NAMES][1][1], 
		sql[QN_VALUES][3] )

end function

integer CREATE_DB
function run_create_database( sequence sql )
	return call_func( CREATE_DB, { sql[QN_TABLE][1] } )
end function

function run_create( sequence sql )
	integer create
	create = sql[QN_VALUES][2]
	if create = EUSQL_TABLE then
		return run_create_table( sql )
		
	elsif create = EUSQL_INDEX then
		return run_create_index( sql )

	elsif create = EUSQL_DATABASE then
		return run_create_database( sql )

	end if
	return EUSQL_FAIL
end function

function run_drop_table( sequence sql )
	sequence name
	object ok
	
	name = sql[QN_TABLE][1]
	ok = drop_table( "", name )
	if atom(ok) then
		return ok
	end if
	
	return {{"Dropped"}, {{name}}, {}}
end function

function run_drop_index( sequence sql )
	sequence name
	object ok
	
	name = sql[QN_INDICES][1][1]
	ok = drop_index( "", name )
	if atom(ok) then
		return ok
	end if
	
	return {{"Dropped"}, {name}, {}}
	
end function

function run_drop( sequence sql )
	if sql[QN_VALUES][2] = EUSQL_TABLE then
		return run_drop_table( sql )
	elsif sql[QN_VALUES][2] = EUSQL_INDEX then
		return run_drop_index( sql )
	end if
	
	extended_error = "Unrecognized DROP query"
	return EUSQL_FAIL
end function

constant
CREATE_INDEXDEF = "CREATE TABLE INDEXDEF NAME AS TEXT, IX.TABLE AS TEXT, " &
	"IX.FIELD AS TEXT, LIST.VALS AS SEQUENCE, LIST.KEYS AS SEQUENCE"

--/topic DB Management
--/func create_db( sequence db_name )
--/info
--Creates a EuSQL database, including TABLEDEF and INDEXDEF tables.  Note that it 
-- is recommended to use the full, cannonical path.
global function create_db( sequence db )
	object ok
	
	ok = db_create( db, DB_LOCK_NO )
	if ok != DB_OK then
		extended_error = "Could not create database"
		return EUSQL_FAIL
	end if
	
	current_db = db
	if not find( db, db_list ) then
		db_list &= { db }
	end if

	ok = create_table( "", "TABLEDEF" )

	if atom(ok) then
		puts(1,"\nFailed to create TABLEDEF.")
		return ok
	end if

	db_cache_clear()
			
	ok = db_insert( "TABLEDEF", TABLEDEF_STRUCT )
	
	if ok != DB_OK then
		puts(1,"\nFailed to insert TABLEDEF_STRUCT into TABLEDEF.")
		puts(1,"\n" & euslib:pretty_sprint(TABLEDEF_STRUCT))
		return ok
	end if
	
	ok = parse_sql( CREATE_INDEXDEF )

	if sequence(ok) then
		ok = run_create( ok )
	end if

	return ok
end function

-- this is a wrapper around the global function create_db() so that 
-- the v2.4 translator will generate correct calls...
function Create_Db( sequence db )
	return create_db( db )
end function
CREATE_DB = routine_id("create_db")

--/topic Queries
--/func run_query( sequence query )
--/info
--query must be compiled SQL returned from /parse_sql().  This function returns a 3 element 
--sequence:
--<ol>
--/li sequence of the field names
--/li records returned by the query
--/li datatypes of each field
--</ol>

global function run_query( sequence sql )
	integer qt
	atom t
	sequence results

	extended_error = {}
	qt = sql[QN_VALUES][1] 
	
	if qt = EUSQL_SELECT then
		return run_select( sql )
	elsif qt = EUSQL_UPDATE then
		return run_update( sql ) 
		
	elsif qt = EUSQL_INSERT then
		return run_insert( sql )
		
	elsif qt = EUSQL_DELETE then
		return run_delete( sql ) 
	
	elsif qt = EUSQL_UNION then
		return run_union( sql ) 
		
	elsif qt = EUSQL_CREATE then
		
		return run_create( sql ) 
		
	elsif qt = EUSQL_DROP then
		return run_drop( sql ) 
	end if
	
	extended_error = "Unsupported Query Type"
	return EUSQL_ERR_SYNTAX
end function

--/topic Queries
--/func run_sql( sequence sql )
--/info
--sql must be a SQL statement in a string.  This function calls parse_sql and run_query for 
--you, returning the result.  If there is an error in the statement, an atom will be returned, 
--otherwise, the result is a three element sequence:
--<ol>
--/li sequence of the field names
--/li records returned by the query
--/li datatypes of each field
--</ol>
global function run_sql( sequence sql )
	object ok
	
	extended_error = {}
	
	ok = parse_sql( sql )
	
	if atom(ok) then
		return ok
	end if
	
	return run_query( ok )
end function

--/topic Data
--/func get_record2( sequence db_name, sequence table_name, sequence search_field, object search, sequence field, sequence field_index )
--/info
--Allows record retrieval based on non-key field values.  Returns only the first record found with
--the correct field value.
global function get_record2( sequence db_name, sequence table_name,
		sequence search_field, object search, sequence field, 
		sequence field_index )
	
	object ok	 
	sequence indexdef, indices, sql, list
	integer ix, kx
	
	save_current()
	
	ok = select_current( db_name, table_name )
	if atom(ok) then
		restore_current()
		return ok
	end if
	
	if length( field ) then
		-- need to find the index of the field
		ok = field_to_index( db_name, table_name, field )
		if atom(ok) then
			restore_current()
			return ok
		end if
		
		field_index = ok
		
	end if
	
	ok = field_to_index( "", table_name, search_field )
	if atom(ok) then
		extended_error = "Invalid search field"
		restore_current()
		return ok
	end if
	
	if equal( ok[1], {1} ) then
		-- trivial case: searching on the key
		ok = get_record( db_name, table_name, search, "", field_index )
		restore_current()
		return ok
	end if
	
	ok = get_record( db_name, "TABLEDEF", table_name, { "INDEXDEF" }, "" )
	if atom(ok) then
		restore_current()
		return ok
	end if
	indexdef = ok[1]
	
	ok = get_record( db_name, "TABLEDEF", table_name, { "INFO.INDICES" }, "" )
	if atom(ok) then
		restore_current()
		return ok
	end if
	indices = ok[1]
	
	ix = find( field_index, indices )
	if not ix then
		restore_current()
		extended_error = "Couldn't match index."
		return EUSQL_FAIL
	end if
	
	if not sequence( indexdef[ix] ) then
		-- just run a select query
		sql = "SELECT " & field & " FROM " & table_name & " WHERE " &
			search_field
		
		if atom( search ) then
			sql &= " = " & sprint( search )
		else
			sql &= " LIKE '" & search & "'"
		end if
		
		ok = run_sql( sql )
		restore_current()
		if atom( ok ) then
			return ok
		end if
		
		return ok[2][1]
	end if
	
	-- the search field is indexed!
	ok = get_record( "", "INDEXDEF", indexdef[ix][1], "LIST" ,"")
	if atom(ok) then
		restore_current()
		return ok
	end if
	
	list = ok[1]
	if sequence(search) and find( '*', search ) or find( '?', search ) then
		-- wildcard search
		kx = h:index_wild( list, search )
	else
		kx = h:index( list, search )
	end if
	
	if not kx then
		restore_current()
		return EUSQL_ERR_NORECORD
	end if
	
	-- get the record's key value
	ok = list[2][kx][1]
	restore_current()
	return get_record( db_name, table_name, ok, field, "" )
end function

--/topic Utilities
--func set_next_autonumber( sequence db, sequence table, sequence field, sequence index, atom number )
--
--Changes the next autonumber value to the specified number.  Returns sequence on success,
--or an integer error code on failure.
global function set_next_autonumber( sequence db, sequence table, sequence field, sequence index, atom number )
object ok
	sequence fields, indices, auto
	integer ix
	
	table = upper(table)
	
	ok = get_record_mult_fields( db, "TABLEDEF", table, {"FIELDS","INFO.INDICES","AUTOINCREMENT"},{})
	if atom(ok) then
		return ok
	end if

	fields = ok[1]
	indices = ok[2]
	auto = ok[3]

	if length(index) then
		ok = index

	elsif length(field) then
		
		if atom(field[1]) then
			field = tokenize( field, '.' )
		end if
	
		ok = validate_field( field, fields )
		if atom(ok) then
			return ok
		end if
		
	else
		extended_error = "Missing field"
		return EUSQL_FAIL
		
	end if
	
	ix = find( ok, indices )
	if not ix then
		extended_error = "TABLEDEF entry for " & table & " may be corrupt"
		return EUSQL_FAIL
	end if	
	
	auto[ix] = number - 1
	
	return update_record( db, "TABLEDEF", table, {"AUTOINCREMENT"}, {auto} )

end function

function field_fetch(object a, sequence b)
	
	for i = 1 to length(b) do
		if b[i] > length(a) then
			return {}
		end if
		a = a[b[i]]
		if i != length(b) then
			a = a[2]
		end if
		
	end for
	
	return a[1]
end function

--/topic DB Management
--/func get_schema()
--
--Returns the schema of the current database in a sequence.  The format of the sequence:
--<ol>
--/li Table name
--/li Sequence of fields for the table
--<ol>
--/li Field name
--/li Datatype value (see /Datatypes)
--/li Index name (if exists)
--</ol</ol>
global function get_schema()
	sequence tabledef, fields, schema, indices, datatypes, indexed, field, 
		format, hyphens, file
	object ok
	integer sx, fn
	
	if not length(current_db) then
		extended_error = "No open database"
		return EUSQL_FAIL
	end if
	ok = run_sql( "select * from tabledef" )	
	tabledef = ok[2]
	schema = ""
	sx = 0
	for tx = 1 to length( tabledef ) do
		if not find( tabledef[tx][1], SYSTEM_TABLES ) then

			schema = append( schema, { tabledef[tx][1], {} } )
			sx += 1
			fields = tabledef[tx][2]
			indices = tabledef[tx][3]
			datatypes = tabledef[tx][4]
			indexed = tabledef[tx][5]
			
			for ix = 1 to length(indices) do
				if atom(indexed[ix]) then
					indexed[ix] = ""
				end if
				field = { field_fetch( fields, indices[ix] ), datatypes[ix], indexed[ix] }
				
				schema[sx][2] = append( schema[sx][2], field )
			end for
			
			
		end if
	end for
	return schema
end function

-- SQL
----------

--/topic SQL
--/info
--Summary of supported SQL syntax
--This is intended to give a basic overview of the SQL language and how EuSQL has implemented it.  
--Here are some resources you can try if you'd like to learn more about SQL (there are many, many 
--more):
--
--/lit'<a href="http://w3.one.net/~jhoffman/sqltut.htm">http://w3.one.net/~jhoffman/sqltut.htm</a><br>'
--/lit'<a href="http://msdn.microsoft.com/library/wcedoc/vbce/sql.htm">http://msdn.microsoft.com/library/wcedoc/vbce/sql.htm</a><br>'
--/lit'<a href="http://www.spnc.demon.co.uk/ora_sql/sqlmain.htm">http://www.spnc.demon.co.uk/ora_sql/sqlmain.htm</a><br>'
--
--There are several strategies for optimizing queries using EuSQL.  First, try to focus
--you queries using a WHERE clause, especially in queries with a join, as this allows
--EuSQL to eliminate many records from its search.  Another way to improve performance 
--is to create indices on fields in your tables.  You should try to create an index on 
--a field that is likely to be part of a join, or that will likely be included in a 
--WHERE clause.  An index on a field will slow down INSERT, DELETE and UPDATE operations, but 
--can dramatically improve SELECT operations.  Since SELECT is usually done on records
--more often than operations that change the data, this is usually a very profitable
--trade off.

--/topic SQL
--/punctuation [...]
--/info
--Used to specify a parameter that can be set independently of parsing/compiling the query.  
--Use set_parameter to set the value of a parameter.  Parameters can be used as values for 
--fields or for comparison purposes.  This can be used for queries that are run often, but 
--which need different values.  Rather than building/parsing a new SQL command, the parameters 
--in a compiled query can be modified.
--
--ex:
--/code
--SELECT NAME FROM EMPLOYEES WHERE NAME LIKE [NAME];
--
--set_parameter( "name", "A*" )
--/endcode

--/topic SQL
--/keyword AS
--/info
--Used to create an alias for a field or table.   When a table is aliased, the table may
--be joined with itself, so that a query based on relationships between table fields
--can be used.
--
--ex:
--/code
--SELECT FNAME AS NAME FROM EMPLOYEES WHERE NAME LIKE 'A*';
--
--SELECT S.FNAME AS SUPERVISOR, E.FNAME AS EMPLOYEE 
--  FROM EMPLOYEES AS S INNER JOIN EMPLOYEES AS E ON
--  S.ID = E.MANAGER
--/endcode

--/topic SQL
--/aggregate AVG()
--/info
--Returns the average of records selected.
--
--ex:
--/code
--SELECT AVG(SALARY) FROM EMPLOYEES;
--/endcode

--/topic SQL
--/aggregate COUNT()
--/info
--Returns a count of the number of records selected.
--
--ex:
--/code
--SELECT COUNT(ID) FROM EMPLOYEES;
--/endcode

--/topic SQL
--/command DELETE
--/info
--Delete records in one or more tables.  Syntax is similar to to SELECT statement.  Any 
--table with a field mentioned between DELETE and FROM will have selected records deleted.  
--Use the WHERE clause to specify records to delete.

--/topic SQL
--/keyword DISTINCT
--/info
--Query will not return duplicate values.
--
--ex:
--/code
--SELECT DISTINCT LNAME FROM EMPLOYEES;
--/endcode

--/topic SQL
--/keyword FROM
--/info
--Specifies table from which fields are selected.
--
--ex:
--/code
--SELECT NAME FROM EMPLOYEES;
--/endcode

--/topic SQL
--/aggregate GROUP BY
--/info
--If other aggregate functions are used (SUM, COUNT, AVG, etc), any field not within a 
--function must be specified by GROUP BY.
--
--ex:
--/code
--SELECT JOB_DESC, AVG(SALARY) FROM EMPLOYEES GROUP BY JOB_DESC;
--/endcode
--
--This returns the average salary for each JOB_DESC:
--/code
--JOB_DESC    AVG OF SALARY
--SECRETARY   25000
--MANAGER     60000
--...etc
--/endcode

--/topic SQL
--/command CREATE
--/info
--Create a database:
--/code
--CREATE DATABASE /i"database-name"
--/endcode
--Create a table:
--/code
--CREATE TABLE /i"table-name", /i"field-1-name" AS /i"field-1-datatype", ...
--/endcode
--Create an index (note that unique indices are not supported at this time):
--/code
--CREATE [UNIQUE] INDEX /i"index-name" ON /i"table-name" ( /i"field-name" )
--/endcode
--

--/topic SQL
--/command DROP
--/info
--Drop a table from the database:
--/code
-- DROP TABLE EMPLOYEE
--/endcode
--Drop an index from the database:
--/code
--DROP INDEX /i"index-name"
--/endcode

--/topic SQL
--/command UPDATE
--/info
--Update records in a table.  The format for the UPDATE command is:
--/code
--  UPDATE /iTABLENAME SET /iFIELD1 = /iVAL1, [/iFIELDN = /iVALN...] [WHERE /iCONDITION]
--/endcode
--For example, if you wanted to change all employees in department 3 to department 2:
--/code
--  UPDATE EMPLOYEES SET DEPARTMENT = 2 WHERE DEPARTMENT = 3
--/endcode

--/topic SQL
--/command INSERT
--/info
--Insert records into a table.  Values to be inserted can be specified either with a SELECT 
--statement or explicity using VALUES( f1, f2, f3, ... ).
--
--The order in which fields are specified must match the order in which the values are given.  
--If the number fields and values (supplied explicitly or implicitly) do not match, an error 
--will be returned.
--/code
--INSERT INTO TABLE1 FIELD1, FIELD3, FIELD4, FIELD2 VALUES( VAL1, VAL3, VAL4, VAL2)
--
--FIELD1 <- VAL1
--FIELD3 <- VAL3
--FIELD4 <- VAL4
--FIELD2 <- VAL2
--
--INSERT INTO TABLE1 FIELD1, FIELD3, FIELD4, FIELD2 SELECT FIELD1, FIELD3, FIELD4, FIELD2 
--FROM TABLE2
--/endcode
--Inserts resulting records of SELECT into TABLE1.
--
--The inserted records will be returned with a status field appended to each record, indicating 
--either "OK" or "ERROR".  The most common error is duplication of primary keys.

--/topic SQL
--/keyword UNION
--/info
--Allows you to combine two /SELECT statements into one query:
--/code
--   SELECT NAME, ADDRESS FROM EMPLOYEES
--   UNION
--   SELECT NAME, ADDRESS FROM DEPENDENTS
--/endcode
--The resulting dataset would contain two fields (name and address) with the
--combined data from each /SELECT statement.

--/topic SQL
--/keyword JOIN: LEFT/RIGHT/INNER JOIN ON
--/info
--Use relationship between two tables to 'join' into one table for querying purposes.  You must 
--specify either LEFT, RIGHT OR INNER.  An INNER join requires that both fields be non-null, 
--while a RIGHT or LEFT join can have either the 'left' or 'right' field, respectively, be null.  
--Field names must have the table name preceding the field name (EMPLOYEES.NAME).
--
--ex:
--/code
--SELECT EMPLOYEE.ID, SCHEDULE.DATE FROM EMPLOYEE INNER JOIN SCHEDULE ON EMPLOYEE.ID = SCHEDULE.ID;
--/endcode
--SCHEDULE.ID is a foreign key to EMPLOYEE.ID, and both fields must be non-null
--/code
--SELECT EMPLOYEE.ID, MGR.NAME FROM EMPLOYEE LEFT JOIN MGR ON EMPLOYEE.MGR_ID = MGR.ID;
--/endcode
--EMPLOYEE.MGR_ID is the foreign key to MGR.ID.  MGR_ID can be null (not all employees
--have managers)

--/topic SQL
--/keyword LIKE
--/info
--Used for wildcard string comparisons.
--
--ex:
--/code
--SELECT NAME FROM EMPLOYEES WHERE NAME LIKE "A*";
--/endcode

--/topic SQL
--/keyword ORDER
--/info
--Set a sort order for the returned records.  The default is to order in ascending order.  
--Use DESC to order by descending order.
--
--ex:
--/code
--SELECT NAME, AGE FROM EMPLOYEES ORDER BY AGE DESC, NAME;
--/endcode

--/topic SQL
--/command SELECT
--/info
--Used to query a database to return values
--
--ex:
--/code
--SELECT NAME, AGE FROM EMPLOYEES;
--/endcode

--/topic SQL
--/aggregate SUM()
--/info
--Returns the sum of records selected.
--
--ex:
--/code
--SELECT SUM(SALARY) FROM EMPLOYEES;
--/endcode

--/topic SQL
--/aggregate MAX()
--/info
--Returns the largest value from the records selected
--
--ex:
--/code
--SELECT MAX(SALARY) FROM EMPLOYEES;
--/endcode

--/topic SQL
--/aggregate MIN()
--/info
--Returns the smallest value from the records selected
--
--ex:
--/code
--SELECT MIN(SALARY) FROM EMPLOYEES;
--/endcode

--/topic SQL
--/keyword WHERE
--/info
--Set constraints on records selected.  You can use =, >, <, <> (not equal) or LIKE for comparisons.  String 
--arguments must be enclosed by single quotes ' '.  If you have multiple conditions (using /AND
--and /OR to tie them together, you should put the individual conditions in parentheses, since
--the precedence order may not be what you believe it to be.
--
--ex:
--/code
--SELECT NAME, AGE FROM EMPLOYEES WHERE (AGE > 40) AND (NAME LIKE 'A*');
--/endcode

--/topic SQL
--/keyword IN
--/info
--
--IN is used in a /WHERE clause to select from a list of values:
--/code
--SELECT NAME, DEPARTMENT FROM EMPLOYEES WHERE DEPARTMENT IN(1,3,5)
--/endcode
--This would select the names of all employees in departments 1, 3, and 5.

--/topic SQL
--/keyword IF( condition, true value, false value )
--/info
--
--IF can be used in a calculated field to do conditional calculations:
--/code
-- SELECT NUM, NUM + IF( NUM > 10, 0, 10 ) AS TEST FROM NUMBERS
--
--  NUM  TEST
--  ---  ----
--    1    10
--   10    10
--   11     0
--/endcode


--/topic SQL
--/keyword STR( [number] )
--/info
--
--Converts an atom (number) into a string.
--/code
-- SELECT THE.FIELD, STR(THE.FIELD) AS STRING FROM MY_TABLE
--
--  THE.FIELD   STRING
--  ---------   ------
--          1      "1"
--        6.7    "6.7"
--/endcode

--/topic SQL
--/keyword VAL( [string] )
--/info
--
--Converts a string to an atom (number), or leaves an atom value alone.
--/code
-- SELECT THE.FIELD, VAL( THE.FIELD ) AS NUM FROM MY_TABLE
--
--  THE.FIELD   NUM
--  ---------   ---
--        "1"     1
--      "6.7"   6.7
--/endcode

--/topic SQL
--/keyword UPPER( [string] )
--/info
--
--Converts the string to upper case

--/topic SQL
--/keyword LOWER( [string] )
--/info
--
--Converts the string to lower case

--/topic SQL
--/keyword LEFT( [string], [chars] )
--/info
--
--Returns the first /i chars characters of /i string.
--/code
-- SELECT THE.FIELD, LEFT(THE.FIELD, 2) AS LEFT_2 FROM MY_TABLE
--
--  THE.FIELD  LEFT_2
--  ---------  ------
--       JOHN      JO
--       MARY      MA
--/endcode


--/topic SQL
--/keyword RIGHT ( [string], [chars] )
--/info
--
--Returns the last /i chars characters of /i string.
--/code
-- SELECT THE.FIELD, RIGHT(THE.FIELD, 2) AS RIGHT_2 FROM MY_TABLE
--
--  THE.FIELD  RIGHT_2
--  ---------  -------
--       JOHN       HN
--       MARY       RY
--/endcode

--/topic SQL
--/keyword LEN( [string] )
--/info
--
--Returns the length of /i string.
--/code
--  SELECT THE.FIELD, LEN(THE.FIELD) AS LENGTH FROM MY_TABLE
--
--   THE.FIELD  LENGTH
--   ---------  ------
--     ABCDEFG       7
--         XYZ       3
--/endcode

--/topic SQL
--/keyword MID( [string], [start], [chars] )
--/info
--
--Returns the /i chars characters of /i string, starting with character
--number /i start.
--/code
-- SELECT THE.FIELD, MID(THE.FIELD, 2, 2) AS MID_2 FROM MY_TABLE
--
--  THE.FIELD  MID_2
--  ---------  -----
--       JOHN     OH
--       MARY     AR
--/endcode

--/topic SQL
--/punctuation &
--/info
--
--Concatenates two strings into one string.
--/code
-- SELECT THE.FIELD, 'FIELD: ' & THE.FIELD AS FIELD FROM MY_TABLE
--
--  THE.FIELD        FIELD
--  ---------  -----------
--         ID    FIELD: ID
--       NAME  FIELD: NAME
--/endcode

-- Miscellaneous Notes
----------

--/topic Miscellaneous Notes
--/info
--How it works, helpful hints
--
--/b Tools /b you /b can /b use<br>
--If you haven't already, I recommend using my Euphoria Database Browser (EDB).  It runs
--on Windows.  Check out <a href="http://www14.brinkster.com/matthewlewis/projects.html">my web page</a> or the
--<a href="http://www.rapideuphoria.com">RDS archives</a> for downloads and updates.
--
--/b Speed<br>
--EuSQL is not extremely fast relative to commercial databases, however, there are some things 
--you can do to speed up operations (meanwhile, I'll work on optimizing everything).  
--<ul>
--/li Create an index on fields that are part of joins.  When an index exists, EuSQL doesn't
--have to search the entire table to find the correct records.  An index will slow update and
--insert operations, but increase SELECT queries.
--/li Use /WHERE clauses, especially when joining two tables.  In conjunction with an index
--or two EuSQL can avoid loading and looking at lots of records.
--</ul>
--
--/b How /b it /b works<br>
--EuSQL needs to have an extra table, named "TABLEDEF" created in the database it is to use.  
--This stores the structures of records in your tables.  This is automatically created when you 
--use create_db.  It will also create the table "INDEXDEF", which is used to store indices created 
--on tables.
--
--The keys [of TABLEDEF] are the names of the tables, and the first field contains a sequence 
--which describes the structure and field names for each table.  Each field is described a 
--sequence with two elements:
--<ol>
--/li The field name
--/li The contents/subfields
--</ol>
--
--The contents of the field could be described by either an empty sequence, or by one or more
--field names.  This way, we preserve the flexibility of deeply nested sequences, while making it easy 
--to use the data.
--
--Other fields [in TABLEDEF] keep track of field datatypes and indices for each table.
--
--Example:
--Suppose table MAIL contains information about people on a mailing list, where the records have 
--the structure (the first field is actually the table/EDS key, which can also be composed of 
--multiple subfields):
--/code
--{ 
--  { "ID",   {} }
--  { "Name",
--        { 
--         {"First", {}}, 
--         {"Last",  {}},
--        }
--  },
--  { "Address", 
--          {
--           {"Street", {}},
--           {"City",   {}},
--           {"State",  {}},
--           {"ZIP",    {}}
--          }
--  }
--}
--/endcode
--Then to refer to a field in a SQL statement (EuSQL is case insensitive):
--
--/code
--First Name :  "name.first"
--    Street :  "address.street"
--   Address :  "address" 
--          -- actually a sequence:
--          -- { Address.Street, Address.City, Address.State, Address.ZIP }
--      etc.
--/endcode
--Using this method, it is possible to grab a single field, or a more complex, nested sequence 
--of fields.

-- TODO
----------

--/topic TODO
--/info
--What's next?
--
--Please let me know if any of these are important to you, and they'll probably
--be implemented sooner than later.
--<ul>
--/li Must have
--<ul>
--/li /set_next_autonumber
--/li ALTER queries
--/li Allow DROP INDEX in SQL statements
--/li Add GET_DATE and GET_TIME to date/time functions.
--</ul>
--/li Would be nice to have
--<ul>
--/li Case insensitive ordering for text fields
--/li Expressions in joins
--/li Optimization
--<ul>
--/li Smarter (binary?) index search when WHERE clause exists
--</ul>
--/li Views
--/li Stored procedures
--/li Callback/progress option for long processing
--/li Constraints
--/li Unique indices
--/li Return partial results
--/li Multi-user (EuSQL Server? ODBC Driver?)
--<ul>
--/li Record locking
--/li Security
--</ul>
--</ul></ul>


-- Known Bugs
----------

--/topic Known Bugs
--/info
--Still gotta squash these...
--
--<ul>
--/li I think there may be some lingering bugs regarding field parsing when the
--table name is or is not prepended.
--</ul>

-- Datatypes
----------

--/topic Datatypes
--/parent Data
--/parent DB Management
--/info
--
--All fields must have a specified data type.  Any writes to the field will be type checked 
--based on the data type.  A non-conforming value will cause an error to be returned.
--It is possible, however, that a field of type INTEGER or ATOM will return an empty sequence.
--This actually means that the field is NULL--no value has yet to be assigned to it.
--
--The EUSQL_* names are the names for the constants defined in eusql.e, and the names
--in 
--<ul>
--/li /b EUSQL_EU_INTEGER (/b INTEGER ) Euphoria 31-bit signed integer
--/li /b EUSQL_EU_ATOM (/b ATOM ) Euphoria atom
--/li /b EUSQL_EU_TEXT (/b TEXT ) One dimension sequence with ASCII data of arbitrary length
--/li /b EUSQL_EU_SEQUENCE (/b SEQUENCE ) Euphoria sequence of arbitrary length and complexity
--/li /b EUSQL_EU_BINARY (/b BINARY ) One dimension sequence of arbitrary length with 
--integer elements between 0 and 255
--/li /b EUSQL_EU_OBJECT (/b OBJECT ) Euphoria object (can be integer, atom or sequence), equivalent
--to no type check.
--/li /b EUSQL_AUTONUMBER (/b AUTONUMBER ) Euphoria atom.  Fields of this data type should be 
--considered read-only, as only EuSQL can write to them.  Any attempt to change a field
--of type AUTONUMBER will result in an error.  To get the value of the next number in 
--the sequence, use the function /get_next_autonumber().
--/li /b EUSQL_EU_BOOLEAN (/b BOOLEAN ) Euphoria integer.  Valid values are 0 (false) and 1 (true).
--In SQL statements you may use 'TRUE' and 'FALSE' when updating, inserting or within a WHERE clause
--when referring to the value of a BOOLEAN field.
--/li /b EUSQL_EU_DATE_TIME (/b DATE_TIME ) Date and time.  See the /Dates section for more information.
--Follows a similar format as the Euphoria date() function,
--except the year is the actual year (not year since 1900):
--<ul>
--/li year 
--/li month  -- January = 1
--/li day  -- day of month, starting at 1
--/li hour  -- 0 to 23
--/li minute  -- 0 to 59
--/li second  -- 0 to 59
--</UL>
--</ul>
--

--/topic Dates
--/parent Data
--/parent Datatypes
--/info
--
--EuSQL has several built-in facilities for dealing with dates using the DATE_TIME datatype.  In an
--insert or delete query, when working with a DATE_TIME field, you should put the DATE_TIME inside of
--quotes.  The format must be:
--/code
--       YYYY-MM-DD HH:MM:SS
--/endcode
--You do not need to include all portions of the date-time (or leading zeroes).  Any omitted parts will be set to zero.  For
--instance, the following are all valid DATE_TIMEs:
--/code
--    2006-1-11 09:10:33
--    2006-01-11
--    2006-1-11 9:11
--    2006-1
--/endcode
--When using a DATE_TIME value in a /WHERE clause, any literal DATE_TIME value should be wrapped in the 
--/DATE_TIME function so that EuSQL will recognize it as a DATE_TIME datatype:
--/code
--    SELECT ORDER_NUM FROM SALES WHERE ORDER_DAY = DATE_TIME( '2006-01-10' );
--/endcode
--See also the documentation on date related functions:
--<ul>
--/li /DATE_TIME
--/li /NOW
--/li /GET_DATE
--/li /GET_TIME
--/li /GET_YEAR
--/li /GET_MONTH
--/li /GET_DAY
--/li /GET_HOUR
--/li /GET_MINUTE
--/li /GET_SECOND
--</ul>

--/topic SQL
--/func DATE_TIME( 'YYYY-MM-DD HH:MM:SS' )
--
--Converts a quoted text date-time into a native EuSQL DATE_TIME piece of data.
--The format required is:
--/code
--     YYYY-MM-DD HH:MM:SS
--/endcode

--/topic SQL
--/func GET_DATE( date_time )
--
--Zeroes out all time data in the DATE_TIME.

--/topic SQL
--/func GET_TIME( date_time )
--
--Zeroes out all date data in the DATE_TIME.

--/topic SQL
--/func GET_YEAR( date_time )
--
--Returns the year in the DATE_TIME as an integer.

--/topic SQL
--/func GET_DAY( date_time )
--
--Returns the day in the DATE_TIME as an integer.

--/topic SQL
--/func GET_MONTH( date_time )
--
--Returns the month in the DATE_TIME as an integer.

--/topic SQL
--/func GET_HOUR( date_time )
--
--Returns the hour in the DATE_TIME as an integer.

--/topic SQL
--/func GET_MINUTE( date_time )
--
--Returns the minute in the DATE_TIME as an integer.

--/topic SQL
--/func GET_SECOND( date_time )
--
--Returns the second in the DATE_TIME as an integer.


--/topic SQL
--/func NOW()
--
--Returns the current DATE_TIME.
