include eusql/eusql.e

include eusql-report.e
include db.e

include std/console.e
include std/sort.e
contest_dir = "2010-12-15-cpu"


function generate( sequence db_name )
	sequence output = ""
	
	report:open_db( db_name )
	sequence sql = `
select 
	id.user as user, 
	id.file as program, 
	if( status > 0, '++Pass++', '--Fail--') as Result, 
	totaltime
from submissions
where id.testname='speed.cpu' and id.mode=1
order by result, totaltime

`
	EUSQLRESULT ok = run_sql( sql )
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
	totaltime
from submissions
where id.testname='speed.cpu' and id.mode=2
order by result, totaltime

`
	ok = run_sql( sql )
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
	totaltime
from submissions
where id.testname='speed.cpu'
order by result, totaltime

`
	ok = run_sql( sql )
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
	tokens
from submissions
where id.testname='basics2.cpu' and id.mode=2
order by result, tokens

`
	ok = run_sql( sql )
	output &= write_table(
		"basics2.cpu Function and token size",
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
	tokens	
from submissions
group by id.user, id.file, tokens
order by pass_score desc, tokens

`
	ok = run_sql( sql )
	output &= write_table(
		"Overall by tokens",
		ok,
		{3, 4 },  -- sort columns
		4 -- delta column
		)
	return output
end function

sequence cmd = command_line()
for i = 3 to length( cmd ) do
	puts(1, generate( cmd[i] ) )
end for

if length( cmd ) < 3 then
	puts( 2, "You must specify at least one results database.\n" )
	abort( 1 )
end if