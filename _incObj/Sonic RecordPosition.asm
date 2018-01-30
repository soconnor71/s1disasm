; ---------------------------------------------------------------------------
; Subroutine to	record Sonic's previous positions for invincibility stars
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RecordPosition:
		move.w	(v_trackpos).w,d0       ; current pointer into track buffer
		lea	(v_tracksonic).w,a1     ; get start of buffer
		lea	(a1,d0.w),a1            ; add offset into track buffer
		move.w	obX(a0),(a1)+           ; store x position
		move.w	obY(a0),(a1)+           ; store y position
		addq.b	#4,(v_trackbyte).w      ; advance track buffer pointer by 4 bytes (2 words) to point to next slot
		rts	                        ; return
; End of function Sonic_RecordPosition