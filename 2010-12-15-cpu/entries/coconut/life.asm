nop ; TITLE: game of life 
nop ; AUTHOR: Jacques Deschênes
nop ; life rules:
nop ; 3 neighbor -> birth
nop ; 2|3 neighbor -> survive
nop ; <2|>3  neighbor -> die
nop ;
nop ;   glider initial shape
nop ;      *          
nop ;       *         
nop ;     ***         

.sym t1 9       ; cell array 1
.sym t2 409     ; cell array 2
.sym max_gen -40 ; stop after 25 generation
.sym size 20    ; size of grid
.sym gencount 2 ; address of generation counter variable

       seti R0 1
       stvar gencount R0  ; generation counter
       nop ; initialize the arrays 
       setreg R3 800 ; loop counter 
       seti R4 t1    ; first array address
:L1    ldvar R0 minus1    ; load -1 in R0
       seti R2 0     ; memset to 0
       stor R2 R4    
       addi R4 1  
       add  R3 R0
       lpnz :L1 R3   ; loop if R3 not 0
       nop ;initialize t1 with a single glider in the top left corner
       seti R3 1    ; value to store
       setreg R4 31 ; store address
       stor R3 R4
       setreg R4 52
       stor R3 R4
       setreg R4 70
       stor R3 R4
       addi R4 1
       stor R3 R4
       addi R4 1
       stor R3 R4   
       nop ; print generation 0
       seti R0 0
       prnl R0
       setreg R5 30 ; t1
       setreg R6 18
       setreg R7 18
:LC    load R0 R5
       prsp R0
       addi R5 1
       ldvar R0 minus1
       add R7 R0
       setreg R2 :LC
       jnz R2 R7
       setreg R7 18
       addi R5 2
       ldvar R0 minus1
       add R6 R0
       prnl R6
       setreg R2 :LC
       jnz R2 R6
       nop ; print generation number
:glp   ldvar R3 gencount
       prnl  R3     ; print generation number
       setreg R4 size ; row increment                      
       setreg R5 30 ; t1 first cell 
       setreg R6 18 ; row counter       
       setreg R7 18 ; column counter
       setreg R8 430; t2 first cell  
:g2    seti R9 0    ; neighbor counter
       ldvar R0 minus1  ; put -1 in R0
       cpy R1 R4    ; 20 -> R1
       mul R1 R0    ; -20 -> R1 
       cpy R2 R5    ; &t1 -> R2
       add R2 R1    ; &t1-20 -> R2
       add R2 R0    ; &t1-21 -> R2
       load R1 R2   ; begin row over neighbor count 
       add R9 R1    ; 
       addi R2 1    ; 
       load R1 R2
       add R9 R1
       addi R2 1
       load R1 R2
       add R9 R1    ; row over neighbord count completed
       add R2 R4    ; begin current neighbor count
       load R1 R2
       add R9 R1
       add R2 R0
       add R2 R0
       load R1 R2
       add R9 R1    ;count complted for this row
       add R2 R4    ; begin row under count
       load R1 R2
       add R9 R1
       addi R2 1
       load R1 R2
       add R9 R1
       addi R2 1 
       load R1 R2 
       add R9 R1   ;all neighbors counted. 
       setreg R2 :GT0
       jnz R2 R9
       goto :die   ; 0 neighbor die
:GT0   ldvar R0 minus1 ; count >= 1
       mul R9 R0  ; negate count           
       addi R9 1  ; check status of this cell
       setreg R2 :GT1
       jnz R2 R9
       goto :die  ; 1 neighbor die    
:GT1   addi R9 1
       setreg R2 :GT2
       jnz R2 R9
       goto :stabl  ; 2 neighbor stay as is. 
:GT2   addi R9 1
       setreg R2 :die
       jnz R2 R9     ; more than 3 neighbor die   
       seti R0 1     
       stor R0 R8    ; store 1 in t2 array
       prsp R0
       goto :nextc
:stabl load R0 R5
       stor R0 R8    ; copy cell t1 to t2
       prsp R0
       goto :nextc       
:die   seti R0 0
       stor R0 R8    ; store 0 in t2
       prsp R0
:nextc addi R5 1     ; next cell
       addi R8 1
       ldvar R0 minus1
       add  R7 R0
       setreg R2 :nxc1
       jnz R2 R7
       setreg R7 18
       ldvar R0 minus1
       add R6 R0
       prnl R6
       setreg R2 :nxc0
       jnz R2 R6
       goto :gend
:nxc0  ldvar R0 minus1 
       addi R5 2
       addi R8 2
:nxc1  goto :g2
       nop ; check gencount stop if = max_gen
:gend  ldvar R3 gencount
       addi  R3 1
       stvar gencount R3
       setreg R0 max_gen
       add R3 R0
       setreg R2 :cpy
       jnz R2 R3
       halt
:cpy   nop   ; copy t2 to 1
       setreg r5 9
       setreg r6 409
       setreg r7 400
:cpy1  load r0 r6
       stor r0 r5
       addi r5 1
       addi r6 1
       ldvar r3 minus1
       add r7 r3
       setreg r2 :cpy1
       jnz r2 r7
       goto  :glp
       halt       
