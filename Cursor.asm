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

CURSOR_HEIGHT   equ 256
CURSOR_WIDTH    equ 256
WINDOW_WIDTH    equ 800
WINDOW_HEIGHT   equ 600
CURSOR_RES_ID   equ 2

.data
hCursorBmp  HBITMAP ?
hdcOldBkGd  HDC     ?
hbmpOldBkGd HBITMAP ?
CursorPos   POINT   <>       

.code

LoadCursorBitmap PROC USES eax
    INVOKE GetModuleHandle, NULL
    INVOKE LoadBitmap, eax, CURSOR_RES_ID
    mov hCursorBmp, eax
    
    ret
LoadCursorBitmap ENDP

CreateOldBkgd PROC USES eax, hdc: HDC
    INVOKE CreateCompatibleDC, hdc
    mov hdcOldBkGd, eax
    INVOKE CreateCompatibleBitmap, hdc, WINDOW_WIDTH, WINDOW_HEIGHT
    mov hbmpOldBkGd, eax
    INVOKE SelectObject, hdcOldBkGd, hbmpOldBkGd
    INVOKE BitBlt, hdcOldBkGd, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, hdc, 0, 0, SRCCOPY  
      
    ret
CreateOldBkgd ENDP

DrawMouse PROC USES eax edx, hdc: HDC, x: LONG, y: LONG
     LOCAL hdcMem: HDC, hbmOld: HBITMAP
     
     INVOKE CreateCompatibleDC, hdc
     mov hdcMem, eax
     INVOKE SelectObject, hdcMem, hCursorBmp
     mov hbmOld, eax

     INVOKE BitBlt, hdc, x, y, CURSOR_WIDTH, CURSOR_HEIGHT, hdcMem, 0, 0, SRCAND
     INVOKE SelectObject, hdcMem, hbmOld
     INVOKE DeleteDC, hdcMem

     ret
DrawMouse ENDP

RedrawMouse PROC USES eax, hdc: HDC, x: LONG, y: LONG
    LOCAL hdcBuffer: HDC, hbmpBuffer: HBITMAP, hbmpOldBuffer: HBITMAP
    
    INVOKE CreateCompatibleDC, hdc
    mov hdcBuffer, eax
    INVOKE CreateCompatibleBitmap, hdc, WINDOW_WIDTH, WINDOW_HEIGHT
    mov hbmpBuffer, eax
    INVOKE SelectObject, hdcBuffer, hbmpBuffer
    mov hbmpOldBuffer, eax
          
    INVOKE BitBlt, hdcBuffer, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, hdcOldBkGd, 0, 0, SRCCOPY
    INVOKE DrawMouse, hdcBuffer, x, y
    INVOKE BitBlt, hdc, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, hdcBuffer, 0, 0, SRCCOPY

    INVOKE SelectObject, hdcBuffer, hbmpOldBuffer
    INVOKE DeleteDC, hdcBuffer
    
    ret
RedrawMouse ENDP

DeleteOldBkgd PROC
    INVOKE DeleteDC, hdcOldBkGd

    ret
DeleteOldBkgd ENDP

GetCursorWinPos PROC USES eax ebx edx, hWnd: HWND, point: PTR POINT
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
GetCursorWinPos ENDP

SetCursorWinPos PROC USES eax, x: LONG, y: LONG
    mov eax, x
    mov CursorPos.x, eax
    mov eax, y
    mov CursorPos.y, eax

    ret
SetCursorWinPos ENDP

END
