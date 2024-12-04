# Project 10
# Group: 11
# Author: Hoang Trong Tan

.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014

.eqv SEVENSEG_LEFT 0xFFFF0011 	# The address of the left 7-segment led
.eqv SEVENSEG_RIGHT 0xFFFF0010 	# The address of the right 7-segment led

.data
add_msg: 	.asciiz " + "
sub_msg: 	.asciiz " - "
mul_msg: 	.asciiz " * "
div_msg: 	.asciiz " / "
mod_msg:	.asciiz " % "
result_msg:	.asciiz " = "
msg_new_line: 	.asciiz "\n"
divider_msg: 	.asciiz "=================\n"
div_err_msg:		.asciiz "\nERR: Divie by zero!\n"
input_overflow_msg:	.asciiz "\nERR: Input data overflow memory\n"
add_overflow_msg:	.asciiz "\nERR: Plus memory overflow\n"
mul_overflow_msg:	.asciiz "\nERR: Multiplication overflow\n"
sub_overflow_msg:	.asciiz "\nERR: Subtraction overflow\n"

_DOT: 	.byte 0x80	# Show dot sign
NEG:	.byte 0x40	# Show minus sign if input Number is Negative
digit:	# Digit: Display numbers by 7-segment led
	ZERO:	.byte 0x3F
	ONE:	.byte 0x06
	TWO:	.byte 0x5b
	THREE:	.byte 0x4f
	FOUR:	.byte 0x66
	FIVE:	.byte 0x6D
	SIX:	.byte 0x7D
	SEVENT:	.byte 0x07
	EIGHT:	.byte 0x7F
	NINE:	.byte 0x6F
# Key code of  key pressed in Digi Lab Sim
key_code: .byte 0x11, 0x21, 0x41, 0x81,	
		0x12, 0x22, 0x42, 0x82,
		0x14, 0x24, 0x44, 0x84,
		0x18, 0x28, 0x48, 0x88

.text
#---------------------------------------------------------------
# main: Use INTERUPT
# main_loop
#	Show nuber by 7-segment led
#---------------------------------------------------------------
main:
	# Global variables
 	li $s0, 0		# Register s0 = 0	: No error
 				# Register s0 = -1 	: ERR: Divide by 0
 				# Register s0 = -2	: ERR: Plus overflow
 				# Register s0 = -3	: ERR: Subtraction overflow 
 				# Register s0 = -4	: ERR: Multiplitation overflow
 				# Register s0 = -5	: ERR: Input data overflow
 			
 	li $s1, 0		# Register s1: 	Store first operand value	default s1 = 0
 	li $s2, -1		# Register s2: 	Operator			default s2 = -1
 	li $s3, 0		# Register s3: 	Store second operand value	default s1 = -1
	li $s7, 0
main_loop:
	jal show_int		# Show nuber by 7-segment led
	nop

	li $t1, IN_ADRESS_HEXA_KEYBOARD
 	li $t2, OUT_ADRESS_HEXA_KEYBOARD
	jal input		# Input data from Digi Lab Sim
	nop			# 0 - 9: Operand,  10 - 13: Operator, 15: Equal sign
				# s4 0-15, s6 prev keypressed
	jal process		#
	nop			# 	Store operator value to $s2
				# 	Store operand value to $s1 of $s3
				# 	caculate when press f (=)
			
	jal handle_exception	# Catch ERRORS
	nop
main_next: 
	j main_loop		# Use loop to input data
	nop
end_main:
	# li $v0, 10	
	# syscall

#---------------------------------------------------------------
# Procedure show_int
# brief: Show operand:
#		- Haven't entered operator: 	s1
# 		- Have entered operator:	s3
# 	 If operand is nagative show '-' on the left position
# param[in] s1 first operand
# param[in] s2 operation
# param[in] s3 second operand
# param[in] $a1 value to shown in binary
#---------------------------------------------------------------
show_int:
	addi $sp, $sp, -4	
	sw $ra, 0($sp)				# Push value of Register ra to Stack
load_num:
	add $a1, $s1, $zero			# Default show the value of Register s1 on 7-segment led
	bne $s2, -1, show_s3			# if s2 is not default (entered operand), show the value of Register s3 on 7-segment led
	nop
	j show_a1_value			
	nop
	show_s3:
		add $a1, $s3, $zero		# Show the value of Register s3 on 7-segment led
	show_a1_value:			
		jal mod_10			# Procedure $v1 := $a1 mod 10
		nop
		la $t3, digit			# $t1 := adress of Array Digit
		add $t0, $t3, $v1	
		lb $a0, 0($t0)			# Set value for segments
		
		li $t0, SEVENSEG_RIGHT 		# Assign port's address
		sb $a0, 0($t0) 			# assign new value
		
		bge $a1, 0, show_left_pos	# If a1 > 0, show left position
		nop
		blt $a1, -9, show_left_pos	# If a1 < -9, show left position 
		nop
		# SHOW - (minus)
			lb $a0, NEG		# Show -
		
			li $t0, SEVENSEG_LEFT	# Assign port's address
			sb $a0, 0($t0) 			# assign new value
		
			j end_show_int		# Return
			nop
	
	show_left_pos:
		div $a1, $a1, 10		# a1 = a1 / 10
		jal mod_10			# v1 = a1 mod 10
		nop
		add $t0, $t3, $v1		
		lb $a0, 0($t0)			# Set value for segments
		
		li $t0, SEVENSEG_LEFT 		# Assign port's address
		sb $a0, 0($t0) 			# assign new value
	
end_show_int:
	lw $ra, 0($sp)				# Load $ra
	addi $sp, $sp, 4			# Pop $ra 
	jr $ra					# Return main
	nop

#---------------------------------------------------------------
# Procedure mod_10:
# brief: v1 = abs(a1 - int(a1/10) * 10)
# param[in] 	$a1 value to shown in binary
# param[out]  	$v1 = $a1 mod 10 in binary
#---------------------------------------------------------------
mod_10:
	add $v1, $a1, $zero		# t0 := a2 = input
	div $v1, $v1, 10		# v1 = input / 10
	mul $v1, $v1, 10		# v1 = v1 * 10
	sub $v1, $a1, $v1		# v1 = a1 - v1
	
	bge $a1, 0, end_mod_10		# return
	nop
	# mod 10 neg
		sub $v1, $zero, $v1	# if v1 < 0 -> v1 = -v1
end_mod_10:
	jr $ra	# return
	nop

#---------------------------------------------------------------
# Procedure input
# Digital lab sim
#	- s4: keycode of key pressed
# 	- s5: Read row 0x01 0x02 0x04 0x08
# param[out] s4: key pressed [0..15], s4 = -1 when no key is pressed
# param[out] s6: prev key pressed
#---------------------------------------------------------------
input:
loop_init:
	li 	$t3, 0x80 			# Turn on interupt bit 
	sb 	$t3, 0($t1)
	loop:		
		sleep:	addi $v0, $zero, 32
			li $a0, 1		# sleep 1ms
			syscall		
		b loop
		nop
end_input:
	jr $ra					# return
	nop
#---------------------------------------------------------------
# Procedure process
# param[in]: s1: The first operand
# param[in]: s2: Operation
# param[in]: s3: The second operand
# param[in]: s4: pressed key
# param[in]: s6: prev pressed key
#---------------------------------------------------------------
process:
	subi $sp, $sp, 4				# Push ra to Stack
	sw $ra, 0($sp)
	new_key_pressed:				# 3 case: Equal sign || Operation ||  Number
		beq $s4, 15, equal			# case 1: Equal sign
		nop
		bgt $s4, 9, new_operator		# case 2: Operation
		nop
		number:					# case 3: Number
			bne $s2, -1, add_s3		# if it is operation, input second operand
			nop
			add_s1:				# If there is no operator, input first operand
				mul $t0, $s1, 10	# s1 = s1 * 10
				
				mfhi $t1		# move valute to $t1
				beq $t1, 0, add_s1_	# if t1 == 0 -> ok  
				nop			#        != 0 -> overflow
				
				# throw error
					error_input_1:
					li $s0, -5
					j end_process	# return
					nop	
				
				add_s1_:		# if not overflow
				move $s1, $t0	
				add $s1, $s1, $s4	# s1 = s1 + s4
				
				andi $t1, $s1, 0x80000000	# t1 = s1 sign bit
				bne $t1, $zero, error_input_1
				nop
				
				# print
				li $v0, 1
				add $a0, $s4, $zero
				syscall
				
				j end_process		# return
				nop
			add_s3:				# input to second operand
				
				mul $t0, $s3, 10
					
				mfhi $t1	
				beq $t1, 0, add_s3_		# check overflow
				nop
				
				# throw error
					error_input_2:
					li $s0, -5
					j end_process
					nop
				
				add_s3_:
				move $s3, $t0
				add $s3, $s3, $s4
				# print
				li $v0, 1
				add $a0, $s4, $zero
				syscall
				
				andi $t1, $s3, 0x80000000	# t1 = s3 sign bit
				bne $t1, $zero, error_input_2
				nop	
				
				j end_process			# return
				nop
		new_operator:					# case: it is operator (+, -, *, /, %)
			#---------------- caculate result when second operator
			
			beq $s7, $zero, new_operator_		# check the first operator
			nop
			
			
			jal calculate
			nop
			bne $s0, 0, end_process			# If have error, no PRINT
			nop
			# Print result
			li $v0, 4
			la $a0, result_msg			# show result msg
			syscall
			li $v0, 1
			add $a0, $s1, $zero			# show result ( in s1 )
			syscall
			#-----------------
			# print
			new_operator_:
			addi $s7, $s7, 1			# count the operator
			
			add $s2, $zero, $s4			# s2 = s4
			jal print_operator
			nop	
			j end_process
			nop
		equal:	# Case: Equal sign = 	
			jal calculate				# Caculate 
			nop
				
			bne $s0, 0, after_print			# If have error, no PRINT
			nop
			
			# Print result
			li $v0, 4
			la $a0, result_msg			# show result msg
			syscall
			li $v0, 1
			add $a0, $s1, $zero			# show result ( in s1 )
			syscall
						
			after_print:
			j end_process				# return
			nop		
end_process:
	lw $ra, 0($sp)						# Pop ra from Stack 
	addi $sp, $sp, 4
	jr $ra							# return
	nop
#------------------------------------------------------
# Procedure calculate
# Caculate the expression
# Param[in] $s1 operand 1
# Param[in] $s2 operator 
# Param[in] $s3 operand 2
# Param[out]$s1 result, s2 := -1, s3 :=0
# Param[out]$s0 ERROR Code
#------------------------------------------------------
calculate:
	# Check the operator
	beq $s2, 10, calc_add					# s2 is plus
	nop
	beq $s2, 11, calc_sub					# s2 is subtraction
	nop
	beq $s2, 12, calc_mul					# s2 is multiplication
	nop
	beq $s2, 13, calc_div					# s2 is divide
	nop
	beq $s2, 14, calc_mod					# s2 is module
	nop
	j end_calculate						# if s2 is not operator
	nop

	calc_add:	# Plus
		andi $t1, $s1, 0x80000000			# t1 = sign bit of s1
		andi $t3, $s3, 0x80000000			# t3 = sign bit of s3
		seq $t2, $t1, $t3				# t2 = 0 if t1 and  t3 are same sign

		s1_add_s3:
			addu $t0, $s1, $s3			# t0 = s1 + s3 
			andi $t4, $t0, 0x80000000		# t4 = bit 
			# handle error
			bne $t2, 1, after_check_add_err		# If t1 and t3 are not same sign -> Don't need to check
			nop
			beq $t1, $t4, after_check_add_err	# if result is same sign with s1 -> NOT overflow
			nop
			throw_add_overflow:
				li $s0, -2			# s0 = -2: is overflow
				j calc_after			# reset and return
				nop
			
		after_check_add_err:
			add $s1, $s1, $s3			# s1 = s1 + s3 
		
		j calc_after					# reset s2 = -1, s3 = 0
		nop
	calc_sub:	# Subtraction
		andi $t1, $s1, 0x80000000			# t1 = sign bit s1
		andi $t3, $s3, 0x80000000			# t3 = sign bit s3
		sne $t2, $t1, $t3				# t2 = 1 if t1 and  t3 are not same sign
		bne $t2, 1, after_check_sub_err			# if t1 and t3 is same sign -> Not overflow
		s1_sub_s3:
			subu $t0, $s1, $s3			# t0 = s1 - s3
			andi $t4, $t0, 0x80000000		# t4 = sign bit of t0
			nop
			beq $t1, $t4, after_check_sub_err	# if result and s1 are same sign -> NOT overflow
			nop
			throw_sub_overflow:
				li $s0, -3			# s0 = -3: sub overflow
				j calc_after			# reset and return
				nop
			
		after_check_sub_err:
		sub $s1, $s1, $s3				# s1 = s1 - s3
		
		j calc_after
		nop
		
	calc_mul:	# Multiplication
		mul $t0, $s1, $s3				# t0 = s1 * s3
		mfhi $t1
		beq $t1, 0, calc_mul_
		nop
		# handle error
			li $s0, -4	
			j calc_after
			nop
		calc_mul_:
		move $s1, $t0					# s1 = t0
		j calc_after
		nop
	calc_div:	# Divide
		bne $s3, 0, divisor_neq_zero			# if not divide by zero
		nop
		# divisor_eq_zero:				# if divide by zero
			li $s0, -1				# throw error
			j calc_after
			nop
	
		divisor_neq_zero:				# if s3 != 0
			div $s1, $s1, $s3			# s1 = s1 / s3
			j calc_after
			nop
	calc_mod:	# Module
		div $t0, $s1, $s3
		mul $t0, $t0, $s3
		sub $s1, $s1, $t0
		bge $s1, 0, calc_after		# return
		nop
		# s1 is neg
			sub $s1, $zero, $s1	# if s1 < 0 -> s1 = -s1
		j calc_after
		nop
	calc_after:	# Reset second operand, reset operator
		li $s3, 0					# reset second operand
		li $s2, -1					# reset operator = -1

end_calculate:	
	jr $ra
	nop
# ---------------------------------------------
# Procedure print_operator
# Print operator
# param[in]: s1: phep tinh 
# 	- Plus: 	s1 = 0xa
#	- Subtraction:	s1 = 0xb
#	- ...
# ---------------------------------------------
print_operator:	
	beq $s2, 10, print_add	# s2 == 10 : Plus
	nop
	beq $s2, 11, print_sub	# s2 == 11 : Subtraction
	nop
	beq $s2, 12, print_mul	# s2 == 12 : Multiplication
	nop
	beq $s2, 13, print_div	# s2 == 13 : Divide
	nop
	beq $s2, 14, print_mod	# s2 == 14 : Module
	nop
	j end_print_operator	# End print operator
	nop
	
	print_add:
		la $a0, add_msg
		j print_operator_
		nop
	print_sub:
		la $a0, sub_msg
		j print_operator_
		nop
	print_mul:
		la $a0, mul_msg

		j print_operator_
		nop
	print_div:
		la $a0, div_msg
		j print_operator_
		nop		
	print_mod:
		la $a0, mod_msg
		j print_operator_
		nop
	print_operator_:
		li $v0, 4
		syscall
end_print_operator:	
	jr $ra
	nop
#------------------------------------------------------
# Handle eror
# Print ERR if has
# Param[in]: $s0 ERROR CODE
#----------------------------------------------------
handle_exception:
	beq $s0, -1, handle_div_err		# ERR: Divide by zero
	nop
	beq $s0, -2, handle_add_overflow	# ERR: Plus overflow 
	nop
	beq $s0, -4, handle_mul_overflow
	nop
	beq $s0, -3, handle_sub_overflow	
	nop
	beq $s0, -5, handle_input_overflow
	nop
	j reset_err
	nop
	handle_div_err:
		li $s3, 0	# reset second operand
		la $a0, div_err_msg
		li $v0, 4		
		syscall
		li $v0, 1	# Print result
		add $a0, $s1, $zero
		syscall	
		j reset_err
		nop
	handle_add_overflow:
		li $s3, 0	# reset second operand
		la $a0, add_overflow_msg
		li $v0, 4		
		syscall
		li $v0, 1	# Print result
		add $a0, $s1, $zero
		syscall	
		j reset_err
		nop
	handle_input_overflow:
		li $s3, 0	# reset second operand
		la $a0, input_overflow_msg
		li $v0, 4		
		syscall
		li $v0, 1	# Print result
		add $a0, $s1, $zero
		syscall	
		j reset_err
		nop
	handle_sub_overflow:
		li $s3, 0	# reset second operand
		la $a0, sub_overflow_msg
		li $v0, 4		
		syscall
		li $v0, 1	# Print result
		add $a0, $s1, $zero
		syscall	
		j reset_err
		nop
	handle_mul_overflow:
		li $s3, 0	# reset second operand
		la $a0, mul_overflow_msg
		li $v0, 4		
		syscall
		li $v0, 1	# Print result
		add $a0, $s1, $zero
		syscall	
		j reset_err
		nop
	reset_err:				
		li $s0, 0	# reset error
		
end_handle_exception:	
	jr $ra
	nop
	
.ktext 0x80000180
	get_cod:
	li $t1, IN_ADRESS_HEXA_KEYBOARD
 	li $t2, OUT_ADRESS_HEXA_KEYBOARD
	li 	$t3, 0x81			# Check Row 1
	sb 	$t3, 0($t1)
	lbu 	$a0, 0($t2)
	bne	$a0, $zero, continue	
	
	li 	$t3, 0x82			# Check Row 2
	sb 	$t3, 0($t1)
	lbu 	$a0, 0($t2)
	bne	$a0, $zero, continue
	
	li 	$t3, 0x84			# Check Row 3
	sb 	$t3, 0($t1)
	lbu	$a0, 0($t2)
	bne	$a0, $zero, continue	

	li 	$t3, 0x88			# Check Row 4
	sb 	$t3, 0($t1)
	lbu 	$a0, 0($t2)
	bne	$a0, $zero, continue		
continue:
	# Return value to $a0 = KEYPRESSED CODE
	map_key: 
	li $t7, 0				# index
	la $t9, key_code			# load arr
	map_key_loop:
		add $t6, $t9, $t7
		lbu $t8, 0($t6)			# arr[i]
		beq $a0, $t8, map_key_return_value
		nop	
		beq $t7, 15, end_map_key
		nop
		
		map_key_next:
		addi $t7, $t7, 1		# index = index + 1	
		j map_key_loop
		nop
		
	map_key_return_value:
		add $s4, $t7, $zero		# set return value
	
	#li $v0, 1
	#add $a0, $s4, $zero
	#syscall
end_map_key:

next_pc:mfc0 	$at, $14
	addi 	$at, $at, 4
	mtc0 	$at, $14
return: eret
