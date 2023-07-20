; #######################################################################
; Grupo_14
; André Correia ist1102666
; Bernardo Augusto ist1102820
; Guilherme Viana ist1102839
; #######################################################################

; **************
; *  CONSTANTS *
; **************

DISPLAYS                EQU 0A000H      ; 7 segment display address
KEY_ROW                 EQU 0C000H      ; address of the keyboard rows
KEY_COL                 EQU 0E000H      ; address of the keyboard columns
ROW                     EQU 16          ; row to test (initial row before SHR)
MASK                    EQU 0FH         ; to isolate the 4bits of least weight, when reading the keyboard columns

START_ENERGY            EQU 105         ; initial energy value
BUFF_MOVE               EQU 1000        ; delay for key pressing

DEFINE_ROW      		EQU 600AH       ; address of the command to define the row
DEFINE_COL       		EQU 600CH       ; address of the command to define the column
DEFINE_PIXEL    		EQU 6012H       ; address of the command to draw a pixel
DELETE_WARN     		EQU 6040H       ; address of the comand that deletes the "no scenery" warning
DELETE_SCREEN		    EQU 6002H       ; address of the command to delete all drawn pixels
SELC_BACKGROUD          EQU 6042H       ; address of the command to select a background image
PLAY_SOUND              EQU 605AH       ; address of the command to play audio
STOP_SOUNDS             EQU 6068H       ; address of the command to stop all audio
START_SOUNDS            EQU 6064H       ; address of the command to start all audio
SELECT_SCREEN           EQU 6004H       ; address of the command to select a pixel screen
SELC_FRONTAL            EQU 6046H       ; address of the command to select the frontal scenery
DEL_FRONTAL             EQU 6044H       ; address of the command to delete the frontal scenery

START_POS               EQU 30          ; starting column of the player
WIDTH		            EQU	5		    ; sprite width
HEIGHT                  EQU 5           ; sprite height
ENEMYCOL		        EQU	30			; enemy column
SHIPROW                 EQU 27          ; player ship row
MAX_ROW                 EQU 10          ; number of the rightmost row an object can occupy
SCREENSIZE              EQU 59          ; x axis size of the screen (-5)
SCREEN_Y                EQU 27          ; y axis size of the screen (-5)
MIN_MISSILE_Y           EQU 15          ; highest position before missile despawns

SIZE_2                  EQU 3           ; first row for sprites to take size 2
SIZE_3                  EQU 6           ; first row for sprites to take size 3
SIZE_4                  EQU 9           ; first row for sprites to take size 4
SIZE_5                  EQU 12          ; first row for sprites to take size 5

; *********
; * COLOR *
; *********

BLANK                   EQU 00000H      ; transparent
DBLUE                   EQU 0F6AFH      ; dark blue
DORNG                   EQU 0FF70H      ; dark orange
DRKRD                   EQU 0FC00H      ; dark red
DYLLW                   EQU 0FFE4H      ; dark yellow
GREEN                   EQU 0F490H      ; green
LGTRD                   EQU 0FF55H      ; light red
LORNG                   EQU 0FFA4H      ; light orange
LYLLW                   EQU 0FFF6H      ; light yellow
PURPL                   EQU 0FF6FH      ; purple
WHITE    		        EQU	0FFFFH      ; white


; #######################################################################
;                               DATA ZONE
; #######################################################################

PLACE		0600H	

; *********
; * STACK *
; *********

pilha:
	STACK 200H				; reserved space for the stack
;						
SP_initial:				

; *********************************
; * TABLE OF INTERRUPTION ROUTINES *
; *********************************

tab:
	WORD rot_int_0			; interruption routine for the enemies
	WORD rot_int_1			; interruption routine for the missile
	WORD rot_int_2			; interruption routine for the energy

; ***********
; * SPRITES *
; ***********

DEF_EXPLOSION:               ; explosion when a ship is destroyed
    WORD        WIDTH
    WORD        HEIGHT

    WORD        BLANK, LGTRD, BLANK, LGTRD, BLANK,
                LGTRD, BLANK, LORNG, BLANK, LGTRD,
                BLANK, LORNG, LYLLW, LORNG, BLANK,
                LGTRD, BLANK, LORNG, BLANK, LGTRD,
                BLANK, LGTRD, BLANK, LGTRD, BLANK

DEF_MISSILE:                 ; player shot
    WORD        1
    WORD        1

    WORD        PURPL

DEF_ALLY1:                  ; ally (size 1)
    WORD        1
    WORD        1

    WORD        DYLLW

DEF_ALLY2:                  ; ally (size 2)
    WORD        2
    WORD        2

    WORD        DYLLW, DYLLW, 
                DYLLW, DYLLW

DEF_ALLY3:                  ; ally (size 3)
    WORD        3
    WORD        3

    WORD        DORNG, BLANK, DORNG,
                WHITE, GREEN, WHITE,
                BLANK, WHITE, BLANK

DEF_ALLY4:                  ; ally (size 4)
    WORD        4
    WORD        4

    WORD        DORNG, BLANK, BLANK, DORNG,
                WHITE, GREEN, GREEN, WHITE,
                BLANK, WHITE, WHITE, BLANK,
                BLANK, WHITE, WHITE, BLANK

DEF_ALLY5:                  ; ally (size 5)
    WORD        WIDTH
    WORD        HEIGHT

    WORD        DORNG, BLANK, BLANK, BLANK, DORNG,
                WHITE, WHITE, GREEN, WHITE, WHITE,
                BLANK, GREEN, GREEN, GREEN, BLANK,
                BLANK, WHITE, GREEN, WHITE, BLANK,
                BLANK, BLANK, WHITE, BLANK, BLANK

DEF_ENEMY1:                 ; enemy (size 1)
    WORD        1
    WORD        1

    WORD        DYLLW

DEF_ENEMY2:                 ; enemy (size 2)
    WORD        2
    WORD        2

    WORD        DYLLW, DYLLW,
                DYLLW, DYLLW

DEF_ENEMY3:                 ; enemy (size 3)
    WORD        3
    WORD        3

    WORD        DORNG, BLANK, DORNG, 
                DRKRD, DRKRD, DRKRD, 
                BLANK, DRKRD, BLANK

DEF_ENEMY4:                 ; enemy (size 4)
	WORD		4
    WORD        4

    WORD        DORNG, BLANK, BLANK, DORNG, 
                DRKRD, DRKRD, DRKRD, DRKRD, 
                BLANK, DRKRD, DRKRD, BLANK, 
                BLANK, DRKRD, DRKRD, BLANK

DEF_ENEMY5:					; enemy (size 5)
	WORD		WIDTH
    WORD        HEIGHT

	WORD		DORNG, BLANK, BLANK, BLANK, DORNG,
                DRKRD, DRKRD, DRKRD, DRKRD, DRKRD,
                BLANK, DRKRD, DBLUE, DRKRD, BLANK,
                BLANK, BLANK, DRKRD, BLANK, BLANK,
                BLANK, BLANK, DRKRD, BLANK, BLANK

DEF_SHIP:					; player ship
	WORD		WIDTH
    WORD        HEIGHT

	WORD		BLANK, BLANK, DBLUE, BLANK, BLANK,
                BLANK, DBLUE, DBLUE, DBLUE, BLANK,
                DBLUE, DBLUE, DBLUE, DBLUE, DBLUE,
                BLANK, DORNG, DYLLW, DORNG, BLANK,
                BLANK, BLANK, DORNG, BLANK, BLANK

; ******************************************************
; * ENEMIES AND ALLIES                                 * 
; * VARIABLES TO STORE ENEMY/ALLY DATA DURING GAMEPLAY *
; ******************************************************

SHIP1:
    WORD        1       ; layer for the ship to be drawn in   
    WORD        9       ; current enemy or ally column
    WORD        0       ; current enemy or ally row
    WORD        0       ; type (0 for enemy, 1 for ally, 2 for exploding, 3 for destroyed)

SHIP2:
    WORD        2       ; layer for the ship to be drawn in 
    WORD        25      ; current enemy or ally column
    WORD        0       ; current enemy or ally row
    WORD        0       ; type (0 for enemy, 1 for ally, 2 for exploding, 3 for destroyed)

SHIP3:
    WORD        3       ; layer for the ship to be drawn in 
    WORD        33      ; current enemy or ally column
    WORD        0       ; current enemy or ally row
    WORD        0       ; type (0 for enemy, 1 for ally, 2 for exploding, 3 for destroyed)

SHIP4:
    WORD        4       ; layer for the ship to be drawn in 
    WORD        49      ; current enemy or ally column
    WORD        0       ; current enemy or ally row
    WORD        0       ; type (0 for enemy, 1 for ally, 2 for exploding, 3 for destroyed)

; *************
; * VARIABLES *
; *************

SHIPCOL:                WORD    16          ; player ship column
ENERGY:                 WORD    100         ; current energy
MISSILE_ROW:            WORD    0           ; row with active missile (0 if theres no missile)
MISSILE_COL:            WORD    0           ; column with active missile


; #######################################################################
;                           INITIALIZATIONS
; #######################################################################

PLACE      0		

; *********
; * STACK *
; *********

    MOV  SP, SP_initial                 ; stack initialization

; ****************
; * START SCREEN *
; ****************

    MOV R5, 0
    MOV [DISPLAYS], R5                  ; puts the display at 0

    MOV R5, 0         
    MOV [SELC_BACKGROUD], R5	        ; selects the background for the start menu

    start_screen:

    MOV R5, 1
    MOV [STOP_SOUNDS], R5               ; stops all sounds

    MOV R5, 0
    MOV [SELECT_SCREEN], R5             ; sets the background
    MOV [DELETE_SCREEN], R5	            ; deletes all drawn pixels

    start_screen_loop:
    MOV R5, KEY_ROW
    MOV R1, 8H
    MOVB [R5], R1
    MOV R5, KEY_COL
    MOVB R0, [R5]
    MOV R5, MASK
    AND R0, R5
    MOV R5, 0
    CMP R0, 1
    JNZ start_screen_loop
    
    MOV R5, 7
    MOV [PLAY_SOUND], R5
    MOV [START_SOUNDS], R5


; ********************
; * SCREEN AND VOLUME*
; ********************

    MOV R5, 1
    MOV [SELC_BACKGROUD], R5            ; selects the games background
    MOV R5, 100H
    MOV [DISPLAYS], R5                  ; writes the default energy value in the display
    MOV R5, 0
    MOV [MISSILE_ROW], R5               ; writes the default energy value in the display

; *************
; * VARIABLES *
; *************

    MOV R5, START_POS
    MOV [SHIPCOL], R5                   ; sets the default value for SHIPCOL
    MOV R5, START_ENERGY
    MOV [ENERGY], R5                    ; sets the default value for ENERGY


; ******************************
; * PLAYER SHIP INITIALIZATION *
; ******************************

    MOV R5, 0
    MOV [SELECT_SCREEN], R5             ; player ship screen layer
    MOV R6, [SHIPCOL]                   ; player ship column
    MOV R10, SHIPROW                    ; player ship row
    MOV	R4, DEF_SHIP		            ; player ship sprite
    CALL draw_sprite                    ; draws the player ship's first position

; *******
; * BTE *
; *******

    MOV  BTE, tab			            ; initializes the BTE (exception table)

; *****************
; * INTERRUPTIONS *
; *****************

    EI0					                ; allows interruptions of type 0
	EI1					                ; allows interruptions of type 1
	EI2					                ; allows interruptions of type 2
    EI					                ; allows interruptions (general)

; #######################################################################
;                           MAIN CODE
; #######################################################################

cycle:
    MOV  R1, ROW            ; initializes reading of the keyboard row

wait_key:                   ; cycle that waits for a key to be pressed
    CMP R1, 1               ; if the last row checked was the last row of the keyboard
    JNZ out                 ; restarts the cycle at the first row
    MOV R1, ROW             ; sets the first row
out:
    SHR R1, 1               ; moves to the next row
    MOV R2, 0               ; initialization of the cycle counter
    MOV R5, KEY_ROW
    MOVB [R5], R1           ; writes on exit peripheral
    MOV R5, KEY_COL
    MOVB R0, [R5]           ; reads from entry peripheral
    MOV R5, MASK
    AND  R0, R5             ; removes bits other than 0-3
    MOV R5, 0
    CMP  R0, 0              ; is there a pressed key?
    JZ   wait_key           ; if no key is being pressed then it repeats

key_pressed:                ; this cycle waits for no key to be pressed
    CMP R2, -1              ; safeguard check to stop overflowing in the pressed buffer
    JNZ buff_check      
    MOV R2, 1
    buff_check:
    CALL check_key
    ADD R2, 1               ; increments the pressed buffer by 1
    MOV R5, KEY_ROW
    MOVB [R5], R1           ; writes on exit peripheral
    MOV R5, KEY_COL
    MOVB R0, [R5]           ; reads from entry peripheral
    MOV R5, MASK
    AND  R0, R5             ; removes bits other than 0-3
    MOV R5, 0
    CMP  R0, 0              ; is there a pressed key?
    JNZ  key_pressed        ; if there is still a key being pressed it waits until there isn't one
    JMP  cycle              ; repeats cycle

;###############################################################################################
; CHECK_KEY - Identifies the row with the key being pressed and executes the needed sub-routine
;
; Arguments:    R1 - row
;               R0 - column
;               R2 - cycle counter
;###############################################################################################

check_key:
    DI
    CMP R2, 0          ; if cycle counter isn't 0 it skips 
    JNZ not_row_4      ; skips all row 4 commands (none allow pressing)

    MOV R5, 8H
    CMP R1, R5         ; checks if the key pressed is part of the fourth keyboard row
    JNZ not_row_4      ; if not jumps
    CALL row_4         ; if it is calls the subroutine to handle these commands
    not_row_4:

    CMP R1, 1H         ; checks if the key pressed is part of the first keyboard row
    JNZ not_row_1      ; if not jumps
    CALL row_1         ; if it is calls the subroutine to handle these commands
    not_row_1:
    
    EI
    RET

;##################################################################################################
; ROW_1 - Identifies the pressed key and executes the needed routines for the first row
;
; Arguments:    R0 - column
;               R2 - cycle counter
;
; registration usage:
;       R0 - column
;       R2 - cycle counter
;       R5 - buffer setting
;       R7 - player movement
;
;##################################################################################################

row_1:
    PUSH R7
    PUSH R5

    MOV R5, BUFF_MOVE   ; gets the pressed buffer setting
    CMP R2, R5          ; compares to current buffer
    JLT smaller_buff    ; if smaller
    SUB R2, R5          ; subtracts the setting value from the current buffer
    smaller_buff:         
    CMP R2, 0           ; if the pressed buffer is different than 0
    JNZ not_right       ; cancels the movement commands

    CMP R0, 1H          ; if first key (0) 
    JNZ not_left        ; jumps if false
    MOV R7, -1          ; sets movement to left
    CALL move           ; moves the player

    not_left:
    CMP R0, 2H          ; if third key (2) 
    JNZ not_shoot       ; jumps if false
    CALL shoot          ; shoots a missile

    not_shoot:
    CMP R0, 4H          ; if third key (2) 
    JNZ not_right       ; jumps if false
    MOV R7, 1           ; sets movement to right
    CALL move           ; moves the player

    not_right:
    POP R5
    POP R7
    RET

;################################################################################################
; ROW_4 - Identifies the pressed key and executes the needed routines for the fourth row
;
; Arguments:    R0 - column
;
; registration usage:
;       R0 - column
;
;################################################################################################

row_4:

    CMP R0, 2H                  ; if second key (D)
    JNZ not_pause               ; jumps if false
    CALL pause                  ; pauses the game
    not_pause:

    CMP R0, 4H                  ; if third key (E)
    JNZ not_end                 ; jumps if false
    CALL end                    ; ends the game
    not_end:

    RET

;###################################################################################
; MOVE - Moves the ship
;
; Arguments:   R7 - number corresponding to the desired movement   
;
; registration usage:
;       R4  - player sprite
;       R7  - number corresponding to the desired movement 
;       R6  - player column 
;       R10 - player row 
;
;###################################################################################

move:
    PUSH R6
    PUSH R10
    PUSH R4
    PUSH R7

    MOV R6, 0
    MOV [SELECT_SCREEN], R6     ; selects the pixel screen to draw the ship in

    MOV R6, [SHIPCOL]           ; player ship column
    ADD R6, R7                  ; adds the desired movement 

    CMP R6, 0                   ; if smaller or equal to 0
    JLT hit_border              ; cancels (hits border)

    MOV R8, SCREENSIZE          ; if greater or equal to SCREENSIZE
    CMP R6, R8                  ; cancels (hits border)
    JGT hit_border

    MOV R10, SHIPROW            ; player ship row
    MOV	R4, DEF_SHIP		    ; sprite that defines the ship
    SUB R6, R7                  ; adds the desired movement in order to erase 
    CALL erase_sprite           ; removes the ship in the old position
    ADD R6, R7                  ; readds the desired movement

    MOV [SHIPCOL], R6           ; stores the new player position
    CALL draw_sprite            ; draws the player ship at its new position

    hit_border:
    POP R7
    POP R4
    POP R10
    POP R6
    RET

;##################################################################################################
; SHOOT - shoots a missile from the player
;
; registration usage:
;       R4  - missile sprite
;       R5  - data management
;       R6  - missile column 
;       R10 - missile row 
;
;##################################################################################################

shoot:
    PUSH R5
    PUSH R4
    PUSH R6
    PUSH R10

    MOV R5, [MISSILE_ROW]               ; gets the current missile position
    CMP R5, 0                           ; if its not equal to zero (value when not spawned)
    JNZ in_cooldown                     ; cancels the spawning as its in cooldown
   
    MOV R5, 0                           ; missile moving sound
    MOV [PLAY_SOUND], R5                ; plays missile moving sound

    MOV R5, 0
    MOV [SELECT_SCREEN], R5             ; selects the screen layer for the missile
    MOV R4, DEF_MISSILE                 ; selects the missile sprite
    MOV R10, SHIPROW                    ; gets the players row
    SUB R10, 1                          ; moves to the row right above the player
    MOV R6, [SHIPCOL]                   ; gets the players column
    ADD R6, 2                           ; moves to the middle of the player sprite
    CALL draw_sprite                    ; draws the missile
    MOV [MISSILE_ROW], R10              ; stores the missile row
    MOV [MISSILE_COL], R6               ; stores the missile column
    MOV R6, -5                          ; sets energy to change by -5
    CALL change_energy                  ; decreases energy by 5

    in_cooldown:
    POP R10
    POP R6
    POP R4
    POP R5
    RET

;###################################################################################
; PAUSE - pauses the game
;
; registration usage:
;       R2  - data management 
;
;###################################################################################
pause:

    PUSH R2
    DI
    MOV R5, 5                           ; pause audio
    MOV [PLAY_SOUND], R5                ; plays the pause audio
    MOV R2, 2
    MOV [SELC_FRONTAL], R2              ; selects the pause menu image for the frontal screen 
    CALL wait_pause                     ; waits for the game to resume or restart
    MOV [DEL_FRONTAL], R2               ; deletes the pause menu image from the frontal screen
    MOV R5, 6                           ; unpause audio
    MOV [PLAY_SOUND], R5                ; plays the unpause audio
    EI
    POP R2
    RET

;###################################################################################
; WAIT_PAUSE - loop to pause the game
;
; registration usage:
;       R0  - keyboard columns 
;       R1  - data management
;       R5  - peripheral address
;
;###################################################################################

wait_pause:
    PUSH R5
    PUSH R1
    PUSH R0

wait_pause_loop:
    MOV R5, KEY_ROW
    MOV R1, 8H
    MOVB [R5], R1                       ; writes on exit peripheral
    MOV R5, KEY_COL
    MOVB R0, [R5]                       ; reads from entry peripheral
    MOV R5, MASK
    AND R0, R5                          ; removes bits other than 0-3
    MOV R5, 0
    CMP R0, 2H                          ; is there a pressed key?
    JZ wait_pause_loop                  ; if a key being pressed then it repeats (until user lets go D)
wait_pause_loop1:
    MOV R5, KEY_ROW
    MOV R1, 8H
    MOVB [R5], R1                       ; writes on exit peripheral
    MOV R5, KEY_COL
    MOVB R0, [R5]                       ; reads from entry peripheral
    MOV R5, MASK
    AND R0, R5                          ; removes bits other than 0-3
    MOV R5, 0
    CMP R0, 2H                          ; is D pressed?
    JZ unpause                          ; if no key is being pressed then it repeats (until user presses D)
    CMP R0, 1H                          ; is C pressed?
    JZ restart                          ; if no key is being pressed then it repeats (until user presses D)
    JMP wait_pause_loop1

    restart:
    MOV R5, 0
    MOV [DELETE_SCREEN], R5	            ; deletes all drawn pixels
    MOV [SELC_BACKGROUD], R5            ; shows the start screen 
    CALL reset_ships                    ; resets the enemies and allies
    MOV R5, 2
    MOV [DEL_FRONTAL], R5               ; deletes the pause menu image from the frontal screen

    JMP start_screen

    unpause:
    POP R0
    POP R1
    POP R5
    RET

;###################################################################################
; END - Ends the game
;
; registration usage:
;       R5  - data management 
;
;###################################################################################

end:
    PUSH R5

    DI
    MOV R5, 0
    MOV [DELETE_SCREEN], R5	            ; deletes all drawn pixels
    MOV [SELC_BACKGROUD], R5            ; shows the start screen 
    CALL reset_ships                    ; resets the enemies and allies
    
    POP R5
    JMP start_screen

;###################################################################################
; RESET_SHIPS - Resets the allies and enemies to start
;
; registration usage:
;       R1  - current ship being reset
;       R2  - data management
;       R5  - data management 
;
;###################################################################################

reset_ships:
    
    PUSH R5
    PUSH R2
    PUSH R1

    MOV R5, 0
    MOV R1, SHIP1           
    MOV R2, 9
    MOV [R1+2], R2                      ;sets the column to its starting value
    MOV [R1+4], R5                      ;sets row back to start
    MOV [R1+6], R5                      ;sets type to enemy
    MOV R1, SHIP2
    MOV R2, 25
    MOV [R1+2], R2                      ;sets the column to its starting value
    MOV [R1+4], R5                      ;sets row back to start
    MOV [R1+6], R5                      ;sets type to enemy
    MOV R1, SHIP3
    MOV R2, 33
    MOV [R1+2], R2                      ;sets the column to its starting value
    MOV [R1+4], R5                      ;sets row back to start
    MOV [R1+6], R5                      ;sets type to enemy
    MOV R1, SHIP4
    MOV R2, 49
    MOV [R1+2], R2                      ;sets the column to its starting value
    MOV [R1+4], R5                      ;sets row back to start
    MOV [R1+6], R5                      ;sets type to enemy

    POP R1
    POP R2
    POP R5
    RET

;###################################################################################
; CHANGE_ENERGY - Changes energy value
;
; Arguments:    R6 - amount to add (subtract if negative)
;
; registration usage:
;       R8  - display value (visualy equivalent to decimal in hexadecimal)
;       R9  - value to subtract from the unconverted amount
;       R10 - unconverted amount
;       R11 - current energy
;
;###################################################################################

change_energy:
    PUSH R11
    PUSH R10
    PUSH R9
    PUSH R8

    MOV R11, [ENERGY]                   ; retrieves current energy value
    ADD R11, R6                         ; adds the intended energy
    MOV R9, 100                         ; max energy
    CMP R11, R9                         ; if current energy is above 100
    JGT border_energy                   ; skips and stays at 100

    MOV R8, 0                           ; else sets display value to 0
    CMP R11, 0                          ; if the current energy is 0
    JLE converted                       ; skips conversion as its already done
    
    MOV R10, R11                        ; copies the current energy
    MOV R9, 100                         ; sets to compare to 100
    CMP R10, R9                         ; if smaller 100 continues conversion
    JLT smaller_than_100                ; else sets as 100 and ends
        
    SUB R10, R9                         ; subtracts 100 from the value still to convert
    MOV R9, 100H                        
    ADD R8, R9                          ; adds 100 to the display value

    smaller_than_100:
    MOV R9, 10                          ; sets to compare to 10
    CMP R10, R9                         ; if smaller 10 continues conversion
    JLT smaller_than_10                 ; else sets as 10 and ends

    SUB R10, R9                         ; subtracts 10 from the value still to convert
    MOV R9, 10H         
    ADD R8, R9                          ; adds 10 to the display value
    JMP smaller_than_100

    smaller_than_10:
    CMP R10, 0                          ; if the remainder is 0 ends conversion
    JZ converted
    SUB R10, 1                          ; subtracts 1 from the value still to convert
    ADD R8, 1H                          ; adds 1 to the display value
    JMP smaller_than_10

    converted:
    MOV [DISPLAYS], R8                  ; changes display to the new value
    MOV [ENERGY], R11                   ; stores the new energy value

    CMP R11, 0                          ; if energy greater than 0
    JGT energy_changed                  ; continues the game
                                        ; else game over
    DI
    MOV R5, 0
    MOV [DELETE_SCREEN], R5	            ; deletes all drawn pixels
    MOV R5, 4                           ; start screen
    MOV [SELC_BACKGROUD], R5            ; shows the start screen 
    CALL reset_ships                    ; resets the enemies and allies
    MOV R5, 4                           ; no energy audio
    MOV [PLAY_SOUND], R5                ; plays the no energy audio
    JMP start_screen

    JMP energy_changed

    border_energy:
    MOV R5, 100H
    MOV [DISPLAYS], R5                  ; changes display to the new value
    MOV R5, 100
    MOV [ENERGY], R5                    ; stores the new energy value

    energy_changed:
    POP R8
    POP R9
    POP R10
    POP R11
    RET

;###################################################################################
; SHIP_MOVER -  Moves the enemies and allies one row down
;
; Arguments:    R1 - address for the selected ship
;
; registration usage:
;       R1  - address for the selected ship
;       R3  - selected ship type
;       R4  - sprite selecting
;       R5  - data management
;       R6  - selected ship column
;       R10 - selected ship row
;       R11 - energy
;
;###################################################################################

ship_mover:

    PUSH R1
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R10
    PUSH R11

; *******************
; * data collection *
; *******************
    MOV R11, R1                     ; copies start address
    MOV R5,  [R1]                   ; gets the layer of the ship
    MOV [SELECT_SCREEN], R5         ; selects the pixel screen for the ship to be drawn in
    MOV R6,  [R1+2]                 ; ship column (R6)
    MOV R10, [R1+4]                 ; ship row    (R10)

; ********************
; * erase old sprite *
; ******************** 

    MOV R4 , DEF_ENEMY5             ; selects a large sprite to delete any size
    CALL erase_sprite               ; deletes the old sprite

; *************************
; * new sprite processing *
; ************************* 

    ADD R10, 1                      ; moves to the next row
    MOV [R1+4], R10                 ; saves the new row in storage

    MOV R5, 32                      ; last row in the screen
    CMP R10, R5                     ; if after the last row
    JGE needs_respawn               ; respawns on top
    JMP no_respawn                  ; else moves down 1 row

    destroyed:                      ; if the ship was destroyed 
    MOV R5, 0                       ; sets type to 0
    MOV [R1+6], R5                  ; saves the new type in storage
                                    ; then respawns

    needs_respawn:
    CALL respawn                    ; respawns

    no_respawn:                     
    MOV R3, [R1+6]                  ; ship type
    CMP R3, 0                       ; if enemy
    JZ enemy_sprite_finder          ; selects an enemy sprite
    CMP R3, 1                       ; if ally
    JZ ally_sprite_finder           ; selects an ally sprite
    CMP R3, 2                       ; if exploded
    JZ exploded                     ; selects the exploding settings
    CMP R3, 3                       ; if destroyed (after exploding)
    JZ destroyed                    ; resets type and respawns

    exploded:
    MOV R5, 3                       ; explosion audio
    MOV [PLAY_SOUND], R5            ; plays the explosion audio
    MOV	R4, DEF_EXPLOSION           ; selects the explosion sprite
    SUB R10, 1                      ; reverts the row advance
    MOV [R1+4], R10                 ; saves the new row in storage
    MOV R5, 3                       ; sets type to destroyed
    MOV [R1+6], R5                  ; stores new type in storage
    JMP size_found                  ; found the sprite to draw

    enemy_sprite_finder:
    MOV	R4, DEF_ENEMY1		        ; defines the sprite as enemy of size 1
    
    MOV R7, SIZE_2                  ; gets the first size 2 row
    CMP R10, R7                     ; if before size 2 rows
    JLE size_found                  ; concludes sprite selection
    MOV	R4, DEF_ENEMY2		        ; else defines the sprite as enemy of size 2

    MOV R7, SIZE_3                  ; gets the first size 3 row
    CMP R10, R7                     ; if before size 3 rows
    JLE size_found                  ; concludes sprite selection
    MOV	R4, DEF_ENEMY3		        ; else defines the sprite as enemy of size 3

    MOV R7, SIZE_4                  ; gets the first size 4 row
    CMP R10, R7                     ; if before size 4 rows
    JLE size_found                  ; concludes sprite selection
    MOV	R4, DEF_ENEMY4		        ; else defines the sprite as enemy of size 4

    MOV R7, SIZE_5                  ; gets the first size 5 row
    CMP R10, R7                     ; if before size 5 rows
    JLE size_found                  ; concludes sprite selection
    MOV	R4, DEF_ENEMY5		        ; else defines the sprite as enemy of size 5
    JMP size_found

    ally_sprite_finder:
    MOV	R4, DEF_ALLY1		        ; defines the sprite as ally of size 1
    
    MOV R7, SIZE_2                  ; gets the first size 2 row
    CMP R10, R7                     ; if before size 2 rows
    JLE size_found                  ; concludes sprite selection
    MOV	R4, DEF_ALLY2		        ; else defines the sprite as ally of size 2

    MOV R7, SIZE_3                  ; gets the first size 3 row
    CMP R10, R7                     ; if before size 3 rows   
    JLE size_found                  ; concludes sprite selection
    MOV	R4, DEF_ALLY3		        ; else defines the sprite as ally of size 3

    MOV R7, SIZE_4                  ; gets the first size 4 row
    CMP R10, R7                     ; if before size 4 rows 
    JLE size_found                  ; concludes sprite selection
    MOV	R4, DEF_ALLY4		        ; else defines the sprite as ally of size 4

    MOV R7, SIZE_5                  ; gets the first size 5 row
    CMP R10, R7                     ; if before size 4 rows 
    JLE size_found                  ; concludes sprite selection
    MOV	R4, DEF_ALLY5		        ; else defines the sprite as ally of size 5


    size_found:
    CALL draw_sprite                ; draws the new ship sprite at updated location

; ****************************
; * player collision checking *
; ****************************

    MOV R5, SHIPROW                     ; stores the players row
    ADD R10, 5                          ; adds the coliding sprites height
    CMP R10, R5                         ; if coliding (top)
    JLE no_collision_player              ; skips as theres no collision
    MOV R5, [SHIPCOL]                   ; gets the players column
    ADD R5, 5                           ; adds the coliding sprites width
    CMP R5, R6                          ; if coliding (left side)
    JLE no_collision_player              ; skips as theres no collision
    ADD R6, 5                           ; moves to the other side of the coliding sprite
    SUB R5, 5                           ; moves to the other side of the player sprite
    CMP R6, R5                          ; if coliding (right side)
    JLE no_collision_player              ; skips as theres no collision

    CMP R3, 0
    JZ enemy_game_over

    MOV R6, 10                          ; moves to argument
    CALL change_energy                  ; sets energy to 100
    MOV R5, 3                           ; sets type to destroyed
    MOV [R1+6], R5                      ; stores new type in storage
    MOV R5, 1                           ; missile moving sound
    MOV [PLAY_SOUND], R5                ; plays missile moving sound
    JMP no_collision_player

    enemy_game_over:
    DI
    MOV R5, 3
    MOV [DELETE_SCREEN], R5	            ; deletes all drawn pixels
    MOV [SELC_BACKGROUD], R5            ; shows the start screen 
    CALL reset_ships                    ; resets the enemies and allies
    MOV R5, 2                           ; GAME OVER enemy sound
    MOV [PLAY_SOUND], R5                ; plays GAME OVER enemy sound
    JMP start_screen

    no_collision_player:
    POP R11
    POP R10
    POP R6
    POP R5
    POP R4
    POP R3
    POP R1
    RET 

;###################################################################################
; RESPAWN -  Respawns a ship
;
; Arguments:    R1  - address for the selected ship
;               R10 - selected ship row
;
; Registration usage:
;       R1  - address for the selected ship
;       R2  - PIN peripheral address
;       R5  - data management
;       R8  - random value from 0-7
;       R10 - selected ship row
;
; Returns:      R10 - new row for the selected ship 
;
;###################################################################################

    respawn:
    PUSH R2
    PUSH R5
    PUSH R8
    

    MOV R5, 8                       ; number of spawn columns in the game
    MOV R2, KEY_COL                 ; takes input from the PIN peripheral
    MOVB R8, [R2]                   ; and puts its value on R8
    SHR R8, 5                       ; moves bits 5-7 to bits 0-2 (a random number 0-7)
    MUL R8, R5                      ; multiplies the random value by the number of spawn columns
    ADD R8, 1                       ; final column value (+1 to center)
    MOV R6, R8                      ; updates the column
    MOV [R1+2], R8                  ; stores the updated column

    MOVB R8, [R2]                   ; puts a random value on R8
    SHR R8, 5                       ; transforms it into a 0-7 value
    CMP R8, 1                       ; if 0 or 1 (25%)
    JLE respawn_ally                ; respawns as an ally
                                    ; else respawns as an enemy
    MOV R5, 0                       ; enemy type
    MOV [R1+6], R5                  ; sets ship type to enemy
    JMP reset_row

    respawn_ally:
    MOV R5, 1                       ; ally type
    MOV [R1+6], R5                  ; sets ship type to ally

    reset_row:
    MOV R10, 0                      ; resets the row of the ship to the start
    MOV [R1+4], R10                 ; stores the new row value in storage

    POP R8
    POP R5
    POP R2
    RET

;###################################################################################
; MISSILE_COLLISION - Calls the routines to check for collisions with the missile
;
; Arguments:    R6  - missile column
;               R10 - missile row
;
; registers usage:
;       R1  - ship to check for collisions
;       R10 - missile row
;
;###################################################################################

missile_collision:
    
    PUSH R10 
    PUSH R1

    MOV R5, 0                           
    MOV R1, SHIP1                       ; check the first ship
    CALL collision_check
    CMP R5, 0                           ; if collided 
    JNZ found_collision                 ; skip to end

    MOV R1, SHIP2                       ; check the first ship
    CALL collision_check
    CMP R5, 0                           ; if collided 
    JNZ found_collision                 ; skip to end

    MOV R1, SHIP3                       ; check the first ship
    CALL collision_check    
    CMP R5, 0                           ; if collided 
    JNZ found_collision                 ; skip to end

    MOV R1, SHIP4                       ; check the first ship
    CALL collision_check
    CMP R5, 0                           ; if collided 
    JNZ found_collision                 ; skip to end

    found_collision:
    POP R1
    POP R10
    RET

;###################################################################################
; COLLISION_CHECK - Checks if the missile collided with an obstacle
;
; Arguments:    R1  - ship to check for collisions
;               R6  - missile column
;               R10 - missile row
;
; registers usage:
;       R1  - ship to check for collisions
;       R2  - column
;       R3  - row
;       R4  - value for the now exploding ship's type
;       R6  - missile column / ship type
;       R10 - missile row
;
; Returns: R5 - collision boolean
;
;###################################################################################

collision_check:
    
    PUSH R6
    PUSH R1
    PUSH R4
    PUSH R2 
    PUSH R3 

    MOV R2, [R1+2]                  ; gets the ship's column
    MOV R3, [R1+4]                  ; gets the ship's row
    ADD R3, 5                       ; moves to the last row of the sprite
    CMP R10, R3                     ; if above player
    JGT no_collision                ; no collision
    CMP R6, R2                      ; if to the left of the missile
    JLT no_collision                ; no collision
    ADD R2, 5                       ; moves to the right side of the sprite
    CMP R6, R2                      ; if to the right of the missile
    JGT no_collision                ; no collision
    MOV R5, 1                       ; marks as having collided
    MOV R4, 2                       ; value for the now exploding ship's type
    MOV R6, [R1+6]                  ; copies the type
    MOV [R1+6], R4                  ; sets the type as exploding

    CMP R6, 0                       ; if was an enemy
    JNZ no_collision                ; skips
    MOV R6, 5                       ; else if was an ally
    CALL change_energy              ; adds 5 to energy

    no_collision:
    POP R3
    POP R2
    POP R4
    POP R1
    POP R6
    RET

;###################################################################################
; ERASE_SPRITE - Deletes sprites from the screen
;
; Arguments:    R10 - row of the sprite to erase
;               R6 - column of the sprite to erase
;               R4 - address of the sprite to erase
; registers usage:
;       R3  - pixel colour (set to 0 to erase)
;       R5  - sprite's width
;       R6  - column
;       R7  - copy of the first column
;       R10 - row
;###################################################################################

erase_sprite:
    PUSH R10
    PUSH R7
    PUSH R6
    PUSH R5
    PUSH R3

    MOV R7, R6                  ; copies the initial column 
	MOV	R5, [R4]			    ; gets the sprite's width
    MOV R9, R5                  ; copies the sprite's width
    MOV	R8, [R4]			    ; gets the sprite's height

delete_pixels:       		    ; loop that deletes the sprite's pixels from the table
	MOV	R3, 0			        ; to erase a pixel, the color of the pixel is set to 0
	MOV  [DEFINE_ROW], R10      ; selects the row
	MOV  [DEFINE_COL], R6	    ; selects the column
	MOV  [DEFINE_PIXEL], R3	    ; changes the color of the pixel on the selected row and column
    ADD  R6, 1                  ; next column
    SUB  R5, 1			        ; one less column to deal with
    JNZ  delete_pixels		    ; continues until it goes through the whole sprite's width
    MOV	 R6, R7                 ; resets the columns
    MOV  R5, R9                 ; resets the row
    ADD  R10, 1                 ; adds 1 to the row
    SUB  R8, 1	                ; reduces the amount of rows left to erase
    JNZ  delete_pixels

    POP R3
    POP R5
    POP R6
    POP R7
    POP R10
    RET

;###################################################################################
; DRAW_SPRITE - Draws a sprite on the screen
;
; Arguments:    R10 - row of the sprite to draw
;               R6 - column of the sprite to draw
;               R4 - address of the sprite to draw
; registers usage:
;       R1  - last row of the screen
;       R3  - color of the next pixel
;       R5  - sprite's width
;       R6  - column
;       R7  - copy of the first column
;       R10 - row
;###################################################################################

draw_sprite:
    PUSH R10
    PUSH R6
    PUSH R7
    PUSH R5
    PUSH R3
    PUSH R1

    MOV R7, R6                  ; copies the initial column
	MOV	R5, [R4]			    ; gets the sprite's width
    MOV R9, R5                  ; copies the sprite's width
    ADD	R4, 2                   ; moves the address to the height
    MOV	R8, [R4]			    ; gets the sprite's height
	ADD	R4, 2			        ; first pixel's color address
    MOV R1, 32                  ; end of the screen

draw_pixels:       		        ; draws the sprite's pixels from the table
	MOV	 R3, [R4]			    ; gets the color of the next pixel from the sprite
	MOV  [DEFINE_ROW], R10	    ; selects a row
	MOV  [DEFINE_COL], R6	    ; selects a column
	MOV  [DEFINE_PIXEL], R3	    ; changes the color of the pixel in the chosen row and column
	ADD	 R4, 2			        ; next pixel color address
    ADD  R6, 1                  ; next column
    SUB  R5, 1			        ; one less column to deal with 
    JNZ  draw_pixels            ; continues until it goes through the whole sprite's length 
    ADD  R10, 1                 ; adds 1 to the row
    CMP  R10, R1                ; if after the end of the screen
    JGE  end_of_screen          ; stops drawing
    MOV	 R6, R7                 ; resets the columns
    MOV  R5, R9                 ; resets the row
    SUB  R8, 1	                ; reduces the amount of rows left to erase
    JNZ  draw_pixels

    end_of_screen:
    POP R1
    POP R3
    POP R5
    POP R7
    POP R6
    POP R10
    RET

;###################################################################################
; ROT_INT_0 -  Moves the enemies and allies one row down
;
; interruption linked to the "meteoros" clock
;
; registers usage:
;       R2  - address for the selected ship
;       R5  - data management
;
;###################################################################################

rot_int_0: 
    
    PUSH R1
    PUSH R5

    MOV R1, SHIP1           ; selects the first defined enemy/ally
    CALL ship_mover         ; processes the next movement for the selected ship
    MOV R1, SHIP2           ; selects the second defined enemy/ally
    CALL ship_mover         ; processes the next movement for the selected ship
    MOV R1, SHIP3           ; selects the third defined enemy/ally
    CALL ship_mover         ; processes the next movement for the selected ship
    MOV R1, SHIP4           ; selects the fourth defined enemy/ally
    CALL ship_mover         ; processes the next movement for the selected ship
    
    POP R5
    POP R1
    RFE

;###################################################################################
; ROT_INT_1 -  Moves the missile up and checks if it collides
;
; interruption linked to the "missil" clock
;
; registers usage:
;       R4  - missile sprite
;       R5  - data management
;       R6  - missile column
;       R10 - missile row
;
;###################################################################################

rot_int_1:
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R10

    MOV R10, [MISSILE_ROW]              ; if the missile is spawned (row different than 0)
    JZ missile_moving                   ; skips the routine

    MOV R5, 0                           ; layer to draw the missile
    MOV [SELECT_SCREEN], R5             ; sets the missiles screen layer
    MOV R4, DEF_MISSILE                 ; gets the missiles sprite
    MOV R6, [MISSILE_COL]               ; gets the missiles column 
    
    CALL erase_sprite                   ; erases the old missile
    SUB R10, 1                          ; moves a row up
    MOV R5, MIN_MISSILE_Y               ; gets the minimum row for the missile
    CMP R10, R5                         ; if smaller
    JLT despawn_missile                 ; despawns the missile
                   
    CALL missile_collision               ; else checks for collisions
    CMP R5, 0                           ; if colided 
    JNZ despawn_missile                 ; despawns the missile

    CALL draw_sprite                    ; else draws the missile at the new position
    MOV [MISSILE_ROW], R10              ; updates the row in storage
    JMP missile_moving                  ; finishes the routine

    despawn_missile:
    MOV R5, 0                           ; sets the row to 0 (meaning unspawned)
    MOV [MISSILE_ROW], R5               ; and saves it in storage

    missile_moving:
    POP R10
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    RFE

;###################################################################################
; ROT_INT_2 -  Decreases the energy by 5
;
; interruption linked to the "energia" clock
;
; registers usage:
;       R6  - amount to change
;
;###################################################################################

rot_int_2:
    PUSH R6

    MOV R6, -5              ; sets energy to change by -5
    CALL change_energy      ; decreases energy by 5

    POP R6
    RFE