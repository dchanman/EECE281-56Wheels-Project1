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
;						1.1)Displays Welcome_message
;						1.2)Displays Manual or Preset
;							- checks to see if the user wants preset(KEY3)or manual (KEY2)
;						1.3)Manual Setting
;							1.3.1)Displays Enter_Soak_temp 			
; 							1.3.2)Waits_for_Values 	
;									-waits for the value from the switches
;									 and waits for Key1 for continue		 
;							1.3.3)Displays Enter_Soak_time
;							1.3.4)Wait_for_Values
;							1.3.5)Displays Enter_Reflow_temp
;							1.3.6)Wait_for_values
;							1.3.7)Displays Enter_Reflow_time
;							1.3.8)Wait_for_Values
;						1.4)Preset Setting
;							1.4.1)Displays Display_options
;							1.4.2)Wait_for_preset_values
;									-waits for the values from 
;									 switch 1-3 and KEY1 for continue
;						1.5)Displays Confirmation_Message
;
;			  3)Status Display / Value Display (Display_board)
;					function: Displays Current Temp / Target Temp to top line 	
;							  Displays Status on bottom line
;
;	Inputs: 	1) Switches 0-9 for inputing digits
;				2) KEY1 for Pressing Continue
;				3) KEY2 for manual
;				4) KEY3 for preset
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
	
	;Displays that the reflow oven controller is on
	lcall Display_welcome_message
	
	;waits 2 seconds
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
	
	lcall Display_preset_or_manual
	;waits for the user to choose preset or manual
	ljmp Wait_for_preset_or_manual
	
preset:
	;Displays the options
	lcall Display_options
	lcall turnoff_7seg
	;waits for the user to choose an option
	ljmp Wait_for_preset_values
	lcall turnoff_7seg

Settings_Initialization_nonwelcome:
	;Setting up Soak_temp
	lcall Display_soak_temp_set
	lcall Wait_for_Values
	mov soak_temperature+0, bcd+0
	mov soak_temperature+1, bcd+1
	mov soak_temperature+2, bcd+2
	mov bcd+2, #0
	mov bcd+0, #0
	mov bcd+1, #0

	;Setting up Soak Time
	lcall Display_soak_time_set
	lcall Wait_for_Values
	mov soak_time+0, bcd+0
	mov soak_time+1, bcd+1
	mov soak_time+2, bcd+2
	mov bcd+2, #0
	mov bcd+0, #0
	mov bcd+1, #0 

;	Setting Up Reflow Temp
	lcall Display_reflow_temp_set
	lcall Wait_for_Values
	mov reflow_temperature+0, bcd+0
	mov reflow_temperature+1, bcd+1
	mov reflow_temperature+2, bcd+2 
	mov bcd+2, #0 
	mov bcd+0, #0
	mov bcd+1, #0

	;Setting Up Reflow Time
	lcall Display_reflow_time_set
	lcall Wait_for_Values
	mov reflow_time+0, bcd+0
	mov reflow_time+1, bcd+1
	mov reflow_time+2, bcd+2
	mov bcd+2, #0 
	mov bcd+0, #0
	mov bcd+1, #0
	lcall Display

;Displays the confirmation message
Confirmation_message:
	lcall turnoff_7seg
	lcall Display_Confirmation_message
	;converts all values from BCD into hex for all 
	;the stored parameters 
	lcall convertbcd2hex
	ret

;Waits for the user to choose an option, or KEY3 for back
wait_for_preset_values:
	jnb KEY.3, preset
	jb SWA.1, option1
	jb SWA.2, option2
	jb SWA.3, option3
	jmp wait_for_preset_values


;Waits for the user to choose preset or manual
Wait_for_preset_or_manual:
	jnb KEY.3, jump_Settings_initialization_nonwelcome ;key 3 is preset values
	jnb KEY.2, wait_key2 ;key 2 is manual
	jmp wait_for_preset_or_manual

;because jumps suck
jump_settings_Initialization_nonwelcome:
	ljmp settings_initialization_nonwelcome
	
;wait for KEY.2 to be unpressed	
wait_key2:
	jb KEY.2, jump_Preset
	jmp wait_key2

;because jumps suck
jump_preset:
	ljmp preset



Wait_for_Confirmation:
	jnb KEY.2, jump_Settings_Initialization_nonwelcome
	jnb KEY.1, Return_function
	jmp Wait_for_confirmation

;Function: Waits for the user to enter a value, and leaves the loop if KEY1 is pressed	
Wait_for_Values:
;Wait_for_Values_loop: 
	lcall Display
	lcall ReadNumber
	jnb KEY.1, wait_key1
	jnc Wait_for_Values
	lcall Shift_Digits
	lcall Display

	ljmp Wait_for_Values


;waits for KEY1 to be unpressed
wait_key1:
	jb KEY.1, Return_function
	jmp wait_key1

;because I suck at coding
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


;Writes the correct values to the parameters depending 
;on what option was chosen
option1:
	;move values into the correct registers
	mov soak_temperature+0, #00110000B
	mov soak_temperature+1, #00000001B
	mov soak_time+0, #00000101B
	mov soak_time+1, #00000000B
	mov reflow_temperature+0, #00010000B
	mov reflow_temperature+1, #00000010B
	mov reflow_time+0, #00000101B
	mov reflow_time+1, #00000000B
	ljmp confirmation_message
option2:
	mov soak_temperature+0, #01010000B
	mov soak_temperature+1, #00000001B
	mov soak_time+0, #10010000B
	mov soak_time+1, #00000000B
	mov reflow_temperature+0, #00100000B
	mov reflow_temperature+1, #00000010B
	mov reflow_time+0, #01000000B
	mov reflow_time+1, #00000000B
	ljmp confirmation_message
option3:
	mov soak_temperature+0, #01110000B
	mov soak_temperature+1, #00000001B
	mov soak_time+0, #00100000B
	mov soak_time+1, #00000001B
	mov reflow_temperature+0, #00110000B
	mov reflow_temperature+1, #00000010B
	mov reflow_time+0, #01000101B
	mov reflow_time+1, #00000000B
	ljmp confirmation_message
	
;converts values from bcd2hex and stores it into the parameters	
convertbcd2hex:
	mov bcd+0, soak_temperature+0
	mov bcd+1, soak_temperature+1
	lcall bcd2hex
	mov soak_temperature+0, x+0
	mov soak_temperature+1, x+1
	
	mov bcd+0, soak_time+0
	mov bcd+1, soak_time+1
	lcall bcd2hex
	mov soak_time+0, x+0
	mov soak_time+1, x+1
	
	mov bcd+0, reflow_temperature+0
	mov bcd+1, reflow_temperature+1
	lcall bcd2hex
	mov reflow_temperature+0, x+0
	mov reflow_temperature+1, x+1
	
	mov bcd+0, reflow_time+0
	mov bcd+1, reflow_time+1
	lcall bcd2hex
	mov reflow_time+0, x+0
	mov reflow_time+1, x+1
ret

;turning off all of the 7-seg displays
turnoff_7seg:
	mov HEX0, #11111111B
	mov HEX1, #11111111B
	mov HEX2, #11111111B
	mov HEX3, #11111111B
	mov HEX4, #11111111B
ret
end
