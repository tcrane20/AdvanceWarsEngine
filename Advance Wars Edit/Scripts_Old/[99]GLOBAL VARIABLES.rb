#===============================================================================
# Constants - For purposes of making variables easier to read
#===============================================================================
#====================#
# Terrain            #
#====================#
TILE_PLAINS     = 0
TILE_ROAD       = 1
TILE_WOODS      = 2
TILE_SEA        = 3
TILE_MOUNTAINS  = 4
TILE_RIVER      = 5
TILE_REEF       = 6
TILE_SHOAL      = 7
TILE_PIPE       = 8

TILE_CITY       = 9
TILE_FACTORY    = 10
TILE_AIRPORT    = 11
TILE_SEAPORT    = 12
TILE_SILO       = 13
TILE_COMTOWER   = 14
TILE_HQ         = 15

TILE_JOINT      = 16
#====================#
# Move Type          #
#====================#
MOVE_FOOT       = 0           # Infantry
MOVE_MECH       = 1           # Mech Infantry
MOVE_TIRE       = 2
MOVE_TREAD      = 3
MOVE_AIR        = 4
MOVE_TRANS      = 5           # Lander only
MOVE_SEA        = 6
MOVE_TIRE_B      = 7

TOTAL_MOVETYPES = 8
#====================#
# Unit Type          #
#====================#
INF             = 0           # Infantry
MEC             = 1           # Mech
RCN             = 2           # Recon
APC             = 3           # APC
ART             = 4           # Artillery
TNK             = 5           # Tank
AAR             = 6           # Anti-Air
MIS             = 7           # Missile
RKT             = 8           # Rockets
MTK             = 9           # Medium Tank
NEO             = 10          # Neotank
TCP             = 11          # Transport Copter
BCP             = 12          # Battle Copter
FTR             = 13          # Fighter
BMR             = 14          # Bomber
LND             = 15          # Lander
CRS             = 16          # Cruiser
SUB             = 17          # Submarine
BSP             = 18          # Battleship
MEG              = 19
CAR              = 20
STH              = 21
DST              = 22
ZEP              = 23
BIK              = 24
ATK              = 25

#====================#
# Unit Groups        #
#====================#
INFANTRY   = [INF, MEC, BIK]
VEHICLE    = [RCN, APC, ART, TNK, AAR, MIS, RKT, MTK, NEO, MEG, ATK]
LAND       = INFANTRY + VEHICLE
COPTER     = [TCP, BCP]
PLANE       = [ZEP, FTR, BMR, STH]
AIR         = COPTER + PLANE
SEA         = [LND, CRS, SUB, BSP, CAR, DST]

TRANSPORT  = [APC, LND, TCP]
TANK      = [TNK, MTK, NEO, MEG]

#==========================#
# General Constants        #
#==========================#
DMG_WINDOW = 0
DMG_RESULT = 1
DMG_AI     = 2

PRIMARY   = 1
SECONDARY = 2

TOTLuck = 0
POSLuck = 1
NEGLuck = 2

MSG_IDLE = 0
MSG_RUN  = 1
MSG_DRAW = 2
MSG_WAIT = 3
MSG_SWAP = 4

WEATHER_NONE = 0
WEATHER_SNOW = 1
WEATHER_RAIN = 2
WEATHER_SAND = 3

WAIT_CURSOR_POWER     = -1
WAIT_CURSOR_ANIMATION = -2
WAIT_UNIT_POWER       = -3
WAIT_UNIT_ANIMATION   = -4
#===============================================================================
# Global Variables - Can be accessed and changed anywhere!!
#===============================================================================
$CO = []
$UNITS = []
$MESSAGES = []
#$TRANSITION = nil




