.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv KEY_CODE 0xFFFF0004 
.eqv KEY_READY 0xFFFF0000 	

#Key of Digital Lab Sim
.eqv input_0 0x11
.eqv input_1 0x21
.eqv input_2 0x41
.eqv input_3 0x81
.eqv input_4 0x12
.eqv input_5 0x22
.eqv input_6 0x42
.eqv input_7 0x82
.eqv input_8 0x14
.eqv input_9 0x24
.eqv input_a 0x44
.eqv input_b 0x84
.eqv input_c 0x18
.eqv input_d 0x28
.eqv input_e 0x48
.eqv input_f 0x88
# Marsbot
.eqv HEADING 0xffff8010 
.eqv MOVING 0xffff8050 
.eqv LEAVETRACK 0xffff8020 
.eqv WHEREX 0xffff8030 #toa do x cua marsbot
.eqv WHEREY 0xffff8040 #toa do y cua marsbot

#===============================================================================
.data

#Control code mac dinh
MOVE_CODE: .asciiz "1b4"
STOP_CODE: .asciiz "c68"
LEFT_CODE: .asciiz "444"
RIGHT_CODE: .asciiz "666"
TRACK_CODE: .asciiz "dad"
UNTRACK_CODE: .asciiz "cbc"
BACK_CODE: .asciiz "999"
WRONG_CODE: .asciiz "Wrong! Again"

#Khai bao cac bien de luu tru code nhap vao,bo nho dem truoc khi xoa de sau nay space, do dai code, vitri cua marsbot
INPUT: .space 50
SAVE: .space 50
LENGTH: .word 0
SAVE_LENGTH: .word 0
NOW_HEAD: .word 0
	
PATH: .space 600
LENGTH_PATH: .word 12
	
.text	
main:
	li $k0, KEY_CODE
 	li $k1, KEY_READY
	li $t1, IN_ADRESS_HEXA_KEYBOARD
	li $t2, 0x80 # bit 7 = 1 to enable
	sb $t2, 0($t1)
	

#-----------------------------------------------------------KeyBoard and Display MMIO--------------------------------------------
loop:		nop
WaitForKey:# nhap vao cac phim Enter/ Delete/ Space
		lw $t8, 0($k1)			#$t8 = [$k1] = KEY_READY
		beq $t8, $zero, WaitForKey	#if $t8 == 0 then Polling 
		nop
		beq $t8, $zero, WaitForKey

		lw $t8, 0($sp)
		addi $sp,$sp,-4
ReadKey:# Doc ky tu vua nhap tu Keyboard
	
		lw $t9, 0($k0)			#$t9 = [$k0] = KEY_CODE
		beq $t9, 127 , notPrint		
		nop
		beq $t9, 127 , notPrint		#if $t9 == delete key then remove input
		nop			
		beq $t9,32,reControl		#if $t9 == space key then reControl again
		bne $t9, '\n' , loop		#if $t9 != '\n' then Polling
		nop
		bne $t9, '\n' , loop
	
Check:# Kiem tra xem ma code vua nhap tu Digital Lab Sim co dung khong
		la $s2, LENGTH			#neu khong phai 3 ky tu thi printError
		lw $s2, 0($s2)
		bne $s2, 3, printError
		
						#neu dúng 3 ky tu thi check xem input la ma dieu khien nao
		la $s3, MOVE_CODE
		jal soSanh2chuoi
		beq $t0, 1, go
		
		la $s3, STOP_CODE
		jal soSanh2chuoi
		beq $t0, 1, stop
			
		
		la $s3, LEFT_CODE
		jal soSanh2chuoi
		beq $t0, 1, goLeft
		
		la $s3, RIGHT_CODE
		jal soSanh2chuoi
		beq $t0, 1, goRight
		
		la $s3, TRACK_CODE
		jal soSanh2chuoi
		beq $t0, 1, track

		
		la $s3, UNTRACK_CODE
		jal soSanh2chuoi
		beq $t0, 1, untrack
		
		
		la $s3, BACK_CODE
		jal soSanh2chuoi
		beq $t0, 1, goBack
		
		beq $t0, 0, printError
			
print:# in ra code vua nhap dung len man hinh
	li $v0, 4
	la $a0, INPUT
	syscall
	nop

saveCode:# luu tru lai code dung truoc khi xoa de reControl neu nguoi dung an Saoce
	addi $sp,$sp,4
	sw $t1, 0($sp)
	addi $sp,$sp,4
	sw $t2, 0($sp)
	addi $sp,$sp,4
	sw $t3, 0($sp)
	addi $sp,$sp,4
	sw $t4, 0($sp)
	addi $sp,$sp,4
	sw $s1, 0($sp)
	addi $sp,$sp,4
	sw $s2, 0($sp)
	addi $sp,$sp,4
	sw $s3, 0($sp)
	addi $sp,$sp,4
	sw $s4, 0($sp)
	
	la $s1,INPUT
	la $s2, LENGTH
	la $s3, SAVE
	la $s4, SAVE_LENGTH
	
	lw $t4,0($s2)
	sw $t4, 0($s4)
	
	addi $t1, $zero, -1				#$t1 = -1 = i
	add $t0, $zero, $zero
	for_loop_to_save:
		addi $t1, $t1, 1			#i++
	
		add $t2, $s1, $t1			#$t2 = INPUT + i
		lb $t2, 0($t2)				#$t2 = INPUT[i]
		
		add $t3, $s3, $t1			#$t3 = s + i
		sb $t2, 0($t3)				#$t3 = s[i]
		

		bne $t1, 3, for_loop_to_save		#if $t1 <=2 continue loop
		nop
		bne $t1, 3, for_loop_to_save
			
			
	lw $s4, 0($sp)
	addi $sp,$sp,-4
	lw $s3, 0($sp)
	addi $sp,$sp,-4
	lw $s2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t4, 0($sp)
	addi $sp,$sp,-4
	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4		
		
notPrint:# khong in va chi xoa		
	jal removeControl		
	nop
	j loop
	nop
	j loop
	
printError:#print code bi nhap sai
	li $v0, 4
	la $a0, INPUT
	syscall
	nop
	
	li $v0, 55
	la $a0, WRONG_CODE
	syscall
	nop
	nop
	j notPrint
	nop
	j notPrint	
removeControl: #xoa code cu de nhap code moi
	#backup
	addi $sp,$sp,4
	sw $t1, 0($sp)
	addi $sp,$sp,4
	sw $t2, 0($sp)
	addi $sp,$sp,4
	sw $s1, 0($sp)
	addi $sp,$sp,4
	sw $t3, 0($sp)
	addi $sp,$sp,4
	sw $s2, 0($sp)
	
	#processing
	la $s2, LENGTH
	lw $t3, 0($s2)					#$t3 = LENGTH
	addi $t1, $zero, -1				#$t1 = -1 = i
	addi $t2, $zero, 0				#$t2 = '\0'
	la $s1, INPUT
	addi $s1, $s1, -1
	for_loop_to_remove:
		addi $t1, $t1, 1			#i++
	
		add $s1, $s1, 1				#$s1 = INPUT + i
		sb $t2, 0($s1)				#INPUT[i] = '\0'
				
		bne $t1, $t3, for_loop_to_remove	#if $t1 <=3 continue loop
		nop
		bne $t1, $t3, for_loop_to_remove
		
	add $t3, $zero, $zero			
	sw $t3, 0($s2)					#LENGTH = 0
		
	#restore
	lw $s2, 0($sp)
	addi $sp,$sp,-4
	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	
	jr $ra
	nop
	jr $ra
reControl:#khi nguoi dung nhap Space se in ra cau lenh truoc do
	addi $sp,$sp,4
	sw $t1, 0($sp)
	addi $sp,$sp,4
	sw $t2, 0($sp)
	addi $sp,$sp,4
	sw $t3, 0($sp)
	addi $sp,$sp,4
	sw $t4, 0($sp)
	addi $sp,$sp,4
	sw $s1, 0($sp)
	addi $sp,$sp,4
	sw $s2, 0($sp)
	addi $sp,$sp,4
	sw $s3, 0($sp)
	addi $sp,$sp,4
	sw $s4, 0($sp)
	
	la $s1,INPUT
	la $s2, LENGTH
	la $s3, SAVE
	la $s4, SAVE_LENGTH
	
	lw $t4,0($s4)
	sw $t4, 0($s2)
	
	addi $t1, $zero, -1				#$t1 = -1 = i
	add $t0, $zero, $zero
	for_to_save:
		addi $t1, $t1, 1			#i++
	
		add $t2, $s3, $t1			#$t2 = INPUT + i
		lb $t2, 0($t2)				#$t2 = INPUT[i]
		
		add $t3, $s1, $t1			#$t3 = s + i
		sb $t2, 0($t3)				#$t3 = s[i]
		

		bne $t1, 3, for_to_save	#if $t1 <=2 continue loop
		nop
		bne $t1, 3, for_to_save
			
			
	lw $s4, 0($sp)
	addi $sp,$sp,-4
	lw $s3, 0($sp)
	addi $sp,$sp,-4
	lw $s2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t4, 0($sp)
	addi $sp,$sp,-4
	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4	
	nop	
	j Check
	nop
	j Check
	
soSanh2chuoi:#so sanh 2 chuoi xem co bang nhau khong
	
	addi $sp,$sp,4
	sw $t1, 0($sp)
	addi $sp,$sp,4
	sw $s1, 0($sp)
	addi $sp,$sp,4
	sw $t2, 0($sp)
	addi $sp,$sp,4
	sw $t3, 0($sp)	
	
	#chuong trinh con
	addi $t1, $zero, -1				#$t1 = -1 = i
	add $t0, $zero, $zero
	la $s1, INPUT			
	for_loop_to_check_equal:
		addi $t1, $t1, 1			#i++
	
		add $t2, $s1, $t1		
		lb $t2, 0($t2)			
		
		add $t3, $s3, $t1			#$t3 = s + i
		lb $t3, 0($t3)				#$t3 = s[i]
		
		bne $t2, $t3, haiChuoiKhongBangNhau		#if $t2 != $t3 -> khong bang nhau

		
		bne $t1, 2, for_loop_to_check_equal	#if $t1 <=2 continue loop
		nop
		bne $t1, 2, for_loop_to_check_equal
haiChuoiBangNhau:
	
	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	
	add $t0, $zero, 1				#update $t0
	jr $ra
	nop
	jr $ra
haiChuoiKhongBangNhau:
	
	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4

	add $t0, $zero, $zero				#update $t0
	jr $ra
	nop
	jr $ra
	
#-------------------------------------------------------------------Mar Bot ------------------------------------------------
	
inputPath:# nhap vao mang path toa do x,y, huong xoay
	#backup
	addi $sp,$sp,4
	sw $t1, 0($sp)
	addi $sp,$sp,4
	sw $t2, 0($sp)
	addi $sp,$sp,4
	sw $t3, 0($sp)
	addi $sp,$sp,4
	sw $t4, 0($sp)
	addi $sp,$sp,4
	sw $s1, 0($sp)
	addi $sp,$sp,4
	sw $s2, 0($sp)
	addi $sp,$sp,4
	sw $s3, 0($sp)
	addi $sp,$sp,4
	sw $s4, 0($sp)
	
	#processing
	li $t1, WHEREX
	lw $s1, 0($t1)		#s1 = x
	li $t2, WHEREY	
	lw $s2, 0($t2)		#s2 = y
	
	la $s4, NOW_HEAD
	lw $s4, 0($s4)		#s4 = NOW_HEAD

	la $t3, LENGTH_PATH
	lw $s3, 0($t3)		#$s3 = LENGTH_PATH (dv: byte)
	
	la $t4, PATH
	add $t4, $t4, $s3	#position to store
	
	sw $s1, 0($t4)		#store x
	sw $s2, 4($t4)		#store y
	sw $s4, 8($t4)		#store heading
	
	addi $s3, $s3, 12	#update LENGTH_PATH
				#12 = 3 (word) x 4 (bytes)
	sw $s3, 0($t3)
	
	#restore
	lw $s4, 0($sp)
	addi $sp,$sp,-4
	lw $s3, 0($sp)
	addi $sp,$sp,-4
	lw $s2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t4, 0($sp)
	addi $sp,$sp,-4
	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	
	jr $ra
	nop
	jr $ra			
goBack:
	#backup
	addi $sp,$sp,4
	sw $s5, 0($sp)
	addi $sp,$sp,4
	sw $s6, 0($sp)
	addi $sp,$sp,4
	sw $s7, 0($sp)
	addi $sp,$sp,4
	sw $t6, 0($sp)
	addi $sp,$sp,4
	sw $t5, 0($sp)
	
	jal UNTRACK
	jal GO
	la $s7, PATH
	la $s5, LENGTH_PATH
	lw $s5, 0($s5)
	add $s7, $s7, $s5
	
begin:
	
	addi $s5, $s5, -12 	#lui lai 1 structure
	
	addi $s7, $s7, -12	#vi tri cua thong tin ve canh cuoi cung
	lw $s6, 8($s7)		#huong cua canh cuoi cung
	addi $s6, $s6, 180	#nguoc lai huong cua canh cuoi cung
	
	
	la $t6, NOW_HEAD	#marsbot quay nguoc lai
	sw $s6, 0($t6)
	jal ROTATE

go_to_first_point_of_edge:	
	lw $t5, 0($s7)		#toa do x cua diem dau tien cua canh
	li $t6, WHEREX		#toa do x hien tai
	lw $t6, 0($t6)

	bne $t6, $t5, go_to_first_point_of_edge
	nop
	bne $t6, $t5, go_to_first_point_of_edge
	
	lw $t5, 4($s7)		#toa do y cua diem dau tien cua canh
	li $t6, WHEREY		#toa do y hien tai
	lw $t6, 0($t6)
	
	bne $t6, $t5, go_to_first_point_of_edge
	nop
	bne $t6, $t5, go_to_first_point_of_edge
	
	beq $s5, 0, finish
	nop
	beq $s5, 0, finish
	
	j begin
	nop
	j begin
	
finish:
	jal STOP
	
	la $t6,NOW_HEAD
	add $s6, $zero, $zero
	sw $s6, 0($t6)		#update heading
	la $t6, LENGTH_PATH
	addi $s5, $zero, 12
	sw $s5, 0($t6)		#update LENGTH_PATH = 12
	
	#restore
	lw $t5, 0($sp)
	addi $sp,$sp,-4
	lw $t6, 0($sp)
	addi $sp,$sp,-4
	lw $s7, 0($sp)
	addi $sp,$sp,-4
	lw $s6, 0($sp)
	addi $sp,$sp,-4
	lw $s5, 0($sp)
	addi $sp,$sp,-4
	
	j print	
track: 	jal UNTRACK 
	jal TRACK
	j print
		
untrack: jal UNTRACK
	j print

go: 	
	jal GO
	j print

stop: 	jal STOP
	j print

goRight:
	#backup
	addi $sp,$sp,4
	sw $s5, 0($sp)
	addi $sp,$sp,4
	sw $s6, 0($sp)
	addi $sp,$sp,4
	sw $at,0($sp)
	addi $sp,$sp,4
	sw $t0,0($sp)
	#chuong trinh con
	li $at, LEAVETRACK 
 	lb $t0, 0($at)
 	beq $t0, $zero, countinue_right
 	jal UNTRACK 
	jal TRACK
 	countinue_right:
	la $s5, NOW_HEAD
	lw $s6, 0($s5)	#$s6 is heading at now
	addi $s6, $s6, 90 #increase heading by 90*
	sw $s6, 0($s5) # update nowHeading
	#
	lw $t0,0($sp)
	addi $sp,$sp,4
	lw $at, 0($sp)
	addi $sp,$sp,-4
	lw $s6, 0($sp)
	addi $sp,$sp,-4
	lw $s5, 0($sp)
	addi $sp,$sp,-4
	
	
	jal inputPath
	jal ROTATE
	j print	
goLeft:	
	addi $sp,$sp,4
	sw $s5, 0($sp)
	addi $sp,$sp,4
	sw $s6, 0($sp)
	addi $sp,$sp,4
	sw $at,0($sp)
	addi $sp,$sp,4
	sw $t0,0($sp)
	#chuong trinh con
	li $at, LEAVETRACK 
 	lb $t0, 0($at)
 	beq $t0, $zero, countinue_left
 	jal UNTRACK 
	jal TRACK
 	countinue_left:
	la $s5, NOW_HEAD
	lw $s6, 0($s5)	#$s6 is heading at now
	addi $s6, $s6, -90 #increase heading by 90*
	sw $s6, 0($s5) # update NOW_HEAD
	#
	lw $t0,0($sp)
	addi $sp,$sp,4
	lw $at, 0($sp)
	addi $sp,$sp,-4
	lw $s6, 0($sp)
	addi $sp,$sp,-4
	lw $s5, 0($sp)
	addi $sp,$sp,-4
	
	jal inputPath
	jal ROTATE
	j print
	
GO: 	#backup
	addi $sp,$sp,4
	sw $at,0($sp)
	addi $sp,$sp,4
	sw $k0,0($sp)
	#processing
	li $at, MOVING # change MOVING port
 	addi $k0, $zero,1 # to logic 1,
	sb $k0, 0($at) # to start running	
	#restore
	lw $k0, 0($sp)
	addi $sp,$sp,-4
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
	jr $ra
	nop
	jr $ra

STOP: 	#backup
	addi $sp,$sp,4
	sw $at,0($sp)
	#processing
	li $at, MOVING # change MOVING port to 0
	sb $zero, 0($at) # to stop
	#restore
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
	jr $ra
	nop
	jr $ra

TRACK: 	#backup
	addi $sp,$sp,4
	sw $at,0($sp)
	addi $sp,$sp,4
	sw $k0,0($sp)
	#processing
	li $at, LEAVETRACK # change LEAVETRACK port
	addi $k0, $zero,1 # to logic 1,
 	sb $k0, 0($at) # to start tracking
 	#restore
	lw $k0, 0($sp)
	addi $sp,$sp,-4
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
 	jr $ra
	nop
	jr $ra

UNTRACK:
	addi $sp,$sp,4
	sw $at,0($sp)
	#chuong trinh con
	li $at, LEAVETRACK 
 	sb $zero, 0($at) 
 	#
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
 	jr $ra
	nop
	jr $ra
ROTATE: 
	
	addi $sp,$sp,4
	sw $t1,0($sp)
	addi $sp,$sp,4
	sw $t2,0($sp)
	addi $sp,$sp,4
	sw $t3,0($sp)
	#chuong trinh con
	li $t1, HEADING
	la $t2, NOW_HEAD
	lw $t3, 0($t2)	
 	sw $t3, 0($t1)
 	#
 	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	
 	jr $ra
	nop
	jr $ra	
#-------------------------------------------------------------Digital Lab Sim----------------------------------------------
.ktext 0x80000180
backup: 
	addi $sp,$sp,4
	sw $ra,0($sp)
	addi $sp,$sp,4
	sw $t1,0($sp)
	addi $sp,$sp,4
	sw $t2,0($sp)
	addi $sp,$sp,4
	sw $t3,0($sp)
	addi $sp,$sp,4
	sw $a0,0($sp)
	addi $sp,$sp,4
	sw $at,0($sp)
	addi $sp,$sp,4
	sw $s0,0($sp)
	addi $sp,$sp,4
	sw $s1,0($sp)
	addi $sp,$sp,4
	sw $s2,0($sp)
	addi $sp,$sp,4
	sw $t4,0($sp)
	addi $sp,$sp,4
	sw $s3,0($sp)
#chuong trinh
get_cod:
	li $t1, IN_ADRESS_HEXA_KEYBOARD
	li $t2, OUT_ADRESS_HEXA_KEYBOARD
row1:
	li $t3, 0x81
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_code_in_char
row2:
	li $t3, 0x82
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_code_in_char
row3:
	li $t3, 0x84
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_code_in_char
row4:
	li $t3, 0x88
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_code_in_char
get_code_in_char:
	beq $a0, input_0, so0
	beq $a0, input_1, so1
	beq $a0, input_2, so2
	beq $a0, input_3, so3
	beq $a0, input_4, so4
	beq $a0, input_5, so5
	beq $a0, input_6, so6
	beq $a0, input_7, so7
	beq $a0, input_8, so8
	beq $a0, input_9, so9
	beq $a0, input_a, a
	beq $a0, input_b, b
	beq $a0, input_c, c
	beq $a0, input_d, d
	beq $a0, input_e, e
	beq $a0, input_f, f
	

so0:	li $s0, '0'
	j inputCode
so1:	li $s0, '1'
	j inputCode
so2:	li $s0, '2'
	j inputCode
so3:	li $s0, '3'
	j inputCode
so4:	li $s0, '4'
	j inputCode
so5:	li $s0, '5'
	j inputCode
so6:	li $s0, '6'
	j inputCode
so7:	li $s0, '7'
	j inputCode
so8:	li $s0, '8'
	j inputCode
so9:	li $s0, '9'
	j inputCode
a:	li $s0, 'a'
	j inputCode
b:	li $s0, 'b'
	j inputCode
c:	li $s0, 'c'
	j inputCode
d:	li $s0, 'd'
	j inputCode
e:	li $s0,	'e'
	j inputCode
f:	li $s0, 'f'
	j inputCode
inputCode:#luu code nhap tu digital lab sim
	la $s1, INPUT
	la $s2, LENGTH
	lw $s3, 0($s2)				
	addi $t4, $t4, -1 			#$t4 = i 
	for_loop_to_store_code:
		addi $t4, $t4, 1
		bne $t4, $s3, for_loop_to_store_code
		add $s1, $s1, $t4		
		sb  $s0, 0($s1)			
		
		addi $s0, $zero, '\n'	
		addi $s1, $s1, 1		
		sb  $s0, 0($s1)			
		
		
		addi $s3, $s3, 1
		sw $s3, 0($s2)		
		


restore:# tra lai gia tri thanh ghi
	lw $s3, 0($sp)
	addi $sp,$sp,-4
	lw $t4, 0($sp)
	addi $sp,$sp,-4
	lw $s2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $s0, 0($sp)
	addi $sp,$sp,-4
	lw $at, 0($sp)
	addi $sp,$sp,-4
	lw $a0, 0($sp)
	addi $sp,$sp,-4
	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	lw $ra, 0($sp)
	addi $sp,$sp,-4
return: eret 	
