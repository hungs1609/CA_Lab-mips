# Final term Project
# Subject: 5
# Convert infix to NPM and evaluate result 
.eqv QUEUE_NODE_SIZE 8
.eqv QUEUE_SIZE 8

.eqv QUEUE_NODE_NEXT 0
.eqv QUEUE_NODE_DATA 4

.eqv QUEUE_FRONT 0
.eqv QUEUE_BACK 4


.eqv STACK_NODE_SIZE 8
.eqv STACK_SIZE 4

.eqv STACK_NODE_NEXT 0
.eqv STACK_NODE_DATA 4

.eqv STACK_BACK 0

.data
	tmp_str: .space 32
	tmp_str2: .space 32
	infix_str: .space 128
	max_byte: .word 128
	postfix_str: .space 256 
	msg1: .asciiz "Input infix: "
	msg2: .asciiz "Equivalent postfix: "
	msg3: .asciiz "Result: "
	msg_err1: .asciiz "Input error\n"
	msg_err2: .asciiz "Evaluate input error\n"
	
	home1: .asciiz "              INFIX TO POSTFIX\n"
	home2: .asciiz "1. Convert infix to postfix and evaluate\n"
	home3: .asciiz "2. Exit\n"
	home4: .asciiz "Enter your choice: "
	home_exit: .asciiz "Exitting the program\n"
	home_err1: .asciiz "Invalid choice\n"

.text
.globl main
main:
	# $t0 - choice int
	main_do_while_loop:
		# print out the menu 
		la $a0, home1
		li $v0, 4
		syscall 
		
		la $a0, home2
		li $v0, 4
		syscall 
		
		la $a0, home3
		li $v0, 4
		syscall 
		
		# choice
		la $a0, home4
		li $v0, 4
		syscall 
		
		# read int
		li $v0, 5
		syscall 
		move $t0, $v0 		# $t0 = choice 
		
		bne $t0, 1, mdwl_not_one
		# if we're here run the function first choice
		jal first_choice
		
		j main_do_while_loop
		mdwl_not_one:
		bne $t0, 2, mdwl_not_two 
		# two exit 
		
		la $a0, home_exit
		li $v0, 4
		syscall 
		
		j end_main_do_while_loop
		mdwl_not_two:
		# invalid input 
		
		la $a0, home_err1
		li $v0, 4
		syscall 
		
		li $a0, '\n'
		li $v0, 11
		syscall 
		
		j main_do_while_loop
	end_main_do_while_loop:
	
end:	
	li $v0, 10
	syscall
	
# @brief: function run the first choice
# @param: void
# @return: void
# @variables:
#		$s0 - address of string 
#		$s1 - address of return queue 
#		$s2 - result
#		$s3 - $ra
first_choice:
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	
	# print new line for clarity
	li $a0, '\n'
	li $v0, 11
	syscall 
	
	move $s3, $ra	

	la $s0, infix_str
	
	# print input prompt
	la $a0, msg1
	li $v0, 4
	syscall  
	
	# read the string 
	move $a0, $s0
	lw $a1, max_byte
	li $v0, 8
	syscall 
	
	# remove all spaces 
	move $a0, $s0 
	jal remove_white_spaces	
	
	# convert to postfix and return a queue pointer
	move $a0, $s0 
	jal infix_to_postfix
	move $s1, $v0 				# $s1 has the queue pointer 
	
	beq $v0, 0, fc_itp_error
	
	# print message for the postfix
	la $a0, msg2
	li $v0, 4
	syscall 
	
	# print out the queue content 
	move $a0, $s1 
	jal print_queue_str
	
	# print newline for clarity 
	li $a0, '\n'
	li $v0, 11
	syscall 
	
	# evaluate the expression 
	move $a0, $s1 
	jal evaluate_postfix 
	# save result 
	move $s2, $v0 
	
	
	beq $v1, -1, fc_ep_error
	
	# print result message 
	la $a0, msg3
	li $v0, 4
	syscall 
	
	# print result 
	move $a0, $s2
	li $v0, 1
	syscall 
	
	# print new line for clarity 
	li $a0, '\n'
	li $v0, 11
	syscall 
	
	j end_first_choice

	fc_itp_error:
		la $a0, msg_err1
		li $v0, 4
		syscall 
		j end_first_choice
		
	fc_ep_error:
		la $a0, msg_err2
		li $v0, 4
		syscall 
		j end_first_choice
	
end_first_choice:
	# print newline for clarity 
	li $a0, '\n'
	li $v0, 11
	syscall 
	
	move $ra, $s3
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 16
	jr $ra



# @brief: 	function evaluate postfix notation
#			will take a queue pointer as input 
#			assume the expression is contained in a queue
# @param:
#			$a0 - address of queue
# @return:
#			$v0 - the result
#			$v1 - status 0 success -1 for failure
# @variables:
#			$s0 - address of queue
#			$s1 - address of stack
#			$s2 - queue.front()
#			$s3 - stack.head()
#			$s4 - $ra
#			$s5 - first number
#			$s6 - second number
evaluate_postfix:
	addi $sp, $sp, -28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	
	move $s4, $ra				# save $ra
	move $s0, $a0 				# $s0 = input queue
	jal init_stack 
	move $s1, $v0 				# $s1 = new stack
	
	ei_while_loop:
		move $a0, $s0 
		jal queue_is_empty
		beq $v0, 1, end_ei_while_loop
	
		# get queue front
		move $a0, $s0 
		jal queue_front
		move $s2, $v0 			# $s2 = queue.front()
		
		move $a0, $s2
		jal op_prec
		bne $v0, -1, ei_is_operator
		
		ei_is_number:
			# the queue.front() is a number in string need to be converted 
			# convert to int
			sw $s2, tmp_str2
			la $a0, tmp_str2
			jal str_to_uint
			
			# push it on to the stack
			move $a0, $s1
			move $a1, $v0
			jal stack_push_back
		  	
			j ei_converge
		ei_is_operator:
			# the queue.front() is an opeartor
			# try to pop the first number of the stack
			move $a0, $s1
			jal stack_back
			
			beq $v1, -1, ei_error
			
			# if we're here the first one is present 
			move $s5, $v0 		# assign it to $s5
			move $a0, $s1
			jal stack_pop_back   # actually popping
			
			# try to pop the second number of the stack 
			move $a0, $s1
			jal stack_back
			
			beq $v1, -1, ei_error
			
		    # if we're here the second one is present
		    move $s6, $v0 		# assign it to $s6
		    move $a0, $s1
		    jal stack_pop_back    # actually popping
		
		    	# calculate the result 
		    move $a0, $s6
		    move $a1, $s5
		    move $a2, $s2
		    jal binary_op	
		       
		    	# push it onto the stack
		    	move $a0, $s1 
			move $a1, $v0
			jal stack_push_back
			
		ei_converge:
		
		move $a0, $s0 
		jal queue_pop_front
		j ei_while_loop
	end_ei_while_loop:
	
	# if we are here then the result is the final number in the stack just pop it
	move $a0, $s1, 
	jal stack_back		# i didn't pop it here because i didnt need to 
	
	li $v1, 0
	j end_evaluate_postfix	
	ei_error:
		li $v1, -1
	
end_evaluate_postfix:
	move $ra, $s4
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	addi $sp, $sp, 28
	jr $ra

# @brief: return the result of operation on 2 integers
#		 assumes inputs are valid
# @param:
#		$a0 - a
#		$a1 - b
#		$a2 - operator (+, -, *, /, %)
# @return:
#		$v0 - result
# @variables:
#		$s0 - $a0
#		$s1 - $a1
#		$s2 - $a2
binary_op:
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	
	bne $s2, '+', bo_not_plus
	
	add $v0, $s0, $s1
	j bo_converge
	
	bo_not_plus:
	bne $s2, '-', bo_not_minus
	
	sub $v0, $s0, $s1
	j bo_converge
	
	bo_not_minus:
	bne $s2, '*', bo_not_mul
	
	mul $v0, $s0, $s1
	j bo_converge
	
	bo_not_mul:
	bne $s2, '/', bo_not_div
	
	div $s0, $s1
	mflo $v0
	j bo_converge
	bo_not_div:
	bne $s2, '%', bo_not_mod
	
	div $s0, $s1
	mfhi $v0 
	j bo_converge
	bo_not_mod:
	bo_converge:

end_binary_op:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12
	jr $ra


# @brief: return the precendence of an operator 
# @param:
#		$a0 - op
# @return:
#		$v0 - 1 if $a0 == '+' || $a0 == '-'
#		$v0 - 2 if $a0 == '*' || $a0 == '/' || $a0 == '%'
#		$v0 - -1 if otherwise (not an operator)
op_prec:
	li $v0, -1			# init ret = -1
		
	bne $a0, '+', op_prec_not_plus	
	
	li $v0, 1
	j end_op_prec
	
	op_prec_not_plus:	
	bne $a0, '-', op_prec_not_minus
	
	li $v0, 1
	j end_op_prec
	
	op_prec_not_minus:
	
	bne $a0, '*', op_prec_not_mul
	
	li $v0, 2
	j end_op_prec
	
	op_prec_not_mul:
	bne $a0, '/', op_prec_not_div
	
	li $v0, 2
	j end_op_prec
	op_prec_not_div:
	bne $a0, '%', op_prec_not_mod
	
	li $v0, 2
	j end_op_prec

	op_prec_not_mod:

end_op_prec: 
	jr $ra


# @brief: 	convert a string of infix notation to postfix 
#			assume the input has no white spaces
#			will check if the input is invalid
#			the original input will be left untouched
#			the function will return pointed to a queue allocated on the heap
#			which contains the result
# @param:
#			$a0 - address of the source infix notation
# @return:	
#			$v0 - address of queue if fail will be set to NULL
# @variables:
#			$t0 - i
#			$t1 - strlen($s0)
#			$t2 - address of temp string (global) 
#			$s0 - address of input string
#			$s1 - string queue
#			$s2 - character stack 
#			$s3 - stack.back()
#			$s4 - $ra
#			$s5 - address of string + i
#			$s6 - string[i]
#			$s7 - op_prec($s6)
#			$t3 - return value ($v0)
#			$t4 - k
#			$t5 - prec(current)
#			$t6 - prec(top)
infix_to_postfix:
	addi $sp, $sp, -60
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $s0, 12($sp)
	sw $s1, 16($sp)
	sw $s2, 20($sp)
	sw $s3, 24($sp)
	sw $s4, 28($sp)
	sw $s5, 32($sp)
	sw $s6, 36($sp)
	sw $s7, 40($sp)
	sw $t3, 44($sp)
	sw $t4, 48($sp)
	sw $t5, 52($sp)
	sw $t6, 56($sp)
	
	move $s4, $ra			# save $ra
	move $s0, $a0 			# $s0 = address of string
	
	
	
	jal init_queue
	move $s1, $v0 			# $s1 = queue
	
	jal init_stack 
	move $s2, $v0 			# $s2 = stack
	
	move $t3, $s1 			# init the pointer
	
	move $a0, $s0 
	jal strlen
	
	move $t1, $v0			# $t1 = strlen($s0)
	la $t2, tmp_str			# $t2 = address of temp_str
	li $t0, 0				# $t0 = i = 0
	infix_to_postfix_for_loop:
		bge $t0, $t1, end_infix_to_postfix_for_loop	# if i >= strlen($s0) end loop
		add $s5, $s0, $t0 							# $s5 = address of string + i
		lb $s6, 0($s5)								# $s6 = string[i]
		
		move $a0, $s6
		jal op_prec
		move $s7, $v0 								# $s7 = op_prec($s6)
		
		blt $s6, '0', itpfl_not_a_digit
		bgt $s6, '9', itpfl_not_a_digit
		
		move $t4, $t0 								# k = i 									
		itp_while_loop1:
			add $s5, $s0, $t4						# $s5 = address string[$t4]
			lb $s6, 0($s5)							# $s6 = string[$t4]
			
			blt $s6, '0', end_itp_while_loop1
			bgt $s6, '9', end_itp_while_loop1
			
			addi $t4, $t4, 1
			j itp_while_loop1
		end_itp_while_loop1:	
		
		# call substrcpy
		move $a0, $t2			# dest
		move $a1, $s0			# source
		move $a2, $t0			# start
		addi $a3, $t4, -1		# end
		addi $sp, $sp, -4
		li $v0, 4
		sw $v0, 0($sp)
		jal substrcpy
		
		move $a0, $s1
		lw $a1, 0($t2)
		jal queue_push_back
		
		move $t0, $t4
		j infix_to_postfix_for_loop
		
		itpfl_not_a_digit:
		bne $s6, '(', itpfl_not_open_paren
		
		# $s6 == '('
		move $a0, $s2
		move $a1, $s6
		jal stack_push_back
		
		j itpfl_done_for_iteration
		itpfl_not_open_paren:
		bne $s6, ')', itpfl_not_close_paren
		# is closing paren
		
		itp_while_loop2:
			move $a0, $s2
			jal stack_is_empty
			beq $v0, 1, end_itp_while_loop2			# if stack is empty then stop loop
		
			move $a0, $s2 
			jal stack_back
			move $s3, $v0 							# $s3 = stack->top->data
		
			beq $s3, '(', end_itp_while_loop2			# $s3 == '(' stop loop
			
			move $a0, $s1
			move $a1, $s3 
			jal queue_push_back						# queue.push_back($s3)
			
			move $a0, $s2
			jal stack_pop_back
		
		end_itp_while_loop2:
		
		move $a0, $s2
		jal stack_back
		move $s3, $v0 
		
		bne $s3, '(', itp_error						# if the top is not '(' then bad paren
		
		move $a0, $s2								# pop the '('
		jal stack_pop_back

		j itpfl_done_for_iteration					# jump to the next iteration
		itpfl_not_close_paren:
		beq $s7, -1, itpfl_not_operator
		# is an operator
		
		itp_while_loop3:
			move $a0, $s2
			jal stack_is_empty
			beq $v0, 1, end_itp_while_loop3			# if stack is empty then stop loop
			
			move $a0, $s2 
			jal stack_back
			move $s3, $v0 							# $s3 = stack->top->data
		
			move $a0, $s3							# $a0 = stack->top->data
			jal op_prec
			move $t6, $v0							# $t6 = op_prec(top)
			
			move $a0, $s6 							# $a0 = current op
			jal op_prec
			move $t5, $v0 							# $t5 = op_prec(cur)
			
			blt $t6, $t5, end_itp_while_loop3
			
			move $a0, $s1							# queue.push(stack.top)
			move $a1, $s3
			jal queue_push_back
			
			move $a0, $s2							# stack.pop
			jal stack_pop_back
			
			j itp_while_loop3
		end_itp_while_loop3:
		move $a0, $s2
		move $a1, $s6
		jal stack_push_back		
		
		j itpfl_done_for_iteration
				
		itpfl_not_operator:										
		li $t3, 0				# if we're here a char is invalid return and $v0 = -1
		j end_infix_to_postfix
		
		itpfl_done_for_iteration:
		addi $t0, $t0, 1
		j infix_to_postfix_for_loop

	end_infix_to_postfix_for_loop:

	itp_while_loop4:
		move $a0, $s2
		jal stack_is_empty
		beq $v0, 1, end_itp_while_loop4			# if stack is empty then stop loop
	
		move $a0, $s2 
		jal stack_back
		move $s3, $v0 							# $s3 = stack->top->data
		
		beq $s3, '(', itp_error					# if the stack contains '(' that means bad parens
		
		move $a0, $s1
		move $a1, $s3
		jal queue_push_back						# push remaining elements into queue
		
		move $a0, $s2							# pop it
		jal stack_pop_back
		j itp_while_loop4
	end_itp_while_loop4:
	
	j end_infix_to_postfix
		
	itp_error:
		li $t3, 0

end_infix_to_postfix:
	
	move $v0, $t3
	move $ra, $s4
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $s0, 12($sp)
	lw $s1, 16($sp)
	lw $s2, 20($sp)
	lw $s3, 24($sp)
	lw $s4, 28($sp)
	lw $s5, 32($sp)
	lw $s6, 36($sp)
	lw $s7, 40($sp)
	lw $t3, 44($sp)
	lw $t4, 48($sp)
	lw $t5, 52($sp)
	lw $t6, 56($sp)

	addi $sp, $sp, 60
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


# @brief function to allocate memory for a node
init_queue_node:
	li $a0, QUEUE_NODE_SIZE
	li $v0, 9
	syscall
end_init_queue_node:
	jr $ra
	
# @brief: function to allocate memory for a queue
init_queue:
	li $a0, QUEUE_SIZE
	li $v0, 9
	syscall
end_init_queue:
	jr $ra

# @brief: function to check if queue is empty
# @param:
#		$a0 - address of queue
# @return:
#		$v0 - 1 if yes, 0 if no 
# @variables:
#		$s0 - queue->back
queue_is_empty:
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	li $v0, 0 				# init to be not empty
	lw $s0, QUEUE_BACK($a0)
	
	beq $s0, 0, queue_empty_true
	
	j end_queue_is_empty
	queue_empty_true:
		li $v0, 1
end_queue_is_empty:
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	jr $ra

# @brief: function to push to the back of the queue 
# @param: 
#		$a0 - address of queue
#		$a1 - data
# @return: void
# @variables:
#		$s0 - address of queue ($a0) 
#		$s1 - data ($a1)
#		$s2 - new node
#		$s3 - queue->back
#		$s4 - $ra
queue_push_back:
	addi $sp, $sp, -20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	
	move $s4, $ra
		
	move $s0, $a0 				# $s0 = address of queue
	move $s1, $a1				# $s1 = data
	jal init_queue_node
	move $s2, $v0 				# $s2 = new node
	
	sw $s1, QUEUE_NODE_DATA($s2)	# $s2->data = data
	
	lw $s3, QUEUE_BACK($s0)		# $s3 = queue->back
	bne $s3, 0, queue_push_back_second_case		# if $s3 != NULL queue is not empty
	queue_push_back_first_case:
		sw $s2, QUEUE_BACK($s0)
		sw $s2, QUEUE_FRONT($s0)
		j end_queue_push_back
	queue_push_back_second_case:
		sw $s2, QUEUE_NODE_NEXT($s3)
		sw $s2, QUEUE_BACK($s0)
		
end_queue_push_back:
	move $ra, $s4
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	addi $sp, $sp, 20
	jr $ra

# @brief: function to get the front data of the queue
# @params:
#		$a0 - address of queue
# @return:
#		$v0 - data 
#		$v1 - 0 for success, -1 for failure
# @variables
#		$s0 - address of queue
#		$s1 - queue->front
#		$s1 - queue->front->data
#		$s2 - queue_is_empty(queue)
#		$s3 - $ra
queue_front:
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	
	move $s3, $ra
	
	move $s0, $a0 				# $s0 = address of queue
	jal queue_is_empty
	
	move $s2, $v0 
	beq $s2, 0, queue_front_not_empty	# $s2 == 0 means queue is not empty
	
	# if we are here then queue is empty
	li $v0, 0
	li $v1, -1
	j end_queue_front
	
	queue_front_not_empty:
		lw $s1, QUEUE_FRONT($s0)
		lw $s1, QUEUE_NODE_DATA($s1)
		
		move $v0, $s1
		li $v1, 0
	
end_queue_front:
	move $ra, $s3
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 16
	jr $ra
	

# @brief: function to pop the front of the queue
# @params:
#		$a0 - address of queue
# @variables:
#		$s0 - address of queue
#		$s1 - queue->front
#		$s2 - queue->front->next
#		$s3 - $ra
#		$s4 - return
#		$t0 - queue->back
#		$t1 - temp
# @return:
#		$v0 - status 0 for success -1 for failure
queue_pop_front:
	addi $sp, $sp, -28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $t0, 20($sp)
	sw $t1, 24($sp)
	move $s3, $ra
	
	li $s4, 0
	move $s0, $a0 				# $s0 = address of queue
	
	move $a0, $s0 
	jal queue_is_empty
	beq $v0, 1, queue_pop_empty_true
	
	# need to check if there's 1 element or not 
	lw $t0, QUEUE_BACK($s0)
	
	lw $s1, QUEUE_FRONT($s0)		# $s1 = queue->front
	
	beq $t0, $s1, qpf_one_node
	# if we're here there are more than 1 node
	lw $s2, QUEUE_NODE_NEXT($s1)  # $s2 = queue->front->next
	sw $s2, QUEUE_FRONT($s0)		# queue->front = $s2
	j end_queue_pop_front
	qpf_one_node:
	li $t1, 0
	sw $t1, QUEUE_BACK($s0)
	sw $t1, QUEUE_FRONT($s0)	
	
	j end_queue_pop_front
	queue_pop_empty_true:
		li $s4, -1
	
end_queue_pop_front:
	move $v0, $s4
	move $ra, $s3
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $t0, 20($sp)
	lw $t1, 24($sp)
	addi $sp, $sp, 28
	jr $ra

# @brief: function to print queue assume the elements are string
# @params:
#		$a0 - address of queue
# @return: void
print_queue_str:
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	move $s0, $a0 
	lw $s0, QUEUE_FRONT($s0)
	
	print_queue_str_loop:
		beq $s0, 0, end_print_queue_int_loop
		addi $a0, $s0, QUEUE_NODE_DATA 
		li $v0, 4
		syscall 
		
		li $a0, ' '
		li $v0, 11
		syscall 
		
		lw $s0, QUEUE_NODE_NEXT($s0)
		j print_queue_str_loop
	
	end_print_queue_str_loop:

	
end_print_queue_str:
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	jr $ra

# @brief: function to print queue assume the elements are integer
# @params: 
#		$a0 - address of queue
# @return: void
print_queue_int:
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	move $s0, $a0
	lw $s0, QUEUE_FRONT($s0)				# $s0 = queue->front
	
	print_queue_int_loop:
		beq $s0, 0, end_print_queue_int_loop
		lw $a0, QUEUE_NODE_DATA($s0)		# $a0 = $s0->data
		li $v0, 1
		syscall 
		
		li $a0, ' '
		li $v0, 11
		syscall 
		
		lw $s0, QUEUE_NODE_NEXT($s0)
		j print_queue_int_loop
	end_print_queue_int_loop:
end_print_queue_int:
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	jr $ra


# HELPER FILES FOR MAIN


# @brief: 
#		function that copies a substring from a specified string to a specified buffer
#		based on the given start and end index  
# @param: 
#		$a0 - dest
#		$a1 - source
#		$a2 - start index
#		$a3 - end index
#		0($fp) - dest size (in bytes)
# @return: 
#		$v0 - 0 if success 1 if fail
# @variables:
#		$t0 - i 
#		$t1 - j
#		$t2 - dest size
#		$t3 - start
#		$t4 - end
#		$t5 - end - start + 1
#		$t6 - strlen(source) - 1
#		$s0 - address of dest
#		$s1 - address of source
#		$s2 - address of dest + j
#		$s3 - address of source + i
#		$s4 - source[i]
#		$s5 - preserve $ra
#		$s6 - return value ($v0)
substrcpy:
	move $fp, $sp			# save the current stack frame
	addi $sp, $sp, -56
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $t6, 24($sp)
	sw $s0, 28($sp)
	sw $s1, 32($sp)
	sw $s2, 36($sp)
	sw $s3, 40($sp)
	sw $s4, 44($sp)
	sw $s5, 48($sp)
	sw $s6, 52($sp)

	move $s5, $ra
	move $s0, $a0			# dest
	move $s1, $a1			# source
	lw $t2, 0($fp)			# dest size
	move $t3, $a2			# start
	move $t4, $a3			# end
	li $s6, 0				# init with okay status
	
	move $a0, $a1
	jal strlen
	addi $t6, $v0, -1		# $t6 = strlen(source) - 1
	
	
	# check if start and end index is valid
	bgt $t3, $t4, substrerr
	blt $t3, 0, substrerr
	bgt $t4, $t6, substrerr
	
	# check if dest has enough space
	sub $t5, $t4, $t3
	addi $t5, $t5, 1 			# $t5 = end - start + 1
	ble $t2, $t5, substrerr
	
	move $t0, $t3
	li $t1, 0
	substrcpy_loop:
		bgt $t0, $t4, end_substrcpy_loop
		
		add $s2, $s0, $t1				# address of dest + j
		add $s3, $s1, $t0 				# address of source + i
		lb $s4, 0($s3)					# $s4 = source[i]
		
		sb $s4, 0($s2)					# dest[j] = source[i]
		
		addi $t1, $t1, 1
		addi $t0, $t0, 1
		j substrcpy_loop
	end_substrcpy_loop:
	
	# add null char to the end of dest
	li $v0, 0
	add $s2, $s0, $t1
	sb $v0, 0($s2)
	j end_substrcpy
	
	substrerr:
		li $s6, 1

end_substrcpy:
	move $ra, $s5
	move $v0, $s6
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $t6, 24($sp)
	lw $s0, 28($sp)
	lw $s1, 32($sp)
	lw $s2, 36($sp)
	lw $s3, 40($sp)
	lw $s4, 44($sp)
	lw $s5, 48($sp)
	lw $s6, 52($sp)
	addi $sp, $sp, 56
	addi $sp, $sp, 4		# because we pass in 1 variable through the stack
	jr $ra


# @brief: function to convert from string to unsigned int 
# @param: 	 $a0 - address of string
# @return:    $v0 - the unsigned int (0 if failure)
#			 $v1 - status code (0 for success 1 for failure) 
# @varibles:
#			 $t0 - i (first counter) 
#			 $t1 - length of str - 1
#			 $t2 - j (second counter)
#			 $t3 - length of str - 1 - i
#			 $s0 - address of str
#			 $s1 - address of str + i 
#			 $s2 - str[i]
#			 $s3 - converted digit
#			 $s4 - save $ra 
#			 $s5 - return uint (will be moved into $v0)
#			 $s6 - return status (will be moved into $v1)
#			 $s7 - multipler of 10

str_to_uint:
	addi $sp, $sp, -48
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $s2, 24($sp)
	sw $s3, 28($sp)
	sw $s4, 32($sp)
	sw $s5, 36($sp)
	sw $s6, 40($sp)
	sw $s7, 44($sp)
	
	move $s4, $ra
	move $s0, $a0			# $s0 = address of str
	li $s5, 0				# init return uint = 0
	li $s6, 0				# init return status = 0
	
	
	# $a0 already contain the address of str	 
	jal strlen
	addi $t1, $v0, -1		# $t1 = strlen(str) - 1
	move $t0, $t1			# $t0 = strlen(str) - 1
	
	str_to_uint_loop1:
		blt $t0, 0, end_str_to_uint
		
		add $s1, $s0, $t0 	# $s1 = address of(str) + i
		lb $s2, 0($s1)		# $s2 = str[i]
		
		blt $s2, '0', stu_error	# if str[i] is not valid (i.e < '0' or > '9' jump to error)
		bgt $s2, '9', stu_error
					
		sub $s3, $s2, '0'		# $s3 = digit value
		li $s7, 1				# mul = 1
		li $t2, 0				# j = 0
		sub $t3, $t1, $t0		# $t3 = strlen(str) - 1 - $t0(i)
		str_to_uint_loop2:
			beq $t2, $t3, end_str_to_uint_loop2
			mul $s7, $s7, 10
			addi $t2, $t2, 1
			j str_to_uint_loop2
		end_str_to_uint_loop2:
		
		mul   $v0, $s3, $s7		# $v0 = $s3 * $s7
		add $s5, $s5, $v0	    # return = return + $s3 * $s7
		
		addi $t0, $t0, -1
		j str_to_uint_loop1
	end_str_to_uint_loop1:
	
	j end_str_to_uint			# skip the error
	
	stu_error:
		li $s5, 0
		li $s6, 1

end_str_to_uint:
	move $ra, $s4
	move $v0, $s5
	move $v1, $s6
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $s0, 16($sp)
	lw $s1, 20($sp)
	lw $s2, 24($sp)
	lw $s3, 28($sp)
	lw $s4, 32($sp)
	lw $s5, 36($sp)
	lw $s6, 40($sp)
	lw $s7, 44($sp)
	addi $sp, $sp, 48
	jr $ra


# @brief : find the length of string excluding newline and null
# @param: a0 - address of string
# @return: v0 - length of string
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

# @brief: removes all space in string, it will mutate the input string 
# @params:
#		$a0 - address of string
# @return: void 
# @variables:
#		$t0 - i
#		$t1 - j
#		$s0 - adddress of string 
#		$s1 - address of string + i
#		$s2 - address of string + j
#		$s3 - string[i]
remove_white_spaces:
	addi $sp, $sp, -24
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $s0, 8($sp)
	sw $s1, 12($sp)
	sw $s2, 16($sp)
	sw $s3, 20($sp)
	
	move $s0, $a0 
	li $t0, 0
	li $t1, 0
	
	remove_white_spaces_loop:
		add $s1, $s0, $t0 		# $s1 = address string + i
		lb $s3, 0($s1) 			# $s3 = string[i]
		beq $s3, 0, end_remove_white_spaces_loop

		beq $s3, ' ', remove_white_spaces_loop_continue
		
		add $s2, $s0, $t1		# $s2 = address of string + j
		sb $s3, 0($s2)			# string[j] = str[i]
		addi $t1, $t1, 1			# j = j + 1
						
		remove_white_spaces_loop_continue:
		addi $t0, $t0, 1
		j remove_white_spaces_loop
	
	end_remove_white_spaces_loop:
	add $s2, $s0, $t1 
	li $v0, 0
	sb $v0, 0($s2)

end_remove_white_spaces:
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $s0, 8($sp)
	lw $s1, 12($sp)
	lw $s2, 16($sp)
	lw $s3, 20($sp)
	addi $sp, $sp, 24
	jr $ra


