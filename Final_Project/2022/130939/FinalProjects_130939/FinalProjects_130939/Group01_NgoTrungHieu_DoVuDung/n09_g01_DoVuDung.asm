.data
String0: .space 5000
String1:  .asciiz "                                             *************  \n"
String2:  .asciiz " ****************                           *3333333333333* \n"
String3:  .asciiz " *2222222222222222*                         *33333********  \n"
String4:  .asciiz " *22222*******222222*                       *33333*         \n"
String5:  .asciiz " *22222*       *22222*                      *33333********  \n"
String6:  .asciiz " *22222*        *22222*      *************  *3333333333333* \n"
String7:  .asciiz " *22222*        *22222*    **11111*****111* *33333********  \n"
String8:  .asciiz " *22222*        *22222*  **1111**       **  *33333*         \n"
String9:  .asciiz " *22222*       *22222*   *1111*             *33333********  \n"
String10: .asciiz " *22222*******222222*   *11111*             *3333333333333* \n"
String11: .asciiz " *2222222222222222*     *11111*              *************  \n"
String12: .asciiz " ****************       *11111*                             \n"
String13: .asciiz "       ---               *1111**                            \n"
String14: .asciiz "     / o o \\              *1111****   *****                 \n"
String15: .asciiz "     \\   > /               **111111***111*                  \n"
String16: .asciiz "      -----                  ***********    dce.hust.edu.vn \n"

Message1: .asciiz"\n\n---------------------------------------- Print DCE --------------------------------------------\n\n"
Message2: .asciiz"\n\n----------------------------------- Print without color ---------------------------------------\n\n"
Message3: .asciiz"\n\n-------------------------------- Change position of D & E -------------------------------------\n\n"
Message4: .asciiz"\n\n------------------------------------- Change color --------------------------------------------\n\n"

StringD: .asciiz"New color of D (0->9): "
StringC: .asciiz"New color of C (0->9): "
StringE: .asciiz"New color of E (0->9): "
.text

############## print ###############
title1:	la $a0, Message1
	li $v0,4
	syscall
main1:	li $s0,0				# i=0
	la $s2, String1
Loop_print:	addi $a0,$s2,0
		li $v0,4
		syscall
		addi $s2, $s2, 62 		# next string(line)
		addi $s0, $s0,1			# i++
		beq $s0, 16, end_print    	# if i=16 => end print (line =16)
		j Loop_print
end_print:

########### IN KHONG MAU ############
title2:	la $a0, Message2
	li $v0,4
	syscall
main2:	li $s0,0				#i=0
	la $s2, String1
Loop:	li $s1,0				#j=0
print_line:	add $t1, $s2, $s1 		# t1 = address of stringX[j]
		lb $t2, 0($t1)			# t2 = stringX[j]
		blt $t2, 48, printc 		# t2 < 48('0') jump printc
		bgt $t2, 57, printc 		# t2 > 57('9') jump printc
		addi $t2, $zero, 32
printc:	addi $a0, $t2, 0	# print character
	li $v0,11
	syscall
	addi $s1,$s1,1 		# j= j+1
	beq $s1,62, next_line
	j print_line
next_line:	addi $s0,$s0,1 	#i= i+1
	addi $s2,$s2,62		# next string
	beq $s0,16, end_loop
	j Loop
end_loop:

############ change D & E #############
title3:	la $a0, Message3
	li $v0,4
	syscall
# D: 0-> 22
# C: 23 -> 42
# E: 43 -> 58
main3:	li $s0,0 		#i=0
	la $s2, String1
Loop1: 	li $s1,43  		# j=43
Print_E:	
	add $t0, $s2, $s1 	# t0 = address of stringX[j]
	lb $t2, 0($t0) 		# t2 = stringX[j]
	addi $a0, $t2, 0 
	li $v0, 11		# print character
	syscall
	addi $s1,$s1,1 		# j++
	beq $s1,59,Loop2 	# if j = 59 jump loop2
	j Print_E
Loop2:	li $s1,23		# j=23
Print_C:	
	add $t0, $s2, $s1 	# t0 = address of stringX[j]
	lb $t2, 0($t0) 		# t2 = stringX[j]
	addi $a0, $t2, 0 
	li $v0, 11		# print character
	syscall
	addi $s1,$s1,1
	beq $s1,43,Loop3	# if i =43 jump loop3
	j Print_C
Loop3: 	li $s1,0		# j=0
Print_D: add $t0, $s2, $s1 	# t0 = address of stringX[j]
	lb $t2, 0($t0) 		# t2 = stringX[j]
	addi $a0, $t2, 0 
	li $v0, 11		# print character
	syscall
	addi $s1,$s1,1
	beq $s1,23,Loop4	# if i=23 jump loop4
	j Print_D
Loop4: li $s1,60		# j=59
Print: add $t0, $s2, $s1 	# t0 = address of stringX[j]
	lb $t2, 0($t0) 		# t2 = stringX[j]
	addi $a0, $t2, 0 
	li $v0, 11		# print character
	syscall
	addi $s1,$s1,1
	beq $s1,62,Line  	# if j = 62 => next line
	j Print
Line:	addi $s0,$s0,1
	beq $s0,16,end		# if i = 16 end
	addi $s2,$s2,62
	j Loop1
end:

############## Change color ##########
title4:	la $a0, Message4
	li $v0,4
	syscall
####
	li $t1, 50 # color base of D
	li $t3, 49 # color base of C
	li $t5, 51 # color base of E

#### input color 
Input_D: li $v0,4
	la $a0, StringD
	syscall
	li $v0,5
	syscall
	blt $v0,0, Input_D 	#if v0<0 input again
	bgt $v0,9, Input_D 	#if v0>9 input again
	addi $t2,$v0,48 	# '0' ascii: 48 , t2: store new color of D
Input_C: li $v0,4
	la $a0, StringC
	syscall
	li $v0,5
	syscall
	blt $v0,0, Input_C 	#if v0<0 input again
	bgt $v0,9, Input_C 	#if v0>9 input again
	addi $t4,$v0,48 	# t4: store new color of C	
Input_E: li $v0,4
	la $a0, StringE
	syscall
	li $v0,5
	syscall
	blt $v0,0, Input_E 	#if v0<0 input again
	bgt $v0,9, Input_E 	#if v0>9 input again
	addi $t6,$v0,48 	#t6: store new color of E

####
main4:	li $s0, 0 		# i=0
	la $s2,String1
	
row:	li $s1,0 		# j=0
check:	add $t0,$s2, $s1 	# t0 = address of StringX[j]
	lb $a0,($t0) 		# a0 = stringX[j]
checkD:	bgt $s1, 23, checkC 	# if j>23 check C
	beq $a0, $t1, fixD 	# if stringX[j] = color base => fix
	j next_char
fixD:	sb $t2, 0($t0)  	# stote new color into stringX[j]
	j next_char
checkC:	bgt $s1, 43, checkE 	# if j>43 check E
	beq $a0, $t3, fixC 	# if stringX[j] = color base => fix
	j next_char
fixC:	sb $t4, 0($t0) 		# stote new color into stringX[j]
	j next_char
checkE:				#bgt $s1, 23, checkC # if j>23 check C
	beq $a0, $t5, fixE 	# if stringX[j] = color base => fix
	j next_char
fixE:	sb $t6, 0($t0) 		# stote new color into stringX[j]
	j next_char
next_char:	addi $s1,$s1, 1 # j++
		beq $s1,62,end_row
		j check
end_row:	addi $a0, $s2,0 # print line
	li $v0,4
	syscall
	addi $s0,$s0,1
	beq $s0,16, end_change
	addi $s2,$s2,62
	j row
end_change:


