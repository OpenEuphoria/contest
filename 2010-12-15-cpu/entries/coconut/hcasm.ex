/*
NAME: hcasm.ex
DESC: assembler for hc1.ex
AUTHOR: Jacques Deschênes
NOTE:
 assembler syntax:
   INSTRUCTION::=OPCODE | OPCODE DEST INT | OPCODE DEST SOURCE
   OPCODE::=JNZ|HALT|SETI|ADDI|MULTI|RCPY|ADD|MUL|LOAD|STOR|PRNL|PRSP
   DEST::=R0|R1|R2|R3|R4|R5|R6|R7|R8|R9
   SOURCE::=R0|R1|R2|R3|R4|R5|R6|R7|R8|R9
   INT::=[0..9]    
   COMMENT::= ; any text
   anything after 3rd token is comment
    
 exemples:
   ADDI  R0 9   ;add 9 to R0
   STOR  R0 R2  ;store contain of R0 in ram pointed by R2
   MULI  R2 8   ;multiply r2 by 8  
 
 symbols can be used for ram locations and goto's
 a goto label begin with ':' and should be in first column
 to define a ram symbol use the keyword VAR 
 VAR_DEFINITION::= 'VAR' SYMBOL [RAM_ADDRESS]
 SYMBOL ::= [_a-zA-Z]+[_a-zA-Z0-9]*
 RAM_ADDRESS::=integer from 0 to 999
 if RAM_ADDRESS is not given the assembler attribute one.
 
 the keyword ALIAS can be used to give register an alias name
 ALIAS::='ALIAS' alias_name regiter
 alias_name::= [_a-zA-Z]+[_a-zA-Z0-9]*
 register::= R[0-9]
   
 mnemonic and keywords are not case sensitive
*/

include std/sequence.e
include std/text.e
include std/get.e

with trace

object _

constant --OPCODE MNEMONICS
MNEMONICS={
  "JNZ",  -- jump if not zero 
  "HALT",     -- halt execution
  "SETI",     -- set register immediate
  "ADDI",     -- add register immediate
  "MULI",     -- multiply register immediate
  "CPY",     -- copy register
  "ADD",     -- add register to register
  "MUL",     -- multiply register to register 
  "LOAD",    -- load register 
  "STOR",    -- store register 
  "PRNL",        -- print line.
  "PRSP"        -- print with space
 } 

constant -- number of arguments used by each mnemonic
ARG_COUNT={2,0,2,2,2,2,2,2,2,2,1,1}






enum SYM_NAME, SYM_VAL
enum URES_LBL, URES_LOC
enum LBL_NAME, LBL_LOC
sequence symbols={{"MINUS1"},{0}}, labels={{},{}}, file="", asm={}, hc={}, unresolved={{},{}}


type register(integer i)
  return i>=0 and i<10
end type

type ram_address(integer i)
  return i>= 0 and i < 1000
end type

type digit(integer i)
  return (i>='0' and i<='9')
end type



procedure read_file()
object line
integer fh

   fh=open(file,"r")
   if fh=-1 then
     printf(1,"unknown file %s\n",{file})
     abort(2)
   end if
   line=gets(fh)
   while sequence(line) do
      if line[$]='\n' then line=line[1..$-1] end if
      if length(line) and line[$]='\r' then line=line[1..$-1] end if
      asm=append(asm,line)
      line=gets(fh)
   end while
   close(fh)        
end procedure


integer asm_line=0

enum ERR_NONE=0, ERR_UNKNOWN_SYMBOL, ERR_MISSING_ARG, ERR_BAD_ARG, ERR_UNKNOWN_LABEL, 
     ERR_LOC_RESOLV, ERR_ALREADY_DEFINED, ERR_UNKNOWN_KEYWORD
     
constant ERR_MSG={
                  "unknown symbol",
                  "missing argument",
                  "bad argument",
                  "unknown label",
                  "error while resolving back location",
                  "this symbol already exist",
                  "unknown keyword"
                 }

procedure error(integer err_code)
  printf(1,"assembler error code %d: %s, at line %d\n",{err_code,ERR_MSG[err_code],asm_line})
  puts(1,asm[asm_line]&'\n')
  abort(1)
end procedure

/*
  keywords procedures
  keywords are asembler directives and does not generate code
  all keywords begin with a '.'
*/

constant KEYWORDS={
  ".SYM"
  }
  
-- add a symbol to symbols table
-- tokens[1] is symbol name, tokens[2] is value
procedure add_symbol(sequence tokens)
sequence t1, t2
   
   t1=tokens[1]
   if find(t1,symbols[SYM_NAME]) then
     error(ERR_ALREADY_DEFINED)
   end if
   t2=value(tokens[2])
   if t2[1]!=GET_SUCCESS then
     error(ERR_BAD_ARG)
   end if
   symbols[SYM_NAME]=append(symbols[SYM_NAME],t1)
   symbols[SYM_VAL]=append(symbols[SYM_VAL],t2[2])   
end procedure

constant rid_keywords={
                        routine_id("add_symbol")
                      }



procedure add_unresolved(sequence lbl, integer loc)
integer p
--trace(1)
   p=find(lbl,unresolved[URES_LBL]) 
   if not p then
     unresolved[URES_LBL]=append(unresolved[URES_LBL],lbl)
     unresolved[URES_LOC]=append(unresolved[URES_LOC],{loc})
   else
     unresolved[URES_LOC][p] &= loc
   end if  
end procedure

procedure resolve(sequence lbl, integer addr)
sequence loc2resolv, saddr
integer p, pc, completed
--trace(1)    
    p = find(lbl,unresolved[URES_LBL])
    if not p then return end if
    loc2resolv=unresolved[URES_LOC][p]
    saddr=sprintf("%04d",addr)
    for i = 1 to length(loc2resolv) do
       pc=loc2resolv[i]
       completed=0
       for j = 1 to 4 do
          if hc[pc+(j-1)*2][1]!='3' then
            exit
          end if
          hc[pc+(j-1)*2][3]=saddr[j]
          if j=4 then
            completed=1
          end if
       end for
       if not completed then error(ERR_LOC_RESOLV) end if      
    end for
    unresolved[URES_LBL]=unresolved[URES_LBL][1..p-1]&unresolved[URES_LBL][p+1..$]
    unresolved[URES_LOC]=unresolved[URES_LOC][1..p-1]&unresolved[URES_LOC][p+1..$]
end procedure

/*
  macros expansion routines
*/

--MACRO: SETREG expansion: generate code to set a register 'r' with arbitrary integer
-- if r <> 0 then use R0 to store multiplier else use R1
function set_reg(sequence tokens)
integer p,d,m, neg=0, val
sequence r={}, t2={}, opcode={}, hc_lines={}

     r=tokens[1]
     if r[1]!='R' then
        error(ERR_BAD_ARG)
     end if
     d=r[2]
     t2=tokens[2]
     if t2[1]=':' then --label reference
       p=find(t2[2..$],labels[LBL_NAME])
       if p then
         val=labels[LBL_LOC][p]
         t2=sprintf("%04d",val)
       else -- unresolved label
         add_unresolved(t2[2..$],length(hc)+4)
         val=9999
         t2="0000"
       end if
     elsif t2[1]='-' and digit(t2[2]) then --negative number
       neg=1
       t2=value(t2[2..$])
       val=t2[2]
       t2=sprintf("%d",val)
     elsif digit(t2[1]) then --positive number    
       t2=value(t2)
       if t2[1]!=GET_SUCCESS then
         error(ERR_BAD_ARG)
       end if
       val=floor(t2[2])
       t2=sprintf("%d",val)
     else  -- symbol reference
       p=find(t2,symbols[SYM_NAME]) 
       if not p then
         error(ERR_UNKNOWN_SYMBOL)
       end if
       val=symbols[SYM_VAL][p]  
       if val<0 then
         neg=1
         val = -val
       end if
       t2=sprintf("%d",val)   
     end if
     if d>'0' then 
       m='0'
     else
       m='1'
     end if
     if val < 10 then
        opcode='2' & d & (val + '0')
        hc_lines={opcode}
     else
        -- set d=0
        opcode='2'&d&'0'  -- SETI Rd 0    
        hc_lines={opcode}
        -- set m=10 ; multiplier
        opcode='2'&m&'9'  -- SETI Rm 9
        hc_lines&={opcode}
        opcode='3'&m&'1'   -- ADDI  Rm 1 -> Rm=10
        hc_lines&={opcode}        
        for i=1 to length(t2) do
           opcode='3'& d & t2[i]  -- ADDI  Rd t2[i]
           hc_lines &= {opcode}
           if i<length(t2) then
             opcode='7'&d&m -- MUL  Rd Rm -> Rd = Rd * 10
             hc_lines&={opcode}
           end if
        end for 
     end if
     if neg then
        opcode='2'&m&'0' -- STI Rm 0
        hc_lines&={opcode}
        opcode='8'&m&m -- LOAD Rm Rm  ->  Rm = -1   
        hc_lines&={opcode}
        opcode='7'&d&m  -- MUL Rd Rm  -> Rd = -Rd
        hc_lines&={opcode}
     end if
     return hc_lines  
end function

-- MACRO: SETRAM expansion: generate code to set ram to an arbitrary integer
-- use R2 to store ram_address and R1 store value
function set_ram(sequence tokens) -- SETRAM  ram_address value
sequence hc_lines
   hc_lines=set_reg({"R2",tokens[1]})&set_reg({"R1",tokens[2]}) --  R2 = ram_address, R1=value
   hc_lines&={"912"} -- STOR  R1 R2 -> ram_address [R2]=R1
   return hc_lines
end function

--MACRO: GOTO expansion: generate code for unconditional goto
-- use R2 to store PC address and R0 set to 1 
function goto_(sequence tokens)  --  GOTO  code_address
sequence address,hc_lines
integer p    
    
    hc_lines= set_reg({"R2"} & tokens)
    hc_lines &={"201","020"} -- SETI R0 0  and JNZ  R1 R0
    return hc_lines
end function


--MACRO: STVAR var_address  Rv   expansion
-- tokens[1]  var_address,  tokens[2] register containing value
function store_var(sequence tokens)
sequence  t2, hc_lines={}
integer s     

     t2=tokens[2]
     if t2[1]!='R' then
       error(ERR_BAD_ARG)
     end if
     s=tokens[2][2]
     hc_lines=set_reg({"R1"}&{tokens[1]})--set address in R1
     hc_lines&={'9'&s&'1'}  -- STORE Rs R1
     return hc_lines
end function

--MACRO: LDVAR Rv var_address expansion
-- tokens[1] register to store value,  tokens[2] var_address
function load_var(sequence tokens)
sequence t1, hc_lines={}
integer rv

     t1= tokens[1]
     if t1[1]!='R' then
       error(ERR_BAD_ARG)
     end if    
     rv=t1[2]
     hc_lines=set_reg(tokens)
     hc_lines&={"8"&rv&rv}
     return hc_lines   
end function


--MACRO: NOP expansion
-- nop operation by adding constant 0 to R0
function nop(sequence tokens)
sequence comment
integer p
    comment=asm[asm_line]
    p = find(';',comment)
    if p then
      comment=comment[p..$]
    else
      comment=""
    end if
    return {"300 "&comment}
end function

--MACRO: LPNZ :label Rc  expansion
-- R2 is used to store label address
-- :label is label to loop back,  Rc is control register for zero value
function loop_not_zero(sequence tokens)
sequence t2,hc_lines={}
integer rc
    
    t2=tokens[2]
    if t2[1]!='R' then
      error(ERR_BAD_ARG)
    end if
    rc=t2[2]
    hc_lines=set_reg({"R2",tokens[1]})
    hc_lines&={"0"&'2'&rc}
    return hc_lines
end function

constant -- list of macros
MACROS={
  "SETREG",
  "SETRAM",
  "GOTO",
  "STVAR",
  "NOP",
  "LPNZ",
  "LDVAR"
}  

constant-- number of arguments used by macro
MAC_ARG_COUNT={2,2,1,2,0,2,2}

constant rid_macros={
                     routine_id("set_reg"),
                     routine_id("set_ram"),
                     routine_id("goto_"),
                     routine_id("store_var"),
                     routine_id("nop"),
                     routine_id("loop_not_zero"),
                     routine_id("load_var") 
                    }



enum ST_IDLE, ST_ARG1, ST_ARG2, ST_COMPLETED
procedure parse(sequence tokens)
integer p,i,m,acount, state=ST_IDLE
sequence opcode, t
--trace(1)
--if asm_line=90 then trace(1) end if
      if not length(tokens) then return end if -- empty or comment line
      i=1
      while state!=ST_COMPLETED and i <= length(tokens) do
         t=tokens[i]
         m=find(t,MNEMONICS)
         switch state do
           case ST_IDLE then
             if t[1]=':' then
                 labels[1]=append(labels[1],t[2..$]) -- label symbol
                 labels[2]=append(labels[2],length(hc)) -- label address
                 resolve(t[2..$],length(hc))
             elsif t[1]='.' then -- keyword
                m=find(t,KEYWORDS)
                if not m then
                  error(ERR_UNKNOWN_KEYWORD)
                end if
                call_proc(rid_keywords[m],{tokens[2..$]})
                state=ST_COMPLETED
                opcode={}
             elsif m then
                acount=ARG_COUNT[m]
                if length(tokens[i+1..$])<acount then error(ERR_MISSING_ARG) end if
                if ARG_COUNT[m]=0 then
                  opcode={"100"}  -- HALT is the only mnemonic without argument
                  state=ST_COMPLETED
                  exit
                elsif m<11  then
                   opcode ={m-1+'0'}
                elsif equal(t,"PRNL") then
                   opcode="?"
                else
                   opcode="??"
                end if
                state=ST_ARG1
             else
                m=find(t,MACROS)
                if not m then error(ERR_UNKNOWN_SYMBOL) end if
                acount=MAC_ARG_COUNT[m]
                if length(tokens[i+1..$])<acount then error(ERR_MISSING_ARG) end if
                opcode=call_func(rid_macros[m],{tokens[i+1..$]})
                state=ST_COMPLETED
             end if   
           case ST_ARG1 then
             if t[1]!='R' then error(ERR_BAD_ARG) end if -- first arg always a register
             p=t[2]
             if p<'0' or p>'9' then error(ERR_BAD_ARG) end if
             opcode&=p
             if acount=1 then
               opcode&=' '
               opcode={opcode}
               state=ST_COMPLETED
             else
               state=ST_ARG2
             end if
           case ST_ARG2 then
             if t[1]='R' then
               p=t[2]
             else
               if digit(t[1]) then
                 p=t[1]
               else
                 p=find(t,symbols[SYM_NAME])
                 if p then
                   p=symbols[SYM_VAL][p]
                   if p<0 or p>9 then
                     p=' '
                   else
                     p+='0'
                   end if
                 else
                   p=' '
                 end if
               end if  
             end if  
             if p<'0' or p>'9' then error(ERR_BAD_ARG) end if
             opcode&=p & ' '
             opcode={opcode}
             state=ST_COMPLETED  
         end switch
         i += 1   
      end while
      if state=ST_COMPLETED then
        if length(opcode) then hc&=opcode end if
      else
        error(ERR_MISSING_ARG)
      end if
end procedure

_ = date()
_[1] += 1900
constant CODE_HEADER={
  "300 ;GENERATOR: hcasm.ex  (macro assembler for half core generation 1 VM)",
  sprintf("300 ;TIMESTAMP: %4d-%02d-%02d %02d:%02d:%02d",_)
}
hc=CODE_HEADER


procedure generate_code()
sequence tokens,comment, code, f_name
integer p, fh, lc

  for i = 1 to length(asm) do
     asm_line=i
     p=find(';',asm[i])
     if p then 
          code=upper(asm[i][1..p-1])
          comment=asm[i][p..$]
     else
          code=upper(asm[i])
     end if    
     if length(code) then
       lc=length(hc)
       tokens=split(code,' ',1)
       parse(tokens)
       for j= lc+1 to length(hc) do
         if length(hc[j])<4 then hc[j] &= repeat(32,4-length(hc[j])) end if
       end for
       if length(hc)>lc then
          lc+=1
          hc[lc] &= code
       end if
     end if     
  end for
  p=find('.',file)
  f_name=file[1..p]&"hc"
  fh=open(f_name,"w")
  for i=1 to length(hc) do
    puts(fh,hc[i]&'\n')
  end for
  close(fh)     
end procedure


procedure parse_args()
sequence args

   args=command_line()
   if length(args)<3 then
     puts(1,"USAGE: eui hcasm.ex asm_file\n")
     abort(1)
   end if
   file=args[3]
end procedure


procedure main()
  parse_args()
  read_file()
  generate_code()
end procedure

main()


