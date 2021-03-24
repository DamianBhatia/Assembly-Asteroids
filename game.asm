#####################################################################
#
#  CSCB58 Winter 2021 Assembly Final Project
#  University of Toronto, Scarborough
#
#  Student: Damian Bhatia, 1005946577, Bhatia85
#
#  Bitmap Display Configuration:
#  - Unit width in pixels: 8 (update this as needed)
#  - Unit height in pixels: 8 (update this as needed)
#  - Display width in pixels: 512 (update this as needed)
#  - Display height in pixels: 512 (update this as needed)
#  - Base Address for Display: 0x10008000 ($gp)
#
#  Which milestones have been reached in this submission?
#  (See the assignment handout for descriptions of the milestones)
#  - Milestone 1/2/3/4 (choose the one the applies)
#
#  Which approved features have been implemented for milestone 4?
#  (See the assignment handout for the list of additional features)
#  1. (fill in the feature, if any)
#  2. (fill in the feature, if any)
#  3. (fill in the feature, if any)
#  ... (add more if necessary)
#
#  Link to video demonstration for final submission:
#  -(insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
#  Are you OK with us sharing the video with people outside course staff?
#  -yes / no/ yes, and please share this project githublink as well!
#
#  Any additional information that the TA needs to know:
#  -(write here, if any)
#
#####################################################################

.eqv	BASE_ADDRESS		0x10008000
.eqv	PURPLE			0x00673AB7
.eqv	GREEN			0x00607D8B
.eqv	RED			0x00FF0000
.eqv	GRAY			0x009E9E9E

.data
ship:		.space		144	# array to hold spaceship position
ship_colors:	.space		144	# array to hold spaceship colors

.text
	li $t0, BASE_ADDRESS	# $t0 stores the base address for the display
	jal init_ship		# initialize ship contents
	jal draw_ship		# draw ship onto the display
	j QUIT			# quit the program


# init_ship: This function initializes the contents of the ship. At each index
# 	     ship[i] we store the index on the display that corresponds to that 
#	     pixel and in ship_colors[i] we store the color for that pixel.
init_ship:
	la $t1, ship		# $t1 holds address of ship
	la $t2, ship_colors	# $t2 holds address of ship_colors
	li $t3, GREEN		# $t3 holds color currently being used
	li $t4, 0		# $t4 holds iterator for loop
	li $t5, 6676		# $t5 holds the index relative to display
init_ship.loop1:
	beq $t4, 24, init_ship.end_loop1		# while in first row
	add $t6, $t1, $t4			# get address of ship[i]
	sw $t5, 0($t6)				# ship[i] = $t5
	beq $t4, 16, init_ship.if		# if on last 2 pixels then change color
init_ship.update1:
	add $t6, $t2, $t4			# get address of ship_colors[i]
	sw $t3, 0($t6)				# ship_colors[i] = $t3
	add $t4, $t4, 4				# increment iterator
	add $t5, $t5, 4				# increment index
	j init_ship.loop1	
init_ship.if:
	li $t3, PURPLE				# change the color
	j init_ship.update1			# return from if statement
init_ship.end_loop1:
	li $t3, GREEN
	li $t5, 6936
init_ship.loop2:
	beq $t4, 32, init_ship.end_loop2
	add $t6, $t1, $t4
	sw $t5, 0($t6)
	add $t6, $t2, $t4
	sw $t3, 0($t6)
	add $t4, $t4, 4
	add $t5, $t5, 4
	j init_ship.loop2
init_ship.end_loop2:
	li $t5, 7196
init_ship.loop3:
	beq $t4, 40, init_ship.end_loop3
	add $t6, $t1, $t4
	sw $t5, 0($t6)
	add $t6, $t2, $t4
	sw $t3, 0($t6)
	add $t4, $t4, 4
	add $t5, $t5, 4
	j init_ship.loop3
init_ship.end_loop3:
	li $t3, GRAY
	li $t5, 7448
init_ship.loop4:
	beq $t4, 56, init_ship.end_loop4
	add $t6, $t1, $t4
	sw $t5, 0($t6)
	add $t6, $t2, $t4
	sw $t3, 0($t6)
	add $t4, $t4, 4
	add $t5, $t5, 4
	j init_ship.loop4
init_ship.end_loop4:
	li $t3, PURPLE
	li $t5, 7700
init_ship.loop5:
	beq $t4, 88, init_ship.end_loop5
	add $t6, $t1, $t4
	sw $t5, 0($t6)
	beq $t4, 60, init_ship.if5		# if second pixel
	beq $t4, 76, init_ship.if6		# if last 3 pixels
init_ship.update5:
	add $t6, $t2, $t4
	sw $t3, 0($t6)
	add $t4, $t4, 4
	add $t5, $t5, 4
	j init_ship.loop5
init_ship.if5:
	li $t3, GRAY				# change the color
	j init_ship.update5			# return from if statement
init_ship.if6:
	li $t3, PURPLE				# change the color
	j init_ship.update5			# return from if statement
init_ship.end_loop5:
	li $t3, GRAY
	li $t5, 7960
init_ship.loop6:
	beq $t4, 104, init_ship.end_loop6
	add $t6, $t1, $t4
	sw $t5, 0($t6)
	add $t6, $t2, $t4
	sw $t3, 0($t6)
	add $t4, $t4, 4
	add $t5, $t5, 4
	j init_ship.loop6
init_ship.end_loop6:
	li $t3, GREEN
	li $t5, 8220
init_ship.loop7:
	beq $t4, 112, init_ship.end_loop7
	add $t6, $t1, $t4
	sw $t5, 0($t6)
	add $t6, $t2, $t4
	sw $t3, 0($t6)
	add $t4, $t4, 4
	add $t5, $t5, 4
	j init_ship.loop7
init_ship.end_loop7:
	li $t5, 8472
init_ship.loop8:
	beq $t4, 120, init_ship.end_loop8
	add $t6, $t1, $t4
	sw $t5, 0($t6)
	add $t6, $t2, $t4
	sw $t3, 0($t6)
	add $t4, $t4, 4
	add $t5, $t5, 4
	j init_ship.loop8
init_ship.end_loop8:
	li $t5, 8724
init_ship.loop9:
	beq $t4, 144, init_ship.end_loop9
	add $t6, $t1, $t4
	sw $t5, 0($t6)
	beq $t4, 136, init_ship.if9		# if second pixel
init_ship.update9:
	add $t6, $t2, $t4
	sw $t3, 0($t6)
	add $t4, $t4, 4
	add $t5, $t5, 4
	j init_ship.loop9
init_ship.if9:
	li $t3, PURPLE				# change the color
	j init_ship.update9			# return from if statement
init_ship.end_loop9:
	jr $ra




# draw_ship: This function draws the ship on the display at the current 
#	     location of the ship.
draw_ship:
	la $t1, ship		# $t1 holds address of the ship
	la $t2, ship_colors	# $t2 holds address of the ship colors
	li $t3, 0		# $t3 holds the index on the display
	li $t4, 0		# $t4 holds the iterator for loop
	li $t5, 0		# $t5 holds color at current index
	li $t6, 0		# $t6 holds offset
draw_ship.loop:
	beq $t4, 144, draw_ship.end_loop		# while not at the end of the array
	add $t6, $t1, $t4			# get ship[i]
	lw $t3, 0($t6)				# get value from ship[i]
	add $t6, $t2, $t4			# get ship_colors[i]
	lw $t5, 0($t6)				# get value from ship_colors[i]
	add $t6, $t0, $t3			# get position on display
	sw $t5, 0($t6)				# color that position
	add $t4, $t4, 4				# increment iterator
	j draw_ship.loop
draw_ship.end_loop:
	jr $ra
	
QUIT:	# Terminate the program gracefully
	li $v0, 10 
	syscall
