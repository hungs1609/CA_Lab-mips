# DCE.****ABCD1234HUSTHUST
.data
enterString: .asciiz "Enter String that can be divided by 8: "
hex: .byte '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' 
array: .space 100
string: .space 1000
enter: .asciiz "/n"
line: .asciiz "      Disk 1                 Disk 2               Disk 3\n"
line2: .asciiz "----------------       ----------------       ----------------\n"
line3: .asciiz "|     "
line4: .asciiz "     |       "
line5: .asciiz "[[ "
line6: .asciiz "]]       "
comma: .asciiz ","
errorMessage: .asciiz "String line must be divided by 8. Please try again!\n"
emptyString: .asciiz "String is empty. String input must be divided by 8!\n"
tryagain: .asciiz "Try again"
tempString: .space 100

.text
input:
	li $v0,4
	la $a0,enterString 	# print enterString
	syscall
	
	li $v0, 8		# lay String da nhap vao string
	la $a0, string
	li $a1, 1000
	syscall
	move $s0, $a0		# move dia chi cua $a0 (String moi nhap) vao $s0
	
	li $v0, 4		#in line
	la $a0, line
	syscall
	li $v0, 4		#in line2
	la $a0, line2		
	syscall
	
length:	#khoi tao length và count
	li $t0,0  		# $t0 = length
	li $t1,0  		# $t1 = count
countLength: #Check xem String có chia het cho 8 hay không
	add $t2, $s0, $t0 	# $t2  = dia chi string
	lb $t3, 0($t2) 		# load tung byte t3 = string[i]
	nop
	
	beq $t3,10,lengthCheck  # if $t3 = '\n' => check chia het cho 8, ket thuc string
	nop
	
	addi $t0,$t0,1 		# length++
	addi $t1,$t1,1		# count++
	j countLength
	nop

lengthCheck:	
	lb $a3, string($zero)
	beq $a3, 10, errorString
 	li $s1,8 		# load 8
 	div $t1,$s1 		# chia count cho 8
 	mfhi $s2 		# lay phep tính chia vua lam vao $s2
	beq $s2,0,divideCheck	 	 

divideError:
 	li $v0, 4
 	la $a0, errorMessage 	# jump to input if String can't be divided by 8
	syscall
	j input

divideCheck: # check so lan chia duoc cho 8
	mflo $s2  		
	li $a2,0 		# $a2 = 0 
	
	addi $t0,$s0,0 		# $t0 = $s0
	li $t2,1 		
parityCheck:
	addi $t1,$t0,4, 	# $t0 = address 4 byte cua block 1, $t1 = address 4 byte cua block 2 
	addi  $a2, $a2,1	# line++
	bgt  $a2,$s2, end
	
	#check bit
	lb $s3, 0($t0)		# lay tu dia chi goc 2 byte dau cua 2 block
	lb $s4, 0($t1)
	xor $t5, $s3, $s4 	

	lb $s3, 1($t0) 		# lay tu dia chi goc 2 byte sau do cua 2 block
	lb $s4, 1($t1)
	xor $t6, $s3,$s4	 	

	lb $s3, 2($t0)		# lay tu dia chi goc 2 byte sau do cua 2 block
	lb $s4, 2($t1)
	xor $a3, $s3,$s4 	

	lb $s3, 3($t0)		# lay tu dia chi goc 2 byte sau do cua 2 block
	lb $s4, 3($t1)
	xor $t8, $s3,$s4	 

	li $t3,3		
	div $t2,$t3		
	mfhi $s5		
	beq $s5, 0, printBlock1
	beq $s5, 1, printBlock2
	beq $s5, 2, printBlock3

printBlock1: #this is line 3
	#block3
	li $v0, 4		
	la $a0, line5
	syscall	

	add $t9,$zero,$t5
	jal HEXASCII
	
	li $v0, 4		
	la $a0, comma
	syscall	
	
	add $t9,$zero,$t6
	jal HEXASCII
	
	li $v0, 4		
	la $a0, comma
	syscall
	
	add $t9,$zero,$a3
	jal HEXASCII
	
	li $v0, 4		
	la $a0, comma
	syscall
	
	add $t9,$zero,$t8
	jal HEXASCII
	
	li $v0, 4		
	la $a0, line6
	syscall

	#block1
	li $v0, 4		
	la $a0, line3
	syscall
	
	la $s6, tempString
	
	lb $s7, 0($t0) 
	sb $s7,0($s6)
	
	lb $s7, 1($t0) 
	sb $s7,1($s6)
	
	lb $s7, 2($t0) 
	sb $s7,2($s6)
	
	lb $s7, 3($t0) 
	sb $s7,3($s6)
	
	li $v0, 4
	la  $a0, tempString 
	syscall
	
	li $v0, 4		
	la $a0, line4
	syscall
	
	#block 2
	li $v0, 4		
	la $a0, line3
	syscall
	
	la $s6, tempString
	 
	lb $s7, 0($t1) 
	sb $s7,0($s6)
	
	lb $s7, 1($t1) 
	sb $s7,1($s6)
	
	lb $s7, 2($t1) 
	sb $s7,2($s6)
	
	lb $s7, 3($t1) 
	sb $s7,3($s6)
	
	li $v0, 4
	la  $a0, tempString 
	syscall
			
	li $v0, 4		
	la $a0, line4
	syscall		


	li $v0, 11 
	li $a0, 10
	syscall 	
	
	j Address

printBlock2: #this is line 1
	#block1
	li $v0, 4		
	la $a0, line3
	syscall
	
	la $s6, tempString
	
	lb $s7, 0($t0) 
	sb $s7,0($s6)
	
	lb $s7, 1($t0) 
	sb $s7,1($s6)
	
	lb $s7, 2($t0) 
	sb $s7,2($s6)
	
	lb $s7, 3($t0) 
	sb $s7,3($s6)
	
	li $v0, 4
	la  $a0, tempString 
	syscall
	
	li $v0, 4		
	la $a0, line4
	syscall
	
	#block2
	li $v0, 4		
	la $a0, line3
	syscall
	
	la $s6, tempString
	
	lb $s7, 0($t1) 
	sb $s7,0($s6)
	
	lb $s7, 1($t1) 
	sb $s7,1($s6)
	
	lb $s7, 2($t1) 
	sb $s7,2($s6)
	
	lb $s7, 3($t1) 
	sb $s7,3($s6)
	
	li $v0, 4
	la  $a0, tempString 
	syscall
			
	li $v0, 4		
	la $a0, line4
	syscall		

	#block3
	li $v0, 4		
	la $a0, line5
	syscall	

	add $t9,$zero,$t5
	jal HEXASCII
	
	li $v0, 4		
	la $a0, comma
	syscall	
	
	add $t9,$zero,$t6
	jal HEXASCII
	
	li $v0, 4		
	la $a0, comma
	syscall
	
	add $t9,$zero,$a3
	jal HEXASCII
	
	li $v0, 4		
	la $a0, comma
	syscall
	
	add $t9,$zero,$t8
	jal HEXASCII
		
	li $v0, 4		
	la $a0, line6
	syscall	

	li $v0, 11 
	li $a0, 10
	syscall 
	
	j Address

printBlock3: #this is line 2
	#block1
	li $v0, 4		
	la $a0, line3
	syscall
	
	la $s6, tempString
	
	lb $s7, 0($t0) 
	sb $s7,0($s6)
	
	lb $s7, 1($t0) 
	sb $s7,1($s6)
	
	lb $s7, 2($t0) 
	sb $s7,2($s6)
	
	lb $s7, 3($t0) 
	sb $s7,3($s6)
	
	li $v0, 4
	la $a0, tempString 
	syscall
	
	
	li $v0, 4		
	la $a0, line4
	syscall

	#block3
	li $v0, 4		
	la $a0, line5
	syscall	

	add $t9,$zero,$t5
	jal HEXASCII
	
	li $v0, 4		
	la $a0, comma
	syscall	
	
	add $t9,$zero,$t6
	jal HEXASCII
	
	li $v0, 4		
	la $a0, comma
	syscall
	
	add $t9,$zero,$a3
	jal HEXASCII
	
	li $v0, 4		
	la $a0, comma
	syscall
	
	add $t9,$zero,$t8
	jal HEXASCII
	
	li $v0, 4		
	la $a0, line6
	syscall	
			
	#block 2
	li $v0, 4		
	la $a0, line3
	syscall
	
	la $s6, tempString
	
	lb $s7, 0($t1) 
	sb $s7,0($s6)
	
	lb $s7, 1($t1) 
	sb $s7,1($s6)
	
	lb $s7, 2($t1) 
	sb $s7,2($s6)
	
	lb $s7, 3($t1) 
	sb $s7,3($s6)
	
	li $v0, 4
	la  $a0, tempString 
	syscall
			
	li $v0, 4		
	la $a0, line4
	syscall		

	li $v0, 11 
	li $a0, 10
	syscall 
	
	j Address
	
Address:
	addi $t2,$t2,1		# $t2++
	addi $t0,$t0,8		# cong dia chi them 8
	j parityCheck

HEXASCII:			
	li $t4,16
	div  $t9,$t4
	mflo $t3
	la $t4, hex
	add $t7,$t4,$t3
	lb $a0, 0($t7) 		# print hex[a0]
	li $v0, 11
	syscall
	mfhi $t3
	add $t7,$t4,$t3
	lb $a0, 0($t7) 		# print hex[a0]
	li $v0, 11
	syscall

endLoop: jr $ra							
			
end:
	li $v0, 4
	la $a0, line2
	syscall 

tryAgain:
	li $v0, 50
	la $a0, tryagain
	syscall
	beq $a0,0, input	
	nop
exit:
	li $v0, 10
	syscall
	
errorString:
	li $v0, 4
	la $a0, emptyString
	syscall
	j tryAgain
	
	
