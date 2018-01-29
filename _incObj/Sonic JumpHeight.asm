; ---------------------------------------------------------------------------
; Subroutine controlling Sonic's jump height/duration
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_JumpHeight:
		tst.b	$3C(a0)                 ; see if sonic jumping
		beq.s	loc_134C4               ; if not continue
		move.w	#-$400,d1               ; set test to -4 pixels per frmae
		btst	#6,obStatus(a0)         ; see if sonic in water
		beq.s	loc_134AE               ; not continue
		move.w	#-$200,d1               ; set test velocity to -2 pixels per frame

loc_134AE:
		cmp.w	obVelY(a0),d1           ; compare y velocity to value from above
		ble.s	locret_134C2            ; if velocity is already less then return
		move.b	(v_jpadhold2).w,d0      ; get joystick value
		andi.b	#btnABC,d0	        ; is A, B or C pressed?
		bne.s	locret_134C2	        ; if yes, branch
		move.w	d1,obVelY(a0)           ; else move above value into y velocity

locret_134C2:
		rts	
; ===========================================================================

loc_134C4:
		cmpi.w	#-$FC0,obVelY(a0)       ; compare to maximum y velocity
		bge.s	locret_134D2            ; if less then return
		move.w	#-$FC0,obVelY(a0)       ; else set max velocity

locret_134D2:
		rts	
; End of function Sonic_JumpHeight