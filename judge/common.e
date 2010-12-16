--****
-- == Common Variables and Methods
--

namespace common

include std/datetime.e

public datetime contest_date
public sequence contest_name, contest_dir, entries_dir
public integer total_tests = 0, debug = 0

public sequence submissions = {}

public enum TEST_NAME, TEST_FILE, TEST_CNTL, TEST_CONTROL, TEST_COUNT
public enum SUB_USER, SUB_FILENAME, SUB_SIZE, SUB_TOK_COUNT

--**
-- NAME/COUNT pairs of tests to run

public sequence tests = {}

without warning += ( override )
override procedure abort(integer code, sequence message = {}, sequence data = {})
	if length(message) then
		printf(2, "*** ERROR ***\n\n  " & message & "\n", data)
	end if

	eu:abort(code)
end procedure
