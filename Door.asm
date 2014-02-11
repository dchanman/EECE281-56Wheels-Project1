$NOLIST
;----------------------------------------------------
;	Door
; 
;	Derek Chan
;	
;	Function: Controls the SSR Relay box
;	Pins:		P1.1 - Door input
;	Constants and Variables to be declared: Door_Open:	1 if door is open, 0 if door is closed
;	Functions:	
;				SSR_Enable 	- 	turns on the SSR
;				SSR_Disable	-	turns off the SSR
;----------------------------------------------------
CSEG

Door_Init:
	anl P1MOD, #11111101B	;set P1MOD as input
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Door_Check
;;
;;Updates Door_Open bit to indicate if the door 
;;is open (1) or closed (0)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Door_Check:
	jb P1.1, Door_Check_closed
	;door is open
	setb Door_Open
	ret
Door_Check_closed:
	clr Door_Open
	ret
	
$LIST
