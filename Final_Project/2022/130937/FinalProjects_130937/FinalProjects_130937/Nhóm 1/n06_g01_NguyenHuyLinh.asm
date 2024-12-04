.data
CharPtr: .word 0 # Bien con tro, tro toi kieu asciiz
BytePtr: .word 0 # Bien con tro, tro toi kieu Byte
WordPtr: .word 0 # Bien con tro, tro toi kieu Word
CharCopy: .word 0 #Copy bien con tro
Array2D: .word 0 #Bien con tro 2 chieu
Message1: .asciiz "\nNhap du lieu test ham 2 con tro:"
Message2: .asciiz "\nDu lieu a[i][j]:"
Message3: .asciiz "\nTong du lieu: "
#CharSize
#byteSize
#wordSize
.kdata
# Bien chua dia chi dau tien cua vung nho con trong
Sys_TheTopOfFree: .word 1
# Vung khong gian tu do, dung de cap bo nho cho cac bien con tro
Sys_MyFreeSpace:

.text
#Khoi tao vung nho cap phat dong

jal SysInitMem
#-----------------------
# Cap phat cho bien con tro, gom 3 phan tu,moi phan tu 1 byte
#-----------------------
la	$a0, CharPtr
addi 	$a1, $zero, 3
addi 	$a2, $zero, 1
jal 	malloc

#-------------------------------------
#Ham copy xau
#-------------------------------------
li $v0,4
la $a0,Message1
syscall
jal 	NhapChuoi 	#tao gia tri kiem thu
la	$a0,CharPtr
li	$a1,3
la	$a2,CharCopy
jal	CopyPtr

#-------------------------------------
#Cap phat bo nho cho mang 2 chieu
#-------------------------------------
# allocated a array a[2][3] ( mang 2 hang 3 cot )
la	$a0,Array2D	#dia chi dau vao
addi	$a1,$0,2 	#dong max
addi	$a2,$0,3	#cot max
jal	malloc2
#set a[1][2] = 5
la	$a0,Array2D
lw	$a0,0($a0)
addi	$a1,$0,1 #dong
addi	$a2,$0,2 #cot
addi	$t1,$0,3 #cot max
addi	$a3,$0,5 #gia tri gan cho mang 
jal	setArray
#set a[1][1] = 4
la	$a0,Array2D
lw	$a0,0($a0)
addi	$a1,$0,1 #dong
addi	$a2,$0,1 #cot
addi	$t1,$0,3 #cot max
addi	$a3,$0,4 #gia tri gan cho mang 
jal	setArray
#message get
li $v0,4
la $a0,Message2 #"\nDu lieu a[i][j]:"
syscall
#get a[1][1] =4
la	$a0,Array2D
lw	$a0,0($a0)
addi	$a1,$0,1 #dong
addi	$a2,$0,1 #cot
addi	$t1,$0,3 #cot max

jal	getArray
add	$a0,$0,$v0
addi	$v0,$0,1
syscall
#set a[1][1] =3
la	$a0,Array2D
lw	$a0,0($a0)
addi	$a1,$0,1 #dong
addi	$a2,$0,1 #cot
addi	$t1,$0,3 #cot max
addi	$a3,$0,3 #gia tri gan cho mang 
jal	setArray

#set a[1][0] =2
la	$a0,Array2D
lw	$a0,0($a0)
addi	$a1,$0,1 #dong
addi	$a2,$0,0 #cot
addi	$t1,$0,3 #cot max
addi	$a3,$0,2 #gia tri gan cho mang 
jal	setArray

#message get
li $v0,4
la $a0,Message2  #"\nDu lieu a[i][j]:"
syscall
#get a[1][1] =3 
la	$a0,Array2D
lw	$a0,0($a0)
addi	$a1,$0,1 #dong
addi	$a2,$0,1 #cot
addi	$t1,$0,3 #cot max
jal	getArray
add	$a0,$0,$v0
addi	$v0,$0,1
syscall
#in ra gia tri cua mang 2 chieu

#-------------------------------------
#Ham tinh tong bo nho
#-------------------------------------
li $v0,4
la $a0,Message3
syscall  

jal AllocatedMem
#-------------------------------------
#Ham Clean bo nho
#-------------------------------------
jal FreeMem


lock: 	j lock
nop
#------------------------------------------
# Ham khoi tao cho viec cap phat dong
# @param khong co
# @detail Danh dau vi tri bat dau cua vung nho co the cap phat duoc
#------------------------------------------
SysInitMem: 	la	$t9, Sys_TheTopOfFree 	#Lay con tro chua dau tien con trong, khoi tao
		la   	$t7, Sys_MyFreeSpace 	#Lay dia chi dau tien con trong, khoi tao
		sw	$t7, 0($t9)	# Luu lai
		
		jr	$ra
#------------------------------------------
# Ham cap phat bo nho dong cho cac bien con tro
# @param [in/out] $a0 Chua dia chi cua bien con tro can cap phat
#Khi ham ket thuc, dia chi vung nho duoc cap phat se luu tru vao bien con tro
# @param [in] $a1 So phan tu can cap phat
# @param [in] $a2 Kich thuoc 1 phan tu, tinh theo byte
# @return $v0 Dia chi vung nho duoc cap phat
#------------------------------------------
malloc:	
	la	$t9, Sys_TheTopOfFree	#
	lw	$t8, 0($t9)	#Lay dia chi dau tien con trong
	#1) Word phai duoc cap phat o dia chi chia het cho 4
	#Dia chi kieu word chia het 4 
	#while( diachi % 4 != 0)
	# diachi ++ => cap phat cho bien char them dia chi
checkWord:
	bne	$a2,4,endCheckWord
	nop
While:	div	$t8,$a2
	mfhi	$t0
	beqz	$t0,endCheckWord
	nop
	addi	$t8,$t8,1	# Dia chi + 1
	j	While
endCheckWord:
	sw	$t8, 0($a0)	#Cat dia chi do vao bien con tro	
	addi 	$v0, $t8, 0	#Dong thoi la ket qua tra ve cua ham
	mul 	$t7, $a1,$a2	#Tinh kich thuoc cua mang can cap phat
	add 	$t6, $t8, $t7 	#Tinh dia chi dau tien con trong
	sw	$t6, 0($t9)	#Luu tro lai dia chi dau tien do vao bien Sys_TheTopOfFree
	jr	$ra

#2) Viết hàm lấy giá trị của biến con trỏ.
#------------------------------------------
# Ham lay gia gia tri cua bien con tro
# @param [in/out] $a2 Chua dia chi cua bien con tro 
# @return $v0 gia tri cua bien con tro
#------------------------------------------
PtrValue: 	lw $v0,0($a0)
		jr  $ra
#3) Viết hàm lấy địa chỉ biến con trỏ.
addressCharPtr:la	$v0,CharPtr
	       jr	$ra
addressBytePtr:la	$v0,BytePtr
		jr	$ra
addressWordPtr:la	$v0,WordPtr
		jr	$ra
#4) Viết hàm thực hiện copy 2 con trỏ xâu kí tự.
#------------------------------------------
# Ham lay gia gia tri cua bien con tro
# @param [in] $a0 Chua dia chi cua bien con tro xau^ goc'
# @param [in] $a1 Chua so phan tu cua con tro xau^ goc'
# @param [in/out] $a2 Chua dia chi con tro xau copy, khi ket thuc chua dia chi copy chuoi moi
# @return $v0 gia tri cua bien con tro
#------------------------------------------
CopyPtr: 
	sw	$ra,-4($sp)	#store the return address
	sw	$a0,-8($sp)	#store $a0 value  
	sw	$a1,-12($sp)	#store $a1 value
	sw	$a2,-16($sp)	#store $a2 value	
	addi	$sp,$sp,-16	#allocate space for $ra,$a0,$a1,$a2 
	
	add	$a0,$0, $a2	# cap phat bo nho cho con tro copy
	add 	$a1, $zero, $a1 # So phan tu cap phat cho string copy
	addi 	$a2, $zero, 1	# so byte cho phan tu
	jal 	malloc

	lw	$a2,0($sp)	#restore $a2 
	lw	$a1,4($sp)	#restore $a1
	lw	$a0,8($sp)	#restore $a0
	lw	$ra,12($sp)	#restore $ra 
	addi	$sp,$sp,16	#restore stack pointer
	
	lw	$t0,0($a0)	#lay dia chi da cap phat cua xau goc
	lw	$t1,0($a2)	#lay dia chi da cap phat cua xau copy
	
	li	$t2,0		#i = 0
LoopCopy:	slt 	$t9,$t2,$a1 	#i < so phan tu cua xau
		beqz 	$t9,end_LoopCopy
		nop
		add	$t9,$t0,$t2	# $t9 = dia chi xau goc + i
		add	$t7,$t1,$t2	# $t7 = dia chi xau copy +i
		lb 	$t3,0($t9)	#  t7[i] = t9[i]
		sb	$t3,0($t7)	#
		addi	$t2,$t2,1	# i ++
		j 	LoopCopy
		nop
end_LoopCopy:	
	jr	$ra
#
NhapChuoi:
la	$a0,CharPtr
lw	$t0,0($a0) # load dia chi dau
addi	$t1,$t0,3 # dia chi dich
loop:
slt	$t3,$t0,$t1# Neu chua den dia chi dich thi tiep tuc read character
beqz	$t3,endNhap 
nop
li	$v0,12	#read chracter
syscall	
nop
beq	$v0,10,endNhap
nop
sb	$v0,0($t0)
addi	$t0,$t0,1
j	loop
nop
endNhap:
jr	$ra


#5) Viết hàm giải phóng bộ nhớ đã cấp phát cho các biến con trỏ.
FreeMem:
	la	$t9, Sys_TheTopOfFree 	#Lay con tro chua dia chi dau tien con trong	
	lw	$t7,0($t9)	#gia tri dia chi dau tien con trong
	addi	$t6,$t9,3	#mut' dia chi cuoi cung cua Sys_TheTopOfFre
	addi	$t7,$t7,-1 	#lui 1 byte den dia chi cuoi cung duoc cap phat
CleanLoop:	slt	$t8,$t6,$t7 # chua den vi tri con trong ban dau duoc cap phat (kdata +4) thi tiep tuc
		beqz	$t8,End_CleanLoop
		nop
		sb	$0,0($t7)
		addi	$t7,$t7,-1 # lui 1 byte 
		j	CleanLoop
End_CleanLoop:	
		la	$t8,Sys_MyFreeSpace # dat lai gia tri dia chi con trong co the cap phat
		sw	$t8, 0($t9)
		la	$t8,CharPtr #empty CharPtr
		sw	$0,0($t8)
		la	$t8,BytePtr #empty BytePtr
		sw	$0,0($t8)
		la	$t8,WordPtr #empty WordPtr
		sw	$0,0($t8)
		jr	$ra
#6) Viết hàm tính toàn bộ lượng bộ nhớ đã cấp phát.
#Dia chi da cap phat bao gom dia chi tu do cap phat cho byte.
#Cach tinh : myFreeSpace - (TheTopOfFree + 4)
# @param: Khong co
AllocatedMem:	la	$t9, Sys_TheTopOfFree ##Lay con tro chua dia chi con trong
		lw	$t8,0($t9)	#Lay dia chi con trong
		sub	$a0,$t8,$t9	#gia tri dia chi dau tien con trong - dia chi TheTopOfFree 
		addi	$a0,$a0,-4	#So phan tu duoc cap phat
		li	$v0,1		#In ra so Phan tu da duoc cap phat
		syscall
		jr	$ra
#7) Hãy viết hàm malloc2 để cấp phát cho mảng 2 chiều kiểu .word với tham số vào gồm:
#@param Địa chỉ con tro 2 chieu  	$a0
#@param Số dòng				$a1
#@param Số cột				$a2
malloc2: 
	la	$t9, Sys_TheTopOfFree	#Lay con tro chua dia chi con trong
	lw	$t8, 0($t9)		#Lay dia chi con trong
	li	$t7,4			#So byte word 
#Kiem tra xem dia chi co chia het cho 4 hay khong
WhileWord:	
	div	$t8,$t7	#Neu dia chi con trong khong chia het cho 4 thi cap phat them 
	mfhi	$t0	#load so du 
	beqz	$t0,endWhileWord#so du = 0 thi ket thuc while
	nop
	addi	$t8,$t8,1	# Dia chi + 1 
	j	WhileWord
endWhileWord:
	sw	$t8,0($a0) 	#cat dia chi cua mang vao con tro chua
	mul 	$t7, $a1,$a2	#Tinh kich thuoc cua mang can cap phat
	mul	$t7, $t7,4	#Bo nho can cap phat= Kich thuoc mang * 4
	add 	$t6, $t8, $t7 	#Gia tri dia chi trong moi = Gia tri dia chi trong cu + Bo nho can cap phat
	sw	$t6, 0($t9)	#Luu tro lai dia chi dau tien do vao con tro Sys_TheTopOfFree
	jr	$ra
#8) Tiếp theo câu 7, hãy viết 2 hàm getArray[i][j] và setArray[i][j] để lấy/thiết lập giá trị cho phần tử ở
#dòng i cột j của mảng
#
#@param[in] Địa chỉ đầu của mảng	 	$a0
#@param[in] Số dòng			$a1
#@param[in] Số cột			$a2
#@param[in] Số cột max			$t1
#Gia tri gan				$a3
setArray:
	mul	$t2,$t1,4	#t2 = Khoang cach nhay giua cac dong
	mul	$a1,$a1,$t2	#a1 = Dia chi dong can den
	mul	$t3,$a2,4	#offset Dia chi cot can den so voi hang 
	add	$a1,$a1,$t3	#Dia chi a[i][j] tuong doi voi dia chi mang 
	add	$t4,$a0,$a1 	#$t4 = Dia chi a[i][j] tuyet doi
	sw	$a3,0($t4)
	jr	$ra
#
#@param[in] Địa chỉ đầu của mảng	 	$a0
#@param[in] Số dòng			$a1
#@param[in] Số cột			$a2
#@param[in] Số cột max			$t1
#return gia tri 			$v0
getArray:
	mul	$t2,$t1,4	#Khoang cach nhay giua cac dong
	mul	$a1,$a1,$t2	#Dia chi dong can den
	mul	$t3,$a2,4	#Dia chi cot can den
	add	$a1,$a1,$t3	#Dia chi a[i][j] tuong doi so voi goc
	add	$t4,$a0,$a1	#Dia chi a[i][j] tuong doi voi dia chi mang 
	lw	$v0,0($t4)	#$t4 = Dia chi a[i][j] tuyet doi
	jr	$ra
