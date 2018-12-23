	include	MicroMenu_Lib.h
	include	HD44780_Lib.h

MicroMenu_Lib_udata	udata_shr
index_menu		res	1
index_submenu	res	1
num_of_submenu	res	1					; Количество пунктов в текущем меню
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
MicroMenu		code					; Сегмент кода библиотеки меню
;===================================================================================================
Table_Action_Complete 
	mod_PCL	symbol_pointer
 	dt		"Action Complete!",0
;===================================================================================================
Menu_heandler							; Обработчик меню
;===================================================================================================
	clrf	index_menu					; Была нажатая какая-то кнопка, очистим индекс пункта меню					

	if	USE_MOVING_CURSOR & !USE_TOP_LAST_CURSOR
	clrf	buttons						; Очистим флаги нажатых кнопок					
	bsf		Press_UP					; И установим признак нажатия только для кнопки "ВВЕРХ"
	endif
;----------------------------------------------------------------------------------------------------------------------------
Draw_Menu								; Отрисовка пунктов меню							
	if	USE_MOVING_CURSOR & USE_TOP_LAST_CURSOR
	movfw	index_menu
	bnz		Check_1						; Если первый пункт меню		
	clrf	buttons						; Очистим флаги нажатых кнопок
	bsf		Press_UP					; И установим признак нажатия только для кнопки "ВВЕРХ"
	goto	Skip_Check_1
Check_1
	sublw	NUM_OF_MAIN_MENU_PUNKTS-1	; Сравниваем с количеством пунктов меню
	bnz		Skip_Check_1				; Если последний пункт меню	
	clrf	buttons						; Очистим флаги нажатых кнопок
	bsf		Press_DOWN					; И установим признак нажатия только для кнопки "ВНИЗ"
Skip_Check_1
	endif

	call	CLR_Display_routine			; Очистим дисплей перед самой перерисовкой пунктов меню, чтобы уменьшить моргание

	if	USE_MOVING_CURSOR
	btfss	Press_UP					; Если была нажата кнопка вверх
	goto	Pressing_DOWN			
	call	Draw_Menu_routine			; Рисуем ТЕКУЩИЙ пункт меню
	Draw_Cursor	LAST_SYMBOL_FIRST_LINE	; Нарисум курсор в конце 1-й строчки
	call	Second_String_routine		; Указатель на 2 строку
	incf	index_menu					; Берем следующий пункт меню
	movfw	index_menu
	sublw	NUM_OF_MAIN_MENU_PUNKTS		; Сравниваем с количеством пунктов меню
	bz		Correct_index_menu				
	call	Draw_Menu_routine			; Рисуем СЛЕДУЮЩИЙ пункт меню под текущим
	decf	index_menu					; Вернем текущий индекс меню
	goto	Skip_Correct_index_menu_3
Correct_index_menu						; Достигли последнего пункта меню, следующим отображаем 1 пункт
	clrf	index_menu
	call	Draw_Menu_routine
	movlw	NUM_OF_MAIN_MENU_PUNKTS-1
	movwf	index_menu
	goto	Skip_Correct_index_menu_3
Pressing_DOWN							; Если была нажата кнопка вниз							
	decf	index_menu					; Берем предыдущий пункт меню
	btfsc	index_menu,.7				; Проверяем на "<0"	простой проверкой 7 бита, максимальное количество пунктов меню ограничено 64
	goto	Correct_index_menu_2
	call	Draw_Menu_routine			; Рисуем предыдущий пункт меню
	call	Second_String_routine		; Указатель на 2 строку
	incf	index_menu					; Вернем текущий индекс меню				
	goto	Skip_Correct_index_menu_2
Correct_index_menu_2
	movlw	NUM_OF_MAIN_MENU_PUNKTS-1
	movwf	index_menu
	call	Draw_Menu_routine			; Рисуем ПРЕДЫДУЩИЙ пункт меню над текущим
	call	Second_String_routine		; Указатель на 2 строку
	clrf	index_menu
Skip_Correct_index_menu_2
	call	Draw_Menu_routine			; Рисуем ТЕКУЩИЙ пункт меню под предыдущим
	Draw_Cursor	LAST_SYMBOL_SECOND_LINE
Skip_Correct_index_menu_3

	else
	call	Draw_Menu_routine			; Рисуем ТЕКУЩИЙ пункт меню
	call	Second_String_routine		; Указатель на 2 строку
	incf	index_menu					; Берем следующий пункт меню
	movfw	index_menu
	sublw	NUM_OF_MAIN_MENU_PUNKTS		; Сравниваем с количеством пунктов меню
	bz		Correct_index_menu		
	call	Draw_Menu_routine			; Рисуем СЛЕДУЮЩИЙ пункт меню под текущим 
	decf	index_menu					; Вернем текущий индекс меню	
	goto	Skip_Correct_index_menu
Correct_index_menu						; Достигли последнего пункта меню, следующим отображаем 1 пункт
	clrf	index_menu
	call	Draw_Menu_routine
	movlw	NUM_OF_MAIN_MENU_PUNKTS-1
	movwf	index_menu					; Вернем текущий индекс меню	
Skip_Correct_index_menu
	endif

	call	Debounce_Delay				; Процедура антидребезга, вызывается при первом входе в меню, при нажатии кнопок "Вверх", "Вниз", выходе из подпункта меню
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
	if	USE_MOVING_CURSOR & !USE_RBIE	; При использовании прерываний этот флаг и так выставляется в обработчике
	clrf	buttons						; Очистим флаги нажатых кнопок					
	bsf		Press_UP					; И установим признак нажатия только для кнопки "ВВЕРХ"
	endif

	decf	index_menu					; Берем предыдущий пункт меню
	btfss	index_menu,.7				; Проверяем на "<0"	простой проверкой 7 бита, максимальное количество пунктов меню ограничено 64
	goto	Draw_Menu
	movlw	NUM_OF_MAIN_MENU_PUNKTS-1	; Стало "<0", сделаем текущим последний пункт меню. Учитываем, что индекс пункта меню на 1 меньше его порядкового номера
	movwf	index_menu
	goto	Draw_Menu					; Отрисовываем новый текущий пункт меню
;-----------------------------------------------------------------
Cursor_DOWN_menu						; Была нажата клавиша "Вниз"
	if	USE_MOVING_CURSOR & !USE_RBIE	; При использовании прерываний этот флаг и так выставляется в обработчике
	clrf	buttons						; Очистим флаги нажатых кнопок					
	bsf		Press_DOWN					; И установим признак нажатия только для кнопки "ВНИЗ"
	endif

	incf	index_menu					; Берем следущий пункт меню
	movfw	index_menu
	sublw	NUM_OF_MAIN_MENU_PUNKTS		; Достигли последнего ?
	btfsc	STATUS,Z
	clrf	index_menu					; Если да, делаем текущим первый пункт меню	
	goto	Draw_Menu					; Отрисовываем новый текущий пункт меню
;-----------------------------------------------------------------
EXIT_menu								; Была нажата клавиша "Выход"
	call	Debounce_Delay	
	goto	Zastavka					; Выходим в заставку
;===================================================================================================
ENTER_menu								; Была нажата клавиша "Вход", осуществлям вход в меню и отрисовку подпунктов
;===================================================================================================
	if	USE_MENU_ACTION		
	incf	index_menu,w				; Берем текущий пункт меню (учитываем, что нумерация начинается с 0)
	movwf	temp_1						; Заносим в счетчик
	movlw	actions_menu_flags			; Берем флаги действий пунктов меню
	movwf	temp_2						; И заносим в переменную
Loop_1
	decfsz	temp_1
	goto	Rotate_action_menu_flags
	bc		Menu_Action					; Флаг действия текущего пункта меню выдавлен в бит переноса, анализируем его
	goto	End_Menu_Action
Rotate_action_menu_flags
	rrf		temp_2						; Перебор флагов действий всех пунктов меню
	goto	Loop_1	
End_Menu_Action
	endif

	call	Num_of_Submenu_Table		; Получаем количество подпунктов в этом пункте меню
	movwf	num_of_submenu				; 1 раз занесем в перемунную, чтобы каждый раз не вызывать эту процедуру	
	sublw	.0							; Сравним с 0
;	movf	num_of_submenu,f			; А можно сравнить с 0 и так: копируем переменную саму в себя, и если она = 0, установится флаг Z
	bz		Draw_Menu					; Если 0, сразу на выход без прорисовки подпунктов
	clrf	index_submenu				; Очистим индекс пункта подменю	

	if	USE_MOVING_CURSOR & SAVE_CURSOR_POSITION
	movfw	buttons
	movwf	save_position				; Сохраним позицию курсора
	endif

	if	USE_MOVING_CURSOR & !USE_TOP_LAST_CURSOR
	clrf	buttons						; Очистим флаги нажатых кнопок					
	bsf		Press_UP					; И установим признак нажатия только для кнопки "ВВЕРХ"
	endif
;===================================================================================================
Draw_Submenu							; Рисуем подпункты меню
;===================================================================================================
	if	USE_MOVING_CURSOR & USE_TOP_LAST_CURSOR
	movfw	index_submenu
	bnz		Check_2		
	clrf	buttons						; Очистим флаги нажатых кнопок
	bsf		Press_UP					; И установим признак нажатия только для кнопки "ВВЕРХ"
	goto	Skip_Check_2
Check_2
	decf	num_of_submenu,w			; Получаем количество подпунктов в этом меню, учитываем, что индекс подпункта начинается с 0
	subwf	index_submenu,w				; Сравниваем с количеством подпунктов меню
	bnz		Skip_Check_2
	clrf	buttons						; Очистим флаги нажатых кнопок
	bsf		Press_DOWN					; И установим признак нажатия только для кнопки "ВНИЗ"
Skip_Check_2
	endif

	call	CLR_Display_routine			; Очистим дисплей перед самой перерисовкой подпунктов меню, чтобы уменьшить моргание

	if	USE_MOVING_CURSOR
	btfss	Press_UP
	goto	Pressing_DOWN_2			
	call	Draw_Submenu_routine		; Рисуем текущий подпункт меню	
	movfw	num_of_submenu				; Получаем количество подпунктов в этом меню
	sublw	.1							; Сравним с 1
	bz		Skip_Correct_index_submenu_3; Если 1, пропускаем прорисовку 2-й строки
	Draw_Cursor	LAST_SYMBOL_FIRST_LINE	; Нарисум курсор в конце 1-й строчки
	call	Second_String_routine		; Указатель на 2 строку
	incf	index_submenu				; Берем следующий пункт
	movfw	num_of_submenu				; Получаем количество подпунктов в этом меню
	subwf	index_submenu,w				; Сравниваем с количеством подпунктов меню
	bz		Correct_index_submenu
	call	Draw_Submenu_routine		; Рисуем подпункт меню под текущим 
	decf	index_submenu				; Не забудем вернуть назад текущий пункт меню	
	goto	Skip_Correct_index_submenu_3
Correct_index_submenu					; Достигли последнего подпункта меню, следующим отображаем 1 подпункт
	clrf	index_submenu
	call	Draw_Submenu_routine
	decf	num_of_submenu,w
	movwf	index_submenu
	goto	Skip_Correct_index_submenu_3
Pressing_DOWN_2
	decf	index_submenu				; Берем предыдущий пункт меню
	btfsc	index_submenu,.7			; Проверяем на "<0"	простой проверкой 7 бита, максимальное количество пунктов меню ограничено 64
	goto	Correct_index_submenu_2
	call	Draw_Submenu_routine		; Рисуем предыдущий пункт меню
	call	Second_String_routine		; Указатель на 2 строку
	incf	index_submenu				; Вернем текущий пункт					
	goto	Skip_Correct_index_submenu_2
Correct_index_submenu_2
	decf	num_of_submenu,w
	movwf	index_submenu
	call	Draw_Submenu_routine		; Рисуем предыдущий пункт меню
	call	Second_String_routine		; Указатель на 2 строку
	clrf	index_submenu
Skip_Correct_index_submenu_2
	call	Draw_Submenu_routine		; Рисуем текущий пункт меню под предыдущим 
	Draw_Cursor	LAST_SYMBOL_SECOND_LINE	; Нарисум курсор в конце 2-й строчки
Skip_Correct_index_submenu_3

	else
	call	Draw_Submenu_routine		; Рисуем ТЕКУЩИЙ подпункт меню	
	movfw	num_of_submenu				; Получаем количество подпунктов в этом меню
	sublw	.1
	bz		Skip_Correct_index_submenu	; Если 1, пропускаем прорисовку 2-й строки
	call	Second_String_routine		; Иначе указатель на 2 строку
	incf	index_submenu				; Индекс СЛЕДУЮЩЕГО пункта
	movfw	num_of_submenu			
	subwf	index_submenu,w				; Сравниваем с количеством подпунктов меню
	bz		Correct_index_submenu
	call	Draw_Submenu_routine		; Рисуем подпункт меню под текущим 
	decf	index_submenu				; Вернем назад индекс подпункта
	goto	Skip_Correct_index_submenu	
Correct_index_submenu					; Достигли последнего подпункта меню, следующим отображаем 1 подпункт
	clrf	index_submenu	
	call	Draw_Submenu_routine
	decf	num_of_submenu,w			; Если меньше <0
	movwf	index_submenu				; Сделаем текущим последний пункт подменю
Skip_Correct_index_submenu
	endif

	call	Debounce_Delay				; Процедура антидребезга, вызывается при первом входе в подпункт меню, при нажатии кнопок "Вверх", "Вниз", выходе из действия подпункта меню
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
	goto	Draw_Menu					; Вышел таймаут нахождения в подменю, выходим в меню
;-----------------------------------------------------------------
Cursor_UP_submenu						; Была нажата клавиша "Вверх"
	if	USE_MOVING_CURSOR & !USE_RBIE	; При использовании прерываний этот флаг и так выставляется в обработчике
	clrf	buttons						; Очистим флаги нажатых кнопок					
	bsf		Press_UP					; И установим признак нажатия только для кнопки "ВВЕРХ"
	endif

	decf	index_submenu				; Уменьшаем индекс подменю
	btfss	index_submenu,.7			; Проверяем на "<0"	простой проверкой 7 бита, максимальное количество пунктов подменю ограничено 64
	goto	Draw_Submenu		
	decf	num_of_submenu,w			; Если меньше <0
	movwf	index_submenu				; Сделаем текущим последний пункт подменю
	goto	Draw_Submenu				; Отрисовываем новый текущий подпункт меню	
;-----------------------------------------------------------------
Cursor_DOWN_submenu						; Была нажата клавиша "Вниз"
	if	USE_MOVING_CURSOR & !USE_RBIE	; При использовании прерываний этот флаг и так выставляется в обработчике
	clrf	buttons						; Очистим флаги нажатых кнопок					
	bsf		Press_DOWN					; И установим признак нажатия только для кнопки "ВНИЗ"
	endif

	incf	index_submenu				; Увеличиваем индекс подменю
	movfw	num_of_submenu				; Берем количество пунктов в даном подменю	
	subwf	index_submenu,w				; Достигли последнего ?	
	btfsc	STATUS,Z
	clrf	index_submenu				; Если да, делаем текущим первый подпункт меню		
	goto	Draw_Submenu				; Отрисовываем новый текущий подпункт меню
;-----------------------------------------------------------------	
EXIT_submenu							; Была нажата клавиша "Выход"
	if USE_MOVING_CURSOR & SAVE_CURSOR_POSITION
	movfw	save_position
	movwf	buttons						; Восстановим позицию курсора
	endif

	clrf	index_submenu				; Обнуляем индекс пункта подменю, чтобы при следующем заходе в любой пункт меню курсор находился на 1 пункте подменю
	goto	Draw_Menu					; Выходим в меню
;===================================================================================================
ENTER_submenu							; Была нажата клавиша "Вход", осуществлям вход в подпункт меню и выполняем его действие
;===================================================================================================
	call	CLR_Display_routine			; Очистим дисплей
	goto	Switch_Action				; Делаем действие текущего подпункта меню
End_Action
;-----------------------------------------------------------------
	Print_LCD_String_macro	Table_Action_Complete	; Рисуем подтверждение действия
	clrf	temp_3						; Задержка, чтобы успеть прочесть уведомление о выполнении действи
	call	Debounce_Delay
	decfsz	temp_3
	goto	$-2
;-----------------------------------------------------------------
	goto	Draw_Submenu				; И идем отрисовывать подпункт меню, курсор на том же подпункте, что и был
;===================================================================================================
Debounce_Delay							; Подпрограмма антидребезговой задержки
	movlw	.3							; Количество проходов подбирается экспериментальным путем
	movwf	temp_2
	clrf	temp_1
Loop_Delay
	movfw	PORTB						
	iorlw	b'00001111'					; Установим незначущие разряды
	addlw	.1
	bnz		Debounce_Delay				; Если хоть одна кнопка нажата, начинаем отсчет антидребезговой задержки заново
	decfsz	temp_1	
	goto	$-1
	decfsz	temp_2	
	goto	Loop_Delay

	if	USE_RBIE
	clrf	buttons						; Очистим флаги нажатых кнопок
	bcf		INTCON,RBIF					; Сбросим флаг возможно вызваного прерывания от кнопок
	bsf		INTCON,RBIE					; И разрешим прерывания от кнопок
	endif

	return
;===================================================================================================
Draw_Menu_routine						; Подпрограмма отрисовки одного пункта меню
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
Draw_Submenu_routine					; Подпрограмма отрисовки одного подпункта меню
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
	call	CLR_Display_routine			; Очистим дисплей
	Print_LCD_String_macro	Table_Zastavka_First_String
	Second_Line_macro
	Print_LCD_String_macro	Table_Zastavka_Second_String
	goto    Main
;===================================================================================================
Second_String_routine					; Подпрограмма перевода указателя на 2-ю строку	
	if	USE_STATIC_CURSOR
	Draw_Cursor	LAST_SYMBOL_FIRST_LINE	; Нарисуем курсор на последнем символе 1-й строки
	endif
	Second_Line_macro					; Переводим указатель на 2-ю строку	
	return								; И приступаем к отрисовке следующего пункта меню
;===================================================================================================
Draw_Cursor_Routine						; Процедура рисования курсора. В w лежит адрес
	call	Send_LCD_Command
	movlw	'<'							; Нарисуем там курсор
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
	retlw_num_of_submenu_punkts			; Макрос, возвращает количество подпунктов текущего пункта меню
;===================================================================================================
Menu_Table
	goto_Punkt_Menu						; Макрос, создает переходы на все пункты меню							
;---------------------------------------------------------------------------------------------------
Submenu_Table
	goto_Punkt_Submenu					; Макрос, создает переходы на все подпункты меню
;---------------------------------------------------------------------------------------------------
Switch_Action							; Выполним действие, на котором находится курсор 
	goto_Punkt_Submenu_action			; Макрос, создает переходы на действия всех подпунктов меню
;===================================================================================================
	Create_Menu_Names					; Макрос, создает имена всех пунктов меню
;===================================================================================================
	Create_Submenu_Names				; Макрос, создает имена всех подпунктов меню
;===================================================================================================
	include Menu_Actions.asm
;===================================================================================================
	end