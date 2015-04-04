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

DEAD            equ 0
DYING           equ 1
ALIVE           equ 2
DIRECTION_LEFT  equ 0
DIRECTION_RIGHT equ 1
HEAD_SIZE       equ 5
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
UpdateStage PROTO
Fire PROTO

.data
     stage  DWORD  0
     person Person <>, <>
     personStageSize equ ($ - person)
            Person <ALIVE, <30, 30>, 0, DIRECTION_RIGHT, 0, stage_1_0>, <ALIVE, <40, 30>, 0, DIRECTION_LEFT, 0, stage_1_1>
            Person <>, <>
            Person <>, <>
     personStageSum DWORD 0, 2, 2, 2
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
     statClass db "STATIC",0 ;bitmap
     bmpBtnCl  db "BUTTON", 0
     blnk      BYTE 0
     hBtn1     DWORD 0
     StartText BYTE "Game Start", 0
.code
     mov eax, localMsg
     .IF     eax == WM_LBUTTONDOWN
          .IF stage > 0
               INVOKE Fire
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
          .IF stage > 0
               INVOKE UpdateStage
          .ENDIF
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

ErrorHandler PROC
.data
     ErrorTitle BYTE  "Sniper", 0
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

UpdateStage PROC USES ebx ecx esi edi
     call GetStagePerson
     call GetStagePersonSum
callAllPersonProc:
     .IF person[ebx + esi].alive == ALIVE
          call person[ebx + esi].lpProc
     .ENDIF
     add esi, TYPE person
     loop callAllPersonProc
     ret
UpdateStage ENDP

juagePerson PROC USES eax edx ecx edx, x:PTR Person
     LOCAL hCursorPoint:POINT
.data
     killed BYTE "KILLED", 0
     miss BYTE "Miss", 0
.code
     INVOKE GetCursorWinPos, ADDR hCursorPoint
     mov ebx, x
     mov eax, [ebx].Person.position.x
     sub eax, hCursorPoint.x
     imul eax
     mov ecx, eax
     mov eax, [ebx].Person.position.y
     sub eax, hCursorPoint.y
     imul eax
     add ecx, eax
     .IF ecx <= HEAD_SIZE * HEAD_SIZE
          mov [ebx].Person.alive, DEAD
          INVOKE MessageBox, NULL, ADDR killed, ADDR MainWndTitle, MB_OK
     .ELSE
          INVOKE MessageBox, NULL, ADDR miss, ADDR MainWndTitle, MB_OK
     .ENDIF
     ret
juagePerson ENDP

Fire PROC USES ebx ecx esi
     call GetStagePerson
     call GetStagePersonSum
juageAllPerson:
     .IF person[ebx + esi].alive == ALIVE
          INVOKE juagePerson, ADDR person[ebx + esi]
     .ENDIF
     add esi, TYPE person
     loop juageAllPerson
     ret
Fire ENDP

;Uses ebx, esi to return value
GetStagePerson PROC USES ecx
     mov ebx, 0
     mov ecx, stage
setBase:
     add ebx, personStageSize
     loop setBase
     mov esi, 0
     ret
GetStagePerson ENDP

;Uses ecx to return value
GetStagePersonSum PROC
     mov ecx, stage
     mov ecx, personStageSum[ecx * TYPE personStageSum]
     ret
GetStagePersonSum ENDP

stage_1_0 PROC
     ret
stage_1_0 ENDP

stage_1_1 PROC
     ret
stage_1_1 ENDP

END WinMain