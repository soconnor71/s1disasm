; ---------------------------------------------------------------------------
; Subroutine to	make an	object fall downwards, increasingly fast
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjectFall:
		move.l	obX(a0),d2              ; get x pixel and subpixel position
		move.l	obY(a0),d3              ; get y pixel and subpixel position
		move.w	obVelX(a0),d0           ; get x velocity
		ext.l	d0                      ; sign extend
		asl.l	#8,d0                   ; align pxel and subpixl parts with longword position
		add.l	d0,d2                   ; add velocity to x
		move.w	obVelY(a0),d0           ; get y velocity
		addi.w	#$38,obVelY(a0)	        ; add gravity ($0038 = 0.21875)
		ext.l	d0                      ; sign extend
		asl.l	#8,d0                   ; align pixel and subpixel parts with longword position
		add.l	d0,d3                   ; add velocity to y position
		move.l	d2,obX(a0)              ; store new x position
		move.l	d3,obY(a0)              ; store new y position
		rts	                        ; return

; End of function ObjectFall