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
ISR				code	4h				; Вектор прерывания
Interrupt_Heandler
	push								; Сохраним контекст	
	bcf		INTCON,RBIF					; Сбросим флаг вызваного прерывания
	movfw	PORTB						
	iorlw	b'00001111'					; Установим незначущие разряды
	addlw	.1
	btfsc	STATUS,Z
	goto	End_Interrupt_Heandler		; Если ни одна кнопка не нажата, пропустим обработку нажатия
	bcf		INTCON,RBIE					; Запретим все дальнейшие прерывания от кнопок, до обработки этого нажатия
	btfss	UP
	bsf		Press_UP		
	btfss	DOWN
	bsf		Press_DOWN
	btfss	ENTER
	bsf		Press_ENTER
	btfss	EXIT
	bsf		Press_EXIT
End_Interrupt_Heandler
	pop									; Восстановим контекст	
	retfie

;-------------------------------------------------------------------------------------------------------------------
Init
	banksel	OPTION_REG
	movlw	b'00000000'					; Enable pull-ups resistors on PortB
	movwf   OPTION_REG
	call	LCD_Line_Init				; Инициализация линий управления и шины данных для работы с дисплеем
	banksel TMR0
	call	LCD_Init					; Инициалзация самого дисплея
	clrf	flags

	movlw	(1<<RBIE)|(1<<GIE)
	iorwf	INTCON

Zastavka								
	goto	Zastavka_routine			; Выведем на экран заставку
Main

	sleep
	nop

	movfw	flags						
	andlw	b'00001111'					; Занулим незначущие разряды
	btfsc	STATUS,Z
	goto	Main						; Если ни одна кнопка не нажата, просто зациклимся
	goto	Menu_heandler				; Иначе входим в обработчик меню

	end