
.eqv STACK_NODE_SIZE 8
.eqv STACK_SIZE 4

.eqv STACK_NODE_NEXT 0
.eqv STACK_NODE_DATA 4

.eqv STACK_BACK 0


.eqv KEY_CODE			0xFFFF0004
.eqv KEY_READY			0xFFFF0000

.eqv DISPLAY_CODE			0xFFFF000C
.eqv DISPLAY_READY		0xFFFF0008

.eqv MASK_CAUSE_DISPKEY	0x00000034


.eqv HEADING 	0xFFFF8010
.eqv TRACKING 	0xFFFF8020 
.eqv WHEREX 		0xFFFF8030 
.eqv WHEREY 		0xFFFF8040
.eqv MOVEMENT 	0xFFFF8050

.eqv UP 0 
.eqv RIGHT 90 
.eqv DOWN 180 
.eqv LEFT 270

.eqv IN_MATRIX_KEYBOARD		0xFFFF0012
.eqv OUT_MATRIX_KEYBOARD		0xFFFF0014

.eqv MASK_CAUSE_MATRIX		0x00000800




.data 
	MARS_CURRENT_HEAD: .word 0
	CONTROL_CODE: .space 4
	
	HIGH_TIME: .word 0 
	LOW_TIME: .word 0 
	
	STACK_POINTER: .word 0
	
	control_success: .asciiz "\nLoaded control success\n"
	control_clear: .asciiz "\nControl code is cleared\n"
	previous_command: .asciiz "\nPrevious command execute\n"
	invalid_control: .asciiz "\nInvalid control code\n"
	alr_go: .asciiz "\nAlready going\n"
	alr_stop: .asciiz "\nAlready stopping\n"
	back_track_msg: .asciiz "\nStart Backtracking\n"
	end_backtrack_msg: .asciiz "\nEnd Backtracking\n"
	
.text
.globl main 
main:
	# Enable Interrupt
	li $t0, 0x80 
	sb $t0, IN_MATRIX_KEYBOARD
	
	# Initialize stack 
	jal init_stack 
	sw $v0, STACK_POINTER 
	
	li $a0, 90 
	jal rotate 
	
	jal go 
	li $a0, 5000
	li $v0, 32
	syscall
	
	li $a0, 180
	jal rotate
	
	jal go 
	li $a0, 2000
	li $v0, 32
	syscall 
	
	jal stop
	
	li $a0, 0
	jal rotate 
	
	# Initialize the time when the program start
	li $v0, 30
	syscall 
	
	sw $a0, LOW_TIME
	sw $a1, HIGH_TIME 
	
	infinite:nop
		wait_key:
			lw $t1, KEY_READY
			bne $t1, 1, wait_key
			nop 
			bne $t1, 1, wait_key			# incase interrupt happens at the previous branch
		read_key:
			sb $zero, IN_MATRIX_KEYBOARD  # Disable interrupt 
			
			lw $a0, KEY_CODE 
			jal process_key
			
		done_exec:
			li $t0, 0x80 
			sb $t0, IN_MATRIX_KEYBOARD 
			
		j infinite
		j infinite
end_main:	
	li $v0, 10
	syscall 

# --------------------------------------------------------------------
# @brief: process key
# @param:
#		$a0 - key
# @return: void
# @variables:
#		$t0 - save lo time
#		$t1 - save hi time
#		$s0 - key
#		$s1 - $ra
#		$s2 - save command
#		$s3 - save time between
# --------------------------------------------------------------------
process_key:
	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $t0, 16($sp)
	sw $t1, 20($sp)
	
	move $s0, $a0 
	move $s1, $ra 
	
	bne $s0, 10, pk_not_enter
	pk_is_enter:
		lw $a0, CONTROL_CODE
		
		bne $a0, 0x00393939, pk_not_backtrack
		is_back_track:
			# Start back track function 
			la $a0, back_track_msg
			li $v0, 4
			syscall	
			
			# Calculate the time that the command was entered 
			# The time between this command and the previous one 
			li $v0, 30 
			syscall 
			lw $a2, LOW_TIME
			lw $a3, HIGH_TIME
			jal sub64
			
			# Push it onto the stack as well
			lw $a0, STACK_POINTER
			move $a1, $v0 
			jal stack_push_back
			
			jal back_track
		
			j pk_converge
		pk_not_backtrack:
		
		lw $a0, CONTROL_CODE
		jal bot_exec 
		
		beq $v0, 0, pk_success
		pk_not_success:			
			j pk_skip_success
	
		pk_success:
			# Calculate current time
			li $v0, 30 
			syscall 
			move $t0, $a0 
			move $t1, $a1
			# $a0 - low $a1 - high 
			lw $a2, LOW_TIME
			lw $a3, HIGH_TIME
			jal sub64
			
			sw $t0, LOW_TIME
			sw $t1, HIGH_TIME
			
			# $v0 contains the time between each command 
			move $a1, $v0 
			lw $a0, STACK_POINTER
			jal stack_push_back
			
			# Store the command as well 
			lw $a1, CONTROL_CODE
			lw $a0, STACK_POINTER
			jal stack_push_back
			
			# Print success message
			la $a0, control_success
			li $v0, 4
			syscall 
		pk_skip_success:
			# Delete the control code buffer
			sw $zero, CONTROL_CODE
		
			j pk_converge
	pk_not_enter:
	bne $s0, 8, pk_not_delete
	pk_is_delete:
	
		sw $zero, CONTROL_CODE
		
		la $a0, control_clear
		li $v0, 4
		syscall 
	
		j pk_converge
	pk_not_delete:
	bne $s0, 32, pk_not_space
	pk_is_space:
		lw $a0, STACK_POINTER
		jal stack_back 
		move $s3, $v0 
		
		# Try to exec
		move $a0, $v0 
		jal bot_exec
		
		beq $v0, 0, be_space_success
		
		j be_skip_space_success
		be_space_success:
		
			li $v0, 30 
			syscall 
		
			move $t0, $a0 
			move $t1, $a1
		
			lw $a2, LOW_TIME
			lw $a3, HIGH_TIME 
			jal sub64
			move $s2, $v0 
		
			# Update the new time
			sw $t0, LOW_TIME
			sw $t1, HIGH_TIME
		
			# Store time between command
			move $a1, $s2
			lw $a0, STACK_POINTER
			jal stack_push_back
		
			# Store command
			move $a1, $s3
			lw $a0, STACK_POINTER
			jal stack_push_back 
	
			# Print success message
			la $a0, previous_command
			li $v0, 4
			syscall 
	
		be_skip_space_success:
		
		j pk_converge
	pk_not_space:
	
	
		j pk_converge
	pk_converge:
	

end_process_key:
	move $ra, $s1
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $t0, 16($sp)
	lw $t1, 20($sp)
	addi $sp, $sp, 24
	jr $ra
	
# --------------------------------------------------------------------
# @brief: function to backtrack the movement of marsbot 
#		 ignore track command
# @param: void
# @return: void
# @variables:
#		$s0 - current command
#		$s1 - current time
#		$s2 - degree + 180
#		$s3 - $ra
#		$s4 - mode running or stopping 1 for running 0 for stopping
#		$s5 - save time
#		$s6 - save top command
# --------------------------------------------------------------------
back_track:
	addi $sp, $sp, -28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	move $s3, $ra
	
	jal track_off
	
	# Get the top of the stack the time to call the 999 
	lw $a0, STACK_POINTER 
	jal stack_back 
	move $s5, $v0 				# $s5 = time
	 
	# Pop it for now 
	lw $a0, STACK_POINTER 
	jal stack_pop_back 
	
	# Get the top command
	lw $a0, STACK_POINTER
	jal stack_back 
	move $s6, $v0 
	
	# If there's no top command exit 
	beq $v1, -1, end_back_track

	
	beq $s6, 0x00383663, bt_first_is_stop			# If it's equal to stop command branch
	bt_first_not_stop:
		lw $a0, STACK_POINTER						# Push time back
		move $a1, $s5
		jal stack_push_back
	
		lw $a0, STACK_POINTER						# Add a stop command to the top
		li $a1, 0x00383663
		jal stack_push_back
	
		j skip_bt_first_is_stop
	bt_first_is_stop:
		# if it's stop then we'll do nothing 
	skip_bt_first_is_stop:
	
	bt_while:
		lw $a0, STACK_POINTER
		jal stack_is_empty
		beq $v0, 1, end_bt_while
	
		lw $a0, STACK_POINTER
		jal stack_back 
		move $s6, $v0 
	
		lw $a0, STACK_POINTER
		jal stack_pop_back 
		
		lw $a0, STACK_POINTER 
		jal stack_back 
		move $s5, $v0 
		
		lw $a0, STACK_POINTER
		jal stack_pop_back 
		
		bne $s6, 0x00383663, bt_not_stop
		bt_is_stop:
			li $s4, 1
			
			lw $s2, MARS_CURRENT_HEAD
			addi $s2, $s2, 180
			
			bgt $s2, 360, bts_overflow
			
			j bts_skip_overflow
			bts_overflow:
			addi $s2, $s2, -360
			bts_skip_overflow:
			sw $s2, MARS_CURRENT_HEAD
			
			move $a0, $s2
			jal rotate 
			
			jal go 
			move $a0, $s5
			li $v0, 32
			syscall	
			jal stop
			j bt_while			
		bt_not_stop:
		bne $s6, 0x00346231, bt_not_go
		bt_is_go:
			li $s4, 0 
			
			lw $s2, MARS_CURRENT_HEAD
			addi $s2, $s2, 180 
			
			bgt $s2, 360, btg_overflow
			
			j btg_skip_overflow
			btg_overflow:
			addi $s2, $s2, -360
			btg_skip_overflow:
			sw $s2, MARS_CURRENT_HEAD
			
			move $a0, $s2
			jal rotate 
			
			jal stop 
			
			j bt_while
		bt_not_go:
		bne $s6, 0x00343434, bt_not_left
		bt_is_left:
			li $a0, 0x00363636
			jal bot_exec
		
			beq $s4, 1, left_go
			left_stop:
			# Don't go here
				jal stop
				j skip_left_go
			left_go:
				jal go 
				li $v0, 32
				move $a0, $s5
				jal stop
				syscall
			skip_left_go:
			j bt_while
		bt_not_left:
		bne $s6, 0x00363636, bt_not_right
		bt_is_right:
			li $a0, 0x00343434
			jal bot_exec
			
			beq $s4, 1, right_go
			right_stop:
				jal stop
				j skip_right_go
			right_go:
				jal go 
				li $v0, 32
				move $a0, $s5
				jal stop
				syscall
			skip_right_go:
			j bt_while	
		bt_not_right:
		bne $s6, 0x00646164, bt_not_ton
		bt_is_ton:
			beq $s4, 1, ton_go
			ton_stop:
				jal stop
				j skip_ton_go
			ton_go:
				jal go 
				li $v0, 32
				move $a0, $s5
				jal stop
				syscall
			skip_ton_go:
			j bt_while
		bt_not_ton:
		bne $s6, 0x00636263, bt_not_toff
		bt_is_toff:
			beq $s4, 1, toff_go
			toff_stop:
				jal stop
				j skip_toff_go
			toff_go:
				jal go 
				li $v0, 32
				move $a0, $s5
				jal stop
				syscall
			skip_toff_go:
			j bt_while
		bt_not_toff:
	end_bt_while:
	
	sw $zero, CONTROL_CODE
	li $v0, 30 
	syscall 
	
	sw $a0, LOW_TIME
	sw $a1, HIGH_TIME
	
	la $a0, end_backtrack_msg
	li $v0, 4
	syscall
	
end_back_track:
	move $ra, $s3
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	addi $sp, $sp, 28
	jr $ra


# --------------------------------------------------------------------
# @brief:  Execute Marsbot instruction based on control code in $a0
#		   If control code is invalid nothing happens return -1
# @params: $a0 - control code
# @return: $v0 - 0 for success -1 for failure
# @variables:
#				$t0 - current move status
#				$s0 - control code 
#				$s1 - current bot head 
#				$s2 - degree to set 
#				$s3 - return
#				$s4 - $ra
# @reference table:			
# 	0x00346231 - 1b4 Move
# 	0x00383663 - c68 Stop 
# 	0x00343434 - 444 Turn left 90 degree with respect to current head
# 	0x00363636 - 666 Turn right 90 degree with respect to current head
# 	0x00646164 - dad Start Tracking 
# 	0x00636263 - cbc Stop Tracking 
# ---------------------------------------------------------------------
bot_exec:	
	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $t0, 20($sp)
	
	li $s3, 0					# init success
	move $s4, $ra				# Save return address
	move $s0, $a0 				# $s0 = control code 
	
	bne $s0, 0x00346231, be_not_move
		lw $t0, MOVEMENT
		beq $t0, 1, be_already_moving

		jal go 
		j be_converge
	
	be_not_move:
	bne $s0, 0x00383663, be_not_stop
		lw $t0, MOVEMENT
		beq $t0, 0, be_already_stop
	
		jal stop 
		j be_converge
	be_not_stop:
	bne $s0, 0x00343434, be_not_turn_left
		lw $s1, MARS_CURRENT_HEAD
		addi $s1, $s1, -90
		blt $s1, 0, be_head_neg
	
		# here is positive just skip
		move $s2, $s1
		j skip_be_head_neg
	
	be_head_neg:
		addi $s2, $s1, 360
		 
	skip_be_head_neg:
		move $a0, $s2
		jal rotate
		sw $s2, MARS_CURRENT_HEAD
		j be_converge
		
	be_not_turn_left:
		bne $s0, 0x00363636, be_not_turn_right
		lw $s1, MARS_CURRENT_HEAD
		addi $s1, $s1, 90
		bgt $s1, 360, be_head_pos
	
	# here is smaller than or equal to 360 its fine 
	move $s2, $s1
	j skip_be_head_pos
	
	be_head_pos:
		addi $s2, $s1, -360
		
	skip_be_head_pos:
		move $a0, $s2
		jal rotate
		sw $s2, MARS_CURRENT_HEAD
		j be_converge
	
	be_not_turn_right:
	bne $s0, 0x00646164, be_not_track_on
		jal track_on
		j be_converge
	
	be_not_track_on:
	bne $s0, 0x00636263, be_not_track_off
		jal track_off
		j be_converge
	
	be_not_track_off:
	
	be_invalid_command:
		la $a0, invalid_control
		li $v0, 4
		syscall 
		
		li $s3, -1
		j be_converge
	be_already_moving:
		la $a0, alr_go 
		li $v0, 4
		syscall
	
		li $s3, -1
		j be_converge
	be_already_stop:
		la $a0, alr_stop
		li $v0, 4
		syscall
	
		li $s3, -1
		j be_converge
	be_converge:

end_bot_exec:
	move $v0, $s3				# return code
	move $ra, $s4
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $t0, 20($sp)
	addi $sp, $sp, 24
	jr $ra







# ----------------------------------------------
# @brief: function to sub tract 2 64 bit numbers 
# @params:
#		$a0 - low order 32 bits of A
#		$a1 - hi order 32 bits of A
#		$a2 - low order 32 bits of B
#		$a3 - hi order 32 bits of B
# @return:
#		$v0 - low order 32 bits of (A - B)
#		$v1 - hi order 32 bits of (A - B)
# @variables:
#		$s0 - $a0 - $a2
#		$s1 - check $s0 is negative (this means there's a borrow)
#		$s2 - $a1 - $s1
#		$s3 - $s2 - $a3
# ----------------------------------------------
sub64:
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	
	subu $s0, $a0, $a2			# $s0 = $a0 - $a2   result low order
	sltu $s1, $a0, $a2			# $s1 = ($a1 < $a3) ? 1 : 0 
	subu $s2, $a1, $s1			# $s2 = $a1 - $s1 
	subu $s3, $s2, $a3			# $s3 = $s2 - $a3   result high order

end_sub64:
	move $v0, $s0 
	move $v1, $s3
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 16
	jr $ra

# --------------------------------------------------------------
# @brief : find the length of string excluding newline and null
# @param: a0 - address of string
# @return: v0 - length of string
# --------------------------------------------------------------
strlen:
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)

	li $t0, 0 				# i = 0
	li $v0, 0

	strlen_loop:
		add $t1, $a0, $t0 
		lb $t2, 0($t1) # string[i]
		
		beq $t2, 0, end_strlen_loop
		beq $t2, '\n', end_strlen_loop
		
		addi $v0, $v0, 1
		addi $t0, $t0, 1
		j strlen_loop
	end_strlen_loop:
end_strlen:		
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)	
	addi $sp, $sp, 12
	jr $ra

# ------------------------------------------------------
# @brief: Append a character to a string 
# @params:
#		$a0 - address of string 
#		$a1 - size of string buffer 
#		$a2 - character to append
# @return: 
#		$v0 - 0 for sucess -1 for failure
# @variables:
#		$t0 - strlen(string)
#		$t1 - strlen(string) + 1
#		$s0 - $a0 
#		$s1 - $a1
#		$s2 - $a2
#		$s3 - return 
#		$s4 - $ra
# -------------------------------------------------------
str_append:
	addi $sp, $sp, -28
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $s0, 8($sp)
	sw $s1, 12($sp)
	sw $s2, 16($sp)
	sw $s3, 20($sp)
	sw $s4, 24($sp)
	
	move $s0, $a0 
	move $s1, $a1
	move $s2, $a2
	move $s4, $ra
	li $s3, 0							# init to be success
	
	move $a0, $s0 
	jal strlen 
	move $t0, $v0 						# $t0 = strlen(str)
	
	addi $t1, $t0, 1						# $t1 = strlen(str) + 1
	beq $t1, $s1, sa_error
	
	add $s0, $s0, $t0 					# $s0 = address of str + strlen(str) 
	
	sb $s2, 0($s0)
	j end_str_append
	
	sa_error:
		li $s3, -1
		j end_str_append
end_str_append:
	move $v0, $s3
	move $ra, $s4
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $s0, 8($sp)
	lw $s1, 12($sp)
	lw $s2, 16($sp)
	lw $s3, 20($sp)
	lw $s4, 24($sp)
	addi $sp, $sp, 28
	jr $ra





# ----------------------------------------------
# @brief: function to enable marsbot movement 
# @params: void
# @return: void	
# ----------------------------------------------
go:
	li $a0, 1
	sw $a0, MOVEMENT
end_go:
	jr $ra
	
# ----------------------------------------------
# @brief: function to disable marsbot movement 
# @params: void
# @return: void	
# ----------------------------------------------
stop:
	li $a0, 0
	sw $a0, MOVEMENT
end_stop:
	jr $ra
	
# -----------------------------------------------
# @brief: function to enable marsbot tracking
# @params: void
# @return: void
# -----------------------------------------------
track_on:
	li $a0, 1
	sw $a0, TRACKING
end_track_on:
	jr $ra
	
# -----------------------------------------------
# @brief: function to disable marsbot tracking
# @params: void
# @return: void
# -----------------------------------------------
track_off:
	li $a0, 0
	sw $a0, TRACKING
end_track_off:
	jr $ra
	
# -----------------------------------------------
# @brief: rotate marsbot
# @params: $a0 - rotation
# @return: void
# -----------------------------------------------
rotate:
	sw $a0, HEADING
end_rotate:
	jr $ra
	
# -----------------------------------------------
# @brief: get current x coordinate of marsbot
# @params: void
# @return: $v0 - x
# -----------------------------------------------
wherex:
	lw $v0, WHEREX
end_wherex:
	jr $ra

# -----------------------------------------------
# @brief: get current y coordinate of marsbot
# @params: void
# @return: $v0 - y
# -----------------------------------------------
wherey:
	lw $v0, WHEREY
end_wherey:
	jr $ra
	





# ---------------------------------------------------------------------
# @brief: convert row and column of key pressed to actual key character
# @param:
#		$a0 - byte that holds the row and column value 
# @return:
#		$v0 - ascii code for character that the byte represent 
#			- 0 if invalid
# @variables:
# ----------------------------------------------------------------------
matrix_to_char:
	bne $a0, 0x11, mtc_not_zero
	li $v0, '0'
	j end_matrix_to_char
	
	mtc_not_zero:
	bne $a0, 0x21, mtc_not_one
	li $v0, '1'
	j end_matrix_to_char
	
	mtc_not_one:
	bne $a0, 0x31, mtc_not_two
	li $v0, '2'
	j end_matrix_to_char

	mtc_not_two:
	bne $a0, 0x81, mtc_not_three
	li $v0, '3'
	j end_matrix_to_char
	
	mtc_not_three:
	bne $a0, 0x12, mtc_not_four
	li $v0, '4'
	j end_matrix_to_char
	
	mtc_not_four:
	bne $a0, 0x22, mtc_not_five
	li $v0, '5'
	j end_matrix_to_char
	
	mtc_not_five:
	bne $a0, 0x42, mtc_not_six
	li $v0, '6'
	j end_matrix_to_char
	
	mtc_not_six:
	bne $a0, 0x82, mtc_not_seven
	li $v0, '7'
	j end_matrix_to_char
	
	mtc_not_seven:
	bne $a0, 0x14, mtc_not_eight
	li $v0, '8'
	j end_matrix_to_char
 
 	mtc_not_eight:
	bne $a0, 0x24, mtc_not_nine
	li $v0, '9'
	j end_matrix_to_char
	
	mtc_not_nine:
	bne $a0, 0x44, mtc_not_a
	li $v0, 'a'
	j end_matrix_to_char
	
	mtc_not_a:
	bne $a0, 0x84, mtc_not_b
	li $v0, 'b'
	j end_matrix_to_char
	
	mtc_not_b:
	bne $a0, 0x18, mtc_not_c
	li $v0, 'c'
	j end_matrix_to_char
	
	mtc_not_c:
	bne $a0, 0x28, mtc_not_d
	li $v0, 'd'
	j end_matrix_to_char
	
	mtc_not_d:
	bne $a0, 0x48, mtc_not_e
	li $v0, 'e'
	j end_matrix_to_char
	
	mtc_not_e:
	bne $a0, 0x88, mtc_not_f
	li $v0, 'f'
	j end_matrix_to_char
	
	mtc_not_f:
	li $v0, 0 
	
end_matrix_to_char: 
	jr $ra


# @brief function to allocate memory for a node
init_stack_node:
	li $a0, STACK_NODE_SIZE
	li $v0, 9
	syscall
end_init_stack_node:
	jr $ra
	
# @brief: function to allocate memory for a stack
init_stack:
	li $a0, STACK_SIZE
	li $v0, 9
	syscall
end_init_stack:
	jr $ra
	
# @brief: function to check if stack is empty
# @params:
#		$a0 - address of stack
# @return:
#		$v0 - 1 yes, 0 no 
# @variables:
#		$s0 - stack->back 
stack_is_empty:
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	li $v0, 0				# init to be not empty
	lw $s0, STACK_BACK($a0)

	beq $s0, 0, stack_empty_true
	
	j end_stack_is_empty
	stack_empty_true:
		li $v0, 1		
end_stack_is_empty:
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	jr $ra

# @brief: function to push value onto the stack
# @params:
#		$a0 - address of stack
#		$a1 - value to be pushed
# @return: void
# @variables:
#		$s0 - address of stack
#		$s1 - content of stack top
#		$s2 - address of new node
#		$s3 - new value
#		$s4 - $ra
#		$s5 - stack->top
stack_push_back:
	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)	
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	
	move $s4, $ra

	move $s0, $a0				# $s0 = address of stack 
	lw $s5, STACK_BACK($s0)		# $s5 = stack->top 
	move $s3, $a1				# $s3 = data to be pushed in 
	
	jal init_stack_node
	move $s2, $v0 				# $s2 = address of new node
	
	sw $s3, STACK_NODE_DATA($s2)		# $s2->data = $s3
	sw $s5, STACK_NODE_NEXT($s2)		# $s2->next = $s5
	
	sw $s2, STACK_BACK($s0)		# stack->top = new node
end_stack_push_back:
	move $ra, $s4
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)	
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	addi $sp, $sp, 24
	jr $ra
	

# @brief: function to peek at the value of the top of the stack
# @param: 
#		$a0 - address of stack
# @return:
#		$v0 = stack->top->value;
#		$v1 = 0 if success, -1 if fail
# @parameters:
#		$s0 = address of stack
#		$s1 = stack->top
#		$s1 = stack->top->data
#		$s2 = stack_is_empty($a0)
#		$s3 = $ra
stack_back:
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	
	move $s3, $ra
	
	move $s0, $a0 				# $s0 = address of stack
	jal stack_is_empty	
	
	move $s2, $v0 
	beq $s2, 0, stack_back_not_empty	# $s2 == 0 means stack is not empty 
	
	# if we re here then the stack is empty
	li $v0, 0
	li $v1, -1
	j end_stack_back
	
	stack_back_not_empty:
		lw $s1, STACK_BACK($s0)		# $s1 = stack->top
		lw $s1, STACK_NODE_DATA($s1)		# $s1 = stack->top->data
	
		move $v0, $s1				# $v0 = $s1
		li $v1, 0
end_stack_back:
	move $ra, $s3
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 16
	jr $ra
	
# @brief: function to pop the top out of a stack
# @params:
#		$a0 - address of stack
# @return: $v0 - 0 for success, -1 for failure
# @parameters:
#		$s0 - address of stack 
#		$s1 - content of stack->top
#		$s2 - content of stack->top->next
#		$s3 - $ra
stack_pop_back:
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	move $s3, $ra
	
	move $s0, $a0 				# $s0 = $a0 = address of stack 
	move $a0, $s0 				
	jal stack_is_empty
	
	beq $v0, 1, spp_fail

	lw $s1, STACK_BACK($s0)		# $s1 = stack->top
	lw $s2, STACK_NODE_NEXT($s1)		# $s2 = stack->top->next
	sw $s2, STACK_BACK($s0)		# stack->top = $s2
	li $v0, 1
	j end_stack_pop_back	
	spp_fail:
		li $v0, -1
	
end_stack_pop_back:
	move $ra, $s3
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 16
	jr $ra


# @brief: function to print out the entire stack
# @params:
#		$a0 - address of stack
# @return: void
print_stack_int:
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	move $s0, $a0 
	lw $s0, STACK_BACK($a0)				# $s0 = stack->top
	
	print_stack_loop:
		beq $s0, 0, end_print_stack_loop  # if $s0 == NULL exit
		
		lw $a0, STACK_NODE_DATA($s0)			# $a0 = $s0->data
		li $v0, 1
		syscall 
		
		li $a0, ' '
		li $v0, 11
		syscall 
		
		lw $s0, STACK_NODE_NEXT($s0)
		j print_stack_loop
	end_print_stack_loop:
end_print_stack:
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	jr $ra














# -----------------------------------------------
# @brief: handle interrupt 
# @params: void
# @return: void
# @variables:
#			$t0 - cause
#			$t1 - Check which cause
#			$t2 - free
#			$t3 - free
#			$t4 - function address
#			$a0, $a1, $a2 
#			$v0 
# -----------------------------------------------
.ktext 0x80000180 
interrupt_handler:
	addi $sp, $sp, -40
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $a0, 20($sp)
	sw $a1, 24($sp)
	sw $a2, 28($sp)
	sw $v0, 32($sp)
	sw $s0, 36($sp)	

	get_cause:
		mfc0 $t0, $13					# $t0 = cause 
	check_cause:
		andi $t1, $t0, MASK_CAUSE_MATRIX
		bne $t1, MASK_CAUSE_MATRIX, not_matrix
		# Exception caused by matrix keyboard
		
		li $t2, 1						
		ih_mk_floop:
			# The loop is guaranteed to terminate 
			# An Exception is only raised when a key is pressed
			# So bne $a0, 0, convert_mkey will definitely jump
			li $t3, 0x80 
			
			add $t3, $t3, $t2
			sb $t3, IN_MATRIX_KEYBOARD
			lbu $a0, OUT_MATRIX_KEYBOARD
			
			bne $a0, 0, convert_mkey
		
			sll $t2, $t2, 1
			j ih_mk_floop
		end_ih_mk_floop:
		
		convert_mkey:
			la $t4, matrix_to_char
			jalr $t4
			move $a0, $v0 			# $a0 = matrix_to_char($a0)
		
			li $v0, 11
			syscall 
		
			la $t4, str_append
			move $a2, $a0 
			la $a0, CONTROL_CODE
			li $a1, 4
			jalr $t4
			
		j end_interrupt_handler
		
		not_matrix:	
		# Exception caused by something else
		j end_interrupt_handler

end_interrupt_handler:
	mtc0 $zero, $13						# Clear the cause register
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $a0, 20($sp)
	lw $a1, 24($sp)
	lw $a2, 28($sp)
	lw $v0, 32($sp)
	lw $s0, 36($sp)
	addi $sp, $sp, 40
	
	# return from exception
	mfc0 $k0, $14
	addi $k0, $k0, 4
	mtc0 $k0, $14
	eret
	

