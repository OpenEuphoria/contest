include report.e
include db.e

include std/sort.e
contest_dir = "2010-12-15-cpu"

function generate( sequence db_name )
	sequence output = ""
	
	sequence submissions = read_submissions( db_name )
	
	output &= test_report( submissions, "basics2.cpu", MODE_INTERP, TOKEN_SORT, SR_TOKENS )
	output &= test_report( submissions, "speed.cpu", MODE_INTERP,  SPEED_SORT, SR_TOTAL )
	output &= test_report( submissions, "speed.cpu", MODE_TRANS,  SPEED_SORT, SR_TOTAL )
	output &= test_report( submissions, "", 0,  SPEED_SORT, SR_TOTAL )
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