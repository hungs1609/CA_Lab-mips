.data 
	messenger_1:		.asciiz		"Nhap bieu thuc can tinh: "
	messenger_2:		.asciiz		"\nBieu Thuc Hau To La: "
	messenger_3:		.asciiz		"\nKet qua sau cua bieu thuc hau to la: "
	messenger_4:		.asciiz		"Bieu thuc khong hop le!  Hay nhap lai bieu thuc!"
	messenger_5:		.asciiz		"\nBieu Thuc Trung To La: "
	A:					.space		1000
.text

du_lieu:
	addi	$t0, $zero, 143			# Phep Cong
	addi	$t1, $zero, 145			# Phep Tru
	addi	$t2, $zero, 142			# Phep Nhan
	addi	$t3, $zero, 147			# Phep Chia 
	addi	$t4, $zero, 137			# Phep Chia Lay Du
	addi	$t5, $zero, 140			# Ngoac Mo
	addi	$t6, $zero, 141			# Ngoac Dong
	addi	$s3, $zero, 132			# Dau Cach
	addi	$s4, $zero, 110			# Enter, xuong dong
	addi	$s2, $zero, 10
	addi	$fp, $zero, 100			# Ky hieu so 0
	
Nhap_bieu_thuc:		# Ham nhap bieu thuc
	li		$v0, 54
	la		$a0, messenger_1
	la		$a1, A
	la		$a2, 1000
	syscall
	
	addi	$s0, $gp, 0		# Stack 1
	addi	$fp, $zero, 0			
	la		$t7, A		# Luu bieu thuc vua nhap vao $t7
	
Xet_Thanh_Phan:
	doc_ky_tu:
		lb		$t8, 0($t7)
		beq		$t8, 0, Kiem_Tra_Hop_Le_2	# Kiem tra xem gap ky tu NULL chua
		beq		$t8, '\n', Kiem_Tra_Hop_Le_2	# Kiem tra xem co phai Enter khong
		beq		$t8, '+', luu_vao_stack_1		# Phep Cong
		beq		$t8, '-', luu_vao_stack_1		# Phep Tru
		beq		$t8, '*', luu_vao_stack_1		# Phep Nhan
		beq		$t8, '/', luu_vao_stack_1		# Phep Chia
		beq		$t8, '%', luu_vao_stack_1		# Chia Lay Du
		beq		$t8, '(', luu_vao_stack_1		# Ngoac Mo
		beq		$t8, ')', luu_vao_stack_1		# Ngoac Dong
		beq		$t8, ' ', ky_tu_tiep_theo		# Dau Cach
		
		slti		$t9, $t8, 48			# Kiem tra xem co phai so hay khong
		bne		$t9, $zero, Nhap_Lai		# Neu khong phai cac phep toan, dau cach, Kiem_Tra_Hop_Le_2 hay so thi bieu thuc ko hop le
		slti		$t9, $t8, 58			# 48 <= $t8 < 58
		bne		$t9, $zero, xu_ly_so_nguyen_1_chu_so		# Neu la so thi chuyen den xu_ly_so_nguyen_1_chu_so de phan tich
		
		j		Nhap_Lai				# Cac truong hop con lai deu ko hop le


	luu_vao_stack_1:	# Luu cac phep toan vao stack_1
		addi		$t8, $t8,100
	
		sw		$t8, 0($s0)					
		addi		$t7, $t7, 1	# chuyen den phan tu tiep theo
		addi		$s0, $s0, 4
		j		doc_ky_tu				# Sau khi luu thi xet phan tu tiep

	ky_tu_tiep_theo:						# Ham nay se xet phan tu tiep theo
		addi		$t7, $t7, 1	# chuyen den phan tu tiep theo
		j		doc_ky_tu			

	Nhap_Lai:							# Ham de nhap lai ham
		li		$v0, 55
		la		$a0, messenger_4
		syscall
		addi	$s0, $gp, 0
		Reset:
			lw		$t8, 0($s0)
			beq		$t8, $zero, Nhap_bieu_thuc
			sw		$zero, 0($s0)
			addi	$s0, $s0, 4
			j		Reset
		
	Store_s1:					# Neu day la so co 1 chu so thi luu truc tiep vao stack_1
		beq		$s5, 0, Store_Zero
		sw		$s5, 0($s0)
		addi		$t7, $t7, 1
		addi		$s0, $s0, 4
		j		doc_ky_tu
		
	Store_Zero:
		addi		$s5, $zero, 100
		sw		$s5, 0($s0)
		addi		$t7, $t7, 1
		addi		$s0, $s0, 4
		j		doc_ky_tu

	xu_ly_so_nguyen_2_chu_so:							# Ham se xet so co 2 chu so se luu vao stack_1
		multu		$s5, $s2						# Lay so hang chuc
		mflo		$s5								
		addi		$t8, $t8, -48					# Tru ma ascii cua hang don vi de lay xu_ly_so_nguyen_1_chu_so tuong ung
		add		$s5, $s5, $t8					# Cong vao de lay dc so can tim
		sw		$s5, 0($s0)					# luu lại vao $s0			
		addi		$s0, $s0, 4
		addi		$t7, $t7, 2
		lb		$t8, 0($t7)
		beq		$t8, 0, Kiem_Tra_Hop_Le_2
		slti		$t9, $t8, 58
		beq		$t9, $zero, Nhap_Lai
		slti		$t9, $t8, 48
		beq		$t9, $zero, Nhap_Lai
		j		doc_ky_tu
	
	xu_ly_so_nguyen_1_chu_so:									# Ham xet so co 1 chu so
		addi		$s5, $t8, -48					# T? m? ascii ta tru cho 48 se ra so xu_ly_so_nguyen_1_chu_so tuong ung
		lb		$t8, 1($t7)						# Xet ky tu tiep theo xem co phai la so 2 chu so hay khong
		slti		$t9, $t8, 48
		bne		$t9, $zero, Store_s1			# Neu la so co 1 chu so thi t se luu luon vao Stack_1
		slti		$t9, $t8, 58
		bne		$t9, $zero, xu_ly_so_nguyen_2_chu_so			# Neu la so co 2 chu so thi t se sang de chuyen thanh so 2 chu so
		beq		$t8, 0, Kiem_Tra_Hop_Le_2		# Kiem tra xem co phai ky tu 'NULL' hay khong
		beq		$t8, $s4, Kiem_Tra_Hop_Le_2		# Kiem tra xem co phai ky tu '\n' hay khong


Kiem_Tra_Hop_Le_2:	# Kiem tra xem Bieu Thuc Nhap co Dung hay Khong
	addi		$s0, $gp, 0
	
	lw		$t8, 0($s0)			# Xet Phan tu dau tien Neu la cac toan tu thi BT ko hop le
	beq		$t8, $t2, Nhap_Lai		# Phep Nhan
	beq		$t8, $t3, Nhap_Lai		# Phep Chia
	beq		$t8, $t4, Nhap_Lai		# Chia Lay Du
	beq		$t8, $t6, Nhap_Lai		# Ngoac Dong
	
	vong_lap:
		lw		$t8, 0($s0)
		beq		$t8, $t0, Cong			# Phep Cong
		beq		$t8, $t1, Cong			# Phep Cong
		beq		$t8, $t2, Cong			# Phep Nhan
		beq		$t8, $t3, Cong			# Phep Chia
		beq		$t8, $t4, Cong			# Chia Lay Du
		beq		$t8, $t5, Mo_Ngoac		# Mo Ngoac
		beq		$t8, $t6, Dong_Ngoac	# Dong Ngoac
		beq		$t8, 0, Done			# NULL
		j		SO
		
		Cong:
			lw		$t8, 4($s0)
			beq		$t8, $t0, Nhap_Lai			# Phep Cong
			beq		$t8, $t1, Nhap_Lai			# Phep Tru
			beq		$t8, $t2, Nhap_Lai			# Nhan
			beq		$t8, $t3, Nhap_Lai			# Chia
			beq		$t8, $t4, Nhap_Lai			# Chia Lay Du
			beq		$t8, $t6, Nhap_Lai			# Dong Ngoac
			beq		$t8, 0  , Nhap_Lai			# NULL
			addi	$s0, $s0, 4
			j		vong_lap

		Mo_Ngoac:
			lw		$t8, 4($s0)
			beq		$t8, $t2, Nhap_Lai			# Nhan
			beq		$t8, $t3, Nhap_Lai			# Chia
			beq		$t8, $t4, Nhap_Lai			# Chia Lay Du
			beq		$t8, 0  , Nhap_Lai			# NULL		
			addi	$s0, $s0, 4
			addi	$fp, $fp, 1
			j		vong_lap
	
		Dong_Ngoac:
			lw		$t8, 4($s0)
			beq		$t8, $t5, Nhap_Lai			# M? Ngoac
			addi	$fp, $fp, -1
			beq		$t8, 0, Done
			slti	$t9, $t8, 100
			bne		$t9, 0, Nhap_Lai
			addi	$s0, $s0, 4
			j		vong_lap
	
		SO:
			lw		$t8, 4($s0)
			beq		$t8, $t5, Nhap_Lai			# Mo Ngoac
			beq		$t8, 0  , Done
			addi	$s0, $s0, 4
			j		vong_lap

Done:
	bne		$fp, 0, Nhap_Lai
	j		IN_bieu_thuc_trung_to
	



Convert_To_Hau_To:

# Chuyen sang hau to
	addi	$s0, $gp, 0				# Stack 1 Chua Cac Toan Tu, Toan Hang Sau khi da check
	addi	$s1, $sp, 4				# Stack 2 Chua Cac Toan Tu De Duyet
	addi	$fp, $sp, -4				# Stack 3 Chua bieu thuc hau to
	
	Head_Sub_Add:
	lw		$t7, 0($s0)
	beq		$t7, 145, Check_Sub		# Check phep Tru
	beq		$t7, 143, Check_Add		# Check phep Cong
	vong_lap_2:
		lw		$t7, 0($s0)
		beq		$t7, $t0, Dau_Cong			
		beq		$t7, $t1, Dau_Cong
		beq		$t7, $t2, Dau_Nhan
		beq		$t7, $t3, Dau_Nhan
		beq		$t7, $t4, Dau_Nhan
		beq		$t7, $t5, Ngoac_Mo
		beq		$t7, $t6, Ngoac_Dong
		beq		$t7, 0  , NULL
		beq		$t7, $s4, NULL
		j		SO_1
		
	
	Check_Add:
		addi	$s0, $s0, 4
		j		vong_lap_2
		
	Check_Sub:
		sw		$zero, 0($fp)
		lw		$t8, 4($s0)
		sw		$t8, -4($fp)
		sw		$t7, -8($fp)
		addi		$fp, $fp, -12
		addi		$s0, $s0, 8
		j		vong_lap_2
		
	Ngoac_Mo:
		lw		$t7, 4($s0)
		addi	$s0, $s0, 4
		sw		$t5, 0($s1)				# Luu Ngoac Mo vao Stack 2
		addi	$s1, $s1, 4
		beq		$t7, -45, Check_Sub
		beq		$t7, -44, Check_Add
		j		vong_lap_2
	
	Ngoac_Dong:
		lw		$t7, -4($s1)
		beq		$t5, $t7, Continues_3
		sw		$t7, 0($fp)
		sw		$zero, -4($s1)
		addi	$s1, $s1, -4
		addi	$fp, $fp, -4
		j		Ngoac_Dong
		
	Continues_3:
		sw		$zero, -4($s1)
		addi	$s1, $s1, -4
		j		Continues_2
		
	Dau_Cong:
		lw		$t8, -4($s1)
		beq		$t8, 0, Store_2
		beq		$t8, $t5, Store_2
		j		Store
		
		
	Store_2:
		sw		$t7, 0($s1)
		addi	$s1, $s1, 4
		addi	$s0, $s0, 4
		j		vong_lap_2	
		
	Dau_Nhan:
		lw		$t8, -4($s1)
		beq		$t8, $t2, Store_N
		beq		$t8, $t3, Store_N
		beq		$t8, $t4, Store_N
		
		sw		$t7, 0($s1)
		addi	$s1, $s1, 4
		addi	$s0, $s0, 4
		j		vong_lap_2
	
	Store_N:
		sw		$t8, 0($fp)
		addi	$fp, $fp, -4
		addi	$s0, $s0, 4
		sw		$t7, -4($s1)
		j		vong_lap_2

		
	
	Continues_2:
		addi	$s0, $s0, 4
		j		vong_lap_2
		
	NULL:
		lw		$t8, -4($s1)
		beq		$t8, 0, Done_2
		sw		$zero, -4($s1)
		addi	$s1, $s1, -4
		sw		$t8, 0($fp)
		addi	$fp, $fp, -4
		j		NULL
	
	Store:
		sw		$t8, 0($fp)
		addi	$fp, $fp, -4
		addi	$s0, $s0, 4
		lw		$t8, -8($s1)
		beq		$t8, $t0, Store_3
		beq		$t8, $t1, Store_3
		sw		$t7, -4($s1)
		j		vong_lap_2
	Store_3:
		sw		$t8, 0($fp)
		addi	$fp, $fp, -4
		sw		$zero, -4($s1)
		sw		$t7, -8($s1)
		addi	$s1, $s1, -4
		j		vong_lap_2
		
	Store_1:
		sw		$t8, 0($fp)
		addi	$fp, $fp, -4
		addi	$s0, $s0, 4
		sw		$t7, -4($s1)
		j		vong_lap_2		
	
	SO_1:
		sw		$t7, 0($fp)
		addi	$fp, $fp, -4
		addi	$s0, $s0, 4
		j		vong_lap_2
	

Done_2:
		j		In_bieu_thuc_hau_to

In_toan_hang:
	li	$v0, 1
	addi	$a0, $t8, 0
	syscall
	li		$v0, 11
	addi	$a0, $zero, 32
	syscall
	j		X_vong_lap
	
In_toan_tu:
	li		$v0, 11
	addi		$a0, $t8,-100
	syscall
	li		$v0, 11
	addi	$a0, $zero, 32
	syscall
	j		X_vong_lap
	
X_vong_lap:
	beq		$t9, 1, vong_lap_3
	j		vong_lap_4

IN_bieu_thuc_trung_to:
	addi	$s0, $gp, 0
	li		$v0, 4
	la		$a0, messenger_5
	syscall
	addi	$t9, $0, 1
	vong_lap_3:
		lw		$t8, 0($s0)
		addi	$s0, $s0, 4
		beq		$t8, 100, In_so_0
		beq		$t8, 0, Convert_To_Hau_To
		sgt		$k1,$t8,100
		beq		$k1, 1, In_toan_tu
		j		In_toan_hang
	In_so_0:
		addi	$t8, $0, 0
		j		In_toan_hang
		
		
In_bieu_thuc_hau_to:
	addi	$fp, $fp, -4
	addi	$s0, $sp, -4
	li		$v0, 4
	la		$a0, messenger_2
	syscall
	addi	$t9, $0, 0
	vong_lap_4:
		lw		$t8, 0($s0)
		addi	$s0, $s0, -4
		beq		$t8, 100, In_so_0
		beq		$s0, $fp, tính_gia_tri_bieu_thuc
		sgt 		$k1,$t8,100
		beq		$k1, 1, In_toan_tu
		j		In_toan_hang
# Tinh Toan Bieu Thuc Hau To

	
tính_gia_tri_bieu_thuc:
	addi	$s2, $0, 0
	
	addi	$fp, $fp, 4
	addi	$s0, $sp, -4
	addi	$s1, $sp, 400
	vong_lap_5:
		lw		$t7, 0($s0)
		beq		$s0, $fp, Print_Values
		addi	$s0, $s0, -4
		beq		$t7, $t0, _Cong
		beq		$t7, $t1, _Tru
		beq		$t7, $t2, _Nhan
		beq		$t7, $t3, _Chia
		beq		$t7, $t4, _Chia_Du
		beq		$t7, 100, _Zero
		j		_SO
	
	_Zero:
		addi	$t7, $0, 0
		j		_SO

Print_Values:
	addi	$v0, $0, 56
	la		$a0, messenger_3
	lw		$a1, 400($sp)
	syscall
	

Exit:
	addi	$v0, $0, 10
	syscall

_Chia_Du:
	lw		$s3, -4($s1)
	sw		$zero, -4($s1)
	lw		$s2, -8($s1)
	div		$s2, $s2, $s3
	mfhi	$s2
	addi	$s1, $s1, -4
	sw		$s2, -4($s1)
	j		vong_lap_5
_Cong:
	lw		$s3, -4($s1)
	sw		$zero, -4($s1)
	lw		$s2, -8($s1)
	add		$s2, $s3, $s2
	addi	$s1, $s1, -4
	sw		$s2, -4($s1)
	j		vong_lap_5

_Nhan:
	lw		$s3, -4($s1)
	sw		$zero, -4($s1)
	lw		$s2, -8($s1)
	mult	$s3, $s2
	mflo	$s2
	addi	$s1, $s1, -4
	sw		$s2, -4($s1)
	j		vong_lap_5
_Chia:
	lw		$s3, -4($s1)
	sw		$zero, -4($s1)
	lw		$s2, -8($s1)
	div		$s2, $s2, $s3
	mflo	$s2
	addi	$s1, $s1, -4
	sw		$s2, -4($s1)
	j		vong_lap_5

_Tru:
	lw		$s3, -4($s1)
	sw		$zero, -4($s1)
	lw		$s2, -8($s1)
	sub		$s2, $s2, $s3
	addi	$s1, $s1, -4
	sw		$s2, -4($s1)
	j		vong_lap_5
	
_SO:
	sw		$t7, 0($s1)
	addi	$s1, $s1, 4
	j		vong_lap_5
