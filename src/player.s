.include "rtdata.inc"
.include "pitches.inc"

.export player_start
.export player_stop

SIDBASE		= $d400
HRTIMER		= 2

.bss
bss_start:
wave0:		.res	1
seqpos0:	.res	1
seqpos1:	.res	1
seqpos2:	.res	1
patpos0:	.res	1
patpos1:	.res	1
patpos2:	.res	1
wave1:		.res	1
pat0:		.res	1
pat1:		.res	1
pat2:		.res	1
speed:		.res	1
frame:		.res	1
tmp:		.res	1
wave2:		.res	1

ghostsid:	.res	$14

bss_size	= *-bss_start

.zeropage
patpitchptr:	.res	2
patargptr:	.res	2

.code

.proc player_start
		ldx	#bss_size
		lda	#$0
clearloop:	sta	bss_start-1, x
		dex
		bne	clearloop
		jsr	sidout
		lda	#$f
		sta	$d418
		lda	#HRTIMER+1
		sta	frame
		lda	#5
		sta	speed

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
		rts
.endproc

.proc play
		asl	$d019
		dec	$1
		jsr	sidout
		dec	frame
		bmi	playnotes
		beq	firstframe
		cmp	#HRTIMER
		bne	play_out
		jmp	hrstep
firstframe:	jmp	ffstep
playnotes:	lda	wave0
		beq	pn_w1
		sta	ghostsid+$4
pn_w1:		lda	wave1
		beq	pn_w2
		sta	ghostsid+$b
pn_w2:		lda	wave2
		beq	pn_speed
		sta	ghostsid+$12
pn_speed:	lda	speed
		sta	frame
.endproc

.proc play_out
		inc	$1
		jmp	$ea31
.endproc

.proc sidout
		ldx	#$14
loop:		lda	ghostsid-1,x
		sta	SIDBASE-1,x
		dex
		bne	loop
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
		lda	(patpitchptr),y
		bmi	cmd0
		ldx	#$0
		jsr	setpitch
		bne	inst0
cmd0:		cmp	#$ff
		beq	end0
		cmp	#$81
		bne	adv0
		lda	ghostsid+$4
		and	#$fe
		sta	ghostsid+$4
		; TODO
end0:		lda	#$0
		sta	patpos0
		beq	ff1
inst0:		lda	(patargptr),y
		ldx	#$0
		jsr	setinst
adv0:		ldx	patpos0
		inx
		txa
		and	#$3f
		sta	patpos0
ff1:		lda	pat1
		jsr	selectpattern
		ldy	patpos1
		lda	(patpitchptr),y
		bmi	cmd1
		ldx	#$7
		jsr	setpitch
		bne	inst1
cmd1:		cmp	#$ff
		bne	adv1
		lda	#$0
		sta	patpos1
		beq	ff2
inst1:		lda	(patargptr),y
		ldx	#$7
		jsr	setinst
adv1:		ldx	patpos1
		inx
		txa
		and	#$3f
		sta	patpos1
ff2:		lda	pat2
		jsr	selectpattern
		ldy	patpos2
		lda	(patpitchptr),y
		bmi	cmd2
		ldx	#$e
		jsr	setpitch
		bne	inst2
cmd2:		cmp	#$ff
		bne	adv2
		lda	#$0
		sta	patpos2
		beq	out
inst2:		lda	(patargptr),y
		ldx	#$e
		jsr	setinst
adv2:		ldx	patpos2
		inx
		txa
		and	#$3f
		sta	patpos2
out:		jmp	play_out
.endproc

.proc setpitch
		tay
		lda	pitches_l,y
		sta	ghostsid,x
		lda	pitches_h,y
		sta	ghostsid+1,x
		rts
.endproc

.proc setinst
		asl
		bcc	noslide
		and	#$1
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

.proc selectpattern
		ldx	#$0
		stx	patpitchptr+1
		stx	patargptr+1
		ldx	#$6
loop:		asl
		rol	patpitchptr+1
		rol	patargptr+1
		dex
		bne	loop
		sta	patargptr
		adc	#<pattern_pitch
		sta	patpitchptr
		lda	patpitchptr+1
		adc	#>pattern_pitch
		sta	patpitchptr+1
		lda	patargptr
		adc	#<pattern_arg
		sta	patargptr
		lda	patargptr+1
		adc	#>pattern_arg
		sta	patargptr+1
		rts
.endproc

.proc hrstep
		ldy	patpos0
		bne	pos0ok
		ldx	seqpos0
ldseq0:		lda	seq0,x
		bpl	seq0ok
		and	#$7f
		tax
		bpl	ldseq0
seq0ok:		sta	pat0
pos0ok:		lda	pat0
		jsr	selectpattern
		lda	(patpitchptr),y
		bmi	hr1
		lda	(patargptr),y
		bmi	hr1
		ldx	#$0
		jsr	dohr
hr1:		ldy	patpos1
		bne	pos1ok
		ldx	seqpos1
ldseq1:		lda	seq1,x
		bpl	seq1ok
		and	#$7f
		tax
		bpl	ldseq1
seq1ok:		sta	pat1
pos1ok:		lda	pat1
		jsr	selectpattern
		lda	(patpitchptr),y
		bmi	hr2
		lda	(patargptr),y
		bmi	hr2
		ldx	#$7
		jsr	dohr
hr2:		ldy	patpos2
		bne	pos2ok
		ldx	seqpos2
ldseq2:		lda	seq2,x
		bpl	seq2ok
		and	#$7f
		tax
		bpl	ldseq2
seq2ok:		sta	pat2
pos2ok:		lda	pat2
		jsr	selectpattern
		lda	(patpitchptr),y
		bmi	out
		lda	(patargptr),y
		bmi	out
		ldx	#$e
		jmp	dohr
out:		jmp	play_out
.endproc

.proc dohr
		lda	#$f
		sta	ghostsid+$5,x
		lda	#$0
		sta	ghostsid+$6,x
		lda	ghostsid+$4,x
		and	#$fe
		sta	ghostsid+$4,x
		rts
.endproc

