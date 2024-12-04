.data
input: 	.space	64
start:	.asciiz	"Nhap chuoi ky tu : "
space:	.asciiz		"     "
m0:	.asciiz "Chon chuc nang: 1. Chay  2. Thoat"
m1: 	.asciiz	 "      Disk 1                 Disk 2               Disk 3\n"
m2:	.asciiz	 " --------------       --------------       --------------\n"
m3:	.asciiz	 	"[[ "
m4:	.asciiz		"]]"
error_length: .asciiz "Do dai chuoi khong hop le! Hay nhap lai.\n"
.align 2
data:			.space		4


.text
#Menu
	addi $t4, $0, 1
	addi $t5, $0, 2
Menu:	
	li		$v0, 51								
	la		$a0, m0
	syscall
	beq $t5, $a0, End
	bne $t4, $a0, Menu
Nhap:
	li		$v0, 4								# print start
	la		$a0, start
	syscall
	li		$v0, 8								# read input
	la		$a0, input							# address of input buffer
	li		$a1, 64								# max length
	syscall
	move $s0, $a0		# s0 chua dia chi xau moi nhap
#kiem tra do dai co chia het cho 8 khong
length: addi $s3, $zero, 0 	# s3 = length
	addi $s6, $zero, 0 	# s6 = index

check_char: add $s7, $s0, $s6 	# s7 = address of string[i]
	lb $t6, 0($s7) 		# t6 = string[i]
	nop
	beq $t6, 10, test_length 	# t6 = '\n' ket thuc xau
	nop
	addi $s3, $s3, 1 	# length++
	addi $s6, $s6, 1	# index++
	j check_char
	nop
test_length:
        beqz $s3, error1
 	move $s5, $s3        
	and $s7, $s3, 0x0000000f		# xoa het cac byte cua $s3 ve 0, chi giu lai byte cuoi
	bne $s7, 0, test1			# byte cuoi bang 0 hoac 8 thi so chia het cho 8
	j Line1
test1:	beq $s7, 8, Line1
	j error1
error1:	li $v0, 4                               #Khong phai chuoi boi cua 8 thi quay lai input
	la $a0, error_length
	syscall
	j Nhap
#ket thuc kiem tra do dai


#Print
Line1:
	li	$v0, 4						# print m1
	la	$a0, m1
	syscall
	la	$a0, m2						# print ----
	syscall
	la	$s0, input
loop:
	lw	$t0, 0($s0)
	lw	$t1, 4($s0)
	li	$t2, 10
	beq	$t0, $t2, end_loop				# Đến kí tự /n thì dừng
	move	$a1, $t0
	jal	print_word
	move	$a1, $t1	
	jal	print_word
	jal	show_partition
	li	$v0, 11						# new line
	li	$a0, 10
	syscall
	addi	$s0, $s0, 8
	lw	$t0, 0($s0)
	lw	$t1, 4($s0)
	li	$t2, 10
	beq	$t0, $t2, end_loop
	move	$a1, $t0
	jal	print_word
	jal	show_partition
	move	$a1, $t1	
	jal	print_word
	li	$v0, 11						# new line
	li	$a0, 10
	syscall
	addi	$s0, $s0, 8
	lw	$t0, 0($s0)
	lw	$t1, 4($s0)
	li	$t2, 10
	beq	$t0, $t2, end_loop
	jal	show_partition
	move	$a1, $t0
	jal	print_word
	move	$a1, $t1	
	jal	print_word
	li	$v0, 11						# new line
	li	$a0, 10
	syscall
	addi	$s0, $s0, 8
	j	loop
end_loop:
	li	$v0, 4
	la	$a0, m2
	syscall
	j Menu

hex_to_string:
	and	$t8, $a0, 0xf		 # Lay  vd b
	bgt	$t8, 0x9, condition1     # >9 hay k
	li	$v0, 0x30                # + 0 trong ascii
	add	$v0, $v0, $t8            # v0 = 0 + t8(<=9) = t8 trong ascii
	j 	next
condition1:
	li	$v0, 0x61                # + "a" ascii
	subi	$t9, $t8, 0xa            # -10
	add	$v0, $v0, $t9		 # Ket qua xor theo ascii 	
next:
	sll	$v0, $v0, 8              # Lay cho ghi ki tu thu 2
	srl	$t8, $a0, 4		 # Lay ki tu thu 2 de xet
	bgt	$t8, 0x9, condition2
	addi	$v0, $v0, 0x30
	add	$v0, $v0, $t8
	j	end_hts
condition2:
	addi	$v0, $v0, 0x61
	subi	$t9, $t8, 10
	add	$v0, $v0, $t9
end_hts:
	jr	$ra
	
print_word:
	li	$v0, 11			# print |
	li	$a0, 124
	syscall
	li	$v0, 4			# print space
	la	$a0, space
	syscall
	la	$a0, data
	sw	$a1, 0($a0) 		# print 4 ki tu
	syscall
	la	$a0, space
	syscall
	li	$v0, 11
	li	$a0, 124
	syscall
	li	$v0, 4
	la	$a0, space
	syscall
	jr	$ra

show_partition:
	li	$v0, 4
	sw	$ra, 0($sp)
	la	$a0, m3       		#print [[
	syscall
	xor	$s1, $t0, $t1
	and	$a0, $s1, 0xff          # Ket qua xor tung bit   vs 0xab
	jal	hex_to_string           # Chuyen ket qua xor sang ascii de in ra man hinh
	la	$a0, data               # in ra 2 chu
	sw	$v0, 0($a0)
	li	$v0, 4
	syscall
	li	$a0, ','
	li	$v0, 11
	syscall
	srl	$s1, $s1, 8
	and	$a0, $s1, 0xff
	jal	hex_to_string
	la	$a0, data
	sw	$v0, 0($a0)
	li	$v0, 4
	syscall
	li	$a0, ','
	li	$v0, 11
	syscall
	srl	$s1, $s1, 8
	and	$a0, $s1, 0xff
	jal	hex_to_string
	la	$a0, data
	sw	$v0, 0($a0)
	li	$v0, 4
	syscall
	li	$a0, ','
	li	$v0, 11
	syscall
	srl	$s1, $s1, 8
	and	$a0, $s1, 0xff
	jal	hex_to_string
	la	$a0, data
	sw	$v0, 0($a0)
	li	$v0, 4
	syscall
	la	$a0, m4
	syscall
	la	$a0, space
	syscall
	lw	$ra, 0($sp)
	jr	$ra
End:
