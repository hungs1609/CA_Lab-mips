.eqv SEVENSEG_LEFT 0xFFFF0010 # Dia chi cua den led 7 doan trai.
.eqv SEVENSEG_RIGHT 0xFFFF0011 # Dia chi cua den led 7 doan phai

.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012 
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014 
.data
Message: .asciiz "\nJump to state "
Message2: .asciiz "\nKet qua tinh toan =  "
Message3: .asciiz "\nKey scan code " 
Overflow_Error: .asciiz "Vuot qua gioi han nhap cho phep : Stack OverFlow"
Logic_Error: .asciiz "Khong the chia mot so cho 0"
.text
main:
 # Enable interrupts you expect 
 #--------------------------------------------------------- 
 # Enable the interrupt of Keyboard matrix 4x4 of Digital Lab Sim 
 	li $k0, IN_ADDRESS_HEXA_KEYBOARD 
 	li $k1, OUT_ADDRESS_HEXA_KEYBOARD 
 	li $t9, 0x80 # bit 7 = 1 to enable 
 	sb $t9, 0($k0) 	
 	
 	li $s0, 0 #Luu gia tri cua toan hang thu nhat
 	li $s1, 0 #Luu gia tri cua toan hang thu hai
 	li $s2, 0 #Trang thai hoat dong
 	# 0- Trang thai khoi tao
 	# 1- Trang thai nhap so thu nhat
 	# 2- Trang thai cho so thu hai
 	# 3- Trang thai nhap so thu hai
 	# 4- Trang thai tinh toan va hien thi ket qua
 	li $s3, 0 # 0- Normal Calculation Mode, 1 - Continuous Calculation Mode
 	li $s4, 0 # Exception Code
 	# 0 - No exception, 1 - overflow, 2 - divide/mod for 0
 	li $s5, 0
 	#s5 is the operator state
 	# 1-plus, 2-minus, 3-mult, 4-div, 5-mod the rest for null
 	
 	
loop: nop
sleep: 	addi $v0,$zero,32 
 	li $a0,300 # sleep 300 ms 
 	syscall 
 	nop # WARNING: nop is mandatory here. 
 	b loop # Loop 
end_main: 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
# GENERAL INTERRUPT SERVED ROUTINE for all interrupts 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
.ktext 0x80000180 
 #------------------------------------------------------- 
 # SAVE the current REG FILE to stack 
 #------------------------------------------------------- 
IntSR1:  addi $sp,$sp,4 # Save $ra because we may change it later 
 	 sw $ra,0($sp) 
	 addi $sp,$sp,4 # Save $at because we may change it later 
	 sw $at,0($sp) 
	 addi $sp,$sp,4 # Save $t1 because we may change it later 
	 sw $k0,0($sp) 

 #-------------------------------------------------------- 
 # Processing 
 #-------------------------------------------------------- 
prn_msg:addi $v0, $zero, 4 
	 la $a0 , Message3
	syscall
polling1 :
	li $t9 , 0x81 # check row 4 with key 0, 1, 2, 3
	sb $t9 , 0( $k0 ) # must reassign expected row
	lb $a0 , 0( $k1 ) # read scan code of key button
	beq $a0 , 0x0 , polling2
	jal pooling_keypad
	jal Sleep
	j prn_cod # continue pooling

polling2:
 	li $t9  , 0x82 # check row 4 with key 4, 5, 6, 7
	sb $t9 , 0( $k0 ) # must reassign expected row
	lb $a0 , 0( $k1 ) # read scan code of key button
	beq $a0 , 0x0 , polling3
	jal pooling_keypad
	jal Sleep
	j prn_cod # continue pooling

polling3:
	li $t9 , 0x84 # check row 4 with key 8, 9, A, B
	sb $t9 , 0( $k0 ) # must reassign expected row
	lb $a0 , 0( $k1 ) # read scan code of key button
	beq $a0 , 0x0 , polling4
	jal pooling_keypad
	jal Sleep
	j prn_cod # continue pooling

polling4:
	li $t9 , 0x88 # check row 4 with key C, D, E, F
	sb $t9 , 0( $k0 ) # must reassign expected row
	lb $a0 , 0( $k1 ) # read scan code of key button
	jal pooling_keypad
	jal Sleep

prn_cod:
	li $v0 , 11
	li $a0 , '\n'
	syscall

Input_Check:
	blt $t0, 48, Operator_Processor #if < 0
	nop
	bgt $t0, 57, Operator_Processor #if > 9
	j Operand_Processor
	nop

Operand_Processor: 
Check_state:
is_State0: bne $s2, 0 , is_State1
	   jal Change_state1
	   j keep_on	
is_State1: bne $s2, 1 , is_State2
	    j keep_on
is_State2: bne $s2, 2 , is_State3
	    jal Change_state3	
	    j keep_on
is_State3: bne $s2, 3 , is_State4	
	    j keep_on
is_State4: jal Change_state1
	    j keep_on	

keep_on:
	addi $t0, $t0, -48# change input key
	mul $t3, $t3, 10
	add $t3, $t3, $t0
	addi $t0, $t0, 48
 	
 	addi $a2, $t3, 0 
 	blt $t3, 0, Change_error1 #overflow
 	jal  display_last_two_number
 	j End_Interupt
 
Operator_Processor: 
If_plus:
	bne $t0, 'a', If_minus
	li $s5, 1
	li $t0, '+'
	j After_Operator
If_minus:
	bne $t0, 'b', If_mult
	li $s5, 2
	li $t0, '-'
	j After_Operator
If_mult:
	bne $t0, 'c', If_div
	li $s5, 3
	li $t0, '*'
	j After_Operator
If_div:
	bne $t0, 'd', If_mod
	li $s5, 4
	li $t0, '/'
	j After_Operator
If_mod:
	bne $t0, 'e', If_equal
	li $s5, 5
	li $t0, '%'
	j After_Operator
If_equal:
	bne $t0, 'f', loop
	li $t0, '='
	j After_Equal

After_Operator:
Is_state1:	bne $s2, 1, Is_state2 
		addi $s0, $t3, 0     #save the first operand in $s0
		li $t3, 0            #reset t3
		jal Change_state2
		j End_Interupt
Is_state2:	bne $s2, 2, Is_state3 
		j End_Interupt
Is_state3:     bne $s2, 3, Is_state4 
		addi $s1, $t3, 0     #save the second operand in $s1
		li $t3,0              #reset $t3 
		li $s3, 1 # Continuous Calculation Mode : Activate
		jal Change_state4
		j go_on
Is_state4:      jal Change_state2
		j End_Interupt
		
After_Equal:
is_state1: bne $s2, 1, is_state2
	addi $s0, $t3, 0     #save the first operand in $s1
	li $t3, 0  #reset $t3
	jal Change_state4
	j go_on   
is_state2:bne $s2, 2, is_state3
	jal Change_state4 
	j go_on
is_state3:bne $s2, 3, is_state4
	addi $s1, $t3, 0     #save the second operand in $s1
	li $t3, 0  #reset $t3
	li $s3, 0 # Continuous Calculation Mode : Terminate
	jal Change_state4 
	j go_on
is_state4:
	jal Change_state4
	j go_on

go_on:
	addi $a1, $s0, 0
	addi $a2, $s1, 0
	beq $s3, 1, continuous_calculate
normal_calculate:	
	jal Calculator
	j finish_calculate
continuous_calculate:
	addi $t9, $t8, 0   #swap to previous oparetor
	addi $t8, $s5, 0
	addi $s5, $t9, 0
	jal Calculator
	addi $t9, $t8, 0   #swap again
	addi $t8, $s5, 0
	addi $s5, $t9, 0
	jal Change_state2
finish_calculate:
	addi $s0, $v0, 0 #Save the result to the first operand
	addi $a2, $s0, 0
 	jal  display_last_two_number
 	j End_Interupt
 		
End_Interupt:
	addi $t8, $s5, 0 #luu trang thai cuar toan tu truoc do trong truong hop tinh toan lien tiep 
 	nop 

next_pc:mfc0 $at, $14 # $at <= Coproc0.$14 = Coproc0.epc 
 	addi $at, $at, 4 # $at = $at + 4 (next instruction) 
 	mtc0 $at, $14 # Coproc0.$14 = Coproc0.epc <= $at 
 #-------------------------------------------------------- 
 # RESTORE the REG FILE from STACK 
 #--------------------------------------------------------
 restore:
 	lw $k0, 0($sp) # Restore the registers from stack 
 	addi $sp,$sp,-4 
 	lw $at, 0($sp) # Restore the registers from stack 
 	addi $sp,$sp,-4 
 	lw $ra, 0($sp) # Restore the registers from stack 
 	addi $sp,$sp,-4 
return: eret # Return from exception

#------------------------------------------ 
#Read corresponding data from the keypad
pooling_keypad:
Case_0:	bne $a0, 0x11, Case_1
	li $t0, '0'
	j print_key 
Case_1: bne $a0, 0x21, Case_2
	li $t0, '1'
	j print_key 
Case_2: bne $a0, 0x41, Case_3
	li $t0, '2'
	j print_key 
Case_3: bne $a0, 0xffffff81, Case_4
	li $t0, '3'
	j print_key 
Case_4: bne $a0, 0x12, Case_5
	li $t0, '4'
	j print_key 
Case_5: bne $a0, 0x22, Case_6
	li $t0, '5'
	j print_key 
Case_6: bne $a0, 0x42, Case_7
	li $t0, '6'
	j print_key 
Case_7: bne $a0, 0xffffff82, Case_8
	li $t0, '7'
	j print_key 
Case_8: bne $a0, 0x14, Case_9
	li $t0, '8'
	j print_key 
Case_9: bne $a0, 0x24, Case_a
	li $t0, '9'
	j print_key 
Case_a: bne $a0, 0x44, Case_b
	li $t0, 'a'
	j print_key 
Case_b: bne $a0, 0xffffff84, Case_c
	li $t0, 'b'
	j print_key 
Case_c: bne $a0, 0x18, Case_d
	li $t0, 'c'
	j print_key 
Case_d: bne $a0, 0x28, Case_e
	li $t0, 'd'
	j print_key 
Case_e: bne $a0, 0x48, Case_f
	li $t0, 'e'
	j print_key 
Case_f: 
	li $t0, 'f'
	j print_key 
print_key:
	addi $at, $v0, 0
	li $v0, 11
	addi $a0 , $t0, 0
	syscall
	addi $v0, $at, 0
	jr $ra

#------------------------------------------ 
#------------------------------------------ 
#Put thread into a sleep
Sleep:	
	addi $at, $v0, 0
 	li $a0 , 100 # sleep 100ms
	li $v0 , 32
	syscall
	addi $v0, $at, 0
	jr $ra
	
#------------------------------------------ 
# Ham hien thi so tren bo led 7 thanh
#  @param  [in]   $a1:  Chua mot so
display_number:
case_0: bne $a1, 0, case_1
	li $a0, 0x3F
	j end_switch
case_1: bne $a1, 1, case_2
	li $a0, 0x6
	j end_switch
case_2: bne $a1, 2, case_3
	li $a0, 0x5B
	j end_switch
case_3: bne $a1, 3, case_4
	li $a0, 0x4F
	j end_switch
case_4: bne $a1, 4, case_5
	li $a0, 0x66
	j end_switch
case_5: bne $a1, 5, case_6
	li $a0, 0x6D
	j end_switch
case_6: bne $a1, 6, case_7
	li $a0, 0x7D
	j end_switch
case_7: bne $a1, 7, case_8
	li $a0, 0x7
	j end_switch
case_8: bne $a1, 8, case_9
	li $a0, 0x7F
	j end_switch
case_9: bne $a1, 9, case_Minus
	li $a0, 0x6F
	j end_switch
case_Minus: li $a0, 0x40
	    j end_switch
end_switch:
	jr $ra 

#------------------------------------------ 
# Ham hien thi 2 so cuoi tren bo led 7 thanh
#  @param  [in]   $a2:  Chua mot so
 	#trich xuat 2 chu so cuoi
display_last_two_number:
	addi $a3, $a2, 0   #swap
	bge $a2, 0, display
	sub $a2, $zero , $a2  

display:li $t4, 100 
	div $a2, $t4
	mfhi $t5
	li $t4, 10
	div $t5, $t4
	mfhi $t5   #chu so hang don vi	
	mflo $t4   #chu so hang chuc
	
	addi $a2, $a3, 0  #swap
			
	bge $a2, 0, display2 #display negative number
	bne $t4, 0, display2 
	nop
	li $t4, 10		

display2:addi $sp,$sp,-4 #making room return address 
 	sw $ra,0($sp) #save return address 
 	   
	addi $a1, $t4, 0 
	jal display_number
	li $t6, SEVENSEG_RIGHT # assign port's address
 	sb $a0, 0($t6) # assign new value
 	
 	addi $a1, $t5, 0
 	jal display_number
 	li $t7, SEVENSEG_LEFT # assign port's address
 	sb $a0, 0($t7) # assign new value
 	#-----------------------------------------
 	
 	lw $ra,0($sp) #restore return address (5) 
 	addi $sp,$sp,4
 	jr $ra 
 
#------------------------------------------

#------------------------------------------ 
# Ham tinh toan 
#  @param  [in]  : $a1: Toan hang thu nhat
#  @param  [in]  : $a2: Toan hang thu hai
#  @return_value  : $v0: Ket qua tinh toan
Calculator: 	li $v0, 0

case_plus:	bne $s5,1,case_minus
		add $v0, $a1, $a2
blt $a1, 0, print_result
blt $v0, 0, Change_error1
		j print_result			
case_minus:	bne $s5,2,case_mult
		sub $v0, $a1, $a2
bgt $a1, 0, print_result
bgt $v0, 0, Change_error1
		j print_result	
case_mult:	bne $s5,3,case_div
		mul $v0, $a1, $a2
#blt $a1, 0, print_result
#blt $v0, 0, Change_error1
		j print_result
case_div:	bne $s5,4,case_mod
		beq $a2, 0, Change_error2
		div $a1, $a2
		mflo $v0
		j print_result
case_mod:	bne $s5,5,case_null
		beq $a2, 0, Change_error2
		div $a1, $a2
		mfhi $v0
		j print_result
case_null:     jr $ra 

print_result: 
	addi $v1, $v0, 0
	li $v0, 4
 	la $a0, Message2
 	syscall 
 	
 	li $v0, 1
 	addi $a0, $v1, 0
 	syscall 
 	addi $v0, $v1, 0
 	
	jr $ra
#------------------------------------------ 

#------------------------------------------ 
#Changing state
Change_state0: li $s2, 0
		#reset all value 
		li $s0, 0
		li $s1, 0
		li $s3, 0
		li $s4, 0
		li $s5, 0
		li $t0, 0
		li $t3, 0
 		
		j Print_State
Change_state1: li $s2, 1
		j Print_State
Change_state2: li $s2, 2
		j Print_State
Change_state3: li $s2, 3
		j Print_State
Change_state4: li $s2, 4
		j Print_State
Print_State:
	addi $v1, $v0, 0
	li $v0, 4
 	la $a0, Message
 	syscall 
 	
 	li $v0, 1
 	addi $a0, $s2, 0
 	syscall 
 	addi $v0, $v1, 0
 	
	jr $ra
#------------------------------------------ 

#------------------------------------------ 
#Execption Handler
Change_error1: li $s4, 1 		
 		j Print_Error
Change_error2:	li $s4, 2
 		j Print_Error
Print_Error:
case_err1:	bne $s4, 1, case_err2 
	addi $v1, $v0, 0
	li $v0, 55
 	la $a0, Overflow_Error
 	li $a1, 0
 	syscall 
 	addi $v0, $v1, 0
 	j Reset_new
case_err2:  	bne $s4, 2, Reset_new
 	addi $v1, $v0, 0
	li $v0, 55
 	la $a0, Logic_Error
 	li $a1, 0
 	syscall 
 	addi $v0, $v1, 0
 	
Reset_new: 	
	jal Change_state0			
	addi $a2, $t3, 0 
 	jal  display_last_two_number
	j End_Interupt
#------------------------------------------ 



