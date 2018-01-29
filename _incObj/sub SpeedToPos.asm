; ---------------------------------------------------------------------------
; Subroutine translating object	speed to update	object position
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SpeedToPos:
		move.l	obX(a0),d2      ; get pixel and subpixel position into x (upper word, pixel, lower word sub pixel)
		move.l	obY(a0),d3      ; get pixel and subpixel position into y
		move.w	obVelX(a0),d0	; load horizontal velocity
		ext.l	d0              ; sign extend to long word
		asl.l	#8,d0		; shift velocity over one byte so pixel and sub pixel components line up with long word
		add.l	d0,d2		; add to x-axis	position
		move.w	obVelY(a0),d0	; load vertical	velocity
		ext.l	d0              ; sign extend
		asl.l	#8,d0		; shift one byte to left, so upper word contains pixel component and lower word contains subpixel
		add.l	d0,d3		; add to y-axis	position
		move.l	d2,obX(a0)	; update x-axis	position
		move.l	d3,obY(a0)	; update y-axis	position
		rts	

; End of function SpeedToPos