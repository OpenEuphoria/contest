--
-- Source code token scoring program for the Euphoria contests
--

include std/sort.e
include std/math.e
include std/filesys.e
include std/sequence.e
include std/utils.e
include std/console.e

include euphoria/tokenize.e

enum NAME, TOKENS

sequence stats = {}

function glob(sequence pattern)
	return vslice(iff(atom(dir(pattern)), "", dir(pattern)), D_NAME)
end function

function glob_patterns(sequence patterns)
	sequence result = {}
	
	for i = 1 to length(patterns) do
		result &= glob(patterns[i])
	end for
	
	return result
end function

sequence cmds = glob_patterns(command_line())
for i = 3 to length(cmds) do
	sequence fname = cmds[i]
	if equal(fname, ".") or equal(fname, "..") then
		continue
	end if
	
	sequence tokens = tokenize:tokenize_file(fname)
	stats &= { { fname, length(tokens[1]) } }
end for

integer
	submission_count = length(stats), 
	twenty_percent = ceil(submission_count * 0.2),
	did_divider = 0

stats = sort_columns(stats, { 2, 1 })

printf(1, "Pos | Tok # | Filename\n", {})
printf(1, "---------------------------------------------------\n", {})
for submission = 1 to length(stats) do
	sequence sub = stats[submission]
	
	if submission > twenty_percent and not did_divider then
		printf(1, "---------------------------------------------------\n", {})
		did_divider = 1
	end if
	
	printf(1, "%3d | %5d | %s\n", { submission, sub[TOKENS], sub[NAME] })
end for
