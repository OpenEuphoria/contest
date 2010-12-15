namespace report

include common.e
include db.e

include std/eds.e
include std/sort.e

export function generate( sequence db_name )
	sequence output = ""
	
	if DB_OK != db_open( db_name ) then
		common:abort( 1, "Couldn't open database: %s", { db_name } )
	end if
	
	sequence submissions = read_submissions()
	
	output &= write_table( 
					"Total Time Interpreted",
					filter_by( 
						stdsort:custom_sort( routine_id("report:by_total_time"), submissions  ),
						SK_MODE,
						MODE_INTERP,
						FILTER_EQUAL
						),
					SD_TOTAL
					)
	
	output &= write_table( 
					"Total Time Translated",
					filter_by( 
						stdsort:custom_sort( routine_id("report:by_total_time"), submissions  ),
						SK_MODE,
						MODE_TRANS,
						FILTER_EQUAL
						),
					SD_TOTAL
					)
					
	output &= write_table(
					"Tokens",
					stdsort:custom_sort( routine_id("report:by_token_count"), submissions ),
					SD_TOKENS
					)
	return output
end function

function read_submissions()
	if DB_OK != db_select_table( "submissions" ) then
		common:abort( 1, "Couldn't open the submissions table in the results db" )
	end if
	
	sequence submissions = repeat( 0, db_table_size() )
	for i = 1 to length( submissions ) do
		submissions[i] = db_record_key( i ) & db_record_data( i )
	end for
	return submissions
end function

function write_table( sequence title, sequence submissions, integer delta_column = 0 )
	sequence output = sprintf("\n== %s\n", {title})
	-- table header
-- 	public enum
-- 	SK_USER, SK_FILE, SK_MODE,
-- 	SD_TIME, SD_STATUS,
-- 	SD_COUNT, SD_TOTAL, SD_MAX, SD_AVG, SD_MIN,
-- 	SD_TOKENS, SD_FILESIZE
-- |=Idx |=Name     |=Description                      |
-- |  *1 | user     | Username on openeuphoria.org     |
-- |  *2 | file     | Filename of the given submission |
-- |  *3 | mode     | INTERP/TRANS                     |
-- |   1 | time     | Testing timestamp                |
-- |   2 | status   | PASS/FAIL status indicator       |
-- |   3 | count    | Count of iterations executed     |
-- |   4 | total    | Total time taken for all tests   |
-- |   5 | max      | Maximum iteration time           |
-- |   6 | avg      | Average iteration time           |
-- |   7 | min      | Minimum iteration time           |
-- |   8 | tokens   | Number of tokens                 |
-- |   9 | filesize | Filesize in bytes                |
--
-- add_submission({ "mattlewis", "cpu-brute.ex", MODE_INTERP }, {
-- 		datetime:now(), STATUS_PASS,
-- 		10, 10 * 230.203, 230.203, 230.204, 230.203,
-- 		89_893_150, 1_291_928
-- 	})
	output &= "|| User || File || Mode || Status || Iterations || Total Time "
	output &= "|| Max Time || Avg Time || Min Time || Tokens || File Size ||"
	atom leader = 0
	if delta_column then
		output &= " Delta ||"
		if length( submissions ) then
			leader = submissions[1][delta_column]
		end if
	end if
	output &= "\n"
	for i = 1 to length( submissions ) do
		output &= format_submission( submissions[i], delta_column, leader )
	end for
	return output
end function

function format_submission( sequence sub, integer delta_column, atom leader )
	sequence output = ""
	
	output &= sprintf( "| %s | %s | ", sub[SK_USER..SK_FILE] )
		
	if sub[SK_MODE] = MODE_INTERP then output &= "Interpreted | "
	else                               output &= "Translated | "
	end if
	
	if sub[SD_STATUS] = STATUS_PASS then output &= "Pass"
	else                                 output &= "Fail"
	end if
	
	output &= sprintf( " | %d | %0.4fs | %0.4fs | %0.4fs | %0.4fs | %d | %d |", sub[SD_COUNT..SD_FILESIZE] )
	
	if delta_column then
		output &= sprintf( " %g |", sub[delta_column] - leader )
	end if
	return output & "\n"
end function

enum by * 2
	FILTER_EQUAL,
	FILTER_LESS,
	FILTER_GREATER
function filter_by( sequence submissions, integer column, object pivot, integer comparison )
	sequence filtered = {}
	for i = 1 to length( submissions ) do
		sequence sub = submissions[i]
		integer c = compare( sub[column], pivot )
		if (c < 0 and and_bits( comparison, FILTER_LESS ) )
		or (c = 0 and and_bits( comparison, FILTER_EQUAL ) )
		or (c > 0 and and_bits( comparison, FILTER_GREATER ) ) 
		then
			filtered = append( filtered, sub )
		end if
	end for
	return filtered
end function

--**
-- Sorts submissions by total time, with passing submissions
-- above failing submissions.
function by_total_time( sequence a, sequence b )
	integer c = compare( a[SD_STATUS], b[SD_STATUS] )
	if c then
		return c
	else
		return compare( a[SD_TOTAL], b[SD_TOTAL] )
	end if
end function

--**
-- Sorts submissions by total time, with passing submissions
-- above failing submissions.
function by_token_count( sequence a, sequence b )
	integer c = compare( a[SD_STATUS], b[SD_STATUS] )
	if c then
		return c
	else
		return compare( a[SD_TOKENS], b[SD_TOKENS] )
	end if
end function

ifdef MOCK then
	puts( 1, generate( "cpu.eds" ) )
end ifdef