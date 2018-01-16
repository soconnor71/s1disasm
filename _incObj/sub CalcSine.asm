; ---------------------------------------------------------------------------
; Subroutine calculate a sine

; input:
;	d0 = angle

; output:
;	d0 = sine
;	d1 = cosine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


CalcSine:
		andi.w	#$FF,d0                     ; limit angle to 0-$ff
		add.w	d0,d0                       ; double the value as each table entry is a word
		addi.w	#$80,d0                     ; add 90 degrees to the angle to get a cos value ($40 is 90 degrees, but 2 bytes per entry so $80)
		move.w	Sine_Data(pc,d0.w),d1       ; get the cos value back
		subi.w	#$80,d0                     ; subtract 90 degrees
		move.w	Sine_Data(pc,d0.w),d0       ; get the sine value back in d0
		rts	
; End of function CalcSine

; ===========================================================================

Sine_Data:	incbin	"misc\sinewave.bin"	; values for a 360� sine wave

; ===========================================================================

; The following code is unused garbage.

		if Revision=0
		movem.l	d1-d2,-(sp)
		move.w	d0,d1
		swap	d1
		moveq	#0,d0
		move.w	d0,d1
		moveq	#7,d2

	loc_2C80:
		rol.l	#2,d1
		add.w	d0,d0
		addq.w	#1,d0
		sub.w	d0,d1
		bcc.s	loc_2C9A
		add.w	d0,d1
		subq.w	#1,d0
		dbf	d2,loc_2C80
		lsr.w	#1,d0
		movem.l	(sp)+,d1-d2
		rts	
; ===========================================================================

	loc_2C9A:
		addq.w	#1,d0
		dbf	d2,loc_2C80
		lsr.w	#1,d0
		movem.l	(sp)+,d1-d2
		rts	
		else
		endc