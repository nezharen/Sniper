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

CURSOR_HEIGHT   equ 256
CURSOR_WIDTH    equ 256
WINDOW_WIDTH    equ 800
WINDOW_HEIGHT   equ 600
CURSOR_RES_ID   equ 2

.data
hCursorBmp  HBITMAP ?
cursorPos   POINT   <>       

.code

LoadCursorBitmap PROC USES eax
    INVOKE GetModuleHandle, NULL
    INVOKE LoadBitmap, eax, CURSOR_RES_ID
    mov hCursorBmp, eax
    
    ret
LoadCursorBitmap ENDP

DrawMouse PROC USES eax, hdc: HDC, x: LONG, y: LONG
    LOCAL hdcMem: HDC, hbmOld: HBITMAP
    
    INVOKE CreateCompatibleDC, hdc
    mov hdcMem, eax
    INVOKE SelectObject, hdcMem, hCursorBmp
    mov hbmOld, eax

    INVOKE BitBlt, hdc, x, y, CURSOR_WIDTH, CURSOR_HEIGHT, hdcMem, 0, 0, SRCAND
	INVOKE SetCursorWinPos, x, y
	
    INVOKE SelectObject, hdcMem, hbmOld
    INVOKE DeleteDC, hdcMem

    ret
DrawMouse ENDP

GetMouseCursorWinPos PROC USES eax ebx edx, hWnd: HWND, point: PTR POINT
    LOCAL rc: RECT
    
    INVOKE GetCursorPos, point
    INVOKE GetWindowRect, hWnd, ADDR rc

    mov ebx, point
    mov eax, [ebx].POINT.x
    mov edx, [ebx].POINT.y
    sub eax, rc.left
    sub edx, rc.top
    sub eax, CURSOR_HEIGHT / 2
    sub edx, 25 + CURSOR_WIDTH / 2

    mov [ebx].POINT.x, eax
    mov [ebx].POINT.y, edx

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
			add ecx, -1
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
		.IF (signedNum < -10) || (eax > 10)
			mov ebx, 10
			cdq
			idiv ebx
			mov ecx, cursorPos.y
			add ecx, eax
		.ELSEIF signedNum < 0
			mov ecx, cursorPos.y
			add ecx, -1
		.ELSE
			mov ecx, cursorPos.y
			add ecx, 1
		.ENDIF
		mov ebx, point
		mov [ebx].POINT.y, ecx
	.ENDIF

	ret
GetNewCursorPos ENDP

END
