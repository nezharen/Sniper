DEAD            equ 0
DYING           equ 1
ALIVE           equ 2
STATE_RUNNING   equ 0
STATE_FAILED    equ 1
STATE_SUCCESS   equ 2
SPEED_NULL      equ 0
SPEED_WALK      equ 1
SPEED_RUN       equ 2
DIRECTION_LEFT  equ -1
DIRECTION_RIGHT equ 1
NO_GUN          equ 0
HAS_GUN         equ 1
ID_TIMER        equ 1
ID_ICON_MAIN    equ 1
ID_BMP_CURSOR   equ 2
ID_BMP_START    equ 3
ID_BMP_SNIPER   equ 4

Person STRUCT
     alive     BYTE   1
     position  POINT  <>
     speed     DWORD  0
     direction SDWORD 0
     hasGun    BYTE   0
     lpProc    DWORD  NULL
Person ENDS
