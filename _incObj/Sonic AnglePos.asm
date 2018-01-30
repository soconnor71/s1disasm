; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's angle & position as he walks along the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_AnglePos:
		btst	#3,obStatus(a0)         ; is sonic in the air but shouldn't fall as he is touching an object not a tile
		beq.s	loc_14602               ; if not continue on
		moveq	#0,d0                   ; otherwise clear d0
		move.b	d0,($FFFFF768).w        ; set left angle to 0
		move.b	d0,($FFFFF76A).w        ; set right angle to 0
		rts	
; ===========================================================================
loc_14602:
		moveq	#3,d0                   ; set d0 to 3 degrees
		move.b	d0,($FFFFF768).w        ; set right foot angle to 3 degrees
		move.b	d0,($FFFFF76A).w        ; set left foot angle to 3 degrees
		move.b	obAngle(a0),d0          ; get angle of object into d0
		addi.b	#$20,d0                 ; add 45 degrees
		bpl.s	loc_14624
		move.b	obAngle(a0),d0
		bpl.s	loc_1461E
		subq.b	#1,d0

loc_1461E:
		addi.b	#$20,d0
		bra.s	loc_14630
; ===========================================================================

loc_14624:
		move.b	obAngle(a0),d0
		bpl.s	loc_1462C
		addq.b	#1,d0

loc_1462C:
		addi.b	#$1F,d0

loc_14630:
		andi.b	#$C0,d0                 ; consider only the msb 2 bits (determines the quadrant)
		cmpi.b	#$40,d0                 ; if only lowest msb bit set then we are walking up left wall
		beq.w	Sonic_WalkVertL         ; go handle that quadrant
		cmpi.b	#$80,d0                 ; if only highest msb bit set then we are upside down
		beq.w	Sonic_WalkCeiling       ; go handle ceiling walking
		cmpi.b	#$C0,d0                 ; if both bits set then walking up right wall
		beq.w	Sonic_WalkVertR         ; go handle walking up right wall
                                                ; otherwise we are on the floor
; ===========================================================================

		move.w	obY(a0),d2              ; get y position into d2
		move.w	obX(a0),d3              ; get x position into d3
		moveq	#0,d0                   ; clear d0
		move.b	obHeight(a0),d0         ; get object height into d0
		ext.w	d0                      ; sign extend into word
		add.w	d0,d2                   ; add height to calc y location of feet
		move.b	obWidth(a0),d0          ; get width of object
		ext.w	d0                      ; sign extend
		add.w	d0,d3                   ; add to x position to get right extent
		lea	($FFFFF768).w,a4        ; get address of right foot angle
		movea.w	#$10,a3                 ; set distance to 16 pixel to add to y position if we need to check for another  tile
		move.w	#0,d6                   ; do not invert y for the height map
		moveq	#$D,d5                  ; bit to test for solidity
		bsr.w	FindFloor               ; find closest floor, distance in d1, angle in location above
		move.w	d1,-(sp)                ; save result to stack
		move.w	obY(a0),d2              ; refetch y pos
		move.w	obX(a0),d3              ; refetch x pos
		moveq	#0,d0                   ; clear
		move.b	obHeight(a0),d0         ; get object height
		ext.w	d0                      ; sign extend
		add.w	d0,d2                   ; add to y to get y position of feet
		move.b	obWidth(a0),d0          ; get width
		ext.w	d0                      ; extend
		neg.w	d0                      ; negate
		add.w	d0,d3                   ; add offset to give left bounds of sonic
		lea	($FFFFF76A).w,a4        ; set address to save angle in
		movea.w	#$10,a3                 ; set 16 pixels to add to y location if we need to test a new tile below
		move.w	#0,d6                   ; do not invert height map
		moveq	#$D,d5                  ; bit to test for solidity
		bsr.w	FindFloor               ; go find closest floor, distance in d1, angle returned in location above
		move.w	(sp)+,d0                ; move right result to d0
		bsr.w	Sonic_Angle             ; d1 set to largest sample point, and object angle updated to match sample point's angle
		tst.w	d1                      ; test distance to move sonic
		beq.s	locret_146BE            ; if zero then just return, we are where we need to be
		bpl.s	loc_146C0               ; if positive, then sonic needs to move down
		cmpi.w	#-$E,d1                 ; see if amount to adjust is greater than 14 pixels up
		blt.s	locret_146E6            ; if so jump ahead and return
		add.w	d1,obY(a0)              ; else add the adjustment to y

locret_146BE:
		rts	                        ; then return
; ===========================================================================

loc_146C0:
		cmpi.w	#$E,d1                  ; see if distance to move greater than 14 pixels down
		bgt.s	loc_146CC               ; if so branch ahead as we are falling

loc_146C6:
		add.w	d1,obY(a0)              ; else add amount to move to y
		rts	                        ; return
; ===========================================================================

loc_146CC:
		tst.b	$38(a0)
		bne.s	loc_146C6
		bset	#1,obStatus(a0)         ; sonic is in the air
		bclr	#5,obStatus(a0)         ; not pushing
		move.b	#1,obNextAni(a0)        ; cue falling animation
		rts	                        ' return
; ===========================================================================

locret_146E6:
		rts	
; End of function Sonic_AnglePos

; ===========================================================================
		move.l	obX(a0),d2
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d2
		move.l	d2,obX(a0)
		move.w	#$38,d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,obY(a0)
		rts	
; ===========================================================================

locret_1470A:
		rts	
; ===========================================================================
		move.l	obY(a0),d3
		move.w	obVelY(a0),d0
		subi.w	#$38,d0
		move.w	d0,obVelY(a0)
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,obY(a0)
		rts	
		rts	
; ===========================================================================
		move.l	obX(a0),d2
		move.l	obY(a0),d3
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d2
		move.w	obVelY(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d2,obX(a0)
		move.l	d3,obY(a0)
		rts	

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's angle as he walks along the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Angle:                                    ; sets sonic to the angle and height of whichever sensor is higher
		move.b	($FFFFF76A).w,d2        ; get angle of right foot position
		cmp.w	d0,d1                   ; compare right height to left height
		ble.s	loc_1475E               ; if less jump ahead
		move.b	($FFFFF768).w,d2        ; else move right foot angle into d2
		move.w	d0,d1                   ; move right foot height into d1

loc_1475E:
		btst	#0,d2                   ; see if bit 0 of angle set
		bne.s	loc_1476A               ; if set continue
		move.b	d2,obAngle(a0)          ; record angle of object
		rts	                        ; return
; ===========================================================================

loc_1476A:
		move.b	obAngle(a0),d2          ; get object angle
		addi.b	#$20,d2                 ; add 45 degrees
		andi.b	#$C0,d2                 ; keep only the top two bits
		move.b	d2,obAngle(a0)          ; move value into angle
		rts	                        ; return
; End of function Sonic_Angle

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk up a vertical slope/wall to	his right
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_WalkVertR:
		move.w	obY(a0),d2              ; get y position into d2
		move.w	obX(a0),d3              ; get x position into d3
		moveq	#0,d0                   ; clear d0
		move.b	obWidth(a0),d0          ; get object width
		ext.w	d0                      ; extend
		neg.w	d0                      ; negate
		add.w	d0,d2                   ; basically subtract width from y to get right foot sample position
		move.b	obHeight(a0),d0         ; get object height
		ext.w	d0                      ; extend
		add.w	d0,d3                   ; add to x position to get bottom level of sonic
		lea	($FFFFF768).w,a4        ; get address of right foot sample angle
		movea.w	#$10,a3                 ; set amount to add to 16 pixels if we need to look for a new tile
		move.w	#0,d6                   ; set we are not flipping the height map
		moveq	#$D,d5                  ; set flag to test for solidity (side)
		bsr.w	FindWall                ; go find closest wall, distance in d1, angle in address above
		move.w	d1,-(sp)                ; save on stack
		move.w	obY(a0),d2              ; restore y pos to d2
		move.w	obX(a0),d3              ; restore x pos to d3
		moveq	#0,d0                   ; clear d0
		move.b	obWidth(a0),d0          ; get object width
		ext.w	d0                      ; extend
		add.w	d0,d2                   ; add to y position to get left foot sample position
		move.b	obHeight(a0),d0         ; get object height
		ext.w	d0                      ; extend
		add.w	d0,d3                   ; add to x to get position of bottom of feet
		lea	($FFFFF76A).w,a4        ; set location to store left foot sample angle
		movea.w	#$10,a3                 ; set amount to add if we need to consider an adjacent tile
		move.w	#0,d6                   ; do not flip the height map
		moveq	#$D,d5                  ; set bit to test for solidity (side)
		bsr.w	FindWall                ; go find closest wall, distance in d1, angle in address above
		move.w	(sp)+,d0                ; restore right foot sample into d0
		bsr.w	Sonic_Angle             ; move largest sample into d1 and matching angle into object angle
		tst.w	d1                      ; test distance
		beq.s	locret_147F0            ; if zero then return
		bpl.s	loc_147F2               ; if plus, then adjusting to right
		cmpi.w	#-$E,d1                 ; compare distance to move to more than 14 pixels to the left (up)
		blt.w	locret_1470A            ; if more, then continue
		add.w	d1,obX(a0)              ; make adjustment

locret_147F0:
		rts	
; ===========================================================================

loc_147F2:
		cmpi.w	#$E,d1                  ; see if distance to move sonic down (in reality to the right) is greater than 14 pixels
		bgt.s	loc_147FE               ; if so continue on

loc_147F8:
		add.w	d1,obX(a0)              ; else do the adjustment
		rts	                        ; return
; ===========================================================================

loc_147FE:
		tst.b	$38(a0)                 ; test flag
		bne.s	loc_147F8               ; if set then make adjustment and continue
		bset	#1,obStatus(a0)         ; set in air
		bclr	#5,obStatus(a0)         ; clear pushing flag
		move.b	#1,obNextAni(a0)        ; set falling anim
		rts	
; End of function Sonic_WalkVertR

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk upside-down
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_WalkCeiling:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF768).w,a4
		movea.w	#-$10,a3
		move.w	#$1000,d6
		moveq	#$D,d5
		bsr.w	FindFloor
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	($FFFFF76A).w,a4
		movea.w	#-$10,a3
		move.w	#$1000,d6               ; flip height map as sonic upside down
		moveq	#$D,d5
		bsr.w	FindFloor
		move.w	(sp)+,d0
		bsr.w	Sonic_Angle
		tst.w	d1
		beq.s	locret_14892
		bpl.s	loc_14894
		cmpi.w	#-$E,d1
		blt.w	locret_146E6
		sub.w	d1,obY(a0)

locret_14892:
		rts	
; ===========================================================================

loc_14894:
		cmpi.w	#$E,d1
		bgt.s	loc_148A0

loc_1489A:
		sub.w	d1,obY(a0)
		rts	
; ===========================================================================

loc_148A0:
		tst.b	$38(a0)
		bne.s	loc_1489A
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		move.b	#1,obNextAni(a0)
		rts	
; End of function Sonic_WalkCeiling

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk up a vertical slope/wall to	his left
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_WalkVertL:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	($FFFFF768).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6                ; flip height map as sonic moving opposite direction from normal
		moveq	#$D,d5
		bsr.w	FindWall
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	($FFFFF76A).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		moveq	#$D,d5
		bsr.w	FindWall
		move.w	(sp)+,d0
		bsr.w	Sonic_Angle
		tst.w	d1
		beq.s	locret_14934
		bpl.s	loc_14936
		cmpi.w	#-$E,d1
		blt.w	locret_1470A
		sub.w	d1,obX(a0)

locret_14934:
		rts	
; ===========================================================================

loc_14936:
		cmpi.w	#$E,d1
		bgt.s	loc_14942

loc_1493C:
		sub.w	d1,obX(a0)
		rts	
; ===========================================================================

loc_14942:
		tst.b	$38(a0)
		bne.s	loc_1493C
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		move.b	#1,obNextAni(a0)
		rts	
; End of function Sonic_WalkVertL
