.data
	messenger_1:		.asciiz		"Nhap bieu thuc can tinh: "
	messenger_2:		.asciiz		"\nBieu Thuc Hau To La: "
	messenger_3:		.asciiz		"\nKet qua sau cua bieu thuc hau to la: "
	messenger_4:		.asciiz		"Bieu thuc khong hop le!  Hay nhap lai bieu thuc!"
	messenger_5:		.asciiz		"\nBieu Thuc Trung To La: "
	A:					.space		1000
.text

data:
	addi	$t0, $zero, -43			# Phep Cong
	addi	$t1, $zero, -45			# Phep Tru
	addi	$t2, $zero, -42			# Phep Nhan
	addi	$t3, $zero, -47			# Phep Chia
	addi	$t4, $zero, -37			# Phep Chia Lay Du
	addi	$t5, $zero, -40			# Ngoac Mo
	addi	$t6, $zero, -41			# Ngoac Dong
	addi	$s3, $zero, -32			# Dau Cach
	addi	$s4, $zero, -10			# Enter, xuong dong
	addi	$s2, $zero, 10			
	addi	$fp, $zero, 100			# Coi 100 la bieu dien cua so 0 trong Stack1
	
Nhap_bieu_thuc:				# Ham nhap bieu thuc
	li		$v0, 54
	la		$a0, messenger_1
	la		$a1, A
	la		$a2, 1000 		# Toi da 1000 ky tu
	syscall
	
	addi	$s0, $gp, 0		# Stack 1
	la		$t7, A			# Luu dia chi cua bieu thuc vua nhap vao $t7
	
Xet_Thanh_Phan:
	Read_Char:
		lb		$t8, 0($t7)
		beq		$t8, 0, Kiem_Tra_Hop_Le_2		# Kiem tra xem gap ky tu NULL chua
		beq		$t8, '\n', Kiem_Tra_Hop_Le_2	# Kiem tra xem co phai Enter khong
		beq		$t8, '+', push_s1		# Phep Cong
		beq		$t8, '-', push_s1		# Phep Tru
		beq		$t8, '*', push_s1		# Phep Nhan
		beq		$t8, '/', push_s1		# Phep Chia
		beq		$t8, '%', push_s1		# Chia Lay Du
		beq		$t8, '(', push_s1		# Ngoac Mo
		beq		$t8, ')', push_s1		# Ngoac Dong
		beq		$t8, ' ', continue_char	# Dau Cach
		
		slti	$t9, $t8, 48			# Kiem tra xem co phai so hay khong
		bne		$t9, $zero, Nhap_Lai	# Neu khong phai cac phep toan, dau cach,
										# Kiem_Tra_Hop_Le_2 hay so thi bieu thuc ko hop le
		slti	$t9, $t8, 58			# 48 <= $t8 < 58
		bne		$t9, $zero, Interger	# Neu la so thi chuyen den Interger de phan tich
		
		j		Nhap_Lai				# Cac truong hop con lai deu ko hop le

	push_s1:	# Luu cac phep toan vao stack_1
		sub		$t8, $0, $t8			# Khi luu vao stack -$t8 se dai dien cho cac toan tu
		sw		$t8, 0($s0)					
		addi	$t7, $t7, 1				
		addi	$s0, $s0, 4
		j		Read_Char				# Sau khi luu thi xet phan tu tiep

	continue_char:						# Ham nay se xet phan tu tiep theo
		addi	$t7, $t7, 1				# Khi gap dau cach thi bo qua xet phan tu tiep
		j		Read_Char			

	Nhap_Lai:							# Ham de nhap lai ham khi ham khong dung dinh dang
		li		$v0, 55
		la		$a0, messenger_4
		syscall
		addi	$s0, $gp, 0				# Reset l?i gia tri cua stack1
		Reset:
			lw		$t8, 0($s0)			
			beq		$t8, $zero, Nhap_bieu_thuc	# Khi da reset xong thi nhap lai bieu thuc
			sw		$zero, 0($s0)				# Reset gia tri cua stack1
			addi	$s0, $s0, 4
			j		Reset
		
	Store_Digit:							# Neu day la so co 1 chu so thi luu truc tiep vao stack_1
		beq		$s5, 0, Store_Zero			# Xet day co la so 0 hay khong
		sw		$s5, 0($s0)					# Neu khac 0 thi luu vao stack1
		addi	$t7, $t7, 1
		addi	$s0, $s0, 4
		j		Read_Char
		
	Store_Zero:								# Ham nay de luu 100 thay cho so 0 vao stack1
		addi	$s5, $zero, 100
		sw		$s5, 0($s0)
		addi	$t7, $t7, 1
		addi	$s0, $s0, 4
		j		Read_Char

	Interger_2:								# Ham se xet so co 2 chu so se luu vao stack_1
		multu	$s5, $s2					# Lay so hang chuc
		mflo	$s5							
		addi	$t8, $t8, -48				# Tru ma ascii cua hang don vi de lay Integer tuong ung
		add		$s5, $s5, $t8				# Cong vao de lay dc so can tim
		sw		$s5, 0($s0)					# Luu so 2 chu so vao tack1
		addi	$s0, $s0, 4					
		addi	$t7, $t7, 2				# Xet phan tu o vi tri i+2 de xet day co phai so 3 chu so ko
		lb		$t8, 0($t7)
		beq		$t8, 0, Kiem_Tra_Hop_Le_2	# Neu xet xong bieu thuc dau vao thi chuyen den ham nay
		beq		$t8, '\n', Kiem_Tra_Hop_Le_2
		slti	$t9, $t8, 58			# Neu la so co 3 chu so thi nhap lai bieu thuc
		beq		$t9, $zero, Nhap_Lai
		slti	$t9, $t8, 48			#     48 <= 48 <58 ?
		beq		$t9, $zero, Nhap_Lai
		j		Read_Char
	
	Interger:									# Ham xet so co 1 chu so
		addi	$s5, $t8, -48					# Ta lay ascii ta tru cho 48 se ra so Integer tuong ung
		lb		$t8, 1($t7)						# Xet ky tu tiep theo xem co phai la so 2 chu so hay khong
		slti	$t9, $t8, 48
		bne		$t9, $zero, Store_Digit			# Neu la so co 1 chu so thi t se luu luon vao Stack_1
		slti	$t9, $t8, 58
		bne		$t9, $zero, Interger_2			# Neu la so co 2 chu so thi t se sang de chuyen thanh so 2 chu so
		beq		$t8, 0, Kiem_Tra_Hop_Le_2		# Kiem tra xem co phai ky tu 'NULL' hay khong
		beq		$t8, $s4, Kiem_Tra_Hop_Le_2		# Kiem tra xem co phai ky tu '\n' hay khong

# Tat ca da duoc luu trong Stack_1
# Giai phong thanh ghi $t7, $t8, $t9, $s2, $s3, $s4, $s5, $s6, $s7
# $s0 la stack_1 luu cac toan tu, toan hang cua bieu thuc
Kiem_Tra_Hop_Le_2:	# Kiem tra xem Bieu Thuc Nhap co Hop Le hay Khong
	addi	$s0, $gp, 0
	addi	$fp, $zero, 0
	
	lw		$t8, 0($s0)				# Xet Phan tu dau tien Neu la cac toan tu thi BT ko hop le
	beq		$t8, $t2, Nhap_Lai		# Phep Nhan
	beq		$t8, $t3, Nhap_Lai		# Phep Chia
	beq		$t8, $t4, Nhap_Lai		# Chia Lay Du
	beq		$t8, $t6, Nhap_Lai		# Ngoac Dong
	
	Loop:
		lw		$t8, 0($s0)
		beq		$t8, $t0, Cong			# Phep Cong
		beq		$t8, $t1, Cong			# Phep Cong
		beq		$t8, $t2, Cong			# Phep Nhan
		beq		$t8, $t3, Cong			# Phep Chia
		beq		$t8, $t4, Cong			# Chia Lay Du
		beq		$t8, $t5, Mo_Ngoac		# Mo Ngoac
		beq		$t8, $t6, Dong_Ngoac	# Dong Ngoac
		beq		$t8, 0, Done			# NULL
		j		Number
		
		Cong:
			lw		$t8, 4($s0)			# Xet ph?n t? sau d?u c?ng
			beq		$t8, $t0, Nhap_Lai			# Phep Cong
			beq		$t8, $t1, Nhap_Lai			# Phep Tru
			beq		$t8, $t2, Nhap_Lai			# Nhan
			beq		$t8, $t3, Nhap_Lai			# Chia
			beq		$t8, $t4, Nhap_Lai			# Chia Lay Du
			beq		$t8, $t6, Nhap_Lai			# Dong Ngoac
			beq		$t8, 0  , Nhap_Lai			# NULL
			addi	$s0, $s0, 4
			j		Loop

		Mo_Ngoac:						# Xet Cac phan tu sau dau ngoac mo
			lw		$t8, 4($s0)
			beq		$t8, $t2, Nhap_Lai			# Nhan
			beq		$t8, $t3, Nhap_Lai			# Chia
			beq		$t8, $t4, Nhap_Lai			# Chia Lay Du
			beq		$t8, 0  , Nhap_Lai			# NULL		
			addi	$s0, $s0, 4
			addi	$fp, $fp, 1					# Gap ngoac mo thì fp+1
			j		Loop
	
		Dong_Ngoac:						# Xet Cac phan tu sau dau ngoac dong
			lw		$t8, 4($s0)
			beq		$t8, $t5, Nhap_Lai	# Mo Ngoac
			addi	$fp, $fp, -1		# Gap ngoac dong thì fp -1	
			blt		$fp, 0, Nhap_Lai	# Neu dau dong ngoac truoc dau ngoac nhap lai
			beq		$t8, 0, Done
			slti	$t9, $t8, 0			# Neu khong phai toan tu nhap lai
			beq		$t9, 0, Nhap_Lai
			addi	$s0, $s0, 4
			j		Loop
	
		Number:		# Xet phan tu sau cac toan hang
			lw		$t8, 4($s0)
			beq		$t8, $t5, Nhap_Lai			# Mo Ngoac
			beq		$t8, 0  , Done
			addi	$s0, $s0, 4
			j		Loop

Done:	# Xet cac dau ngoac co dung vi tri hay khong
	bne		$fp, 0, Nhap_Lai
	j		Print_Infix
	



Convert_To_Hau_To:
# Tat ca da duoc luu trong Stack_1
# Giai phong thanh ghi $t7, $t8, $t9, $s2, $s3, $s4, $s5, $s6, $s7, $fp
# $s0 la stack_1 luu cac toan tu, toan hang cua bieu thuc

# Chuyen sang hau to
	addi	$s0, $gp, 0				# Stack 1 Chua Cac Toan Tu, Toan Hang Sau khi da check
	addi	$s1, $sp, 4				# Stack 2 Chua Cac Toan Tu De Duyet
	addi	$fp, $sp, -4			# Stack 3 Chua PostFix
	
	Head_Sub_Add:
	lw		$t7, 0($s0)
	beq		$t7, -45, Check_Sub		# Check phep Tru
	beq		$t7, -43, Check_Add		# Check phep Cong
	Loop_2:		# Xet tung phan tu
		lw		$t7, 0($s0)
		beq		$t7, $t0, Dau_Cong			
		beq		$t7, $t1, Dau_Cong
		beq		$t7, $t2, Dau_Nhan
		beq		$t7, $t3, Dau_Nhan
		beq		$t7, $t4, Dau_Nhan
		beq		$t7, $t5, Ngoac_Mo
		beq		$t7, $t6, Ngoac_Dong
		beq		$t7, 0  , NULL		# Khi xet het phan tu cua bieu thuc chuyen den NUll
		beq		$t7, $s4, NULL		# de dua cac phan tu con lai cua Stack 2 sang Stack 3
		j		Number_1
		
	Check_Sub:		# Kiem tra phan tu dau co la dau -
		sw		$zero, 0($fp)		# (-3) = 03-
		lw		$t8, 4($s0)
		sw		$t8, -4($fp)
		sw		$t7, -8($fp)
		addi	$fp, $fp, -12
		addi	$s0, $s0, 8
		j		Loop_2
		
	Check_Add:		# Nau phan tu dau la dau + thi b? qua
		addi	$s0, $s0, 4
		j		Loop_2
		

	Ngoac_Mo:		# Khi la dau ngoac mo
		lw		$t7, 4($s0)				# Xet phan tu tiep la gi
		addi	$s0, $s0, 4
		sw		$t5, 0($s1)				# Luu Ngoac Mo vao Stack 2
		addi	$s1, $s1, 4
		beq		$t7, -45, Check_Sub		# Neu la - thi vao Check_Sub
		beq		$t7, -44, Check_Add		# Tuong tu
		j		Loop_2
	
	Ngoac_Dong:		# Khi dong ngoac
		lw		$t7, -4($s1)			# Xet cac phan tu trong stack chua toan tu
		beq		$t5, $t7, Continues_3	# Neu la ngoac mo thi xet cac phan tu tiep
		sw		$t7, 0($fp)				# Neu khong phai chuyen cac toan tu sang Stack 3
		sw		$zero, -4($s1)			# Reset lai phan tu da chuyen cua Stack 2
		addi	$s1, $s1, -4			# 
		addi	$fp, $fp, -4	
		j		Ngoac_Dong
		
	Continues_3:
		sw		$zero, -4($s1)			# Xoa ngoac mo khoi Stack 2 chua toan tu
		addi	$s1, $s1, -4			
		j		Continues_2
		
	Dau_Cong:							# Neu la cong hoac tru thi 
		lw		$t8, -4($s1)			
		beq		$t8, 0, Store_2			# Neu Stack 2 trong thi luu truc tiep vao
		beq		$t8, $t5, Store_2		# Neu truoc no la dau ngoac thi luu vao 
		j		Store					# Neu khong phai chuyen sang Store
		
		
	Store_2:		
		sw		$t7, 0($s1)				# Dung de luu cac toan hang vao Stack 2
		addi	$s1, $s1, 4
		addi	$s0, $s0, 4
		j		Loop_2	
		
	Dau_Nhan:							# Dau nhan
		lw		$t8, -4($s1)			# Xet phan tu trong Stack 2
		beq		$t8, $t2, Store_N		# Neu gap dau nhan thi luu chuyen
		beq		$t8, $t3, Store_N		# Neu gap dau chia thi luu chuyen
		beq		$t8, $t4, Store_N		# Neu gap dau chia du thi chuyen
		
		sw		$t7, 0($s1)				# Neu khong phai thi luu luon vao Stack2
		addi	$s1, $s1, 4		
		addi	$s0, $s0, 4
		j		Loop_2
	
	Store_N:			
		sw		$t8, 0($fp)			# Luu phan tu dau Stack 2 vao Stack 3 Postfix
		addi	$fp, $fp, -4		
		addi	$s0, $s0, 4
		sw		$t7, -4($s1)		# Sau do luu phan tu dang xet vao Stack 2
		j		Loop_2

		
	
	Continues_2:					# Xet tiep phan tu
		addi	$s0, $s0, 4
		j		Loop_2
		
	NULL:	# Sau khi xet het bieu thuc thi dua cac toan tu con lai cua st2->st3
		lw		$t8, -4($s1)	
		beq		$t8, 0, Done_2		# Sau khi dua het thi chuyen xong
		sw		$zero, -4($s1)		# Khi lay phan tu ra khoi st2 thi reset 
		addi	$s1, $s1, -4
		sw		$t8, 0($fp)			# Luu vao Stack 3
		addi	$fp, $fp, -4
		j		NULL
	
	Store:		# Khi la dau cong thi
		sw		$t8, 0($fp)			# Chuyen phan tu dau tien cua Stack2 -> Stack3
		addi	$fp, $fp, -4
		addi	$s0, $s0, 4
		lw		$t8, -8($s1)		# Xet tiep phan tu Neu la nhung phan tu co do uu 
		beq		$t8, $t0, Store_3	# Uu tien thap ra Stack 3
		beq		$t8, $t1, Store_3
		sw		$t7, -4($s1)		# Neu khong thi luu toan tu vao Stack 2
		j		Loop_2
	Store_3:	# 
		sw		$t8, 0($fp)
		addi	$fp, $fp, -4
		sw		$zero, -4($s1)
		sw		$t7, -8($s1)
		addi	$s1, $s1, -4
		j		Loop_2
		
	Store_1:
		sw		$t8, 0($fp)
		addi	$fp, $fp, -4
		addi	$s0, $s0, 4
		sw		$t7, -4($s1)
		j		Loop_2		
	
	Number_1:	# Gap toan hang
		sw		$t7, 0($fp)		# Gap toan hang luu luon vao Stack 3
		addi	$fp, $fp, -4
		addi	$s0, $s0, 4
		j		Loop_2
	

Done_2:
		j		Print_Postfix

Print_number:	# N?u g?p s? thì in s?
	li	$v0, 1
	addi	$a0, $t8, 0
	syscall
	li		$v0, 11
	addi	$a0, $zero, 32
	syscall
	j		X_Loop
	
Print_operater:	# N?u là toán t? thì in ki?u char
	li		$v0, 11
	abs		$a0, $t8
	syscall
	li		$v0, 11
	addi	$a0, $zero, 32
	syscall
	j		X_Loop
	
X_Loop:			
	beq		$t9, 1, Loop_3
	j		Loop_4

Print_Infix:	# In h?u t?
	addi	$s0, $gp, 0
	li		$v0, 4
	la		$a0, messenger_5
	syscall
	addi	$t9, $0, 1
	Loop_3: # Lap de in phan tu
		lw		$t8, 0($s0)
		addi	$s0, $s0, 4
		beq		$t8, 100, Print_zero
		beq		$t8, 0, Convert_To_Hau_To
		blt		$t8, 0, Print_operater
		j		Print_number
	Print_zero:
		addi	$t8, $0, 0
		j		Print_number
		
		
Print_Postfix:	# In ra Trung t?
	addi	$fp, $fp, -4
	addi	$s0, $sp, -4
	li		$v0, 4
	la		$a0, messenger_2
	syscall
	addi	$t9, $0, 0
	Loop_4:		# Lap de in phan tu
		lw		$t8, 0($s0)
		addi	$s0, $s0, -4
		beq		$t8, 100, Print_zero
		beq		$s0, $fp, Calculater
		blt		$t8, 0, Print_operater
		j		Print_number
		
		
# Tinh Toan Bieu Thuc Hau To

	
Calculater:	
	addi	$s2, $0, 0
	
	addi	$fp, $fp, 4		# Lam dieu kien ngat
	addi	$s0, $sp, -4	# Stack luu Postfix
	addi	$s1, $sp, 20  	# Luu cac toan hang
	Loop_5:		# Xet cac phan tu
		lw		$t7, 0($s0)
		beq		$s0, $fp, Print_Values
		addi	$s0, $s0, -4
		beq		$t7, $t0, _Cong
		beq		$t7, $t1, _Tru
		beq		$t7, $t2, _Nhan
		beq		$t7, $t3, _Chia
		beq		$t7, $t4, _Chia_Du
		beq		$t7, 100, _Zero
		j		_Number
	
	_Zero:
		addi	$t7, $0, 0
		j		_Number

Print_Values:
	addi	$v0, $0, 56
	la		$a0, messenger_3
	lw		$a1, 20($sp)
	syscall
	

Exit:
	addi	$v0, $0, 10
	syscall

_Cong:
	lw		$s3, -4($s1)
	sw		$zero, -4($s1)
	lw		$s2, -8($s1)
	add		$s2, $s3, $s2
	addi	$s1, $s1, -4
	sw		$s2, -4($s1)
	j		Loop_5
_Tru:
	lw		$s3, -4($s1)
	sw		$zero, -4($s1)
	lw		$s2, -8($s1)
	sub		$s2, $s2, $s3
	addi	$s1, $s1, -4
	sw		$s2, -4($s1)
	j		Loop_5
_Nhan:
	lw		$s3, -4($s1)
	sw		$zero, -4($s1)
	lw		$s2, -8($s1)
	mult	$s3, $s2
	mflo	$s2
	addi	$s1, $s1, -4
	sw		$s2, -4($s1)
	j		Loop_5
_Chia:
	lw		$s3, -4($s1)
	sw		$zero, -4($s1)
	lw		$s2, -8($s1)
	div		$s2, $s2, $s3
	mflo	$s2
	addi	$s1, $s1, -4
	sw		$s2, -4($s1)
	j		Loop_5
_Chia_Du:
	lw		$s3, -4($s1)
	sw		$zero, -4($s1)
	lw		$s2, -8($s1)
	div		$s2, $s2, $s3
	mfhi	$s2
	addi	$s1, $s1, -4
	sw		$s2, -4($s1)
	j		Loop_5
_Number:
	sw		$t7, 0($s1)
	addi	$s1, $s1, 4
	j		Loop_5
