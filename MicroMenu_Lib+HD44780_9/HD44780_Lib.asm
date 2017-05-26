	include	HD44780_Lib.h				; подключаем LCD header	
				
LCD_Lib_udata	udata_shr
temp_1	res	1
temp_2	res	1
symbol	res	1							; Holds value to send to LCD module

global	Send_LCD_Symbol,Send_LCD_Command,LCD_Line_Init,LCD_Init,Delay_4ms

LCD_Lib_code	code

Strob									; Strob + Delay 100 us
	bsf     LCD_CNTL,E
	nop
	bcf     LCD_CNTL,E
	movlw	.30							
	movwf	temp_1		
	decfsz	temp_1
	goto	$-1
	return

Send_LCD_Symbol
	if	(!Use_4_bit_mode)	
	movwf	LCD_DATA
	call	Strob
	endif

	if	(Use_4_bit_mode && Use_High_Nible)
	movwf	symbol	
	movwf	LCD_DATA
	call	Strob
	swapf	symbol,w
	movwf	LCD_DATA
	call	Strob

	else
	movwf	symbol
	swapf	symbol,w
	movwf	LCD_DATA
	call	Strob
	movfw	symbol
	movwf	LCD_DATA
	call	Strob
	endif

	return

Send_LCD_Command
	bcf     LCD_CNTL,RS					; Опускаем RS, здесь нельзя через Чтение - Модификацию - Запись !!!

	if	(!Use_4_bit_mode)	
	movwf	LCD_DATA
	call	Strob
	endif

	if	(Use_4_bit_mode && Use_High_Nible)
	movwf	symbol	
	movwf	LCD_DATA
	call	Strob
	swapf	symbol,w
	movwf	LCD_DATA
	call	Strob

	else
	movwf	symbol
	swapf	symbol,w
	movwf	LCD_DATA
	call	Strob
	movfw	symbol
	movwf	LCD_DATA
	call	Strob
	endif

	bsf     LCD_CNTL,RS					; Теперь выводим не команды а символы на дисплей, поэтому поднимаем RS
	return

LCD_Line_Init							; Инициализация линий управления и шины данных для работы с дисплеем
	if	(Use_4_bit_mode && Use_High_Nible)
	movlw   b'00001111'
	endif

	if	(Use_4_bit_mode && !Use_High_Nible)
	movlw   b'11110000'

	else
	movlw   b'00000000'
	endif

	andwf   LCD_DATA_TRIS
	movlw   CNTL_TRIS_MASK				; RS and E as outputs, if RW not used - as input
	andwf	LCD_CNTL_TRIS
	return						 

;========== Initilize the LCD Display Module =========================================================
LCD_Init
	clrf    LCD_CNTL
	clrf    LCD_DATA
	call	Delay_4ms					; Обязательная стартовая задержка !!!
	bcf     LCD_CNTL,RS					; Опускаем RS

	if	(Use_4_bit_mode && !Use_High_Nible)
	movlw	b'00000011'					; При инициализации сперва выставим 8-bit шину, так надо (DL=1)
	iorwf   LCD_DATA
	call	Strob
	call	Delay_4ms					; Обязательная задержка !!!
	movlw	b'00000011'					; Второй раз выставим 8-bit шину, так надо (DL=1)
	iorwf   LCD_DATA
	call	Strob
	movlw	b'00000011'					; И в третий раз выставим 8-bit шину, так надо (DL=1)
	iorwf   LCD_DATA
	call	Strob	

	else
	movlw	b'00110000'					; При инициализации сперва выставим 8-bit шину, так надо (DL=1)
	iorwf   LCD_DATA
	call	Strob
	call	Delay_4ms					; Обязательная задержка !!!
	movlw	b'00110000'					; Второй раз выставим 8-bit шину, так надо (DL=1)
	iorwf   LCD_DATA
	call	Strob
	movlw	b'00110000'					; И в третий раз выставим 8-bit шину, так надо (DL=1)
	iorwf   LCD_DATA
	call	Strob
	endif

; Дальше надо бы читать состояния флага шины (BF), но легче тупить задержками по 100 мкс (в составе процедуры Strob)

	if	(Use_4_bit_mode && !Use_High_Nible)
	movlw	b'00000010'					; Выставляем 4-bit шину (DL=0), старший полубайт
	movwf   LCD_DATA
	call	Strob
	movlw	b'00000010'					; Опять старший полубайт, потому что мы перед этим переключились на 4-х битную шину и его надо переслать опять
	movwf   LCD_DATA
	call	Strob
	movlw	b'00001000'					; Младший полубайт (N = 1 - 2 строки, F = 0 - символы 5*7)
	movwf   LCD_DATA
	call	Strob
	
	else
	movlw	b'00100000'					; Выставляем 4-bit шину (DL=0), старший полубайт
	movwf   LCD_DATA
	call	Strob
	movlw	b'00100000'					; Опять старший полубайт, потому что мы перед этим переключились на 4-х битную шину и его надо переслать опять
	movwf   LCD_DATA
	call	Strob
	movlw	b'10000000'					; Младший полубайт (N = 1 - 2 строки, F = 0 - символы 5*7)
	movwf   LCD_DATA
	call	Strob
	endif

; Тепрь шлем все команды 1 байтом, команда Send_LCD_Symbol при необходимости сама разьобет на ниблы и отправит в порт LCD_DATA
; ВНИМАНИЕ !!! Hitachi LM032L (находиться в составе PICDEM 2 PLUS) имеет особенность в порядке следования команд при инициализации
; Этот порядок ни в коем случае нельза нарушать !!!

	movlw	DISP_ON						; Обязательно сперва включаем дисплей
	call	Send_LCD_Symbol
	movlw	ENTRY_INC					; Автоинкремент адреса, нет сдвига
	call	Send_LCD_Symbol
	movlw	CLR_DISP					; В конце очищаем дисплей и устанавливаем курсор на 1 позицию
	call	Send_LCD_Symbol
	call	Delay_4ms					; Обязательная задержка !!!
	bsf     LCD_CNTL,RS					; Теперь выводим не команды а символы на дисплей, поэтому поднимаем RS
	return
;========== END Initilize the LCD Display Module =========================================================
Delay_4ms
	movlw	.5
	movwf	temp_2
	clrf	temp_1		
	decfsz	temp_1
	goto	$-1
	decfsz	temp_2
	goto	$-3
	return

	end