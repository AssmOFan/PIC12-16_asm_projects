; ��������� �� ���� ������������� ���������� HD44780 � ������������������� ��������� (���������� ������)

include	hardware_profile.inc
include	Macro.h	

#define	USE_STATIC_CURSOR		1				; ������ �������� ������ � ����� 1-� ������
#define	USE_MOVING_CURSOR		0				; ������������ ������������ ������ (�������� �������� ������������� ���� � ������ ��������)
#define	USE_TOP_LAST_CURSOR		0				; ������������ ����������� "������ ����� ������ ������" � "��������� ����� ������ �����" (�������� �������� ������������� ���� � ������ ��������)
#define	SAVE_CURSOR_POSITION	0				; ��������� ������� ������� ��� ����� � �������, � ��������������� �� ��� ������ � ������� ����
#define	USE_MENU_ACTION			1				; ������������ ����������� ������� �������� ��� ����� � ����� ����
#define	USE_RBIE				0				; ������������ ���������� �� ��������� ��������� PORTB ��� ��������� ������ (��������� ������������ ���)

if	USE_MENU_ACTION	
#define	actions_menu_flags		b'00000001'		; ������������ ��� - ���� �������� ��� ����� � ���� ����� ���� (�� ������ ��������� ���������� ��������)
endif

#define	UP						PORTB,4
#define	DOWN					PORTB,5
#define	ENTER					PORTB,6
#define	EXIT					PORTB,7

#define	Press_UP				buttons,0
#define	Press_DOWN				buttons,1
#define	Press_EXIT				buttons,2
#define	Press_ENTER				buttons,3	

;#define	ZUMER					PORTA,0

#define	EXIT_DELAY				.20				; ���������� ������� ������, �� ������ � ���������� ������� (* 0,8 ���)

#define	ZASTAVKA_FIRST_STRING	"  MicroMenuLib"
#define	ZASTAVKA_SECOND_STRING	"  ver 1.0 beta"

#define	NUM_OF_MAIN_MENU_PUNKTS	.5				; ���������� ������� ����, �� 10 

#define	MENU_NAME_1				"1.Menu_1"
#define	MENU_NAME_2				"2.Menu_2"
#define	MENU_NAME_3				"3.Menu_3"
#define	MENU_NAME_4				"4.Menu_4"
#define	MENU_NAME_5				"5.Menu_5"
#define	MENU_NAME_6				"6.Menu_6"	

#define	NUM_OF_SUBMENU_PUNKTS_1	.0				; ���������� ���������� ������� ������ ����, �� 8

#define	MENU_SUBMENU_NAME_1_1	"1.1.Subm"
#define	MENU_SUBMENU_NAME_1_2	"1.2.Subm"
#define	MENU_SUBMENU_NAME_1_3	"1.3.Subm"
#define	MENU_SUBMENU_NAME_1_4	"1.4.Subm"

#define	NUM_OF_SUBMENU_PUNKTS_2	.1

#define	MENU_SUBMENU_NAME_2_1	"2.1.Subm"
#define	MENU_SUBMENU_NAME_2_2	"2.2.Subm"
#define	MENU_SUBMENU_NAME_2_3	"2.3.Subm"
#define	MENU_SUBMENU_NAME_2_4	"2.4.Subm"
				
#define	NUM_OF_SUBMENU_PUNKTS_3	.2

#define	MENU_SUBMENU_NAME_3_1	"3.1.Subm"
#define	MENU_SUBMENU_NAME_3_2	"3.2.Subm"
#define	MENU_SUBMENU_NAME_3_3	"3.3.Subm"
#define	MENU_SUBMENU_NAME_3_4	"3.4.Subm"

#define	NUM_OF_SUBMENU_PUNKTS_4	.3

#define	MENU_SUBMENU_NAME_4_1	"4.1.Subm"
#define	MENU_SUBMENU_NAME_4_2	"4.2.Subm"
#define	MENU_SUBMENU_NAME_4_3	"4.3.Subm"
#define	MENU_SUBMENU_NAME_4_4	"4.4.Subm"

#define	NUM_OF_SUBMENU_PUNKTS_5	.4

#define	MENU_SUBMENU_NAME_5_1	"5.1.Subm"
#define	MENU_SUBMENU_NAME_5_2	"5.2.Subm"
#define	MENU_SUBMENU_NAME_5_3	"5.3.Subm"
#define	MENU_SUBMENU_NAME_5_4	"5.4.Subm"
;================================================================================================================
Create_Menu_Names	macro				; ������, ������� ����� ���� ������� ����
			local	a=1
				while	a<NUM_OF_MAIN_MENU_PUNKTS+1
				Menu_#v(a)
					mod_PCL	symbol_pointer
					dt		MENU_NAME_#v(a),0
					a+=1
				endw
			endm
;================================================================================================================
retlw_num_of_submenu_punkts	macro		; ������, ���������� ���������� ������� ������� �������
				mod_PCL	index_menu
			local	a=1
				while	a<NUM_OF_MAIN_MENU_PUNKTS+1
					retlw	NUM_OF_SUBMENU_PUNKTS_#v(a)
					a+=1
				endw
			endm
;================================================================================================================
goto_Punkt_Menu	macro					; ������, ������� �������� �� ��� ������ ����
				mod_PCL	index_menu
			local	a=1
				while	a<NUM_OF_MAIN_MENU_PUNKTS+1
					goto	Menu_#v(a)
					a+=1
				endw
			endm
;================================================================================================================
goto_Punkt_Submenu	macro				; ������, ������� �������� �� ����� ���� ���������� ����
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
goto_Punkt_Submenu_action	macro		; ������, ������� �������� �� �������� ���� ���������� ����
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
Create_Submenu_Names_	macro				; �� ���������� ������ �������� ���� ���� ���������� ���� :(
						local	d=1
						local	a	
						while	d<NUM_OF_MAIN_MENU_PUNKTS+1
							a=1
							while	a<NUM_OF_SUBMENU_PUNKTS_#v(d)+1							
								Menu_#v(d)_Submenu_#v(a)
								mod_PCL	symbol_pointer
								dt	MENU_SUBMENU_NAME_#v(d)_#v(a),0
								a+=1
							endw
							d+=1
						endw
						endm
;================================================================================================================
Create_Submenu_Names	macro				; ������, ������� ����� ���� ���������� ����
				local	d=1
;-----------------------------------------------------------------------------------------------------------
; ��������� 1 ������ ����
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
; ��������� 2 ������ ����
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
; ��������� 3 ������ ����
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
; ��������� 4 ������ ����
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
; ��������� 5 ������ ����
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
; ��������� 6 ������ ����
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
; ��������� 7 ������ ����
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
; ��������� 8 ������ ����
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
goto_Menu_action	macro		; ������, ������� �������� �� �������� ���� ������� ���� (���� �������� ��������������� �����)
					mod_PCL	index_menu			
					local	a=1
				while	a<NUM_OF_MAIN_MENU_PUNKTS+1
					goto	Menu_#v(a)_action
					a+=1
				endw
					endm
endif
;================================================================================================================
MicroMenu_Init	macro
				call	LCD_Init					; ������������ ������ �������	
				clrf	buttons						; ������� ����� ������� ������
				if	USE_RBIE
				bcf		INTCON,RBIF			
				movlw	(1<<RBIE)|(1<<GIE)
				iorwf	INTCON
				endif
				endm
;================================================================================================================
if	USE_RBIE
Button_Heandler	macro								; ���������� ������� ������
				bcf		INTCON,RBIF					; ������� ���� ��������� ����������
				movfw	PORTB						
				iorlw	b'00001111'					; ��������� ���������� �������
				addlw	.1
				bz		End_Interrupt_Heandler		; ���� �� ���� ������ �� ������, ��������� ��������� �������
				btfss	UP
				bsf		Press_UP		
				btfss	DOWN
				bsf		Press_DOWN
				btfss	ENTER
				bsf		Press_ENTER
				btfss	EXIT
				bsf		Press_EXIT
				bcf		INTCON,RBIE					; �������� ��� ���������� ���������� �� ������, �� ��������� ����� �������
				endm
endif
;================================================================================================================
Check_buttons_macro	macro
					if	USE_RBIE
					sleep
					nop
					movfw	buttons						
					andlw	b'00001111'					; ������� ���������� �������
					bnz		Menu_heandler				; ���� ���� ���� ������ ������, ������ � ���������� ����
				
					else
					movfw	PORTB						
					iorlw	b'00001111'					; ��������� ���������� �������
					addlw	.1
					bnz		Menu_heandler				; ���� ���� ���� ������ ������, ������ � ���������� ����
					endif
					endm
;================================================================================================================
