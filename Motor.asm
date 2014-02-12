$NOLIST

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Motor
;;
;;Driver for the motor
;;
;;Constants:
;;		ORANGE	EQU	P1.3
;;		YELLOW	EQU	P1.4
;;		PINK	EQU	P1.6
;;		BLUE	EQU	P1.7
;;Ports:
;;		P1.2 - Red wire
;;		P1.3 - Orange wire
;;		P1.4 - Yellow wire
;;		P1.6 - Pink wire
;;		P1.7 - Blue wire
;;Variables:
;;		Motor_Phase:	ds 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Motor_ISR:
	push ACC
	mov A, Motor_Phase
	cjne A, #0, Motor_ISR_phase1	
	
	mov LEDRB, A
	
	setb ORANGE
	clr YELLOW
	clr PINK
	clr BLUE
	
	add A, #1
	mov Motor_Phase, A
	pop ACC
	ret
Motor_ISR_phase1:
	cjne A, #1, Motor_ISR_phase2	
	
	mov LEDRB, A
	
	setb ORANGE
	setb YELLOW
	clr PINK
	clr BLUE
	
	add A, #1
	mov Motor_Phase, A
	pop ACC
	ret
Motor_ISR_phase2:
	cjne A, #2, Motor_ISR_phase3	

	mov LEDRB, A

	clr ORANGE
	setb YELLOW
	clr PINK
	clr BLUE
	
	add A, #1
	mov Motor_Phase, A
	pop ACC
	ret
Motor_ISR_phase3:
	cjne A, #3, Motor_ISR_phase4
	
	mov LEDRB, A	

	clr ORANGE
	setb YELLOW
	setb PINK
	clr BLUE

	inc A
	mov Motor_Phase, A
	pop ACC
	ret
Motor_ISR_phase4:
	cjne A, #4, Motor_ISR_phase5
	
	mov LEDRB, A	
	
	clr ORANGE
	clr YELLOW
	setb PINK
	clr BLUE
	
	inc A
	mov Motor_Phase, A
	pop ACC
	ret
Motor_ISR_phase5:
	cjne A, #5, Motor_ISR_phase6	
	
	mov LEDRB, A
	
	clr ORANGE
	clr YELLOW
	setb PINK
	setb BLUE
	
	inc A
	mov Motor_Phase, A
	pop ACC
	ret
Motor_ISR_phase6:
	cjne A, #6, Motor_ISR_phase7
	
	mov LEDRB, A	
	
	clr ORANGE
	clr YELLOW
	clr PINK
	setb BLUE
	
	inc A
	mov Motor_Phase, A
	pop ACC
	ret
Motor_ISR_phase7:

	mov LEDRB, A

	setb ORANGE
	clr YELLOW
	clr PINK
	setb BLUE

	mov Motor_Phase, #0
	pop ACC
	ret
		
Motor_Init:
	orl P1MOD, #11011100B
	setb P1.2
	ret

Motor_WaitHalfSec:
	mov R2, #90
N3: mov R1, #250
N2: mov R0, #250
N1: djnz R0, N1 ; 3 machine cycles-> 3*30ns*250=22.5us
	djnz R1, N2 ; 22.5us*250=5.625ms
	djnz R2, N3 ; 5.625ms*90=0.5s (approximately)
	ret


$LIST