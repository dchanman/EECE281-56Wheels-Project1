
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
	
Thermocouple_LCD_Temperature:
	DB   0000,  0039,  0079,  0119,  0158,  0198,  0238,  0277,  0317,  0357,  0397
  	DB   0397,  0437,  0477,  0517,  0557,  0597,  0637,  0677,  0718,  0758,  0798
  	DB   0798,  0838,  0879,  0919,  0960,  1000,  1041,  1081,  1122,  1163,  1203 
  	DB   1203,  1244,  1285,  1326,  1366,  1407,  1448,  1489,  1530,  1571,  1612 
  	DB   1612,  1653,  1694,  1735,  1776,  1817,  1858,  1899,  1941,  1982,  2023 
 
  	DB   2023,  2064,  2106,  2147,  2188,  2230,  2271,  2312,  2354,  2395,  2436 
  	DB   2436,  2478,  2519,  2561,  2602,  2644,  2685,  2727,  2768,  2810,  2851 
  	DB   2851,  2893,  2934,  2976,  3017,  3059,  3100,  3142,  3184,  3225,  3267 
  	DB   3267,  3308,  3350,  3391,  3433,  3474,  3516,  3557,  3599,  3640,  3682 
  	DB   3682,  3723,  3765,  3806,  3848,  3889,  3931,  3972,  4013,  4055,  4096 
 
 	DB   4096,  4138,  4179,  4220,  4262,  4303,  4344,  4385,  4427,  4468,  4509 
 	DB   4509,  4550,  4591,  4633,  4674,  4715,  4756,  4797,  4838,  4879,  4920 
 	DB   4920,  4961,  5002,  5043,  5084,  5124,  5165,  5206,  5247,  5288,  5328 
 	DB   5328,  5369,  5410,  5450,  5491,  5532,  5572,  5613,  5653,  5694,  5735 
 	DB   5735,  5775,  5815,  5856,  5896,  5937,  5977,  6017,  6058,  6098,  6138 
 
 	DB 	 6138,  6179,  6219,  6259,  6299,  6339,  6380,  6420,  6460,  6500,  6540 
 	DB   6540,  6580,  6620,  6660,  6701,  6741,  6781,  6821,  6861,  6901,  6941 
 	DB   6941,  6981,  7021,  7060,  7100,  7140,  7180,  7220,  7260,  7300,  7340 
 	DB   7340,  7380,  7420,  7460,  7500,  7540,  7579,  7619,  7659,  7699,  7739 
 	DB   7739,  7779,  7819,  7859,  7899,  7939,  7979,  8019,  8059,  8099,  8138
 
 	DB   8138,  8178,  8218,  8258,  8298,  8338,  8378,  8418,  8458,  8499,  8539 
 	DB   8539,  8579,  8619,  8659,  8699,  8739,  8779,  8819,  8860,  8900,  8940 
 	DB   8940,  8980,  9020,  9061,  9101,  9141,  9181,  9222,  9262,  9302,  9343 
	DB   9343,  9383,  9423,  9464,  9504,  9545,  9585,  9626,  9666,  9707,  9747 
 	DB   9747,  9788,  9828,  9869,  9909,  9950,  9991,  10031, 10072, 10113, 10153

 		
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
	

