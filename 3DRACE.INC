	nolist

ex_scrsiz	equ	$E069
ex_dotmod	equ	$E06C
ex_scrmod	equ	$E06F
ex_imode	equ	$E072
ex_vmode	equ	$E075
ex_hmode	equ	$E078
ex_vsync	equ	$E07B
ex_joysns	equ	$E063
_ax		equ	$20F8
_al		equ	$20F8
_ah		equ	$20F9
_bx		equ	$20FA
_bl		equ	$20FA
_bh		equ	$20FB
_cx		equ	$20FC
_cl		equ	$20FC
_ch		equ	$20FD
_dx		equ	$20FE
_dl		equ	$20FE
_dh		equ	$20FF
joytrg		equ	$222D
joy		equ	$2228
dv_System	equ	$4000
dv_Standby	equ	$4003
dv_GetVdp	equ	$4006
dv_SetVdp	equ	$4009
dv_Vpoke	equ	$400C
dv_Vpeek	equ	$400F
dv_Ram2VRam	equ	$4012
dv_VRam2Ram	equ	$4015
dv_FillVram	equ	$4018
dv_Ram2Plt	equ	$401B
dv_Plt2Ram	equ	$401E
dv_Screen1	equ	$4021
MA_MUL16U	equ	$E0C3

; Main System Staytus

P_X	EQU	$2000	; Now Player X_Point
P_Y	EQU	$2002	; Now Player Y_Point
FX	EQU	$2031
FY	EQU	$2033
RAZIAN	EQU	$2004	; Now Player direction
SPEED 	EQU	$2005	; Now Player Speed
SPRD	EQU	$2007	; SPEER direction
SHOCK	EQU	$2008	; cllide staytus

; Main System use bektor 

SPYY	EQU	$2009	; SPEED VECTOR Y ( 2009 - 2012 )
SPYX	EQU	$2013   ; SPEED VECTOR X ( 2013 - 201C )
YX	EQU	$201D   ; direction X vektor
YY	EQU	$201F	; direction Y vektor

; Sub Routine Work

XX	EQU	$2021
XY	EQU	$2023
DX	EQU	$2025
DY	EQU	$2027
BX	EQU	$2029
BY	EQU	$202B
NUMBER	EQU	$202D	; 1 byte
SIZE	EQU	$202E	; 2 bytes
NOW_P	EQU	$2030	; 2 bytes

_stwi	macro	@mem,@imm
	pha
	lda	#high (@imm)
	sta	@mem+1
	lda	#low (@imm)
	sta	@mem
	pla
	endm

_stwx	macro	@mem,@mm2
	pha
	lda	@mm2,X
	sta	@mem
	lda	@mm2+1,X
	sta	@mem+1
	pla
	endm

_subw	macro	@mem,@mm2
	pha
	sec
	lda	@mem
	sbc	@mm2
	sta	@mem
	lda	@mem+1
	sbc	@mm2+1
	sta	@mem+1
	pla
	endm


_addw 	macro	@mem,@mm2
	pha
	clc
	lda	@mem
	adc	@mm2
	sta	@mem
	lda	@mem+1
	adc	@mm2+1
	sta	@mem+1
	pla
	endm


_movw	macro	@dst,@src
	pha
	lda	@src
	sta	@dst
	lda	@src+1
	sta	@dst+1
	pla
	endm

_incw	macro	@mem
	inc	@mem
	bne	@label
	inc	@mem+1
@label:
	endm

_decw	macro	@mem
	pha
	sec
	lda	@mem
	sbc	#1
	sta	@mem
	lda	@mem+1
	sbc	#0
	sta	@mem+1
	pla
	endm

cmpwi	macro	@mem,@imm
	lda	@mem+1
	cmp	#high (@imm)
	bne	@label
	lda	@mem
	cmp	#low (@imm)
@label:
	endm

_addwi	macro	@mem,@imm
	pha
	clc
	lda	@mem
	adc	#low(@imm)
	sta	@mem
	lda	@mem+1
	adc	#high(@imm)
	sta	@mem+1
	pla
	endm

_subwi	macro	@mem,@imm
	pha
	sec
	lda	@mem
	sbc	#low (@imm)
	sta	@mem
	lda	@mem+1
	sbc	#high (@imm)
	sta	@mem+1
	pla
	endm

	List
