.eqv KEY_CODE 0xFFFF0004 		# Mã Ascii từ  keyboard, 1 byte	
.eqv KEY_READY 0xFFFF0000 		# = 1 nếu có kí tự mới
.data
base: .word 0x10010000 		#địa chỉ bắt đầu của bitmap screen
color: .word 0x00FFFF00 		# màu mặc định của quả bóng ở đây là màu vàng 
background: .word 0x00000000 		# màu nền mặc định là màu đen 
radius: .word 25 			# bán kính mặc định
middle_x: .word 256 			#vị trí tâm quả bóng
middle_y: .word 256
dis_width: .word 512 			#chiều rộng hiển thị bitmap
dis_height: .word 512 			#chiều dài hiển thị bitmap
.text
#cong thức P được thiết lập sẵn là : P = 1 - r từ chứng minh công thức có trong docs của bài làm 
main:
	li 	$a2, 1
	lw 	$t2, radius		# t2 = bán kính quả bóng	
	lw 	$t3, color		# t3 = màu quả bóng
	li 	$t6, 1		     	# t6 = tốc độ di chuyển của bóng 
	lw 	$t8, middle_x 		# t8 = tọa độ x của tâm quả bóng (x0)
	lw	$t9, middle_y		# t9 = tọa độ y của tâm quả bóng (y0)
	li 	$t1, 1			# t1 = 1
	jal 	draw_circle		# chuyển đến draw_circle - vẽ quả bóng
#điều khiển di chuyển của quả bóng 
pause: 
	li 	$k0, KEY_CODE 				
	li 	$k1, KEY_READY
	lw 	$t1, 0($k1) 			# t1 = [k1] = KEY_READY
	beq 	$t1, $zero, pause 		# t1 = 0 -> quay lại pause
#nhận và xử lý kí tự vừa nhập
looping: 	
	lw 	$t0, 0($k0) 			# mã ascii của kí tự vừa nhập vào
	beq 	$t0, 97, main_left		# bấm A, quả bóng di chuyển sang trái
	beq 	$t0, 100, main_right		# bấm D, quả bóng di chuyển sang phải
	beq 	$t0, 119, main_up		# bấm W, quả bóng di chuyển lên trên		
	beq 	$t0, 115, main_down		# bấm S, quả bóng di chuyển xuống dưới
	beq	$t0, 110, pause			# bấm N, dừng chuyển động
	beq     $t0, 113, main_done		# bấm Q, thoát
	beq     $t0, 120, slow_down		# bấm X để giảm tốc quả bóng mặc định tốc độ ở 1 
	beq 	$t0, 122, speed_up 		# bấm Z, gia tốc quả bóng	
break1:	j 	read_key_code
#đọc vào kí tự
read_key_code:
	li 	$k0, KEY_CODE 				
	li 	$k1, KEY_READY
	lw 	$t1, 0($k1) 			#$t1 = [$k1] = KEY_READY
	bne 	$t1, $zero, looping		# t1 != 0 -> looping
	jr 	$ra
#di chuyển sang trái
main_left:
	blt 	$t8, 25, main_right	#x < bán kính, di chuyển sang phải
	nop					# 
	jal 	delete			       	#xóa quả bóng hiện tại
	sub 	$t8, $t8, $t6			#thực hiện thay đổi vi trí (x,y) -> ( x--,y )  
	jal 	bounce				#trả về quả bóng mới
	jal 	read_key_code			#đọc key code
	j 	main_left			#nếu không thay đổi quay lại vòng lặp
#di chuyển sang phải
main_right:	
	bgt 	$t8, 487, main_left	#x > bán kính, di chuyển sang trái
	nop					#
	jal 	delete			    	#xóa quả bóng hiện tại
	add 	$t8, $t8, $t6			#thực hiện thay đổi vi trí (x,y) - > (x++,y)
	jal 	bounce				#trả về quả bóng mới
	jal 	read_key_code			#đọc key code
	j	main_right			#nếu không thay đổi quay lại vòng lặp
#di chuyển xuống dưới
main_down:	
	bgt 	$t9, 487, main_up		# y > bán kính, di chuyển lên trên
	nop					#
	jal	delete				#xóa quả bóng hiện tại
	add 	$t9, $t9, $t6			#thực hiện thay đổi vi trí (x,y) -> (x,y++)
	jal 	bounce				#trả về quả bóng mới
	jal	read_key_code			#đọc key code
	j	main_down 			#nếu không thay đổi quay lại vòng lặp
#di chuyển lên trên
main_up:			
	blt 	$t9, 25, main_down		# y < bán kính, di chuyển xuống dưới
	nop					#
	jal	delete				#xóa quả bóng hiện tại
	sub 	$t9, $t9, $t6			#thực hiện thay đổi vi trí (x,y) -> (x,y--)
	jal 	bounce				#trả về quả bóng mới
	jal 	read_key_code			#đọc key code
	j 	main_up				#nếu không thay đổi quay lại vòng lặp


#xóa quả bóng
delete:
	addi	$v0, $zero, 32	# mở lệnh syscall sleep
	addi	$a0, $zero, 5	# speed = 5 ms
	syscall
	
	subi 	$sp, $sp, 4			# sp = sp - 4
	sw 	$ra, 0($sp)			# lưu địa chỉ trả về vào ngăn xếp
	li 	$t1, 0				# $t1 = 0
	jal 	draw_circle			# vẽ quả bóng
	lw 	$ra, 0($sp)			# lấy ra địa chỉ trả về
	addi 	$sp, $sp,4			# sp = sp + 4
	jr 	$ra				# trở lại chương trình đang thực hiện
#tạo quả bóng mới
bounce:		
	subi 	$sp, $sp, 4			# sp = sp - 4
	sw 	$ra, 0($sp)			# lưu địa chỉ trả về vào ngăn xếp
	li 	$t1, 1				# $t1 = 1
	jal 	draw_circle 			# vẽ quả bóng
	lw 	$ra, 0($sp)			# lấy ra địa chỉ trả về
	addi 	$sp, $sp,4			# sp = sp + 4
	jr 	$ra				# trở lại chương trình đang thực hiện
# thoát chương trình
main_done:					
	li 	$v0, 10
	syscall
#gia tăng tốc độ bóng với giới hạn tốc độ giảm thấp nhất là 1
speed_up : #z
	addi $t6,$t6,1 #tăng biến tốc độ lên 1 
	jr $ra		#trở lại chương trình đang thực hiện
#giảm tốc độ bóng 
slow_down: #x 
	ble $t6,$a2,break1 # kiểm tra xem giá trị giảm xuống này có phải là 1 nếu là 1 thì không cho giảm xuống mà trở về loop 
	addi $t6,$t6,-1 #giảm giá trị tốc độ xuống 1 đơn vị
	jr $ra		#trở lại chương trình đang thực hiện 
# vẽ quả bóng      
draw_circle:
	subi 	$sp, $sp, 4		# sp = sp - 4
	sw 	$ra, 0($sp)		# lưu địa chỉ trả về vào ngăn xếp
	lw 	$k0, base 		# hiển thị ra màn hình
	lw 	$s0, radius		# s0 = x = bán kính
	li 	$s1, 0			# s1 = y = 0
	sub	$s3, $t2, 1		# 
	sub	$s3, $zero, $s3 	# P = 1-r 
	jal 	setpixel
#vòng lặp để vẽ các điểm
main_loop:
	blt 	$s0, $s1, main_loop_done	#x < y,dừng -> main_loop_done
	ble 	$s3, $0, inside_circle		#P <= 0,vẽ (X, Y + 1)
	bgt 	$s3, $0, outside_circle		#P > 0,vẽ (X - 1, Y + 1)
continue:
	j 	main_loop			#quay lại main_loop
main_loop_done:
	lw 	$ra, 0($sp)			#lấy ra địa chỉ trả về
	addi 	$sp, $sp, 4			#sp = sp + 4
	jr 	$ra				#trở lại chương trình đang thực hiện
#vẽ điểm bên trong hoặc trên
inside_circle:	#P = P + 2 * y + 1
	addi 	$s1, $s1, 1		#s1 = y = y+1	
	add 	$s4, $s1, $s1		#s4 = 2y	
	addi 	$s4, $s4, 1		#s4 = 2y+1	
	add 	$s3, $s3, $s4		#P = P + 2y + 1
	jal 	setpixel               #nhảy đến setpixel
	j 	continue		#nhảy đến continue
#vẽ điểm bên ngoài
outside_circle:	 #P = P + 2 * y - 2 * x + 1
	subi 	$s0, $s0, 1		#s0 = x = x-1	
	addi 	$s1, $s1, 1		#s1 = y = y+1
	add 	$s4, $s1, $s1		#s4 = 2y		
	addi 	$s4, $s4, 1		#s4 = 2y+1	
	sub 	$s7, $0, $s0		#s7 = -x
	sub 	$s7, $s7, $s0		#s7 = -2x	
	add 	$s7, $s7, $s4		#s7 = 2y-2x+1	
	add 	$s3, $s3, $s7		#P = P + 2y - 2x  + 1
	jal 	setpixel		#nhảy đến setpixel
	j 	continue		#nhảy đến continue
#tính giá trị tọa độ của 8 điểm cần vẽ
setpixel:	
	subi 	$sp,$sp,4		#sp = sp - 4
	sw 	$ra,0($sp)		# lưu địa chỉ trả về vào ngăn xếp	
	# vẽ (X, Y)
	add 	$s6,$t8,$s0 		# X = x0 + x
	add 	$s5,$t9,$s1		# Y = y0 + y
	jal 	setpixel_go		#chuyển đến setpixel_go
	# draw (Y, X)
	add 	$s6,$t8,$s1		# X = x0 + y
	add 	$s5,$t9,$s0		# Y = y0 + x
	jal 	setpixel_go		#chuyển đến setpixel_go
	# draw (-X, -Y)
	sub 	$s6,$t8,$s0		# X = x0 - x
	sub 	$s5,$t9,$s1		# Y = y0 - y
	jal 	setpixel_go		#chuyển đến setpixel_go
	# draw (-Y, -X)
	sub 	$s6,$t8,$s1		# X = x0 - y
	sub 	$s5,$t9,$s0		# Y = y0 - x
	jal 	setpixel_go
	# draw (X, -Y)
	add 	$s6,$t8,$s0		# X = x0 + x
	sub 	$s5,$t9,$s1		# Y = y0 - y
	jal 	setpixel_go		#chuyển đến setpixel_go
	# draw (Y, -X)
	add 	$s6,$t8,$s1		# X = x0 + y
	sub 	$s5,$t9,$s0		# Y = y0 - x
	jal 	setpixel_go		#chuyển đến setpixel_go
	# draw (-Y, X)
	sub 	$s6,$t8,$s1		# X = x0 - y
	add 	$s5,$t9,$s0		# Y = y0 + x
	jal 	setpixel_go		#chuyển đến setpixel_go
	# draw (-X, Y)
	sub 	$s6,$t8,$s0		# X = x0 - x
	add 	$s5,$t9,$s1		# Y = y0 + y
	jal 	setpixel_go		#chuyển đến setpixel_go
	lw 	$ra,0($sp)		#lấy ra địa chỉ trả về
	addi 	$sp,$sp,4		# sp = sp + 4
	jr 	$ra			#trở lại chương trình đang thực hiện
#xác định địa chỉ của ô cần vẽ và tô màu
setpixel_go:	
	subi 	$sp, $sp, 4		# sp = sp - 4
	sw 	$ra, 0($sp)		# lưu địa chỉ trả về vào ngăn xếp
	mul 	$s5, $s5, 512		# hiển thị quả bóng trên màn hình
	add 	$k1, $s5, $s6 		# thiết lập vị trí của quả bóng
	mul 	$k1, $k1, 4		#
	add 	$k1, $k1, $k0		# k1 = địa chỉ ô cần vẽ
	beq 	$t1, $0, delete_circle	# nếu $t1 = 0 -> delete_circle		
	add 	$t0, $zero, $t3 	# t0 = màu quả bóng
	sw 	$t0, 0($k1)		# hiển thị màu quả bóng
drawing:	
	lw 	$ra, 0($sp)		#lấy ra địa chỉ trả về	
	addi 	$sp, $sp,4		# sp = sp + 4
	jr 	$ra			# trở lại chương trình đang thực hiện
#xóa hình tròn
delete_circle:		
	lw 	$t0, background		#t0 = màu nền
	sw 	$t0, 0($k1)		#hiển thị màu nền
	j drawing

