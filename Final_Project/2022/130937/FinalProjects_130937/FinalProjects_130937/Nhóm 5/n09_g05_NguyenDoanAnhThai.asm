.data
	Menu: .asciiz "------------IN CHU-----------\n"
	Func1:.asciiz "1. In DCE\n"
	Func2:.asciiz "2. In DCE(giu lai vien khong in mau)\n"
	Func3:.asciiz "3. Thay doi vi tri D, C, E\n"
	Func4:.asciiz "4. Doi mau\n"
	Func5:.asciiz "5. Thoat\n"
	Thank:.asciiz "------------THANK YOU-----------\n"
	Nhap: .asciiz "Nhap chuc nang: "
	ChuD: .asciiz "Nhap mau cho chu D(0->9): "
	ChuC: .asciiz "Nhap mau cho chu C(0->9): "
	ChuE: .asciiz "Nhap mau cho chu E(0->9): "
	Warning: .asciiz "Vui long chon 1 trong 5 chuc nang\n"
	data: .asciiz "                                           ************* **************                            *3333333333333**222222222222222*                         *33333******** *22222******222222*                       *33333*        *22222*      *22222*                      *33333******** *22222*       *22222*      *************  *3333333333333**22222*       *22222*    **11111*****111* *33333******** *22222*       *22222*  **1111**       **  *33333*        *22222*      *222222*  *1111*             *33333******** *22222*******222222*  *11111*             *3333333333333**2222222222222222*    *11111*              ************* ***************       *11111*                                  ---              *1111**                               / o o \\             *1111****   *****                    \\   > /              **111111***111*                      -----                 ***********    dce.hust.edu.vn"
.text
main:
	la $s0,data # địa chỉ của xâu data	
	li $s1, 57 # chiều dài 1 dòng
	li $s2,'2' # màu khởi tạo của chữ D
	li $s3,'1' # màu khởi tạo của chữ C
	li $s4,'3' # màu khởi tạo của chữ E
	li $s5,0 # s5 = 0 thì in DCE s5 = 1 thì in ECD
	
	la $a0, Menu
	li $v0, 4
	syscall
	
	la $a0, Func1	# In chức năng 1
	li $v0, 4
	syscall
	
	la $a0, Func2 	# In chức năng 2
	li $v0,4
	syscall
	
	la $a0,Func3 	# In chức năng 3
	li $v0,4
	syscall
	
	la $a0,Func4	# In chức năng 4
	li $v0,4
	syscall
	
	la $a0,Func5	# Thoát
	li $v0,4
	syscall
	
	la $a0,Nhap 	# Nhập
	li $v0,4
	syscall
	
	li $v0,5	
	syscall 
	
	Case1:
		li $v1,1 # v1 = 1
		bne $v0,$v1,Case2  # v0 != v1 thì nhảy đến Case2
		j F1 # v0 = v1 thì thực hiện Func1
	Case2:
		li $v1,2 # v1 = 2
		bne $v0,$v1,Case3 # v0 != 2 thì nhảy đến Case3
		j F2 # v0 = 2 thì thực hiện Func2
	Case3:
		li $v1,3 # v1 = 3
		bne $v0,$v1,Case4 # v0 != 3 thì nhảy đến Case4
		j F3 # v0 = 3 thì thực hiện Func3
	Case4:
		li $v1,4 # v1 = 4
		bne $v0,$v1,Case5 # v0 != 4 thì nhảy đến Case5
		j F4 # v0 = 4 thì thực hiện Func4
	Case5:
		li $v1,5 # v1 = 5
		bne $v0,$v1,default # v0 != 5 thì nhảy đến default
		j F5 # v0 = 5 thì thực hiện Func5
	default:
		li $v0,4
		la $a0,Warning
		syscall
		j main
#########Func1#############
F1:
	jal print
	j main
#########Func2#############
F2:
	# thay màu bằng kí tự space
	li $s2,' ' 
	li $s3,' '
	li $s4,' '
	jal print
	j main
#########Func3#############
F3:
	li $s5,1 # gán $ s5 = 1 để in ECD
	jal print
	j main
#########Func4#############
F4:
	# Them mau cho D
	NhapD:
    	li $v0, 4		
	la $a0, ChuD
	syscall
	li $v0, 12	
	syscall 
	
    	add $s2,$v0,0
    	blt $s2,48,NhapD
    	bgt $s2,57,NhapD
    	# Them mau cho C
    	NhapC:
    	li $v0, 4		
	la $a0, ChuC
	syscall
	li $v0, 12	
	syscall
    	add $s3,$v0,0
  	blt $s3,48,NhapC
    	bgt $s3,57,NhapC
    	# Them mau cho E
    	NhapE:
    	li $v0, 4		
	la $a0, ChuE
	syscall
	li $v0, 12	
	syscall
    	add $s4,$v0,0
    	blt $s4,48,NhapE
    	bgt $s4,57,NhapE
    	jal print
    	j main
#########Func5#############
F5:
	la $a0,Thank	# In chức năng 4
	li $v0,4
	syscall
	li $v0,10
	syscall
print:
	li $t0,0 # gán t0 = 0
	addi $sp, $sp, -4
	sw $ra, 0($sp) # ra chứa địa chỉ của lệnh sau lệnh jal
	loopPrint:
	# cho t0 chạy từ 0->15 để in 16 dòng
		beq $t0,16,endLoopPrint # t0 = 16 thì dừng loop
		beq $s5,1,childF3 # nếu s5 = 1 thì thực hiện Func3 (in ECD)
		jal printD # in D
		jal printC # in C
		jal printE # in E
		continue:
		li $v0,11 # xuống dòng mới
		la $a0,'\n'
		syscall
		addi $t0,$t0,1 # t0 = t0 + 1
		j loopPrint
	endLoopPrint:
		lw $ra,0($sp)
		addi $sp, $sp, 4
		jr $ra
childF3:
	
	jal printE # in E
	jal printC # in C
	jal printD # in D
	j continue # quay lại hàm print để in dòng mới
		
printD:
	mul $t1,$t0,$s1 # t1 = 57 * (0,1,...15)
	add $t2,$t1,0 # t2 = t1: độ dài min của chữ D
	addi $t3,$t1,22 # độ dài max của chữ D theo từng dòng (chữ D dài 22 byte) 
	loopPrintD:
		beq $t2,$t3,endLoopPrintD # t2 = t3 thì dừng
		add $t4,$s0,$t2 # t4 = s0 + t2 : lấy từng byte trong xâu data
		lb $a0,0($t4) # giá trị của địa chỉ t4
		beq $a0,'2',printAsS2
		continueD:
		li,$v0,11
		syscall # in ra màn hình
		add $t2,$t2,1 # tăng t2
		j loopPrintD
	endLoopPrintD:
		jr $ra
	printAsS2:
		addi $a0,$s2,0
		j continueD
printC:
	mul $t1,$t0,$s1 # t1 = 57 * (0,1,...15)
	add $t2,$t1,22 # t2 = t1 + 22: độ dài min của chữ C 
	addi $t3,$t1,42 # độ dài max của chữ D theo từng dòng (chữ D dài 20 byte) 
	loopPrintC:
		beq $t2,$t3,endLoopPrintC # t2 = t3 thì dừng
		add $t4,$s0,$t2 # t4 = s0 + t2 : lấy từng byte trong xâu data
		lb $a0,0($t4) # giá trị của địa chỉ t4
		beq $a0,'1',printAsS3
		continueC:
		li,$v0,11
		syscall # in ra màn hình
		add $t2,$t2,1 # tăng t2
		j loopPrintC
	endLoopPrintC:
		jr $ra
	printAsS3:
		addi $a0,$s3,0
		j continueC
printE:
	mul $t1,$t0,$s1 # t1 = 57 * (0,1,...15)
	add $t2,$t1,42 # t2 = t1 + 42 : độ dài min của chữ E
	addi $t3,$t1,57 # độ dài max của chữ E theo từng dòng (chữ D dài 15 byte) 
	loopPrintE:
		beq $t2,$t3,endLoopPrintE # t2 = t3 thì dừng
		add $t4,$s0,$t2 # t4 = s0 + t2 : lấy từng byte trong xâu data
		lb $a0,0($t4) # giá trị của địa chỉ t4
		beq $a0,'3',printAsS4
		continueE:
		li,$v0,11
		syscall # in ra màn hình
		add $t2,$t2,1 # tăng t2
		j loopPrintE
	endLoopPrintE:
		jr $ra
	printAsS4:
		addi $a0,$s4,0
		j continueE
