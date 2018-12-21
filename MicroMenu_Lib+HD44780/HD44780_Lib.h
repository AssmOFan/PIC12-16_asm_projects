include	hardware_profile.inc

y				equ		1				; YES
n				equ		0				; NO

Use_4_bit_mode	equ		y				; YES/NO
Use_High_Nible	equ		n				; YES/NO
Use_One_Port	equ		n				; YES/NO
Only_Write		equ		y				; YES/NO

LCD_DATA		equ		PORTB			; ��������� ���� ����� ������
LCD_DATA_TRIS	equ		TRISB

	if	(Use_4_bit_mode && Use_One_Port); ���� ���������� ���� ���� ��� ������ � ����� ����������

LCD_CNTL		equ		LCD_DATA		; �� ��� � ������
LCD_CNTL_TRIS	equ		LCD_DATA_TRIS

	else

LCD_CNTL		equ		PORTA			; ����� ������� ����� ������
LCD_CNTL_TRIS	equ		TRISA
	endif
	
	if	(Use_4_bit_mode && Use_One_Port && Use_High_Nible && Only_Write)
E				equ		2
RS				equ		3
CNTL_TRIS_MASK	equ		b'11110011'		; ����� ��������� ����� ����������
	endif

	if	(Use_4_bit_mode && Use_One_Port && Use_High_Nible && !Only_Write)
E				equ		1
RW				equ		2
RS				equ		3
CNTL_TRIS_MASK	equ		b'11110001'		; ����� ��������� ����� ����������
	endif	

	if	(Use_4_bit_mode && Use_One_Port && !Use_High_Nible && Only_Write)
E				equ		4
RS				equ		5
CNTL_TRIS_MASK	equ		b'11001111'		; ����� ��������� ����� ����������
	endif	

	if	(Use_4_bit_mode && Use_One_Port && !Use_High_Nible && !Only_Write)
E				equ		4
RW				equ		5
RS				equ		6
CNTL_TRIS_MASK	equ		b'10001111'		; ����� ��������� ����� ����������

	else	; ����� ����������� ����������� ������ ����� ������ ���� � �������� ����� �� �� ������ ����������
	
E				equ		1
RS				equ		3
CNTL_TRIS_MASK	equ		b'11110101'		; ����� ��������� ����� ����������
	endif

DISP_ON			EQU		b'00001100'		; Display on
DISP_ON_C		EQU		b'00001110'		; Display on, Cursor on
DISP_ON_B		EQU		b'00001111'		; Display on, Cursor on, Blink cursor
DISP_OFF		EQU		b'00001000'		; Display off
CLR_DISP		EQU		b'00000001'		; Clear the Display
ENTRY_INC		EQU		b'00000110'		; ������������� ������, ��� ������ 
ENTRY_INC_S		EQU		b'00000111'		; ������������� ������, ���� �����
ENTRY_DEC		EQU		b'00000100'		; ������������� ������, ��� ������ 
ENTRY_DEC_S		EQU		b'00000101'		;
DD_RAM_ADDR		EQU		b'10000000'		; Least Significant 7-bit are for address
DD_RAM_UL		EQU		b'10000000'		; Upper Left coner of the Display
SECOND_LINE		EQU		b'11000000'		; Move cursor to second line
LAST_SYMBOL_FIRST_LINE	EQU	b'10001111'	; ��������� ������ �� ��������� ������ 1-� ������
LAST_SYMBOL_SECOND_LINE	EQU	b'11001111'	; ��������� ������ �� ��������� ������ 2-� ������

Print_LCD_String_macro	macro	LABEL
						local	Print_LCD_String,End_LCD_String	
						clrf	symbol_pointer
					Print_LCD_String
						call	LABEL
						andlw   0FFh
						btfsc   STATUS,Z
						goto	End_LCD_String		
						call    Send_LCD_Symbol
						incf	symbol_pointer	
						goto    Print_LCD_String
					End_LCD_String	
						endm
;================================================================================================================
Draw_Cursor	macro	SYMBOL
			movlw	SYMBOL
			call	Draw_Cursor_Routine
			endm
;================================================================================================================
Second_Line_macro	macro
					movlw	SECOND_LINE	
					call	Send_LCD_Command
					endm
;================================================================================================================
