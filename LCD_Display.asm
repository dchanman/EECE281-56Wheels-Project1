;Function:  1)To initialize the LCD Display
;			2)To be able to write text to the LCD
;
;			note: functions taken from spi.logger.asm
;
;			Functions added:
;			1)
;


Wait40us:
	mov R0, #149
Wait40us_L0: 
	nop
	nop
	nop
	nop
	nop
	nop
	djnz R0, Wait40us_L0 ; 9 machine cycles-> 9*30ns*149=40us
    ret

LCD_command:
	mov	LCD_DATA, A
	clr	LCD_RS
	nop
	nop
	setb LCD_EN ; Enable pulse should be at least 230 ns
	nop
	nop
	nop
	nop
	nop
	nop
	clr	LCD_EN
	ljmp Wait40us

LCD_put:
	mov	LCD_DATA, A
	setb LCD_RS
	nop
	nop
	setb LCD_EN ; Enable pulse should be at least 230 ns
	nop
	nop
	nop
	nop
	nop
	nop
	clr	LCD_EN
	ljmp Wait40us

LCD_Init:
    ; Turn LCD on, and wait a bit.
    setb LCD_ON
    clr LCD_EN  ; Default state of enable must be zero
    lcall Wait40us
    
    mov LCD_MOD, #0xff ; Use LCD_DATA as output port
    clr LCD_RW ;  Only writing to the LCD in this code.
	
	mov a, #0ch ; Display on command
	lcall LCD_command
	mov a, #38H ; 8-bits interface, 2 lines, 5x7 characters
	lcall LCD_command
	mov a, #01H ; Clear screen (Warning, very slow command!)
	lcall LCD_command
    
    ; Delay loop needed for 'clear screen' command above (1.6ms at least!)
    mov R1, #40
Clr_loop:
	lcall Wait40us
	djnz R1, Clr_loop
	ret
Display_welcome_message:
; Display the first row	
	mov a, #80H
	lcall LCD_command
		
	mov a, #'R'
	lcall LCD_put
    mov a, #'e'
	lcall LCD_put
	mov a, #'f'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'O'
	lcall LCD_put
	mov a, #'v'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	;display the second row
	mov a, #0c0H
	lcall LCD_command
	
	lcall LCD_put
	mov a, #'C'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'I'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'O'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	ret
Display_soak_temp_set:
; Display the first row	
	mov a, #80H
	lcall LCD_command
		
	mov a, #'P'
	lcall LCD_put
    mov a, #'l'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'E'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	;display the second row
	mov a, #0c0H
	lcall LCD_command
	
	lcall LCD_put
	mov a, #'S'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'k'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	ret

Display_soak_time_set:
	; Display the first row	
	mov a, #80H
	lcall LCD_command
		
	mov a, #'P'
	lcall LCD_put
    mov a, #'l'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'E'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	;display the second row
	mov a, #0c0H
	lcall LCD_command
	
	lcall LCD_put
	mov a, #'S'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'k'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	ret

Display_reflow_temp_set:
; Display the first row	
	mov a, #80H
	lcall LCD_command
		
	mov a, #'P'
	lcall LCD_put
    mov a, #'l'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'E'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	;display the second row
	mov a, #0c0H
	lcall LCD_command
	
	lcall LCD_put
	mov a, #'R'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'f'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'P'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	ret

Display_reflow_time_set:
	; Display the first row	
	mov a, #80H
	lcall LCD_command
		
	mov a, #'P'
	lcall LCD_put
    mov a, #'l'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'E'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	;display the second row
	mov a, #0c0H
	lcall LCD_command
	
	lcall LCD_put
	mov a, #'R'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'f'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	ret

Confirmation_message:
	; Display the first row	
	mov a, #80H
	lcall LCD_command
		
	mov a, #'C'
	lcall LCD_put
    mov a, #'o'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'f'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'g'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	;display the second row
	mov a, #0c0H
	lcall LCD_command
	
	lcall LCD_put
	mov a, #'V'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'u'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #'.'
	lcall LCD_put
	mov a, #'.'
	lcall LCD_put
	mov a, #'.'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	

	lcall waitHalfSec
	lcall waitHalfSec

	; Display the first row	
	mov a, #80H
	lcall LCD_command
		
	mov a, #'S'
	lcall LCD_put
    mov a, #'o'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'k'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	;highest value
	mov a, #''
	lcall LCD_put
	;higher value
	mov a, #' '
	lcall LCD_put
	;lower value
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	;display the second row
	mov a, #0c0H
	lcall LCD_command
	
	lcall LCD_put
	mov a, #'S'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'k'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	;highest value
	mov a, #' '
	lcall LCD_put
	;higher value
	mov a, #' '
	lcall LCD_put
	;lower value
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	lcall waitHalfSec
	lcall waitHalfSec
	lcall waitHalfSec
	lcall waitHalfSec

	; Display the first row	
	mov a, #80H
	lcall LCD_command
		
	mov a, #'R'
	lcall LCD_put
    mov a, #'e'
	lcall LCD_put
	mov a, #'f'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	;highest value
	mov a, #' '
	lcall LCD_put
	;higher value
	mov a, #' '
	lcall LCD_put
	;lower value
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	;display the second row
	mov a, #0c0H
	lcall LCD_command
	
	lcall LCD_put
	mov a, #'R'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'f'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	;highest value
	mov a, #' '
	;higher value
	lcall LCD_put
	;lower value
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put

	lcall waitHalfSec
	lcall waitHalfSec
	lcall WaitHalfSec
	lcall WaitHalfSec
ret


