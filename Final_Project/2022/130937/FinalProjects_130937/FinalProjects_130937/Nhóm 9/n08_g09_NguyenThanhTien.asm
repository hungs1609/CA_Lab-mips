.data
string: 			.space		128
input:	.asciiz		"Nhap chuoi: "
errormess:	.asciiz		"Chuoi Nhap Vao Khong Phai Boi Cua 8\n"
menumess:	.asciiz 	"Menu Chuong trinh\n 1 .NhapChuoi\n 2.Quit"
endmess:	.asciiz 	"\n exit success!"
space:			.asciiz		"     "
header: 	.asciiz		"     Disk 1               Disk 2               Disk 3\n"
line:		.asciiz		" --------------       --------------       --------------\n"
print_beginP:			.asciiz		"[[ "
print_endP:			.asciiz		"]]"
.align 2
data:			.space		4


.text
	addi $s6,$0,1
	addi $s7,$s0,2
NEW:  
	li		$v0, 51								# In Ra menu De Lua Chon
	la		$a0, menumess
	syscall
	beq $s7,$a0,QUIT
	bne $s6,$a0,NEW
	li		$v0, 4								
	la		$a0, input
	syscall
	
	li		$v0, 8								# Nhap chuoi
	la		$a0, string							# Dia Chi
	li		$a1, 128							# gioi han cua chuoi nhap vao
	syscall		
	addi $t1,$0,0
CHECK_LENGTH:
	add $a1,$a0,$t1
	lb $t0,0($a1)
	beq $0,$t0,END_CHECK
	addi $t1,$t1,1
	j CHECK_LENGTH
END_CHECK:
	addi $t1,$t1,-1	
	addi $t8,$0,8
	div $t1,$t8
	mfhi  $t8
	bne $t8,$0,ERROR
#----------------------------------------------------------------------------------------------------------------------
# Ve giao dien
#----------------------------------------------------------------------------------------------------------------------							
first_line:
	li		$v0, 4							
	la		$a0, header
	syscall
	la		$a0, line						
	syscall
	la		$s0, string

loop:
	lw		$t0, 0($s0)
	lw		$t1, 4($s0)
	li		$t2, 10                    
	beq		$t0, $t2, end_loop                  # check line feed "kiem tra ki tu xuong dong de ket thuc thuat toan"
#----------------------------------------------------------------------------------------------------------------------
# Ve split thu 1
#----------------------------------------------------------------------------------------------------------------------	
	move	$a1, $t0 
	jal		print_block
	move	$a1, $t1	
	jal		print_block
	jal		caculator_and_print_partition
	li		$v0, 11								
	li		$a0, 10
	syscall
	addi	$s0, $s0, 8 						#thay doi $s0 den vi tri can xet tiep theo trong string 
	lw		$t0, 0($s0)
	lw		$t1, 4($s0)
	li		$t2, 10
	beq		$t0, $t2, end_loop
#----------------------------------------------------------------------------------------------------------------------
# Ve split thu 2
#----------------------------------------------------------------------------------------------------------------------
	move	$a1, $t0
	jal		print_block
	jal		caculator_and_print_partition
	move	$a1, $t1	
	jal		print_block
	li		$v0, 11								
	li		$a0, 10
	syscall
	addi	$s0, $s0, 8
	lw		$t0, 0($s0)
	lw		$t1, 4($s0)
	li		$t2, 10
	beq		$t0, $t2, end_loop
	jal		caculator_and_print_partition
#----------------------------------------------------------------------------------------------------------------------
# Ve split thu 3
#----------------------------------------------------------------------------------------------------------------------
	move	$a1, $t0
	jal		print_block
	move	$a1, $t1	
	jal		print_block
	li		$v0, 11								
	li		$a0, 10
	syscall
	addi	$s0, $s0, 8
	j		loop
end_loop: 
	li		$v0, 4
	la		$a0, line
	syscall
	j NEW
#-----------------------------------------------------------------------------------------------------------------------
# chuyen doi tung ki tu hexa sang dang string 
#-----------------------------------------------------------------------------------------------------------------------
changeto_character:
	and		$t8, $a0, 0xf        # lay 4 bit dau trong 8 bit da lay ra
	bgt		$t8, 9, check1     
	li		$v0, 48                   
	add		$v0, $v0, $t8              # "0" + $t8 = string("$t8")
	j 		continue
check1:
	li		$v0, 87                    
	add		$v0, $v0, $t8			# 'a'(97) - 10(0xa) + $t8 = string("$t8") 
continue:
	sll		$v0, $v0, 8                     # lay khoang trong de cong tiep gia tri cua 4bit xet sau                               
	srl		$t8, $a0, 4                    #  xoa di cac bit vua check o tren
	bgt		$t8, 0x9, check2
	addi	$v0, $v0, 48
	add		$v0, $v0, $t8
	j		end_change
check2:
	addi	$v0, $v0, 87 
	add		$v0, $v0, $t8      
end_change:
	jr		$ra
#-----------------------------------------------------------------------------------------------------------------------
# In ra giao dien 1 block gom 4 ki tu trong string da nhap vao
#-----------------------------------------------------------------------------------------------------------------------
print_block:
	li		$v0, 11
	li		$a0, 0x7c                  # in ra | (0x7c = "|")
	syscall
	li		$v0, 4                    
	la		$a0, space
	syscall
	la		$a0, data      		# print string 4 character is 0($a) -> 3($a) litte-endian
	sw		$a1, 0($a0)
	syscall
	la		$a0, space		
	syscall
	li		$v0, 11
	li		$a0, 0x7c                 
	syscall
	li		$v0, 4
	la		$a0, space                
	syscall
	jr		$ra
#-----------------------------------------------------------------------------------------------------------------------
# Tinh Toan 
#-----------------------------------------------------------------------------------------------------------------------
caculator_and_print_partition:
	li		$v0, 4
	sw		$ra, 0($sp)
	la		$a0, print_beginP
	syscall
	xor		$s1, $t0, $t1
	and		$a0, $s1, 0xff       #lay 8 bit dau cua $s1  ghi vao thanh ghi a0
	jal		changeto_character   #chuyen doi ki tu hexa sang cac ki tu character
	la		$a0, data
	sw		$v0, 0($a0)
	li		$v0, 4
	syscall
	li		$a0, ','
	li		$v0, 11
	syscall
	srl		$s1, $s1, 8
	and		$a0, $s1, 0xff 
	jal		changeto_character
	la		$a0, data
	sw		$v0, 0($a0)
	li		$v0, 4
	syscall
	li		$a0, ','
	li		$v0, 11
	syscall
	srl		$s1, $s1, 8
	and		$a0, $s1, 0xff
	jal		changeto_character
	la		$a0, data
	sw		$v0, 0($a0)
	li		$v0, 4
	syscall
	li		$a0, ','
	li		$v0, 11
	syscall
	srl		$s1, $s1, 8
	and		$a0, $s1, 0xff
	jal		changeto_character
	la		$a0, data
	sw		$v0, 0($a0)
	li		$v0, 4
	syscall
	la		$a0, print_endP
	syscall
	la		$a0, space
	syscall
	lw		$ra, 0($sp)
	jr		$ra
#-----------------------------------------------------------------------------------------------------------------------
# In ra Loi neu chuoi dau vao co length khong phai boi cua 8
#-----------------------------------------------------------------------------------------------------------------------
ERROR:
	li		$v0, 4								
	la		$a0, errormess
	syscall
	j NEW
#-----------------------------------------------------------------------------------------------------------------------
# Phan Ket Thuc Chuong trinh
#-----------------------------------------------------------------------------------------------------------------------	
QUIT:
	li		$v0, 4								
	la		$a0, endmess
	syscall
