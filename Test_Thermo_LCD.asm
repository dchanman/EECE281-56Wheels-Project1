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

STATE_STANDBY 	EQU 0
STATE_HEATING1	EQU 1
STATE_SOAK		EQU 2
STATE_HEATING2	EQU 3
STATE_REFLOW	EQU 4
STATE_COOLDOWN	EQU 5
STATE_OPEN_DOOR	EQU 6

T2LOAD EQU 65536-(FREQ/(32*BAUD))
FREQ   EQU 33333333
BAUD   EQU 115200

DSEG at 30H
x:	ds 2
y:	ds 2
bcd:	ds 3
Temperature_Measured:	ds 2
Outside_Temperature_Measured: ds 2
state:				ds 2
soak_temperature 		: ds 2
soak_time		 		: ds 2
reflow_temperature		: ds 2
reflow_time		 		: ds 2
target_temperature		: ds 2

BSEG
mf:					dbit 1
ChannelSelect:		dbit 1 
Temperature_Measured_Sign: dbit 1



CSEG
$include(Thermo2.asm)
$include(math16.asm)
$include(Serial_Port.asm)
$include(LCD_Display.asm)
$include(User_Interface.asm)
$include(Read_SW5.asm)


; Look-up table for 7-seg displays
BCD_LUT:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H        ; 0 TO 4
    DB 092H, 082H, 0F8H, 080H, 090H        ; 4 TO 9

; Display the value on HEX display
Display_T:
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
	lcall LCD_init
	clr A
	mov LEDRA, A
	mov LEDRB, A
	mov LEDRC, A
	mov LEDG, A
	
	mov state, #STATE_HEATING1
	mov target_temperature, #150
	mov target_temperature+1, #0
	mov Temperature_Measured, #0
	mov Temperature_Measured+1, #0
	
forever:
	lcall Display_status
	mov LEDRC, #0FFH
	lcall waithalfsec
	lcall waithalfsec
	mov LEDRC, #0
	lcall Thermocouple_Update
	mov x+0, Temperature_Measured+0
	mov x+1, Temperature_Measured+1
	lcall hex2bcd
	lcall Display_T
	lcall Serial_Port_Send_String
	lcall waithalfsec
	lcall waithalfsec
	sjmp forever
	
END