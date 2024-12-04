.eqv HEADING 0xffff8010 # Integer: An angle between 0 and 359
# 0 : North (up)
# 90: East (right)
# 180: South (down)
# 270: West (left)
.eqv MOVING 0xffff8050 # Boolean: whether or not to move
.eqv LEAVETRACK 0xffff8020 # Boolean (0 or non-0):
# whether or not to leave a track
.eqv WHEREX 0xffff8030 # Integer: Current x-location ofMarsBot
.eqv WHEREY 0xffff8040 # Integer: Current y-location of
.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014
.data 
Postscript1:	180,0,2000, 90,0,1000, 180,1,10000, 75,1,2500, 50,1,2500, 25,1,2500, 0,1,2000 325,1,2500, 300,1,2500 275,1,1900, 90,0,12000, 250,1,2800, 200,1,4000, 160,1,4000, 110,1, 2800 ,90,0,6000, 270,1,2500, 0,1,10000, 90,1,2500, 180,0,5000, 270,1,2500
end_post1:  -1
Postscript2:	180,0,2000, 90,0,1000, 180,1,5000, 0,0,5000, 135,1,2500, 45,1,2500, 180,1,5000, 90,0,2000, 0,1,5000, 90,0,2000, 180,1,5000, 0,0,5000, 135,1,7000, 0,1,5000, 90,0,2000, 180,1,5000, 90,0,3000, 0,1,5000, 180,0,2500, 270,1,3000
end_post2:  -1
Postscript3:	180,0,2000, 90,0,1000, 180,1,5000, 90,1,2000, 45,1,1000, 0,0,1000, 90,0,1000, 270,1,2000, 90,0,1000, 180,1,2000, 0,0,5500, 270,1,2500, 90,0,5000, 180,1,5000, 90,0,1000, 15,1,6000, 165,1,6000, 345,0,3000, 270,1,1500, 0,0,2500, 90,0,3000, 180,1,5000, 0,0,5000, 150,1,5500, 0,1,5000, 90,0,1000, 180,1,5000, 90,1,2000, 45,1,1000, 0,0,1000, 90,0,1000, 270,1,2000, 90,0,1000, 180,1,2000, 0,0,5500, 270,1,2500
end_post3:  -1
message: .asciiz "Hay lua chon hinh dang muon cut bang cach bam phim 0, 4, 8\n"

.text
main: 		
check_post: 	li $t1, IN_ADRESS_HEXA_KEYBOARD
		li $t2, OUT_ADRESS_HEXA_KEYBOARD
polling: 	li $t3, 0x1 # check row 1 with key 0, 1, 2, 3
		sb $t3, 0($t1) # must reassign expected row
		lb $a0, 0($t2) # read scan code of key button
		li $t3, 0x2 # check row 2 with key 4, 5, 6, 7
		sb $t3, 0($t1) # must reassign expected row
		lb $a1, 0($t2) # read scan code of key button
		li $t3, 0x4 # check row 3 with key 8, 9, a, b
		sb $t3, 0($t1) # must reassign expected row
		lb $a2, 0($t2) # read scan code of key button
		beq $a0, 0x11, post1 
		beq $a1, 0x12, post2 
		beq $a2, 0x14, post3 
		j no_choice
post1:		la $t1, Postscript1 #luu phuong thuc cat DCE trong t1
		j CNC
post2:		la $t1, Postscript2 #luu phuong thuc cat MINH trong t1
		j CNC
post3:		la $t1, Postscript3 #luu phuong thuc cat GIANG trong t1
		j CNC	
no_choice: 	li $v0, 4
		la $a0, message
		syscall
sleep: 		li $a0, 100 # sleep 100ms
		li $v0, 32
		syscall
back_to_polling: j polling # continue polling
CNC:		jal GO			#start mars bot
		nop
CUT: 		lw $a0, ($t1) 		#load heading
		slt $t2, $a0, $zero 	# neu a0<0 thi ket thuc
		bne $t2, $zero, end_main
		add $t1, $t1, 4		#doc thong so tiep theo cuar postscript
		jal ROTATE
		nop
		lw $a0, ($t1)		#load track or not
		add $t1, $t1, 4
		beq $a0, $zero, UNTRACKING	#neu khong cat thi nhay den untracking
		jal TRACK
		nop
	 	lw $a0, ($t1)		#load time sleep
	 	add $t1, $t1, 4		#doc thong so tiep theo cuar postscript
		addi $v0,$zero,32  	# Keep running by sleeping time in a0
		syscall
		jal UNTRACK
		nop
		j CUT			#tiep tuc qua trinh chay may CNC
		nop
UNTRACKING:	lw $a0, ($t1)		#load time sleep
		add $t1, $t1, 4		#doc thong so tiep theo cuar postscript
		addi $v0,$zero,32  	# Keep running by sleeping time in a0
		syscall
		j CUT			#tiep tuc qua trinh chay may CNC
		nop
end_main:	jal STOP		#dung mars bot
		nop
		li $v0, 10
		syscall
#-----------------------------------------------------------
# GO procedure, to start running
# param[in] none
#-----------------------------------------------------------
GO: li $at, MOVING # change MOVING port
addi $k0, $zero,1 # to logic 1,
sb $k0, 0($at) # to start running
nop
jr $ra
nop
#-----------------------------------------------------------
# STOP procedure, to stop running
# param[in] none
#-----------------------------------------------------------Ha Noi University of Science and Technology

STOP: li $at, MOVING # change MOVING port to 0
sb $zero, 0($at) # to stop
nop
jr $ra
nop
#-----------------------------------------------------------
# TRACK procedure, to start drawing line
# param[in] none
#-----------------------------------------------------------
TRACK: li $at, LEAVETRACK # change LEAVETRACK port
addi $k0, $zero,1 # to logic 1,
sb $k0, 0($at) # to start tracking
nop
jr $ra
nop
#-----------------------------------------------------------
# UNTRACK procedure, to stop drawing line
# param[in] none
#-----------------------------------------------------------
UNTRACK:li $at, LEAVETRACK # change LEAVETRACK port to 0
sb $zero, 0($at) # to stop drawing tail
nop
jr $ra
nop
#-----------------------------------------------------------
# ROTATE procedure, to rotate the robot
# param[in] $a0, An angle between 0 and 359
# 0 : North (up)
# 90: East (right)
# 180: South (down)
# 270: West (left)
#-----------------------------------------------------------
ROTATE: li $at, HEADING # change HEADING port
sw $a0, 0($at) # to rotate robot
nop
jr $ra
nop
