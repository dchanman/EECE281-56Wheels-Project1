
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
	
Thermocouple_LCD_Temperature:
	DB   0.000,  0.039,  0.079,  0.119,  0.158,  0.198,  0.238,  0.277,  0.317,  0.357,  0.397
  	DB   0.397,  0.437,  0.477,  0.517,  0.557,  0.597,  0.637,  0.677,  0.718,  0.758,  0.798
  	DB   0.798,  0.838,  0.879,  0.919,  0.960,  1.000,  1.041,  1.081,  1.122,  1.163,  1.203 
  	DB   1.203,  1.244,  1.285,  1.326,  1.366,  1.407,  1.448,  1.489,  1.530,  1.571,  1.612 
  	DB   1.612,  1.653,  1.694,  1.735,  1.776,  1.817,  1.858,  1.899,  1.941,  1.982,  2.023 
 
  	DB   2.023,  2.064,  2.106,  2.147,  2.188,  2.230,  2.271,  2.312,  2.354,  2.395,  2.436 
  	DB   2.436,  2.478,  2.519,  2.561,  2.602,  2.644,  2.685,  2.727,  2.768,  2.810,  2.851 
  	DB   2.851,  2.893,  2.934,  2.976,  3.017,  3.059,  3.100,  3.142,  3.184,  3.225,  3.267 
  	DB   3.267,  3.308,  3.350,  3.391,  3.433,  3.474,  3.516,  3.557,  3.599,  3.640,  3.682 
  	DB   3.682,  3.723,  3.765,  3.806,  3.848,  3.889,  3.931,  3.972,  4.013,  4.055,  4.096 
 
 	DB   4.096,  4.138,  4.179,  4.220,  4.262,  4.303,  4.344,  4.385,  4.427,  4.468,  4.509 
 	DB   4.509,  4.550,  4.591,  4.633,  4.674,  4.715,  4.756,  4.797,  4.838,  4.879,  4.920 
 	DB   4.920,  4.961,  5.002,  5.043,  5.084,  5.124,  5.165,  5.206,  5.247,  5.288,  5.328 
 	DB   5.328,  5.369,  5.410,  5.450,  5.491,  5.532,  5.572,  5.613,  5.653,  5.694,  5.735 
 	DB   5.735,  5.775,  5.815,  5.856,  5.896,  5.937,  5.977,  6.017,  6.058,  6.098,  6.138 
 
 	DB 	 6.138,  6.179,  6.219,  6.259,  6.299,  6.339,  6.380,  6.420,  6.460,  6.500,  6.540 
 	DB   6.540,  6.580,  6.620,  6.660,  6.701,  6.741,  6.781,  6.821,  6.861,  6.901,  6.941 
 	DB   6.941,  6.981,  7.021,  7.060,  7.100,  7.140,  7.180,  7.220,  7.260,  7.300,  7.340 
 	DB   7.340,  7.380,  7.420,  7.460,  7.500,  7.540,  7.579,  7.619,  7.659,  7.699,  7.739 
 	DB   7.739,  7.779,  7.819,  7.859,  7.899,  7.939,  7.979,  8.019,  8.059,  8.099,  8.138
 
 	DB   8.138,  8.178,  8.218,  8.258,  8.298,  8.338,  8.378,  8.418,  8.458,  8.499,  8.539 
 	DB   8.539,  8.579,  8.619,  8.659,  8.699,  8.739,  8.779,  8.819,  8.860,  8.900,  8.940 
 	DB   8.940,  8.980,  9.020,  9.061,  9.101,  9.141,  9.181,  9.222,  9.262,  9.302,  9.343 
	DB   9.343,  9.383,  9.423,  9.464,  9.504,  9.545,  9.585,  9.626,  9.666,  9.707,  9.747 
 	DB   9.747,  9.788,  9.828,  9.869,  9.909,  9.950,  9.991,  10.031, 10.072, 10.113, 10.153 
 	

	
Thermocouple_Python_Temperature:
	DB 	 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
	DB 	 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20
	DB 	 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30
	DB 	 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40
	DB 	 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50
	DB 	 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60
	DB 	  60,  61,  62,  63,  64,  65,  66,  67,  68,  69,  70
	DB 	  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,  80
	DB 	  80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90
	DB 	  90,  91,  92,  93,  94,  95,  96,  97,  98,  99, 100
	DB	 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110
	DB 	 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120
	DB 	 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130
	DB 	 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140
	DB 	 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150
	DB 	 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160
	DB 	 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170
	DB 	 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180
	DB 	 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190
	DB 	 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200
	DB	 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210
	DB 	 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220
	DB 	 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230
	DB 	 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240
	DB 	 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250


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
	

