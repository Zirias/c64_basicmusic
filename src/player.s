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
speed:		.res	1
frame:		.res	1
seqpos0:	.res	1
seqpos1:	.res	1
seqpos2:	.res	1
wave1:		.res	1
patpos1:	.res	1
pat0:		.res	1
pat1:		.res	1
pat2:		.res	1
stoprq:		.res	1
stopstep:	.res	1
wave2:		.res	1
patpos2:	.res	1

ghostsid:	.res	$19
sidsize		= *-ghostsid

bss_size	= *-bss_start

.data
stopvol:	.byte	$0,$1,$1,$1,$1,$2,$2,$2,$2,$3,$3,$3,$4,$4,$4,$5,$5
		.byte	$6,$6,$7,$7,$8,$9,$a,$b,$d
stoplen		= *-stopvol

.code

.proc player_start
		jsr	$b79b
		ldy	#bss_size
		lda	#$0
clearloop:	sta	bss_start-1,y
		dey
		bne	clearloop
		stx	speed
		jsr	sidout
		lda	#$f
		sta	ghostsid+$18
		lda	#HRTIMER+1
		sta	frame

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
		rts
.endproc

.proc play
		asl	$d019
		dec	$1
		jsr	sidout
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

.proc dohr
		lda	#$f
		sta	ghostsid+$5,x
		lda	#$0
		sta	ghostsid+$6,x
gateoff:	lda	ghostsid+$4,x
		and	#$fe
		sta	ghostsid+$4,x
		rts
.endproc

.proc ffstep
		lda	#$0
		sta	wave0
		sta	wave1
		sta	wave2
		lda	pat0
		jsr	selectpattern
		ldy	patpos0
		ldx	#$0
		lda	(patpitchptr),y
		bmi	cmd0
		jsr	setpitch
		bpl	inst0
cmd0:		cmp	#$81
		bne	adv0
		jsr	dohr::gateoff
		bcs	adv0
inst0:		lda	(patargptr),y
		jsr	setinst
adv0:		jsr	advpatpos
		lda	pat1
		jsr	selectpattern
		ldy	patpos1
		ldx	#$7
		lda	(patpitchptr),y
		bmi	cmd1
		jsr	setpitch
		bpl	inst1
cmd1:		cmp	#$81
		bne	adv1
		jsr	dohr::gateoff
		bcs	adv1
inst1:		lda	(patargptr),y
		jsr	setinst
adv1:		jsr	advpatpos
		lda	pat2
		jsr	selectpattern
		ldy	patpos2
		ldx	#$e
		lda	(patpitchptr),y
		bmi	cmd2
		jsr	setpitch
		bpl	inst2
cmd2:		cmp	#$81
		bne	adv2
		jsr	dohr::gateoff
		bcs	adv2
inst2:		lda	(patargptr),y
		jsr	setinst
adv2:		jsr	advpatpos
		jmp	play_out
.endproc

.proc advpatpos
		lda	patpos0,x
		sec
		adc	#$0
		and	#$3f
		sta	patpos0,x
		rts
.endproc

.proc setpitch
		sty	resty+1
		tay
		lda	pitches_l,y
		sta	ghostsid,x
		lda	pitches_h,y
		sta	ghostsid+1,x
resty:		ldy	#$ff
		rts
.endproc

.proc setinst
		asl
		bcc	noslide
		ora	#$1
noslide:	lsr
		tay
		lda	inst_ad,y
		sta	ghostsid+5,x
		lda	inst_sr,y
		sta	ghostsid+6,x
		lda	inst_wave,y
		sta	wave0,x
		bcs	out
		lda	#$9
		sta	ghostsid+4,x
out:		rts
.endproc

.proc hrstep
		lda	stoprq
		beq	nostop
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
nostop:		ldy	patpos0
		bne	pos0ok
advseq0:	ldx	seqpos0
ldseq0:		lda	seq0,x
		bpl	seq0ok
		and	#$7f
		tax
		bpl	ldseq0
seq0ok:		sta	pat0
		inx
		stx	seqpos0
pos0ok:		lda	pat0
		jsr	selectpattern
		lda	(patpitchptr),y
		bpl	note0
		cmp	#$ff
		bne	hr1
		ldy	#$0
		sty	patpos0
		beq	advseq0
note0:		lda	(patargptr),y
		bmi	hr1
		ldx	#$0
		jsr	dohr
hr1:		ldy	patpos1
		bne	pos1ok
advseq1:	ldx	seqpos1
ldseq1:		lda	seq1,x
		bpl	seq1ok
		and	#$7f
		tax
		bpl	ldseq1
seq1ok:		sta	pat1
		inx
		stx	seqpos1
pos1ok:		lda	pat1
		jsr	selectpattern
		lda	(patpitchptr),y
		bpl	note1
		cmp	#$ff
		bne	hr2
		ldy	#$0
		sty	patpos1
		beq	advseq1
note1:		lda	(patargptr),y
		bmi	hr2
		ldx	#$7
		jsr	dohr
hr2:		ldy	patpos2
		bne	pos2ok
advseq2:	ldx	seqpos2
ldseq2:		lda	seq2,x
		bpl	seq2ok
		and	#$7f
		tax
		bpl	ldseq2
seq2ok:		sta	pat2
		inx
		stx	seqpos2
pos2ok:		lda	pat2
		jsr	selectpattern
		lda	(patpitchptr),y
		bpl	note2
		cmp	#$ff
		bne	out
		ldy	#$0
		sty	patpos2
		beq	advseq2
note2:		lda	(patargptr),y
		bmi	out
		ldx	#$e
		jmp	dohr
out:		jmp	play_out
.endproc

