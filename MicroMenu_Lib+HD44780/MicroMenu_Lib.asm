	include	MicroMenu_Lib.h
	include	HD44780_Lib.h

MicroMenu_Lib_udata	udata_shr
index_menu		res	1
index_submenu	res	1
num_of_submenu	res	1					; ���������� ������� � ������� ����
symbol_pointer	res	1
menu_counter	res	1
buttons			res	1
temp_1			res	1
temp_2			res	1
temp_3			res	1

	if SAVE_CURSOR_POSITION
save_position	res	1
	endif

	if	USE_SHORT_MOD_PCL
	extern	known_zero
	endif

	global	buttons
	extern	offset
	global	Menu_heandler,Zastavka,ENTER_menu
	extern	Send_LCD_Symbol,Send_LCD_Command,Delay_4ms,CLR_Display_routine,Main
;===================================================================================================
MicroMenu		code					; ������� ���� ���������� ����
;===================================================================================================
Table_Action_Complete 
	mod_PCL	symbol_pointer
 	dt		"Action Complete!",0
;===================================================================================================
Menu_heandler							; ���������� ����
;===================================================================================================
	clrf	index_menu					; ���� ������� �����-�� ������, ������� ������ ������ ����					

	if	USE_MOVING_CURSOR & !USE_TOP_LAST_CURSOR
	clrf	buttons						; ������� ����� ������� ������					
	bsf		Press_UP					; � ��������� ������� ������� ������ ��� ������ "�����"
	endif
;----------------------------------------------------------------------------------------------------------------------------
Draw_Menu								; ��������� ������� ����							
	if	USE_MOVING_CURSOR & USE_TOP_LAST_CURSOR
	movfw	index_menu
	bnz		Check_1						; ���� ������ ����� ����		
	clrf	buttons						; ������� ����� ������� ������
	bsf		Press_UP					; � ��������� ������� ������� ������ ��� ������ "�����"
	goto	Skip_Check_1
Check_1
	sublw	NUM_OF_MAIN_MENU_PUNKTS-1	; ���������� � ����������� ������� ����
	bnz		Skip_Check_1				; ���� ��������� ����� ����	
	clrf	buttons						; ������� ����� ������� ������
	bsf		Press_DOWN					; � ��������� ������� ������� ������ ��� ������ "����"
Skip_Check_1
	endif

	call	CLR_Display_routine			; ������� ������� ����� ����� ������������ ������� ����, ����� ��������� ��������

	if	USE_MOVING_CURSOR
	btfss	Press_UP					; ���� ���� ������ ������ �����
	goto	Pressing_DOWN			
	call	Draw_Menu_routine			; ������ ������� ����� ����
	Draw_Cursor	LAST_SYMBOL_FIRST_LINE	; ������� ������ � ����� 1-� �������
	call	Second_String_routine		; ��������� �� 2 ������
	incf	index_menu					; ����� ��������� ����� ����
	movfw	index_menu
	sublw	NUM_OF_MAIN_MENU_PUNKTS		; ���������� � ����������� ������� ����
	bz		Correct_index_menu				
	call	Draw_Menu_routine			; ������ ��������� ����� ���� ��� �������
	decf	index_menu					; ������ ������� ������ ����
	goto	Skip_Correct_index_menu_3
Correct_index_menu						; �������� ���������� ������ ����, ��������� ���������� 1 �����
	clrf	index_menu
	call	Draw_Menu_routine
	movlw	NUM_OF_MAIN_MENU_PUNKTS-1
	movwf	index_menu
	goto	Skip_Correct_index_menu_3
Pressing_DOWN							; ���� ���� ������ ������ ����							
	decf	index_menu					; ����� ���������� ����� ����
	btfsc	index_menu,.7				; ��������� �� "<0"	������� ��������� 7 ����, ������������ ���������� ������� ���� ���������� 64
	goto	Correct_index_menu_2
	call	Draw_Menu_routine			; ������ ���������� ����� ����
	call	Second_String_routine		; ��������� �� 2 ������
	incf	index_menu					; ������ ������� ������ ����				
	goto	Skip_Correct_index_menu_2
Correct_index_menu_2
	movlw	NUM_OF_MAIN_MENU_PUNKTS-1
	movwf	index_menu
	call	Draw_Menu_routine			; ������ ���������� ����� ���� ��� �������
	call	Second_String_routine		; ��������� �� 2 ������
	clrf	index_menu
Skip_Correct_index_menu_2
	call	Draw_Menu_routine			; ������ ������� ����� ���� ��� ����������
	Draw_Cursor	LAST_SYMBOL_SECOND_LINE
Skip_Correct_index_menu_3

	else
	call	Draw_Menu_routine			; ������ ������� ����� ����
	call	Second_String_routine		; ��������� �� 2 ������
	incf	index_menu					; ����� ��������� ����� ����
	movfw	index_menu
	sublw	NUM_OF_MAIN_MENU_PUNKTS		; ���������� � ����������� ������� ����
	bz		Correct_index_menu		
	call	Draw_Menu_routine			; ������ ��������� ����� ���� ��� ������� 
	decf	index_menu					; ������ ������� ������ ����	
	goto	Skip_Correct_index_menu
Correct_index_menu						; �������� ���������� ������ ����, ��������� ���������� 1 �����
	clrf	index_menu
	call	Draw_Menu_routine
	movlw	NUM_OF_MAIN_MENU_PUNKTS-1
	movwf	index_menu					; ������ ������� ������ ����	
Skip_Correct_index_menu
	endif

	call	Debounce_Delay				; ��������� ������������, ���������� ��� ������ ����� � ����, ��� ������� ������ "�����", "����", ������ �� ��������� ����
	movlw	EXIT_DELAY					; ������� ������� �������� ������ ������
	movwf	menu_counter
	clrf	temp_1
	clrf	temp_2
Loop_Menu								; ��������� ������� �������
	if	USE_RBIE
	btfsc	Press_UP
	goto	Cursor_UP_menu				
	btfsc	Press_DOWN
	goto	Cursor_DOWN_menu
	btfsc	Press_ENTER
	goto	ENTER_menu
	btfsc	Press_EXIT
	goto	EXIT_menu

	else
	btfss	UP
	goto	Cursor_UP_menu				
	btfss	DOWN
	goto	Cursor_DOWN_menu
	btfss	ENTER
	goto	ENTER_menu
	btfss	EXIT
	goto	EXIT_menu
	endif
;-----------------------------------------------------------------										
	decfsz	temp_1						; �� ���� ������� �� ������						
	goto	Loop_Menu					; ���� �������� ������� � ������� ����	
	decfsz	temp_2	
	goto	Loop_Menu
	decfsz	menu_counter				; ��������� �������� �������� ������ ������	
	goto	Loop_Menu
	goto	Zastavka					; ����� ������� ���������� � ����, ������� � ��������	
;-----------------------------------------------------------------
Cursor_UP_menu							; ���� ������ ������� "�����"
	if	USE_MOVING_CURSOR & !USE_RBIE	; ��� ������������� ���������� ���� ���� � ��� ������������ � �����������
	clrf	buttons						; ������� ����� ������� ������					
	bsf		Press_UP					; � ��������� ������� ������� ������ ��� ������ "�����"
	endif

	decf	index_menu					; ����� ���������� ����� ����
	btfss	index_menu,.7				; ��������� �� "<0"	������� ��������� 7 ����, ������������ ���������� ������� ���� ���������� 64
	goto	Draw_Menu
	movlw	NUM_OF_MAIN_MENU_PUNKTS-1	; ����� "<0", ������� ������� ��������� ����� ����. ���������, ��� ������ ������ ���� �� 1 ������ ��� ����������� ������
	movwf	index_menu
	goto	Draw_Menu					; ������������ ����� ������� ����� ����
;-----------------------------------------------------------------
Cursor_DOWN_menu						; ���� ������ ������� "����"
	if	USE_MOVING_CURSOR & !USE_RBIE	; ��� ������������� ���������� ���� ���� � ��� ������������ � �����������
	clrf	buttons						; ������� ����� ������� ������					
	bsf		Press_DOWN					; � ��������� ������� ������� ������ ��� ������ "����"
	endif

	incf	index_menu					; ����� �������� ����� ����
	movfw	index_menu
	sublw	NUM_OF_MAIN_MENU_PUNKTS		; �������� ���������� ?
	btfsc	STATUS,Z
	clrf	index_menu					; ���� ��, ������ ������� ������ ����� ����	
	goto	Draw_Menu					; ������������ ����� ������� ����� ����
;-----------------------------------------------------------------
EXIT_menu								; ���� ������ ������� "�����"
	call	Debounce_Delay	
	goto	Zastavka					; ������� � ��������
;===================================================================================================
ENTER_menu								; ���� ������ ������� "����", ����������� ���� � ���� � ��������� ����������
;===================================================================================================
	if	USE_MENU_ACTION		
	incf	index_menu,w				; ����� ������� ����� ���� (���������, ��� ��������� ���������� � 0)
	movwf	temp_1						; ������� � �������
	movlw	actions_menu_flags			; ����� ����� �������� ������� ����
	movwf	temp_2						; � ������� � ����������
Loop_1
	decfsz	temp_1
	goto	Rotate_action_menu_flags
	bc		Menu_Action					; ���� �������� �������� ������ ���� �������� � ��� ��������, ����������� ���
	goto	End_Menu_Action
Rotate_action_menu_flags
	rrf		temp_2						; ������� ������ �������� ���� ������� ����
	goto	Loop_1	
End_Menu_Action
	endif

	call	Num_of_Submenu_Table		; �������� ���������� ���������� � ���� ������ ����
	movwf	num_of_submenu				; 1 ��� ������� � ����������, ����� ������ ��� �� �������� ��� ���������	
	sublw	.0							; ������� � 0
;	movf	num_of_submenu,f			; � ����� �������� � 0 � ���: �������� ���������� ���� � ����, � ���� ��� = 0, ����������� ���� Z
	bz		Draw_Menu					; ���� 0, ����� �� ����� ��� ���������� ����������
	clrf	index_submenu				; ������� ������ ������ �������	

	if	USE_MOVING_CURSOR & SAVE_CURSOR_POSITION
	movfw	buttons
	movwf	save_position				; �������� ������� �������
	endif

	if	USE_MOVING_CURSOR & !USE_TOP_LAST_CURSOR
	clrf	buttons						; ������� ����� ������� ������					
	bsf		Press_UP					; � ��������� ������� ������� ������ ��� ������ "�����"
	endif
;===================================================================================================
Draw_Submenu							; ������ ��������� ����
;===================================================================================================
	if	USE_MOVING_CURSOR & USE_TOP_LAST_CURSOR
	movfw	index_submenu
	bnz		Check_2		
	clrf	buttons						; ������� ����� ������� ������
	bsf		Press_UP					; � ��������� ������� ������� ������ ��� ������ "�����"
	goto	Skip_Check_2
Check_2
	decf	num_of_submenu,w			; �������� ���������� ���������� � ���� ����, ���������, ��� ������ ��������� ���������� � 0
	subwf	index_submenu,w				; ���������� � ����������� ���������� ����
	bnz		Skip_Check_2
	clrf	buttons						; ������� ����� ������� ������
	bsf		Press_DOWN					; � ��������� ������� ������� ������ ��� ������ "����"
Skip_Check_2
	endif

	call	CLR_Display_routine			; ������� ������� ����� ����� ������������ ���������� ����, ����� ��������� ��������

	if	USE_MOVING_CURSOR
	btfss	Press_UP
	goto	Pressing_DOWN_2			
	call	Draw_Submenu_routine		; ������ ������� �������� ����	
	movfw	num_of_submenu				; �������� ���������� ���������� � ���� ����
	sublw	.1							; ������� � 1
	bz		Skip_Correct_index_submenu_3; ���� 1, ���������� ���������� 2-� ������
	Draw_Cursor	LAST_SYMBOL_FIRST_LINE	; ������� ������ � ����� 1-� �������
	call	Second_String_routine		; ��������� �� 2 ������
	incf	index_submenu				; ����� ��������� �����
	movfw	num_of_submenu				; �������� ���������� ���������� � ���� ����
	subwf	index_submenu,w				; ���������� � ����������� ���������� ����
	bz		Correct_index_submenu
	call	Draw_Submenu_routine		; ������ �������� ���� ��� ������� 
	decf	index_submenu				; �� ������� ������� ����� ������� ����� ����	
	goto	Skip_Correct_index_submenu_3
Correct_index_submenu					; �������� ���������� ��������� ����, ��������� ���������� 1 ��������
	clrf	index_submenu
	call	Draw_Submenu_routine
	decf	num_of_submenu,w
	movwf	index_submenu
	goto	Skip_Correct_index_submenu_3
Pressing_DOWN_2
	decf	index_submenu				; ����� ���������� ����� ����
	btfsc	index_submenu,.7			; ��������� �� "<0"	������� ��������� 7 ����, ������������ ���������� ������� ���� ���������� 64
	goto	Correct_index_submenu_2
	call	Draw_Submenu_routine		; ������ ���������� ����� ����
	call	Second_String_routine		; ��������� �� 2 ������
	incf	index_submenu				; ������ ������� �����					
	goto	Skip_Correct_index_submenu_2
Correct_index_submenu_2
	decf	num_of_submenu,w
	movwf	index_submenu
	call	Draw_Submenu_routine		; ������ ���������� ����� ����
	call	Second_String_routine		; ��������� �� 2 ������
	clrf	index_submenu
Skip_Correct_index_submenu_2
	call	Draw_Submenu_routine		; ������ ������� ����� ���� ��� ���������� 
	Draw_Cursor	LAST_SYMBOL_SECOND_LINE	; ������� ������ � ����� 2-� �������
Skip_Correct_index_submenu_3

	else
	call	Draw_Submenu_routine		; ������ ������� �������� ����	
	movfw	num_of_submenu				; �������� ���������� ���������� � ���� ����
	sublw	.1
	bz		Skip_Correct_index_submenu	; ���� 1, ���������� ���������� 2-� ������
	call	Second_String_routine		; ����� ��������� �� 2 ������
	incf	index_submenu				; ������ ���������� ������
	movfw	num_of_submenu			
	subwf	index_submenu,w				; ���������� � ����������� ���������� ����
	bz		Correct_index_submenu
	call	Draw_Submenu_routine		; ������ �������� ���� ��� ������� 
	decf	index_submenu				; ������ ����� ������ ���������
	goto	Skip_Correct_index_submenu	
Correct_index_submenu					; �������� ���������� ��������� ����, ��������� ���������� 1 ��������
	clrf	index_submenu	
	call	Draw_Submenu_routine
	decf	num_of_submenu,w			; ���� ������ <0
	movwf	index_submenu				; ������� ������� ��������� ����� �������
Skip_Correct_index_submenu
	endif

	call	Debounce_Delay				; ��������� ������������, ���������� ��� ������ ����� � �������� ����, ��� ������� ������ "�����", "����", ������ �� �������� ��������� ����
	movlw	EXIT_DELAY					; ������� ������� �������� ������ ������
	movwf	menu_counter
	clrf	temp_1
	clrf	temp_2
Loop_Submenu							; �� ����� � ����� ����, ���� ������� ��������� ������
	if	USE_RBIE
	btfsc	Press_UP
	goto	Cursor_UP_submenu				
	btfsc	Press_DOWN
	goto	Cursor_DOWN_submenu
	btfsc	Press_ENTER
	goto	ENTER_submenu
	btfsc	Press_EXIT
	goto	EXIT_submenu

	else
	btfss	UP
	goto	Cursor_UP_submenu				
	btfss	DOWN
	goto	Cursor_DOWN_submenu
	btfss	ENTER
	goto	ENTER_submenu
	btfss	EXIT
	goto	EXIT_submenu
	endif
;-----------------------------------------------------------------
	decfsz	temp_1						; �� ���� ������� �� ������	
	goto	Loop_Submenu				; ���� �������� ������� � ������ ����
	decfsz	temp_2	
	goto	Loop_Submenu
	decfsz	menu_counter				; ��������� �������� �������� ������ ������		
	goto	Loop_Submenu
	goto	Draw_Menu					; ����� ������� ���������� � �������, ������� � ����
;-----------------------------------------------------------------
Cursor_UP_submenu						; ���� ������ ������� "�����"
	if	USE_MOVING_CURSOR & !USE_RBIE	; ��� ������������� ���������� ���� ���� � ��� ������������ � �����������
	clrf	buttons						; ������� ����� ������� ������					
	bsf		Press_UP					; � ��������� ������� ������� ������ ��� ������ "�����"
	endif

	decf	index_submenu				; ��������� ������ �������
	btfss	index_submenu,.7			; ��������� �� "<0"	������� ��������� 7 ����, ������������ ���������� ������� ������� ���������� 64
	goto	Draw_Submenu		
	decf	num_of_submenu,w			; ���� ������ <0
	movwf	index_submenu				; ������� ������� ��������� ����� �������
	goto	Draw_Submenu				; ������������ ����� ������� �������� ����	
;-----------------------------------------------------------------
Cursor_DOWN_submenu						; ���� ������ ������� "����"
	if	USE_MOVING_CURSOR & !USE_RBIE	; ��� ������������� ���������� ���� ���� � ��� ������������ � �����������
	clrf	buttons						; ������� ����� ������� ������					
	bsf		Press_DOWN					; � ��������� ������� ������� ������ ��� ������ "����"
	endif

	incf	index_submenu				; ����������� ������ �������
	movfw	num_of_submenu				; ����� ���������� ������� � ����� �������	
	subwf	index_submenu,w				; �������� ���������� ?	
	btfsc	STATUS,Z
	clrf	index_submenu				; ���� ��, ������ ������� ������ �������� ����		
	goto	Draw_Submenu				; ������������ ����� ������� �������� ����
;-----------------------------------------------------------------	
EXIT_submenu							; ���� ������ ������� "�����"
	if USE_MOVING_CURSOR & SAVE_CURSOR_POSITION
	movfw	save_position
	movwf	buttons						; ����������� ������� �������
	endif

	clrf	index_submenu				; �������� ������ ������ �������, ����� ��� ��������� ������ � ����� ����� ���� ������ ��������� �� 1 ������ �������
	goto	Draw_Menu					; ������� � ����
;===================================================================================================
ENTER_submenu							; ���� ������ ������� "����", ����������� ���� � �������� ���� � ��������� ��� ��������
;===================================================================================================
	call	CLR_Display_routine			; ������� �������
	goto	Switch_Action				; ������ �������� �������� ��������� ����
End_Action
;-----------------------------------------------------------------
	Print_LCD_String_macro	Table_Action_Complete	; ������ ������������� ��������
	clrf	temp_3						; ��������, ����� ������ �������� ����������� � ���������� �������
	call	Debounce_Delay
	decfsz	temp_3
	goto	$-2
;-----------------------------------------------------------------
	goto	Draw_Submenu				; � ���� ������������ �������� ����, ������ �� ��� �� ���������, ��� � ���
;===================================================================================================
Debounce_Delay							; ������������ ��������������� ��������
	movlw	.3							; ���������� �������� ����������� ����������������� �����
	movwf	temp_2
	clrf	temp_1
Loop_Delay
	movfw	PORTB						
	iorlw	b'00001111'					; ��������� ���������� �������
	addlw	.1
	bnz		Debounce_Delay				; ���� ���� ���� ������ ������, �������� ������ ��������������� �������� ������
	decfsz	temp_1	
	goto	$-1
	decfsz	temp_2	
	goto	Loop_Delay

	if	USE_RBIE
	clrf	buttons						; ������� ����� ������� ������
	bcf		INTCON,RBIF					; ������� ���� �������� ��������� ���������� �� ������
	bsf		INTCON,RBIE					; � �������� ���������� �� ������
	endif

	return
;===================================================================================================
Draw_Menu_routine						; ������������ ��������� ������ ������ ����
	clrf	symbol_pointer
Loop_Draw_Menu
	call	Menu_Table
	andlw   0FFh
	btfsc   STATUS,Z
	return 
	call    Send_LCD_Symbol
	incf	symbol_pointer	
	goto    Loop_Draw_Menu
;----------------------------------------------------------------------------------------------------------------------------
Draw_Submenu_routine					; ������������ ��������� ������ ��������� ����
	clrf	symbol_pointer
Loop_Draw_Submenu
	call	Submenu_Table
	andlw   0FFh
	btfsc   STATUS,Z
	return 
	call    Send_LCD_Symbol
	incf	symbol_pointer	
	goto    Loop_Draw_Submenu
;===================================================================================================
Zastavka
	call	CLR_Display_routine			; ������� �������
	Print_LCD_String_macro	Table_Zastavka_First_String
	Second_Line_macro
	Print_LCD_String_macro	Table_Zastavka_Second_String
	goto    Main
;===================================================================================================
Second_String_routine					; ������������ �������� ��������� �� 2-� ������	
	if	USE_STATIC_CURSOR
	Draw_Cursor	LAST_SYMBOL_FIRST_LINE	; �������� ������ �� ��������� ������� 1-� ������
	endif
	Second_Line_macro					; ��������� ��������� �� 2-� ������	
	return								; � ���������� � ��������� ���������� ������ ����
;===================================================================================================
Draw_Cursor_Routine						; ��������� ��������� �������. � w ����� �����
	call	Send_LCD_Command
	movlw	'<'							; �������� ��� ������
	call	Send_LCD_Symbol
	return
;===================================================================================================
Table_Zastavka_First_String
	mod_PCL	symbol_pointer
	dt		ZASTAVKA_FIRST_STRING,0
Table_Zastavka_Second_String 
	mod_PCL	symbol_pointer
	dt		ZASTAVKA_SECOND_STRING,0
;===================================================================================================
Num_of_Submenu_Table					
	retlw_num_of_submenu_punkts			; ������, ���������� ���������� ���������� �������� ������ ����
;===================================================================================================
Menu_Table
	goto_Punkt_Menu						; ������, ������� �������� �� ��� ������ ����							
;---------------------------------------------------------------------------------------------------
Submenu_Table
	goto_Punkt_Submenu					; ������, ������� �������� �� ��� ��������� ����
;---------------------------------------------------------------------------------------------------
Switch_Action							; �������� ��������, �� ������� ��������� ������ 
	goto_Punkt_Submenu_action			; ������, ������� �������� �� �������� ���� ���������� ����
;===================================================================================================
	Create_Menu_Names					; ������, ������� ����� ���� ������� ����
;===================================================================================================
	Create_Submenu_Names				; ������, ������� ����� ���� ���������� ����
;===================================================================================================
	include Menu_Actions.asm
;===================================================================================================
	end