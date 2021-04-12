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
#  - Milestone 4 (choose the one the applies)
#
#  Which approved features have been implemented for milestone 4?
#  (See the assignment handout for the list of additional features)
#  1. Asteroid speeds increase the longer the game progresses
#  2. Heal and Slow Asteroids powerups appear randomly that the ship can pickup
#  3. Smooth graphics to try and eliminate flickering
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
.eqv 	LIME_GREEN		0x0000FF00
.eqv	CYAN			0x0000FFFF


.data
ship:				.space		144	# array to hold spaceship position
ship_colors:			.space		144	# array to hold spaceship colors
asteroids:			.space		144	# array to hold the 3 asteroids positions
health_bar:			.space		80	# array to hold the ships health
health:				.word		20	# current value of the ship health
power_up:			.word		17000	# array to hold the powerup
power_up_timer:			.word		300	# timer for when to spawn powerup
power_type:			.word		0	# 0 if heal and 1 if speed boost	
asteroid_speed:			.word		1	# speed at which asteroid is going
asteroid_timer:			.word		350	# timer for when to increment asteroid speed


.text
	li $t0, BASE_ADDRESS	# $t0 stores the base address for the display
	jal init_ship		# initialize ship contents
	jal init_asteroids	# initialize asteroid contents
	jal init_healthbar	# initialize ship health bar
	jal game_loop		# main game loop
	j QUIT			# quit the program


# game_loop: This function is the main game loop. It will keep running while the 
#	     player has not quit the game. All updating and rendering will be done
#	     from inside of this function.
game_loop:
	li $t9, 0xffff0000	# check for key pressed
	lw $t8, 0($t9)
	beq $t8, 1, handle_keypress	# if there was a key pressed then handle the event
keypress_return:
	jal delete_asteroids
	jal update_asteroids	# update asteroids state
	jal check_collisions 	# check for asteroid and ship collision	
	jal powerup_collision
	jal asteroid_speeds	# check if speed needs to increase
	
	la $t4, health		# check if game over
	lw $t4, 0($t4)
	ble $t4, $zero, game_over
	
	jal draw_power_up	# draw powerup if timer has finished
	jal draw_healthbar	# draw the healthbar
	jal draw_asteroids	# draw the asteroids
	jal draw_ship		# draws the ship
	li $v0, 32		# sleep
	li $a0, 40
	syscall
	j game_loop



# asteroid_speeds: This function is responsible for checking the speed of the 
#		    asteroids and incrementing the speed if the timer hits 0
asteroid_speeds:
	la $t1, asteroid_timer
	lw $t2, 0($t1)
	ble $t2, $zero, speed_increment		# check if timer has run out
	sub $t2, $t2, 1				# if no then decrement timer by 1
	sw $t2, 0($t1)
	j asteroid_speeds.done			# done checking
speed_increment:
	la $t3, asteroid_speed			# get the asteroid speed
	lw $t4, 0($t3)
	add $t4, $t4, 1				# increment the speed by 1
	sw $t4, 0($t3)		
	li $t3, 350				# reset the timer for next time
	sw $t3, 0($t1)
asteroid_speeds.done:
	jr $ra
	
	

# draw_power_up: This function will draw the powerup at a random location
#		  if the spawn timer has hit zero
draw_power_up:
	la $t1, power_up_timer	# $t1 will hold the spawn timer
	lw $t2, 0($t1)		# $t2 holds time remainings
	beq $t2, $zero, draw_power_up.loop
	sub $t2, $t2, 2		# decrement timer
	sw $t2, 0($t1)		# update timer
	
	j draw_power_up.color
draw_power_up.loop:
	la $t8, power_up	# $t3 holds address of powerup 
	# Random number generator
	li $v0, 42
	li $a0, 0
	li $a1, 59 
	syscall
	
	move $t5, $a0		# $t5 holds the random number for y
	mul $t5, $t5, 256
	
	li $v0, 42
	li $a0, 0
	li $a1, 40 
	syscall
	
	move $t9, $a0		# $t9 holds the random number for x
	add $t9, $t9, 15
	mul $t9, $t9, 4	
	add $t5, $t5, $t9	# $t5 holds the index on the display
	
	# delete the powerup
	lw $t4, 0($t8)
	li $t6, BLACK
	add $t7, $t0, $t4	# get display position
	
	sw $t6, 0($t7)		# color that position on display
	sw $t6, 4($t7)
	sw $t6, -4($t7)
	
	add $t4, $t4, 256	# color bottom part of the cross
	add $t7, $t0, $t4
	sw $t6, 0($t7)
	
	sub $t4, $t4, 512	# color top part of the cross
	add $t7, $t0, $t4
	sw $t6, 0($t7)
	
	sw $t5, 0($t8)		# store position in power up
	
	li $t2, 300		# Reset the spawn timer
	la $t1, power_up_timer	# $t1 will hold the spawn timer
	sw $t2, 0($t1)
	
	# Checks the type of powerup and flips it
	la $t2, power_type
	lw $t5, 0($t2)
	beq $t5, $zero, set_power_one
	li $t5, 0
	sw $t5, 0($t2)
	j draw_power_up.color
set_power_one:
	li $t5, 1
	sw $t5, 0($t2)
draw_power_up.color:	# choose the color based off of powerup type
	la $t9, power_type
	lw $t9, 0($t9)
	
	beq $t9, 0, speed
	li $t8, LIME_GREEN		# $t8 holds the color of the powerup
	j render_powerup
speed:
	li $t8, CYAN		
render_powerup:
	la $t1, power_up
	lw $t9, 0($t1)
	add $t7, $t0, $t9	# get display position
	
	sw $t8, 0($t7)		# color that position on display
	sw $t8, 4($t7)
	sw $t8, -4($t7)
	
	add $t9, $t9, 256	# color bottom part of the cross
	add $t7, $t0, $t9
	sw $t8, 0($t7)
	
	sub $t9, $t9, 512	# color top part of the cross
	add $t7, $t0, $t9
	sw $t8, 0($t7)
draw_power_up.done:
	jr $ra



# powerup_collision: This function checks to see if the ship has 
# 		      collided with the powerup and applies the 
#		      effect based off of the powerup type
powerup_collision:
	la $t1, power_up			# $t1 holds address of powerup
	la $t2, ship				# $t2 holds address of the ship
	lw $t3, 0($t1)
	lw $t4, 68($t2)
	sub $t5, $t3, $t4			# get distance
	beq $t5, $zero, collision.yes		# check if collision occurred
	j powerup_collision.done
collision.yes:					# collision has occurred with the powerup
	la $t3, power_type			# get the current powerup type
	lw $t3, 0($t3)
	beq $t3, 1, health_powerup		# branch if powerup is health type
	la $t4, asteroid_speed			# get asteroid speed
	lw $t5, 0($t4)
	sub $t5, $t5, 1				# decrement asteroid speed by 1
	blt $t5, 1, powerup_collision.done	# if speed < 1 then dont use powerup
	sw $t5, 0($t4)
	add $sp, $sp, 4
	sw $ra, 0($sp)
	jal draw_power_up.loop			# if powerup used then delete from display
	lw $ra, 0($sp)
	sub $sp, $sp, 4
	j powerup_collision.done		# skip to end 
health_powerup:					# if type is currently a health powerup
	la $t2, health				# get the health
	lw $t1, 0($t2)	
	add $t1, $t1, 5				# add 5 to the existing health
	bgt $t1, 20, powerup_collision.done	# if new health is greater than max health skip this powerup
	sw $t1, 0($t2)
	add $sp, $sp, 4
	sw $ra, 0($sp)
	jal draw_power_up.loop			# if powerup is used then delete it from the screen
	lw $ra, 0($sp)
	sub $sp, $sp, 4
powerup_collision.done:
	jr $ra
	
	
	
# game_over: This function handles the game over screen and waits to
#	     see if the user wants to restart the game
game_over:
	li $t1, 0		# $t1 will hold the address on the display
	li $t2, 0		# $t2 holds the iterator for the loop
	li $t3, RED		# $t3 holds the color black
game_over.repaint_loop:
	beq $t2, 16384, game_over.loop	
	add $t1, $t0, $t2	# get position on display
	sw $t3, 0($t1)		# color position red
	add $t2, $t2, 4		# increment iterator
	j game_over.repaint_loop
game_over.loop:
	li $t9, 0xffff0000		# check if a key was pressed
	lw $t8, 0($t9)
	beq $t8, 1, game_over.handle_keypress
	j game_over.loop
	
game_over.handle_keypress:
	lw $t2, 4($t9)			# get which key was pressed
	beq $t2, 0x70, restart		# if p was pressed restart game
	j game_over.loop
restart:
	jal restart_game		# resest the game state
	j game_loop			# jump back to the main game loop




# handle_keypress: This function handles any keys pressed and calls the 
# 		   correct function to handle the key press
handle_keypress:
	lw $t2, 4($t9)			# get which key was pressed
	beq $t2, 0x70, restart_game	# if p was pressed restart game
	beq $t2, 0x77, move_ship_up	# if w was pressed move up
	beq $t2, 0x73, move_ship_down	# if s was pressed move down
	beq $t2, 0x61, move_ship_left	# if a was pressed move left
	beq $t2, 0x64, move_ship_right	# if d was pressed move right
	j keypress_return		# otherwise return to game loop


# restart_game: This function reinitializes the game variables so that the
#		 game goes back to the state at the start of the game
restart_game:
	add $sp, $sp, 4
	sw $ra, 0($sp)
	jal init_ship		# initialize ship contents
	jal init_asteroids	# initialize asteroid contents
	jal init_healthbar
	jal clear_screen
	lw $ra, 0($sp)
	sub $sp, $sp, 4
	la $t1, asteroid_speed
	li $t2, 1
	sw $t2, 0($t1)
	la $t1, asteroid_timer
	li $t2, 350
	sw $t2, 0($t1)
	jr $ra



# move_ship_up: This function moves the ship up when the w key is pressed
move_ship_up:
	jal delete_ship
	la $t1, ship	# $t1 holds address of the ship
	li $t3, 0	# $t3 holds the iterator for the loop
	li $t4, 0	# $t4 holds the address of ship[i]
	lw $t9, 0($t1)	# $t9 holds ship[0]
	ble $t9, 252, move_ship_up.end_loop
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
	jal delete_ship
	la $t1, ship		# $t1 holds address of the ship
	li $t3, 0		# $t3 holds the iterator for the loop
	li $t4, 0		# $t4 holds the address of ship[i]
	lw $t9, 120($t1)	# $t9 holds ship[30]
	bge $t9, 16128, move_ship_down.end_loop
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
	jal delete_ship
	la $t1, ship		# $t1 holds address of the ship
	li $t3, 0		# $t3 holds the iterator for the loop
	li $t4, 0		# $t4 holds the address of ship[i]
	lw $t9, 0($t1)		# $t9 holds ship[0]
	div $t9, $t9, 4		# divide the index on display by 4
	li $t8, 64		
	div $t9, $t8		# divide by 64 to get remainder which will be x value
	mfhi $t9		# store x value
	beqz $t9, move_ship_left.end_loop	# if x == 0 then don't want to move left
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
	jal delete_ship
	la $t1, ship	# $t1 holds address of the ship
	li $t3, 0	# $t3 holds the iterator for the loop
	li $t4, 0	# $t4 holds the address of ship[i]
	lw $t9, 84($t1)		# $t9 holds ship[21]
	div $t9, $t9, 4		# divide the index on display by 4
	li $t8, 64		
	div $t9, $t8		# divide by 64 to get remainder which will be x value
	mfhi $t9		# store x value
	beq $t9, 63, move_ship_right.end_loop	# if x == 0 then don't want to move left
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
	li $t3, 64	
	
	# Check if at left adge of the screen
	lw $t9, 0($t1)		# first asteroid top left
	div $t7, $t9, 4		# divide the index on display by 4

	div $t7, $t3			# divide by 64 to get remainder which will be x value
	mfhi $t7			# store x value
	
	bne $t7, 0, gen_new_random.end # if x != 0 then don't want to generate new random position
	
	# Generate new random position
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
	
	move $t8, $a0		# $t8 holds the random number for x
	add $t8, $t8, 32
	mul $t8, $t8, 4	
	add $t5, $t5, $t8	# $t5 holds the index on the display
	
	li $a3, 0		# iterator for the loop
gen_new_position_loop:
	beq $a3, 36, gen_new_random.end			# while not at the end of the asteroid
	beq $a3, 12, gen_new_position_first_update	# if in second row
	beq $a3, 24, gen_new_position_first_update	# if in third row
gen_new_position_continue:
	add $t9, $t1, $a3	# get asteroid[i]
	sw $t5, 0($t9)		# replace current position with new random position
	add $a3, $a3, 4		# increment loop iterator
	add $t5, $t5, 4		# increment index on display
	j gen_new_position_loop
gen_new_position_first_update:
	add $t5, $t5, 244	# jump to next line if in another row
	j gen_new_position_continue
gen_new_random.end:
	# Check if at left adge of the screen
	lw $t9, 36($t1)		# first asteroid top left
	div $t7, $t9, 4		# divide the index on display by 4

	div $t7, $t3			# divide by 64 to get remainder which will be x value
	mfhi $t7			# store x value
	
	bne $t7, 0, gen_new_random.end2 # if x != 0 then don't want to generate new random position
	
	# Generate new random position
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
	
	move $t8, $a0		# $t8 holds the random number for x
	add $t8, $t8, 32
	mul $t8, $t8, 4	
	add $t5, $t5, $t8	# $t5 holds the index on the display
	
	li $a3, 36		# iterator for the loop
gen_new_position_loop2:
	beq $a3, 72, gen_new_random.end2		# while not at the end of the asteroid
	beq $a3, 48, gen_new_position_second_update	# if in second row
	beq $a3, 60, gen_new_position_second_update	# if in third row
gen_new_position_continue2:
	add $t9, $t1, $a3	# get asteroid[i]
	sw $t5, 0($t9)		# replace current position with new random position
	add $a3, $a3, 4		# increment loop iterator
	add $t5, $t5, 4		# increment index on display
	j gen_new_position_loop2
gen_new_position_second_update:
	add $t5, $t5, 244	# jump to next line if in another row
	j gen_new_position_continue2
gen_new_random.end2:
	# Check if at left adge of the screen
	lw $t9, 72($t1)		# first asteroid top left
	div $t7, $t9, 4		# divide the index on display by 4

	div $t7, $t3			# divide by 64 to get remainder which will be x value
	mfhi $t7			# store x value
	
	bne $t7, 0, gen_new_random.end3 # if x != 0 then don't want to generate new random position
	
	# Generate new random position
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
	
	move $t8, $a0		# $t8 holds the random number for x
	add $t8, $t8, 32
	mul $t8, $t8, 4	
	add $t5, $t5, $t8	# $t5 holds the index on the display
	
	li $a3, 72		# iterator for the loop
gen_new_position_loop3:
	beq $a3, 108, gen_new_random.end3		# while not at the end of the asteroid
	beq $a3, 84, gen_new_position_third_update	# if in second row
	beq $a3, 96, gen_new_position_third_update	# if in third row
gen_new_position_continue3:
	add $t9, $t1, $a3	# get asteroid[i]
	sw $t5, 0($t9)		# replace current position with new random position
	add $a3, $a3, 4		# increment loop iterator
	add $t5, $t5, 4		# increment index on display
	j gen_new_position_loop3
gen_new_position_third_update:
	add $t5, $t5, 244	# jump to next line if in another row
	j gen_new_position_continue3
gen_new_random.end3:
	# Check if at left adge of the screen
	lw $t9, 108($t1)		# first asteroid top left
	div $t7, $t9, 4		# divide the index on display by 4

	div $t7, $t3			# divide by 64 to get remainder which will be x value
	mfhi $t7			# store x value
	
	bne $t7, 0, update_asteroids.loop	# if x != 0 then don't want to generate new random position
	
	# Generate new random position
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
	
	move $t8, $a0		# $t8 holds the random number for x
	add $t8, $t8, 32
	mul $t8, $t8, 4	
	add $t5, $t5, $t8	# $t5 holds the index on the display
	
	li $a3, 108		# iterator for the loop
gen_new_position_loop4:
	beq $a3, 144, update_asteroids.loop		# while not at the end of the asteroid
	beq $a3, 120, gen_new_position_fourth_update	# if in second row
	beq $a3, 132, gen_new_position_fourth_update	# if in third row
gen_new_position_continue4:
	add $t9, $t1, $a3	# get asteroid[i]
	sw $t5, 0($t9)		# replace current position with new random position
	add $a3, $a3, 4		# increment loop iterator
	add $t5, $t5, 4		# increment index on display
	j gen_new_position_loop4
gen_new_position_fourth_update:
	add $t5, $t5, 244	# jump to next line if in another row
	j gen_new_position_continue4
update_asteroids.loop:
	beq $t4, 144, update_asteroids.end_loop		# for loop for entire asteroid
	add $t2, $t4, $t1					# get address of asteroids[i]
	lw $t6, 0($t2)						# get value at asteroids[i]
	la $t3, asteroid_speed
	lw $t3, 0($t3)						# get asteroid speed
	mul $t3, $t3, 4						# multiply by 4
	sub $t6, $t6, $t3					# move to the left
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
	beq $t2, 16384, clear_screen.end_loop	
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



# delete_asteroids: This function deletes the asteroids from the screen
#	     	     so that we can move them smoothly
delete_asteroids:
	la $t1, asteroids
	li $t2, BLACK
	li $t3, 0
	li $t4, 0
	li $t6, 0
delete_asteroids.loop:
	beq $t4, 144, delete_asteroids.end_loop	# while not at end of asteroid
	add $t6, $t1, $t4			# get asteroids[i]
	lw $t3, 0($t6)				# get value at asteroids[i]
	add $t6, $t0, $t3			# get position on display
	sw $t2, 0($t6)				# color that position
	add $t4, $t4, 4				# increment iterator
	j delete_asteroids.loop 
delete_asteroids.end_loop:
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


# delete_ship: This function paints the ship to match the background so that
#	       the ship can be moved to a new position
delete_ship:
	la $t1, ship		# $t1 holds address of the ship
	li $t3, 0		# $t3 holds the index on the display
	li $t4, 0		# $t4 holds the iterator for loop
	li $t5, BLACK		# $t5 holds color at current index
	li $t6, 0		# $t6 holds offset
delete_ship.loop:
	beq $t4, 144, delete_ship.end_loop		# while not at the end of the array
	add $t6, $t1, $t4			# get ship[i]
	lw $t3, 0($t6)				# get value from ship[i]
	add $t6, $t0, $t3			# get position on display
	sw $t5, 0($t6)				# color that position
	add $t4, $t4, 4				# increment iterator
	j delete_ship.loop
delete_ship.end_loop:
	jr $ra
	
	
# check_collisions: This function checks for collisions between the player ship and
# 		     the asteroids
check_collisions:
	la $t1, ship		# $t1 holds the address for the ship
	la $t2, asteroids	# $t2 holds the address for the asteroids
	li $t3, 64
	
	lw $t9, 68($t1)		# $t9 holds value of ship[i]
	div $t7, $t9, 4		# divide the index on display by 4

	div $t7, $t3			# divide by 64 to get remainder which will be x value
	mfhi $t7			# store x value
	mflo $t5			# store y value
	
	# Check asteroid 1 collision
	lw $t8, 16($t2)		# $t8 holds middle of asteroid
	div $t6, $t8, 4		# divide the index on display by 4
	
	div $t6, $t3		# divide by 64 to get remainder which will be x value
	mfhi $t6		# store x value
	mflo $t3		# store y value
	
	sub $t4, $t6, $t7 	# get x value distance between ship and asteroid
	sub $t3, $t3, $t5	# get y value distance between ship and asteroid
	
	# Branch if the x or y distance is not within 2 otherwise a collision has happened
	bgt $t4, 2, check_collisions.second		
	blt $t4, -2, check_collisions.second		
	bgt $t3, 4, check_collisions.second		
	blt $t3, -4, check_collisions.second
	
	j collision_happened
	
check_collisions.second:
	li $t3, 64
	# Check asteroid 2 collision
	lw $t8, 52($t2)		# $t8 holds middle of asteroid
	div $t6, $t8, 4		# divide the index on display by 4
	
	div $t6, $t3		# divide by 64 to get remainder which will be x value
	mfhi $t6		# store x value
	mflo $t3		# store y value
	
	sub $t4, $t6, $t7 	# get x value distance between ship and asteroid
	sub $t3, $t3, $t5	# get y value distance between ship and asteroid
	
	# Branch if the x or y distance is not within 2 otherwise a collision has happened
	bgt $t4, 2, check_collisions.third		
	blt $t4, -2, check_collisions.third		
	bgt $t3, 4, check_collisions.third		
	blt $t3, -4, check_collisions.third
	
	j collision_happened
	
check_collisions.third:
	li $t3, 64
	# Check asteroid 3 collision
	lw $t8, 88($t2)		# $t8 holds middle of asteroid
	div $t6, $t8, 4		# divide the index on display by 4
	
	div $t6, $t3		# divide by 64 to get remainder which will be x value
	mfhi $t6		# store x value
	mflo $t3		# store y value
	
	sub $t4, $t6, $t7 	# get x value distance between ship and asteroid
	sub $t3, $t3, $t5	# get y value distance between ship and asteroid
	
	# Branch if the x or y distance is not within 2 otherwise a collision has happened
	bgt $t4, 2, check_collisions.fourth		
	blt $t4, -2, check_collisions.fourth		
	bgt $t3, 4, check_collisions.fourth		
	blt $t3, -4, check_collisions.fourth
	
	j collision_happened
	
check_collisions.fourth:
	li $t3, 64
	# Check asteroid 4 collision
	lw $t8, 124($t2)		# $t8 holds middle of asteroid
	div $t6, $t8, 4		# divide the index on display by 4
	
	div $t6, $t3		# divide by 64 to get remainder which will be x value
	mfhi $t6		# store x value
	mflo $t3		# store y value
	
	sub $t4, $t6, $t7 	# get x value distance between ship and asteroid
	sub $t3, $t3, $t5	# get y value distance between ship and asteroid
	
	# Branch if the x or y distance is not within 2 otherwise a collision has happened
	bgt $t4, 2, check_collisions.done		
	blt $t4, -2, check_collisions.done		
	bgt $t3, 4, check_collisions.done		
	blt $t3, -4, check_collisions.done
	
	j collision_happened
	
collision_happened:
	li $t3, 0		# $t3 holds the index on the display
	li $t4, 0		# $t4 holds the iterator for loop
	li $t5, RED		# $t5 holds color at current index
	li $t6, 0		# $t6 holds offset
	la $t9, health		# $t9 holds address of health
	lw $t8, 0($t9)		# get current health
	sub $t8, $t8, 1		# decrease health by 1
	sw $t8, 0($t9)		# write new health
collision_happened.loop:
	beq $t4, 144, check_collisions.done		# while not at the end of the array
	add $t6, $t1, $t4			# get ship[i]
	lw $t3, 0($t6)				# get value from ship[i]
	add $t6, $t0, $t3			# get position on display
	sw $t5, 0($t6)				# color that position
	add $t4, $t4, 4				# increment iterator
	j collision_happened.loop
check_collisions.done:
	jr $ra


# init_healthbar: This function sets the ships healthbar to be full health
init_healthbar:
	la $t1, health	# $t1 holds address of health
	li $t2, 20	# $t1 holds value of 100
	sw $t2, 0($t1)	# resets health to 100
	jr $ra
	

# draw_healthbar: This function draws the healthbar in the top right corner
#		   of the bitmap display
draw_healthbar:
	li $t9, LIME_GREEN	# $t9 holds the color for healthbar
	la $t1, health_bar	# $t1 holds address of the healthbar
	la $t2, health		# $t2 holds address of current health
	li $t4, 0		# $t4 holds iterator for loop
	li $t5, 424
	lw $t3, 0($t2)		# get the current health
	mul $t3, $t3, 4
draw_healthbar.loop:
	beq $t4, $t3, draw_healthbar.end_loop
	add $t6, $t0, $t5	# get position on display
	sw $t9, 0($t6)		# color position on display
	add $t4, $t4, 4		# increment loop iterator
	add $t5, $t5, 4
	j draw_healthbar.loop
draw_healthbar.end_loop:
	li $t9, RED
draw_healthbar.loop2:
	beq $t4, 80, draw_healthbar.end_loop2
	add $t6, $t0, $t5	# get position on display
	sw $t9, 0($t6)		# color position on display
	add $t4, $t4, 4		# increment loop iterator
	add $t5, $t5, 4
	j draw_healthbar.loop2
draw_healthbar.end_loop2:
	jr $ra
	
	
QUIT:	# Terminate the program gracefully
	li $v0, 10 
	syscall
