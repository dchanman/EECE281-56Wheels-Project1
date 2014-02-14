$modde2

org 0000H
   ljmp main_init
   
org 000BH
	ljmp Buzzer_ISR
	
org 001BH
	ljmp ISR_Timer
      
;Thermocouple Constants
FREQ	EQU 33333333
BAUD	EQU 115200
T2LOAD	EQU 65536-(FREQ/(32*BAUD))
THERMO_TEMP_ADJ		EQU		5			;negative offset because LM335 reports too high
OVERSHOOT_COMPENSATE	EQU 25

;Serial Port Constants
MISO	EQU  P0.0 
MOSI	EQU  P0.1 
SCLK	EQU  P0.2
CE_ADC	EQU  P0.3
CE_EE	EQU  P0.4
CE_RTC	EQU  P0.5 

;Buzzer Constants
BUZZER_CLK EQU 33333333
BUZZER_FREQ EQU 2000
BUZZER_T0_RELOAD EQU 65536-(BUZZER_CLK/(12*2*BUZZER_FREQ))

;Timer Constants
Timer_XTAL           EQU 33333333
Timer_FREQ           EQU 100
TIMER1_RELOAD  EQU 65538-(Timer_XTAL/(12*Timer_FREQ))

;State Constants
STATE_STANDBY 	EQU 0
STATE_HEATING1	EQU 1
STATE_SOAK		EQU 2
STATE_HEATING2	EQU 3
STATE_REFLOW	EQU 4
STATE_COOLDOWN	EQU 5
STATE_OPEN_DOOR	EQU 6
STATE_FAILURE	EQU 7	
STATE_DONE		EQU 8

DSEG at 30H

;User_Interface Variables
soak_temperature 		: ds 2
soak_time		 		: ds 2
reflow_temperature		: ds 2
reflow_time		 		: ds 2
target_temperature		: ds 2


;Thermocouple Variables
Temperature_Measured	: ds 2
Outside_Temperature_Measured:	ds 2

;Buzzer Variables
Buzzer_Beep_Count	:	ds 1
Buzzer_Beep_Num		:	ds 1

;Timer
Timer_count10ms: 	ds 1
Timer_Total_Time_Seconds: 	ds 1	;incrementing every second
Timer_Total_Time_Minutes: 	ds 1	;incrementing every minute
Timer_Elapsed_Time:			ds 2	;incrementing every second

;Math16/32 Variables
x						: ds 2
y						: ds 2
bcd						: ds 3
op						: ds 1

;State
state					: ds 1

BSEG
;Math16
mf 						:  dbit 1

;Door
Door_Open				:	dbit 1

;Buzzer bit variables
Buzzer_Beep_Active		:	dbit 1		
Buzzer_Continuous_Tone	:	dbit 1

;Thermo2 Variables
Temperature_Measured_Sign	:	dbit 1

;UI Variables
UI_Input_Error			: dbit 1


CSEG

$include(math16.asm)
$include(SSR.asm)
$include(Serial_Port.asm)
$include(Buzzer.asm)
$include(Thermo2.asm)
$include(User_Interface.asm)
$include(LCD_Display.asm)
$include(Door.asm)
$include(Timer.asm)
$include(Read_sw5.asm)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;main_Maintain_Temperature(var temp)
;;
;;Maintains the desired temperature given in var temp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main_Maintain_Temperature MAC
	lcall Thermocouple_Update
	mov x+0, Temperature_Measured+0
	mov x+1, Temperature_Measured+1
	mov y+0, %0+0
	mov y+1, %0+1
	
	lcall x_lt_y
	lcall main_Maintain_Temperature_helper
	
ENDMAC

main_Maintain_Temperature_helper:
	jb mf, main_Maintain_Temperature_tooCold
	;too hot:
	lcall SSR_Disable
	ret
main_Maintain_Temperature_tooCold:
	lcall SSR_Enable
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;main_Alert_Open_Door
;;
;;Stalling code that stops all functions until the
;;door is closed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main_Alert_Open_Door:
	
	
	lcall Door_Check
	jnb Door_Open, main_Alert_Open_Door_done
	lcall Display_Close_Door
	setb Buzzer_Continuous_Tone
	clr ET1
	lcall Buzzer_Start_Beep
	
	mov A, #0FFH	
		mov LEDRA, A
	mov LEDRB, A
	mov LEDRC, A
	mov LEDG, A
	
main_Alert_Open_Door_loop:
	lcall Door_Check
	jb Door_Open, main_Alert_Open_Door_loop	
	setb ET1
	clr Buzzer_Continuous_Tone
	lcall Buzzer_Stop_Beep	
	
		mov A, #0
		mov LEDRA, A
	mov LEDRB, A
	mov LEDRC, A
	mov LEDG, A
main_Alert_Open_Door_done:	
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;main_state_standby
;;
;;Function:
;;	*Checks all inputs
;;	*Turns all outputs off
;;	*Displays message 	"Please specify parameters:				"
;;						"Soak: (temp/time) | Reflow (temp/time)	"
;;
;;State Change:
;;	STATE_HEATING1:
;;	*On button pressed 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main_state_standby:
	;mov LEDRA, #10000000B
	
	lcall UI_Set_Up_Parameters
	lcall test_proper_values
	jb UI_Input_Error, main_state_standby
	;;
	;;TODO: remove this override
	;;;
	;mov soak_temperature, #low(150)
	;mov soak_temperature+1, #high(150)
	;mov soak_time, #low(90)
	;mov soak_time+1, #high(90)
	;mov reflow_temperature, #low(217)
	;mov reflow_temperature+1, #high(217)
	;mov reflow_time, #low(55)
	;mov reflow_time+1, #high(55)
	
	mov state, #STATE_HEATING1
	lcall Timer_Reset
	mov target_temperature, soak_temperature
	mov target_temperature+1, soak_temperature+1
	
	
	
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;main_state_heating1
;;
;;Function:
;;	*Heats the oven to the soak temperature
;;
;;State Change:
;;	STATE_SOAK:
;;	*Temperature_Measured == soak_temperature
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main_state_heating1:	
	mov LEDRA, #00100000B
	lcall main_Alert_Open_Door
	lcall Timer_Display
	lcall waitHalfSec	;delay to make the LCD not glitch up
	
	lcall Thermocouple_Update
	lcall Serial_Port_Send_String
	lcall Display_Status  ;this is UI_Update

	mov x+0, Temperature_Measured+0
	mov x+1, Temperature_Measured+1
	mov y+0, soak_temperature+0
	mov y+1, soak_temperature+1
	
	lcall x_lt_y	
	jb mf, main_state_heating1_close	
	mov state, #STATE_SOAK
	Buzzer_Beep_Multiple(4)
	lcall Timer_Reset_Elapsed_Time
	
main_state_heating1_close:
	load_y(OVERSHOOT_COMPENSATE)
	lcall add16
	mov y+0, soak_temperature+0
	mov y+1, soak_temperature+1
	lcall x_lt_y	
	jb mf, main_state_heating1_else
	lcall SSR_Disable
	sjmp main_state_heating1_done
	
main_state_heating1_else:
	lcall SSR_Enable
	
main_state_heating1_done:	
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;main_state_soak
;;
;;Function:
;;	*Maintains oven temperature for the time specified
;;		in soak_time
;;
;;State Change:
;;	STATE_HEATING2:
;;		*elapsed_time == soak_time 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main_state_soak:
	mov LEDRA, #00110000B
	lcall main_Alert_Open_Door
	lcall Display_Status  ;this is UI_Update
	
	lcall Timer_Display
	lcall waitHalfSec	;delay to make the LCD not glitch up
	
	main_Maintain_Temperature(soak_temperature)
	lcall Serial_Port_Send_String
	
	mov x+0, Timer_elapsed_time+0
	mov x+1, Timer_elapsed_time+1
	mov y+0, soak_time+0
	mov y+1, soak_time+1
	
	lcall x_lt_y
	jb mf, main_state_soak_done
	
	mov state, #STATE_HEATING2
	mov target_temperature, reflow_temperature
	mov target_temperature+1, reflow_temperature+1
	Buzzer_Beep_Multiple(4)
	lcall Timer_Reset_Elapsed_Time
	mov target_temperature, reflow_temperature

main_state_soak_done:
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;main_state_heating2
;;
;;Function:
;;	*Heats the oven to the reflow temperature
;;
;;State Change:
;;	STATE_REFLOW:
;;		*Temperature_Measured == reflow_temperature
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main_state_heating2:
	mov LEDRA, #00111000B
	lcall main_Alert_Open_Door
	lcall Display_Status  ;this is UI_Update
	lcall Timer_Display
	lcall waitHalfSec	;delay to make the LCD not glitch up
	
	lcall Thermocouple_Update	
	lcall Serial_Port_Send_String
	mov x+0, Temperature_Measured+0
	mov x+1, Temperature_Measured+1
	mov y+0, reflow_temperature+0
	mov y+1, reflow_temperature+1
	
	lcall x_lt_y
	jb mf, main_state_heating2_close
	mov state, #STATE_REFLOW
	Buzzer_Beep_Multiple(4)
	lcall Timer_Reset_Elapsed_Time
	
main_state_heating2_close:
	load_y(5)
	lcall add16
	mov y+0, reflow_temperature+0
	mov y+1, reflow_temperature+1
	lcall x_lt_y	
	jb mf, main_state_heating2_else
	lcall SSR_Disable
	sjmp main_state_heating2_done
	
main_state_heating2_else:
	lcall SSR_Enable
	
main_state_heating2_done:	
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;main_state_reflow
;;
;;Function:
;;	*Maintains oven temperature at reflow_temperature
;;	for the time specified in reflow_time
;;
;;State Change:
;;	STATE_COOLDOWN:
;;		*elapsed_time == reflow_time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main_state_reflow:
	mov LEDRA, #00111100B
	lcall main_Alert_Open_Door
	lcall Display_Status  ;this is UI_Update
	lcall Timer_Display
	lcall waitHalfSec	;delay to make the LCD not glitch up
	main_Maintain_Temperature(reflow_temperature)
	lcall Serial_Port_Send_String
	
	mov x+0, Timer_elapsed_time+0
	mov x+1, Timer_elapsed_time+1
	mov y+0, reflow_time+0
	mov y+1, reflow_time+1
	
	lcall x_lt_y
	jb mf, main_state_reflow_done
	
	mov state, #STATE_OPEN_DOOR
	Buzzer_Beep_Multiple(4)
	lcall Timer_Reset_Elapsed_Time
	mov target_temperature, #low(40)
	mov target_temperature+1, #high(40)

main_state_reflow_done:
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;main_state_cooldown
;;
;;Function:
;;	*Beep until the door opens
;;
;;State Change:
;;	STATE_OPEN_DOOR:
;;		*Door_Open == true
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main_state_cooldown:
	mov LEDRA, #00111110B
	lcall Display_Status  ;this is UI_Update
	lcall Timer_Display
	lcall waitHalfSec	;delay to make the LCD not glitch up
	lcall Thermocouple_Update
	lcall Serial_Port_Send_String
	lcall SSR_Disable
	setb Buzzer_Continuous_Tone
	lcall Buzzer_Start_Beep
	
	lcall Door_Check
	jnb Door_Open, main_state_cooldown_done
	mov state, #STATE_OPEN_DOOR
	lcall Buzzer_Stop_Beep
	clr Buzzer_Continuous_Tone
	lcall Timer_Reset_Elapsed_Time
	
main_state_cooldown_done:	
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;main_state_open_door
;;
;;Function:
;;	*Waits until component is cool
;;
;;State Change:
;;	STATE_STANDBY:
;;		*Temperature_Measured < 40 degrees C
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main_state_open_door:
	;check if the door got re-closed
	lcall Door_Check
	jb Door_Open, main_state_open_door_next
	lcall Display_Open_Door
	setb Buzzer_Continuous_Tone
	clr ET1
	lcall Buzzer_Start_Beep
	
	mov A, #0FFH	
	mov LEDRA, A
	mov LEDRB, A
	mov LEDRC, A
	mov LEDG, A
	
main_state_Open_Door_loop:
	lcall Door_Check
	jnb Door_Open, main_state_Open_Door_loop	
	setb ET1
	clr Buzzer_Continuous_Tone
	lcall Buzzer_Stop_Beep	
	
	mov A, #0
	mov LEDRA, A
	mov LEDRB, A
	mov LEDRC, A
	mov LEDG, A
		
main_state_open_door_next:
	mov LEDRA, #00111111B
	lcall Display_Status  ;this is UI_Update
	lcall Timer_Display
	lcall waitHalfSec	;delay to make the LCD not glitch up
	lcall Thermocouple_Update	
	lcall Serial_Port_Send_String
	mov x+0, Temperature_Measured+0
	mov x+1, Temperature_Measured+1
	mov y+0, #low(40)
	mov y+1, #high(40)
	
	lcall x_gt_y
	jb mf, main_state_open_door_done	
	mov state, #STATE_DONE
	Buzzer_Beep_Multiple(3)
	lcall Timer_Reset	
	
main_state_open_door_done:	
	
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;;main_state_done
;;
;;Finished!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
main_state_done:
	mov LEDRA, #00111111B
	mov LEDG, #10000000B
	lcall Display_Finished
	
	mov x+0, Timer_elapsed_time+0
	mov x+1, Timer_elapsed_time+1
	mov y+0, #low(5)
	mov y+1, #high(5)
	
	lcall x_lt_y
	jb mf, main_state_done_done
	mov state, #STATE_STANDBY
	lcall Timer_Reset
	lcall Timer_Clear
	clr A
	mov LEDRA, A
	mov LEDG, A
	
main_state_done_done:
	ret
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;;main_state_failure
;;
;;Something went horribly wrong with the process
;;Wait for user to open door, then reset machine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main_state_failure:
	lcall Timer_Clear
	setb Buzzer_Continuous_Tone
	lcall Buzzer_Start_Beep
	;lcall LCD_Please_Close_Door
main_state_failure_loop:
	lcall Door_check
	jnb Door_Open, main_state_failure_loop
	;lcall LCD_Critical_Error
main_state_failure_forever:
	sjmp main_state_failure_forever
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;init											
;;												
;;Starting point for the program. Initializes	
;;all of the components for the controller.		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main_init:
	mov SP, #7FH
	mov A, #0FFH
	mov HEX0, A
	mov HEX1, A
	mov HEX2, A
	mov HEX3, A
	mov HEX4, A
	mov HEX5, A
	mov HEX6, A
	mov HEX7, A
	
	clr A
	clr C
	mov LEDG, A
	mov LEDRA, A
	mov LEDRB, A
	mov LEDRC, A
	mov state, #STATE_STANDBY	;initialize state
	
	mov soak_temperature, A
	mov soak_time, A
	mov reflow_temperature, A
	mov reflow_time, A
	mov target_temperature, A
	mov temperature_measured, A
	mov outside_temperature_measured, A
	mov soak_temperature+1, A
	mov soak_time+1, A
	mov reflow_temperature+1, A
	mov reflow_time+1, A
	mov target_temperature+1, A
	mov temperature_measured+1, A
	
	lcall SSR_init
	lcall Serial_Port_init
	lcall Thermocouple_Input_init
	lcall Init_Timer
	lcall Door_init
	lcall LCD_init
	lcall Buzzer_init
	
	setb EA
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;main:
;
;State-based outputs are generated according to
;the inputs received.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main:	
	
	mov A, state
		
	cjne A, #STATE_STANDBY, main_checkEmergencyStop
		lcall main_state_standby
		sjmp main
		
;check emergency stop button
main_checkEmergencyStop:
	mov A, SWC
	jnb ACC.1, main_heating1
	mov A, #0FFH
	mov LEDRA, A
	mov LEDRB, A
	mov LEDRC, A
	mov LEDG, A
	die:		
		mov A, SWC
		jb ACC.1, die
	mov state, #STATE_STANDBY
	ljmp main_init
	
	;lcall check_emergency_stop
		
main_heating1:
	mov A, state
	cjne A, #STATE_HEATING1, main_soak
		lcall main_state_heating1
		sjmp main
main_soak:
	cjne A, #STATE_SOAK, main_heating2
		lcall main_state_soak
		sjmp main
main_heating2:
	cjne A, #STATE_HEATING2, main_reflow
		lcall main_state_heating2
		sjmp main
main_reflow:
	cjne A, #STATE_REFLOW, main_cooldown
		lcall main_state_reflow
		sjmp main
main_cooldown:
	cjne A, #STATE_COOLDOWN, main_open_door
		lcall main_state_cooldown
		sjmp main
main_open_door:
	cjne A, #STATE_OPEN_DOOR, main_done
		lcall main_state_open_door
		sjmp main
main_done:
	cjne A, #STATE_DONE, main_failure
		lcall main_state_done
		sjmp main
		
main_failure:
	cjne A, #STATE_FAILURE, main_error
		ljmp main_failure

;if for some reason, our state is an incorrect value, 
;	reset the device for safety
main_error:
	ljmp main_init	
	END
