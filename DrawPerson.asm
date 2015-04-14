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
INCLUDE Sniper.inc

.data
dwPara180  DWORD  180

.code

DrawPerson PROC USES eax ebx ecx, hdcbuffer:HDC, hperson:PTR Person
           LOCAL headcenter_x:DWORD, headcenter_y:DWORD,neckpointx:DWORD, neckpointy:DWORD, waistpointx:DWORD, waistpointy:DWORD, 
                 trunkdegree:DWORD, armleftdegree:DWORD, armrightdegree:DWORD, legleftdegree:DWORD,legrightdegree:DWORD,armspeed:DWORD,legspeed:DWORD,
                 stTime:SYSTEMTIME, direction:SDWORD, speed:DWORD, alive:BYTE, hasGUN:BYTE, deadheadcenterX:DWORD, deadheadcenterY:DWORD,
                 tmpheadcenter_x:DWORD,tmpheadcenter_y:DWORD
    mov eax,hperson
    mov ebx,[eax].Person.position.x
    mov headcenter_x,ebx
    mov ebx,[eax].Person.position.y
    mov headcenter_y,ebx
    mov ebx,[eax].Person.direction
    mov direction,ebx
    mov ebx,[eax].Person.speed
    mov speed,ebx
    mov bl,[eax].Person.alive
    mov alive,bl
    mov bl,[eax].Person.hasGun
    mov hasGUN,bl

    .IF alive == ALIVE
        mov eax,headcenter_y
        add eax,PERSON_HEAD_RADIUS
        mov neckpointy,eax
        add eax,PERSON_TRUNK_LENGTH
        mov waistpointy,eax

        mov eax,headcenter_x
        mov neckpointx,eax
        mov waistpointx,eax
        
        mov eax,STAND_TRUNK_DEGREE
        mov trunkdegree,eax
        
        .IF speed == SPEED_NULL
            mov eax,STAND_ARM_LEFT_STATIC_DEGREE
            mov armleftdegree,eax
            mov eax,STAND_ARM_RIGHT_STATIC_DEGREE
            mov armrightdegree,eax

            mov eax,STAND_LEG_LEFT_STATIC_DEGREE
            mov legleftdegree,eax
            mov eax,STAND_LEG_RIGHT_STATIC_DEGREE
            mov legrightdegree,eax

            mov eax,speed
            mov armspeed,eax
            mov legspeed,eax
        .ELSEIF speed == SPEED_WALK
            mov eax,WALK_ARM_LEFT_START_DEGREE
            mov armleftdegree,eax
            mov eax,WALK_ARM_RIGHT_START_DEGREE
            mov armrightdegree,eax

            mov eax,WALK_LEG_LEFT_START_DEGREE
            mov legleftdegree,eax
            mov eax,WALK_LEG_RIGHT_START_DEGREE
            mov legrightdegree,eax

            mov eax,WALK_ARM_SPEED
            mov armspeed,eax
            mov eax,WALK_LEG_SPEED
            mov legspeed,eax
        .ELSE
            mov eax,RUN_ARM_LEFT_START_DEGREE
            mov armleftdegree,eax
            mov eax,RUN_ARM_RIGHT_START_DEGREE
            mov armrightdegree,eax

            mov eax,RUN_LEG_LEFT_START_DEGREE
            mov legleftdegree,eax
            mov eax,RUN_LEG_RIGHT_START_DEGREE
            mov legrightdegree,eax

            mov eax,RUN_ARM_SPEED
            mov armspeed,eax
            mov eax,RUN_LEG_SPEED
            mov legspeed,eax
        .ENDIF
    .ELSEIF alive == DYING
       .IF direction == DIRECTION_LEFT
            mov eax,headcenter_x
            mov tmpheadcenter_x,eax
            ;caculate dying head center
            mov ebx,PERSON_HEAD_CENTER_TO_ANKLE_LENGTH
            mov ecx,DYING_DIRECTION_LEFT_HEAD_TO_FOOT_DEGREE
            INVOKE CalcX,ecx,ebx,eax
            mov headcenter_x,eax

            mov eax,headcenter_y
            mov tmpheadcenter_y,eax

            mov ebx,PERSON_HEAD_CENTER_TO_ANKLE_LENGTH
            add eax,ebx
            mov ecx,DYING_DIRECTION_LEFT_HEAD_TO_FOOT_DEGREE
            INVOKE CalcY,ecx,ebx,eax
            mov headcenter_y,eax
            ;caculate dying trunk and arm top point
            mov eax,tmpheadcenter_x
            mov ebx,PERSON_HEAD_CENTER_TO_ANKLE_LENGTH
            sub ebx,PERSON_HEAD_RADIUS
            mov ecx,DYING_DIRECTION_LEFT_HEAD_TO_FOOT_DEGREE
            INVOKE CalcX,ecx,ebx,eax
            mov neckpointx,eax

            mov eax,tmpheadcenter_y
            mov ebx,PERSON_HEAD_CENTER_TO_ANKLE_LENGTH
            add eax,ebx
            sub ebx,PERSON_HEAD_RADIUS
            mov ecx,DYING_DIRECTION_LEFT_HEAD_TO_FOOT_DEGREE
            INVOKE CalcY,ecx,ebx,eax
            mov neckpointy,eax
            ;caculate dying leg to point
            mov eax,tmpheadcenter_x
            mov ebx,PERSON_HEAD_CENTER_TO_ANKLE_LENGTH
            sub ebx,PERSON_HEAD_RADIUS
            sub ebx,PERSON_TRUNK_LENGTH
            mov ecx,DYING_DIRECTION_LEFT_HEAD_TO_FOOT_DEGREE
            INVOKE CalcX,ecx,ebx,eax
            mov waistpointx,eax

            mov eax,tmpheadcenter_y
            mov ebx,PERSON_HEAD_CENTER_TO_ANKLE_LENGTH
            add eax,ebx
            sub ebx,PERSON_HEAD_RADIUS
            sub ebx,PERSON_TRUNK_LENGTH
            mov ecx,DYING_DIRECTION_LEFT_HEAD_TO_FOOT_DEGREE
            INVOKE CalcY,ecx,ebx,eax
            mov waistpointy,eax

            mov eax,DYING_DIRECTION_LEFT_BODY_TO_HEAD_DEGREE
            mov trunkdegree,eax
            mov armrightdegree,eax
            mov armleftdegree,eax
            mov legleftdegree,eax
            mov legrightdegree,eax

            mov eax,DYING_SPEED
            mov armspeed,eax
            mov legspeed,eax
       .ELSE
            mov eax,headcenter_x
            mov tmpheadcenter_x,eax
            ;caculate dying head center
            mov ebx,PERSON_HEAD_CENTER_TO_ANKLE_LENGTH
            mov ecx,DYING_DIRECTION_RIGHT_HEAD_TO_FOOT_DEGREE
            INVOKE CalcX,ecx,ebx,eax
            mov headcenter_x,eax

            mov eax,headcenter_y
            mov tmpheadcenter_y,eax

            mov ebx,PERSON_HEAD_CENTER_TO_ANKLE_LENGTH
            add eax,ebx
            mov ecx,DYING_DIRECTION_RIGHT_HEAD_TO_FOOT_DEGREE
            INVOKE CalcY,ecx,ebx,eax
            mov headcenter_y,eax
            ;caculate dying trunk and arm top point
            mov eax,tmpheadcenter_x
            mov ebx,PERSON_HEAD_CENTER_TO_ANKLE_LENGTH
            sub ebx,PERSON_HEAD_RADIUS
            mov ecx,DYING_DIRECTION_RIGHT_HEAD_TO_FOOT_DEGREE
            INVOKE CalcX,ecx,ebx,eax
            mov neckpointx,eax

            mov eax,tmpheadcenter_y
            mov ebx,PERSON_HEAD_CENTER_TO_ANKLE_LENGTH
            add eax,ebx
            sub ebx,PERSON_HEAD_RADIUS
            mov ecx,DYING_DIRECTION_RIGHT_HEAD_TO_FOOT_DEGREE
            INVOKE CalcY,ecx,ebx,eax
            mov neckpointy,eax
            ;caculate dying leg to point
            mov eax,tmpheadcenter_x
            mov ebx,PERSON_HEAD_CENTER_TO_ANKLE_LENGTH
            sub ebx,PERSON_HEAD_RADIUS
            sub ebx,PERSON_TRUNK_LENGTH
            mov ecx,DYING_DIRECTION_RIGHT_HEAD_TO_FOOT_DEGREE
            INVOKE CalcX,ecx,ebx,eax
            mov waistpointx,eax

            mov eax,tmpheadcenter_y
            mov ebx,PERSON_HEAD_CENTER_TO_ANKLE_LENGTH
            add eax,ebx
            sub ebx,PERSON_HEAD_RADIUS
            sub ebx,PERSON_TRUNK_LENGTH
            mov ecx,DYING_DIRECTION_RIGHT_HEAD_TO_FOOT_DEGREE
            INVOKE CalcY,ecx,ebx,eax
            mov waistpointy,eax

            mov eax,DYING_DIRECTION_RIGHT_BODY_TO_HEAD_DEGREE
            mov trunkdegree,eax
            mov armrightdegree,eax
            mov armleftdegree,eax
            mov legleftdegree,eax
            mov legrightdegree,eax

            mov eax,DYING_SPEED
            mov armspeed,eax
            mov legspeed,eax
       .ENDIF
    .ELSE ; alive == DEAD
        mov eax,headcenter_x
        .IF direction == DIRECTION_LEFT
            sub eax,PERSON_HEAD_CENTER_TO_ANKLE_LENGTH
            mov headcenter_x,eax
            add eax,PERSON_HEAD_RADIUS
            mov neckpointx,eax
            add eax,PERSON_TRUNK_LENGTH
            mov waistpointx,eax
        .ELSE
            add eax,PERSON_HEAD_CENTER_TO_ANKLE_LENGTH
            mov headcenter_x,eax
            sub eax,PERSON_HEAD_RADIUS
            mov neckpointx,eax
            sub eax,PERSON_TRUNK_LENGTH
            mov waistpointx,eax
        .ENDIF

        mov eax,headcenter_y
        add eax,PERSON_HEAD_CENTER_TO_ANKLE_LENGTH
        mov headcenter_y,eax
        mov neckpointy,eax
        mov waistpointy,eax
        
        .IF direction == DIRECTION_LEFT
            mov eax,DEAD_DIRECTION_LEFT_BODY_DEGREE
            mov trunkdegree,eax
            mov armleftdegree,eax
            mov armrightdegree,eax
            mov legleftdegree,eax
            mov legrightdegree,eax
        .ELSE
            mov eax,DEAD_DIRECTION_RIGHT_BODY_DEGREE
            mov trunkdegree,eax
            mov armleftdegree,eax
            mov armrightdegree,eax
            mov legleftdegree,eax
            mov legrightdegree,eax
        .ENDIF

        mov eax,DEAD_SPEED
        mov armspeed,eax
        mov legspeed,eax
    .ENDIF

    .IF alive == DEAD
        INVOKE DrawDeadBlood,hdcbuffer,headcenter_x,headcenter_y
    .ENDIF

    INVOKE DrawHead,hdcbuffer,headcenter_x,headcenter_y
    INVOKE DrawTrunk,hdcbuffer,neckpointx,neckpointy,trunkdegree

    INVOKE DrawArm,hdcbuffer,neckpointx,neckpointy,armleftdegree,armspeed,ROTATE_DIRECTION_ANTICLOCKWISE
    INVOKE DrawArm,hdcbuffer,neckpointx,neckpointy,armrightdegree,armspeed,ROTATE_DIRECTION_CLOCKWISE

    INVOKE DrawLeg,hdcbuffer,waistpointx,waistpointy,legleftdegree,legspeed,ROTATE_DIRECTION_CLOCKWISE,direction
    INVOKE DrawLeg,hdcbuffer,waistpointx,waistpointy,legrightdegree,legspeed,ROTATE_DIRECTION_ANTICLOCKWISE,direction
    
    .IF hasGUN == HAS_GUN
        INVOKE DrawRifle,hdcbuffer,headcenter_x,headcenter_y,direction
    .ENDIF
    
    .IF alive == DYING
        INVOKE DrawShootBlood,hdcbuffer,headcenter_x,headcenter_y
    .ENDIF

    ret
DrawPerson ENDP

DrawShootBlood PROC USES eax ebx ecx,hdcbuffer:HDC, x:DWORD, y:DWORD
    LOCAL holdpen:HPEN,hredpen:HPEN,hredbrush:HBRUSH,blood_red:DWORD,tmpX:DWORD,tmpY:DWORD,
    tmpX1:DWORD,tmpY1:DWORD,bloodlength:DWORD,blooddegree:DWORD
    INVOKE SetBkMode,hdcbuffer,TRANSPARENT
    RGB 0CDh, 000h, 000h
    mov blood_red,eax
    INVOKE CreatePen,PS_DOT,BLOOD_WIDTH,blood_red
    mov hredpen,eax
    INVOKE CreateSolidBrush,blood_red
    mov hredbrush,eax
    INVOKE SelectObject,hdcbuffer,hredpen
    mov holdpen,eax
    
    mov eax,BLOOD_LENGTH
    mov bloodlength,eax
    
    mov ecx,BLOOD_LINE_NUM
    mov eax,BLOOD_LINE_DEGREE
    mov blooddegree,eax
    
Ldrawblood:
    pusha
    mov ebx,BLOOD_LINE_INTERVAL
    sub blooddegree,ebx
    INVOKE CalcX,blooddegree,bloodlength,x
    mov tmpX,eax
    INVOKE CalcY,blooddegree,bloodlength,y
    mov tmpY,eax
    INVOKE MoveToEx,hdcbuffer,x,y,NULL
    INVOKE LineTo,hdcbuffer,tmpX,tmpY
    popa
    LOOP Ldrawblood

    INVOKE SelectObject,hdcbuffer,holdpen
    INVOKE DeleteObject,hredpen
    ret
DrawShootBlood ENDP

DrawDeadBlood PROC USES eax ebx ecx,hdcbuffer:HDC, x:DWORD, y:DWORD
    LOCAL holdpen:HPEN,hredpen:HPEN,hredbrush:HBRUSH,blood_red:DWORD,tmpX:DWORD,tmpY:DWORD,
    tmpX1:DWORD,tmpY1:DWORD,bloodlength:DWORD,blooddegree:DWORD
    INVOKE SetBkMode,hdcbuffer,TRANSPARENT
    RGB 0CDh, 000h, 000h
    mov blood_red,eax
    INVOKE CreatePen,PS_DOT,BLOOD_WIDTH,blood_red
    mov hredpen,eax
    INVOKE CreateSolidBrush,blood_red
    mov hredbrush,eax
    INVOKE SelectObject,hdcbuffer,hredpen
    mov holdpen,eax
    
    mov eax,BLOOD_LENGTH
    mov bloodlength,eax
    
    mov ecx,BLOOD_LINE_NUM
    mov eax,BLOOD_LINE_DEGREE
    mov blooddegree,eax
    
Ldrawblood:
    pusha
    mov ebx,BLOOD_LINE_INTERVAL
    sub blooddegree,ebx
    INVOKE CalcX,blooddegree,bloodlength,x
    mov tmpX,eax
    INVOKE CalcY,blooddegree,bloodlength,y
    mov tmpY,eax
    INVOKE MoveToEx,hdcbuffer,x,y,NULL
    INVOKE LineTo,hdcbuffer,tmpX,tmpY
    popa
    LOOP Ldrawblood
    
    INVOKE SelectObject,hdcbuffer,hredbrush
    mov eax,x
    sub eax,BLOOD_POOL_MAJOR_HALF_AXIS
    mov tmpX,eax
    add eax,BLOOD_POOL_MAJOR_AXIS
    mov tmpX1,eax

    mov eax,y
    sub eax,BLOOD_POOL_MINOR_HALF_AXIS
    mov tmpY,eax
    add eax,BLOOD_POOL_MINOR_AXIS
    mov tmpY1,eax

    INVOKE Ellipse,hdcbuffer,tmpX,tmpY,tmpX1,tmpY1

    INVOKE SelectObject,hdcbuffer,holdpen
    INVOKE DeleteObject,hredpen
    INVOKE DeleteObject,hredbrush
    ret
DrawDeadBlood ENDP
; x: headcenter_x, y: headcenter_y: direction: DIRECTION_LEFT or DIRECTION_RIGHT
DrawRifle PROC USES eax edx, hdcbuffer: HDC, x: LONG, y: LONG, direction: SDWORD
	LOCAL hThickPen: HPEN, oldPen: HPEN, hThinPen: HPEN, hMediumPen: HPEN
	
	RGB 128, 0, 0
	INVOKE CreatePen, PS_SOLID, 4, eax
	mov hThickPen, eax
	RGB 128, 0, 0
	INVOKE CreatePen, PS_SOLID, 2, eax
	mov hThinPen, eax
	RGB 128, 0, 0
	INVOKE CreatePen, PS_SOLID, 3, eax
	mov hMediumPen, eax
	
	INVOKE SelectObject, hdcbuffer, hThickPen
	mov oldPen, eax
	
	mov eax, x
	.IF direction == DIRECTION_LEFT
		sub eax, 5
	.ELSE
		add eax, 5
	.ENDIF
	mov edx, y
	add edx, 5
	mov x, eax
	mov y, edx
	
	INVOKE MoveToEx, hdcbuffer, x, y, NULL
	mov eax, x
	.IF direction == DIRECTION_LEFT
		add eax, 5
	.ELSE
		sub eax, 5
	.ENDIF
	mov edx, y
	add edx, 10
	INVOKE LineTo, hdcbuffer, eax, edx

	INVOKE SelectObject, hdcbuffer, hMediumPen

	mov eax, x
	.IF direction == DIRECTION_LEFT
		add eax, 3
	.ELSE
		sub eax, 3
	.ENDIF
	mov edx, y
	add edx, 6
	INVOKE MoveToEx, hdcbuffer, eax, edx, NULL
	mov eax, x
	.IF direction == DIRECTION_LEFT
		sub eax, 6
	.ELSE
		add eax, 6
	.ENDIF
	mov edx, y
	add edx, 6
	INVOKE LineTo, hdcbuffer, eax, edx

	INVOKE SelectObject, hdcbuffer, hThinPen
	
	mov eax, x
	.IF direction == DIRECTION_LEFT
		add eax, 5
	.ELSE
		sub eax, 5
	.ENDIF
	mov edx, y
	add edx, 10
	INVOKE MoveToEx, hdcbuffer, eax, edx, NULL
	mov eax, x
	.IF direction == DIRECTION_LEFT
		sub eax, 1
	.ELSE
		add eax, 1
	.ENDIF
	mov edx, y
	add edx, 13
	INVOKE LineTo, hdcbuffer, eax, edx
	
	INVOKE SelectObject, hdcbuffer, oldPen
	INVOKE DeleteObject, hThickPen
	INVOKE DeleteObject, hThinPen
	INVOKE DeleteObject, hMediumPen

	ret
DrawRifle ENDP

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

DrawLeg PROC,hdcbuffer:HDC,legtop_x:DWORD,legtop_y:DWORD,degree:DWORD,legspeed:DWORD,legRotateDirection:DWORD, direction:SDWORD
    LOCAL anklex:DWORD, ankley:DWORD, leg_degree:DWORD, foot_direction:DWORD
    
    .IF direction == DIRECTION_LEFT
        mov eax, STAND_FOOT_DIRECTION_LEFT
    .ELSE
        mov eax, STAND_FOOT_DIRECTION_RIGHT
    .ENDIF
    mov foot_direction, eax

    .IF legspeed == 0
        INVOKE DrawDegreeLine,hdcbuffer,legtop_x,legtop_y,PERSON_LEG_LENGTH,PERSON_LEG_WIDTH,degree

        INVOKE CalcX, degree,PERSON_LEG_LENGTH,legtop_x
        mov anklex, eax
        INVOKE CalcY, degree,PERSON_LEG_LENGTH,legtop_y
        mov ankley, eax
        INVOKE DrawFoot,hdcbuffer,anklex,ankley,foot_direction
    .ELSE
        INVOKE DrawRotateLine,hdcbuffer,legtop_x,legtop_y,PERSON_LEG_LENGTH,PERSON_LEG_WIDTH,degree,legspeed,legRotateDirection

        mov leg_degree, eax
        INVOKE CalcX, leg_degree,PERSON_LEG_LENGTH,legtop_x
        mov anklex, eax
        INVOKE CalcY, leg_degree,PERSON_LEG_LENGTH,legtop_y
        mov ankley, eax
        INVOKE DrawFoot,hdcbuffer,anklex,ankley,foot_direction

    .ENDIF
    ret
DrawLeg ENDP

DrawFoot PROC,hdcbuffer:HDC,foottop_x:DWORD,foottop_y:DWORD,degree:DWORD
    
    INVOKE DrawDegreeLine,hdcbuffer,foottop_x,foottop_y,PERSON_FOOT_LENGTH,PERSON_FOOT_WIDTH,degree

    ret
DrawFoot ENDP

;return eax value degree
DrawRotateLine PROC USES ebx,hdcbuffer:HDC,centerX:DWORD,centerY:DWORD,radius:DWORD,linewidth:DWORD,startdegree:DWORD,rotateCoefficient:DWORD, rotateDirection:DWORD
    LOCAL stTime:SYSTEMTIME, rotateRange:DWORD, DrotateRange:DWORD

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