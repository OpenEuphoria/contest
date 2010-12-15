namespace report

include common.e
include db.e

include std/eds.e
include std/datetime.e
include std/sort.e

export function generate( sequence db_name )
	sequence output = ""
	
	if DB_OK != db_open( db_name ) then
		common:abort( 1, "Couldn't open database: %s", { db_name } )
	end if
	
	sequence submissions = read_submissions()
	
	output &= write_table( 
					"Total Time",
					stdsort:custom_sort( routine_id("report:by_total_time"), submissions  )
					)
	
	output &= write_table(
					"Tokens",
					stdsort:custom_sort( routine_id("report:by_token_count"), submissions )
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

function write_table( sequence title, sequence submissions )
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
	output &= "|| User || File || Mode || Date || Status || Iterations || Total Time "
	output &= "|| Max Time || Avg Time || Min Time || Tokens || File Size ||\n"
	
	for i = 1 to length( submissions ) do
		output &= format_submission( submissions[i] )
	end for
	return output
end function

function format_submission( sequence sub )
	sequence output = ""
	
	output &= sprintf( "| %s | %s | ", sub[SK_USER..SK_FILE] )
		
	if sub[SK_MODE] = MODE_INTERP then output &= "Interpreted"
	else                               output &= "Translated"
	end if
	
	output &= sprintf(" | %s | ", { datetime:format( sub[SD_TIME], "%Y-%m-%d" ) } )
	
	if sub[SD_STATUS] = STATUS_PASS then output &= "Pass"
	else                                 output &= "Fail"
	end if
	
	output &= sprintf( " | %d | %0.4fs | %0.4fs | %0.4fs | %0.4fs | %d | %d |\n", sub[SD_COUNT..SD_FILESIZE] )
	return output
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