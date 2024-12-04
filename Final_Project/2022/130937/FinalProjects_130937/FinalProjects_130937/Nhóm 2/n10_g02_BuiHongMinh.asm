.data
	.eqv IN_ADDRESS_HEXA_KEYBOARD 	0xFFFF0012
	.eqv OUT_ADDRESS_HEXA_KEYBOARD 	0xFFFF0014
	.eqv SEVENSEG_LEFT 0xFFFF0011
	.eqv SEVENSEG_RIGHT 0xFFFF0010
	.eqv enable0 0x80
	.eqv enable1 0x81
	.eqv enable2 0x82
	.eqv enable3 0x84
	.eqv enable4 0x88        
	display0:  .byte 0x3f
	display1:   .byte 0x6
	display2:   .byte 0x5b
	display3: .byte 0x4f
	display4:  .byte 0x66
	display5:  .byte 0x6d
	display6:   .byte 0x7d
	display7: .byte 0x7
	display8: .byte 0x7f
	display9:  .byte 0x6f

	cantdivide: .asciiz "Can't divide by 0\n"
	plussign: .asciiz " + "
	subsign: .asciiz " - "
	powsign: .asciiz " x "
	dividesign: .asciiz " mod "
	remaintext: .asciiz " remain = " 
	equalsign: .asciiz " = "


.text
#---------------------------------------------------------------
# main
# $t0: Dia chi cua den led 7 doan trai
# $t1: Dia chi cua den led 7 doan phai
# $t2: command row number of hexadecimal keyboard (bit 0 to 3) and enable keyboard interrupt (bit 7) 
# $t3: receive row and column of the key pressed, 0 if not key pressed 
# $t4: display byte value (for led)
# $t5: bien luu gia tri cua cac trang thai enabale
# $t6: display byte value (for led), su dung cung $t4
# $t7: value so (1 chu so) doc duoc
# $t8: 10, 100...
# $t9: gia tri tam thoi cua hang tu
# $s0: bien kiem tra loai gia tri dang duoc nhap vao (0 - 1 - 2 ~~ so hang - toan tu - exit)
# $s3: bien kiem tra loai toan tu (1 - 2 - 3 - 4 ~~ cong - tru - nhan - chia)
# $s4: gia tri dung de tinh toan, so thu nhat
# $s5: gia tri dung de tinh toan, so thu hai
# $s6: gia tri ket qua tinh toan, dau ra
# $s7: chua gia tri so du
# $sp: stack
# $a3: trang thai toan tu dang xu ly (1 - 2 - 3 - 4 ~~ cong - tru - nhan - chia)

#---------------------------------------------------------------
main:
setup_all_value:
    	li $t0,SEVENSEG_LEFT     	 
    	li $t1,SEVENSEG_RIGHT     	 
    	li $t2, OUT_ADDRESS_HEXA_KEYBOARD 	
    	li $t3, IN_ADDRESS_HEXA_KEYBOARD
    	li $t5, enable0			  # Chua enable cho hang nao
    	li $s0,0      			  # Tam thoi loai gia tri duoc nhap vao la 0
    	li $s3,0     		
	li $s4,0      			 # so thu nhat = 0
	li $s5,0   			 # so thu hai = 0
	li $s6,0     			 # ket qua = 0 
	li $t9,0 			 # gia tri value tam thoi = 0
	sb $t5, 0($t3)                  # dua gia tri trang thai enable hien tai vao $t3[0]
	li $t7,0       			  # gia tri chu so doc duoc = 0
	lb $t4,display0			  # display value for led  = 0        		  
	addi $sp,$sp,4			  # sp[+] = $t7
	sb $t7,0($sp)	
	addi $sp,$sp,4  		  # sp[+] = $t4
	sb $t4,0($sp)
run:					  # vong lap chay vo han va de xu ly cac kien interupt
	beq $s0,2,break   		  # break run khi $s0 = 2 (exit)
	nop
	b run
	nop
break:
end:
	li $v0,10
	syscall
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# interupt: lien tuc check de doc du lieu input tu digital lab sim
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.ktext 0x80000180
interupt:
	jal first_row			#check hang 1 xem co phim nao duoc nhap ko
	jal second_row
	jal third_row
	jal fourth_row
first_row:
	addi $sp,$sp,4
        sw $ra,0($sp) 		# day gia tri $ra vao stack        
        li $t5,enable1     	# Enable cho hang 1
        sb $t5,0($t3)         # Luu vao $t3[0]
        jal get_input_address	# chay get_input_address lay code key
        lw $ra,0($sp)         # lay pop $ra tu sp
        addi $sp,$sp,-4
        bnez $t5,get_value_from_input_address # lay gia tri $t5 neu gia tri cua no khac 0
        nop
        jr $ra
second_row: #tuong tu first_row
	addi $sp,$sp,4
        sw $ra,0($sp) 
	li $t5,enable2     
        sb $t5,0($t3)
        jal get_input_address
        lw $ra,0($sp)
        addi $sp,$sp,-4
        bnez $t5,get_value_from_input_address
        nop
        jr $ra
third_row: #tuong tu first_row
	addi $sp,$sp,4
        sw $ra,0($sp) 
	li $t5,enable3   
        sb $t5,0($t3)
        jal get_input_address
        lw $ra,0($sp)
        addi $sp,$sp,-4
        bnez $t5,get_value_from_input_address
        nop
        jr $ra
fourth_row: #tuong tu first_row
	addi $sp,$sp,4
        sw $ra,0($sp) 
	li $t5,enable4  
        sb $t5,0($t3)
        jal get_input_address
        lw $ra,0($sp)
        addi $sp,$sp,-4
        bnez $t5,get_value_from_input_address
        jr $ra
get_input_address:
        li $t2,OUT_ADDRESS_HEXA_KEYBOARD  # dia chi chua code key
        lb $t5,0($t2)			  # lay code key t2[0]
        jr $ra
get_value_from_input_address:			# convert tu code sang value
	beq $t5,0x11,case_0			# 0x11 -> 0
	beq $t5,0x21,case_1			# 0x21 -> 1			
	beq $t5,0x41,case_2                 
	beq $t5,0xffffff81,case_3
	beq $t5,0x12,case_4
	beq $t5,0x22,case_5
	beq $t5,0x42,case_6
	beq $t5,0xffffff82,case_7
	beq $t5,0x14,case_8
	beq $t5,0x24,case_9
	beq $t5 0x44,case_a
	beq $t5 0xffffff84,case_b
	beq $t5,0x18,case_c
	beq $t5,0x28,case_d
	beq $t5,0x48,case_e
	beq $t5 0xffffff88,case_f
case_0:
	li $t7,0		# gia tri chu so doc duoc la 0
	jal convert		# chuyen doi de luu display_value
	j add_value		# them gia tri nay vao bien luu tam thoi
case_1: #tuong tu case 0
	li $t7,1
	jal convert
	j add_value
case_2: #tuong tu case 0
	li $t7,2
	jal convert
	j add_value
case_3: #tuong tu case 0
	li $t7,3
	jal convert
	j add_value
case_4: #tuong tu case 0
	li $t7,4
	jal convert
	j add_value
case_5: #tuong tu case 0
	li $t7,5
	jal convert
	j add_value
case_6: #tuong tu case 0
	li $t7,6
	jal convert
	j add_value
case_7: #tuong tu case 0
	li $t7,7
	jal convert
	j add_value
case_8: #tuong tu case 0
	li $t7,8
	jal convert
	j add_value
case_9: #tuong tu case 0
	li $t7,9
	jal convert
	j add_value
case_a:	#gap toan tu cong
	addi $a3,$zero,1	 # trang thai toan tu dung de xu ly: $a3 = 1 (cong)
	addi $s0,$s0,1          # trang thai vua nhan vao: $s0 = 1 -> da nhan vao 1 toan tu
	bne $s3,0,begin_a_operator # neu trang thai toan tu = 0 jump toi begin_a_operator
	addi $s3,$zero,1	 # trang thai toan tu $s3 = 1
	j get_first_term        # tinh toan
case_b: #gap toan tu tru
	addi $a3,$zero,2
	addi $s0,$s0,1
	bne $s3,0,begin_a_operator
	addi $s3,$zero,2
	j get_first_term
case_c: #gap toan tu nhan
	addi $a3,$zero,3
	addi $s0,$s0,1
	bne $s3,0,begin_a_operator
	addi $s3,$zero,3
	j get_first_term	
case_d: #gap toan tu chia
	addi $a3,$zero,4
	addi $s0,$s0,1
	bne $s3,0,begin_a_operator
	addi $s3,$zero,4
	j get_first_term

case_e:  #exit
	addi $s0,$s0,2         # danh dau s0 = 2 (exit)
	j finish
get_first_term:       		# ham tinh so dau tien
	addi $s4, $t9, 0       # phan tu dau tien = $s9
	li $t9, 0		# reset $t9
	j done
case_f:  #truong hop bam =
	addi $s5, $t9, 0	# phan tu thu hai = $s9
	beq $s3,1,plus         # re nhanh theo trang thai toan tu da co
	beq $s3,2,subtr
	beq $s3,3,pow
	beq $s3,4,divide
plus:
	add $s6,$s5,$s4
	li $s3,0
	li $t9, 0 
	j print_plus
	nop     		# s6=s5+s4
	
print_plus:
	li $v0, 1
	move $a0, $s4
	syscall
	li $s4, 0
	
	
	li $v0, 4
	la $a0, plussign
	syscall
	
	li $v0, 1
	move $a0, $s5
	syscall
	li $s5, 0		#reset $s5
	
	li $v0, 4
	la $a0, equalsign
	syscall
	
	li $v0, 1
	move $a0, $s6
	syscall
	nop
	
	li $v0, 11
	li $a0, '\n'
	syscall
	li $s7,100
	div $s6,$s7
	mfhi $s6	    # lay phan du tu phep chia 100
	j display_result
	nop
	
subtr:
	sub $s6,$s4,$s5    # s6=s4-s5
	li $s3,0
	li $t9, 0 
	j print_sub
	nop
subtrne: 
	sub $s6, $zero, $s6
	j subtrne_continue
print_sub:
	li $v0, 1
	move $a0, $s4
	syscall
	
	li $v0, 4
	la $a0, subsign
	syscall
	
	li $v0, 1
	move $a0, $s5
	syscall
	li $s5, 0		#reset $s5
	
	li $v0, 4
	la $a0, equalsign
	syscall
	
	li $v0, 1
	move $a0, $s6
	syscall
	
	li $v0, 11
	li $a0, '\n'
	syscall
	
	blt $s6, $zero, subtrne
subtrne_continue:	
	li $s7,100
	div $s6,$s7
	mfhi $s6	    # lay phan du tu phep chia 100
	j display_result       # chuyen den ham chia ket qua thanh 2 chu so de hien thi len tung led
	nop
pow:
	mul $s6,$s4,$s5     # s6=s4*s5
	li $s3,0
	li $t9, 0 
	j print_pow
	nop
print_pow:
	li $v0, 1
	move $a0, $s4
	syscall
	
	li $v0, 4
	la $a0, powsign
	syscall
	
	li $v0, 1
	move $a0, $s5
	syscall
	li $s5, 0		#reset $s5
	
	li $v0, 4
	la $a0, equalsign
	syscall
	
	li $v0, 1
	move $a0, $s6
	syscall
	
	li $v0, 11
	li $a0, '\n'
	syscall
	li $s7,100
	div $s6,$s7
	mfhi $s6	    
	j display_result
	nop
divide:
	beq $s5,0,divide0
	li $s3,0
	div $s4,$s5   	    # s6=s4/s5
	mflo $s6
	mfhi $s7
	li $t9, 0 
	j print_divide
	nop
print_divide:
	li $v0, 1
	move $a0, $s4
	syscall
	
	li $v0, 4
	la $a0, dividesign
	syscall
	
	li $v0, 1
	move $a0, $s5
	syscall
	li $s5, 0		#reset $s5
	
	li $v0, 4
	la $a0, equalsign
	syscall
	
	li $v0, 1
	move $a0, $s6
	syscall
	
	li $v0, 4
	la $a0, remaintext
	syscall
	
	li $v0, 1 		# in ra so du
	move $a0, $s7
	syscall
	
	li $v0, 11
	li $a0, '\n'
	syscall
	
	li $s7,100
	div $s6,$s7
	mfhi $s6	    # lay phan du tu phep chia 100
	j display_result       # chuyen den ham chia ket qua thanh 2 chu so de hien thi len tung led
	nop
divide0: 
	li $v0, 55
	la $a0, cantdivide
	li $a1, 0
	syscall
	j reset_led

display_result:
	li $t8,10
	div $s6,$t8    
	mflo $t7       # lay 1 chu so
	jal convert    # lay display_value
        #---------
        sb $t4,0($t0)  # hien thi len led trai
     	add $sp,$sp,4
	sb $t7,0($sp)	# sp[+] = $s7
	add $sp,$sp,4
	sb $t4,0($sp)   # sp[+] = $s4
	#----------
	mfhi $t7       #t7 = remainder
	jal convert    # thuc hien tuong tu
        sb $t4,0($t1)  
       	add $sp,$sp,4
	sb $t7,0($sp)
	add $sp,$sp,4
	sb $t4,0($sp)  
        j reset_led     # ham reset lai led
add_value:			
	 mul $t9, $t9, 10    # gia tri tam thoi t9 = t9 * 10 -> them hang don vi
	 add $t9, $t9, $t7   # gia tri tam thoi t9 = t9 + t7 
done:
	beq $s0,1,reset_led   # s0=1 -> da nhan toan tu
	nop
get_left_value:        
	lb $t6,0($sp)       #l oad display_value tu stack
	add $sp,$sp,-4
	lb $t8,0($sp)       # load gia tri
	add $sp,$sp,-4      
	sb $t6,0($t0)       # hien thi len led trai
get_right_value:	# tuong tu
	sb $t4,0($t1)      
	add $sp,$sp,4
	sb $t7,0($sp)	   
	add $sp,$sp,4
	sb $t4,0($sp)       
	j finish            
reset_led:
	li $s0,0           # dua trang thai ve doi number
        li $t8,0           # reset t8
	addi $sp,$sp,4      # sp[+] = t8 (0)
        sb $t8,0($sp)
        lb $t6,display0     # display led = 0 (display0)
	addi $sp,$sp,4      # sp[+] = $t6
        sb $t6,0($sp)
finish:
	j end_exception
	nop
end_exception:
	la $a3, run         #quay ve run
	mtc0 $a3, $14
	eret

convert:
	addi $sp,$sp,4
        sw $ra,0($sp)
        beq $t7,0,case_01    # t7=0 ung voi gia tri 0 -> hien thi 0 -> display0
        beq $t7,1,case_11
        beq $t7,2,case_21
        beq $t7,3,case_31
        beq $t7,4,case_41
        beq $t7,5,case_51
        beq $t7,6,case_61
        beq $t7,7,case_71
        beq $t7,8,case_81
        beq $t7,9,case_91
case_01:
	lb $t4,display0    # t4 = display 0
	j afterconvert # ket thuc
case_11:
	lb $t4,display1
	j afterconvert
case_21:
	lb $t4,display2
	j afterconvert
case_31:
	lb $t4,display3
	j afterconvert
case_41:
	lb $t4,display4
	j afterconvert
case_51:
	lb $t4,display5
	j afterconvert
case_61:
	lb $t4,display6
	j afterconvert
case_71:
	lb $t4,display7
	j afterconvert
case_81:
	lb $t4,display8
	j afterconvert
case_91:
	lb $t4,display9
	j afterconvert
afterconvert:
	lw $ra,0($sp)
	addi $sp,$sp,-4
	jr $ra  #ve lai
begin_a_operator:
	addi $s5, $t9, 0        # s5 = t9 + 0 = 0
	beq $a3,1,plus         # s3 = 1 -> phep cong
	beq $a3,2,subtr
	beq $a3,3,pow
	beq $a3,4,divide
