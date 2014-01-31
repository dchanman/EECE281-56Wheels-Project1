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

DSEG at 30H

;User_Interface Variables
soak_temperature 		: ds 1
soak_time		 		: ds 2
reflow_temperature		: ds 1
reflow_time		 		: ds 2

<<<<<<< HEAD
;LCD_Init Variables
LCD_ON			 :  dbit 1
LCD_EN			 :  dbit 1
LCD_MOD			 :  dbit 1
LCD_RW           :  dbit 1

=======
;Math16/32 Variables
x						: ds 2
y						: ds 2
bcd						: ds 3
op						: ds 1
>>>>>>> c8b18c869d7b674820e16d78508aeeb66a90365e

BSEG

;Thermocouple Registers (mf from math16/32)
mf 						: db 1

CSEG

$include(Controller_Output.asm)
$include(Serial_Port.asm)
$include(Thermocouple_Input.asm)
$include(User_Interface.asm)
<<<<<<< HEAD
$include(LCD_Display.asm)
=======
$include(math16.asm)
>>>>>>> c8b18c869d7b674820e16d78508aeeb66a90365e

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;init <STATE>									;;
;;												;;
;;Starting point for the program. Initializes	;;
;;all of the components for the controller.		;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main_init:
	clr A
	clr C
	mov LEDG, A
	mov LEDRA, A
	mov LEDRB, A
	mov LEDRC, A
	
	lcall Controller_Output_init
	lcall Serial_Port_init
	lcall Thermocouple_Input_init
	lcall User_Interface_init
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;main_standby <STATE>									;;
;;														;;
;;Standby state for the controller. Checks for inputs,	;;
;;allows the changing of parameters, and waits for the	;;
;;ON switch to be toggled.								;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main_standby:
	;check all inputs and update parameters as needed
	mov A, SWB
	jnb ACC.5, main_standby_next0	;Set Reflow Time 
		lcall Reflow_Time_Input
		sjmp main_standby
main_standby_next0:
	jnb ACC.6, main_standby_next1	;Set Reflow Temp
		lcall Reflow_Temperature_Input
		sjmp main_standby
main_standby_next1:
	jnb ACC.7, main_standby_next2	;Set Soak Time
		lcall Soak_Time_Input
		sjmp main_standby
main_standby_next2:
	mov A, SWC
	JB ACC.0,	main_standby_next3	;Set Soak Temp
		lcall Soak_Temperature_Input
		sjmp main_standby
main_standby_next3:
	JB ACC.1,	main_standby_next4	;Start Heating Process	
		sjmp main_heatingProcess
main_standby_next4:
	sjmp main_standby

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;main_heatingProcess <STATE>			;;
;;										;;
;;Heating state for the controller. 	;;
;;Goes through the procedure of baking	;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main_heatingProcess:
	sjmp main_standby
	END
