.include "rtdata.inc"

.export def_instr
.export def_pattern
.export def_seq

.code

.proc def_instr
		jsr	$b79b
		txa
		tay
		jsr	$b79b
		txa
		sta	inst_ad,y
		jsr	$b79b
		txa
		sta	inst_sr,y
		jsr	$b79b
		txa
		sta	inst_wave,y
		rts
.endproc

.proc def_pattern

.endproc

.proc def_seq

.endproc
