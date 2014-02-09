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
						1.1)Welcome_message
						1.2)Soak_Temperature_Input
						1.3)Reflow_Temperature_Input
						1.4)Reflow_Time_Input
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
;					note: time is given is seconds, and temperature is given in degrees C. both take two registers to store
;

;----------------------------------------------------
CSEG

User_Interface_Init:
	;lcall Settings_Initialization	
ret
	

;Function: Gets the correct parameters for over control from the user	
UI_Set_Up_Parameters:
;Settings_Initializations:
	;lcall LCD_Init

	lcall Display_welcome_message

	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec

Settings_Initialization_nonwelcome:
	lcall Display_soak_temp_set
	lcall Wait_for_Values
	mov soak_temp+0, bcd+0
	mov soak_temp+1, bcd+1
	mov bcd+2, 0

	lcall Display_soak_time_set
	lcall Wait_for_Values
	mov soak_time+0, bcd+0
	mov soak_time+1, bcd+1
	mov bcd+2, 0 

	lcall Display_reflow_temp_set
	lcall Wait_for_Values
	mov reflow_temp+0, bcd+0
	mov reflow_temp+1, bcd+1
	mov bcd+2, 0 

	lcall Display_reflow_time_set
	lcall Wait_for_Values
	mov reflow_temp+0, bcd+0
	mov reflow_temp+1, bcd+1
	mov bcd+2, 0 

	lcall Display_Confirmation_message 

ret


;Function: Waits for the user to enter a value, and leaves the loop if Switch17 is ;pressed
Wait_for_Values:
Wait_for_Values_loop: 
	lcall ReadNumber
	jnc Wait_for_Values_loop
	lcall Shift_Digits
	lcall Display
	jnb KEY0, wait_key0
	ljmp Wait_for_Values_loop


wait_key0:
	jb Key0, Return_function
	jmp wait_key0

Return_function
	ret


Wait_for_Confirmation:
	jnb KEY0, Return_function
	jnb KEY1, Settings_Initialization_nonwelcome
	jmp Wait_for_confirmation

;Function: Displays the welcome message 
;			("Welcome! Please enter oven parameters")
Welcome_message:
ret

;Function: Waits for user to input the soak temperature
Soak_Temperature_Input:
ret

;Function: Waits for user to input the soak time
Soak_Time_Input:
ret

;Function: Waits for user to input the reflow temperature
Reflow_Temperature_Input:
ret

;Function: Waits for user to input the reflow time
Reflow_Time_Input:
ret


$LIST
