# moon patrol
transcode of Moon Patrol arcade version for 68000 machines

Credits:

- jotd: Z80 to 68000 conversion, amiga graphics conversion, amiga sound effects
- no9: amiga music
- ross: help with AGA version and hardware scrolling. Big Kudos!!
- http://www.computerarcheology.com/Arcade/MoonPatrol/ help with reverse-engineering
  (merged their comments & variable names after having started my RE)
- PascalDe73: icon
- mrv2k: boxart
- DamienD: floppy menu

Amiga version (OCS):

- runs on 512K chip/512k fast OCS 68000 Amiga, 25 fps (some slowdowns to expect at times)
- adapted "low detail" graphics, no blue mountain background 
- low sound quality
- no whdload (no need, as it is designed to run on a 1MB OCS machine)

Amiga version (ECS):

- runs on 1MB ECS 68000 Amiga, 25 fps (some slowdowns to expect at times)
- Uses AGA fast DMA mode if found and runs at 50fps on AGA+fastmem
- adapted "low detail" graphics, but will display extra background layer
  if run on a 68020+
- higher sound quality

Amiga version (AGA):

- runs on vanilla A1200 at 50 fps, with smooth scrolling layers
- original colors & graphics
- highest sound quality

Highscores & best times are saved

From whdload, game runs at 55Hz in PAL (close to original 56Hz), and 60Hz in NTSC (slightly faster)
Outside whdload, game runs at 66Hz in NTSC (sorry for this, it's not really designed for NTSC)

Controls:

- joystick left/right: brake/accelerate
- joystick fire: fire
- joystick up/2nd button: jump

To start a game (when game not running):

- insert coin: fire/5
- start/continue game (1 player): up/1
- start/continue game (2 players): down/2

Cheat keys:
- F1: complete section
- F2: complete level
- F4: toggle invincibility