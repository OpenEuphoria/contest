300 ;GENERATOR: hcasm.ex  (macro assembler for half core generation 1 VM)
300 ;TIMESTAMP: 2010-12-12 18:29:18
300 ; TITLE: game of life NOP 
300 ; AUTHOR: Jacques DeschênesNOP 
300 ; life rules:NOP 
300 ; 3 neighbor -> birthNOP 
300 ; 2|3 neighbor -> surviveNOP 
300 ; <2|>3  neighbor -> dieNOP 
300 ;NOP 
300 ;   glider initial shapeNOP 
300 ;      *          NOP 
300 ;       *         NOP 
300 ;     ***         NOP 
201        SETI R0 1
212        STVAR GENCOUNT R0  
901 
300 ; initialize the arrays        NOP 
230        SETREG R3 800 
209 
301 
338 
730 
330 
730 
330 
249        SETI R4 T1    
200 :L1    LDVAR R0 MINUS1    
800 
220        SETI R2 0     
924        STOR R2 R4    
341        ADDI R4 1  
630        ADD  R3 R0
220        LPNZ :L1 R3   
209 
301 
320 
720 
320 
720 
322 
720 
326 
023 
300 ;initialize t1 with a single glider in the top left corner       NOP 
231        SETI R3 1    
240        SETREG R4 31 
209 
301 
343 
740 
341 
934        STOR R3 R4
240        SETREG R4 52
209 
301 
345 
740 
342 
934        STOR R3 R4
240        SETREG R4 70
209 
301 
347 
740 
340 
934        STOR R3 R4
341        ADDI R4 1
934        STOR R3 R4
341        ADDI R4 1
934        STOR R3 R4   
300 ; print generation 0       NOP 
200        SETI R0 0
?0         PRNL R0
250        SETREG R5 30 
209 
301 
353 
750 
350 
260        SETREG R6 18
209 
301 
361 
760 
368 
270        SETREG R7 18
209 
301 
371 
770 
378 
805 :LC    LOAD R0 R5
??0        PRSP R0
351        ADDI R5 1
200        LDVAR R0 MINUS1
800 
670        ADD R7 R0
220        SETREG R2 :LC
209 
301 
320 
720 
320 
720 
329 
720 
321 
027        JNZ R2 R7
270        SETREG R7 18
209 
301 
371 
770 
378 
352        ADDI R5 2
200        LDVAR R0 MINUS1
800 
660        ADD R6 R0
?6         PRNL R6
220        SETREG R2 :LC
209 
301 
320 
720 
320 
720 
329 
720 
321 
026        JNZ R2 R6
300 ; print generation number       NOP 
232 :GLP   LDVAR R3 GENCOUNT
833 
?3         PRNL  R3     
240        SETREG R4 SIZE 
209 
301 
342 
740 
340 
250        SETREG R5 30 
209 
301 
353 
750 
350 
260        SETREG R6 18 
209 
301 
361 
760 
368 
270        SETREG R7 18 
209 
301 
371 
770 
378 
280        SETREG R8 430
209 
301 
384 
780 
383 
780 
380 
290 :G2    SETI R9 0    
200        LDVAR R0 MINUS1  
800 
514        CPY R1 R4    
710        MUL R1 R0    
525        CPY R2 R5    
621        ADD R2 R1    
620        ADD R2 R0    
812        LOAD R1 R2   
691        ADD R9 R1    
321        ADDI R2 1    
812        LOAD R1 R2
691        ADD R9 R1
321        ADDI R2 1
812        LOAD R1 R2
691        ADD R9 R1    
624        ADD R2 R4    
812        LOAD R1 R2
691        ADD R9 R1
620        ADD R2 R0
620        ADD R2 R0
812        LOAD R1 R2
691        ADD R9 R1    
624        ADD R2 R4    
812        LOAD R1 R2
691        ADD R9 R1
321        ADDI R2 1
812        LOAD R1 R2
691        ADD R9 R1
321        ADDI R2 1 
812        LOAD R1 R2 
691        ADD R9 R1   
220        SETREG R2 :GT0
209 
301 
320 
720 
322 
720 
322 
720 
321 
029        JNZ R2 R9
220        GOTO :DIE   
209 
301 
320 
720 
323 
720 
321 
720 
324 
201 
020 
200 :GT0   LDVAR R0 MINUS1 
800 
790        MUL R9 R0  
391        ADDI R9 1  
220        SETREG R2 :GT1
209 
301 
320 
720 
322 
720 
324 
720 
328 
029        JNZ R2 R9
220        GOTO :DIE  
209 
301 
320 
720 
323 
720 
321 
720 
324 
201 
020 
391 :GT1   ADDI R9 1
220        SETREG R2 :GT2
209 
301 
320 
720 
322 
720 
327 
720 
322 
029        JNZ R2 R9
220        GOTO :STABL  
209 
301 
320 
720 
322 
720 
329 
720 
329 
201 
020 
391 :GT2   ADDI R9 1
220        SETREG R2 :DIE
209 
301 
320 
720 
323 
720 
321 
720 
324 
029        JNZ R2 R9     
201        SETI R0 1     
908        STOR R0 R8    
??0        PRSP R0
220        GOTO :NEXTC
209 
301 
320 
720 
323 
720 
321 
720 
327 
201 
020 
805 :STABL LOAD R0 R5
908        STOR R0 R8    
??0        PRSP R0
220        GOTO :NEXTC       
209 
301 
320 
720 
323 
720 
321 
720 
327 
201 
020 
200 :DIE   SETI R0 0
908        STOR R0 R8    
??0        PRSP R0
351 :NEXTC ADDI R5 1     
381        ADDI R8 1
200        LDVAR R0 MINUS1
800 
670        ADD  R7 R0
220        SETREG R2 :NXC1
209 
301 
320 
720 
323 
720 
327 
720 
320 
027        JNZ R2 R7
270        SETREG R7 18
209 
301 
371 
770 
378 
200        LDVAR R0 MINUS1
800 
660        ADD R6 R0
?6         PRNL R6
220        SETREG R2 :NXC0
209 
301 
320 
720 
323 
720 
326 
720 
326 
026        JNZ R2 R6
220        GOTO :GEND
209 
301 
320 
720 
323 
720 
328 
720 
323 
201 
020 
200 :NXC0  LDVAR R0 MINUS1 
800 
352        ADDI R5 2
382        ADDI R8 2
220 :NXC1  GOTO :G2
209 
301 
320 
720 
321 
720 
326 
720 
326 
201 
020 
300 ; check gencount stop if = max_gen       NOP 
232 :GEND  LDVAR R3 GENCOUNT
833 
331        ADDI  R3 1
212        STVAR GENCOUNT R3
931 
200        SETREG R0 MAX_GEN
219 
311 
304 
701 
300 
210 
811 
701 
630        ADD R3 R0
220        SETREG R2 :CPY
209 
301 
320 
720 
324 
720 
321 
720 
320 
023        JNZ R2 R3
100        HALT
300 ; copy t2 to 1:CPY   NOP   
259        SETREG R5 9
260        SETREG R6 409
209 
301 
364 
760 
360 
760 
369 
270        SETREG R7 400
209 
301 
374 
770 
370 
770 
370 
806 :CPY1  LOAD R0 R6
905        STOR R0 R5
351        ADDI R5 1
361        ADDI R6 1
230        LDVAR R3 MINUS1
833 
673        ADD R7 R3
220        SETREG R2 :CPY1
209 
301 
320 
720 
324 
720 
322 
720 
328 
027        JNZ R2 R7
220        GOTO  :GLP
209 
301 
320 
720 
321 
720 
323 
720 
321 
201 
020 
100        HALT       
