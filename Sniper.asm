.486
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

DIED            equ 0
DYING           equ 1
ALIVE           equ 2
DIRECTION_LEFT  equ 0
DIRECTION_RIGHT equ 1
CURSOR_HEIGHT   equ 256
CURSOR_WIDTH    equ 256

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
DrawMouse PROTO, hdc: HDC, hWnd: HWND
RestoreBackground PROTO, hdc: HDC
updateStage PROTO, hWnd:HWND, uMsg:DWORD, idEvent:DWORD, dwTime:DWORD

.data
     stage  DWORD  0
     person Person <ALIVE, <0, 0>, 0, DIRECTION_RIGHT, NULL>, <ALIVE, <0, 0>, 0, DIRECTION_LEFT, NULL>
     personStageSize equ ($ - person)
            Person <>, <>
            Person <>, <>

     hCursorBmp   HBITMAP  ?
     hdcBuffer     HDC  ?
     oPoint   POINT <>
     hbmBuffer    HBITMAP 0

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
     LOCAL xPos:DWORD, yPos:DWORD, hdc: HDC, ps: PAINTSTRUCT
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
          
          INVOKE DrawStage
          INVOKE DrawMouse, hdc, hWnd

          INVOKE EndPaint, hWnd, ADDR ps
     .ELSEIF eax == WM_CLOSE
          INVOKE DestroyWindow, hWnd
     .ELSEIF eax == WM_DESTROY
          INVOKE PostQuitMessage, 0
     .ELSEIF eax == WM_CREATE
          INVOKE LoadBitmap, hInstance, 2
          mov hCursorBmp, eax
     .ELSEIF eax == WM_MOUSEMOVE
          INVOKE GetDC, hWnd
          mov hdc, eax
          INVOKE RestoreBackground, hdc
          INVOKE DrawMouse, hdc, hWnd
          INVOKE DeleteDC, hdc
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

;?®Â??òÈ?stageË°®Á§∫?≥Âç°?∑„Ä?Ë°®Á§∫ÂºÄÂßãÁ???
DrawStage PROC
     ret
DrawStage ENDP

DrawMouse PROC, hdc: HDC, hWnd: HWND
     LOCAL hdcMem: HDC,
     hbmOld: HBITMAP,
     hPoint: POINT,
     rc: RECT 
     
     INVOKE CreateCompatibleDC, hdc
     mov hdcMem, eax
     INVOKE SelectObject, hdcMem, hCursorBmp
     mov hbmOld, eax
     INVOKE GetCursorPos, ADDR hPoint
     INVOKE GetWindowRect, hWnd, ADDR rc
     
     push edx
     mov eax, hPoint.x
     mov edx, hPoint.y
     sub eax, rc.left
     sub edx, rc.top
     sub edx, 25 + 128
     sub eax, 128
     mov oPoint.x, eax
     mov oPoint.y, edx

     .IF hbmBuffer != 0
          INVOKE DeleteDC, hdcBuffer
          INVOKE DeleteObject, hbmBuffer
     .ENDIF
     INVOKE CreateCompatibleDC, hdc
     mov hdcBuffer, eax
     INVOKE CreateCompatibleBitmap, hdc, CURSOR_WIDTH, CURSOR_HEIGHT
     mov hbmBuffer, eax
     INVOKE SelectObject, hdcBuffer, hbmBuffer

     INVOKE BitBlt, hdcBuffer, 0, 0, CURSOR_WIDTH, CURSOR_HEIGHT, hdc, oPoint.x, oPoint.y, SRCCOPY
     INVOKE BitBlt, hdc, oPoint.x, oPoint.y, CURSOR_WIDTH, CURSOR_HEIGHT, hdcMem, 0, 0, SRCAND
     pop edx
     INVOKE SelectObject, hdcMem, hbmOld
     INVOKE DeleteDC, hdcMem

     ret
DrawMouse ENDP

RestoreBackground PROC, hdc: HDC

     INVOKE BitBlt, hdc, oPoint.x, oPoint.y, CURSOR_WIDTH, CURSOR_HEIGHT, hdcBuffer, 0, 0, SRCCOPY
     ret
RestoreBackground ENDP
END WinMain