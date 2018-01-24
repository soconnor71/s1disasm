; ---------------------------------------------------------------------------
; Subroutine to	make Sonic walk/run
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Move:
		move.w	(v_sonspeedmax).w,d6    ; get sonics max speed into d6 ($0600 which is 6 pixels per frame)
		move.w	(v_sonspeedacc).w,d5    ; get sonics movement accel into d5 ($000c, which is 0.046875 per frame)
		move.w	(v_sonspeeddec).w,d4    ; get sonics deceleration is switching directions into d4 ($0080 which is 0.5 per frame)
		tst.b	(f_jumponly).w          ; see if jumping only
		bne.w	loc_12FEE               ; branch if jumping only and add force in direction of movement
		tst.w	$3E(a0)                 ; see if control lock timer active (when timer active moving is disabled)
		bne.w	Sonic_ResetScr          ; if so then jump ahead
		btst	#bitL,(v_jpadhold2).w   ; is left being pressed?
		beq.s	@notleft	        ; if not, go see if right pressed
		bsr.w	Sonic_MoveLeft          ; go handle left movement

	@notleft:
		btst	#bitR,(v_jpadhold2).w   ; is right being pressed?
		beq.s	@notright	        ; if not, continue ahead
		bsr.w	Sonic_MoveRight         ; otherwise handle right movement

	@notright:
		move.b	obAngle(a0),d0          ; get angle of sonic
		addi.b	#$20,d0                 ; add 45 degrees
		andi.b	#$C0,d0		        ; is Sonic on a	slope?
		bne.w	Sonic_ResetScr	        ; if yes, branch
		tst.w	obVelocity(a0)	        ; see if sonics velocity..
		bne.w	Sonic_ResetScr	        ; ..is greater than zero, if so branch
		bclr	#5,obStatus(a0)         ; clear pushing animation
		move.b	#id_Wait,obAnim(a0)     ; use "standing" animation
		btst	#3,obStatus(a0)
		beq.s	Sonic_Balance
		moveq	#0,d0
		move.b	$3D(a0),d0
		lsl.w	#6,d0
		lea	(v_objspace).w,a1
		lea	(a1,d0.w),a1
		tst.b	obStatus(a1)
		bmi.s	Sonic_LookUp
		moveq	#0,d1
		move.b	obActWid(a1),d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#4,d2
		add.w	obX(a0),d1
		sub.w	obX(a1),d1
		cmpi.w	#4,d1
		blt.s	loc_12F6A
		cmp.w	d2,d1
		bge.s	loc_12F5A
		bra.s	Sonic_LookUp
; ===========================================================================

Sonic_Balance:
		jsr	(ObjFloorDist).l
		cmpi.w	#$C,d1
		blt.s	Sonic_LookUp
		cmpi.b	#3,$36(a0)
		bne.s	loc_12F62

loc_12F5A:
		bclr	#0,obStatus(a0)
		bra.s	loc_12F70
; ===========================================================================

loc_12F62:
		cmpi.b	#3,$37(a0)
		bne.s	Sonic_LookUp

loc_12F6A:
		bset	#0,obStatus(a0)

loc_12F70:
		move.b	#id_Balance,obAnim(a0) ; use "balancing" animation
		bra.s	Sonic_ResetScr
; ===========================================================================

Sonic_LookUp:
		btst	#bitUp,(v_jpadhold2).w  ; is up being pressed?
		beq.s	Sonic_Duck	        ; if not, branch
		move.b	#id_LookUp,obAnim(a0)   ; use "looking up" animation
		cmpi.w	#$C8,(v_lookshift).w
		beq.s	loc_12FC2
		addq.w	#2,(v_lookshift).w
		bra.s	loc_12FC2
; ===========================================================================

Sonic_Duck:
		btst	#bitDn,(v_jpadhold2).w  ; is down being pressed?
		beq.s	Sonic_ResetScr	        ; if not, branch
		move.b	#id_Duck,obAnim(a0)     ; use "ducking" animation
		cmpi.w	#8,(v_lookshift).w
		beq.s	loc_12FC2
		subq.w	#2,(v_lookshift).w
		bra.s	loc_12FC2
; ===========================================================================

Sonic_ResetScr:
		cmpi.w	#$60,(v_lookshift).w    ; is screen in its default position?
		beq.s	loc_12FC2	        ; if yes, branch
		bcc.s	loc_12FBE
		addq.w	#4,(v_lookshift).w      ; move screen back to default

loc_12FBE:
		subq.w	#2,(v_lookshift).w      ; move screen back to default

loc_12FC2:
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnL+btnR,d0	        ; is left/right	pressed?
		bne.s	loc_12FEE	        ; if yes, branch
		move.w	obVelocity(a0),d0
		beq.s	loc_12FEE
		bmi.s	loc_12FE2
		sub.w	d5,d0
		bcc.s	loc_12FDC
		move.w	#0,d0

loc_12FDC:
		move.w	d0,obVelocity(a0)
		bra.s	loc_12FEE
; ===========================================================================

loc_12FE2:
		add.w	d5,d0
		bcc.s	loc_12FEA
		move.w	#0,d0

loc_12FEA:
		move.w	d0,obVelocity(a0)

loc_12FEE:
		move.b	obAngle(a0),d0          ; get the angle of sonic
		jsr	(CalcSine).l            ; returns with sine in d0 and cosine in d1 (word with fraction in low byte portion, whole number in upper byte)
		muls.w	obVelocity(a0),d1       ; multiply object speed by cosine, x_vel = velocity * cos(a)
		asr.l	#8,d1                   ; shift the calculated component to right 8 bits to readjust for fixed point (e.g. $08 = 0.5, $08*$08 = $40, but should be $04, or .25)
		move.w	d1,obVelX(a0)           ; move into x velocity
		muls.w	obVelocity(a0),d0       ; multiple y by sine of angle to get y component portion, y_vel = velocity * sin(a)
		asr.l	#8,d0                   ; shift right one byte, this realigns the fraction and whole part as using fixed point math
		move.w	d0,obVelY(a0)           ; move value into y velocity

loc_1300C:
		move.b	obAngle(a0),d0          ; get angle of object
		addi.b	#$40,d0                 ; add 90 degrees to it
		bmi.s	locret_1307C            ; if now 180 degrees or more then continue
		move.b	#$40,d1
		tst.w	obVelocity(a0)
		beq.s	locret_1307C
		bmi.s	loc_13024
		neg.w	d1

loc_13024:
		move.b	obAngle(a0),d0          ; get angle into d0
		add.b	d1,d0
		move.w	d0,-(sp)
		bsr.w	Sonic_WalkSpeed
		move.w	(sp)+,d0
		tst.w	d1
		bpl.s	locret_1307C
		asl.w	#8,d1
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	loc_13078
		cmpi.b	#$40,d0
		beq.s	loc_13066
		cmpi.b	#$80,d0
		beq.s	loc_13060
		add.w	d1,obVelX(a0)
		bset	#5,obStatus(a0)
		move.w	#0,obVelocity(a0)
		rts	
; ===========================================================================

loc_13060:
		sub.w	d1,obVelY(a0)
		rts	
; ===========================================================================

loc_13066:
		sub.w	d1,obVelX(a0)
		bset	#5,obStatus(a0)
		move.w	#0,obVelocity(a0)
		rts	
; ===========================================================================

loc_13078:
		add.w	d1,obVelY(a0)

locret_1307C:
		rts	
; End of function Sonic_Move


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_MoveLeft:
		move.w	obVelocity(a0),d0       ; get sonics velocity
		beq.s	loc_13086               ; if not moving continue
		bpl.s	loc_130B2               ; if moving right then jump ahead to decelerate sonic

loc_13086:
		bset	#0,obStatus(a0)         ; set facing left, and test first
		bne.s	loc_1309A               ; if already facing left continue
		bclr	#5,obStatus(a0)         ; otherwise clear pushing flag
		move.b	#1,obNextAni(a0)        ; reset animation frame

loc_1309A:
		sub.w	d5,d0                   ; subract acceleration from sonic to accelerate to left
		move.w	d6,d1                   ; get max speed into d1, 6 pixels per frame
		neg.w	d1                      ; negate, -6
		cmp.w	d1,d0                   ; compare current velocity to max
		bgt.s	loc_130A6               ; if less then continue on
		move.w	d1,d0                   ; else store max velocity

loc_130A6:
		move.w	d0,obVelocity(a0)       ; save velocity
		move.b	#id_Walk,obAnim(a0)     ; use walking animation
		rts	
; ===========================================================================

loc_130B2:                                      ; if we are here then pressing left button, but moving right
		sub.w	d4,d0                   ; subract deceleration constant from velocity to slow sonic down
		bcc.s	loc_130BA               ; if sign has not changed (i.e. still moving right) continue
		move.w	#-$80,d0                ; else clamp velocity to -$80 or -0.5

loc_130BA:
		move.w	d0,obVelocity(a0)       ; save value into velocity
		move.b	obAngle(a0),d0          ; get sonics angle
		addi.b	#$20,d0                 ; add 45 degrees
		andi.b	#$C0,d0                 ; see if on slope
		bne.s	locret_130E8            ; if so return
		cmpi.w	#$400,d0
		blt.s	locret_130E8
		move.b	#id_Stop,obAnim(a0)     ; use "stopping" animation
		bclr	#0,obStatus(a0)
		sfx	sfx_Skid,0,0,0	        ; play stopping sound

locret_130E8:
		rts	
; End of function Sonic_MoveLeft


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_MoveRight:                                ; right button is pressed
		move.w	obVelocity(a0),d0       ; get sonics current velocity
		bmi.s	loc_13118               ; are we currently moving left, if so we need to decelerate sonic
		bclr	#0,obStatus(a0)         ; set to facing right, and test to see if we were already facing right
		beq.s	loc_13104               ; if so skip
		bclr	#5,obStatus(a0)         ; if not then clear any pushing state
		move.b	#1,obNextAni(a0)        ; reset animation frame

loc_13104:
		add.w	d5,d0                   ; add acceleration constant to sonics velocity
		cmp.w	d6,d0                   ; compare to max velocty
		blt.s	loc_1310C               ; if less continue
		move.w	d6,d0                   ; else move max speed into sonics velocity

loc_1310C:
		move.w	d0,obVelocity(a0)       ; save new velocity
		move.b	#id_Walk,obAnim(a0)     ; use walking animation
		rts	                        ; return
; ===========================================================================

loc_13118:                                      ; if we get here, sonic is currently moving left (-ve velocity, but we are pressing right)
		add.w	d4,d0                   ; add deceleration constant to sonics velocity so we start to slow down and move to right
		bcc.s	loc_13120               ; did we change sign?, i.e. back to zero or moving to the right, if not continue
		move.w	#$80,d0                 ; else clamp speed to $80 (0.5)

loc_13120:
		move.w	d0,obVelocity(a0)       ; save new velocity
		move.b	obAngle(a0),d0          ; get angle of sonic
		addi.b	#$20,d0                 ; add 45 degrees
		andi.b	#$C0,d0                 ; see if on slope
		bne.s	locret_1314E
		cmpi.w	#-$400,d0
		bgt.s	locret_1314E
		move.b	#id_Stop,obAnim(a0)     ; use "stopping" animation
		bset	#0,obStatus(a0)
		sfx	sfx_Skid,0,0,0	        ; play stopping sound

locret_1314E:
		rts	
; End of function Sonic_MoveRight
