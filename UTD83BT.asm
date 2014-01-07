; Ultimate Tag: Deathmatch 83, Beyond Thunderdom 
; Simpler Tag game made for the Atari 2600, uses DASM emulator and
; requires vcs.h for memory locations.
; Written By: William Roy
; Lastest Revision: November 8th, 2013

; ***** Sorry about the grammar and spelling in the comments. 
; ***** I also can't move the bot any slower.
	
	processor 6502				;tells DASM the processor I'd like to use
	include vcs.h 				;imports the names of the Atari memory locations
	org $F000 					;tells DASM where the starting memory location is

;Memory aliases 	
YPosFromBot1 = $80				;player1 distance from the bottom
YPosFromBot2 = $81				;player 2 distance from the bottom
VisiblePlayer1Line = $82		;player 1 box
VisiblePlayer2Line = $83		;player 2 box
SprintCharge = $84				;how long player 1 can boost
Timer = $85						;how long before boost recharges
ItPlayer = $86					;Says which player is it
Safety = $87					;safety timer after touch
BotXDirection = $88				;the direction the bot player is moving in x axis
SwapTimer = $89					;the timer that decides when the bot swaps x direction

;Required start up stuff
Start
	SEI							;disables interupts
	CLD 						;clear BCD math bit	
	LDX #$FF 					;sets X where we want the stack pointer (top of the stack)	
	TXS							;sets the stack pointer to the top (whatever's in x register)
	LDA #0 						;sets accumulator to 0, used to reset X in ClearMem

;clears the memory	
ClearMem 
	STA 0,X						;store whatever is in the accumulator to X offset by 0	
	DEX							;decrease x by 1	
	BNE ClearMem 				;if x doesn't equal 0, go to ClearMem	

;sets the characteristics of player 1
BuildPlayers
	;player 1 always starts as it
	LDA #$43					;loads accumulator with the color red
	STA COLUP0					;sets player one to be red
	LDA #$20					;loads the accumulator with the size of player1
	STA NUSIZ0					;sets the size of player 1
	LDA #80						;loads the accumulator with the starting y position of player 1
	STA YPosFromBot1			;set the Initial Y Position of player 1
	LDA $1 						;makes player 1 it
	STA ItPlayer 				;stores it at itplayer memory

	;sets the characteristics of player 2
	LDA #2 						;
	STA ENAM1  					;enable it
	LDA #$70 					;loads blue to the accumulator
	STA COLUP1 					;color bot blue
	LDA #$20					;loads the accumulator with a quad width
	STA NUSIZ1					;make the bot quadwidth 
	LDA #40						;loads the accumulator with the starting y position of player 2
	STA YPosFromBot2			;set the Initial Y Position of player 1

	;sets the stage, timers, and sprint remaining
	LDA #$00 					;loads accumulator with the color black
	STA COLUBK					;start with black background
	LDA $20;					;loads the accumulator with a full sprint charge
	STA SprintCharge			;sets the sprint value to the accumulator
	LDA $0 						;loads the accumulator with empty charge timer
	STA Timer 					;sets the sprint charge timer to 0
	LDA $0 						;loads the accumulator with empty safety timer
	STA Safety 					;sets the safety timer to 0
	LDA $0 						;loads the accumulator with 0, start swaptimer
	STA SwapTimer 				;sets the swaptimer to 0
	LDA #$10 					;loads the accumulator with the left direction
	STA BotXDirection 			;set the bots direction to move left

;Main loop that all the game activities take place inside.
MainLoop
	;VSYNC the screen and atari
	LDA #2
	STA VSYNC	
	STA WSYNC	
	STA WSYNC 	
	STA WSYNC	
	LDA #43	
	STA TIM64T	
	LDA #0
	STA VSYNC 	

;checks down, up, left, right and does a BIT compare to see if 
;a certain direction is pressed, and then move the player in 
;that direction
	LDA #%00010000	    		;binary pattern for down button
	BIT SWCHA 					;
	BNE SkipMoveDown 			;branch if down is not pressed
	INC YPosFromBot1 			;double move down, double moving helps
	INC YPosFromBot1 			;player keep pace with the bot.
SkipMoveDown 					
	LDA #%00100000				;binary pattern for up button
	BIT SWCHA 					;
	BNE SkipMoveUp 				;branch if up is not pressed
	DEC YPosFromBot1 			;double move up
	DEC YPosFromBot1 			;
SkipMoveUp
								;left vs right speeds
								;left 1-7 slow to fast
								;right 8-F fast to slow
	LDX #0						;assume horizontal movement is 0
	LDA #%01000000				;binary pattern for left button
	BIT SWCHA  					;
	BNE SkipMoveLeft 			;branch if left not pressed
	LDX #$10					;a 1 in the left digit means go left... move left
SkipMoveLeft 
	LDA #%10000000				;binary pattern for right button
	BIT SWCHA 					;
	BNE SkipMoveRight 			;branch if right not pressed
	LDX #$F0					;a F in the left digit means go right... move right
SkipMoveRight
	STX HMM0					;set the x move for player 1

	
;Boost managing. Checks if the boost button is pressed and if 
;the player is moving in a direction, if the player is moving and 
;pressing the boost button, move them faster. When boost is pressed
;the sprint charge is depleted. If there is no sprint charge the player
;cannot boost.
	LDA INPT4					;read button input
	BMI ButtonNotPressed		;skip if button not pressed

	LDA $0 						;
	CMP SprintCharge			;Check if the sprint charge is 0
	BEQ EndClock				;if zero branch and skip boost section

	LDA $0 						;
	CMP SprintCharge 			;check if sprint charge has gone negative (0-sprintcharge)
	BPL EndClock 				;if sprint is negative branch and skip boost section

	LDA #%00010000	    		;binary pattern for down button
	BIT SWCHA 					;
	BNE SkipMoveDownBoost 		;branch if down is not pressed
	INC YPosFromBot1 			;4x move down, super speed
	INC YPosFromBot1 			;
	INC YPosFromBot1 			;
	INC YPosFromBot1 			;
	DEC SprintCharge 			;decrement the sprint charge 
SkipMoveDownBoost 

	LDA #%00100000				;binary pattern for up button
	BIT SWCHA 					;
	BNE SkipMoveUpBoost 		;branch if up is not pressed
	DEC YPosFromBot1 			;4x move up, super speed
	DEC YPosFromBot1 			;
	DEC YPosFromBot1 			;
	DEC YPosFromBot1 			;
	DEC SprintCharge 			;decrement the sprint charge
SkipMoveUpBoost

	LDX #0						;sets horizontal movement to 0 if player is not moving

	LDA #%01000000				;binary pattern for left button
	BIT SWCHA 
	BNE SkipMoveLeftBoost		;branch if not left button
	LDX #$30					;move the player left, much faster
	DEC SprintCharge			;decrement the remaining sprint charge
SkipMoveLeftBoost 

	LDA #%10000000				;binary pattern for right button
	BIT SWCHA 
	BNE SkipMoveRightBoost 		;branch if not right button
	LDX #$D0					;move the player right, much faster
	DEC SprintCharge 			;decrement the remaining sprint charge
SkipMoveRightBoost

	STX HMM0 					;actually moves the player after the boost

	;following 2 lines are a magic parlour trick the change the screen colour
	;I didn't have the heart to fully take them out.
	;LDA YPosFromBot1			;must be pressed, get YPos
	;STA COLUBK					;load into bgcolor
ButtonNotPressed

;recharges SprintCharge after 200 cycles through the main loop.
;I used the loop cycles over the timer function because the
;game's processing never really gets any more difficult thus 
;doesn't vary too much.
Clock 
	INC Timer 					;increment timer, another interation through mainloop
	LDA $200 					;loads acumulator with 200
	CMP Timer 					;check if timer is equal to 200
	BNE EndClock 				;if not equal skip sprint recharge as player has not earned it
	LDA $20 					;if equal load accumulator with 20 to check if sprint charge is full
	CMP SprintCharge
	BEQ EndClock 				;if sprint charge is already full skip recharge
	LDA $20 					;load accumulator with 20
	STA SprintCharge 			;recharge sprintcharge to full
	LDA $0 						;load accumulator with 0
	STA Timer 					;sets timer back to 0 to begin counting to next recharge
EndClock

;handles the bots left and right movements
;because the Atari doesn't track the exact horizontal position, I
;made the horizontal movement "seemingly" random. The bot will switch
;back and forth between left and right.
SwapX
	LDA $7500 					;loads accumulator with 7500, the bot swaps directions ever 7500 cycles
	CMP SwapTimer 				;compares 7500 to swaptimer
	BNE EndSwapX 				;if swap timer does not equal 7500 branch and do not swap directions
	LDA #$10 					;if timer is 7500, load accumulator with Hex 10
	CMP BotXDirection 			;check if the bot is moving left (hex 10)
	BEQ SwapRight 				;if the bot is moving left branch, make the bot move right
SwapLeft
	LDA #$10 					;if bot is moving right, load 10 into accumulator (left)
	STA BotXDirection 			;set the memory address for the bots direction to left
	STA HMM1					;start moving the bot in that direction
	LDA $0 						;load accumulator with 0
	STA SwapTimer 				;reset the swap timer
	JMP EndSwapX 				;skip to the end of the direction swapping
SwapRight
	LDA #$F0 					;if the bot is moving left, load F0 into accumulator (right)
	STA BotXDirection 			;set the memory address for the bot's direction to right
	STA HMM1 					;start moving the bot right
	LDA $0 						;load accumulator with 0
	STA SwapTimer 				;reset the swap timer
EndSwapX
	INC SwapTimer 				;count another interation of the loop, used for bot's x-axis direction

;handles the collisions, checks if the 2 players have tagged each other
;if the players have collided, swap who is it. Depending on your emulator,
;the collisions may bug out and not register. 
CollisionDetection
	INC Safety 					;increment safety timer
	LDA $75 					;load accumulator with 75
	CMP Safety 					;check if safety equals 75
	BPL NoCollision 			;if (75-Safety)>0 then recently tagged player is still safe, skip collision
	LDA #%01000000 				;loads accumulator with collision check pattern
	BIT CXPPMM					;checks if M1 has collied with M2 
	BEQ NoCollision				;skip if no collision
	LDA $1 						;load accumulator with 1 
	CMP ItPlayer 				;check if the it player is player 1 (human)
	BEQ Player1TouchPlayer2 	;branch if human player has tagged bot play
Player2TouchPlayer1
	LDA #$70 					;set player 2 to not it, blue
	STA COLUP1 					;colors player 2 to blue
	LDA #$43 					;set player 1 to it, red
	STA COLUP0 					;color player 1 to red
	LDA $1 						;loads accumulator with 1, says player 1 is it
	STA ItPlayer 				;makes player 1 it
	LDA $0 						;loads accumulator with 0
	STA Safety 					;sets safety timer to 0, player 2 can't be tagged for 75 cycles
	JMP NoCollision 			;jump to the end of the collision handler
Player1TouchPlayer2
	LDA #$43 					;set player 2 to it, red
	STA COLUP1 					;colors player 2 to red
	LDA #$70 					;set player 1 to not it, blue
	STA COLUP0 					;colors player one blue
	LDA $2 						;loads accumulator with 2, says player 2 is it
	STA ItPlayer 				;makes player 2 it
	LDA $0 						;loads accumulator with 0
	STA Safety 					;sets safety timer to 0, player 1 can't be tagged for 75 cycles
NoCollision
	STA CXCLR					;reset the collision detection for next time

;handles the ai when the player is it
StartAI
	LDA $1 						;loads accumulator with 1
	CMP ItPlayer 				;compares it player to one, checks if player 1 is it
	BNE StartItAI 				;if player 1 is not it, bot is it and branch to StartItAI
StartNotItAI
	LDA YPosFromBot2 			;load accumulator with the bot y position 
	CMP YPosFromBot1 			;compare the bot's y position to the players y position
	BPL AIRunAwayUp 			;if bot's y > player's y, branch to AIRunAwayUp
AIRunAwayDown
	DEC YPosFromBot2 			;bot is bellow player, keep moving the bot down
	JMP EndItAI 				;skip the rest of the AI code
AIRunAwayUp
	INC YPosFromBot2 			;if bot is above the player, keep moving the bot up
	JMP EndItAI	 				;skip the rest of the AI code
EndNotItAI

;handles the ai when the bot is it
StartItAI
	LDA YPosFromBot2 			;loads the accumulator with the bot's y position
	CMP YPosFromBot1 			;compare bot's y postion to player's y position
	BMI AIRunTowardsUp 			;if bot is bellow player, branch to AIRunTowardUp
AIRunTowardsDown
	DEC YPosFromBot2 			;bot is above player, Dec bot's y postion towards player
	JMP EndItAI 				;skip the rest of the AI code
AIRunTowardsUp
	INC YPosFromBot2			;bot is bellow the player, inc bot's y position toward the player
EndItAI	
	LDA BotXDirection 			;load the bot's x direction
	STA HMM1 					;have the bot move in that x direction
EndAI

;resyncs the screen, I'm not really sure how it works
WaitForVblankEnd
	LDA INTIM					
	BNE WaitForVblankEnd		
	LDY #191 					
	STA WSYNC 					
	STA VBLANK  				
	STA WSYNC					
	STA HMOVE 					

ScanLoop 
	STA WSYNC 	

;handles all the player and bot drawing graphics

;draws the player
CheckActivatePlayer1
	CPY YPosFromBot1 			;compares y position of player to y register
	BNE SkipActivatePlayer1 	;branch if not equal, player is activated, don't activate the player
	LDA #8 						;load acumulator with 8
	STA VisiblePlayer1Line 		;active the player graphic
SkipActivatePlayer1
	LDA #0						;loads accumulator with 0
	STA ENAM0 					;turn player off 
	LDA VisiblePlayer1Line  	;load accumulator with the player line, 
	BEQ FinishPlayer1 			;if player line isn't 0, draw it
IsPlayer1On	
	LDA #2						;load accumulator with 2
	STA ENAM0 					;remove the extra pieces of the player line, making it a square, turn player on
	DEC VisiblePlayer1Line 		;decrement where the player line is being removed
FinishPlayer1

;draws the bot
CheckActivatePlayer2
	CPY YPosFromBot2 			;compare the y position of the bot to the y reguster
	BNE SkipActivatePlayer2 	;branch if not equal, bot is activated, don't activate the bot
	LDA #8 						;load accumulator with 8
	STA VisiblePlayer2Line 		;activate the bot's graphic
SkipActivatePlayer2
	LDA #0						;loads the accumulator with 0
	STA ENAM1 					;turn the bot off
	LDA VisiblePlayer2Line 		;loads the accumulator with the bot line
	STA ENAM1 					;turns the bot on
	BEQ FinishPlayer2 			;this recycles the player compare for drawing the box
IsPlayer2On	
	LDA #2						;loads accumulator with 2
	STA ENAM1 					;removes the extra pieces of the bot line, making it a square, turn bot on
	DEC VisiblePlayer2Line  	;decrement where the bot line is being removed
FinishPlayer2

;more syncing stuff that I don't fully understand
	DEY		
	BNE ScanLoop	

	LDA #2		
	STA WSYNC  	
	STA VBLANK 	
	LDX #30		
OverScanWait
	STA WSYNC
	DEX
	BNE OverScanWait
	JMP  MainLoop      
 
	org $FFFC
	.word Start
	.word Start