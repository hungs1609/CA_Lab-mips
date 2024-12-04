.data
	String1: .asciiz  "                                             *************   \n"
	String2: .asciiz  "**************                              *3333333333333*  \n"
	String3: .asciiz  "*222222222222222*                           *33333********   \n"
	String4: .asciiz  "*22222******222222*                         *33333*          \n"
	String5: .asciiz  "*22222*      *22222*                        *33333********   \n"
	String6: .asciiz  "*22222*       *22222*       *************   *3333333333333*  \n"
	String7: .asciiz  "*22222*       *22222*     **11111*****111*  *33333********   \n"
	String8: .asciiz  "*22222*       *22222*   **1111**       **   *33333*          \n"
	String9: .asciiz  "*22222*      *222222*   *1111*              *33333********   \n"
	String10: .asciiz "*22222*******222222*   *11111*              *3333333333333*  \n"
	String11: .asciiz "*2222222222222222*     *11111*               *************   \n"
	String12: .asciiz "***************        *11111*                               \n"
	String13: .asciiz "      ---              *1111**                               \n"
	String14: .asciiz "    ( o o )             *1111****   *****                    \n"
	String15: .asciiz "    (  >  )              **111111***111*                     \n"
	String16: .asciiz "     -----                 ***********      dce.hust.edu.vn  \n"
	Message0: .asciiz "------------IN CHU-----------\n"
	Case1_text:		.asciiz" 1. In ra chu\n"
	Case2_text:		.asciiz" 2. In ra chu rong\n"
	Case3_text:		.asciiz" 3. Thay doi vi tri\n"
	Case4_text:		.asciiz" 4. Doi mau cho chu\n"
	Thoat:    		.asciiz" 5. Thoat\n"
	Nhap:     		.asciiz" Nhap chu nang muon thuc hien gia tri: "
	Chu_D:     		.asciiz" Nhap mau cho chu D(0->9): "
	Chu_C:     		.asciiz" Nhap mau cho chu C(0->9): "
	Chu_E:     		.asciiz" Nhap mau cho chu E(0->9): "
.text
	# Set up color default characters
	addi $t5, $zero, 50 	# Mau hien tai cua chu D
	addi $t6, $zero, 49		# Mau hien tai cua chu C
	addi $t7, $zero, 51		# Mau hien tai cua chu E
main:
	li $v0, 4
	la $a0, Message0		# In ra Menu
	syscall
	li $v0, 4
	la $a0, Case1_text		# In ra Case1
	syscall
	li $v0, 4
	la $a0, Case2_text		# In ra Case2
	syscall
	li $v0, 4
	la $a0, Case3_text		# In ra Case3
	syscall
	li $v0, 4
	la $a0, Case4_text		# In ra Case4
	syscall
	li $v0, 4
	la $a0, Thoat			# In ra Thoat
	syscall
	li $v0, 4
	la $a0, Nhap			# In ra Nhap
	syscall
	
	li $v0, 5
	syscall
	
Case1_menu:
	bne $v0, 1, Case2_menu	# Khac chuc nang 1 => 2
	j Case1
Case2_menu:
	bne $v0, 2, Case3_menu	# Khac chuc nang 2 => 3
	j Case2		
Case3_menu:
	bne $v0, 3, Case4_menu	# Khac chuc nang 3 => 4
	j Case3	
Case4_menu:
	bne $v0, 4, Case5_menu	# Khac chuc nang 4 => 5
	j Case4		
Case5_menu:
	bne $v0, 5, main		# Khac chuc nang 5 => Chon lai chuc nang
	j Exit					# Chuc nang 5 => Exit
	
# Chuc nang 1: In ra giao dien chu
Case1:
	addi 	$t0, $0, 0			# Bien dem so dong: $t0 = i = 0
	addi 	$t1, $0, 16			# Tong so dong: $t1 = 16
	la 		$a0, String1
Loop_Case1:	
	beq 		$t1, $t0, main		# $t0 = $t1 => main. Ket thuc chuc nang 1
	li 		$v0, 4
	syscall	
	addi 	$a0, $a0, 63		# 1 dong co 63 ky tu. Chuyen in dong tiep theo
	addi 	$t0, $t0, 1			# So dong i += 1
	j Loop_Case1

# Chuc nang 2: In ra giao dien chu khong co mau (chi co vien)
Case2:
	addi 	$s0, $0, 0			# Bien dem so dong: $s0 = i = 0
	addi 	$s1, $0, 16
	la   	$s2, String1		# Lay ra dia chi cua String1 vao $s2

Loop_Case2:	
	beq  	$s1, $s0, main		# $s0 = $s1 => main. Ket thuc chuc nang 2
	addi 	$t0, $zero, 0		# Bien dem ky tu trong 1 dong $t0 = j = 0
	addi 	$t1, $zero, 63      # 1 dong co 63 ky tu. Chuyen in dong tiep theo
KiemTraMau:
	beq 	$t1, $t0, End			# $t0 = $t1 => End. Ket thuc in ra 1 hang
	lb  	$t2, 0($s2)				# Load byte tu dia chi 0 cua thanh ghi $s2
	slti	$t3, $t2, 48			# $t3 = $t2 < 48 ? 1 : 0
	beq 	$t3, $zero, LonHon_0 	# Lon hon 0 => LonHon_0
	j In_Ky_Tu
LonHon_0:
	slti	$t3, $t2, 59			# 48 <= $t3 = $t2 < 59 ? 1 : 0
	beq  	$t3, $zero, In_Ky_Tu	# Lon hon 9 => In_Ky_Tu
	addi 	$t2, $zero, 32  		# Doi mau bang " "
	j In_Ky_Tu	
In_Ky_Tu: 	
	li 		$v0, 11 				# In tung ky tu
	addi 	$a0 $t2 0
	syscall
	addi 	$s2 $s2 1        		# Tang dia chi cua $s2. Chuyen toi ky tu tiep theo
	addi 	$t0, $t0, 1      		# Dem ky tu j += 1
	j KiemTraMau
End:	
	addi 	$s0 $s0 1        	# So dong i += 1
	j Loop_Case2

# Chuc nang 3: Dao vi tri cac chu
Case3:
	addi 	$s0, $zero, 0       # Bien dem so dong $s0 = i = 0
	addi 	$s1, $zero, 16
	la 		$s2, String1        # Lay ra dia chi cua String1 vao $s2
Loop_Case3:	
	beq 	$s1, $s0, main		# $s0 = $s1 => main. Ket thuc chuc nang 3
	# Tach chuoi lon tao ra 3 chuoi nho phan chia 3 chu 		
	sb 		$zero, 22($s2)		# Truoc chu C = "null"
	sb 		$zero, 43($s2)		# Truoc chu E = "null"
	sb 		$zero, 60($s2)		# Truoc \n = "null"
	# In doi vi tri
	li 		$v0, 4 
	la 		$a0 44($s2) 			# In chu E
	syscall

	li 		$v0, 4 
	la 		$a0 23($s2) 			# In chu C
	syscall
	
	li 		$v0, 4 
	la 		$a0 0($s2) 			# In chu D
	syscall
	
	li 		$v0, 4 
	la 		$a0 61($s2)			# In phan con lai \n
	syscall
	# Gop lai thanh chuoi lon ban dau
	addi 	$t1, $zero, 32		# " "
	sb 		$t1, 22($s2)		# Truoc chu C = " "
	sb 		$t1, 43($s2)		# Truoc chu E = " "
	sb 		$t1, 60($s2)		# Truoc \n = " "
	
	addi 	$s0, $s0, 1			# So dong i += 1
	addi 	$s2, $s2, 63		# Gan lai dia chi moi xuong dong tiep theo += 63	
	j Loop_Case3
	
# Chuc nang 4: Doi mau chu
Case4:
	j Input_D
Input_D:	
	li 		$v0, 4		
	la 		$a0, Chu_D
	syscall

	li 		$v0, 5				# Nhap vao mau cua chu D muon doi
	syscall

	addi		$t2, $v0, 0				
	slti		$t3, $t2, 0				# $t3 = $t2 < 0 ? 1 : 0
	bne 		$t3, $zero, Input_D 		# Nho hon 0 => Input_D: Nhap lai
	slti		$t3, $t2, 9				# 0 <= $t3 = $t2 < 9 ? 1 : 0
	beq 		$t3, $zero, Input_D		# Lon hon 9 => Input_D: Nhap lai
	addi		$s3, $v0, 48	        # Luu lai gia tri mau cua chu D = $s3
Input_C:	
	li 		$v0, 4		
	la 		$a0, Chu_C
	syscall
	
	li 		$v0, 5				# Nhap vao mau cua chu C muon doi
	syscall
	
	addi		$t2, $v0, 0
	slti		$t3, $t2, 0				# $t3 = $t2 < 0 ? 1 : 0
	bne 		$t3, $zero, Input_C 	# Nho hon 0 => Input_C: Nhap lai
	slti		$t3, $t2, 9				# 0 <= $t3 = $t2 < 9 ? 1 : 0
	beq  	$t3, $zero, Input_C		# Lon hon 9 => Input_C: Nhap lai 
	addi		$s4, $v0, 48	        # Luu lai gia tri mau cua chu C = $s4
Input_E:	            
	li 		$v0, 4		
	la 		$a0, Chu_E
	syscall
	
	li 		$v0, 5				# Nhap vao mau cua chu E muon doi
	syscall

	addi		$t2, $v0, 0
	slti		$t3, $t2, 0				# $t3 = $t2 < 0 ? 1 : 0
	bne 		$t3, $zero, Input_C 	# Nho hon 0 => Input_E: Nhap lai
	slti		$t3, $t2, 9				# 0 <= $t3 = $t2 < 9 ? 1 : 0
	beq  	$t3, $zero, Input_C		# Lon hon 9 => Input_E: Nhap lai 
	addi		$s5, $v0, 48	        # Luu lai gia tri mau cua chu E = $s5
Set_Default:
	addi 	$s0, $zero, 0       	# Bien dem so dong $s0 = i = 0
	addi    $s1, $zero, 16
	la      $s2, String1	    	# Lay ra dia chi cua String1 vao $s2
	addi    $a1, $zero, 48          # Gia tri cua so 0
	addi	$a2, $zero, 58          # Gia tri cua so 9
Loop_Case4:	            
	beq     $s1, $s0, Update_Mau	# $s0 = $s1 => Update_Mau: Cap nhat lai mau moi cho chu
	addi 	$t0, $zero, 0			# Bien dem ky tu trong 1 dong $t0 = j = 0
	addi 	$t1, $zero, 63      	# 1 dong co 63 ky tu. Chuyen in dong tiep theo
Check:
	beq 		$t1, $t0, Complete		
	lb 		$t2, 0($s2)	 			# Lay ra gia chi cua dia chi 0($s2) vao $t2
Check_D:
	slti		$s6, $t0, 23			# $t0 < 23 ? 1 : 0
	beq		$s6, $zero, Check_C	 	# $s6 = 0 => Check_C: Thay doi het mau cua chu D
    beq		$t2, $t5, Update_D
    j ChuyenKyTu
Check_C: 
	slti		$s6, $t0, 44			# $t0 < 44 ? 1 : 0
	beq		$s6, $zero, Check_E	 	# $s6 = 0 => Check_E: Thay doi het mau cua chu C
    beq		$t2, $t6, Update_C
    j ChuyenKyTu
Check_E: 
	beq		$t2, $t7, Update_E
    j ChuyenKyTu	
Update_D: 	
	sb 		$s3 0($s2)
	j ChuyenKyTu
Update_C: 	
	sb		$s4 0($s2)
	j ChuyenKyTu
Update_E: 	
	sb		$s5 0($s2)
	j ChuyenKyTu
ChuyenKyTu: 	
	addi	$s2, $s2, 1 			# Chuyen toi ky tu tiep theo
	addi 	$t0, $t0, 1				# Dem ky tu j += 1
	j Check
Complete:	
	li 		$v0, 4  
	addi 	$a0, $s2, -63			# Chuyen ve ky tu dau cua dong
	syscall
	addi 	$s0, $s0, 1 			# So dong i += 1
	j Loop_Case4
Update_Mau: 
	move 	$t5, $s3
	move 	$t6, $s4
	move 	$t7, $s5
	j main	
Exit:
