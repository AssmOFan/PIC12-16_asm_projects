; Микроменю на базе двухстрочного индикатора HD44780 и четырехпозиционного джойстика (крестовины кнопок)

include	hardware_profile.inc
include	Macro.h	

#define	USE_CURSOR				0				; Всегда рисовать курсор в конце 1-й строки
#define	USE_MOVING_CURSOR		1				; Использовать перемещаемый курсор (повышает удобство использования меню и размер прошивки)
#define	USE_TOP_LAST_CURSOR		1				; Использовать отображение "первый пункт всегда сверху" и "последний пункт всегда снизу" (повышает удобство использования меню и размер прошивки)
#define	USE_RBIE				1				; Использовать прерывание по изминению состояния PORTB для обработки кнопок (позволяет использовать сон)

#define	UP						PORTB,4
#define	DOWN					PORTB,5
#define	ENTER					PORTB,6
#define	EXIT					PORTB,7

#define	Press_UP				flags,0
#define	Press_DOWN				flags,1
#define	Press_EXIT				flags,2
#define	Press_ENTER				flags,3	

#define	EXIT_DELAY				.20				; Количество опросов кнопок, до выхода в предыдущий уровень (* 0,8 сек)

#define	ZASTAVKA_FIRST_STRING	"  MicroMenuLib"
#define	ZASTAVKA_SECOND_STRING	"  ver 1.0 beta"

#define	NUM_OF_MAIN_MENU_PUNKTS	.5				; Количество пунктов меню, до 10 

#define	MENU_NAME_1				"1.Menu_1"
#define	MENU_NAME_2				"2.Menu_2"
#define	MENU_NAME_3				"3.Menu_3"
#define	MENU_NAME_4				"4.Menu_4"
#define	MENU_NAME_5				"5.Menu_5"	

#define	NUM_OF_SUBMENU_PUNKTS_1	.3				; Количество подпунктов каждого пункта меню, до 10

#define	MENU_SUBMENU_NAME_1_1	"1.1.Garage"
#define	MENU_SUBMENU_NAME_1_2	"1.2.Doors"
#define	MENU_SUBMENU_NAME_1_3	"1.3.House"

#define	NUM_OF_SUBMENU_PUNKTS_2	.3

#define	MENU_SUBMENU_NAME_2_1	"2.1.Garage"
#define	MENU_SUBMENU_NAME_2_2	"2.2.Doors"
#define	MENU_SUBMENU_NAME_2_3	"2.3.House"
				
#define	NUM_OF_SUBMENU_PUNKTS_3	.3

#define	MENU_SUBMENU_NAME_3_1	"3.1.Review"
#define	MENU_SUBMENU_NAME_3_2	"3.2.Shut Off"
#define	MENU_SUBMENU_NAME_3_3	"3.3.FAQ"

#define	NUM_OF_SUBMENU_PUNKTS_4	.3

#define	MENU_SUBMENU_NAME_4_1	"4.1.Review"
#define	MENU_SUBMENU_NAME_4_2	"4.2.Shut Off"
#define	MENU_SUBMENU_NAME_4_3	"4.3.FAQ"

#define	NUM_OF_SUBMENU_PUNKTS_5	.3

#define	MENU_SUBMENU_NAME_5_1	"5.1.Config"
#define	MENU_SUBMENU_NAME_5_2	"5.2.Settings"
#define	MENU_SUBMENU_NAME_5_3	"5.3.About"

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
goto_Punkt_Submenu	macro				; Макрос, создает переходы на все подпункты меню
					mod_PCL	index_menu				
			local	c=1
				while	c<NUM_OF_MAIN_MENU_PUNKTS+1
					goto	Menu_#v(c)_Table
					c+=1
				endw
			local	d=1
;-----------------------------------------------------------------------------------------------------------
; Переходы на подпункты 1 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
; Переходы на подпункты 2 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
; Переходы на подпункты 3 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
; Переходы на подпункты 4 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
; Переходы на подпункты 5 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
; Переходы на подпункты 6 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
; Переходы на подпункты 7 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
; Переходы на подпункты 8 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
; Переходы на подпункты 9 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
; Переходы на подпункты 10 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)
					a+=1
				endw
					d+=1
				endif		
;-----------------------------------------------------------------------------------------------------------
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
;-----------------------------------------------------------------------------------------------------------
; Действия подпунктов 1 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table_action
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)_action
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
; Действия подпунктов 2 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table_action
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)_action
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
; Действия подпунктов 3 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table_action
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)_action
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
; Действия подпунктов 4 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table_action
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)_action
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
; Действия подпунктов 5 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table_action
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)_action
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
; Действия подпунктов 6 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table_action
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)_action
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
; Действия подпунктов 7 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table_action
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)_action
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
; Действия подпунктов 8 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table_action
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)_action
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
; Действия подпунктов 9 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table_action
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)_action
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
; Действия подпунктов 10 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				Menu_#v(d)_Table_action
					mod_PCL	index_submenu
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					goto	Menu_#v(d)_Submenu_#v(a)_action
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
			endm

;===================================================================================================
Create_Submenu_Names	macro				; Макрос, создает имена всех подпунктов меню
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
; Подпункты 9 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
						mod_PCL	symbol_pointer
						dt		MENU_SUBMENU_NAME_9_#v(a),0
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
; Подпункты 10 пункта меню
;-----------------------------------------------------------------------------------------------------------
				if		d<NUM_OF_MAIN_MENU_PUNKTS+1
				local	a=1	
				while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1
					Menu_#v(d)_Submenu_#v(a)
						mod_PCL	symbol_pointer
						dt		MENU_SUBMENU_NAME_10_#v(a),0
					a+=1
				endw
					d+=1
				endif
;-----------------------------------------------------------------------------------------------------------
			endm