LoadCursorBitmap PROTO
CreateOldBkgd PROTO, hdc: HDC
DrawMouse PROTO, hdc: HDC, x: LONG, y: LONG
RedrawMouse PROTO, hdc: HDC, x: LONG, y: LONG
DeleteOldBkgd PROTO
GetMouseCursorWinPos PROTO, hWnd: HWND, point: PTR POINT
SetCursorWinPos PROTO, x: LONG, y: LONG
GetCursorWinPos PROTO, point: PTR POINT
