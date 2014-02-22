$NOLIST
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	SSR 
;; 
;;	Derek Chan
;;	
;;	Function: Controls the SSR Relay box
;;	Constants and Variables to be declared: n/a
;;	Subroutines:
;;				SSR_Enable 	- 	turns on the SSR
;;				SSR_Disable	-	turns off the SSR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CSEG

SSR_Init:
	orl P1MOD, #00000001B
	clr P1.0
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;SSR_Enable
;;
;;Enables the SSR, thus turning on the oven
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
SSR_Enable:
	setb P1.0
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;SSR_Disable
;;
;;Disables the SSR, thus turning off the oven
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SSR_Disable:
	clr	P1.0
	ret
	
$LIST
