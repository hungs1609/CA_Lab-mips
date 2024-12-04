#	8 Mo phong o dia RAID 5
#	He thong o dia RAID5 can toi thieu 3 o dia cung trong do phan du lieu parity se duoc chua lan luot len 3
#	o dia nhu trong hinh ben Hay viet chuong trinh mo phong hoat dong cua RAID 5 voi 3 o dia voi gia dinh
#	rang moi block du lieu co 4 ki tu Giao dien nhu trong minh hoa duoi Gioi han chuoi ki tu nhap vao co do
#	dai la boi cua 8 	DCE.****ABCD1234HUSTHUST
.data
Start: .asciiz "Nhap chuoi ky tu : "
Hex: .byte '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' 
Disk1: .space 4
Disk2: .space 4
Disk3: .space 4
Array: .space 32
String: .space 1000
Enter: .asciiz "\n"
Error: .asciiz "Do dai chuoi khong hop le! Nhap lai.\n"
Message1: .asciiz "      Disk 1                 Disk 2               Disk 3\n"
Message2: .asciiz "----------------       ----------------       ----------------\n"
Message3: .asciiz "|     "
Message4: .asciiz "     |       "
Message5: .asciiz "[[ "
Message6: .asciiz "]]       "
Comma: .asciiz ","
.text
Input:	
	li $v0, 4		# in chuoi Start
	la $a0, Start
	syscall
	li $v0, 8		# doc chuoi tu ban phim
	la $a0, String	 
	li $a1, 1000	
	syscall
	addi $s0, $a0, 0	# s0 = dia chi xau vua nhap
	li $v0, 4
	la $a0, Message1	
	syscall		# in chuoi
	li $v0, 4
	la $a0, Message2
	syscall
# Kiem tra do dai co chia het cho 8 hay khong
	addi $t3, $zero, 0 	# t3 = chieu dai xau
	addi $t0, $zero, 0 	# t0 = bien chay
Length: 
	add $t1, $s0, $t0 	# t1 = dia chi String[i]
	lb $t2, 0($t1) 	# t2 = String[i]
	nop
	beq $t2, 10, Test 	# t2 = '\n' ket thuc xau
	nop
	addi $t3, $t3, 1 	# length++
	addi $t0, $t0, 1	# index++
	j Length
	nop
Test: 
	and $t1, $t3, 0x0000000f		# xoa het cac byte cua $t3 ve 0, chi giu lai byte cuoi
	beq $t1, 0, Line1			# byte cuoi bang 0 hoac 8 thi so chia het cho 8
	beq $t1, 8, Line1
	li $v0, 4
	la $a0, Error
	syscall
	j Input
# Tinh parity
HEX:	
	li $t4, 7
loopH:	
	blt $t4, $0, endloopH		#  Ket thuc khi t4 < 0
	sll $s6, $t4, 2			# s6 = t4 * 4 = 28
	srlv $a0, $t8, $s6			# a0 = t8 >> s6
	andi $a0, $a0, 0x0000000f	# lay byte cuoi cung cua a0 
	la $t7, Hex 
	add $t7, $t7, $a0 	
	bgt $t4, 1, nextc			# Neu t4 > 1 thi chuyen sang nextc 
	lb $a0, 0($t7) 			# in Hex[a0]
	li $v0, 11
	syscall
nextc:	
	addi $t4, $t4, -1
	j loopH
endloopH: 
	jr $ra
# Mo phong Raid 5
Line1:	
	addi $t0, $zero, 0
	la $s1, Disk1
	la $s2, Disk2
	la $s3, Array
	li $v0, 4		# in "|      "
	la $a0, Message3
	syscall
Loop1:
# Disk 1
	lb $t1, ($s0)		# t1 chua dia chi tung byte cua disk 1
	addi $t3, $t3, -1
	sb $t1, ($s1)		# luu t1 vao s1
# Disk 2
	add $s5, $s0, 4
	lb $t2, ($s5)		# t2 chua dia chi tung byte cua disk 2
	addi $t3, $t3, -1
	sb $t2, ($s2)
# Disk 3
	xor $a3, $t1, $t2
	sw $a3, ($s3)  	# luu a3 vao mang 
	addi $s3, $s3, 4	# s3 += 4 
	addi $t0, $t0, 1 	# so byte in ra + 1
	addi $s0, $s0, 1	# dia chi xau + 1 
	addi $s1, $s1, 1 	# s1 ++
	addi $s2, $s2, 1	# s2 ++
	blt $t0, 4, Loop1	# neu t0 < 4 -> In tiep
	la $s1, Disk1		
	la $s2, Disk2
	addi $t9, $zero, 0
Loop11:
	lb $a0, ($s1)		# in 4 byte dau cua xau
	li $v0, 11		
	syscall		
	addi $t9, $t9, 1
	addi $s1, $s1, 1
	blt $t9, 4, Loop11
	li $v0, 4		# in "       |     "
	la $a0, Message4
	syscall
	li $v0, 4
	la $a0, Message3	# in " |      "
	syscall
	addi $t9, $zero, 0
Loop12:
	lb $a0, ($s2)		# in 4 byte tiep theo
	li $v0, 11
	syscall
	addi $t9, $t9, 1
	addi $s2, $s2, 1
	blt $t9, 4, Loop12	
	li $v0, 4	
	la $a0, Message4
	syscall		# in "       |      "
	li $v0, 4
	la $a0, Message5	# in "[[   "
	syscall
	la $s3, Array		
	addi $t9, $zero, 0
	addi $t8, $zero, 0
Loop13:
	lb $t8, ($s3)		# t8 = mang disk 3
	jal HEX		# in disk 3
	li $v0, 4
	la $a0, Comma	# in ", "
	syscall
	addi $t9, $t9, 1
	addi $s3, $s3, 4
	blt $t9, 3, Loop13	# in 3 dau phay thi dung
	lb $t8, ($s3)
	jal HEX
	li $v0, 4
	la $a0, Message6	# in " ]]"
	syscall		
	li $v0, 4		# xuong dong
	la $a0, Enter
	syscall
	beq $t3, 0, Exit	#  neu ket thuc xau, kt chuong trinh
# Line 2
	la $s2, Array		# Line 2, 3 tuong tu
	la $s1, Disk1
	la $s3, Disk3
	addi $s0, $s0, 4
	addi $t0, $zero, 0
	li $v0, 4
	la $a0, Message3
	syscall
Loop2:	
	lb $t1, ($s0)
	addi $t3, $t3, -1
	sb $t1, ($s1)
	add $s5, $s0, 4
	lb $t2, ($s5)
	addi $t3, $t3, -1
	sb $t2, ($s3)
	xor $a3, $t1, $t2
	sw $a3, ($s2)
	addi $s2, $s2, 4
	addi $t0, $t0, 1
	addi $s0, $s0, 1
	addi $s1, $s1, 1
	addi $s3, $s3, 1
	blt $t0, 4, Loop2
	la $s1, Disk1
	la $s3, Disk3
	addi $t9, $zero, 0
Loop21:
	lb $a0, ($s1)
	li $v0, 11
	syscall
	addi $t9, $t9, 1
	addi $s1, $s1, 1
	blt $t9, 4, Loop21
	li $v0, 4
	la $a0, Message4
	syscall
	la $s2, Array
	addi $t9, $zero, 0
	li $v0, 4
	la $a0, Message5
	syscall
Loop22:
	lb $t8, ($s2)
	jal HEX
	li $v0, 4
	la $a0, Comma
	syscall
	addi $t9, $t9, 1
	addi $s2, $s2, 4
	blt $t9, 3, Loop22
	lb $t8, ($s2)
	jal HEX
	li $v0, 4
	la $a0, Message6
	syscall
	li $v0, 4
	la $a0, Message3
	syscall
	addi $t8, $zero, 0
Loop23:
	lb $a0, ($s3)
	li $v0, 11
	syscall
	addi $t8, $t8, 1
	addi $s3, $s3, 1
	blt $t8, 4, Loop23
	li $v0, 4
	la $a0, Message4
	syscall
	li $v0, 4
	la $a0, Enter
	syscall
	beq $t3, 0, Exit
# Line 3
	la $a2, Array	 # tuong tu
	la $s2, Disk2
	la $s3, Disk3
	addi $s0, $s0, 4
	addi $t0, $zero, 0
	li $v0, 4
	la $a0, Message5
	syscall
Loop3:
	lb $t1, ($s0)
	addi $t3, $t3, -1
	sb $t1, ($s1)
	add $s5, $s0, 4
	lb $t2, ($s5)
	addi $t3, $t3, -1
	sb $t2, ($s3)
	xor $a3, $t1, $t2
	sw $a3, ($a2)
	addi $a2, $a2, 4
	addi $t0, $t0, 1
	addi $s0, $s0, 1
	addi $s1, $s1, 1
	addi $s3, $s3, 1
	blt $t0, 4, Loop3
	la $s2, Disk2
	la $s3, Disk3
	la $a2, Array
	addi $t9, $zero, 0
Loop31:
	lb $t8, ($a2)
	jal HEX
	li $v0, 4
	la $a0, Comma
	syscall
	addi $t9, $t9, 1
	addi $a2, $a2, 4
	blt $t9, 3, Loop31	
	lb $t8, ($a2)
	jal HEX
	li $v0, 4
	la $a0, Message6
	syscall
	li $v0, 4
	la $a0, Message3
	syscall
	addi $t9, $zero, 0
Loop32:
	lb $a0, ($s2)
	li $v0, 11
	syscall
	addi $t9, $t9, 1
	addi $s2, $s2, 1
	blt $t9, 4, Loop32
	addi $t9, $zero, 0
	addi $t8, $zero, 0
	li $v0, 4
	la $a0, Message4
	syscall	
	li $v0, 4
	la $a0, Message3
	syscall	
Loop33:
	lb $a0, ($s3)
	li $v0, 11
	syscall
	addi $t8, $t8, 1
	addi $s3, $s3, 1
	blt $t8, 4, Loop33
	li $v0, 4
	la $a0, Message4
	syscall
	li $v0, 4
	la $a0, Enter
	syscall
	beq $t3, 0, Exit
# Chua het chuoi, xet 6 block tiep theo
Next: 
	addi $s0, $s0, 4	# ky tu tiep theo 
	j Line1		# quay lai in tu dong 1
Exit:	
	li $v0, 4
	la $a0, Message2	
	syscall
	li $v0, 10
	syscall
