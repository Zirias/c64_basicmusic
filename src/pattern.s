.include "rtdata.inc"

.export selectpattern
.export selectsequence

.exportzp patpitchptr
.exportzp patargptr

.zeropage
patpitchptr:	.res	2
patargptr:	.res	2

.code

.proc selectpattern
		stx	restx+1
		ldx	#$0
		stx	patpitchptr+1
		stx	patargptr+1
		ldx	#$6
loop:		asl
		rol	patpitchptr+1
		dex
		bne	loop
		sta	patargptr
		adc	#<pattern_pitch
		sta	patpitchptr
		lda	patpitchptr+1
		sta	patargptr+1
		adc	#>pattern_pitch
		sta	patpitchptr+1
		lda	patargptr
		adc	#<pattern_arg
		sta	patargptr
		lda	patargptr+1
		adc	#>pattern_arg
		sta	patargptr+1
restx:		ldx	#$ff
		rts
.endproc

.proc selectsequence
		stx	restx+1
		cpx	#$e
		beq	select2
		cpx	#$7
		beq	select1
		lda	#<seq0
		ldx	#>seq0
		bne	select
select1:	lda	#<seq1
		ldx	#>seq1
		bne	select
select2:	lda	#<seq2
		ldx	#>seq2
select:		sta	patargptr
		stx	patargptr+1
restx:		ldx	#$ff
		rts
.endproc

