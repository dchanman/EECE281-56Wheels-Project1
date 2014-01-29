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
;
;	Outputs: 	1)HEX Display (writes the correct value to x+0 and x+1, and calls 	;				hex2bcd and calls display)
;				2) LCD Display depending on status (Derek's portion) displays the
;				current state that it is in (Set Up/Heating/Cooldown etc) and
;				also displays what you want to enter in the initialization portion
;
;	Memory: 	1) Soak Temp - R7
;				2) 
;

;----------------------------------------------------
CSEG

User_Interface_Init:
	

	ret
	
$LIST
