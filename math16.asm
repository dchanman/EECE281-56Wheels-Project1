$NOLIST
;----------------------------------------------------
; math16.asm: Addition, subtraction, multiplication,
; and division of 16-bit integers. Also included are
; binary to bcd and bcd to binary conversion subroutines.
;
; 2011-2013 by Jesus Calvino-Fraga
;
;----------------------------------------------------

CSEG

;----------------------------------------------------
; Converts the 16-bit hex number in 'x' to a 
; 5-digit packed BCD in 'bcd' using the
; double-dabble algorithm.
;---------------------------------------------------
hex2bcd:
	push acc
	push psw
	push AR0
	
	clr a
	mov bcd+0, a ; Initialize BCD to 00-00-00 
	mov bcd+1, a
	mov bcd+2, a
	mov r0, #16  ; Loop counter.

hex2bcd_L0:
	; Shift binary left	
	mov a, x+1
	mov c, acc.7 ; This way x remains unchanged!
	mov a, x+0
	rlc a
	mov x+0, a
	mov a, x+1
	rlc a
	mov x+1, a
    
	; Perform bcd + bcd + carry using BCD arithmetic
	mov a, bcd+0
	addc a, bcd+0
	da a
	mov bcd+0, a
	mov a, bcd+1
	addc a, bcd+1
	da a
	mov bcd+1, a
	mov a, bcd+2
	addc a, bcd+2
	da a
	mov bcd+2, a

	djnz r0, hex2bcd_L0

	pop AR0
	pop psw
	pop acc
	ret

;------------------------------------------------
; bcd2hex:
; Converts the 5-digit packed BCD in 'bcd' to a 
; 16-bit hex number in 'x'
;------------------------------------------------

rrc_and_correct:
    rrc a
    push psw  ; Save carry (it is changed by the add instruction)
    jnb acc.7, nocor1
    add a, #(100H-30H) ; subtract 3 from packed BCD MSD
nocor1:
    jnb acc.3, nocor2
    add a, #(100H-03H) ; subtract 3 from packed BCD LSD
nocor2:
    pop psw   ; Restore carry
    ret

bcd2hex:
	push acc
	push psw
	push AR0
	push bcd+0
	push bcd+1
	push bcd+2
	mov R0, #16 ;Loop counter.
	
bcd2hex_L0:
    ; Divide BCD by two
    clr c
    mov a, bcd+2
    lcall rrc_and_correct
    mov bcd+2, a
    mov a, bcd+1
    lcall rrc_and_correct
    mov bcd+1, a
    mov a, bcd+0
    lcall rrc_and_correct
    mov bcd+0, a
    ;Shift R0-R1 right through carry
    mov a, x+1
    rrc a
    mov x+1, a
    mov a, x+0
    rrc a
    mov x+0, a
    djnz R0, bcd2hex_L0
    
    pop bcd+2
    pop bcd+1
    pop bcd+0
	pop AR0
	pop psw
	pop acc
	ret

;------------------------------------------------
; x = x + y
;------------------------------------------------
add16:
	push acc
	push psw
	mov a, x+0
	add a, y+0
	mov x+0, a
	mov a, x+1
	addc a, y+1
	mov x+1, a
	pop psw
	pop acc
	ret

;------------------------------------------------
; x = x - y
;------------------------------------------------
sub16:
	push acc
	push psw
	clr c
	mov a, x+0
	subb a, y+0
	mov x+0, a
	mov a, x+1
	subb a, y+1
	mov x+1, a
	pop psw
	pop acc
	ret

;------------------------------------------------
; mf=1 if x < y
;------------------------------------------------
x_lt_y:
	push acc
	push psw
	clr c
	mov a, x+0
	subb a, y+0
	mov a, x+1
	subb a, y+1
	mov mf, c
	pop psw
	pop acc
	ret

;------------------------------------------------
; mf=1 if x > y
;------------------------------------------------
x_gt_y:
	push acc
	push psw
	clr c
	mov a, y+0
	subb a, x+0
	mov a, y+1
	subb a, x+1
	mov mf, c
	pop psw
	pop acc
	ret

;------------------------------------------------
; mf=1 if x = y
;------------------------------------------------
x_eq_y:
	push acc
	push psw
	clr mf
	clr c
	mov a, y+0
	subb a, x+0
	jnz x_eq_y_done
	mov a, y+1
	subb a, x+1
	jnz x_eq_y_done
	setb mf
x_eq_y_done:
	pop psw
	pop acc
	ret

;------------------------------------------------
; mf=1 if x >= y
;------------------------------------------------
x_gteq_y:
	lcall x_eq_y
	jb mf, x_gteq_y_done
	ljmp x_gt_y
x_gteq_y_done:
	ret

;------------------------------------------------
; mf=1 if x <= y
;------------------------------------------------
x_lteq_y:
	lcall x_eq_y
	jb mf, x_lteq_y_done
	ljmp x_lt_y
x_lteq_y_done:
	ret
	
;------------------------------------------------
; x = x * y
;------------------------------------------------
mul16:
	push acc
	push b
	push psw
	push AR0
	push AR1
		
	; R0 = x+0 * y+0
	; R1 = x+1 * y+0 + x+0 * y+1
	
	; Byte 0
	mov	a,x+0
	mov	b,y+0
	mul	ab		; x+0 * y+0
	mov	R0,a
	mov	R1,b
	
	; Byte 1
	mov	a,x+1
	mov	b,y+0
	mul	ab		; x+1 * y+0
	add	a,R1
	mov	R1,a
	clr	a
	addc a,b
	mov	R2,a
	
	mov	a,x+0
	mov	b,y+1
	mul	ab		; x+0 * y+1
	add	a,R1
	mov	R1,a
	
	mov	x+1,R1
	mov	x+0,R0

	pop AR1
	pop AR0
	pop psw
	pop b
	pop acc
	
	ret

;------------------------------------------------
; x = sqrt(x)
;------------------------------------------------
sqrt16:
	
	push acc
	push b
	push psw
	push AR0
	push AR1
	push AR2
	push AR3

	mov r0, #80H ; Bit under test.  Start with most significant
	mov r2, #8   ; Loop counter: our answer is 8-bits
	mov r3, #0   ; Result

sqrt16_L0:
	mov a, r3
	orl a, r0
	mov r3, a
	mov b, a
	mul ab

	; Check if the square of our aproximation in [b,a] is bigger than x
	clr c
	subb a, x+0
	mov r1, a
	mov a, b
	subb a, x+1
	orl a, r1
	jz sqrt16_done ; Perfect match found! No need for stinky approximations!
	jnc sqrt16_bigger
	sjmp sqrt16_next_bit

sqrt16_bigger:
	; Too big, discard the bit
	mov a, r0
	cpl a
	anl a, r3
	mov r3, a
	
sqrt16_next_bit:		
	mov a, r0
	rr a
	mov r0, a
	
	djnz r2, sqrt16_L0
	
sqrt16_done:

	mov x+0, r3
	mov x+1, #0
	
	pop AR3
	pop AR2
	pop AR1
	pop AR0
	pop psw
	pop b
	pop acc
	
	ret

;------------------------------------------------
; x = x / y
; This subroutine uses the 'paper-and-pencil' 
; method described in page 139 of 'Using the
; MCS-51 microcontroller' by Han-Way Huang.
;------------------------------------------------
div16:
	push acc
	push psw
	push AR0
	push AR1
	push AR2
	
	mov	R2,#16 ; Loop counter
	clr	a
	mov	R0,a
	mov	R1,a
	
div16_loop:
	; Shift the 32-bit of [R1, R0, x+1, x+0] left:
	clr c
	; First shift x:
	mov	a,x+0
	rlc a
	mov	x+0,a
	mov	a,x+1
	rlc	a
	mov	x+1,a
	; Then shift [R1,R0]:
	mov	a,R0
	rlc	a 
	mov	R0,a
	mov	a,R1
	rlc	a
	mov	R1,a
	
	; [R1, R0] - y
	clr c	     
	mov	a,R0
	subb a,y+0
	mov	a,R1
	subb a,y+1
	
	jc	div16_minus		; temp >= y?
	
	; -> yes;  [R1, R0] -= y;
	; clr c ; carry is always zero here because of the jc above!
	mov	a,R0
	subb a,y+0 
	mov	R0,a
	mov	a,R1
	subb a,y+1
	mov	R1,a
	
	; Set the least significant bit of x to 1
	orl	x+0,#1
	
div16_minus:
	djnz R2, div16_loop	; -> no
	
div16_exit:

	pop AR2
	pop AR1
	pop AR0
	pop psw
	pop acc
	
	ret

; Copy x to y	
copy_xy:
	mov y+0, x+0
	mov y+1, x+1
	ret

; Exchange x and y 
xchg_xy:
	mov a, x+0
	xch a, y+0
	mov x+0, a
	mov a, x+1
	xch a, y+1
	mov x+1, a
	ret

Load_X MAC
	mov x+0, #low (%0) 
	mov x+1, #high(%0) 
ENDMAC

Load_y MAC
	mov y+0, #low (%0) 
	mov y+1, #high(%0) 
ENDMAC
	
$LIST
