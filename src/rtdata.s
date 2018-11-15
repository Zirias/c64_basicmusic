.include "rtdatadefs.inc"

.export inst_ad
.export inst_sr
.export inst_wave
.export inst_pwidth
.export inst_vdelay
.export inst_vspeed
.export inst_voff
.export pattern_pitch
.export pattern_arg
.export seq0
.export seq1
.export seq2

.bss
inst_ad:	.res	NUM_INSTS
inst_sr:	.res	NUM_INSTS
inst_wave:	.res	NUM_INSTS
inst_pwidth:	.res	NUM_INSTS
inst_vdelay:	.res	NUM_INSTS
inst_vspeed:	.res	NUM_INSTS
inst_voff:	.res	NUM_INSTS

pattern_pitch:	.res	PAT_MAXLEN * NUM_PATS
pattern_arg:	.res	PAT_MAXLEN * NUM_PATS

seq0:		.res	SEQ_MAXLEN
seq1:		.res	SEQ_MAXLEN
seq2:		.res	SEQ_MAXLEN

