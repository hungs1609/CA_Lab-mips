.eqv SCREEN 	0x10010000	#Man hinh bitmap	
.eqv GREEN 	0x0000FF00
.eqv BACKGROUND 	0x00000000
.eqv KEY_A 	97
.eqv KEY_S	115
.eqv KEY_D	100
.eqv KEY_W	119
.eqv KEY_Z	122
.eqv KEY_X	120
.eqv KEY_ENTER	0x0000000a
.eqv DELTA_X	10
.eqv DELTA_Y	10
.eqv VERYFAST	10	# 10ms
.eqv FAST	70	# 70ms
.eqv NORMAL	130	# 130ms
.eqv SLOW	190	# 190ms
.eqv VERYSLOW	250	# 250ms
.eqv KEY_CODE	0xFFFF0004	# Ki tu go vao
.eqv KEY_READY	0xFFFF0000	# Kiem ki tu da san sang de doc chua

.macro delay_time(%time)	# delay 1 khoang thoi gian tinh bang mili giay
 	li $a0, %time
 	li $v0, 32
 	syscall
.end_macro
	 
.macro set_color_and_draw_circle(%color)
	li $s5, %color	# Dat mau 
 	jal draw_circle	# de xoa duong tron cu.
.end_macro  

.macro add_point(%r1, %r2, %r3)
	add $sp, $sp, -12
	sw %r1, 0($sp)
	sw %r2, 4($sp)
	sw %r3, 8($sp)
.end_macro

.macro add_position(%r1, %r2, %r3, %r4)
	add $sp, $sp, -16
	sw %r1, 0($sp)
	sw %r2, 4($sp)
	sw %r3, 8($sp)
	sw %r4, 12($sp)
.end_macro

.macro get_point(%r1, %r2, %r3)
	lw %r1, 0($sp)
 	lw %r2, 4($sp)
 	lw %r3, 8($sp)
 	add $sp, $sp, 12
.end_macro

.macro get_position(%r1, %r2, %r3, %r4)
	lw %r1, 0($sp)
 	lw %r2, 4($sp)
 	lw %r3, 8($sp)
 	lw %r4, 12($sp)
 	add $sp, $sp, 16
.end_macro

.kdata
	CIRCLE_ARRAY: 	.space 512
.text
li $s0, 256	# Xo = 256		Toa do X cua tam duong tron
li $s1, 256	# Yo = 256		Toa do Y cua tam duong tron
li $s2, 24	# R = 24 		Ban kinh cua tam duong tron
li $s3, 512	# SCREEN_WIDTH = 512	Be ngang man hinh
li $s4, 512	# SCREEN_HEIGHT = 512	Chieu cao man hinh
li $s5, GREEN	# Dat mau hinh tron
li $t6, NORMAL	# Dat toc do ban dau la NORMAL 
mul $s6, $s2, $s2	# R^2
li $s7, 0		# dx = 0
li $t8, DELTA_Y		# dy = 10
li $t7, 0 	# kiem tra de khoi tao hinh tron ban dau tai giua man hinh
  
jal start_draw_circle
nop
 
programLoop:
read_from_keyboard:
	lw $k1, KEY_READY 	# Vong lap cho ban phim san sang
	beqz $k1, check_position
 	nop 
 	lw $k0, KEY_CODE		# Doc ky tu ban phim
 	beq $k0, KEY_A, case_a	# Kiem tra nut A
 	beq $k0, KEY_S, case_s	# Kiem tra nut S
 	beq $k0, KEY_D, case_d	# Kiem tra nut D
 	beq $k0, KEY_W, case_w	# Kiem tra nut W
 	beq $k0, KEY_Z, case_z	# Kiem tra nut Z
 	beq $k0, KEY_X, case_x	# Kiem tra nut X
 	beq $k0, KEY_ENTER, case_enter	# Kiem tra nut ENTER
 	j check_position
case_a:
  	addi $t7, $zero, 1
 	jal move_to_left
 	j check_position
case_s:
   	addi $t7, $zero, 1
 	jal move_to_down
 	j check_position
case_d:
   	addi $t7, $zero, 1
 	jal move_to_right
 	j check_position
case_w:
   	addi $t7, $zero, 1
 	jal move_to_up
 	j check_position
case_z:
   	addi $t7, $zero, 1
	beq $t6, VERYFAST, notMinus	# kiem tra neu dat toc do VERYFAST thi se khong tang toc hon duoc nua
	subi $t6, $t6, 60
	notMinus:
 	set_color_and_draw_circle(BACKGROUND)
 	j draw
case_x:
   	addi $t7, $zero, 1
	beq $t6, VERYSLOW, notPlus	# kiem tra neu dat toc do VERYSLOW thi se khong giam toc hon duoc nua
	addi $t6, $t6, 60
	notPlus:
 	set_color_and_draw_circle(BACKGROUND)
 	j draw
case_enter: 
 	j endProgram
 	
check_position:		
checkRightExtreme:
 	add $v0, $s0, $s2	
 	add $v0, $v0,$s7		
 	ble $v0, $s3, checkLeftExtreme	# Neu Xo + R + DELTA_X > SCREEN_WIDTH thi move_to_left
 	jal move_to_left	
 	nop
checkLeftExtreme:
 	sub $v0, $s0, $s2	
 	add $v0, $v0, $s7	
 	ble $zero, $v0, checkTopExtreme	# Neu Xo - R + DELTA_X < 0 thi move_to_right
 	jal move_to_right	
 	nop
checkTopExtreme:
 	sub $v0, $s1, $s2	
 	add $v0, $v0, $t8	
 	ble $zero, $v0, checkBottomExtreme	# Neu Yo - R + DELTA_Y < 0 thi move_to_down
 	jal move_to_down	
 	nop
checkBottomExtreme:
 	add $v0, $s1, $s2	
 	add $v0, $v0, $t8	
 	beq $t7, 1, activeCircle
	ble $v0, $s4, drawInit # ve duong tron ban dau tai giua man hinh
	activeCircle: 	
	ble $v0, $s4, draw	# neu Yo + R + DELTA_Y > SCREEN_HEIGHT thi move_to_up
 	jal move_to_up	
 	nop
 	
#-------------------------------------------------------------------------------------------------------------------
#	Xoa duong tron cu va ve duong tron moi
#-------------------------------------------------------------------------------------------------------------------

drawInit: 	
 	set_color_and_draw_circle(BACKGROUND) # Ve duong tron trung mau nen
 	addi $s0, $s0, 0			# vi tri ban dau x = 256
 	addi $s1, $s1, 0			# vi tri ban dau y = 256
 	set_color_and_draw_circle(GREEN) 	# Ve duong tron moi
 	beq $t6, VERYSLOW, veryslow
 	beq $t6, SLOW, slow
	beq $t6, NORMAL, normal
	beq $t6, FAST, fast
	beq $t6, VERYFAST, veryfast	
 		
draw: 	
 	set_color_and_draw_circle(BACKGROUND) # Ve duong tron trung mau nen
 	add $s0, $s0, $s7		# Cap nhat toa do moi
 	add $s1, $s1, $t8		# cua duong tron
 	set_color_and_draw_circle(GREEN) 	# Ve duong tron moi
	beq $t6, VERYSLOW, veryslow
 	beq $t6, SLOW, slow
	beq $t6, NORMAL, normal
	beq $t6, FAST, fast
	beq $t6, VERYFAST, veryfast
 	
endProgram:				# Ket thuc chuong trinh
	set_color_and_draw_circle(BACKGROUND)
 	li $v0, 10
 	syscall

veryslow: 
	delay_time(VERYSLOW)		# Dat toc do VERYSLOW
 	j programLoop
slow: 
	delay_time(SLOW)		# Dat toc do SLOW
 	j programLoop
normal: 
	delay_time(NORMAL)		# Dat toc do NORMAL
 	j programLoop
fast: 
	delay_time(FAST)		# Dat toc do FAST
 	j programLoop
veryfast: 
	delay_time(VERYFAST)		# Dat toc do VERYFAST
 	j programLoop

#-------------------------------------------------------------------------------------------------------------------
#	Stack Position luu lai vi tri( toa do) cac diem cua duong tron
#	Tao mang du lieu luu toa do cac diem cua duong tron
#	Luu lai cac gia tri tuong ung cua j khi i chay tu 0 -> R
#-------------------------------------------------------------------------------------------------------------------

start_draw_circle: 
	add_position($ra, $t0, $t3, $t5)
	li $t0, 0		# i = 0
	la $t5, CIRCLE_ARRAY
loop:	
	slt $v0, $t0, $s2	# Neu i > R -> end_start_draw_circle
	beqz $v0, end_draw_circle
	mul $t3, $t0, $t0	# i^2
	sub $t3, $s6, $t3	# $t3 = R^2 - i^2
	move $v0, $t3
	jal sqrt
	sw $a0, 0($t5)		# Luu j = sqrt(R^2 - i^2) vao mang du lieu
	addi $t0, $t0, 1		# i = i + 1
	add $t5, $t5, 4
	j loop
end_draw_circle:
	get_position($ra, $t0, $t3, $t5)
	jr $ra
	nop
	
#-------------------------------------------------------------------------------------------------------------------
#	Ve diem tren duong tron
# 	Ve dong thoi 2 diem (X0 + i, Y0 +j ) va (Xo + j, Xo + i)
#	Tham so $a0 = i ; $a1 = j
#-------------------------------------------------------------------------------------------------------------------

draw_circle_point:
	add_point($t1, $t2, $t4)

 	add $t1, $s0, $a0 	# Xi = Xo + i
	add $t4, $s1, $a1	# Yi = Yo + j
	mul $t2, $t4, $s3	# Yi * SCREEN_WIDTH
	add $t1, $t1, $t2	# Yi * SCREEN_WIDTH + Xi (Toa do 1 chieu cua diem anh)
	sll $t1, $t1, 2		# Dia chi tuong doi cua diem anh
	sw $s5, SCREEN($t1)	# Ve diem anh
	add $t1, $s0, $a1 	# Xi = Xo + j
	add $t4, $s1, $a0	# Yi = Yo + i
	mul $t2, $t4, $s3	# Yi * SCREEN_WIDTH
	add $t1, $t1, $t2	# Yi * SCREEN_WIDTH + Xi (Toa do 1 chieu cua diem anh)
	sll $t1, $t1, 2		# Dia chi tuong doi cua diem anh
	sw $s5, SCREEN($t1)	# Ve diem anh
	get_point($t1, $t2, $t4)
	jr $ra

#-------------------------------------------------------------------------------------------------------------------
#	Ve duong tron
#-------------------------------------------------------------------------------------------------------------------
	
draw_circle:
	add_position($ra, $t0, $t1, $t3)
 	li $t0, 0	# init i = 0
loop_drawCircle:
  	slt $v0, $t0, $s2
 	beqz $v0,  end_drawCircle
	
	sll $t1, $t0, 2
	lw $t3, CIRCLE_ARRAY($t1) # Load j to $t3	 
	
 	move $a0, $t0	# $a0 = i
	move $a1, $t3	# $a1 = j
	jal draw_circle_point	# ve 2 diem (Xo + i, Yo + j), (Xo + j, Yo + i)
	sub $a1, $zero, $t3
	jal draw_circle_point	# ve 2 diem (Xo + i, Yo - j), (Xo + j, Yo - i)
	sub $a0, $zero, $t0
	jal draw_circle_point	# ve 2 diem (Xo - i, Yo - j), (Xo - j, Yo - i)
	add $a1, $zero, $t3
	jal draw_circle_point	# ve 2 diem (Xo - i, Yo + j), (Xo - j, Yo + i)
	
	addi $t0, $t0, 1 # i = i + 1
	j loop_drawCircle
end_drawCircle:
	get_position($ra, $t0, $t1, $t3)	
 	jr $ra
	 				
# 	Ham tinh can bac hai				 				 				 				
# 	$v0 = S, $a0 = sqrt(S)
sqrt:
	mtc1 $v0, $f0
	cvt.s.w $f0, $f0
	sqrt.s $f0, $f0
	cvt.w.s $f0, $f0
	mfc1 $a0, $f0
	jr $ra
	
#-------------------------------------------------------------------------------------------------------------------
#	Di chuyen
#-------------------------------------------------------------------------------------------------------------------

move_to_left:
	li $s7, -DELTA_X
 	li $t8, 0
	jr $ra 	
move_to_right:
	li $s7, DELTA_X
 	li $t8, 0
	jr $ra 	
move_to_up:
	li $s7, 0
 	li $t8, -DELTA_Y
	jr $ra 	
move_to_down:
	li $s7, 0
 	li $t8, DELTA_Y
	jr $ra 
