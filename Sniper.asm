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
     lpProc    DWORD NULL
Person ENDS

DrawStage PROTO
updateStage PROTO, hWnd:HWND, uMsg:DWORD, idEvent:DWORD, dwTime:DWORD

.data
     stage  DWORD  0
     person Person <ALIVE, <0, 0>, 0, DIRECTION_RIGHT, NULL>, <ALIVE, <0, 0>, 0, DIRECTION_LEFT, NULL>
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
     INVOKE LoadIcon, hInstance, 1
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

;Test Timer
     INVOKE SetTimer, hMainWnd, stage, 5000, updateStage

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
.data
     PopupTitle BYTE "Sniper", 0
     PopupText  BYTE "Fire!", 0
.code
     mov eax, localMsg
     .IF     eax == WM_LBUTTONDOWN
          GET_X_LPARAM lParam
          mov xPos, eax
          GET_Y_LPARAM lParam
          mov yPos, eax
          INVOKE ltoa, yPos, ADDR PopupText
          INVOKE MessageBox, hWnd, ADDR PopupText, ADDR MainWndTitle, MB_OK
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
     .ELSEIF eax == WM_TIMER
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

          INVOKE RedrawMouse, hdc, hCursorPoint.x, hCursorPoint.y

          INVOKE ReleaseDC, hWnd, hdc
     .ENDIF
     INVOKE DefWindowProc, hWnd, localMsg, wParam, lParam
     ret
WinProc ENDP

updateStage PROC, hWnd:HWND, uMsg:DWORD, idEvent:DWORD, dwTime:DWORD
.code
     
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

;?¨å??˜é?stageè¡¨ç¤º?³å¡?·ã€?è¡¨ç¤ºå¼€å§‹ç???
DrawStage PROC
     ret
DrawStage ENDP

END WinMain