--****
-- == Testing
--
-- This module handles the execution and collection of the actual
-- testing information
--

include std/console.e
include std/filesys.e
include std/io.e

include common.e
include db.e

public procedure run_tests(integer mode)
	integer total_submissions = length(common:submissions), status = STATUS_UNKNOWN
	sequence cwd = current_dir(), mode_name

	switch mode do
		case MODE_INTERP then
			mode_name = "interpret"
		case MODE_TRANS then
			mode_name = "translate"
		case else
			abort(1, "Invalid mode: %d", { mode })
	end switch

	for i = 1 to total_submissions do
		sequence contestant = common:submissions[i][SUB_USER]
		sequence   subfname = common:submissions[i][SUB_FILENAME]
		integer    filesize = common:submissions[i][SUB_SIZE]
		integer    tokcount = common:submissions[i][SUB_TOK_COUNT]
		integer       is_pp = match("-pp", subfname)
		integer      is_fun = match("-fun", subfname)

		chdir(dirname(subfname))

		printf(1, "%3d%% (%3d/%3d) %s/%s\n", {
			floor(100 * (i / total_submissions)),
			i, total_submissions,
			contestant, filebase(subfname)
		})

		for j = 1 to length(common:tests) do
			sequence test = common:tests[j]
			sequence result_file = subfname & "." & test[TEST_NAME] & "-" & mode_name & ".log"
			sequence cmd
	
			db:submission_key sk = new_sk(contestant, filename(subfname), mode, test[TEST_NAME])
			db:submission sub = new_submission()

			sub[SD_FILESIZE] = filesize
			sub[SD_TOKENS]   = tokcount
			sub[SD_FUN]      = is_fun

			printf(1, "\t%s %s (%d): ", { test[TEST_NAME], mode_name, test[TEST_COUNT] })

			if is_pp then
				sequence pp_file = common:contest_dir & SLASH &
					filebase(test[TEST_NAME]) & ".pp." & fileext(test[TEST_NAME])
				delete_file(pp_file)
			end if

			switch mode do
				case MODE_INTERP then
					mode_name = "interpret"
					if is_pp then
						cmd = sprintf("eui -batch %s > %s", { test[TEST_FILE], result_file })
					else
						cmd = sprintf("eui -batch %s %s > %s", { subfname, test[TEST_FILE], result_file })
					end if
	
				case MODE_TRANS then
					sequence executable_name = subfname & "." & test[TEST_NAME] & "-" & mode_name
					ifdef WINDOWS then
						executable_name &= ".exe"
					end ifdef
	
					mode_name = "translate"
					if is_pp then
						cmd = sprintf("euc -con -o %s %s > %s", {
							executable_name, test[TEST_FILE], result_file
						})
					else
						cmd = sprintf("euc -con -o %s %s %s > %s", {
							executable_name, subfname, test[TEST_FILE], result_file
						})
					end if

					printf(1, "txing")
					system(cmd)
					printf(1, ", ")

					sub[SD_LOG] &= "Translating\n" & read_file(result_file) & "\n"
	
					-- TODO: Did it translate? Could use system_exec, but it can't
					-- redirect stdout :-/. Could use pipeio but it can't give me
					-- an exit code :-/
	
					-- Setup the command to run the resulting executable"
					cmd = sprintf("%s %s > %s", { executable_name, test[TEST_FILE], result_file })
			end switch

			-- Setup/Translation is done, start the timer
			sub[SD_TOTAL] = time()

			for k = 1 to test[TEST_COUNT] do
				atom it_start = time()
				system(cmd)
				atom it_dur = time() - it_start

				sequence result_content = read_file(result_file, TEXT_MODE)
				sub[SD_LOG] &= sprintf("Execution %d\n%s\n", { k, result_content })

				integer ok = equal(result_content, test[TEST_CONTROL])
				if not common:debug then
					delete_file(result_file)
				end if

				if not ok then
					sub[SD_STATUS] = STATUS_FAIL
					printf(1, " failed")
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

			-- Stop the timer, all done testing
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

		printf(1, "\n")

		chdir(cwd)
	end for
end procedure
