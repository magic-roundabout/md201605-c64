;
; MD201605
;

; Code and graphics by T.M.R/Cosine
; Music by aNdy/Cosine


; Select an output filename
		!to "md201605.prg",cbm


; Yank in binary data
		* = $1000
music		!binary "data/fletch_theme.prg",,2

		* = $4808
		!binary "data/tech_logo_0.chr"

		* = $5008
		!binary "data/tech_logo_1.chr"

		* = $5808
		!binary "data/tech_logo_2.chr"

		* = $6008
		!binary "data/tech_logo_3.chr"

		* = $6808
		!binary "data/tech_logo_4.chr"

		* = $7008
		!binary "data/tech_logo_5.chr"

		* = $7808
		!binary "data/tech_logo_6.chr"

		* = $a008
		!binary "data/tech_logo_3.chr"
		* = $a808
		!binary "data/rez_logo_1.chr"

		* = $9000
dycp_char	!binary "data/dycp_char.raw"


; Constants: raster split positions
rstr1p		= $00
rstr2p		= $44


; Labels
rn		= $50

cos_at_1	= $51
cos_at_2	= $52

cos_at_3	= $53
cos_offset_3	= $0d		; constant
cos_speed_3	= $03		; constant
scroll_x	= $54

rez_d016_cnt	= $55
rez_d018_cnt	= $56

tech_cos_work	= $60		; $30 bytes used

dycp_buffer	= $90		; $28 bytes used
dycp_cos_work	= $b8		; $28 bytes used

dycp_work	= $8808


; Add a BASIC startline
		* = $0801
		!word entry-2
		!byte $00,$00,$9e
		!text "2066"
		!byte $00,$00,$00


; Entry point at $0812
		* = $0812
entry		sei

		lda #$35
		sta $01

		lda #<nmi
		sta $fffa
		lda #>nmi
		sta $fffb

		lda #<int
		sta $fffe
		lda #>int
		sta $ffff

		lda #$7f
		sta $dc0d
		sta $dd0d

		lda $dc0d
		lda $dd0d

		lda #rstr1p
		sta $d012

		lda #$1b
		sta $d011
		lda #$01
		sta $d019
		sta $d01a


; Clear zero page workspace
		ldx #$50
		lda #$00
nuke_zp		sta $00,x
		inx
		bne nuke_zp

; Zero the screen and colour RAM areas
		ldx #$00
		txa
clear_screen	sta $4000,x
		sta $4100,x
		sta $4200,x
		sta $42e8,x
		sta $8000,x
		sta $8100,x
		sta $8200,x
		sta $82e8,x
		sta $d800,x
		sta $d900,x
		sta $da00,x
		sta $dae8,x
		inx
		bne clear_screen

; Generate the various 40 by 6 character areas on screen
		ldx #$00
		lda #$01
		clc
screen_gen	sta $4078,x
		sta $8190,x
		sta $82a8,x
		adc #$01
		sta $40a0,x
		sta $81b8,x
		sta $82d0,x
		adc #$01
		sta $40c8,x
		sta $81e0,x
		sta $82f8,x
		adc #$01
		sta $40f0,x
		sta $8208,x
		sta $8320,x
		adc #$01
		sta $4118,x
		sta $8230,x
		sta $8348,x
		adc #$01
		sta $4140,x
		sta $8258,x
		sta $8370,x
		adc #$01
		inx
		cpx #$28
		bne screen_gen

		ldx #$00
screen_col_gen	lda #$0a
		sta $d878,x
		lda #$0d
		sta $d990,x
		lda #$0c
		sta $daa8,x
		inx
		cpx #$f0
		bne screen_col_gen

; Mask the areas between effects
		ldx #$00
		lda #$fe
mask_scrn_gen	sta $4050,x
		sta $4168,x
		sta $8168,x
		sta $8280,x
		sta $8398,x
		inx
		cpx #$28
		bne mask_scrn_gen

		ldx #$00
		lda #$0b
mask_col_gen	sta $d850,x
		sta $d968,x
		sta $da80,x
		sta $db98,x
		inx
		cpx #$28
		bne mask_col_gen

; Fill the second to last character of each set with $fe
		ldx #$00
		lda #$ff
mask_fill	sta $4ff0,x
		sta $57f0,x
		sta $5ff0,x
		sta $67f0,x
		sta $6ff0,x
		sta $77f0,x
		sta $7ff0,x
		sta $8ff0,x
		sta $a7f0,x
		sta $aff0,x
		inx
		cpx #$08
		bne mask_fill

; Init our variables
		lda #$01
		sta rn

; Reset the scroller
		jsr reset

; Init music
		ldx #$00
		stx $bfff
		txa
		tay
		jsr music+$00

		cli

; Infinite loop - runtime isn't needed
		jmp *


; IRQ interrupt
int		pha
		txa
		pha
		tya
		pha

		lda $d019
		and #$01
		sta $d019
		bne ya
		jmp ea31

ya		lda rn
		cmp #$02
		bne *+$05
		jmp rout2


; Raster split 1
rout1		lda #$02
		sta rn
		lda #rstr2p
		sta $d012

		lda #$0b
		sta $d020
		lda #$0e
		sta $d021

		lda #$c6
		sta $dd00

		jsr dycp_draw

; Play the music
		jsr music+$03

		jmp ea31


		* = $1a00

; Raster split 2
rout2		nop
		nop
		nop
		nop
		nop
		bit $ea

; Line up for a cycle-accurate split (not needed, but tidy!)
		lda $d012
		cmp #rstr2p+$01
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		nop
		nop
		lda $d012
		cmp #rstr2p+$02
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		nop
		nop
		lda $d012
		cmp #rstr2p+$03
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		nop
		lda $d012
		cmp #rstr2p+$04
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		bit $ea
		nop
		lda $d012
		cmp #rstr2p+$05
		bne *+$02
;		sta $d020

		nop
		nop
		nop

		ldx #$09
		dex
		bne *-$01
		nop
		lda $d012
		cmp #rstr2p+$06
		bne *+$02
;		sta $d020


		lda #$0a
		sta $d021
		lda #$07
		sta $d022
		lda #$0f
		sta $d023

		ldx #$05
		dex
		bne *-$01

; Tech tech splitter loop
		ldx #$00
tech_splitter	lda d016_table,x
		ldy d018_table,x
		sta $d016
		sty $d018
		inx
		nop

		lda d016_table,x
		ldy d018_table,x
		sta $d016
		sty $d018
		inx
		ldy #$08
		dey
		bne *-$01
		nop
		nop

		lda d016_table,x
		ldy d018_table,x
		sta $d016
		sty $d018
		inx
		ldy #$08
		dey
		bne *-$01
		nop
		nop

		lda d016_table,x
		ldy d018_table,x
		sta $d016
		sty $d018
		inx
		ldy #$08
		dey
		bne *-$01
		nop
		nop

		lda d016_table,x
		ldy d018_table,x
		sta $d016
		sty $d018
		inx
		ldy #$08
		dey
		bne *-$01
		nop
		nop

		lda d016_table,x
		ldy d018_table,x
		sta $d016
		sty $d018
		inx
		ldy #$08
		dey
		bne *-$01
		nop
		nop

		lda d016_table,x
		ldy d018_table,x
		sta $d016
		sty $d018
		inx
		ldy #$08
		dey
		bne *-$01
		nop
		nop

		lda d016_table,x
		ldy d018_table,x
		sta $d016
		sty $d018
		inx
		ldy #$07
		dey
		bne *-$01
		nop

		cpx #$30
		beq *+$05
		jmp tech_splitter

; Set up some registers for the scroller
		lda scroll_x
		and #$03
		asl
		eor #$07
		sta $d016

		ldx #$03
		dex
		bne *-$01
		nop

		lda #$05
		sta $d021

		lda #$c5
		sta $dd00

		lda #$02
		sta $d018


; Generate new tech tech data
		ldx #$00
		lda cos_at_1
		clc
		adc #$02
		sta cos_at_1
		tay
curve_gen	lda tech_cosinus,y
		sta tech_cos_work,x
		tya
		clc
		adc #$03
		tay
		inx
		cpx #$30
		bne curve_gen

; Render new tech tech
		ldx #$00
tech_tech_gen	ldy tech_cos_work,x
		lda d016_decode,y
		sta d016_table,x
		lda d018_decode,y
		sta d018_table,x
		inx
		cpx #$30
		bne tech_tech_gen

; Long-ish wait for the dissolve effect colour and mode changes
		ldx #$dd
		dex
		bne *-$01

; Get ready for the dissolve effect
		lda #$0e
		sta $d021
		lda #$0d
		sta $d022
		lda #$03
		sta $d023

		lda #$c5
		sta $dd00

; Dissolve effect splitter loop
		ldx #$00
rez_splitter
rs_d016_mod_01	lda rez_d016_table,x
rs_d018_mod_01	ldy rez_d018_table,x
		sta $d016
		sty $d018
		inx
		nop

rs_d016_mod_02	lda rez_d016_table,x
rs_d018_mod_02	ldy rez_d018_table,x
		sta $d016
		sty $d018
		inx
		ldy #$08
		dey
		bne *-$01
		nop
		nop

rs_d016_mod_03	lda rez_d016_table,x
rs_d018_mod_03	ldy rez_d018_table,x
		sta $d016
		sty $d018
		inx
		ldy #$08
		dey
		bne *-$01
		nop
		nop

rs_d016_mod_04	lda rez_d016_table,x
rs_d018_mod_04	ldy rez_d018_table,x
		sta $d016
		sty $d018
		inx
		ldy #$08
		dey
		bne *-$01
		nop
		nop

rs_d016_mod_05	lda rez_d016_table,x
rs_d018_mod_05	ldy rez_d018_table,x
		sta $d016
		sty $d018
		inx
		ldy #$08
		dey
		bne *-$01
		nop
		nop

rs_d016_mod_06	lda rez_d016_table,x
rs_d018_mod_06	ldy rez_d018_table,x
		sta $d016
		sty $d018
		inx
		ldy #$08
		dey
		bne *-$01
		nop
		nop

rs_d016_mod_07	lda rez_d016_table,x
rs_d018_mod_07	ldy rez_d018_table,x
		sta $d016
		sty $d018
		inx
		ldy #$08
		dey
		bne *-$01
		nop
		nop

rs_d016_mod_08	lda rez_d016_table,x
rs_d018_mod_08	ldy rez_d018_table,x
		sta $d016
		sty $d018
		inx
		ldy #$07
		dey
		bne *-$01
		nop

		cpx #$30
		beq *+$05
		jmp rez_splitter

		lda #$00
		sta $d016
		lda #$0a
		sta $d021

; Update the dissolve effect (self-modifying code)
		ldx rez_d016_cnt
		dex
		cpx #$ff
		bne *+$04
		ldx #$1f
		stx rez_d016_cnt

		stx rs_d016_mod_01+$01
		stx rs_d016_mod_02+$01
		stx rs_d016_mod_03+$01
		stx rs_d016_mod_04+$01
		stx rs_d016_mod_05+$01
		stx rs_d016_mod_06+$01
		stx rs_d016_mod_07+$01
		stx rs_d016_mod_08+$01

		ldx rez_d018_cnt
		inx
		cpx #$c0
		bne *+$04
		ldx #$00
		stx rez_d018_cnt

		stx rs_d018_mod_01+$01
		stx rs_d018_mod_02+$01
		stx rs_d018_mod_03+$01
		stx rs_d018_mod_04+$01
		stx rs_d018_mod_05+$01
		stx rs_d018_mod_06+$01
		stx rs_d018_mod_07+$01
		stx rs_d018_mod_08+$01

; Wait for the lower border to disable it
		lda #$f9
		cmp $d012
		bne *-$03

		lda #$14
		sta $d011


		lda #$fc
		cmp $d012
		bne *-$03

		lda #$1b
		sta $d011

; Clear the DYCP
		lda #$00

!set column_cnt=$00
!do {
		ldy dycp_cos_work+column_cnt

		sta dycp_work+$000+(column_cnt*$30),y
		sta dycp_work+$001+(column_cnt*$30),y
		sta dycp_work+$002+(column_cnt*$30),y
		sta dycp_work+$003+(column_cnt*$30),y
		sta dycp_work+$004+(column_cnt*$30),y
		sta dycp_work+$005+(column_cnt*$30),y
		sta dycp_work+$006+(column_cnt*$30),y
		sta dycp_work+$007+(column_cnt*$30),y

		!set column_cnt=column_cnt+$01
} until column_cnt=$27

; Update the scroller
		ldx scroll_x
		inx
		cpx #$04
		bne scr_xb

		ldx #$00
mover		lda dycp_buffer+$01,x
		sta dycp_buffer+$00,x
		inx
		cpx #$26
		bne mover

mread		lda scroll_text
		bne okay
		jsr reset
		jmp mread

okay		sta dycp_buffer+$26

		inc mread+$01
		bne *+$05
		inc mread+$02

		lda cos_at_3
		clc
		adc #cos_offset_3
		sta cos_at_3

		ldx #$00
scr_xb		stx scroll_x

; Update the DYCP
		lda cos_at_3
		clc
		adc #cos_speed_3
		sta cos_at_3
		tax

!set column_cnt=$00
!do {
		lda dycp_cosinus,x
		sta dycp_cos_work+column_cnt

		txa
		clc
		adc #cos_offset_3
		tax

		!set column_cnt=column_cnt+$01
} until column_cnt=$27

		lda #$01
		sta rn
		lda #rstr1p
		sta $d012

; Exit the interrupt
ea31		pla
		tay
		pla
		tax
		pla
nmi		rti


; Draw the DYCP (called from rout1 as a subroutine)
dycp_draw

!set column_cnt=$00
!do {
		ldx dycp_buffer+column_cnt
		ldy dycp_cos_work+column_cnt

		lda dycp_char+$000,x
		sta dycp_work+$000+(column_cnt*$30),y
		lda dycp_char+$040,x
		sta dycp_work+$001+(column_cnt*$30),y
		lda dycp_char+$080,x
		sta dycp_work+$002+(column_cnt*$30),y
		lda dycp_char+$0c0,x
		sta dycp_work+$003+(column_cnt*$30),y
		lda dycp_char+$100,x
		sta dycp_work+$004+(column_cnt*$30),y
		lda dycp_char+$140,x
		sta dycp_work+$005+(column_cnt*$30),y
		lda dycp_char+$180,x
		sta dycp_work+$006+(column_cnt*$30),y
		lda dycp_char+$1c0,x
		sta dycp_work+$007+(column_cnt*$30),y

		!set column_cnt=column_cnt+$01
} until column_cnt=$27

		rts


; Reset the scroller
reset		lda #<scroll_text
		sta mread+$01
		lda #>scroll_text
		sta mread+$02
		rts


; Work data for the tech tech
		* = ((*/$100)+1)*$100	; start at next page boundary

d016_table	!byte $10,$11,$12,$13,$14,$15,$16,$17
		!byte $10,$11,$12,$13,$14,$15,$16,$17
		!byte $10,$11,$12,$13,$14,$15,$16,$17
		!byte $10,$11,$12,$13,$14,$15,$16,$17
		!byte $10,$11,$12,$13,$14,$15,$16,$17
		!byte $10,$11,$12,$13,$14,$15,$16,$17

d018_table	!byte $02,$02,$02,$02,$02,$02,$02,$02
		!byte $04,$04,$04,$04,$04,$04,$04,$04
		!byte $06,$06,$06,$06,$06,$06,$06,$06
		!byte $08,$08,$08,$08,$08,$08,$08,$08
		!byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a
		!byte $0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c


d016_decode	!byte $10,$11,$12,$13,$14,$15,$16,$17
		!byte $10,$11,$12,$13,$14,$15,$16,$17
		!byte $10,$11,$12,$13,$14,$15,$16,$17
		!byte $10,$11,$12,$13,$14,$15,$16,$17
		!byte $10,$11,$12,$13,$14,$15,$16,$17
		!byte $10,$11,$12,$13,$14,$15,$16,$17
		!byte $10,$11,$12,$13,$14,$15,$16,$17

d018_decode	!byte $02,$02,$02,$02,$02,$02,$02,$02
		!byte $04,$04,$04,$04,$04,$04,$04,$04
		!byte $06,$06,$06,$06,$06,$06,$06,$06
		!byte $08,$08,$08,$08,$08,$08,$08,$08
		!byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a
		!byte $0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c
		!byte $0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e

; Tech tech curve
		* = ((*/$100)+1)*$100	; start at next page boundary

tech_cosinus	!byte $37,$37,$37,$37,$37,$37,$37,$37
		!byte $37,$37,$37,$36,$36,$36,$36,$36
		!byte $35,$35,$35,$35,$34,$34,$34,$33
		!byte $33,$32,$32,$32,$31,$31,$30,$30
		!byte $2f,$2f,$2e,$2e,$2d,$2d,$2c,$2c
		!byte $2b,$2a,$2a,$29,$29,$28,$27,$27
		!byte $26,$26,$25,$24,$24,$23,$22,$22
		!byte $21,$20,$20,$1f,$1e,$1e,$1d,$1c

		!byte $1b,$1b,$1a,$19,$19,$18,$17,$17
		!byte $16,$15,$15,$14,$13,$13,$12,$11
		!byte $11,$10,$0f,$0f,$0e,$0e,$0d,$0c
		!byte $0c,$0b,$0b,$0a,$0a,$09,$09,$08
		!byte $08,$07,$07,$06,$06,$05,$05,$05
		!byte $04,$04,$03,$03,$03,$02,$02,$02
		!byte $02,$01,$01,$01,$01,$00,$00,$00
		!byte $00,$00,$00,$00,$00,$00,$00,$00

		!byte $00,$00,$00,$00,$00,$00,$00,$00
		!byte $00,$00,$00,$01,$01,$01,$01,$01
		!byte $02,$02,$02,$03,$03,$03,$04,$04
		!byte $04,$05,$05,$06,$06,$06,$07,$07
		!byte $08,$08,$09,$09,$0a,$0a,$0b,$0b
		!byte $0c,$0d,$0d,$0e,$0e,$0f,$10,$10
		!byte $11,$12,$12,$13,$14,$14,$15,$16
		!byte $16,$17,$18,$18,$19,$1a,$1a,$1b

		!byte $1c,$1c,$1d,$1e,$1e,$1f,$20,$20
		!byte $21,$22,$22,$23,$24,$24,$25,$26
		!byte $26,$27,$28,$28,$29,$29,$2a,$2b
		!byte $2b,$2c,$2c,$2d,$2d,$2e,$2e,$2f
		!byte $2f,$30,$30,$31,$31,$32,$32,$32
		!byte $33,$33,$34,$34,$34,$35,$35,$35
		!byte $35,$36,$36,$36,$36,$37,$37,$37
		!byte $37,$37,$37,$37,$37,$37,$37,$37

; DYCP curve
		* = ((*/$100)+1)*$100	; start at next page boundary

dycp_cosinus	!byte $28,$28,$28,$28,$28,$28,$28,$28
		!byte $28,$28,$28,$28,$28,$27,$27,$27
		!byte $27,$27,$27,$26,$26,$26,$26,$25
		!byte $25,$25,$25,$24,$24,$24,$23,$23
		!byte $23,$22,$22,$22,$21,$21,$20,$20
		!byte $20,$1f,$1f,$1e,$1e,$1d,$1d,$1d
		!byte $1c,$1c,$1b,$1b,$1a,$1a,$19,$19
		!byte $18,$18,$17,$17,$16,$16,$15,$15

		!byte $14,$14,$13,$13,$13,$12,$12,$11
		!byte $11,$10,$10,$0f,$0f,$0e,$0e,$0d
		!byte $0d,$0c,$0c,$0b,$0b,$0b,$0a,$0a
		!byte $09,$09,$09,$08,$08,$07,$07,$07
		!byte $06,$06,$06,$05,$05,$05,$04,$04
		!byte $04,$04,$03,$03,$03,$03,$02,$02
		!byte $02,$02,$02,$01,$01,$01,$01,$01
		!byte $01,$01,$01,$01,$01,$01,$01,$01

		!byte $01,$01,$01,$01,$01,$01,$01,$01
		!byte $01,$01,$01,$01,$01,$02,$02,$02
		!byte $02,$02,$02,$03,$03,$03,$03,$04
		!byte $04,$04,$04,$05,$05,$05,$06,$06
		!byte $06,$07,$07,$08,$08,$08,$09,$09
		!byte $09,$0a,$0a,$0b,$0b,$0c,$0c,$0c
		!byte $0d,$0d,$0e,$0e,$0f,$0f,$10,$10
		!byte $11,$11,$12,$12,$13,$13,$14,$14

		!byte $15,$15,$16,$16,$17,$17,$18,$18
		!byte $19,$19,$19,$1a,$1a,$1b,$1b,$1c
		!byte $1c,$1d,$1d,$1e,$1e,$1e,$1f,$1f
		!byte $20,$20,$21,$21,$21,$22,$22,$22
		!byte $23,$23,$23,$24,$24,$24,$25,$25
		!byte $25,$25,$26,$26,$26,$26,$27,$27
		!byte $27,$27,$27,$28,$28,$28,$28,$28
		!byte $28,$28,$28,$28,$28,$28,$28,$28

; Data tables for the dissolve effect
		* = ((*/$100)+1)*$100	; start at next page boundary

rez_d018_table	!byte $08,$08,$08,$08,$08,$08,$08,$08
		!byte $08,$08,$08,$08,$08,$08,$08,$08
		!byte $08,$08,$08,$08,$08,$08,$08,$08
		!byte $08,$08,$08,$08,$08,$08,$08,$08
		!byte $08,$08,$08,$08,$08,$08,$08,$08
		!byte $08,$08,$08,$08,$08,$08,$08,$08

		!byte $08,$08,$08,$0a,$08,$08,$08,$08
		!byte $08,$0a,$08,$08,$08,$08,$08,$0a
		!byte $08,$08,$08,$0a,$08,$08,$0a,$08
		!byte $0a,$08,$0a,$0a,$08,$0a,$0a,$0a
		!byte $08,$0a,$0a,$0a,$0a,$08,$0a,$0a
		!byte $0a,$0a,$0a,$08,$0a,$0a,$0a,$0a

		!byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a
		!byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a
		!byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a
		!byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a
		!byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a
		!byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a

		!byte $0a,$0a,$0a,$08,$0a,$0a,$0a,$0a
		!byte $0a,$08,$0a,$0a,$0a,$0a,$0a,$08
		!byte $0a,$0a,$0a,$08,$0a,$0a,$08,$0a
		!byte $08,$0a,$08,$08,$0a,$08,$08,$08
		!byte $0a,$08,$08,$08,$08,$0a,$08,$08
		!byte $08,$08,$08,$0a,$08,$08,$08,$08

		!byte $08,$08,$08,$08,$08,$08,$08,$08
		!byte $08,$08,$08,$08,$08,$08,$08,$08
		!byte $08,$08,$08,$08,$08,$08,$08,$08
		!byte $08,$08,$08,$08,$08,$08,$08,$08
		!byte $08,$08,$08,$08,$08,$08,$08,$08
		!byte $08,$08,$08,$08,$08,$08,$08,$08

		* = ((*/$100)+1)*$100	; start at next page boundary

rez_d016_table	!byte $10,$10,$10,$10,$11,$11,$11,$12
		!byte $12,$13,$14,$15,$15,$16,$16,$16
		!byte $17,$17,$17,$17,$16,$16,$16,$15
		!byte $15,$14,$13,$12,$12,$11,$11,$11
		!byte $10,$10,$10,$10,$11,$11,$11,$12
		!byte $12,$13,$14,$15,$15,$16,$16,$16
		!byte $17,$17,$17,$17,$16,$16,$16,$15
		!byte $15,$14,$13,$12,$12,$11,$11,$11

		!byte $10,$10,$10,$10,$11,$11,$11,$12
		!byte $12,$13,$14,$15,$15,$16,$16,$16


; Our beloved scroller
scroll_text	!scr "welcome one and all to another random event courtesy "
		!scr "of cosine...    "
		!scr "--=- md201605 -=--"
		!scr "         "

		!scr "programming and graphics by the magic roundabout, with "
		!scr "an excellent cover of fletch's theme courtesy of andy - "
		!scr "it seemed appropriate since this demo has something of "
		!scr "a 1980s-style ",$22,"vibe",$22,"..."
		!scr "         "

		!scr "i mentioned on my blog - jasonkelk.me.uk for those "
		!scr "who like their plugs to be utterly shameless - the idea "
		!scr "of posting source code for a simple dycp routine to "
		!scr "github and a couple of people seemed interested...   "
		!scr "but there's a part of me that simply con't just release "
		!scr "something like that without at least making a bit of "
		!scr "a show out of it, so here's that routine along with a "
		!scr "basic character set based tech tech and... well, a "
		!scr "dissolve effect.   come to think of it, does that thing "
		!scr "at the bottom of the screeneven have a proper name?   "
		!scr "i've always called them a ",$22,"drive rez",$22," since "
		!scr "i originally saw one in drive's contribution to the "
		!scr "trc mega-co demo in 1989!"
		!scr "         "

		!scr "it'll be quite interesting to see what reaction this "
		!scr "gets at pouet, the gamerz xtreme intro we released a few "
		!scr "months ago was slated in the comments there for not "
		!scr "being a ",$22,"modern homage",$22,"...   whatever that "
		!scr "actually means?   who knows though, perhaps bunging a "
		!scr "load of pastel colours in with the 1980s effect  code "
		!scr "this time will cheer them up a little!"
		!scr "         "

		!scr "anyway, i should probably think about rolling this "
		!scr "thing up for release now, which means getthing the "
		!scr "hellos out of the way...   so cheerful waves to:"
		!scr "   "

		!scr "abyss connection, "
		!scr "arkanix labs, "
		!scr "artstate, "
		!scr "ate bit, "
		!scr "atlantis and f4cg, "
		!scr "booze design, "
		!scr "camelot, "
		!scr "censor design, "
		!scr "chorus, "
		!scr "chrome, "
		!scr "cncd, "
		!scr "cpu, "
		!scr "crescent, "
		!scr "crest, "
		!scr "covert bitops, "
		!scr "defence force, "
		!scr "dekadence, "
		!scr "desire, "
		!scr "dac, "
		!scr "dmagic, "
		!scr "dualcrew, "
		!scr "exclusive on, "
		!scr "fairlight, "
		!scr "fire, "
		!scr "focus, "
		!scr "french touch, "
		!scr "funkscientist productions, "
		!scr "genesis project, "
		!scr "gheymaid inc., "
		!scr "hitmen, "
		!scr "hokuto force, "
		!scr "level64, "
		!scr "maniacs of noise, "
		!scr "mayday, "
		!scr "meanteam, "
		!scr "metalvotze, "
		!scr "noname, "
		!scr "nostalgia, "
		!scr "nuance, "
		!scr "offence, "
		!scr "onslaught, "
		!scr "orb, "
		!scr "oxyron, "
		!scr "padua, "
		!scr "plush, "
		!scr "psytronik, "
		!scr "reptilia, "
		!scr "resource, "
		!scr "rgcd, "
		!scr "secure, "
		!scr "shape, "
		!scr "side b, "
		!scr "singular, "
		!scr "slash, "
		!scr "slipstream, "
		!scr "success and trc, "
		!scr "style, "
		!scr "suicyco industries, "
		!scr "taquart, "
		!scr "tempest, "
		!scr "tek, "
		!scr "triad, "
		!scr "trsi, "
		!scr "viruz, "
		!scr "vision, "
		!scr "wow, "
		!scr "wrath, "
		!scr "xenon..."
		!scr "         "

		!scr "and that's me done for another monthly demo.   if"
		!scr " you've liked this release, check out our website"
		!scr " at http://cosine.org.uk/ for more of the same (or"
		!scr " at least similar) because we like getting visitors"
		!scr " with news of the outside world.   oh, and bring"
		!scr " cake as well!"
		!scr "         "

		!scr "this was the magic roundabout, developing an exit "
		!scr "strategy and running for cover on the 30th of may "
		!scr "2016 - no hardware sprites were harmed during the "
		!scr "making of this demo... .. .  .   ."
		!scr "         "

		!byte $00

