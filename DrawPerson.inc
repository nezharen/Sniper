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