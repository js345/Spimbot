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
.align 2
cloud_data: .space 40
.align 2
plant_data: .space 88
.align 2
plant_done: .space 4

.text
main:
	# go wild
	# the world is your oyster :)
	li	$t4, CLOUD_CHANGE_STATUS_INT_MASK	# cloud change status enable bit
	or  $t4, $t4, PLANT_FULLY_WATERED_INT_MASK
	or	$t4, $t4, BONK_MASK
	or	$t4, $t4, OUT_OF_WATER_INT_MASK
	or	$t4, $t4, 1							# global interrupt enable
	mtc0	$t4, $12						# set interrupt mask (Status register)

	li	$t4, 10								# t4 = velocity = 10
	li	$t6, 1								# t6 = 1 angle control

	li	$t5, 150							# load target starting y
	# load index a0 = index, index < 3
	li  $a0, 0
	li  $a1, 0

start_loop:
	li	$t7, 90								# down
	sw	$t7, ANGLE($zero)					# set angle down
	sw	$t6, ANGLE_CONTROL($zero)
	sw	$t4, VELOCITY($zero)				# set velocity
	lw	$t3, BOT_Y($zero)					# t3 = bot_y
	ble	$t3, $t5, start_loop				# while (bot_y != target)

cloud:
	la	$t0, cloud_data						# load cloud data
	sw	$t0, CLOUD_SCAN						# fill
	# load cloud location
	mul	$a1, $a0, 12
	add	$t0, $t0, $a1						# iterator
	lw	$t1, 8($t0)							# t1 = cloud1_x
	lw	$t2, 12($t0)						# t2 = cloud1_y
	la	$t0, plant_data
	sw	$t0, PLANT_SCAN
	mul	$a1, $a0, 8
	add $t0, $t0, $a1						# iterator
	lw	$t3, 4($t0)
	beq	$t3, $t1, end						# not watered yet

find_loop:
	lw	$t3, BOT_X($zero)					# t3 = bot_x
	beq	$t1, $t3, pause						# while bot_x != cloud1_x
	ble	$t1, $t3, set_left					# if (cloud1_x <= bot_x)
set_right:
	li	$t7, 0								# right
	sw	$t7, ANGLE($zero)					# set angle right
	sw	$t6, ANGLE_CONTROL($zero)
	j	find_loop
set_left:
	li	$t7, 180							# left
	sw	$t7, ANGLE($zero)					# set angle left
	sw	$t6, ANGLE_CONTROL($zero)
	j	find_loop

pause:
	lw	$t3, BOT_Y($zero)					# t3 = bot_y
	beq	$t2, $t3, wait						# while bot_y != cloud1_y
	sw	$t4, VELOCITY($zero)
	ble	$t2, $t3, set_down					# if (cloud1_y <= bot_y)
set_up:
	li	$t7, 90								# up
	sw	$t7, ANGLE($zero)					# set angle up
	sw	$t6, ANGLE_CONTROL($zero)
	j	pause								# wait for interrupt
set_down:
	li	$t7, 270							# down
	sw	$t7, ANGLE($zero)					# set angle down
	sw	$t6, ANGLE_CONTROL($zero)
	j 	pause

wait:
	la	$t0, plant_data
	sw	$t0, PLANT_SCAN
	mul	$a1, $a0, 8
	add $t0, $t0, $a1						# iterator
	lw	$t1, 4($t0)							# t1 = plant1_x

find_plant:
	lw	$t3, BOT_X($zero)					# t3 = bot_x
	beq	$t1, $t3, end						# while bot_x != cloud1_x
	sw	$t4, VELOCITY($zero)
	ble	$t1, $t3, turn_left					# if (cloud1_x <= bot_x)
turn_right:
	li	$t7, 0								# right
	sw	$t7, ANGLE($zero)					# set angle right
	sw	$t6, ANGLE_CONTROL($zero)
	j	find_plant
turn_left:
	li	$t7, 180							# left
	sw	$t7, ANGLE($zero)					# set angle left
	sw	$t6, ANGLE_CONTROL($zero)
	j	find_plant

end:
	add	$a0, $a0, 1							# index++
	blt	$a0, 3, skip
	li	$t7, 270							# turn up
	sw	$t7, ANGLE($zero)
	sw	$t6, ANGLE_CONTROL($zero)
	sw	$t4, VELOCITY($zero)
	li	$a0, 0								# reset a0
	li	$a2, 0
	j	infinite
skip:
	j start_loop

infinite:
	# note that we infinite loop to avoid stopping the simulation early
	beq	$a2, 1, skip						# if fully watered, find next one
	j	infinite


.kdata				# interrupt handler data (separated just for readability)
chunkIH:	.space 8	# space for two registers
non_intrpt_str:	.asciiz "Non-interrupt exception\n"
unhandled_str:	.asciiz "Unhandled interrupt type\n"


.ktext 0x80000180
interrupt_handler:
.set noat
	move	$k1, $at						# Save $at
.set at
	la	$k0, chunkIH
	sw	$a0, 0($k0)							# Get some free registers
	sw	$a1, 4($k0)							# by storing them to a global variable

	mfc0	$k0, $13						# Get Cause register
	srl	$a0, $k0, 2
	and	$a0, $a0, 0xf						# ExcCode field
	bne	$a0, 0, non_intrpt

interrupt_dispatch:							# Interrupt:
	mfc0	$k0, $13						# Get Cause register, again
	beq	$k0, 0, done						# handled all outstanding interrupts

	and	$a0, $k0, CLOUD_CHANGE_STATUS_INT_MASK	#  cloud interrupt?
	bne	$a0, 0, cloud_interrupt

	and	$a0, $k0, PLANT_FULLY_WATERED_INT_MASK	# 	fully watered?
	bne	$a0, 0, plant_interrupt

	# add dispatch for other interrupt types here.

	li	$v0, PRINT_STRING					# Unhandled interrupt types
	la	$a0, unhandled_str
	syscall
	j	done

cloud_interrupt:
	sw	$a1, CLOUD_CHANGE_STATUS_ACK		# ack
	j	interrupt_dispatch

plant_interrupt:
	li  $a2, 1
	sw  $a1, PLANT_FULLY_WATERED_ACK		# ack
	j   interrupt_dispatch

bonk_interrupt:
	sw	$a1, BONK_ACK
	j	interrupt_dispatch

out_interrupt:
	sw	$a1, OUT_OF_WATER_ACK
	j	interrupt_dispatch

non_intrpt:									# was some non-interrupt
	li	$v0, PRINT_STRING
	la	$a0, non_intrpt_str
	syscall									# print out an error message
	# fall through to done


done:
	la	$k0, chunkIH
	lw	$a0, 0($k0)							# Restore saved registers
	lw	$a1, 4($k0)
.set noat
	move	$at, $k1						# Restore $at
.set at
	eret
