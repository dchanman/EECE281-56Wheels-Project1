;;;;;;;;;;;;;;
;;Timer
;;
;;Nina Dacanay, Derek Chan
;;
;;Keeps track of elapsed time for the system
;;
;;Constants:
;;	TIMER_XTAL           	EQU 33333333
;;	TIMER_FREQ           	EQU 100
;;	TIMER1_RELOAD  			EQU 65538-(TIMER_XTAL/(12*TIMER_FREQ))
;;
;;Variables:
;;	Timer_count10ms: 	ds 1
;;	Timer_Total_Time: 	ds 2	;incrementing every second
;;	Timer_Elapsed_Time:	ds 2	;incrementing every second
;;
;;Interrupt Service Routine:
;;	org 0AB8H
;;	ljmp ISR_Timer
;;
;;;;;;;;;;;;;;;
$NOLIST

ISR_Timer:
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
    
   	mov a, Timer_Elapsed_Time
    add a, #1
    mov Timer_Elapsed_Time, A
    mov A, Timer_Elapsed_Time+1
    addc a, #0
    mov Timer_Elapsed_Time+1, A

Timer_Seconds:    
    mov a, Timer_Total_Time_Seconds
    add a, #1
    cjne A, #60, ISR_Timer1_L0
    mov a, #0
    mov Timer_Total_Time_Seconds, a 

Timer_Minutes:   
    mov a, Timer_Total_Time_Minutes
    add a, #1
    cjne A, #60, ISR_Timer1_L0
    mov a, #0
    mov Timer_Total_Time_Minutes, a    

ISR_Timer1_L0:	
	; Restore used registers
	pop dpl
	pop dph
	pop acc
	pop psw    
	reti
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Init_Timer
;;
;;Initializes the timer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Init_Timer:	
	orl TMOD,  #00010000B ; GATE=0, C/T*=0, M1=0, M0=1: 16-bit timer
	clr TR1 ; Disable timer 1
	clr TF1
    mov TH1, #high(TIMER1_RELOAD)           ;PLEASE EXPLAIN WHAT THIS IS
    mov TL1, #low(TIMER1_RELOAD)            ;PLEASE EXPLAIN WHAT THIS IS
    setb TR1 ; Enable timer 1
    setb ET1 ; Enable timer 1 interrupt
    ret
    
;;
;;
;;
; Look-up table for 7-segment displays
Timer_LUT:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H
    DB 092H, 082H, 0F8H, 080H, 090H
    DB 0FFH ; All segments off
    
;;;
;Display Timer
;;;
Timer_Display:
	mov dptr, #Timer_LUT
	mov x+0, Timer_Elapsed_Time+0
	mov x+1, Timer_Elapsed_Time+1
	mov LEDG, x+0
	mov LEDRA, x+1
	lcall hex2bcd
	
	mov a, bcd+0
	anl a, #0fH
	movc a, @a+dptr
	mov HEX0, a
	
	mov a, bcd+0
	swap a
	anl a, #0fH
	movc a, @a+dptr
	mov HEX1, a
	
	mov a, bcd+1
	anl a, #0fH
	movc a, @a+dptr
	mov HEX2, a
	
	mov a, bcd+1
	swap a
	anl a, #0fH
	movc a, @a+dptr
	mov HEX3, a
	
;TOTAL TIME	
	mov x+0, Timer_Total_Time_Seconds
	mov x+1, Timer_Total_Time_Minutes
	lcall hex2bcd
	
	mov a, bcd+0
	anl a, #0fH
	movc a, @a+dptr
	mov HEX4, a
	
	mov a, bcd+0
	swap a
	anl a, #0fH
	movc a, @a+dptr
	mov HEX5, a

	mov a, bcd+1
	anl a, #0fH
	movc a, @a+dptr
	mov HEX6, a
	
	mov a, bcd+1
	swap a
	anl a, #0fH
	movc a, @a+dptr
	mov HEX7, a
	ret
$LIST