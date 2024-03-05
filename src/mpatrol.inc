

***    
*** BUILD OPTIONS
***

	.ifdef	RELEASE
    OPT_DISABLE_BG_LAYER=0            | LEAVE AT 0!!!
    OPT_DISABLE_SPRITES=0             | LEAVE AT 0!!!
    OPT_START_SCORE=0                 | LEAVE AT 0!!!
	OPT_SKIP_INTRO_SCREEN=0           | LEAVE AT 0!!!
	OPT_SKIP_GAME_DEMO=0              | LEAVE AT 0!!!
	.else
	
    * hardware options
    OPT_DISABLE_BG_LAYER=0
    OPT_DISABLE_SPRITES=0
   
	* permanent cheats/hacks to test game
    * score is BCD format
	* all options are zeroed for release
    OPT_START_SCORE=0x0
	OPT_SKIP_INTRO_SCREEN=0
	OPT_SKIP_GAME_DEMO=0

	.endif
	
***
*** end of BUILD OPTIONS
***




* sound ordinals
                    

	.equ	STOP_LOOP_SND,             0
	.equ	EXPLOSION_SND,	           1
	.equ	BOMB_EXPLOSION_SND,        2
	.equ	PING_SND,                  3
	.equ	UFO_EXPLOSION_SND,         4
	.equ	SHOOT_SND,                 5
	.equ	COIN_SND,                  6
	.equ	JEEP_JUMP_SND,             7
	.equ	SPACE_PLANT_SND,           8
	.equ	UFO_ATTACK_SND,            9
	.equ	MAIN_TUNE_SND,             10
	.equ	COURSE_START_SND,          11
	.equ	SECTION_END_SND,           12
	.equ	COURSE_END_SND,            13
	.equ    GAME_OVER_SND,              14
	.equ	JEEP_EXPLOSION_SND,        15

    
