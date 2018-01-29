; ---------------------------------------------------------------------------
; Subroutine to	find the distance to the floor
; Looking at the maps, there are never more than two tiles that actually
; use a height map, therefore these routines will look up and down to find
; the next tile if a collision is not located with the given collision point
;
; a tile has the following format:
;   0SSYX0TTTTTTTTTT
;   SS = 00:  Not solid
;        01:  Top Solid
;        10:  Bottom, left and right solid
;        11:  Solid
;   Y = flip in y
;   X = flip in x
;   T = the tile id to use
;
; input:
;	d2 = y-position of point to test
;	d3 = x-position of point to test
;	d5 = bit to test for solidness
;   d6 = value to EOR with
;   a3 = amount to add to y position if we need to check for another tile (usually 16, the width of a single tile)
;   a4 = address of where to write the computed angle from the height map tile


; output:
;	d1 = distance to the floor
;	a1 = address within 256x256 mappings where object is standing
;	     (refers to a 16x16 tile number)
;	(a4) = floor angle
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FindFloor:
		bsr.s	FindNearestTile ; returns address of tile that contains sample point
		move.w	(a1),d0		    ; get the tile meta data
		move.w	d0,d4           ; save the data to d4
		andi.w	#$7FF,d0        ; mask out just the tile id
		beq.s	@isblank	    ; branch if tile is blank
		btst	d5,d4		    ; d5 is used to determine which bit to test to see if we are solid (we can either test for top solid, or bottom left and right solid)
		bne.s	@issolid	    ; if yes, branch

@isblank:
		add.w	a3,d2           ; add the given offset to move us to the next tile
		bsr.w	FindFloor2	    ; try to find the distance from this tile
		sub.w	a3,d2           ; adjust the y position back to where it was
		addi.w	#$10,d1		    ; add 16 to distance to tile, though this should probably be adding a3 really
		rts	
; ===========================================================================

@issolid:
		movea.l	(v_collindex).w,a2  ; get base address of the collision map table
		move.b	(a2,d0.w),d0	    ; index the collision id table based on tile id to get the collision id
		andi.w	#$FF,d0             ; see if any bits set
		beq.s	@isblank	        ; branch if 0, and try the next tile down
		lea	(AngleMap).l,a2         ; get base address of angle map for tiles
		move.b	(a2,d0.w),(a4)	    ; get the angle value for the current height map table and store in the address given in a4
		lsl.w	#4,d0               ; there are 16 entries in each height table entry, so mult collision id by 16 to get offset into height table
		move.w	d3,d1		        ; get x-pos. of object
		btst	#$B,d4		        ; is block flipped horizontally?
		beq.s	@noflip		        ; if not, branch
		not.w	d1                  ; invert x-position
		neg.b	(a4)                ; negate angle to flip in x-axis

	@noflip:
		btst	#$C,d4		        ; see if y bit set to see if we need to flip vertically
		beq.s	@noflip2	        ; if not, branch
		addi.b	#$40,(a4)           ; add 90 degrees to angle
		neg.b	(a4)                ; negate angle
		subi.b	#$40,(a4)           ; subtract 90 degrees, basically this flips angle in y direction

	@noflip2:
		andi.w	#$F,d1              ; extract only the lower 4 bits of x-position to find position within tile (0-15)
		add.w	d0,d1		        ; add x-position into tile to height map base address to get height at x -location
		lea	(CollArray1).l,a2       ; get base address
		move.b	(a2,d1.w),d0	    ; get height value from map
		ext.w	d0                  ; extend to word
		eor.w	d6,d4               ; the tile meta data is xor'd here with d6. This allows us to toggle the y flip status if sonic is upside down
		btst	#$C,d4		        ; test y-bit again to see if we need to flip in vertical
		beq.s	@noflip3	        ; if not, branch
		neg.w	d0                  ; negate the height value from the map

	@noflip3:
		tst.w	d0                  ; test height map value (basically compare to zero)
		beq.s	@isblank	        ; if zero, then go check next tile below this one
		bmi.s	@negfloor	        ; if value is negative, then go handle specially
		cmpi.b	#$10,d0             ; see if value $10,
		beq.s	@maxfloor	        ; if so then we need to inspect the tile above this one
		move.w	d2,d1		        ; get y-pos. of object
		andi.w	#$F,d1              ; extract lower 4 bits, which limits it to the y position within tile (0-15)
		add.w	d1,d0               ; tile height is based from bottom of tile, y position is based from top of tile, so ypos - (15 - tile height) = ypos+
		move.w	#$F,d1              ; put 15 into d1
		sub.w	d0,d1		        ; 15-(d0+d1) = 15 - ypos - yheight
		rts	
; ===========================================================================

@negfloor:
		move.w	d2,d1               ; get y position into d1
		andi.w	#$F,d1              ; mask out lower 4 bits to get position into tile (0-15)
		add.w	d1,d0
		bpl.w	@isblank

@maxfloor:
		sub.w	a3,d2
		bsr.w	FindFloor2	; try tile above the nearest
		add.w	a3,d2
		subi.w	#$10,d1		; return distance to floor
		rts	
; End of function FindFloor


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FindFloor2:
		bsr.w	FindNearestTile
		move.w	(a1),d0
		move.w	d0,d4
		andi.w	#$7FF,d0
		beq.s	@isblank2
		btst	d5,d4
		bne.s	@issolid

@isblank2:
		move.w	#$F,d1
		move.w	d2,d0
		andi.w	#$F,d0
		sub.w	d0,d1
		rts	
; ===========================================================================

@issolid:
		movea.l	(v_collindex).w,a2
		move.b	(a2,d0.w),d0
		andi.w	#$FF,d0
		beq.s	@isblank2
		lea	(AngleMap).l,a2
		move.b	(a2,d0.w),(a4)
		lsl.w	#4,d0
		move.w	d3,d1
		btst	#$B,d4
		beq.s	@noflip
		not.w	d1
		neg.b	(a4)

	@noflip:
		btst	#$C,d4
		beq.s	@noflip2
		addi.b	#$40,(a4)
		neg.b	(a4)
		subi.b	#$40,(a4)

	@noflip2:
		andi.w	#$F,d1
		add.w	d0,d1
		lea	(CollArray1).l,a2
		move.b	(a2,d1.w),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$C,d4
		beq.s	@noflip3
		neg.w	d0

	@noflip3:
		tst.w	d0
		beq.s	@isblank2
		bmi.s	@negfloor
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts	
; ===========================================================================

@negfloor:
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	@isblank2
		not.w	d1
		rts	
; End of function FindFloor2
