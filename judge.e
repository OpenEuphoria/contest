-- judge.e

include std/filesys.e
include std/io.e
include std/get.e

include euphoria/tokenize.e

sequence CONTESTANTS, CONTEST_DIR, PROGRAMS
object CHECKER

enum TOKENS,SPEED
sequence results = repeat({},2)

public procedure set_contest_dir(sequence d)
	CONTEST_DIR = d
end procedure

procedure load_contestants()
sequence
	prog_list = {{},{}},
	dir_list = dir(CONTEST_DIR & "\\entries\\")

	for t=1 to length(dir_list) do
		if find('d',dir_list[t][D_ATTRIBUTES]) and find(dir_list[t][D_NAME],{".",".."}) = 0 then
			prog_list[1] = append(prog_list[1],dir_list[t][D_NAME])
			prog_list[2] = append(prog_list[2],{})
		end if
	end for
	
	for t=1 to length( prog_list[1] ) do
		dir_list = dir( CONTEST_DIR & "\\entries\\" & prog_list[1][t] & "\\*.ex" )
		for x=1 to length(dir_list) do
			prog_list[2][t] = append(prog_list[2][t],dir_list[x][D_NAME])
		end for
	end for
	
	CONTESTANTS = prog_list
end procedure

public procedure load_programs()
PROGRAMS = repeat({},length( CONTESTANTS[1] ))
	for t=1 to length(CONTESTANTS[1]) do
		for x=1 to length(CONTESTANTS[2][t]) do
			PROGRAMS[t] = append(PROGRAMS[t],read_file( CONTEST_DIR & "\\entries\\" & CONTESTANTS[1][t] & "\\" & CONTESTANTS[2][t][x] ) )
		end for
	end for
end procedure

procedure load_checker()
atom fn
	fn = open(CONTEST_DIR & "\\checker.txt","r")
	if fn > 0 then
		CHECKER = get(fn)
		close(fn)
		CHECKER = CHECKER[2]
	else
		CHECKER = 0
	end if
end procedure

public function has_changed()
atom fn
	load_contestants()
	load_programs()
	load_checker()
	
	if integer(CHECKER) then
		fn = open(CONTEST_DIR & "\\checker.txt","w")
		print(fn,PROGRAMS)
		close(fn)
	end if
	
	return not equal(PROGRAMS,CHECKER)
end function

public function get_contestants()
	return CONTESTANTS
end function

public procedure run_token_count()
sequence
	token_count,
	prog
	
integer fn
	
	results[TOKENS] = repeat({},length(CONTESTANTS[1]))
	
	for t=1 to length( CONTESTANTS[1] ) do
		for x=1 to length( CONTESTANTS[2][t] ) do
			prog = CONTEST_DIR & "\\entries\\" & CONTESTANTS[1][t] & "\\" & CONTESTANTS[2][t][x]
			puts(1,"\nParsing " & prog)
			token_count = tokenize_file( prog )
			results[TOKENS][t] &= length(token_count[1])
		end for
	end for
	
	fn = open(CONTEST_DIR & "\\tokens.txt","w")
	print(fn,results[TOKENS])
	close(fn)
	
end procedure

public procedure display_token_results()
sequence TEMP
integer fn

	fn = open(CONTEST_DIR & "\\tokens.txt","r")
	TEMP = get(fn)
	close(fn)
	results[TOKENS] = TEMP[2]
	
	puts(1,"\n---------------------------------------------------")
	puts(1,"\n---------------------------------------------------")
	puts(1,"\nToken results:")
	puts(1,"\n---------------------------------------------------")
	for t=1 to length( CONTESTANTS[1] ) do
		puts(1,"\nResults for " & CONTESTANTS[1][t])
		for x=1 to length(CONTESTANTS[2][t]) do
			printf(1,"\n|%s|%d|",{CONTESTANTS[2][t][x],results[TOKENS][t][x]})
		end for
		puts(1,"\n---------------------------------------------------")
	end for
end procedure
