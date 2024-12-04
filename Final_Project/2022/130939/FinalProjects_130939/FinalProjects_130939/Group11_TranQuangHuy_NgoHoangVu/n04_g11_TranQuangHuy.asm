# Programmer: Tràn Quang Huy								      #
# Description: This program simulate a CNC Marsbot to cut metal.			      #
# Bugs:											      #
###############################################################################################

#.............................................................................................
# Hexadecimal keyboard
.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014
#.............................................................................................
# Marsbot
.eqv HEADING 0xffff8010		# Integer: An angle between 0 and 359
					# 0 : North (up)
					# 90: East (right)
					# 180: South (down)
					# 270: West (left)
.eqv MOVING 0xffff8050		# Boolean whether or not to move
.eqv LEAVETRACK 0xffff8020	# Boolean whether or not to leave a track
.eqv WHEREX 0xffff8030 		# Integer: Current x-location of MarsBot
.eqv WHEREY 0xffff8040 		# Integer: Current y-location of MarsBot
#.............................................................................................
# Key value
	.eqv KEY_0 0x11
	.eqv KEY_4 0x12
	.eqv KEY_8 0x14
		
#=============================================================================================
#=============================================================================================
.data
	DCE_script: .word  180, 1, 5000, 70, 1, 1500, 35, 1, 1500, 0, 1, 1500, 325, 1, 1500, 290, 1, 1500, 		# D
			   90, 0, 5000,									  		# sleeping
			   255, 1, 1500, 195, 1, 2120, 165, 1, 2120, 105, 1, 1500,			  		# C
			   90, 0, 1000,									  		# sleeping
			   90, 1, 2000, 270, 0, 2000, 0, 1, 2500, 90, 1, 2000, 270, 0, 2000, 0, 1, 2500, 90, 1, 2000,   # E
			   90, 0, 5000, -1								  		# sleeping
	HUY_script: .word  180, 1, 5000, 0, 0, 2500, 90, 1, 2500, 180, 1, 2500, 0, 0, 2500, 0 1, 2500 			# H
			   90, 0, 1000,											# sleeping
			   180, 1, 4300, 140, 1, 990, 90, 1, 1300, 40, 1, 990, 0, 1, 4500,				# U
			   90, 0, 1000,											# sleeping
			   135, 1, 2828, 180, 1 3000, 0, 0, 3000, 45, 1, 2828,						# Y
			   90, 0, 5000, -1										# sleeping
			   		
	BUMA_script: .word 180, 1, 5000, 80, 1, 1500, 35, 1, 750, 0, 1, 800, 325, 1, 750, 				# B
			   280, 1, 750, 270, 1, 750, 80, 1, 1500, 35, 1, 750, 0, 1, 800, 
			   325, 1, 750, 295, 1, 750, 270, 1, 750,
			   90, 0, 3000,											# sleeping
			   180, 1, 4300, 140, 1, 990, 90, 1, 1300, 40, 1, 990, 0, 1, 4500,				# U
			   90, 0, 1000, 										# sleeping
			   180, 1, 5000, 0, 0, 5000, 150, 1, 2500, 30, 1, 2500, 180, 1, 5000, 				# M
			   90, 0, 1000,											# sleeping
			   15, 1, 5200, 165, 1, 5200, 0, 0, 2300, 270, 1, 3000,						# A
			   0, 0, 2700, 90, 0, 7500, -1									# sleeping	
	padding_script: .word 90, 0, 1000, 180, 0, 1000, -1
	
#=============================================================================================
#=============================================================================================
.text
draw_padding:
  la $s0, padding_script
  j start_cut_metal
main:
  #...........................................................................................
  # Enable the interrupt of Keyboard matrix 4x4 of Digital Lab Sim
  li $t0, IN_ADRESS_HEXA_KEYBOARD
  li $t1, 0x80	# bit 7 = 1 to enable
  sb $t1, 0($t0)
  #...........................................................................................
  # Infinite loop that wait for interrupt
  loop:
    nop
    bnez $s0, start_cut_metal
    nop
    b loop
  
  start_cut_metal:
  li $t1, 0x00		# disable interrupt while cutting
  sb $t1, 0($t0)
  jal GO

  read_script: 
    lw $a0, 0($s0)	# load direction, -1 if script end.
    beq $a0, -1, stop
    jal ROTATE		# change direction of Marsbot

    lw $a0, 4($s0)
    jal SET_TRACK
 
   sleep:
    li $v0, 32		# keep running by sleeping
    lw $a0, 8($s0)
    syscall
 
    li $a0, 0
    jal SET_TRACK	# auto untrack everytime to keep path
 
    addi $s0, $s0, 12
    j read_script
 
  stop:
    jal STOP		# stop Marsbot
    li $s0, 0		# clear current script
    j main		# wait another draw command

#---------------------------------------------------------------------------------------------
# SET_TRACK procedure, to start drawing line 
# param[in]	$a0, A boolean whether leavetrack or not
#---------------------------------------------------------------------------------------------
SET_TRACK:
  li $at, LEAVETRACK	# change LEAVETRACK port
  sb $a0, 0($at)
  nop
  jr $ra
  nop
#---------------------------------------------------------------------------------------------
# ROTATE procedure, to rotate the robot
# param[in]	$a0, An angle between 0 and 359
#---------------------------------------------------------------------------------------------
ROTATE:
  li $at, HEADING 	# change HEADING port
  sw $a0, 0($at) 	# to rotate robot
  nop
  jr $ra
  nop
#---------------------------------------------------------------------------------------------
# GO procedure, to start running
# param[in]	none
#---------------------------------------------------------------------------------------------
GO: li $at, MOVING 	# change MOVING port
 addi $k0, $zero, 1 	# to logic 1, 
 sb $k0, 0($at) 	# to start running
 nop 
 jr $ra
 nop
#---------------------------------------------------------------------------------------------
# STOP procedure, to stop running
# param[in] 	none
#---------------------------------------------------------------------------------------------
STOP: li $at, MOVING # change MOVING port to 0
 sb $zero, 0($at) # to stop
 nop
 jr $ra
 nop
#=============================================================================================
#=============================================================================================
.ktext 0x80000180
#.............................................................................................
# Backup
  addi $sp, $sp, 4
  sw $t1, 0($sp)
  addi $sp, $sp, 4
  sw $t2, 0($sp)
  addi $sp, $sp, 4
  sw $t3, 0($sp)
  addi $sp, $sp, 4
  sw $a0, 0($sp)
#.............................................................................................
# Processing
get_number:
  li $t1, IN_ADRESS_HEXA_KEYBOARD
  li $t2, OUT_ADRESS_HEXA_KEYBOARD
scan_row1:				# Scan number 0, 1, 2, 3
  li $t3, 0x81
  sb $t3, 0($t1)
  lbu $a0, 0($t2)
  bnez $a0, check_number
scan_row2:				# Scan number 4, 5, 6, 7
  li $t3, 0x82
  sb $t3, 0($t1)
  lbu $a0, 0($t2)
  bnez $a0, check_number
scan_row3:				# Scan number 8, 9 + letter A, B
  li $t3, 0x84
  sb $t3, 0($t1)
  lbu $a0, 0($t2)
  bnez $a0, check_number

check_number:
  beq $a0, KEY_0, case_0
  beq $a0, KEY_4, case_4
  beq $a0, KEY_8, case_8
  j next_pc
  
case_0:
  la $s0, DCE_script
  j next_pc

case_4:
  la $s0, HUY_script
  j next_pc

case_8:
  la $s0, BUMA_script
  j next_pc
    
#...........................................................................................
# Evaluate the return address of main routine epc <- epc + 4
next_pc:
  mfc0 $at, $14   	# $at <= Coproc0.$14 = Coproc0.epc
  addi $at, $at, 4	# $at = $at + 4 (next instruction)
  mtc0 $at, $14		# Coproc0.$14 = Coproc0.epc <= $at
#...........................................................................................
# Restore the registers from stack
  lw $a0, 0($sp)
  addi $sp, $sp, -4
  lw $t3, 0($sp)
  addi $sp, $sp, -4
  lw $t2, 0($sp)
  addi $sp, $sp, -4
  lw $t1, 0($sp)
  addi $sp, $sp, -4
return: eret   		# Return from exception
