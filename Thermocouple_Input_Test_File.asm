
;----------------------------------------------------
;	Thermocouple/Serial Input Interface
; 
;	Kyujin Park, Nina Dacanay, Glyn Han
;	
;	Function:	1) Reads the voltage from the K-Type Thermocouple connected to 
;				   the MCP 3004 ADC Converter
;				2) The temperature will be calculated 
;				   => (ADC*62/256)+(ADC*63/256)-273 (include math16.asm, maybe math32.asm)
;
;	Possible Labels need to be declared
; 			My_Lut, Display, Init_Serial_Port, Wait_Half_Sec, 
;			Init_SPI, Do_SPI_G, Do_SPI_G_Loop, Delay, Delay_Loop, 
;			Read_ADC_Channel, MISO, MOSI, SCLK, CE_ADC, CE_EE, CE_RTC
;
;	Most Difficult Part : Displaying Temperature on LED Screen
;						  Conversion Calculation
;
;	Functions 			: Loop_Up_Table; Display_Seven_Seg(from 0-9), Wait_Half_Sec, Timer_Two
;						  Timer_Two, My_Program	
;
;	Equation(voltage to temp) :  The equation above 0 °C is of the form 
;								 E = sum(i=0 to n) c_i t^i + a0 exp(a1 (t - a2)^2)
;
;	Extra Files need for calculation: math16.asm, math32.asm (depending on the overflow of bit operation)
;
;	Registers/Variables :	
;		thermocouple_temp: db 2		  
;----------------------------------------------------

;Thermocouple_Input_Init:
	;ret	
$Modde2
org 0000H
   ljmp Thermocouple_Program
   
FREQ   EQU 33333333
BAUD   EQU 115200
T2LOAD EQU 65536-(FREQ/(32*BAUD))

MISO   EQU  P0.0 
MOSI   EQU  P0.1 
SCLK   EQU  P0.2
CE_ADC EQU  P0.3
CE_EE  EQU  P0.4
CE_RTC EQU  P0.5 

	DSEG at 30H
x:      ds 2
y:      ds 2
bcd:	ds 3
op:     ds 1

	BSEG
mf:     dbit 1

	CSEG
$include(math16.asm)

; Look-up table for 7-seg displays
myLUT:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H        ; 0 TO 4
    DB 092H, 082H, 0F8H, 080H, 090H        ; 4 TO 9

; Display the value on HEX display
Display:
	mov dptr, #myLUT
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
    
;Initializes the serial port  through timer 2    
InitSerialPort:
	clr TR2 ; Disable timer 2
	mov T2CON, #30H ; RCLK=1, TCLK=1 
	mov RCAP2H, #high(T2LOAD)  
	mov RCAP2L, #low(T2LOAD)
	setb TR2 ; Enable timer 2
	mov SCON, #52H
	ret

;Stores the value taken from the serial port into the serial buffer (SBUF)    
Thermocouple_Putchar:
    JNB TI, Thermocouple_Putchar
    CLR TI
    MOV SBUF, a
    RET

;Converts the value from numerical to string
;Allows Python to read and graph a strip chart of the 
;Temperature inside the oven 
Thermocouple_Send_Number:
	mov dptr, #String_Number
	; Display Digit 0
    mov A, bcd+0
    swap a
    anl a, #0fh
    movc A, @A+dptr
    lcall Thermocouple_Putchar
    
    mov A, bcd+0
    anl a, #0fh
    movc A, @A+dptr
    lcall Thermocouple_Putchar
	; Display Digit 1
    
    mov A, #0AH
    movc A, @A+dptr
    lcall Thermocouple_Putchar
    ret

;look up chart table for Thermocouple_Send_Number
String_Number:
	DB '0','1','2','3','4','5','6','7','8','9','\n'
	

;Delay half a second	
WaitHalfSec:
	mov R2, #90
L3: mov R1, #250
L2: mov R0, #250
L1: djnz R0, L1
	djnz R1, L2
	djnz R2, L3
	ret
    
;set outputs and inputs for the serial
INIT_SPI:
    orl P0MOD, #00000110b ; Set SCLK, MOSI as outputs
    anl P0MOD, #11111110b ; Set MISO as input
    clr SCLK              ; For mode (0,0) SCLK is zero
	ret

;	
DO_SPI_G:
	push acc
    mov R1, #0            ; Received byte stored in R1
    mov R2, #8            ; Loop counter (8-bits)
DO_SPI_G_LOOP:
    mov a, R0             ; Byte to write is in R0
    rlc a                 ; Carry flag has bit to write
    mov R0, a
    mov MOSI, c
    setb SCLK             ; Transmit
    mov c, MISO           ; Read received bit
    mov a, R1             ; Save received bit in R1
    rlc a
    mov R1, a
    clr SCLK
    djnz R2, DO_SPI_G_LOOP
    pop acc
    ret

Delay:
	mov R3, #20
Delay_loop:
	djnz R3, Delay_loop
	ret

; Channel to read passed in register b
Read_ADC_Channel:
	clr CE_ADC
	mov R0, #00000001B ; Start bit:1
	lcall DO_SPI_G
	
	mov a, b
	swap a
	anl a, #0F0H
	setb acc.7 ; Single mode (bit 7).
	
	mov R0, a ;  Select channel
	lcall DO_SPI_G
	mov a, R1          ; R1 contains bits 8 and 9
	anl a, #03H
	mov R7, a
	
	mov R0, #55H ; It doesn't matter what we transmit...
	lcall DO_SPI_G
	mov a, R1    ; R1 contains bits 0 to 7
	mov R6, a
	setb CE_ADC
	ret
 	
Thermocouple_Program:
	mov sp, #07FH
	clr a
	mov LEDG,  a
	mov LEDRA, a
	mov LEDRB, a
	mov LEDRC, a
	orl P0MOD, #00111000b ; make all CEs outputs
	
	setb CE_ADC
	setb CE_EE
	clr  CE_RTC ; RTC CE is active high

	lcall INIT_SPI
	lcall initserialport
	
Thermocouple_Forever:
	mov b, #0  ; Read channel 0
	lcall Read_ADC_Channel
	
	mov x+1, R7
	mov x+0, R6
	
	; The temperature can be calculated as (ADC*500/1024)-273 (may overflow 16 bit operations)
	; or (ADC*250/512)-273 (may overflow 16 bit operations)
	; or (ADC*125/256)-273 (may overflow 16 bit operations)
	; or (ADC*62/256)+(ADC*63/256)-273 (Does not overflow 16 bit operations!)
	
	Load_y(62)
	lcall mul16
	mov R4, x+1

	mov x+1, R7
	mov x+0, R6

	Load_y(63)
	lcall mul16
	mov R5, x+1
	
	mov x+0, R4
	mov x+1, #0
	mov y+0, R5
	mov y+1, #0
	lcall add16
	
	clr mf
	Load_y(273)
	lcall x_lt_y
	jnb mf, Thermocouple_Positive_Temperature

Thermocouple_Negative_Temperature:	
	lcall xchg_xy
	lcall sub16
	mov a, #'-'
	lcall Thermocouple_Putchar
	mov hex2, #3FH
	sjmp Thermocouple_Result
	
Thermocouple_Positive_Temperature:
	Load_y(273)
	lcall sub16
	mov hex2, #7FH
	
Thermocouple_Result:	
	lcall hex2bcd
	lcall Display
	lcall Thermocouple_Send_Number
	lcall WaitHalfSec
	lcall WaitHalfSec	
	
	ljmp Thermocouple_Forever
	
END
	

