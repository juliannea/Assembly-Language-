.data
# DONOTMODIFYTHISLINE
frameBuffer:			.space 0x80000	# 512 wide X 256 high pixels
w:				.word 100
h:				.word 106
d:				.word 50
cr:				.word 0xFF0000
cg:				.word 0x00FF00
cb:				.word 0x0000FF
# DONOTMODIFYTHISLINE
# Your other variables go BELOW here only

.text 
#drawing yellow background
    la $t1, frameBuffer     	#t1 <- address of FrameBuffer
    li $t2, 0x00FFFF00    	#t2 <- yellow color 	
    li $t0, 0             	#t0 <- 0, (loop counter i)
fill_loop:
    sw $t2, 0($t1)        	#t1 <- Yellow color 
    addi $t1, $t1, 4     	#go to next pixel 
    addi $t0, $t0, 1     	#$t0 <- t0 + 1 (i++)
    bne $t0, 131072, fill_loop  # Loop until all pixels (512 * 256) are filled

#edge cases 
#make sure within 512 & 256 range 
    #testing width in range 
    la $t1, w			#t1 <- address of w (width)
    lw $t1, 0($t1)		#t1 <- value of w (width 
    slti $t2, $t1, 512 		#t2 <- 1 if t1 < 512 (if width < 512) else 0
    beq $t2, $zero, exit 	#exit if equal to 0 meaning not less than 512 out of range 
    #testing height in range 
    la $t2, h 			#t2 <- address of h (height)
    lw $t2, 0($t2) 		#t2 <- value of h (height)
    slti $t3, $t2, 256		#t3 <- 1 if t2 < 256 (if height < 256) else 0
    beq $t3, $zero, exit 	#exit if equal to  0 meaning not less than 256, out of range 
    #testing depth in range 
    la $t4, d			#t4 <- address of d (depth)
    lw $t4, 0($t4)		#t4<- value of d (depth)
    add $t5, $t4, $t1		#t5 <- t4 + t1 (d + w)
    slti $t6, $t5, 512		#t6 <- 1 if t5 < 512, else 0 
    beq  $t6, $zero, exit 	#exit if t6 equal to 0 meaning depth out of range 
    add  $t5, $t4, $t2		#t5 <- t4 + t2 (d + h)
    slti $t6, $t5, 256		#t6 <- 1 if t5 < 256, else 0
    beq  $t6, $zero, exit       #exit if equal to 0 meaning not less than 256, out of range 
    #testing if centerable (input even)
    andi $t3, $t1, 1 		#mask the least significant bit, 1 if odd, 0 if even in terms of w 
    bne  $t3, $zero, exit 	#exit if t3 not zero, meaning w odd 
    andi $t3, $t2, 1            #mask the least significant bit, 1 if odd, 0 if even in terms of h
    bne  $t3, $zero, exit 	#exit if t3 not zero, meaning h is odd 

#draw first square face 
   #getting frame buffer & color 
   la $t0, frameBuffer 		#t0 <- address of frameBuffer 
   la $t9, cb			#t9 <- address of cb 
   lw $t9, 0($t9) 		#t9 <- value of cb (blue color) 
   
#center calculations find left most pixel framebuffer + 4x + 2048(y+d) 
   #get depth 
   la $t3, d 			#t3 <- address of d (depth)
   lw $t3, 0($t3) 		#t3 <- value of d (depth)
   #get y value (256 = 2y + h + d)
   addi $t4, $zero, 256		#t5 <- 256 
   add $t5, $t2, $t3 		#t4 <- t2 + t3 (h +d)
   sub 	$t4, $t4, $t5		#t5 <- 256 - (h + d)
   srl	$t4, $t4, 1		#t4 <- t4 << 1 (shift right 1 basically dividing by 2, represents y), 256 - (h + d)/ 2 (y) 
   #get x value 512 = 2x + w + d 
   addi $t5, $zero, 512 	#t5 <- 512 
   add	$t6, $t1, $t3 		#t6 <- t1 + t3 (w + d) 
   sub 	$t5, $t5, $t6		#t5 <- 512 - (w + d) 
   srl 	$t5, $t5, 1 		##t5 <- t5 << 1 (shift right 1 basically dividing by 2, represents x) 512 - (w + d) / 2
   
   #getting left most pixel of first face square framebuffer + 4x + 2048(y+d) 
   add $t6, $zero, $t0 		#t6 <- frameBuffer 
   sll $t5, $t5, 2 		#t5 <- t5 << 4 (sift left by 2, basically multip[lying by 4 (4x))
   add $t6, $t6, $t5 		#t6 <- t6 + t5 (frameBuffer + 4x)
   add $t4, $t4, $t3 		#t4 <- t4 + t3 (y+d) 
   sll $t4, $t4, 11		#t4 <- t4 << 11 (shift left by 11, basically multiplying by 2048. 2048(y+d)
   add $t6, $t6, $t4 		#t6 <- t6 + t4 (frameBuffer + 4x + 2048) location of left most pixel of first square front face 
   
   
#for loops for first face square 
    add $t7, $zero, $zero       # t7 <- 0 (represents i) row counter
    add $t8, $zero, $zero       # t8 <- 0 (represents j) column counter 

outLoop1:
    slt $t4, $t7, $t2           # t4 <- 1 if t7 < t2 (i < h), else 0 
    beq $t4, $zero, exitLoop1    # exit loop if 0 

    add $t3, $zero, $t6         # t3 <- leftmost

innerLoop1: 
    slt $t4, $t8, $t1         # t4 <- 1 if t8 < t1 (j < w), else 0
    beq $t4, $zero, innerNext1   # go to innerNext if false
    sw  $t9, 0($t3)             # store blue color 
    addi $t3, $t3, 4            # go to next bit 
    addi $t8, $t8, 1            # j++ 
    j innerLoop1 
    
innerNext1:
    addi $t7, $t7, 1           # i++
    addi $t6, $t6, 2048        # move to next row
    add $t8, $zero, $zero      #reset column counter
    j outLoop1                 # go back to out loop

exitLoop1:   

#recalculate first position
   la $t9, cr			#t9 <- address of cr (red)
   lw $t9, 0($t9)		#t9 <- value of cr 
#get depth 
   la $t3, d 			#t3 <- address of d (depth)
   lw $t3, 0($t3) 		#t3 <- value of d (depth)
   #get y value (256 = 2y + h + d)
   addi $t4, $zero, 256		#t5 <- 256 
   add $t5, $t2, $t3 		#t4 <- t2 + t3 (h +d)
   sub 	$t4, $t4, $t5		#t5 <- 256 - (h + d)
   srl	$t4, $t4, 1		#t4 <- t4 << 1 (shift right 1 basically dividing by 2, represents y), 256 - (h + d)/ 2 (y) 
   #get x value 512 = 2x + w + d 
   addi $t5, $zero, 512 	#t5 <- 512 
   add	$t6, $t1, $t3 		#t6 <- t1 + t3 (w + d) 
   sub 	$t5, $t5, $t6		#t5 <- 512 - (w + d) 
   srl 	$t5, $t5, 1 		##t5 <- t5 << 1 (shift right 1 basically dividing by 2, represents x) 512 - (w + d) / 2
   
   #getting left most pixel of first face square framebuffer + 4x + 2048(y+d) 
   add $t6, $zero, $t0 		#t6 <- frameBuffer 
   sll $t5, $t5, 2 		#t5 <- t5 << 4 (sift left by 2, basically multip[lying by 4 (4x))
   add $t6, $t6, $t5 		#t6 <- t6 + t5 (frameBuffer + 4x)
   add $t4, $t4, $t3 		#t4 <- t4 + t3 (y+d) 
   sll $t4, $t4, 11		#t4 <- t4 << 11 (shift left by 11, basically multiplying by 2048. 2048(y+d)
   add $t6, $t6, $t4 		#t6 <- t6 + t4 (frameBuffer + 4x + 2048) location of left most pixel of first square front face 
   
   #for loops for top of square 
    add $t7, $zero, $zero       # t7 <- 0 (represents i) row counter
    add $t8, $zero, $zero       # t8 <- 0 (represents j) column counter 
    addi $t6, $t6, -2048 	#move up one row from leftmost of first square
    
outLoop2: 
    slt $t4, $t7, $t3 		#t4 <- 1 if t7 < t3 (i < d), else 0
    beq $t4, $zero, exitLoop2 	#if t4 <- 0 exit loop
    addi $t6, $t6, 4		#shift by one pixel before adding color 
    add  $t5, $zero, $t6 	#t5 <- t6 (to preserve value)
innerLoop2: 
    slt $t4, $t8, $t1		#t4 <- 1 if t8 < t1 (j < w), else 0
    beq $t4, $zero, innerNext2  #t4 <- 0 go to innerNext2
    sw $t9, 0($t5) 		# store red color 
    addi $t5, $t5, 4 		#move to next pixel 
    addi $t8, $t8, 1 		#j++ 
    j innerLoop2		#jump back to loop 
innerNext2:
    addi $t7,$t7,1 		#i++
    addi $t6,$t6,-2048		#move up a row 
    #addi $t6, $t6, 4 		#shift by 1 pixel 
    add	 $t8, $zero, $zero 	#reset column counter
    j outLoop2			#back to loop 

exitLoop2:
    la $t9, cg			#t9 <- address of cg 
    lw $t9, 0($t9) 		#t9<- value of cg (green color)
      
#3rd box face 
    add $t7, $zero, $zero 	#t7 <- 0 (i) row counter 
    add $t8, $zero, $zero 	#t8 <- 0 (j) clolumn counter 
    
    sll $t5, $t1, 2 		#t5 <- t1 << 4 (basically 4w) to get location of edge 
    add $t6, $t6, $t5		#move t6 to pixel location at far right edge 
    add $t6, $t6, 2048 		#move down one pixel
    
outLoop3: 
    slt $t4, $t3, $t7		#t4 <-1 if t3 < t7 (d < i)
    bne $t4, $zero, exitLoop3	#exit loop if t4 is 0 
    add $t5, $zero, $t6 	#t5 <- t6 (to preserve location)
innerLoop3: 
    slt $t4, $t8, $t2		#t4 <- 1 if t8 < t2 (j < h)
    beq $t4, $zero, innerNext3	#go to innerNext 3 if t4 0
    sw	$t9, 0($t5)		#store color at pixel 
    addi $t5, $t5, 2048		#move down one pixel 
    addi $t8, $t8, 1		#j++
    j innerLoop3		#jump back to loop 
innerNext3:
    addi $t7,$t7, 1 		#i++
    add $t8, $zero, $zero 	#reset inner counter
    addi $t6,$t6, -4		#shift to pixel on left 
    addi $t6,$t6, 2048 		#go to next row 
    j outLoop3			#got back to loop 

exitLoop3: 

   

exit:   
li $v0, 10               # Exit syscall
    syscall
