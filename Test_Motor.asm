$modde2

ORANGE EQU P1.3
YELLOW	EQU	P1.4
PINK	EQU	P1.6
BLUE	EQU	P1.7

TIMER_XTAL           	EQU 33333333
TIMER_FREQ           	EQU 100
TIMER1_RELOAD  			EQU 65538-(TIMER_XTAL/(12*TIMER_FREQ))

org 0000H
	ljmp init
	
DSEG at 30H
	Motor_Phase:	ds 1
	
CSEG
$include(Motor.asm)

Wait50ms:
;33.33MHz, 1 clk per cycle: 0.03us
	mov R0, #2
L3: mov R1, #74
L2: mov R2, #250
L1: djnz R2, L1 ;3*250*0.03us=22.5us
    djnz R1, L2 ;74*22.5us=1.665ms
    djnz R0, L3 ;1.665ms*30=50ms
    ret

init:
	clr A
	mov LEDRA, A
	mov LEDRB, A
	mov LEDRC, A
	mov LEDG, A
	mov Motor_Phase, A
	lcall Motor_Init
forever:
	lcall Motor_ISR
	mov LEDRA, Motor_Phase
	lcall Wait50ms
	
	sjmp forever
	