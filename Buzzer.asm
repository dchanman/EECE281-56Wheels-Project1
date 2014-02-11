$NOLIST
;----------------------------------------------------
;	Buzzer
; 
;	Derek Chan
;	
;	Function: Interface for the Buzzer component
;
;	Subroutines:
;		Buzzer_Init:	Initlizes P1MOD, TMOD, ***DOES NOT ENABLE INTERRUPTS***
;		Buzzer_ISR:		Makes the buzzer beep, *prioritized*
;		Buzzer_Start_Beep:	Starts the buzzer
;		Buzzer_Stop_Beep:	Stops the buzzer
;
;	Interrupt:
;		org 000BH
;			ljmp Buzzer_ISR
;	Registers:
;		P1.5 - Buzzer
;	Constants:
;		BUZZER_CLK EQU 33333333
;		BUZZER_FREQ EQU 2000
;		BUZZER_T0_RELOAD EQU 65536-(BUZZER_CLK/(12*2*BUZZER_FREQ))
;	Variables:
;		Buzzer_Beep_Count	:	ds 1
;
;		Buzzer_Beep_Active		:	dbit 1		
;		Buzzer_Continuous_Tone	:	dbit 1
;----------------------------------------------------
CSEG

Buzzer_Init:
	orl P1MOD, #00100000B	; P1.5 is an output
	orl TMOD, #00000001B 	; GATE=0, C/T*=0, M1=0, M0=1: 16-bit timer
	clr TR0 				; Disable timer 0
	clr TF0
	mov TH0, #high(BUZZER_T0_RELOAD)
	mov TL0, #low(BUZZER_T0_RELOAD)
	setb ET0				; Enable T0 interrupt
	setb PT0				; Set T0 priority
	
	setb Buzzer_Beep_Active
	clr Buzzer_Continuous_Tone
	mov Buzzer_Beep_Count, #0
	
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Buzzer_ISR
;;
;;Interrupt service routine for the buzzer. Causes
;;the buzzer to beep according to set parameters.
;;
;;@param	-	Buzzer_Continuous_Tone:	
;;					Buzzer goes BEEEEEEEEEEEP if set to 1,
;;					Buzzer goes beep-beep-beep... if set to 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Buzzer_ISR:
	push acc
	push psw
	jb Buzzer_Continuous_Tone, Buzzer_ISR_Make_Beep

	clr C
	mov A, Buzzer_Beep_Count
	add A, #1
	mov Buzzer_Beep_Count, A

	jnc Buzzer_ISR_Check_Beep
	cpl Buzzer_Beep_Active

Buzzer_ISR_Check_Beep:
	jnb Buzzer_Beep_Active, Buzzer_ISR_end	
	
Buzzer_ISR_Make_Beep:
	clr A
	cpl P1.5
	
Buzzer_ISR_end:
	mov TH0, #high(BUZZER_T0_RELOAD)
	mov TL0, #low(BUZZER_T0_RELOAD)
	pop psw
	pop acc
	reti
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Buzzer_Start_Beep
;;
;;Starts the buzzer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Buzzer_Start_Beep:
	setb TR0
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Buzzer_Stop_Beep
;;
;;Stops the buzzer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Buzzer_Stop_Beep:
	clr TR0
	ret
	
$LIST
