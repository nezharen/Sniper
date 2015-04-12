DrawStandPerson PROTO, hdcbuffer:HDC, headcenter_x:DWORD, headcenter_y:DWORD
DrawHead PROTO,hdcbuffer:HDC,headcenter_X:DWORD,headcenter_Y:DWORD
DrawTrunk PROTO,hdcbuffer:HDC,trunktop_X:DWORD,trunktop_Y:DWORD,degree:DWORD
DrawArm PROTO,hdcbuffer:HDC,armtop_x:DWORD,armtop_y:DWORD,degree:DWORD,armtype:DWORD
DrawLeg PROTO,hdcbuffer:HDC,legtop_x:DWORD,legtop_y:DWORD,degree:DWORD
DrawFoot PROTO,hdcbuffer:HDC,foottop_x:DWORD,foottop_y:DWORD,degree:DWORD
DrawDegreeLine PROTO,hdcbuffer:HDC,centerX:DWORD,centerY:DWORD,radius:DWORD,linewidth:DWORD,degree:DWORD
DrawRotateLine PROTO,hdcbuffer:HDC,centerX:DWORD,centerY:DWORD,radius:DWORD,linewidth:DWORD,startdegree:DWORD,rotatespeed:DWORD
CalcX PROTO,dwDegree:DWORD,dwRadius:DWORD,dwCenterX:DWORD
CalcY PROTO,dwDegree:DWORD,dwRadius:DWORD,dwCenterY:DWORD

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

STAND_ARM_MOVE_PERIOD equ 1 ;右胳膊每隔几秒钟动一次
STAND_ARM_MOVE_DEGREE_RANGE equ 20 ;胳膊的幅度

REFRESH_PERIOD equ 20
REFRESH_HALF_FRAME equ 25
REFRESH_FRAME equ 50

ROTATE_LINE_SPEED_ONE equ 2 ; for normal speed
ROTATE_LINE_SPEED_TWO equ 6 ; for high speed