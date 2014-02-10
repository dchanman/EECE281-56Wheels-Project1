$modde2

org 0000H
   ljmp main_init
      
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

;Math16/32 Variables
x						: ds 2
y						: ds 2
bcd						: ds 3
op						: ds 1

;State
state					: ds 1
elapsed_time			: ds 1

BSEG
;LCD_Init Variables
;;lcd_on			 		:  dbit 1
;;LCD_EN			 		:  dbit 1
;;LCD_MOD			 		:  dbit 1
;;LCD_RW          		:  dbit 1

;Thermocouple Registers (mf from math16/32)
mf 						:  dbit 1


CSEG

$include(math16.asm)
$include(SSR.asm)
$include(Serial_Port.asm)
;$include(Thermocouple_Input.asm)
$include(Thermo2.asm)
$include(User_Interface.asm)
$include(LCD_Display.asm)
;$include(Read_sw5.asm)

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
	;lcall UI_Heating
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
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;main_state_cooldown
;;
;;Function:
;;	*Waits for oven temperature to decrease to approx
;;		0.5*reflow_temperature
;;
;;State Change:
;;	STATE_OPEN_DOOR:
;;		*temperature_measured == 0.5*reflow_temperature
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main_state_cooldown:
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;main_state_open_door
;;
;;Function:
;;	*Makes three beep sounds
;;
;;State Change:
;;	STATE_STANDBY:
;;		*door opens (if feature available)
;;		*Or after the beeps are finished
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main_state_open_door:
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
