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

public procedure run_tests()
	integer total_submissions = length(common:submissions), status = STATUS_UNKNOWN

	for i = 1 to total_submissions do
		sequence contestant = common:submissions[i][SUB_USER]
		sequence   subfname = common:submissions[i][SUB_FILENAME]
		integer    filesize = common:submissions[i][SUB_SIZE]
		integer    tokcount = common:submissions[i][SUB_TOK_COUNT]

		printf(1, "%3d%% (%3d/%3d) %s/%s\n", {
			floor(100 * (i / total_submissions)),
			i, total_submissions,
			contestant, filebase(subfname)
		})

		for j = 1 to length(common:tests) do
			sequence test = common:tests[j]

			printf(1, "\t%s (%d): ", { test[TEST_NAME], test[TEST_COUNT] })

			db:submission_key sk = new_sk(contestant, filename(subfname), db:MODE_INTERP, test[TEST_NAME])
			db:submission sub = new_submission()

			sub[SD_TOTAL]    = time()
			sub[SD_FILESIZE] = filesize
			sub[SD_TOKENS]   = tokcount

			for k = 1 to test[TEST_COUNT] do
				sequence result_file = subfname & "." & test[TEST_NAME]
				sequence cmd = sprintf("eui %s %s > %s", {
						subfname, test[TEST_FILE], result_file
					})

				atom it_start = time()
				system(cmd)
				atom it_dur = time() - it_start

				if not equal(checksum(result_file), test[TEST_CHECKSUM]) then
					sub[SD_STATUS] = STATUS_FAIL
					printf(1, " failed\n")
					exit
				end if

				sub[SD_COUNT] += 1

				if it_dur < sub[SD_MIN] then
					sub[SD_MIN] = it_dur
				end if

				if it_dur > sub[SD_MAX] then
					sub[SD_MAX] = it_dur
				end if

				if k > 1 then
					printf(1, ", ")
				end if

				printf(1, "%f", it_dur)
			end for

			printf(1, "\n")

			sub[SD_TOTAL] = time() - sub[SD_TOTAL]

			if sub[SD_COUNT] = 0 or sub[SD_STATUS] = STATUS_FAIL then
				sub[SD_AVG]   = -1
				sub[SD_MIN]   = -1
				sub[SD_MAX]   = -1
				sub[SD_TOTAL] = -1
			else
				sub[SD_AVG] = sub[SD_TOTAL] / sub[SD_COUNT]
			end if

			if sub[SD_COUNT] = test[TEST_COUNT] then
				sub[SD_STATUS] = STATUS_PASS
			 end if

			add_submission(sk, sub)
		end for

		printf(1, "\n\n")

	end for
end procedure
