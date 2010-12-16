include eusql/eusql.e

include eusql-report.e
include db.e

include std/console.e
include std/sort.e
contest_dir = "2010-12-15-cpu"


function generate( sequence db_name )
	sequence output = "= Result Tables\n"
	
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
	ok[2] = format_entries( ok[2] )
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
	ok[2] = format_entries( ok[2] )
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
	if( status > 0, '++Pass++', '--Fail--') as Result, 
	totaltime,
	if( fun, 'Yes', '' ) as fun_entry
from submissions
where id.testname='speed.cpu'
order by result, totaltime

`
	ok = run_sql( sql )
	ok[2] = format_entries( ok[2] )
	output &= write_table(
		"speed.cpu Free for All Speed test",
		ok,
		{3, 4 },  -- sort columns
		4 -- delta column
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
	sum( totaltime ) as pass_score,
	tokens,
	if( fun, 'Yes', '' ) as fun_entry
from submissions
group by id.user, id.file, tokens, fun_entry
order by pass_score desc, tokens

`
	ok = run_sql( sql )
	ok[2] = format_entries( ok[2] )
	output &= write_table(
		"Overall by speed",
		ok,
		{3, 4 },  -- sort columns
		4 -- delta column
		)
	
	-- SUBMISSION LOG:
	output &= write_submission_log()
	
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
	ok[2] = format_entries( ok[2] )
	
	sequence output = "= Submission Log\n"
	sequence current_user = ""
	sequence current_file = ""
	sequence logs = ok[2]
	for i = 1 to length( logs ) do
		sequence current_log = logs[i]
		if compare( current_user, current_log[1] ) then
			output &= sprintf( "\n== %s\n", { current_user } )
			current_file = ""
		end if
		
		if compare( current_file, current_log[2] ) then
			output &= sprintf( "=== %s\n", { current_file } )
			current_file = current_log[2]
		end if
		
		output &= sprintf( "==== %s\n{{{\n%s\n}}}\n", { current_log[3], current_log[4] } )
	end for
	
	
	
	return output
end function

sequence cmd = command_line()
for i = 3 to length( cmd ) do
	puts(1, generate( cmd[i] ) )
end for

display( run_sql( "select * from submissions" ) )
if length( cmd ) < 3 then
	puts( 2, "You must specify at least one results database.\n" )
	abort( 1 )
end if