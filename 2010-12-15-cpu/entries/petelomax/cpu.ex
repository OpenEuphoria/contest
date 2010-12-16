--
-- Pete Lomax
--
-- I was't going to enter, but grew curious as to what the example
-- programs did. My only hope is 361 tokens, which sounds huge!
-- Still, someone has to come last I suppose ;-) In my defense I've
-- spent more time getting 4.0, token_count and Tools/reindent in
-- Edita to work, than I have on this. Honest guv.
--

include std\console.e
sequence reg = repeat(0,10),        -- regs 0 to 9, indexed as 1..10
         RAM = -1&repeat(0,999),    -- likewise RAM[1] == address 0
         line,
         instructions = {},         -- each instruction is of the 
         triplet                    --  form {opcode,reg,reg}
                                    -- again, pc=0 => instructions[1]
integer k,l,m,
        pc = 0

constant formats = {"%d\n","%d "}

constant cl = command_line()
--  if length(cl)<3 then
--      puts(1,"usage: PL.exw <program>\n")
--      ?9/0
--  end if
include std\io.e
sequence source = read_lines(cl[3])
--  if atom(source) then -- (& change the declaration to object)
--      puts(1,"error opening file\n")
--      ?9/0
--  end if
    for i=1 to length(source) do
        line = source[i]
        m = line[1]
        if m='?' then
            k = 11                          -- 'print' opcode
            l = 1                           -- newline
            m = line[2]
            if m='?' then
                l = 2                       -- space
                m = line[3]
            end if
        else
            k = find(m,"1234567890")        -- obvs, '0'->10
            l = find(line[2],"0123456789")  -- as below
            m = line[3]
        end if
        m = find(m,"0123456789")        -- note '0'->1, '1'->2, etc
        if k and l and m then
            instructions &= {{k,l,m}}   -- eg "200" -> {2,1,1} [!!]
        end if
    end for
    instructions &= {{1,0,0}}
    while 1 do
        pc += 1
        triplet = instructions[pc]
        k = triplet[1]      -- 1..9, 0 as 10, ? as 11
        l = triplet[2]      -- 0..9 as 1..10
        m = triplet[3]      -- 0..9 as 1..10
        switch k do
            case 2,3,4 then
                m -= 1
            case 5,6,7 then
                m = reg[m]
                k -= 3
        end switch
        switch k do
            case 1 then
                -- assume any 1nn to halt, not just 100
                exit
            case 2 then         -- ==5
                reg[l] = m
            case 3 then         -- ==6
                reg[l] += m
            case 4 then         -- ==7
                reg[l] *= m
            case 8 then
                reg[l] = RAM[reg[m]+1]
            case 9 then
                RAM[reg[m]+1] = reg[l]
            case 10 then -- 0 really
                if reg[m] then
                    pc = reg[l]
                end if
            case 11 then
                printf(1,formats[l],reg[m])
        end switch
    end while

    maybe_any_key()


