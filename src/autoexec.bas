10 LOADM"FLASH"
20 INPUT "CMD (E,S,R):";A$
30 IF A$ = "S" THEN GOSUB 200:GOTO 20
40 IF A$="E" THEN GOSUB 100:GOTO 20
50 IF A$="R" THEN GOSUB 300:GOTO 20
99 GOTO 20
100 POKE 4000,0:REM BANK
110 POKE 4001,0:REM ADDR HI BYTE
120 POKE 4002,0:REM ADR LO BYTE
130 POKE 4003,43:REM DATA
140 EXEC 4010
150 RETURN
200 INPUT "BANK";BA
210 INPUT "ADDRESS";AD
220 INPUT "DATA";DA
230 POKE 4000,BA
240 POKE 4001,AD/256
250 POKE 4002,AD AND 255
260 POKE 4003,DA
270 EXEC 4010+3
280 RETURN
300 INPUT "BANK";BA
310 INPUT "ADDRESS";AD
330 POKE 4000,BA
340 POKE 4001,AD/256
350 POKE 4002,AD AND 255
360 EXEC 4010+6
370 PRINT PEEK(4003)
380 RETURN
