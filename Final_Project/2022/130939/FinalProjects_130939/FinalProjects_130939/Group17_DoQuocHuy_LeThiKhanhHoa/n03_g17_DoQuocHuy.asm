.eqv SEVENSEG_LEFT    0xFFFF0011 # Dia chi cua den led 7 doan trai	
					#Bit 0 = doan a         
					#Bit 1 = doan b	
					#Bit 7 = dau . 
.eqv SEVENSEG_RIGHT   0xFFFF0010 # Dia chi cua den led 7 doan phai 

.eqv KEY_CODE   0xFFFF0004         # ASCII code from keyboard, 1 byte 
.eqv KEY_READY  0xFFFF0000        	# =1 if has a new keycode ?                                  
				        # Auto clear after lw  
.eqv DISPLAY_CODE   0xFFFF000C   	# ASCII code to show, 1 byte 
.eqv DISPLAY_READY  0xFFFF0008   	# =1 if the display has already to do  
	                                # Auto clear after sw  
.eqv MASK_CAUSE_KEYBOARD   0x0000034     # Keyboard Cause    
  
.data 
LED7SEG     : .byte 0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F 	#biểu diễn 0,1,2,3,4,5,6,7,8,9
string : .space 1000			#khoang trong de luu cac ky tu nhap tu ban phim.
stringsource : .asciiz "bo mon ky thuat may tinh" 
keyin1s: .asciiz "\n So ky tu nhap trong 1s :  "
numright: .asciiz  "\n So ky tu nhap dung la: "
time:	.asciiz "\n Thoi gian nhap la: "
ms:	.asciiz "ms\n"
notification: .asciiz "\n Chuong trinh da ket thuc. Ban muon tro lai chuong trinh?"

.text
	li   $k0,  KEY_CODE
	li   $k1,  KEY_READY                    
	li   $s0, DISPLAY_CODE              
	li   $s1, DISPLAY_READY  	
main:         
	li $s2,0 				#dung de dem toan bo so ky tu nhap vao
  	li $s3,0				#dung de dem so vong lap 
  	li $t5,100				#so vong lap trong 1 giay 
	li $t6,0				#bien dem so ky tu nhap duoc trong 1s
	li $v1,0				# =1 khi chuong trinh ket thuc
LOOP:          
WaitForKey:  
 	lw   $t1, 0($k1)              
	beq  $t1, $zero, next             # if $t1 == 0 (khong co ky tu duoc nhap), chuyen sang vong lap ke tiep          
CountIn1s:
	addi $t6,$t6,1    		#so ky tu nhap duoc trong 1s +1
	teqi $t1, 1                       # if $t1 = 1 then raise an Interrupt    
next:          
	addi    $s3, $s3, 1      	#so vong lap +1
	div 	$s3,$t5			#lay so vong lap chia cho 100 de xac dinh da duoc 1s hay chua
	mfhi 	$t7			#luu phan du cua phep chia tren
	bne 	$t7,0,sleep		#neu chua duoc 1s (so vong lap != x00), nhay den sleep
					#neu da duoc 1s thi nhay den printKeyin1s de in ra man hinh
printKeyin1s:
	li $v0,4			#bat dau chuoi lenh in ra so ky tu nhap duoc trong 1s
	la $a0,keyin1s
	syscall	
	li    $v0,1            		#in ra so ky tu trong 1s
	add   $a0,$0,$t6 		
	syscall

Display_7SEG:
	li $t4, 10
	div $t6,$t4			#lay so ky tu nhap duoc trong 1s chia cho 10
	mflo $t7			#luu gia tri phan nguyen, gia tri nay se duoc hien thi o den LED ben trai (hang chuc)
	la $a2,LED7SEG			#lay dia chi cua danh sach luu gia tri den LED
	add $a2,$a2,$t7			#xac dinh dia chi cua gia tri den LED tuong ung
	lb $a0,0($a2)                 	#lay noi dung cho vao $a0           
	jal   SHOW_7SEG_LEFT       	# show

	mfhi $t7			#luu gia tri phan du, gia tri nay se duoc hien thi o den LED ben phai (hang don vi)
	la $a2,LED7SEG		
	add $a2,$a2,$t7
	lb $a0,0($a2)                	# set value for segments           
	jal  SHOW_7SEG_RIGHT      	# show    

	li    $t6,0			#sau khi da hoan thanh, reset bien dem so ky tu trong 1s de bat dau chu ky moi
	beq $v1,1,Notify

sleep:  
	addi    $v0,$zero,32                   
	li      $a0,10              	# sleep 10 ms         
	syscall         
	nop        
	b       LOOP
END_main:				#ket thuc chuong trinh
	li $v0,10
	syscall
	
SHOW_7SEG_LEFT:  
	li   $t0,  SEVENSEG_LEFT 	# assign port's address                   
	sb   $a0,  0($t0)        	# assign new value                    
	jr   $ra 
	
SHOW_7SEG_RIGHT: 
	li   $t0,  SEVENSEG_RIGHT 	# assign port's address                  
	sb   $a0,  0($t0)         	# assign new value                   
	jr   $ra 

.ktext    0x80000180         		#interupt      
	mfc0  $t1, $13                  #luu nguyen nhan xay ra ngat
	li    $t2, MASK_CAUSE_KEYBOARD
	and   $at, $t1,$t2              
	beq   $at,$t2, Counter_Keyboard		#neu nguyen nhan xay ra ngat tu Keyboard, thuc hien Counter_Keyboard
	j    EndProcess				#neu khong phai tu Keyboard, EndProcess
	
Counter_Keyboard: 
ReadKey:     lb   $t0, 0($k0)            	# $t0 = [$k0] = KEY_CODE 
WaitForDis: 
	     lw   $t2, 0($s1)            	# $t2 = [$s1] = DISPLAY_READY            
	     beq  $t2, $zero, WaitForDis	# if $t2 == 0 then Polling
ShowKey: 
	     sb $t0, 0($s0)              	# hien thi ky tu vua nhap tu ban phim tren man hinh MMIO
	     nop
	     
             la  $t7,string			# $t7 luu dia chi cua chuoi nhap vao
             add $t7,$t7,$s2			#dia chi byte cuoi cung duoc nhap tu keyboard
             sb $t0,0($t7)
             addi $s2,$s2,1			#so ky tu duoc nhap +1
             beq $t0,10,EndLOOP			#neu gap ky tu "\n" (ENTER) (ket thuc xau) thi nhay den EndLOOP
          
EndProcess:                         
next_pc:    mfc0    $at, $14	        # $at <= Coproc0.$14 = Coproc0.epc              
	    addi    $at, $at, 4	        # $at = $at + 4 (next instruction)              
            mtc0    $at, $14	       	# Coproc0.$14 = Coproc0.epc <= $at  
RETURN:     eret                       # return from exception
EndLOOP:
	li $v0,11         
	li $a0,'\n'         		# xuong dong
	syscall 
	li $t1,0 			# $t1 luu so ky tu da duoc kiem tra
	li $t3,0                       # dem so ky tu nhap dung
	li $t8,24			#$t8 luu do dai xau goc stringsource trong ma nguon
	slt $t7,$s2,$t8			#so sanh xem do dai xau nhap tu ban phim va do dai cua xau co dinh trong ma nguon
					#xau nao nho hon thi duyet theo do dai cua xau do
	bne $t7,1, Check	
	add $t8,$0,$s2
	addi $t8,$t8,-1			#tru 1 vi ky tu cuoi cung la dau enter thi khong can xet.
Check:			
	la $t2,string
	add $t2,$t2,$t1
	li $v0,11			#in ra cac ky tu da nhap tu ban phim.
	lb $t5,0($t2)			#lay ky tu thu $t1 trong string luu vao $t5 de so sanh voi ky tu thu $t1 o stringsource
	move $a0,$t5
	syscall 
	la $t4,stringsource
	add $t4,$t4,$t1
	lb $t6,0($t4)			#lay ky tu thu $t1 trong stringsource luu vao $t6
	bne $t6,$t5,CONTINUE		#neu 2 ky tu thu $t1 khac nhau thi xet ky tu tiep theo
	addi $t3,$t3,1			#giong nhau thi tang bien dem so ky tu dung len 1
CONTINUE: 
	addi $t1,$t1,1			#sau khi so sanh 1 ky tu, tang bien dem len 
	beq $t1,$t8,Print_NumRight	#neu da duyet het so ky tu can xet thi in ra man hinh so ky tu nhap dung
	j Check				#neu chua duyet het thi tiep tuc xet tiep cac ky tu 
Print_NumRight:
	li $v0,4			#in xau numright
	la $a0,numright
	syscall
	li $v0,1			#in so ky tu dung
	add $a0,$0,$t3
	syscall
	mul $t4,$s3, 10			#tinh thoi gian nhap (tinh theo ms)
	li $v0,4			#in chuoi time
	la $a0, time
	syscall
	add $a0,$0,$t4
	li $v0,1
	syscall
	li $v0,4
	la $a0, ms
	syscall
	li $v1,1
	li $t6,0			#sau khi ket thuc chuong trinh, so ky tu dung duoc luu vao $t6 roi quay tro ve phan hien thi.
	add $t6,$0,$t3
	b Display_7SEG 
Notify: 
	li $v0, 50
	la $a0, notification
	syscall
	beq $a0,0,main		
	b exit
exit:
