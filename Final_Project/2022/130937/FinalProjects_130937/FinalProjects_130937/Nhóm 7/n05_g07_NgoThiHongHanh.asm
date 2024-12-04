.data
infix: .space 256
postfix: .space 256
stack: .space 256
Mess1:	.asciiz "Nhap bieu thuc trung to:\n(Luu y!) Cac so nhap vao nam trong khoang 0-99"
Xuong_dong: .asciiz "\n"
Mess2: .asciiz "Bieu thuc hau to: "
Mess4: .asciiz "Ket qua: "
Mess3: .asciiz "Bieu thuc trung to: "
# Khoi tao bieu thuc trung to
.text
#-------Nhap bieu thuc trung to---------
 li $v0, 54
 la $a0, Mess1  
 la $a1, infix  	# nhap BT trung to
 la $a2, 256
 syscall 
#--------In ra BT trung to--------------  
la $a0, Mess3 
li $v0, 4      		# In mess
syscall	
la $a0, infix     	#In Infix
li $v0, 4
syscall
#----------Chuyen doi BT trung to sang hau to------
li $s6, -1 # i Bien dem trong BT trung to
li $s7, -1 # k Bien dem trong stack
li $t7, -1 # j Bien diem trong bieu thuc hau to
while:
        la $s1, infix       # $s1 = address (infix)
        la $t5, postfix     # $t5 = address(postfix )
        la $t6, stack       # $t6 = address(stack)
        li $s2, '+'         # gan $s2 = '+'
        li $s3, '-'         # gan $s3 = '-'
        li $s4, '*'         # gan $s4 = '*'
        li $s5, '/'         # gan $s5 = '/'
        li $a3, '%'	        # gan $a3 = '%'
	addi $s6, $s6, 1  # i = i ++	
# Xet Infix[i]
	add $s1, $s1, $s6 #$s1= address (infix(i))
	lb $t1, 0($s1)	  # $t1 =  gia tri infix(i)

	beq $t1, $s2, toan_tu # '+'
	nop
	beq $t1, $s3, toan_tu # '-'
	nop
	beq $t1, $s4, toan_tu # '*'
	nop
	beq $t1, $s5, toan_tu # '/'
	nop
	beq $t1, $a3, toan_tu # '%'
	nop
	beq $t1, 10, khong_la_toan_tu # '\n'  #(ki tu \0) ket thuc infix
	nop
	beq $t1, 32, khong_la_toan_tu # ' '   # dau cach
	nop
	beq $t1, $zero, endWhile       # Neu Infix[] khong con phan tu nao thi ket thuc
	nop	
# ---------Dua toan hang vao postfix--------------
	addi $t7, $t7, 1       	# j = j++
	add $t5, $t5, $t7 		# $t5 = address(Postfix[j])	
	sb $t1, 0($t5)  	    # $t1 = postfix[j]	
	lb $a0, 1($s1)          # $a0 = infix[i+1]	
	jal check_number        # $v0 = 1 khi infix[i] la toan hang
	beq $v0, 1, khong_la_toan_tu   # neu no la toan hang=> xet ki tu tiep theo
	nop
	
	add_space:              # Them dau cach giua cac phan tu
	add $t1, $zero, 32
	sb $t1, 1($t5)
	addi $t7, $t7, 1
	
	j khong_la_toan_tu
	nop
	
toan_tu:
	# add to stack ...
		
	beq $s7, -1, pushToStack   #neu stack rong => push to stack
	nop
	
	add $t6, $t6, $s7
	lb $t2, 0($t6)          # t2 = value of stack[counter]	
#-------------------Kiem tra muc do uu tien cua toan tu ----------
# $t1 là infix[i]  ,$t2 là top(stack)    $s2 la '+',$s3 là '-'
	beq $t1, $s2, Muc_1   #Neu toan tu la '+'  hoac '-'=> muc 1
	nop
	beq $t1, $s3, Muc_1    
	nop
	
	li $t3, 2            # Neu phan tu dang xet ko phai '+' hay '-' thi co muc do uu tien la 2
	                     #$t3: Muc do uu tien cua Infix(i)
	j check_t2           #Kiem tra muc do uu tien phan tu top(stack)
	nop		
Muc_1:
	li $t3, 1	
# Xet do uu tien cua top (stack)
check_t2:	
	beq $t2, $s2, Muc1    #Neu toan tu la '+'  hoac '-'=> muc 1
	nop                   
	beq $t2, $s3, Muc1
	nop
	
	li $t4, 2	            # Neu phan tu dang xet ko phai '+' hay '-' thi co muc do uu tien la 2
                            #$t4: Muc do uu tien cua Top(stack)
	j So_sanh_do_uu_tien
	nop		
Muc1:
	li $t4, 1
#So sanh muc do uu tien cua phan tu top(stack) vs phan tu dang xet trong Infix	
So_sanh_do_uu_tien:	
	
	beq $t3, $t4, Dong_muc_do
	nop
	slt $s1, $t3, $t4   #$t3 <=  $t4 = 1:0
	beqz $s1, t3_hon_t4 # $t3 >= $t4 => Dua t1 vao trong stack
	nop	
#-------------------	
# t3 < t4
# pop t2 from stack  va push t2 vao postfix  
#??????????????????
	sb $zero, 0($t6)
	addi $s7, $s7, -1  # scounter ++
	addi $t6, $t6, -1
	la $t5, postfix #postfix = $t5
	addi $t7, $t7, 1
	add $t5, $t5, $t7
	sb $t2, 0($t5)
	j toan_tu # So sanh $t1 vs phan tu tiep stack
	nop	
t3_hon_t4:
# push t1 to stack
	j pushToStack
	nop
#---------------------------------
Dong_muc_do:
# pop t2  tu stack va luu vao postfix  
# push to stack


	sb $zero, 0($t6)   #xoa phan tu $t2 khoi stack
	addi $s7, $s7, -1  # k = k-- (bien dem trong stack )
	la $t5, postfix    # $t5 = address(postfix[0])
	addi $t7, $t7, 1   # j = j++ (Bien diem postfix)
	add $t5, $t5, $t7  #tinh dia chi postfix[k]
	
	sb $t2, 0($t5)     #luu $t2 vao Postfix
	j pushToStack
	nop
#---------Cho ki tu vao trong stack
pushToStack:

	la $t6, stack     #stack = $t6
	addi $s7, $s7, 1  # scounter ++
	add $t6, $t6, $s7 # $t6 = address(stack(j))
	sb $t1, 0($t6)	  #Luu gia tri vao stack
	
	khong_la_toan_tu:	# xet phan tu ke tiep
	j while	
	nop
	
endWhile: # lay ra dia chi top cua stack ($t6)
#Khi gap \0 thi ket thuc	
	addi $s1, $zero, 32
	add $t7, $t7, 1
	add $t5, $t5, $t7  # $t5 = top (postfix)
	la $t6, stack
	add $t6, $t6, $s7
	
popallstack: 
	lb $t2, 0($t6) # t2 = stack[i]
	beq $t2, 0, endPostfix
	sb $zero, 0($t6)
	addi $s7, $s7, -2
	add $t6, $t6, $s7
	
	sb $t2, 0($t5)
	add $t5, $t5, 1
		
	j popallstack
	nop

endPostfix:
# ----------------In ra bieu thuc hau to ---------------------------
la $a0, Mess2
li $v0, 4
syscall

la $a0, postfix
li $v0, 4
syscall

la $a0, Xuong_dong   #Xuong dong
li $v0, 4
syscall
#-----------------------TINH GIA TRI BIEU THUC HAU TO------------------------
#Sau khi pop het ra postfix => stack rong
li $s3, 0           # $s3 = 0 ,Bien dem cua stack (i)
la $s2, stack       #stack = $s2   

# Postfix to stack
while_P_to_S:
	la $s1, postfix          #postfix = $s1
	
	add $s1, $s1, $s3        # lay ra dia chi cua postfix[i]
	lb $t1, 0($s1)           # $t1 = postfix[i]
		
# Neu xau postfix ket thuc
	beqz $t1 end_while_p_to_S
	nop
	
	add $a0, $zero, $t1      # $a0 = postfix[i]
	jal check_number         # $v0 = 1 => La toan hang
	nop                      # $v0 = 0 => la toan tu
	
	beqz $v0, la_toan_tu
	nop
	
	jal Them_so_vao_stack    # Neu postfix(i) la toan hang => Them vao stack
	nop

	j continue
	nop
#Neu postfix(i) la toan tu thi pop ra  		
la_toan_tu:
	
	jal pop                    #pop toan hang tu stack
	nop
	
	add $a1, $zero, $v0         #$a1 la toan hang t1

	jal pop                     #pop toan hang tu stack
	nop
	
	add $a0, $zero, $v0         #$a0 la toan hang t2
		
	add $a2, $zero, $t1         # toan tu
	
	jal Tinh		
	
continue:	# bo qua dau cach	
	add $s3, $s3, 1 # i++	
	j while_P_to_S
	nop
#-----------------------------Tinh--------------------------
#$t1 = postfix(i) khi la toan tu
Tinh:
	sw $ra, 0($sp)          # luu $ra vao $sp
	li $v0, 0               # gan $v0 = 0
	beq $t1, '*', Phep_nhan
	nop
	beq $t1, '/', Phep_chia
	nop
	beq $t1, '+', Phep_cong
	nop
	beq $t1, '-', Phep_tru
	nop
	beq $t1 , '%',Chia_du
	nop 
	
	Phep_nhan:
		mul $v0, $a0, $a1
		j Push_KQ
	Phep_chia:
		div $a0, $a1
		mflo $v0
		j Push_KQ
	Phep_cong:
		add $v0, $a0, $a1
		j Push_KQ
	Phep_tru:
		sub $v0, $a0, $a1
		j Push_KQ
	Chia_du:
	        div $a0,$a1
	        mfhi $v0
	        j Push_KQ		
	Push_KQ: # day gia tri tinh duoc vao stack
		add $a0, $v0, $zero   #$a0 = $v0 
		jal push
		nop
		lw $ra, 0($sp) 
		jr $ra                #Quay lai vong lap while_P_to_S
		nop	
#----------------------------Them so vao stack----------------
#$s3 : bien dem cua postfix[]  ,$s2 = stack
#$s1 = postfix[i]
# $t1 :toan hang dang xet
Them_so_vao_stack:
	sw $ra, 0($sp)              #luu $ra vao $sp
	li $v0, 0
	
	While_add:                 # while add number to stack
		beq $t1, '0', case_0
		nop
		beq $t1, '1', case_1
		nop
		beq $t1, '2', case_2
		nop
		beq $t1, '3', case_3
		nop
		beq $t1, '4', case_4
		nop
		beq $t1, '5', case_5
		nop
		beq $t1, '6', case_6
		nop
		beq $t1, '7', case_7
		nop
		beq $t1, '8', case_8
		nop
		beq $t1, '9', case_9
		nop
		
		case_0:
			j end_case 
		case_1:
			addi $v0, $v0, 1	
			j end_case
			nop
		case_2:
			addi $v0, $v0, 2
			j end_case
			nop
		case_3:
			addi $v0, $v0, 3
			j end_case
			nop
		case_4:
			addi $v0, $v0, 4
			j end_case
			nop
		case_5:
			addi $v0, $v0, 5
			j end_case
			nop
		case_6:
			addi $v0, $v0, 6
			j end_case
			nop
		case_7:
			addi $v0, $v0, 7
			j end_case
			nop
		case_8:
			addi $v0, $v0, 8
			j end_case
			nop
		case_9:
			addi $v0, $v0, 9
			j end_case
			nop
end_case: 
			
			add $s3, $s3, 1     # counter++
			la $s1, postfix     #postfix = $s1 
	
			add $s1, $s1, $s3   #Tinh dia chi postfix[i]
			lb $t1, 0($s1)      # Luu $t1 = postfix[i]
		
			beq $t1, $zero, end_While_add
			beq $t1, ' ', end_While_add
			
			mul $v0, $v0, 10  #$v0 = $v0 * 10
			
			j While_add		
end_While_add:
		add $a0, $zero, $v0   #luu $a0 = $v0
		jal push
		lw $ra, 0($sp)        # get $ra
		jr $ra
		nop			
#-----------------Kiem tra ki tu nhap vao co phai so hay khong?-------------------
check_number:        
	li $t8, '0'       # $t8 = 0
	li $t9, '9'       #$t9 = 9
	
	beq $t8, $a0, toan_hang         # Kiem tra xem $a0 co thuoc khoang tu 0 - 9 khong?
	beq $t9, $a0, toan_hang         
	
	slt $v0, $t8, $a0                 # 0 < $a0=> $v0 = 1 : 0
	beqz $v0, khong_la_toan_hang      # $v0 = 0 => ko phai so
	
	slt $v0, $a0, $t9               # $a0 < 9 => $v0 = 1: 0
	beqz $v0, khong_la_toan_hang    # $v0 = 0 => ko phai so
		
toan_hang: 

	li $v0, 1             
	jr $ra
	nop
khong_la_toan_hang:

	li $v0, 0            	
	jr $ra
	nop
#---------------------Pop toan hang tu stack ------------------------------------------
#$s2 = stack
#$v0 : gia tri pop
pop:
	lw $v0, -4($s2)   #$v0 = top
	sw $zero, -4($s2) #Lay ra gia tri top va xoa gtri top
	add $s2, $s2, -4  #giam dia chi top
	jr $ra
	nop
#----------------------Push gia tri sau khi tinh vao stack----------------------------------
#$a0: gia tri push
push:
	sw $a0, 0($s2)  # Luu top = $a0
	add $s2, $s2, 4 # tang dia chi 
	jr $ra
	nop	
end_while_p_to_S:
# add null to end of stack
# -------------In ra gia tri bieu thuc hau to----------------------------
la $a0, Mess4
li $v0, 4
syscall

jal pop
add $a0, $zero, $v0 
li $v0, 1
syscall

la $a0, Xuong_dong
li $v0, 4
syscall

