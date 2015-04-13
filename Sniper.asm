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
INCLUDE Window.inc
INCLUDE Cursor.inc
INCLUDE DrawPage.inc
INCLUDE DrawPerson.inc
INCLUDE Sniper.inc

DrawStage PROTO, hdcBuffer: HDC
UpdateStage PROTO
Fire PROTO
RestoreStage PROTO

.data
     stage  DWORD  0
     state  DWORD  STATE_RUNNING
     person Person <>, <>, <>, <>
     personStageSize equ ($ - person)
            Person <>, <>, <>, <>
            Person <>, <>, <>, <>
            Person <>, <>, <>, <>
     personStageSum DWORD 0, 2, 3, 4
     personBackup Person <>, <>, <>, <>
            Person <ALIVE, <180, 180>, SPEED_NULL, DIRECTION_RIGHT, NO_GUN, stage_1_0>, <ALIVE, <200, 185>, SPEED_NULL, DIRECTION_LEFT, NO_GUN, stage_1_1>, <>, <>
            Person <ALIVE, <100, 300>, SPEED_NULL, DIRECTION_RIGHT, HAS_GUN, stage_2_0>, <ALIVE, <300, 350>, SPEED_NULL, DIRECTION_RIGHT, HAS_GUN, stage_2_1>,
                   <ALIVE, <600, 320>, SPEED_WALK, DIRECTION_LEFT, HAS_GUN, stage_2_2>, <>
            Person <ALIVE, <50, 370>, SPEED_WALK, DIRECTION_RIGHT, HAS_GUN, stage_3_0>, <ALIVE, <750, 330>, SPEED_WALK, DIRECTION_LEFT, HAS_GUN, stage_3_1>,
                   <ALIVE, <375, 350>, SPEED_NULL, DIRECTION_RIGHT, NO_GUN, stage_3_2>, <ALIVE, <425, 355>, SPEED_NULL, DIRECTION_LEFT, NO_GUN, stage_3_3>
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
     LOCAL hCursorPoint: POINT, hdcBkGd: HDC, hdcBuffer: HDC, hbmpBuffer: HBITMAP,
           xPos:DWORD, yPos:DWORD, hdc: HDC, ps: PAINTSTRUCT, hPoint: POINT,
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
		  .IF stage > 0
			INVOKE DrawStage, hdcBuffer
			INVOKE GetNewCursorPos, hWnd, ADDR hCursorPoint
			INVOKE DrawMouse, hdcBuffer, hCursorPoint.x, hCursorPoint.y
		  .ENDIF
		  
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
          
          INVOKE DrawStartBtn, 180, 510, hWnd, 401
          
     .ELSEIF eax == WM_COMMAND
          .IF wParam == 401
              INVOKE ModifyPageCode,1
			  INVOKE DestroyStartBtn
			  INVOKE CreateStageSelectMenu, hWnd
			  INVOKE InvalidateRect, hWnd, NULL, FALSE
		  .ELSEIF wParam == 402	; Start stage 1
			  INVOKE ModifyPageCode, 21
			  INVOKE DestroyStartBtn
			  mov stage, 1
			  INVOKE RestoreStage
			  mov state, STATE_RUNNING
			  INVOKE ShowCursor, FALSE
		  .ELSEIF wParam == 403	; Start stage 2
			  INVOKE ModifyPageCode, 22
			  INVOKE DestroyStartBtn
			  mov stage, 2
			  INVOKE RestoreStage
			  mov state, STATE_RUNNING
			  INVOKE ShowCursor, FALSE
		  .ELSEIF wParam == 404	; Start stage 3
			  INVOKE ModifyPageCode, 23
			  INVOKE DestroyStartBtn
			  mov stage, 3
			  INVOKE RestoreStage
			  mov state, STATE_RUNNING
			  INVOKE ShowCursor, FALSE
		  .ELSEIF wParam == 501	; Go to stage 1
			  INVOKE ModifyPageCode, 11
			  INVOKE DestroyStageSelectMenu
			  INVOKE DrawStartBtn, 650, 530, hWnd, 402
			  INVOKE InvalidateRect, hWnd, NULL, FALSE
		  .ELSEIF wParam == 502	; Go to stage 2
			  INVOKE ModifyPageCode, 12
			  INVOKE DestroyStageSelectMenu
			  INVOKE DrawStartBtn, 650, 530, hWnd, 403
			  INVOKE InvalidateRect, hWnd, NULL, FALSE
		  .ELSEIF wParam == 503	; Go to stage 3
			  INVOKE ModifyPageCode, 13
			  INVOKE DestroyStageSelectMenu
			  INVOKE DrawStartBtn, 650, 530, hWnd, 404
			  INVOKE InvalidateRect, hWnd, NULL, FALSE
		  .ELSEIF wParam == 600
			  INVOKE DestroyContinueButton
			  INVOKE GetPreviousPageCode
			  mov edx, eax
			  sub eax, 10
			  INVOKE ModifyPageCode, eax
			  add edx, 381
			  INVOKE DrawStartBtn, 650, 530, hWnd, edx
			  INVOKE InvalidateRect, hWnd, NULL, FALSE
		  .ELSEIF wParam == 601
			  INVOKE ModifyPageCode,1
			  INVOKE DestroyContinueButton
			  INVOKE CreateStageSelectMenu, hWnd
			  INVOKE InvalidateRect, hWnd, NULL, FALSE
          .ENDIF
     .ELSEIF eax == WM_TIMER
          .IF stage > 0
               INVOKE InvalidateRect, hWnd, NULL, FALSE
               INVOKE UpdateWindow, hWnd
               INVOKE UpdateStage
		  .ELSE
			   INVOKE GetPageCode
			   .IF eax >= 21 && eax <= 23
				.IF state == STATE_FAILED
					INVOKE SavePreviousPageCode
					INVOKE ModifyPageCode, 40
					INVOKE CreateContinueButton, hWnd, 600
					INVOKE ShowCursor, TRUE
					INVOKE InvalidateRect, hWnd, NULL, FALSE
				.ELSEIF state == STATE_SUCCESS
					INVOKE ModifyPageCode, 41
					INVOKE CreateContinueButton, hWnd, 601
					INVOKE ShowCursor, TRUE
					INVOKE InvalidateRect, hWnd, NULL, FALSE
				.ENDIF
			   .ENDIF
          .ENDIF
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

DrawStage PROC USES eax ecx esi ebx, hdcBuffer: HDC
	call GetStagePerson
    call GetStagePersonSum
	cmp ecx, 0
	je finish
drawAllPerson:
	INVOKE DrawPerson, hdcBuffer, ADDR person[ebx + esi]
    add esi, TYPE person
    loop drawAllPerson
finish:
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

RestoreStage PROC USES ecx esi edi eax edx ebx
	cld
	mov eax, stage
	mov ebx, personStageSize
	mul ebx
	mov esi, OFFSET personBackup
	add esi, eax
	mov edi, OFFSET person
	add edi, eax
	mov ecx, personStageSize
	rep movsb

	ret
RestoreStage ENDP

juagePerson PROC USES eax ebx ecx edx, x:PTR Person
     LOCAL hCursorPoint:POINT
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
     .IF ecx <= PERSON_HEAD_RADIUS * PERSON_HEAD_RADIUS
          mov [ebx].Person.alive, DYING
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
               .IF person[ebx + esi].position.x >= 795
                    mov state, STATE_FAILED
               .ENDIF
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
               .IF person[ebx + esi + TYPE person].position.x <= 5
                    mov state, STATE_FAILED
               .ENDIF
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
                    .IF person[ebx + esi + 2 * TYPE person].position.x <= 590
                         mov state, STATE_FAILED
                    .ENDIF
               .ELSE
                    .IF person[ebx + esi + 2 * TYPE person].position.x <= 400
                         mov person[ebx + esi + 2 * TYPE person].direction, DIRECTION_RIGHT
                    .ENDIF
               .ENDIF
          .ELSE
               .IF person[ebx + esi + 2 * TYPE person].position.x >= 600
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

stage_3_0 PROC USES ebx esi
     call GetStagePerson
     .IF person[ebx + esi].alive == ALIVE
          .IF person[ebx + esi].direction == DIRECTION_RIGHT
               .IF person[ebx + esi].position.x >= 150
                    mov person[ebx + esi].direction, DIRECTION_LEFT
               .ENDIF
          .ELSE
               .IF person[ebx + esi].position.x <= 50
                    mov person[ebx + esi].direction, DIRECTION_RIGHT
               .ENDIF
          .ENDIF
     .ELSE
          mov state, STATE_FAILED
     .ENDIF
     ret
stage_3_0 ENDP

stage_3_1 PROC USES ebx esi
     call GetStagePerson
     .IF person[ebx + esi + TYPE person].alive == ALIVE
          .IF person[ebx + esi + TYPE person].direction == DIRECTION_LEFT
               .IF person[ebx + esi + TYPE person].position.x <= 650
                    mov person[ebx + esi + TYPE person].direction, DIRECTION_RIGHT
               .ENDIF
          .ELSE
               .IF person[ebx + esi + TYPE person].position.x >= 750
                    mov person[ebx + esi + TYPE person].direction, DIRECTION_LEFT
               .ENDIF
          .ENDIF
     .ELSE
          mov state, STATE_FAILED
     .ENDIF
     ret
stage_3_1 ENDP

stage_3_2 PROC USES ebx esi
     call GetStagePerson
     .IF person[ebx + esi + 2 * TYPE person].alive == ALIVE
          .IF person[ebx + esi + 3 * TYPE person].alive == DEAD
               mov person[ebx + esi + 2 * TYPE person].speed, SPEED_RUN
               .IF person[ebx + esi + 2 * TYPE person].position.x >= 505
                    mov state, STATE_FAILED
               .ENDIF
          .ENDIF
     .ELSE
          .IF person[ebx + esi + 3 * TYPE person].alive != ALIVE
               mov state, STATE_SUCCESS
          .ENDIF
     .ENDIF
     ret
stage_3_2 ENDP

stage_3_3 PROC USES ebx esi
     call GetStagePerson
     .IF person[ebx + esi + 3 * TYPE person].alive == ALIVE
          .IF person[ebx + esi + 2 * TYPE person].alive == DEAD
               mov person[ebx + esi + 3 * TYPE person].speed, SPEED_RUN
               .IF person[ebx + esi + 3 * TYPE person].position.x <= 302
                    mov state, STATE_FAILED
               .ENDIF
          .ENDIF
     .ELSE
          .IF person[ebx + esi + 2 * TYPE person].alive != ALIVE
               mov state, STATE_SUCCESS
          .ENDIF
     .ENDIF
     ret
stage_3_3 ENDP

END WinMain