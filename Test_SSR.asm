$modde2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Test file for SSR
;
;Use SW0 to check enable and disable the SSR
;P1.0 is the output of the SSR Enable/Disable
;You'll use this output to activate/deactivate a BJT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org 0000h
	lcall init

CSEG
$include(SSR.asm)
    
init:
	lcall SSR_init
	clr A
	mov LEDRA, A
	mov LEDRB, A
	mov LEDRC, A
	mov LEDG, A
forever:
	mov A, SWA
	jb ACC.0, on
	;turn ssr off
	lcall SSR_disable
	mov LEDRA, #0
	sjmp forever

on:	
	;turn ssr on
	lcall SSR_enable
	mov LEDRA, #1
	sjmp forever
	
END