.include "rtdata.inc"
.include "pitches.inc"
.include "pattern.inc"

.export player_start
.export player_stop

SIDBASE		= $d400
HRTIMER		= 2

.bss
bss_start:
wave0:		.res	1
patpos0:	.res	1
inst0:		.res	1
chordpos0:	.res	1
seqpos0:	.res	1
pat0:		.res	1
basepitch0:	.res	1
wave1:		.res	1
patpos1:	.res	1
inst1:		.res	1
chordpos1:	.res	1
seqpos1:	.res	1
pat1:		.res	1
basepitch1:	.res	1
wave2:		.res	1
patpos2:	.res	1
inst2:		.res	1
chordpos2:	.res	1
seqpos2:	.res	1
pat2:		.res	1
basepitch2:	.res	1
speed:		.res	1
frame:		.res	1
stoprq:		.res	1
stopstep:	.res	1

ghostsid:	.res	$19
sidsize		= *-ghostsid

bss_size	= *-bss_start

.data
stopvol:	.byte	$0,$1,$1,$1,$1,$2,$2,$2,$2,$3,$3,$3,$4,$4,$4,$5,$5
		.byte	$6,$6,$7,$7,$8,$9,$a,$b,$d
stoplen		= *-stopvol

.code

.proc player_start
		jsr	$b1b2
		ldy	#bss_size
		lda	#$0
clearloop:	sta	bss_start-1,y
		dey
		bne	clearloop
		lda	$65
		sta	speed
		lda	#$f
		sta	ghostsid+$18
		lda	#HRTIMER+1
		sta	frame
		lda	#$ff
		sta	inst0
		sta	inst1
		sta	inst2

		lda	#$7f
		sta	$dc0d
		lda	$dc0d
		lda	#<play
		sta	$314
		lda	#>play
		sta	$315
		lda	#$0
		sta	$d012
		lda	#$1b
		sta	$d011
		lda	#$1
		sta	$d01a
		rts
.endproc

.proc player_stop
		lda	#stoplen-1
		sta	stopstep
		lda	#$1
		sta	stoprq
		jmp	$0073
.endproc

.proc play
		asl	$d019
		dec	$1
		jsr	sidout
		ldx	#$0
		jsr	dochord
		ldx	#$7
		jsr	dochord
		ldx	#$e
		jsr	dochord
		dec	frame
		bmi	playnotes
		beq	firstframe
		lda	#HRTIMER
		cmp	frame
		bne	play_out
		jmp	hrstep
firstframe:	jmp	ffstep
playnotes:	ldx	#$e
notechan:	lda	wave0,x
		beq	nextchan
		sta	ghostsid+$4,x
nextchan:	txa
		lsr
		tax
		beq	dospeed
		bcc	notechan
		ldx	#$0
		beq	notechan
dospeed:	lda	speed
		sta	frame
.endproc

.proc play_out
		inc	$1
		jmp	$ea31
.endproc

.proc sidout
		ldx	#sidsize
loop:		lda	ghostsid-1,x
		sta	SIDBASE-1,x
		dex
		bne	loop
		rts
.endproc

.proc dochord
		lda	ghostsid+$4,x
		and	#$8
		bne	out
		ldy	inst0,x
		bmi	out
		lda	inst_chordlen,y
		beq	out
		cmp	chordpos0,x
		bne	posok
		lda	#$0
		sta	chordpos0,x
posok:		tya
		asl
		asl
		asl
		adc	chordpos0,x
		tay
		lda	inst_chord,y
		clc
		adc	basepitch0,x
		clc
		jsr	setpitch
		inc	chordpos0,x
out:		rts
.endproc

.proc dohr
		ldy	patpos0,x
		bne	posok
advseq:		jsr	selectsequence
		ldy	seqpos0,x
ldseq:		lda	(patargptr),y
		bpl	seqok
		and	#$7f
		tay
		bpl	ldseq
seqok:		sta	pat0,x
		iny
		tya
		sta	seqpos0,x
		ldy	patpos0,x
posok:		lda	pat0,x
		jsr	selectpattern
		lda	(patpitchptr),y
		bpl	note
		cmp	#$ff
		bne	out
		lda	#$0
		sta	patpos0,x
		beq	advseq
note:		lda	(patargptr),y
		bmi	out
		lda	#$ff
		sta	inst0,x
		lda	#$f
		sta	ghostsid+$5,x
		lda	#$0
		sta	ghostsid+$6,x
gateoff:	lda	ghostsid+$4,x
		and	#$fe
		sta	ghostsid+$4,x
out:		rts
.endproc

.proc ffstep
		lda	#$0
		sta	wave0
		sta	wave1
		sta	wave2
		ldx	#$e
chanloop:	lda	pat0,x
		jsr	selectpattern
		ldy	patpos0,x
		lda	(patpitchptr),y
		bmi	cmd
		sec
		jsr	setpitch
		bpl	inst
cmd:		cmp	#$81
		bne	adv
		jsr	dohr::gateoff
		bcs	adv
inst:		lda	(patargptr),y
		asl
		bcc	noslide
		ora	#$1
noslide:	lsr
		sta	inst0,x
		tay
		lda	inst_ad,y
		sta	ghostsid+5,x
		lda	inst_sr,y
		sta	ghostsid+6,x
		lda	inst_wave,y
		sta	wave0,x
		bcs	skipffval
		lda	#$9
		sta	ghostsid+4,x
		lda	#$0
		sta	chordpos0,x
skipffval:	lda	#$0
		sta	ghostsid+3,x
		lda	inst_pwidth,y
		asl
		rol	ghostsid+3,x
		asl
		rol	ghostsid+3,x
		asl
		rol	ghostsid+3,x
		asl
		rol	ghostsid+3,x
		sta	ghostsid+2,x
adv:		lda	patpos0,x
		sec
		adc	#$0
		and	#$3f
		sta	patpos0,x
nextchan:	txa
		lsr
		tax
		beq	out
		bcc	chanloop
		ldx	#$0
		beq	chanloop
out:		jmp	play_out
.endproc

.proc setpitch
		sty	resty+1
		bcc	skipbase
		sta	basepitch0,x
skipbase:	tay
		lda	pitches_l,y
		sta	ghostsid,x
		lda	pitches_h,y
		sta	ghostsid+1,x
resty:		ldy	#$ff
		rts
.endproc

.proc hrstep
		lda	stoprq
		beq	hrchans
		ldx	stopstep
		bpl	fadeout
		lda	#$0
		sta	$d01a
		lda	#$31
		sta	$314
		lda	#$ea
		sta	$315
		lda	#$81
		sta	$dc0d
		jmp	play_out
fadeout:	lda	stopvol,x
		sta	ghostsid+$18
		dex
		stx	stopstep
hrchans:	ldx	#$0
		jsr	dohr
		ldx	#$7
		jsr	dohr
		ldx	#$e
		jsr	dohr
		jmp	play_out
.endproc

