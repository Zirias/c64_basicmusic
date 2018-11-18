.include "rtdata.inc"

.export selectpattern

.exportzp patpitchptr
.exportzp patargptr

.zeropage
patpitchptr:	.res	2
patargptr:	.res	2

.code

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

