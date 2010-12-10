include std/filesys.e
include std/pretty.e
include std/console.e
include std/cmdline.e

include judge.e

-- get list of programs to run
sequence
	cmd = command_line()
	
if length(cmd) < 3 then -- default for testing from editor
	cmd = {"","","2010-12-04-lcd"}
end if

set_contest_dir( cmd[3] )
-- cmd = append(cmd,"-c")

-- optional -c will clear all results
if find("-c",cmd) then
	clear_results()
end if

if not has_changed() then
	puts(1,"Nothing has changed.")
else
	judge_token_count()
	judge_loc()
	judge_filesize()
end if

display_token_results()
maybe_any_key("\n\n")

display_loc_results()
maybe_any_key("\n\n")

display_filesize_results()
maybe_any_key("\n\n")
