.data
Menu:		.asciiz		"\n----------\n1/ Lay gia tri bien con tro\n2/ Lay dia chi bien con tro\n3/ Giai phong bo nho da cap phat cho bien con tro\n4/ Tinh toan bo luong bo nho da cap phat\n5/ GetArray[i][j]\n6/ SetArray[i][j]\n7/ Thoat\n----------\nChon:_____?\n"
String:		.word 	0	#Bien con tro, tro toi kieu ascii
Array2:		.word 	0	#Bien con tro, tro toi mang 2 chieu kieu word
Success1:	.asciiz 	"\nOption "
Success2:	.asciiz		" thuc hien thanh cong!"
Opt3Message1:	.asciiz 	"\nLuong bo nho da cap phat: "
Opt3Message2:	.asciiz 	" byte!"
Input:		.asciiz 	"Name: Ngo Hoang Vu-MSSV: 20194721"	#Bien chua xau ky tu gia su duoc nhap tu ban phim
.kdata
Sys_TheTopOfFree: 	.word  	1
Sys_MyFreeSpace: 
.text
Main:
	jal   	SysInitMem 
	
	la   	$a0, String	
	addi 	$a1, $zero, 50	#50 phan tu
	addi 	$a2, $zero, 1  	#moi phan tu 1 byte
	jal 	malloc		#Cap bo nho cho bien String
	
	la	$a1,Input
	lw	$a2,String
	jal	strcpy		#Copy xau da nhap vao Bien da duoc cap phat bo nho
	
	la	$a0, Array2
	addi 	$a1, $zero, 5	#5 dong
	addi 	$a2, $zero, 6  	#6 cot
	jal	malloc2		#Cap bo nho cho mang 2 chieu
	
	la	$a0,Array2
	li	$a3,1402
	li	$a1,2
	li 	$a2,1
	jal	SetArray2
	
	la	$a0,Array2
	li	$a3,10
	li	$a1,0
	li 	$a2,0
	jal	SetArray2
	
	la	$a0,Array2
	li	$a3,2001
	li	$a1,4
	li 	$a2,3
	jal	SetArray2
	
LoopMenu:
	li	$v0, 4		#print Menu
	la	$a0, Menu
	syscall
	
	li	$v0, 5		#doc lua chon Menu
	syscall
	
	beq	$v0, 1, Opt1
	beq	$v0, 2, Opt2
	beq	$v0, 3, Opt3
	beq	$v0, 4, Opt4
	beq	$v0, 5, Opt5
	beq	$v0, 6, Opt6
	beq	$v0, 7, EndMain
ContLoopMenu:
	j	LoopMenu
EndMain:
	li	$v0, 10
	syscall
	
#--------------------
SysInitMem:  
	la   	$t9, Sys_TheTopOfFree  	#Lay con tro chua dau tien con trong, khoi tao
	la   	$t7, Sys_MyFreeSpace 	#Lay dia chi dau tien con trong, khoi tao      
	sw   	$t7, 0($t9) 		#Luu lai
	jr   	$ra
#--------------------
malloc:   
	la   	$t9, Sys_TheTopOfFree   #
	lw   	$t8, 0($t9) 		#Lay dia chi dau tien con trong
	sw   	$t8, 0($a0)    		#Cat dia chi do vao bien con tro
	addi 	$v0, $t8, 0   		#Dong thoi la ket qua tra ve cua ham 
	mul  	$t7, $a1,$a2   		#Tinh kich thuoc cua mang can cap phat
	
	div	$t7, $t7, 4		#Thay doi kich thuoc de chia het cho 4
	mfhi	$t0			
	beq	$t0, 0, NoChange	#Neu size %4 == 0 -> branch 
	addi	$t7, $t7, 1		
	mul	$t7, $t7, 4		#else size b?ng s? nh? nh?t chia h?t cho 4 > $t7
	j	EndGetArraySize
NoChange:
	mul	$t7,$t7,4		#Khong thay doi
EndGetArraySize:

	add  	$t6, $t8, $t7  		#Tinh dia chi dau tien con trong 
	sw   	$t6, 0($t9)    		#Luu tro lai dia chi dau tien do vao bien Sys_TheTopOfFree 
	jr   	$ra	
#--------------------
strcpy:
	add	$t0,$zero,$zero         #$t0=i=0
L1:
	add	$t1,$t0,$a1             #$t1 = $t0 + $a1 = i + y[0]
					#    = dia chi cua y[i]
	lb	$t2,0($t1)              #$t2 = gia tri tai $t1 = y[i]
	add	$t3,$t0,$a2             #$t3 = $t0 + $a0 = i + x[0] 
					#    = adia chi x[i]
	sb	$t2,0($t3)              #x[i]= $t2 = y[i]
	beq	$t2,$zero,end_of_strcpy #if y[i]==0, exit
	nop	
	addi	$t0,$t0,1               #$t0=$t0 + 1 <-> i=i+1
	j	L1                      #char tiep theo
	nop
end_of_strcpy:
	jr	$ra
#--------------------
Opt1:
	la	$a0, String
	lw	$a1,0($a0)
	li	$t0,0			#Offset = 0
	add	$a1,$a1,$t0		#Lay gia tri tai offset = $t0
	lbu	$s0,0($a1)		#Tra ve gia tri byte
	
	#li	$v0, 4			#print String
	#add	$a0, $a1,$zero
	#syscall
	
	li	$v0, 4			#print Succes
	la	$a0, Success1
	syscall
	
	li	$v0, 1	
	li	$a0, 1
	syscall
	
	li	$v0, 4
	la	$a0, Success2
	syscall
	
	j 	ContLoopMenu
#--------------------	
Opt2:
	la	$a0, String
	lw	$s1,0($a0)		#Tra ve dia chi
	
	li	$v0, 4			#print Succes
	la	$a0, Success1
	syscall
	
	li	$v0, 1	
	li	$a0, 2
	syscall
	
	li	$v0, 4
	la	$a0, Success2
	syscall
	
	j	ContLoopMenu
#--------------------
Opt3:
	la	$a0,Sys_TheTopOfFree		
	lw	$a1,0($a0)		#Lay dia chi dich -> $a1
	la	$a0,Sys_MyFreeSpace	#Lay dia chi nguon
	add	$a2,$a0,$zero		#$a2 = dia chi nguon
LoopFree:
	beq	$a2,$a1,EndLoopFree	#$a2 == dia chi dich -> ket thuc giai phong
	sw	$zero,0($a2)		#Giai phong du lieu o word hien tai	
	addi	$a2,$a2,4		#$a2-> dia chi word tiep theo
	j	LoopFree
EndLoopFree:	
	la	$a0,Sys_MyFreeSpace
	sw	$a0,Sys_TheTopOfFree	#Sys_TopOfFree chua dia chi dau tien cua vung nho con trong
	
	li	$v0, 4			#print Succes
	la	$a0, Success1
	syscall
	
	li	$v0, 1	
	li	$a0, 3
	syscall
	
	li	$v0, 4
	la	$a0, Success2
	syscall
	
	j	ContLoopMenu
#--------------------	
Opt4:
	la	$a0,Sys_TheTopOfFree
	lw	$a1,0($a0)
	la	$a0,Sys_MyFreeSpace
	add	$a2,$a0,$zero
	add	$t0,$zero,$zero
LoopCount:
	beq	$a2,$a1,EndLoopCount
	addi	$a2,$a2,4
	addi	$t0,$t0,4
	j	LoopCount
EndLoopCount:
	li	$v0, 4			#print Message
	la	$a0, Opt3Message1
	syscall
	
	li	$v0, 1	
	add	$a0,$t0,$zero
	syscall
	
	li	$v0, 4
	la	$a0, Opt3Message2
	syscall
	
	li	$v0, 4			#print Succes
	la	$a0, Success1
	syscall
	
	li	$v0, 1	
	li	$a0, 4
	syscall
	
	li	$v0, 4
	la	$a0, Success2
	syscall
	
	j	ContLoopMenu
#--------------------
malloc2:   
	la   	$t9, Sys_TheTopOfFree   #
	lw   	$t8, 0($t9) 		#Lay dia chi dau tien con trong
	sw   	$t8, 0($a0)    		#Cat dia chi do vao bien con tro
	addi 	$v0, $t8, 0   		#Dong thoi la ket qua tra ve cua ham 
	mul  	$t7, $a1,$a2   		#Tinh kich thuoc cua mang can cap phat		
	mul	$t7, $t7, 4		#Nhan so phan tu mang voi 4 byte trong 1 word
	add  	$t6, $t8, $t7  		#Tinh dia chi dau tien con trong 
	sw   	$t6, 0($t9)    		#Luu tro lai dia chi dau tien do vao bien Sys_TheTopOfFree 
	add	$s6,$a1,$zero		#Luu lai so han va so cot
	add	$s7,$a2,$zero
	jr   	$ra	
#--------------------
GetArray2:
	lw	$t0,0($a0)		#Dia chi cua vung nho cua Array2
	mul	$t1,$a1,$s7		#$t1 = i *so cot
	add	$t1,$t1,$a2		#$t1 = i * so cot + j = index cua mang 2 chieu
	mul	$t1,$t1,4
	add	$t0,$t0,$t1		#$t0 = Array2[0][0] + offsdet
	lw	$s2,0($t0)		#lay gia tri tu trong mang luu trong $s2
	jr	$ra
#--------------------
Opt5:
	la	$a0,Array2
	li	$a1,2
	li 	$a2,1
	jal	GetArray2
	
	li	$v0, 4			#print Succes
	la	$a0, Success1
	syscall
	
	li	$v0, 1	
	li	$a0, 5
	syscall
	
	li	$v0, 4
	la	$a0, Success2
	syscall
	
	j	ContLoopMenu
#--------------------
SetArray2:
	lw	$t0,0($a0)		#Dia chi cua vung nho cua Array2
	mul	$t1,$a1,$s7		#$t1 = i *so cot
	add	$t1,$t1,$a2		#$t1 = i * so cot + j = index cua mang 2 chieu
	mul	$t1,$t1,4
	add	$t0,$t0,$t1		#$t0 = Array2[0][0] + offsdet
	sw	$a3,0($t0)		#luu gia tri vao vung nho cua phan tu trong mang
	jr	$ra
#--------------------	
Opt6:
	la	$a0,Array2
	li	$a3,194721
	li	$a1,2
	li 	$a2,3
	jal	SetArray2
	
	li	$v0, 4			#print Succes
	la	$a0, Success1
	syscall
	
	li	$v0, 1	
	li	$a0, 6
	syscall
	
	li	$v0, 4
	la	$a0, Success2
	syscall
	
	j	ContLoopMenu