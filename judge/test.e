--****
-- == Testing
--
-- This module handles the execution and collection of the actual
-- testing information
--

include std/console.e
include std/filesys.e

include common.e
include db.e

public procedure line()
	printf(1, repeat('-', 50) & "\n")
end procedure

public procedure run_tests()
	integer total_submissions = length(common:submissions), status = STATUS_UNKNOWN

	for i = 1 to total_submissions do
		sequence contestant = common:submissions[i][1]
		sequence submission = common:submissions[i][2]

		line()

		printf(1, "%3d%% (%3d/%3d) %s/%s\n", {
			floor(100 * (i / total_submissions)),
			i, total_submissions,
			contestant, filebase(submission)
		})

		for j = 1 to length(common:tests) do
			sequence test = common:tests[j]
			printf(1, "\t%s (%d): ", { test[TEST_NAME], test[TEST_COUNT] })

			for k = 1 to test[TEST_COUNT] do
				sequence result_file = submission & "." & test[TEST_NAME]
				sequence cmd = sprintf("eui %s %s > %s", {
						submission, test[TEST_FILE], result_file
					})

				atom it_start = time()
				system(cmd)
				atom it_end = time()

				if not equal(checksum(result_file), test[TEST_CHECKSUM]) then
					status = STATUS_FAIL
					printf(1, " failed\n")
					exit
				end if

				if k > 1 then
					printf(1, ", ")
				end if

				printf(1, "%f", it_end - it_start)
			end for

			printf(1, "\n")
		end for

		line()

	end for
end procedure
