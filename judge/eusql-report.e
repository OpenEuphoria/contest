namespace report

include common.e
include db.e

include eusql/eusql.e as eusql

include std/eds.e
include std/filesys.e
include std/sort.e
include std/text.e

export constant 
	SPEED_SORT = { SR_STATUS, SR_TOTAL, SR_AVG, SR_MIN, SR_MAX, SR_TOKENS },
	TOKEN_SORT =  { SR_STATUS, SR_TOKENS, SR_TOTAL, SR_AVG, SR_MIN, SR_MAX }  

export sequence contest_dir = ""

export procedure open_db( sequence db_name )
	object ok = db_open( db_name )
	if ok != DB_OK then
		common:abort( 1, "Couldn't open the db: %s", { db_name} )
	end if
	
	if db_select_table( "TABLEDEF" ) != DB_OK then
	
	-- now make sure it's set up for eusql
	
		-- nope!  have to convert...
		sequence submissions = read_submissions()
		db_close()
		db_name = pathname( db_name ) & "eusql-" & filename( db_name )
		delete_file( db_name )
		create_db( db_name )
		create_table( db_name, submission_tn )
		
-- 	SK_USER, SK_FILE, SK_MODE, SK_NAME
-- 		SD_TIME, SD_STATUS,
-- 		SD_COUNT, SD_TOTAL, SD_MAX, SD_AVG, SD_MIN,
-- 		SD_TOKENS, SD_FILESIZE
		create_field( db_name, submission_tn, "ID.USER", EUSQL_EU_TEXT, 0 )
		create_field( db_name, submission_tn, "ID.FILE", EUSQL_EU_TEXT, 0 )
		create_field( db_name, submission_tn, "ID.MODE", EUSQL_EU_INTEGER, 0 )
		create_field( db_name, submission_tn, "ID.TESTNAME", EUSQL_EU_TEXT, 0 )
		create_field( db_name, submission_tn, "FILETIME", EUSQL_EU_SEQUENCE, 0 )
		create_field( db_name, submission_tn, "STATUS", EUSQL_EU_INTEGER, 0 )
		create_field( db_name, submission_tn, "ITERATIONS", EUSQL_EU_INTEGER, 0 )
		create_field( db_name, submission_tn, "TOTALTIME", EUSQL_EU_ATOM, 0 )
		create_field( db_name, submission_tn, "MAXTIME", EUSQL_EU_ATOM, 0 )
		create_field( db_name, submission_tn, "AVGTIME", EUSQL_EU_ATOM, 0 )
		create_field( db_name, submission_tn, "MINTIME", EUSQL_EU_ATOM, 0 )
		create_field( db_name, submission_tn, "TOKENS", EUSQL_EU_INTEGER, 0 )
		create_field( db_name, submission_tn, "FILESIZE", EUSQL_EU_INTEGER, 0 )
		create_field( db_name, submission_tn, "FUN", EUSQL_EU_INTEGER, 0 )
		create_field( db_name, submission_tn, "TESTLOG", EUSQL_EU_TEXT, 0 )
		
		db_select_table( upper( submission_tn ) )
		for i = 1 to length( submissions ) do
			submission_key key  = submissions[i][1]
			submission     data = submissions[i][2]
			if sequence( data[SD_FUN] ) then
				data[SD_FUN] = 0
			end if
			
			db_insert( key, submissions[i][2] )
		end for
		close_db( db_name )
	end if
	
	ok = eusql:open_db( db_name )
	if atom( ok ) then
		common:abort( 1, get_sql_err( ok ) )
	end if
	
	
end procedure

function read_submissions()
	db_select_table( submission_tn )
	integer size = db_table_size()
	if not size then
		return {}
	end if
	
	sequence submissions = repeat( 0, size )
	for i = 1 to length( submissions ) do
		submissions[i] = { db_record_key( i ), db_record_data( i ) }
	end for
	return submissions
end function

export function write_table( sequence title, sequence results, sequence sort_columns = {}, integer delta_column = 0, integer header_level = 2 )
	
	sequence output = sprintf("\n%s %s\n", { repeat( '=', header_level ), title } )
	
	output &= "||"
	
	-- header...
	sequence header = results[1]
	for i = 1 to length( header ) do
		output &= header[i] 
		integer sx = find( i, sort_columns )
		if sx then
			output &= sprintf(" (%d)", sx )
		end if
		output &= " ||"
	end for
	
	integer delta_asc = 1
	if delta_column then
		if delta_column < 0 then
			delta_asc = 0
			delta_column = -delta_column
		end if
		output &= sprintf( "Delta %s||", { header[delta_column] } )
	end if
	output &= '\n'
	
	sequence data = results[2]
	object leader = 0
	if length( data ) and delta_column and atom( data[1][delta_column] ) then
		leader = data[1][delta_column]
	end if
	for i = 1 to length( data ) do
		sequence record = data[i]
		output &= "|"
		for j = 1 to length( record ) do
			if sequence( record[j] ) then
				output &= record[j] & "|"
			else
				output &= sprintf("%g|", record[j] )
			end if
			
		end for
		
		if delta_column then
			if atom( record[delta_column] ) then
				if delta_asc then
					output &= sprintf("%g|", record[delta_column] - leader )
				else
					output &= sprintf("%g|", leader - record[delta_column] )
				end if
			else
				output &= "N/A|"
			end if
		end if
		output &= '\n'
	end for
	return output
end function

export function format_entries( sequence submissions, integer user_column = 1, integer entry_column = 2 )
	for i = 1 to length( submissions ) do
		sequence sub        = submissions[i]
		sequence user_name  = sub[user_column]
		sequence entry_name = sub[entry_column]
		sub[entry_column] = sprintf( "[[%s->hg:contest/file/default/%s/entries/%s/%s]]", 
			{ entry_name, contest_dir, user_name, entry_name } )
		submissions[i] = sub
	end for
	return submissions
end function

export function dnf_entries( sequence submissions, integer time_column )
	for i = 1 to length( submissions ) do
		sequence sub    = submissions[i]
		atom time_value = sub[time_column]
		if time_value < 0 then
			sub[time_column] = "DNF"
		end if
		submissions[i] = sub
	end for
	return submissions
end function
