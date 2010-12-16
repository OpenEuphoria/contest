include std/utils.e

integer
	reg0 = 0,
	reg1 = 0,
	reg2 = 0,
	reg3 = 0,
	reg4 = 0,
	reg5 = 0,
	reg6 = 0,
	reg7 = 0,
	reg8 = 0,
	reg9 = 0,
	$

sequence ram = repeat(0, 1000 )
ram[1] = -1

sequence cmd = command_line()
integer fn = iff( length(cmd) > 2, open( cmd[3], "r" ), -1 )
if fn = -1 then
	puts(2, "you must provide a file to run\n")
	abort(1)
end if
object in
sequence lines = {}

while sequence( in ) with entry do
	lines = append( lines, in )
entry
	in = gets( fn )
end while
close(fn)

ifdef DEBUG then
	integer logfn = open( "cpu.log", "w" )
end ifdef

sequence code = repeat( 0, length( lines ) )
for i = 1 to length( lines ) do
	sequence line = lines[i]
	if length( line ) < 3 then
		continue
	end if
	integer op   = line[1]
	integer opnd = line[2]
	
	switch op do
		case '?' then
			op = 1001
			if opnd = '?' then
				opnd = line[3]
				op += 10
			end if
			opnd -= '0'
			op += opnd
			code[i] = op
		case '1' then
			code[i] = 100
		case else
			op -= '0'
			op *= 100
			
			opnd -= '0'
			opnd *= 10
			op += opnd
			
			opnd = line[3]
			opnd -= '0'
			
			op += opnd
			
			code[i] = op
			
	end switch
ifdef DEBUG then
	printf( logfn, "pc[%2d] op[%3d] %s", { i, code[i], line })
end ifdef
end for

-- make sure there's a halt at the end for cleaner exits
code = append( code, "100" )


ifdef DEBUG then
	-- if we're debugging, we want to count the steps, so we make sure it's defined
	with define STEPS
end ifdef

ifdef STEPS then
	atom steps = 0
end ifdef
integer pc = 0
integer op, ptr

while 1 do
	pc += 1
	-- op is an integer, and assigning it here is faster than inside the switch.  If we did:
	--        switch code[pc] do...
	-- Then the subscripting would create a temp which the interpreter would have to deal 
	-- with.  This way, the result is assigned directly to "op".  We know it will be an
	-- integer, so this is a good way to hint to euphoria about the value we're working with.
	-- The parser would emit code to assign the result of the subcript to a temp, so assigning
	-- to a variable doesn't create more work, even though it's a little more code.
	op = code[pc]
	
	ifdef DEBUG then
		-- This is useful when debugging a program, and only runs when DEBUG is
		-- defined, usually by: eui -d DEBUG cpu-brute.ex prog.cpu
		printf(logfn, "pc[%2d] op[%03d ] : ", pc & op )
		print(logfn, { reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9 } )
		print(logfn, ram)
		puts(logfn,"\n")
	end ifdef
	
	ifdef STEPS then
		steps += 1
	end ifdef
	
	-- This switch has a case for each possible op.  This prevents any subscripting,
	-- except for RAM access or storage.  The switch variable and all cases are 
	-- integers, and the spread is small enough to allow the switch use the fast
	-- lookup table instead of find().  Certain ops that have no effect will simply
	-- increment the counter, saving time vs a more generic interpreter.
	--
	-- The cases were machine generated.
	--
	-- There is no code after the switch inside the while loop, and there are no 
	-- declared variables inside the while loop, so there are no variables to
	-- clean up, and branch straightening causes the execution to come right back
	-- up to the top.  NOPs like 300 are omitted entirely, and execution goes
	-- right from the switch to the top of the while loop.
	switch op do
		case 0 then 	if reg0 then pc = reg0 continue end if
		case 1 then 	if reg1 then pc = reg0 continue end if
		case 2 then 	if reg2 then pc = reg0 continue end if
		case 3 then 	if reg3 then pc = reg0 continue end if
		case 4 then 	if reg4 then pc = reg0 continue end if
		case 5 then 	if reg5 then pc = reg0 continue end if
		case 6 then 	if reg6 then pc = reg0 continue end if
		case 7 then 	if reg7 then pc = reg0 continue end if
		case 8 then 	if reg8 then pc = reg0 continue end if
		case 9 then 	if reg9 then pc = reg0 continue end if
		case 10 then 	if reg0 then pc = reg1 continue end if
		case 11 then 	if reg1 then pc = reg1 continue end if
		case 12 then 	if reg2 then pc = reg1 continue end if
		case 13 then 	if reg3 then pc = reg1 continue end if
		case 14 then 	if reg4 then pc = reg1 continue end if
		case 15 then 	if reg5 then pc = reg1 continue end if
		case 16 then 	if reg6 then pc = reg1 continue end if
		case 17 then 	if reg7 then pc = reg1 continue end if
		case 18 then 	if reg8 then pc = reg1 continue end if
		case 19 then 	if reg9 then pc = reg1 continue end if
		case 20 then 	if reg0 then pc = reg2 continue end if
		case 21 then 	if reg1 then pc = reg2 continue end if
		case 22 then 	if reg2 then pc = reg2 continue end if
		case 23 then 	if reg3 then pc = reg2 continue end if
		case 24 then 	if reg4 then pc = reg2 continue end if
		case 25 then 	if reg5 then pc = reg2 continue end if
		case 26 then 	if reg6 then pc = reg2 continue end if
		case 27 then 	if reg7 then pc = reg2 continue end if
		case 28 then 	if reg8 then pc = reg2 continue end if
		case 29 then 	if reg9 then pc = reg2 continue end if
		case 30 then 	if reg0 then pc = reg3 continue end if
		case 31 then 	if reg1 then pc = reg3 continue end if
		case 32 then 	if reg2 then pc = reg3 continue end if
		case 33 then 	if reg3 then pc = reg3 continue end if
		case 34 then 	if reg4 then pc = reg3 continue end if
		case 35 then 	if reg5 then pc = reg3 continue end if
		case 36 then 	if reg6 then pc = reg3 continue end if
		case 37 then 	if reg7 then pc = reg3 continue end if
		case 38 then 	if reg8 then pc = reg3 continue end if
		case 39 then 	if reg9 then pc = reg3 continue end if
		case 40 then 	if reg0 then pc = reg4 continue end if
		case 41 then 	if reg1 then pc = reg4 continue end if
		case 42 then 	if reg2 then pc = reg4 continue end if
		case 43 then 	if reg3 then pc = reg4 continue end if
		case 44 then 	if reg4 then pc = reg4 continue end if
		case 45 then 	if reg5 then pc = reg4 continue end if
		case 46 then 	if reg6 then pc = reg4 continue end if
		case 47 then 	if reg7 then pc = reg4 continue end if
		case 48 then 	if reg8 then pc = reg4 continue end if
		case 49 then 	if reg9 then pc = reg4 continue end if
		case 50 then 	if reg0 then pc = reg5 continue end if
		case 51 then 	if reg1 then pc = reg5 continue end if
		case 52 then 	if reg2 then pc = reg5 continue end if
		case 53 then 	if reg3 then pc = reg5 continue end if
		case 54 then 	if reg4 then pc = reg5 continue end if
		case 55 then 	if reg5 then pc = reg5 continue end if
		case 56 then 	if reg6 then pc = reg5 continue end if
		case 57 then 	if reg7 then pc = reg5 continue end if
		case 58 then 	if reg8 then pc = reg5 continue end if
		case 59 then 	if reg9 then pc = reg5 continue end if
		case 60 then 	if reg0 then pc = reg6 continue end if
		case 61 then 	if reg1 then pc = reg6 continue end if
		case 62 then 	if reg2 then pc = reg6 continue end if
		case 63 then 	if reg3 then pc = reg6 continue end if
		case 64 then 	if reg4 then pc = reg6 continue end if
		case 65 then 	if reg5 then pc = reg6 continue end if
		case 66 then 	if reg6 then pc = reg6 continue end if
		case 67 then 	if reg7 then pc = reg6 continue end if
		case 68 then 	if reg8 then pc = reg6 continue end if
		case 69 then 	if reg9 then pc = reg6 continue end if
		case 70 then 	if reg0 then pc = reg7 continue end if
		case 71 then 	if reg1 then pc = reg7 continue end if
		case 72 then 	if reg2 then pc = reg7 continue end if
		case 73 then 	if reg3 then pc = reg7 continue end if
		case 74 then 	if reg4 then pc = reg7 continue end if
		case 75 then 	if reg5 then pc = reg7 continue end if
		case 76 then 	if reg6 then pc = reg7 continue end if
		case 77 then 	if reg7 then pc = reg7 continue end if
		case 78 then 	if reg8 then pc = reg7 continue end if
		case 79 then 	if reg9 then pc = reg7 continue end if
		case 80 then 	if reg0 then pc = reg8 continue end if
		case 81 then 	if reg1 then pc = reg8 continue end if
		case 82 then 	if reg2 then pc = reg8 continue end if
		case 83 then 	if reg3 then pc = reg8 continue end if
		case 84 then 	if reg4 then pc = reg8 continue end if
		case 85 then 	if reg5 then pc = reg8 continue end if
		case 86 then 	if reg6 then pc = reg8 continue end if
		case 87 then 	if reg7 then pc = reg8 continue end if
		case 88 then 	if reg8 then pc = reg8 continue end if
		case 89 then 	if reg9 then pc = reg8 continue end if
		case 90 then 	if reg0 then pc = reg9 continue end if
		case 91 then 	if reg1 then pc = reg9 continue end if
		case 92 then 	if reg2 then pc = reg9 continue end if
		case 93 then 	if reg3 then pc = reg9 continue end if
		case 94 then 	if reg4 then pc = reg9 continue end if
		case 95 then 	if reg5 then pc = reg9 continue end if
		case 96 then 	if reg6 then pc = reg9 continue end if
		case 97 then 	if reg7 then pc = reg9 continue end if
		case 98 then 	if reg8 then pc = reg9 continue end if
		case 99 then 	if reg9 then pc = reg9 continue end if
		case 100 then	exit
		case 200 then 	reg0 = 0
		case 201 then 	reg0 = 1
		case 202 then 	reg0 = 2
		case 203 then 	reg0 = 3
		case 204 then 	reg0 = 4
		case 205 then 	reg0 = 5
		case 206 then 	reg0 = 6
		case 207 then 	reg0 = 7
		case 208 then 	reg0 = 8
		case 209 then 	reg0 = 9
		case 210 then 	reg1 = 0
		case 211 then 	reg1 = 1
		case 212 then 	reg1 = 2
		case 213 then 	reg1 = 3
		case 214 then 	reg1 = 4
		case 215 then 	reg1 = 5
		case 216 then 	reg1 = 6
		case 217 then 	reg1 = 7
		case 218 then 	reg1 = 8
		case 219 then 	reg1 = 9
		case 220 then 	reg2 = 0
		case 221 then 	reg2 = 1
		case 222 then 	reg2 = 2
		case 223 then 	reg2 = 3
		case 224 then 	reg2 = 4
		case 225 then 	reg2 = 5
		case 226 then 	reg2 = 6
		case 227 then 	reg2 = 7
		case 228 then 	reg2 = 8
		case 229 then 	reg2 = 9
		case 230 then 	reg3 = 0
		case 231 then 	reg3 = 1
		case 232 then 	reg3 = 2
		case 233 then 	reg3 = 3
		case 234 then 	reg3 = 4
		case 235 then 	reg3 = 5
		case 236 then 	reg3 = 6
		case 237 then 	reg3 = 7
		case 238 then 	reg3 = 8
		case 239 then 	reg3 = 9
		case 240 then 	reg4 = 0
		case 241 then 	reg4 = 1
		case 242 then 	reg4 = 2
		case 243 then 	reg4 = 3
		case 244 then 	reg4 = 4
		case 245 then 	reg4 = 5
		case 246 then 	reg4 = 6
		case 247 then 	reg4 = 7
		case 248 then 	reg4 = 8
		case 249 then 	reg4 = 9
		case 250 then 	reg5 = 0
		case 251 then 	reg5 = 1
		case 252 then 	reg5 = 2
		case 253 then 	reg5 = 3
		case 254 then 	reg5 = 4
		case 255 then 	reg5 = 5
		case 256 then 	reg5 = 6
		case 257 then 	reg5 = 7
		case 258 then 	reg5 = 8
		case 259 then 	reg5 = 9
		case 260 then 	reg6 = 0
		case 261 then 	reg6 = 1
		case 262 then 	reg6 = 2
		case 263 then 	reg6 = 3
		case 264 then 	reg6 = 4
		case 265 then 	reg6 = 5
		case 266 then 	reg6 = 6
		case 267 then 	reg6 = 7
		case 268 then 	reg6 = 8
		case 269 then 	reg6 = 9
		case 270 then 	reg7 = 0
		case 271 then 	reg7 = 1
		case 272 then 	reg7 = 2
		case 273 then 	reg7 = 3
		case 274 then 	reg7 = 4
		case 275 then 	reg7 = 5
		case 276 then 	reg7 = 6
		case 277 then 	reg7 = 7
		case 278 then 	reg7 = 8
		case 279 then 	reg7 = 9
		case 280 then 	reg8 = 0
		case 281 then 	reg8 = 1
		case 282 then 	reg8 = 2
		case 283 then 	reg8 = 3
		case 284 then 	reg8 = 4
		case 285 then 	reg8 = 5
		case 286 then 	reg8 = 6
		case 287 then 	reg8 = 7
		case 288 then 	reg8 = 8
		case 289 then 	reg8 = 9
		case 290 then 	reg9 = 0
		case 291 then 	reg9 = 1
		case 292 then 	reg9 = 2
		case 293 then 	reg9 = 3
		case 294 then 	reg9 = 4
		case 295 then 	reg9 = 5
		case 296 then 	reg9 = 6
		case 297 then 	reg9 = 7
		case 298 then 	reg9 = 8
		case 299 then 	reg9 = 9
		case 301 then 	reg0 += 1
		case 302 then 	reg0 += 2
		case 303 then 	reg0 += 3
		case 304 then 	reg0 += 4
		case 305 then 	reg0 += 5
		case 306 then 	reg0 += 6
		case 307 then 	reg0 += 7
		case 308 then 	reg0 += 8
		case 309 then 	reg0 += 9
		case 311 then 	reg1 += 1
		case 312 then 	reg1 += 2
		case 313 then 	reg1 += 3
		case 314 then 	reg1 += 4
		case 315 then 	reg1 += 5
		case 316 then 	reg1 += 6
		case 317 then 	reg1 += 7
		case 318 then 	reg1 += 8
		case 319 then 	reg1 += 9
		case 321 then 	reg2 += 1
		case 322 then 	reg2 += 2
		case 323 then 	reg2 += 3
		case 324 then 	reg2 += 4
		case 325 then 	reg2 += 5
		case 326 then 	reg2 += 6
		case 327 then 	reg2 += 7
		case 328 then 	reg2 += 8
		case 329 then 	reg2 += 9
		case 331 then 	reg3 += 1
		case 332 then 	reg3 += 2
		case 333 then 	reg3 += 3
		case 334 then 	reg3 += 4
		case 335 then 	reg3 += 5
		case 336 then 	reg3 += 6
		case 337 then 	reg3 += 7
		case 338 then 	reg3 += 8
		case 339 then 	reg3 += 9
		case 341 then 	reg4 += 1
		case 342 then 	reg4 += 2
		case 343 then 	reg4 += 3
		case 344 then 	reg4 += 4
		case 345 then 	reg4 += 5
		case 346 then 	reg4 += 6
		case 347 then 	reg4 += 7
		case 348 then 	reg4 += 8
		case 349 then 	reg4 += 9
		case 351 then 	reg5 += 1
		case 352 then 	reg5 += 2
		case 353 then 	reg5 += 3
		case 354 then 	reg5 += 4
		case 355 then 	reg5 += 5
		case 356 then 	reg5 += 6
		case 357 then 	reg5 += 7
		case 358 then 	reg5 += 8
		case 359 then 	reg5 += 9
		case 361 then 	reg6 += 1
		case 362 then 	reg6 += 2
		case 363 then 	reg6 += 3
		case 364 then 	reg6 += 4
		case 365 then 	reg6 += 5
		case 366 then 	reg6 += 6
		case 367 then 	reg6 += 7
		case 368 then 	reg6 += 8
		case 369 then 	reg6 += 9
		case 371 then 	reg7 += 1
		case 372 then 	reg7 += 2
		case 373 then 	reg7 += 3
		case 374 then 	reg7 += 4
		case 375 then 	reg7 += 5
		case 376 then 	reg7 += 6
		case 377 then 	reg7 += 7
		case 378 then 	reg7 += 8
		case 379 then 	reg7 += 9
		case 381 then 	reg8 += 1
		case 382 then 	reg8 += 2
		case 383 then 	reg8 += 3
		case 384 then 	reg8 += 4
		case 385 then 	reg8 += 5
		case 386 then 	reg8 += 6
		case 387 then 	reg8 += 7
		case 388 then 	reg8 += 8
		case 389 then 	reg8 += 9
		case 391 then 	reg9 += 1
		case 392 then 	reg9 += 2
		case 393 then 	reg9 += 3
		case 394 then 	reg9 += 4
		case 395 then 	reg9 += 5
		case 396 then 	reg9 += 6
		case 397 then 	reg9 += 7
		case 398 then 	reg9 += 8
		case 399 then 	reg9 += 9
		case 400 then 	reg0 *= 0
		case 402 then 	reg0 *= 2
		case 403 then 	reg0 *= 3
		case 404 then 	reg0 *= 4
		case 405 then 	reg0 *= 5
		case 406 then 	reg0 *= 6
		case 407 then 	reg0 *= 7
		case 408 then 	reg0 *= 8
		case 409 then 	reg0 *= 9
		case 410 then 	reg1 *= 0
		case 412 then 	reg1 *= 2
		case 413 then 	reg1 *= 3
		case 414 then 	reg1 *= 4
		case 415 then 	reg1 *= 5
		case 416 then 	reg1 *= 6
		case 417 then 	reg1 *= 7
		case 418 then 	reg1 *= 8
		case 419 then 	reg1 *= 9
		case 420 then 	reg2 *= 0
		case 422 then 	reg2 *= 2
		case 423 then 	reg2 *= 3
		case 424 then 	reg2 *= 4
		case 425 then 	reg2 *= 5
		case 426 then 	reg2 *= 6
		case 427 then 	reg2 *= 7
		case 428 then 	reg2 *= 8
		case 429 then 	reg2 *= 9
		case 430 then 	reg3 *= 0
		case 432 then 	reg3 *= 2
		case 433 then 	reg3 *= 3
		case 434 then 	reg3 *= 4
		case 435 then 	reg3 *= 5
		case 436 then 	reg3 *= 6
		case 437 then 	reg3 *= 7
		case 438 then 	reg3 *= 8
		case 439 then 	reg3 *= 9
		case 440 then 	reg4 *= 0
		case 442 then 	reg4 *= 2
		case 443 then 	reg4 *= 3
		case 444 then 	reg4 *= 4
		case 445 then 	reg4 *= 5
		case 446 then 	reg4 *= 6
		case 447 then 	reg4 *= 7
		case 448 then 	reg4 *= 8
		case 449 then 	reg4 *= 9
		case 450 then 	reg5 *= 0
		case 452 then 	reg5 *= 2
		case 453 then 	reg5 *= 3
		case 454 then 	reg5 *= 4
		case 455 then 	reg5 *= 5
		case 456 then 	reg5 *= 6
		case 457 then 	reg5 *= 7
		case 458 then 	reg5 *= 8
		case 459 then 	reg5 *= 9
		case 460 then 	reg6 *= 0
		case 462 then 	reg6 *= 2
		case 463 then 	reg6 *= 3
		case 464 then 	reg6 *= 4
		case 465 then 	reg6 *= 5
		case 466 then 	reg6 *= 6
		case 467 then 	reg6 *= 7
		case 468 then 	reg6 *= 8
		case 469 then 	reg6 *= 9
		case 470 then 	reg7 *= 0
		case 472 then 	reg7 *= 2
		case 473 then 	reg7 *= 3
		case 474 then 	reg7 *= 4
		case 475 then 	reg7 *= 5
		case 476 then 	reg7 *= 6
		case 477 then 	reg7 *= 7
		case 478 then 	reg7 *= 8
		case 479 then 	reg7 *= 9
		case 480 then 	reg8 *= 0
		case 482 then 	reg8 *= 2
		case 483 then 	reg8 *= 3
		case 484 then 	reg8 *= 4
		case 485 then 	reg8 *= 5
		case 486 then 	reg8 *= 6
		case 487 then 	reg8 *= 7
		case 488 then 	reg8 *= 8
		case 489 then 	reg8 *= 9
		case 490 then 	reg9 *= 0
		case 492 then 	reg9 *= 2
		case 493 then 	reg9 *= 3
		case 494 then 	reg9 *= 4
		case 495 then 	reg9 *= 5
		case 496 then 	reg9 *= 6
		case 497 then 	reg9 *= 7
		case 498 then 	reg9 *= 8
		case 499 then 	reg9 *= 9
		case 501 then 	reg0 = reg1
		case 502 then 	reg0 = reg2
		case 503 then 	reg0 = reg3
		case 504 then 	reg0 = reg4
		case 505 then 	reg0 = reg5
		case 506 then 	reg0 = reg6
		case 507 then 	reg0 = reg7
		case 508 then 	reg0 = reg8
		case 509 then 	reg0 = reg9
		case 510 then 	reg1 = reg0
		case 512 then 	reg1 = reg2
		case 513 then 	reg1 = reg3
		case 514 then 	reg1 = reg4
		case 515 then 	reg1 = reg5
		case 516 then 	reg1 = reg6
		case 517 then 	reg1 = reg7
		case 518 then 	reg1 = reg8
		case 519 then 	reg1 = reg9
		case 520 then 	reg2 = reg0
		case 521 then 	reg2 = reg1
		case 523 then 	reg2 = reg3
		case 524 then 	reg2 = reg4
		case 525 then 	reg2 = reg5
		case 526 then 	reg2 = reg6
		case 527 then 	reg2 = reg7
		case 528 then 	reg2 = reg8
		case 529 then 	reg2 = reg9
		case 530 then 	reg3 = reg0
		case 531 then 	reg3 = reg1
		case 532 then 	reg3 = reg2
		case 534 then 	reg3 = reg4
		case 535 then 	reg3 = reg5
		case 536 then 	reg3 = reg6
		case 537 then 	reg3 = reg7
		case 538 then 	reg3 = reg8
		case 539 then 	reg3 = reg9
		case 540 then 	reg4 = reg0
		case 541 then 	reg4 = reg1
		case 542 then 	reg4 = reg2
		case 543 then 	reg4 = reg3
		case 545 then 	reg4 = reg5
		case 546 then 	reg4 = reg6
		case 547 then 	reg4 = reg7
		case 548 then 	reg4 = reg8
		case 549 then 	reg4 = reg9
		case 550 then 	reg5 = reg0
		case 551 then 	reg5 = reg1
		case 552 then 	reg5 = reg2
		case 553 then 	reg5 = reg3
		case 554 then 	reg5 = reg4
		case 556 then 	reg5 = reg6
		case 557 then 	reg5 = reg7
		case 558 then 	reg5 = reg8
		case 559 then 	reg5 = reg9
		case 560 then 	reg6 = reg0
		case 561 then 	reg6 = reg1
		case 562 then 	reg6 = reg2
		case 563 then 	reg6 = reg3
		case 564 then 	reg6 = reg4
		case 565 then 	reg6 = reg5
		case 567 then 	reg6 = reg7
		case 568 then 	reg6 = reg8
		case 569 then 	reg6 = reg9
		case 570 then 	reg7 = reg0
		case 571 then 	reg7 = reg1
		case 572 then 	reg7 = reg2
		case 573 then 	reg7 = reg3
		case 574 then 	reg7 = reg4
		case 575 then 	reg7 = reg5
		case 576 then 	reg7 = reg6
		case 578 then 	reg7 = reg8
		case 579 then 	reg7 = reg9
		case 580 then 	reg8 = reg0
		case 581 then 	reg8 = reg1
		case 582 then 	reg8 = reg2
		case 583 then 	reg8 = reg3
		case 584 then 	reg8 = reg4
		case 585 then 	reg8 = reg5
		case 586 then 	reg8 = reg6
		case 587 then 	reg8 = reg7
		case 589 then 	reg8 = reg9
		case 590 then 	reg9 = reg0
		case 591 then 	reg9 = reg1
		case 592 then 	reg9 = reg2
		case 593 then 	reg9 = reg3
		case 594 then 	reg9 = reg4
		case 595 then 	reg9 = reg5
		case 596 then 	reg9 = reg6
		case 597 then 	reg9 = reg7
		case 598 then 	reg9 = reg8
		case 600 then 	reg0 += reg0
		case 601 then 	reg0 += reg1
		case 602 then 	reg0 += reg2
		case 603 then 	reg0 += reg3
		case 604 then 	reg0 += reg4
		case 605 then 	reg0 += reg5
		case 606 then 	reg0 += reg6
		case 607 then 	reg0 += reg7
		case 608 then 	reg0 += reg8
		case 609 then 	reg0 += reg9
		case 610 then 	reg1 += reg0
		case 611 then 	reg1 += reg1
		case 612 then 	reg1 += reg2
		case 613 then 	reg1 += reg3
		case 614 then 	reg1 += reg4
		case 615 then 	reg1 += reg5
		case 616 then 	reg1 += reg6
		case 617 then 	reg1 += reg7
		case 618 then 	reg1 += reg8
		case 619 then 	reg1 += reg9
		case 620 then 	reg2 += reg0
		case 621 then 	reg2 += reg1
		case 622 then 	reg2 += reg2
		case 623 then 	reg2 += reg3
		case 624 then 	reg2 += reg4
		case 625 then 	reg2 += reg5
		case 626 then 	reg2 += reg6
		case 627 then 	reg2 += reg7
		case 628 then 	reg2 += reg8
		case 629 then 	reg2 += reg9
		case 630 then 	reg3 += reg0
		case 631 then 	reg3 += reg1
		case 632 then 	reg3 += reg2
		case 633 then 	reg3 += reg3
		case 634 then 	reg3 += reg4
		case 635 then 	reg3 += reg5
		case 636 then 	reg3 += reg6
		case 637 then 	reg3 += reg7
		case 638 then 	reg3 += reg8
		case 639 then 	reg3 += reg9
		case 640 then 	reg4 += reg0
		case 641 then 	reg4 += reg1
		case 642 then 	reg4 += reg2
		case 643 then 	reg4 += reg3
		case 644 then 	reg4 += reg4
		case 645 then 	reg4 += reg5
		case 646 then 	reg4 += reg6
		case 647 then 	reg4 += reg7
		case 648 then 	reg4 += reg8
		case 649 then 	reg4 += reg9
		case 650 then 	reg5 += reg0
		case 651 then 	reg5 += reg1
		case 652 then 	reg5 += reg2
		case 653 then 	reg5 += reg3
		case 654 then 	reg5 += reg4
		case 655 then 	reg5 += reg5
		case 656 then 	reg5 += reg6
		case 657 then 	reg5 += reg7
		case 658 then 	reg5 += reg8
		case 659 then 	reg5 += reg9
		case 660 then 	reg6 += reg0
		case 661 then 	reg6 += reg1
		case 662 then 	reg6 += reg2
		case 663 then 	reg6 += reg3
		case 664 then 	reg6 += reg4
		case 665 then 	reg6 += reg5
		case 666 then 	reg6 += reg6
		case 667 then 	reg6 += reg7
		case 668 then 	reg6 += reg8
		case 669 then 	reg6 += reg9
		case 670 then 	reg7 += reg0
		case 671 then 	reg7 += reg1
		case 672 then 	reg7 += reg2
		case 673 then 	reg7 += reg3
		case 674 then 	reg7 += reg4
		case 675 then 	reg7 += reg5
		case 676 then 	reg7 += reg6
		case 677 then 	reg7 += reg7
		case 678 then 	reg7 += reg8
		case 679 then 	reg7 += reg9
		case 680 then 	reg8 += reg0
		case 681 then 	reg8 += reg1
		case 682 then 	reg8 += reg2
		case 683 then 	reg8 += reg3
		case 684 then 	reg8 += reg4
		case 685 then 	reg8 += reg5
		case 686 then 	reg8 += reg6
		case 687 then 	reg8 += reg7
		case 688 then 	reg8 += reg8
		case 689 then 	reg8 += reg9
		case 690 then 	reg9 += reg0
		case 691 then 	reg9 += reg1
		case 692 then 	reg9 += reg2
		case 693 then 	reg9 += reg3
		case 694 then 	reg9 += reg4
		case 695 then 	reg9 += reg5
		case 696 then 	reg9 += reg6
		case 697 then 	reg9 += reg7
		case 698 then 	reg9 += reg8
		case 699 then 	reg9 += reg9
		case 700 then 	reg0 *= reg0
		case 701 then 	reg0 *= reg1
		case 702 then 	reg0 *= reg2
		case 703 then 	reg0 *= reg3
		case 704 then 	reg0 *= reg4
		case 705 then 	reg0 *= reg5
		case 706 then 	reg0 *= reg6
		case 707 then 	reg0 *= reg7
		case 708 then 	reg0 *= reg8
		case 709 then 	reg0 *= reg9
		case 710 then 	reg1 *= reg0
		case 711 then 	reg1 *= reg1
		case 712 then 	reg1 *= reg2
		case 713 then 	reg1 *= reg3
		case 714 then 	reg1 *= reg4
		case 715 then 	reg1 *= reg5
		case 716 then 	reg1 *= reg6
		case 717 then 	reg1 *= reg7
		case 718 then 	reg1 *= reg8
		case 719 then 	reg1 *= reg9
		case 720 then 	reg2 *= reg0
		case 721 then 	reg2 *= reg1
		case 722 then 	reg2 *= reg2
		case 723 then 	reg2 *= reg3
		case 724 then 	reg2 *= reg4
		case 725 then 	reg2 *= reg5
		case 726 then 	reg2 *= reg6
		case 727 then 	reg2 *= reg7
		case 728 then 	reg2 *= reg8
		case 729 then 	reg2 *= reg9
		case 730 then 	reg3 *= reg0
		case 731 then 	reg3 *= reg1
		case 732 then 	reg3 *= reg2
		case 733 then 	reg3 *= reg3
		case 734 then 	reg3 *= reg4
		case 735 then 	reg3 *= reg5
		case 736 then 	reg3 *= reg6
		case 737 then 	reg3 *= reg7
		case 738 then 	reg3 *= reg8
		case 739 then 	reg3 *= reg9
		case 740 then 	reg4 *= reg0
		case 741 then 	reg4 *= reg1
		case 742 then 	reg4 *= reg2
		case 743 then 	reg4 *= reg3
		case 744 then 	reg4 *= reg4
		case 745 then 	reg4 *= reg5
		case 746 then 	reg4 *= reg6
		case 747 then 	reg4 *= reg7
		case 748 then 	reg4 *= reg8
		case 749 then 	reg4 *= reg9
		case 750 then 	reg5 *= reg0
		case 751 then 	reg5 *= reg1
		case 752 then 	reg5 *= reg2
		case 753 then 	reg5 *= reg3
		case 754 then 	reg5 *= reg4
		case 755 then 	reg5 *= reg5
		case 756 then 	reg5 *= reg6
		case 757 then 	reg5 *= reg7
		case 758 then 	reg5 *= reg8
		case 759 then 	reg5 *= reg9
		case 760 then 	reg6 *= reg0
		case 761 then 	reg6 *= reg1
		case 762 then 	reg6 *= reg2
		case 763 then 	reg6 *= reg3
		case 764 then 	reg6 *= reg4
		case 765 then 	reg6 *= reg5
		case 766 then 	reg6 *= reg6
		case 767 then 	reg6 *= reg7
		case 768 then 	reg6 *= reg8
		case 769 then 	reg6 *= reg9
		case 770 then 	reg7 *= reg0
		case 771 then 	reg7 *= reg1
		case 772 then 	reg7 *= reg2
		case 773 then 	reg7 *= reg3
		case 774 then 	reg7 *= reg4
		case 775 then 	reg7 *= reg5
		case 776 then 	reg7 *= reg6
		case 777 then 	reg7 *= reg7
		case 778 then 	reg7 *= reg8
		case 779 then 	reg7 *= reg9
		case 780 then 	reg8 *= reg0
		case 781 then 	reg8 *= reg1
		case 782 then 	reg8 *= reg2
		case 783 then 	reg8 *= reg3
		case 784 then 	reg8 *= reg4
		case 785 then 	reg8 *= reg5
		case 786 then 	reg8 *= reg6
		case 787 then 	reg8 *= reg7
		case 788 then 	reg8 *= reg8
		case 789 then 	reg8 *= reg9
		case 790 then 	reg9 *= reg0
		case 791 then 	reg9 *= reg1
		case 792 then 	reg9 *= reg2
		case 793 then 	reg9 *= reg3
		case 794 then 	reg9 *= reg4
		case 795 then 	reg9 *= reg5
		case 796 then 	reg9 *= reg6
		case 797 then 	reg9 *= reg7
		case 798 then 	reg9 *= reg8
		case 799 then 	reg9 *= reg9
		case 800 then 	ptr = reg0 ptr +=1 reg0 = ram[ptr]
		case 801 then 	ptr = reg1 ptr +=1 reg0 = ram[ptr]
		case 802 then 	ptr = reg2 ptr +=1 reg0 = ram[ptr]
		case 803 then 	ptr = reg3 ptr +=1 reg0 = ram[ptr]
		case 804 then 	ptr = reg4 ptr +=1 reg0 = ram[ptr]
		case 805 then 	ptr = reg5 ptr +=1 reg0 = ram[ptr]
		case 806 then 	ptr = reg6 ptr +=1 reg0 = ram[ptr]
		case 807 then 	ptr = reg7 ptr +=1 reg0 = ram[ptr]
		case 808 then 	ptr = reg8 ptr +=1 reg0 = ram[ptr]
		case 809 then 	ptr = reg9 ptr +=1 reg0 = ram[ptr]
		case 810 then 	ptr = reg0 ptr +=1 reg1 = ram[ptr]
		case 811 then 	ptr = reg1 ptr +=1 reg1 = ram[ptr]
		case 812 then 	ptr = reg2 ptr +=1 reg1 = ram[ptr]
		case 813 then 	ptr = reg3 ptr +=1 reg1 = ram[ptr]
		case 814 then 	ptr = reg4 ptr +=1 reg1 = ram[ptr]
		case 815 then 	ptr = reg5 ptr +=1 reg1 = ram[ptr]
		case 816 then 	ptr = reg6 ptr +=1 reg1 = ram[ptr]
		case 817 then 	ptr = reg7 ptr +=1 reg1 = ram[ptr]
		case 818 then 	ptr = reg8 ptr +=1 reg1 = ram[ptr]
		case 819 then 	ptr = reg9 ptr +=1 reg1 = ram[ptr]
		case 820 then 	ptr = reg0 ptr +=1 reg2 = ram[ptr]
		case 821 then 	ptr = reg1 ptr +=1 reg2 = ram[ptr]
		case 822 then 	ptr = reg2 ptr +=1 reg2 = ram[ptr]
		case 823 then 	ptr = reg3 ptr +=1 reg2 = ram[ptr]
		case 824 then 	ptr = reg4 ptr +=1 reg2 = ram[ptr]
		case 825 then 	ptr = reg5 ptr +=1 reg2 = ram[ptr]
		case 826 then 	ptr = reg6 ptr +=1 reg2 = ram[ptr]
		case 827 then 	ptr = reg7 ptr +=1 reg2 = ram[ptr]
		case 828 then 	ptr = reg8 ptr +=1 reg2 = ram[ptr]
		case 829 then 	ptr = reg9 ptr +=1 reg2 = ram[ptr]
		case 830 then 	ptr = reg0 ptr +=1 reg3 = ram[ptr]
		case 831 then 	ptr = reg1 ptr +=1 reg3 = ram[ptr]
		case 832 then 	ptr = reg2 ptr +=1 reg3 = ram[ptr]
		case 833 then 	ptr = reg3 ptr +=1 reg3 = ram[ptr]
		case 834 then 	ptr = reg4 ptr +=1 reg3 = ram[ptr]
		case 835 then 	ptr = reg5 ptr +=1 reg3 = ram[ptr]
		case 836 then 	ptr = reg6 ptr +=1 reg3 = ram[ptr]
		case 837 then 	ptr = reg7 ptr +=1 reg3 = ram[ptr]
		case 838 then 	ptr = reg8 ptr +=1 reg3 = ram[ptr]
		case 839 then 	ptr = reg9 ptr +=1 reg3 = ram[ptr]
		case 840 then 	ptr = reg0 ptr +=1 reg4 = ram[ptr]
		case 841 then 	ptr = reg1 ptr +=1 reg4 = ram[ptr]
		case 842 then 	ptr = reg2 ptr +=1 reg4 = ram[ptr]
		case 843 then 	ptr = reg3 ptr +=1 reg4 = ram[ptr]
		case 844 then 	ptr = reg4 ptr +=1 reg4 = ram[ptr]
		case 845 then 	ptr = reg5 ptr +=1 reg4 = ram[ptr]
		case 846 then 	ptr = reg6 ptr +=1 reg4 = ram[ptr]
		case 847 then 	ptr = reg7 ptr +=1 reg4 = ram[ptr]
		case 848 then 	ptr = reg8 ptr +=1 reg4 = ram[ptr]
		case 849 then 	ptr = reg9 ptr +=1 reg4 = ram[ptr]
		case 850 then 	ptr = reg0 ptr +=1 reg5 = ram[ptr]
		case 851 then 	ptr = reg1 ptr +=1 reg5 = ram[ptr]
		case 852 then 	ptr = reg2 ptr +=1 reg5 = ram[ptr]
		case 853 then 	ptr = reg3 ptr +=1 reg5 = ram[ptr]
		case 854 then 	ptr = reg4 ptr +=1 reg5 = ram[ptr]
		case 855 then 	ptr = reg5 ptr +=1 reg5 = ram[ptr]
		case 856 then 	ptr = reg6 ptr +=1 reg5 = ram[ptr]
		case 857 then 	ptr = reg7 ptr +=1 reg5 = ram[ptr]
		case 858 then 	ptr = reg8 ptr +=1 reg5 = ram[ptr]
		case 859 then 	ptr = reg9 ptr +=1 reg5 = ram[ptr]
		case 860 then 	ptr = reg0 ptr +=1 reg6 = ram[ptr]
		case 861 then 	ptr = reg1 ptr +=1 reg6 = ram[ptr]
		case 862 then 	ptr = reg2 ptr +=1 reg6 = ram[ptr]
		case 863 then 	ptr = reg3 ptr +=1 reg6 = ram[ptr]
		case 864 then 	ptr = reg4 ptr +=1 reg6 = ram[ptr]
		case 865 then 	ptr = reg5 ptr +=1 reg6 = ram[ptr]
		case 866 then 	ptr = reg6 ptr +=1 reg6 = ram[ptr]
		case 867 then 	ptr = reg7 ptr +=1 reg6 = ram[ptr]
		case 868 then 	ptr = reg8 ptr +=1 reg6 = ram[ptr]
		case 869 then 	ptr = reg9 ptr +=1 reg6 = ram[ptr]
		case 870 then 	ptr = reg0 ptr +=1 reg7 = ram[ptr]
		case 871 then 	ptr = reg1 ptr +=1 reg7 = ram[ptr]
		case 872 then 	ptr = reg2 ptr +=1 reg7 = ram[ptr]
		case 873 then 	ptr = reg3 ptr +=1 reg7 = ram[ptr]
		case 874 then 	ptr = reg4 ptr +=1 reg7 = ram[ptr]
		case 875 then 	ptr = reg5 ptr +=1 reg7 = ram[ptr]
		case 876 then 	ptr = reg6 ptr +=1 reg7 = ram[ptr]
		case 877 then 	ptr = reg7 ptr +=1 reg7 = ram[ptr]
		case 878 then 	ptr = reg8 ptr +=1 reg7 = ram[ptr]
		case 879 then 	ptr = reg9 ptr +=1 reg7 = ram[ptr]
		case 880 then 	ptr = reg0 ptr +=1 reg8 = ram[ptr]
		case 881 then 	ptr = reg1 ptr +=1 reg8 = ram[ptr]
		case 882 then 	ptr = reg2 ptr +=1 reg8 = ram[ptr]
		case 883 then 	ptr = reg3 ptr +=1 reg8 = ram[ptr]
		case 884 then 	ptr = reg4 ptr +=1 reg8 = ram[ptr]
		case 885 then 	ptr = reg5 ptr +=1 reg8 = ram[ptr]
		case 886 then 	ptr = reg6 ptr +=1 reg8 = ram[ptr]
		case 887 then 	ptr = reg7 ptr +=1 reg8 = ram[ptr]
		case 888 then 	ptr = reg8 ptr +=1 reg8 = ram[ptr]
		case 889 then 	ptr = reg9 ptr +=1 reg8 = ram[ptr]
		case 890 then 	ptr = reg0 ptr +=1 reg9 = ram[ptr]
		case 891 then 	ptr = reg1 ptr +=1 reg9 = ram[ptr]
		case 892 then 	ptr = reg2 ptr +=1 reg9 = ram[ptr]
		case 893 then 	ptr = reg3 ptr +=1 reg9 = ram[ptr]
		case 894 then 	ptr = reg4 ptr +=1 reg9 = ram[ptr]
		case 895 then 	ptr = reg5 ptr +=1 reg9 = ram[ptr]
		case 896 then 	ptr = reg6 ptr +=1 reg9 = ram[ptr]
		case 897 then 	ptr = reg7 ptr +=1 reg9 = ram[ptr]
		case 898 then 	ptr = reg8 ptr +=1 reg9 = ram[ptr]
		case 899 then 	ptr = reg9 ptr +=1 reg9 = ram[ptr]
		case 900 then 	ptr = reg0 ptr += 1 ram[ptr] = reg0
		case 901 then 	ptr = reg1 ptr += 1 ram[ptr] = reg0
		case 902 then 	ptr = reg2 ptr += 1 ram[ptr] = reg0
		case 903 then 	ptr = reg3 ptr += 1 ram[ptr] = reg0
		case 904 then 	ptr = reg4 ptr += 1 ram[ptr] = reg0
		case 905 then 	ptr = reg5 ptr += 1 ram[ptr] = reg0
		case 906 then 	ptr = reg6 ptr += 1 ram[ptr] = reg0
		case 907 then 	ptr = reg7 ptr += 1 ram[ptr] = reg0
		case 908 then 	ptr = reg8 ptr += 1 ram[ptr] = reg0
		case 909 then 	ptr = reg9 ptr += 1 ram[ptr] = reg0
		case 910 then 	ptr = reg0 ptr += 1 ram[ptr] = reg1
		case 911 then 	ptr = reg1 ptr += 1 ram[ptr] = reg1
		case 912 then 	ptr = reg2 ptr += 1 ram[ptr] = reg1
		case 913 then 	ptr = reg3 ptr += 1 ram[ptr] = reg1
		case 914 then 	ptr = reg4 ptr += 1 ram[ptr] = reg1
		case 915 then 	ptr = reg5 ptr += 1 ram[ptr] = reg1
		case 916 then 	ptr = reg6 ptr += 1 ram[ptr] = reg1
		case 917 then 	ptr = reg7 ptr += 1 ram[ptr] = reg1
		case 918 then 	ptr = reg8 ptr += 1 ram[ptr] = reg1
		case 919 then 	ptr = reg9 ptr += 1 ram[ptr] = reg1
		case 920 then 	ptr = reg0 ptr += 1 ram[ptr] = reg2
		case 921 then 	ptr = reg1 ptr += 1 ram[ptr] = reg2
		case 922 then 	ptr = reg2 ptr += 1 ram[ptr] = reg2
		case 923 then 	ptr = reg3 ptr += 1 ram[ptr] = reg2
		case 924 then 	ptr = reg4 ptr += 1 ram[ptr] = reg2
		case 925 then 	ptr = reg5 ptr += 1 ram[ptr] = reg2
		case 926 then 	ptr = reg6 ptr += 1 ram[ptr] = reg2
		case 927 then 	ptr = reg7 ptr += 1 ram[ptr] = reg2
		case 928 then 	ptr = reg8 ptr += 1 ram[ptr] = reg2
		case 929 then 	ptr = reg9 ptr += 1 ram[ptr] = reg2
		case 930 then 	ptr = reg0 ptr += 1 ram[ptr] = reg3
		case 931 then 	ptr = reg1 ptr += 1 ram[ptr] = reg3
		case 932 then 	ptr = reg2 ptr += 1 ram[ptr] = reg3
		case 933 then 	ptr = reg3 ptr += 1 ram[ptr] = reg3
		case 934 then 	ptr = reg4 ptr += 1 ram[ptr] = reg3
		case 935 then 	ptr = reg5 ptr += 1 ram[ptr] = reg3
		case 936 then 	ptr = reg6 ptr += 1 ram[ptr] = reg3
		case 937 then 	ptr = reg7 ptr += 1 ram[ptr] = reg3
		case 938 then 	ptr = reg8 ptr += 1 ram[ptr] = reg3
		case 939 then 	ptr = reg9 ptr += 1 ram[ptr] = reg3
		case 940 then 	ptr = reg0 ptr += 1 ram[ptr] = reg4
		case 941 then 	ptr = reg1 ptr += 1 ram[ptr] = reg4
		case 942 then 	ptr = reg2 ptr += 1 ram[ptr] = reg4
		case 943 then 	ptr = reg3 ptr += 1 ram[ptr] = reg4
		case 944 then 	ptr = reg4 ptr += 1 ram[ptr] = reg4
		case 945 then 	ptr = reg5 ptr += 1 ram[ptr] = reg4
		case 946 then 	ptr = reg6 ptr += 1 ram[ptr] = reg4
		case 947 then 	ptr = reg7 ptr += 1 ram[ptr] = reg4
		case 948 then 	ptr = reg8 ptr += 1 ram[ptr] = reg4
		case 949 then 	ptr = reg9 ptr += 1 ram[ptr] = reg4
		case 950 then 	ptr = reg0 ptr += 1 ram[ptr] = reg5
		case 951 then 	ptr = reg1 ptr += 1 ram[ptr] = reg5
		case 952 then 	ptr = reg2 ptr += 1 ram[ptr] = reg5
		case 953 then 	ptr = reg3 ptr += 1 ram[ptr] = reg5
		case 954 then 	ptr = reg4 ptr += 1 ram[ptr] = reg5
		case 955 then 	ptr = reg5 ptr += 1 ram[ptr] = reg5
		case 956 then 	ptr = reg6 ptr += 1 ram[ptr] = reg5
		case 957 then 	ptr = reg7 ptr += 1 ram[ptr] = reg5
		case 958 then 	ptr = reg8 ptr += 1 ram[ptr] = reg5
		case 959 then 	ptr = reg9 ptr += 1 ram[ptr] = reg5
		case 960 then 	ptr = reg0 ptr += 1 ram[ptr] = reg6
		case 961 then 	ptr = reg1 ptr += 1 ram[ptr] = reg6
		case 962 then 	ptr = reg2 ptr += 1 ram[ptr] = reg6
		case 963 then 	ptr = reg3 ptr += 1 ram[ptr] = reg6
		case 964 then 	ptr = reg4 ptr += 1 ram[ptr] = reg6
		case 965 then 	ptr = reg5 ptr += 1 ram[ptr] = reg6
		case 966 then 	ptr = reg6 ptr += 1 ram[ptr] = reg6
		case 967 then 	ptr = reg7 ptr += 1 ram[ptr] = reg6
		case 968 then 	ptr = reg8 ptr += 1 ram[ptr] = reg6
		case 969 then 	ptr = reg9 ptr += 1 ram[ptr] = reg6
		case 970 then 	ptr = reg0 ptr += 1 ram[ptr] = reg7
		case 971 then 	ptr = reg1 ptr += 1 ram[ptr] = reg7
		case 972 then 	ptr = reg2 ptr += 1 ram[ptr] = reg7
		case 973 then 	ptr = reg3 ptr += 1 ram[ptr] = reg7
		case 974 then 	ptr = reg4 ptr += 1 ram[ptr] = reg7
		case 975 then 	ptr = reg5 ptr += 1 ram[ptr] = reg7
		case 976 then 	ptr = reg6 ptr += 1 ram[ptr] = reg7
		case 977 then 	ptr = reg7 ptr += 1 ram[ptr] = reg7
		case 978 then 	ptr = reg8 ptr += 1 ram[ptr] = reg7
		case 979 then 	ptr = reg9 ptr += 1 ram[ptr] = reg7
		case 980 then 	ptr = reg0 ptr += 1 ram[ptr] = reg8
		case 981 then 	ptr = reg1 ptr += 1 ram[ptr] = reg8
		case 982 then 	ptr = reg2 ptr += 1 ram[ptr] = reg8
		case 983 then 	ptr = reg3 ptr += 1 ram[ptr] = reg8
		case 984 then 	ptr = reg4 ptr += 1 ram[ptr] = reg8
		case 985 then 	ptr = reg5 ptr += 1 ram[ptr] = reg8
		case 986 then 	ptr = reg6 ptr += 1 ram[ptr] = reg8
		case 987 then 	ptr = reg7 ptr += 1 ram[ptr] = reg8
		case 988 then 	ptr = reg8 ptr += 1 ram[ptr] = reg8
		case 989 then 	ptr = reg9 ptr += 1 ram[ptr] = reg8
		case 990 then 	ptr = reg0 ptr += 1 ram[ptr] = reg9
		case 991 then 	ptr = reg1 ptr += 1 ram[ptr] = reg9
		case 992 then 	ptr = reg2 ptr += 1 ram[ptr] = reg9
		case 993 then 	ptr = reg3 ptr += 1 ram[ptr] = reg9
		case 994 then 	ptr = reg4 ptr += 1 ram[ptr] = reg9
		case 995 then 	ptr = reg5 ptr += 1 ram[ptr] = reg9
		case 996 then 	ptr = reg6 ptr += 1 ram[ptr] = reg9
		case 997 then 	ptr = reg7 ptr += 1 ram[ptr] = reg9
		case 998 then 	ptr = reg8 ptr += 1 ram[ptr] = reg9
		case 999 then 	ptr = reg9 ptr += 1 ram[ptr] = reg9
		case 1001 then ? reg0
		case 1011 then printf(1,"%d ", reg0 )
		case 1002 then ? reg1
		case 1012 then printf(1,"%d ", reg1 )
		case 1003 then ? reg2
		case 1013 then printf(1,"%d ", reg2 )
		case 1004 then ? reg3
		case 1014 then printf(1,"%d ", reg3 )
		case 1005 then ? reg4
		case 1015 then printf(1,"%d ", reg4 )
		case 1006 then ? reg5
		case 1016 then printf(1,"%d ", reg5 )
		case 1007 then ? reg6
		case 1017 then printf(1,"%d ", reg6 )
		case 1008 then ? reg7
		case 1018 then printf(1,"%d ", reg7 )
		case 1009 then ? reg8
		case 1019 then printf(1,"%d ", reg8 )
		case 1010 then ? reg9
		case 1020 then printf(1,"%d ", reg9 )
	end switch
end while

ifdef STEPS then
	printf(1, "\nsteps: %d\n", steps )
end ifdef
