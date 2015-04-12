.386
.model flat,STDCALL
option casemap :none

include \masm32\include\windows.inc
include \masm32\macros\macros.asm
include \masm32\include\masm32.inc
include \masm32\include\gdi32.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

INCLUDE Cursor.inc

.data
hCursorBmp  HBITMAP ?
cursorPos   POINT   <>
cursorMask1	HBITMAP	?
cursorMask2	HBITMAP	?

.code

LoadCursorBitmap PROC USES eax
	LOCAL hInstance: HINSTANCE
    
	INVOKE GetModuleHandle, NULL
	mov hInstance, eax
    
	INVOKE LoadBitmap, hInstance, CURSOR_RES_ID
    mov hCursorBmp, eax
	INVOKE LoadBitmap, hInstance, MASK_1_RES_ID
	mov cursorMask1, eax
	INVOKE LoadBitmap, hInstance, MASK_2_RES_ID
	mov cursorMask2, eax
    
    ret
LoadCursorBitmap ENDP

DrawMouse PROC USES eax edx, hdc: HDC, x: LONG, y: LONG
    LOCAL hdcMem: HDC, hbmOld: HBITMAP
    
	INVOKE StretchBkgd, hdc, x, y
	
    INVOKE CreateCompatibleDC, hdc
    mov hdcMem, eax
    INVOKE SelectObject, hdcMem, hCursorBmp
    mov hbmOld, eax

	mov eax, x
	sub eax, CURSOR_WIDTH / 2
	mov edx, y
	sub edx, CURSOR_HEIGHT / 2
    INVOKE BitBlt, hdc, eax, edx, CURSOR_WIDTH, CURSOR_HEIGHT, hdcMem, 0, 0, SRCAND
	INVOKE SetCursorWinPos, x, y
	
    INVOKE SelectObject, hdcMem, hbmOld
    INVOKE DeleteDC, hdcMem

    ret
DrawMouse ENDP

GetMouseCursorWinPos PROC USES eax, hWnd: HWND, point: PTR POINT
    
    INVOKE GetCursorPos, point
	INVOKE ScreenToClient, hWnd, point

    ret
GetMouseCursorWinPos ENDP

SetCursorWinPos PROC USES eax, x: LONG, y: LONG
    mov eax, x
    mov cursorPos.x, eax
    mov eax, y
    mov cursorPos.y, eax

    ret
SetCursorWinPos ENDP

GetCursorWinPos PROC USES eax ebx, point: PTR POINT
    mov ebx, point
    mov eax, cursorPos.x
    mov [ebx].POINT.x, eax
    mov eax, cursorPos.y
    mov [ebx].POINT.y, eax

    ret
GetCursorWinPos ENDP

GetNewCursorPos PROC USES eax ebx ecx edx, hWnd: HWND, point: PTR POINT
	LOCAL hPoint: POINT, signedNum: SDWORD

	INVOKE GetMouseCursorWinPos, hWnd, ADDR hPoint
    ; Calculate new x-coordinate
    mov eax, hPoint.x
    sub eax, cursorPos.x
	
	.IF eax == 0
		mov ebx, point
		mov eax, hPoint.x
		mov [ebx].POINT.x, eax
	.ELSE
		mov signedNum, eax
		.IF (signedNum < -10) || (signedNum > 10)
			mov ebx, 10
			cdq
			idiv ebx
			mov ecx, cursorPos.x
			add ecx, eax
		.ELSEIF signedNum < 0
			mov ecx, cursorPos.x
			sub ecx, 1
		.ELSE
			mov ecx, cursorPos.x
			add ecx, 1
		.ENDIF
		mov ebx, point
		mov [ebx].POINT.x, ecx
	.ENDIF
    ; Calculate new y-coordinate
    mov eax, hPoint.y
    sub eax, cursorPos.y
	
    .IF eax == 0
		mov ebx, point
		mov eax, hPoint.y
		mov [ebx].POINT.y, eax
	.ELSE
		mov signedNum, eax
		.IF (signedNum < -10) || (signedNum > 10)
			mov ebx, 10
			cdq
			idiv ebx
			mov ecx, cursorPos.y
			add ecx, eax
		.ELSEIF signedNum < 0
			mov ecx, cursorPos.y
			sub ecx, 1
		.ELSE
			mov ecx, cursorPos.y
			add ecx, 1
		.ENDIF
		mov ebx, point
		mov [ebx].POINT.y, ecx
	.ENDIF

	ret
GetNewCursorPos ENDP

StretchBkgd PROC USES eax edx ecx ebx, hdc: HDC, x: LONG, y: LONG
	LOCAL hdcMem: HDC, hdcTarget: HDC, hbmMem: HBITMAP, hbmMemOld: HBITMAP, hbmTarget: HBITMAP, hbmTargetOld: HBITMAP, hdcMask: HDC, hbmMaskOld: HBITMAP
	
	INVOKE CreateCompatibleDC, hdc
	mov hdcMem, eax
	INVOKE CreateCompatibleBitmap, hdc, CURSOR_WIDTH, CURSOR_HEIGHT
	mov hbmMem, eax
	INVOKE SelectObject, hdcMem, hbmMem
	mov hbmMemOld, eax
	
	INVOKE CreateCompatibleDC, hdc
	mov hdcTarget, eax
	INVOKE CreateCompatibleBitmap, hdc, CURSOR_WIDTH, CURSOR_HEIGHT
	mov hbmTarget, eax
	INVOKE SelectObject, hdcTarget, hbmTarget
	mov hbmTargetOld, eax
	
	INVOKE CreateCompatibleDC, hdc
	mov hdcMask, eax
	INVOKE SelectObject, hdcMask, cursorMask2
	mov hbmMaskOld, eax

	mov eax, x
	mov edx, y
	sub eax, CURSOR_WIDTH / 2
	sub edx, CURSOR_HEIGHT / 2
	INVOKE BitBlt, hdcTarget, 0, 0, CURSOR_WIDTH, CURSOR_HEIGHT, hdc, eax, edx, SRCCOPY	; Copy target part
	INVOKE BitBlt, hdcTarget, 0, 0, CURSOR_WIDTH, CURSOR_HEIGHT, hdcMask, 0, 0, SRCAND	; Prune inner-circle part
	mov eax, x
	mov edx, y
	sub eax, CURSOR_WIDTH / 4
	sub edx, CURSOR_HEIGHT / 4
	mov ebx, CURSOR_WIDTH / 2
	mov ecx, CURSOR_HEIGHT / 2
	INVOKE StretchBlt, hdcMem, 0, 0, CURSOR_WIDTH, CURSOR_HEIGHT, hdc, eax, edx, ebx, ecx, SRCCOPY	; Copy the part need to zoom out
	INVOKE SelectObject, hdcMask, cursorMask1
	INVOKE BitBlt, hdcMem, 0, 0, CURSOR_WIDTH, CURSOR_HEIGHT, hdcMask, 0, 0, SRCAND	; Prune outer-circle part
	
	INVOKE BitBlt, hdcTarget, 0, 0, CURSOR_WIDTH, CURSOR_HEIGHT, hdcMem, 0, 0, SRCPAINT	; Combine two pictures

	mov eax, x
	mov edx, y
	sub eax, CURSOR_WIDTH / 2
	sub edx, CURSOR_HEIGHT / 2
	INVOKE BitBlt, hdc, eax, edx, CURSOR_WIDTH, CURSOR_HEIGHT, hdcTarget, 0, 0, SRCCOPY
	
	INVOKE SelectObject, hdcMem, hbmMemOld
	INVOKE DeleteDC, hdcMem
	INVOKE DeleteObject, hbmMem
	
	INVOKE SelectObject, hdcTarget, hbmTargetOld
	INVOKE DeleteDC, hdcTarget
	INVOKE DeleteObject, hbmTarget
	
	INVOKE SelectObject, hdcMask, hbmMaskOld
	INVOKE DeleteDC, hdcMask

	ret
StretchBkgd ENDP

END
