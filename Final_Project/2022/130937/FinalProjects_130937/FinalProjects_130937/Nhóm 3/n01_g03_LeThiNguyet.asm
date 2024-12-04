# eqv for Digital Lab Sim
.eqv	KEY_0 0x11	
.eqv	KEY_1 0x21
.eqv	KEY_2 0x41
.eqv	KEY_3 0x81
.eqv	KEY_4 0x12
.eqv	KEY_5 0x22
.eqv	KEY_6 0x42
.eqv	KEY_7 0x82
.eqv	KEY_8 0x14
.eqv	KEY_9 0x24
.eqv	KEY_a 0x44
.eqv	KEY_b 0x84
.eqv	KEY_c 0x18
.eqv	KEY_d 0x28
.eqv	KEY_e 0x48
.eqv	KEY_f 0x88

# eqv for Keyboard
.eqv	IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv	OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv	KEY_CODE 0xFFFF0004	# ASCII code from keyboard, 1 byte
.eqv	KEY_READY 0xFFFF0000	# = 1 if has a new keycode ?
				# Auto clear after lw

# eqv for Mars bot
.eqv	HEADING 0xffff8010	# Integer: An angle between 0 and 359
			# 0 : North (up)
			# 90: East (right)
			# 180: South (down)
			# 270: West (left)
.eqv	MOVING 0xffff8050	# Boolean: whether or not to move
.eqv	LEAVETRACK 0xffff8020	# Boolean: whether or not to leave a track
.eqv	WHEREX 0xffff8030	# Integer: Current x-location of MarsBot
.eqv	WHEREY 0xffff8040	# Integer: Current y-location of MarsBot

#-------------------------------------------------------------------------------
.data
	x_history:		.word 0 : 16	
	y_history:		.word 0 : 16	
	a_history:		.word 0 : 16
	l_history:		.word 4		# history length

	a_current:		.word 0		# current alpha
	
	isGoing:		.word 0
	isTracking:		.word 0

	cmdCode:		.space 8	# input command code
	code_history: 		.space 8 	# history code
	cmdLen:			.word 0		# input command length

	MOVE_CODE:		.asciiz "1b4"	# command code
	STOP_CODE:		.asciiz "c68"
	TURN_LEFT_CODE:		.asciiz "444"
	TURN_RIGHT_CODE:	.asciiz "666"
	TRACK_CODE:		.asciiz "dad"
	UNTRACK_CODE:		.asciiz "cbc"
	GOBACKWARD_CODE:	.asciiz "999"
	
	invalidCmd_msg:		.asciiz "Invalid command code: "

#-------------------------------------------------------------------------------
.text	
main:	li $k0, KEY_CODE
 	li $k1, KEY_READY
 	
	li $t1, IN_ADRESS_HEXA_KEYBOARD	# enable the interrupt of Digital Lab Sim
	li $t3, 0x80			# bit 7 = 1 to enable
	sb $t3, 0($t1)
		
setStartHeading: 
	lw	$t7, l_history		# l_history += 4
	addi	$t7, $zero, 4		# to save x = 0; y = 0; a = 90
	sw	$t7, l_history
	
	li	$t7, 90
	sw	$t7, a_current	# a_current = 90 -> heading down
	jal	ROTATE
	nop
	
	sw	$t7, a_history + 4	# a_history[1] = 90
					# x_history[1] =0
					# y_history[1] = 0
	j	waitForKey

printErrorMsg: 
	li	$v0, 4
	la	$a0, invalidCmd_msg
	syscall
		
printCmd:	
	li	$v0, 4
	la	$a0, cmdCode
	syscall
	
resetInput:	
	jal	strClear			
	nop						

waitForKey:	
	lw	$t5, 0($k1)			# $t5 = [$k1] = KEY_READY
	beq	$t5, $zero, waitForKey		# if $t5 == 0 -> Polling 
	nop
	beq	$t5, $zero, waitForKey
readKey:	
	lw	$t6, 0($k0)			# $t6 = [$k0] = KEY_CODE
	beq	$t6, 0x7f , resetInput		# if $t6 == 'DEL' -> reset input
	beq 	$t6,0x20,copy_code_history	# if $t6 =='SPACE' -> recontrol
	bne	$t6, 0x0a, waitForKey		# if $t6 != '\n' -> Polling
	nop
	bne	$t6, 0x0a, waitForKey
checkCmd:	
	lw	$s2, cmdLen			# cmdLen != 3 -> invalid cmd
	bne	$s2, 3, printErrorMsg
		
	la	$s3, MOVE_CODE
	jal	strcmp
	beq	$t0, 1, case_go
		
	la	$s3, STOP_CODE
	jal	strcmp
	beq	$t0, 1, case_stop
		
	la	$s3, TURN_LEFT_CODE
	jal	strcmp
	beq	$t0, 1, case_turnLeft
	
	la	$s3, TURN_RIGHT_CODE
	jal	strcmp
	beq	$t0, 1, case_turnRight
	
	la	$s3, TRACK_CODE
	jal	strcmp
	beq	$t0, 1, case_track

	la	$s3, UNTRACK_CODE
	jal	strcmp
	beq	$t0, 1, case_untrack
	
	la	$s3, GOBACKWARD_CODE
	jal	strcmp
	beq	$t0, 1, goBackward
	nop
	
	j	printErrorMsg
	
	switch:
	case_go:	jal save_code	
			j	go
	case_stop:	jal save_code
			j	stop
	case_turnLeft:	jal save_code
			j	turnLeft
	case_turnRight:	jal save_code
			j	turnRight
	case_track:	jal save_code
			j	track
	case_untrack:	jal save_code
			j	untrack
	case_goBackWard:jal save_code
			j	goBackward
	default:
	# j	printCmdCode

#-----------------------------------------------------------	
go: 	jal	GO
	j	printCmd
	
#-----------------------------------------------------------	
stop: 	jal	STOP
	j	printCmd

#-----------------------------------------------------------	
track: 	jal	TRACK
	j	printCmd
	
#-----------------------------------------------------------	
untrack:	jal	UNTRACK
	j	printCmd
		
#-----------------------------------------------------------	
turnRight:	
	lw	$t7, isGoing
	lw	$s0, isTracking
	
	jal	STOP
	nop
	jal	UNTRACK
	nop
	
	la	$s5, a_current
	lw	$s6, 0($s5)		# $s6 is heading at now
	addi	$s6, $s6, 90		# increase alpha by 90*
	sw	$s6, 0($s5)		# update a_current
	
	jal	saveHistory
	jal	ROTATE
	
	beqz	$s0, noTrack1
	nop
	jal	TRACK
	noTrack1:	nop
	
	beqz	$t7, noGo1
	nop
	jal	GO
	noGo1:	nop
	
	j	printCmd	
	
#-----------------------------------------------------------	
turnLeft:	
	lw	$t7, isGoing
	lw	$s0, isTracking
	
	jal	STOP
	nop
	jal	UNTRACK
	nop

	la	$s5, a_current
	lw	$s6, 0($s5)		# $s6 is heading at now
	addi	$s6, $s6, -90		# decrease alpha by 90*
	sw	$s6, 0($s5)		# update a_current
	
	jal	saveHistory
	jal	ROTATE
	
	beqz	$s0, noTrack2
	nop
	jal	TRACK
	noTrack2:	nop
	
	beqz	$t7, noGo2
	nop
	jal	GO
	noGo2:	nop
	
	j	printCmd	

#-----------------------------------------------------------	
goBackward:	
	li	$t7, IN_ADRESS_HEXA_KEYBOARD	# Disable interrupts when going backward
    	sb	$zero, 0($t7)

	lw	$s5, l_history			# $s5 = length history
	jal	UNTRACK
	jal	GO
	
goBackward_turn: 
	
	lw	$s6, a_history($s5)		# $s6 = a_history[l_history]
	addi	$s6, $s6, 180			# $s6 = the reverse direction of alpha
	sw	$s6, a_current
	jal	ROTATE
	nop
	
goBackward_toTurningPoint:
	lw	$t9, x_history($s5)		# $t9 = x_history[i]	
	get_x: 
	li	$t8, WHEREX		# $t8 = x_current
	lw	$t8, 0($t8)
	bne	$t8, $t9, get_x		# x_current == x_history[i]
	nop				# -> get y
	
	lw	$t9, y_history($s5)		# $t9 = y_history[i]
	get_Y: 
	li	$t8, WHEREY		# $t8 = y_current
	lw	$t8, 0($t8)
	bne	$t8, $t9, get_Y		# y_current == y_history[i]
	nop				# -> turn or end
	
	beq $s5, 4, goBackward_end	# l_history == 4
	nop				# -> end
	addi $s5, $s5, -4 		# l_history--
	j goBackward_turn		# else -> turn
	
goBackward_end: 
	jal	STOP
	sw	$zero, a_current		# update heading
	jal	ROTATE
	
	addi	$s5, $zero, 4
	sw	$s5, l_history		# reset l_history = 4
	
	j	printCmd
	
#-----------------------------------------------------------
# saveHistory()
#-----------------------------------------------------------
saveHistory:
	addi	$sp, $sp, 4			# backup
	sw	$t1, 0($sp)
	addi	$sp, $sp, 4
	sw	$t2, 0($sp)
	addi	$sp, $sp, 4
	sw	$t3, 0($sp)
	addi	$sp, $sp, 4
	sw	$t4, 0($sp)
	addi	$sp, $sp, 4
	sw	$s1, 0($sp)
	addi	$sp, $sp, 4
	sw	$s2, 0($sp)
	addi	$sp, $sp, 4
	sw	$s3, 0($sp)
	addi	$sp, $sp, 4
	sw	$s4, 0($sp)
	
	lw	$s1, WHEREX			# s1 = x	
	lw	$s2, WHEREY			# s2 = y
	lw	$s4, a_current		# s4 = a_current
	
	lw	$t3, l_history		# $t3 = l_history
	addi	$t3,$t3,4
	sw	$s1, x_history($t3)		# store: x, y, alpha
	sw	$s2, y_history($t3)
	sw	$s4, a_history($t3) 
	
	sw	$t3, l_history
	
	lw	$s4, 0($sp)			# restore backup
	addi	$sp, $sp, -4
	lw	$s3, 0($sp)
	addi	$sp, $sp, -4
	lw	$s2, 0($sp)
	addi	$sp, $sp, -4
	lw	$s1, 0($sp)
	addi	$sp, $sp, -4
	lw	$t4, 0($sp)
	addi	$sp, $sp, -4
	lw	$t3, 0($sp)
	addi	$sp, $sp, -4
	lw	$t2, 0($sp)
	addi	$sp, $sp, -4
	lw	$t1, 0($sp)
	addi	$sp, $sp, -4
	
saveHistory_end: jr	$ra		
save_code:	addi	$sp, $sp, 4 # back up
		sw	$t0, 0($sp)
		addi	$sp, $sp, 4
		sw	$t1, 0($sp)
		addi	$sp, $sp, 4
		sw	$t2, 0($sp)
		addi	$sp, $sp, 4
		sw	$t3, 0($sp)
		addi	$sp, $sp, 4
		sw	$s0, 0($sp)
		addi	$sp, $sp, 4
		sw	$s1, 0($sp)
		
		
		
		la $t0,cmdLen
		lw $t0,cmdLen
		la $s0, cmdCode
		la $s1, code_history
		li $t1,0		# i =0		
save_code_loop:
		add $t2, $s0,$t1
		lb $t2,0($t2) 		# $t2 = cmdcode[i]
		add $t3, $s1,$t1
		sb $t2,0($t3) 		# code_history[i] = cmdcode[i]
		beq $t1,$t0,end_save_code_loop
		add $t1,$t1,1
		j save_code_loop
end_save_code_loop:
	
	
	
	lw	$s1, 0($sp)			# restore backup
	addi	$sp, $sp, -4
	lw	$s0, 0($sp)
	addi	$sp, $sp, -4
	lw	$t3, 0($sp)
	addi	$sp, $sp, -4
	lw	$t2, 0($sp)
	addi	$sp, $sp, -4
	lw	$t1, 0($sp)
	addi	$sp, $sp, -4
	lw	$t0, 0($sp)
	addi	$sp, $sp, -4
 	jr $ra
copy_code_history:	addi	$sp, $sp, 4 # back up
		sw	$t0, 0($sp)
		addi	$sp, $sp, 4
		sw	$t1, 0($sp)
		addi	$sp, $sp, 4
		sw	$t2, 0($sp)
		addi	$sp, $sp, 4
		sw	$t3, 0($sp)
		addi	$sp, $sp, 4
		sw	$s0, 0($sp)
		addi	$sp, $sp, 4
		sw	$s1, 0($sp)
		
		
		la $s0, code_history
		lb $t0,0($s0)
		beq $t0,$0,waitForKey
		nop
		beq $t0,$0,waitForKey
		li $t0,3 
		sb $t0, cmdLen 
		la $s0, code_history
		la $s1, cmdCode 
		li $t1,0
		
		
copy_code_history_loop:	
		add $t2, $s0,$t1
		lb $t2,0($t2)
		add $t3, $s1,$t1
		sb $t2,0($t3)
		beq $t1,$t0,end_copy_code_history_loop
		add $t1,$t1,1
		j copy_code_history_loop
end_copy_code_history_loop:
	
	
	lw	$s1, 0($sp)			# restore backup
	addi	$sp, $sp, -4
	lw	$s0, 0($sp)
	addi	$sp, $sp, -4
	lw	$t3, 0($sp)
	addi	$sp, $sp, -4
	lw	$t2, 0($sp)
	addi	$sp, $sp, -4
	lw	$t1, 0($sp)
	addi	$sp, $sp, -4
	lw	$t0, 0($sp)
	addi	$sp, $sp, -4
 	j checkCmd
#===============================================================================
# Procedure for Mars bot
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# GO()
#-----------------------------------------------------------
GO: 	addi	$sp, $sp, 4			# backup
	sw	$at, 0($sp)
	addi	$sp, $sp, 4
	sw	$k0, 0($sp)

	li	$at, MOVING			# change MOVING port
 	addi	$k0, $zero, 1		# to logic 1,
	sb	$k0, 0($at)			# to start running
	
	li	$t7, 1			# isGoing = 0
	sw	$t7, isGoing		
		
	lw	$k0, 0($sp)			# restore back up
	addi	$sp, $sp, -4
	lw	$at, 0($sp)
	addi	$sp, $sp, -4
	
GO_end:	jr	$ra
	
#-----------------------------------------------------------
# STOP()
#-----------------------------------------------------------
STOP: 	addi	$sp, $sp, 4			# backup
	sw	$at, 0($sp)
	
	li	$at, MOVING			# change MOVING port to 0
	sb	$zero, 0($at)		# to stop
	
	sw	$zero, isGoing		# isGoing = 0
	
	lw	$at, 0($sp)			# restore back up
	addi	$sp, $sp, -4
	
STOP_end:	jr $ra
	
#-----------------------------------------------------------
# TRACK()
#-----------------------------------------------------------
TRACK:	addi	$sp, $sp, 4			# backup
	sw	$at, 0($sp)
	addi	$sp, $sp, 4
	sw	$k0, 0($sp)

 	li	$at, LEAVETRACK		# change LEAVETRACK port
	addi	$k0, $zero,1		# to logic 1,
 	sb	$k0, 0($at)			# to start tracking
 	
 	addi	$s0, $zero, 1
 	sw	$s0, isTracking
 	
	lw	$k0, 0($sp)			# restore back up
	addi	$sp, $sp, -4
	lw	$at, 0($sp)
	addi	$sp, $sp, -4
	
TRACK_end:	jr $ra
	
#-----------------------------------------------------------
# UNTRACK()
#-----------------------------------------------------------
UNTRACK:	addi	$sp, $sp, 4		# backup
	sw	$at, 0($sp)
	
	li	$at, LEAVETRACK	# change LEAVETRACK port to 0
 	sb	$zero, 0($at)	# to stop drawing tail
 	
 	sw	$zero, isTracking
 	
	lw	$at, 0($sp)		# restore back up
	addi	$sp, $sp, -4
	
UNTRACK_end: jr	$ra

#-----------------------------------------------------------
# ROTATE()
#-----------------------------------------------------------
ROTATE:	addi	$sp, $sp, 4		# backup
	sw	$t1, 0($sp)
	addi	$sp, $sp, 4
	sw	$t2, 0($sp)
	addi	$sp, $sp, 4
	sw	$t3, 0($sp)
	
	li	$t1, HEADING	# change HEADING port
	la	$t2, a_current
	lw	$t3, 0($t2)		# $t3 is heading at now
 	sw	$t3, 0($t1)		# to rotate robot
 	
 	lw	$t3, 0($sp)		# restore back up
	addi	$sp, $sp, -4
	lw	$t2, 0($sp)
	addi	$sp, $sp, -4
	lw	$t1, 0($sp)
	addi	$sp, $sp, -4
	
ROTATE_end: jr	$ra
	
#===============================================================================
# Procedure for string 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# strcmp()
# - input: $s3 = string to compare with cmdCode
# - output: $t0 = 0 if not equal, 1 if equal
#-----------------------------------------------------------					
strcmp:	addi	$sp, $sp, 4			# back up
	sw	$t1, 0($sp)
	addi	$sp, $sp, 4
	sw	$s1, 0($sp)
	addi	$sp,$sp,4
	sw	$t2, 0($sp)
	addi	$sp, $sp, 4
	sw	$t3, 0($sp)
	
	li	$t0,0		# $t0  = 0
	li 	$t1,0		# $t1 = i = 0
	
strcmp_loop: 
	beq 	$t1, 3, strcmp_equal		# if i = 3 -> end loop -> equal
	nop
	
	lb	$t2, cmdCode($t1)		# $t2 = cmdCode[i]
			
	add	$t3, $s3, $t1		# $t3 = s + i
	lb	$t3, 0($t3)			# $t3 = s[i]
	
	beq	$t2, $t3, strcmp_next		# if $t2 == $t3 -> continue the loop
	nop
	
	j	strcmp_end

strcmp_next: 
	addi	$t1, $t1, 1 		# i++
	j	strcmp_loop

strcmp_equal: add	$t0, $zero, 1		# $t0 = 1

strcmp_end: lw	$t3, 0($sp)			# restore the backup
	addi	$sp, $sp, -4
	lw	$t2, 0($sp)
	addi	$sp, $sp, -4
	lw	$s1, 0($sp)
	addi	$sp, $sp, -4
	lw	$t1, 0($sp)
	addi	$sp, $sp, -4

	jr $ra

#-----------------------------------------------------------
# strClear()
#-----------------------------------------------------------				
strClear:	
	addi	$sp, $sp, 4			# backup
	sw	$t1, 0($sp)
	addi	$sp, $sp, 4	
	sw	$t2, 0($sp)	
	addi	$sp, $sp, 4	
	sw	$s1, 0($sp)
	addi	$sp, $sp, 4
	sw	$t3, 0($sp)
	addi	$sp, $sp, 4	
	sw	$s2, 0($sp)
	
	lw	$t3, cmdLen			# $t3 = cmdLen
	addi	$t1, $zero, -1		# $t1 = -1 = i
	
strClear_loop: 
	addi	$t1, $t1, 1			# i++	
	sb	$zero, cmdCode($t1)		# cmdCode[i] = '\0'			
	bne	$t1, $t3, strClear_loop	# if $t1 <=3 resetInput loop
	nop
				
	sw	$zero, cmdLen		# reset cmdLen = 0
	
strClear_end: 
	lw	$s2, 0($sp)			# restore backup
	addi	$sp, $sp, -4
	lw	$t3, 0($sp)
	addi	$sp, $sp, -4
	lw	$s1, 0($sp)
	addi	$sp, $sp, -4
	lw	$t2, 0($sp)
	addi	$sp, $sp, -4
	lw	$t1, 0($sp)
	addi	$sp, $sp, -4
	
	jr	$ra
		
#===============================================================================
# GENERAL INTERRUPT SERVED ROUTINE for all interrupts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.ktext	0x80000180
#-------------------------------------------------------
# SAVE the current REG FILE to stack
#-------------------------------------------------------
backup:	addi	$sp, $sp, 4
	sw	$ra, 0($sp)
	addi	$sp, $sp, 4
	sw	$t1, 0($sp)
	addi	$sp, $sp, 4
	sw	$t2, 0($sp)
	addi	$sp, $sp, 4
	sw	$t3, 0($sp)
	addi	$sp, $sp, 4
	sw	$a0, 0($sp)
	addi	$sp, $sp, 4
	sw	$at, 0($sp)
	addi	$sp, $sp, 4
	sw	$s0, 0($sp)
	addi	$sp, $sp, 4
	sw	$s1, 0($sp)
	addi	$sp, $sp, 4
	sw	$s2, 0($sp)
	addi	$sp, $sp, 4
	sw	$t4, 0($sp)
	addi	$sp, $sp, 4
	sw	$s3, 0($sp)
#--------------------------------------------------------
# Processing
#--------------------------------------------------------
get_cod:	
	li	$t1, IN_ADRESS_HEXA_KEYBOARD
	li	$t2, OUT_ADRESS_HEXA_KEYBOARD

scan_row1:	
	li	$t3, 0x81
	sb	$t3, 0($t1)
	lbu	$a0, 0($t2)
	bnez	$a0, get_code_in_char

scan_row2:	
	li	$t3, 0x82
	sb	$t3, 0($t1)
	lbu	$a0, 0($t2)
	bnez	$a0, get_code_in_char

scan_row3:	
	li	$t3, 0x84
	sb	$t3, 0($t1)
	lbu	$a0, 0($t2)
	bnez	$a0, get_code_in_char

scan_row4:	
	li	$t3, 0x88
	sb	$t3, 0($t1)
	lbu	$a0, 0($t2)
	bnez	$a0, get_code_in_char

get_code_in_char:
	beq	$a0, KEY_0, case_0
	beq	$a0, KEY_1, case_1
	beq	$a0, KEY_2, case_2
	beq	$a0, KEY_3, case_3
	beq	$a0, KEY_4, case_4
	beq	$a0, KEY_5, case_5
	beq	$a0, KEY_6, case_6
	beq	$a0, KEY_7, case_7
	beq	$a0, KEY_8, case_8
	beq	$a0, KEY_9, case_9
	beq	$a0, KEY_a, case_a
	beq	$a0, KEY_b, case_b
	beq	$a0, KEY_c, case_c
	beq	$a0, KEY_d, case_d
	beq	$a0, KEY_e, case_e
	beq	$a0, KEY_f, case_f
	
case_0:	li	$s0, '0'		# $s0 store code in char type
	j	store_code
case_1:	li	$s0, '1'
	j	store_code
case_2:	li	$s0, '2'
	j	store_code
case_3:	li	$s0, '3'
	j	store_code
case_4:	li	$s0, '4'
	j	store_code
case_5:	li	$s0, '5'
	j	store_code
case_6:	li	$s0, '6'
	j	store_code
case_7:	li	$s0, '7'
	j	store_code
case_8:	li	$s0, '8'
	j	store_code
case_9:	li	$s0, '9'
	j	store_code
case_a:	li	$s0, 'a'
	j	store_code
case_b:	li	$s0, 'b'
	j	store_code
case_c:	li	$s0, 'c'
	j	store_code
case_d:	li	$s0, 'd'
	j	store_code
case_e:	li	$s0, 'e'
	j	store_code
case_f:	li	$s0, 'f'
	j	store_code
	
store_code:	la	$s1, cmdCode   
	la	$s2, cmdLen
	lw	$s3, 0($s2)			# $s3 = strlen(cmdCode)
	add	$t4, $s3, $0 		# $t4 = cmdLen
	add	$s1, $s1, $t4		# $s1 = cmdCode + i
	sb	$s0, 0($s1)			# cmdCode[cmdLen] = $s0
	addi	$s0, $zero, '\n'		# add '\n' character to end of string
	addi	$s1, $s1, 1
	sb	$s0, 0($s1) 	#cmdCode[cmdLen+1] = '\n'
	
	addi	$s3, $s3, 1
	sw	$s3, 0($s2)			# update cmdLen
		
#--------------------------------------------------------
# Evaluate the return address of main routine
# epc <= epc + 4
#--------------------------------------------------------
next_pc:
	mfc0	$at, $14		# $at <= Coproc0.$14 = Coproc0.epc
	addi	$at, $at, 4		# $at = $at + 4 (next instruction)
	mtc0	$at, $14		# Coproc0.$14 = Coproc0.epc <= $at
#--------------------------------------------------------
# RESTORE the REG FILE from STACK
#--------------------------------------------------------
restore:	lw	$s3, 0($sp)
	addi	$sp, $sp, -4
	lw	$t4, 0($sp)
	addi	$sp, $sp, -4
	lw	$s2, 0($sp)
	addi	$sp, $sp, -4
	lw	$s1, 0($sp)
	addi	$sp, $sp, -4
	lw	$s0, 0($sp)
	addi	$sp, $sp, -4
	lw	$at, 0($sp)
	addi	$sp, $sp, -4
	lw	$a0, 0($sp)
	addi	$sp, $sp, -4
	lw	$t3, 0($sp)
	addi	$sp, $sp, -4
	lw	$t2, 0($sp)
	addi	$sp, $sp, -4
	lw	$t1, 0($sp)
	addi	$sp, $sp, -4
	lw	$ra, 0($sp)
	addi	$sp, $sp, -4
return: eret # Return from exception
