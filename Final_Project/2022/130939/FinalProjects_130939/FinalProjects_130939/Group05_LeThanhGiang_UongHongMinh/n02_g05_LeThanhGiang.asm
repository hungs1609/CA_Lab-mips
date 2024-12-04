######################################################################
# 			     Ex 2 	                             #
######################################################################
#           		Le Thanh Giang			             #
######################################################################
#	          						     #
#       Bitmap Display Settings:                                     #
#	Unit Width: 1						     #
#	Unit Height: 1						     #
#	Display Width: 512					     #
#	Display Height: 512					     #
#	Base Address for Display: 0x10010000		             #
######################################################################

.eqv 	INPUT_KEY 0xFFFF0004  			# ASCII code to show, 1 byte 
.eqv 	CHECK_KEY 0xFFFF0000      		# =1 if has a new keycode ?                                  
						# Auto clear after lw
.eqv	COLOR 0x00FFFF66			# cobalt blue
.eqv	BLACK 0x00000000			# black
.eqv	ENV 0x1001
.eqv FAST	10	
.eqv NORMAL	100
.eqv SLOW	190
.eqv KEY_A 	97
.eqv KEY_S	115
.eqv KEY_D	100
.eqv KEY_W	119
.eqv KEY_Z	122
.eqv KEY_X	120


.text	
	li 	$k0, INPUT_KEY 			# Read_Input_Key key     
	li 	$k1, CHECK_KEY			# Check if any key has been entered  
	addi	$s7, $zero, 512			# store the width in s7
	add	$t7, $t7, $zero

#---------------------------------------------------------
#------------Circle detail-------------------------------
circle:
	addi	$a0, $zero, 256			# x0 = 256
	addi	$a1, $zero, 256			# y0 = 256	
	addi	$a2, $zero, 20 			# r0 = 20 ban kinh cua hinh tron
	addi 	$s0, $zero, COLOR
	jal 	DrawCircle
	
max_right_or_down:
	sub 	$s6, $s7, $a2

#---------------------------------------------------------
#------------Controller on key----------------------------
Control:		
	beq 	$t0, KEY_A, left		# on-click A
	beq 	$t0, KEY_D, right		# on-click D
	beq 	$t0, KEY_S, down		# on-click S
	beq 	$t0, KEY_W, up			# on-click W
	beq 	$t0, KEY_Z, fast		# on-click Z
	j 	Read_Input_Key


	left:
		addi 	$s0, $zero, BLACK
		jal 	DrawCircle

		addi 	$a0, $a0, -1
		add 	$a1, $a1, $zero
		addi 	$s0, $zero, COLOR
		jal  	DrawCircle
	
		blt 	$a0, $a2, reboundRight
		j 	Read_Input_Key
	
	right: 
		addi 	$s0, $zero, BLACK
		jal 	DrawCircle
	
		addi 	$a0, $a0, 1
		add 	$a1, $a1, $zero
		addi 	$s0, $zero, COLOR
		jal 	DrawCircle
	
		bgt 	$a0,$s6,reboundLeft
		j 	Read_Input_Key

	up: 
		addi 	$s0, $zero, BLACK
		jal 	DrawCircle

		addi 	$a1, $a1, -1
		add 	$a0, $a0, $zero
		addi 	$s0, $zero, COLOR
		jal 	DrawCircle
	
		blt 	$a1, $a2, reboundDown	
		j 	Read_Input_Key
	
	down: 
		addi 	$s0, $zero, BLACK
		jal 	DrawCircle
	
		addi 	$a1, $a1, 1
		add 	$a0, $a0, $zero
		addi 	$s0, $zero, COLOR
		jal 	DrawCircle
	
		bgt 	$a1, $s6, reboundUp	
		j 	Read_Input_Key
	
	fast: 
 		addi 	$a0, $a0, 5
 		li	$v0, 30
 		syscall
 		j Read_Input_Key

	reboundLeft:
		li 	$t3, 97
		sw 	$t3, 0($k0)
		j 	Read_Input_Key
	
	reboundRight:
		li	$t3, 100
		sw 	$t3, 0($k0)
		j 	Read_Input_Key
		
	reboundDown:
		li 	$t3, 115
		sw 	$t3,0($k0)
		j 	Read_Input_Key
	
	reboundUp:
		li 	$t3, 119
		sw	$t3,0($k0)
		j 	Read_Input_Key
	
Done:	
	

#---------------------------------------------------------
#------------Key Input------------------------------------
Read_Input_Key: 
	lw 	$t0, 0($k0) 			# $t0 = [$k0] = INPUT_KEY chua ky tu nhap vao
	j 	Control

#-----------------------------------------------------------
#------------Ve duong tron lu bat dau-----------------------
DrawCircle:	
	addi	$sp, $sp, -32			# Khoi tao bien sp bat dau ve vong tron dung thuat toan Breseham
	sw 	$ra, 28($sp)
	sw	$a0, 24($sp)
	sw	$a1, 20($sp)
	sw	$a2, 16($sp)
	sw	$s4, 12($sp)
	sw	$s3, 8($sp)
	sw	$s2, 4($sp)
	sw	$s0, 0($sp)


#-----------------------------------------------------------
#------------Thuat toan ve duong tron-----------------------
Bresenham_Alogorithm:				# thuat toan ve duong tron
	add 	$t0, $zero, $a0			# x0
	add	$t1, $zero, $a1			# y0
	add	$t2, $zero, $a2			# r
	add	$s2, $zero, $zero		# x = 0
	add 	$s3, $zero, $a2			# y = r
	mul	$s4, $a2, -2			# s4 = -2r
	addi	$s4, $s4, 3			# p = 3 - 2r

#---------------------------------------------------------
#------------Draw 8 point---------------------------------
DrawCircleCondition:	
	bgt 	$s2, $s3, exitDrawCircle		#if x > y, break the loop (while loop x <= y)
	
	# ve 8 diem voi cac toa do tuong ung
	
	# C1(x0+x,y0+y)	
	add	$a0, $t0, $s2
	add	$a1, $t1, $s3
	jal	PutPixel			# xac dinh toa do va ve tren bitmap
	
	
	# C2(x0-x,y0+y)
	sub	$a0, $t0, $s2
	add	$a1, $t1, $s3
	jal	PutPixel
	
	
	# C3(x0+x,y0-y)
	add	$a0, $t0, $s2
	sub	$a1, $t1, $s3
	jal	PutPixel
	
	
	# C4(x0-x,y0-y)
	sub	$a0, $t0, $s2
	sub	$a1, $t1, $s3
	jal	PutPixel
	

	# C5(x0+y,y0+x)
	add	$a0, $t0, $s3
	add	$a1, $t1, $s2
	jal	PutPixel
	
	
	# C6(x0-y,y0+x)
	sub	$a0, $t0, $s3
	add	$a1, $t1, $s2
	jal	PutPixel
	
	
	# C7(x0+y,y0-x)
	add	$a0, $t0, $s3
	sub	$a1, $t1, $s2
	jal	PutPixel
	
	
	# C8(x0-y,y0-x)
	sub	$a0, $t0, $s3
	sub	$a1, $t1, $s2
	jal	PutPixel
	
	addi 	$s2, $s2, 1
	
	# if p<0 Vong while check dieu kien
	bgez	$s4, Else
	sll 	$t5, $s2, 2			# 4x
	addi	$t5, $t5, 6			# 4x + 6	
	add 	$s4, $s4, $t5			# p = p + 4x +6
	j	Cont
	
Else:	# re nhanh
	sub	$t3, $s2, $s3
	sll	$t5, $t3, 2			# 4(x-y)
	addi	$t5, $t5, 10			# 4(x-y) + 1
	add	$s4, $t5, $s4			# p = p + 4(x-y) + 10
	addi 	$s3, $s3, -1
	
Cont:
	j	DrawCircleCondition
	
exitDrawCircle:
	lw	$s0, 0($sp)			# Xoa bo nho
	lw	$s2, 4($sp)
	lw	$s3, 8($sp)
	lw	$s4, 12($sp)
	lw	$a2, 16($sp)
	lw	$a1, 20($sp)
	lw	$a0, 24($sp)
	lw	$ra, 28($sp)
	addi	$sp, $sp, 32
	jr 	$ra

#---------------------------------------------------------
#------------Draw on Bitmap Display-----------------------	
PutPixel:
	addiu	$sp, $sp, -20			
	sw	$ra, 16($sp)
	sw	$s1, 12($sp)
	sw	$s0, 8($sp)			
	sw	$a0, 4($sp)
	sw	$a1, 0($sp)
	
	lui	$s1, ENV			# starting address of the screen	
	sll	$a0, $a0, 2 			# myltiply by the size of the pixels (4)	lay toa do tung va hoanh lay dia chi
	sll	$a1, $a1, 2			# myltiply by the size of the pixels (4)
	add	$s1, $s1, $a0			# x co-ord addded to pixel position
	mul  	$a1, $a1, $s7			# multiply by width
	add	$s1, $s1, $a1			# add y co-ord to pixel position
	sw	$s0, 0($s1)			# stores the value of colour into the pixels memory address 32x + 4y xuong 512 o thi dich den pixel do
	
	lw	$a1, 0($sp)			
	lw	$a0, 4($sp)
	lw	$s0, 8($sp)
	lw	$s1, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20	
	jr	$ra
