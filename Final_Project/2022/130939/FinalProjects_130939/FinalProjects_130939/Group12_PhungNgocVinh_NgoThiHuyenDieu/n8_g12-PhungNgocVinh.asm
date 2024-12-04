.data
d1: 		.space 4
d2: 		.space 4
array: 		.space 32
string: 	.space 1000

hex_result: 	.space 8
start: 		.asciiz "Nhap chuoi ky tu : "
enter: 		.asciiz "\n"
error_length: 	.asciiz "Do dai chuoi khong hop le! Ban co muon nhap lai 1 lan nua ? \n"
m1: 		.asciiz "      Disk 1                 Disk 2               Disk 3\n"
m2: 		.asciiz "----------------       ----------------       ----------------\n"
slash: 		.asciiz "|"
space: 		.asciiz "     "
space2:		.asciiz "       "
m3: 		.asciiz "[[ "
m4: 		.asciiz "]]"
comma: 		.asciiz ","
ms_again : 	.asciiz "Ban co muon tiep tuc chuong trinh \n ?"

.text
main:
	jal input
	nop
	jal output
	nop
	
	li $v0, 50		# service 50 is ConfirmDialog . a0 = 0 :  yes 
 	la $a0, ms_again	# the message to user 
 	syscall 		# execute
 	beq $a0,0,main		# if a0 = 0 => jump to main 
 	nop
exit:
	li $v0, 10		# service 10 is exit
	syscall			# execute
 	
 	
#===================================INPUT===============================================================
# t3 = length ; $s0 = input_string	
input:	li $v0, 54		# service 54 is input diaglog string
	la $a0, start		# the message to user 
 	la $a1, string 		# $a1 = address of input buffer. $a1 contains status value : 0 : ok
 	la $a2, 1000		# maximum number of characters to read is 1000 
 	syscall 		# execute
 	bne $a1,$0,error	# if a1 !=0 => goi den ham error1
 	la $s0,string		# s0 chua dia chi xau moi nhap
	
	
#-----------------------kiem tra do dai co chia het cho 8 khong--------------------------
length: addi $t3, $zero, 0 	# t3 = length

check_char: add $t1, $s0, $t3 	# t1 = address of string[i]
	lb $t2, 0($t1) 		# t2 = string[i]
	nop
	beq $t2, 10, check_length 	# t2 = '\n' ket thuc xau
	nop
	addi $t3, $t3, 1 	# length++
	j check_char		# tiep tuc check_char
	nop
check_length: 
	move $t5, $t3		# t5 = t3 = length of input string
	addi $t4,$0,8		# t4 = 8 
	div $t3, $t4		# Lo = $t3 / $t4, Hi = $t3 mod $t4 
	mfhi $t4		# $t4 = Hi =  $t3 mod $t4 (t4 la so du )
	bne $t4,0,error		# if $t4 != 0 (length khong chia het cho 8) => goi ham error
 	jr $ra			# nhay ve main
 	nop
 	
error:	
	li $v0, 50		# service 50 is ConfirmDialog
 	la $a0, error_length	# set $a0 to error_length's address. The message to user . 
 	syscall 		# execute
 	beq $a0,0,input		# $a0 contains value of user-chosen option . 0: Yes 1: No 2: Cancel. If a0 = 0 => turn back to input
 	j exit			# jump to exit
 	nop
#===================================OUTPUT============================================
output:
	addi $sp, $sp, -4	# sp = sp - 4
	sw $ra, 0($sp) 		# store $ra contents into effective memory word address . Luu dia chi tro ve main vao main 
	
	li $v0, 4		# service 4 is print string 
	la $a0, m1		# the string to be printed is string "   Disk 1                 Disk 2               Disk 3\n"
	syscall			# execute
	li $v0, 4		# service 4 is print string 
	la $a0, m2		# the string to be printed is string "----------------       ----------------       ----------------\n"
	syscall			# execute
	
	li $s7,1		# $t7 = 1 (dat flag)
output_loop:
	addi $t0, $zero, 0	# t0 = 0 (t0 la so thu tu cac byte da duoc xu li trong 1 block)
	la $s1, d1		# s1 : mang chua cac ki tu o block 4 byte dau
	la $s2, d2		# s2 : mang chua cac ki tu o block 4 byte tiep thep
	la $a2, array		# a2 : mang chua cac byte partity
block1:				#block 4 byte k
	lb $t1, ($s0)		#t1 = string[i]
	addi $t3, $t3, -1	# t3 = t3 - 1
	sb $t1, ($s1)		# $s1[] = $t1
block2:				#block 4 byte k+1
	add $s5, $s0, 4		# $s5 = $s0 + 4 
	lb $t2, ($s5)		# t2 = string[i+4]
	addi $t3, $t3, -1	# t3 = t3 - 1
	sb $t2,($s2)
pitity_block:
	xor $a3, $t1, $t2	# set $a3 to bitwise XOR of $t1 and $t2 . $a3 = $t1 XOR $t2
	sw $a3, ($a2)		# store $a3 contents into effective memory word address
	addi $a2, $a2, 4	# a2 = a2 + 4
	addi $t0, $t0, 1	# t0 = t0 +1 (them 1 byte da duoc xu ly)
	addi $s0, $s0, 1	# s0 = s0 + 1
	addi $s1, $s1, 1	# s1 = s1 + 1
	addi $s2, $s2, 1	# s2 = s2 + 1
	beq $t0, 4, reset 	# if t0 = 4 => goi ham reset
	j block1			# else => jump to a1 : tiep tuc xu li cac cap ki tu 
	nop
reset:	la $s1, d1
	la $s2, d2
	la $a2, array
	
case1:
	addi  $t6, $0, 1		# $t6 = 1
	bne   $s7, $t6, case2   	# s7 == 1? if not, skip to case 2
	jal   print_block1			# goi toi thu tuc print_block1
	nop
	jal   print_block2			# goi toi thu tuc print_block2
	nop
	jal   print_parity_array	# goi toi thu tuc print_parity_array
	nop
	j     done			# jump to done
case2:
	addi  $t6, $0, 2	# $t6 = 2
	bne   $s7, $t6, case3    # t7 == 2? if not, skip to case 3
	jal   print_block1
	nop
	jal   print_parity_array
	nop
	jal   print_block2
	nop
	j     done
case3:
	jal   print_parity_array
	nop
	jal   print_block1
	nop
	jal   print_block2
	nop
	j     done
done:
	li $v0, 4			# service 4 is print string 
	la $a0, enter			# the string to be printed is '\n' 
	syscall				# execute
	beq $t3, 0, exit1		# if t3 = 0 (da xu li het tat ca cac ky tu) => jump to exit1
	addi $s0, $s0, 4		# s0 = s0 + 4 ; (tang i len 4 )
	beq $s7,3,else			# if s7 = 3 => jump to else
	addi $s7,$s7,1			# else s7 = s7 + 1;
	j output_loop			# jump to output_loop. Tiep tuc vong lap
	nop 
else:
	addi $s7,$0,1			# s7 = 0 
	j output_loop			# # jump to output_loop. Tiep tuc vong lap
	nop
print_block1:
	li $v0, 4			# service 4 is print string
	la $a0, slash			# string to be printed is "|"
	syscall				# execute
	li $v0, 4			# service 4 is print string
	la $a0, space			# string to be printed is "       "
	syscall				# execute
	addi $t9, $zero, 0 		# t9 = 0  (index)
print_block1_loop:
	lb $a0, ($s1)			# load byte : set $a0 to sign-extended 8bit value from $s1 memory byte address . ao chua ky tu dau tien trong s1
	li $v0, 11			# service 11 is print character
	syscall				# execute
	addi $t9, $t9, 1		# t9 = t9 + 1 
	addi $s1, $s1, 1		# s1 = s1 + 1 (chuyen toi ky tu tiep theo)
	beq $t9, 4, end_print_block1	# if t9 = 4(nhom 4 ky tu da dc in ra) => jump to end_print_block1
	j print_block1_loop			# else jump to print_block1_loop . Tiep tuc vong lap in ky tu trong block

end_print_block1:
	li $v0, 4			# service 4 is print string
	la $a0, space			# string to be printed is "      "
	syscall				# execute
	li $v0, 4			# service 4 is print string
	la $a0, slash			# string to be printed is "|"
	syscall				# execute
	li $v0, 4			# service 4 is print string
	la $a0, space2			# string to be printed is "          "
	syscall				# execute
	jr	$ra			# nhay ve cac case goi toi tuong ung
	nop
print_block2:
	li $v0, 4
	la $a0, slash
	syscall
	li $v0, 4
	la $a0, space
	syscall
	addi $t9, $zero, 0 
print_block2_loop:
	lb $a0, ($s2)			# load byte : set $a0 to sign-extended 8bit value from $s1 memory byte address . ao chua ky tu dau tien trong s2
	li $v0, 11
	syscall
	addi $t9, $t9, 1
	addi $s2, $s2, 1
	beq $t9, 4, end_print_block2
	j print_block2_loop

end_print_block2:
	li $v0, 4
	la $a0, space
	syscall
	li $v0, 4
	la $a0, slash
	syscall
	li $v0, 4
	la $a0, space2
	syscall
	jr $ra
	nop
print_parity_array: 
	addi $sp, $sp, -4		# sp = sp -4
	sw $ra, 0($sp)			# luu lai dia chi tro ve case goi tuong tuong ung vao dau ngan xep
	li $v0, 4			# service 4 is print string
	la $a0, m3 			# string to be printed is "[["
	syscall				# execute
	addi $t9, $zero, 0 		# t9 = 0 (index)
print_parity_array_loop:
	lb $t8, ($a2)			# load byte 
	jal hex_convert			# goi toi thu tuc hex_convert
	nop 
	li $v0, 4			# service 4 is print string
	la $a0, comma			# string to be printed is ","
	syscall				# execute
	addi $t9, $t9, 1		# t9 ++
	addi $a2, $a2, 4		# tro toi gia tri tiep theo trong mang
	beq $t9, 3, end_print_parity_array	# if t9 = 3 => jump to  end_print_parity_array .  in ra 3 parity dau co dau ",", parity cuoi cung k co
	j print_parity_array_loop
end_print_parity_array:
	lb $t8, ($a2)
	jal  hex_convert
	nop 	 
	li $v0, 4			# service 4 is print string
	la $a0, m4			# string to be printed is "]]"
	syscall				# execute
	li $v0, 4
	la $a0, space2
	syscall
	lw $ra, 0($sp)			# load lai dia chi tro ve case tuong ung da dc luu o dinh sp .
	addi $sp, $sp, 4		# sp = sp + 4
	jr $ra				# tro ve case tuong ung goi toi
	nop

#==============Hex==========================
#convert to hex and print
hex_convert:
	add $t2,$t8,$zero		#Lay gia tri so input gan vao $t2	
	li $t5,0			#flag $t5 = 0 
	li $t0,8			#Gan gia tri i = 8 (So vong lap)       
	la $t7,hex_result		#Lay dia chi string result

Loop_hex:
	beqz $t0,hex_convert_end	#Dieu kien thoat vong lap i = 0	
	nop
	rol $t2,$t2,4			#Xoay vong, lan luot lay ra 4 bit (Tuong ung voi 1 vi tri trong he co so 16)
	and $t4,$t2,0xf			#$t4 chi luu gia tri 4 bit lay ra
	ble $t4,9,Sum_hex		#Neu $t4 <= 9 gia tri se cong them 48 (gia tri tu 0 - > 9 trong ascii)
	nop
	addi $t4,$t4,87	      		#Neu $t4 >9 gia tri cong them 87 (gia tri a, b, c, d, e, f)
	b End_hex			#Chuyen huong xuong end_hex
	nop

Sum_hex:
	addi $t4, $t4, 48 		#Neu $t4 <= 9 gia tri se cong them 48 (gia tri tu 0 - > 9 trong ascii)
End_hex:
	bgt $t0,2,End_hex2
	nop
	sb $t4, 0($t7)			#Nap vao hex_result		
	addi $t7, $t7, 1		#Lay hex_result[j]	
End_hex2:
	addi $t0, $t0, -1		#i = i - 1
	j Loop_hex			#Quay lai vong lap
	nop
hex_convert_end:
	la $a0,hex_result		#In ra gia tri hex
	li $v0,4
	syscall
	jr $ra				# tro ve 
	nop 

#==========Exit1===============================
exit1:	li $v0, 4			# service 4 is print string
	la $a0, m2			# print to be printed is "------- --------- -----------" 
	syscall				# execute
	lw $ra, 0($sp)			# load dia chi tro ve main da duoc luu o dinh ngan xep 
	addi $sp, $sp, 4		# sp = sp + 4
	jr $ra				# nhay ve main
	nop
