	include	hardware_profile.inc
	__config	_CP_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC

	include	MicroMenu_Lib.h

Main_udata	udata_shr
w_temp		res	1
status_temp	res	1
flags		res	1
offset		res	1

	if	USE_SHORT_MOD_PCL
known_zero	res	1
global	known_zero
	endif

	global	flags,offset

	global	End_Interrupt_Heandler,Zastavka,Main
	extern	LCD_Line_Init,LCD_Init
	extern	Menu_heandler,Zastavka_routine
;==============================================================================================
RESET_VECTOR	code	0h
	goto	Init
;==============================================================================================
ISR				code	4h				; ������ ����������
Interrupt_Heandler
	push								; �������� ��������	
	bcf		INTCON,RBIF					; ������� ���� ��������� ����������
	movfw	PORTB						
	iorlw	b'00001111'					; ��������� ���������� �������
	addlw	.1
	btfsc	STATUS,Z
	goto	End_Interrupt_Heandler		; ���� �� ���� ������ �� ������, ��������� ��������� �������
	bcf		INTCON,RBIE					; �������� ��� ���������� ���������� �� ������, �� ��������� ����� �������
	btfss	UP
	bsf		Press_UP		
	btfss	DOWN
	bsf		Press_DOWN
	btfss	ENTER
	bsf		Press_ENTER
	btfss	EXIT
	bsf		Press_EXIT
End_Interrupt_Heandler
	pop									; ����������� ��������	
	retfie

;-------------------------------------------------------------------------------------------------------------------
Init
	banksel	OPTION_REG
	movlw	b'00000000'					; Enable pull-ups resistors on PortB
	movwf   OPTION_REG
	call	LCD_Line_Init				; ������������� ����� ���������� � ���� ������ ��� ������ � ��������
	banksel TMR0
	call	LCD_Init					; ������������ ������ �������
	clrf	flags

	movlw	(1<<RBIE)|(1<<GIE)
	iorwf	INTCON

Zastavka								
	goto	Zastavka_routine			; ������� �� ����� ��������
Main

	sleep
	nop

	movfw	flags						
	andlw	b'00001111'					; ������� ���������� �������
	btfsc	STATUS,Z
	goto	Main						; ���� �� ���� ������ �� ������, ������ ����������
	goto	Menu_heandler				; ����� ������ � ���������� ����

	end