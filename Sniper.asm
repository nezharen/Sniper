.486
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\macros\macros.asm
include \masm32\include\masm32.inc
include \masm32\include\gdi32.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\comctl32.inc
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\comctl32.lib

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
     himl         HIMAGELIST  ?
     hCursorIndex DWORD    ?

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
     LOCAL xPos:DWORD, yPos:DWORD, hCursorPos: POINT, hWndRect: RECT
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
          INVOKE DrawStage
     .ELSEIF eax == WM_CLOSE
          INVOKE DestroyWindow, hWnd
     .ELSEIF eax == WM_DESTROY
          INVOKE PostQuitMessage, 0
     .ELSEIF eax == WM_CREATE
          INVOKE LoadBitmap, hInstance, 2
          mov hCursorBmp, eax
          INVOKE InitCommonControls
          INVOKE ImageList_Create, CURSOR_WIDTH, CURSOR_HEIGHT, ILC_COLOR32, 1, 0
          mov himl, eax
          INVOKE ImageList_Add, himl, hCursorBmp, NULL
          mov hCursorIndex, eax

          INVOKE ImageList_BeginDrag, himl, hCursorIndex, 0, 0
          INVOKE GetCursorPos, ADDR hCursorPos
          INVOKE GetWindowRect, hWnd, ADDR hWndRect
     
          push edx
          mov eax, hCursorPos.x
          mov edx, hCursorPos.y
          sub eax, hWndRect.left
          sub edx, hWndRect.top
          sub edx, 128
          sub eax, 128
          
          INVOKE ImageList_DragEnter, hWnd, eax, edx
          pop edx
     .ELSEIF eax == WM_MOUSEMOVE
          INVOKE GetCursorPos, ADDR hCursorPos
          INVOKE GetWindowRect, hWnd, ADDR hWndRect
     
          push edx
          mov eax, hCursorPos.x
          mov edx, hCursorPos.y
          sub eax, hWndRect.left
          sub edx, hWndRect.top
          sub edx, 128
          sub eax, 128

          INVOKE ImageList_DragMove, eax, edx
          pop edx
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

;?��??��?stage表示?�卡?��?表示开始�???
DrawStage PROC
     ret
DrawStage ENDP

END WinMain