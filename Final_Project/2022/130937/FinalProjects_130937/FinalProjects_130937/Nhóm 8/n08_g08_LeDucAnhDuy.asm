.eqv	DISK_1	0x10010200	
.eqv	DISK_2	0x10010300
.eqv	DISK_3	0x10010400

.data
	msg0:	.asciiz	"Nhap vao xau du lieu:"
	msg1:	.space	160
	hex:	.ascii "0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f" 
	disk1:	.asciiz	"     Disk 1     "
	disk2:	.asciiz	"     Disk 2     "
	disk3:	.asciiz	"     Disk 3     "
	line:	.asciiz	" -------------- "
	tab:	.asciiz	"\t"
	space:	.asciiz  "     "
	brkline:	.asciiz	"\n"	
	err:	.asciiz	"Do dai xau nhap vao phai la boi cua 8"
	
.text
	la	$s4, DISK_1 
	la	$s5, DISK_2
	la	$s6, DISK_3
	li	$a3, 4
	
#------ Nhap vao du lieu-------#	
input:
	la	$a0, msg0	
	la	$a1, msg1
	la	$a2, 160
	li	$v0, 54
	syscall
	
#-------- Kiem tra do dai xau -------#
#Do dai xau phai la boi cua 8	
	la	$s1, msg1
	addi	$s7, $zero, 0xA		# 0xA = '\n'
	li 	$s2, 0
get_lenght:
	lb	$t1, 0($s1)
	
	beq	$t1, $s7, check
	
	addi	$s2, $s2, 1
	addi	$s1, $s1, 1
	
	j	get_lenght
check:
	addi	$s7, $zero, 8
	div	$s2, $s7
	mfhi	$s2
	bne	$s2, $zero, error
	
	
#------- Load byte ---------#
# Load tung 8 byte mot luot, va luu vao 2 disk, 
# dong thoi xor va luu vao disk con lai	

# $s1: Dia chi byte thu n
# $s2: Dia chi byte thu n + 4
# $t1, $t2: gia tri byt thu n va n + 4
# $t0: gia tri xor parity

	la	$s1, msg1		# dia chi byte thu n
	li 	$s3, 0
	
Load_4bytes:
	addi	$s7, $zero, 0xA
	
	addi	$s2, $s1, 4		# dia chi byte thu n + 4
	
	lb	$t1, 0($s1)		# gia tri byte thu n	
	lb	$t2, 0($s2)		# gia tri byte thu n + 4	

	beq	$t1, $s7, print
	
	xor	$t0, $t1, $t2		# gia tri xor parity
	jal	store			#luu gia tri vao disk
	
	addi	$s1, $s1, 1		# advance
	addi	$s3, $s3, 1
	
	bne	$s3, $a3, Load_4bytes	# i > 4 ? tiep tuc lap
	add	$s3, $zero, $zero	# reset i = 0
	
	addi	$s1, $s1, 4
	addi	$t8, $t8, 1		# So block 8 byte da doc
		
	j 	Load_4bytes
	
#------- Luu tru ---------#
# Trong Raid 5, cac block parity phai duoc phan bo deu
# ==> Moi lan luu tru se luu vao mot trong 3 disk luan phien
# Su dung cach chia co du 
# VD: lan ghi thu 2 ==> 2 : 3 du 2 ==> ghi vao DISK_3 	
store:	
	add	$t9, $t8, $zero
	
	addi	$s7, $zero, 3
	div 	$t9, $s7		#$t9 chia 3 du 0, 1, 2 ?
	mfhi	$t9
	
	addi	$s7, $zero, 0
	beq	$t9, $zero, store_0	
	
	addi	$s7, $zero, 1
	beq	$t9, $s7, store_1

	addi	$s7, $zero, 2
	beq	$t9, $s7, store_2
	
#-----Store parity to Disk 1------#
store_0:	
	sb	$t1, 0($s4)
	addi	$s4, $s4, 1
	
	sb	$t2, 0($s5)
	addi	$s5, $s5, 1
	
	sb 	$t0, 0($s6)
	addi	$s6, $s6, 1		# luu parity vao disk1	
	jr	$ra
	
#-----Store parity to Disk 2------#
store_1:
	sb	$t1, 0($s4)
	addi	$s4, $s4, 1
	
	sb	$t0, 0($s5)
	addi	$s5, $s5, 1
	
	sb 	$t2, 0($s6)
	addi	$s6, $s6, 1
	jr	$ra
	
#-----Store parity to Disk 3------#
store_2:		
	sb	$t0, 0($s4)
	addi	$s4, $s4, 1
	
	sb	$t1, 0($s5)
	addi	$s5, $s5, 1
	
	sb 	$t2, 0($s6)
	addi	$s6, $s6, 1
		
	jr	$ra	

#--------Print--------#
# in tung ky tu ra man hinh
print:
#----------Menu chinh---------#
#disk 1, 2, 3
# disk 1
	
	la	$a0, disk1	# "Disk 1"
	li	$v0, 4	
	syscall
	
	la	$a0, tab		# tab
	li	$v0, 4
	syscall
	
#disk 2	
	la	$a0, tab		# tab	
	li	$v0, 4
	syscall
	
	la	$a0, disk2	
	li	$v0, 4
	syscall
	
	la	$a0, tab
	li	$v0, 4
	syscall

#  disk 3		
	la	$a0, tab
	li	$v0, 4
	syscall
	
	la	$a0, disk3
	li	$v0, 4
	syscall
	
	la	$a0, tab
	li	$v0, 4
	syscall

# line
	la	$a0, brkline
	li	$v0, 4
	syscall
	
	add	$a3, $zero, $zero
	addi	$s7, $zero, 3
printLine_1:

	addi	$a3, $a3, 1
	
	
	la	$a0, line
	li	$v0, 4
	syscall
	
	la	$a0, tab
	li	$v0, 4
	syscall
	
	la	$a0, tab
	li	$v0, 4
	syscall
	
	beq	$a3, $s7, printData
	j	printLine_1

#-------- In ra data-----------#
# Can biet duoc vi tri cua byte parity (disk 1, 2 hay 3
# lay bien chay chia lay du cho 3

printData:
	
	la	$s4, DISK_1 
	la	$s5, DISK_2
	la	$s6, DISK_3
	
	addi	$t7, $zero, 3 
	add	$t6, $zero, $zero
	add	$t9, $zero, $zero

main_loop:
	
	addi	$a3, $zero, 3
	
	div	$t9, $a3			# $s7 = 3
	mfhi	$t9
	
	beq	$t9, $zero, printData_1
	
	addi	$a3, $zero, 1
	beq	$t9, $a3, printData_2
	
	addi	$a3, $zero, 2
	beq	$t9, $a3, printData_3

#-----------PRINT_I -------------#
# disk 1, 2 chua du lieu
# disk 3 parity	
printData_1:
	
	addi	$t6, $t6, 1

	add	$s7, $zero, $zero
 		
	jal 	Break_line
	jal	Print_ke_thang		# "|   "   
	jal	Print_5space
	
#Print disk 1
loop11:	
	lb	$a0, 0($s4)
	li	$v0, 11
	syscall
	
	beq	$s7, $t7, end_loop11	
	addi	$s4, $s4, 1
	addi	$s7, $s7, 1
	j 	loop11
end_loop11:	
	jal	Print_5space
	jal	Print_ke_thang		#"    |"
	

	
	add	$s7, $zero, $zero
	
	jal	Print_tab
	jal	Print_tab
	jal	Print_ke_thang		# "|   " 
	jal	Print_5space
	
#Print disk 2
loop12:	
	lb	$a0, 0($s5)
	li	$v0, 11
	syscall
	
	beq	$s7, $t7, end_loop12
	addi	$s5, $s5, 1
	addi	$s7, $s7, 1
	j 	loop12
	
end_loop12:	
	jal	Print_5space
	jal	Print_ke_thang		#"    |"
	

	add	$s7, $zero, $zero

	jal	Print_tab
	jal	Print_tab
	jal	Print_mo_ngoac_vuong	#"[[    "
	jal	Print_mo_ngoac_vuong
	jal	Print_space
#Print disk 3 (parity)
loop13:	
	lb	$t5, 0($s6)
	jal 	Hexa
	
	beq	$s7, $t7, end_loop13
	
	li	$a0, 0x2C
	li	$v0, 11
	syscall
	
	addi	$s6, $s6, 1
	addi	$s7, $s7, 1
	j 	loop13

end_loop13:
	jal	Print_space
	jal	Print_dong_ngoac_vuong		#"    ]]"
	jal	Print_dong_ngoac_vuong
	
	beq	$t6, $t8, end
	addi	$s4, $s4, 1
	addi	$s5, $s5, 1
	addi	$s6, $s6, 1
	addi	$t9, $t9, 1
	j 	main_loop

#-----------PRINT_II -------------#
# disk 1, 3 chua du lieu
# disk 2 parity	

printData_2:
	
	addi	$t6, $t6, 1

	add	$s7, $zero, $zero
 		
	jal 	Break_line
	jal	Print_ke_thang		# "|   " 
	jal	Print_5space
	
#Print disk 1
loop21:	
	lb	$a0, 0($s4)
	li	$v0, 11
	syscall
	
	beq	$s7, $t7,end_loop21	
	addi	$s4, $s4, 1
	addi	$s7, $s7, 1
	j 	loop21
end_loop21:	
	jal	Print_5space
	jal	Print_ke_thang
	
	add	$s7, $zero, $zero
	
	jal	Print_tab
	jal	Print_tab
	jal	Print_mo_ngoac_vuong	#"[[    "
	jal	Print_mo_ngoac_vuong
	jal	Print_space
#Print disk 2(parity)
loop22:	
	lb	$t5, 0($s5)
	jal 	Hexa
	
	beq	$s7, $t7, end_loop22
	
	li	$a0, 0x2C
	li	$v0, 11
	syscall
	
	addi	$s5, $s5, 1
	addi	$s7, $s7, 1
	j 	loop22
	
end_loop22:	
	jal	Print_space
	jal	Print_dong_ngoac_vuong
	jal	Print_dong_ngoac_vuong	#"    ]]"
	
	add	$s7, $zero, $zero

	jal	Print_tab
	jal	Print_tab		# "|   " 
	jal	Print_ke_thang
	jal	Print_5space
	
#Print disk 3
loop23:	
	lb	$a0, 0($s6)
	li	$v0, 11
	syscall
	
	beq	$s7, $t7, end_loop23
	addi	$s6, $s6, 1
	addi	$s7, $s7, 1
	j 	loop23

end_loop23:
	jal	Print_5space
	jal	Print_ke_thang	
	
	beq	$t6, $t8, end
	addi	$s4, $s4, 1
	addi	$s5, $s5, 1
	addi	$s6, $s6, 1
	addi	$t9, $t9, 1
	j 	main_loop
	
#-----------PRINT_III -------------#
# disk 2, 3 chua du lieu
# disk 1 parity	

printData_3:
	
	addi	$t6, $t6, 1

	add	$s7, $zero, $zero
 		
	jal 	Break_line
	jal	Print_mo_ngoac_vuong
	jal	Print_mo_ngoac_vuong
	jal	Print_space
	
#Print disk 1(parity)
loop31:	
	lb	$t5, 0($s4)
	jal 	Hexa
	
	beq	$s7, $t7,end_loop31
	
	li	$a0, 0x2C
	li	$v0, 11
	syscall	
		
	addi	$s4, $s4, 1
	addi	$s7, $s7, 1
	j 	loop31
end_loop31:	
	jal	Print_space
	jal	Print_dong_ngoac_vuong
	jal	Print_dong_ngoac_vuong
	
	add	$s7, $zero, $zero
	
	jal	Print_tab
	jal	Print_tab
	jal	Print_ke_thang
	jal	Print_5space
	
#Print disk 2
loop32:	
	lb	$a0, 0($s5)
	li	$v0, 11
	syscall
	
	beq	$s7, $t7, end_loop32
	addi	$s5, $s5, 1
	addi	$s7, $s7, 1
	j 	loop32
	
end_loop32:	
	jal	Print_5space
	jal	Print_ke_thang
	

	add	$s7, $zero, $zero

	jal	Print_tab
	jal	Print_tab
	jal	Print_ke_thang
	jal	Print_5space
	
#Print disk 3
loop33:	
	
	
	lb	$a0, 0($s6)
	li	$v0, 11
	syscall
	
	beq	$s7, $t7, end_loop33
	addi	$s6, $s6, 1
	addi	$s7, $s7, 1
	j 	loop33

end_loop33:
	
	jal	Print_5space
	jal	Print_ke_thang
	
	beq	$t6, $t8, end_main_loop
	addi	$s4, $s4, 1
	addi	$s5, $s5, 1
	addi	$s6, $s6, 1
	addi	$t9, $t9, 1
	j 	main_loop	
	
end_main_loop:	
	jal	Break_line

	add	$a3, $zero, $zero
	addi	$s7, $zero, 3
	
printLine_2:

	addi	$a3, $a3, 1
	
	
	la	$a0, line
	li	$v0, 4
	syscall
	
	la	$a0, tab
	li	$v0, 4
	syscall
	
	la	$a0, tab
	li	$v0, 4
	syscall
	
	beq	$a3, $s7, end
	j	printLine_2	
	
#-----------Xu ly so thap luc phan ------------------#
Hexa:
	srl	$t4, $t5, 4
	andi	$t4, $t4, 0x0000000f
	la	$a1, hex
	add	$a1, $a1, $t4
	lb	$a0, 0($a1)
	li	$v0, 11
	syscall
		
	andi	$t5, $t5, 0x0000000f
	la	$a1, hex
	add	$a1, $a1, $t5
	lb	$a0, 0($a1)
	li	$v0, 11
	syscall
	
	jr	$ra
	
	
		
#----------- In ra mot so ky tu dac biet ------------#

Print_ke_thang:
	li	$a0, 0x7C 
	li	$v0, 11
	syscall
	jr	$ra
	
Print_space:
	li	$a0, 0x20
	li	$v0, 11
	syscall
	jr	$ra

Print_mo_ngoac_vuong:
	li	$a0, 0x5B
	li	$v0, 11
	syscall
	jr	$ra
	

Print_dong_ngoac_vuong:
	li	$a0, 0x5D
	li	$v0, 11
	syscall
	jr	$ra		
	
Print_tab:
	la	$a0, tab
	li	$v0, 4
	syscall
	jr	$ra

Print_5space:
	la	$a0, space
	li	$v0, 4
	syscall
	jr	$ra

Break_line:
	la	$a0, brkline
	li	$v0, 4
	syscall	
	jr	$ra
error:
	la	$a0, err
	li	$a1, 2
	li	$v0, 55
	syscall		
end:
	li	$v0, 10
	syscall	
	
	
	
	
	
	
	
	
	
