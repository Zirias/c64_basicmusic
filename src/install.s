.include "define.inc"
.include "player.inc"

CHRGET	= $73
GONECNT = $a7e7
NEXTST	= $a7ae

.data

.define commands def_instr, def_pattern, def_seq, player_start, player_stop
commands_l:	.lobytes commands
commands_h:	.hibytes commands

.segment "INSTALL"

		lda	#<gonehook
		sta	$308
		lda	#>gonehook
		sta	$309
		rts

.code

.proc gonehook
		jsr	CHRGET
		php
		cmp	#'@'
		beq	parsecmd
		plp
		jmp	GONECNT
parsecmd:	plp
		ldx	#$0
		jsr	CHRGET
		cmp	#'i'
		beq	execute
		inx
		cmp	#'t'
		beq	execute
		inx
		cmp	#'q'
		beq	execute
		inx
		cmp	#'p'
		beq	execute
		inx
		cmp	#'s'
		bne	error
execute:	lda	commands_l,x
		sta	cmdjmp+1
		lda	commands_h,x
		sta	cmdjmp+2
cmdjmp:		jsr	$ffff
		jmp	NEXTST
error:		jmp	$af08	
.endproc
