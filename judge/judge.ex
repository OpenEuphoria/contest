--****
-- == Judge
--
-- See ##eui judge.ex --help## for description of the command line arguments
--
-- Example command line use:
-- {{{
-- % eui judge\judge.ex -d 2010-12-15 -n cpu basics.cpu 10 \
--         basics2.cpu 10 speed.cpu life.cpu
-- 4 tests, 22 total iterations, 19 submissions
-- }}}
--

include std/cmdline.e
include std/console.e
include std/convert.e
include std/datetime.e as dt
include std/filesys.e
include std/map.e
include std/math.e
include std/sequence.e

include euphoria/tokenize.e

include common.e
include db.e
include test.e

procedure configure_test_specs(sequence args)
	integer i = 1

	while i <= length(args) do
		sequence test_file = canonical_path(common:contest_dir & SLASH & args[i])
		sequence cntl_file = canonical_path(common:contest_dir & SLASH & filebase(args[i]) & ".out")
		sequence test = { args[i], test_file, cntl_file, 0, 1 }
		if i < length(args) then
			integer count = to_integer(args[i + 1], 0)
			if count then
				test[TEST_COUNT] = count
				i += 1
			end if
		end if

		if not file_exists(test_file) then
			abort(1, "Test file not found: %s\n", { test_file })
		end if

		if not file_exists(cntl_file) then
			abort(1, "Control file not found: %s\n", { cntl_file })
		end if

		test[TEST_CHECKSUM] = checksum(cntl_file)

		common:tests &= { test }
		i += 1
	end while
end procedure

procedure find_submissions(sequence ignored_users, sequence only_users)
	sequence contestants = dir(common:entries_dir)
	for i = 1 to length(contestants) do
		if contestants[i][1][1] = '.' or find(contestants[i][1], ignored_users) then
			continue
		end if

		if length(only_users) and not find(contestants[i][1], only_users) then
			continue
		end if

		sequence cont_dir = common:entries_dir & SLASH & contestants[i][1]
		object entries = dir(cont_dir & SLASH & common:contest_name & "*.ex")
		if not sequence(entries) then
			continue
		end if

		for j = 1 to length(entries) do
			sequence canonical_name = canonical_path(cont_dir & SLASH & entries[j][1])
			sequence tokens = tokenize:tokenize_file(canonical_name)
	
			-- Don't count the "#!/usr/bin/env eui" line
			if tokens[1][1][TTYPE] = T_SHBANG then
				tokens[1] = remove(tokens[1], 1)
			end if
	
			submissions &= {{
				contestants[i][1],
				canonical_name,
				file_length(canonical_name),
				length(tokens[1])
			}}
		end for
	end for
end procedure

procedure main()
	sequence options = {
		{ "n", 0, "Contest name",          { HAS_PARAMETER, "name", ONCE, MANDATORY } },
		{ "d", 0, "Contest deadline date", { HAS_PARAMETER, "YYYY-MM-DD", ONCE, MANDATORY } },
		{ "i", 0, "Ignore user",           { HAS_PARAMETER, "user", MULTIPLE } },
		{ "o", 0, "Only user",             { HAS_PARAMETER, "user", MULTIPLE } },
		{   0, 0, 0,                       { MANDATORY } }
	}
		
	map opts = cmd_parse(options, { HELP_RID,
		"Addition arguments are:\n" &
		"\n" &
		"    testfile [iterations] ... testfile_n [iterations]\n" &
		"\n" &
		"Test files should exist under the contest date-name directory\n" &
		"and have an associated .out file that contains the correct\n" &
		"output for the given test. This is the control file."
	})

	common:contest_date = dt:parse(map:get(opts, "d"), "%Y-%m-%d")
	common:contest_name = map:get(opts, "n")
	common:contest_dir  = canonical_path(map:get(opts, "d") & "-" & common:contest_name)
	common:entries_dir  = common:contest_dir & SLASH & "entries"

	if not file_exists(contest_dir) then
		abort(1, "Contest directory does not yet exist: %s", { common:contest_dir })
	end if

	if not file_exists(common:entries_dir) then
		abort(1, "Entries directory does not yet exist: %s", { common:entries_dir })
	end if

	configure_test_specs(map:get(opts, cmdline:EXTRAS))
	find_submissions(map:get(opts, "i", {}), map:get(opts, "o", {}))

	-- For progress compuations
	for i = 1 to length(common:tests) do
		common:total_tests += common:tests[i][TEST_COUNT]
	end for
	common:total_tests *= length(common:submissions)

	printf(1, "%d submissions, %d tests, %d total iterations\n\n", {
		length(common:submissions),
		length(common:tests),
		common:total_tests
	})

	db:open(datetime:format(common:contest_date, "%Y-%m-%d") & "-" & common:contest_name & SLASH &
		"results.eds")

	run_tests()

	db:close()
end procedure

main()
