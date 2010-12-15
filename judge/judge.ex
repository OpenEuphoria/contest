--****
-- == Judge
--

include std/console.e
include std/convert.e
include std/cmdline.e
include std/datetime.e as dt
include std/filesys.e
include std/map.e

include common.e

procedure configure_test_specs(sequence args)
	integer i = 1

	while i <= length(args) do
		sequence test_file = canonical_path(common:contest_dir & SLASH & args[i])
		sequence cntl_file = canonical_path(common:contest_dir & SLASH & filebase(args[i]) & ".out")
		sequence test = { args[i], test_file, cntl_file, 1 }
		if i < length(args) then
			integer count = to_integer(args[i + 1], 0)
			if count then
				test[4] = count
				i += 1
			end if
		end if

		if not file_exists(test_file) then
			abort(1, "Test file not found: %s\n", { test_file })
		end if

		if not file_exists(cntl_file) then
			abort(1, "Control file not found: %s\n", { cntl_file })
		end if

		common:tests &= { test }
		i += 1
	end while
end procedure

procedure find_submissions()
	sequence contestants = dir(common:entries_dir)
	for i = 1 to length(contestants) do
		if contestants[i][1] = '.' then
			continue
		end if

		sequence cont_dir = common:entries_dir & SLASH & contestants[i][1]
		sequence entries = dir(cont_dir & SLASH & common:contest_name & "*.ex")
	end for
end procedure

procedure main()
	sequence options = {
		{ "n", 0, "Contest name",          { HAS_PARAMETER, "name", ONCE, MANDATORY } },
		{ "d", 0, "Contest deadline date", { HAS_PARAMETER, "YYYY-MM-DD", ONCE, MANDATORY } },
		{   0, 0, 0,                       { MANDATORY } }
	}
		
	map opts = cmd_parse(options)

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
	find_submissions()

end procedure

main()
