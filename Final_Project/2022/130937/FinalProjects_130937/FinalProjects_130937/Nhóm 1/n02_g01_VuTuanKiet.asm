.eqv 	MONITOR_SCREEN 	0x10010000
.eqv 	RED 		0x00FF0000
.eqv 	BLACK 		0x00000000

.eqv	KEY_CODE	0xFFFF0004	# ASCII code from keyboard, 1 byte 
.text
#-----------------------------------------------------------------------#
# main function: display circle in bitmap and move by MMIO Simulator 	#
# radius and center coordinates is given first				#
# screen: width 512px, height 512px. unit: width 1px, height 1px     	#
# [$k0]: screen							     	#
# [$to]: color to print					     	     	#
# [$s0]: x					     		     	#
# [$s1]: y 					       		     	#
#-----------------------------------------------------------------------#
main:
	li $k0, MONITOR_SCREEN			# load screen
	li $t0, RED				# load red color
	li $a2, KEY_CODE
	li $s0, 256				# init x in center screen: 256
	li $s1, 256				# init y in center screen: 256
	li $s4, 1				# distance move <=> speed
	jal print				# display circle
	j moving				# start moving
exit:
	li $v0, 10				# exit program
	syscall
endmain:
#----------------------------------------------------------------------	#
# print function: print circle in bitmap				#
# [$t1]: point x to print circle					#
# [$t2]: point y to print circle					#
# [$t9]: temp screen to print						#
# to access to current location: 4*(y*512+x)				#
# phase1: print fourth quadrant. Stop when point y == y			#
# phase2: print first quadrant. Stop when point y == stop y		#
# phase3: print second quadrant. Stop when point y == y			#
# phase4: print third quadrant. Stop when point y == stop y		#
#----------------------------------------------------------------------	#
print:
	sw $ra, 0($sp)
	add $t1, $s0, $0			# point x = Rx
	subi $t2, $s1, 32			# point y = Ry-32
	phase1:
		beq $t2, $s1, endphase1		# if point y == y stop
		sll $t9, $t2, 9			# y*512
		add $t9, $t9, $t1		# y*512+x
		sll $t9, $t9, 2			# 4*(y*512+x)
		add $t9, $t9, $k0		# access to screen
		sw $t0, 0($t9)			# print pixel
		
		addi $t2, $t2, 1		# point point y ++
		sub $t1, $t2, $s1		# point y-Ry
		mul $t1, $t1, $t1		# (point y-Ry)^2
		subi $t1, $t1, 1024		# (point y-Ry)^2-R^2
		sub $t1, $0, $t1		# R^2-(point y-Ry)^2
		jal square			# square(R^2-(point y-Ry)^2)
		add $t1, $t1, $s0		# point x=square(R^2-(point y-Ry)^2)+Rx
		
		j phase1
	endphase1:
	
	addi $t3, $s1, 32			# point to stop
	phase2:
		beq $t2, $t3, endphase2		# if tmp x == x stop
		sll $t9, $t2, 9			# y*512
		add $t9, $t9, $t1		# y*512+x
		sll $t9, $t9, 2			# 4*(y*512+x)
		add $t9, $t9, $k0		# access to screen
		sw $t0, 0($t9)			# print pixel
		
		addi $t2, $t2, 1		# point y ++
		sub $t1, $t2, $s1		# point y-Ry
		mul $t1, $t1, $t1		# (point y-Ry)^2
		subi $t1, $t1, 1024		# (point y-Ry)^2-R^2
		sub $t1, $0, $t1		# R^2-(point y-Ry)^2
		jal square			# square(R^2-(point y-Ry)^2)
		add $t1, $t1, $s0		# point x=square(R^2-(point y-Ry)^2)+Rx
		
		j phase2
	endphase2:
	
	
	phase3:
		beq $t2, $s1, endphase3		# if tmp y == y stop
		sll $t9, $t2, 9			# y*512
		add $t9, $t9, $t1		# y*512+x
		sll $t9, $t9, 2			# 4*(y*512+x)
		add $t9, $t9, $k0		# access to screen
		sw $t0, 0($t9)			# print pixel
		
		subi $t2, $t2, 1		# tmp y --
		sub $t1, $t2, $s1		# point y-Ry
		mul $t1, $t1, $t1		# (point y-Ry)^2
		subi $t1, $t1, 1024		# (point y-Ry)^2-R^2
		sub $t1, $0, $t1		# R^2-(point y-Ry)^2
		jal square			# square(R^2-(point y-Ry)^2)
		sub $t1, $t1, $s0		# square(R^2-(point y-Ry)^2)-Rx
		sub $t1, $0, $t1		# point x=Rx-square(R^2-(point y-Ry)^2)
		
		j phase3
	endphase3:
	
	
	subi $t3, $s1, 32			# point to stop
	phase4:
		beq $t2, $t3, endphase4		# if point y == stop y => stop
		sll $t9, $t2, 9			# y*512
		add $t9, $t9, $t1		# y*512+x
		sll $t9, $t9, 2			# 4*(y*512+x)
		add $t9, $t9, $k0		# access to screen
		sw $t0, 0($t9)			# print pixel
		subi $t2, $t2, 1		# tmp y --
		
		sub $t1, $t2, $s1		# point y-Ry
		mul $t1, $t1, $t1		# (point y-Ry)^2
		subi $t1, $t1, 1024		# (point y-Ry)^2-R^2
		sub $t1, $0, $t1		# R^2-(point y-Ry)^2
		jal square			# square(R^2-(point y-Ry)^2)
		sub $t1, $t1, $s0		# square(R^2-(point y-Ry)^2)-Rx
		sub $t1, $0, $t1		# point x=Rx-square(R^2-(point y-Ry)^2)
		
		j phase4
	endphase4:
	lw $ra, 0($sp)
	jr $ra
endprint:

#----------------------------------------------------------------------	#
# square root function: calculate square root of N			#
# [$t1]: value N to calculate						#
# [$t1]: result in integer after calculate				#
#----------------------------------------------------------------------	#

square:
	mtc1 $t1, $f0				# move content to float register
	cvt.d.w $f0, $f0			# convert to float
	sqrt.d $f0, $f0				# square root
	cvt.w.d $f0, $f0			# convert content to integer
	mfc1 $t1, $f0				# move content float after casting to integer register
	jr $ra
endsquare:

#----------------------------------------------------------------------	#
# moving: read keycode, move and change speed				#
# [$s3]: store keycode							#
# [$s4]: store speed = d							#
# [$t0]: store color to print						#
# read keycode: when keycode is read => do moving or change speed	#
#		then store keycode to the new keycode is read		#
# 		keycode = w => circle move left d
#		keycode = s => circle move down	d			#
#		keycode = a => circle move left	d			#
# 		keycode = d => circle move right d			#
#		keycode = z => speed up	=> speedx2			#
#		keycode = x => speed down => speed/2			#
#		keycode = e => exit					#
# speed is distance moving. init = 1					#
# speed includes 4 level: 1, 2, 4, 8					#
#----------------------------------------------------------------------	#

moving:
	ReadKey:
		lw $s3, 0($a2)				# load keycode from keyboard
		beq $s3, 119 ,UP			# w => up
		beq $s3, 115, DOWN			# s => down
		beq $s3, 97, LEFT			# a => left
		beq $s3, 100, RIGHT			# d => right
		beq $s3, 122, SPEEDUP			# z => speed up
		beq $s3, 120, SPEEDDOWN			# x => speed down
		beq $s3, 101, exit			# e => exit
		j ReadKey
	EndReadKey:
	
	UP:
		addi $s3, $0, 119			# set to up
		sw $s3, 0($a2)	
		blt $s1, 32, DOWN			# rebound to down if meet edge
		li $t0, BLACK				# print again circle with color of screen
		jal print
		li $a0, 0				# load time
		li $v0, 32				# delay
		syscall
		li $t0, RED				# load color RED
		sub $s1, $s1, $s4			# update new location
		jal print				# print new circle
		j ReadKey
	ENDUP:

	DOWN:
		addi $s3, $0, 115			# set to down
		sw $s3, 0($a2)
		bgt $s1, 480, UP			# rebound to up if meet edge
		li $t0, BLACK				# print again circle with color of screen
		jal print
		li $a0, 0				# load time
		li $v0, 32				# delay
		syscall
		li $t0, RED				# load color RED
		add $s1, $s1, $s4			# update new location
		jal print				# print new circle
		j ReadKey
	ENDDOWN:

	LEFT:
		addi $s3, $0, 97			# set to left
		sw $s3, 0($a2)
		blt $s0, 32, RIGHT			# rebound to right if meet edge
		li $t0, BLACK				# print again circle with color of screen
		jal print
		li $a0, 0				# load time
		li $v0, 32				# delay
		syscall
		li $t0, RED				# load color RED
		sub $s0, $s0, $s4			# update new location
		jal print				# print new circle
		j ReadKey
	ENDLEFT:

	RIGHT:
		addi $s3, $0, 100			# set to right
		sw $s3, 0($a2)
		bgt $s0, 480, LEFT			# rebound to left if meet edge
		li $t0, BLACK				# print again circle with color of screen
		jal print
		li $a0, 0				# load time
		li $v0, 32				# delay
		syscall
		li $t0, RED				# load color RED
		add $s0, $s0, $s4			# update new location
		jal print				# print new circle
		j ReadKey
	ENDRIGHT:

	SPEEDUP:
		sw $0, 0($a2)
		sll $s4, $s4, 1				# speed up x2
		bgt $s4, 8, UPDATEUP			# speed max=8
		j ReadKey
	ENDSPEEDUP:

	UPDATEUP:
		addi $s4, $0, 8				# set time delay=0
		j ReadKey
	ENDUPDATEUP:

	SPEEDDOWN:
		sw $0, 0($a2)
		srl $s4, $s4, 1				# speed down x2
		blt $s4, 1, UPDATEDOWN			# speed min=1
		j ReadKey
	ENDSPEEDDOWN:

	UPDATEDOWN:
		addi $s4, $0, 1			# set time delay=10
		j ReadKey
	ENDUPDATEDOWN:
endmoving:
