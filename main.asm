$modde2

org 0000H
   ljmp init
   
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

;Math16/32 Variables
x						: ds 2
y						: ds 2
bcd						: ds 3
op						: ds 1

BSEG

;Thermocouple Registers (mf from math16/32)
mf 						: db 1

CSEG

$include(Controller_Output.asm)
$include(Serial_Port.asm)
$include(Thermocouple_Input.asm)
$include(User_Interface.asm)
$include(math16.asm)
$include(math32.asm)

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
