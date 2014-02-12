;;;;;;;;;;;;;;
;;Timer
;;
;;Nina Dacanay, Derek Chan
;;
;;Keeps track of elapsed time for the system
;;
;;;;;;;;;;;;;;;

$MODDE2

XTAL           EQU 33333333
FREQ           EQU 100
TIMER1_RELOAD  EQU 65538-(XTAL/(12*20*FREQ))

org 0000H
	ljmp My_Program

org 00B3H
	ljmp ISR_Timer
		
DSEG at 30H
Timer_count10ms: 			ds 1
Timer_Total_Time_Seconds: 	ds 1	;incrementing every second
Timer_Total_Time_Minutes: 	ds 1	;incrementing every minute
Timer_Elapsed_Time:			ds 2	;incrementing every second
x				: ds 2
bcd				: ds 3
y				: ds 2

BSEG
mf				: dbit 1

CSEG

$include(math16.asm)
$include(Timer.asm)


My_Program:
	mov SP, #7FH
	mov LEDRA,#0
	mov LEDRB,#0
	mov LEDRC,#0
	mov LEDG,#0
	
	mov Timer_Total_Time_Seconds, #000H
	mov Timer_Total_Time_Minutes, #0H
	mov Timer_Elapsed_Time, #000H
	mov Timer_Elapsed_Time+1, #0H
	
	lcall Init_Timer
    setb EA  ; Enable all interrupts
    
Timer_Forever:
	lcall Timer_Display

	mov LEDG, Timer_Elapsed_Time
		
	jb SWA.1, Timer_Reset_TimeElapsed
	jb SWA.2, Timer_Reset_Everything
	sjmp Timer_Forever

Timer_Reset_TimeElapsed:
	lcall Timer_Reset_Elapsed_Time
	sjmp Timer_Forever
	
Timer_Reset_Everything:
	lcall Timer_Reset
	sjmp Timer_Forever
END
