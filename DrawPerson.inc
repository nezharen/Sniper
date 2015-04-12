DrawStandPerson PROTO, hdcbuffer:HDC, headcenter_x:DWORD, headcenter_y:DWORD, direction:DWORD
DrawHead PROTO,hdcbuffer:HDC,headcenter_X:DWORD,headcenter_Y:DWORD
DrawTrunk PROTO,hdcbuffer:HDC,trunktop_X:DWORD,trunktop_Y:DWORD,degree:DWORD
DrawArm PROTO,hdcbuffer:HDC,armtop_x:DWORD,armtop_y:DWORD,degree:DWORD,armspeed:DWORD,armRotateDirection:DWORD
DrawLeg PROTO,hdcbuffer:HDC,legtop_x:DWORD,legtop_y:DWORD,degree:DWORD,legspeed:DWORD,legRotateDirection:DWORD, direction:DWORD
DrawFoot PROTO,hdcbuffer:HDC,foottop_x:DWORD,foottop_y:DWORD,degree:DWORD
DrawDegreeLine PROTO,hdcbuffer:HDC,centerX:DWORD,centerY:DWORD,radius:DWORD,linewidth:DWORD,degree:DWORD
DrawRotateLine PROTO,hdcbuffer:HDC,centerX:DWORD,centerY:DWORD,radius:DWORD,linewidth:DWORD,startdegree:DWORD,rotatespeed:DWORD, rotateDirection:DWORD
CalcX PROTO,dwDegree:DWORD,dwRadius:DWORD,dwCenterX:DWORD
CalcY PROTO,dwDegree:DWORD,dwRadius:DWORD,dwCenterY:DWORD

PERSON_HEAD_RADIUS equ 5
PERSON_TRUNK_LENGTH equ 10
PERSON_TRUNK_WIDTH equ 4
PERSON_ARM_LENGTH equ 10
PERSON_ARM_WIDTH equ 4
PERSON_LEG_LENGTH equ 15
PERSON_LEG_WIDTH equ 4
PERSON_FOOT_LENGTH equ 3
PERSON_FOOT_WIDTH equ 3

STAND_TRUNK_DEGREE equ 180
STAND_LEG_RIGHT_DEGREE equ 170
STAND_LEG_LEFT_DEGREE equ 200
STAND_FOOT_DIRECTION_LEFT equ 270
STAND_FOOT_DIRECTION_RIGHT equ 90

STAND_ARM_LEFT_STATIC_DEGREE equ 210
STAND_ARM_RIGHT_STATIC_DEGREE equ 150

STAND_ARM_MOVE_PERIOD equ 1 ;右胳膊每隔几秒钟动一次

;画面20ms刷新一次，毫秒范围0-999，推测refresh_period为20的倍数看起来可能更流畅。1000/20=50
REFRESH_PERIOD equ 40
REFRESH_HALF_FRAME equ 25
REFRESH_FRAME equ 50

ROTATE_LINE_SPEED_ONE equ 2 ; for normal speed
ROTATE_LINE_SPEED_TWO equ 6 ; for high speed
ROTATE_DIRECTION_NULL equ 0
ROTATE_DIRECTION_CLOCKWISE equ 1
ROTATE_DIRECTION_ANTICLOCKWISE equ 2
