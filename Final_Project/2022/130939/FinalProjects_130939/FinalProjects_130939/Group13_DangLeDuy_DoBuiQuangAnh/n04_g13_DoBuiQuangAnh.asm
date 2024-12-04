.eqv HEADING 0xffff8010 
.eqv MOVING 0xffff8050
.eqv LEAVETRACK 0xffff8020
.eqv IN_KEYBOARD 0xFFFF0012
.eqv OUT_KEYBOARD 0xFFFF0014

.data
# DCE
script1: .word  90,2000,0,180,3000,0,180,5790,1,80,500,1,70,500,1,60,500,1,50,500,1,40,500,1,30,500,1,20,500,1,10,500,1,0,500,1,350,500,1,340,500,1,330,500,1,320,500,1,310,500,1,300,500,1,290,500,1,280,490,1,90,2000,0,90,4500,0,270,500,1,260,500,1,250,500,1,240,500,1,230,500,1,220,500,1,210,500,1,200,500,1,190,500,1,180,500,1,170,500,1,160,500,1,150,500,1,140,500,1,130,500,1,120,500,1,110,500,1,100,500,1,90,900,1,90,4500,0,270,2000,1,0,5800,1,90,2000,1,180,2900,0,270,2000,1,90,3000,0
zero1: .word
# Nguoi que
script2: .word  146,3605,0,0,0,1,4,174,1,15,174,1,24,174,1,35,174,1,45,174,1,54,174,1,65,174,1,74,174,1,84,174,1,94,174,1,105,174,1,114,174,1,125,174,1,135,174,1,145,174,1,155,174,1,164,174,1,175,174,1,184,174,1,194,174,1,204,174,1,215,174,1,225,174,1,235,174,1,245,174,1,254,174,1,265,174,1,274,174,1,284,174,1,294,174,1,305,174,1,315,174,1,324,174,1,335,174,1,345,174,1,355,174,1,135,1414,0,180,4000,1,0,4000,0,225,1414,1,180,1000,1,26,2236,0,135,1414,1,180,1000,1,206,2236,0,225,1414,1,180,1000,1,26,2236,0,135,1414,1,180,1000,1
zero2: .word
# Chan dung thay Le Ba Vui
script3: .word  167,8102,0,336,2284,1,29,4837,1,83,2716,1,102,2765,1,142,3420,1,184,3612,1,334,4965,1,260,5474,1,199,3511,1,174,3014,1,149,3498,1,110,2563,1,69,2563,1,23,2954,1,11,3059,1,270,6600,0,90,1200,1,90,2400,0,90,1200,1,248,3231,0,180,1500,1,108,948,1,63,670,1,0,1500,1,221,3612,0,108,948,1,90,900,1,75,1236,1
zero3: .word

.text
main:
	jal	choose
	nop
	jal	draw
	nop
	jal	quit
	nop
choose: 
	li 	$t3, IN_KEYBOARD
	li 	$t4, OUT_KEYBOARD
	addi 	$t6, $zero, 0 # Su dung de loop qua mang
	addi 	$t7, $zero, 0
	NUM_0:
		li 	$t5, 0x01
		sb 	$t5, 0($t3) 
		lb 	$a0, 0($t4) 
		bne 	$a0, 0x11, NUM_4
		nop
		la	$a1, script1
		la	$a2, zero1
		jr	$ra
	NUM_4:
		li 	$t5, 0x02
		sb 	$t5, 0($t3)
		lb 	$a0, 0($t4)
		bne	$a0, 0x12, NUM_8
		nop
		la 	$a1, script2
		la	$a2, zero2
		jr	$ra
	NUM_8:
		li 	$t5, 0X04
		sb 	$t5, 0($t3)
		lb 	$a0, 0($t4)
		bne 	$a0, 0x14, main
		nop
		la	$a1, script3
		la	$a2, zero3
		jr	$ra

draw:
	li 	$at, MOVING 
 	addi 	$k0, $zero,1 
 	sb 	$k0, 0($at) 
readPath:
	nextPath: 
		addi	$t0, $zero, 0
		addi	$t1, $zero, 0
 		angle:		# Extract goc di chuyen
 			sll	$t0, $t6, 2
 			add 	$t7, $a1, $t0
			lw 	$t5, 0($t7)
			add 	$a0, $t5, $zero
			jal 	ROTATE
 			nop
 		distance:
 			addi	$t6, $t6, 1
 			sll	$t0, $t6, 2
 			add 	$t7, $a1, $t0
			lw 	$t5, 0($t7) 
			add 	$t1, $zero, $t5
 		willCut:	# Lay boolean xet co cat hay khong
 			jal 	UNTRACK			# Set the previous point
 			nop
 			addi 	$t6, $t6, 1
 			sll	$t0, $t6, 2
 			add 	$t7, $a1, $t0
			lw 	$t5, 0($t7)
 			beq 	$t5, 1, cut
 			nop
 			j   	noCut 
 			nop
 	cut:
		jal	TRACK		# Cho track tuong duong voi cat
		nop
		j	SLEEP
		nop
	noCut:
		jal UNTRACK		# Bo track tuong duong voi khong cat
		nop
		j	SLEEP
		nop
	TRACK: 
		li 	$at, LEAVETRACK #  Dat LEAVETRACK = 1 de ve track
		li 	$k0, 1
		sb 	$k0, 0($at) 
 		jr 	$ra

	UNTRACK:
		li 	$at, LEAVETRACK #  Dat LEAVETRACK = 0 de khong ve track
 		sb 	$0, 0($at) 
 		jr 	$ra

	ROTATE: 
		li 	$at, HEADING 	# Dat HEADING la goc trong a0
 		sw 	$a0, 0($at) 
 		jr 	$ra
	SLEEP:
		li	$v0, 32 	
 		move 	$a0, $t1	# Ngu de cho Marsbot cat trong khoang thoi gian $t1
		syscall
 		addi 	$t6, $t6, 1
 		sll	$t0, $t6, 2
		add 	$t7, $a1, $t0
		bne	$t7, $a2, draw	# Sau khi ket thuc 1 net, quay lai ve tiep, tru khi gap end
	END: 
		li 	$at, MOVING	# Dat dia chi MOVING thanh 0 va ket thuc
 		sb 	$0, 0($at)
 		add	$at, $zero, 0
 		
quit:
	li 	$v0, 10
	syscall
