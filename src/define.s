.include "rtdata.inc"
.include "pattern.inc"

.export def_instr
.export def_pattern
.export def_seq

.bss
bss_start:
tmp:		.res	1
inst:		.res	1
pitch:		.res	1
patpos:		.res	1
strpos:		.res	1
strlen:		.res	1
bss_size = *-bss_start

.data
notes:		.byte	"c@d@ef@g@a@b"
notes_len	= *-notes

.code
.proc get_signedbyte
		jsr	$0073
		cmp	#'-'
		beq	negative
		cmp	#$ab
		bne	positive
negative:	jsr	$b79b
		txa
		eor	#$ff
		adc	#$0
		rts
positive:	jsr	$b79e
		txa
		rts
.endproc

.proc def_instr
		jsr	$b1b2
		lda	$65
		sta	patargptr
		jsr	$b79b
		txa
		ldy	patargptr
		sta	inst_ad,y
		jsr	$b79b
		txa
		ldy	patargptr
		sta	inst_sr,y
		jsr	$b79b
		txa
		ldy	patargptr
		sta	inst_wave,y
		jsr	get_signedbyte
		clc
		adc	#$80
		ldy	patargptr
		sta	inst_pwidth,y
		jsr	$b79b
		txa
		ldy	patargptr
		sta	inst_chordlen,y
		beq	nochord
		tya
		asl
		asl
		asl
		sta	patargptr
		stx	patpitchptr
chordloop:	jsr	get_signedbyte
		ldy	patargptr
		sta	inst_chord,y
		inc	patargptr
		dec	patpitchptr
		bne	chordloop
nochord:	rts
.endproc

.proc fetchchar
		ldy	strpos
		cpy	strlen
		bcs	out
		lda	($22),y
		iny
		sty	strpos
		clc
out:		rts
.endproc
		
.proc def_pattern
		ldx	#bss_size
		lda	#$0
clearvars:	sta	bss_start-1,x
		dex
		bne	clearvars

		jsr	$b1b2
		lda	$65
		jsr	selectpattern
		jsr	$aefd
		jsr	$ad9e
		jsr	$b6a3
		sta	strlen
		dec	$1

loop:		jsr	fetchchar
		bcc	ok
		jmp	out
ok:		cmp	#'r'
		bne	haveinst
		lda	#$81
		sta	pitch
		lda	#$00
		sta	inst
		beq	length
haveinst:	sec
		sbc	#$30
		sta	inst

		jsr	fetchchar
		bcs	out
		cmp	#'l'
		bne	getnote
		lda	inst
		ora	#$80
		sta	inst
		jsr	fetchchar
		bcs	out
getnote:	ldx	#notes_len-1
searchnote:	cmp	notes,x
		beq	found
		dex
		bpl	searchnote
found:		stx	pitch

		jsr	fetchchar
		bcs	out
		cmp	#'#'
		bne	nosharp
		inc	pitch
		jsr	fetchchar
		bcs	out
		bcc	octave
nosharp:	cmp	#'&'
		bne	octave
		dec	pitch
		jsr	fetchchar
		bcs	out
octave:		sec
		sbc	#$30
		asl
		asl
		sta	tmp
		asl
		adc	tmp
		adc	pitch
		sta	pitch

length:		jsr	fetchchar
		bcs	out
		sbc	#$30
		tax
		ldy	patpos
		lda	pitch
		sta	(patpitchptr),y
		lda	inst
		sta	(patargptr),y
		iny
		dex
		bmi	done
emptyloop:	lda	#$80
		sta	(patpitchptr),y
		lda	#$00
		sta	(patargptr),y
		iny
		dex
		bpl	emptyloop
done:		sty	patpos
		jmp	loop

out:		ldy	patpos
		cpy	#PAT_MAXLEN
		bcs	skipendmark
		lda	#$ff
		sta	(patpitchptr),y
		lda	#$00
		sta	(patargptr),y
skipendmark:	inc	$1
		rts
.endproc

.proc def_seq
		jsr	$b1b2
		ldx	$65
		dex
		bne	notsq0
		lda	#<seq0
		sta	patargptr
		lda	#>seq0
		sta	patargptr+1
		bne	start
notsq0:		dex
		bne	notsq1
		lda	#<seq1
		sta	patargptr
		lda	#>seq1
		sta	patargptr+1
		bne	start
notsq1:		lda	#<seq2
		sta	patargptr
		lda	#>seq2
		sta	patargptr+1
start:		lda	#$0
		sta	patpitchptr
loop:		lda	#$2c
		ldy	#$0
		cmp	($7a),y
		bne	out
		jsr	$b79b
		txa
		ldy	patpitchptr
		sta	(patargptr),y
		iny
		sty	patpitchptr
		bne	loop
out:		rts
.endproc
