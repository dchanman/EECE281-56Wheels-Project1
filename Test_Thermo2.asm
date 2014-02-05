$modde2

;
;Test file for T
;

org 0000h
	lcall init
	
MISO   EQU  P0.0 
MOSI   EQU  P0.1 
SCLK   EQU  P0.2
CE_ADC EQU  P0.3

T2LOAD EQU 65536-(FREQ/(32*BAUD))
FREQ   EQU 33333333
BAUD   EQU 115200

DSEG at 30H
x:	ds 2
y:	ds 2
bcd:	ds 3
Temperature_Measured:	ds 2

BSEG
mf:	dbit 1

CSEG
$include(Thermo2.asm)
$include(math16.asm)
$include(Serial_Port.asm)


;Delay half a second	
WaitHalfSec:
	mov R2, #90
L3: mov R1, #250
L2: mov R0, #250
L1: djnz R0, L1
	djnz R1, L2
	djnz R2, L3
	ret
	
; Look-up table for 7-seg displays
BCD_LUT:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H        ; 0 TO 4
    DB 092H, 082H, 0F8H, 080H, 090H        ; 4 TO 9

; Look-up table for the Python Temperature Strip Chart   
Serial_Port_My_Lut_ASCII:
	DB 030H, 031H, 032H, 033H, 034H       ; 0 TO 4
    DB 035H, 036H, 037H, 038H, 039H       ; 4 TO 9
    
; Display the value on HEX display
Display:
	mov dptr, #BCD_LUT
	; Display Digit 0
    mov A, bcd+0
    anl a, #0fh
    movc A, @A+dptr
    mov HEX0, A
	; Display Digit 1
    mov A, bcd+0
    swap a
    anl a, #0fh
    movc A, @A+dptr
    mov HEX1, A
    
    ; Display Digit 2
    mov A, bcd+1
    anl a, #0fh
    movc A, @A+dptr
    mov HEX2, A
	; Display Digit 3
    mov A, bcd+1
    swap a
    anl a, #0fh
    movc A, @A+dptr
    mov HEX3, A
    
    ; Display Digit 4
    mov A, bcd+2
    anl a, #0fh
    movc A, @A+dptr
    mov HEX4, A
	; Display Digit 5
    mov A, bcd+2
    swap a
    anl a, #0fh
    movc A, @A+dptr
    mov HEX5, A
    
    ret
    
init:
	lcall Thermocouple_Input_Init
	lcall Serial_Port_Init
	clr A
	mov LEDRA, A
	mov LEDRB, A
	mov LEDRC, A
	mov LEDG, A
forever:
	lcall Thermocouple_Input_Read_ADC
	mov LEDRA, R7
	mov LEDG, R6	
	mov x, Temperature_Measured
	mov x+1, Temperature_Measured+1
	
	lcall hex2bcd	
	lcall Display
	
	lcall waithalfsec
	lcall waithalfsec
	lcall Serial_Port_Send_String
	sjmp forever
	
END