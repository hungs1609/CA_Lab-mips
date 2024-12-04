.data
nhap: .asciiz "Nhap vao chuoi ky tu : "
hex:   .byte '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' 
d1:    .space 4
d2:    .space 4
d3:    .space 4
array: .space 32
string:.space 10000
enter: .asciiz "\n"
m1:     .asciiz "      Disk 1                 Disk 2               Disk 3\n"
m2:    .asciiz "----------------       ----------------       ----------------\n"
m3:    .asciiz "|     "
m4:    .asciiz "     |       "
m5:    .asciiz "[[ "
m6:    .asciiz "]]       "
comma: .asciiz ","



m7:    .asciiz "Ban co muon nhap lai chuoi khac"
error_length: .asciiz "Do dai chuoi khong hop le! Moi nhap lai!\n"

.text
	la $s1, d1
	la $s2, d2
	la $s3, d3
	la $a2, array		# dia chi mang chua ma parity
	
input:	li $v0, 4		# nhap chuoi ki tu
	la $a0, nhap
	syscall
	li $v0, 8
	la $a0, string
	li $a1, 10000
	syscall
			
	
	
# Kiem tra do dai co phai la boi cua 8 khong
length: move $s0, $a0          # s0 chua dia chi xau moi nhap

        addi $t3, $zero, 0 	# t3 = length
	addi $t0, $zero, 0 	# i = 0

check_char: 
        add $t1, $s0, $t0 	# t1 = address of string[i]
	lb $t2, 0($t1) 		# t2 = string[i]
	nop
	beq $t2,10,test_length 	# t2 = '\n' ket thuc xau
	nop
	addi $t3, $t3, 1 	# length++
	addi $t0, $t0, 1	# index++
	j check_char
	nop
test_length: 
	and $t1, $t3, 0x0000000f		# giu lai chu so hexa cuoi
	bne $t1, 0, test1			# chu so hexa cuoi bang 0 hoac 8 thi length chia het cho 8
	j start
test1:	beq $t1, 8, start                     # kiem tra co phai bang 8 ?
	j error1
error1:	li $v0, 4
	la $a0, error_length                   # do dai xau khong hop le
	syscall
	j input
# Ket thuc kiem tra do dai

# Xu li ma parity
HEX:
        add  $t9,$t8,$0
        andi $t8,$t8,0x0000000f       # lay chu so hexa ben phai
        srl  $t9,$t9,4
        andi $t9,$t9,0x0000000f       # lay chu so hexa ben trai
        la $t5,hex
        move $t6,$t5
        add $t5,$t5,$t9
        add $t6,$t6,$t8
        lb $a0,0($t5)                 # print ma parity
        li $v0,11
        syscall
        lb $a0,0($t6)
        li $v0,11
        syscall
        jr $ra
# Ket thuc xu li ma parity

#------------------------------mo phong RAID 5-------------------------------
#-----------------------xet 6 khoi dau----------------------
#----------------lan 1: luu vao 2 khoi 1,2; xor vao 3-------
start:
	li $v0, 4
	la $a0, m1
	syscall
	li $v0, 4
	la $a0, m2
	syscall
# Xet nhom gom 2 block 4 byte thu nhat
split1:	addi $t0, $zero, 0	
	addi $t9, $zero, 0
	addi $t8, $zero, 0
	la $s1, d1           # disk 1
	la $s2, d2           # disk 2
	la $a2, array        # ma parity
print11:li $v0, 4
	la $a0, m3
	syscall
b11:	lb $t1, ($s0)
	addi $t3, $t3, -1
	sb $t1, ($s1)        # luu vao disk1
b21:	add $s5, $s0, 4
	lb $t2, ($s5)		
	addi $t3, $t3, -1
	sb $t2, ($s2)        # luu vao disk2
b31:	xor $a3, $t1, $t2   
	sw $a3, ($a2)        # luu vao array
	addi $a2, $a2, 4
	addi $t0, $t0, 1
	addi $s0, $s0, 1
	addi $s1, $s1, 1
	addi $s2, $s2, 1
	bgt $t0, 3, reset    # doc xong split1
	j b11
reset:	la $s1, d1
	la $s2, d2
	la $a2, array
print12:lb $a0, ($s1)        # print noi dung disk
	li $v0, 11
	syscall
	addi $t9, $t9, 1
	addi $s1, $s1, 1
	bgt $t9, 3, next11
	j print12	
next11:	li $v0, 4
	la $a0, m4
	syscall
	li $v0, 4
	la $a0, m3
	syscall
print13:lb $a0, ($s2)
	li $v0, 11
	syscall
	addi $t8, $t8, 1
	addi $s2, $s2, 1
	bgt $t8, 3, next12
	j print13
next12:	li $v0, 4
	la $a0, m4
	syscall
	li $v0, 4
	la $a0, m5
	syscall
	
	
	addi $t7, $zero, 0
print14:lw $t8, 0($a2)
	jal HEX
	addi $t7, $t7, 1
	addi $a2, $a2, 4
	bgt $t7, 3, end1
	
        li $v0, 4
	la $a0, comma
	syscall
		
	j print14	
end1:	
	li $v0, 4
	la $a0, m6
	syscall
	li $v0, 4
	la $a0, enter
	syscall
	beq $t3, 0, exit1            # kiem tra da doc het xau chua?
# Xet nhom gom 2 block 4 byte thu 2
split2:	la $a2, array
	la $s1, d1
	la $s3, d3
	addi $s0, $s0, 4
	addi $t0, $zero, 0
print21:li $v0, 4
	la $a0, m3
	syscall
b12:	lb $t1, ($s0)
	addi $t3, $t3, -1
	sb $t1, ($s1)
b32:	add $s5, $s0, 4
	lb $t2, ($s5)
	addi $t3, $t3, -1
	sb $t2, ($s3)
b22:	xor $a3, $t1, $t2
	sw $a3, ($a2)
	addi $a2, $a2, 4
	addi $t0, $t0, 1
	addi $s0, $s0, 1
	addi $s1, $s1, 1
	addi $s3, $s3, 1
	bgt $t0, 3, reset2
	j b12
reset2:	la $s1, d1
	la $s3, d3
	la $a2, array
	addi $t9, $zero, 0
print22:lb $a0, ($s1)
	li $v0, 11
	syscall
	addi $t9, $t9, 1
	addi $s1, $s1, 1
	bgt $t9, 3, next21
	j print22
next21:	li $v0, 4
	la $a0, m4
	syscall
	addi $t7, $zero, 0
	li $v0, 4
	la $a0, m5
	syscall
print23:lw $t8, 0($a2)
	jal HEX
	addi $t7, $t7, 1
	addi $a2, $a2, 4
	bgt $t7, 3, next22
	li $v0, 4
	la $a0, comma
	syscall
	
	j print23		
next22:	
	li $v0, 4
	la $a0, m6
	syscall
	li $v0, 4
	la $a0, m3
	syscall
	addi $t8, $zero, 0
print24:lb $a0, ($s3)
	li $v0, 11
	syscall
	addi $t8, $t8, 1
	addi $s3, $s3, 1
	bgt $t8, 3, end2
	j print24

end2:	li $v0, 4
	la $a0, m4
	syscall
	li $v0, 4
	la $a0, enter
	syscall
	beq $t3, 0, exit1
# Xet nhom gom 2 block 4 byte thu 3
split3:	la $a2, array
	la $s2, d2
	la $s3, d3
	addi $s0, $s0, 4
	addi $t0, $zero, 0
print31:li $v0, 4
	la $a0, m5
	syscall
b23:	lb $t1, ($s0)
	addi $t3, $t3, -1
	sb $t1, ($s2)
b33:	add $s5, $s0, 4
	lb $t2, ($s5)
	addi $t3, $t3, -1
	sb $t2, ($s3)
b13:	xor $a3, $t1, $t2
	sw $a3, ($a2)
	addi $a2, $a2, 4
	addi $t0, $t0, 1
	addi $s0, $s0, 1
	addi $s2, $s2, 1
	addi $s3, $s3, 1
	bgt $t0, 3, reset3
	j b23
reset3:	la $s2, d2
	la $s3, d3
	la $a2, array
	addi $t7, $zero, 0
print32:lw $t8, 0($a2)
	jal HEX
	addi $t7, $t7, 1
	addi $a2, $a2, 4
	bgt $t7, 3, next31
	li $v0, 4
	la $a0, comma
	syscall
	
	j print32		
next31:	
	li $v0, 4
	la $a0, m6
	syscall
	li $v0, 4
	la $a0, m3
	syscall
	addi $t9, $zero, 0
print33:lb $a0, 0($s2)
	li $v0, 11
	syscall
	addi $t9, $t9, 1
	addi $s2, $s2, 1
	bgt $t9, 3, next32
	j print33
next32:	li $v0, 4
	la $a0, m4
	syscall	
	li $v0, 4
	la $a0, m3
	syscall	
	addi $t9, $zero, 0
print34:lb $a0, ($s3)
	li $v0, 11
	syscall
	addi $t9, $t9, 1
	addi $s3, $s3, 1
	bgt $t9, 3, end3
	j print34

end3:	li $v0, 4
	la $a0, m4
	syscall
	li $v0, 4
	la $a0, enter
	syscall
	beq $t3, 0, exit1

        addi $s0, $s0, 4
	j split1
	
exit1:	li $v0, 4
	la $a0, m2
	syscall
	j ask
# ket thuc mo phong RAID 5

# nhap xau moi
ask:	li $v0, 50
	la $a0, m7
	syscall
	beq $a0, 0, input
	nop
	j exit
	nop

exit:	li $v0, 10
	syscall


