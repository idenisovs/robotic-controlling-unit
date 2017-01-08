			.include "m88def.inc"
			.include "macro.inc"

; Macros Start ===============================================
	

; Macros End   ===============================================


; RAM ========================================================
			.DSEG

			.equ 	LowByte  = 255
			.equ	MedByte  = 255
			.equ	HighByte = 1

			.equ MAXBUFF_IN	 =	10	
			.equ MAXBUFF_OUT = 	10

IN_buff:	.byte	MAXBUFF_IN
IN_PTR_S:	.byte	1
IN_PTR_E:	.byte	1
IN_FULL:	.byte	1	

OUT_buff:	.byte	MAXBUFF_OUT
OUT_PTR_S:	.byte	1
OUT_PTR_E:	.byte	1
OUT_FULL:	.byte	1

TCNT:		.byte	4


; FLASH ======================================================

			.CSEG

; Vectors table ==============================================

			.ORG $000		; Reset Handler
			rjmp RESET 
			.ORG $001		; IRQ0 Handler
			RETI 
			.ORG $002		; IRQ1 Handler
			RETI 
			.ORG $003 		; PCINT0 Handler
			RETI 
			.ORG $004		; PCINT1 Handler
			RETI 
			.ORG $005 		; PCINT2 Handler
			RETI 
			.ORG $006 		; Watchdog Timer Handler
			RETI 
			.ORG $007 		; Timer2 Compare A Handler
			RETI 
			.ORG $008		; Timer2 Compare B Handler
			RETI
			.ORG $009 		; Timer2 Overflow Handler
			RETI 
			.ORG $00A 		; Timer1 Capture Handler
			RETI 
			.ORG $00B 		; Timer1 Compare A Handler
			RETI 
			.ORG $00C 		; Timer1 Compare B Handler
			RETI 
			.ORG $00D 		; Timer1 Overflow Handler
			RETI 
			.ORG $00E 		; Timer0 Compare A Handler
			RETI 
			.ORG $00F 		; Timer0 Compare B Handler
			RETI 
			.ORG $010 		; Timer0 Overflow Handler
			RETI 
			.ORG $011 		; SPI Transfer Complete Handler
			RETI 
			.ORG $012 		; USART, RX Complete Handler
			RJMP RX_OK 
			.ORG $013 		; USART, UDR Empty Handler
			RJMP UD_OK 
			.ORG $014 		; USART, TX Complete Handler
			RJMP TX_OK 
			.ORG $015 		; ADC Conversion Complete Handler
			RETI 
			.ORG $016 		; EEPROM Ready Handler
			RETI 
			.ORG $017 		; Analog Comparator Handler
			RETI 
			.ORG $018 		; 2-wire Serial Interface Handler
			RETI 
			.ORG $019 		; Store Program Memory Ready Handler
			RETI 

			.ORG   INT_VECTORS_SIZE

; Interrupts =================================================


; ���������� �� ����� ������.

RX_OK:		PUSHF				; ������, �������� � ���� SREG � R16
			PUSH	R17
			PUSH	R18
			PUSH	XL
			PUSH	XH
 
			LDI		XL,low(IN_buff)		; ����� ����� ������ �������
			LDI		XH,high(IN_buff)
			LDS		R16,IN_PTR_E		; ����� �������� ����� ������
			LDS		R18,IN_PTR_S		; ����� �������� ����� ������
 
			ADD		XL,R16				; ��������� ������ �� ���������
			CLR		R17					; �������� ����� ����� ������
			ADC		XH,R17
 
			LDS		R17,UDR0			; �������� ������
			ST		X,R17				; ��������� �� � ������
 
			INC		R16					; ����������� ��������
 
			CPI		R16,MAXBUFF_IN		; ���� �������� ����� 
			BRNE	NoEnd
			CLR		R16					; ������������ �� ������
 
NoEnd:		CP		R16,R18				; ����� �� ������������� ������?
			BRNE	RX_OUT				; ���� ���, �� ������ �������
 
 
RX_FULL:	LDI		R18,1				; ���� ��, �� ������ ����������.
			STS		IN_FULL,R18			; ���������� ���� �������������
 
RX_OUT:		STS		IN_PTR_E,R16		; ��������� ��������. �������
 
			POP		XH
			POP		XL
			POP		R18
			POP		R17
			POPF						; ������� SREG � R16
			RETI

; ���������� �� �������� ������.

TX_OK:		nop
			nop
			nop
			RETI

; ���������� �� ����������� �������.

UD_OK:		PUSHF						
			PUSH	R17
			PUSH	R18
			PUSH	R19
			PUSH	XL
			PUSH	XH
 
 
			LDI		XL,low(OUT_buff)	; ����� ����� ������ �������
			LDI		XH,high(OUT_buff)
			LDS		R16,OUT_PTR_E		; ����� �������� ����� ������
			LDS		R18,OUT_PTR_S		; ����� �������� ����� ������			
			LDS		R19,OUT_FULL		; ���� ���� ������������
 
			CPI		R19,1				; ���� ������ ����������, �� ��������� ������
			BREQ 	NeedSend			; ����� ��������� �����. ��� ���� ������.
	 
			CP		R18,R16				; ��������� ������ ������ ��������� ������?
			BRNE	NeedSend			; ���! ������ �� ����. ���� ����� ������
 
 			; ������ ����������
			LDI 	R16,(1<<RXEN0)|(1<<TXEN0)|(1<<RXCIE0)|(1<<TXCIE0)|(0<<UDRIE0)
			STS 	UCSR0B, R16			; �� ������� UDR
			RJMP 	TX_OUT				; �������
 
NeedSend:	CLR		R17					; �������� ����
			STS		OUT_FULL,R17		; ���������� ���� ������������
 
			ADD		XL,R18				; ��������� ������ �� ���������
			ADC		XH,R17				; �������� ����� ����� ������
 
			LD		R17,X				; ����� ���� �� �������
			STS		UDR0,R17			; ���������� ��� � USART
 
			INC		R18					; ����������� �������� ��������� ������
 
			CPI		R18,MAXBUFF_OUT		; �������� ����� ������?
			BRNE	TX_OUT				; ���? 
 
			CLR		R18					; ��? ����������, ����������� �� 0
 
TX_OUT:		STS		OUT_PTR_S,R18		; ��������� ���������
 
			POP		XH
			POP		XL
			POP		R19
			POP		R18
			POP		R17
			POPF						; �������, ������ ��� �� �����
			RETI


; Load Loop Buffer 
; IN R19 	- DATA
; OUT R19 	- ERROR CODE 
Buff_Push:	CLI 						; ������ ����������. 
			LDI		XL,low(OUT_buff)	; ����� ����� ������ �������
			LDI		XH,high(OUT_buff)
			LDS		R16,OUT_PTR_E		; ����� �������� ����� ������
			LDS		R18,OUT_PTR_S		; ����� �������� ����� ������
 
			ADD		XL,R16				; ��������� ������ �� ���������
			CLR		R17					; �������� ����� ����� ������
			ADC		XH,R17
 
 
			ST		X,R19				; ��������� �� � ������
			CLR		R19					; ������� R19, ������ ��� ��� ������
										; ������� ������ ������������
 
			INC		R16					; ����������� ��������
 
			CPI		R16,MAXBUFF_OUT		; ���� �������� ����� 
			BRNE	_NoEnd
			CLR		R16					; ������������ �� ������
 
_NoEnd:		CP		R16,R18				; ����� �� ������������� ������?
			BRNE	_RX_OUT				; ���� ���, �� ������ �������
 
 
_RX_FULL:	LDI		R19,1				; ���� ��, �� ������ ����������.
			STS		OUT_FULL,R19		; ���������� ���� �������������
			; � R19 �������� 1 - ��� ������ ������������
 
_RX_OUT:	STS		OUT_PTR_E,R16		; ��������� ��������. �������
			SEI 						; ���������� ����������
			RET

; Read from loop Buffer
; IN: NONE
; OUT: 	R17 - Data,
;		R19 - ERROR CODE
 
Buff_Pop: 	CLI 					; ��������� ���������. 
									; �� ����� ��������� ���������� ���������  �� 
									; UART, ��� ��������� ������ ���.
			LDI		XL,low(IN_buff)	; ����� ����� ������ �������
			LDI		XH,high(IN_buff)
			LDS		R16,IN_PTR_E	; ����� �������� ����� ������
			LDS		R18,IN_PTR_S	; ����� �������� ����� ������			
			LDS		R19,IN_FULL		; ���� ���� ������������
 
			CPI		R19,1			; ���� ������ ����������, �� ��������� ������
			BREQ	NeedPop			; ����� ��������� �����. ��� ���� ������.
 
			CP		R18,R16			; ��������� ������ ������ ��������� ������?
			BRNE	NeedPop			; ���! ������ �� ����. �������� ������
 
			LDI		R19,1			; ��� ������ - ������ ������!
 
			RJMP	_TX_OUT			; �������
 
NeedPop:	CLR		R17				; �������� ����
			STS		IN_FULL,R17		; ���������� ���� ������������
 
			ADD		XL,R18			; ��������� ������ �� ���������
			ADC		XH,R17			; �������� ����� ����� ������
 
			LD		R17,X			; ����� ���� �� �������
			CLR		R19				; ����� ���� ������
 
			INC		R18				; ����������� �������� ��������� ������
 
			CPI		R18,MAXBUFF_OUT	; �������� ����� ������?
			BRNE	_TX_OUT			; ���? 
 
			CLR		R18				; ��? ����������, ����������� �� 0
 
_TX_OUT:	STS		IN_PTR_S,R18	; ��������� ���������
			SEI						; ��������� ����������
			RET



; RUN =====================================================

Reset:   	STACKINIT
			RAMFLUSH

; Internal Hardware Init  =================================


			; USART Init

			.equ 	XTAL = 8000000 	
			.equ 	baudrate = 19200  
			.equ 	bauddivider = XTAL/(16*baudrate)-1

			LDI		R16, high(bauddivider)
			STS		UBRR0H, R16
			LDI		R16, low(bauddivider)
			STS		UBRR0L, R16

			; ������� UCSR0A.
			LDI		R16, 0
			STS		UCSR0A, R16

			; ������� UCSR0B, ��������� ����������, ���� � �������� ������.
			; ����� ���������� �� ����������� �������� ������.
			LDI		R16, (1<<RXCIE0)|(1<<TXCIE0)|(0<<UDRIE0)|(1<<RXEN0)|(1<<TXEN0)
			STS		UCSR0B, R16
			
			; ������� UCSR0C.
			; ������ ����� - 8 ���, 1 ���� ���, ����������� �����.
			LDI		R16, (1<<UMSEL01)|(1<<UCSZ00)|(1<<UCSZ01)
			STS		UCSR0C, R16

			
			; PORT D Init
			
			; 11 � 12 ������� (OC0B � OC0A) �������� ��� �����
			IN		R16, DDRD
			SBR		R16, (1<<PD5)|(1<<PD6)
			OUT		DDRD, R16

			; Buffers Init

			CLR		R16
			STS		IN_PTR_S, R16
			STS		IN_PTR_E, R16
			STS		OUT_PTR_S, R16
			STS		OUT_PTR_E, R16

			; PWM initialization

			LDI		R16, 0
			OUT		OCR0A, R16
			OUT		OCR0B, R16	

PwmInit:	OUTI	TCCR0A, (1<<COM0A1)|(0<<COM0A0)|(1<<COM0B1)|(0<<COM0B0)|(1<<WGM01)|(1<<WGM00)
			OUTI	TCCR0B, (1<<CS00)|(0<<WGM02)

			; Interrupts enabled

			SEI

; Main =====================================================
			
Main:		
Loops:		RCALL	Buff_Pop
			CPI		R19, 1
			BREQ	LOOPS

			RCALL	Msg

			MOV		R19, R17
			RCALL	Buff_Push

			CPI		R19, 1
			BRNE	Run
			;RCALL	Delay

Run:		TX_RUN
			RJMP	Main

; Procedures =====================================================

Msg:		CLI						; ������ �� ���������� 

			SBRC	R20, 4			; ��������-���� ���.��������
			RJMP	Spd

			; ��������� �������� �������� ����������
			CPI		R17, 'L'		; ����� ������ ����.
			BREQ	Left
			CPI		R17, 'R'		; ����� ������� ����.
			BREQ	Right
			CPI		R17, 'F'		; ���. ����. ��������
			BREQ	Forw			; ��������� - �����
			CPI		R17, 'B'		; ���. ����. ��������
			BREQ	Back			; ��������� - �����
			
			; ������� ��������� ��������
			CPI		R17, 'V'		; ����������
			BREQ	Voltage
			CPI		R17, 'T'		; �����������
			BREQ	Temp

			LDI		R17, 170		; ��������� ������
			RJMP	MsgOut

			; ����������� ��������

Temp:		LDI		R17, 21			; ������ �����������
			RJMP	MsgOut

Voltage:	LDI		R17, 12			; ������ ����������
			RJMP	MsgOut
			
Left:		CBR		R20, (1<<1)		; ��������-����� ����.
			LDI		R17, 'e'
			RJMP	MsgOut

Right:		SBR		R20, (1<<1)		; ��������-������ ����.
			LDI		R17, 'i'
			RJMP	MsgOut

Forw:		SBRS	R20, 1			; ������ ����� ����.
			SBR		R20, (1<<2)		; ����������� "�����"
			SBRC	R20, 1			; ������ ������ ����.
			SBR		R20, (1<<3)		; ����������� "�����"

			SBR		R20, (1<<4)		; ���� ���. ��������.
			RJMP	MsgOut

Back:		SBRC	R20, 1			; ������ ����� ����.
			CBR		R20, (1<<2)		; ����������� "�����"
			SBRS	R20, 1			; ������ ������ ����
			CBR		R20, (1<<3)		; ����������� "�����"

			SBR		R20, (1<<4)		; ���� ���. ��������.

			RJMP	MsgOut

Spd:		LDI		R16, 0			; ������������� PWM
			OUT		TCCR0A, R16
			OUT		TCCR0B, R16
			OUT		TCNT0, R16

			CBR		R20, (1<<4)		; ������� ���� ���. ����.

			SBRS	R20, 1			; ������������� ��������
			OUT		OCR0A, R17		; ������ ���������
			SBRC	R20, 1			; ������������� ��������
			OUT		OCR0B, R17		; ������� ���������
			
			; ������ �������������� PWM
			OUTI	TCCR0A, (1<<COM0A1)|(0<<COM0A0)|(1<<COM0B1)|(0<<COM0B0)|(1<<WGM01)|(1<<WGM00)
			OUTI	TCCR0B, (1<<CS00)|(0<<WGM02)

			IN		R17, OCR0A

MsgOut:		SEI
			RET		


Delay:		LDI		R16,LowByte
			LDI		R17,MedByte	
			LDI		R18,HighByte
 
loop:		SUBI	R16,1			
			SBCI	R17,0			
			SBCI	R18,0			
 
			BRCC	Loop

uart_snt:	LDS 	R17, UCSR0A
			SBRS	R17, UDRE0
			RJMP	PC-1

			STS		UDR0, R16
			RET


uart_rcv:	LDS		R17, UCSR0A
			SBRS	R17, RXC0
			RJMP	uart_rcv

			LDS		R16,UDR0
			RET


; EEPROM =====================================================
			.ESEG
