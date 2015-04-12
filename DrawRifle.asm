; x: headcenter_x, y: headcenter_y: direction: DIRECTION_LEFT or DIRECTION_RIGHT
DrawRifle PROC USES eax edx, hdcbuffer: HDC, x: LONG, y: LONG, direction: SDWORD
	LOCAL hThickPen: HPEN, oldPen: HPEN, hThinPen: HPEN, hMediumPen: HPEN
	
	RGB 0FFh, 0FFh, 0FFh
	INVOKE CreatePen, PS_SOLID, 4, eax
	mov hThickPen, eax
	RGB 0FFh, 0FFh, 0FFh
	INVOKE CreatePen, PS_SOLID, 2, eax
	mov hThinPen, eax
	RGB 0FFh, 0FFh, 0FFh
	INVOKE CreatePen, PS_SOLID, 3, eax
	mov hMediumPen, eax
	
	INVOKE SelectObject, hdcbuffer, hThickPen
	mov oldPen, eax
	
	mov eax, x
	.IF direction == DIRECTION_LEFT
		sub eax, 5
	.ELSE
		add eax, 5
	.ENDIF
	mov edx, y
	add edx, 5
	mov x, eax
	mov y, edx
	
	INVOKE MoveToEx, hdcbuffer, x, y, NULL
	mov eax, x
	.IF direction == DIRECTION_LEFT
		add eax, 5
	.ELSE
		sub eax, 5
	.ENDIF
	mov edx, y
	add edx, 10
	INVOKE LineTo, hdcbuffer, eax, edx

	INVOKE SelectObject, hdcbuffer, hMediumPen

	mov eax, x
	.IF direction == DIRECTION_LEFT
		add eax, 3
	.ELSE
		sub eax, 3
	.ENDIF
	mov edx, y
	add edx, 6
	INVOKE MoveToEx, hdcbuffer, eax, edx, NULL
	mov eax, x
	.IF direction == DIRECTION_LEFT
		sub eax, 6
	.ELSE
		add eax, 6
	.ENDIF
	mov edx, y
	add edx, 6
	INVOKE LineTo, hdcbuffer, eax, edx

	INVOKE SelectObject, hdcbuffer, hThinPen
	
	mov eax, x
	.IF direction == DIRECTION_LEFT
		add eax, 5
	.ELSE
		sub eax, 5
	.ENDIF
	mov edx, y
	add edx, 10
	INVOKE MoveToEx, hdcbuffer, eax, edx, NULL
	mov eax, x
	.IF direction == DIRECTION_LEFT
		sub eax, 1
	.ELSE
		add eax, 1
	.ENDIF
	mov edx, y
	add edx, 13
	INVOKE LineTo, hdcbuffer, eax, edx
	
	INVOKE SelectObject, hdcbuffer, oldPen
	INVOKE DeleteObject, hThickPen
	INVOKE DeleteObject, hThinPen
	INVOKE DeleteObject, hMediumPen

	ret
DrawRifle ENDP


; Example:
; INVOKE DrawRifle, hdcbuffer, headcenter_x, headcenter_y, DIRECTION_RIGHT