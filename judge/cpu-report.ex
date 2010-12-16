include report.e
include db.e

include std/sort.e

function generate( sequence db_name )
	sequence output = ""
	
	sequence submissions = read_submissions( db_name )
	
	output &= write_table( 
					"Speed Test Interpreted",
					filter_by(
						filter_by( 
							report:sort( submissions, { SR_TOTAL, SR_AVG, SR_MIN, SR_MAX, SR_TOKENS }  ),
							SR_MODE,
							MODE_INTERP,
							FILTER_EQUAL
							),
						SR_NAME,
						"speed.cpu",
						FILTER_EQUAL
					),
					SR_TOTAL
					)
	
	output &= write_table( 
					"Total Time Interpreted",
					filter_by( 
						report:sort( submissions, { SR_TOTAL, SR_AVG, SR_MIN, SR_MAX, SR_TOKENS }  ),
						SR_MODE,
						MODE_INTERP,
						FILTER_EQUAL
						),
					SR_TOTAL
					)
	
	output &= write_table( 
					"Total Time Translated",
					filter_by( 
						report:sort( submissions, { SR_TOTAL, SR_AVG, SR_MIN, SR_MAX, SR_TOKENS } ),
						SR_MODE,
						MODE_TRANS,
						FILTER_EQUAL
						),
					SR_TOTAL
					)
					
	output &= write_table(
					"Tokens",
					report:sort( submissions, { SR_TOKENS, SR_TOTAL, SR_AVG, SR_MIN, SR_MAX } ),
					SR_TOKENS
					)
	return output
end function

printf(1, generate( "cpu-results.eds" ) )
