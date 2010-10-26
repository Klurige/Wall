#INCLUDE qtqy_registers.inc

Ram	EQU $0080
Flash	EQU $F800
Vectors	EQU $FFDE

	ORG Ram
cycle	ds 1

	ORG Flash
init	
	mov	#$01,CONFIG2	;Osc disable on stop, SCI clock source internal
	mov	#$01,CONFIG1	;COP disabled, all other default (see p142)

	mov	#$00,OSCSTAT	; Internal clock, 4.0MHz
	lda	#$02
	sta	OSCTRIM
	; TOF=0, TOIE=1, TSTOP=1, TRST=1,PS2,1,0=000
	bset	5,TSC	; TSTOP=1
	bset	4,TSC	; TRST=1
	bclr	2,TSC	; PRESCALER=000
	bclr	1,TSC
	bclr	0,TSC
	bset	6,TSC	; TOIE=1


	mov	#$00,TMODH
	mov	#104,TMODL	; Period =  1/38kHz
	mov	#$00,TCH0H
	mov	#52,TCH0L	; On for half the period, off for half.

	bset	6,TSC0	; CH0IE=1
	bclr	5,TSC0	; MS0B=0
	bset	4,TSC0	; MS0A=1
	bclr	3,TSC0	; ELS0B=0
	bclr	2,TSC0	; ELS0A=0
	bclr	1,TSC0	; TOV0=0
	bclr	0,TSC0	; CH0MAX=0
	
	
	mov	#$00,TSC1	; Disabled

	mov	#38,cycle	; Period = 76 cycles, Hex 4C cycles;

	cli
	bclr	5,TSC		; Start timer by resetting TSTOP, keep other bits.

	clra			;clears A, X, and H regs
	clrx
	clrh

	mov #$00,PORTA		;sets port A data register to 0 for all bits
	mov #$FF,DDRA		;sets port A to be all output

main
	wait
	bra	main
	bset	4,PORTA		; turn on PTA4
	bsr delay		; delay for one sec
	bclr	4,PORTA		; turn all off
	bsr delay		; delay for one sec
	bra main		; loop back to main

delay
	clra
loop2	psha
	clra
loop1	dbnza loop1
	pula
	dbnza loop2
	rts

TimerToggle
	; Acknowledge interrupt
	bclr	7,TSC0
	; Half a period. Switch off PTA0
	bclr	0,PORTA
	rti

TimerOverflow
	; Acknowledge interrupt
	bclr	7,TSC
	; Full period. Switch on PTA0
	brclr	1,PORTA,tmoOff
	bset	0,PORTA
tmoOff
	; Every 38 cycles, PTA1 should be toggled
	dbnz	cycle,tmoRet
	mov	#38,cycle	
	brset	1,PORTA,tmoClear
	bset	1,PORTA
tmoRet
	rti
tmoClear
	bclr	1,PORTA
	rti

	ORG Vectors
	dw init			; ADC Conversion complete
	dw init			; Keyboard
	dw init			; Not used
	dw init			; Not used
	dw init			; Not used
	dw init			; Not used
	dw init			; Not used
	dw init			; Reserved
	dw init			; Not used
	dw init			; Not used
	dw TimerOverflow	; TIM overflow
	dw init			; TIM channel 1
	dw TimerToggle		; TIM channel 0
	dw init			; Not used
	dw init			; IRQ
	dw init			; SWI
	dw init			; Reset

