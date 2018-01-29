; ---------------------------------------------------------------------------
; Subroutine to	return Sonic's angle to 0 as he jumps
; Every frame 2 units will be added or subtracted from sonics angle until
; he returns to zero angle or the jump ends.
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_JumpAngle:
		move.b	obAngle(a0),d0	; get Sonic's angle
		beq.s	locret_135A2	; if already 0,	then simply return
		bpl.s	loc_13598	; if higher than 0, branch we need to decrease the angle

		addq.b	#2,d0		; increase angle
		bcc.s	loc_13596       ; continue on to save value if we haven't wrapped
		moveq	#0,d0           ; else clamp angle to zero

loc_13596:
		bra.s	loc_1359E
; ===========================================================================

loc_13598:
		subq.b	#2,d0		; decrease angle
		bcc.s	loc_1359E       ; if greater than zero branch ahead
		moveq	#0,d0           ; clamp to zero

loc_1359E:
		move.b	d0,obAngle(a0)  ; save value back into sonics angle

locret_135A2:
		rts	                ; return
; End of function Sonic_JumpAngle