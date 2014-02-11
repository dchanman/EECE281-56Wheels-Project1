$modde2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Test file for Door
;
;P1.1 is for one arm of the door, 5V is for the other
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org 0000h
	lcall init

DSEG at 30H
BSEG
	Door_Open	:	dbit 1

CSEG
$include(Door.asm)
    
init:
	lcall Door_init
	clr A
	mov LEDRA, A
	mov LEDRB, A
	mov LEDRC, A
	mov LEDG, A
forever:
	lcall Door_Check
	jb Door_Open, forever_open
	;door is closed	
	mov LEDG, #0
	sjmp forever
forever_open:
	;door is open
	mov LEDG, #1
	sjmp forever

	
END