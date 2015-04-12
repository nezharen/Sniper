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
PAGE_CODE 			DWORD 	0
previousPageCode	DWORD	?
statClass 			db 		"STATIC",0 ;bitmap
bmpBtnCl  			db 		"BUTTON", 0
hbtn_start			DWORD 	0
hBmp_start			HBITMAP	?
hbmp_start_btn		HBITMAP	?
hBmp				HBITMAP	?
hBtnStage1			HWND	?
hBtnStage2			HWND	?
hBtnStage3			HWND	?
hBmpBtnStage1		HBITMAP	?
hBmpBtnStage2		HBITMAP	?
hBmpBtnStage3		HBITMAP	?
hBmpStage1			HBITMAP ?
hBmpStage2			HBITMAP ?
hBmpStage3			HBITMAP ?
hBmpIntro1			HBITMAP ?
hBmpIntro2			HBITMAP ?
hBmpIntro3			HBITMAP ?
hBtnContinue		HWND	?
hBmpContinue		HBITMAP	?
hBmpFailed			HBITMAP	?
hBmpComplete		HBITMAP	?

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
	
	INVOKE LoadBitmap, hInstance, STAGE_BACKGROUND_1
	mov hBmpStage1, eax
	INVOKE LoadBitmap, hInstance, STAGE_BACKGROUND_2
	mov hBmpStage2, eax
	INVOKE LoadBitmap, hInstance, STAGE_BACKGROUND_3
	mov hBmpStage3, eax

	INVOKE LoadBitmap, hInstance, STAGE_INTRODUCTION_1
	mov hBmpIntro1, eax
	INVOKE LoadBitmap, hInstance, STAGE_INTRODUCTION_2
	mov hBmpIntro2, eax
	INVOKE LoadBitmap, hInstance, STAGE_INTRODUCTION_3
	mov hBmpIntro3, eax
	
	INVOKE LoadBitmap, hInstance, CONTINUE_BTN
	mov hBmpContinue, eax

	INVOKE LoadBitmap, hInstance, FAILED_BACKGROUND
	mov hBmpFailed, eax
	
	INVOKE LoadBitmap, hInstance, COMPLETE_BACKGROUND
	mov hBmpComplete, eax
	
	ret
LoadAllPages ENDP
 
DrawStartBtn PROC USES eax, x: LONG, y: LONG, hWnd: HWND, wParam: DWORD
    INVOKE CreateWindowEx,0,
        ADDR bmpBtnCl,NULL,
        WS_CHILD or WS_VISIBLE or BS_BITMAP or BS_FLAT,
        x,y,BUTTON_WIDTH,BUTTON_HEIGHT,hWnd,wParam,
        NULL,NULL
    mov hbtn_start, eax

    INVOKE SendMessage,hbtn_start,BM_SETIMAGE,0,hbmp_start_btn
	
    ret
DrawStartBtn ENDP

CreateStageSelectMenu PROC USES eax, hWnd: HWND
	INVOKE CreateWindowEx, 0, ADDR bmpBtnCl, NULL, WS_CHILD or WS_VISIBLE or BS_BITMAP or BS_FLAT, 550, 160, BUTTON_WIDTH, BUTTON_HEIGHT, hWnd, 501, NULL, NULL
	mov hBtnStage1, eax
	INVOKE SendMessage, hBtnStage1, BM_SETIMAGE, 0, hBmpBtnStage1
	
	INVOKE CreateWindowEx, 0, ADDR bmpBtnCl, NULL, WS_CHILD or WS_VISIBLE or BS_BITMAP or BS_FLAT, 530, 210, BUTTON_WIDTH, BUTTON_HEIGHT, hWnd, 502, NULL, NULL
	mov hBtnStage2, eax
	INVOKE SendMessage, hBtnStage2, BM_SETIMAGE, 0, hBmpBtnStage2
	
	INVOKE CreateWindowEx, 0, ADDR bmpBtnCl, NULL, WS_CHILD or WS_VISIBLE or BS_BITMAP or BS_FLAT, 510, 260, BUTTON_WIDTH, BUTTON_HEIGHT, hWnd, 503, NULL, NULL
	mov hBtnStage3, eax
	INVOKE SendMessage, hBtnStage3, BM_SETIMAGE, 0, hBmpBtnStage3
	
	ret
CreateStageSelectMenu ENDP

CreateContinueButton PROC USES eax, hWnd: HWND, wParam: DWORD
	INVOKE CreateWindowEx, 0, ADDR bmpBtnCl, NULL, WS_CHILD or WS_VISIBLE or BS_BITMAP or BS_FLAT, 350, 350, BUTTON_WIDTH, BUTTON_HEIGHT, hWnd, wParam, NULL, NULL
	mov hBtnContinue, eax
	INVOKE SendMessage, hBtnContinue, BM_SETIMAGE, 0, hBmpContinue

	ret
CreateContinueButton ENDP

DestroyStartBtn PROC USES eax
	INVOKE DestroyWindow, hbtn_start
	
	ret
DestroyStartBtn ENDP

DestroyStageSelectMenu PROC USES eax
	INVOKE DestroyWindow, hBtnStage1
	INVOKE DestroyWindow, hBtnStage2
	INVOKE DestroyWindow, hBtnStage3

	ret
DestroyStageSelectMenu ENDP

DestroyContinueButton PROC USES eax
	INVOKE DestroyWindow, hBtnContinue

	ret
DestroyContinueButton ENDP

DrawAllPage PROC USES eax edx, hdcBuffer: HDC
	LOCAL hdcBkGd: HDC, hbmpOldBkGd: HBITMAP
    
    INVOKE CreateCompatibleDC, hdcBuffer
	mov hdcBkGd, eax
	
    .IF PAGE_CODE == 0
        mov eax, hBmp_start
    .ELSEIF PAGE_CODE == 1
        mov eax, hBmp
	.ELSEIF PAGE_CODE == 11
		mov eax, hBmpIntro1
	.ELSEIF PAGE_CODE == 21
		mov eax, hBmpStage1
	.ELSEIF PAGE_CODE == 12
		mov eax, hBmpIntro2
	.ELSEIF PAGE_CODE == 22
		mov eax, hBmpStage2
	.ELSEIF PAGE_CODE == 13
		mov eax, hBmpIntro3
	.ELSEIF PAGE_CODE == 23
		mov eax, hBmpStage3
	.ELSEIF PAGE_CODE == 40
		mov eax, hBmpFailed
	.ELSEIF PAGE_CODE == 41
		mov eax, hBmpComplete
    .ENDIF
	INVOKE SelectObject, hdcBkGd, eax
	mov hbmpOldBkGd, eax

	INVOKE BitBlt, hdcBuffer, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, hdcBkGd, 0, 0, SRCCOPY	; draw background to buffer
    
    INVOKE SelectObject, hdcBkGd, hbmpOldBkGd
    INVOKE DeleteDC, hdcBkGd
	
    ret
DrawAllPage ENDP

ModifyPageCode PROC USES eax,newPageCode: DWORD
    mov eax,newPageCode
    mov PAGE_CODE,eax
    ret
ModifyPageCode ENDP

SavePreviousPageCode PROC USES eax
	mov eax, PAGE_CODE
	mov previousPageCode, eax

	ret
SavePreviousPageCode ENDP

GetPreviousPageCode	PROC
	mov eax, previousPageCode
	
	ret
GetPreviousPageCode ENDP

GetPageCode PROC
	mov eax, PAGE_CODE

	ret
GetPageCode ENDP

DeleteBackGround PROC

ret
DeleteBackGround ENDP


END