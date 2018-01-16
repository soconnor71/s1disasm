; ---------------------------------------------------------------------------
; Subroutine to	find which tile	a given x,y point is contained in

; input:
;	d2 = y-position of point to test
;	d3 = x-position of point to test

; output:
;	a1 = address within 256x256 mappings where object is standing
;	     (refers to a 16x16 tile number)
;
; A level is made up of blocks. Blocks represent a 256x256 pixel area. Each block
; is made up of 16x16 tiles, where each tile is 2x2 characters in size, each
; character being 8 pixels wide.
;
; A level consists of a single byte per block number, and are stored in a
; 128x8 matrix
;
; Blocks are stored consecutively in memory and consist of one word (two bytes)
; per tile. Therefore each block takes 16x16x2 = 512 bytes
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FindNearestTile:
		move.w	d2,d0		    ; get y-pos. of object
		lsr.w	#1,d0		    ; we figure out the offset into the level data. Each block is 256 pixels high, and there are 128 bytes per block row, so y/256 gives us the row number, multiply by 128 gives us the memory offset, y/256 * 128 is the same as y/2, which is what we do to get the offset into the block data
		andi.w	#$380,d0	    ; this keeps only the part of y we are interested in, if we had divided by 256, and then multiplied the low order bits would be zero, this clears it out, it also clamps the important part of y to only be between 0-7 as we only have 8 rows of data.
		move.w	d3,d1		    ; get x-pos. of object
		lsr.w	#8,d1		    ; as a block is 256 pixels wide, we divide the x co-ord by 256 (right shift 8 times) to find the column offset
		andi.w	#$7F,d1		    ; here we and with $7f to clamp the x offset to a value between 0-127 which is how many columns there are in the data
		add.w	d1,d0		    ; adding the two values together gives us the offset into the level data to determine which block id to use.
		moveq	#-1,d1		    ; signals blank tile
		lea	(v_lvllayout).w,a1  ; we get the base address of the level layout data into a1
		move.b	(a1,d0.w),d1	; we use the above offset to look up the block id that our collision point is contained in
		beq.s	@blanktile	    ; branch if 0
		bmi.s	@specialtile	; branch if >$7F
		subq.b	#1,d1		    ; as 0 means blank tile, our valid ids start at 1. This subracts one to make our id's zero based for calculating the offset into the block data.
		ext.w	d1		        ; extend byte data to word
		ror.w	#7,d1		    ; Each block contains 16x16 tile ids, each id is one word (2 bytes) so is 512 bytes long. We multiply our block id by 512 to get the starting offset into the correct block's data.
		move.w	d2,d0		    ; we copy y into d0 and now need to figure out the corresponding row into the block.
		add.w	d0,d0		    ; Each pixel is 16 pixels high, so y/16 gives us a column for the entire level. There are 16 tiles per row, so y/16 * 16 gives us the memory offset, but each location is two bytes, so y/16 * 16 * 2 which reduces to y * 2
		andi.w	#$1E0,d0	    ; this value still represents the y column for all tiles, so to limit it to just the block in question, we mask out the high bytes, so we only have 4 y bits (value from 0-15) which gives us the correct offset into our current block.
		add.w	d0,d1		    ; we add this value to the start of our block data to get the start of the correct row based on y
		move.w	d3,d0		    ; to figure out the correct column we only need to divide x by 16, but then multiply by 2 as each tile entry has 2 bytes
		lsr.w	#3,d0		    ; so here we divide by 8
		andi.w	#$1E,d0		    ; this gives us the tile column across the who level width, so we mask off the top bits to leave only the 4 bits needed to represent the column value within our current block only
		add.w	d0,d1		    ; we add this to the row start value to get the actual address of the tile the test point was contained within.

@blanktile:
		movea.l	d1,a1		    ; we move the calculated address in d1 into the a1 register and return
		rts	
; ===========================================================================

@specialtile:
		andi.w	#$7F,d1		    ; we mask out bit 7 to return it to a 'normal' tile.
		btst	#6,obRender(a0) ; is object "behind a loop"?
		beq.s	@treatasnormal	; if not, branch to go calculate the address position
		addq.w	#1,d1		    ; we add 1 to the block id,
		cmpi.w	#$29,d1		    ; to see if it matches block #$29
		bne.s	@treatasnormal	; if it doesn't then we continue as before
		move.w	#$51,d1

	@treatasnormal:
		subq.b	#1,d1		    ; this code performs essentially the same steps as above with the exception of the sign extension
		ror.w	#7,d1		    ; this code calculates which tile within the 16x16 block of tiles contains the sample point
		move.w	d2,d0		    ; and generates an address to that word of data within the block data.
		add.w	d0,d0		    ; see above for more detail of how this works.
		andi.w	#$1E0,d0
		add.w	d0,d1
		move.w	d3,d0
		lsr.w	#3,d0
		andi.w	#$1E,d0
		add.w	d0,d1
		movea.l	d1,a1
		rts	
; End of function FindNearestTile