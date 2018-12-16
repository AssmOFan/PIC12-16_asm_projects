if	USE_MENU_ACTION
Menu_Action
	goto_Menu_action
;===================================================================================================
Menu_1_action							; Выполняем действие 1 пункта меню
	call	CLR_Display_routine			; Очистим дисплей
	Print_LCD_String_macro	Table_Action_Complete
	clrf	temp_3						; Задержка, чтобы успеть прочесть уведомление о выполнении действи
	call	Debounce_Delay
	decfsz	temp_3
	goto	$-2
	goto	End_Menu_Action
Menu_2_action							; Выполняем действие 2 пункта меню
;	nop
	goto	End_Menu_Action
Menu_3_action							; Выполняем действие 3 пункта меню
;	nop
	goto	End_Menu_Action
Menu_4_action							; Выполняем действие 4 пункта меню
;	nop
	goto	End_Menu_Action
Menu_5_action							; Выполняем действие 5 пункта меню
;	nop
	goto	End_Menu_Action
Menu_6_action							; Выполняем действие 3 пункта меню
;	nop
	goto	End_Menu_Action
Menu_7_action							; Выполняем действие 4 пункта меню
;	nop
	goto	End_Menu_Action
Menu_8_action							; Выполняем действие 5 пункта меню
;	nop
	goto	End_Menu_Action
endif
;===================================================================================================
Menu_1_Submenu_1_action					; Выполняем действие 1 подпункта 1 пункта
;	nop
	goto	End_Action
Menu_1_Submenu_2_action					; Выполняем действие 2 подпункта 1 пункта
;	nop
	goto	End_Action
Menu_1_Submenu_3_action					; Выполняем действие 3 подпункта 1 пункта
;	nop
	goto	End_Action
;---------------------------------------------------------------------------------------------------
Menu_2_Submenu_1_action					; Выполняем действие 1 подпункта 2 пункта
;	nop
	goto	End_Action
Menu_2_Submenu_2_action					; Выполняем действие 2 подпункта 2 пункта
;	nop
	goto	End_Action
Menu_2_Submenu_3_action					; Выполняем действие 3 подпункта 2 пункта
;	nop
	goto	End_Action
;---------------------------------------------------------------------------------------------------
Menu_3_Submenu_1_action					; Выполняем действие 1 подпункта 3 пункта
;	nop
	goto	End_Action
Menu_3_Submenu_2_action					; Выполняем действие 2 подпункта 3 пункта
;	nop
	goto	End_Action
Menu_3_Submenu_3_action					; Выполняем действие 3 подпункта 3 пункта
;	nop
	goto	End_Action
;---------------------------------------------------------------------------------------------------
Menu_4_Submenu_1_action					; Выполняем действие 1 подпункта 4 пункта
;	nop
	goto	End_Action
Menu_4_Submenu_2_action					; Выполняем действие 2 подпункта 4 пункта
;	nop
	goto	End_Action
Menu_4_Submenu_3_action					; Выполняем действие 3 подпункта 4 пункта
;	nop
	goto	End_Action								
;---------------------------------------------------------------------------------------------------
Menu_5_Submenu_1_action					; Выполняем действие 1 подпункта 5 пункта
;	nop
	goto	End_Action
Menu_5_Submenu_2_action					; Выполняем действие 2 подпункта 5 пункта
;	nop
	goto	End_Action
Menu_5_Submenu_3_action					; Выполняем действие 3 подпункта 5 пункта
;	nop
	goto	End_Action
Menu_5_Submenu_4_action					; Выполняем действие 4 подпункта 5 пункта
;	nop
	goto	End_Action
;---------------------------------------------------------------------------------------------------
Menu_6_Submenu_1_action					; Выполняем действие 1 подпункта 5 пункта
;	nop
	goto	End_Action
Menu_6_Submenu_2_action					; Выполняем действие 2 подпункта 5 пункта
;	nop
	goto	End_Action
Menu_6_Submenu_3_action					; Выполняем действие 2 подпункта 5 пункта
;	nop
	goto	End_Action
Menu_6_Submenu_4_action					; Выполняем действие 2 подпункта 5 пункта
;	nop
	goto	End_Action