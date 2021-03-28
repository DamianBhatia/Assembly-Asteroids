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
.eqv	DARK_GRAY		0x005C5C5C
.eqv	BLACK			0x00000000

.data
ship:		.space		144	# array to hold spaceship position
ship_colors:	.space		144	# array to hold spaceship colors
asteroids:	.space		144	# array to hold the 3 asteroids positions

.text
	li $t0, BASE_ADDRESS	# $t0 stores the base address for the display
	jal init_ship		# initialize ship contents
	jal init_asteroids	# initialize asteroid contents
	jal game_loop		# main game loop
	j QUIT			# quit the program


# game_loop: This function is the main game loop. It will keep running while the 
#	     player has not quit the game. All updating and rendering will be done
#	     from inside of this function.
game_loop:
	li $t9, 0xffff0000	# check for key pressed
	lw $t8, 0($t9)
	beq $t8, 1, handle_keypress
keypress_return:
	jal update_asteroids	# update asteroids state	
	jal clear_screen	# clears the screen
	jal draw_asteroids	# draw the asteroids
	jal draw_ship		# draws the ship
	li $v0, 32		# sleep
	li $a0, 40
	syscall
	j game_loop


# handle_keypress: This function handles any keys pressed and calls the 
# 		   correct function to handle the key press
handle_keypress:
	lw $t2, 4($t9)			# get which key was pressed
	beq $t2, 0x77, move_ship_up	# if w was pressed move up
	beq $t2, 0x73, move_ship_down	# if s was pressed move down
	beq $t2, 0x61, move_ship_left	# if a was pressed move left
	beq $t2, 0x64, move_ship_right	# if d was pressed move right
	j keypress_return		# otherwise return to game loop


# move_ship_up: This function moves the ship up when the w key is pressed
move_ship_up:
	la $t1, ship	# $t1 holds address of the ship
	li $t3, 0	# $t3 holds the iterator for the loop
	li $t4, 0	# $t4 holds the address of ship[i]
move_ship_up.loop:
	beq $t3, 144, move_ship_up.end_loop
	add $t4, $t1, $t3	# get ship[i] address
	lw $t5, 0($t4)		# get current position at ship[i]
	sub $t5, $t5, 256	# calculate move position up
	sw $t5, 0($t4)		# change position
	add $t3, $t3, 4		# increment iterator
	j move_ship_up.loop
move_ship_up.end_loop:
	j keypress_return	# return to game loop
	

# move_ship_down: This function moves the ship down when the s key is pressed
move_ship_down:
	la $t1, ship	# $t1 holds address of the ship
	li $t3, 0	# $t3 holds the iterator for the loop
	li $t4, 0	# $t4 holds the address of ship[i]
move_ship_down.loop:
	beq $t3, 144, move_ship_down.end_loop
	add $t4, $t1, $t3	# get ship[i] address
	lw $t5, 0($t4)		# get current position at ship[i]
	add $t5, $t5, 256	# calculate move position down
	sw $t5, 0($t4)		# change position
	add $t3, $t3, 4		# increment iterator
	j move_ship_down.loop
move_ship_down.end_loop:
	j keypress_return	# return to game loop


# move_ship_left: This function moves the ship left when the a key is pressed
move_ship_left:
	la $t1, ship	# $t1 holds address of the ship
	li $t3, 0	# $t3 holds the iterator for the loop
	li $t4, 0	# $t4 holds the address of ship[i]
move_ship_left.loop:
	beq $t3, 144, move_ship_left.end_loop
	add $t4, $t1, $t3	# get ship[i] address
	lw $t5, 0($t4)		# get current position at ship[i]
	sub $t5, $t5, 4		# calculate move position left
	sw $t5, 0($t4)		# change position
	add $t3, $t3, 4		# increment iterator
	j move_ship_left.loop
move_ship_left.end_loop:
	j keypress_return	# return to game loop
	
	
# move_ship_right: This function moves the ship right when the d key is pressed
move_ship_right:
	la $t1, ship	# $t1 holds address of the ship
	li $t3, 0	# $t3 holds the iterator for the loop
	li $t4, 0	# $t4 holds the address of ship[i]
move_ship_right.loop:
	beq $t3, 144, move_ship_right.end_loop
	add $t4, $t1, $t3	# get ship[i] address
	lw $t5, 0($t4)		# get current position at ship[i]
	add $t5, $t5, 4		# calculate move position right
	sw $t5, 0($t4)		# change position
	add $t3, $t3, 4		# increment iterator
	j move_ship_right.loop
move_ship_right.end_loop:
	j keypress_return	# return to game loop
	

# update_asteroids: This function updates the state of the asteroids
update_asteroids:
	la $t1, asteroids					# $t1 holds address of asteroids
	li $t4, 0						# $t4 holds iterator for loop
	li $t6, 0						# $t6 holds the index on the display
	li $t2, 0						# $t2 holds offset
update_asteroids.loop:
	beq $t4, 144, update_asteroids.end_loop		# for loop for entire asteroid
	add $t2, $t4, $t1					# get address of asteroids[i]
	lw $t6, 0($t2)						# get value at asteroids[i]
	sub $t6, $t6, 4						# move to the left
	sw $t6, 0($t2)						# write new position
	add $t4, $t4, 4
	j update_asteroids.loop
update_asteroids.end_loop:
	jr $ra
	

# clear_screen: This function will clear the display, making every pixel black
clear_screen:
	li $t1, 0		# $t1 will hold the address on the display
	li $t2, 0		# $t2 holds the iterator for the loop
	li $t3, BLACK		# $t3 holds the color black
clear_screen.loop:
	beq $t2, 16380, clear_screen.end_loop	
	add $t1, $t0, $t2	# get position on display
	sw $t3, 0($t1)		# color position black
	add $t2, $t2, 4		# increment iterator
	j clear_screen.loop
clear_screen.end_loop:
	jr $ra


# init_asteroids: This function initializes the contents of the asteroids. At
#		   each index asteroids[i] we store the index on the display
#		   corresponding to that pixel.
init_asteroids:
	la $t1, asteroids	# $t1 holds address of asteroids
	li $t4, 0		# $t4 holds iterator for loop
	
	# Random number generator
	li $v0, 42
	li $a0, 0
	li $a1, 59 
	syscall
	
	move $t5, $a0		# $t5 holds the random number or y
	mul $t5, $t5, 256
	
	li $v0, 42
	li $a0, 0
	li $a1, 40
	syscall
	
	move $t9, $a0		# $t9 holds the random number for x
	add $t9, $t9, 15
	mul $t9, $t9, 4	
	add $t5, $t5, $t9	# $t5 holds the index on the display
	
	# Initialize the first asteroid
init_asteroids.first:
	beq $t4, 144, init_asteroids.second		# for loop for entire asteroid
	beq $t4, 12, init_asteroids.first_update	# if in second row
	beq $t4, 24, init_asteroids.first_update	# if in third row
	
	beq $t4, 36, init_asteroids.first_genrandom	# get new random position
	beq $t4, 48, init_asteroids.first_update	# if in second row of second asteroid
	beq $t4, 60, init_asteroids.first_update	# if in third row of second asteroid
	
	beq $t4, 72, init_asteroids.first_genrandom	# get new random position
	beq $t4, 84, init_asteroids.first_update	# if in second row of third asteroid
	beq $t4, 96, init_asteroids.first_update	# if in third row of third asteroid
	
	beq $t4, 108, init_asteroids.first_genrandom	# get new random position
	beq $t4, 120, init_asteroids.first_update	# if in second row of fourth asteroid
	beq $t4, 132, init_asteroids.first_update	# if in third row of fourth asteroid
init_asteroids.first_continue:
	add $t6, $t1, $t4	# get address of asteroids[i]
	sw $t5, 0($t6)		# asteroids[i] = $t5
	add $t4, $t4, 4		# increment iterator by 4
	add $t5, $t5, 4		# increment index by 4
	j init_asteroids.first
init_asteroids.first_update:	# update the index position
	add $t5, $t5, 244
	j init_asteroids.first_continue
init_asteroids.first_genrandom:		# generate new random number
	# Random number generator
	li $v0, 42
	li $a0, 0
	li $a1, 59 
	syscall
	
	move $t5, $a0		# $t5 holds the random number or y
	mul $t5, $t5, 256
	
	li $v0, 42
	li $a0, 0
	li $a1, 40 
	syscall
	
	move $t9, $a0		# $t9 holds the random number for x
	add $t9, $t9, 15
	mul $t9, $t9, 4	
	add $t5, $t5, $t9	# $t5 holds the index on the display
	j init_asteroids.first_continue
init_asteroids.second:
	jr $ra
	
	
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
	beq $t4, 24, init_ship.end_loop1	# while in first row
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
	li $t3, GREEN				# set the color to green
	li $t5, 6936				#  set the start index on display
init_ship.loop2:				# initialize the second row of the ship
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
init_ship.loop3:				# initialize the third row of the ship
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
init_ship.loop4:				# initialize the fourth row of the ship
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
init_ship.loop5:				# initialize the fifth row of the ship
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
init_ship.loop6:				# initialize the sixth row of the ship
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
init_ship.loop7:				# initialize the seventh row of the ship
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
init_ship.loop8:				# initialize the eighth row of the ship
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
init_ship.loop9:				# initialize ninth row of the ship
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


# draw_asteroids: This function draws the asteroids on the display at the current 
#	     location of the asteroids.
draw_asteroids:
	la $t1, asteroids
	li $t2, DARK_GRAY
	li $t3, 0
	li $t4, 0
	li $t6, 0
draw_asteroids.loop:
	beq $t4, 144, draw_asteroids.end_loop	# while not at end of asteroid
	add $t6, $t1, $t4			# get asteroids[i]
	lw $t3, 0($t6)				# get value at asteroids[i]
	add $t6, $t0, $t3			# get position on display
	sw $t2, 0($t6)				# color that position
	add $t4, $t4, 4				# increment iterator
	j draw_asteroids.loop 
draw_asteroids.end_loop:
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
