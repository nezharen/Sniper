DEAD            equ 0
DYING           equ 1
ALIVE           equ 2
STATE_RUNNING   equ 0
STATE_FAILED    equ 1
STATE_SUCCESS   equ 2
SPEED_NULL      equ 0
SPEED_WALK      equ 1
SPEED_RUN       equ 3
DIRECTION_LEFT  equ -1
DIRECTION_RIGHT equ 1
NO_GUN          equ 0
HAS_GUN         equ 1
ID_TIMER        equ 1
ID_ICON_MAIN    equ 1
DYING_TIME      equ 1

Person STRUCT
     alive     BYTE   ALIVE
     position  POINT  <0, 0>
     speed     DWORD  SPEED_NULL
     direction SDWORD DIRECTION_RIGHT
     hasGun    BYTE   NO_GUN
     lastTime  BYTE   DYING_TIME
     lpProc    DWORD  NULL
Person ENDS
