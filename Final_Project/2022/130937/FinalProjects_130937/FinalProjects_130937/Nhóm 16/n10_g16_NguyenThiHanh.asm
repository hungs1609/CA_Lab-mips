.data 
  welc:       	.asciiz "\n Welcome to Calculator MARS\n" 
  p_int:      	.asciiz "\n Enter the first 4 digit number.\n The first number is: "
  p_int1:     	.asciiz "\n Enter the second 4 digit number.\n The second number is: "
  p_toantu:   	.asciiz "\n Enter operator:\n Enter a to get the addition.\n Enter b to get the subtraction. \n Enter b to get the multiplication \n Enter b to get the division. \n Enter b to get the modulo.\n "
  ketqua:     	.asciiz "\n The result is:  "
  space:   	.asciiz " "
  err1:       	.asciiz "\n An error occurred. Please re-enter.\n"
  err2:		.asciiz "\n You entered division by 0.\n Please re-enter.\n"
  erram:      	.asciiz "\n The result is a negative number, which cannot be displayed on the LED.\n"
  sb_cong:   	.asciiz "\n You have entered addition. \n"
  sb_tru:     	.asciiz "\n You have entered subtraction. \n"
  sb_nhan:    	.asciiz "\n You have entered multiplication. \n"
  sb_chia:    	.asciiz "\n You have entered division. \n"
  sb_lay_du: 	.asciiz "\n You have entered modulo. \n"
  sb_daubang: 	.asciiz "\n Enter f to display the results. \n"
  rep:        	.asciiz "\n Enter 0 to exit the program. \n Enter a non-zero number to continue. \n "  
  goodbye:    	.asciiz "\n Goodbye\n"
  
.eqv ZERO                   63  		# Gia tri byte hien thi so 0 tren den LED
.eqv ONE                    6  			# Gia tri byte hien thi so 1 tren den LED
.eqv TWO                    91 			# Gia tri byte hien thi so 2 tren den LED
.eqv THREE                  79 			# Gia tri byte hien thi so 3 tren den LED
.eqv FOUR                   102  		# Gia tri byte hien thi so 4 tren den LED
.eqv FIVE                   109  		# Gia tri byte hien thi so 5 tren den LED
.eqv SIX                    125  		# Gia tri byte hien thi so 6 tren den LED
.eqv SEVEN                  7  			# Gia tri byte hien thi so 7 tren den LED 
.eqv EIGHT                  127  		# Gia tri byte hien thi so 8 tren den LED
.eqv NINE                   111  		# Gia tri byte hien thi so 9 tren den LED
.eqv IN_ADDRESS_HEXA_KEYBOARD   0xFFFF0012  	# chua byte dieu khien dong cua ban phim
.eqv OUT_ADDRESS_HEXA_KEYBOARD  0xFFFF0014  	# chua byte tra ve vi tri cua phim duoc bam
.eqv LEFT_LED            0xFFFF0010  		# chua byte dieu khien den led ben phai
.eqv RIGHT_LED          0xFFFF0011  		# chua byte dieu khien den led ben trai
.text 
main: 
start:
     		la $a0, welc
     		li $v0, 4     
     		syscall
     		la $a0, p_int
     		li $v0, 4     
     		syscall 
# Kich hoat interupt -----------------------------------------
		li $t1, IN_ADDRESS_HEXA_KEYBOARD   
  		li $t3, 0x80     	# Kich hoat interupt tu ban phim hexa
  		sb $t3, 0($t1)
# Khai bao bien ---------------------------------------------------
      		li $t6, 0      		# $t6: Bien gia tri so cua den LED trai
      		li $t7, 0      		# $t7: Bien gia tri so cua den LED phai
      		li $s1, 0      		# $s1: Gia tri lay ra
      		li $s2, 0      		# $s2: toan tu lay ra
      		li $s5, 0      		# $s5:  dau =
      		li $s3, 0 		# so thu nhat
      		li $s4, 0 		# so thu 2
      		li $s6, 0 		# bien dem s6
# Vong lap cho tin hieu interupt so thu nhat
Loop: 		beq $s6, 4, nhapso2		    
      		nop
      		beq $s6, 4, nhapso2
      		nop
      		beq $s6, 4, nhapso2
      		nop
		beq $s6, 4, nhapso2
      		j Loop  			#Wait for interrupt
      		beq $s6, 4, nhapso2
      		nop
      		beq $s6, 4, nhapso2
      		j Loop 
#----------------------------------------------------------------------
nhapso2:	add $s3, $s1, $0 # luu gia tri so thu nhat vao s3
    		add $s1, $0, $0 # reset s1
    		addi $s6, $0, 0 # reset bien dem s6
    		move $a0, $s3 
    		li $v0, 1
    		syscall 
    		li $t6, 0      # reset den led
    		li $t7, 0 
    		la $a0, p_int1
    		li $v0, 4
    		syscall
# VOng lap cho interupt so thu 2 -----------------------------
Loop1: 		beq $s6, 4, nhaptoantu
     		nop
     		beq $s6, 4, nhaptoantu
     		nop
     		beq $s6, 4, nhaptoantu
     		nop
		beq $s6, 4, nhaptoantu
     		b Loop1      #Wait for interrupt
     		beq $s6, 4, nhaptoantu
     		nop
		beq $s6, 4, nhaptoantu
     		b Loop1 
nhaptoantu:	add $s4, $s1, $0 # luu gia tri so thu hai vao s4
  		add $s1, $0, $0  # reset s1
  		addi $s6, $0, 0 # reset bien dem s6
  		la $a0, space
  		li $v0, 4     
  		syscall
   		move $a0, $s4  # in so thu 2
  		li $v0, 1
  		syscall 
  		li $t6, 0  # reset den led    
  		li $t7, 0 
  		la $a0, p_toantu
  		li $v0, 4
  		syscall
Loop2:		beq $s6, 1, nhaptoantu2
    		nop 
    		beq $s6, 1, nhaptoantu2
    		nop
    		beq $s6, 1, nhaptoantu2
    		nop
    		beq $s6, 1, nhaptoantu2	
    		b Loop2    #Wait for interrupt
    		beq $s6, 1, nhaptoantu2
    		nop
    		beq $s6, 1, nhaptoantu2	
    		b Loop2
nhaptoantu2:	add $a3, $0, $0
     		add $s1, $0, $0 # reset s1
     		addi $s6, $0, 0 # reset bien dem s6
cong1: 		bne $s2, 1, tru1
    		la $a0, sb_cong
		li $v0, 4     
  		syscall
  		j baonhapdaubang
tru1:  		bne $s2, 2, nhan1
   		la $a0, sb_tru
        	li $v0, 4     
        	syscall
        	j baonhapdaubang
nhan1: 		bne $s2, 3, chia1
        	la $a0, sb_nhan
        	li $v0, 4
        	syscall
        	j baonhapdaubang
chia1: 		bne $s2, 4, baonhapdaubang
        	la $a0, sb_chia
        	li $v0, 4     
        	syscall
        	j baonhapdaubang
laydu1:		bne $s2, 5, baonhapdaubang
        	la $a0, sb_lay_du
        	li $v0, 4     
        	syscall
        	j baonhapdaubang
baonhapdaubang:	la $a0, sb_daubang
  	        li $v0, 4     
                syscall
 
Loop3: 		beq $s5, 6, show
    		nop
    		beq $s5, 6, show
    		nop
    		beq $s5, 6, show
    		nop
    		beq $s5, 6, show
    		j Loop3    #Wait for interrupt
    		beq $s5, 6, show
    		nop
    		beq $s5, 6, show
    		j Loop3
show:
case_cong:  	bne $s2, 1, case_tru  # neu la phep cong
            	addu $s7, $s3, $s4 # thuc hien phep cong
            	la $a0, ketqua 
            	li $v0, 4     
            	syscall
            	move $a0, $s7 # in ket qua ra console 
            	li $v0, 1
            	syscall 
            	j showketqua
case_tru:   	bne $s2, 2, case_nhan
            	la $a0, ketqua
            	li $v0, 4     
            	syscall
            	sub $s7, $s3, $s4
            	move $a0, $s7
            	li $v0, 1
            	syscall 
            	j showketqua
case_nhan:  	bne $s2, 3, case_chia
            	la $a0, ketqua
            	li $v0, 4
            	syscall 
            	mul $s7, $s3, $s4
            	move $a0, $s7
           	li $v0, 1
            	syscall 
            	j showketqua
case_chia:  	bne $s2, 4, case_lay_du
	    	beq $s4, 0, chia_cho_0
            	la $a0, ketqua
            	li $v0, 4
            	syscall 
            	div $s7, $s3, $s4
            	move $a0, $s7
            	li $v0, 1
            	syscall 
       	    	j showketqua
case_lay_du: 	bne $s2, 5, pheptinhdf
	    	beq $s4, 0, chia_cho_0
	    	la $a0, ketqua
            	li $v0, 4
            	syscall 
            	div $s3, $s4
            	mfhi $a0
            	li $v0, 1
            	syscall 
       	    	j showketqua
       	    
chia_cho_0: 	la $a0, err2	# loi chia cho 0
	    	li $v0, 4
	    	syscall
	    	j showketqua
	    
pheptinhdf: 	la $a0, err1	# bao loi
  	    	li $v0, 4     
  	    	syscall
  	    	li $v0, 51
              	la $a0, rep
              	syscall
              	beq $a0, $0, END
              	nop
              	j start
              	nop
              	la $v0, 10
              	syscall

showketqua: 	li $t9, 0
            	li $t8, 0
            	slt $k1, $s7, $0 # kiem tra ket  qua la so am hay khong
            	bne $k1, $0, loisoam
            	div $t8, $s7, 10
            	mfhi $t9
            	beq $t8, 0, napgiatricholed
            	div $t8, $t8, 10
            	mfhi $t8
napgiatricholed: 
                li $t2, LEFT_LED   # hien thi den LED trai
                add $s0, $zero, $t9 # truyen bien left
                jal hienthi
                nop
                li $t2, RIGHT_LED  # hien thi den LED phai
                add $s0, $zero, $t8 # truyen bien right
                jal hienthi
                nop
                j endmain
endmain:
       		li $v0, 51
       		la $a0, rep
       		syscall
       		beq $a0, $0, END
       		nop
       		j start
       		nop
END:
      		la $a0, goodbye
      		li $v0, 4     
      		syscall
      		la $v0, 10   
      		syscall    
loisoam: 				# bao loi ket qua am
              	la $a0, erram
              	li $v0, 4     
              	syscall
              	li $v0, 51
              	la $a0, rep
              	syscall
              	beq $a0, $0, END
              	nop
              	j start
              	nop
              	la $v0, 10   
              	syscall         
hienthi:    
led_0:		bne $s0, 0, led_1  # case $s0 = 0
      		li $t4, ZERO
      		j napgiatri
led_1: 		bne $s0, 1, led_2  # case $s0 = 1
      		li $t4, ONE
      		j napgiatri
led_2: 		bne $s0, 2, led_3  # case $s0 = 2
      		li $t4, TWO
      		j napgiatri
led_3: 		bne $s0, 3, led_4  # case $s0 = 3
      		li $t4, THREE
      		j napgiatri
led_4: 		bne $s0, 4, led_5  # case $s0 = 4
      		li $t4, FOUR
      		j napgiatri
led_5: 		bne $s0, 5, led_6  # case $s0 = 5
      		li $t4, FIVE
      		j napgiatri
led_6: 		bne $s0, 6, led_7  # case $s0 = 6
      		li $t4, SIX
      		j napgiatri
led_7: 		bne $s0, 7, led_8  # case $s0 = 7
      		li $t4, SEVEN
      		j napgiatri
led_8: 		bne $s0, 8, led_9  # case $s0 = 8
      		li $t4, EIGHT
      		j napgiatri
led_9: 		bne $s0, 9, led_df # case $s0 = 9
      		li $t4, NINE
      		j napgiatri
led_df:  	jr $ra
napgiatri:    	sb $t4, 0($t2)
	      	jr $ra

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Xu ly khi xay ra interupt
# Hien thi so vua bam len den led 7 doan
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.ktext 0x80000180
  #--------------------------------------------------------------------------
  # SAVE the current REG FILE to stack
  #--------------------------------------------------------------------------
IntSR:		addi $sp, $sp, 4    # Save $ra because we may change it later
      		sw $ra, 0($sp)
      		addi $sp, $sp, 4    # Save $ra because we may change it later
      		sw  $at, 0($sp)
      		addi $sp, $sp, 4    # Save $ra because we may change it later
      		sw $v0, 0($sp)
      		addi $sp, $sp, 4    # Save $a0, because we may change it later
      		sw $a0, 0($sp)
      		addi $sp, $sp, 4    # Save $t1, because we may change it later
      		sw $t1, 0($sp)
      		addi $sp, $sp, 4    # Save $t3, because we may change it later
      		sw $t3, 0($sp)
      		addi $sp, $sp, 4 
      		sw $s6, 0($sp)
  # ----------------------------------------------------------------------
  # Processing
  # ----------------------------------------------------------------------
      		addi $s6, $s6, 1
      		jal getInt1
      		nop
      		jal getInt2
      		nop
      		jal getInt3
      		nop
     		jal getInt4
      		nop
next_pc:    	mfc0 $at, $14    # $at <= Copro0.$14 = Coproc0.epc
      		addi $at, $at, 4    # $at = $at + 4
      		mtc0 $at, $14    #Coproc0.$14 = Coproc0.epc <= $at
  #-----------------------------------------------------------------------
  #-----------------------------------------------------------------------
  # RESTORE the REG FILE from STACK
  #-----------------------------------------------------------------------
restore:
      		lw $t3, 0($sp)
      		addi $sp, $sp, -4
      		lw $t1, 0($sp)
      		addi $sp, $sp, -4
      		lw $a0, 0($sp)
      		addi $sp, $sp, -4
      		lw $v0, 0($sp)
      		addi $sp, $sp, -4
      		lw $ra, 0($sp)
      		addi $sp, $sp, -4
      		lw $t4, 0($sp)
      		addi $sp, $sp, -4
back_main:  	eret
  #------------------------------------------------------------------------
  # Thu tuc quet cac phim o hang 1 va xu ly
  # Tham so truyen vao: 
  # Tra ve:
  #------------------------------------------------------------------------
getInt1: 	addi $sp, $sp, 4
      		sw $ra, 0($sp) 
      		li $t1, IN_ADDRESS_HEXA_KEYBOARD
      		li $t3, 0x81     # Kich hoat interrupt, cho phep bam phim o hang 1
      		sb $t3, 0($t1)
      		li $t1, OUT_ADDRESS_HEXA_KEYBOARD
      		lb $t3, 0($t1)   # Nhan byte the hien vi tri cua phim duoc bam trong hang 1
case_0:   	li $t5, 0x11
      		bne $t3, $t5, case_1  # case 0x11
      		addi $t7, $t6, 0    # left=right
      		addi $t6, $zero, 0  # left = 0
      		mul $s1, $s1, 10
      		add $s1, $s1, $t6   # factor=factor*10+left
      		j show1
case_1:   	li $t5, 0x21
      		bne $t3, $t5, case_2  # case 0x21
      		addi $t7, $t6, 0    # left=right
      		addi $t6, $zero, 1  # left = 1
      		mul $s1, $s1, 10
      		add $s1, $s1, $t6 # factor=factor*10+left
      		j show1
case_2:   	li $t5, 0x41
      		bne $t3, $t5, case_3  # case 0x41
      		addi $t7, $t6, 0    # left=right
      		addi $t6, $zero, 2  # left = 2
      		mul $s1, $s1, 10
      		add $s1, $s1, $t6 # factor=factor*10+left
      		j show1
case_3:   	li $t5, 0xffffff81
      		bne $t3, $t5, case_default1  # case 0xffffff81
      		addi $t7, $t6, 0    # left=right
      		addi $t6, $zero, 3  # left = 3
      		mul $s1, $s1, 10
      		add $s1, $s1, $t6 # factor=factor*10+left
      		j show1
show1:    	li $t2, LEFT_LED   # hien thi den LED trai
      		add $s0, $zero, $t6 # truyen bien left
      		jal displayLED
      		nop
      		li $t2, RIGHT_LED  # hien thi den LED phai
      		add $s0, $zero, $t7 # truyen bien right
      		jal displayLED
      		nop
case_default1:  j getInt1rt
getInt1rt: 	lw $ra, 0($sp)
      		addi $sp, $sp, -4
      		jr $ra
##################### GETCODE 3 #####################
getInt2: 	addi $sp, $sp, 4
      		sw $ra, 0($sp) 
      		li $t1, IN_ADDRESS_HEXA_KEYBOARD
      		li $t3, 0x82     # Kich hoat interrupt, cho phep bam phim o hang 1
      		sb $t3, 0($t1)
      		li $t1, OUT_ADDRESS_HEXA_KEYBOARD
      		lb $t3, 0($t1)   # Nhan byte the hien vi tri cua phim duoc bam trong hang 1
case_4:   	li $t5, 0x12
      		bne $t3, $t5, case_5  # case 0x11
      		addi $t7, $t6, 0    # left=right
      		addi $t6, $zero, 4  # left = 4
      		mul $s1, $s1, 10
      		add $s1, $s1, $t6   # factor=factor*10+left
      		j show2
case_5:   	li $t5, 0x22
      		bne $t3, $t5, case_6  # case 0x21
      		addi $t7, $t6, 0    # left=right
      		addi $t6, $zero, 5  # left = 5
      		mul $s1, $s1, 10
      		add $s1, $s1, $t6   # factor=factor*10+left
      		j show2
case_6:   	li $t5, 0x42
      		bne $t3, $t5, case_7  # case 0x41
      		addi $t7, $t6, 0    # left=right
      		addi $t6, $zero, 6  # left = 6
      		mul $s1, $s1, 10
      		add $s1, $s1, $t6   # factor=factor*10+left
      		j show2
case_7:   	li $t5, 0xffffff82
      		bne $t3, $t5, case_default2  # case 0xffffff81
      		addi $t7, $t6, 0    # left=right
      		addi $t6, $zero, 7  # left = 7
      		mul $s1, $s1, 10
      		add $s1, $s1, $t6 # factor=factor*10+left
      		j show2
show2:    	li $t2, LEFT_LED   # hien thi den LED trai
      		add $s0, $zero, $t6 # truyen bien left
      		jal displayLED
      		nop
      		li $t2, RIGHT_LED  # hien thi den LED phai
      		add $s0, $zero, $t7 # truyen bien right
      		jal displayLED
      		nop
case_default2:  j getInt2rt
getInt2rt: 	lw $ra, 0($sp)
      		addi $sp, $sp, -4
      		jr $ra
##################### GETCODE 3 #####################
 getInt3: 	addi $sp, $sp, 4
      		sw $ra, 0($sp) 
      		li $t1, IN_ADDRESS_HEXA_KEYBOARD
      		li $t3, 0x84     # Kich hoat interrupt, cho phep bam phim o hang 3
      		sb $t3, 0($t1)
      		li $t1, OUT_ADDRESS_HEXA_KEYBOARD
      		lb $t3, 0($t1)   # Nhan byte the hien vi tri cua phim duoc bam trong hang 3
case_8:   	li $t5, 0x00000014
      		bne $t3, $t5, case_9  # case 0x14
      		addi $t7, $t6, 0    # left=right
      		addi $t6, $zero, 8  # left = 8
      		mul $s1, $s1, 10
      		add $s1, $s1, $t6   # factor=factor*10+left
      		j show3
case_9:   	li $t5, 0x00000024
      		bne $t3, $t5, case_a  # case 0x24
      		addi $t7, $t6, 0    # left=right
      		addi $t6, $zero, 9  # left = 9
      		mul $s1, $s1, 10
      		add $s1, $s1, $t6   # factor=factor*10+left
      		j show3
case_a:   	li $t5, 0x44
         	bne $t3, $t5, case_b # case 0x44
         	addi $s2, $0, 1
         	j case_default3
case_b:   	li $t5, 0xffffff84
    		bne $t3, $t5, case_default3
    		addi $s2, $0, 2
  		j  case_default3
show3: 		li $t2, LEFT_LED   # hien thi den LED trai
      		add $s0, $zero, $t6 # truyen bien left
      		jal displayLED
      		nop
      		li $t2, RIGHT_LED  # hien thi den LED phai
      		add $s0, $zero, $t7 # truyen bien right
      		jal displayLED
      		nop
case_default3:  j getInt3rt
getInt3rt: 	lw $ra, 0($sp)
      		addi $sp, $sp, -4
      		jr $ra
##################### GETCODE 4 #####################
 getInt4: 	addi $sp, $sp, 4
      		sw $ra, 0($sp) 
      		li $t1, IN_ADDRESS_HEXA_KEYBOARD
      		li $t3, 0x88     # Kich hoat interrupt, cho phep bam phim o hang 4
      		sb $t3, 0($t1)
      		li $t1, OUT_ADDRESS_HEXA_KEYBOARD
      		lb $t3, 0($t1)   # Nhan byte the hien vi tri cua phim duoc bam trong hang 4
case_c:   	li $t5, 0x18
          	bne $t3, $t5, case_d # case 0x44
          	addi $s2, $0, 3
          	j case_default3
case_d:   	li $t5, 0x28
          	bne $t3, $t5, case_e
          	addi $s2, $0, 4
          	j  case_default4         
case_e:   	li $t5, 0x48
          	bne $t3, $t5, case_f
          	addi $s2, $0, 5
          	j case_default4
case_f:   	li $t5, 0xffffff88 
          	bne $t3, $t5, case_default4
          	addi $s5, $0, 6
          	j case_default4
case_default4:  j getInt4rt
getInt4rt:      lw $ra, 0($sp)
                addi $sp, $sp, -4
                jr $ra
  #-------------------------------------------------------------------------
  # Thu tuc hien thi den LED
  # Tham so truyen vao: $t2 (dia chi cua LEFT_LED hoac RIGHT_LED), $s0 : bien kieu int
  # Den LED $t2 se hien thi so $s0
  #-------------------------------------------------------------------------
displayLED: 	addi $sp, $sp, 4
      		sw $ra, 0($sp)   # save $ra
display:    
so_0: 		bne $s0, 0, so_1  # case $s0 = 0
      		li $t4, ZERO
      		j assign
so_1: 		bne $s0, 1, so_2  # case $s0 = 1
      		li $t4, ONE
      		j assign
so_2: 		bne $s0, 2, so_3  # case $s0 = 2
      		li $t4, TWO
      		j assign
so_3: 		bne $s0, 3, so_4  # case $s0 = 3
      		li $t4, THREE
      		j assign
so_4: 		bne $s0, 4, so_5  # case $s0 = 4
      		li $t4, FOUR
      		j assign
so_5: 		bne $s0, 5, so_6  # case $s0 = 5
      		li $t4, FIVE
      		j assign
so_6: 		bne $s0, 6, so_7  # case $s0 = 6
      		li $t4, SIX
      		j assign
so_7: 		bne $s0, 7, so_8  # case $s0 = 7
      		li $t4, SEVEN
      		j assign
so_8: 		bne $s0, 8, so_9  # case $s0 = 8
      		li $t4, EIGHT
      		j assign
so_9: 		bne $s0, 9, hienthi_df # case $s0 = 9
      		li $t4, NINE
      		j assign
hienthi_df:  	j displayLEDrt
assign:   	sb $t4, 0($t2)
displayLEDrt: 	lw $ra, 0($sp)
      		addi $sp, $sp, -4
      		jr $ra
