	include	HD44780_Lib.h				; ���������� LCD header	
				
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
	bcf     LCD_CNTL,RS					; �������� RS, ����� ������ ����� ������ - ����������� - ������ !!!

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

	bsf     LCD_CNTL,RS					; ������ ������� �� ������� � ������� �� �������, ������� ��������� RS
	return

LCD_Line_Init							; ������������� ����� ���������� � ���� ������ ��� ������ � ��������
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
	call	Delay_4ms					; ������������ ��������� �������� !!!
	bcf     LCD_CNTL,RS					; �������� RS

	if	(Use_4_bit_mode && !Use_High_Nible)
	movlw	b'00000011'					; ��� ������������� ������ �������� 8-bit ����, ��� ���� (DL=1)
	iorwf   LCD_DATA
	call	Strob
	call	Delay_4ms					; ������������ �������� !!!
	movlw	b'00000011'					; ������ ��� �������� 8-bit ����, ��� ���� (DL=1)
	iorwf   LCD_DATA
	call	Strob
	movlw	b'00000011'					; � � ������ ��� �������� 8-bit ����, ��� ���� (DL=1)
	iorwf   LCD_DATA
	call	Strob	

	else
	movlw	b'00110000'					; ��� ������������� ������ �������� 8-bit ����, ��� ���� (DL=1)
	iorwf   LCD_DATA
	call	Strob
	call	Delay_4ms					; ������������ �������� !!!
	movlw	b'00110000'					; ������ ��� �������� 8-bit ����, ��� ���� (DL=1)
	iorwf   LCD_DATA
	call	Strob
	movlw	b'00110000'					; � � ������ ��� �������� 8-bit ����, ��� ���� (DL=1)
	iorwf   LCD_DATA
	call	Strob
	endif

; ������ ���� �� ������ ��������� ����� ���� (BF), �� ����� ������ ���������� �� 100 ��� (� ������� ��������� Strob)

	if	(Use_4_bit_mode && !Use_High_Nible)
	movlw	b'00000010'					; ���������� 4-bit ���� (DL=0), ������� ��������
	movwf   LCD_DATA
	call	Strob
	movlw	b'00000010'					; ����� ������� ��������, ������ ��� �� ����� ���� ������������� �� 4-� ������ ���� � ��� ���� ��������� �����
	movwf   LCD_DATA
	call	Strob
	movlw	b'00001000'					; ������� �������� (N = 1 - 2 ������, F = 0 - ������� 5*7)
	movwf   LCD_DATA
	call	Strob
	
	else
	movlw	b'00100000'					; ���������� 4-bit ���� (DL=0), ������� ��������
	movwf   LCD_DATA
	call	Strob
	movlw	b'00100000'					; ����� ������� ��������, ������ ��� �� ����� ���� ������������� �� 4-� ������ ���� � ��� ���� ��������� �����
	movwf   LCD_DATA
	call	Strob
	movlw	b'10000000'					; ������� �������� (N = 1 - 2 ������, F = 0 - ������� 5*7)
	movwf   LCD_DATA
	call	Strob
	endif

; ����� ���� ��� ������� 1 ������, ������� Send_LCD_Symbol ��� ������������� ���� �������� �� ����� � �������� � ���� LCD_DATA
; �������� !!! Hitachi LM032L (���������� � ������� PICDEM 2 PLUS) ����� ����������� � ������� ���������� ������ ��� �������������
; ���� ������� �� � ���� ������ ������ �������� !!!

	movlw	DISP_ON						; ����������� ������ �������� �������
	call	Send_LCD_Symbol
	movlw	ENTRY_INC					; ������������� ������, ��� ������
	call	Send_LCD_Symbol
	movlw	CLR_DISP					; � ����� ������� ������� � ������������� ������ �� 1 �������
	call	Send_LCD_Symbol
	call	Delay_4ms					; ������������ �������� !!!
	bsf     LCD_CNTL,RS					; ������ ������� �� ������� � ������� �� �������, ������� ��������� RS
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