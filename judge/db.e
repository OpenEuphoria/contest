--****
-- == Judge Database
--
-- === Submissions Table
--
-- //* marks primary keys//
--
-- |=Idx |=Name     |=Description                      |
-- |  *1 | user     | Username on openeuphoria.org     |
-- |  *2 | file     | Filename of the given submission |
-- |  *3 | mode     | INTERP/TRANS                     |
-- |   1 | name     | Test name                        |
-- |   2 | time     | Testing timestamp                |
-- |   3 | status   | PASS/FAIL status indicator       |
-- |   4 | count    | Count of iterations executed     |
-- |   5 | total    | Total time taken for all tests   |
-- |   6 | max      | Maximum iteration time           |
-- |   7 | avg      | Average iteration time           |
-- |   8 | min      | Minimum iteration time           |
-- |   9 | tokens   | Number of tokens                 |
-- |  10 | filesize | Filesize in bytes                |
--

namespace db

include std/console.e
include std/datetime.e
include std/eds.e
include std/error.e

constant
	submission_tn = "submissions"

public enum
	SK_USER, SK_FILE, SK_MODE,
	SD_NAME, SD_TIME, SD_STATUS,
	SD_COUNT, SD_TOTAL, SD_MAX, SD_AVG, SD_MIN,
	SD_TOKENS, SD_FILESIZE

public enum MODE_INTERP, MODE_TRANS
public enum STATUS_FAIL=-1, STATUS_UNKNOWN, STATUS_PASS

public type submission_key(object o)
	if not sequence(o) then return 0 end if
	if not length(o) = 3 then return 0 end if
	if not sequence(o[1]) then return 0 end if
	if not sequence(o[2]) then return 0 end if
	if not integer(o[3]) then return 0 end if

	return 1
end type

public type submission(object o)
	if not sequence(o) then return 0 end if
	if not sequence(o[1]) then return 0 end if -- SK_NAME
	if not datetime(o[2]) then return 0 end if -- SK_TIME
	if not integer(o[3]) then return 0 end if  -- SK_STATUS
	if not integer(o[4]) then return 0 end if  -- SK_COUNT
	if not atom(o[5]) then return 0 end if     -- SK_TOTAL
	if not atom(o[6]) then return 0 end if     -- SK_MAX
	if not atom(o[7]) then return 0 end if     -- SK_AVG
	if not atom(o[8]) then return 0 end if     -- SK_MIN
	if not integer(o[9]) then return 0 end if  -- SK_TOKENS
	if not integer(o[10]) then return 0 end if -- SK_FILESIZE

	return 1
end type

public function new_sk(sequence username, sequence filename, integer mode)
	return { username, filename, mode }
end function

public function new_submission()
	return {
		"UNKNOWN",      -- SD_NAME
		datetime:now(), -- SD_TIME
		STATUS_UNKNOWN, -- SD_STATUS
		0,              -- SD_COUNT
		0.0,            -- SD_TOTAL
		0.0,            -- SD_MAX
		999_999.0,      -- SD_AVG
		0.0,            -- SD_MIN
		0,              -- SD_TOKENS
		0               -- SD_FILESIZE
	}
end function

public function open(sequence filename)
    integer status = db_open(filename, DB_LOCK_EXCLUSIVE)
    switch status do
        case DB_OK then
            return 1

        case DB_LOCK_FAIL then
            return -1
    end switch

    -- Open failed, let's try to create the database
    status = db_create(filename, DB_LOCK_EXCLUSIVE)
    if status != DB_OK then
        return 0
    end if

    status = db_create_table(submission_tn)
    if status != DB_OK then
        db_close()

        return 0
    end if

    return 1
end function

public procedure close()
	db_close()
end procedure

public procedure add_submission(submission_key sk, submission s)
    atom recid = db_get_recid(sk, submission_tn)
    if recid > 0 then
        db_replace_recid(recid, s)
	else
    	if db_insert(sk, s, submission_tn) != DB_OK then
			display({ sk, s })
			error:crash("Could not insert submission")
        end if
    end if
end procedure

ifdef MOCK then
	open("cpu.eds")
	
	add_submission({ "jeremy", "cpu1.ex", MODE_INTERP }, {
		datetime:now(), STATUS_PASS,
		10, 10 * 0.203, 0.203, 0.205, 0.204,
		150, 1928
	})
	
	add_submission({ "mattlewis", "cpu-brute.ex", MODE_INTERP }, {
		datetime:now(), STATUS_PASS,
		10, 10 * 230.203, 230.203, 230.204, 230.203,
		89_893_150, 1_291_928
	})
	
	add_submission({ "mattlewis", "cpu-brute.ex", MODE_TRANS }, {
		datetime:now(), STATUS_PASS,
		10, 10 * 2.203, 0.203, 0.204, 0.203,
		89_893_150, 1_291_928
	})
	close()
end ifdef
