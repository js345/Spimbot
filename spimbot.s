# syscall constants
PRINT_STRING = 4
PRINT_CHAR   = 11
PRINT_INT    = 1

# debug constants
PRINT_INT_ADDR   = 0xffff0080
PRINT_FLOAT_ADDR = 0xffff0084
PRINT_HEX_ADDR   = 0xffff0088

# spimbot constants
VELOCITY       = 0xffff0010
ANGLE          = 0xffff0014
ANGLE_CONTROL  = 0xffff0018
BOT_X          = 0xffff0020
BOT_Y          = 0xffff0024
OTHER_BOT_X    = 0xffff00a0
OTHER_BOT_Y    = 0xffff00a4
TIMER          = 0xffff001c
SCORES_REQUEST = 0xffff1018

PLANT_SCAN            = 0xffff0050
CLOUD_SCAN            = 0xffff0054
CLOUD_STATUS_INFO     = 0xffff00c0
GET_WATER             = 0xffff00c8
WATER_VALVE           = 0xffff00c4
REQUEST_PUZZLE        = 0xffff00d0
REQUEST_PUZZLE_STRING = 0xffff00dc
SUBMIT_SOLUTION       = 0xffff00d4

# interrupts constants
BONK_MASK  = 0x1000
BONK_ACK   = 0xffff0060
TIMER_MASK = 0x8000
TIMER_ACK  = 0xffff006c

CLOUD_CHANGE_STATUS_ACK      = 0xffff0064
CLOUD_CHANGE_STATUS_INT_MASK = 0x2000
OUT_OF_WATER_ACK             = 0xffff0068
OUT_OF_WATER_INT_MASK        = 0x4000
PLANT_FULLY_WATERED_ACK      = 0xffff0058
PLANT_FULLY_WATERED_INT_MASK = 0x400
REQUEST_PUZZLE_ACK           = 0xffff00d8
REQUEST_PUZZLE_INT_MASK      = 0x800

.data
# data things go here

.text
main:
	# go wild
	# the world is your oyster :)
	j	main
