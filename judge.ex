include std/filesys.e
include std/pretty.e
include std/console.e
include std/cmdline.e

include judge.e

-- get list of programs to run
sequence
	cmd = command_line()
	
if length(cmd) < 3 then -- default for testing from editor
	cmd = {"","","2010-12-15-cpu"}
end if

set_contest_dir( cmd[3] )

if not has_changed() then
	puts(1,"Nothing has changed.")
else
	run_token_count()
end if

display_token_results()

maybe_any_key("\n\n")
