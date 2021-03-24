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
.eqv	COLOR_RED		0x00FF0000

.data
ship:	.space	36	# 3x3 spaceship

.text
	li $t0, BASE_ADDRESS	# $t0 stores the base address for the display
	jal init_ship		# initialize the indices of the ship
	jal draw_ship		# draw the ship on the display
	j QUIT			# quit the program


# init_ship: This function initializes the contents of the ship. At each index
# 	     ship[i] we store the index on the display that corresponds to that 
#	     pixel.
init_ship:
	la $t1, ship		# $t1 holds address of the ship
	li $t2, 0		# $t2 holds counter to go through array
	li $t3, 8036		# $t3 holds start index of ship
	li $t4, 0		# $t4 holds address of ship[i]
	add $t5, $t1, 12 	# $t5 holds location of ship[3]
	add $t6, $t1, 24	# $t6 sholds ship[6]
init_ship.loop: 
	beq $t2, 36, init_ship.end_loop		# while not at the end of the array
	add $t4, $t2, $t1			# get ship[i]
	beq $t4, $t5, init_ship.if		# branch if we are about to be in the second row
	beq $t4, $t6, init_ship.if		# branch if we are about to be in the third row
init_ship.update:	
	sw $t3, 0($t4)		# store the index at ship[i]
	add $t3, $t3, 4		# increment index by 4
	add $t2, $t2, 4		# increment counter by 4
	j init_ship.loop	# jump to start of loop
init_ship.if:
	add $t3, $t3, 244	# shift the index over to the next row
	j init_ship.update
init_ship.end_loop:
	jr $ra


# draw_ship: This function draws the ship on the display at the current 
#	     location of the ship.	
draw_ship:
	la $t1, ship		# $t1 holds address of the ship
	li $t2, 0		# $t2 holds counter to go through array
	li $t4, 0		# $t4 holds value of ship[i]
	li $t3, COLOR_RED	# $t3 holds color of the ship
draw_ship.loop:
	beq $t2, 36, draw_ship.end_loop		# while not at the end of the array
	add $t6, $t1, $t2			# get address of ship[i]
	lw $t4, 0($t6)				# get value of ship[i]
	add $t5, $t0, $t4			# get position on the display
	sw $t3, 0($t5)				# color the position on the display
	add $t2, $t2, 4				# increment index counter by 4
	j draw_ship.loop			# jump to start of loop
draw_ship.end_loop:
	jr $ra

QUIT:	# Terminate the program gracefully
	li $v0, 10 
	syscall
