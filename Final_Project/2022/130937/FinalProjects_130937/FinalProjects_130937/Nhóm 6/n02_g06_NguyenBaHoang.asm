.eqv 	screen 		0x10010000
.eqv 	yellow_color	0x00FFFF00
.eqv	black_color	0x00000000
.eqv 	KEY_CODE  	0xFFFF0004
.eqv 	KEY_READY  	0xFFFF0000
.text
	li	$k0,  KEY_CODE
	li	$k1,  KEY_READY
	li	$s0,screen
	li	$t0,yellow_color
	li	$a2,50		#thoi gian sleeping mac dinh(toc do)
	li	$s2,0		#huong di chuyen cua dia chi
	li	$s3,0		#huong di chuyen ngang
	li	$s4,0		#huong di chuyen doc
	li	$t1,255		#toa do x
	li	$t2,254		#toa do y
	li	$t3,23		#can tren va can trai toa do tam
	li	$t4,488		#can duoi va can phai toa do tam
	addi	$s1,$s0,521212	#dia chi ban dau cua tam hinh tron
	jal	draw
	j	loop
Change:     			#da co phim duoc bam tu keyboard 
	lw	$v0, 0($k0)	
	li	$v1,'w'
	beq	$v1,$v0,up
	li	$v1,'s'
	beq	$v1,$v0,down
	li	$v1,'d'
	beq	$v1,$v0,right
	li	$v1,'a'
	beq	$v1,$v0,left
	li	$v1,'z'
	beq	$v1,$v0,speed_up
	li	$v1,'x'
	beq	$v1,$v0,slow_down
	j	loop
up:				#giam dia chi tam de tang duoc 1 hang
	li	$s2,-2048
	li	$s3,0
	li	$s4,-1
	j	loop
down:				#tang dia chi tam de xuong duoc 1 hang
	li	$s2,2048
	li	$s3,0
	li	$s4,1
	j	loop
right:				#tang dia chi tam de sang phai duoc 1 cot
	li	$s2,4
	li	$s3,1
	li	$s4,0
	j	loop
left:				#giam dia chi tam de sang trai duoc 1 cot
	li	$s2,-4
	li	$s3,-1
	li	$s4,0
	j	loop
speed_up:			#giam thoi gian sleep giua cac vong lap de tang toc
	addi	$a2,$a2,-5
	j	loop
slow_down:			#tang thoi gian sleep giua cac vong lap de giam toc do
	addi	$a2,$a2,5
	j	loop
undo_right:				#reset toa do tam ve buoc truoc(vi da ra qua gioi han cho phep)
	sub	$s1,$s1,$s2		#thay doi dia chi tam duong tron
	sub	$t1,$t1,$s3		#thay doi toa do x
	sub	$t2,$t2,$s4		#thay doi toa do y
	j	right
undo_left:
	sub	$s1,$s1,$s2		#thay doi dia chi tam duong tron
	sub	$t1,$t1,$s3		#thay doi toa do x
	sub	$t2,$t2,$s4		#thay doi toa do y
	j	left
undo_down:
	sub	$s1,$s1,$s2		#thay doi dia chi tam duong tron
	sub	$t1,$t1,$s3		#thay doi toa do x
	sub	$t2,$t2,$s4		#thay doi toa do y
	j	down
undo_up:
	sub	$s1,$s1,$s2		#thay doi dia chi tam duong tron
	sub	$t1,$t1,$s3		#thay doi toa do x
	sub	$t2,$t2,$s4		#thay doi toa do y
	j	up
loop:
	addi    $v0,$zero,32		#sleep 
	add  	$a0,$zero,$a2
	syscall
	li	$t0,black_color		#xoa duong tron cu
	jal	draw
	add	$s1,$s1,$s2		#thay doi dia chi tam duong tron
	add	$t1,$t1,$s3		#thay doi toa do x
	add	$t2,$t2,$s4		#thay doi toa do y
	beq	$t3,$t1,undo_right	#va cham canh trai
	beq	$t3,$t2,undo_down	#va cham canh tren
	beq	$t4,$t1,undo_left	#va cham canh phai
	beq	$t4,$t2,undo_up		#va cham canh duoi
	li	$t0,yellow_color	#ve duong tron moi
	jal	draw			
	lw	$a0, 0($k1)		#loop doi keyboard
	beq	$a0, $zero, loop
	j	Change
draw:					#ve duong tron gom 132 pixel
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
	jr	$ra
