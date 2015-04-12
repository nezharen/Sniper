LoadAllPages PROTO
DrawStartPage PROTO, hdcBuffer: HDC
DrawStartBtn PROTO, hWnd:HWND
DrawModePage PROTO, hdcBuffer: HDC
DrawAllPage PROTO, hdcBuffer: HDC
ModifyPageCode PROTO,newPageCode: DWORD

WINDOW_WIDTH    equ 800
WINDOW_HEIGHT   equ 600
PAGE_START_BACK equ 4
PAGE_START_BTN  equ 3
PAGE_CHOOSE_MODE_BACK equ 5