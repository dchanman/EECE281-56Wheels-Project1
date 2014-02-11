$NOLIST
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

Display_Confirmation_message:
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
	lcall WaitHalfSec
	lcall WaitHalfSec


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
	
	
	mov bcd+0, soak_temperature+0
	mov bcd+1, soak_temperature+1
	mov bcd+2, soak_temperature+2
	
	mov a, bcd+1
	anl a, #0fH
	orl a, #30H
	lcall LCD_put
	
	mov a, bcd+0
	swap a
	anl a, #0fH
	orl a, #30H
	lcall LCD_put

	mov a, bcd+0
	anl a, #0fH
	orl a, #30h
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

	
	mov bcd+0, soak_time+0
	mov bcd+1, soak_time+1
	mov bcd+2, soak_time+2
	
	mov a, bcd+1
	anl a, #0fH
	orl a, #30H
	lcall LCD_put
	
	mov a, bcd+0
	swap a
	anl a, #0fH
	orl a, #30H
	lcall LCD_put

	mov a, bcd+0
	anl a, #0fH
	orl a, #30h
	lcall LCD_put
	

	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	

	lcall Wait_for_Confirmation

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
	
	mov bcd+0, reflow_temperature+0
	mov bcd+1, reflow_temperature+1
	mov bcd+2, reflow_temperature+2
	
	mov a, bcd+1
	anl a, #0fH
	orl a, #30H
	lcall LCD_put
	
	mov a, bcd+0
	swap a
	anl a, #0fH
	orl a, #30H
	lcall LCD_put

	mov a, bcd+0
	anl a, #0fH
	orl a, #30h
	lcall LCD_put

	mov a, #' '
	lcall LCD_put
	
	;display the second row
	mov a, #0c0H
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
	mov a, #'i'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	
	mov bcd+0, reflow_time+0
	mov bcd+1, reflow_time+1
	mov bcd+2, reflow_time+2
	
	mov a, bcd+1
	anl a, #0fH
	orl a, #30H
	lcall LCD_put
	
	mov a, bcd+0
	swap a
	anl a, #0fH
	orl a, #30H
	lcall LCD_put

	mov a, bcd+0
	anl a, #0fH
	orl a, #30h
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	lcall waitHalfSec

	lcall Wait_for_Confirmation
ret

Display_preset_or_manual:
	mov a, #80h
	lcall LCD_command
	mov a, #'C'
	lcall LCD_put
	mov a, #'h'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'P'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	
	mov a, #0c0H
	lcall LCD_command
	mov a, #'I'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	mov a, #'u'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'B'
	lcall LCD_put
	mov a, #'y'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'H'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'d'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
ret
	
Display_Status:
	mov a, #80H
	lcall LCD_command
	 mov a, #'T'
	 lcall LCD_put
	 mov a, #':'
	 lcall LCD_put
	 mov a, #' ';tempsignificant digit
	 lcall LCD_put
	 mov a, #' ';tempmiddigit
	 lcall LCD_put
	 mov a, #' ';smalldigit
	 lcall LCD_put
	 mov a, #'C'
	 lcall LCD_put
	 mov a, #' '
	 lcall LCD_put
	 mov a, #'T'
	 lcall LCD_put
	 mov a, #'i'
	 lcall LCD_put
	 mov a, #':'
	 lcall LCD_put
	 ;code for writing time, need to decide on seconds or :

	;display the second row
	mov a, #0c0H
	lcall LCD_command

	mov a, #'S'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put

	
	;need to have logic to test which state we're in
	mov a, state
	cjne a, STATE_STANDBY, G1
	mov a, #'S'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'d'
	lcall LCD_put
	mov a, #'b'
	lcall LCD_put
	mov a, #'y'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	 mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
G1: mov a, state
	cjne a, STATE_HEATING1, G2
	mov a, #'H'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'g'
	lcall LCD_put
	mov a, #'1'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
G2: mov a, state
	cjne a, STATE_SOAK, G3
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
G3: mov a, state
	cjne a, STATE_HEATING2, G4
	mov a, #'H'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'g'
	lcall LCD_put
	mov a, #'2'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
G4: mov a, state
	cjne a, STATE_REFLOW, G5
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
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
G5: mov a, state
	cjne a, STATE_COOLING, G6
	mov a, #'C'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #'g'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
G6: mov a, state
	cjne a, STATE_OPEN_DOOR, G7
	mov a, #'O'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'D'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
G7:
	ret

Display_Options:
	mov a, #80H
	lcall LCD_command
	mov a, #1H
	orl a, #30H
	lcall LCD_put
	mov a, #')'
	lcall LCD_put
	mov a, #'S'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #01H
	orl a, #30H
	lcall LCD_put
	mov a, #03H
	orl a, #30H
	lcall LCD_put
	mov a, #00H
	orl a, #30H
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'S'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #0H
	orl a, #30H
	lcall LCD_put
	mov a, #6H
	orl a, #30H
	lcall LCD_put
	mov a, #0H
	orl a, #30H
	lcall LCD_put
	
	mov a, #0c0H
	lcall LCD_command
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'R'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #02H
	orl a, #30H
	lcall LCD_put
	mov a, #01H
	orl a, #30H
	lcall LCD_put
	mov a, #00H
	orl a, #30H
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'R'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #0H
	orl a, #30H
	lcall LCD_put
	mov a, #3H
	orl a, #30H
	lcall LCD_put
	mov a, #0H
	orl a, #30H
	lcall LCD_put

	lcall waithalfsec
	lcall waithalfsec
	lcall waithalfsec
	lcall waithalfsec
	lcall waithalfsec
	lcall waithalfsec
	lcall waithalfsec
	lcall waithalfsec

	mov a, #80H
	lcall LCD_command
	mov a, #2H
	orl a, #30H
	lcall LCD_put
	mov a, #')'
	lcall LCD_put
	mov a, #'S'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #01H
	orl a, #30H
	lcall LCD_put
	mov a, #05H
	orl a, #30H
	lcall LCD_put
	mov a, #00H
	orl a, #30H
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'S'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #0H
	orl a, #30H
	lcall LCD_put
	mov a, #9H
	orl a, #30H
	lcall LCD_put
	mov a, #0H
	orl a, #30H
	lcall LCD_put
	
	mov a, #0c0H
	lcall LCD_command
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'R'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #02H
	orl a, #30H
	lcall LCD_put
	mov a, #02H
	orl a, #30H
	lcall LCD_put
	mov a, #00H
	orl a, #30H
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'R'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #0H
	orl a, #30H
	lcall LCD_put
	mov a, #4H
	orl a, #30H
	lcall LCD_put
	mov a, #0H
	orl a, #30H
	lcall LCD_put

	lcall waithalfsec
	lcall waithalfsec
	lcall waithalfsec
	lcall waithalfsec
	lcall waithalfsec
	lcall waithalfsec
	lcall waithalfsec
	lcall waithalfsec

	mov a, #80H
	lcall LCD_command
	mov a, #3H
	orl a, #30H
	lcall LCD_put
	mov a, #')'
	lcall LCD_put
	mov a, #'S'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #01H
	orl a, #30H
	lcall LCD_put
	mov a, #07H
	orl a, #30H
	lcall LCD_put
	mov a, #00H
	orl a, #30H
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'S'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #1H
	orl a, #30H
	lcall LCD_put
	mov a, #2H
	orl a, #30H
	lcall LCD_put
	mov a, #0H
	orl a, #30H
	lcall LCD_put
	
	mov a, #0c0H
	lcall LCD_command
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'R'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #02H
	orl a, #30H
	lcall LCD_put
	mov a, #03H
	orl a, #30H
	lcall LCD_put
	mov a, #00H
	orl a, #30H
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'R'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #0H
	orl a, #30H
	lcall LCD_put
	mov a, #4H
	orl a, #30H
	lcall LCD_put
	mov a, #5H
	orl a, #30H
	lcall LCD_put

	lcall waithalfsec
	lcall waithalfsec
	lcall waithalfsec
	lcall waithalfsec
	lcall waithalfsec
	lcall waithalfsec
	lcall waithalfsec
	lcall waithalfsec
	
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
	mov a, #'c'
	lcall LCD_put
	mov a, #'h'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'s'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	mov a, #0c0H
	lcall LCD_command
	mov a, #'O'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	mov a, #'t'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'n'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #01H
	orl a, #30H
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #02H
	orl a, #30H
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'r'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #03H
	orl a, #30H
	lcall LCD_put
	mov a, #' '
	lcall LCD_put

end

