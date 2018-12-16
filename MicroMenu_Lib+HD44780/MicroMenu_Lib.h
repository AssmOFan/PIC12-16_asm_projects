; Микроменю на базе двухстрочного индикатора HD44780 и четырехпозиционного джойстика (крестовины кнопок)
; Библиотека построена на основе "индексов". Меню имеет 2 уровня вложености (вход в пункт меню + вход в подпункт меню)
; При навигации по меню изменяются номера ("индексы") текущего пункта меню и текущего подпункта меню
; На основе этих данных и выводится информация на дисплей/совершаются действия

	include	hardware_profile.inc
	include	Macro.h
	include	HD44780_Lib.h

#define	USE_STATIC_CURSOR		0				; Всегда рисовать курсор в конце 1-й строки
#define	USE_MOVING_CURSOR		1				; Использовать перемещаемый курсор (повышает удобство использования меню и размер прошивки)
#define	USE_TOP_LAST_CURSOR		1				; Использовать отображение "первый пункт всегда сверху" и "последний пункт всегда снизу" (повышает удобство использования меню и размер прошивки)
#define	USE_RBIE				1				; Использовать прерывание по изминению состояния PORTB для обработки кнопок (позволяет использовать сон)
#define	USE_MENU_ACTION			1				; Использовать возможность запуска действий при входе в пункт меню (повышает размер прошивки)

	if	USE_MENU_ACTION	
#define	actions_menu_flags		b'00000001'		; Выставленный бит - есть действие при входе в этот пункт меню (не забыть заполнить обработчик действия !!!)
	endif

#define	UP						PORTB,4
#define	DOWN					PORTB,5
#define	ENTER					PORTB,6
#define	EXIT					PORTB,7

#define	Press_UP				flags,0
#define	Press_DOWN				flags,1
#define	Press_ENTER				flags,2
#define	Press_EXIT				flags,3
	
#define	EXIT_DELAY				.20				; Количество опросов кнопок, до автовыхода в предыдущий уровень (* 0,8 сек)

#define	ZASTAVKA_FIRST_STRING	"  MicroMenuLib"
#define	ZASTAVKA_SECOND_STRING	"  ver 1.0 beta"

#define	ACTION_COMPLETE_STRING	"Action Complete!"

#define	NUM_OF_MAIN_MENU_PUNKTS	.6				; Количество пунктов меню, до 8 (можно и больше, но действия при входе в меню доступны только для первых 8 пунктов) 

#define	MENU_NAME_1				"1.Menu_1"
#define	MENU_NAME_2				"2.Menu_2"
#define	MENU_NAME_3				"3.Menu_3"
#define	MENU_NAME_4				"4.Menu_4"
#define	MENU_NAME_5				"5.Menu_5"
#define	MENU_NAME_6				"6.Menu_6"	

#define	NUM_OF_SUBMENU_PUNKTS_1	.0				; Количество подпунктов каждого пункта меню (в теории до 64, но больше 8 не проверялось, памяти в контроллере не хватило)
												; Не забываем оформить обработчик для каждого действия !!!
#define	MENU_SUBMENU_NAME_1_1	"1.1.SubMenu"
#define	MENU_SUBMENU_NAME_1_2	"1.2.SubMenu"
#define	MENU_SUBMENU_NAME_1_3	"1.3.SubMenu"

#define	NUM_OF_SUBMENU_PUNKTS_2	.1

#define	MENU_SUBMENU_NAME_2_1	"2.1.SubMenu"
#define	MENU_SUBMENU_NAME_2_2	"2.2.SubMenu"
#define	MENU_SUBMENU_NAME_2_3	"2.3.SubMenu"
				
#define	NUM_OF_SUBMENU_PUNKTS_3	.2

#define	MENU_SUBMENU_NAME_3_1	"3.1.SubMenu"
#define	MENU_SUBMENU_NAME_3_2	"3.2.SubMenu"
#define	MENU_SUBMENU_NAME_3_3	"3.3.SubMenu"

#define	NUM_OF_SUBMENU_PUNKTS_4	.3

#define	MENU_SUBMENU_NAME_4_1	"4.1.SubMenu"
#define	MENU_SUBMENU_NAME_4_2	"4.2.SubMenu"
#define	MENU_SUBMENU_NAME_4_3	"4.3.SubMenu"

#define	NUM_OF_SUBMENU_PUNKTS_5	.4

#define	MENU_SUBMENU_NAME_5_1	"5.1.SubMenu"
#define	MENU_SUBMENU_NAME_5_2	"5.2.SubMenu"
#define	MENU_SUBMENU_NAME_5_3	"5.3.SubMenu"
#define	MENU_SUBMENU_NAME_5_4	"5.4.SubMenu"

#define	NUM_OF_SUBMENU_PUNKTS_6	.1

#define	MENU_SUBMENU_NAME_6_1	"6.1.SubMenu"
;================================================================================================================
Create_Menu_Names	macro				; Макрос, создает имена всех пунктов меню
					local	a=1
					while	a<NUM_OF_MAIN_MENU_PUNKTS+1
						Menu_#v(a)
						mod_PCL	symbol_pointer
						dt		MENU_NAME_#v(a),0
						a+=1
					endw
					endm
;================================================================================================================
retlw_num_of_submenu_punkts	macro		; Макрос, возвращает количество пунктов нужного подменю
							mod_PCL	index_menu
							local	a=1
							while	a<NUM_OF_MAIN_MENU_PUNKTS+1
								retlw	NUM_OF_SUBMENU_PUNKTS_#v(a)
								a+=1
							endw
							endm
;================================================================================================================
goto_Punkt_Menu	macro					; Макрос, создает переходы на все пункты меню
				mod_PCL	index_menu
				local	a=1
				while	a<NUM_OF_MAIN_MENU_PUNKTS+1
					goto	Menu_#v(a)
					a+=1
				endw
				endm
;================================================================================================================
goto_Punkt_Submenu	macro				; Макрос, создает переходы на имена всех подпунктов меню
					mod_PCL	index_menu				
					local	c=1
					while	c<NUM_OF_MAIN_MENU_PUNKTS+1
						goto	Menu_#v(c)_Table
						c+=1
					endw
					local	d=1
					local	a
					while		d<NUM_OF_MAIN_MENU_PUNKTS+1
						a=1	
						Menu_#v(d)_Table
						mod_PCL	index_submenu
						while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
							goto	Menu_#v(d)_Submenu_#v(a)
							a+=1
						endw
						d+=1
					endw	
					endm
;================================================================================================================
goto_Punkt_Submenu_action	macro		; Макрос, создает переходы на действия всех подпунктов меню
							mod_PCL	index_menu				
							local	c=1
							while	c<NUM_OF_MAIN_MENU_PUNKTS+1
								goto	Menu_#v(c)_Table_action
								c+=1
							endw
							local	d=1
							local	a
							while		d<NUM_OF_MAIN_MENU_PUNKTS+1
								a=1	
								Menu_#v(d)_Table_action
								mod_PCL	index_submenu
								while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
									goto	Menu_#v(d)_Submenu_#v(a)_action
									a+=1
								endw
								d+=1
							endw
							endm
;================================================================================================================
Create_Submenu_Names	macro				; Макрос, создает имена всех подпунктов меню
; К сожаления, почему-то не получилось создавать имена всех подпунктов меню в цикле, поэтому приходится вызывать макрос столько раз, сколько есть пунктов меню
; Внимание, если количество пунктов в меню превышает 8, просто добавьте еще
						local	d=1
;-----------------------------------------------------------------------------------------------------------
; Подпункты 1 пункта меню
;-----------------------------------------------------------------------------------------------------------
						if		d<NUM_OF_MAIN_MENU_PUNKTS+1
							local	a=1	
							while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
								Menu_#v(d)_Submenu_#v(a)
								mod_PCL	symbol_pointer
								dt		MENU_SUBMENU_NAME_1_#v(a),0
								a+=1
							endw
							d+=1
						endif
;-----------------------------------------------------------------------------------------------------------
; Подпункты 2 пункта меню
;-----------------------------------------------------------------------------------------------------------
						if		d<NUM_OF_MAIN_MENU_PUNKTS+1
							local	a=1	
							while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
								Menu_#v(d)_Submenu_#v(a)
								mod_PCL	symbol_pointer
								dt		MENU_SUBMENU_NAME_2_#v(a),0
								a+=1
							endw
							d+=1
						endif
;-----------------------------------------------------------------------------------------------------------
; Подпункты 3 пункта меню
;-----------------------------------------------------------------------------------------------------------
						if		d<NUM_OF_MAIN_MENU_PUNKTS+1
							local	a=1	
							while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
								Menu_#v(d)_Submenu_#v(a)
								mod_PCL	symbol_pointer
								dt		MENU_SUBMENU_NAME_3_#v(a),0
								a+=1
							endw
							d+=1
						endif
;-----------------------------------------------------------------------------------------------------------
; Подпункты 4 пункта меню
;-----------------------------------------------------------------------------------------------------------
						if		d<NUM_OF_MAIN_MENU_PUNKTS+1
							local	a=1	
							while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
								Menu_#v(d)_Submenu_#v(a)
								mod_PCL	symbol_pointer
								dt		MENU_SUBMENU_NAME_4_#v(a),0
								a+=1
							endw
							d+=1
						endif
;-----------------------------------------------------------------------------------------------------------
; Подпункты 5 пункта меню
;-----------------------------------------------------------------------------------------------------------
						if		d<NUM_OF_MAIN_MENU_PUNKTS+1
							local	a=1	
							while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
								Menu_#v(d)_Submenu_#v(a)
								mod_PCL	symbol_pointer
								dt		MENU_SUBMENU_NAME_5_#v(a),0
								a+=1
							endw
							d+=1
						endif
;-----------------------------------------------------------------------------------------------------------
; Подпункты 6 пункта меню
;-----------------------------------------------------------------------------------------------------------
						if		d<NUM_OF_MAIN_MENU_PUNKTS+1
							local	a=1	
							while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
								Menu_#v(d)_Submenu_#v(a)
								mod_PCL	symbol_pointer
								dt		MENU_SUBMENU_NAME_6_#v(a),0
								a+=1
							endw
							d+=1
						endif
;-----------------------------------------------------------------------------------------------------------
; Подпункты 7 пункта меню
;-----------------------------------------------------------------------------------------------------------
						if		d<NUM_OF_MAIN_MENU_PUNKTS+1
							local	a=1	
							while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
								Menu_#v(d)_Submenu_#v(a)
								mod_PCL	symbol_pointer
								dt		MENU_SUBMENU_NAME_7_#v(a),0
								a+=1
							endw
							d+=1
						endif
;-----------------------------------------------------------------------------------------------------------
; Подпункты 8 пункта меню
;-----------------------------------------------------------------------------------------------------------
						if		d<NUM_OF_MAIN_MENU_PUNKTS+1
							local	a=1	
							while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
								Menu_#v(d)_Submenu_#v(a)
								mod_PCL	symbol_pointer
								dt		MENU_SUBMENU_NAME_8_#v(a),0
								a+=1
							endw
							d+=1
						endif
;-----------------------------------------------------------------------------------------------------------
						endm
;================================================================================================================
	if	USE_MENU_ACTION	
goto_Menu_action	macro		; Макрос, создает переходы на действия всех пунктов меню (если включена соответствующая опция)
					mod_PCL	index_menu				
					local	a=1
					while	a<NUM_OF_MAIN_MENU_PUNKTS+1
						goto	Menu_#v(a)_action
						a+=1
					endw
					endm
	endif
;================================================================================================================
Draw_Cursor	macro	LAST_SYMBOL
			movlw	LAST_SYMBOL
			call	Draw_Cursor_Routine
			endm
						