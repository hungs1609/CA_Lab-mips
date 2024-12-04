.data
	#cau truc cau lenh: 'addi $t1 $t2 0' 
	library: .asciiz "lw****140-lb****140-sw****140-sb****140-addi**112-add***111-addiu*112-and***111-andi**112-beq***113-bne***113-div***110-divu**110-j*****300-jal***300-lui***120-mfhi**100-mflo**100-mul***111-nop***000-nor***111-or****111-ori***112-sll***111-slt***111-slti**112-sub***111-subu**111-xor***111-xori**112-"
	register: .asciiz "$zero-$at-$v0-$v1-$a0-$a1-$a2-$a3-$t0-$t1-$t2-$t3-$t4-$t5-$t6-$t7-$t8-$t9-$s1-$s2-$s3-$s4-$s5-$s6-$s7-$k0-$k1-$gp-$sp-$fp-$ra-$0-$1-$2-$3-$4-$5-$6-$7-$8-$9-$10-$11-$12-$13-$14-$15-$16-$17-$18-$19-$20-$21-$22-$23-$24-$25-$26-$27-$28-$29-$30-$31-"
	#quy uoc cac toan hang: 1 registers, 2 constant, 3 label, 4 imm(rs)
	menu_msg:       .asciiz "\n>>>>>>>>>>MENU<<<<<<<<<<\n1. Kiem tra code\n2. Thoat \nLua chon: "
	menu_error_msg: .asciiz "\nKhong co trong menu. Hay chon lai!\n"
	msg1: "Nhap vao mot dong lenh hop ngu: "
	msg2: "Opcode: "
	msg3: "Toan hang: "
	msg4: "Cau lenh: "
	msg5: "\nChay tiep chuong trinh (Y/N): "
	msg_valid:" hop le\n"
	msg_invalid:" khong hop le\n"
	data: .space 200 	# luu input
	temp: .space 50 	# luu cac thanh phan cau lenh sau khi cat
	temp2: .space 10 	# luu khuon dang cau lenh
	temp3: .space 50 	# luu thanh phan sau khi cat duoc o offset(base)

.text
m_menu_start:
	li $v0, 4
	la $a0, menu_msg 		#Hien menu
	syscall
	
	# Doc so tu menu
	li $v0, 5
	syscall
	
	beq $v0, 2, out		# 2: Thoat
	beq $v0, 1, m_menu_end		# 1: Nhay đen chuong trinh
	
	li $v0, 4
	la $a0, menu_error_msg	 	# input sai
	syscall
	
	j m_menu_start

m_menu_end:
# >>>>>>>>>> READ INPUT <<<<<<<<<< 
inputData:
	jal  readData
	nop
	
readData:	# doc lenh nhap vao tu ban phim
	li	$v0, 4 		# in msg ra run i/o
	la	$a0, msg1
	syscall
	li	$v0, 8
	la	$a0, data 	# luu chuoi nhap vao -> data
	li	$a1, 200 	# so ky tu toi da doc vao
	syscall

main:
	la	$s0, data 		# dia chi data
	la	$s1, temp 		# dia chi chuoi sau khi cat 
	add	$s2, $zero, $zero 	# i = 0 data
	add	$s3, $zero, $zero 	# dem thanh phan: 1 - opcode, 2, 3, 4 - toan hang, 5 check ki tu thua
	la	$s4, temp2 		# dia chi temp2

# lap 5 lan de lay cac thanh phan cau lenh 
# 1 - lay opcode
# 2, 3, 4 - lay toan hang
# 5 - check ki tu thua
getComponent:	
	addi	$s3, $s3, 1
	beq	$s3, 6, exit   		# dem >= 6 -> exit
	add	$a0, $s0, $zero 	# truyen bien vao cutComponent
	add	$a1, $s1, $zero		# dia chi temp
	add	$a2, $s2, $zero		# dia chi trong data
	jal	cutComponent
	add	$s2, $v0, $zero
	beq	$s3, 5, endGetComponent # dem = 5 -> check ket thuc
	beq	$s3, 1, opcode 		# dem = 1 -> check ket thuc 
	j	checkToanHang 		# dem = 2, 3, 4 -> check toan hang

opcode:
	add	$a0, $s1, $zero 	# truyen vao temp
	la	$a1, library 		# opcode chuan
	jal	checkOpcode
	add	$s5, $v0, $zero 	# check
	li	$v0, 4
	la	$a0, msg2	
	syscall
	li	$v0, 4
	la	$a0, temp
	syscall
	j	check

checkToanHang:
	addi	$t0, $s3, -2 		# k - stt cua toan hang 
	add	$t0, $s4, $t0 		# t0 = dia chi temp2[k]
	lb	$t1, 0($t0) 		# t1 = temp2[k]
	beq	$t1, 48, null 		# null - 0
	beq	$t1, 49, reg 		# register - 1
	beq	$t1, 50, const 		# constant - 2
	beq	$t1, 51, label 		# label - 3
	beq	$t1, 52, immrs 		# imm(rs) - 4

reg:
	add	$a0, $s1, $zero         # i
	jal	checkReg
	add	$s5, $v0, $zero
	j	print
	
const:
	add	$a0, $s1, $zero
	jal	checkConstant
	add	$s5, $v0, $zero
	j	print

label:
	add	$a0, $s1, $zero
	jal	checkLabel
	add	$s5, $v0, $zero
	j	print

immrs:
	add	$a0, $s1, $zero
	jal 	checkImmRs
	add	$s5, $v0, $zero
	j	print

print:
	li	$v0, 4
	la	$a0, msg3
	syscall
	li	$v0, 4
	la	$a0, temp
	syscall
	j	check

null:
endGetComponent:
	add	$s3, $zero, 5			# dem = 5 de kiem tra ki tu thua
	li	$v0, 4	
	la	$a0, msg4
	syscall	
	add	$t0, $s1, $zero 		# check xem con ki tu thua hay ko	
	lb	$t2, 0($t0)			
	bne	$t2, $zero, invalid		# neu sau toan hang cuoi cung khac rong thi sai
	j	valid

check:
	beq	$s5, $zero, invalid

valid:	# in ra hop le
	li	$v0, 4
	la	$a0, msg_valid
	syscall
	j	getComponent

invalid: #in ra khong hop le
	li	$v0, 4
	la	$a0, msg_invalid
	syscall

exit:
repeatMain: #lap lai code
	li	$v0, 4
	la	$a0, msg5
	syscall
	li	$v0, 8
	la	$a0, data
	li	$a1, 200
	syscall

checkRepeat: # kiem tra so nhap vao
	add	$t0, $a0, $zero 	# ki tu dau tien
	lb	$t0, 0($t0)
	beq	$t0, 78, out		# = N
	beq	$t0, 110, out		# = n
	beq	$t0, 89, readData	# = 1 -> lap lai
	beq	$t0, 121, readData
	j	repeatMain 

out: # ket thuc
	li $v0, 10 #exit
	syscall

#---------------------------------------------------------------
# cutComponent: cat cac thanh phan cau lenh (bo qua cac ky tu space, dau phay, \t)
# a0 -> dia chi chuoi data
# a1 -> dia chi temp - chuoi chua ket qua sau cut
# a2 -> vi tri bat dau cat
# v0 -> vi tri ket thuc cat
#---------------------------------------------------------------
cutComponent: 
	addi	$sp, $sp, -8
	sw	$ra, 0($sp) 			# luu lai dia chi truoc khi nhay
	sw	$s0, 4($sp) 			# luu lai j dem temp

init1: # khoi tao j moi
	add	$s0, $zero, $zero 		# j = 0 

_X: # check ki tu "\t", ",", " ", check xuong dong 
	add	$t0, $a0, $a2 			# dia chi data[i]
	lb	$t1, 0($t0)			# t1 = data[i]
	beq	$t1, 9, update1 		# \t
	beq	$t1, 32, update1 		# ' '
	beq	$t1, 44, update1 		# ','
	beq	$t1, 10, endF1 			# \n
	j	loadChar

update1: # bo qua ki tu hien tai
	addi	$a2, $a2, 1
	j	_X

loadChar: # load ki tu nhan duoc vao mang temp
	beq	$t1, 9, endF1			
	beq	$t1, 32, endF1			
	beq	$t1, 44, endF1			
	beq	$t1, 10, endF1			
	beq	$t1, $zero, endF1 		# ki tu ket thuc
	add	$t0, $a1, $s0 			# dia chi temp
	sb	$t1, 0($t0) 			# temp[j]
	addi	$s0, $s0, 1 			# j++
	addi	$a2, $a2, 1 			# i++
	add	$t0, $a0, $a2 			# dia chi data[i]
	lb	$t1, 0($t0) 			# data[i]
	j	loadChar

endF1:	# ket thuc cat thanh phan, lay lai cac du lieu da luu trong stack, quay lai dia chi cu da luu
	add	$t0, $a1, $s0 
	sb	$zero, 0($t0) 
	add	$v0, $a2, $zero 
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra

#---------------------------------------------------------------
# checkOpcode: check opcode co hop le ko -> lay khuon dang toan hang
# a0 -> dia chi opcode cat duoc
# a1 -> dia chi chuoi opcode chuan
# v0 -> 0|1 -> ko hop le | hop le
#---------------------------------------------------------------

checkOpcode:
	addi	$sp, $sp, -16
	sw	$ra, 0($sp)			# luu lai dia chi cu de quay lai
	sw	$s0, 4($sp) 			# j temp
	sw	$s1, 8($sp) 			# i opcode
	sw	$s2, 12($sp) 			# check = 0

initcheckOpcode: # khoi tao cac du lieu
	add	$s0, $zero, $zero		# j = 0
	add	$s1, $zero, $zero		# i = 0
	add	$s2, $zero, $zero 		# flag danh dau opcode hop le hay khong 

loopCheckOpcode: # bat dau lay tung ki tu so sanh voi tung ki tu trong opcode chuan
	add	$t0, $a1, $s1 			# dia chi chuoi opcode chuan 
	lb	$t1, 0($t0) 			# opcode[i]
	beq	$t1, $zero, endFCheckOpcode 	# ket thuc opcode nhung ko co opcode phu hop
	add	$t0, $a0, $s0 			# dia chi chuoi opcode
	lb	$t2, 0($t0) 			# temp[j]
	addi	$s0, $s0, 1			# j = j+1
	addi	$s1, $s1, 1			# i = i+1
	beq	$t1, $t2, loopCheckOpcode 	# temp[j] = opcode[i] -> loop
	bne	$t1, 42, updateNext 		# neu opcode[i] != '*' -> sai tu nay -> check tu tiep theo
	bne	$t2, $zero, updateNext 		# neu temp[j] != '\0' -> check tu tiep theo
	j	assign

updateNext: # bo qua nhung ki tu tiep trong libary
	add	$s0, $zero, $zero 		# xet tu temp[0] 
	addi	$t0, $zero, 10 			# so ki tu trong 1 opcode
	div	$s1, $t0 			# i/10
	mflo	$t1 				# lay lay thuong
	addi	$t1, $t1, 1			# them 1 vao thuong moi lay duoc
	mul	$s1, $t1, $t0			# nhan 10 de lay duoc dia chi của opcode tiep theo trong libary
	j	loopCheckOpcode

assign: # chuan bi luu opcode chuan
	addi	$s2, $zero, 1			# opcode hop le -> flag = 1
	la	$a0, temp2 			# gan khuon dang
	add	$s0, $zero, $zero 		# dem temp2[j] 

_X42: 	# bo qua dau "*" trong libary
	addi	$s1, $s1, 1			# i = i+1
	add 	$t0, $a1, $s1
	lb	$t1, 0($t0) 			# opcode[i]
	beq	$t1, 42, _X42			# opcode[i] = '*' -> bo qua

loopAssign: # gan khuon dang cua opcode vao temp2
	add 	$t0, $a0, $s0 			# dia chi temp2[i]
	sb	$t1, 0($t0)
	addi	$s1, $s1, 1			# i = i+1
	addi	$s0, $s0, 1			# j = j+1
	add 	$t0, $a1, $s1		
	lb	$t1, 0($t0) 			# opcode[i]
	bne	$t1, 45, loopAssign 		# opcode[i] != '-' -> tiep tuc gan
	add 	$t0, $a0, $s0
	sb	$zero, 0($t0) 			# gan '\0' cho temp2[i]

endFCheckOpcode: # ket thuc kiem tra opcode, lay lai cac du lieu da luu trong stack, quay lai dia chi cu
	add	$v0, $s2, $zero
	lw	$ra, 0($sp)
	lw	$s0, 4($sp) 			# j temp
	lw	$s1, 8($sp) 			# i opcode
	lw	$s2, 12($sp) 			# check = 0
	addi	$sp, $sp, 16
	jr 	$ra

#---------------------------------------------------------------
# checkReg: ktra register co hop le hay ko?
# a0 -> dia chi temp - chuoi chua gia tri can check
# v0 -> 0|1: ko hop le | hop le
#---------------------------------------------------------------

checkReg:
	addi	$sp, $sp, -20
	sw	$ra, 0($sp) 
	sw	$s0, 4($sp) 		# dia chiopcode chuan
	sw	$s1, 8($sp) 		# i
	sw	$s2, 12($sp) 		# j temp[j]
	sw	$s3, 16($sp) 		#check

initCheckReg: # khoi tao cac du lieu can thiet 
	la	$s0, register
	add	$s1, $zero, $zero 	# i
	add	$s2, $zero, $zero 	# j
	add	$s3, $zero, $zero 	# flag = 0

loopCheckReg: # bat dau so sanh tung ki tu luu trong temp voi thu vien register
	add	$t0, $s0, $s1 		# dia chi register[i]
	lb	$t1, 0($t0) 		# register[i]
	beq	$t1, $zero, endCheckReg # ket thuc chuoi register khi temp rong
	add	$t0, $a0, $s2 		# dia chi temp[j]
	lb	$t2, 0($t0)		# temp[j]
	addi	$s1, $s1, 1
	addi	$s2, $s2, 1
	beq	$t1, $t2, loopCheckReg 	# bang nhau -> loop
	bne	$t1, 45, updateNextReg	# reg[i] = '-'
	beq	$t2, $zero, true 	# temp[j] = '\0'

updateNextReg: # chuyen sang register tiep theo trong thu vien register khi kiem tra sai 
_X45: # skip cac ki tu sau cua thu vien libary ma khong can so sanh
	add	$t0, $s0, $s1 		# dia chi reg[i]
	lb	$t1, 0($t0)		# reg[i]
	beq	$t1, 45, false 		# neu ki tu hien tai la "-" thi ket thuc viec skip ki tu de tiep tuc so sanh
	add	$s1, $s1, 1
	j	_X45

false: # chuyen sang thanh phan tiep theo cua thu vien register
	addi	$s1, $s1, 1
	add	$s2, $zero, $zero
	j	loopCheckReg

true:
	addi	$s3, $zero, 1		# flag = 1

endCheckReg:
	add	$v0, $s3, $zero
	lw	$ra, 0($sp) 
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	addi	$sp, $sp, 20
	jr	$ra

#---------------------------------------------------------------
# checkConstant: ktra 1 hang so co hop le hay ko
# a0 -> temp: dia chi chuoi chua gia tri can check
# v0 -> 0|1 -> ko hop le | hop le
#---------------------------------------------------------------

checkConstant:
	addi	$sp, $sp, -12
	sw	$ra, 0($sp) 
	sw	$s0, 4($sp) 		
	sw	$s1, 8($sp) 		

initCheckConstant:
	add	$s0, $zero, $zero	# i
	addi	$s1, $zero, 1		# flag = 1

firstChar: # isNumber
	add	$t0, $a0, $s0		# dia chi tenp[i]
	lb	$t1, 0($t0) 		# temp[i]
	beq	$t1, 43, dkien 		# +
	beq	$t1, 45, dkien 		# -

	j	isNumber

dkien: # check sau dau +, - co so khong
	add	$s0, $s0, 1		# i++
	add	$t0, $a0, $s0        	# dia chi temp[i]
	lb	$t1, 0($t0)      	# temp[i]
	bne	$t1, $zero, isNumber
	j	falseCheckConstant
	
loopCheckConstant:
	add	$s0, $s0, 1			# i++
	add	$t0, $a0, $s0			# dia chi temp[i]
	lb	$t1, 0($t0) 			# temp[i]
	bne	$t1, $zero, isNumber
	beq	$s0, $zero, falseCheckConstant 	# co ky tu hay ko
	j	endCheckConstant

isNumber: # neu ma ASCII cua ki tu nhan duoc khong thuoc khoang tu 48 den 58 thi sai 
	slti	$t0, $t1, 48 			
	bne	$t0, $zero, falseCheckConstant  # temp[i] < 48 -> sai
	slti	$t0, $t1, 58			
	beq	$t0, $zero, falseCheckConstant	# temp[i] >= 58 -> sai
	j	loopCheckConstant

falseCheckConstant:
	add	$s1, $zero, $zero		# flag = 0

endCheckConstant:
	add	$v0, $s1, $zero
	lw	$ra, 0($sp) 
	lw	$s0, 4($sp) 		# i
	lw	$s1, 8($sp) 		# check
	addi	$sp, $sp, 12
	jr	$ra

#---------------------------------------------------------------
# checkLabel: ktra 1 label co hop le hay ko
# a0 -> temp -> dia chi chuoi chua gia tri can ktra
# v0 -> 0|1 -> ko hop le | hop le
#---------------------------------------------------------------

checkLabel:
	addi	$sp, $sp, -12
	sw	$ra, 0($sp) 
	sw	$s0, 4($sp) 	
	sw	$s1, 8($sp) 		

initCheckLabel:
	add	$s0, $zero, $zero	# i
	addi	$s1, $zero, 1		# flag = 1

firstCharLabel: #lay ki tu dau cua label
	add	$t0, $a0, $s0
	lb	$t1, 0($t0) 		# temp[i]
	j	isUpcase 		# nhay den ham check chu in hoa 

loopCheckLabel:
	add	$s0, $s0, 1
	add	$t0, $a0, $s0
	lb	$t1, 0($t0) 		# temp[i]
	beq	$t1, $zero, endCheckLabel

isNumberL: # 48 -> 57
	slti	$t0, $t1, 48
	bne	$t0, $zero, falseCheckLabel
	slti	$t0, $t1, 58
	beq	$t0, $zero, isUpcase
	j	loopCheckLabel

isUpcase: # 65 -> 90 ma ASCII cua chu in ho
	slti	$t0, $t1, 65
	bne	$t0, $zero, falseCheckLabel	# temp[i] < 65 -> sai
	slti	$t0, $t1, 91
	beq	$t0, $zero, _			# temp[i] >= 91 -> check xem co = '_'
	j	loopCheckLabel

_:
	bne	$t1, 95, isLowcase		# nhay den ham check chu in thuong
	j	loopCheckLabel

isLowcase: # 97  -> 122
	slti	$t0, $t1, 97
	bne	$t0, $zero, falseCheckLabel	# temp[i] < 97 -> sai
	slti	$t0, $t1, 123	
	beq	$t0, $zero, falseCheckLabel	# temp[i] >= 123 -> sai
	j	loopCheckLabel

falseCheckLabel:
	add	$s1, $zero, $zero		# flag = 0

endCheckLabel:
	add	$v0, $s1, $zero
	lw	$ra, 0($sp) 
	lw	$s0, 4($sp) # i
	lw	$s1, 8($sp) # check
	addi	$sp, $sp, 12
	jr	$ra

#---------------------------------------------------------------
# checkImmRs: kiem tra 1 cum offset(base) xem co hop le hay ko? vd: 12($t0)
# a0 -> dia chi temp - chuoi chua gia tri can ktra
# v0 -> 0|1 -> ko hop le | hop le
#---------------------------------------------------------------

checkImmRs:
	addi	$sp, $sp, -28
	sw	$ra, 0($sp)
	sw	$s0, 4($sp) 			# temp
	sw	$s1, 8($sp) 			# i
	sw	$s2, 12($sp) 			# temp3
	sw	$s3, 16($sp) 			# check
	sw	$s4, 20($sp) 			# space 32

initCheckImmRs:
	add	$s0, $a0, $zero 		# luu dia chi temp -> s0
	add	$s1, $zero, $zero		# i
	la	$s2, temp3			# cum offset(base) sau khi cat
	add	$s3, $zero, $zero		# flag = 0
	addi	$s4, $zero, 32			# s4 = ' ' de thay vao vi tri cua dau ( )
	
test:
	add	$t0, $s0, $s1 			# dia chi temp[i]
	lb	$t1, 0($t0)			# temp[i]
	addi	$s1, $s1, 1 			# i++
	beq	$t1, $zero, endTest
	beq	$t1, 40, open			# '('
	beq	$t1, 41, close			# ')'
	j	test

open: #thay dau "(" thanh " "
	bne	$s3, $zero, falseCheckImmRs	# flag != 0 -> sai
	sb	$s4, 0($t0) 			# luu ' ' thay '('
	addi	$s3, $s3, 1 			# flag = 1
	j	test

close: #thay dau ")" thanh " "
	bne	$s3, 1, falseCheckImmRs		# flag != 1 -> sai
	sb	$zero, 0($t0) 			# luu '\0' thay ')'	
	addi	$s3, $s3, 1 			# s3 = 2
	add	$t0, $s0, $s1 			# dia chi temp[i]
	lb	$t1, 0($t0)			# temp[i]
	bne	$t1, $zero, falseCheckImmRs	# temp[i] != '\0' -> sai, check xem co ki tu sau dau ")" 

endTest:	
	bne	$s3, 2, falseCheckImmRs		# flag != 2 -> sai

init2:
	add	$s3, $zero, $zero 		# flag = 0
	add	$s1, $zero, $zero 		# i = 0 

mainCheck:
	add	$a0, $s0, $zero 		# truyen bien vao cutComponent
	add	$a1, $s2, $zero
	add	$a2, $s1, $zero
	jal	cutComponent
	add	$s1, $v0, $zero 		# i ket thuc cat
	add	$a0, $s2, $zero 		# truyen temp3
	jal	checkConstant
	add	$s3, $v0, $zero 		# lay ket qua 0|1
	beq	$s3, $zero, falseCheckImmRs
	add	$a0, $s0, $zero 		# truyen bien vao cutComponent
	add	$a1, $s2, $zero
	add	$a2, $s1, $zero
	jal	cutComponent
	add	$s1, $v0, $zero
	add	$a0, $s2, $zero
	jal	checkReg
	add	$s3, $v0, $zero
	bne	$s3, $zero, trueCheckImmRs

falseCheckImmRs: # flag = 0
	add	$s3, $zero, $zero
	j	endCheckImmRs

trueCheckImmRs: # falg = 1
	addi	$s3, $zero, 1

endCheckImmRs:
	add	$v0, $s3, $zero
	lw 	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	lw	$s4, 20($sp) # space 32
	addi	$sp, $sp, 24
	jr	$ra
