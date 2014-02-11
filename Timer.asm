; clk_v3.asm: Displays seconds, minuts, and hours in HEX2 to HEX7
; We can set the time by flipping SW0 and using KEY.3, KEY.2, KEY.1
; to increment the Hours, Minutes, and Seconds.

$MODDE2

org 0000H
	ljmp My_Program

org 0AB8H
	ljmp ISR_Timer1
		
DSEG at 30H
Timer_count10ms: 	ds 1
Timer_Total_Time: 	ds 2	;incrementing every second
Timer_Elapsed_Time:	ds 2	;incrementing every second

CSEG


WaitHalfSec:
	mov R4, #90
H3: mov R5, #250
H2: mov R6, #250
H1: djnz R4, H1 ; 3 machine cycles-> 3*30ns*250=22.5us
	djnz R5, H2 ; 22.5us*250=5.625ms
	djnz R6, H3 ; 5.625ms*90=0.5s (approximately)
	ret
	
; Look-up table for 7-segment displays
myLUT:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H
    DB 092H, 082H, 0F8H, 080H, 090H
    DB 0FFH ; All segments off

XTAL           EQU 33333333
FREQ           EQU 100
TIMER1_RELOAD  EQU 65538-(XTAL/(12*FREQ))

ISR_Timer1:
	; Reload the timer
    mov TH1, #high(TIMER1_RELOAD)
    mov TL1, #low(TIMER1_RELOAD)
    
    ; Save used register into the stack
    push psw
    push acc
    push dph
    push dpl
        
    ; Increment the counter and check if a second has passed
    inc Timer_count10ms
    mov a, Timer_count10ms
    cjne A, #100, ISR_Timer1_L0
    mov Timer_count10ms, #0
    
;To check if Elapsed_Time are increasing:
Elapsed_Time:
    cpl LEDRA.2
    mov a, Timer_Elapsed_Time
    add a, #1
    da a
    mov Timer_Elapsed_Time, a
    cjne A, #255, Total_Time
    mov Timer_Elapsed_Time, #0
    
;To check if Total_Time are increasing:    
Total_Time:
	cpl LEDRA.3
    mov a, Timer_Total_Time
    add a, #1
    da a
    mov Timer_Total_Time, a
    cjne A, #255, ISR_Timer1_L0
    mov Timer_Total_Time, #0
    
; Update the display.  This happens every 10 ms	
ISR_Timer1_L0:
;ELAPSED_TIME	
	mov dptr, #myLUT
	
	mov a, Timer_Elapsed_Time+0
	anl a, #0fH
	movc a, @a+dptr
	mov HEX0, a
	
	mov a, Timer_Elapsed_Time+0
	swap a
	anl a, #0fH
	movc a, @a+dptr
	mov HEX1, a
	
	mov a, Timer_Elapsed_Time+1
	anl a, #0fH
	movc a, @a+dptr
	mov HEX2, a
	
	mov a, Timer_Elapsed_Time+1
	swap a
	anl a, #0fH
	movc a, @a+dptr
	mov HEX3, a
	
;TOTAL TIME	
	mov a, Timer_Total_Time+0
	anl a, #0fH
	movc a, @a+dptr
	mov HEX4, a
	
	mov a, Timer_Total_Time+0
	swap a
	anl a, #0fH
	movc a, @a+dptr
	mov HEX5, a

	mov a, Timer_Total_Time+1
	anl a, #0fH
	movc a, @a+dptr
	mov HEX6, a
	
	mov a, Timer_Total_Time+1
	swap a
	anl a, #0fH
	movc a, @a+dptr
	mov HEX7, a
	
	; Restore used registers
	pop dpl
	pop dph
	pop acc
	pop psw    
	reti

Init_Timer1:	
	orl TMOD,  #00010000B ; GATE=0, C/T*=0, M1=0, M0=1: 16-bit timer
	clr TR1 ; Disable timer 1
	clr TF1
    mov TH1, #high(TIMER1_RELOAD)           ;PLEASE EXPLAIN WHAT THIS IS
    mov TL1, #low(TIMER1_RELOAD)            ;PLEASE EXPLAIN WHAT THIS IS
    setb TR1 ; Enable timer 1
    setb ET1 ; Enable timer 1 interrupt
    ret

My_Program:
	mov SP, #7FH
	mov LEDRA,#0
	mov LEDRB,#0
	mov LEDRC,#0
	mov LEDG,#0
	mov HEX2, #0FFH
	mov HEX3, #0FFH
	mov Timer_Total_Time, #063H
	mov Timer_Elapsed_Time, #063H
	
	lcall Init_Timer1
    setb EA  ; Enable all interrupts

Timer_Forever:
	mov LEDG, Timer_Elapsed_Time
	
Timer_Forever_Subroutine:	
	jb SWA.1, Timer_Reset_TimeElapsed
	
	sjmp Timer_Forever

Timer_Reset_TimeElapsed:
	mov Timer_Elapsed_Time, #00H
	ljmp Timer_Forever_Subroutine
	
END
