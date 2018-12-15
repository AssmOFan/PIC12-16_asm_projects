
#define	USE_SHORT_MOD_PCL	1	; Использовать "укороченную" версию макроса модификации PCL, позволяет экономить 1 слово памяти на каждом вызове макроса ценой 1 лишней ячейки ОЗУ

push	macro
		movwf	w_temp
		swapf	STATUS,w
		movwf	status_temp
		endm

pop		macro
		swapf	status_temp,w
		movwf	STATUS
		swapf	w_temp,f
		swapf	w_temp,w
		endm

mod_PCL	macro	target			; Макрос, позволяет размещать таблицы на границах страниц
		local	Table
		movfw	target
		addlw	low Table		; Добавить 8 младших бит адреса таблицы к смещению
		movwf	offset			; Сохранить младшие 8 бит требуемого адреса
	if	USE_SHORT_MOD_PCL
		rlf		known_zero,w	; так сохраняют бит переполнения от сложения 
		addlw	high Table		; Загрузить 5 старших бит адреса
	else
		movlw	high Table		; Загрузить 5 старших бит адреса
		btfsc	STATUS,C		; Перешли границу страницы памяти программ?
		addlw	1				; Если да, увеличить на 1 старшие 5 бит
	endif
		movwf	PCLATH			; Установить старшую часть адреса
		movfw	offset			; Загрузить рассчитанное значание младшей части адреса
		movwf	PCL				; Установить младшую часть адреса
	Table
		endm

add_PCL	macro	target,address	; Макрос, позволяет удобно указывать страницу для следующего за ним кода
				movfw	target	
				clrf	PCLATH
			if	(address==0x100)
				bsf		PCLATH,0
			endif
			if	(address==0x200)
				bsf		PCLATH,1
			endif
			if	(address==0x300)
				bsf		PCLATH,0				
				bsf		PCLATH,1
			endif
			if	(address==0x400)
				bsf		PCLATH,2				
			endif
				addwf   PCL
				endm
