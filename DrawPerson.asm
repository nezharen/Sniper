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

.data
dwPara180  DWORD  180

.code

DrawStandPerson PROC USES eax ebx, hdcbuffer:HDC, headcenter_x:DWORD, headcenter_y:DWORD
           LOCAL neckpointx:DWORD, neckpointy:DWORD, waistpointx:DWORD, waistpointy:DWORD, anklex:DWORD, ankley:DWORD,stTime:SYSTEMTIME
    
    INVOKE DrawHead,hdcbuffer,headcenter_x,headcenter_y

    mov eax,headcenter_y
    add eax,PERSON_HEAD_RADIUS
    mov neckpointy,eax
    mov eax,headcenter_x
    mov neckpointx,eax
    INVOKE DrawTrunk,hdcbuffer,neckpointx,neckpointy,STAND_TRUNK_DEGREE
    
    mov eax,neckpointy
    add eax,PERSON_TRUNK_LENGTH
    mov waistpointy,eax
    mov eax,neckpointx
    mov waistpointx,eax

    INVOKE GetLocalTime,ADDR stTime
    mov ax, stTime.wSecond
    mov bl, STAND_ARM_MOVE_PERIOD
    div bl

    .IF ah == 0
        INVOKE DrawArm,hdcbuffer,neckpointx,neckpointy,205,1,ROTATE_DIRECTION_ANTICLOCKWISE
        INVOKE DrawArm,hdcbuffer,neckpointx,neckpointy,155,1,ROTATE_DIRECTION_CLOCKWISE

        INVOKE DrawLeg,hdcbuffer,waistpointx,waistpointy,155,1,ROTATE_DIRECTION_CLOCKWISE
        INVOKE DrawLeg,hdcbuffer,waistpointx,waistpointy,205,1,ROTATE_DIRECTION_ANTICLOCKWISE
    .ELSEIF
        INVOKE DrawArm,hdcbuffer,neckpointx,neckpointy,212,0,ROTATE_DIRECTION_NULL
        INVOKE DrawArm,hdcbuffer,neckpointx,neckpointy,147,0,ROTATE_DIRECTION_NULL

        INVOKE DrawLeg,hdcbuffer,waistpointx,waistpointy,147,0,ROTATE_DIRECTION_NULL
        INVOKE DrawLeg,hdcbuffer,waistpointx,waistpointy,212,0,ROTATE_DIRECTION_NULL
    .ENDIF
    
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
    
    INVOKE DrawDegreeLine,hdcbuffer,trunktop_x,trunktop_y,PERSON_TRUNK_LENGTH,PERSON_TRUNK_WIDTH,degree

    ret
DrawTrunk ENDP

;armtype: 0 for still, 1 for move in a normal speed, 2 for mov in a high speed
DrawArm PROC,hdcbuffer:HDC,armtop_x:DWORD,armtop_y:DWORD,degree:DWORD,armspeed:DWORD,armRotateDirection:DWORD
    .IF armspeed == 0
        INVOKE DrawDegreeLine,hdcbuffer,armtop_x,armtop_y,PERSON_ARM_LENGTH,PERSON_ARM_WIDTH,degree
    .ELSE
        INVOKE DrawRotateLine,hdcbuffer,armtop_x,armtop_y,PERSON_ARM_LENGTH,PERSON_ARM_WIDTH,degree,armspeed,armRotateDirection
    .ENDIF
    ret
DrawArm ENDP

DrawLeg PROC,hdcbuffer:HDC,legtop_x:DWORD,legtop_y:DWORD,degree:DWORD,legspeed:DWORD,legRotateDirection:DWORD
    LOCAL anklex:DWORD, ankley:DWORD, leg_degree:DWORD
    .IF legspeed == 0
        INVOKE DrawDegreeLine,hdcbuffer,legtop_x,legtop_y,PERSON_LEG_LENGTH,PERSON_LEG_WIDTH,degree
    .ELSE
        INVOKE DrawRotateLine,hdcbuffer,legtop_x,legtop_y,PERSON_LEG_LENGTH,PERSON_LEG_WIDTH,degree,legspeed,legRotateDirection

        mov leg_degree, eax
        INVOKE CalcX, leg_degree,PERSON_LEG_LENGTH,legtop_x
        mov anklex, eax
        INVOKE CalcY, leg_degree,PERSON_LEG_LENGTH,legtop_y
        mov ankley, eax
        INVOKE DrawFoot,hdcbuffer,anklex,ankley,270

    .ENDIF
    ret
DrawLeg ENDP

DrawFoot PROC,hdcbuffer:HDC,foottop_x:DWORD,foottop_y:DWORD,degree:DWORD
    
    INVOKE DrawDegreeLine,hdcbuffer,foottop_x,foottop_y,PERSON_FOOT_LENGTH,PERSON_FOOT_WIDTH,degree

    ret
DrawFoot ENDP

;return eax value degree
DrawRotateLine PROC USES ebx,hdcbuffer:HDC,centerX:DWORD,centerY:DWORD,radius:DWORD,linewidth:DWORD,startdegree:DWORD,rotatespeed:DWORD, rotateDirection:DWORD
    LOCAL stTime:SYSTEMTIME, rotateRange:DWORD, DrotateRange:DWORD, rotateCoefficient:DWORD

    .IF rotatespeed == 1
        mov rotateCoefficient,ROTATE_LINE_SPEED_ONE
    .ELSEIF rotatespeed == 2
        mov rotateCoefficient,ROTATE_LINE_SPEED_TWO
    .ENDIF
    
    mov eax, REFRESH_FRAME
    mov ebx, rotateCoefficient
    mul ebx
    mov DrotateRange,eax


    INVOKE GetLocalTime,ADDR stTime
    mov ax, stTime.wMilliseconds
    mov bl, REFRESH_PERIOD
    div bl
    .IF rotateDirection == ROTATE_DIRECTION_CLOCKWISE
        .IF al < REFRESH_HALF_FRAME
            movzx ebx,al
            mov eax,ebx
            mov ebx,rotateCoefficient
            mul ebx
            add eax, startdegree
            mov ebx,eax
            INVOKE DrawDegreeLine,hdcbuffer,centerX,centerY,radius,linewidth,ebx
        .ELSEIF
            movzx ebx,al
            mov eax,ebx
            mov ebx,rotateCoefficient
            mul ebx
            mov ebx,startdegree
            add ebx,DrotateRange
            sub ebx,eax
            INVOKE DrawDegreeLine,hdcbuffer,centerX,centerY,radius,linewidth,ebx
        .ENDIF
    .ELSEIF rotateDirection == ROTATE_DIRECTION_ANTICLOCKWISE
        .IF al < REFRESH_HALF_FRAME
            movzx ebx,al
            mov eax,ebx
            mov ebx,rotateCoefficient
            mul ebx
            mov ebx,startdegree
            sub ebx,eax
            INVOKE DrawDegreeLine,hdcbuffer,centerX,centerY,radius,linewidth,ebx
        .ELSEIF
            movzx ebx,al
            mov eax,ebx
            mov ebx,rotateCoefficient
            mul ebx
            mov ebx,startdegree
            sub ebx,DrotateRange
            add ebx,eax
            INVOKE DrawDegreeLine,hdcbuffer,centerX,centerY,radius,linewidth,ebx
        .ENDIF
    .ENDIF
    mov eax,ebx
    ret
DrawRotateLine ENDP

DrawDegreeLine PROC USES eax,hdcbuffer:HDC,centerX:DWORD,centerY:DWORD,radius:DWORD,linewidth:DWORD,degree:DWORD
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
DrawDegreeLine ENDP

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