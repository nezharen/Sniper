.386
.model flat,STDCALL
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

INCLUDE DrawPerson.inc

PERSON_HEAD_RADIUS equ 5
PERSON_TRUNK_LENGTH equ 10
PERSON_TRUNK_WIDTH equ 4
PERSON_ARM_LENGTH equ 10
PERSON_ARM_WIDTH equ 4
PERSON_LEG_LENGTH equ 15
PERSON_LEG_WIDTH equ 4

STAND_TRUNK_DEGREE equ 180
STAND_LEG_RIGHT_DEGREE equ 200
STAND_LEG_LEFT_DEGREE equ 170
.data

.code

DrawStandPerson PROC USES eax ebx, hdcbuffer:HDC, headcenter_x:DWORD, headcenter_y:DWORD
           LOCAL neckpointx:DWORD,neckpointy:DWORD,waistpointx:DWORD,waistpointy:DWORD,stTime:SYSTEMTIME
    
    INVOKE DrawHead,hdcbuffer,headcenter_x,headcenter_y

    mov eax,headcenter_y
    add eax,PERSON_HEAD_RADIUS
    mov neckpointy,eax
    INVOKE DrawTrunk,hdcbuffer,headcenter_x,neckpointy,STAND_TRUNK_DEGREE
    
    INVOKE GetLocalTime,ADDR stTime

    INVOKE DrawArm,hdcbuffer,headcenter_x,neckpointy,stTime.wMilliseconds
    INVOKE DrawArm,hdcbuffer,headcenter_x,neckpointy,150

    mov eax,neckpointy
    add eax,PERSON_TRUNK_LENGTH
    mov waistpointy,eax
    INVOKE DrawLeg,hdcbuffer,headcenter_x,waistpointy,STAND_LEG_RIGHT_DEGREE
    INVOKE DrawLeg,hdcbuffer,headcenter_x,waistpointy,STAND_LEG_LEFT_DEGREE

    ret
DrawStandPerson ENDP

DrawHead PROC USES eax ebx ecx edx,hdcbuffer:HDC,headcenter_X:DWORD,headcenter_Y:DWORD
    LOCAL hbrush:HBRUSH
    
    INVOKE GetStockObject,BLACK_BRUSH
    mov hbrush,eax
    INVOKE SelectObject,hdcbuffer,hbrush
    INVOKE DeleteObject,eax

    mov eax, headcenter_X
    sub eax, PERSON_HEAD_RADIUS
    mov ebx, headcenter_Y
    sub ebx, PERSON_HEAD_RADIUS
    mov ecx, headcenter_X
    add ecx, PERSON_HEAD_RADIUS
    mov edx, headcenter_Y
    add edx, PERSON_HEAD_RADIUS
    INVOKE Ellipse,hdcbuffer,eax,ebx,ecx,edx
    ret
DrawHead ENDP

DrawTrunk PROC USES eax,hdcbuffer:HDC,trunktop_x:DWORD,trunktop_y:DWORD,degree:DWORD
    
    INVOKE DrawRotateLine,hdcbuffer,trunktop_x,trunktop_y,PERSON_TRUNK_LENGTH,PERSON_TRUNK_WIDTH,degree

    ret
DrawTrunk ENDP

DrawArm PROC,hdcbuffer:HDC,armtop_x:DWORD,armtop_y:DWORD,degree:DWORD
    
    INVOKE DrawRotateLine,hdcbuffer,armtop_x,armtop_y,PERSON_ARM_LENGTH,PERSON_ARM_WIDTH,degree

    ret
DrawArm ENDP

DrawLeg PROC,hdcbuffer:HDC,legtop_x:DWORD,legtop_y:DWORD,degree:DWORD

    INVOKE DrawRotateLine,hdcbuffer,legtop_x,legtop_y,PERSON_LEG_LENGTH,PERSON_LEG_WIDTH,degree

    ret
DrawLeg ENDP

DrawRotateLine PROC USES eax,hdcbuffer:HDC,centerX:DWORD,centerY:DWORD,radius:DWORD,linewidth:DWORD,degree:DWORD
    LOCAL hpen:HPEN,linePointX:DWORD,linePointY:DWORD

    INVOKE CreatePen, PS_SOLID,linewidth,00h
    mov hpen, eax
    INVOKE SelectObject,hdcbuffer,hpen
    INVOKE DeleteObject,eax
    
    INVOKE MoveToEx,hdcbuffer,centerX,centerY,NULL

    INVOKE CalcX,degree,radius,centerX
    mov linePointX, eax
    INVOKE CalcY,degree,radius,centerY
    mov linePointY, eax
    
    INVOKE LineTo,hdcbuffer,linePointX,linePointY
    ret
DrawRotateLine ENDP

;calculate-rotate line-the other point-value x
dwPara180  DWORD  180
CalcX PROC,dwDegree:DWORD,dwRadius:DWORD,dwCenterX:DWORD
        local   @dwReturn

        fild    dwCenterX
        fild    dwDegree
        fldpi
        fmul            ;角度*Pi
        fild    dwPara180
        fdivp   st(1),st    ;角度*Pi/180
        fsin            ;Sin(角度*Pi/180)
        fild    dwRadius
        fmul            ;半径*Sin(角度*Pi/180)
        fadd            ;X+半径*Sin(角度*Pi/180)
        fistp   @dwReturn
        mov eax,@dwReturn
        ret
CalcX ENDP
;calculate-rotate line-the other point-value x
CalcY PROC,dwDegree:DWORD,dwRadius:DWORD,dwCenterY:DWORD
        local   @dwReturn

        fild    dwCenterY
        fild    dwDegree
        fldpi
        fmul
        fild    dwPara180
        fdivp   st(1),st
        fcos
        fild    dwRadius
        fmul
        fsubp   st(1),st
        fistp   @dwReturn
        mov eax,@dwReturn
        ret

CalcY ENDP

END