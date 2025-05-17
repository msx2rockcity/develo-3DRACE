	INCLUDE "3DRACE.INC"

CHAMAK		EQU	$6000
VISUAL		EQU	$60C0
VIWORK		EQU	$61CA
GET_UNIT	EQU	$65CA
GET_BDX		EQU	$65F0
gx_mul		EQU	$675F
GET_POINT	EQU	$6790
sindata		EQU	$67E3
plt_dat		EQU	$6AE3

	ORG	$7000

;-------------------------------------------
; MAIN ROUTINE START
;-------------------------------------------
MAIN:
	JSR	INIT
	JSR	CHAMAK
	JSR	MNSTART
	
MAINLOOP:
	JSR	KEY
	JSR	GET_VEC
	JSR	SEARCH_M
MNSTART:
	_movw	FX,P_X
	_movw	FY,P_Y
	
	JSR	GET_UNIT
	JSR	VISUAL
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
	
	_stwi	_ax,VIWORK	; VIJUAL WORK CLEAR
	_stwi	_bx,1024
	CLY
in_loop2:
	CLX
in_loop1:
	LDA	#$01
	CPX	#20
	BCS	in_skip1
	CPY	#10
	BCS	in_skip1
	LDA	#$11
in_skip1:
	STA	(_ax)
	_incw	_ax
	INX
	CPX	#64
	BCC	in_loop1
	INY
	CPY	#16
	BCC	in_loop2
	
	LDA	#28
	STZ	P_X
	STA	P_X+1
	LDA	#28
	STZ	P_Y
	STA	P_Y+1
	STZ	RAZIAN
	STZ	SPRD
	STZ	SHOCK
	STZ	SPEED
	
	ply
	plx
	pla
	rts
	ds	32

;-------------------------------------------
; KEY CONTROLL routine
;-------------------------------------------

KEY:
	TST	#128,joy	; LEFT BOTTON
	BEQ	ky_skip1
	LDA	RAZIAN
	INC	A
	INC	A
	AND	#63
	STA	RAZIAN
ky_skip1:
	TST	#32,joy		; RIGHT BOTTON
	BEQ	ky_skip2
	LDA	RAZIAN
	DEC	A
	DEC	A
	AND	#63
	STA	RAZIAN
ky_skip2:
	TST	#$FF,SHOCK	; Now SHOCK = 0 ?
	BEQ	ky_skipS
	DEC	SHOCK
	BRA	ky_skipT
ky_skipS:
	TST	#1,joy		; I BOTTON
	BEQ	ky_skipT
	LDA	RAZIAN
	STA	SPRD
	_addwi	SPEED,25
	TST	#$02,SPEED+1
	BEQ	ky_skip3
	_stwi	SPEED,511	; SPEED OVER 
	BRA	ky_skip3
ky_skipT:
	_subwi	SPEED,8		; I BOTTON = NONE or SHOCK NOW
	TST	#$80,SPEED+1	; SPEED DOWN
	BEQ	ky_skip3
	STZ	SPEED
	STZ	SPEED+1
	STZ	SHOCK
ky_skip3:
	TST	#12,joy		; RESET
	BEQ	ky_skip4
	JMP	dv_System
ky_skip4:
	RTS

;-------------------------------------------
; touch routine
;-------------------------------------------

SEARCH_M:
	CLA
	ORA	SPEED
	ORA	SPEED+1
	BNE	sm_skip
	RTS
sm_skip:
	TST	#$FF,SPEED+1
	BEQ	sm_skip2
sm_skip1:
	_movw	FX,P_X
	_movw	FY,P_Y
	JSR	GET_VEC
	_addw	FX,SPYX+4
	_addw	FY,SPYY+4
	JSR	SEARCH
	TST	#$FF,TUCH
	BNE	sm_skip1
	_movw	P_X,FX
	_movw	P_Y,FY
	JSR	sm_skip3
sm_skip2:
	_movw	FX,P_X
	_movw	FY,P_Y
	JSR	GET_VEC
sm_skip3:
	LDA	SPEED
	STA	_bl
	STZ	_bh
	_movw	_ax,SPYX+4
	JSR	gx_mul
	_addw	FX,_ch
	_movw	_ax,SPYY+4
	JSR	gx_mul
	_addw	FY,_ch
	JSR	SEARCH
	TST	#$FF,TUCH
	BNE	sm_skip2
	_movw	P_X,FX
	_movw	P_Y,FY
	RTS
	
SEARCH:
	STZ	TUCH	; TUCH FLUG
	CLX		; LOOP COUNT
	LDY	#$E2	; RAZIAN OFFSET
se_loop:
	LDA	SPYX,X	; SEARCH POINT SET to BX,BY
	CLC
	ADC	FX
	STA	BX
	LDA	SPYX+1,X
	ADC	FX+1
	STA	BX+1
	
	LDA	SPYY,X
	CLC
	ADC	FY
	STA	BY
	LDA	SPYY+1,X
	ADC	FY+1
	STA	BY+1
	
	JSR	GET_POINT
	CMP	#0
	BEQ	se_skip		; IF NO TUCH JUMP
	
	TST	#$FF,TUCH
	BEQ	se_skip2
	
	TYA
	CLC
	ADC	SPRD
	AND	#63
	STA	SPRD
	CLY
	BRA	se_skip
se_skip2:
	TST	#$FF,SHOCK	; FAST TUCH
	BNE	se_skip1
	LDA	#5
	STA	SHOCK
se_skip1:
	INC	TUCH
	TYA
	ASL	A
	CLC
	ADC	SPRD
	AND	#63
	STA	SPRD
	CLY
se_skip:
	INX
	INX
	TYA
	CLC
	ADC	#7
	TAY
	CPX	#10
	BCC	se_loop
	RTS
	
TUCH:	DB	0

;-------------------------------------------
; GET_VECTOR ( SPYY & SPYX )
;-------------------------------------------

GET_VEC:
	PHA
	PHX
	PHY
	
	LDA	SPRD
	SEC
	SBC	#14
	AND	#63
	ASL	A
	CLX
VE_loop:
	TAY
	LDA	sindata,Y
	STA	SPYY,X
	LDA	sindata+1,Y
	STA	SPYY+1,X
	PHY
	TYA
	CLC
	ADC	#32
	AND	#127
	TAY
	LDA	sindata,Y
	STA	SPYX,X
	LDA	sindata+1,Y
	STA	SPYX+1,X
	PLA
	CLC
	ADC	#14
	AND	#127
	INX
	INX
	CPX	#10
	BCC	VE_loop
	
	PLY
	PLX
	PLA
	RTS

