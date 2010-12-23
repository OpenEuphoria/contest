include eusql/eusql.e

include eusql-report.e
include db.e

include std/console.e
include std/sort.e
contest_dir = "2010-12-15-cpu"


function generate( sequence db_name )
	sequence output = `
@@(title CPU Emulator Contest)@
%%maxnumlevel = 4
%%toclevel = 1
%%splitname = cpu
%%splitlevel = 2
<<TOC level=1 depth=2>>

`
	
	output &= "= Summary Result Tables\n<<LEVELTOC level=1 depth=4>>\n"
	
	report:open_db( db_name )
	sequence sql = `
select 
	id.user as user, 
	id.file as program, 
	if( status > 0, '++Pass++', '--Fail--') as Result, 
	totaltime,
	if( fun, 'Yes', '' ) as fun_entry
from submissions
where id.testname='speed.cpu' and id.mode=1
order by result, totaltime

`
	EUSQLRESULT ok = run_sql( sql )
	ok[2] = dnf_entries( format_entries( ok[2] ), 4 )
	output &= write_table(
		"speed.cpu Interpreted Speed test",
		ok,
		{3, 4 },  -- sort columns
		4 -- delta column
		)

	sql = `
select 
	id.user as user, 
	id.file as program, 
	if( status > 0, '++Pass++', '--Fail--') as Result, 
	totaltime,
	if( fun, 'Yes', '' ) as fun_entry
from submissions
where id.testname='speed.cpu' and id.mode=2
order by result, totaltime

`
	ok = run_sql( sql )
	ok[2] = dnf_entries( format_entries( ok[2] ), 4 )
	output &= write_table(
		"speed.cpu Translated Speed test",
		ok,
		{3, 4 },  -- sort columns
		4 -- delta column
		)
		
		
	sql = `
select 
	id.user as user, 
	id.file as program, 
	if( id.mode = 1, 'Interpreted', 'Translated' ) as runmode
	if( status > 0, '++Pass++', '--Fail--') as Result, 
	totaltime,
	if( fun, 'Yes', '' ) as fun_entry
from submissions
where id.testname='speed.cpu'
order by result, totaltime

`
	ok = run_sql( sql )
	ok[2] = dnf_entries( format_entries( ok[2] ), 5 )
	output &= write_table(
		"speed.cpu Free for All Speed test",
		ok,
		{4, 5 },  -- sort columns
		5 -- delta column
		)
	
	sql = `
select 
	id.user as user, 
	id.file as program, 
	if( status > 0, '++Pass++', '--Fail--') as Result, 
	tokens,
	if( fun, 'Yes', '' ) as fun_entry
from submissions
where id.testname='basics2.cpu' and id.mode=2
order by result, tokens

`
	ok = run_sql( sql )
	ok[2] = format_entries( ok[2] )
	output &= write_table(
		"basics2.cpu Function Test and Token Size",
		ok,
		{3, 4 },  -- sort columns
		4 -- delta column
		)
		
	-- Overall test...
	sql = `
select 
	id.user as user, 
	id.file as program, 
	sum( status ) as pass_score,
	tokens	,
	if( fun, 'Yes', '' ) as fun_entry
from submissions
group by id.user, id.file, tokens, fun_entry
order by pass_score desc, tokens

`
	ok = run_sql( sql )
	ok[2] = format_entries( ok[2] )
	output &= write_table(
		"Overall by tokens",
		ok,
		{3, 4 },  -- sort columns
		4 -- delta column
		)
		
	-- Overall test...
	sql = `
select 
	id.user as user, 
	id.file as program, 
	sum( totaltime ) as total_runtime,
	sum( iterations) as times_run,
	tokens,
	if( fun, 'Yes', '' ) as fun_entry
from submissions
group by id.user, id.file, tokens, fun_entry
order by times_run desc, total_runtime, tokens

`
	ok = run_sql( sql )
	sequence 
		ok_times = {},
		bad_times = {}
	for i = 1 to length( ok[2] ) do
		if ok[2][i][3] < 0 then
			bad_times = append( bad_times, ok[2][i] )
		else
			ok_times = append( ok_times, ok[2][i] )
		end if
	end for
	ok[2] = dnf_entries( format_entries( ok_times & bad_times ), 3 )
	output &= write_table(
		"Overall by speed",
		ok,
		{4, 3, 5 },  -- sort columns
		3 -- delta column
		)
	
	-- SUBMISSION LOG:
-- 	output &= write_submission_log()
	output &= all_test_tables()
	return output
end function

constant TEST_SQL = `
select 
	id.user, 
	id.file, 
	if( status > 0, '++Pass++', '--Fail--') as Result, 
	totaltime, 
	tokens
from submissions
where id.testname = [test] and id.mode=[mode]
order by result, totaltime
`
EUSQLRESULT test_query = {}
function test_table( sequence test, integer mode = 0 )
	sequence mode_name
	if mode = 0 then
		return  sprintf("== %s\n%s\n%s\n", { test[1], test_table( test, MODE_INTERP ), test_table( test, MODE_TRANS ) } )
	
	elsif mode = MODE_INTERP then
		mode_name = "Interpreted"
		
	elsif mode = MODE_TRANS then
		mode_name = "Translated"
	
	end if
	
	if not length( test_query ) then
		test_query = parse_sql( TEST_SQL )
	end if
	
	set_parameter( "test", test[1] )
	set_parameter( "mode", mode )
	
	EUSQLRESULT ok = run_query( test_query )
	
	ok[2] = dnf_entries( format_entries( ok[2] ), 4 )
	return write_table(
		sprintf("%s %s", {test[1], mode_name}),
		ok,
		{4, 3, 5 },  -- sort columns
		3, -- delta column
		3
		)
	
	
end function

function all_test_tables()
	EUSQLRESULT ok
	sequence output = "= Test Details\n<<LEVELTOC level=1 depth=4>>\n"
	ok = run_sql( "select distinct id.testname from submissions order by id.testname" )
	
	sequence tests = ok[2]
	for i = 1 to length( tests ) do
		output &= test_table( tests[i] )
	end for
	return output
end function

function write_submission_log()
	sequence sql = `
select 
	id.user, 
	id.file, 
	id.testname, 
	testlog
from submissions
order by id.user, id.file, id.testname
`
	EUSQLRESULT ok = run_sql( sql )
	sequence unformatted_entries = ok[2]
	sequence formatted_entries   = format_entries( ok[2] )
	
	sequence output = "= Submission Log\n<<LEVELTOC level=1 depth=4>>\n"
	sequence current_user = ""
	sequence current_file = ""
	
	for i = 1 to length( formatted_entries ) do
		sequence current_log = formatted_entries[i]
		if compare( current_user, current_log[1] ) then
			current_user = current_log[1]
			output &= sprintf( "\n== %s\n", { current_user } )
			current_file = ""
		end if
		
		if compare( current_file, current_log[2] ) then
			current_file = current_log[2]
			output &= sprintf( "=== %s\n%s\n", { unformatted_entries[i][2], current_file } )
			
		end if
		
		output &= sprintf( "==== %s\nOutput Log:\n\n{{{\n%s\n}}}\n", { current_log[3], current_log[4] } )
	end for
	
	
	
	return output
end function

sequence cmd = command_line()
for i = 3 to length( cmd ) do
	puts(1, generate( cmd[i] ) )
end for
-- display( run_sql("select * from submissions") )
if length( cmd ) < 3 then
	puts( 2, "You must specify at least one results database.\n" )
	abort( 1 )
end if
