.data
	title1: .asciiz  "Nhap chuoi ki tu : " 
	title2: .asciiz	 "     Disk 1                Disk 2                Disk 3\n"
	title3: .asciiz	 " --------------        --------------        --------------\n"
	title4: .asciiz  "|     "
	title5: .asciiz  "     |"
	title6: .asciiz  "[[ "
	title7: .asciiz  "]]"
	title8: .asciiz  "      "
	title9: .asciiz  "\n"
	title10: .asciiz ","
	error_length: .asciiz "Do dai chuoi khong hop le! Nhap lai.\n"
	
	str: .space 100		# bien luu chuoi nhap tu ban phim
	block1: .space 100	# block 1
	block2: .space 100	# block 2
	block3: .space 100	# block 3 (ket qua phep xor)

# ------------------------------------------------------------------------------------------------
# TAC DUNG CUA CAC THANH GHI BIEN

# s0 : dia chi chua ky tu trong chuoi str
# s1 : dia chi block 1
# s2 : dia chi block 2
# s3 : dia chi block 3 (chua su dung)
# s4 : check dieu kien chuoi la boi cua 8
# s5 : ky tu lay ra tu trong chuoi str
# s6 : bien chi dinh disk save parity

# ------------------------------------------------------------------------------------------------


.text 	
input:
	# title nhap chuoi
 	li $v0, 4
 	la $a0, title1
 	syscall
 	
 	# doc chuoi tu ban phim
 	li $v0, 8
 	la $a0, str
 	li $a1, 100
 	syscall
 	
main:
 	la $s0, str	# s0 = address(str) -> $s0 chỉ đến kí tự đầu tiên trong chuỗi nhập
length: 
	addi $t3, $zero, 0 	# t3 = length
	addi $t0, $zero, 0 	# t0 = index -> chỉ số
	

check_char: 
	add $t1, $s0, $t0 	# t1 = address of string[i]
	lb $t2, 0($t1) 		# t2 = string[i]
	nop
	beq $t2, 10, test_length 	# t2 = '\n' ket thuc xau
	nop
	addi $t3, $t3, 1 	# length++
	addi $t0, $t0, 1	# index++
	j check_char
	nop
test_length: 
	and $t1, $t3, 0x0000000f		# xoa het cac byte cua $t3 ve 0, chi giu lai byte cuoi 
	bne $t1, 0, test1			# byte cuoi bang 0 hoac 8 thi so chia het cho 8
	j raid5
test1:	
	beq $t1, 8, raid5
error1:	
	li $v0, 4
	la $a0, error_length
	syscall
	j input
raid5: 
	# tieu de output
 	li $v0, 4
 	la $a0, title2
 	syscall
 	
 	# ky tu ngan cach
 	li $v0, 4
 	la $a0, title3
 	syscall
  	la $s1, block1	# s1 = address(block1)    -> block1, block2 luu du lieu; block3 luu ket qua xor
 	la $s2, block2	# s2 = address(block2)	
 		
 	li $s6, 0
 	# quy tac luu parity: 0 -> disk 3; 1 -> disk 2; 2 -> disk 1

start:
	li $s4, 0		# reset lai sau 8 byte duoc doc tu chuoi str
 	 	
check_block_full:
	beq $s4, 8, block_3
load_from_str:
 	lb $s5, 0($s0)		# lay ky tu tai dia chi s0 -> $s5 = string[0]
 	addi $s0, $s0, 1	# tang dia chi s0 len 1      
 	beq $s5, '\n', exit_main	# neu ket thuc chuoi thi thoat main
 
 	addi $s4, $s4, 1	# so thu tu ky tu vua lay ra tu str 
 	nop
 	slti $t1, $s4, 5	# neu so thu tu nho hon 5 thi luu vao block 1
 	beq $t1, 1, block_1
 	j block_2
 	
 	
block_1:
	sb $s5, 0($s1)		# luu ky tu vao block 1 [i]
	addi $s1, $s1, 1	# tang len block 1 [i+1]
	j load_from_str		# quay lai doc ky tu tiep theo trong str

block_2: 	
	sb $s5, 0($s2)		# luu ky tu vao block 2 [i]
	addi $s2, $s2, 1	# tang len block 2 [i+1]
	j check_block_full	# quay lai check so ky tu da luu 

block_3:
	addi $s1, $s1, -4	# quay ve dia chi ky tu dau tien trong block 1
	addi $s2, $s2, -4	# quay ve dia chi ky tu dau tien trong block 2
	
	add $t8, $s1, $zero	# t8 = s1
	add $t9, $s2, $zero	# t9 = s2
	
	li $t4, 0		# bien dem so lan xor

save_to_disk:
	beq $s6, 0, disk_3_parity
	beq $s6, 1, disk_2_parity
	beq $s6, 2, disk_1_parity

disk_1_parity: 
	nop
	# ki tu mo block 3
 	li $v0, 4
 	la $a0, title6
 	syscall
 	
	nop
	jal save_block_3	# save block 3 vao disk 1
	nop 
	
	# ki tu dong block 3
 	li $v0, 4
 	la $a0, title7
 	syscall
	
	# ki tu cach giua cac disk
 	li $v0, 4
 	la $a0, title8
 	syscall
	
	nop
	jal save_block_1	# save block 1 vao disk 2
	
	# ki tu cach giua cac disk
 	li $v0, 4
 	la $a0, title8
 	syscall
	
	nop 
	jal save_block_2	# save block 2 vao disk 3
	nop
	
	j refresh_disk_parity

disk_2_parity:
	nop 
	jal save_block_1	# save block 1 vao disk 1
	nop
	
	# ki tu cach giua cac disk
 	li $v0, 4
 	la $a0, title8
 	syscall
 	
 	nop
	# ki tu mo block 3
 	li $v0, 4
 	la $a0, title6
 	syscall
	
	nop
	jal save_block_3	# save block 3 vao disk 2
	nop
	
	# ki tu dong block 3
 	li $v0, 4
 	la $a0, title7
 	syscall
	
	# ki tu cach giua cac disk
 	li $v0, 4
 	la $a0, title8
 	syscall
	
	nop
	jal save_block_2	# save block 2 vao disk 3
	nop
	
	j refresh_disk_parity

disk_3_parity: 
	nop
	jal save_block_1	# save block 1 vao disk 1
	nop
	
	# ki tu cach giua cac disk
 	li $v0, 4
 	la $a0, title8
 	syscall
	
	nop
	jal save_block_2	# save block 2 vao disk 2
	nop
	
	# ki tu cach giua cac disk
 	li $v0, 4
 	la $a0, title8
 	syscall
	
	nop
	# ki tu mo block 3
 	li $v0, 4
 	la $a0, title6
 	syscall
 	
 	nop
	jal save_block_3	# # save block 3 vao disk 3
	nop
	
	# ki tu dong block 3
 	li $v0, 4
 	la $a0, title7
 	syscall
	
	
	j refresh_disk_parity
	
	
save_block_1:
	# ki tu mo
	li $v0, 4
 	la $a0, title4
 	syscall
 	
 	# noi dung disk
 	li $v0, 4
 	la $a0, block1
 	syscall
 	
 	# ki tu dong
 	li $v0, 4
 	la $a0, title5
 	syscall
 		
 	nop
 	jr $ra

save_block_2:
	# ki tu mo
	li $v0, 4
 	la $a0, title4
 	syscall
 	
 	# noi dung disk
 	li $v0, 4
 	la $a0, block2
 	syscall
 	
 	# ki tu dong
 	li $v0, 4
 	la $a0, title5
 	syscall

 	nop
 	jr $ra

save_block_3:
	lb $t1, 0($t8)		# lay ky tu block 1 [i]
	lb $t2, 0($t9)		# lay ky tu block 2 [i]
	xor $t3, $t1, $t2	# xor 2 ky tu
	addi $t4, $t4, 1	# so lan xor tang len 1
	
	# chuyen ve he co so 16
	div $a0, $t3, 16	# lay thuong khi chia cho 16
	li $t6, 0		# thong bao dang lay thuong
	j check_quotient_remainder
	
save_block_3_back_1:
	mfhi $a0		# lay du khi chia cho 16
	li $t6, 1		# thong bao dang lay du
	j check_quotient_remainder
	
save_block_3_back_2:
	addi $t8, $t8, 1	# tang len block 1 [i+1]
	addi $t9, $t9, 1	# tang len block 2 [i+1]
	j save_block_3		# tiep tuc xor 2 ki tu tiep theo trong block 1 va 2

# kiem tra thuong hoac du co < 10 khong
check_quotient_remainder:
	slti $t5, $a0, 10
	beq $t5, 1, print_int
	
# neu >= 10 thi chuyen sang ky tu A,B,C,D,E,F
convert_char_16:
	beq $a0, 10, print_A
	beq $a0, 11, print_B
	beq $a0, 12, print_C
	beq $a0, 13, print_D
	beq $a0, 14, print_E
	beq $a0, 15, print_F
	
	
print_A:
	li $a0, 'A'
	j print_char
	
print_B:
	li $a0, 'B'
	j print_char
	
print_C:
	li $a0, 'C'
	j print_char	
	
print_D:
	li $a0, 'D'
	j print_char

print_E:
	li $a0, 'E'
	j print_char

print_F:
	li $a0, 'F'
	j print_char
	
print_char:
	li $v0, 11
	syscall
	nop
	j exit_or_back

print_int:
	li $v0, 1
	syscall
	nop
	j exit_or_back
	
exit_or_back:
	beq $t6, 0, save_block_3_back_1	# da lay thuong
	beq $t6, 1, print_comma		# da lay du
	
print_comma:
	beq $t4, 4, complete_block_3 	# neu t4 = 4 thi khong in dau phay va hoan thanh block 3
	# in dau phay neu t4 < 4
	li $v0, 4
 	la $a0, title10
 	syscall
 	j save_block_3_back_2
	
# hoan thanh block 3
complete_block_3:	
	jr $ra
	
refresh_disk_parity:
	# xuong dong
	li $v0, 4
 	la $a0, title9
 	syscall
	#chuyen doi disk parity
	addi $s6, $s6, 1	# tang them 1 vao bien de xac dinh disk save parity tiep theo
	div $s6, $s6, 3		# chia 3 lay du
	mfhi $s6 		# lay du
	j start

 	
exit_main:
	# ky tu ngan cach
 	li $v0, 4
 	la $a0, title3
 	syscall

	# ket thuc chuong trinh
 	li $v0, 10
 	syscall
 	
