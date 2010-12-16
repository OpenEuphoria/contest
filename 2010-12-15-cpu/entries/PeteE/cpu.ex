#!/usr/bin/eui
-- User: PeteE
-- Contest 2 virtual machine

include std/io.e
include std/cmdline.e
include std/convert.e

constant cmd_line = command_line()
sequence
  prog = read_lines(cmd_line[3]),
  reg = repeat(0, 10),  -- 10 registers
  ram = -1 & repeat(0, 999), -- 1000 ramz
  op

integer
  ip = 1, -- instruction pointer
  d, -- first operand
  n  -- second operand

while ip <= length(prog) label "main" do
  op = prog[ip]
  ip += 1  -- next instruction
  if length(op) < 2 then
    continue
  end if
  d = op[2]-'0'+1
  if length(op) > 2 then
    n = op[3]-'0'+1
  end if

  switch op[1] do
  case '1' then
    -- 100| halt
    if d = 1 and n = 1 then
      exit "main"
    end if
    break
  case '2' then
    -- 2dn| set register d to n
    reg[d] = n-1
    break
  case '3' then
    -- 3dn| add n to register d
    reg[d] += n-1
    break
  case '4' then
    -- 4dn| multiply register d by n
    reg[d] *= n-1
    break
  case '5' then
    -- 5dn| set register d to the value of register n
    reg[d] = reg[n]
    break
  case '6' then
    -- 6dn| add the value of register n to register d
    reg[d] += reg[n]
    break
  case '7' then
    -- 7dn| multiply register d by the value of register n
    reg[d] *= reg[n]
    break
  case '8' then
    -- 8dn| set register d to the value in RAM whose address is in register n
    reg[d] = ram[reg[n]+1]
    break
  case '9' then
    -- 9dn| set the value in RAM whose address is in register n to that of register d
    ram[reg[n]+1] = reg[d]
    break
  case '0' then
    -- 9dn| goto the location in register d unless register n contains 0
    if reg[n] then
      ip = reg[d]+1  -- program is zero-based, but sequence is 1-based
      continue "main"
    end if
  case '?' then
    if op[2] != '?' then
      -- ?d | print the value of register d with a trailing newline
      printf(STDOUT, "%d\n", reg[d])
    else
      -- ??n | print the value of register n followed by a space
      printf(STDOUT, "%d ", reg[n])
    end if
  end switch
end while
