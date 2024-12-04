.data
	CharPtr: .word 0	# Bien con tro, tro toi kieu asciiz
	BytePtr: .word 0	# Bien con tro, tro toi kieu Byte
	WordPtr: .word 0	# Bien con tro, tro toi mang kieu Word
	ArrayPtr: .word 0	# Bien con tro, tro toi mang 2 chieu
	CharPtr1: .word 0
	CharPtr2: .word 0
	Enter: .asciiz "\n"
	row: .word 1
	col: .word 1		# tranh nhap nhang
	menu: .asciiz "1.Malloc char\n2.Malloc Byte\n3.Malloc Word\n4.Gia tri cac bien con tro\n5.Dia chi cac bien con tro\n6.Copy con tro xau\n7.Free Storage\n8.Bo nho da cap phat\n9.Malloc 2D word Array\n10.Set Array\n11.Get Array\nChon 1-11:"
	mal: .asciiz "\nso hang va cot phai nho hon 1000"
	char: .asciiz "\n Nhap so phan tu cua mang char:"
	word: .asciiz "\n Nhap so phan tu cua mang word:"
	byte: .asciiz "\n Nhap so phan tu cua mang byte:"
	arr1: .asciiz "\n Nhap so cot cua mang array:"
	arr2: .asciiz "\n Nhap so hang cua mang array:"
	in_row: .asciiz "\n Nhap i:"
	in_col: .asciiz "\n Nhap j:"
	in_value: .asciiz "\n Nhap gia tri de gan:"
	out_value:.asciiz "\n Gia tri tra ve:"
	value_annoucer: .asciiz "\n Gia tri tai cac bien con tro CharPtr BytePtr WordPtr ArrayPtr la:"
	addr_annoucer: .asciiz "\n Dia chi cua cac bien con tro CharPtr BytePtr WordPtr ArrayPtr la:"
	success:  .asciiz "\n Malloc success. Dia chi vung nho duoc cap phat : "
	annoucer: .asciiz "\n Kich thuoc cua vung nho vua duoc cap phat la "
	bound: .asciiz "\n index out of bound"
	null: .asciiz "\nNull Pointer Exception. Chua khoi tao mang!!!!"
	free_storage_annoucer: .asciiz "\nDa giai phong bo nho cap phat! " 
	storage_annoucer: .asciiz "\nBo nho da cap phat: " 
	bytes: .asciiz " bytes."
	too_big: .asciiz "\n gia tri nhap vao qua lon!!"
	too_small: .asciiz "\n Gia tri nhap vao nho hon hoac bang 0"
	example: .asciiz "example string"
	print_matrix: .asciiz  "\nSo hang va cot cua mang 2 chieu la:"
.kdata
	Sys_TheTopOfFree: .word 1	# Bien chua dia chi dau tien cua vung nho con trong
	Sys_MyFreeSpace: 		# Vung khong gian tu do, dung de cap bo nho cho cac bien con tro
.text
	jal SysInitMem			#Khoi tao vung nho cap phat dong
main:
show_menu:
	la $a0,menu
	jal IntDialog
	move $t0, $a0
	beq $t0, 1, op1
	beq $t0, 2, op2
	beq $t0, 3, op3
	beq $t0, 4, op4
	beq $t0, 5, op5
	beq $t0, 6, op6
	beq $t0, 7, op7
	beq $t0, 8, op8
	beq $t0, 9, op9
	beq $t0, 10, op10
	beq $t0, 11, op11
	j end
	
op1:#Malloc char
	la $a0,char 
	jal IntDialog
	jal Check_value
	move $a1,$a0 
	la $a0,CharPtr
	li $a2,1
	jal malloc		# $v0 = dia chi bat dau cap phat boi malloc
	move $t0,$v0 
	la $a0,success
	li $v0,4
	syscall 		# in thong bao malloc success
	move $a0,$t0
	li $v0,34
	syscall 		# mang bat dau tai dia chi : $t0
	la $a0,annoucer
	li $v0,4
	syscall 		# in thong bao kich thuoc con tro
	move $a0,$t7		# $a0 = $t7 = kich thuoc cua mang cap phat
	li $v0,34
	syscall
	j main
op2:#Malloc byte
	la $a0,byte
	jal IntDialog
	jal Check_value
	move $a1,$a0
	la $a0,BytePtr
	li $a2,1
	jal malloc
	move $t0,$v0 
	la $a0,success
	li $v0,4
	syscall
	move $a0,$t0
	li $v0,34 
	syscall
	la $a0,annoucer
	li $v0,4
	syscall
	move $a0,$t7
	li $v0,34
	syscall
	j main
op3:#Malloc word
	la $a0,word
	jal IntDialog
	jal Check_value
	move $a1,$a0
	la $a0,WordPtr
	li $a2,4
	jal malloc
	move $t0,$v0
	la $a0,success
	li $v0,4
	syscall
	move $a0,$t0
	li $v0,34
	syscall 
	la $a0,annoucer
	li $v0,4
	syscall
	move $a0,$t7
	li $v0,34
	syscall
	j main
op4:#Print value of pointer
	la $a0,value_annoucer
	li $v0,4
	syscall 
	li $a0,0
	jal value
	jal print_value_or_address
	li $a0,1
	jal value
	jal print_value_or_address
	li $a0,2
	jal value
	jal print_value_or_address
	li $a0,3
	jal value
	jal print_value_or_address
	j main
op5:#Print address of pointer
	la $a0,addr_annoucer
	li $v0,4
	syscall 
	li $a0,0
	jal address
	jal print_value_or_address
	li $a0,1
	jal address
	jal print_value_or_address
	li $a0,2
	jal address
	jal print_value_or_address
	li $a0,3
	jal address
	jal print_value_or_address
	j main
	
# ----------------------------------
# copy CharPtr1 -> CharPtr2
# print CharPtr2
# a1 = Ptr1
# a2 = Ptr2 -> Sys_TheTopOfFree
# ----------------------------------

op6:#copy string pointer
copy:   
	la $t0,CharPtr1
	la $t1, example
	sw $t1,($t0)		#CharPtr1 -> example
	la $a2,CharPtr2
	la $a0,Sys_TheTopOfFree
	lw $t5,($a0)
	sw $t5,($a2)		#CharPtr2 -> Top
	lw $t2,($a2)
	lw $t4, ($a0)
copy_loop:
	lb $t3,($t1)
	sb $t3,($t2)		# copy vlueCharPtr1 vao vung bo nho tu do
	addi $t4, $t4,1		# tang len de tinh SystopFree
	addi $t1,$t1,1		# charPtr1[i++]
	addi $t2,$t2,1		# charPtr2[i++]
	beq $t3,'\0',exit_copy
	j copy_loop
exit_copy:	
	sw $t4,($a0)		# SystopFree moi
	la $a2, CharPtr2
	lw $a0, ($a2)
	li $v0,4
	syscall			# in ra noi dung CharPtr2 tro toi
	la $a0, Enter
	syscall 
	j main
op7:#freeStorage
	jal freeStorage
	la $a0,free_storage_annoucer
	li $v0,4
	syscall
	j main
op8:#show storage
	la $a0,storage_annoucer
	li $v0,4
	syscall
	jal storage
	move $a0,$v0
	li $v0,1
	syscall	
	la $a0,bytes
	li $v0,4
	syscall	
	j main
op9:#Malloc 2D Array
	la $a0,arr1
	jal IntDialog		#read in_row
	move $s0,$a0 
	la $a0,arr2
	jal IntDialog		# read col
	move $a1,$s0		# malloc2 2nd param: row
	move $a2,$a0		# malloc2 3rd param: col
	la $a0,ArrayPtr
	jal Malloc2		# call malloc2
	move $t0,$v0		# save return value of malloc
	la $a0,success
	li $v0,4
	syscall
	move $a0,$t0
	li $v0,34
	syscall
	li $v0, 4
	la $a0, Enter
	syscall
	move $a0, $s5
	li $v0, 34
	syscall
	
	li $v0, 11
	li $a0,','
	syscall
	
	move $a0, $s6
	li $v0, 34
	syscall
	j main
op10:#setter
	la $a0,ArrayPtr
	lw $s7,0($a0) # Luu **ArrayPtr vao $s7
	beqz $s7,nullptr # if *ArrayPtr==0 error null pointer
	la $a0,in_row
	jal IntDialog # get row
	move $s0,$a0
	la $a0,in_col
	jal IntDialog  #get col
	move $s1,$a0
	la $a0,in_value
	jal IntDialog  #get val
	move $a3,$a0
	move $a1,$s0
	move $a2,$s1
	move $a0,$s7
	jal SetArray # SetArray($a0:**ArrayPtr,$a1:hang,$a2:cot,$a3:Gia tri)
	j main
op11:#getter
	la $a0,ArrayPtr
	lw $s1,0($a0)
	beqz $s1,nullptr # if *ArrayPtr==0 error null pointer
	la $a0,in_row
	jal IntDialog # get row
	move $s0,$a0
	la $a0,in_col
	jal IntDialog  #get col
	move $a2,$a0
	move $a1,$s0
	move $a0,$s1
	jal GetArray #GetArray(*ArrayPointer,row,col)
	move $s0,$v0 # save return value of GetArray
	la $a0,out_value
	li $v0,4
	syscall
	move $a0,$s0
	li $v0,34
	syscall
	j main
	
#------------------------------------------
#Giai phong bo nho cap phat cho cac bien con tro
freeStorage:
	la $t9,Sys_TheTopOfFree
	la $t8,Sys_MyFreeSpace
	sw $t8, 0($t9)
	la $t0,CharPtr		# lay dia chi cua bien con tro dau tien
	mul $t2,$t2,0
loop:	
	sll $t1, $t2, 2 
	addi $t2, $t2, 1
	addu $t0, $t0, $t1	# lay dia chi tai *CharPtr + 4*$a0
	sw $t3, 0($t0)		# lay gia tri cua *---Ptr 
	beq $t2,4,exit_free
	j loop
exit_free:	
	jr $ra
#------------------------------------------
# Tinh tong luong bo nho da cap phat
# @param: none
# @return: $v0 dung luong bo nho da cap phat (byte)
#------------------------------------------
storage:
	la $t9,Sys_TheTopOfFree
	lw $t9,0($t9)
	la $t8,Sys_MyFreeSpace
	sub $v0, $t9, $t8
	jr $ra
	
#------------------------------------------
# InputDialogInt
# Lap den khi nao nhap vao thanh cong
#------------------------------------------
IntDialog:
	move $t0,$a0		# luu dia chi cua chuoi ki tu
	li $v0,51
	syscall 
	beq $a1,0,done		# success
	beq $a1,-2,end		# thoat chuong trinh khi nguoi dung chon "cancel"
	move $a0,$t0		# lay lai dia chi cua chuoi ki tu
	j IntDialog
done:
	jr $ra 
	
#------------------------------------------
# check: 0<input<1000?
#------------------------------------------
Check_value:
	bge $a0,1000,over_value
	blez $a0,negative
	jr $ra
over_value:
	la $a0,too_big
	j error
negative:
	la $a0,too_small
	j error
	
#------------------------------------------
# Ham khoi tao cho viec cap phat dong
# @param: none
# @detail Danh dau vi tri bat dau cua vung nho co the cap phat duoc
#------------------------------------------
SysInitMem: 
	la $t9, Sys_TheTopOfFree	# Lay con tro chua dau tien con trong, khoi tao
	la $t7, Sys_MyFreeSpace		# Lay dia chi dau tien con trong, khoi tao
	sw $t7, 0($t9)			# Luu lai
	jr $ra
	
#------------------------------------------
# Ham cap phat bo nho dong cho cac bien con tro
# @param: [in/out] $a0 Chua dia chi cua bien con tro can cap phat
# Khi ham ket thuc, dia chi vung nho duoc cap phat se luu tru vao bien con tro
# @param: $a1 So phan tu can cap phat
# @param: $a2 Kich thuoc 1 phan tu, tinh theo byte
# @return: $v0 Dia chi vung nho duoc cap phat
#------------------------------------------
malloc: 
	la $t9, Sys_TheTopOfFree	# luu dia chi con trong vao trong $t9
	lw $t8, 0($t9)			# Lay dia chi dau tien con trong trong $t9(lay dia chi cua dia chi (C: **))
	bne $a2, 4, skip
	addi $t8,$t8,3			# truong hop so khong chia het cho 4
	andi $t8, $t8, 0xfffffffc	# lay dia chi chia het cho 4be nhat co the
skip:
	sw $t8, 0($a0)			# Cat dia chi do vao bien con tro
	addi $v0, $t8, 0		# Dong thoi la ket qua tra ve cua ham
	mul $t7, $a1,$a2		# Tinh kich thuoc cua mang can cap phat
	add $t8, $t8, $t7		# Tinh dia chi dau tien con trong
	sw $t8, 0($t9)			# Luu tro lai dia chi dau tien do vao bien Sys_TheTopOfFree
	jr $ra

#------------------------------------------
# Ham cap phat bo nho dong cho mang 2 chieu
# @param: [in/out] $a0 Chua dia chi cua bien con tro can cap phat
# Khi ham ket thuc, dia chi vung nho duoc cap phat se luu tru vao bien con tro
# @param: $a1 So hang
# @param: $a2 so cot
# @return: $v0 Dia chi vung nho duoc cap phat
#------------------------------------------
Malloc2:
	addi $sp,$sp,-4			# them 1 ngan trong vao stack
	sw $ra, 4($sp)			# push $ra
	bgt $a1,1000,mal_err		# kiem tra loi so luong
	bgt $a2,1000,mal_err		# cua hang (cot)
	la $s0,row			# luu so hang va so cot row[0]= row, row[1]=col
	sw $a1,0($s0)
	sw $a2,4($s0)
	move $s5, $a1			#hang
	move $s6, $a2			#cot
	mul $a1,$a1,$a2
	li $a2,4
	jal malloc
	lw $ra, 4($sp)
	addi $sp,$sp,4
	jr $ra
	
#------------------------------------------
# lay gia tri cua trong mang
# @param [in] $a0 Chua dia chi bat dau mang
# @param [in] $a1 hang (i)
# @param [in] $a2 cot (j)
# @return $v0 gia tri tai hang a1 cot a2 trong mang
#	------------------------------------------
GetArray:
	la $s0,row		# s0 =ptr so ha`ng
	lw $s1,0($s0)		#s1 so hang
	lw $s2,4($s0)		#s2 so cot
	bge $a1,$s1,bound_err 
	bge $a2,$s2,bound_err 
	mul $s0,$s2,$a1
	addu $s0,$s0,$a2 	#s0= i*col +j
	sll $s0, $s0, 2
	addu $s0,$s0,$a0 	#s0 = *array + (i*col +j)*4
	lw $v0,0($s0)
	jr $ra
	
#------------------------------------------
# gan gia tri cua trong mang
# @param [in] $a0 Chua dia chi bat dau mang
# @param [in] $a1 hang (i)	# @param [in] $a2 cot (j)
# @param [in] $a3 gia tri gan
#------------------------------------------
SetArray:
	la $s0,row
	lw $s1,0($s0)
	lw $s2,4($s0)
	bge $a1,$s1,bound_err
	bge $a2,$s2,bound_err 
	mul $s0,$s2,$a1
	addu $s0,$s0,$a2
	sll $s0, $s0, 2
	addu $s0,$s0,$a0
	sw $a3,0($s0)
	jr $ra
	
#------------------------------------------
# ham lay gia tri bien con tro
# @param: $a0 {0:char ; 1:byte ; 2:word ; 3: array}
# @return: $v0 gia tri bien con tro
#------------------------------------------
value:
	la $t0,CharPtr		# lay dia chi cua bien con tro dau tien
	sll $t1, $a0, 2 
	addu $t0, $t0, $t1	# lay dia chi tai *CharPtr + 4*$a0
	lw $v0, 0($t0)		# lay gia tri cua *---Ptr 
	jr $ra
	
#------------------------------------------
# ham lay dia chi bien con tro
# @param: $a0 {0:char ; 1:byte ; 2:word ; 3: array}
# @return: $v0 dia chi bien con tro
#------------------------------------------
address:
	la $t0,CharPtr
	sll $t1, $a0, 2
	addu $v0, $t0, $t1
	jr $ra
	
#------------------------------------------
# print value or address of pointer
#------------------------------------------
print_value_or_address:
	move $t1,$a0		# kiem tra lan in cuoi
	move $a0,$v0
	li $v0,34
	syscall
	li $v0,11
	beq $t1,3,fix
	li $a0,','
	syscall
	jr $ra
fix:	li $a0,'.'
	syscall
	jr $ra
	
#------------------------------------------
# errors
#------------------------------------------
mal_err:		# thong bao loi so luong malloc
	la $a0, mal
	j error
bound_err:		# thong bao loi chi so vuot ngoai pham vi
	la $a0, bound
	j error
nullptr:		# thong bao con tro rong
	la $a0, null	
error:			# in ra thong bao loi
	li $v0,4
	syscall
end:			# ket thuc chuong trinh
	li $v0,10
	syscall
