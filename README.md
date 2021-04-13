# Assembly Asteroids
## Table of Contents
* [General Info](#general-info)
* [Setup](#setup)
* [Controls](#controls)

## General Info
This game was my final project for CSCB58 - Computer Organization at the University of Toronto Scarborough. The game was created using the MIPS Assembly programming language and used the MARS Simulator in order to assemble and execute the code.


## Setup
To run this project, download the MARS Simulator from http://courses.missouristate.edu/kenvollmar/mars/download.htm if you have not already. Then, download the game.asm file to your device. Once both are installed, open up MARS and browse until you find the downloaded game.asm file.

In order to run the game you will need to use the MARS Bitmap Display and the Keyboard MMIO Simulator.

### Bitmap Display
To open the bitmap display, click on the Tools tab and select Bitmap Display. In the window that is opened, set the values as follows:

* Unit Width in Pixels: 8
* Unit Height in Pixels: 8
* Display Width in Pixels: 512
* Display Height in Pixels: 512
* Base address for display: 0x10008000 ($gp)

Once the values are set click the Connect to MIPS button in the bottom left.

### Keyboard and Display MMIO Simulator
Similarly, to open the keyboard and display MMIO simulator, click on the Tools tab and select Keyboard and Display MMIO Simulator from the dropdown menu. In the window that is opened, click the Connect to MIPS button in the bottom left.

### Running the Game
Once everything is setup and ready to go, press the F3 key in order to assemble the code and then the green play button. The game should start running in the Bitmap display window. In order to interact with the game, click inside of the bottom textarea labelled KEYBOARD inside of the Keyboard and Display MMIO Simulator and now any key you press will be captured inside of the game.

## Controls
* W - Move up
* A - Move left
* S - Move down
* D - Move right
* P - Restart the game

### Power-ups
* Green powerups will give the player +5 health if their health is currently <= 15. (MAX health is 20)
* Blue powerups will slow down the asteroids if the asteroids speed is currently > 1 (MIN speed is 1)

----
Thank you for reading these instructions and I hope you enjoy the game!
