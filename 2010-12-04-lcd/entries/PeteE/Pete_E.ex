--
-- User: Pete_E
--
-- Speed: 0.023635 per iteration
--
-- Points: 9
--
-- Bonus Points:
--   (1) top 20% for size
--   (1) followed spec
--   (1) used 4.0
--   (1) optional scaling
--
-- 4.0 features:
--   (1) assign on create
--   (1) ignore function result
--
-- 4.0 methods:
--   (1) join
--   (1) columnize
--   (1) to_integer
--

include std/sequence.e
include std/convert.e

constant segmap = {
   "||- -||", -- 0
   "||",      -- 1
   " |---| ", -- 2
   "  ---||", -- 3
   "|  - ||", -- 4
   "| --- |", -- 5
   "||--- |", -- 6
   "  -  ||", -- 7
   "||---||", -- 8
   "| -- ||"  -- 9
}

integer w = 4

function column(sequence a, sequence b)
   return a[1] & repeat(b[1], w-2) & a[2] & repeat(b[2], w-2) & a[3]
end function

function lcd(sequence str)
   sequence
     cols = {},
     seg
   for i = 1 to length(str) do
     if str[i] < '0' or str[i] > '9' then  -- skip nondigits
       continue
     end if
     seg = segmap[str[i]-'0'+1]
     cols &= {column("   ", seg[1..2])}  -- left column
     if length(seg) = 7 then
       cols &= repeat(column(seg[3..5], "  "), w-2)  -- middle column
       cols &= {column("   ", seg[6..7])}  -- right column
     end if
     cols &= {repeat(' ',w+w-1)}  -- space column
   end for

   puts(1, join(columnize(cols), '\n') & '\n') -- rotate 90deg and print
   return 1
end function

sequence cmd = command_line()
integer i = 2
while i < length(cmd) do  -- process command line options
    i += 1
    if equal(cmd[i], "-w") then
        w = to_integer(cmd[i+1])  -- no error checking!
        i += 1
    else
        lcd(cmd[i])
    end if
end while
