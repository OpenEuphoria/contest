namespace report

include common.e
include db.e

include std/eds.e
include std/sort.e

export sequence contest_dir = ""
export function read_submissions( sequence db_name )
	if DB_OK != db_open( db_name ) then
		common:abort( 1, "Couldn't open the db: %s", { db_name} )
	end if
	if DB_OK != db_select_table( "submissions" ) then
		common:abort( 1, "Couldn't open the submissions table in the results db" )
	end if
	
	integer size = db_table_size()
	if not size then
		return {}
	end if
	
	sequence submissions = repeat( 0, size )
	for i = 1 to length( submissions ) do
		submissions[i] = db_record_key( i ) & db_record_data( i )
	end for
	return submissions
end function

export function write_table( sequence title, sequence submissions, integer delta_column = 0 )
	sequence output = sprintf("\n== %s\n", {title})
	-- table header
-- 	public enum
-- 	SR_USER, SR_FILE, SR_MODE,
-- 	SR_TIME, SR_STATUS,
-- 	SR_COUNT, SR_TOTAL, SR_MAX, SR_AVG, SR_MIN,
-- 	SR_TOKENS, SR_FILESIZE
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
	output &= "|| User || File || Mode || Test || Status || Iterations || Total Time "
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

export function format_submission( sequence sub, integer delta_column, atom leader )
	sequence output = ""
	
	output &= sprintf( "| %s | [[%s->hg:contest/file/default/%s/entries/%s/%s]] | ", 
		sub[SR_USER..SR_FILE] & { contest_dir } & sub[SR_USER..SR_FILE] )
	-- [[hg:contest/file/default/2010-12-15-cpu/entries/ChrisB/cpu.ex|cpu.ex]]
	if sub[SR_MODE] = MODE_INTERP then output &= "Interpreted"
	else                               output &= "Translated"
	end if
	
	output &= sprintf( " | %s | ", {sub[SR_NAME]})
	
	if    sub[SR_STATUS] = STATUS_PASS then output &= "Pass"
	elsif sub[SR_STATUS] = STATUS_FAIL then output &= "Fail"
	else                                    output &= "?"
	end if
	
	output &= sprintf( " | %d | %0.4fs | %0.4fs | %0.4fs | %0.4fs | %d | %d |", sub[SR_COUNT..SR_FILESIZE] )
	
	if delta_column then
		output &= sprintf( " %g |", sub[delta_column] - leader )
	end if
	return output & "\n"
end function

export enum by * 2
	FILTER_EQUAL,
	FILTER_LESS,
	FILTER_GREATER
export function filter_by( sequence submissions, integer column, object pivot, integer comparison )
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

sequence sort_columns = {}
function submission_sort( sequence a, sequence b )
	for i = 1 to length( sort_columns ) do
		integer col = sort_columns[i]
		integer c = 0
		switch col do
			case SR_STATUS then
				c = compare( a[col], b[col] )
				if c then
					if a[col] = STATUS_PASS then
						return -1
					elsif b[col] = STATUS_PASS then
						return 1
					elsif a[col] = STATUS_UNKNOWN then
						return -1
					else
						return 1
					end if
				end if
			case SR_TOTAL, SR_MIN, SR_MAX, SR_AVG then
				if a[col] = -1  and b[col] != -1 then
					return 1
				elsif b[col] = -1 and a[col] != -1 then
					return -1
				end if
				c = compare( a[col], b[col] )
			case else
				c = compare( a[col], b[col] )
		end switch
		if c then
			return c
		end if
	end for
	return compare( a, b )
end function

export function sort( sequence submissions, sequence columns = {} )
	sort_columns = columns
	return custom_sort( routine_id("submission_sort"), submissions )
end function

export function distinct( sequence submissions, integer column )
	sequence filtered = {}
	for i = 1 to length( submissions ) do
		object val = submissions[i][column]
		if not find( val, filtered ) then
			filtered = append( filtered, val )
		end if
	end for
	return sort( filtered )
end function


--**
-- Run a report for a particular test.
export function test_report( sequence submissions, sequence test_name, integer mode, sequence sorting )
	sequence mode_name
	if mode = MODE_INTERP then
		mode_name = "Interpreted"
	elsif mode = MODE_TRANS then
		mode_name = "Translated"
	else
		mode_name = "All"
	end if
	
	submissions = report:sort( submissions, sorting  )
	if mode != 0 then
		submissions = filter_by( 
							submissions,
							SR_MODE,
							mode,
							FILTER_EQUAL
							)
	end if
	
	if length( test_name ) then
		submissions = filter_by(
						submissions,
						SR_NAME,
						test_name,
						FILTER_EQUAL
					)
	else
		test_name = "All"
	end if
	
	return write_table( 
					sprintf( "%s %s", {test_name, mode_name}),
					submissions,
					SR_TOTAL
					)
end function
