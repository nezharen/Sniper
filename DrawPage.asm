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

INCLUDE Window.inc
INCLUDE DrawPage.inc

.data
PAGE_CODE 		DWORD 	0
statClass 		db 		"STATIC",0 ;bitmap
bmpBtnCl  		db 		"BUTTON", 0
hbtn_start		DWORD 	0
hBmp_start		HBITMAP	?
hbmp_start_btn	HBITMAP	?
hBmp			HBITMAP	?
hBtnStage1		HWND	?
hBtnStage2		HWND	?
hBtnStage3		HWND	?
hBmpBtnStage1	HBITMAP	?
hBmpBtnStage2	HBITMAP	?
hBmpBtnStage3	HBITMAP	?

.code

LoadAllPages PROC USES eax
	LOCAL hInstance: HINSTANCE
	
	INVOKE GetModuleHandle, NULL
	mov hInstance, eax
    
	INVOKE LoadBitmap, hInstance, PAGE_START_BACK
    mov hBmp_start, eax
	
	INVOKE LoadBitmap, hInstance, PAGE_START_BTN
    mov hbmp_start_btn, eax
	
	INVOKE LoadBitmap, hInstance, PAGE_CHOOSE_MODE_BACK
    mov hBmp, eax 
	
	INVOKE LoadBitmap, hInstance, STAGE_BTN_1
	mov hBmpBtnStage1, eax
	
	INVOKE LoadBitmap, hInstance, STAGE_BTN_2
	mov hBmpBtnStage2, eax
	
	INVOKE LoadBitmap, hInstance, STAGE_BTN_3
	mov hBmpBtnStage3, eax

	ret
LoadAllPages ENDP

DrawStartPage PROC USES eax edx, hdcBuffer: HDC
    LOCAL hdcBkGd: HDC, hbmpOldBkGd: HBITMAP
    
    INVOKE CreateCompatibleDC, hdcBuffer
	mov hdcBkGd, eax
	INVOKE SelectObject, hdcBkGd, hBmp_start
	mov hbmpOldBkGd, eax

	INVOKE BitBlt, hdcBuffer, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, hdcBkGd, 0, 0, SRCCOPY	; draw background to buffer
    
    INVOKE SelectObject, hdcBkGd, hbmpOldBkGd
    INVOKE DeleteDC, hdcBkGd
    ret
DrawStartPage ENDP
 
DrawStartBtn PROC USES eax, hWnd:HWND
    INVOKE CreateWindowEx,0,
        ADDR bmpBtnCl,NULL,
        WS_CHILD or WS_VISIBLE or BS_BITMAP or BS_FLAT,
        180,510,BUTTON_WIDTH,BUTTON_HEIGHT,hWnd,401,
        NULL,NULL
    mov hbtn_start, eax

    INVOKE SendMessage,hbtn_start,BM_SETIMAGE,0,hbmp_start_btn
	
    ret
DrawStartBtn ENDP

CreateStageSelectMenu PROC USES eax, hWnd: HWND
	INVOKE CreateWindowEx, 0, ADDR bmpBtnCl, NULL, WS_CHILD or WS_VISIBLE or BS_BITMAP or BS_FLAT, 550, 120, BUTTON_WIDTH, BUTTON_HEIGHT, hWnd, 501, NULL, NULL
	mov hBtnStage1, eax
	INVOKE SendMessage, hBtnStage1, BM_SETIMAGE, 0, hBmpBtnStage1
	
	INVOKE CreateWindowEx, 0, ADDR bmpBtnCl, NULL, WS_CHILD or WS_VISIBLE or BS_BITMAP or BS_FLAT, 550, 170, BUTTON_WIDTH, BUTTON_HEIGHT, hWnd, 502, NULL, NULL
	mov hBtnStage2, eax
	INVOKE SendMessage, hBtnStage2, BM_SETIMAGE, 0, hBmpBtnStage2
	
	INVOKE CreateWindowEx, 0, ADDR bmpBtnCl, NULL, WS_CHILD or WS_VISIBLE or BS_BITMAP or BS_FLAT, 550, 220, BUTTON_WIDTH, BUTTON_HEIGHT, hWnd, 503, NULL, NULL
	mov hBtnStage3, eax
	INVOKE SendMessage, hBtnStage3, BM_SETIMAGE, 0, hBmpBtnStage3
	
	ret
CreateStageSelectMenu ENDP

DestroyStartBtn PROC USES eax
	INVOKE DestroyWindow, hbtn_start

	ret
DestroyStartBtn ENDP

DrawModePage PROC USES eax edx, hdcBuffer: HDC
    LOCAL hdcBkGd: HDC, hbmpOldBkGd: HBITMAP

    INVOKE DestroyWindow,hbtn_start

    INVOKE CreateCompatibleDC, hdcBuffer
    mov hdcBkGd, eax
    INVOKE SelectObject, hdcBkGd, hBmp
    mov hbmpOldBkGd, eax

    INVOKE BitBlt, hdcBuffer, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, hdcBkGd, 0, 0, SRCCOPY  ; draw background to buffer
    
    INVOKE SelectObject, hdcBkGd, hbmpOldBkGd
    INVOKE DeleteDC, hdcBkGd
    ret
DrawModePage ENDP

DrawAllPage PROC USES eax edx, hdcBuffer: HDC
    .IF PAGE_CODE == 0
        INVOKE DrawStartPage, hdcBuffer
    .ELSEIF PAGE_CODE == 1
        INVOKE DrawModePage, hdcBuffer
    .ENDIF
    ret
DrawAllPage ENDP

ModifyPageCode PROC USES eax,newPageCode: DWORD
    mov eax,newPageCode
    mov PAGE_CODE,eax
    ret
ModifyPageCode ENDP

DeleteBackGround PROC

ret
DeleteBackGround ENDP


END