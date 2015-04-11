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
INCLUDE DrawPage.inc
INCLUDE DrawPerson.inc
DEAD            equ 0
DYING           equ 1
ALIVE           equ 2
STATE_RUNNING   equ 0
STATE_FAILED    equ 1
STATE_SUCCESS   equ 2
SPEED_NULL      equ 0
SPEED_WALK      equ 1
SPEED_RUN       equ 2
DIRECTION_LEFT  equ -1
DIRECTION_RIGHT equ 1
NO_GUN          equ 0
HAS_GUN         equ 1
HEAD_SIZE       equ 5
WINDOW_WIDTH    equ 800
WINDOW_HEIGHT   equ 600
ID_TIMER        equ 1
ID_ICON_MAIN    equ 1
ID_BMP_CURSOR   equ 2
ID_BMP_START    equ 3
ID_BMP_SNIPER   equ 4

Person STRUCT
     alive     BYTE   1
     position  POINT  <>
     speed     DWORD  0
     direction SDWORD 0
     hasGun    BYTE   0
     lpProc    DWORD  NULL
Person ENDS

DrawStage PROTO
UpdateStage PROTO
Fire PROTO

.data
	hBmp_start	HBITMAP	?
     stage  DWORD  0
     state  DWORD  STATE_RUNNING
     person Person <>, <>, <>
     personStageSize equ ($ - person)
            Person <ALIVE, <30, 30>, SPEED_NULL, DIRECTION_RIGHT, NO_GUN, stage_1_0>, <ALIVE, <40, 30>, SPEED_NULL, DIRECTION_LEFT, NO_GUN, stage_1_1>, <>
            Person <ALIVE, <100, 300>, SPEED_NULL, DIRECTION_RIGHT, HAS_GUN, stage_2_0>, <ALIVE, <300, 300>, SPEED_NULL, DIRECTION_RIGHT, HAS_GUN, stage_2_1>,
                   <ALIVE, <500, 300>, SPEED_WALK, DIRECTION_LEFT, HAS_GUN, stage_2_2>
            Person <>, <>, <>
     personStageSum DWORD 0, 2, 3, 3
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
           hCursorPoint: POINT, hdcBkGd: HDC, hdcBuffer: HDC, hbmpBuffer: HBITMAP,
		   hbmpOldBuffer: HBITMAP, hbmpOldBkGd: HDC
.data
     hBtn_start     DWORD 0
.code
     mov eax, localMsg
     .IF     eax == WM_LBUTTONDOWN
          .IF stage > 0
               INVOKE Fire
          .ENDIF
     .ELSEIF eax == WM_PAINT
          INVOKE BeginPaint, hWnd, ADDR ps
          mov hdc, eax

		  INVOKE CreateCompatibleDC, hdc
		  mov hdcBuffer, eax
		  INVOKE CreateCompatibleBitmap, hdc, WINDOW_WIDTH, WINDOW_HEIGHT
		  mov hbmpBuffer, eax
		  INVOKE SelectObject, hdcBuffer, hbmpBuffer
		  mov hbmpOldBuffer, eax
		  
          INVOKE DrawAllPage, hdcBuffer
		  INVOKE DrawStandPerson, hdcBuffer, 400,300
          

		  
		  INVOKE GetNewCursorPos, hWnd, ADDR hCursorPoint
		  INVOKE StretchBkgd, hdcBuffer, hCursorPoint.x, hCursorPoint.y
		  INVOKE DrawMouse, hdcBuffer, hCursorPoint.x, hCursorPoint.y
		  INVOKE BitBlt, hdc, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, hdcBuffer, 0, 0, SRCCOPY	; draw buffer to screen
		  
		  INVOKE SelectObject, hdcBuffer, hbmpOldBuffer
		  INVOKE DeleteDC, hdcBuffer
		  INVOKE DeleteObject, hbmpBuffer

          INVOKE EndPaint, hWnd, ADDR ps
     .ELSEIF eax == WM_CLOSE
          INVOKE DestroyWindow, hWnd
     .ELSEIF eax == WM_DESTROY
          INVOKE KillTimer, hWnd, ID_TIMER
          INVOKE PostQuitMessage, 0
     .ELSEIF eax == WM_CREATE
          INVOKE LoadCursorBitmap
		  INVOKE LoadAllPages
          INVOKE SetTimer, hWnd, ID_TIMER, 20, NULL
          
          INVOKE DrawStartBtn, hWnd
          
     .ELSEIF eax == WM_COMMAND
          .IF wParam == 401
              INVOKE ModifyPageCode,1
          .ENDIF
     .ELSEIF eax == WM_TIMER
          .IF stage > 0
               INVOKE UpdateStage
          .ENDIF
          INVOKE InvalidateRect, hWnd, NULL, FALSE
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

UpdateStage PROC USES eax ebx ecx esi edi
     call GetStagePerson
     call GetStagePersonSum
callAllPersonProc:
     .IF     person[ebx + esi].alive == ALIVE
          call person[ebx + esi].lpProc
          mov eax, person[ebx + esi].direction
          imul person[ebx + esi].speed
          add person[ebx + esi].position.x, eax
     .ELSEIF person[ebx + esi].alive == DYING
          call person[ebx + esi].lpProc
          mov person[ebx + esi].alive, DEAD
     .ENDIF
     add esi, TYPE person
     loop callAllPersonProc
     .IF state != STATE_RUNNING
          mov stage, 0
     .ENDIF
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
          mov [ebx].Person.alive, DYING
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

stage_1_0 PROC USES ebx esi
     call GetStagePerson
     .IF person[ebx + esi].alive == ALIVE
          .IF person[ebx + esi + TYPE person].alive == DEAD
               mov person[ebx + esi].speed, SPEED_RUN
          .ENDIF
     .ELSE
          .IF person[ebx + esi + TYPE person].alive != ALIVE
               mov state, STATE_SUCCESS
          .ENDIF
     .ENDIF
     ret
stage_1_0 ENDP

stage_1_1 PROC USES ebx esi
     call GetStagePerson
     .IF person[ebx + esi + TYPE person].alive == ALIVE
          .IF person[ebx + esi].alive == DEAD
               mov person[ebx + esi + TYPE person].speed, SPEED_RUN
          .ENDIF
     .ELSE
          .IF person[ebx + esi].alive != ALIVE
               mov state, STATE_SUCCESS
          .ENDIF
     .ENDIF
     ret
stage_1_1 ENDP

stage_2_0 PROC USES ebx esi
     call GetStagePerson
     .IF person[ebx + esi].alive == ALIVE
          .IF (person[ebx + esi + TYPE person].alive != ALIVE) || (person[ebx + esi + 2 * TYPE person].alive != ALIVE)
               mov state, STATE_FAILED
          .ENDIF
     .ELSE
          .IF (person[ebx + esi + TYPE person].alive != ALIVE) && (person[ebx + esi + 2 * TYPE person].alive != ALIVE)
               mov state, STATE_SUCCESS
          .ENDIF
     .ENDIF
     ret
stage_2_0 ENDP

stage_2_1 PROC USES ebx esi
     call GetStagePerson
     .IF person[ebx + esi + TYPE person].alive == ALIVE
          .IF person[ebx + esi + 2 * TYPE person].alive != ALIVE
               mov state, STATE_FAILED
          .ENDIF
     .ELSE
          .IF (person[ebx + esi].alive != ALIVE) && (person[ebx + esi + 2 * TYPE person].alive != ALIVE)
               mov state, STATE_SUCCESS
          .ENDIF
     .ENDIF
     ret
stage_2_1 ENDP

stage_2_2 PROC USES ebx esi
     call GetStagePerson
     .IF person[ebx + esi + 2 * TYPE person].alive == ALIVE
          .IF person[ebx + esi + 2 * TYPE person].direction == DIRECTION_LEFT
               .IF (person[ebx + esi].alive != ALIVE) || (person[ebx + esi + TYPE person].alive != ALIVE)
                    mov state, STATE_FAILED
               .ELSE
                    .IF person[ebx + esi + 2 * TYPE person].position.x <= 400
                         mov person[ebx + esi + 2 * TYPE person].direction, DIRECTION_RIGHT
                    .ENDIF
               .ENDIF
          .ELSE
               .IF person[ebx + esi + 2 * TYPE person].position.x >= 500
                    mov person[ebx + esi + 2 * TYPE person].direction, DIRECTION_LEFT
               .ENDIF
          .ENDIF
     .ELSE
          .IF (person[ebx + esi].alive != ALIVE) && (person[ebx + esi + TYPE person].alive != ALIVE)
               mov state, STATE_SUCCESS
          .ENDIF
     .ENDIF
     ret
stage_2_2 ENDP

END WinMain