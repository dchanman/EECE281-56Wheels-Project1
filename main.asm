$modde2

org 0000H
   ljmp init

DSEG at 30H

;User_Interface Variables
soak_temperature :  ds 1
soak_time		 :  ds 2
reflow_temperature: ds 1
reflow_time		 :  ds 2


BSEG



CSEG

$include(Controller_Output.asm)
$include(Serial_Port.asm)
$include(Thermocouple_Input.asm)
$include(User_Interface.asm)

init:
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
main:
	sjmp main
