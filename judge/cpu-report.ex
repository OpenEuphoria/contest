include report.e
include db.e

include std/sort.e
contest_dir = "2010-12-15-cpu"
function generate( sequence db_name )
	sequence output = ""
	
	sequence submissions = read_submissions( db_name )
	
	output &= test_report( submissions, "basics2.cpu", MODE_INTERP,  { SR_STATUS, SR_TOKENS, SR_TOTAL, SR_AVG, SR_MIN, SR_MAX } )
	output &= test_report( submissions, "speed.cpu", MODE_INTERP,  { SR_STATUS, SR_TOTAL, SR_AVG, SR_MIN, SR_MAX, SR_TOKENS } )
	output &= test_report( submissions, "speed.cpu", MODE_TRANS,  { SR_STATUS, SR_TOTAL, SR_AVG, SR_MIN, SR_MAX, SR_TOKENS } )
	output &= test_report( submissions, "", 0,  { SR_STATUS, SR_TOTAL, SR_AVG, SR_MIN, SR_MAX, SR_TOKENS } )
	return output
end function

printf(1, generate( "cpu-results.eds" ) )
