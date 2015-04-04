.386
.model flat, stdcall
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

DIED            equ 0
DYING           equ 1
ALIVE           equ 2
DIRECTION_LEFT  equ 0
DIRECTION_RIGHT equ 1
WINDOW_WIDTH    equ 800
WINDOW_HEIGHT   equ 600
ID_TIMER        equ 1
ID_ICON_MAIN    equ 1
ID_BMP_CURSOR   equ 2
ID_BMP_START    equ 3
ID_BMP_SNIPER   equ 4

GET_X_LPARAM MACRO lParam
     mov eax, lParam
     and eax, 0FFFFh
ENDM

GET_Y_LPARAM MACRO lParam
     mov eax, lParam
     shr eax, 16
     and eax, 0FFFFh
ENDM

Person STRUCT
     alive     BYTE  1
     position  POINT <>
     speed     DWORD 0
     direction BYTE  0
     hasGun    BYTE  0
     lpProc    DWORD NULL
Person ENDS

DrawStage PROTO
updateStage PROTO

.data
     stage  DWORD  0
     person Person <ALIVE, <0, 0>, 0, DIRECTION_RIGHT, 0, stage_0_0>, <ALIVE, <0, 0>, 0, DIRECTION_LEFT, 0, stage_0_1>
     personStageSize equ ($ - person)
            Person <>, <>
            Person <>, <>
.code

WinMain PROC
.data
     className    BYTE     "MainWin", 0
     MainWndTitle BYTE     "Sniper", 0
     MainWin      WNDCLASS <NULL, WinProc, NULL, NULL, NULL, NULL, NULL, \
                            COLOR_WINDOW, NULL, className>
     msg          MSG      <>
     hIcon        HICON    ?
     hMainWnd     HWND    ?
     hInstance    HINSTANCE    ?
.code
     INVOKE GetModuleHandle, NULL
     mov hInstance, eax
     mov MainWin.hInstance, eax
     INVOKE LoadIcon, hInstance, ID_ICON_MAIN
     mov MainWin.hIcon, eax
     INVOKE LoadCursor, NULL, IDC_ARROW
     mov MainWin.hCursor, eax

     INVOKE RegisterClass, ADDR MainWin
     .IF eax == 0
          call ErrorHandler
          jmp ExitProgram
     .ENDIF

     INVOKE CreateWindowEx, 0, ADDR className, ADDR MainWndTitle, 
                            WS_OVERLAPPED + WS_CAPTION + WS_SYSMENU + WS_MINIMIZEBOX,
                            CW_USEDEFAULT, CW_USEDEFAULT, 800, 600, 
                            NULL, NULL, hInstance, NULL
     .IF eax == 0
          call ErrorHandler
          jmp ExitProgram
     .ENDIF

     mov hMainWnd, eax
     INVOKE ShowWindow, hMainWnd, SW_SHOWNORMAL
     INVOKE UpdateWindow, hMainWnd

MessageLoop:
     INVOKE GetMessage, ADDR msg, NULL, NULL, NULL
     .IF eax == 0
          jmp ExitProgram
     .ENDIF
     INVOKE DispatchMessage, ADDR msg
     jmp MessageLoop

ExitProgram:
     INVOKE ExitProcess, 0

WinMain ENDP

WinProc PROC, hWnd:HWND, localMsg:DWORD, wParam:WPARAM, lParam:LPARAM
     LOCAL xPos:DWORD, yPos:DWORD, hdc: HDC, ps: PAINTSTRUCT, hPoint: POINT,
           hCursorPoint: POINT
     LOCAL hStatImage :DWORD  ;start define bitmap handle
     LOCAL hStatIcon  :DWORD
     LOCAL hBmp   :DWORD
     LOCAL hBmp1  :DWORD      ;end define bitmap handle
.data
     PopupTitle BYTE "Sniper", 0
     PopupText  BYTE "Fire!", 0
     statClass db "STATIC",0 ;bitmap
     bmpBtnCl  db "BUTTON", 0
     blnk      BYTE 0
     hBtn1         dd 0
     StartText BYTE "Game Start", 0
.code
     mov eax, localMsg
     .IF     eax == WM_LBUTTONDOWN
          .IF stage > 0
               GET_X_LPARAM lParam
               mov xPos, eax
               GET_Y_LPARAM lParam
               mov yPos, eax
               INVOKE ltoa, yPos, ADDR PopupText
               INVOKE MessageBox, hWnd, ADDR PopupText, ADDR MainWndTitle, MB_OK
          .ENDIF
     .ELSEIF eax == WM_PAINT
          INVOKE BeginPaint, hWnd, ADDR ps
          mov hdc, eax

          INVOKE CreateOldBkgd, hdc
          INVOKE DrawStage
          INVOKE GetMouseCursorWinPos, hWnd, ADDR hPoint
          INVOKE DrawMouse, hdc, hPoint.x, hPoint.y

          INVOKE EndPaint, hWnd, ADDR ps
     .ELSEIF eax == WM_CLOSE
          INVOKE DestroyWindow, hWnd
     .ELSEIF eax == WM_DESTROY
          INVOKE DeleteOldBkgd
          INVOKE KillTimer, hWnd, ID_TIMER
          INVOKE PostQuitMessage, 0
     .ELSEIF eax == WM_CREATE
          INVOKE LoadCursorBitmap
          INVOKE SetTimer, hWnd, ID_TIMER, 20, NULL
          ;start paint bitmap
          INVOKE CreateWindowEx,WS_EX_STATICEDGE,
            ADDR statClass,NULL,
            WS_CHILD or WS_VISIBLE or SS_BITMAP,
            0,0,800,600,hWnd,65535,
            hInstance,NULL
          mov hStatImage, eax
          INVOKE LoadBitmap,hInstance,4
          mov hBmp, eax 
          INVOKE SendMessage,hStatImage,STM_SETIMAGE,IMAGE_BITMAP,hBmp
          ;end paint bitmap
          ;start paint start button
          invoke CreateWindowEx,0,
            ADDR bmpBtnCl,NULL,
            WS_CHILD or WS_VISIBLE or BS_BITMAP or BS_FLAT,
            180,510,100,36,hWnd,401,
            hInstance,NULL
          mov hBtn1, eax
          invoke LoadBitmap,hInstance,3
          mov hBmp1, eax
          invoke SetWindowText,hBtn1,ADDR StartText
          invoke SendMessage,hBtn1,BM_SETIMAGE,0,hBmp1
          ;end paint start button
     .ELSEIF eax == WM_COMMAND
          .IF wParam == 401
          szText btnMsg1,"Game Start!"
            invoke MessageBox,hWnd,ADDR btnMsg1,
                              ADDR StartText,MB_OK
          .ENDIF
     .ELSEIF eax == WM_TIMER
          INVOKE updateStage
          INVOKE GetDC, hWnd
          mov hdc, eax

          INVOKE GetMouseCursorWinPos, hWnd, ADDR hPoint
          INVOKE GetCursorWinPos, ADDR hCursorPoint
          ; Calculate new x-coordinate
          mov eax, hPoint.x
          sub eax, hCursorPoint.x
          cdq
          mov ebx, 10
          idiv ebx
          mov ecx, eax
          cdq
          xor eax, edx
          sub eax, edx
          .IF eax < 1
                mov eax, hPoint.x
                mov hCursorPoint.x, eax
          .ELSE
                add hCursorPoint.x, ecx
          .ENDIF
          ; Calculate new y-coordinate
          mov eax, hPoint.y
          sub eax, hCursorPoint.y
          cdq
          mov ebx, 10
          idiv ebx
          mov ecx, eax
          cdq
          xor eax, edx
          sub eax, edx
          .IF eax < 1
                mov eax, hPoint.y
                mov hCursorPoint.y, eax
          .ELSE
                add hCursorPoint.y, ecx
          .ENDIF
          ;commenting the next line will see the start page
          INVOKE RedrawMouse, hdc, hCursorPoint.x, hCursorPoint.y

          INVOKE ReleaseDC, hWnd, hdc
     .ENDIF
     INVOKE DefWindowProc, hWnd, localMsg, wParam, lParam
     ret
WinProc ENDP

updateStage PROC
     .IF stage == 1
          call person.lpProc
          call person[SIZEOF Person].lpProc
     .ENDIF
     ret
updateStage ENDP

ErrorHandler PROC
.data
     ErrorTitle BYTE  "Sniper"
     pErrorMsg  DWORD ?
     messageID  DWORD ?
.code
     INVOKE GetLastError
     mov messageID, eax
     INVOKE FormatMessage, FORMAT_MESSAGE_ALLOCATE_BUFFER + FORMAT_MESSAGE_FROM_SYSTEM, 
                           NULL, messageID, NULL, ADDR pErrorMsg, NULL, NULL
     INVOKE MessageBox, NULL, pErrorMsg, ADDR ErrorTitle, MB_ICONERROR + MB_OK
     INVOKE LocalFree, pErrorMsg
     ret
ErrorHandler ENDP

DrawStage PROC
     ret
DrawStage ENDP

stage_0_0 PROC
     ret
stage_0_0 ENDP

stage_0_1 PROC
     ret
stage_0_1 ENDP

END WinMain