$modde2

org 0000H
   ljmp main_init
   
org 000BH
	ljmp Buzzer_ISR
      
;Thermocouple Constants
FREQ	EQU 33333333
BAUD	EQU 115200
T2LOAD	EQU 65536-(FREQ/(32*BAUD))

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

;State Constants
STATE_STANDBY 	EQU 0
STATE_HEATING1	EQU 1
STATE_SOAK		EQU 2
STATE_HEATING2	EQU 3
STATE_REFLOW	EQU 4
STATE_COOLDOWN	EQU 5
STATE_OPEN_DOOR	EQU 6

DSEG at 30H

;User_Interface Variables
soak_temperature 		: ds 2
soak_time		 		: ds 2
reflow_temperature		: ds 2
reflow_time		 		: ds 2

;Thermocouple Variables
Temperature_Measured	: ds 2
Outside_Temperature_Measured:	ds 2

;Buzzer Variables
Buzzer_Beep_Count	:	ds 1
Buzzer_Beep_Num		:	ds 1

;Timer
elapsed_time			: ds 1

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

;Buzzer bit variables
Buzzer_Beep_Active		:	dbit 1		
Buzzer_Continuous_Tone	:	dbit 1


CSEG

$include(math16.asm)
$include(SSR.asm)
$include(Serial_Port.asm)
$include(Buzzer.asm)
$include(Thermo2.asm)
$include(User_Interface.asm)
$include(LCD_Display.asm)
;$include(Read_sw5.asm)

;;;;
;;main_Maintain_Temperature(var temp)
;;
;;Maintains the desired temperature given in var temp
;;;;
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
	lcall SSR_Enable	
	
	lcall Thermocouple_Update	
	mov x+0, Thermocouple_Update+0
	mov x+1, Thermocouple_Update+1
	mov y+0, soak_temperature+0
	mov y+1, soak_temperature+1
	
	lcall x_lt_y
	jb mf, main_state_heating1_done	
	mov state, #STATE_SOAK
	Buzzer_Beep_Multiple(4)
	;lcall resetElapsedTime
	
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
	main_Maintain_Temperature(soak_temperature)
	
	mov x+0, elapsed_time+0
	mov x+1, elapsed_time+1
	mov y+0, soak_time+0
	mov y+1, soak_time+1
	
	lcall x_lt_y
	jb mf, main_state_soak_done
	
	mov state, #STATE_HEATING2
	Buzzer_Beep_Multiple(4)
	;lcall resetElapsedTime

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
	lcall SSR_Enable	
	
	lcall Thermocouple_Update	
	mov x+0, Thermocouple_Update+0
	mov x+1, Thermocouple_Update+1
	mov y+0, reflow_temperature+0
	mov y+1, reflow_temperature+1
	
	lcall x_lt_y
	jb mf, main_state_heating2_done	
	mov state, #STATE_REFLOW
	Buzzer_Beep_Multiple(4)
	;lcall resetElapsedTime
	
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
	main_Maintain_Temperature(reflow_temperature)
	
	mov x+0, elapsed_time+0
	mov x+1, elapsed_time+1
	mov y+0, reflow_time+0
	mov y+1, reflow_time+1
	
	lcall x_lt_y
	jb mf, main_state_reflow_done
	
	mov state, #STATE_COOLDOWN
	Buzzer_Beep_Multiple(4)
	;lcall resetElapsedTime

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
	lcall Thermocouple_Update
	lcall SSR_Disable
	lcall Buzzer_Start_Beep
	
	;lcall Door_Check
	;jnb Door_Open, main_state_cooldown_done
	mov state, #STATE_OPEN_DOOR
	lcall Buzzer_Stop_Beep
	;lcall elapsed_time
	
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
	lcall Thermocouple_Update	
	mov x+0, Thermocouple_Update+0
	mov x+1, Thermocouple_Update+1
	mov y+0, low(40)
	mov y+1, high(40)
	
	lcall x_gt_y
	jb mf, main_state_open_door_done	
	mov state, #STATE_STANDBY
	Buzzer_Beep_Multiple(3)
	;lcall resetElapsedTime
	
main_state_open_door_done:	
	
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;init											
;;												
;;Starting point for the program. Initializes	
;;all of the components for the controller.		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main_init:
	clr A
	clr C
	mov LEDG, A
	mov LEDRA, A
	mov LEDRB, A
	mov LEDRC, A
	mov state, #STATE_STANDBY	;initialize state
	
	lcall SSR_init
	lcall Serial_Port_init
	lcall Thermocouple_Input_init
	lcall User_Interface_init
	lcall LCD_init
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;main:
;
;State-based outputs are generated according to
;the inputs received.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main:	
	
	mov A, state	
	lcall UI_Update
	cjne A, STATE_STANDBY, main_checkEmergencyStop
		lcall main_state_standby
		
	

;check emergency stop button
main_checkEmergencyStop:
	;lcall check_emergency_stop
		
main_heating1:
	cjne A, STATE_HEATING1, main_soak
		lcall main_state_standby	
		sjmp main
main_soak:
	cjne A, STATE_SOAK, main_heating2
		lcall main_state_soak
		sjmp main
main_heating2:
	cjne A, STATE_HEATING2, main_reflow
		lcall main_state_heating2
		sjmp main
main_reflow:
	cjne A, STATE_REFLOW, main_cooldown
		lcall main_state_reflow
		sjmp main
main_cooldown:
	cjne A, STATE_COOLDOWN, main_open_door
		lcall main_state_cooldown
		sjmp main
main_open_door:
	cjne A, STATE_OPEN_DOOR, main_error
		lcall main_state_open_door
		sjmp main

;if for some reason, our state is an incorrect value, 
;	reset the device for safety
main_error:
	ljmp main_init	
	END
