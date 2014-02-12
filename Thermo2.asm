$NOLIST
;----------------------------------------------------
;	Thermocouple/Serial Input Interface
; 
;	Kyujin Park, Nina Dacanay, Glyn Han, Derek Chan
;	
;	Function:	1) 	Reads the voltage from the K-Type Thermocouple connected to 
;				   	the MCP 3004 ADC Converter
;				2) 	Converts the temperature and stores it as a binary value in
;					the variable Temperature_Measured				   
;
;	Constants and Variables to be declared:
;			MISO 	EQU P0.0
;			MOSI	EQU P0.1
;			SCLK	EQU P0.2
;			CE_ADC	EQU P0.3			
;			Temperature_Measured:	ds 2
;			Temperature_Measured_Sign: db 1
;
;	Functions: 
;			Thermocouple_Input_Read_ADC
;
;	Equation(voltage to temp) :  The equation above 0 �C is of the form 
;								 E = sum(i=0 to n) c_i t^i + a0 exp(a1 (t - a2)^2)
;	  
;----------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Thermocouple_Input_Init								
;														
;Initializes Port 0 to be used for SPI communication	
;														
;@modifies	P0MOD, CE_ADC, SCLK							
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Thermocouple_Input_Init:
	orl P0MOD, #00001000b ; make CE_ADC* output	
	setb CE_ADC	;	disables ADC initially - we aren't using it yet
	lcall Thermocouple_Input_INIT_SPI
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Thermocouple_Update
;
;Updates the temperature variables.
;Reads from Thermocouple and LM335, adds the temperatures,
;and stores the resulting temperature in Temperature_Measured
;
;@modifies	Temperature_Measured+0			-	"True" temperature 	LSBs
;			Temperature_Measured+1			-						MSBs
;			Outside_Temperature_Measured	-	LM335 variable
;			R7, R6, R1, R0, ACC, PSW, CE_ADC
;			x			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Thermocouple_Update:
	lcall Thermocouple_ReadCH0
	lcall Thermocouple_ReadCH1
	mov A, Temperature_Measured+0
	add A, Outside_Temperature_Measured
	clr c
	subb A, #THERMO_TEMP_ADJ
	mov Temperature_Measured+0, A
	mov A, Temperature_Measured+1
	addc A, #0
	mov Temperature_Measured+1, A
	ret
	
;-----------------------------------------------------------------------------------------
;Helper subroutines - not used in the main program
;-----------------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Oven
;
;@returns Temperature_Measured
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Thermocouple_ReadCH0:
	mov B, #0
	lcall Thermocouple_Input_Read_ADC		
	lcall Thermocouple_Input_Convert_Binary_To_Temperature
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Outside
;
;@returns Temperature_Measured_Outside
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Thermocouple_ReadCH1:
	mov B, #1
	lcall Thermocouple_Input_Read_ADC
	lcall Thermocouple_Input_Convert_Binary_To_Outside_Temperature
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Thermocouple_Input_Read_ADC								
;															
;Reads the 10-bit value from the ADC and stores it in		
;the registers. Automatically follows the reading with a 
;conversion of the temperature to be stored 
;
;@returns	R7 - Most significant bits 	(XXXXXX98 binary)	
;			R6 - Least significant bits	(76543210 binary)
;			Temperature_Measured+0 - LSBs
;			Temperature_Measured+1 - MSBs	
;@modifies	A, R0, R1, R6, R7, PSW								
;			CE_ADC
;			x, Temperature_Measured											
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Thermocouple_Input_Read_ADC:
	clr CE_ADC
	mov R0, #00000001B ; Start bit:1
	lcall Thermocouple_Input_Do_SPI
	
Thermocouple_Input_Read_ADC_Subroutine:	
	mov a, b
	swap a
	anl a, #0F0H
	setb acc.7 ; Single mode (bit 7).
	
	mov R0, a ;  Select channel
	lcall Thermocouple_Input_Do_SPI
	mov a, R1          ; R1 contains bits 8 and 9
	anl a, #03H
	mov R7, a
	
	mov R0, #55H ; Send them trash. Ye boi.
	lcall Thermocouple_Input_Do_SPI
	mov a, R1    ; R1 contains bits 0 to 7
	mov R6, a
	setb CE_ADC	
	
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Thermocouple_Input_BinaryToTemperature						
;															
;Lookup table used for the conversion of binary values		
;from the ADC into temperature values. Note that 2-bytes	
;are needed to store the values							
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Thermocouple_Input_BinaryToTemperature:
	DW 000, 000, 001, 001, 001, 001, 002, 002, 002, 003, 003, 003, 003, 004, 004, 004, 004, 005, 005, 005, 006, 006, 006, 006, 007, 007, 007, 008, 008, 008, 008, 009, 009, 009, 010, 010, 010, 010, 011, 011, 011, 011, 012, 012, 012, 013, 013, 013, 013, 014, 014, 014, 015, 015, 015, 015, 016, 016, 016, 017, 017, 017, 017, 018, 018, 018, 018, 019, 019, 019, 020, 020, 020, 020, 021, 021, 021, 022, 022, 022, 022, 023, 023, 023, 024, 024, 024, 024, 025, 025, 025, 025, 026, 026, 026, 027, 027, 027, 027, 028, 028, 028, 029, 029, 029, 029, 030, 030, 030, 031, 031, 031, 031, 032, 032, 032, 032, 033, 033, 033, 034, 034, 034, 034, 035, 035, 035, 036, 036, 036, 036, 037, 037, 037, 038, 038, 038, 038, 039, 039, 039, 040, 040, 040, 040, 041, 041, 041, 041, 042, 042, 042, 043, 043, 043, 043, 044, 044, 044, 045, 045, 045, 045, 046, 046, 046, 047, 047, 047, 047, 048, 048, 048, 048, 049, 049, 049, 050, 050, 050, 050, 051, 051, 051, 052, 052, 052, 052, 053, 053, 053, 054, 054, 054, 054, 055, 055, 055, 055, 056
	DW 056, 056, 057, 057, 057, 057, 058, 058, 058, 059, 059, 059, 059, 060, 060, 060, 061, 061, 061, 061, 062, 062, 062, 062, 063, 063, 063, 064, 064, 064, 064, 065, 065, 065, 066, 066, 066, 066, 067, 067, 067, 068, 068, 068, 068, 069, 069, 069, 069, 070, 070, 070, 071, 071, 071, 071, 072, 072, 072, 073, 073, 073, 073, 074, 074, 074, 075, 075, 075, 075, 076, 076, 076, 076, 077, 077, 077, 078, 078, 078, 078, 079, 079, 079, 080, 080, 080, 080, 081, 081, 081, 082, 082, 082, 082, 083, 083, 083, 083, 084, 084, 084, 085, 085, 085, 085, 086, 086, 086, 087, 087, 087, 087, 088, 088, 088, 089, 089, 089, 089, 090, 090, 090, 090, 091, 091, 091, 092, 092, 092, 092, 093, 093, 093, 094, 094, 094, 094, 095, 095, 095, 096, 096, 096, 096, 097, 097, 097, 097, 098, 098, 098, 099, 099, 099, 099, 100, 100, 100, 101, 101, 101, 101, 102, 102, 102, 103, 103, 103, 103, 104, 104, 104, 104, 105, 105, 105, 106, 106, 106, 106, 107, 107, 107, 108, 108, 108, 108, 109, 109, 109, 110, 110, 110, 110, 111, 111, 111, 111, 112
	DW 112, 112, 113, 113, 113, 113, 114, 114, 114, 115, 115, 115, 115, 116, 116, 116, 117, 117, 117, 117, 118, 118, 118, 119, 119, 119, 119, 120, 120, 120, 120, 121, 121, 121, 122, 122, 122, 122, 123, 123, 123, 124, 124, 124, 124, 125, 125, 125, 126, 126, 126, 126, 127, 127, 127, 127, 128, 128, 128, 129, 129, 129, 129, 130, 130, 130, 131, 131, 131, 131, 132, 132, 132, 133, 133, 133, 133, 134, 134, 134, 134, 135, 135, 135, 136, 136, 136, 136, 137, 137, 137, 138, 138, 138, 138, 139, 139, 139, 140, 140, 140, 140, 141, 141, 141, 141, 142, 142, 142, 143, 143, 143, 143, 144, 144, 144, 145, 145, 145, 145, 146, 146, 146, 147, 147, 147, 147, 148, 148, 148, 148, 149, 149, 149, 150, 150, 150, 150, 151, 151, 151, 152, 152, 152, 152, 153, 153, 153, 154, 154, 154, 154, 155, 155, 155, 155, 156, 156, 156, 157, 157, 157, 157, 158, 158, 158, 159, 159, 159, 159, 160, 160, 160, 161, 161, 161, 161, 162, 162, 162, 162, 163, 163, 163, 164, 164, 164, 164, 165, 165, 165, 166, 166, 166, 166, 167, 167, 167, 168, 168
	DW 168, 168, 169, 169, 169, 169, 170, 170, 170, 171, 171, 171, 171, 172, 172, 172, 173, 173, 173, 173, 174, 174, 174, 175, 175, 175, 175, 176, 176, 176, 176, 177, 177, 177, 178, 178, 178, 178, 179, 179, 179, 180, 180, 180, 180, 181, 181, 181, 182, 182, 182, 182, 183, 183, 183, 183, 184, 184, 184, 185, 185, 185, 185, 186, 186, 186, 187, 187, 187, 187, 188, 188, 188, 189, 189, 189, 189, 190, 190, 190, 190, 191, 191, 191, 192, 192, 192, 192, 193, 193, 193, 194, 194, 194, 194, 195, 195, 195, 196, 196, 196, 196, 197, 197, 197, 198, 198, 198, 198, 199, 199, 199, 199, 200, 200, 200, 201, 201, 201, 201, 202, 202, 202, 203, 203, 203, 203, 204, 204, 204, 205, 205, 205, 205, 206, 206, 206, 206, 207, 207, 207, 208, 208, 208, 208, 209, 209, 209, 210, 210, 210, 210, 211, 211, 211, 212, 212, 212, 212, 213, 213, 213, 213, 214, 214, 214, 215, 215, 215, 215, 216, 216, 216, 217, 217, 217, 217, 218, 218, 218, 219, 219, 219, 219, 220, 220, 220, 220, 221, 221, 221, 222, 222, 222, 222, 223, 223, 223, 224, 224
	DW 224, 224, 225, 225, 225, 226, 226, 226, 226, 227, 227, 227, 227, 228, 228, 228, 229, 229, 229, 229, 230, 230, 230, 231, 231, 231, 231, 232, 232, 232, 233, 233, 233, 233, 234, 234, 234, 234, 235, 235, 235, 236, 236, 236, 236, 237, 237, 237, 238, 238, 238, 238, 239, 239, 239, 240, 240, 240, 240, 241, 241, 241, 241, 242, 242, 242, 243, 243, 243, 243, 244, 244, 244, 245, 245, 245, 245, 246, 246, 246, 247, 247, 247, 247, 248, 248, 248, 248, 249, 249, 249, 250, 250, 250, 250, 251, 251, 251, 252, 252, 252, 252, 253, 253, 253, 254, 254, 254, 254, 255, 255, 255, 255, 256, 256, 256, 257, 257, 257, 257, 258, 258, 258, 259, 259, 259, 259, 260, 260, 260, 261, 261, 261, 261, 262, 262, 262, 262, 263, 263, 263, 264, 264, 264, 264, 265, 265, 265, 266, 266, 266, 266, 267, 267, 267, 268, 268, 268, 268, 269, 269, 269, 269, 270, 270, 270, 271, 271, 271, 271, 272, 272, 272, 273, 273, 273, 273, 274, 274, 274, 275, 275, 275, 275, 276, 276, 276, 277, 277, 277, 277, 278, 278, 278, 278, 279, 279, 279, 280, 280
	DW 280, 280, 281, 281, 281, 282, 282, 282, 282, 283, 283, 283, 284, 284, 284, 284, 285, 285, 285, 285, 286, 286, 286, 287

;;;;;;;;;;;;;;;;;;;;;
;Helper delay loop	
;Uses R3			
;;;;;;;;;;;;;;;;;;;;;
Thermocouple_Input_Delay:
	mov R3, #20
Thermocouple_Input_Delay_loop:
	djnz R3, Thermocouple_Input_Delay_loop
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Thermocouple_Input_INIT_SPI			
;										
;Helper subroutine to initialize SPI		
;										
;@requires:	SCLK	 	as P0.2			
;			MISO		as P0.0			
;			MOSI		as P0.1			
;			CE_ADC*		as P0.3			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Thermocouple_Input_INIT_SPI:
    orl P0MOD, #00000110b ; Set SCLK, MOSI as outputs
    anl P0MOD, #11111110b ; Set MISO as input
    clr SCLK              ; For mode (0,0) SCLK is zero
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Thermocouple_Input_Do_SPI
;
;Helper subroutine								
;														
;Runs the SPI routine to read/write						
;														
;@param		R0 - the byte to write out					
;@returns	R1 - the byte read by the routine																	
;@modifies	R0, R1, R2,									
;			MISO, MOSI, SCLK							
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Thermocouple_Input_Do_SPI:
	push acc
	push psw
    mov R1, #0            ; Received byte stored in R1
    mov R2, #8            ; Loop counter (8-bits)
Thermocouple_Input_Do_SPI_Loop:
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
    djnz R2, Thermocouple_Input_Do_SPI_Loop
    pop psw
    pop acc
    ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Thermocouple_Input_Convert_Binary_To_Temperature
;
;Helper subroutine
;
;Converts the binary voltage reading from the ADC into
;a 2-byte temperature value in binary
;
;@param		R7 - MSBs of the binary voltage reading
;			R6 - LSBs of the binary voltage reading
;@returns	Temperature_Measured - 2-byte temperature value
;				T_M+0 - Least significant byte
;				T_M+1 - Most significant byte
;@modifies	A, DPTR, PSW, x, x+1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Thermocouple_Input_Convert_Binary_To_Temperature:
	;dptr = LUT + (2 * binary value)
	mov dptr, #Thermocouple_Input_BinaryToTemperature
	clr C
	mov A, dpl
	add A, R6
	mov dpl, A
	mov A, dph
	addc A, R7
	mov dph, A
	clr C
	mov A, dpl
	add A, R6
	mov dpl, A
	mov A, dph
	addc A, R7
	mov dph, A
	
	clr A
	movc A, @A+dptr
	mov Temperature_Measured+1, A	;high part is stored first
	inc dptr
	clr A
	movc A, @A+dptr
	mov Temperature_Measured+0, A	;then low part
	
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Thermocouple_Input_Binary_To_Outside_Temperature						
;															
;Lookup table used for the conversion of binary values		
;from the ADC into temperature values. Note that 2-bytes	
;are needed to store the values							
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Thermocouple_LM335_LUT:
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Thermocouple_Input_Convert_Binary_To_Outside_Temperature
;
;Helper subroutine
;
;Converts the binary voltage reading from the ADC into
;a 2-byte temperature value in binary
;
;@param		R7 - MSBs of the binary voltage reading
;			R6 - LSBs of the binary voltage reading
;@returns	Temperature_Measured - 2-byte temperature value
;				T_M+0 - Least significant byte
;				T_M+1 - Most significant byte
;				Temperature_Measured_Sign: db 1
;@modifies	A, DPTR, PSW, x, x+1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Thermocouple_Input_Convert_Binary_To_Outside_Temperature:

	mov x+0, R6
	mov x+1, R7	
	mov y+1, #high(560)
	mov y+0, #low(560)
	lcall x_gt_y
	
	mov Temperature_Measured_Sign, mf

	;dptr = LUT + (2 * binary value)
	mov dptr, #Thermocouple_LM335_LUT
	clr C
	mov A, dpl
	add A, R6
	mov dpl, A
	mov A, dph
	addc A, R7
	mov dph, A
	
	clr A
	movc A, @A+dptr
	mov Outside_Temperature_Measured+0, A
			
	ret

$LIST