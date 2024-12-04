 .eqv KEY_CODE 0xFFFF0004  # ASCII code to show, 1 byte  
.data 
LEFT:	.asciiz "a" 
RIGHT : .asciiz "d" 
UP: 	.asciiz "w" 
DOWN: 	.asciiz "s" 

.text 
li $k0, KEY_CODE #Enter the key to direct ball

.eqv YELLOW 0x00FFFF00
.eqv MONITOR_SCREEN 0x10010000

.text
#Draw the circle at the center of screen 
# Center point is (x0, y0)
#s0 = x0
#s1 = y0
#s2 = color
#s3 = radius

li $v1, MONITOR_SCREEN
#Set the first value
	li $s0, 256 # set x_center point at center of screen
	li $s1, 256 # set y_center point at center of screen
	li $s3, 20 # value of radius
	li $s2, YELLOW
	li $s4, 1
	addi $s7, $0, 512  #save the large to $s7
	jal DrawCircle
	nop
#-------------------------------------------------------------------------------------------------------------------------------
MMove: #Moving the circle
    Readkey:
    	lw $t0, 0($k0)
	beq $t0, 97, left 	#$t0 = 'a'
	beq $t0, 100, right 	#$t0 = 'd'
	beq $t0, 115, down	#$t0 = 's'
	beq $t0, 119, up	#$t0 = 'w'
	beq $t0, 120, slow
	beq $t0, 122, speed
	j Readkey
    EndReadkey:
    		#----------------------------------------------------------------------------#
    left:
   	addi $t0, $0, 97
   	sw $t0, 0($k0)
   	bltu  $s0, 20, right # If go the the left margin, back right
   	li $s2, 0x00000000
   	jal DrawCircle
   	li $a0, 0
   	li $v0, 32
   	syscall
   	li $s2, YELLOW
   	sub $s0, $s0, $s4
   	jal DrawCircle
   	jal Readkey
   end_left:
   			#---------------------------------------------#
     right:
     	addi $t0, $0, 100
   	sw $t0, 0($k0)
   	bgtu  $s0, 492, left
   	li $s2, 0x00000000
   	jal DrawCircle
   	li $a0, 0
   	li $v0, 32
   	syscall
   	li $s2, YELLOW
   	add $s0, $s0, $s4
   	jal DrawCircle
   	jal Readkey
   end_right:
   			#---------------------------------------------#
   up:
   	addi $t0, $0, 119
   	sw $t0, 0($k0)
   	bltu  $s1, 20, down
   	li $s2, 0x00000000
   	jal DrawCircle
   	li $a0, 0
   	li $v0, 32
   	syscall
   	li $s2, YELLOW
   	sub $s1, $s1, $s4
   	jal DrawCircle
   	jal Readkey
   end_up:
   			#---------------------------------------------#
   down:
   	addi $t0, $0, 115
   	sw $t0, 0($k0)
   	bgtu $s1, 492, up
   	li $s2, 0x00000000
   	jal DrawCircle
   	li $a0, 0
   	li $v0, 32
   	syscall
   	li $s2, YELLOW
   	addu $s1, $s1, $s4
   	jal DrawCircle
   	jal Readkey
   end_down:
   			#---------------------------------------------#
   speed:
   	sw $0, 0($k0)
   	sll $s4, $s4, 1
   	bgt $s4, 8, update_speed
   	j Readkey
   end_speed:
   
   update_speed:
   	addi $s4, $0, 8
   	j Readkey
   end_update_speed:
   
   slow:
   	sw $0, 0($k0)
   	srl $s4, $s4, 1
   	blt $s4, 1, update_slow
   	j Readkey
   end_slow:
   
   update_slow:
   	addi $s4, $0, 1
   	j Readkey
   end_update_slow:
 end_MMove:
#------------------------------------------------------------------------------------------------------------
DrawCircle: #Using Midpoint Circle Algo
#CREATE STACK TO STRORE DATAL POINT, COLOR, ...
    	addi        $sp, $sp, -20       #Make room on stack for 1 words 
   	sw      $ra, 0($sp)     #Store $ra on element 0 of stack 
    	sw      $s0, 4($sp)     #Store $a0 on element 1 of stack 
    	sw      $s1, 8($sp)     #Store $a1 on element 2 of stack 
    	sw      $s2, 12($sp)        #Store $a2 on element 3 of stack 
    	sw      $s3, 16($sp)        #Store $a3 on element 4 of stack 
    	
    	#VARIABLES 
    	move    $t0, $s0            #x0 
    	move    $t1, $s1           #y0 
    	move    $t2, $s3         #radius 
    	addi    $t3, $t2, 0             #x 
    	li      $t4, 0              #y 

    	li      $t7, 0              #Err 

    	#While(x >= y)

circleLoop: 
    	blt         $t3, $t4, skipCircleLoop    #If x < y, skip circleLoop 
	#s5 = x, s6 = y 
	#Draw Dot (x0 + x, y0 + y) 
    	addu        $s5, $t0, $t3 
    	addu        $s6, $t1, $t4 
    	lw          $s2, 12($sp) 
    	jal         drawDot             #Jump to drawDot 
        #Draw Dot (x0 + y, y0 + x) 
        addu        $s5, $t0, $t4 
        addu        $s6, $t1, $t3 
        lw      $s2, 12($sp) 
        jal     drawDot             #Jump to drawDot 
        #Draw Dot (x0 - y, y0 + x) 
        subu        $s5, $t0, $t4 
        addu        $s6, $t1, $t3 
        lw      $s2, 12($sp) 
        jal     drawDot             #Jump to drawDot 
        #Draw Dot (x0 - x, y0 + y) 
        subu        $s5, $t0, $t3 
        addu        $s6, $t1, $t4 
        lw      $s2, 12($sp) 
        jal     drawDot             #Jump to drawDot 
        #Draw Dot (x0 - x, y0 - y) 
        subu        $s5, $t0, $t3 
        subu        $s6, $t1, $t4 
        lw      $s2, 12($sp) 
        jal     drawDot             #Jump to drawDot 
        #Draw Dot (x0 - y, y0 - x) 
        subu        $s5, $t0, $t4 
        subu        $s6, $t1, $t3 
        lw      $s2, 12($sp) 
        jal     drawDot             #Jump to drawDot 
        #Draw Dot (x0 + y, y0 - x) 
        addu        $s5, $t0, $t4 
        subu        $s6, $t1, $t3 
        lw      $a2, 12($sp) 
        jal     drawDot             #Jump to drawDot 
        #Draw Dot (x0 + x, y0 - y) 
        addu        $s5, $t0, $t3 
        subu        $s6, $t1, $t4 
        lw      $s2, 12($sp) 
        jal     drawDot             #Jump to drawDot 
    	#If (err <= 0) 
    	bgtz        $t7, doElse 
    	addi        $t4, $t4, 1     #y++ 
    	sll $t8, $t4, 1			#Bitshift y left 1	 
    	addi $t8, $t8, 1		#2y + 1 
    	addu $t7, $t7, $t8		#Add  e + (2y + 1) 
    	j       circleContinue      #Skip else stmt 

    	#Else If (err > 0) 
	doElse: 
    	addi        $t3, $t3, -1        #x--   	 
	sll $t8, $t3, 1			#Bitshift x left 1 
    	addi $t8, $t8, 1		#2x + 1 
    	subu $t7, $t7, $t8		#Subtract e - (2x + 1) 

j circleContinue 

circleContinue: 
    	#LOOP 
    	j       circleLoop 
   	#CONTINUE 
  	skipCircleLoop:      
    	#RESTORE $RA 
    	lw      $ra, 0($sp)     #Restore $ra from stack 
    	addiu        $sp, $sp, 20        #Readjust stack 
    	jr $ra 
    	nop 

drawDot: 
    	#li $a2, YELLOW 
    	add $at, $s6, $0 
    	sll     $at, $at, 9        # calculate offset in $at: at = y_pos * 512 
    	add     $at, $at, $s5       # at = y_pos * 512 + x_pos = "index" 
    	sll     $at, $at, 2         # at = (y_pos * 512 + x_pos)*4 = "offset" 
    	add     $at, $at, $v1       # at = v1 + offset 
    	sw      $s2, ($at)          # draw it! 
    	jr $ra 
	

	
	
