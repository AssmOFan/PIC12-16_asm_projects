
#define	USE_SHORT_MOD_PCL	1	; ������������ "�����������" ������ ������� ����������� PCL, ��������� ��������� 1 ����� ������ �� ������ ������ ������� ����� 1 ������ ������ ���

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

mod_PCL	macro	target			; ������, ��������� ��������� ������� �� �������� �������
		local	Table
		movfw	target
		addlw	low Table		; �������� 8 ������� ��� ������ ������� � ��������
		movwf	offset			; ��������� ������� 8 ��� ���������� ������
	if	USE_SHORT_MOD_PCL
		rlf		known_zero,w	; ��� ��������� ��� ������������ �� �������� 
		addlw	high Table		; ��������� 5 ������� ��� ������
	else
		movlw	high Table		; ��������� 5 ������� ��� ������
		btfsc	STATUS,C		; ������� ������� �������� ������ ��������?
		addlw	1				; ���� ��, ��������� �� 1 ������� 5 ���
	endif
		movwf	PCLATH			; ���������� ������� ����� ������
		movfw	offset			; ��������� ������������ �������� ������� ����� ������
		movwf	PCL				; ���������� ������� ����� ������
	Table
		endm

add_PCL	macro	target,address	; ������, ��������� ������ ��������� �������� ��� ���������� �� ��� ����
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
