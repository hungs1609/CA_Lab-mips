.data
line1: .asciiz  "                                            *************               \n"
line2: .asciiz  "**************                             *3333333333333*              \n"
line3: .asciiz  "*222222222222222*                          *33333********               \n"
line4: .asciiz  "*22222******222222*                        *33333*                      \n"
line5: .asciiz  "*22222*       *22222*                      *33333********               \n"
line6: .asciiz  "*22222*       *22222*       *************  *3333333333333*              \n"
line7: .asciiz  "*22222*        *22222*    **11111*****111* *33333********               \n"
line8: .asciiz  "*22222*        *22222*  **1111**       **  *33333*                      \n"
line9: .asciiz  "*22222*       *222222*  *1111*             *33333********               \n"
line10: .asciiz "*22222*******222222*  *11111*              *3333333333333*              \n"
line11: .asciiz "*2222222222222222*    *11111*               *************               \n"
line12: .asciiz "***************       *11111*                                           \n"
line13: .asciiz "      ---              *1111**                                          \n"
line14: .asciiz "    / o o \\             *1111****   *****                              \n"
line15: .asciiz "    \\   > /              **111111***111*                               \n"
line16: .asciiz "     -----                 ***********     dce.hust.edu.vn              \n"
menu: .asciiz "menu: \n1. Chi con lai vien\n2. Doi vi tri thanh ECD\n3. Doi ki tu mau\n4. Reset\n5. Thoat\nChon chuc nang (1-5) : "
nhap1: .asciiz "Mau chu D(0-9): "
nhap2: .asciiz "Mau chu C(0-9): "
nhap3: .asciiz "Mau chu E(0-9): " 
nhap_sai: .asciiz "Ky tu ban nhap khong hop le, nhap lai: \n"
thong_bao: .asciiz "===== Khong co chuc nang nay =====\n"
xuong_dong: .asciiz "\n"
.text
	li $s0,50 		# mau D = 2
	li $s1,49 		# mau C = 1
	li $s2,51 		# mau E = 3
	li $t0,0 		# i = 0
	li $s6,0 		# kiem tra chuc nang 2 co bat hay khong
	li $a3,21 
	j printf
	nop
loop:
	li $v0,4
	la $a0,menu 		# hien menu
	syscall
	li $v0,5 		# chon chuc nang
	syscall
	add $s7,$v0,$0 		# luu chuc nang

	li $t1,1
	beq $v0,$t1,chuc_nang_1 	# nhan 1 thuc hien chuc nang 1
	nop
	li $t1,2
	bne $v0,$t1,END_ADD 	# neu khong phai chuc nang 2 thi bo qua ADD
	nop
ADD:	
	add $v0,$v0,$s6 	# neu la chuc nang 2 thi ADD $v0 = $v0 + $s6 
END_ADD:
	li $t1,2
	beq $v0,$t1,SWAP 	# neu $v0 la chuc nang 2 va $s6 = 0 (chua SWAP) thi thuc hien SWAP
	nop
	li $t1,7 
	beq $v0,$t1,chuc_nang_2 	# neu $v0 = 7 ($s6 = 5) da SWAP roi nen chi can print
	nop
	li $t1,3
	beq $v0,$t1,chuc_nang_3 	# thuc hien chuc nang 3
	nop
	li $t1,4
	beq $v0,$t1,chuc_nang_4 	# thuc hien chuc nang 4
	nop
	li $t1,5
	beq $v0,$t1,chuc_nang_5 	# thuc hien chuc nang 5
	nop
	j khong_co_chuc_nang
	nop
chuc_nang_1:	
	j VIEN 		# jump vien
	nop
SWAP:	# thuc hien dao tung long (line i)
	la $a0,line1 
	jal DAO 		# swap dong thu 1
	nop
	la $a0,line2 
	jal DAO		# swap dong thu 2
	nop
	la $a0,line3
	jal DAO		# swap dong thuc 3
	nop
	la $a0,line4
	jal DAO		#...
	nop
	la $a0,line5
	jal DAO
	nop
	la $a0,line6
	jal DAO
	nop
	la $a0,line7
	jal DAO
	nop
	la $a0,line8
	jal DAO
	nop
	la $a0,line9
	jal DAO
	nop
	la $a0,line10
	jal DAO
	nop
	la $a0,line11
	jal DAO
	nop
	la $a0,line12
	jal DAO
	nop
	la $a0,line13
	jal DAO
	nop
	la $a0,line14
	jal DAO
	nop
	la $a0,line15
	jal DAO
	nop
	la $a0,line16
	jal DAO
	nop
	li $t1,3
	beq $s7,$t1,end_xu_ly_dao 	# neu la chuc nang 3 thi dao lai lan nua
	nop
	li $t1,4 
	beq $s7,$t1,reset 	# neu la chuc nang 4 thi dao ve vi tri ban dau
	nop
chuc_nang_2:	
	li $s6,5
	li $t7,7
	j printf 		# print sau khi swap
	nop
chuc_nang_3:	
	bne $s6,$0,SWAP 	# neu $s6 = 5 thi thuc hien dao ve vi tri ban dau khoi tao
	nop
	j end_xu_ly_dao 	# thuc hien nhap
	nop
xu_ly_dao: 	
	li $s7,10
	j SWAP 		# sau khi dao ve vi tri ban dau thuc hien swap 
	nop
end_xu_ly_dao:	
	la $a0,nhap1 		# print "mau chu D"
	la $a1,nhap1 		# bien phu luu lai de neu nhap loi co the print lai dung mau
	jal nhap_mau 		# thuc hien nhap
	nop
	add $s3,$a2,$0 		# $s3 luu ma mau vua nhap
	la $a0,nhap2 		# tiep tuc nhap mau cac chu tiep theo
	la $a1,nhap2
	jal nhap_mau
	nop
	add $s4,$a2,$0
	la $a0,nhap3
	la $a1,nhap3
	jal nhap_mau
	nop
	add $s5,$a2,$0
	j MAU1 		# thuc hien thay doi mau
	nop
chuc_nang_4: 	
	bne $s6, $0,SWAP
	nop
	j reset
	nop
chuc_nang_5:  	
	li $v0,10
	syscall
reset:	
	li $s6,0
	li $s3,50 		# mau D = 2
	li $s4,49 		# mau C = 1
	li $s5,51 		# mau E = 3
	j MAU1
	nop
VIEN:	# xu li vien line i (la $a1, line i)
	li $t0,0 		# i = 0
	la $a1,line1 
	jal XU_LY_VIEN 		# xu li vien line1
	nop
	la $a1,line2
	jal XU_LY_VIEN 		# xu li vien line2
	nop
	la $a1,line3
	jal XU_LY_VIEN 		# xu li vien line3
	nop
	la $a1,line4
	jal XU_LY_VIEN 		#...
	nop
	la $a1,line5
	jal XU_LY_VIEN
	nop
	la $a1,line6
	jal XU_LY_VIEN
	nop
	la $a1,line7
	jal XU_LY_VIEN
	nop
	la $a1,line8
	jal XU_LY_VIEN
	nop
	la $a1,line9
	jal XU_LY_VIEN
	nop
	la $a1,line10
	jal XU_LY_VIEN
	nop
	la $a1,line11
	jal XU_LY_VIEN
	nop
	la $a1,line12
	jal XU_LY_VIEN
	nop
	la $a1,line13
	jal XU_LY_VIEN
	nop
	la $a1,line14
	jal XU_LY_VIEN
	nop
	la $a1,line15
	jal XU_LY_VIEN
	nop
	la $a1,line16
	jal XU_LY_VIEN
	nop
	j loop
	nop
nhap_mau:	
	li $v0,4
	syscall 		# print "mau chu D(0-9): "
	li $v0,12
	syscall 		# nhap ma mau
	add $a2,$v0,$0
	li $v0,4
	la $a0, xuong_dong 	# print "xuong_dong"
	syscall
kiem_tra:	
	li $t1,48 		# $t1 = '0'
	slt $t7,$a2,$t1 	# $t7 = $v0 < 0 ? 1 : 0
	li $t1,57
	slt $t6, $t1, $a2 	# t6 = 9 < $v0 ? 1 : 0
	or $t7,$t7,$t6 		# $t7 = $t7 and $t6
	bne $t7,$0,nhap_lai 	# if($v0>9 || $v0 < 0) nhap_lai
	nop
	jr $ra
	nop
end_nhap:		
nhap_lai:	
	li $v0,4
	la $a0,nhap_sai 	# print thong bao nhap sai
	syscall
	add $a0,$a1,$0
	j nhap_mau
	nop
MAU1:	
	add $v1, $s3,$0 	# $v1 la bien thay doi mau 
	j XET1 		# thuc hien thay doi mau cho chu D
	nop
MAU2:	
	add $v1, $s4,$0
	j XET2
	nop
MAU3:	
	add $v1, $s5,$0
	j XET3
	nop
XET1:	
	li $t0,0 		# i = 0
	li $a2,0 		# xet tu ki tu 0 - 22 (so ky tu cua chu D)
	li $a3,22 		# xet tu ki tu 0 - 22
	add $t7,$zero,$s0 	# $t7 la bien luu mau cua cac chu
	jal XU_LY 		# bat dau doi mau
	nop
	add $s0,$v1,$0
	li $t1,3
	beq $s7,$t1,MAU2
	nop
	li $t1,4
	beq $s7,$t1,MAU2
	nop
XET2:	
	li $t0,22
	li $a2,22 		# xet ki tu tu 22-41 (ki tu cua chu C)
	li $a3,41
	add $t7,$zero,$s1
	jal XU_LY
	nop
	add $s1,$v1,$0
	li $t1,3
	beq $s7,$t1,MAU3
	nop
	li $t1,4
	beq $s7,$t1,MAU3
	nop
XET3:	
	li $t0,41
	li $a2,41
	li $a3,70
	add $t7,$zero,$s2 
	jal XU_LY
	nop
	add $s2,$v1,$0
	bne $s6,$0,xu_ly_dao 	# neu $s6 = 5 thuc hien dao lai vi tri 
	nop
	j printf 		# print
XU_LY:  	# thuc hien duyet tung dong 
	add $k1,$0,$ra 		# luu thanh ghi $ra de quay lai (XET i)
	la $k0, line1
	jal duyet
	nop
	la $k0, line2
	jal duyet
	nop
	la $k0, line3
	jal duyet
	nop
	la $k0, line4
	jal duyet
	nop
	la $k0, line5
	jal duyet
	nop
	la $k0, line6
	jal duyet
	nop
	la $k0, line7
	jal duyet
	nop
	la $k0, line8
	jal duyet
	nop
	la $k0, line9
	jal duyet
	nop
	la $k0, line10
	jal duyet
	nop
	la $k0, line11
	jal duyet
	nop
	la $k0, line12
	jal duyet
	nop
	la $k0, line13
	jal duyet
	nop
	la $k0, line14
	jal duyet
	nop
	la $k0, line15
	jal duyet
	nop
	la $k0, line16
	jal duyet
	nop
	add $ra,$0,$k1
	jr $ra 		# tiep tuc xet mau cua ki tu tiep theo
	nop
duyet:	
	add $t1,$k0,$t0 	# address i # duyet tung ki tu trong khoang $a2 - $a3
	lb $t2,0($t1) 		# value i
	beq $t0,$a3, end_duyet 	# den $a3 dung lai
	nop
	beq $t2,$t7,change 	# thay doi ma mau
	nop
jump:	
	addi $t0,$t0,1
	j duyet
	nop
change:  	
	sb $v1, 0($t1) 
	j jump 		# tiep tuc duyet ki tu sau
	nop
end_duyet:	
	add $t0,$a2,$0
	jr $ra

printf: 	# thuc hien in tung dong
	li $v0,4
	li $t0,0
	la $a0,line1
	syscall
	la $a0,line2
	syscall
	la $a0,line3
	syscall
	la $a0,line4
	syscall
	la $a0,line5
	syscall
	la $a0,line6
	syscall
	la $a0,line7
	syscall
	la $a0,line8
	syscall
	la $a0,line9
	syscall
	la $a0,line10
	syscall
	la $a0,line11
	syscall
	la $a0,line12
	syscall
	la $a0,line13
	syscall
	la $a0,line14
	syscall
	la $a0,line15
	syscall
	la $a0,line16
	syscall
	li $t0,0
	li $t1,0
	j loop
	nop
DAO:	
	li $t0,0 		# khoi tao i = 0
loop2:	
	add $t1,$a0,$t0 	# duyet tung phan tu
	#dinh tien cac ki tu len 43 o nho va ca ki tu tu 43 tro len di chuyen xuong 43 o nho 
	lb $t2,0($t1) 
	lb $t3,43($t1) 		# doi vi tri 2 ki tu cach nhau 43 o nho
	sb $t3,0($t1)
	sb $t2,43($t1)
	li $t1,21 		# thuc hien voi 21 ki tu (do ki tu lon nhat can dao la 21)
	beq $t0,$t1,end_loop2
	nop
	addi $t0,$t0,1 		# i = i + 1
	j loop2
	nop
end_loop2: 	
	jr $ra 		# quay lai duyet dong tiep theo
	nop
END_DAO: 
XU_LY_VIEN: 	
	add $t1,$a1,$t0 	# thuc hien duyet tung ki tu - $a1 la bien luu tru line i
	lb $a0,0($t1)
	nop
	li $t1,10 		# t1 = '\n'
	beq $a0,$t1,end_xu_ly_vien 	# if($t1 = "\n") end_xy_ly vien dong i
	nop
	li $t1,48
	slt $t2,$a0,$t1 	# $t2 = $a0 < 48 ? 1:0
	nop
	li $t1,57
	slt $t3,$t1,$a0 	# $t3 = 57 < $a0 ? 1:0
	or $t1,$t2,$t3 		# if(48<= $a0 <= 57) print " "
	beq $t1,$0,print_32
	nop
	li $v0,11 		# if($a0<48 || $a0 >57) print $a0
	syscall
	j jump_xu_ly_vien 	# quay lai vong lap
	nop
print_32:	
	li $v0,11 		# print " "
	li $a0,32
	syscall
jump_xu_ly_vien:	
	addi $t0,$t0,1 		# quay lai vong lap
	j XU_LY_VIEN
	nop
end_xu_ly_vien: 	
	li $v0,11		# print "\n"
	syscall
	li $t0,0 		# khoi tao lai i = 0
	jr $ra 		# quay lai duyet dong tiep theo
khong_co_chuc_nang: 	
	li $v0,4 		# thong bao loi 
	la $a0,thong_bao
	syscall
	j loop
	nop
end:
.ktext 0x80000180
b khong_co_chuc_nang
	
	
