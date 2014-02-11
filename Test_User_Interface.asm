$modde2

org 000H
	ljmp main

STATE_STANDBY 	EQU 0
STATE_HEATING1	EQU 1
STATE_SOAK		EQU 2
STATE_HEATING2	EQU 3
STATE_REFLOW	EQU 4
STATE_COOLING	EQU 5
STATE_OPEN_DOOR	EQU 6
	
DSEG at 30h

soak_temperature : ds 2
soak_time		 : ds 2
reflow_temperature: ds 2
reflow_time       : ds 2
state			  : ds 2

;Math16/32 Variables
x						: ds 2
y						: ds 2
bcd						: ds 3

;LCD_DATA			: ds 1

BSEG
;LCD_ON				: dbit 1
;LCD_EN				: dbit 1
;LCD_MOD				: dbit 1
;LCD_RW				: dbit 1
BSEG
;Math16
mf 						:  dbit 1



CSEG

myLUT:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H        ; 0 TO 4
    DB 092H, 082H, 0F8H, 080H, 090H        ; 4 TO 9
    DB 088H, 083H, 0C6H, 0A1H, 086H, 08EH  ; A to F

$include (LCD_Display.asm)
$include (Read_sw5.asm)
$include (User_Interface.asm)
$include (math16.asm)

main:
	clr A
	clr C
	mov LEDG, A
	mov LEDRA, A
	mov LEDRB, A
	mov LEDRC, A
	
	lcall LCD_init
forever:
	lcall UI_Set_Up_Parameters
	
	sjmp forever
	



end
