.data

string: .space 	100
m0:	.asciiz	"Nhap chuoi ky tu : " 
er_len: .asciiz "Do dai chuoi ki tu khong hop le. Hay thu lai!.\n"
m1: 	.asciiz "     Disk 1               Disk 2              Disk 3\n"
m2: 	.asciiz "----------------     ----------------     ---------------- \n"
opn: 	.asciiz "[[ "
cls: 	.asciiz "]]"
space: 	.asciiz	"     "
try: 	.asciiz "Do you want to try again?"
# "\n" = 10 in asciiz
.align 2
d:	.space	4

.text
INPUT:	li 	$v0, 4				# Print "Nhap chuoi ky tu : "
	la 	$a0, m0
	syscall
	li 	$v0, 8
	la 	$a0, string			# Read the input string 
	li 	$a1, 100
	syscall
	move 	$s0, $a0			# s0 contains address of the input string
	
#Check if the length of the input string is divisible by 8?
length: li 	$t0, 0 				# t0 = length
	li 	$t1, 0 				# t1 = index
check_char: 
	add 	$t2, $s0, $t1 			# t2 = address of string[i]
	lb 	$t3, 0($t2) 			# t3 = string[i]
	beq 	$t3, 10, test_len 		# t3 = "\n" ends string
	addi 	$t0, $t0, 1 			# length++
	addi 	$t1, $t1, 1 			# index++
	j 	check_char
test_len:
	beqz	$t0, er 
	move 	$t4, $t0
	and 	$t2, $t0, 0xf			# Get the last byte of $t0
	bne 	$t2, 0, test1			# If it equals 0 or 8, $t0 is divisble by 8
	j 	START
test1:	beq 	$t2, 8, START
	j 	er
er:	li 	$v0, 4				# The length of the input string isn't appropriate
	la 	$a0, er_len			
	syscall
	j 	INPUT				# Retype the input string

#Stimulate RAID5
START:	li 	$v0, 4
	la 	$a0, m1
	syscall
	la 	$a0, m2
	syscall
loop:

#Disk 1 XOR Disk 2 = Disk 3
	lw	$s1, 0($s0)			# Load first 4 bytes from $s0
	lw	$s2, 4($s0)			# Load next 4 bytes from $s0
	li	$k0, 10
	beq	$s1, $k0, end			# If $s1 = "/n" then ends loop
	
	move	$a1, $s1			# Print Disk 1
	jal	PRINT				
	
	move	$a1, $s2			# Print Disk 2
	jal	PRINT
	
	jal	PARITY				# Print Disk 3
	
	li	$v0, 11				# Print "\n"
	li	$a0, 10		
	syscall		
	addi	$s0, $s0, 8			# Return $s0 8 bytes
	
#Disk 1 XOR Disk 3 = Disk 2
	lw	$s1, 0($s0)			# Load first 4 bytes from $s0
	lw	$s2, 4($s0)			# Load next 4 bytes from $s0
	li	$k0, 10
	beq	$s1, $k0, end			# If $s1 = "/n" then ends loop
	
	move	$a1, $s1			# Print Disk 1
	jal	PRINT				
	
	jal	PARITY				# Print Disk 2
	
	move	$a1, $s2			# Print Disk 3
	jal	PRINT
	
	li	$v0, 11				# Print "\n"
	li	$a0, 10	
	syscall
	addi	$s0, $s0, 8			# Return $s0 8 bytes
	
#Disk 2 XOR Disk 3 = Disk 1		
	lw	$s1, 0($s0)			# Load first 4 characters from $s0
	lw	$s2, 4($s0)			# Load next 4 characters from $s0
	li	$k0, 10
	beq	$s1, $k0, end			# If $s1 = "/n" then ends loop
	
	jal	PARITY				# Print Disk 1
	
	move	$a1, $s1			# Print Disk 2
	jal	PRINT				
	
	move	$a1, $s2			# Print Disk 3
	jal	PRINT
	
	li	$v0, 11				# Print "\n"
	li	$a0, 10				
	syscall
	addi	$s0, $s0, 8			# Return $s0 8 bytes
	j	loop
end:
	li	$v0, 4
	la	$a0, m2
	syscall
	j 	REPEAT
#-----------------------------Functions------------------------------------		
PRINT:
	li	$v0, 11				# print '|'
	li	$a0, '|'
	syscall
	li	$v0, 4				# print "     "
	la	$a0, space
	syscall
	la	$a0, d
	sw	$a1, 0($a0) 			# print 4 characters
	syscall
	la	$a0, space			# print "     "
	syscall
	li	$v0, 11				# print '|'
	li	$a0, '|'
	syscall
	li	$v0, 4				# print "     "
	la	$a0, space
	syscall
	jr	$ra
# XOR processing	
PARITY:
	li	$v0, 4
	sw	$ra, 0($sp)
	la	$a0, opn       			# print "[[ "
	syscall
	
	xor	$s3, $s1, $s2		
	and	$a0, $s3, 0xff          	# Get 2 bytes from result of $s0 XOR $s1
	jal	HEX           			# Turn result into asciiz to print
	la	$a0, d               		# Print 2 characters in hex
	sw	$v0, 0($a0)
	li	$v0, 4
	syscall
	
	li	$v0, 11				# print ","
	li	$a0, ','
	syscall
	srl	$s3, $s3, 8			# Shift right 8 bits
	and	$a0, $s3, 0xff			# Get 2 bytes from result of $s0 XOR $s1
	jal	HEX				# Turn result into asciiz to print
	la	$a0, d
	sw	$v0, 0($a0)
	li	$v0, 4
	syscall
	li	$a0, ','
	li	$v0, 11
	syscall
	srl	$s3, $s3, 8			# Shift right 8 bits
	and	$a0, $s3, 0xff			# Get 2 bytes from result of $s0 XOR $s1
	jal	HEX				# Turn result into asciiz to print
	la	$a0, d
	sw	$v0, 0($a0)
	li	$v0, 4
	syscall
	li	$a0, ','
	li	$v0, 11
	syscall
	srl	$s3, $s3, 8			# Shift right 8 bits
	and	$a0, $s3, 0xff			# Get 2 bytes from result of $s0 XOR $s1
	jal	HEX				# Turn result into asciiz to print
	la	$a0, d
	sw	$v0, 0($a0)
	li	$v0, 4
	syscall
	la	$a0, cls			 # print "]]"
	syscall
	la	$a0, space			# print "       "
	syscall
	lw	$ra, 0($sp)
	jr	$ra

# Turn binary XOR result into hex by asciiz	
HEX:
	and	$k1, $a0, 0xf		 	# Get 1 byte first 
	bgt	$k1, 9, char1     		# if $k1 < 9
	li	$v0, 0x30                	# $v0 = 0 in asciiz
	add	$v0, $v0, $k1            	# $v0 = 0 + $k1 by number form in ascii
	j 	next
char1:
	li	$v0, 0x61                	# $v0 = "a" ascii
	subi	$k1, $k1, 0xa            	# minus 10
	add	$v0, $v0, $k1		 	# print a, b, c, d,... by ascii
		
next:
	sll	$v0, $v0, 8              	# Shift left 8 bits
	srl	$k1, $a0, 4		 	# Take next byte
	bgt	$k1, 0x9, char2
	addi	$v0, $v0, 0x30
	add	$v0, $v0, $k1
	j	endH
char2:
	addi	$v0, $v0, 0x61
	subi	$k1, $k1, 10
	add	$v0, $v0, $k1
endH:	jr	$ra

# Try again?
REPEAT:	li $v0, 50
	la $a0, try
	syscall
	beq $a0, 0, clear
	nop
	j exit
clear:	la 	$s0, string
	add 	$t5, $s0, $t4			# t5: address of the last byte used in the string
	li 	$t2, 0
Again: 
	sb 	$t2, ($s0)				# set byte at address $s0 = 0
	nop
	addi 	$s0, $s0, 1
	bge 	$s0, $t5, INPUT
	j 	Again
#------------------------------EXIT---------------------------------------	
exit:	li $v0, 10
	syscall