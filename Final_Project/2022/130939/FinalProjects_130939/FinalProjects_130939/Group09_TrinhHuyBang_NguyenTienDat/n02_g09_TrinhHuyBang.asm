.eqv SCREEN 	0x10010000	
.eqv YELLOW 	0x00FFFF66
.eqv BACKGROUND 	0x00000000
.eqv KEY_A 	0x00000061
.eqv KEY_S	0x00000073
.eqv KEY_D	0x00000064
.eqv KEY_W	0x00000077
.eqv KEY_Z	0x0000007A # tang toc (giam thoi gian delay hoac tang do lon khoang nhay) 
.eqv KEY_X	0x00000078 # Giam toc ( tang thoi gian delay hoac giam do lon khoang nhay)
.eqv KEY_ENTER	0x0000000A
.eqv DELTA	15
.eqv KEY_CODE	0xFFFF0004
.eqv KEY_READY	0xFFFF0000

#--------------------------------------------------------------------------------------------
# Delay chuong trinh
# Khoang thoi gian delay giua cac lan di chuyen cua hinh tron (ms)

.macro delay(%r)	# %r thanh ghi chua gia tri thoi gian delay
 	addi $a0,%r,0
 	li $v0, 32 
 	syscall
.end_macro
	
.macro branchIfLessOrEqual(%r1, %r2, %branch) # Tap lenh dung de so sanh neu r1 <= r2 ghi nhay den nhan branch
	sle $v0, %r1, %r2	# $v0 = 1 neu %r1 <= %r2 nguoc lai $v0 = 0
 	bnez $v0, %branch	# neu $v0 != 0 nhay den nhan %branch
.end_macro
	 
.macro setColorAndDrawCirle(%color)
	li $s5, %color		#	Dat mau den cho duong tron de
 	jal drawCircle		#	xoa duong tron cu.
.end_macro  

.kdata	
	CIRCLE_DATA: 	.space 512  
.text
 	li $s0, 256	# Xo = 256		Toa do X cua tam duong tron
 	li $s1, 256	# Yo = 256		Toa do Y cua tam duong tron
 	li $s2, 30	# R = 24 		Ban kinh cua duong tron
	li $s3, 512	# SCREEN_WIDTH = 512	Do rong man hinh
 	li $s4, 512	# SCREEN_HEIGHT = 512	Chieu cao man hinh
 	li $s5, YELLOW #	Mau sac duong tron la mau vang
 	li $t6, DELTA	# Khoang nhay giua cac hinh tron
 	li $s7, 0	#	dx = 0
 	li $t8, 0	#	dy = 0  
 	li $t9, 100    # Thanh ghi luu tru thoi gian delay ( khoi tao la 100 (ms) )
 
 #--------------------------------------------------------------------------------------------
 # Ham khoi dong duong tron
 # Tao mang du lieu luu toa do cac diem cua duong tron
 
 circleInit: 
	li $t0, 0		# i = 0
	la $t5, CIRCLE_DATA	# tro vao dia chi cua noi luu du lieu duong tron
 loop:	slt $v0, $t0, $s2	# for loop i -> R
	beqz $v0, end_circleInit
	mul $s6, $s2, $s2	# R^2
	mul $t3, $t0, $t0	# i^2
	sub $t3, $s6, $t3	# $t3 = R^2 - i^2   
	move $v0, $t3
	jal sqrt
				
	sw $a0, 0($t5)		# Luu j = sqrt(R^2 - i^2) vao mang du lieu
	addi $t0, $t0, 1		# i++
	add $t5, $t5, 4		# Di den vi tri tiep theo luu du lieu cua CIRCLE_DATA
	j loop
 end_circleInit:

 #--------------------------------------------------------------------------------------------
 # Ham nhap du lieu tu ban phim

 start:
 readKeyboard:
 	lw $k1, KEY_READY # kiem tra da nhap ki tu nao chua
 	beqz $k1, positionCheck	 # Neu $k1 != 0 tuc da nhan duoc ki tu nhap tu ban phim thi bat dau kiem tra da va cham canh nao chua
 	lw $k0, KEY_CODE	# $k0 luu gia tri ki tu nhap vao, kiem tra voi tung truong hop
 	beq $k0, KEY_A, case_a  # Dieu khien qua trai
 	beq $k0, KEY_S, case_s	# Dieu khien xuong duoi
 	beq $k0, KEY_D, case_d # DIeu khien qua phai
 	beq $k0, KEY_W, case_w # Dieu khien len tren
 	beq $k0, KEY_X, case_x # Giam toc do
 	beq $k0, KEY_Z, case_z # Tang toc do
 	beq $k0, KEY_ENTER, case_enter # Dung chuong trinh
 	j positionCheck
 	nop
 case_a:
 	jal moveToLeft
 	j positionCheck
 case_s:
 	jal moveToDown
 	j positionCheck
 case_d:
 	jal moveToRight
 	j positionCheck
 case_w:
 	jal moveToUp
 	j positionCheck
 #--------------------------------------------
 # Dieu chinh toc do bang khoang nhay DELTA
 
 #case_z:
 #	addi $t6,$t6,5
 #	j positionCheck
 #case_x:
 #	subi $t6,$t6,5
 #	j positionCheck
 # -------------------------------------------

 #--------------------------------------------
 # Dieu chinh toc do bang thoi gian delay
 case_z:
	subi $t9,$t9,50
 	j positionCheck
 case_x:
 	addi $t9,$t9,50
 	j positionCheck
  #---------------------------------------------
  
 case_enter: 
 	j endProgram
 	
 positionCheck:		
 checkRightEdge:
 	add $v0, $s0, $s2	# Xo + R
 	add $v0, $v0,$s7		# If Xo + R + DELTA > SCREEN_WIDTH Then moveToLeft
 	branchIfLessOrEqual($v0, $s3, checkLeftEdge)	# else check left edge
 	jal moveToLeft	
 	nop
 checkLeftEdge:
 	sub $v0, $s0, $s2	
 	add $v0, $v0, $s7	# If Xo - R + DELTA < 0 then moveToRight
 	branchIfLessOrEqual($zero, $v0, checkTopEdge)	 # else check top edge	
 	jal moveToRight	
 	nop
 checkTopEdge:
 	sub $v0, $s1, $s2	
 	add $v0, $v0, $t8	# If Yo - R + DELTA < 0 then moveToDown
 	branchIfLessOrEqual($zero, $v0, checkBottomEdge) # else check bottom edge
 	jal moveToDown	
 	nop
 checkBottomEdge:
 	add $v0, $s1, $s2	
 	add $v0, $v0, $t8	# If Yo + R + DELTA > SCREEN_HEIGHT then moveToUp
 	branchIfLessOrEqual($v0, $s4, draw)	         # else all condition eligible, draw circle
 	jal moveToUp				
 	nop
 	
#--------------------------------------------------------------------------------------------	
# Ham ve duong tron
	 					 				
draw: 	
 	setColorAndDrawCirle(BACKGROUND) # Ve duong tron trung mau nen
 	add $s0, $s0, $s7		# Cap nhat toa do moi cua duong tron
 	add $s1, $s1, $t8		
 
 	setColorAndDrawCirle(YELLOW) 	# Ve duong tron moi
 	delay($t9)				# Dung chuong trinh 1 khoang
 	j start
 	
endProgram:
 	li $v0, 10
 	syscall

#--------------------------------------------------------------------------------------------
# Ham ve duong tron
# Su dung du lieu o mang CIRCLE_DATA tao boi Circle_Init	

 drawCircle:
	add $sp, $sp, -4
	sw $ra, 0($sp)
 	li $t0, 0		# khoi tao bien i = 0
 loop_drawCircle:
  	slt $v0, $t0, $s2   	# i -> R
 	beqz $v0,  end_drawCircle # Neu i = R thi dung 
	
	sll $t5, $t0, 2		
	lw $t3, CIRCLE_DATA($t5) # Load j to $t3	 
	
 	move $a0, $t0		# i = $a0
	move $a1, $t3		# j = $a1
	jal drawCirclePoint	# Ve 2 diem (Xo + i, Yo + j), (Xo + j, Yo + i) tren phan tu thu I
	sub $a1, $zero, $t3
	jal drawCirclePoint	# Ve 2 diem (Xo + i, Yo - j), (Xo + j, Yo - i) tren phan tu thu II
	sub $a0, $zero, $t0
	jal drawCirclePoint	# Ve 2 diem (Xo - i, Yo - j), (Xo - j, Yo - i) tren phan tu thu III
	add $a1, $zero, $t3
	jal drawCirclePoint	# Ve 2 diem (Xo - i, Yo + j), (Xo - j, Yo + i) tren phan tu thu IV
	
	addi $t0, $t0, 1
	j loop_drawCircle
  end_drawCircle:
 	lw $ra, 0($sp)
 	add $sp, $sp, 0	
 	jr $ra
 
#--------------------------------------------------------------------------------------------
#	Ham ve diem tren duong tron
# 	Ve dong thoi 2 diem (X0 + i, Y0 +j ) va (Xo + j, Yo + i)
#	i = $a0, j = $a1
#	Xi =$t1, Yi = $t4

 drawCirclePoint:
 	
 	add $t1, $s0, $a0 	# Xi = X0 + i
	add $t4, $s1, $a1	# Yi = Y0 + j
	mul $t2, $t4, $s3	# Yi * SCREEN_WIDTH
	add $t1, $t1, $t2	# Yi * SCREEN_WIDTH + Xi (Toa do 1 chieu cua diem anh)
	sll $t1, $t1, 2		# Dia chi tuong doi cua diem anh
	sw $s5, SCREEN($t1)	# Draw anh
	add $t1, $s0, $a1 	# Xi = Xo + j
	add $t4, $s1, $a0	# Yi = Y0 + i
	mul $t2, $t4, $s3	# Yi * SCREEN_WIDTH
	add $t1, $t1, $t2	# Yi * SCREEN_WIDTH + Xi (Toa do 1 chieu cua diem anh)
	sll $t1, $t1, 2		# Dia chi tuong doi cua diem anh
	sw $s5, SCREEN($t1)	# Draw anh
	
	jr $ra
	
#--------------------------------------------------------------------------------------------			 					
# Cac ham di chuyen

moveToLeft:
	sub $s7, $zero, $t6
 	li $t8, 0
	jr $ra 	
moveToRight:
	add $s7, $zero, $t6
 	li $t8, 0
	jr $ra 	
moveToUp:
	li $s7, 0
	sub $t8, $zero, $t6
	jr $ra 	
moveToDown:
	li $s7, 0
	add $t8, $zero, $t6
	jr $ra 
	
#--------------------------------------------------------------------------------------------			 				
# Square Root
# de su dung floating point thi phai chuyen sang coprocessor	 				 				 				
# $v0 = S, $a0 = sqrt(S)

sqrt: 
	mtc1 $v0, $f0 # dua tu $v0 vao $f0
	cvt.s.w $f0, $f0 # Chuyen ve int 32 bit
	sqrt.s $f0, $f0 # Tinh can bac hai cua %f0
	cvt.w.s $f0, $f0 # Chuyen lai ve word
	mfc1 $a0, $f0 # dua lai tu $f0 vao $a0
	jr $ra
