if	USE_MENU_ACTION
Menu_Action
	goto_Menu_action
;===================================================================================================
Menu_1_action							; ��������� �������� 1 ������ ����
	call	CLR_Display_routine			; ������� �������
	Print_LCD_String_macro	Table_Action_Complete
	clrf	temp_3						; ��������, ����� ������ �������� ����������� � ���������� �������
	call	Debounce_Delay
	decfsz	temp_3
	goto	$-2
	goto	End_Menu_Action
Menu_2_action							; ��������� �������� 2 ������ ����
;	nop
	goto	End_Menu_Action
Menu_3_action							; ��������� �������� 3 ������ ����
;	nop
	goto	End_Menu_Action
Menu_4_action							; ��������� �������� 4 ������ ����
;	nop
	goto	End_Menu_Action
Menu_5_action							; ��������� �������� 5 ������ ����
;	nop
	goto	End_Menu_Action
Menu_6_action							; ��������� �������� 3 ������ ����
;	nop
	goto	End_Menu_Action
Menu_7_action							; ��������� �������� 4 ������ ����
;	nop
	goto	End_Menu_Action
Menu_8_action							; ��������� �������� 5 ������ ����
;	nop
	goto	End_Menu_Action
endif
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
Menu_5_Submenu_4_action					; ��������� �������� 4 ��������� 5 ������
;	nop
	goto	End_Action
;---------------------------------------------------------------------------------------------------
Menu_6_Submenu_1_action					; ��������� �������� 1 ��������� 5 ������
;	nop
	goto	End_Action
Menu_6_Submenu_2_action					; ��������� �������� 2 ��������� 5 ������
;	nop
	goto	End_Action
Menu_6_Submenu_3_action					; ��������� �������� 2 ��������� 5 ������
;	nop
	goto	End_Action
Menu_6_Submenu_4_action					; ��������� �������� 2 ��������� 5 ������
;	nop
	goto	End_Action