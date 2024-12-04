# Mars bot
.eqv HEADING 0xffff8010 
.eqv LEAVETRACK 0xffff8020
.eqv WHEREX 0xffff8030
.eqv WHEREY 0xffff8040
.eqv MOVING 0xffff8050

# Key matrix
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012

.data
# postscript-DCE -> enter 0
# (motion angle, 0=untrack | 1=track,;)
pscript1: .asciiz "90,0,1000,180,0,3000,180,1,6000,80,1,2000,40,1,2000,0,1,2000,320,1,2000,280,1,2000,90,0,8000,270,1,2000,210,1,2000,180,1,2000,150,1,2000,90,1,2000,90,0,5000,270,1,3000,0,1,5800,90,1,3000,180,0,3000,270,1,3000,"
# postscript- Dung -> enter 4
pscript2: .asciiz "90,0,1000,180,0,3000,180,1,6000,80,1,2000,40,1,2000,0,1,2000,320,1,2000,280,1,2000,90,0,5000,180,1,5700,90,1,3000,0,1,5700,90,0,2000,180,1,5700,0,0,5700,135,1,8000,0,1,5700,90,0,5000,270,1,2000,210,1,2000,180,1,2000,150,1,2000,90,1,2000,0,1,2000,270,0,500,90,1,1000,"
# postscript- Duc -> enter 8
pscript3: .asciiz "90,0,1000,180,0,3000,180,1,6000,80,1,2000,40,1,2000,0,1,2000,320,1,2000,280,1,2000,90,0,5000,180,1,5700,90,1,3000,0,1,5700,90,0,5000,270,1,2000,210,1,2000,180,1,2000,150,1,2000,90,1,2000,"
.text
# Key Matrix
	li $s1, IN_ADRESS_HEXA_KEYBOARD
	li $s2, OUT_ADRESS_HEXA_KEYBOARD
SELECT: 
	li $t4, 0x01 		# dong 1 cua key matrix
	sb $t4, 0($s1) 
	lb $a0, 0($s2) 
	bne $a0, 0x11, NOT_0
	la $a1, pscript1
	j START
	NOT_0:
	li $t4, 0x02 		# dong 2 cua key matrix
	sb $t4, 0($s1)
	lb $a0, 0($s2)
	bne $a0, 0x12, NOT_4
	la $a1, pscript2
	j START
	NOT_4:
	li $t4, 0x04 		# dong 3 cua key matrix
	sb $t4, 0($s1)
	lb $a0, 0($s2)
	bne $a0, 0x14, BACK
	la $a1, pscript3
	j START
BACK: j SELECT 		# Vong lap cho den khi chon dung 1 trong 3 so 0, 4, 8
# end

# xu li mars bot 
START:
	jal GO
READ_PSCRIPT: 
	addi $t1, $zero, 0 # luu gia tri goc chuyen dong
	addi $t2, $zero, 0 # luu gia tri thoi gian
	addi $t3, $zero, 0 # luu gia tri track 
	
 	READ_ROTATE:
 	add $t7, $a1, $t6 
	lb $t4, 0($t7)  		# doc 1 ki tu cua pscript
	beq $t4, 0, END 		# ket thuc pscript
 	beq $t4, 44, READ_ROTATE1 	# gap ki tu ','
 	mul $t1, $t1, 10 
 	addi $t4, $t4, -48 		# So 0-9 co thu tu 48-57 trong bang ascii.
 	add $t1, $t1, $t4 		# cong cac chu so lai voi nhau-> goc can quay
 	addi $t6, $t6, 1 		# tang vi tri ki tu can doc them 1
 	j READ_ROTATE 			# quay lai doc tiep den khi gap dau ','
 	
 	READ_ROTATE1:
 	add $a0, $t1, $zero
	jal ROTATE
 	
 	READ_TRACK:			# doc xem co track khong
 	addi $t6, $t6, 1 
 	add $t7, $a1, $t6
	lb $t4, 0($t7) 
 	addi $t4, $t4, -48
 	add $t3, $zero, $t4
 	addi $t6, $t6, 1
 	
 	READ_TIME: 			# doc thoi gian chuyen dong.
 	addi $t6, $t6, 1
 	add $t7, $a1, $t6 
	lb $t4, 0($t7) 
	beq $t4, 44, RUN_TRACK
	mul $t2, $t2, 10
 	addi $t4, $t4, -48
 	add $t2, $t2, $t4
 	j READ_TIME 			# quay lai doc tiep den khi gap dau ','
 	
 	RUN_TRACK:
 	addi $v0,$zero,32	 	# thoi gian marbot track = $t2
 	add $a0, $zero, $t2
 	beq $t3, $zero, CHECK_UNTRACK 	# 1=track | 0=untrack
 	jal UNTRACK
	jal TRACK
	j INCREAMENT
	
CHECK_UNTRACK:
	jal UNTRACK
INCREAMENT:
	syscall
 	addi $t6, $t6, 1		# bo qua dau ','
 	j READ_PSCRIPT

GO: 
 	li $at, MOVING 
 	addi $k0, $zero,1 
 	sb $k0, 0($at) 
 	jr $ra

STOP: 
	li $at, MOVING 
 	sb $zero, 0($at)
 	jr $ra

TRACK: 
	li $at, LEAVETRACK 
 	addi $k0, $zero,1 
	sb $k0, 0($at) 
 	jr $ra

UNTRACK:
	li $at, LEAVETRACK 
 	sb $zero, 0($at) 
 	jr $ra

ROTATE: 
	li $at, HEADING 
 	sw $a0, 0($at) 
 	jr $ra
END:
	jal STOP
	li $v0, 10
	syscall
	j SELECT
# end
