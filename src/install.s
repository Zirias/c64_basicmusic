.include "define.inc"
.include "player.inc"

CHRGET	= $73
GONECNT = $a7e7
NEXTST	= $a7ae

.data

.define commands def_instr, def_pattern, def_seq, player_start, player_stop, uninstall
commands_l:	.lobytes commands
commands_h:	.hibytes commands

.code

.proc uninstall
gone_olb:	lda	#$ff
		sta	$308
gone_ohb:	lda	#$ff
		sta	$309
stop_olb:	lda	#$ff
		sta	$328
stop_ohb:	lda	#$ff
		sta	$329
		jmp	$0073
.endproc

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
		beq	execute
		inx
		cmp	#'x'
		bne	error
execute:	lda	commands_l,x
		sta	cmdjmp+1
		lda	commands_h,x
		sta	cmdjmp+2
cmdjmp:		jsr	$ffff
		jmp	NEXTST
error:		jmp	$af08	
.endproc

.segment "INSTALL"

		lda	$308
		sta	uninstall::gone_olb+1
		lda	#<gonehook
		sta	$308
		lda	$309
		sta	uninstall::gone_ohb+1
		lda	#>gonehook
		sta	$309
		lda	$328
		sta	uninstall::stop_olb+1
		lda	#<stophook
		sta	$328
		lda	$329
		sta	uninstall::stop_ohb+1
stophook:	lda	#>stophook
		sta	$329
		rts

