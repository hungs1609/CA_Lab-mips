.eqv KEY_CODE 0xFFFF0004  # ASCII code to show, 1 byte 
.eqv KEY_READY 0xFFFF0000        # =1 if has a new keycode ?                                  
				# Auto clear after lw 
.data
L :	.asciiz "a"
R : 	.asciiz "d"
U: 	.asciiz "w"
D: 	.asciiz "s"
.text	
	li $k0, KEY_CODE 	# chua k� tu nhap vao     
	li $k1, KEY_READY	# kiem tra da nhap phim nao chua  
	
	addi	$s7, $0, 512			#store the width in s7
	
	#circle:
	addi	$a0, $0, 256		#x = 256
	addi	$a1, $0, 256		#y = 256	
	addi	$a2, $0, 20		#r = 20
	addi 	$s0, $0, 0xFFFFFFFF
	jal 	DrawCircle	
	nop
moving:
	
	beq $t0,97,left #a
	beq $t0,100,right #d
	beq $t0,115,down #s
	beq $t0,119,up #w
	j Input
	left:
		addi $s0,$0,0x00000000 # delteCircle
		jal DrawCircle
		addi $a0,$a0,-1 #x= x-1
		add $a1,$a1, $0 #y=y
		addi $s0,$0,0xFFFFFFFF #drawNewCircle
		jal DrawCircle
		jal Pause # x=20
		bltu $a0,20,reboundRight #??i h??ng
		j Input
	right: 
		addi $s0,$0,0x00000000 # delteCircle
		jal DrawCircle
		addi $a0,$a0,1 #x= x+1
		add $a1,$a1, $0 #y=y
		addi $s0,$0,0xFFFFFFFF #drawNewCircle
		jal DrawCircle
		jal Pause # x=492
		bgtu $a0,492,reboundLeft #??i h??ng
		j Input
	up: 
		addi $s0,$0,0x00000000 # delteCircle
		jal DrawCircle
		addi $a1,$a1,-1 #y=y-1
		add $a0,$a0,$0 #x=x
		addi $s0,$0,0xFFFFFFFF #drawNewCircle
		jal DrawCircle
		jal Pause #when y=20
		bltu $a1,20,reboundDown	#??i h??ng
		j Input
	down: 
		addi $s0,$0,0x00000000 # delteCircle
		jal DrawCircle
		addi $a1,$a1,1 #y=y+1
		add $a0,$a0,$0 #x=x
		addi $s0,$0,0xFFFFFFFF #drawNewCircle
		jal DrawCircle
		jal Pause #when y=492
		bgtu $a1,492,reboundUp	#??i h??ng
		j Input
	reboundLeft:
		li $t3 97
		sw $t3,0($k0)
		j Input
	reboundRight:
		li $t3 100
		sw $t3,0($k0)
		j Input
	reboundDown:
		li $t3 115
		sw $t3,0($k0)
		j Input
	reboundUp:
		li $t3 119
		sw $t3,0($k0)
		j Input
endMoving:...
Input:
	ReadKey: lw $t0, 0($k0) # $t0 = [$k0] = KEY_CODE
	j moving
	
	
Pause:
	addiu $sp,$sp,-4
	sw $a0, ($sp)
	la $a0,0		# speed =20ms
	li $v0, 32	 #syscall value for sleep
	syscall
	lw $a0,($sp)
	addiu $sp,$sp,4
	jr $ra
DrawCircle:
	#a0 = cx
	#a1 = cy
	#a2 = radius
	#s0 = colour
	#cx,cy la toa do tam duong tron
	addiu	$sp, $sp, -32
	sw 	$ra, 28($sp)
	sw	$a0, 24($sp)
	sw	$a1, 20($sp)
	sw	$a2, 16($sp)
	sw	$s4, 12($sp)
	sw	$s3, 8($sp)
	sw	$s2, 4($sp)
	sw	$s0, ($sp)
	
	#code goes here
	sub	$s2, $0, $a2			#s2=-R
	add	$s3, $0, $a2			#s3=x=R
	add	$s4, $0, $0			#y = 0
	# chon diem can ve (x,y) = (R,0) 
	DrawCircleLoop:
	bgt 	$s4, $s3, exitDrawCircle	#if y is greater than x, break the loop (while loop x >= y)
	nop
	
	#plots 4 points along the right of the circle, then swaps the x and y and plots the opposite 4 points
	jal	plot8points
	nop
	
	add	$s2, $s2, $s4			#s2 = -R +y
	addi	$s4, $s4, 1			
	add	$s2, $s2, $s4			#s2 = -R + 2y +1
	
	blt	$s2, 0, DrawCircleLoop		#if s2 >= 0, start loop again
	nop
	
	sub	$s3, $s3, 1			
	sub	$s2, $s2, $s3			
	sub	$s2, $s2, $s3			#s2 = - R +2y-2x +3
	
	j	DrawCircleLoop
	nop	
	
	exitDrawCircle:
	
	lw	$s0, ($sp)
	lw	$s2, 4($sp)
	lw	$s3, 8($sp)
	lw	$s4, 12($sp)
	lw	$a2, 16($sp)
	lw	$a1, 20($sp)
	lw	$a0, 24($sp)
	lw	$ra, 28($sp)
	
	addiu	$sp, $sp, 32
	
	jr 	$ra
	nop
	
plot8points:
	addiu	$sp, $sp -4
	sw	$ra, ($sp)
	
	jal	plot4points
	nop
	
	beq 	$s4, $s3, skipSecondplot #if x = y
	nop
	
	#swap y and x, and do it again
	add	$t2, $0, $s4			#puts y into t2
	add	$s4, $0, $s3			#puts x in to y
	add	$s3, $0, $t2			#puts y in to x
	
	jal	plot4points
	nop
	
	#swap them back
	add	$t2, $0, $s4			#puts y into t2
	add	$s4, $0, $s3			#puts x in to y
	add	$s3, $0, $t2			#puts y in to x
		
	skipSecondplot:
		
	lw	$ra, ($sp)
	addiu	$sp, $sp, 4
	
	jr	$ra
	nop
	
plot4points:
	#4 diem ben phai duong tron
	addiu	$sp, $sp -4
	sw	$ra, ($sp)
	
	#$a0 = a0 + s3, $a2 = a1 + s4
	add	$t0, $0, $a0			#t0 =cx
	add	$t1, $0, $a1			#t1 =cy
	
	add	$a0, $t0, $s3			#a0 =cx +x
	add	$a2, $t1, $s4			#a2 = cy + y
	
	jal	SetPixel			#draw the first pixel
	nop
	
	sub	$a0, $t0, $s3			#a0 = cx - x
	
	beq	$s3, $0, skipXnotequal0 	#if s3 (x) equals 0, skip
	nop
	
	jal 	SetPixel			#if x!=0 (cx - x, cy + y)
	nop	

	skipXnotequal0:	
	sub	$a2, $t1, $s4			#cy - y (a0 already equals cx - x
	jal 	SetPixel			#no if	 (cx - x, cy - y)
	nop
	
	add	$a0, $t0, $s3
	
	beq	$s4, $0, skipYnotequal0 	#if s4 (y) equals 0, skip
	nop
	
	jal	SetPixel			#if y!=0 (cx + x, cy - y)
	nop
	
	skipYnotequal0:
	# tra lai gia tri
	add	$a0, $0, $t0			#a0 = cx
	add	$a2, $0, $t1			#a2 = cy
	
	lw	$ra, ($sp)
	addiu	$sp, $sp, 4
	
	jr	$ra
	nop
SetPixel:
	#a0 x
	#a1 y
	#s0 colour
	addiu	$sp, $sp, -20			# Save return address on stack
	sw	$ra, 16($sp)
	sw	$s1, 12($sp)
	sw	$s0, 8($sp)			# Save original values of a0, s0, a2
	sw	$a0, 4($sp)
	sw	$a2, ($sp)

	lui	$s1, 0x1004			#dia chi ban dau	
	sll	$a0, $a0, 2 			#a0 = 4*a0= 4*(cx + x)
	add	$s1, $s1, $a0			#s1 = 0x10040000 + a0 them toa do x cho pixel 
	mul  	$a2, $a2, $s7			#a2 = (cy+y)*512
	mul	$a2, $a2, 4			#a2 = (cy+y)*512*4
	add	$s1, $s1, $a2			#s1 = 0x10040000 + a0 + a2 them toa do y cho pixel 

	sw	$s0, ($s1)			#to mau pixel
	
	lw	$a2, ($sp)			#retrieve original values and return address
	lw	$a0, 4($sp)
	lw	$s0, 8($sp)
	lw	$s1, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20	
	
	jr	$ra
	nop
	
