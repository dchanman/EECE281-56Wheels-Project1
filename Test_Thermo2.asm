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

DSEG at 30H
x:	ds 2
y:	ds 2
bcd:	ds 3

BSEG
mf:	dbit 1

CSEG
$include(Thermo2.asm)
$include(math16.asm)

; Look-up table for 7-seg displays
BCD_LUT:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H        ; 0 TO 4
    DB 092H, 082H, 0F8H, 080H, 090H        ; 4 TO 9
    
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
    ret
    
init:
	lcall Thermocouple_Input_Init
	clr A
	mov LEDRA, A
	mov LEDRB, A
	mov LEDRC, A
	mov LEDG, A
forever:
	lcall Thermocouple_Input_Read_ADC
	mov LEDRB, R7
	mov LEDRA, R6
	lcall Thermocouple_Input_Delay
	sjmp forever
	
END