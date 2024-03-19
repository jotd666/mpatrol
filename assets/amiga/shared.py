import collections

jeep_cluts = {0,12}

BB_SHIP = 1
BB_ROLLING_ROCK = 2
BB_WHEEL = 3

def define_sprites(add_sprite_block):

    # thanks to sprite multiplexing, a lot of ground objects can
    # be sprites
    # jeep wheels are made of sprites: 3 sprites needed, 4 color slots
    # so we can allow 4 more sprites!!!
    # missile qualifies (made of 2 sprites)
    # tank qualifies (there can be 2 tanks at once)

    add_sprite_block(1,4,"jeep_part",jeep_cluts,False)
    # all ships are sprites with bob backups
    add_sprite_block(0x42,0x42,"saucer",7,True,bob_backup=BB_SHIP)
    add_sprite_block(0x43,0x44,"hole_making_ship",7,True,mirror=True,flip=True,bob_backup=BB_SHIP)
    add_sprite_block(0x45,0x47,"ovoid_ship",7,True,mirror=True,bob_backup=BB_SHIP)

    add_sprite_block(0x38,0x38,"tank",7,True)
    add_sprite_block(0x3A,0x3B,"missile",9,True)
    add_sprite_block(0x7B,0x7C,"missile",9,True)
    add_sprite_block(0x7D,0x7E,"points",{14,15},False)  # 300,500 800,1000

    add_sprite_block(0x31,0x34,"rock_ball",4,True,mirror=True,flip=True,bob_backup=BB_ROLLING_ROCK)
    add_sprite_block(0x36,0x37,"rock_ball",4,True,mirror=True,flip=True,bob_backup=BB_ROLLING_ROCK)
    add_sprite_block(0x40,0x41,"medium_explosion",1,False)
    add_sprite_block(0x2a,0x2c,"shot_explosion",1,False)
    add_sprite_block(0x2D,0x30,"rock",4,False)
    add_sprite_block(0x3E,0x3F,"explosion",1,False)
    add_sprite_block(0x48,0x4A,"ship_explosion",1,False)
    add_sprite_block(0x7A,0x7A,"small_explosion",1,False)
    add_sprite_block(0x61,0x6F,"ground_explosion",3,True)
    add_sprite_block(0x4B,0x4D,"ship_bomb",1,False,mirror=True)
    add_sprite_block(0x11,0x27,"jeep_explosion",{1,13},True)
    add_sprite_block(0x3D,0x3D,"mine",{3,0xA,0xB},True)
    add_sprite_block(0x39,0x39,"tank_shot",4,True)
    add_sprite_block(0x3C,0x3C,"missile_shot",4,False)   # maybe wrong clut
    add_sprite_block(0,0,"blank",0,False)   # maybe wrong clut
    add_sprite_block(0x28,0x29,"jeep_shot",1,False)
    add_sprite_block(0x35,0x35,"ground_digging_bomb",{0xA,0xB},False)

    # below are sprites which are mapped to hardware sprites (lower part of the field)
    # rather chosen for their special colors than for good performance
    add_sprite_block(0x4E,0x5E,"hole_explosion",1,True)
    add_sprite_block(0x5F,0x60,"hole_explosion",0xD,True)
    add_sprite_block(0x73,0x75,"space_plant",2,True,mirror=True)
    add_sprite_block(0x70,0x70,"space_plant_flat",2,True,mirror=True)
    add_sprite_block(0x71,0x72,"space_plant_base",8,False)
    add_sprite_block(0x76,0x79,"space_plant_base",8,False)
    add_sprite_block(0x9,0x10,"falling_jeep",jeep_cluts,True)
    add_sprite_block(5,8,"jeep_wheel",0,False)  #True,bob_backup=BB_WHEEL)

def get_used_tile_cluts():
    used_cluts = collections.defaultdict(set)
    # letters beginner
    for i in range(0,0x5C):
        used_cluts[i].add(1)
        used_cluts[i].add(0xC)
    # mini-map
    for i in range(4,0x5C):
        used_cluts[i].add(2)

    # blanks for all cluts
    for i in range(0,22):
        used_cluts[0].add(i)

    # letters, champion level, stupidly lots of cluts
    for i in range(0x30,0x60):
        for c in [0,10,13,7,17,11]:
            used_cluts[i].add(c)

    # digits
    for i in range(0x30,0x3A):
        used_cluts[i].add(0)

    # champion
    for i in range(0x12,0x40):
        used_cluts[i].add(8)
        used_cluts[i].add(0xE)
    for i in range(0xE,0x1C):
        used_cluts[i].add(0xD)

    # map bar, beginner,champion
    for c in [2,0xD]:
        for i in [5,7,9,0x1B]:
            used_cluts[i].add(c)  # map letters
        for i in range(0x21,0x30):
            used_cluts[i].add(c)  # map progress rectangles
    # ground
    for i in range(0x88,0x110):
        used_cluts[i].add(0x4)
    # vertical shot
    for i in range(0x60,0x68):
        used_cluts[i].add(0)
    # moon patrol title
    for i in range(0x1B0,0x200):
        used_cluts[i].add(0)

    # moon base/platform
    for i in range(0x68,0x71):
        used_cluts[i].add(0)
    for i in range(0x81,0x85):
        used_cluts[i].add(0x13)
    for i in range(0x7C,0x81):
        used_cluts[i].add(0x10)
    for i in range(0x8D,0x91):
        used_cluts[i].add(0x10)
    for i in range(0x71,0x77):
        used_cluts[i].add(0X11)
    for i in range(0x77,0x7C):
        used_cluts[i].add(0X12)
    for i in range(0x87,0x8D):
        used_cluts[i].add(0X12)
    used_cluts[85].add(0xF)
    used_cluts[86].add(0x14)

    return used_cluts
