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


; Прерывание по приёму данных.

RX_OK:		PUSHF				; Макрос, пихающий в стек SREG и R16
			PUSH	R17
			PUSH	R18
			PUSH	XL
			PUSH	XH
 
			LDI		XL,low(IN_buff)		; Берем адрес начала буффера
			LDI		XH,high(IN_buff)
			LDS		R16,IN_PTR_E		; Берем смещение точки записи
			LDS		R18,IN_PTR_S		; Берем смещение точки чтения
 
			ADD		XL,R16				; Сложением адреса со смещением
			CLR		R17					; получаем адрес точки записи
			ADC		XH,R17
 
			LDS		R17,UDR0			; Забираем данные
			ST		X,R17				; сохраняем их в кольцо
 
			INC		R16					; Увеличиваем смещение
 
			CPI		R16,MAXBUFF_IN		; Если достигли конца 
			BRNE	NoEnd
			CLR		R16					; переставляем на начало
 
NoEnd:		CP		R16,R18				; Дошли до непрочитанных данных?
			BRNE	RX_OUT				; Если нет, то просто выходим
 
 
RX_FULL:	LDI		R18,1				; Если да, то буффер переполнен.
			STS		IN_FULL,R18			; Записываем флаг наполненности
 
RX_OUT:		STS		IN_PTR_E,R16		; Сохраняем смещение. Выходим
 
			POP		XH
			POP		XL
			POP		R18
			POP		R17
			POPF						; Достаем SREG и R16
			RETI

; Прерывание по передаче данных.

TX_OK:		nop
			nop
			nop
			RETI

; Прерывание по опустошению буффера.

UD_OK:		PUSHF						
			PUSH	R17
			PUSH	R18
			PUSH	R19
			PUSH	XL
			PUSH	XH
 
 
			LDI		XL,low(OUT_buff)	; Берем адрес начала буффера
			LDI		XH,high(OUT_buff)
			LDS		R16,OUT_PTR_E		; Берем смещение точки записи
			LDS		R18,OUT_PTR_S		; Берем смещение точки чтения			
			LDS		R19,OUT_FULL		; Берм флаг переполнения
 
			CPI		R19,1				; Если буффер переполнен, то указатель начала
			BREQ 	NeedSend			; Равер указателю конца. Это надо учесть.
	 
			CP		R18,R16				; Указатель чтения достиг указателя записи?
			BRNE	NeedSend			; Нет! Буффер не пуст. Надо слать дальше
 
 			; Запрет прерывания
			LDI 	R16,(1<<RXEN0)|(1<<TXEN0)|(1<<RXCIE0)|(1<<TXCIE0)|(0<<UDRIE0)
			STS 	UCSR0B, R16			; По пустому UDR
			RJMP 	TX_OUT				; Выходим
 
NeedSend:	CLR		R17					; Получаем ноль
			STS		OUT_FULL,R17		; Сбрасываем флаг переполнения
 
			ADD		XL,R18				; Сложением адреса со смещением
			ADC		XH,R17				; получаем адрес точки чтения
 
			LD		R17,X				; Берем байт из буффера
			STS		UDR0,R17			; Отправляем его в USART
 
			INC		R18					; Увеличиваем смещение указателя чтения
 
			CPI		R18,MAXBUFF_OUT		; Достигли конца кольца?
			BRNE	TX_OUT				; Нет? 
 
			CLR		R18					; Да? Сбрасываем, переставляя на 0
 
TX_OUT:		STS		OUT_PTR_S,R18		; Сохраняем указатель
 
			POP		XH
			POP		XL
			POP		R19
			POP		R18
			POP		R17
			POPF						; Выходим, достав все из стека
			RETI


; Load Loop Buffer 
; IN R19 	- DATA
; OUT R19 	- ERROR CODE 
Buff_Push:	CLI 						; Запрет прерываний. 
			LDI		XL,low(OUT_buff)	; Берем адрес начала буффера
			LDI		XH,high(OUT_buff)
			LDS		R16,OUT_PTR_E		; Берем смещение точки записи
			LDS		R18,OUT_PTR_S		; Берем смещение точки чтения
 
			ADD		XL,R16				; Сложением адреса со смещением
			CLR		R17					; получаем адрес точки записи
			ADC		XH,R17
 
 
			ST		X,R19				; сохраняем их в кольцо
			CLR		R19					; Очищаем R19, теперь там код ошибки
										; Который вернет подпрограмма
 
			INC		R16					; Увеличиваем смещение
 
			CPI		R16,MAXBUFF_OUT		; Если достигли конца 
			BRNE	_NoEnd
			CLR		R16					; переставляем на начало
 
_NoEnd:		CP		R16,R18				; Дошли до непрочитанных данных?
			BRNE	_RX_OUT				; Если нет, то просто выходим
 
 
_RX_FULL:	LDI		R19,1				; Если да, то буффер переполнен.
			STS		OUT_FULL,R19		; Записываем флаг наполненности
			; В R19 остается 1 - код ошибки переполнения
 
_RX_OUT:	STS		OUT_PTR_E,R16		; Сохраняем смещение. Выходим
			SEI 						; Разрешение прерываний
			RET

; Read from loop Buffer
; IN: NONE
; OUT: 	R17 - Data,
;		R19 - ERROR CODE
 
Buff_Pop: 	CLI 					; Запрещаем прерыания. 
									; Но лучше запретить прерывания конкретно  от 
									; UART, чем запрещать вообще все.
			LDI		XL,low(IN_buff)	; Берем адрес начала буффера
			LDI		XH,high(IN_buff)
			LDS		R16,IN_PTR_E	; Берем смещение точки записи
			LDS		R18,IN_PTR_S	; Берем смещение точки чтения			
			LDS		R19,IN_FULL		; Берм флаг переполнения
 
			CPI		R19,1			; Если буффер переполнен, то указатель начала
			BREQ	NeedPop			; Равен указателю конца. Это надо учесть.
 
			CP		R18,R16			; Указатель чтения достиг указателя записи?
			BRNE	NeedPop			; Нет! Буффер не пуст. Работаем дальше
 
			LDI		R19,1			; Код ошибки - пустой буффер!
 
			RJMP	_TX_OUT			; Выходим
 
NeedPop:	CLR		R17				; Получаем ноль
			STS		IN_FULL,R17		; Сбрасываем флаг переполнения
 
			ADD		XL,R18			; Сложением адреса со смещением
			ADC		XH,R17			; получаем адрес точки чтения
 
			LD		R17,X			; Берем байт из буффера
			CLR		R19				; Сброс кода ошибки
 
			INC		R18				; Увеличиваем смещение указателя чтения
 
			CPI		R18,MAXBUFF_OUT	; Достигли конца кольца?
			BRNE	_TX_OUT			; Нет? 
 
			CLR		R18				; Да? Сбрасываем, переставляя на 0
 
_TX_OUT:	STS		IN_PTR_S,R18	; Сохраняем указатель
			SEI						; Разрешаем прерывания
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

			; Регистр UCSR0A.
			LDI		R16, 0
			STS		UCSR0A, R16

			; Регистр UCSR0B, разрешаем прерывания, приём и передачу данных.
			; кроме прерывания по опустошению регистра данных.
			LDI		R16, (1<<RXCIE0)|(1<<TXCIE0)|(0<<UDRIE0)|(1<<RXEN0)|(1<<TXEN0)
			STS		UCSR0B, R16
			
			; Регистр UCSR0C.
			; Формат кадра - 8 бит, 1 стоп бит, асинхронный режим.
			LDI		R16, (1<<UMSEL01)|(1<<UCSZ00)|(1<<UCSZ01)
			STS		UCSR0C, R16

			
			; PORT D Init
			
			; 11 и 12 контакт (OC0B и OC0A) работает как выход
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

Msg:		CLI						; Запрет на прерывания 

			SBRC	R20, 4			; Проверка-флаг уст.скорости
			RJMP	Spd

			; Установка скорости вращения двигателей
			CPI		R17, 'L'		; Выбор левого двиг.
			BREQ	Left
			CPI		R17, 'R'		; Выбор правого двиг.
			BREQ	Right
			CPI		R17, 'F'		; Выб. напр. движения
			BREQ	Forw			; двигатель - вперёд
			CPI		R17, 'B'		; Выб. напр. движения
			BREQ	Back			; двигатель - назад
			
			; Снимаем показания датчиков
			CPI		R17, 'V'		; Напряжение
			BREQ	Voltage
			CPI		R17, 'T'		; Температуры
			BREQ	Temp

			LDI		R17, 170		; Сообщение ошибки
			RJMP	MsgOut

			; Обработчики запросов

Temp:		LDI		R17, 21			; Датчик температуры
			RJMP	MsgOut

Voltage:	LDI		R17, 12			; Датчик напряжения
			RJMP	MsgOut
			
Left:		CBR		R20, (1<<1)		; Выбираем-левый двиг.
			LDI		R17, 'e'
			RJMP	MsgOut

Right:		SBR		R20, (1<<1)		; Выбираем-правый двиг.
			LDI		R17, 'i'
			RJMP	MsgOut

Forw:		SBRS	R20, 1			; Выбран левый двиг.
			SBR		R20, (1<<2)		; Направление "вперёд"
			SBRC	R20, 1			; Выбран правый двиг.
			SBR		R20, (1<<3)		; Направление "вперёд"

			SBR		R20, (1<<4)		; Флаг уст. скорости.
			RJMP	MsgOut

Back:		SBRC	R20, 1			; Выбран левый двиг.
			CBR		R20, (1<<2)		; Направление "назад"
			SBRS	R20, 1			; Выбран правый двиг
			CBR		R20, (1<<3)		; Направление "назад"

			SBR		R20, (1<<4)		; Флаг уст. скорости.

			RJMP	MsgOut

Spd:		LDI		R16, 0			; Останавливаем PWM
			OUT		TCCR0A, R16
			OUT		TCCR0B, R16
			OUT		TCNT0, R16

			CBR		R20, (1<<4)		; Снимаем флаг уст. скор.

			SBRS	R20, 1			; Устанавливаем скорость
			OUT		OCR0A, R17		; левого двигателя
			SBRC	R20, 1			; Устанавливаем скорость
			OUT		OCR0B, R17		; правого двигателя
			
			; Заново инициализируем PWM
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
