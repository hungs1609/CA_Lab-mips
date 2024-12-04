.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv KEY_CODE 0xFFFF0004 	# ASCII code from keyboard, 1 byte
.eqv KEY_READY 0xFFFF0000 	# =1 if has a new keycode ?
 				# Auto clear after lw
# Marsbot setup
.eqv HEADING 0xffff8010 
.eqv MOVING 0xffff8050 
.eqv LEAVETRACK 0xffff8020 
.eqv WHEREX 0xffff8030 
.eqv WHEREY 0xffff8040
#setup keyReader
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
#===============================================================================
.data
#cac ma lenh cua mars bot 
	moveEvent: .asciiz "1b4"    #duoc luu là 1 trong mang di chuyen neu nhu bi goi den
	stopEvent: .asciiz "c68"    #duoc luu là 2 trong mang di chuyen neu nhu bi goi den
	leftEvent: .asciiz "444"    #duoc luu là 3 trong mang di chuyen neu nhu bi goi den
	rightEvent: .asciiz "666"   #duoc luu là 4 trong mang di chuyen neu nhu bi goi den
	trackEvent: .asciiz "dad"   #duoc luu là 5 trong mang di chuyen neu nhu bi goi den
	UNtrackEvent: .asciiz "cbc" #duoc luu là 6 trong mang di chuyen neu nhu bi goi den
	backEvent: .asciiz "999"    #duoc luu là 7 trong mang di chuyen neu nhu bi goi den
#cac ant dung de luu tru cac lich su cua bot
	currentLocation: .word 0  #luu lai vi tri hien tai cua bot phuc vu cho qua trinh back
	saveTimeArray:word 0:100  # luu lai cac khoang thoi gian giua cac cau lenh   
	saveControlCase:word 0:100 # luu cac buoc da su dung
	saveStateBot: .space 300       # luu cac trang thai cua bot [toa do x, toa do y, huong da lua chon]
	distanceMove: .word 12	  #khoang con bot di chuyen
#cac bien xu ly du lieu dau vao
	inputSaveCode: .space 20 # luu code dau vao
	lengthControlCode: .word 0 # luu do dai code
	errorCode: .asciiz "Something wrong, please try again\n"
	nofiCode: .asciiz "Repeating.....<.>\n"
	enterChar: .asciiz "\n"
.text	
main:
# khoi tao cac bien lay du lieu
	li $k0, KEY_CODE
 	li $k1, KEY_READY
 	li $a2,0 # so thao tac
	li $t1, IN_ADRESS_HEXA_KEYBOARD
	li $t3, 0x80 # bit 7 = 1 to enable
	sb $t3, 0($t1)
#---------------------------------------------------------
loadKeyCase:	lw $t6, 0($k1)			#nhap tung ki ty cho den khi gap dau \n delete space
		beq $t6, $zero, loadKeyCase	
		nop
		beq $t6, $zero, loadKeyCase
		lw $t5, 0($k0)			#doc tung gia tri cua nut
		beq $t5, 127 , resetCode		#delete case
		beq $t5, 32, doAgain		#space case			
		bne $t5, '\n' , loadKeyCase     #gap /n thi dung va chay xuong checkLengt
		nop		
checkLength:
		la $s2, lengthControlCode # kiem tra xem ma dieu khien co do dai = 3 hay khong
		lw $s2, 0($s2)
		bne $s2, 3, printferrorCode # in loi neu nhu do dai cua code khac 3
ReadCase:		
		la $s3, moveEvent # $s3 la trung gian de check
		jal checkCaseEvent
		beq $t0, 1, goCase
		
		la $s3, stopEvent
		jal checkCaseEvent
		beq $t0, 1, stopCase
		
		la $s3, leftEvent
		jal checkCaseEvent
		beq $t0, 1, goLeftCase
		
		la $s3, rightEvent
		jal checkCaseEvent
		beq $t0, 1, goRightCase
		
		la $s3, trackEvent
		jal checkCaseEvent
		beq $t0, 1, trackCase

		la $s3, UNtrackEvent
		jal checkCaseEvent
		beq $t0, 1, untrackCase
		
		la $s3, backEvent
		jal checkCaseEvent
		beq $t0, 1, goBackCase
endCase:	
		beq $t0, 0, printferrorCode # neu khong khop duoc lenh nao thi se bao loi	
# cac ham thong bao			
printf:	
	li $v0, 4
	la $a0, inputSaveCode
	syscall
	nop	
resetCode:
	jal deleteCode			
	nop
	j loadKeyCase
	nop
printferrorCode:
	li $v0, 4
	la $a0, inputSaveCode
	syscall
	nop
	nop
	li $v0, 55
	la $a0, errorCode
	syscall
	nop
	j resetCode
	nop
printfBack:	
	li $v0, 4
	la $a0, backEvent
	syscall
	li $v0, 4
	la $a0, enterChar
	syscall
	nop
	nop
	j again				
#Case control
doAgain:
	li $v0,4
	la $a0,nofiCode
	syscall
	li $t1,0
	addi $t9,$a2,0
loopWhile:
	beq $t1,$t9,endLoop
	addi $a3,$t1,0
	sll $a3,$a3,2
	lw $t8,saveControlCase($a3)
	#case check
	li $v1,1
	beq $t8,$v1,goCase
	li $v1,2
	beq $t8,$v1,stopCase
	li $v1,3
	beq $t8,$v1,goLeftCase
	li $v1,4
	beq $t8,$v1,goRightCase
	li $v1,5
	beq $t8,$v1,trackCase
	li $v1,6
	beq $t8,$v1,untrackCase
	li $v1,7
	beq $t8,$v1,again
	backToWhileLoop:
	subi $v1,$a2,1
	beq $t1,$v1,endLoop
	addi $a3,$t1,1
	sll $a3,$a3,2
	lw $a0,saveTimeArray($a3)
	li $v0,32
	syscall
	addi $t1,$t1,1
	j loopWhile
endLoop:
	j resetCode

#bang dieu khien cac hoat dong cua bot

goCase: 	
	sll $a3,$a2,2   
	addi $t7,$a1,0 # $a1 co nhiem vu la thoi gian cua cau lenh truoc duoc goi
	li $v0,30
	syscall        # lay thoi gian hien tai vao $a0
	sub $a1,$a0,$t7   # tinh khoang cach thoi gian giua cac cau lenh
	sw $a1,saveTimeArray($a3) # luu gia tri vua tim duoc vao mang
	addi $a1,$a0,0      # luu a1 thanh thoi gian cau lenh nay va tiep tuc qua trinh truoc
	li $v0,1            # luu ma cua case nay   
	sw $v0,saveControlCase($a3) # dua ma vao mang
	addi $a2,$a2,1
	jal GO
	beq $v1,$v0,backToWhileLoop # chi xay ra neu nhu duoc goi tu loopWhile
	j printf
stopCase:
	sll $a3,$a2,2
	addi $t7,$a1,0
	li $v0,30
	syscall
	sub $a1,$a0,$t7
	sw $a1,saveTimeArray($a3)
	addi $a1,$a0,0
	li $v0,2
	sw $v0,saveControlCase($a3)
	addi $a2,$a2,1 	
	jal STOP
	
	beq $v1,$v0,backToWhileLoop
	j printf

goLeftCase:	
	sll $a3,$a2,2
	addi $t7,$a1,0
	li $v0,30
	syscall
	sub $a1,$a0,$t7
	sw $a1,saveTimeArray($a3)
	addi $a1,$a0,0
	li $v0,3
	sw $v0,saveControlCase($a3)
	addi $a2,$a2,1
	#-------------------------------
	addi $sp,$sp,4
	sw $s5, 0($sp)
	addi $sp,$sp,4
	sw $s6, 0($sp)
	
	la $s5, currentLocation
	lw $s6, 0($s5)	
	addi $s6, $s6, -90 
	sw $s6, 0($s5)
	#tra lai gia tri
	lw $s6, 0($sp)
	addi $sp,$sp,-4
	lw $s5, 0($sp)
	addi $sp,$sp,-4
	jal saveStatus
	jal ROTATE
	beq $v1,$v0,backToWhileLoop
	j printf
goRightCase:
	sll $a3,$a2,2
	addi $t7,$a1,0 
	li $v0,30
	syscall
	sub $a1,$a0,$t7
	sw $a1,saveTimeArray($a3)
	addi $a1,$a0,0
	li $v0,4
	sw $v0,saveControlCase($a3)
	addi $a2,$a2,1
	#------------------------------
	addi $sp,$sp,4
	sw $s5, 0($sp)
	addi $sp,$sp,4
	sw $s6, 0($sp)
	la $s5, currentLocation
	lw $s6, 0($s5)	#thay doi vi tri hien tai
	addi $s6, $s6, 90 #quay phai 90
	sw $s6, 0($s5) 
	#tra lai gia tri
	lw $s6, 0($sp)
	addi $sp,$sp,-4
	lw $s5, 0($sp)
	addi $sp,$sp,-4
	jal saveStatus
	jal ROTATE
	
	beq $v1,$v0,backToWhileLoop
	j printf
trackCase:
	sll $a3,$a2,2
	
	addi $t7,$a1,0
	li $v0,30
	syscall
	sub $a1,$a0,$t7
	sw $a1,saveTimeArray($a3)
	addi $a1,$a0,0
	
	li $v0,5
	sw $v0,saveControlCase($a3)
	
	addi $a2,$a2,1	
	jal TRACK
	
	beq $v1,$v0,backToWhileLoop
	j printf
untrackCase:
	sll $a3,$a2,2
	
	addi $t7,$a1,0
	li $v0,30
	syscall
	sub $a1,$a0,$t7
	sw $a1,saveTimeArray($a3)
	addi $a1,$a0,0
	
	li $v0,6
	sw $v0,saveControlCase($a3)
	addi $a2,$a2,1 
	jal UNTRACK
	li $a3,6
	beq $v1,$v0,backToWhileLoop
	j printf
goBackCase:
	j printfBack
again:
	sll $a3,$a2,2
	addi $t7,$a1,0
	li $v0,30
	syscall
	sub $a1,$a0,$t7
	sw $a1,saveTimeArray($a3)
	addi $a1,$a0,0
	li $v0,7
	sw $v0,saveControlCase($a3)
	addi $a2,$a2,1
	#tra lai gia tri
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
	la $s7, saveStateBot
	la $s5, distanceMove
	lw $s5, 0($s5)
	add $s7, $s7, $s5
goBackloop1:
	addi $s5, $s5, -12 	#tim duoc trang thai gan nhat cua bot
	addi $s7, $s7, -12	#vi tri cuoi cung cua bot
	lw $s6, 8($s7)		#huong cua bot
	addi $s6, $s6, 180	#cho bot di nguoc lkai
	la $t8, currentLocation	
	sw $s6, 0($t8)
	jal ROTATE
goBackloop2:	
	lw $t9, 0($s7)		#toa do x cua diem dau tien cua canh
	li $t8, WHEREX		#toa do x hien tai
	lw $t8, 0($t8)
	bne $t8, $t9, goBackloop2
	nop
	bne $t8, $t9, goBackloop2
	lw $t9, 4($s7)		#toa do y cua diem dau tien cua canh
	li $t8, WHEREY		#toa do y hien tai
	lw $t8, 0($t8)
	bne $t8, $t9, goBackloop2
	nop
	bne $t8, $t9, goBackloop2
	beq $s5, 0, outLoop
	nop
	beq $s5, 0, outLoop
	j goBackloop1
	nop
	j goBackloop1
outLoop:
	jal STOP
	la $t8, currentLocation
	add $s6, $zero, $zero
	sw $s6, 0($t8)		#update heading
	la $t8, distanceMove
	addi $s5, $zero, 12
	sw $s5, 0($t8)		
	#restore
	lw $t9, 0($sp)
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
	li $a3,7
	beq $v1,$v0,backToWhileLoop
	j resetCode					
deleteCode:
	#luu gia tri khi jal
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
	#-------------------------------------------------------------------------
	la $s2, lengthControlCode
	lw $t3, 0($s2)					#do dai cua code hien tai lay tu labsim
	addi $t1, $zero, -1				
	addi $t2, $zero, 0				
	la $s1, inputSaveCode
	addi $s1, $s1, -1
loopDelete1:
		addi $t1, $t1, 1			#i++
		add $s1, $s1, 1				
		sb $t2, 0($s1)				#xoa dan dan cac phan tu bang cac thay 0 vao	
		bne $t1, $t3, loopDelete1	
		nop
		bne $t1, $t3, loopDelete1
		
	add $t3, $zero, $zero			
	sw $t3, 0($s2)					#gan lai do dai cua code
		
	#tra lai cac gia tri
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
checkCaseEvent:
	#moi khi dung jal phai luu lai cac bien s,sp.....
	addi $sp,$sp,4
	sw $t1, 0($sp)
	addi $sp,$sp,4
	sw $s1, 0($sp)
	addi $sp,$sp,4
	sw $t2, 0($sp)
	addi $sp,$sp,4
	sw $t3, 0($sp)	
	#tien hanh check
	addi $t1, $zero, -1				
	add $t0, $zero, $zero
	la $s1, inputSaveCode	   		
	loopStringCheck:          # check cho den khi phat hien 1 ky tu khac
		addi $t1, $t1, 1			
		add $t2, $s1, $t1			
		lb $t2, 0($t2)				
		add $t3, $s3, $t1			
		lb $t3, 0($t3)				
		bne $t2, $t3, falseCase # phat hien ky tu khac se tu dong nhay sang false
		bne $t1, 2, loopStringCheck	
		nop
		bne $t1, 2, loopStringCheck
trueCase: # neu chay het vong lap se chay xuong true case
	lw $t3, 0($sp) # gan lai cac gia tri truoc da save o truoc
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	li $t0,1       #return true false bang $t0
	jr $ra
	nop
	jr $ra
falseCase:
	#restore
	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	li $t0,0	#return true false bang $t0
	jr $ra
	nop
	jr $ra
			
GO: 	#luu gia tri khi jal
	addi $sp,$sp,4
	sw $at,0($sp)
	addi $sp,$sp,4
	sw $k0,0($sp)
	li $at, MOVING 
 	addi $k0, $zero,1 
	sb $k0, 0($at) 
	#tra lai gia tri
	lw $k0, 0($sp)
	addi $sp,$sp,-4
	lw $at, 0($sp)
	addi $sp,$sp,-4
	jr $ra
	nop
	jr $ra
STOP: 	#luu gia tri khi jal
	addi $sp,$sp,4
	sw $at,0($sp)

	li $at, MOVING 
	sb $zero, 0($at) 
	#tra lai gia tri
	lw $at, 0($sp)
	addi $sp,$sp,-4
	jr $ra
	nop
	jr $ra
TRACK: 	#luu lai gia tri khi jal
	addi $sp,$sp,4
	sw $at,0($sp)
	addi $sp,$sp,4
	sw $k0,0($sp)
	
	li $at, LEAVETRACK 
	addi $k0, $zero,1 
 	sb $k0, 0($at) 
 	#tra lai gia tri
	lw $k0, 0($sp)
	addi $sp,$sp,-4
	lw $at, 0($sp)
	addi $sp,$sp,-4
 	jr $ra
	nop
	jr $ra
UNTRACK:#luu gia tri khi jal
	addi $sp,$sp,4
	sw $at,0($sp)
	#processing
	li $at, LEAVETRACK 
 	sb $zero, 0($at) 
	lw $at, 0($sp) 
	addi $sp,$sp,-4
 	jr $ra
	nop
	jr $ra
ROTATE: 
	#luu lai gia tri khi jal
	addi $sp,$sp,4
	sw $t1,0($sp)
	addi $sp,$sp,4
	sw $t2,0($sp)
	addi $sp,$sp,4
	sw $t3,0($sp)
	#processing
	li $t1, HEADING 
	la $t2, currentLocation
	lw $t3, 0($t2)	
 	sw $t3, 0($t1) 
 	#tra lai gia tri
 	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	
 	jr $ra
	nop
	jr $ra	
saveStatus:
	#luu du lieu khi dung jal
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
	#---------------------------------------------------------------
	li $t1, WHEREX
	lw $s1, 0($t1)		#tien hanh luu x vao o dau tien $t1
	li $t2, WHEREY	
	lw $s2, 0($t2)		#luu y vao $s2
	la $s4, currentLocation
	lw $s4, 0($s4)		#vi tri hien tai cua con bot 
	la $t3, distanceMove
	lw $s3, 0($t3)		#luu lai quang duong cua bot
	la $t4, saveStateBot    # luu tat ca cac  trang thai vao mang saveState
	add $t4, $t4, $s3	
	sw $s1, 0($t4)		# tien hanh luu vao mang
	sw $s2, 4($t4)		
	sw $s4, 8($t4)		
	addi $s3, $s3, 12	
	sw $s3, 0($t3)
	#tra lai du lieu
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
get_cod:
	li $t1, IN_ADRESS_HEXA_KEYBOARD
	li $t2, OUT_ADRESS_HEXA_KEYBOARD
scan_row1:
	li $t3, 0x81
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_code_in_char
scan_row2:
	li $t3, 0x82
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_code_in_char
scan_row3:
	li $t3, 0x84
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_code_in_char
scan_row4:
	li $t3, 0x88
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_code_in_char
get_code_in_char:
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
case_0:	li $s0, '0'
	j store_code
case_1:	li $s0, '1'
	j store_code
case_2:	li $s0, '2'
	j store_code
case_3:	li $s0, '3'
	j store_code
case_4:	li $s0, '4'
	j store_code
case_5:	li $s0, '5'
	j store_code
case_6:	li $s0, '6'
	j store_code
case_7:	li $s0, '7'
	j store_code
case_8:	li $s0, '8'
	j store_code
case_9:	li $s0, '9'
	j store_code
case_a:	li $s0, 'a'
	j store_code
case_b:	li $s0, 'b'
	j store_code
case_c:	li $s0, 'c'
	j store_code
case_d:	li $s0, 'd'
	j store_code
case_e:	li $s0,	'e'
	j store_code
case_f:	li $s0, 'f'
	j store_code
store_code:
	la $s1, inputSaveCode
	la $s2, lengthControlCode
	lw $s3, 0($s2)				
	addi $t4, $t4, -1 			
	loopSave:
		addi $t4, $t4, 1       # tang gia tri them 1
		bne $t4, $s3, loopSave
		add $s1, $s1, $t4		
		sb  $s0, 0($s1)			
		addi $s0, $zero, '\n'	 # them gia tri \n de xuong dong	
		addi $s1, $s1, 1		
		sb  $s0, 0($s1)			
		addi $s3, $s3, 1
		sw $s3, 0($s2)			#luu lai do dai code
		
next_pc:
	mfc0 $at, $14 # $at <= Coproc0.$14 = Coproc0.epc
	addi $at, $at, 4 # $at = $at + 4 (next instruction)
	mtc0 $at, $14 # Coproc0.$14 = Coproc0.epc <= $at
restore:
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
