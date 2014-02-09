$MODDE2


org 0000H
   ljmp MyProgram

FREQ   EQU 33333333
BAUD   EQU 115200
T2LOAD EQU 65536-(FREQ/(32*BAUD))

;For communicating with the ADC
SCLK	EQU	P0.2	;clock			OUTPUT
MOSI	EQU	P0.1	;				OUTPUT
MISO	EQU	P0.0	;				INPUT
SS		EQU	P0.3	;slave select	OUTPUT

DSEG at 30H
x:	ds 4
y:	ds 4
bcd:	ds 5

BSEG
mf: dbit 1

CSEG

$include(math32.asm)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Initializes the ADC serial port;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
InitSerialADC:
	;initialize for bit banginging the ADC
	orl P0MOD, #00001110B	;outputs
	anl P0MOD, #11111110B	;inputs
	clr SCLK
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reads the byte stored in the ADC;
;The output is stored in R1      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Read_ADC:
	push ACC
	mov R1, #0
	mov R2, #8
Read_ADC_Loop:
	mov A, R0
	rlc A
	mov R0, A
	mov MOSI, C
	setb SCLK
	;nop
	;nop
	mov C, MISO
	mov A, R1
	rlc A
	mov R1, A
	clr SCLK
	djnz R2, Read_ADC_Loop
	pop ACC
	ret

; Configure the serial port and baud rate using timer 2
InitSerialPort:
	clr TR2 ; Disable timer 2
	mov T2CON, #30H ; RCLK=1, TCLK=1 
	mov RCAP2H, #high(T2LOAD)  
	mov RCAP2L, #low(T2LOAD)
	setb TR2 ; Enable timer 2
	mov SCON, #52H ;0101 0010 -  mode 1, receiver enable, transmit flag set
	
	ret

;;;;;;;
;Delay;
;;;;;;;
delay:
	mov R3, #20
delay_loop:
	djnz R3, Delay_loop
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;
;Waits 50 milliseconds;
;;;;;;;;;;;;;;;;;;;;;;;
Wait50ms:
;33.33MHz, 1 clk per cycle: 0.03us
	mov R0, #30
L3: mov R1, #74
L2: mov R2, #250
L1: djnz R2, L1 ;3*250*0.03us=22.5us
    djnz R1, L2 ;74*22.5us=1.665ms
    djnz R0, L3 ;1.665ms*30=50ms
    ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Converts voltage into a BCD value;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
convertVoltageToBCD:
	lcall hex2BCD
	mov dptr, #String_Numbers
	
	mov A, bcd+4
	swap A
	anl A, #0FH
	movc A, @A+dptr
	lcall putchar
	
	mov A, bcd+4
	anl A, #0FH
	movc A, @A+dptr
	lcall putchar
	
	mov A, bcd+3
	swap A
	anl A, #0FH
	movc A, @A+dptr
	lcall putchar
	
	mov A, bcd+3
	anl A, #0FH
	movc A, @A+dptr
	lcall putchar
	
	mov A, bcd+2
	swap A
	anl A, #0FH
	movc A, @A+dptr
	lcall putchar
	
	mov A, bcd+2
	anl A, #0FH
	movc A, @A+dptr
	lcall putchar
	
	mov A, bcd+1
	swap A
	anl A, #0FH
	movc A, @A+dptr
	lcall putchar
	
	mov A, bcd+1
	anl A, #0FH
	movc A, @A+dptr
	lcall putchar
	
	mov A, bcd
	swap A
	anl A, #0FH
	movc A, @A+dptr
	lcall putchar
	
	mov A, bcd
	anl A, #0FH
	movc A, @A+dptr
	lcall putchar
	
	mov dptr, #NewLine
	lcall SendString
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sends a String with the temperature through the serial port;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
displayTemperatureThroughSerial:
	mov dptr, #DecimalTemperature
	mov A, dpl
	add A, x
	mov dpl, A
	mov A, dph
	addc A, x+1
	mov dph, A	
	clr A
	movc A, @A+dptr
	
	push x
	push x+1
	
	mov x, A
	mov x+1, #0
	lcall hex2bcd
	mov dptr, #String_Numbers
		
	pop x+1
	pop x
	mov y+1, #high(560)
	mov y, #low(560)
	lcall x_gt_y
	jb mf, DTTS_Positive
	
	;send negative
	mov A, #'-'
	lcall putchar	
DTTS_Positive:
	mov A, bcd+1
	swap A
	anl A, #0FH
	movc A, @A+dptr
	lcall putchar
	
	mov A, bcd+1
	anl A, #0FH
	movc A, @A+dptr
	lcall putchar
	
	mov A, bcd
	swap A
	anl A, #0FH
	movc A, @A+dptr
	lcall putchar
	
	mov A, bcd
	anl A, #0FH
	movc A, @A+dptr
	lcall putchar
	
	mov dptr, #NewLine
	lcall SendString
	
	ret
	
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Displays voltage onto the Hex displays;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
displayTemperatureOnHex:
	mov dptr, #VoltageToBCDTemperature
	mov A, dpl
	add A, x
	mov dpl, A
	mov A, dph
	addc A, x+1
	mov dph, A
	
	clr A
	movc A, @A+dptr
	mov R7, A
	anl A, #0FH
	mov dptr, #BCD_Numbers
	movc A, @A+dptr
	mov HEX0, A
	
	mov A, R7
	swap A
	anl A, #0FH	
	movc A, @A+dptr
	mov HEX1, A
	
	;display negative
	mov y+1, #high(560)
	mov y, #low(560)
	lcall x_gt_y
	jb mf, DisplayTemperatureOnHex_Positive
	mov HEX2, #0111111b
	ret
DisplayTemperatureOnHex_Positive:
	mov HEX2, #0FFH	
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Updates the Voltage in x and x+1;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
updateVoltage:
	clr A	
	mov x+2, A
	mov x+3, A
	
	clr SS
	mov R0, #00000001B	;start bit
	lcall Read_ADC
	mov R0, #10000000B
	lcall Read_ADC
	mov A, R1
	anl A, #03H
	mov LEDRB, A
	mov x+1, A
	
	mov R0, #005H		;send trash
	lcall Read_ADC
	mov LEDRA, R1
	mov x, R1
	setb SS
	ret

; Send a character through the serial port
putchar:
    JNB TI, putchar
    CLR TI
    MOV SBUF, a
    RET

; Send a constant-zero-terminated string through the serial port
SendString:
    CLR A
    MOVC A, @A+DPTR
    JZ SSDone
    LCALL putchar
    INC DPTR
    SJMP SendString
SSDone:
    ret
 
Hello_World:
    DB  'Hello, EECE281!', '\r', '\n', 0
NewLine:
	DB	'\r','\n', 0
String_Numbers:
	DB '0','1','2','3','4','5','6','7','8','9'
BCD_Numbers:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H
    DB 092H, 082H, 0F8H, 080H, 090H
VoltageToBCDTemperature:
	DB 73H, 73H, 73H, 73H, 73H, 71H, 71H, 71H, 71H, 69H, 69H, 69H, 69H, 67H, 67H, 67H, 67H, 65H, 65H, 65H, 65H, 63H, 63H, 63H, 63H, 61H, 61H, 61H, 61H, 59H, 59H, 59H, 59H, 58H, 57H, 57H, 57H, 56H, 55H, 55H, 55H, 54H, 53H, 53H, 53H, 52H, 51H, 51H, 51H, 50H, 49H, 49H, 49H, 48H, 47H, 47H, 47H, 46H, 45H, 45H, 45H, 44H, 43H, 43H, 43H, 43H, 42H, 41H, 41H, 41H, 40H, 39H, 39H, 39H, 38H, 37H, 37H, 37H, 36H, 35H, 35H, 35H, 34H, 33H, 33H, 33H, 32H, 31H, 31H, 31H, 30H, 29H, 29H, 29H, 28H, 27H, 27H, 27H, 26H, 26H
	DB 25H, 25H, 24H, 24H, 23H, 23H, 22H, 22H, 21H, 21H, 20H, 20H, 19H, 19H, 18H, 18H, 17H, 17H, 16H, 16H, 15H, 15H, 14H, 14H, 13H, 13H, 12H, 12H, 11H, 11H, 11H, 10H, 10H, 9H, 9H, 8H, 8H, 7H, 7H, 6H, 6H, 5H, 5H, 4H, 4H, 3H, 3H, 2H, 2H, 1H, 1H, 0H, 0H, 99H, 99H, 98H, 98H, 97H, 97H, 96H, 96H, 96H, 95H, 94H, 94H, 94H, 93H, 92H, 92H, 92H, 91H, 90H, 90H, 90H, 89H, 88H, 88H, 88H, 87H, 86H, 86H, 86H, 85H, 84H, 84H, 84H, 83H, 82H, 82H, 82H, 81H, 80H, 80H, 80H, 80H, 79H, 78H, 78H, 78H, 77H
	DB 76H, 76H, 76H, 75H, 74H, 74H, 74H, 73H, 72H, 72H, 72H, 71H, 70H, 70H, 70H, 69H, 68H, 68H, 68H, 67H, 66H, 66H, 66H, 65H, 64H, 64H, 64H, 64H, 62H, 62H, 62H, 62H, 60H, 60H, 60H, 60H, 58H, 58H, 58H, 58H, 56H, 56H, 56H, 56H, 54H, 54H, 54H, 54H, 52H, 52H, 52H, 52H, 50H, 50H, 50H, 50H, 48H, 48H, 48H, 48H, 48H, 46H, 46H, 46H, 46H, 44H, 44H, 44H, 44H, 42H, 42H, 42H, 42H, 40H, 40H, 40H, 40H, 38H, 38H, 38H, 38H, 36H, 36H, 36H, 36H, 34H, 34H, 34H, 34H, 33H, 32H, 32H, 32H, 31H, 30H, 30H, 30H, 29H, 28H, 28H
	DB 28H, 27H, 26H, 26H, 26H, 25H, 24H, 24H, 24H, 23H, 22H, 22H, 22H, 21H, 20H, 20H, 20H, 19H, 18H, 18H, 18H, 18H, 17H, 16H, 16H, 16H, 15H, 14H, 14H, 14H, 13H, 12H, 12H, 12H, 11H, 10H, 10H, 10H, 9H, 8H, 8H, 8H, 7H, 6H, 6H, 6H, 5H, 4H, 4H, 4H, 3H, 2H, 2H, 2H, 1H, 1H, 0H, 0H, 99H, 99H, 98H, 98H, 97H, 97H, 96H, 96H, 95H, 95H, 94H, 94H, 93H, 93H, 92H, 92H, 91H, 91H, 90H, 90H, 89H, 89H, 88H, 88H, 87H, 87H, 86H, 86H, 86H, 85H, 85H, 84H, 84H, 83H, 83H, 82H, 82H, 81H, 81H, 80H, 80H, 79H
	DB 79H, 78H, 78H, 77H, 77H, 76H, 76H, 75H, 75H, 74H, 74H, 73H, 73H, 72H, 72H, 71H, 71H, 71H, 70H, 69H, 69H, 69H, 68H, 67H, 67H, 67H, 66H, 65H, 65H, 65H, 64H, 63H, 63H, 63H, 62H, 61H, 61H, 61H, 60H, 59H, 59H, 59H, 58H, 57H, 57H, 57H, 56H, 55H, 55H, 55H, 55H, 54H, 53H, 53H, 53H, 52H, 51H, 51H, 51H, 50H, 49H, 49H, 49H, 48H, 47H, 47H, 47H, 46H, 45H, 45H, 45H, 44H, 43H, 43H, 43H, 42H, 41H, 41H, 41H, 40H, 39H, 39H, 39H, 39H, 37H, 37H, 37H, 37H, 35H, 35H, 35H, 35H, 33H, 33H, 33H, 33H, 31H, 31H, 31H, 31H
	DB 29H, 29H, 29H, 29H, 27H, 27H, 27H, 27H, 25H, 25H, 25H, 25H, 23H, 23H, 23H, 23H, 23H, 21H, 21H, 21H, 21H, 19H, 19H, 19H, 19H, 17H, 17H, 17H, 17H, 15H, 15H, 15H, 15H, 13H, 13H, 13H, 13H, 11H, 11H, 11H, 11H, 9H, 9H, 9H, 9H, 8H, 7H, 7H, 7H, 6H, 5H, 5H, 5H, 4H, 3H, 3H, 3H, 2H, 1H, 1H, 1H, 0H, 1H, 1H, 1H, 2H, 3H, 3H, 3H, 4H, 5H, 5H, 5H, 6H, 7H, 7H, 7H, 7H, 8H, 9H, 9H, 9H, 10H, 11H, 11H, 11H, 12H, 13H, 13H, 13H, 14H, 15H, 15H, 15H, 16H, 17H, 17H, 17H, 18H, 19H
	DB 19H, 19H, 20H, 21H, 21H, 21H, 22H, 23H, 23H, 23H, 24H, 24H, 25H, 25H, 26H, 26H, 27H, 27H, 28H, 28H, 29H, 29H, 30H, 30H, 31H, 31H, 32H, 32H, 33H, 33H, 34H, 34H, 35H, 35H, 36H, 36H, 37H, 37H, 38H, 38H, 39H, 39H, 39H, 40H, 40H, 41H, 41H, 42H, 42H, 43H, 43H, 44H, 44H, 45H, 45H, 46H, 46H, 47H, 47H, 48H, 48H, 49H, 49H, 50H, 50H, 51H, 51H, 52H, 52H, 53H, 53H, 54H, 54H, 54H, 55H, 56H, 56H, 56H, 57H, 58H, 58H, 58H, 59H, 60H, 60H, 60H, 61H, 62H, 62H, 62H, 63H, 64H, 64H, 64H, 65H, 66H, 66H, 66H, 67H, 68H
	DB 68H, 68H, 69H, 70H, 70H, 70H, 70H, 71H, 72H, 72H, 72H, 73H, 74H, 74H, 74H, 75H, 76H, 76H, 76H, 77H, 78H, 78H, 78H, 79H, 80H, 80H, 80H, 81H, 82H, 82H, 82H, 83H, 84H, 84H, 84H, 85H, 86H, 86H, 86H, 86H, 88H, 88H, 88H, 88H, 90H, 90H, 90H, 90H, 92H, 92H, 92H, 92H, 94H, 94H, 94H, 94H, 96H, 96H, 96H, 96H, 98H, 98H, 98H, 98H, 0H, 0H, 0H, 0H, 2H, 2H, 2H, 2H, 2H, 4H, 4H, 4H, 4H, 6H, 6H, 6H, 6H, 8H, 8H, 8H, 8H, 10H, 10H, 10H, 10H, 12H, 12H, 12H, 12H, 14H, 14H, 14H, 14H, 16H, 16H, 16H
	DB 16H, 17H, 18H, 18H, 18H, 19H, 20H, 20H, 20H, 21H, 22H, 22H, 22H, 23H, 24H, 24H, 24H, 25H, 26H, 26H, 26H, 27H, 28H, 28H, 28H, 29H, 30H, 30H, 30H, 31H, 32H, 32H, 32H, 32H, 33H, 34H, 34H, 34H, 35H, 36H, 36H, 36H, 37H, 38H, 38H, 38H, 39H, 40H, 40H, 40H, 41H, 42H, 42H, 42H, 43H, 44H, 44H, 44H, 45H, 46H, 46H, 46H, 47H, 48H, 48H, 48H, 49H, 49H, 50H, 50H, 51H, 51H, 52H, 52H, 53H, 53H, 54H, 54H, 55H, 55H, 56H, 56H, 57H, 57H, 58H, 58H, 59H, 59H, 60H, 60H, 61H, 61H, 62H, 62H, 63H, 63H, 64H, 64H, 64H, 65H
	DB 65H, 66H, 66H, 67H, 67H, 68H, 68H, 69H, 69H, 70H, 70H, 71H, 71H, 72H, 72H, 73H, 73H, 74H, 74H, 75H, 75H, 76H, 76H, 77H, 77H, 78H, 78H, 79H, 79H, 79H, 80H, 81H, 81H, 81H, 82H, 83H, 83H, 83H, 84H, 85H, 85H, 85H, 86H, 87H, 87H, 87H, 88H, 89H, 89H, 89H, 90H, 91H, 91H, 91H, 92H, 93H, 93H, 93H, 94H, 95H, 95H, 95H, 95H, 96H, 97H, 97H, 97H, 98H, 99H, 99H, 99H, 0H, 1H, 1H, 1H, 2H, 3H, 3H, 3H, 4H, 5H, 5H, 5H, 6H, 7H, 7H, 7H, 8H, 9H, 9H, 9H, 10H, 11H, 11H, 11H, 11H, 13H, 13H, 13H, 13H
	DB 15H, 15H, 15H, 15H, 17H, 17H, 17H, 17H, 19H, 19H, 19H, 19H, 21H, 21H, 21H, 21H, 23H, 23H, 23H, 23H, 25H, 25H, 25H, 25H
DecimalTemperature:
	DB 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 254, 253, 253, 253, 252, 251, 251, 251, 250, 249, 249, 249, 248, 247, 247, 247, 246, 245, 245, 245, 244, 243, 243, 243, 243, 242, 241, 241, 241, 240, 239, 239, 239, 238, 237, 237, 237, 236, 235, 235, 235, 234, 233, 233, 233, 232, 231, 231, 231, 230, 229, 229, 229, 228, 227, 227, 227, 226, 226
	DB 225, 225, 224, 224, 223, 223, 222, 222, 221, 221, 220, 220, 219, 219, 218, 218, 217, 217, 216, 216, 215, 215, 214, 214, 213, 213, 212, 212, 211, 211, 211, 210, 210, 209, 209, 208, 208, 207, 207, 206, 206, 205, 205, 204, 204, 203, 203, 202, 202, 201, 201, 200, 200, 199, 199, 198, 198, 197, 197, 196, 196, 196, 195, 194, 194, 194, 193, 192, 192, 192, 191, 190, 190, 190, 189, 188, 188, 188, 187, 186, 186, 186, 185, 184, 184, 184, 183, 182, 182, 182, 181, 180, 180, 180, 180, 179, 178, 178, 178, 177
	DB 176, 176, 176, 175, 174, 174, 174, 173, 172, 172, 172, 171, 170, 170, 170, 169, 168, 168, 168, 167, 166, 166, 166, 165, 164, 164, 164, 164, 162, 162, 162, 162, 160, 160, 160, 160, 158, 158, 158, 158, 156, 156, 156, 156, 154, 154, 154, 154, 152, 152, 152, 152, 150, 150, 150, 150, 148, 148, 148, 148, 148, 146, 146, 146, 146, 144, 144, 144, 144, 142, 142, 142, 142, 140, 140, 140, 140, 138, 138, 138, 138, 136, 136, 136, 136, 134, 134, 134, 134, 133, 132, 132, 132, 131, 130, 130, 130, 129, 128, 128
	DB 128, 127, 126, 126, 126, 125, 124, 124, 124, 123, 122, 122, 122, 121, 120, 120, 120, 119, 118, 118, 118, 118, 117, 116, 116, 116, 115, 114, 114, 114, 113, 112, 112, 112, 111, 110, 110, 110, 109, 108, 108, 108, 107, 106, 106, 106, 105, 104, 104, 104, 103, 102, 102, 102, 101, 101, 100, 100, 99, 99, 98, 98, 97, 97, 96, 96, 95, 95, 94, 94, 93, 93, 92, 92, 91, 91, 90, 90, 89, 89, 88, 88, 87, 87, 86, 86, 86, 85, 85, 84, 84, 83, 83, 82, 82, 81, 81, 80, 80, 79
	DB 79, 78, 78, 77, 77, 76, 76, 75, 75, 74, 74, 73, 73, 72, 72, 71, 71, 71, 70, 69, 69, 69, 68, 67, 67, 67, 66, 65, 65, 65, 64, 63, 63, 63, 62, 61, 61, 61, 60, 59, 59, 59, 58, 57, 57, 57, 56, 55, 55, 55, 55, 54, 53, 53, 53, 52, 51, 51, 51, 50, 49, 49, 49, 48, 47, 47, 47, 46, 45, 45, 45, 44, 43, 43, 43, 42, 41, 41, 41, 40, 39, 39, 39, 39, 37, 37, 37, 37, 35, 35, 35, 35, 33, 33, 33, 33, 31, 31, 31, 31
	DB 29, 29, 29, 29, 27, 27, 27, 27, 25, 25, 25, 25, 23, 23, 23, 23, 23, 21, 21, 21, 21, 19, 19, 19, 19, 17, 17, 17, 17, 15, 15, 15, 15, 13, 13, 13, 13, 11, 11, 11, 11, 9, 9, 9, 9, 8, 7, 7, 7, 6, 5, 5, 5, 4, 3, 3, 3, 2, 1, 1, 1, 0, 1, 1, 1, 2, 3, 3, 3, 4, 5, 5, 5, 6, 7, 7, 7, 7, 8, 9, 9, 9, 10, 11, 11, 11, 12, 13, 13, 13, 14, 15, 15, 15, 16, 17, 17, 17, 18, 19
	DB 19, 19, 20, 21, 21, 21, 22, 23, 23, 23, 24, 24, 25, 25, 26, 26, 27, 27, 28, 28, 29, 29, 30, 30, 31, 31, 32, 32, 33, 33, 34, 34, 35, 35, 36, 36, 37, 37, 38, 38, 39, 39, 39, 40, 40, 41, 41, 42, 42, 43, 43, 44, 44, 45, 45, 46, 46, 47, 47, 48, 48, 49, 49, 50, 50, 51, 51, 52, 52, 53, 53, 54, 54, 54, 55, 56, 56, 56, 57, 58, 58, 58, 59, 60, 60, 60, 61, 62, 62, 62, 63, 64, 64, 64, 65, 66, 66, 66, 67, 68
	DB 68, 68, 69, 70, 70, 70, 70, 71, 72, 72, 72, 73, 74, 74, 74, 75, 76, 76, 76, 77, 78, 78, 78, 79, 80, 80, 80, 81, 82, 82, 82, 83, 84, 84, 84, 85, 86, 86, 86, 86, 88, 88, 88, 88, 90, 90, 90, 90, 92, 92, 92, 92, 94, 94, 94, 94, 96, 96, 96, 96, 98, 98, 98, 98, 100, 100, 100, 100, 102, 102, 102, 102, 102, 104, 104, 104, 104, 106, 106, 106, 106, 108, 108, 108, 108, 110, 110, 110, 110, 112, 112, 112, 112, 114, 114, 114, 114, 116, 116, 116
	DB 116, 117, 118, 118, 118, 119, 120, 120, 120, 121, 122, 122, 122, 123, 124, 124, 124, 125, 126, 126, 126, 127, 128, 128, 128, 129, 130, 130, 130, 131, 132, 132, 132, 132, 133, 134, 134, 134, 135, 136, 136, 136, 137, 138, 138, 138, 139, 140, 140, 140, 141, 142, 142, 142, 143, 144, 144, 144, 145, 146, 146, 146, 147, 148, 148, 148, 149, 149, 150, 150, 151, 151, 152, 152, 153, 153, 154, 154, 155, 155, 156, 156, 157, 157, 158, 158, 159, 159, 160, 160, 161, 161, 162, 162, 163, 163, 164, 164, 164, 165
	DB 165, 166, 166, 167, 167, 168, 168, 169, 169, 170, 170, 171, 171, 172, 172, 173, 173, 174, 174, 175, 175, 176, 176, 177, 177, 178, 178, 179, 179, 179, 180, 181, 181, 181, 182, 183, 183, 183, 184, 185, 185, 185, 186, 187, 187, 187, 188, 189, 189, 189, 190, 191, 191, 191, 192, 193, 193, 193, 194, 195, 195, 195, 195, 196, 197, 197, 197, 198, 199, 199, 199, 200, 201, 201, 201, 202, 203, 203, 203, 204, 205, 205, 205, 206, 207, 207, 207, 208, 209, 209, 209, 210, 211, 211, 211, 211, 213, 213, 213, 213
	DB 215, 215, 215, 215, 217, 217, 217, 217, 219, 219, 219, 219, 221, 221, 221, 221, 223, 223, 223, 223, 225, 225, 225, 225

MyProgram:
    MOV SP, #7FH
    mov LEDRA, #0
    mov LEDRB, #0
    mov LEDRC, #0
    mov LEDG, #0
    
    LCALL InitSerialPort
    lcall InitSerialADC
    
Forever:
	lcall UpdateVoltage	
	lcall Delay
	
	lcall DisplayTemperatureOnHex
	lcall DisplayTemperatureThroughSerial
	
delay1s:
	;mov R6, #20
	lcall wait50ms
	;djnz R6, delay1s
	
    sjmp Forever
END
