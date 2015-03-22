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

.code

WinMain PROC
.data
     className    BYTE     "MainWin", 0
     MainWndTitle BYTE     "Sniper", 0
     MainWin      WNDCLASS <NULL, WinProc, NULL, NULL, NULL, NULL, NULL, \
                            COLOR_WINDOW, NULL, className>
     msg          MSG      <>
     hMainWnd     DWORD    ?
     hInstance    DWORD    ?
.code
     INVOKE GetModuleHandle, NULL
     mov hInstance, eax
     mov MainWin.hInstance, eax
     INVOKE LoadIcon, NULL, IDI_APPLICATION
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

WinProc PROC, hWnd:DWORD, localMsg:DWORD, wParam:DWORD, lParam:DWORD
.data
     PopupTitle BYTE "Sniper", 0
     PopupText  BYTE "Fire!", 0
.code
     mov eax, localMsg
     .IF     eax == WM_LBUTTONDOWN
          INVOKE MessageBox, hWnd, ADDR PopupText, ADDR PopupTitle, MB_OK
          ret
     .ELSEIF eax == WM_CLOSE
          INVOKE DestroyWindow, hWnd
          ret
     .ELSEIF eax == WM_DESTROY
          INVOKE PostQuitMessage, 0
          ret
     .ELSE
          INVOKE DefWindowProc, hWnd, localMsg, wParam, lParam
          ret
     .ENDIF
WinProc ENDP

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

END WinMain