.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014 #dia chi ngat ket noi digital lab sim
.eqv KEY_CODE 0xFFFF0004 	# Lw keyboard
.eqv KEY_READY 0xFFFF0000 	# cho keyboard			
#-------------------------------------------------------------------------------
# Key value
	.eqv KEY_0 0x11
	.eqv KEY_1 0x21
	.eqv KEY_2 0x41
	.eqv KEY_3 0x81
	.eqv KEY_4 0x12
	.eqv KEY_5 0x22
	.eqv KEY_6 0x42
	.eqv KEY_7 0x82
	.eqv KEY_8 0x14
	.eqv KEY_9 0x24
	.eqv KEY_a 0x44
	.eqv KEY_b 0x84
	.eqv KEY_c 0x18
	.eqv KEY_d 0x28
	.eqv KEY_e 0x48
	.eqv KEY_f 0x88
#-------------------------------------------------------------------------------
# Marsbot
.eqv HEADING 0xffff8010 # Integer: Goc tu 0 den 359
.eqv MOVING 0xffff8050 # Boolean: di chuyen?
.eqv LEAVETRACK 0xffff8020 # de lai vet
.eqv WHEREX 0xffff8030 #Vi tri x hien tai cua MarsBot
.eqv WHEREY 0xffff8040 #Vi tri y hien tai cua MarsBot
#-------------------------------------------------------------------------------
.data
	#Control code
	MoveCode: .asciiz "1b4"
	StopCode: .asciiz "c68"
	GoLeftCode: .asciiz "444"
	GoRightCode: .asciiz "666"
	DeLaiVet: .asciiz "dad"
	StopDeLaiVet: .asciiz "cbc"
	BackCode: .asciiz "999"
	WRONG_CODE: .asciiz "Nhap sai code!!!"
	
	inputControlCode: .space 10
	lengthControlCode: .word 0
	nowHeading: .word 0   # vi tri hien tai cua boot
	path: .space 600 # luu trang thai khi thay doi cau lenh
	lengthPath: .word 12		# do lon byte luu 3 gia tri x,y,z
#-------------------------------------------------------------------------------
.text	
main:   #khai bao
	li $k0, KEY_CODE
 	li $k1, KEY_READY
	li $t1, IN_ADRESS_HEXA_KEYBOARD		# Cho phep ngat ban phim cua Digital Lab Sim
	li $t3, 0x80 				
	sb $t3, 0($t1)
#-------------------------------------------------------------------------------
loop:		nop
WAITKEY:	lw $t5, 0($k1)			# $t5 = [$k1] = KEY_READY
		beq $t5, $zero, WAITKEY	# Neu $t5 == 0 thi lap lai WAITKEY, kiem tra key moi
		nop
		beq $t5, $zero, WAITKEY		
		nop
READ:       lw $t6, 0($k0)			# $t6 = [$k0] = KEY_CODE
		beq $t6, 127, delete		# Neu $t6 == delete key thi xoa input, 127 la delete key trong ma ascii
		nop
		bne $t6, '\n', loop		# Neu $t6 != '\n' thi lap lai loop, dung de doc enter khi nhap vao
		nop
CHECKCONTROL:
		la $s2, lengthControlCode
		lw $s2, 0($s2)
		bne $s2, 3, errorMessage
		nop
		
		la $s3, MoveCode
		jal TEST_CONTROL
		nop
		beq $t0, 1, go
		nop
		
		la $s3, StopCode
		jal TEST_CONTROL
		nop
		beq $t0, 1, stop
		nop
			
		
		la $s3, GoLeftCode
		jal TEST_CONTROL
		nop
		beq $t0, 1, goLeft
		nop
		
		la $s3, GoRightCode
		jal TEST_CONTROL
		nop
		beq $t0, 1, goRight
		nop
		
		la $s3, DeLaiVet
		jal TEST_CONTROL
		nop
		beq $t0, 1, track
		nop

		
		la $s3, StopDeLaiVet
		jal TEST_CONTROL
		nop
		beq $t0, 1, untrack
		nop
		
		
		la $s3, BackCode
		jal TEST_CONTROL
		nop
		beq $t0, 1, goBack
		nop
		
		beq $t0, 0, errorMessage
		nop
			
PRINT_CONTROL:	
	li $v0, 4
	la $a0, inputControlCode
	syscall
	nop
delete:
	jal REMOVE_CONTROL			
	nop
	j loop
	nop
	j loop

TEST_CONTROL:# so sanh keyboard voi $s3( == -> $t0=1; != ->4st0=0)
	#backup
	addi $sp,$sp,4
	sw $t1, 0($sp)
	addi $sp,$sp,4
	sw $s1, 0($sp)
	addi $sp,$sp,4
	sw $t2, 0($sp)
	addi $sp,$sp,4
	sw $t3, 0($sp)	
	
							# processing
	addi $t1, $zero, -1				# $t1 = -1 = i
	add $t0, $zero, $zero
	la $s1, inputControlCode			# $s1 = inputControlCode
	loopToCheckString:
		addi $t1, $t1, 1			# i++
	
		add $t2, $s1, $t1			# $t2 = inputControlCode + i
		lb $t2, 0($t2)				# $t2 = inputControlCode[i]
		
		add $t3, $s3, $t1			# $t3 = s + i
		lb $t3, 0($t3)				# $t3 = s[i]
		
		bne $t2, $t3, isNotControlCode		# Neu $t2 != $t3 nhay den isNotControlCode

		
		bne $t1, 2, loopToCheckString		# Neu $t1 <= 2 tiep tuc vong lap
		nop
		bne $t1, 2, loopToCheckString
												
	lw $t3, 0($sp)					# restore
	addi $sp,$sp,-4	
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	
	add $t0, $zero, 1				# Cap nhat $t0 = 1
	jr $ra
	nop
	jr $ra
isNotControlCode:
	lw $t3, 0($sp)					# restore
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4

	add $t0, $zero, $zero				# Cap nhat $t0 = 0
	jr $ra
	nop
	jr $ra

errorMessage: #Hien thong bao dialog khi nhap code sai
	li $v0, 4
	la $a0, inputControlCode
	syscall
	nop
	
	li $v0, 55
	la $a0, WRONG_CODE
	syscall
	nop
	nop
	j delete
	nop
	j delete		

REMOVE_CONTROL: #Xoa xau inputControlCode, lan luot gan cac ky tu cua inputControlCode = '\0'
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
	la $s2, lengthControlCode
	lw $t3, 0($s2)					#$t3 = lengthControlCode
	addi $t1, $zero, -1				#$t1 = -1 = i
	addi $t2, $zero, 0				#$t2 = '\0'
	la $s1, inputControlCode
	addi $s1, $s1, -1
	forLoopToRemove:
		addi $t1, $t1, 1			#i++
	
		add $s1, $s1, 1				#$s1 = inputControlCode + i
		sb $t2, 0($s1)				#inputControlCode[i] = '\0'
				
		bne $t1, $t3, forLoopToRemove	#if $t1 <=3 continue loop
		nop
		bne $t1, $t3, forLoopToRemove
		
	add $t3, $zero, $zero			
	sw $t3, 0($s2)				#lengthControlCode = 0
		
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

storePath:                      # luu lai thong tin ve duong di cua Marsbot vao mang path
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
	lw $s1, 0($t1)		# s1 = x
	li $t2, WHEREY	
	lw $s2, 0($t2)		# s2 = y
	
	la $s4, nowHeading
	lw $s4, 0($s4)		# s4 = now heading

	la $t3, lengthPath
	lw $s3, 0($t3)		# $s3 = lengthPath (dv: byte)
	
	la $t4, path
	add $t4, $t4, $s3	# Vi tri bat dau luu 
	
	sw $s1, 0($t4)		# Luu x
	sw $s2, 4($t4)		# Luu y
	sw $s4, 8($t4)		# Luu heading
	
	addi $s3, $s3, 12	# Cap nhat lengthPath
				# 12 = 3 (word) x 4 (bytes)
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

track: 	jal TRACK        #track: Dieu khien Marsbot va in control conde
	j PRINT_CONTROL

untrack: jal UNTRACK                 #untrack: Dieu khien Marsbot va in control conde
	j PRINT_CONTROL

go: 	
	jal GO
	j PRINT_CONTROL

stop: 	jal STOP
	j PRINT_CONTROL

goRight:
	#backup
	addi $sp,$sp,4
	sw $s5, 0($sp)
	addi $sp,$sp,4
	sw $s6, 0($sp)
	#restore
	la $s5, nowHeading
	lw $s6, 0($s5)		
	addi $s6, $s6, 90 	
	sw $s6, 0($s5) 		# Cap nhat nowHeading = nowHeading + 90
	#restore
	lw $s6, 0($sp)
	addi $sp,$sp,-4
	lw $s5, 0($sp)
	addi $sp,$sp,-4
	
	jal storePath
	jal ROTATE
	j PRINT_CONTROL	

goLeft:	                      #Dieu khien Marsbot quay va di chuyen sang trai mot goc 90
	#backup
	addi $sp,$sp,4
	sw $s5, 0($sp)
	addi $sp,$sp,4
	sw $s6, 0($sp)
	#processing
	la $s5, nowHeading
	lw $s6, 0($s5)		
	addi $s6, $s6, -90 	
	sw $s6, 0($s5) 		# Cap nhat nowHeading = nowHeading - 90
	#restore
	lw $s6, 0($sp)
	addi $sp,$sp,-4
	lw $s5, 0($sp)
	addi $sp,$sp,-4
	
	jal storePath
	jal ROTATE
	j PRINT_CONTROL

goBack:                   #goBack: Dieu khien Marsbot di nguoc lai theo lo trinh da di va ve lai diem xuat phat
	#backup
	addi $sp,$sp,4
	sw $s5, 0($sp)
	addi $sp,$sp,4
	sw $s6, 0($sp)
	addi $sp,$sp,4
	sw $s7, 0($sp)
	addi $sp,$sp,4
	sw $t8, 0($sp)
	addi $sp,$sp,4
	sw $t9, 0($sp)
	
	jal UNTRACK
	jal GO
	la $s7, path
	la $s5, lengthPath
	lw $s5, 0($s5)
	add $s7, $s7, $s5
begin:
	addi $s5, $s5, -12 	# Lui lai 1 structure
	
	addi $s7, $s7, -12	# Vi tri cua thong tin ve canh cuoi cung
	lw $s6, 8($s7)		# Huong cua canh cuoi cung
	addi $s6, $s6, 180	# Nguoc lai huong cua canh cuoi cung
	
	la $t8, nowHeading	# Marsbot quay nguoc lai
	sw $s6, 0($t8)
	jal ROTATE

goToFirstPointOfEdge:	
	lw $t9, 0($s7)		# Toa do x cua diem dau tien cua canh
	li $t8, WHEREX		# Toa do x hien tai
	lw $t8, 0($t8)

	bne $t8, $t9, goToFirstPointOfEdge
	nop
	bne $t8, $t9, goToFirstPointOfEdge
	
	lw $t9, 4($s7)		# Toa do y cua diem dau tien cua canh
	li $t8, WHEREY		# Toa do y hien tai
	lw $t8, 0($t8)
	
	bne $t8, $t9, goToFirstPointOfEdge
	nop
	bne $t8, $t9, goToFirstPointOfEdge
	
	beq $s5, 0, finish
	nop
	beq $s5, 0, finish
	
	j begin
	nop
	j begin
	
finish:
	jal STOP
	
	la $t8, nowHeading
	add $s6, $zero, $zero
	sw $s6, 0($t8)		# Cap nhat heading
	la $t8, lengthPath
	addi $s5, $zero, 12
	sw $s5, 0($t8)		# Cap nhat lengthPath = 12
	
	lw $t9, 0($sp)		#restore
	addi $sp,$sp,-4
	lw $t8, 0($sp)
	addi $sp,$sp,-4
	lw $s7, 0($sp)
	addi $sp,$sp,-4
	lw $s6, 0($sp)
	addi $sp,$sp,-4
	lw $s5, 0($sp)
	addi $sp,$sp,-4
	
	jal ROTATE
	j PRINT_CONTROL				

GO: 	                       #GO: Dieu khien Marsbot chuyen dong
	addi $sp,$sp,4		# backup
	sw $at,0($sp)
	addi $sp,$sp,4
	sw $k0,0($sp)
	
				# processing
	li $at, MOVING 		# Thay doi MOVING port
 	addi $k0, $zero,1 	# logic 1
	sb $k0, 0($at) 		# Bat dau chuyen dong	
	
	lw $k0, 0($sp)		# restore
	addi $sp,$sp,-4
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
	jr $ra
	nop
	jr $ra

STOP: 	                       #STOP: Dieu khien Marsbot dung lai
	addi $sp,$sp,4		# backup
	sw $at,0($sp)
	
				# processing
	li $at, MOVING 		# Thay doi MOVING port thanh 0
	sb $zero, 0($at) 	# Dung lai
	
	lw $at, 0($sp)		# restore
	addi $sp,$sp,-4
	
	jr $ra
	nop
	jr $ra

TRACK: 	                       #TRACK: Dieu khien Marsbot bat dau de lai vet 
	addi $sp,$sp,4		# backup
	sw $at,0($sp)
	addi $sp,$sp,4
	sw $k0,0($sp)
	
				# processing
	li $at, LEAVETRACK 	# Thay doi LEAVETRACK port
	addi $k0, $zero,1 	# logic 1
 	sb $k0, 0($at) 		# Bat dau ve
 	
	lw $k0, 0($sp)		# restore
	addi $sp,$sp,-4
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
 	jr $ra
	nop
	jr $ra

UNTRACK:                       #UNTRACK: Dieu khien Marsbot ket thuc de lai vet
				#backup
	addi $sp,$sp,4
	sw $at,0($sp)
	
				#processing
	li $at, LEAVETRACK 	# Thay doi LEAVETRACK port thanh 0
 	sb $zero, 0($at) 	# Dung ve
 	
 	#restore
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
 	jr $ra
	nop
	jr $ra

ROTATE:                        # ROTATE: Quay Marsbot theo huong co so do luu trong nowHeading
	addi $sp,$sp,4		#backup
	sw $t1,0($sp)
	addi $sp,$sp,4
	sw $t2,0($sp)
	addi $sp,$sp,4
	sw $t3,0($sp)
	
				#processing
	li $t1, HEADING 	# Thay doi HEADING port
	la $t2, nowHeading
	lw $t3, 0($t2)		# $t3 la heading hien tai	
 	sw $t3, 0($t1) 		# Xoay bot
 	
 	lw $t3, 0($sp)		#restore
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	
 	jr $ra
	nop
	jr $ra	



# GENERAL INTERRUPT SERVED ROUTINE for all interrupts

.ktext 0x80000180

# SAVE the current REG FILE to stack
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

# Processing

getCode:
	li $t1, IN_ADRESS_HEXA_KEYBOARD
	li $t2, OUT_ADRESS_HEXA_KEYBOARD
scanRow1:
	li $t3, 0x81
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, getCodeInChar
scanRow2:
	li $t3, 0x82
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, getCodeInChar
scanRow3:
	li $t3, 0x84
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, getCodeInChar
scanRow4:
	li $t3, 0x88
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, getCodeInChar
getCodeInChar:
	beq $a0, KEY_0, case_0
	beq $a0, KEY_1, case_1
	beq $a0, KEY_2, case_2
	beq $a0, KEY_3, case_3
	beq $a0, KEY_4, case_4
	beq $a0, KEY_5, case_5
	beq $a0, KEY_6, case_6
	beq $a0, KEY_7, case_7
	beq $a0, KEY_8, case_8
	beq $a0, KEY_9, case_9
	beq $a0, KEY_a, case_a
	beq $a0, KEY_b, case_b
	beq $a0, KEY_c, case_c
	beq $a0, KEY_d, case_d
	beq $a0, KEY_e, case_e
	beq $a0, KEY_f, case_f
	
	# $s0 luu tru code kieu ky tu
case_0:	li $s0, '0'
	j storeCode
case_1:	li $s0, '1'
	j storeCode
case_2:	li $s0, '2'
	j storeCode
case_3:	li $s0, '3'
	j storeCode
case_4:	li $s0, '4'
	j storeCode
case_5:	li $s0, '5'
	j storeCode
case_6:	li $s0, '6'
	j storeCode
case_7:	li $s0, '7'
	j storeCode
case_8:	li $s0, '8'
	j storeCode
case_9:	li $s0, '9'
	j storeCode
case_a:	li $s0, 'a'
	j storeCode
case_b:	li $s0, 'b'
	j storeCode
case_c:	li $s0, 'c'
	j storeCode
case_d:	li $s0, 'd'
	j storeCode
case_e:	li $s0,	'e'
	j storeCode
case_f:	li $s0, 'f'
	j storeCode
storeCode:
	la $s1, inputControlCode
	la $s2, lengthControlCode
	lw $s3, 0($s2)				# $s3 = strlen(inputControlCode)
	addi $t4, $t4, -1 			# $t4 = i 
	loopToStoreCode:
		addi $t4, $t4, 1		 # i++
		bne $t4, $s3, loopToStoreCode	 # neu $t4 != $s3 thi nhay lai tu dau
		add $s1, $s1, $t4		 # $s1 = inputControlCode + i
		sb  $s0, 0($s1)			 # inputControlCode[i] = $s0
		
		addi $s0, $zero, '\n'		# Them '\n' vao cuoi xau
		addi $s1, $s1, 1		
		sb  $s0, 0($s1)			
		
		addi $s3, $s3, 1
		sw $s3, 0($s2)			# cap nhat lai do dai cua inputControlCode
		
next_pc:                                      #Evaluate the return address of main routine, epc <= epc + 4
	mfc0 $at, $14 # $at <= Coproc0.$14 = Coproc0.epc
	addi $at, $at, 4 # $at = $at + 4 (next instruction)
	mtc0 $at, $14 # Coproc0.$14 = Coproc0.epc <= $at


restore:                                     # RESTORE the REG FILE from STACK               
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
return: eret # Return from exception
