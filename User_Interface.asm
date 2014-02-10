$NOLIST
;----------------------------------------------------
;	User Interface
; 
;	Jessica Hua and Sasha Dordzijev
;	
;	Function: 1)Settings Initialization (Settings_Initialization)
;				Called at the beginning of the code, this is the user interface
;				function used to get the temperature settings and stores them 
;				into registers. 
;						1.1)Welcome_message
;						1.2)Soak_Temperature_Input
;						1.3)Reflow_Temperature_Input
;						1.4)Reflow_Time_Input
;
;  			  2)Checking for other inputs (Check_Inputs)
;				Provides a check to the other user inputs used during the heating
;				process (ie force stop / oven open)
;
;			  3)Status Display / Value Display (Display_board)
;				Ability to write to the Hex Display / LCD Display and output set 
;				messages onto the LCD Display 	
;		
;	Inputs: 	1) Switches 0-9 for inputing digits
;				2) Switch 10 for Pressing Enter
;				3) Switch 11 for Pressing Back
;				4)Switch 12 for switching between Celcius/Kelvin/Farhenheit
;
;	Outputs: 	1)HEX Display (writes the correct value to x+0 and x+1, and calls hex2bcd and display
;				2) LCD Display depending on status (Derek's portion) displays the
;				current state that it is in (Set Up/Heating/Cooldown etc) and
;				also displays what you want to enter in the initialization portion
;
;	Memory: 	1) Soak Temperature - soak_temperature
;				2) Soak Time - soak_time
;				3) Reflow Temperature - reflow_temperature
;				4) Reflow Time        - relow_time
;					note: time is given is seconds, and temperature is given; indegrees C. both take two registers to store
;

;----------------------------------------------------
CSEG
;Function: Gets the correct parameters for over control from the user	
UI_Set_Up_Parameters:
;Settings_Initializations:
	

	lcall Display_welcome_message

	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec

Settings_Initialization_nonwelcome:
	lcall Display_soak_temp_set
	lcall Wait_for_Values
	mov soak_temperature+0, bcd+0
	mov soak_temperature+1, bcd+1
	mov soak_temperature+2, bcd+2
	mov bcd+2, #0
	mov bcd+0, #0
	mov bcd+1, #0


	lcall Display_soak_time_set
	lcall Wait_for_Values
	mov soak_time+0, bcd+0
	mov soak_time+1, bcd+1
	mov soak_time+2, bcd+2
	mov bcd+2, #0
	mov bcd+0, #0
	mov bcd+1, #0 

	lcall Display_reflow_temp_set
	lcall Wait_for_Values
	mov reflow_temperature+0, bcd+0
	mov reflow_temperature+1, bcd+1
	mov reflow_temperature+2, bcd+2 
	mov bcd+2, #0 
	mov bcd+0, #0
	mov bcd+1, #0

	lcall Display_reflow_time_set
	lcall Wait_for_Values
	mov reflow_time+0, bcd+0
	mov reflow_time+1, bcd+1
	mov reflow_time+2, bcd+2
	mov bcd+2, #0 
	mov bcd+0, #0
	mov bcd+1, #0
	lcall Display

	lcall Display_Confirmation_message 

ret
;Function: Waits for the user to enter a value, and leaves the loop if Switch17 is ;pressed
Wait_for_Confirmation:
	jnb KEY.2, Settings_Initialization_nonwelcome
	jnb KEY.1, Return_function
	jmp Wait_for_confirmation


Wait_for_Values:
;Wait_for_Values_loop: 
	lcall Display
	lcall ReadNumber
	jnb KEY.1, wait_key0
	jnc Wait_for_Values
	lcall Shift_Digits
	lcall Display

	ljmp Wait_for_Values


wait_key0:
	jb KEY.1, Return_function
	jmp wait_key0

Return_function:
	ret

WaitHalfSec:
	mov R2, #90
N3: mov R1, #250
N2: mov R0, #250
N1: djnz R0, N1 ; 3 machine cycles-> 3*30ns*250=22.5us
	djnz R1, N2 ; 22.5us*250=5.625ms
	djnz R2, N3 ; 5.625ms*90=0.5s (approximately)
	ret
	
Display_R57:
	mov dptr, #myLUT
	; Display Digit 0
    mov A, bcd+0
    anl a, #0fh
    movc A, @A+dptr
    mov R5, A
	; Display Digit 1
    mov A, bcd+0
    swap a
    anl a, #0fh
    movc A, @A+dptr
    mov R6, A
	; Display Digit 2
    mov A, bcd+1
    anl a, #0fh
    movc A, @A+dptr
    mov R7, A
	; Display Digit 3
    ;mov A, bcd+1
    ;swap a
    ;anl a, #0fh
    ;movc A, @A+dptr
    ;mov HEX3, A
	; Display Digit 4
    ;mov A, bcd+2
    ;anl a, #0fh
    ;movc A, @A+dptr
    ;mov HEX4, A
    ret
	
end
