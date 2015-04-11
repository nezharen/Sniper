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
PERSON_FOOT_LENGTH equ 4
PERSON_FOOT_WIDTH equ 3

STAND_TRUNK_DEGREE equ 180
STAND_LEG_RIGHT_DEGREE equ 200
STAND_LEG_LEFT_DEGREE equ 170
STAND_ARM_LEFT_STATIC_DEGREE equ 150
STAND_ARM_RIGHT_STATIC_DEGREE equ 210

STAND_ARM_MOVE_PERIOD equ 5 ;右胳膊每隔几秒钟动一次
STAND_ARM_MOVE_DEGREE_RANGE equ 20 ;胳膊的幅度

.data
dwPara180  DWORD  180
.code

DrawStandPerson PROC USES eax ebx, hdcbuffer:HDC, headcenter_x:DWORD, headcenter_y:DWORD
           LOCAL neckpointx:DWORD,neckpointy:DWORD,waistpointx:DWORD,waistpointy:DWORD,anklex:DWORD,ankley:DWORD,stTime:SYSTEMTIME
    
    INVOKE DrawHead,hdcbuffer,headcenter_x,headcenter_y

    mov eax,headcenter_y
    add eax,PERSON_HEAD_RADIUS
    mov neckpointy,eax
    mov eax,headcenter_x
    mov neckpointx,eax
    INVOKE DrawTrunk,hdcbuffer,neckpointx,neckpointy,STAND_TRUNK_DEGREE
    
    INVOKE GetLocalTime,ADDR stTime
    mov ax, stTime.wSecond
    mov bl, STAND_ARM_MOVE_PERIOD
    div bl

    .IF ah == 0
        mov ax, stTime.wMilliseconds
        mov bl, STAND_ARM_MOVE_DEGREE_RANGE
        div bl
        
        .IF al < 25
            add al, STAND_ARM_RIGHT_STATIC_DEGREE
            movzx ebx,al
            INVOKE DrawArm,hdcbuffer,headcenter_x,neckpointy,ebx
        .ELSEIF
            movzx ebx,al
            mov eax,STAND_ARM_RIGHT_STATIC_DEGREE
            add eax,50
            sub eax,ebx
            INVOKE DrawArm,hdcbuffer,headcenter_x,neckpointy,eax
        .ENDIF
    .ELSEIF
        INVOKE DrawArm,hdcbuffer,headcenter_x,neckpointy,STAND_ARM_RIGHT_STATIC_DEGREE
    .ENDIF

    INVOKE DrawArm,hdcbuffer,neckpointx,neckpointy,STAND_ARM_LEFT_STATIC_DEGREE
    
    mov eax,neckpointy
    add eax,PERSON_TRUNK_LENGTH
    mov waistpointy,eax
    mov eax,neckpointx
    mov waistpointx,eax
    INVOKE DrawLeg,hdcbuffer,waistpointx,waistpointy,STAND_LEG_RIGHT_DEGREE
    INVOKE DrawLeg,hdcbuffer,waistpointx,waistpointy,STAND_LEG_LEFT_DEGREE
    
    INVOKE CalcX, STAND_LEG_RIGHT_DEGREE,PERSON_LEG_LENGTH,waistpointx
    mov anklex,eax
    INVOKE CalcY, STAND_LEG_RIGHT_DEGREE,PERSON_LEG_LENGTH,waistpointy
    mov ankley,eax
    INVOKE DrawFoot,hdcbuffer,anklex,ankley,270
    
    INVOKE CalcX, STAND_LEG_LEFT_DEGREE,PERSON_LEG_LENGTH,waistpointx
    mov anklex,eax
    INVOKE CalcY, STAND_LEG_LEFT_DEGREE,PERSON_LEG_LENGTH,waistpointy
    mov ankley,eax
    INVOKE DrawFoot,hdcbuffer,anklex,ankley,270

    ret
DrawStandPerson ENDP

DrawHead PROC USES eax ebx ecx edx,hdcbuffer:HDC,headcenter_X:DWORD,headcenter_Y:DWORD
    LOCAL hbrush:HBRUSH, holdObject:HGDIOBJ
    
    INVOKE GetStockObject,BLACK_BRUSH
    mov hbrush,eax
    INVOKE SelectObject,hdcbuffer,hbrush
    mov holdObject,eax

    mov eax, headcenter_X
    sub eax, PERSON_HEAD_RADIUS
    mov ebx, headcenter_Y
    sub ebx, PERSON_HEAD_RADIUS
    mov ecx, headcenter_X
    add ecx, PERSON_HEAD_RADIUS
    mov edx, headcenter_Y
    add edx, PERSON_HEAD_RADIUS
    INVOKE Ellipse,hdcbuffer,eax,ebx,ecx,edx
    
    INVOKE SelectObject,hdcbuffer,holdObject
    INVOKE DeleteObject,eax
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

DrawFoot PROC,hdcbuffer:HDC,foottop_x:DWORD,foottop_y:DWORD,degree:DWORD
    
    INVOKE DrawRotateLine,hdcbuffer,foottop_x,foottop_y,PERSON_FOOT_LENGTH,PERSON_FOOT_WIDTH,degree

    ret
DrawFoot ENDP

DrawRotateLine PROC USES eax,hdcbuffer:HDC,centerX:DWORD,centerY:DWORD,radius:DWORD,linewidth:DWORD,degree:DWORD
    LOCAL hpen:HPEN,linePointX:DWORD,linePointY:DWORD,holdObject:HGDIOBJ

    INVOKE CreatePen, PS_SOLID,linewidth,00h
    mov hpen, eax
    INVOKE SelectObject,hdcbuffer,hpen
    mov holdObject, eax
    
    INVOKE MoveToEx,hdcbuffer,centerX,centerY,NULL

    INVOKE CalcX,degree,radius,centerX
    mov linePointX, eax
    INVOKE CalcY,degree,radius,centerY
    mov linePointY, eax
    
    INVOKE LineTo,hdcbuffer,linePointX,linePointY

    INVOKE SelectObject,hdcbuffer,holdObject
    INVOKE DeleteObject,eax
    ret
DrawRotateLine ENDP

;calculate-rotate line-the other point-value x
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