.eqv HEXA_KEYBOARD_IN 0xFFFF0012
.eqv HEXA_KEYBOARD_OUT 0xFFFF0014
.eqv HEX_CODE 0xFFFF0004 	
.eqv HEX_READY 0xFFFF0000 	
 				
#-------------------------------------------------------------------------------
# Key 
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
.eqv STATE 0xffff8010 
.eqv MOVING 0xffff8050 
.eqv LEAVETRACK 0xffff8020 
.eqv AXISX 0xffff8030 
.eqv AXISY 0xffff8040
#===============================================================================
.data
#cac lenh dieu khien
	
	inputCode: .space 50
	lengthInputCode: .word 0
	nowState: .word 0
	timeHistory:word 0:100       
	historyControl:word 0:100 # luu cac buoc da su dung
	history: .space 600       # luu toa do cua con bot
	length: .word 12		#bytes
	moveCode: .asciiz "1b4"    
	stopCode: .asciiz "c68"    
	leftCode: .asciiz "444"    
	rightCode: .asciiz "666"   
	trackCode: .asciiz "dad"   
	UNtrackCode: .asciiz "cbc" 
	backCode: .asciiz "999"    
	Error: .asciiz "Error! An error occurred.\n"
	SpaceAsciiz: .asciiz " "
.text	
main:
	li $k0, HEX_CODE
 	li $k1, HEX_READY
 	li $a2,0          # so thao tac
#---------------------------------------------------------
# Enable the interrupt of Keyboard matrix 4x4 of Digital Lab Sim
#---------------------------------------------------------
	li $t1, HEXA_KEYBOARD_IN
	li $t3, 0x80 # bit 7 = 1 to enable
	sb $t3, 0($t1)
#---------------------------------------------------------
loop:		nop
WAIT:	lw $t5, 0($k1)			#$t5 = [$k1] = HEX_READY
		beq $t5, $zero, WAIT	#if $t5 == 0 then Polling 
		nop
		beq $t5, $zero, WAIT
READ:	lw $t6, 0($k0)			#$t6 = [$k0] = HEX_CODE
		beq $t6, 127 , continue		#if $t6 == delete key then remove input , 127 is delete key in ascii	
		beq $t6, 32, do_one_more	#if $t6 == space key then run previous command, 32 is space key in ascii
		bne $t6, '\n' , loop		#if $t6 != '\n' then Polling
		nop
		bne $t6, '\n' , loop
checkControl:
		la $s2, lengthInputCode # kiem tra xem ma dieu khien co do dai = 3 hay khong
		lw $s2, 0($s2)
		bne $s2, 3, consologError # in loi
		la $s3, moveCode
		jal checkCase
		beq $t0, 1, go
		
		la $s3, stopCode
		jal checkCase
		beq $t0, 1, stop
		
		la $s3, leftCode
		jal checkCase
		beq $t0, 1, left
		
		la $s3, rightCode
		jal checkCase
		beq $t0, 1, right
		
		la $s3, trackCode
		jal checkCase
		beq $t0, 1, track

		la $s3, UNtrackCode
		jal checkCase
		beq $t0, 1, untrack
		
		la $s3, backCode
		jal checkCase
		beq $t0, 1, back
	
		beq $t0, 0, consologError # neu khong khop duoc lenh nao thi se bao loi
			
consolog:	
	li $v0, 4
	la $a0, inputCode
	syscall
	nop
		
continue:
	jal remove			
	nop
	j loop
	nop
	j loop
#
saveHistory:
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
	li $t1, AXISX
	lw $s1, 0($t1)		#s1 = x
	li $t2, AXISY	
	lw $s2, 0($t2)		#s2 = y
	la $s4, nowState
	lw $s4, 0($s4)		#s4 = now state
	la $t3, length
	lw $s3, 0($t3)		#$s3 = length (dv: byte)
	la $t4, history
	add $t4, $t4, $s3	#position to save
	sw $s1, 0($t4)		#save x
	sw $s2, 4($t4)		#save y
	sw $s4, 8($t4)		#save state
	addi $s3, $s3, 12	#update length 12 = 3 (word) x 4 (bytes)
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
do_one_more:
	li $t1,0
	addi $t9,$a2,0
loopWhile:
	beq $t1,$t9,endLoop
	addi $a3,$t1,0
	sll $a3,$a3,2
	lw $t8,historyControl($a3)
	#case check
	li $v1,1
	beq $t8,$v1,go
	li $v1,2
	beq $t8,$v1,stop
	li $v1,3
	beq $t8,$v1,left
	li $v1,4
	beq $t8,$v1,right
	li $v1,5
	beq $t8,$v1,track
	li $v1,6
	beq $t8,$v1,untrack
	li $v1,7
	beq $t8,$v1,back
	point:
	subi $v1,$a2,1
	beq $t1,$v1,endLoop
	addi $a3,$t1,1
	sll $a3,$a3,2
	lw $a0,timeHistory($a3)
	li $v0,32
	syscall
	addi $t1,$t1,1
	j loopWhile
endLoop:
	j continue
back:
	
	
	sll $a3,$a2,2
	
	addi $t7,$a1,0
	li $v0,30
	syscall
	sub $a1,$a0,$t7
	sw $a1,timeHistory($a3)
	addi $a1,$a0,0
	li $v0,7
	sw $v0,historyControl($a3)
	
	addi $a2,$a2,1
	
	
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
	la $s7, history
	la $s5, length
	lw $s5, 0($s5)
	add $s7, $s7, $s5
start:
	addi $s5, $s5, -12 	#lui lai 1 structure
	addi $s7, $s7, -12	#vi tri cua thong tin ve canh cuoi cung
	lw $s6, 8($s7)		#huong cua canh cuoi cung
	addi $s6, $s6, 180	#nguoc lai huong cua canh cuoi cung
	la $t8, nowState	#marsbot quay nguoc lai
	sw $s6, 0($t8)
	jal NAVIGATE
firstPointEdge:	
	lw $t9, 0($s7)		#toa do x cua diem dau tien cua canh
	li $t8, AXISX		#toa do x hien tai
	lw $t8, 0($t8)
	bne $t8, $t9, firstPointEdge
	nop
	bne $t8, $t9, firstPointEdge
	lw $t9, 4($s7)		#toa do y cua diem dau tien cua canh
	li $t8, AXISY		#toa do y hien tai
	lw $t8, 0($t8)
	bne $t8, $t9, firstPointEdge
	nop
	bne $t8, $t9, firstPointEdge
	beq $s5, 0, end
	nop
	beq $s5, 0, end
	j start
	nop
	j start
end:
	jal STOP
	la $t8, nowState
	add $s6, $zero, $zero
	sw $s6, 0($t8)		#update heading
	la $t8, length
	addi $s5, $zero, 12
	sw $s5, 0($t8)		#update length = 12
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
	jal NAVIGATE
	li $a3,7
	beq $v1,$a3,point
	j consolog
#control
track:
	sll $a3,$a2,2
	
	addi $t7,$a1,0
	li $v0,30
	syscall
	sub $a1,$a0,$t7
	sw $a1,timeHistory($a3)
	addi $a1,$a0,0
	
	li $v0,5
	sw $v0,historyControl($a3)
	
	addi $a2,$a2,1	
	jal TRACK
	li $a3,5
	beq $v1,$a3,point
	j consolog
untrack:
	sll $a3,$a2,2
	
	addi $t7,$a1,0
	li $v0,30
	syscall
	sub $a1,$a0,$t7
	sw $a1,timeHistory($a3)
	addi $a1,$a0,0
	
	li $v0,6
	sw $v0,historyControl($a3)
	addi $a2,$a2,1 
	jal UNTRACK
	li $a3,6
	beq $v1,$a3,point
	j consolog
go: 	
	sll $a3,$a2,2
	
	addi $t7,$a1,0
	li $v0,30
	syscall
	sub $a1,$a0,$t7
	sw $a1,timeHistory($a3)
	addi $a1,$a0,0
	
	li $v0,1
	sw $v0,historyControl($a3)
	addi $a2,$a2,1
	jal GO
	li $a3,1
	beq $v1,$a3,point
	j consolog
stop:
	sll $a3,$a2,2
	
	addi $t7,$a1,0
	li $v0,30
	syscall
	sub $a1,$a0,$t7
	sw $a1,timeHistory($a3)
	addi $a1,$a0,0

	li $v0,2
	sw $v0,historyControl($a3)
	addi $a2,$a2,1 	
	jal STOP
	li $a3,2
	beq $v1,$a3,point
	j consolog
right:
	sll $a3,$a2,2
	
	addi $t7,$a1,0
	li $v0,30
	syscall
	sub $a1,$a0,$t7
	sw $a1,timeHistory($a3)
	addi $a1,$a0,0
	
	li $v0,4
	sw $v0,historyControl($a3)
	addi $a2,$a2,1
	#------------------------------
	addi $sp,$sp,4
	sw $s5, 0($sp)
	addi $sp,$sp,4
	sw $s6, 0($sp)
	#restore
	la $s5, nowState
	lw $s6, 0($s5)	#$s6 is state at now
	addi $s6, $s6, 90 #increase state by 90*
	sw $s6, 0($s5) # update nowState
	#restore
	lw $s6, 0($sp)
	addi $sp,$sp,-4
	lw $s5, 0($sp)
	addi $sp,$sp,-4
	
	jal saveHistory
	jal NAVIGATE
	li $a3,4
	beq $v1,$a3,point
	j consolog
left:	
	sll $a3,$a2,2
	
	addi $t7,$a1,0
	li $v0,30
	syscall
	sub $a1,$a0,$t7
	sw $a1,timeHistory($a3)
	addi $a1,$a0,0
	
	li $v0,3
	sw $v0,historyControl($a3)
	addi $a2,$a2,1
	#-------------------------------
	addi $sp,$sp,4
	sw $s5, 0($sp)
	addi $sp,$sp,4
	sw $s6, 0($sp)
	#processing
	la $s5, nowState
	lw $s6, 0($s5)	#$s6 is state at now
	addi $s6, $s6, -90 #increase state by 90*
	sw $s6, 0($s5) # update nowState
	#restore
	lw $s6, 0($sp)
	addi $sp,$sp,-4
	lw $s5, 0($sp)
	addi $sp,$sp,-4
	
	jal saveHistory
	jal NAVIGATE
	li $a3,3
	beq $v1,$a3,point
	j consolog						
remove:
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
	la $s2, lengthInputCode
	lw $t3, 0($s2)					#$t3 = lengthInputCode
	addi $t1, $zero, -1				#$t1 = -1 = i
	addi $t2, $zero, 0				#$t2 = '\0'
	la $s1, inputCode
	addi $s1, $s1, -1
	for_loop_to_remove:
		addi $t1, $t1, 1			#i++
		add $s1, $s1, 1				#$s1 = inputCode + i
		sb $t2, 0($s1)				#inputCode[i] = '\0'	
		bne $t1, $t3, for_loop_to_remove	#if $t1 <=3 continue loop
		nop
		bne $t1, $t3, for_loop_to_remove
		
	add $t3, $zero, $zero			
	sw $t3, 0($s2)					#lengthInputCode = 0
		
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
	jr $ra			
checkCase:
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
	la $s1, inputCode			
	loopStringCheck:          # check cho den khi phat hien 1 ky ty khac
		addi $t1, $t1, 1			
		add $t2, $s1, $t1			
		lb $t2, 0($t2)				
		add $t3, $s3, $t1			
		lb $t3, 0($t3)				
		bne $t2, $t3, falseCase
		bne $t1, 2, loopStringCheck	
		nop
		bne $t1, 2, loopStringCheck
trueCase:
	lw $t3, 0($sp) # gan lai cac gia tri truoc da save o truoc
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	li $t0,1 #return true false bang $t0
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
consologError:
	li $v0, 4
	la $a0, inputCode
	syscall
	nop
	li $v0, 4
	la $a0, Error
	syscall
	nop
	nop
	j continue
	nop
	j continue				
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
UNTRACK:#backup
	addi $sp,$sp,4
	sw $at,0($sp)
	#processing
	li $at, LEAVETRACK # change LEAVETRACK port to 0
 	sb $zero, 0($at) # to stop drawing tail
	lw $at, 0($sp) #save du lieu sau khi jal
	addi $sp,$sp,-4
 	jr $ra
	nop
	jr $ra
NAVIGATE: 
	#backup
	addi $sp,$sp,4
	sw $t1,0($sp)
	addi $sp,$sp,4
	sw $t2,0($sp)
	addi $sp,$sp,4
	sw $t3,0($sp)
	#processing
	li $t1, STATE # change STATE port
	la $t2, nowState
	lw $t3, 0($t2)	#$t3 is heading at now
 	sw $t3, 0($t1) # to navigate robot
 	#restore
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
	li $t1, HEXA_KEYBOARD_IN
	li $t2, HEXA_KEYBOARD_OUT
scan_row1:
	li $t3, 0x81
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_char
scan_row2:
	li $t3, 0x82
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_char
scan_row3:
	li $t3, 0x84
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_char
scan_row4:
	li $t3, 0x88
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_char
get_char:
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
	j saveCode
case_1:	li $s0, '1'
	j saveCode
case_2:	li $s0, '2'
	j saveCode
case_3:	li $s0, '3'
	j saveCode
case_4:	li $s0, '4'
	j saveCode
case_5:	li $s0, '5'
	j saveCode
case_6:	li $s0, '6'
	j saveCode
case_7:	li $s0, '7'
	j saveCode
case_8:	li $s0, '8'
	j saveCode
case_9:	li $s0, '9'
	j saveCode
case_a:	li $s0, 'a'
	j saveCode
case_b:	li $s0, 'b'
	j saveCode
case_c:	li $s0, 'c'
	j saveCode
case_d:	li $s0, 'd'
	j saveCode
case_e:	li $s0,	'e'
	j saveCode
case_f:	li $s0, 'f'
	j saveCode
saveCode:
	la $s1, inputCode
	la $s2, lengthInputCode
	lw $s3, 0($s2)				#$s3 = strlen(inputCode)
	addi $t4, $t4, -1 			#$t4 = i 
	forLoopSaveCode:
		addi $t4, $t4, 1
		bne $t4, $s3, forLoopSaveCode
		add $s1, $s1, $t4		#$s1 = inputCode + i
		sb  $s0, 0($s1)			#inputCode[i] = $s0
		
		addi $s0, $zero, '\n'		#add '\n' character to end of string
		addi $s1, $s1, 1		#add '\n' character to end of string
		sb  $s0, 0($s1)			#add '\n' character to end of string
		
		
		addi $s3, $s3, 1
		sw $s3, 0($s2)			#update length of input code
		
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
