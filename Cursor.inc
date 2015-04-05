LoadCursorBitmap PROTO
DrawMouse PROTO, hdc: HDC, x: LONG, y: LONG
RedrawMouse PROTO, hdc: HDC, x: LONG, y: LONG
GetMouseCursorWinPos PROTO, hWnd: HWND, point: PTR POINT
SetCursorWinPos PROTO, x: LONG, y: LONG
GetCursorWinPos PROTO, point: PTR POINT
GetNewCursorPos PROTO, hWnd: HWND, point: PTR POINT
StretchBkgd PROTO, hdc: HDC, x: LONG, y: LONG