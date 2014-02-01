
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

	
$Modde2
org 0000H
	lcall Thermocouple_test
   
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
	mov dptr, #Thermocouple_Python_Temperature
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
	
Thermocouple_BinaryToTemperature:
	 DW 000, 000, 001, 001, 001, 001, 002, 002, 002, 003, 003, 003, 003, 004, 004, 004, 004, 005, 005, 005, 006, 006, 006, 006, 007, 007, 007, 008, 008, 008, 008, 009, 009, 009, 010, 010, 010, 010, 011, 011, 011, 011, 012, 012, 012, 013, 013, 013, 013, 014, 014, 014, 015, 015, 015, 015, 016, 016, 016, 017, 017, 017, 017, 018, 018, 018, 018, 019, 019, 019, 020, 020, 020, 020, 021, 021, 021, 022, 022, 022, 022, 023, 023, 023, 024, 024, 024, 024, 025, 025, 025, 025, 026, 026, 026, 027, 027, 027, 027, 028, 028, 028, 029, 029, 029, 029, 030, 030, 030, 031, 031, 031, 031, 032, 032, 032, 032, 033, 033, 033, 034, 034, 034, 034, 035, 035, 035, 036, 036, 036, 036, 037, 037, 037, 038, 038, 038, 038, 039, 039, 039, 040, 040, 040, 040, 041, 041, 041, 041, 042, 042, 042, 043, 043, 043, 043, 044, 044, 044, 045, 045, 045, 045, 046, 046, 046, 047, 047, 047, 047, 048, 048, 048, 048, 049, 049, 049, 050, 050, 050, 050, 051, 051, 051, 052, 052, 052, 052, 053, 053, 053, 054, 054, 054, 054, 055, 055, 055, 055, 056
	 DW 056, 056, 057, 057, 057, 057, 058, 058, 058, 059, 059, 059, 059, 060, 060, 060, 061, 061, 061, 061, 062, 062, 062, 062, 063, 063, 063, 064, 064, 064, 064, 065, 065, 065, 066, 066, 066, 066, 067, 067, 067, 068, 068, 068, 068, 069, 069, 069, 069, 070, 070, 070, 071, 071, 071, 071, 072, 072, 072, 073, 073, 073, 073, 074, 074, 074, 075, 075, 075, 075, 076, 076, 076, 076, 077, 077, 077, 078, 078, 078, 078, 079, 079, 079, 080, 080, 080, 080, 081, 081, 081, 082, 082, 082, 082, 083, 083, 083, 083, 084, 084, 084, 085, 085, 085, 085, 086, 086, 086, 087, 087, 087, 087, 088, 088, 088, 089, 089, 089, 089, 090, 090, 090, 090, 091, 091, 091, 092, 092, 092, 092, 093, 093, 093, 094, 094, 094, 094, 095, 095, 095, 096, 096, 096, 096, 097, 097, 097, 097, 098, 098, 098, 099, 099, 099, 099, 100, 100, 100, 101, 101, 101, 101, 102, 102, 102, 103, 103, 103, 103, 104, 104, 104, 104, 105, 105, 105, 106, 106, 106, 106, 107, 107, 107, 108, 108, 108, 108, 109, 109, 109, 110, 110, 110, 110, 111, 111, 111, 111, 112
	 DW 112, 112, 113, 113, 113, 113, 114, 114, 114, 115, 115, 115, 115, 116, 116, 116, 117, 117, 117, 117, 118, 118, 118, 119, 119, 119, 119, 120, 120, 120, 120, 121, 121, 121, 122, 122, 122, 122, 123, 123, 123, 124, 124, 124, 124, 125, 125, 125, 126, 126, 126, 126, 127, 127, 127, 127, 128, 128, 128, 129, 129, 129, 129, 130, 130, 130, 131, 131, 131, 131, 132, 132, 132, 133, 133, 133, 133, 134, 134, 134, 134, 135, 135, 135, 136, 136, 136, 136, 137, 137, 137, 138, 138, 138, 138, 139, 139, 139, 140, 140, 140, 140, 141, 141, 141, 141, 142, 142, 142, 143, 143, 143, 143, 144, 144, 144, 145, 145, 145, 145, 146, 146, 146, 147, 147, 147, 147, 148, 148, 148, 148, 149, 149, 149, 150, 150, 150, 150, 151, 151, 151, 152, 152, 152, 152, 153, 153, 153, 154, 154, 154, 154, 155, 155, 155, 155, 156, 156, 156, 157, 157, 157, 157, 158, 158, 158, 159, 159, 159, 159, 160, 160, 160, 161, 161, 161, 161, 162, 162, 162, 162, 163, 163, 163, 164, 164, 164, 164, 165, 165, 165, 166, 166, 166, 166, 167, 167, 167, 168, 168
	 DW 168, 168, 169, 169, 169, 169, 170, 170, 170, 171, 171, 171, 171, 172, 172, 172, 173, 173, 173, 173, 174, 174, 174, 175, 175, 175, 175, 176, 176, 176, 176, 177, 177, 177, 178, 178, 178, 178, 179, 179, 179, 180, 180, 180, 180, 181, 181, 181, 182, 182, 182, 182, 183, 183, 183, 183, 184, 184, 184, 185, 185, 185, 185, 186, 186, 186, 187, 187, 187, 187, 188, 188, 188, 189, 189, 189, 189, 190, 190, 190, 190, 191, 191, 191, 192, 192, 192, 192, 193, 193, 193, 194, 194, 194, 194, 195, 195, 195, 196, 196, 196, 196, 197, 197, 197, 198, 198, 198, 198, 199, 199, 199, 199, 200, 200, 200, 201, 201, 201, 201, 202, 202, 202, 203, 203, 203, 203, 204, 204, 204, 205, 205, 205, 205, 206, 206, 206, 206, 207, 207, 207, 208, 208, 208, 208, 209, 209, 209, 210, 210, 210, 210, 211, 211, 211, 212, 212, 212, 212, 213, 213, 213, 213, 214, 214, 214, 215, 215, 215, 215, 216, 216, 216, 217, 217, 217, 217, 218, 218, 218, 219, 219, 219, 219, 220, 220, 220, 220, 221, 221, 221, 222, 222, 222, 222, 223, 223, 223, 224, 224
	 DW 224, 224, 225, 225, 225, 226, 226, 226, 226, 227, 227, 227, 227, 228, 228, 228, 229, 229, 229, 229, 230, 230, 230, 231, 231, 231, 231, 232, 232, 232, 233, 233, 233, 233, 234, 234, 234, 234, 235, 235, 235, 236, 236, 236, 236, 237, 237, 237, 238, 238, 238, 238, 239, 239, 239, 240, 240, 240, 240, 241, 241, 241, 241, 242, 242, 242, 243, 243, 243, 243, 244, 244, 244, 245, 245, 245, 245, 246, 246, 246, 247, 247, 247, 247, 248, 248, 248, 248, 249, 249, 249, 250, 250, 250, 250, 251, 251, 251, 252, 252, 252, 252, 253, 253, 253, 254, 254, 254, 254, 255, 255, 255, 255, 256, 256, 256, 257, 257, 257, 257, 258, 258, 258, 259, 259, 259, 259, 260, 260, 260, 261, 261, 261, 261, 262, 262, 262, 262, 263, 263, 263, 264, 264, 264, 264, 265, 265, 265, 266, 266, 266, 266, 267, 267, 267, 268, 268, 268, 268, 269, 269, 269, 269, 270, 270, 270, 271, 271, 271, 271, 272, 272, 272, 273, 273, 273, 273, 274, 274, 274, 275, 275, 275, 275, 276, 276, 276, 277, 277, 277, 277, 278, 278, 278, 278, 279, 279, 279, 280, 280
	 DW 280, 280, 281, 281, 281, 282, 282, 282, 282, 283, 283, 283, 284, 284, 284, 284, 285, 285, 285, 285, 286, 286, 286, 287


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
 	
Thermocouple_Input_Init:
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
	
	ret
	
Thermocouple_MainProgram:
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
	
	ret
	
Thermocouple_test:
   lcall Thermocouple_Input_Init
   lcall Thermocouple_Main_Program
   sjmp Thermocouple_test
	
END
	

