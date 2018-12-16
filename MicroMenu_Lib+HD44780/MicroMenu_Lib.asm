	include	MicroMenu_Lib.h
	include	HD44780_Lib.h

MicroMenu_Lib_udata	udata_shr
index_menu		res	1					; Индекс текущего пункта меню
index_submenu	res	1					; Индекс текущего пункта подменю
num_of_submenu	res	1					; Количество пунктов в текущем меню
symbol_pointer	res	1					; Указатель на выводимый символ
menu_counter	res	1					; Счетчик опросов кнопок в меню
temp_1			res	1
temp_2			res	1
temp_3			res	1

	extern	flags,offset

	if	USE_SHORT_MOD_PCL				; Если используется "укороченная" версия макроса модификации PCL
	extern	known_zero
	endif

	global	Menu_heandler,Zastavka
	extern	Send_LCD_Symbol,Send_LCD_Command,Delay_4ms,Main
;===================================================================================================
MicroMenu		code					; Сегмент кода библиотеки меню
;===================================================================================================
Table_Action_Complete 
	mod_PCL	symbol_pointer
 	dt		ACTION_COMPLETE_STRING,0

Table_Zastavka_First_String
	mod_PCL	symbol_pointer
	dt		ZASTAVKA_FIRST_STRING,0

Table_Zastavka_Second_String 
	mod_PCL	symbol_pointer
	dt		ZASTAVKA_SECOND_STRING,0
;===================================================================================================
Num_of_Submenu_Table					
	retlw_num_of_submenu_punkts			; Макрос, возвращает количество подпунктов текущего пункта меню
;===================================================================================================
Switch_Menu_Table						; Переходим на нужный пункт меню
	goto_Punkt_Menu						; Макрос, создает переходы на все пункты меню						
;---------------------------------------------------------------------------------------------------
Switch_Submenu_Table					; Переходим на нужный подпункт меню
	goto_Punkt_Submenu					; Макрос, создает переходы на все подпункты меню
;---------------------------------------------------------------------------------------------------
Switch_Action							; Выполним действие, на котором находится курсор 
	goto_Punkt_Submenu_action			; Макрос, создает переходы на действия всех подпунктов меню
;===================================================================================================
	Create_Menu_Names					; Макрос, создает имена всех пунктов меню
;===================================================================================================
	Create_Submenu_Names				; Макрос, создает имена всех подпунктов меню
;===================================================================================================
include	Menu_Action.asm
;===================================================================================================
CLR_Display_routine						; Подпрограмма очистки дисплея
	movlw   CLR_DISP
	call	Send_LCD_Command
	call	Delay_4ms					; Обязательная задержка после очистки дисплея !!!
	return
;===================================================================================================
Draw_Cursor_Routine						; Процедура рисования курсора. В w лежит адрес
	call	Send_LCD_Command
	movlw	'<'							; Нарисуем там курсор
	call	Send_LCD_Symbol
	return
;===================================================================================================
Second_String_routine					; Подпрограмма перевода указателя на 2-ю строку	
	if	USE_STATIC_CURSOR
	Draw_Cursor	LAST_SYMBOL_FIRST_LINE	; Нарисум курсор в конце 1-й строки
	endif
	movlw	SECOND_LINE					; Переводим указатель на 2-ю строку	
	call	Send_LCD_Command
	return								; И приступаем к отрисовке следующего пункта меню
;===================================================================================================
Switch_Menu_routine						; Подпрограмма вывода названия пункта меню на дисплей
	clrf	symbol_pointer
String_Menu
	call	Switch_Menu_Table
	andlw   0FFh
	btfsc   STATUS,Z
	return 
	call    Send_LCD_Symbol
	incf	symbol_pointer	
	goto    String_Menu
;---------------------------------------------------------------------------------------------------
Switch_Submenu_routine					; Подпрограмма вывода названия подпункта меню на дисплей
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
Menu_heandler							; Обработчик меню
	clrf	index_menu					; Была нажатая какая-то кнопка, очистим индекс пункта меню					
	if	USE_MOVING_CURSOR & !USE_TOP_LAST_CURSOR
	movlw	b'11110000'					; Сбросим признак нажатия для всех кнопок					
	andwf	flags						
	bsf		Press_UP					; И установим признак нажатия только для кнопки "ВВЕРХ"
	endif
;----------------------------------------------------------------------------------------------------------------------------
Switch_Menu								; Поместим курсор на нужный пункт меню							
	if	USE_MOVING_CURSOR & USE_TOP_LAST_CURSOR
	movfw	index_menu
	bnz		Check_1
	movlw	b'11110000'					; Сбросим признак нажатия для всех кнопок					
	andwf	flags	
	bsf		Press_UP					; И установим признак нажатия только для кнопки "ВВЕРХ"
	goto	Skip_Check_1
Check_1
	sublw	NUM_OF_MAIN_MENU_PUNKTS-1	; Сравниваем с количеством пунктов меню
	bnz		Skip_Check_1	
	movlw	b'11110000'					; Сбросим признак нажатия для всех кнопок					
	andwf	flags
	bsf		Press_DOWN					; И установим признак нажатия только для кнопки "ВНИЗ"
Skip_Check_1
	endif

	call	CLR_Display_routine			; Очистим дисплей перед самой перерисовкой пунктов меню, чтобы уменьшить моргание
	
	if	USE_MOVING_CURSOR
	btfss	Press_UP					; Чтобы двигать курсор, надо знать, какая кнопка была нажата
	goto	Pressing_DOWN				; Была нажата кнопка UP		
	call	Switch_Menu_routine			; Рисуем текущий пункт меню	
	Draw_Cursor	LAST_SYMBOL_FIRST_LINE	; Нарисум курсор в конце 1-й строчки
	call	Second_String_routine		; Указатель на 2 строку
	incf	index_menu					; Берем следующий пункт
	movfw	index_menu	
	sublw	NUM_OF_MAIN_MENU_PUNKTS		; Сравниваем с количеством пунктов меню
	bz		Correct_index_menu			
	call	Switch_Menu_routine			; Рисуем пункт меню под текущим 
	decf	index_menu					; Не забудем вернуть назад текущий пункт меню	
	goto	Skip_Correct_index_menu_3
Correct_index_menu						; Достигли последнего пункта меню, следующим отображаем 1 пункт
	clrf	index_menu
	call	Switch_Menu_routine
	movlw	NUM_OF_MAIN_MENU_PUNKTS-1
	movwf	index_menu	
	goto	Skip_Correct_index_menu_3
Pressing_DOWN							; Была нажата кнопка DOWN	
	decf	index_menu					; Берем предыдущий пункт меню
	btfsc	index_menu,.7				; Проверяем на "<0"	простой проверкой 7 бита, максимальное количество пунктов меню ограничено 64
	goto	Correct_index_menu_2
	call	Switch_Menu_routine			; Рисуем предыдущий пункт меню
	call	Second_String_routine		; Указатель на 2 строку
	incf	index_menu					; Вернем текущий пункт					
	movfw	index_menu	
	goto	Skip_Correct_index_menu_2
Correct_index_menu_2
	movlw	NUM_OF_MAIN_MENU_PUNKTS-1
	movwf	index_menu
	call	Switch_Menu_routine			; Рисуем предыдущий пункт меню
	call	Second_String_routine		; Указатель на 2 строку
	clrf	index_menu
Skip_Correct_index_menu_2
	call	Switch_Menu_routine			; Рисуем текущий пункт меню под предыдущим 
	Draw_Cursor	LAST_SYMBOL_SECOND_LINE	; Нарисум курсор в конце 2-й строчки
Skip_Correct_index_menu_3
	
	else
	call	Switch_Menu_routine			; Рисуем текущий пункт меню
	call	Second_String_routine		; Указатель на 2 строку
	incf	index_menu					; Берем следующий пункт
	movfw	index_menu	
	sublw	NUM_OF_MAIN_MENU_PUNKTS		; Сравниваем с количеством пунктов меню
	bz		Correct_index_menu			
	call	Switch_Menu_routine			; Рисуем пункт меню под текущим 
	decf	index_menu					; Не забудем вернуть назад текущий пункт меню	
	goto	Skip_Correct_index_menu
Correct_index_menu						; Достигли последнего пункта меню, следующим отображаем 1 пункт
	clrf	index_menu
	call	Switch_Menu_routine
	movlw	NUM_OF_MAIN_MENU_PUNKTS-1
	movwf	index_menu	
Skip_Correct_index_menu
	endif

	call	Debounce_Delay				; Процедура антидребезга, вызывается при первом входе в меню, при нажатии кнопок "Вверх", "Вниз", выходе из подпункта меню
	if	USE_RBIE
	movlw	b'11110000'					; Сбросим признак нажатия для всех кнопок					
	andwf	flags	
	bcf		INTCON,RBIF					; Сбросим флаг возможно вызваного прерывания от кнопок
	bsf		INTCON,RBIE					; И разрешим прерывания от кнопок
	endif

	movlw	EXIT_DELAY					; Заносим счетчик проходов опроса клавиш
	movwf	menu_counter
	clrf	temp_1
	clrf	temp_2
Loop_Menu								; Вычисляем нажатую клавишу
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
	decfsz	temp_1						; Ни одна клавиша не нажата						
	goto	Loop_Menu					; Цикл ожидания нажатия в главном меню	
	decfsz	temp_2	
	goto	Loop_Menu
	decfsz	menu_counter				; Декремент счетчика проходов опроса клавиш	
	goto	Loop_Menu
	goto	Zastavka					; Вышел таймаут нахождения в меню, выходим в заставку	
;-----------------------------------------------------------------
Cursor_UP_menu							; Была нажата клавиша "Вверх"
	if	USE_MOVING_CURSOR & !USE_RBIE
	movlw	b'11110000'					; Сбросим признак нажатия для всех кнопок					
	andwf	flags						
	bsf		Press_UP					; И установим признак нажатия только для кнопки "ВВЕРХ"
	endif

	decf	index_menu					; Берем предыдущий пункт меню
	btfss	index_menu,.7				; Проверяем на "<0"	простой проверкой 7 бита, максимальное количество пунктов меню ограничено 64
	goto	Switch_Menu
	movlw	NUM_OF_MAIN_MENU_PUNKTS-1	; Стало "<0", сделаем текущим последний пункт меню. Учитываем, что индекс пункта меню на 1 меньше его порядкового номера
	movwf	index_menu
	goto	Switch_Menu					; Отрисовываем новый текущий пункт меню
;-----------------------------------------------------------------
Cursor_DOWN_menu						; Была нажата клавиша "Вниз"
	if	USE_MOVING_CURSOR & !USE_RBIE
	movlw	b'11110000'					; Сбросим признак нажатия для всех кнопок					
	andwf	flags						
	bsf		Press_DOWN					; И установим признак нажатия только для кнопки "ВНИЗ"
	endif

	incf	index_menu					; Берем следущий пункт меню
	movfw	index_menu
	sublw	NUM_OF_MAIN_MENU_PUNKTS		; Достигли последнего ?
	btfsc	STATUS,Z
	clrf	index_menu					; Если да, делаем текущим первый пункт меню	
	goto	Switch_Menu					; Отрисовываем новый текущий пункт меню
;-----------------------------------------------------------------
EXIT_menu								; Была нажата клавиша "Выход"
	if	USE_RBIE
	movlw	b'11110000'					; Сбросим признак нажатия для всех кнопок					
	andwf	flags	
	bcf		INTCON,RBIF					; Сбросим флаг возможно вызваного прерывания
	bsf		INTCON,RBIE					; И разрешим прерывания от кнопок
	
	else
	call	Debounce_Delay	
	endif

	goto	Zastavka					; Выходим в заставку
;-----------------------------------------------------------------
ENTER_menu								; Была нажата клавиша "Вход", заходим в текущий пункт меню
	if	USE_MENU_ACTION		
	movfw	index_menu					; Берем текущий пункт меню
	movwf	temp_1						; Заносим в счетчик
	incf	temp_1						; Учитываем, что нумерация начинается с 0
	movlw	actions_menu_flags			; Берем флаги действий пунктов меню
	movwf	temp_2						; И заносим в переменную
Loop_1
	decfsz	temp_1
	goto	Rotate_action_menu_flags
	bc		Menu_Action					; Флаг действия текущего пункта меню выдавлен в бит переноса, анализируем его. Если у текущего пункта меню есть действие, выполняем его
	goto	End_Menu_Action
Rotate_action_menu_flags
	rrf		temp_2						; Перебор флагов действий всех пунктов меню
	goto	Loop_1	
End_Menu_Action
	endif

	call	Num_of_Submenu_Table		; Получаем количество подпунктов в этом пункте меню
	movwf	num_of_submenu				; 1 раз занесем в перемунную, чтобы каждый раз не вызывать эту процедуру	
	sublw	.0
	bz		Switch_Menu					; Если 0, сразу на выход без прорисовки чего либо
	clrf	index_submenu				; Очистим индекс пункта подменю	

	if	USE_MOVING_CURSOR	&	!USE_TOP_LAST_CURSOR
	movlw	b'11110000'					; Сбросим признак нажатия для всех кнопок					
	andwf	flags						
	bsf		Press_UP					; И установим признак нажатия только для кнопки "ВВЕРХ"
	endif
;-----------------------------------------------------------------
Switch_Submenu							; Поместим курсор на нужный подпункт нужного пункта
	if	USE_MOVING_CURSOR	&	USE_TOP_LAST_CURSOR
	movfw	index_submenu
	bnz		Check_2
	movlw	b'11110000'					; Сбросим признак нажатия для всех кнопок					
	andwf	flags	
	bsf		Press_UP					; И установим признак нажатия только для кнопки "ВВЕРХ"
	goto	Skip_Check_2
Check_2
	decf	num_of_submenu,w			; Получаем количество подпунктов в этом меню, учитываем, что индекс подпункта начинается с 0
	subwf	index_submenu,w				; Сравниваем с количеством подпунктов меню
	bnz		Skip_Check_2
	movlw	b'11110000'					; Сбросим признак нажатия для всех кнопок					
	andwf	flags
	bsf		Press_DOWN					; И установим признак нажатия только для кнопки "ВНИЗ"
Skip_Check_2
	endif

	call	CLR_Display_routine			; Очистим дисплей перед самой перерисовкой подпунктов меню, чтобы уменьшить моргание

	if	USE_MOVING_CURSOR
	btfss	Press_UP
	goto	Pressing_DOWN_2			
	call	Switch_Submenu_routine		; Рисуем текущий подпункт меню
	movfw	num_of_submenu				; Получаем количество подпунктов в этом меню
	sublw	.1
	bz		Skip_Correct_index_submenu_3; Если 1, пропускаем прорисовку 2-й строки
	Draw_Cursor	LAST_SYMBOL_FIRST_LINE	; Нарисум курсор в конце 1-й строчки
	call	Second_String_routine		; Указатель на 2 строку
	incf	index_submenu				; Берем следующий пункт
	movfw	num_of_submenu				; Получаем количество подпунктов в этом меню
	subwf	index_submenu,w				; Сравниваем с количеством подпунктов меню
	bz		Correct_index_submenu
	call	Switch_Submenu_routine		; Рисуем подпункт меню под текущим 
	decf	index_submenu				; Не забудем вернуть назад текущий пункт меню	
	goto	Skip_Correct_index_submenu_3
Correct_index_submenu					; Достигли последнего подпункта меню, следующим отображаем 1 подпункт
	clrf	index_submenu
	call	Switch_Submenu_routine
	movfw	num_of_submenu				; Получаем количество подпунктов в этом меню
	movwf	index_submenu
	decf	index_submenu				; Учитываем, что индекс подпункта начинается с 0	
	goto	Skip_Correct_index_submenu_3

Pressing_DOWN_2
	decf	index_submenu				; Берем предыдущий пункт меню
	btfsc	index_submenu,.7			; Проверяем на "<0"	простой проверкой 7 бита, максимальное количество пунктов меню ограничено 64
	goto	Correct_index_submenu_2
	call	Switch_Submenu_routine		; Рисуем предыдущий пункт меню
	call	Second_String_routine		; Указатель на 2 строку
	incf	index_submenu				; Вернем текущий пункт					
	movfw	index_submenu	
	goto	Skip_Correct_index_submenu_2
Correct_index_submenu_2
	movfw	num_of_submenu				; Стало "<0", возвращаем количество пунктов в даном подменю	
	movwf	index_submenu				; Сделаем текущим последний пункт подменю
	decf	index_submenu				; Учитываем, что индекс пункта подменю на 1 меньше его порядкового номера
	call	Switch_Submenu_routine		; Рисуем предыдущий пункт меню
	call	Second_String_routine		; Указатель на 2 строку
	clrf	index_submenu
Skip_Correct_index_submenu_2
	call	Switch_Submenu_routine		; Рисуем текущий пункт меню под предыдущим 
	Draw_Cursor	LAST_SYMBOL_SECOND_LINE	; Нарисум курсор в конце 2-й строчки
Skip_Correct_index_submenu_3

	else
	call	Switch_Submenu_routine		; Рисуем текущий подпункт меню

	movfw	num_of_submenu				; Получаем количество подпунктов в этом меню
	sublw	.1
	bz		Skip_Correct_index_submenu	; Если 1, пропускаем прорисовку 2-й строки
	call	Second_String_routine		; Указатель на 2 строку
	incf	index_submenu
	movfw	num_of_submenu	
	subwf	index_submenu,w				; Сравниваем с количеством подпунктов меню
	bz		Correct_index_submenu
	call	Switch_Submenu_routine		; Рисуем подпункт меню под текущим 
	decf	index_submenu				; Не забудем вернуть назад текущий подпункт меню
	goto	Skip_Correct_index_submenu	
Correct_index_submenu					; Достигли последнего подпункта меню, следующим отображаем 1 подпункт
	clrf	index_submenu	
	call	Switch_Submenu_routine
	movfw	num_of_submenu
	movwf	index_submenu	
	decf	index_submenu				; Учитываем, что индекс подпункта начинается с 0
Skip_Correct_index_submenu
	endif

	call	Debounce_Delay				; Процедура антидребезга, вызывается при первом входе в подпункт меню, при нажатии кнопок "Вверх", "Вниз", выходе из действия подпункта меню
	if	USE_RBIE
	movlw	b'11110000'					; Сбросим признак нажатия для всех кнопок					
	andwf	flags	
	bcf		INTCON,RBIF					; Сбросим флаг возможно вызваного прерывания
	bsf		INTCON,RBIE					; И разрешим прерывания от кнопок
	endif

	movlw	EXIT_DELAY					; Заносим счетчик проходов опроса клавиш
	movwf	menu_counter
	clrf	temp_1
	clrf	temp_2
Loop_Submenu							; Мы зашли в пункт меню, ждем нажатия следующей кнопки
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
	decfsz	temp_1						; Ни одна клавиша не нажата	
	goto	Loop_Submenu				; Цикл ожидания нажатия в пункте меню
	decfsz	temp_2	
	goto	Loop_Submenu
	decfsz	menu_counter				; Декремент счетчика проходов опроса клавиш		
	goto	Loop_Submenu
	goto	Switch_Menu					; Вышел таймаут нахождения в подменю, выходим в предыдущий пункт меню
;-----------------------------------------------------------------
Cursor_UP_submenu						; Была нажата клавиша "Вверх"
	if	USE_MOVING_CURSOR & !USE_RBIE
	movlw	b'11110000'					; Сбросим признак нажатия для всех кнопок					
	andwf	flags						
	bsf		Press_UP					; И установим признак нажатия только для кнопки "ВВЕРХ"
	endif

	decf	index_submenu				; Берем предыдущий пункт подменю
	btfss	index_submenu,.7			; Проверяем на "<0"	простой проверкой 7 бита, максимальное количество подпунктов меню ограничено 64
	goto	Switch_Submenu	
	movfw	num_of_submenu				; Стало "<0", возвращаем количество пунктов в даном подменю	
	movwf	index_submenu				; Сделаем текущим последний пункт подменю
	decf	index_submenu				; Учитываем, что индекс пункта подменю на 1 меньше его порядкового номера
	goto	Switch_Submenu				; Отрисовываем новый текущий подпункт меню	
;-----------------------------------------------------------------
Cursor_DOWN_submenu						; Была нажата клавиша "Вниз"
	if	USE_MOVING_CURSOR & !USE_RBIE
	movlw	b'11110000'					; Сбросим признак нажатия для всех кнопок					
	andwf	flags						
	bsf		Press_DOWN					; И установим признак нажатия только для кнопки "ВНИЗ"
	endif

	incf	index_submenu				; Берем следущий пункт подменю
	movfw	num_of_submenu				; Возвращаем количество пунктов в даном подменю	
	subwf	index_submenu,w				; Достигли последнего ?	
	btfsc	STATUS,Z
	clrf	index_submenu				; Если да, делаем текущим первый подпункт меню		
	goto	Switch_Submenu				; Отрисовываем новый текущий подпункт меню
;-----------------------------------------------------------------	
EXIT_submenu							; Была нажата клавиша "Выход"
	clrf	index_submenu				; Обнуляем индекс пункта подменю, чтобы при следующем заходе в любой пункт меню курсор находился на 1 пункте подменю			
	goto	Switch_Menu					; Выходим в меню
;-----------------------------------------------------------------
ENTER_submenu							; Была нажата клавиша "Вход"
	call	CLR_Display_routine			; Очистим дисплей
	goto	Switch_Action				; Делаем действие текущего подпункта меню
End_Action
;-----------------------------------------------------------------
	clrf	symbol_pointer				; Рисуем подтверждение действия
String_Action_Complete
	call	Table_Action_Complete	
	andlw   0FFh
	btfsc   STATUS,Z
	goto    Out_Action_Complete
	call    Send_LCD_Symbol
	incf	symbol_pointer	
	goto    String_Action_Complete
Out_Action_Complete
	clrf	temp_3						; Задержка, чтобы успеть прочесть уведомление о выполнении действи
	call	Debounce_Delay
	decfsz	temp_3
	goto	$-2
;-----------------------------------------------------------------
	goto	Switch_Submenu				; И идем отрисовывать подпункт меню, курсор на том же подпункте, что и был
;===================================================================================================
Zastavka
	call	CLR_Display_routine			; Очистим дисплей
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
Debounce_Delay							; Подпрограмма антидребезговой задержки
	movlw	.3							; Количество проходов подбирается экспериментальным путем
	movwf	temp_2
	clrf	temp_1
Loop_Delay
	movfw	PORTB						
	iorlw	b'00001111'					; Установим незначущие разряды
	addlw	.1
	btfss	STATUS,Z
	goto	Loop_Delay					; Если хоть одна кнопка нажата, просто зациклимся
	decfsz	temp_1	
	goto	$-1
	decfsz	temp_2	
	goto	Loop_Delay
	return
;===================================================================================================
	end