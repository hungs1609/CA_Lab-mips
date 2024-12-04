.eqv MONITOR_SCREEN 0x10010000
.eqv RED 0x00FF0000
.eqv GREEN 0x0000FF00
.eqv BLUE 0x000000FF
.eqv WHITE 0x00FFFFFF
.eqv YELLOW 0x00FFFF00

.eqv KEY_CODE 0xFFFF0004 		# ASCII code from keyboard, 1 byte
.eqv KEY_READY 0xFFFF0000 		# =1 if has a new keycode ?
 # Auto clear after lw
.eqv DISPLAY_CODE 0xFFFF000C		# ASCII code to show, 1 byte
.eqv DISPLAY_READY 0xFFFF0008	 	# =1 if the display has already to do
 # Auto clear after sw
.text
	li $k0, KEY_CODE
	li $k1, KEY_READY
	li $v1, 10 		# speed
	li $s0, DISPLAY_CODE
	li $s1, DISPLAY_READY
KHOI_TAO:	
	li $s2, 255 		# $s2 = x = 255
	li $s3, 255		# $s3 = y = 255
	li $t7,0
	jal TAM 		# xac dinh tam hinh tron
	nop
	jal MOVE 		# xac dinh mau hinh tron
	nop
	jal DRAW 		# ve hinh tron
	nop
#j end
WaitForKey:	
	lw $t1, 0($k1) 		# $t1 = [$k1] = KEY_READY
 	bne $t1, $zero, ReadKey 	# if $t1 == 1 then ReadKey
 	beq $t7,$zero,WaitForKey 	# neu chua nhap phim gi thi hinh tron khong thay doi
 	j XU_LY 		# neu co phim nhap vao jump den XU_LY de xu li phim do
 	nop
ReadKey: 	
	lw $s4, 0($k0)	 	# $s3= [$k0] = KEY_CODE
XU_LY:	
	li $t7,1 		# da co phim nhap vao
	li $t1, 65 		# A
	beq $s4, $t1, TRAI 	# neu $s4 = KEY_CODE = 65 => di chuyen sang ben TRAI
	nop
	li $t1, 68 		# D
	beq $s4, $t1, PHAI 	# neu $s4 = KEY_CODE = 68 => di chuyen sang ben PHAI
	nop
	li $t1, 87 		# W
	beq $s4, $t1, LEN 	# neu $s4 = KEY_CODE = 87 => di chuyen LEN
	nop
	li $t1, 83 		# S
	beq $s4, $t1, XUONG 	# neu $s4 = KEY_CODE = 83 => di chuyen XUONG
	nop
	li $t1, 90 		# Z
	beq $s4, $t1, SPEED_UP 	# neu $s4 = KEY_CODE = 90 => tang toc do 
	nop
	li $t1, 88 		# X
	beq $s4, $t1, SPEED_DOWN 	# neu $s4 = KEY_CODE = 88 => giam toc do 
	nop
	j OTHER 		# neu nhap phim khac thi xu ly OTHER
	nop
#j WaitForKey
END_XL:	# XU_LY xong  
	jal SLEEP 		# tam dung chuong trinh tuy vao toc do hien tai
	nop
	jal DELETE 		# xoa nhung diem cu bang cach to mau den
	nop
	jal DRAW 		# xoa diem cu
	nop
	#jal SLEEP
	jal TAM 		# xac dinh tam moi
	nop
	jal MOVE 		# to mau cho hinh moi
	nop
	jal DRAW 		# ve hinh moi
	nop
	j WaitForKey 		# quay lai xac dinh phim moi 
	nop
TAM:	
	li $s1, 0 		# khoi tao tam = 0
	li $t1,512 		# gan $t1 = 512 (do rong cua man hinh 512x512)
	mult $t1,$s3 		# $t1 * $s3 = 512 * $s3
	mflo $t1 		# $t2 = 512y
	add $s1,$t1,$s2 	# $s1 = x + 512y
	li $t1,4
	mult $s1, $t1 		# $s1 = 4(x+512y) # toa do tam
	mflo $s1
	li $t1, MONITOR_SCREEN 	# dia chi luu tam
	add $s1,$t1,$s1 	# xac dinh dia chi luu tam
	jr $ra
	nop
MOVE: 	
	li $t0, GREEN		# doi mau GREEN
	jr $ra 
	nop
DELETE: 	
	li $t0, 0X0 		# to mau den
	jr $ra
	nop
DI_NGUOC_TRAI:	
	li $s4,65 		# xu ly cham vien
TRAI:	
	add $s5,$0,$s4 		# luu tru $s5
	li $t1,23 		# vien ben TRAI
	beq $t1,$s2,DI_NGUOC_PHAI 	# xu ly cham vien
	nop
	addi $s2,$s2,-1
	j END_XL
	nop
DI_NGUOC_PHAI: 
	li $s4,68 		# xu ly cham vien
PHAI:	
	add $s5,$0,$s4 		# luu tru $s5
	li $t1,488 		# vien ben PHAI
	beq $t1,$s2,DI_NGUOC_TRAI 	# xu ly cham vien
	nop
	addi $s2,$s2,1
	j END_XL
DI_NGUOC_LEN: 	
	li $s4,87 		# xu ly cham vien
LEN:	
	add $s5,$0,$s4 		# luu tru $s5
 	li $t1,23 		# vien ben tren
	beq $t1,$s3,DI_NGUOC_XUONG 	# xu ly cham vien
	nop
	addi $s3,$s3,-1
	j END_XL
	nop
DI_NGUOC_XUONG: 
	li $s4,83 		# xu ly cham vien
XUONG:	
	add $s5,$0,$s4 		# luu tru $s5
	li $t1,488 		# vien ben duoi
	beq $t1,$s3,DI_NGUOC_LEN 	# xu ly cham vien
	nop
	addi $s3,$s3,1
	j END_XL
	nop
OTHER:	
	add $s4,$0,$s5 		# gan lai $s4 = $s5 - phim da bam truoc do
	j WaitForKey 		# tiep tuc nhan phim
	nop
SPEED_UP:	
	li $t1,5 
	beq $v1,$t1,OTHER 	# kiem tra toc do toi da hay chua ? toi da thi khong tang toc duoc nua
	nop
	addi $v1,$v1,-5 	# toc do tang len 5ms
	j OTHER 		# lay lai lenh di chuyen truoc do
	nop
SPEED_DOWN: 	
	addi $v1,$v1,5 		# toc do giam 5ms
	j OTHER 		# lay lai lenh di chuyen truoc do
	nop
SLEEP:	
	li $v0,32 		# tam dung chuong trinh tuy vao toc do
	add $a0, $v1, $0 	# $a0 = $v1 + $0
	syscall
	jr $ra
	nop
DRAW: 	# ve hinh tron
	sw	$t0,-47120($s1)
	sw	$t0,-47116($s1)
	sw	$t0,-47112($s1)
	sw	$t0,-47108($s1)
	sw	$t0,-47104($s1)
	sw	$t0,-47100($s1)
	sw	$t0,-47096($s1)
	sw	$t0,-47092($s1)
	sw	$t0,-47088($s1)
	sw	$t0,-45076($s1)
	sw	$t0,-45080($s1)
	sw	$t0,-45084($s1)
	sw	$t0,-45088($s1)
	sw	$t0,-45036($s1)
	sw	$t0,-45032($s1)
	sw	$t0,-45028($s1)
	sw	$t0,-45024($s1)
	sw	$t0,-43044($s1)
	sw	$t0,-43048($s1)
	sw	$t0,-42972($s1)
	sw	$t0,-42968($s1)
	sw	$t0,-41004($s1)
	sw	$t0,-41008($s1)
	sw	$t0,-40916($s1)
	sw	$t0,-40912($s1)
	sw	$t0,-38964($s1)
	sw	$t0,-38860($s1)
	sw	$t0,-36920($s1)
	sw	$t0,-36808($s1)
	sw	$t0,-34876($s1)
	sw	$t0,-34880($s1)
	sw	$t0,-34756($s1)
	sw	$t0,-34752($s1)
	sw	$t0,-32836($s1)
	sw	$t0,-32700($s1)
	sw	$t0,-30788($s1)
	sw	$t0,-30652($s1)
	sw	$t0,-28744($s1)
	sw	$t0,-28600($s1)
	sw	$t0,-26700($s1)
	sw	$t0,-26548($s1)
	sw	$t0,-24656($s1)
	sw	$t0,-24496($s1)
	sw	$t0,-22608($s1)
	sw	$t0,-22448($s1)
	sw	$t0,-20564($s1)
	sw	$t0,-20396($s1)
	sw	$t0,-18516($s1)
	sw	$t0,-18348($s1)
	sw	$t0,-16472($s1)
	sw	$t0,-16296($s1)
	sw	$t0,-14424($s1)
	sw	$t0,-14248($s1)
	sw	$t0,-12376($s1)
	sw	$t0,-12200($s1)
	sw	$t0,-10328($s1)
	sw	$t0,-10152($s1)
	sw	$t0,-8284($s1)
	sw	$t0,-8100($s1)
	sw	$t0,-6236($s1)
	sw	$t0,-6052($s1)
	sw	$t0,-4188($s1)
	sw	$t0,-4004($s1)
	sw	$t0,-2140($s1)
	sw	$t0,-1956($s1)
	sw	$t0,-92($s1)
	sw	$t0,47120($s1)
	sw	$t0,47116($s1)
	sw	$t0,47112($s1)
	sw	$t0,47108($s1)
	sw	$t0,47104($s1)
	sw	$t0,47100($s1)
	sw	$t0,47096($s1)
	sw	$t0,47092($s1)
	sw	$t0,47088($s1)
	sw	$t0,45076($s1)
	sw	$t0,45080($s1)
	sw	$t0,45084($s1)
	sw	$t0,45088($s1)
	sw	$t0,45036($s1)
	sw	$t0,45032($s1)
	sw	$t0,45028($s1)
	sw	$t0,45024($s1)
	sw	$t0,43044($s1)
	sw	$t0,43048($s1)
	sw	$t0,42972($s1)
	sw	$t0,42968($s1)
	sw	$t0,41004($s1)
	sw	$t0,41008($s1)
	sw	$t0,40916($s1)
	sw	$t0,40912($s1)
	sw	$t0,38964($s1)
	sw	$t0,38860($s1)
	sw	$t0,36920($s1)
	sw	$t0,36808($s1)
	sw	$t0,34876($s1)
	sw	$t0,34880($s1)
	sw	$t0,34756($s1)
	sw	$t0,34752($s1)
	sw	$t0,32836($s1)
	sw	$t0,32700($s1)
	sw	$t0,30788($s1)
	sw	$t0,30652($s1)
	sw	$t0,28744($s1)
	sw	$t0,28600($s1)
	sw	$t0,26700($s1)
	sw	$t0,26548($s1)
	sw	$t0,24656($s1)
	sw	$t0,24496($s1)
	sw	$t0,22608($s1)
	sw	$t0,22448($s1)
	sw	$t0,20564($s1)
	sw	$t0,20396($s1)
	sw	$t0,18516($s1)
	sw	$t0,18348($s1)
	sw	$t0,16472($s1)
	sw	$t0,16296($s1)
	sw	$t0,14424($s1)
	sw	$t0,14248($s1)
	sw	$t0,12376($s1)
	sw	$t0,12200($s1)
	sw	$t0,10328($s1)
	sw	$t0,10152($s1)
	sw	$t0,8284($s1)
	sw	$t0,8100($s1)
	sw	$t0,6236($s1)
	sw	$t0,6052($s1)
	sw	$t0,4188($s1)
	sw	$t0,4004($s1)
	sw	$t0,2140($s1)
	sw	$t0,1956($s1)
	sw	$t0,92($s1)
	jr $ra
	nop
end:
