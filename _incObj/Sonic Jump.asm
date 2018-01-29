; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to jump
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Jump:
		move.b	(v_jpadpress2).w,d0     ; get joypad
		andi.b	#btnABC,d0	        ; is A, B or C pressed?
		beq.w	locret_1348E	        ; if not, return
		moveq	#0,d0                   ; clear d0
		move.b	obAngle(a0),d0          ; get sonics angle
		addi.b	#$80,d0                 ; add 180 degrees (flip direction)
		bsr.w	sub_14D48
		cmpi.w	#6,d1
		blt.w	locret_1348E
		move.w	#$680,d2                ; set jump speed to $680 (6.5 per frame)
		btst	#6,obStatus(a0)         ; see if sonic in water
		beq.s	loc_1341C               ; if not jump ahead
		move.w	#$380,d2                ; otherwise set jump speed to $380 (3.5 per frame)

loc_1341C:
		moveq	#0,d0                   ; clear d0
		move.b	obAngle(a0),d0          ; get sonics angle
		subi.b	#$40,d0                 ; subtract 90 degrees (we want to jump away from the ground)
		jsr	(CalcSine).l            ; calc angle
		muls.w	d2,d1                   ; get x component of jump x, = vel * cos(angle)
		asr.l	#8,d1                   ; remove any fractional part
		add.w	d1,obVelX(a0)	        ; save x velocity
		muls.w	d2,d0                   ; get y component of jump, y = vel * sin(angle)
		asr.l	#8,d0                   ; remove fractional part
		add.w	d0,obVelY(a0)	        ; save y velocity
		bset	#1,obStatus(a0)         ; set sonic in the air
		bclr	#5,obStatus(a0)         ; clear pushing flag
		addq.l	#4,sp                   ; this will cause us to return to the previous function before the function that called this one, this will stop us doing the rest of the modes for this frame
		move.b	#1,$3C(a0)              ; set jumping flag
		clr.b	$38(a0)
		sfx	sfx_Jump,0,0,0	        ; play jumping sound
		move.b	#$13,obHeight(a0)       ; set sonics height to be 19
		move.b	#9,obWidth(a0)          ; set sonics width to be 9
		btst	#2,obStatus(a0)         ; see if rolling
		bne.s	loc_13490               ; if so branch
		move.b	#$E,obHeight(a0)        ; change height
		move.b	#7,obWidth(a0)          ; change width
		move.b	#id_Roll,obAnim(a0)     ; use "jumping" animation
		bset	#2,obStatus(a0)         ; set jumping status flag
		addq.w	#5,obY(a0)              ; set offset to y so sonic stays in same place relative to where he was

locret_1348E:
		rts	
; ===========================================================================

loc_13490:
		bset	#4,obStatus(a0)         ; set jumping after rolling flag
		rts	                        ; return
; End of function Sonic_Jump