;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Test_Buzzer
;;
;;Test program for the buzzer module.
;;
;;SW0 - Turns buzzer on/off
;;SW1 - Sets buzzer to beep or long-tone
;;
;;P1.5 is used for the buzzer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
$modde2

BUZZER_CLK EQU 33333333
BUZZER_FREQ EQU 2000
BUZZER_T0_RELOAD EQU 65536-(BUZZER_CLK/(12*2*BUZZER_FREQ))

org 0000H
	ljmp init
	
org 000BH
	ljmp Buzzer_ISR
	
DSEG at 30H
Buzzer_Beep_Count	:	ds 1

BSEG
Buzzer_Beep_Active		:	dbit 1
Buzzer_Continuous_Tone	:	dbit 1

CSEG
$include(Buzzer.asm)

init:
	clr A
	mov LEDRA, A
	mov LEDRB, A
	mov LEDRC, A
	mov LEDG, A
	lcall Buzzer_Init
	setb EA
	
forever:
	mov A, SWA
	
	jnb ACC.0, forever_stopbeep
		mov LEDG, #10000000B
		lcall Buzzer_Start_Beep
		sjmp forever_checksw1
		
forever_stopbeep:
		mov LEDG, #00000000B
		lcall Buzzer_Stop_Beep

forever_checksw1:
	jnb ACC.1, forever_longtone
		mov LEDRA, #00000001B
		setb Buzzer_Continuous_Tone
		sjmp forever
		
forever_longtone:
		mov LEDRA, #00000000B
		clr Buzzer_Continuous_Tone
		sjmp forever
		
END