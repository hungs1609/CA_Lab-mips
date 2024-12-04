.eqv HEADING 0xffff8010 
.eqv MOVING 0xffff8050
.eqv LEAVETRACK 0xffff8020
.eqv WHEREX 0xffff8030
.eqv WHEREY 0xffff8040

.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012

.data
pscript1: .word 90,0,2000,180,0,3000,180,1,10000, 90,1,2500, 45,1,3520, 0,1,5000, 315,1,3520, 270,1,2500, 90,0,15000,  270,1,2500, 225,1,3520, 180,1,5000, 135,1,3520, 90,1,2500, 90,0,10000,  270,1,5000, 0,1,10000, 90,1,5000, 180,0,5000, 270,1,5000, 90,0,10000
pscript1_end: .word #DCE
pscript2: .word 90,0,2000,180,0,13000, 0,1,10000, 143,1,12500, 0,1,10000, 90,0,8000, 206,1,11180, 26,0,11180, 154,1,11180, 334,0,5590, 270,1,4900, 90,0,4900, 334,0,5590, 90,0,10000,  180,1,5000, 135,1,7071, 45,1,7071, 0,1,5000,  90,0,10000
pscript2_end: .word #NAV
pscript3: .word 90,0,2000,180,0,3000, 180,1,10000, 90,1,2500, 45,1,3520, 0,1,5000, 315,1,3520, 270,1,2500, 90,0,10000, 180,0,10000, 0,1,10000, 143,1,12500, 0,1,10000, 90,0,6000,  180,1,10000, 90,1,2500, 45,1,3520, 315,1,3520, 270,1,2500, 90,0,2500, 45,1,3520, 315,1,3520, 270,1,2500, 90,0,10000
pscript3_end: .word #DNB

.text
	li $t3, IN_ADRESS_HEXA_KEYBOARD
	li $t4, OUT_ADRESS_HEXA_KEYBOARD
GET_INPUT: 
	li $t5, 0x1 
	sb $t5, 0($t3) 
	lb $a0, 0($t4) 
	bne $a0, 0x11, NOT_0 # kiem tra xem co phai phim 0 khong
	la $a1, pscript1
	la $a2, pscript1_end
	j INIT
	NOT_0:
	li $t5, 0x2 
	sb $t5, 0($t3)
	lb $a0, 0($t4)
	bne $a0, 0x12, NOT_4 # kiem tra xem co phai phim 4 khong
	la $a1, pscript2
	la $a2, pscript2_end
	j INIT
	NOT_4:
	li $t5, 0x4 
	sb $t5, 0($t3)
	lb $a0, 0($t4)
	bne $a0, 0x14, LOOP # kiem tra xem co phai phim 8 khong
	la $a1, pscript3
	la $a2, pscript3_end
	j INIT
LOOP: j GET_INPUT # Neu cac phim 0, 4, 8 khong duoc nhan thi quay lai doc tiep

INIT:
	li $t0, -3 # i
	jal GO
PSCRIPT_TRAVERSAL:
	
	# rotate
	addi $t0, $t0, 3
	sll $t1, $t0, 2
	add $t2, $a1, $t1
	lw $t3, 0($t2) # pscript i
	add $a0, $zero, $t3
	jal ROTATE
	
	# lay track
	addi $t2, $t2, 4
	lw $t3, 0($t2)
	beq $t3, $zero, NO_CUT
	jal UNTRACK
	jal TRACK # and draw new track line
	NO_CUT:
	# lay time
	addi $t2, $t2, 4
	lw $t3, 0($t2)
	
SLEEP: 
	addi $v0,$zero,32 # Keep running by sleeping
	add $a0, $zero, $t3
	syscall
	jal UNTRACK # keep old track
	addi $t2, $t2, 4
	bne $t2, $a2, PSCRIPT_TRAVERSAL
END: 
	jal STOP
	li $v0, 10
	syscall		


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
