.data
	infix: .space 256
	postfix: .space 256
	operator: .space 256
	endMsg: .asciiz "Ban co muon tiep tuc khong?"
	byeMsg: .asciiz "Ket thuc chuong trinh"
	errorMsg: .asciiz "Input error"
	startMsg: .asciiz "Nhap bieu thuc trung to\nNote: chi su dung + - * / % ()\nCac so tu 00-99"
	prompt_postfix: .asciiz "Bieu thuc hau to: "
	prompt_result: .asciiz "Ket qua: "
	prompt_infix: .asciiz "Bieu thuc trung to: "
	reset: .word 1
	stack: .word
.text
start:
# Nhap bieu thuc trung to
	li $v0, 54
	la $a0, startMsg
	la $a1, infix
 	la $a2, 256
 	syscall
 	beq $a1,-2,end
 	beq $a1,-3,start
# In ra Trung to
	li $v0, 4
	la $a0, prompt_infix
	syscall
	li $v0, 4
	la $a0, infix
	syscall
	li $v0, 11
	li $a0, '\n'
	syscall
# Trang thai
	li $s7,0		# Trang thai 
				# 0 = ban dau khong nhan vao anything
				# 1 = nhap vao so
				# 2 = nhap vao toan tu
				# 3 = nhap vao dau (
				# 4 = nhapm vao dau )
	li $t9,0		# Dem chu so
	li $t5,-1		# Postfix top offset
	li $t6,-1		# Operator top offset
	la $t1, infix		# Infix dia chi byte hien tai +1 mỗi loop
	la $t2, postfix
	la $t3, operator	
	addi $t1,$t1,-1		# Dat dia chi ban dau cua infix ve -1
# Chuyen thanh hau to
scanInfix: 			# Loop doi voi moi 1 ki tu trong postfix
# Kiem tra input 
	addi $t1,$t1,1			# Tang vi tri infix 
	lb $t4, ($t1)			# Load infix input hien tai
	beq $t4, ' ', scanInfix		# Neu scan dau cach thi bo qua va scan lai
	beq $t4, '\n', EOF		# Scan den het input --> pop moi operator sang postfix
	beq $t9,0,digit1		# Neu trang thai la 0 chu so
	beq $t9,1,digit2		# Neu trang thai la 1 chu so
	beq $t9,2,digit3		# Neu trang thai la 2 chu so
	continueScan:
	beq $t4, '+', plusMinus
	beq $t4, '-', plusMinus
	beq $t4, '*', multiplyDivide
	beq $t4, '/', multiplyDivide
	beq $t4, '%', multiplyDivide
	beq $t4, '(', openBracket
	beq $t4, ')', closeBracket
wrongInput:	# Khi phat hien input nhap sai
	li $v0, 55
 	la $a0, errorMsg
 	li $a1, 2
 	syscall
 	j ask
finishScan:
# In bieu thuc hau to
	# Print prompt:
	li $v0, 4
	la $a0, prompt_postfix
	syscall
	li $t6,-1		# Load Postfix offset hien tai ve -1
printPost:
	addi $t6,$t6,1		# Tang Postfix offset hien tai 
	add $t8,$t2,$t6		# Load dia chi cua Postfix hien tai
	lbu $t7,($t8)		# Load gia tri cua Postfix hien tai
	bgt $t6,$t5,finishPrint	# In moi postfix --> tinh toan
	bgt $t7,99,printOp	# Neu Postfix hien tai > 99 --> 1 toan tu
	# Neu khong thi Postfix hien tai la mot so
	li $v0, 1
	add $a0,$t7,$zero
	syscall
	li $v0, 11
	li $a0, ' '
	syscall
	j printPost		# Loop
	printOp:
	li $v0, 11
	addi $t7,$t7,-100	#Giai ma toan tu
	add $a0,$t7,$zero
	syscall
	li $v0, 11
	li $a0, ' '
	syscall
	j printPost		# Loop
finishPrint:
	li $v0, 11
	li $a0, '\n'
	syscall
# Tinh toan
	li $t9,-4		# Dat top cua stack offset ve -4
	la $t3,stack		# Load dia chi stack
	li $t6,-1		# Load Postfix offset hien tai ve -1
	
calPost:
	addi $t6,$t6,1		# Tang Postfix offset hien tai 
	add $t8,$t2,$t6		# Load dia chi cua Postfix hien tai
	lbu $t7,($t8)		# Load gia tri cua Postfix hien tai
	bgt $t6,$t5,printResult	# Tinh toan moi postfix --> in
	bgt $t7,99,calculate	# Neu Postfix hien tai > 99 --> 1 toan tu --> popout 2 so de tinh
	# Neu khong thi Postfix hien tai la mot so
	addi $t9,$t9,4		# stack top offset hien tai
	add $t4,$t3,$t9		# Dia chi stack top hien tai
	sw $t7,($t4)		#day so vao stack
	j calPost		# Loop
	calculate:
		# Pop 1 so
		add $t4,$t3,$t9		
		lw $s3,($t4)
		# Pop so ke tiep
		addi $t9,$t9,-4
		add $t4,$t3,$t9		
		lw $s2,($t4)
		# Giai ma toan tu
		beq $t7,143,plus
		beq $t7,145,minus
		beq $t7,142,multiply
		beq $t7,147,divide
		beq $t7,137,mod
		plus:
			add $s1,$s2,$s3
			sw $s1,($t4)
			sub $s2,$s2,$s2	# Reset s2 s3
			sub $s3,$s3,$s3	
			j calPost
		minus:
			sub $s1,$s2,$s3
			sw $s1,($t4)	
			sub $s2,$s2,$s2	# Reset s2 s3
			sub $s3,$s3,$s3
			j calPost
		multiply:
			mul $s1,$s2,$s3
			sw $s1,($t4)	
			sub $s2,$s2,$s2	# Reset s2 s3
			sub $s3,$s3,$s3
			j calPost
		divide:
			div $s1,$s2,$s3
			sw $s1,($t4)	
			sub $s2,$s2,$s2	# Reset s2 s3
			sub $s3,$s3,$s3
			j calPost
		mod:	
			div $s1,$s2,$s3
			mfhi $s1
			sw $s1,($t4)	
			sub $s2,$s2,$s2	# Reset s2 s3
			sub $s3,$s3,$s3
			j calPost
printResult:	
	li $v0, 4
	la $a0, prompt_result
	syscall
	li $v0, 1
	lw $a0,($t4)
	syscall
	li $v0, 11
	li $a0, '\n'
	syscall
ask: 			# Hoi nguoi dung co tiep tuc khong
 	li $v0, 50
 	la $a0, endMsg
 	syscall
 	beq $a0,0,start
 	beq $a0,2,ask
# Ket thuc chuong trinh
end:
 	li $v0, 55
 	la $a0, byeMsg
 	li $a1, 1
 	syscall
 	li $v0, 10
 	syscall
 
# Chuong trinh con
EOF:
	beq $s7,2,wrongInput			# Ket thuc voi mot toan tu hoac dau mo ngoac
	beq $s7,3,wrongInput
	beq $t5,-1,wrongInput			# Khong nhap vao anything
	j popAll
digit1:
	beq $t4,'0',store1Digit
	beq $t4,'1',store1Digit
	beq $t4,'2',store1Digit
	beq $t4,'3',store1Digit
	beq $t4,'4',store1Digit
	beq $t4,'5',store1Digit
	beq $t4,'6',store1Digit
	beq $t4,'7',store1Digit
	beq $t4,'8',store1Digit
	beq $t4,'9',store1Digit
	j continueScan
	
digit2: 
	beq $t4,'0',store2Digit
	beq $t4,'1',store2Digit
	beq $t4,'2',store2Digit
	beq $t4,'3',store2Digit
	beq $t4,'4',store2Digit
	beq $t4,'5',store2Digit
	beq $t4,'6',store2Digit
	beq $t4,'7',store2Digit
	beq $t4,'8',store2Digit
	beq $t4,'9',store2Digit
	# Neu khong nhan chu so thu 2
	jal numberToPost
	j continueScan
digit3: 
	# Neu scan chu so thu 3 --> error
	beq $t4,'0',wrongInput
	beq $t4,'1',wrongInput
	beq $t4,'2',wrongInput
	beq $t4,'3',wrongInput
	beq $t4,'4',wrongInput
	beq $t4,'5',wrongInput
	beq $t4,'6',wrongInput
	beq $t4,'7',wrongInput
	beq $t4,'8',wrongInput
	beq $t4,'9',wrongInput
	# Neu khong nhan chu so thu 3
	jal numberToPost
	j continueScan
plusMinus:			# Input la + -
	beq $s7,2,wrongInput		# Nhan vao 1 toan tu ngay sau 1 toan tu hoac nhan vao dau mo ngoac 
	beq $s7,3,wrongInput
	beq $s7,0,wrongInput		# Nhan vao toan tu truoc bat ky so nao
	li $s7,2			# Chuyen trang thai input sang 2
	continuePlusMinus:
	beq $t6,-1,inputToOp		# Khong co gi trong Operator stack --> day vao
	add $t8,$t6,$t3			# Load dia chi cua top Operator
	lb $t7,($t8)			# Load gia tri byte cua top Operator
	beq $t7,'(',inputToOp		# Neu top la ( --> day vao
	beq $t7,'+',equalPrecedence	# Neu top la + -
	beq $t7,'-',equalPrecedence
	beq $t7,'*',lowerPrecedence	# Neu top la * / %
	beq $t7,'/',lowerPrecedence
	beq $t7,'%',lowerPrecedence
multiplyDivide:			# Input la * /
	beq $s7,2,wrongInput		# Nhan vao 1 toan tu ngay sau 1 toan tu hoac nhan vao dau mo ngoac 
	beq $s7,3,wrongInput
	beq $s7,0,wrongInput		# Nhan vao toan tu truoc bat ky so nao
	li $s7,2			# Chuyen trang thai input sang 2
	beq $t6,-1,inputToOp		# Khong co gi trong Operator stack --> day vao
	add $t8,$t6,$t3			# Load dia chi cua top Operator
	lb $t7,($t8)			# Load gia tri byte cua top Operator
	beq $t7,'(',inputToOp		# Neu top la ( --> day vao
	beq $t7,'+',inputToOp		# Neu top la + - --> day vao
	beq $t7,'-',inputToOp
	beq $t7,'*',equalPrecedence	# Neu top la * / %
	beq $t7,'/',equalPrecedence
	beq $t7,'%',equalPrecedence
openBracket:			# Input la (
	beq $s7,1,wrongInput		# Nhan vao 1 dau mo ngoac sau 1 so hoac nhan vao dau dong ngoac
	beq $s7,4,wrongInput
	li $s7,3			# Chuyen trang thai input sang 3
	j inputToOp
closeBracket:			# Input la )
	beq $s7,2,wrongInput		# Nhan vao 1 dau dong ngoac sau 1 toan tu hoac nhan vao 1 toan tu
	beq $s7,3,wrongInput	
	li $s7,4			# Chuyen trang thai input sang 4
	add $t8,$t6,$t3			# Load dia chi cua top Operator 
	lb $t7,($t8)			# Load gia tri byte cua top Operator
	beq $t7,'(',wrongInput		# Input chua () ma khong co gi ben trong --> error
	continueCloseBracket:
	beq $t6,-1,wrongInput		# Khong the tim 1 dau mo ngoac --> error
	add $t8,$t6,$t3			# Load dia chi cua top Operator
	lb $t7,($t8)			# Load gia tri byte cua top Operator
	beq $t7,'(',matchBracket	# Tim dau ngoac tuong ung
	jal opToPostfix			# Pop top cua Operator sang Postfix
	j continueCloseBracket		# Sau do loop lai cho den khi tim duoc dau ngoac tuong ung hoac error			
equalPrecedence:	# Nhap vao + - va top la + - || nhap vao * / % va top la * / %
	jal opToPostfix			# Pop top cua Operator sang Postfix
	j inputToOp			# Day toan tu moi vao
lowerPrecedence:	# Nap vao + - va top la * / %
	jal opToPostfix			# Pop top cua Operator sang Postfix
	j continuePlusMinus		# Loop again
inputToOp:			# Day input sang Operator
	add $t6,$t6,1			# Tang top cua Operator offset
	add $t8,$t6,$t3			# Load dia chi cua top Operator 
	sb $t4,($t8)			# Store input vao Operator
	j scanInfix
opToPostfix:			# Pop top cua Operator roi day vao Postfix
	addi $t5,$t5,1			# Tang top cua Postfix offset
	add $t8,$t5,$t2			# Load dia chi cua top Postfix 
	addi $t7,$t7,100		# Giai ma operator + 100
	sb $t7,($t8)			# Store operator vao Postfix
	addi $t6,$t6,-1			# Giam top cua Operator offset
	jr $ra
matchBracket:			# Loai bo 1 cap dau ngoac tuong ung
	addi $t6,$t6,-1			# Giam top cua Operator offset
	j scanInfix
popAll:				# Pop moi Operator sang Postfix
	jal numberToPost
	beq $t6,-1,finishScan		# Operator trong --> finish
	add $t8,$t6,$t3			# Load dia chi top Operator 
	lb $t7,($t8)			# Load gia tri byte cua top Operator
	beq $t7,'(',wrongInput		# Dau ngoac khong tuong ung --> error
	beq $t7,')',wrongInput
	jal opToPostfix
	j popAll			# Loop cho den khi Operator rong
store1Digit:
	beq $s7,4,wrongInput		# Nhan vao so sau )
	addi $s4,$t4,-48		# Store chu so thu nhat nhu 1 so
	add $t9,$zero,1			# Chuyen trang thai sang 1 chu so
	li $s7,1
	j scanInfix
store2Digit:
	beq $s7,4,wrongInput		# Nhan vao so sau )
	addi $s5,$t4,-48		# Store chu so thu 2 nhu 1 so
	mul $s4,$s4,10
	add $s4,$s4,$s5			# Stored number = first digit * 10 + second digit
	add $t9,$zero,2			# Chuyen trang thai sang 2 chu so
	li $s7,1
	j scanInfix
numberToPost:
	beq $t9,0,endnumberToPost
	addi $t5,$t5,1
	add $t8,$t5,$t2			
	sb $s4,($t8)			# Store so trong Postfix
	add $t9,$zero,$zero		# Chuyen trang thai sang 0 chu so
	endnumberToPost:
	jr $ra
