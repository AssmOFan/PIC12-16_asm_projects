	include	MicroMenu_Lib.h
	include	HD44780_Lib.h

MicroMenu_Lib_udata	udata_shr
index_menu		res	1
index_submenu	res	1
symbol_pointer	res	1
menu_counter	res	1
temp_1			res	1
temp_2			res	1
temp_3			res	1

extern	flags,offset

	if	USE_SHORT_MOD_PCL
extern	known_zero
	endif

	global	Menu_heandler,Zastavka
	extern	Send_LCD_Symbol,Send_LCD_Command,Delay_4ms,Main
;===================================================================================================
MicroMenu		code					; ������� ���� ���������� ����
;===================================================================================================
Table_Action_Complete 
	mod_PCL	symbol_pointer
 	dt		"Action Complete!",0

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
Switch_Menu_Table						; ��������� �� ������ ����� ����
	goto_Punkt_Menu						; ������, ������� �������� �� ��� ������ ����. ������ GOTO ������ ��������� �� ������ 0x100							
;---------------------------------------------------------------------------------------------------
Switch_Submenu_Table					; ��������� �� ������ �������� ����
	goto_Punkt_Submenu					; ������, ������� �������� �� ��� ��������� ����
;---------------------------------------------------------------------------------------------------
Switch_Action							; �������� ��������, �� ������� ��������� ������ 
	goto_Punkt_Submenu_action			; ������, ������� �������� �� �������� ���� ���������� ����
;===================================================================================================
	Create_Menu_Names					; ������, ������� ����� ���� ������� ����
;===================================================================================================
	Create_Submenu_Names				; ������, ������� ����� ���� ���������� ����
;===================================================================================================
Menu_1_Submenu_1_action					; ��������� �������� 1 ��������� 1 ������
;	nop
	goto	End_Action
Menu_1_Submenu_2_action					; ��������� �������� 2 ��������� 1 ������
;	nop
	goto	End_Action
Menu_1_Submenu_3_action					; ��������� �������� 3 ��������� 1 ������
;	nop
	goto	End_Action
;---------------------------------------------------------------------------------------------------
Menu_2_Submenu_1_action					; ��������� �������� 1 ��������� 2 ������
;	nop
	goto	End_Action
Menu_2_Submenu_2_action					; ��������� �������� 2 ��������� 2 ������
;	nop
	goto	End_Action
Menu_2_Submenu_3_action					; ��������� �������� 3 ��������� 2 ������
;	nop
	goto	End_Action
;---------------------------------------------------------------------------------------------------
Menu_3_Submenu_1_action					; ��������� �������� 1 ��������� 3 ������
;	nop
	goto	End_Action
Menu_3_Submenu_2_action					; ��������� �������� 2 ��������� 3 ������
;	nop
	goto	End_Action
Menu_3_Submenu_3_action					; ��������� �������� 3 ��������� 3 ������
;	nop
	goto	End_Action
;---------------------------------------------------------------------------------------------------
Menu_4_Submenu_1_action					; ��������� �������� 1 ��������� 4 ������
;	nop
	goto	End_Action
Menu_4_Submenu_2_action					; ��������� �������� 2 ��������� 4 ������
;	nop
	goto	End_Action
Menu_4_Submenu_3_action					; ��������� �������� 3 ��������� 4 ������
;	nop
	goto	End_Action								
;---------------------------------------------------------------------------------------------------
Menu_5_Submenu_1_action					; ��������� �������� 1 ��������� 5 ������
;	nop
	goto	End_Action
Menu_5_Submenu_2_action					; ��������� �������� 2 ��������� 5 ������
;	nop
	goto	End_Action
Menu_5_Submenu_3_action					; ��������� �������� 3 ��������� 5 ������
;	nop
	goto	End_Action			
;===================================================================================================
CLR_Display_routine						; ������������ ������� �������
	movlw   CLR_DISP
	call	Send_LCD_Command
	call	Delay_4ms					; ������������ �������� ����� ������� ������� !!!
	return
;===================================================================================================
Second_String_routine					; ������������ �������� ��������� �� 2-� ������	
if	USE_CURSOR
	movlw	b'10001111'					; ��������� ������ �� ��������� ������ 1-� ������
	call	Send_LCD_Command
	movlw	'<'							; � �������� ��� ��������� �������� ������ ����
	call	Send_LCD_Symbol
endif
	movlw	SECOND_LINE					; ��������� ��������� �� 2-� ������	
	call	Send_LCD_Command
	return								; � ���������� � ��������� ���������� ������ ����
;===================================================================================================
Switch_Menu_routine						; ������������ ������ �������� ������ ���� �� �������
	clrf	symbol_pointer
String_Menu
	call	Switch_Menu_Table
	andlw   0FFh
	btfsc   STATUS,Z
	return 
	call    Send_LCD_Symbol
	incf	symbol_pointer	
	goto    String_Menu
;----------------------------------------------------------------------------------------------------------------------------
Switch_Submenu_routine					; ������������ ������ �������� ��������� ���� �� �������
	clrf	symbol_pointer
String_Submenu
	call	Switch_Submenu_Table
	andlw   0FFh
	btfsc   STATUS,Z
	return 
	call    Send_LCD_Symbol
	incf	symbol_pointer	
	goto    String_Submenu
;===================================================================================================
Menu_heandler							; ���������� ����
	clrf	index_menu					; ���� ������� �����-�� ������, ������� ������ ������ ����					

if	USE_MOVING_CURSOR	&	!USE_TOP_LAST_CURSOR
	movlw	b'11110000'					; ������� ������� ������� ��� ���� ������					
	andwf	flags						
	bsf		Press_UP					; � ��������� ������� ������� ������ ��� ������ "�����"
endif

Switch_Menu								; �������� ������ �� ������ ����� ����							

if	USE_MOVING_CURSOR	&	USE_TOP_LAST_CURSOR
	movfw	index_menu
	btfss	STATUS,Z
	goto	Check_1		
	movlw	b'11110000'					; ������� ������� ������� ��� ���� ������					
	andwf	flags	
	bsf		Press_UP					; � ��������� ������� ������� ������ ��� ������ "�����"
	goto	Skip_Check_1
Check_1
	sublw	NUM_OF_MAIN_MENU_PUNKTS-1	; ���������� � ����������� ������� ����
	btfss	STATUS,Z	
	goto	Skip_Check_1	
	movlw	b'11110000'					; ������� ������� ������� ��� ���� ������					
	andwf	flags
	bsf		Press_DOWN					; � ��������� ������� ������� ������ ��� ������ "����"
Skip_Check_1
endif

	call	CLR_Display_routine			; ������� ������� ����� ����� ������������ ������� ����, ����� ��������� ��������

if	USE_MOVING_CURSOR
	btfss	Press_UP
	goto	Pressing_DOWN			
	call	Switch_Menu_routine			; ������ ������� ����� ����	
	movlw	b'10001111'					; ��������� ������ �� ��������� ������ 1-� ������	
	call	Send_LCD_Command
	movlw	'<'							; � �������� ��� ��������� �������� ������ ����
	call	Send_LCD_Symbol
	call	Second_String_routine		; ��������� �� 2 ������
	incf	index_menu					; ����� ��������� �����
	movfw	index_menu	
	sublw	NUM_OF_MAIN_MENU_PUNKTS		; ���������� � ����������� ������� ����
	btfsc	STATUS,Z
	goto	Correct_index_menu			
	call	Switch_Menu_routine			; ������ ����� ���� ��� ������� 
	decf	index_menu					; �� ������� ������� ����� ������� ����� ����	
	goto	Skip_Correct_index_menu_3
Correct_index_menu						; �������� ���������� ������ ����, ��������� ���������� 1 �����
	clrf	index_menu
	call	Switch_Menu_routine
	movlw	NUM_OF_MAIN_MENU_PUNKTS-1
	movwf	index_menu	
	goto	Skip_Correct_index_menu_3

Pressing_DOWN
	decf	index_menu					; ����� ���������� ����� ����
	btfsc	index_menu,.7				; ��������� �� "<0"	������� ��������� 7 ����, ������������ ���������� ������� ���� ���������� 64
	goto	Correct_index_menu_2
	call	Switch_Menu_routine			; ������ ���������� ����� ����
	call	Second_String_routine		; ��������� �� 2 ������
	incf	index_menu					; ������ ������� �����					
	movfw	index_menu	
	goto	Skip_Correct_index_menu_2
Correct_index_menu_2
	movlw	NUM_OF_MAIN_MENU_PUNKTS-1
	movwf	index_menu
	call	Switch_Menu_routine			; ������ ���������� ����� ����
	call	Second_String_routine		; ��������� �� 2 ������
	clrf	index_menu
Skip_Correct_index_menu_2
	call	Switch_Menu_routine			; ������ ������� ����� ���� ��� ���������� 
	movlw	b'11001111'					; ��������� ������ �� ��������� ������ 2-� ������
	call	Send_LCD_Command
	movlw	'<'							; � �������� ��� ��������� �������� ������ ����
	call	Send_LCD_Symbol
Skip_Correct_index_menu_3

else
	call	Switch_Menu_routine			; ������ ������� ����� ����
	call	Second_String_routine		; ��������� �� 2 ������
	incf	index_menu					; ����� ��������� �����
	movfw	index_menu	
	sublw	NUM_OF_MAIN_MENU_PUNKTS		; ���������� � ����������� ������� ����
	btfsc	STATUS,Z
	goto	Correct_index_menu			
	call	Switch_Menu_routine			; ������ ����� ���� ��� ������� 
	decf	index_menu					; �� ������� ������� ����� ������� ����� ����	
	goto	Skip_Correct_index_menu
Correct_index_menu						; �������� ���������� ������ ����, ��������� ���������� 1 �����
	clrf	index_menu
	call	Switch_Menu_routine
	movlw	NUM_OF_MAIN_MENU_PUNKTS-1
	movwf	index_menu	
Skip_Correct_index_menu
endif

	call	Debounce_Delay				; ��������� ������������, ���������� ��� ������ ����� � ����, ��� ������� ������ "�����", "����", ������ �� ��������� ����

if	USE_RBIE
	movlw	b'11110000'					; ������� ������� ������� ��� ���� ������					
	andwf	flags	
	bcf		INTCON,RBIF					; ������� ���� �������� ��������� ����������
	bsf		INTCON,RBIE					; � �������� ���������� �� ������
endif

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

if	USE_MOVING_CURSOR	&	!USE_RBIE
	movlw	b'11110000'					; ������� ������� ������� ��� ���� ������					
	andwf	flags						
	bsf		Press_UP					; � ��������� ������� ������� ������ ��� ������ "�����"
endif

	decf	index_menu					; ����� ���������� ����� ����
	btfss	index_menu,.7				; ��������� �� "<0"	������� ��������� 7 ����, ������������ ���������� ������� ���� ���������� 64
	goto	Switch_Menu
	movlw	NUM_OF_MAIN_MENU_PUNKTS-1	; ����� "<0", ������� ������� ��������� ����� ����. ���������, ��� ������ ������ ���� �� 1 ������ ��� ����������� ������
	movwf	index_menu
	goto	Switch_Menu					; ������������ ����� ������� ����� ����
;-----------------------------------------------------------------
Cursor_DOWN_menu						; ���� ������ ������� "����"

if	USE_MOVING_CURSOR	&	!USE_RBIE
	movlw	b'11110000'					; ������� ������� ������� ��� ���� ������					
	andwf	flags						
	bsf		Press_DOWN					; � ��������� ������� ������� ������ ��� ������ "����"
endif

	incf	index_menu					; ����� �������� ����� ����
	movfw	index_menu
	sublw	NUM_OF_MAIN_MENU_PUNKTS		; �������� ���������� ?
	btfsc	STATUS,Z
	clrf	index_menu					; ���� ��, ������ ������� ������ ����� ����	
	goto	Switch_Menu					; ������������ ����� ������� ����� ����
;-----------------------------------------------------------------
EXIT_menu								; ���� ������ ������� "�����"

if	USE_RBIE
	movlw	b'11110000'					; ������� ������� ������� ��� ���� ������					
	andwf	flags	
	bcf		INTCON,RBIF					; ������� ���� �������� ��������� ����������
	bsf		INTCON,RBIE					; � �������� ���������� �� ������
else
	call	Debounce_Delay	
endif
	goto	Zastavka					; ������� � ��������
;-----------------------------------------------------------------
ENTER_menu								; ���� ������ ������� "����"
	clrf	index_submenu				; ������� ������ ������ �������	

if	USE_MOVING_CURSOR	&	!USE_TOP_LAST_CURSOR
	movlw	b'11110000'					; ������� ������� ������� ��� ���� ������					
	andwf	flags						
	bsf		Press_UP					; � ��������� ������� ������� ������ ��� ������ "�����"
endif

Switch_Submenu							; �������� ������ �� ������ �������� ������� ������

if	USE_MOVING_CURSOR	&	USE_TOP_LAST_CURSOR
	movfw	index_submenu
	btfss	STATUS,Z
	goto	Check_2		
	movlw	b'11110000'					; ������� ������� ������� ��� ���� ������					
	andwf	flags	
	bsf		Press_UP					; � ��������� ������� ������� ������ ��� ������ "�����"
	goto	Skip_Check_2
Check_2
	call	Num_of_Submenu_Table			
	movwf	temp_1	
	decf	temp_1,	w					; ���������, ��� ������ ��������� ���������� � 0
	subwf	index_submenu,w				; ���������� � ����������� ���������� ����
	btfss	STATUS,Z	
	goto	Skip_Check_2	
	movlw	b'11110000'					; ������� ������� ������� ��� ���� ������					
	andwf	flags
	bsf		Press_DOWN					; � ��������� ������� ������� ������ ��� ������ "����"
Skip_Check_2
endif

	call	CLR_Display_routine			; ������� ������� ����� ����� ������������ ���������� ����, ����� ��������� ��������

if	USE_MOVING_CURSOR
	btfss	Press_UP
	goto	Pressing_DOWN_2			
	call	Switch_Submenu_routine		; ������ ������� �������� ����	
	movlw	b'10001111'					; ��������� ������ �� ��������� ������ 1-� ������	
	call	Send_LCD_Command
	movlw	'<'							; � �������� ��� ��������� �������� ������ ����
	call	Send_LCD_Symbol
	call	Second_String_routine		; ��������� �� 2 ������
	incf	index_submenu				; ����� ��������� �����
	call	Num_of_Submenu_Table			
	subwf	index_submenu,w				; ���������� � ����������� ���������� ����
	btfsc	STATUS,Z
	goto	Correct_index_submenu			
	call	Switch_Submenu_routine		; ������ �������� ���� ��� ������� 
	decf	index_submenu				; �� ������� ������� ����� ������� ����� ����	
	goto	Skip_Correct_index_submenu_3
Correct_index_submenu					; �������� ���������� ��������� ����, ��������� ���������� 1 ��������
	clrf	index_submenu
	call	Switch_Submenu_routine
	call	Num_of_Submenu_Table
	movwf	index_submenu
	decf	index_submenu				; ���������, ��� ������ ��������� ���������� � 0	
	goto	Skip_Correct_index_submenu_3

Pressing_DOWN_2
	decf	index_submenu				; ����� ���������� ����� ����
	btfsc	index_submenu,.7			; ��������� �� "<0"	������� ��������� 7 ����, ������������ ���������� ������� ���� ���������� 64
	goto	Correct_index_submenu_2
	call	Switch_Submenu_routine		; ������ ���������� ����� ����
	call	Second_String_routine		; ��������� �� 2 ������
	incf	index_submenu				; ������ ������� �����					
	movfw	index_submenu	
	goto	Skip_Correct_index_submenu_2
Correct_index_submenu_2
	call	Num_of_Submenu_Table		; ����� "<0", ���������� ���������� ������� � ����� �������	
	movwf	index_submenu				; ������� ������� ��������� ����� �������
	decf	index_submenu				; ���������, ��� ������ ������ ������� �� 1 ������ ��� ����������� ������
	call	Switch_Submenu_routine		; ������ ���������� ����� ����
	call	Second_String_routine		; ��������� �� 2 ������
	clrf	index_submenu
Skip_Correct_index_submenu_2
	call	Switch_Submenu_routine		; ������ ������� ����� ���� ��� ���������� 
	movlw	b'11001111'					; ��������� ������ �� ��������� ������ 2-� ������
	call	Send_LCD_Command
	movlw	'<'							; � �������� ��� ��������� �������� ������ ����
	call	Send_LCD_Symbol
Skip_Correct_index_submenu_3

else
	call	Switch_Submenu_routine		; ������ ������� �������� ����	
	call	Second_String_routine		; ��������� �� 2 ������
	incf	index_submenu
	call	Num_of_Submenu_Table			
	subwf	index_submenu,w				; ���������� � ����������� ���������� ����
	btfsc	STATUS,Z
	goto	Correct_index_submenu
	call	Switch_Submenu_routine		; ������ �������� ���� ��� ������� 
	decf	index_submenu				; �� ������� ������� ����� ������� �������� ����
	goto	Skip_Correct_index_submenu	
Correct_index_submenu					; �������� ���������� ��������� ����, ��������� ���������� 1 ��������
	clrf	index_submenu	
	call	Switch_Submenu_routine
	call	Num_of_Submenu_Table
	movwf	index_submenu	
	decf	index_submenu				; ���������, ��� ������ ��������� ���������� � 0
Skip_Correct_index_submenu
endif

	call	Debounce_Delay				; ��������� ������������, ���������� ��� ������ ����� � �������� ����, ��� ������� ������ "�����", "����", ������ �� �������� ��������� ����

if	USE_RBIE
	movlw	b'11110000'					; ������� ������� ������� ��� ���� ������					
	andwf	flags	
	bcf		INTCON,RBIF					; ������� ���� �������� ��������� ����������
	bsf		INTCON,RBIE					; � �������� ���������� �� ������
endif

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
	goto	Switch_Menu					; ����� ������� ���������� � �������, ������� � ���������� ����� ����
;-----------------------------------------------------------------
Cursor_UP_submenu						; ���� ������ ������� "�����"

if	USE_MOVING_CURSOR	&	!USE_RBIE
	movlw	b'11110000'					; ������� ������� ������� ��� ���� ������					
	andwf	flags						
	bsf		Press_UP					; � ��������� ������� ������� ������ ��� ������ "�����"
endif

	decf	index_submenu				; ����� ���������� ����� �������
	btfss	index_submenu,.7			; ��������� �� "<0"	������� ��������� 7 ����, ������������ ���������� ������� ������� ���������� 64
	goto	Switch_Submenu	
	call	Num_of_Submenu_Table		; ����� "<0", ���������� ���������� ������� � ����� �������	
	movwf	index_submenu				; ������� ������� ��������� ����� �������
	decf	index_submenu				; ���������, ��� ������ ������ ������� �� 1 ������ ��� ����������� ������
	goto	Switch_Submenu				; ������������ ����� ������� �������� ����	
;-----------------------------------------------------------------
Cursor_DOWN_submenu						; ���� ������ ������� "����"

if	USE_MOVING_CURSOR	&	!USE_RBIE
	movlw	b'11110000'					; ������� ������� ������� ��� ���� ������					
	andwf	flags						
	bsf		Press_DOWN					; � ��������� ������� ������� ������ ��� ������ "����"
endif

	incf	index_submenu				; ����� �������� ����� �������
	call	Num_of_Submenu_Table		; ���������� ���������� ������� � ����� �������	
	subwf	index_submenu,w				; �������� ���������� ?	
	btfsc	STATUS,Z
	clrf	index_submenu				; ���� ��, ������ ������� ������ �������� ����		
	goto	Switch_Submenu				; ������������ ����� ������� �������� ����
;-----------------------------------------------------------------	
EXIT_submenu							; ���� ������ ������� "�����"
	clrf	index_submenu				; �������� ������ ������ �������, ����� ��� ��������� ������ � ����� ����� ���� ������ ��������� �� 1 ������ �������			
	goto	Switch_Menu					; ������� � ����
;-----------------------------------------------------------------
ENTER_submenu							; ���� ������ ������� "����"
	call	CLR_Display_routine			; ������� �������
	goto	Switch_Action				; ������ �������� �������� ��������� ����
End_Action
;-----------------------------------------------------------------
	clrf	symbol_pointer				; ������ ������������� ��������
String_Action_Complete
	call	Table_Action_Complete	
	andlw   0FFh
	btfsc   STATUS,Z
	goto    Out_Action_Complete
	call    Send_LCD_Symbol
	incf	symbol_pointer	
	goto    String_Action_Complete
Out_Action_Complete
	clrf	temp_3						; ��������, ����� ������ �������� ����������� � ���������� �������
	call	Debounce_Delay
	decfsz	temp_3
	goto	$-2
;-----------------------------------------------------------------
	goto	Switch_Submenu				; � ���� ������������ �������� ����, ������ �� ��� �� ���������, ��� � ���
;===================================================================================================
Zastavka
	call	CLR_Display_routine			; ������� �������
	clrf	symbol_pointer
First_String
	call	Table_Zastavka_First_String	
	andlw   0FFh
	btfsc   STATUS,Z
	goto    Out_First_String
	call    Send_LCD_Symbol
	incf	symbol_pointer	
	goto    First_String
Out_First_String
	movlw	SECOND_LINE	
	call	Send_LCD_Command
	clrf	symbol_pointer
Next_String
	call	Table_Zastavka_Second_String
	andlw   0FFh
	btfsc   STATUS,Z
	goto    Out_Next_String
	call    Send_LCD_Symbol
	incf	symbol_pointer	
	goto    Next_String
Out_Next_String
	goto	Main	
;===================================================================================================
Debounce_Delay							; ������������ ��������������� ��������
	movlw	.3							; ���������� �������� ����������� ����������������� �����
	movwf	temp_2
	clrf	temp_1
Loop_Delay
	movfw	PORTB						
	iorlw	b'00001111'					; ��������� ���������� �������
	addlw	.1
	btfss	STATUS,Z
	goto	Loop_Delay					; ���� ���� ���� ������ ������, ������ ����������
	decfsz	temp_1	
	goto	$-1
	decfsz	temp_2	
	goto	Loop_Delay
	return
;===================================================================================================
	end