	INCLUDE "3DRACING.H"

NOW_P	EQU	$2050
YX	EQU	$2052
YY	EQU	$2054

	ORG	$6000

;-------------------------------------------
; MAIN ROUTINE START
;-------------------------------------------
MAIN:
	JSR	INIT
	JSR	CHAMAK
	
	_stwi	_ax,VIWORK
	_stwi	_bx,1024
	CLY
mn_loop2:
	CLX
mn_loop1:
	LDA	#$01
	CPX	#20
	BCS	mn_skip1
	CPY	#10
	BCS	mn_skip1
	LDA	#$11
mn_skip1:
	STA	(_ax)
	_incw	_ax
	INX
	CPX	#64
	BCC	mn_loop1
	INY
	CPY	#16
	BCC	mn_loop2
	
	LDA	#32
	STZ	P_X
	STA	P_X+1
	STZ	P_Y
	STA	P_Y+1
	STZ	RAZIAN
	
MAINLOOP:
	JSR	GET_UNIT
	JSR	VISUAL
	JSR	KEY
	BRA	MAINLOOP

;-------------------------------------------
; INIT ROUTINE
;-------------------------------------------

INIT:
	pha
	phx
	phy
	
	cla
	jsr	ex_dotmod
	cla
	jsr	ex_scrsiz	; M_screen size 32x32 
	
	cla			; 5MHz
	ldx	32		; screen_X_axis
	ldy	24		; screen_Y_axis
	jsr	ex_scrmod
	
	_stwi	_ax,plt_dat
	_stwi	_bx,0
	_stwi	_cx,32
	jsr	dv_Ram2Plt	; Palette 0 set
	
	ply
	plx
	pla
	rts

;-------------------------------------------
; character making  ( $1000 - $1FFF )
;-------------------------------------------

CHAMAK:
	pha
	phx
	phy
	
	clx
	lda	#$FF
cm_clear2:
	sta	cm_work+16,x
	inx
	cpx	#16
	bcc	cm_clear2
	
	cla
cm_loop4:
	sta	_ah	; character number
	pha
	
	clx
cm_clear:
	stz	cm_work,x
	inx
	cpx	#16
	bcc	cm_clear	; work clear
	
	clx
cm_loop3:
	phx
	sax
	ldy	#$F0
	bit	#$01
	beq	cm_skip1
	ldy	#$0F	; mask set
cm_skip1:	
	ldx	#1
	bit	#$02
	beq	cm_skip2
	ldx	#9	; work offset
cm_skip2:	
	say
	tst	#$80,_ah
	beq	cm_skip3
	phx
	cly
cm_loop1:
	pha
	ora	cm_work,x
	sta	cm_work,x
	pla
	inx
	inx
	iny
	cpy	#4
	bcc	cm_loop1
	plx
cm_skip3:
	dex
	tst	#$40,_ah
	beq	cm_skip4
	cly
cm_loop2:
	pha
	ora	cm_work,x
	sta	cm_work,x
	pla
	inx
	inx
	iny
	cpy	#4
	bcc	cm_loop2
cm_skip4:
	rol	_ah
	rol	_ah
	plx
	inx
	cpx	#4
	bcc	cm_loop3
	
	pla
	pha
	_stwi	_ax,cm_work
	_stwi	_cx,16
	sta	_bl
	lda	#1
	sta	_bh
	asl	_bl
	rol	_bh
	asl	_bl
	rol	_bh
	asl	_bl
	rol	_bh
	asl	_bl
	rol	_bh
	jsr	dv_Ram2VRam	; copy to VRam
	pla
	inc	a
	beq	cm_ret
	jmp	cm_loop4
	
cm_ret:
	ply
	plx
	pla
	rts
	
cm_work:
	ds	32

;-------------------------------------------
; KEY CONTROLL routine
;-------------------------------------------

KEY:	
	TST	#$AD,joy
	BEQ	KEY
	
	TST	#128,joy
	BEQ	ky_skip1
	LDA	RAZIAN
	INC	A
	INC	A
	AND	#63
	STA	RAZIAN
ky_skip1:
	TST	#32,joy
	BEQ	ky_skip2
	LDA	RAZIAN
	DEC	A
	DEC	A
	AND	#63
	STA	RAZIAN
ky_skip2:
	TST	#1,joy
	BEQ	ky_skip3
	_addw	P_X,YX
	_addw	P_Y,YY
	_addw	P_X,YX
	_addw	P_Y,YY
ky_skip3:
	TST	#12,joy
	BEQ	ky_skip4
	JMP	dv_System
ky_skip4:
	RTS

;-------------------------------------------
; COURSE WRITE ROUTINE
;-------------------------------------------
VISUAL:	PHA
	PHX
	PHY
	
	_stwi	NOW_P,VIWORK
	LDA	#31
	STA	NUMBER
	CLX
vi_loop:
	JSR	GET_BDX
	CLY
vi_loop1:
	LDA	(NOW_P),Y
	ASL	A
	ASL	A
	STA	_al
	JSR	GET_POINT
	ORA	_al
	
	_addw	BX,DX
	_addw	BY,DY
	
	ASL	A
	ASL	A
	STA	_al
	JSR	GET_POINT
	ORA	_al
	STA	(NOW_P),Y
	
	_addw	BX,DX
	_addw	BY,DY
	
	INY
	INY
	CPY	#64
	BCC	vi_loop1
	
	DEC	NUMBER
	JSR	GET_BDX
	CLY
vi_loop2:
	LDA	(NOW_P),Y
	ASL	A
	ASL	A
	STA	_al
	JSR	GET_POINT
	ORA	_al
	
	_addw	BX,DX
	_addw	BY,DY
	
	ASL	A
	ASL	A
	STA	_al
	JSR	GET_POINT
	ORA	_al
	STA	(NOW_P),Y
	
	_addw	BX,DX
	_addw	BY,DY
	
	INY
	INY
	CPY	#64
	BCC	vi_loop2
	
	_addwi	NOW_P,64
	DEC	NUMBER
	INX
	CPX	#16
	BEQ	vi_ret
	JMP	vi_loop
	
vi_ret:
	_stwi	_ax,VIWORK
	_stwi	_bx,128
	_stwi	_cx,512
	JSR	dv_Ram2VRam
	PLY
	PLX
	PLA
	RTS

VIWORK:	DS	1024

;-------------------------------------------
; UNIT vektor to ( YX & YY )
;-------------------------------------------

GET_UNIT:
	PHA
	PHX
	
	LDA	RAZIAN
	ASL	A
	TAX
	_stwx	YY,sindata
	TXA
	CLC
	ADC	#32
	AND	#127
	TAX
	_stwx	YX,sindata
	
	PLX
	PLA
	RTS

;-------------------------------------------
; GET ( BX,BY & DX,DY ) ROUTINE
;-------------------------------------------

GET_BDX:
	PHA
	PHX
	PHY
	
	LDA	NUMBER
	ASL	A
	TAX
	_stwx	_bx,vektor
	
	_movw	_ax,YX
	JSR	gx_mul
	_movw	XX,_ch
	
	_movw	_ax,YY
	JSR	gx_mul
	_movw	XY,_ch
	
	LDA	#$FF
	EOR	XX
	STA	DY
	LDA	#$FF
	EOR	XX+1
	STA	DY+1
	_incw	DY
	LDA	DY
	AND	#$E0
	STA	DY
	
	_movw	DX,XY
	LDA	DX
	AND	#$E0
	STA	DX
	
	_movw	BX,P_X
	_addw	BX,XX
	_subw	BX,DX
	
	_movw	BY,P_Y
	_addw	BY,XY
	_subw	BY,DY
	
	LSR	DX+1
	ROR	DX
	LSR	DX+1
	ROR	DX
	LSR	DX+1
	ROR	DX
	LSR	DX+1
	ROR	DX
	LSR	DX+1
	ROR	DX
	TST	#$04,DX+1
	BEQ	gx_skip
	LDA	#$F8
	TSB	DX+1
gx_skip:
	LSR	DY+1
	ROR	DY
	LSR	DY+1
	ROR	DY
	LSR	DY+1
	ROR	DY
	LSR	DY+1
	ROR	DY
	LSR	DY+1
	ROR	DY
	TST	#$04,DY+1
	BEQ	gx_skip2
	LDA	#$F8
	TSB	DY+1
gx_skip2:
	PLY
	PLX
	PLA
	RTS
	
gx_mul:
	TST	#$80,_ah
	BEQ	gx_ml_plus
	LDA	#$FF
	EOR	_ah
	STA	_ah
	LDA	#$FF
	EOR	_al
	STA	_al
	_incw	_ax
	
	JSR	MA_MUL16U
	
	LDA	#$FF
	EOR	_ch
	STA	_ch
	LDA	#$FF
	EOR	_dl
	STA	_dl
	_incw	_ch
	RTS
	
gx_ml_plus:
	JSR	MA_MUL16U
	RTS

;-------------------------------------------
; GET POINT COLOR ( X , Y )  TO  A
;-------------------------------------------

GET_POINT:
	PHX
	PHY
	
	LDX	BX+1
	CPX	#64
	BCS	gp_ret
gp_skip1:	
	LDY	BY+1
	CPY	#64
	BCC	gp_skip2
	
gp_ret:	LDA	#3
	PLY
	PLX
	RTS
	
gp_skip2:
	PHY
	TYA
	AND	#$38
	STA	_ah
	TXA
	LSR	A
	LSR	A
	LSR	A
	ORA	_ah
	TAY
	TXA
	AND	#$07
	STA	_ah
	PLA
	ASL	A
	ASL	A
	ASL	A
	AND	#$38
	ORA	_ah
	TAX
	
	LDA	MAPDATA,Y
	ASL	A
	TAY
	LDA	SENTOW,Y
	STA	_chgpt+1
	LDA	SENTOW+1,Y
	STA	_chgpt+2
_chgpt:	LDA	$FFFF,X
	PLY
	PLX
	RTS

SENTOW:
	DW	CHARA_1,CHARA_2,CHARA_3,CHARA_4
	DW	CHARA_5,CHARA_6,CHARA_7

;-------------------------------------------
; SIN & VEKTOR DATA
;-------------------------------------------

sindata:
	dw	$0000,$0019,$0031,$004A,$0061,$0078,$008E,$00A2
	dw	$00B5,$00C5,$00D4,$00E1,$00EC,$00F4,$00FB,$00FE
	dw	$0100,$00FE,$00FB,$00F4,$00EC,$00E1,$00D4,$00C5
	dw	$00B5,$00A2,$008E,$0078,$0061,$004A,$0031,$0019
	dw	$0000,$FFE7,$FFCF,$FFB6,$FF9F,$FF88,$FF72,$FF5E
	dw	$FF4B,$FF3B,$FF2C,$FF1F,$FF14,$FF0C,$FF05,$FF02
	dw	$FF00,$FF02,$FF05,$FF0C,$FF14,$FF1F,$FF2C,$FF3B
	dw	$FF4B,$FF5E,$FF72,$FF88,$FF9F,$FFB6,$FFCF,$FFE7

vektor:
	dw	$0300,$0318,$0333,$034F,$036D,$038E,$03B1,$03D7
	dw	$0400,$042C,$045D,$0492,$04CC,$050D,$0555,$05A5
	dw	$0600,$0666,$06DB,$0762,$0800,$08BA,$0999,$0AAA
	dw	$0C00,$0DB6,$1000,$1333,$1800,$2000,$3000,$6000

;-------------------------------------------
; COURSE CHARACTER DATA
;-------------------------------------------

CHARA_1:
	db	1,0,0,0,0,0,0,1
	db	2,0,0,0,0,0,0,2
	db	2,0,0,0,0,0,0,2
	db	1,0,0,0,0,0,0,1
	db	1,0,0,0,0,0,0,1
	db	2,0,0,0,0,0,0,2
	db	2,0,0,0,0,0,0,2
	db	1,0,0,0,0,0,0,1
CHARA_2:
	db	1,2,2,1,1,2,2,1
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db 	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db	1,2,2,1,1,2,2,1
CHARA_3:
	db	3,3,3,1,1,2,2,1
	db	3,3,2,0,0,0,0,0
	db	3,2,0,0,0,0,0,0
	db	1,0,0,0,0,0,0,0
	db	1,0,0,0,0,0,0,0
	db	2,0,0,0,0,0,0,0
	db	2,0,0,0,0,0,0,0
	db	1,0,0,0,0,0,0,0
CHARA_4:
	db	1,2,2,1,1,3,3,3
	db	0,0,0,0,0,2,3,3
	db	0,0,0,0,0,0,2,3
	db	0,0,0,0,0,0,0,1
	db	0,0,0,0,0,0,0,1
	db	0,0,0,0,0,0,0,2
	db	0,0,0,0,0,0,0,2
	db	0,0,0,0,0,0,0,1
CHARA_5:
	db	1,0,0,0,0,0,0,0
	db	2,0,0,0,0,0,0,0
	db	2,0,0,0,0,0,0,0
	db	1,0,0,0,0,0,0,0
	db	1,0,0,0,0,0,0,0
	db	3,2,0,0,0,0,0,0
	db	3,3,2,0,0,0,0,0
	db	3,3,3,1,1,2,2,1
CHARA_6:
	db	0,0,0,0,0,0,0,1
	db	0,0,0,0,0,0,0,2
	db	0,0,0,0,0,0,0,2
	db	0,0,0,0,0,0,0,1
	db	0,0,0,0,0,0,0,1
	db	0,0,0,0,0,0,2,3
	db	0,0,0,0,0,2,3,3
	db	1,2,2,1,1,3,3,3
CHARA_7:
	db	3,3,3,3,3,3,3,3
	db	3,3,3,3,3,3,3,3
	db	3,3,3,3,3,3,3,3
	db	3,3,3,3,3,3,3,3
	db	3,3,3,3,3,3,3,3
	db	3,3,3,3,3,3,3,3
	db	3,3,3,3,3,3,3,3
	db	3,3,3,3,3,3,3,3

;-------------------------------------------
; MAP DATA
;-------------------------------------------

MAPDATA:
	db	2,1,1,3,6,6,6,6
	db	0,6,6,0,6,6,6,6
	db	0,6,6,0,6,6,6,6
	db	4,1,1,0,1,1,1,3
	db	6,6,6,0,6,6,6,0
	db	6,6,6,0,6,6,6,0
	db	6,6,6,0,6,6,6,0
	db	6,6,6,4,1,1,1,5

;-------------------------------------------
; PALETTE_DATA
;-------------------------------------------

plt_dat:
	dw	0,0,0,0,0,0,0,0,0,0,0,0
	dw	$016D,$0038,$01FF,$0180
	dw	0,0,0,0,0,0,0,0,0,0,0,0
	dw	$00DC,$0028,$016C,$0100
