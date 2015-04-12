CURSOR_HEIGHT   EQU 256
CURSOR_WIDTH    EQU 256
CURSOR_RES_ID   EQU 2
MASK_1_RES_ID	EQU 6
MASK_2_RES_ID	EQU 7

LoadCursorBitmap PROTO
DrawMouse PROTO, hdc: HDC, x: LONG, y: LONG
RedrawMouse PROTO, hdc: HDC, x: LONG, y: LONG
GetMouseCursorWinPos PROTO, hWnd: HWND, point: PTR POINT
SetCursorWinPos PROTO, x: LONG, y: LONG
GetCursorWinPos PROTO, point: PTR POINT
GetNewCursorPos PROTO, hWnd: HWND, point: PTR POINT
StretchBkgd PROTO, hdc: HDC, x: LONG, y: LONG