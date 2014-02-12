$NOLIST
;----------------------------------------------------
;	Serial Port Interface
; 
;	Nina Dacanay 
;
;	Function:  1.)Takes and Reads the temperature from 
;				 the K-Type thermocouple connected to 
;				 the MCP3004 ADC Converter.
;				  
;			   2.)Displays the temperature to a Python
;				 Strip Chart through the Serial Port.
;	
;	Inputs:    1.)Temperature
;	Outputs:   2.)Temperature Strip Chart
;
;   Timers used:
;			   1.)Timer 2 (To configure the srial port and baud rate)
;
;	Look-up tables used:
;			   1.)Serial_Port_My_Lut_ASCII
;	
;	Constants to be initialized:
;			   1.)T2LOAD EQU 65536-(FREQ/(32*BAUD))
;			   2.)FREQ   EQU 33333333
;			   3.)BAUD   EQU 115200
;	Variables and Registers: 
;				1.)Accumulator
;			    2.)Temperature_Measured
;			  	3.)SBUF
;				     
;----------------------------------------------------

CSEG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Serial_Port_My_Lut_ASCII							
;														
;Look-up table for the Python Strip Chart
;		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
Serial_Port_My_Lut_ASCII:
	DB 030H, 031H, 032H, 033H, 034H       ; 0 TO 4
    DB 035H, 036H, 037H, 038H, 039H       ; 4 TO 9
    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Serial_Port_Init							
;														
;Initializes Timer 2 to be used for Serial Port Communication
;Initializes SCON to enable the use of the Serial Port 	
;														
;@modifies	Timer 2 
;			SCON		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Serial_Port_Init:
	
	clr TR2 ; Disable timer 2
	mov T2CON, #30H ; RCLK=1, TCLK=1 
	mov RCAP2H, #high(T2LOAD)  
	mov RCAP2L, #low(T2LOAD)
	setb TR2 ; Enable timer 2
	mov SCON, #52H	
	
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Serial_Port_Putchar							
;														
;Send a character to register SBUF that is output from the serial port 	
;														
;@modifies	SBUF	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
Serial_Port_Putchar:
    JNB TI, Serial_Port_Putchar
    CLR TI
    MOV SBUF, a
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Serial_Port_Send_String							
;														
;Send a constant string that is terminated with an '\n' through the serial port
;
;I kept the code to display the temperature in the hex displays for testing purposes
;														
;@modifies	SBUF
;			BCD+0, BCD+1, BCD+2	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Serial_Port_Send_String:
	mov x+0, Temperature_Measured
	mov x+1, Temperature_Measured+1
	lcall hex2bcd
	mov dptr, #Serial_Port_My_Lut_ASCII
	
	;jb Temperature_Measured_Sign, Serial_Port_Send_String_positive
	;mov A, #'-'
	;lcall Serial_Port_Putchar
	
Serial_Port_Send_String_positive:
	; Display Digit 5
    mov A, bcd+2
    swap a
    anl a, #0fh
    movc A, @A+dptr
    lcall Serial_Port_Putchar  
    
    ; Display Digit 4
    mov A, bcd+2
    anl a, #0fh
    movc A, @A+dptr
    lcall Serial_Port_Putchar
    
	; Display Digit 3
    mov A, bcd+1
    swap a
    anl a, #0fh
    movc A, @A+dptr
    lcall Serial_Port_Putchar
    
    ; Display Digit 2
    mov A, bcd+1
    anl a, #0fh
    movc A, @A+dptr
    lcall Serial_Port_Putchar
    	
	; Display Digit 1
    mov A, bcd+0
    swap a
    anl a, #0fh
    movc A, @A+dptr
    lcall Serial_Port_Putchar
    
    ; Display Digit 0
    mov A, bcd+0
    anl a, #0fh
    movc A, @A+dptr
    lcall Serial_Port_Putchar
    
    mov A, #'\r'
    lcall Serial_Port_Putchar
    mov A, #'\n'
    lcall Serial_Port_Putchar
    ret  	
	
$LIST	
	

