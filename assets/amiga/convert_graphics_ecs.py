import os,re,bitplanelib,ast
from PIL import Image,ImageOps

# ECS version
import collections


transparent = (60,100,200)  # whatever is not a used RGB is ok

this_dir = os.path.dirname(__file__)
src_dir = os.path.join(this_dir,"../../src/ecs")
dump_dir = os.path.join(this_dir,"dumps")
dump_tiles_dir = os.path.join(dump_dir,"tiles")
dump_palettes_dir = os.path.join(dump_dir,"palettes")
dump_sprites_dir = os.path.join(dump_dir,"sprites")
uncategorized_dump_sprites_dir = os.path.join(dump_sprites_dir,"__uncategorized")
def ensure_empty(sd):
    if os.path.exists(sd):
        for p in os.listdir(sd):
            n = os.path.join(sd,p)
            if os.path.isfile(n):
                os.remove(n)
    else:
        os.mkdir(sd)

dump_tiles = True
dump_sprites = True
dump_palettes = True

if dump_palettes:
    ensure_empty(dump_dir)
    ensure_empty(dump_palettes_dir)

if dump_tiles:
    ensure_empty(dump_dir)
    ensure_empty(dump_tiles_dir)

if dump_sprites:
    ensure_empty(dump_dir)
    ensure_empty(dump_sprites_dir)
    ensure_empty(uncategorized_dump_sprites_dir)


NB_POSSIBLE_SPRITES = 256
NB_BOB_PLANES = 4


def dump_asm_bytes(*args,**kwargs):
    bitplanelib.dump_asm_bytes(*args,**kwargs,mit_format=True)


sprites = dict()

block_dict = {}

# hackish convert of c gfx table to dict of lists
# (Thanks to Mark Mc Dougall for providing the ripped gfx as C tables)
with open(os.path.join(this_dir,"..","mpatrol_gfx.c")) as f:
    block = []
    block_name = ""
    start_block = False

    for line in f:
        if "uint8" in line:
            # start group
            start_block = True
            if block:
                txt = "".join(block).strip().strip(";")
                block_dict[block_name] = {"size":size,"data":ast.literal_eval(txt)}
                block = []
            block_name = line.split()[1].split("[")[0]
            size = int(line.split("[")[2].split("]")[0])
        elif start_block:
            line = re.sub("//.*","",line)
            line = line.replace("{","[").replace("}","]")
            block.append(line)

    if block:
        txt = "".join(block).strip().strip(";")
        block_dict[block_name] = {"size":size,"data":ast.literal_eval(txt)}

# block_dict structure is as follows:
# dict_keys(['tile', 'sprite', 'sprite_clut', 'sprite_palette', 'tile_palette', 'background_palette', 'green_mountains', 'blue_mountains', 'green_city'])

# 88 colors but only 15 unique colors, but organized like linear cluts which probably explains
# the high number of color slots but low number of colors. 88 = 11 cluts for 4 consecutive colors
tile_palette = [tuple(x) for x in block_dict['tile_palette']["data"]]
# 16 colors for sprite palette (uses indexed CLUTs)
sprite_palette = [tuple(x) for x in block_dict['sprite_palette']["data"]]
# some colors for background palette
background_palette = sorted(tuple(x) for x in block_dict["background_palette"]["data"])

if dump_palettes:
    for name,p in zip(("tiles","sprites","background"),(tile_palette,sprite_palette,background_palette)):
        bitplanelib.palette_dump(p,os.path.join(dump_palettes_dir,name+".png"),bitplanelib.PALETTE_FORMAT_PNG)

# cluts
sprite_cluts = [[sprite_palette[i] for i in clut] for clut in block_dict['sprite_clut']["data"]]

yellow_background_city_color = (255,222,81)
green_background_mountain_color = (0,151,0)

brown_rock_color = (0x84,0x51,0x00)
blue_dark_mountain_color = (0,0,0xFF)
dark_brown_color = (0x3E,0x37,0)
yellow_color = (0xC1,0xC8,00)

bitplane_cache = dict()
plane_next_index = 0

def generate_bitplanes(bitplanes):
    global plane_next_index
    bitplane_size = len(bitplanes)//(NB_BOB_PLANES+1)  # don't forget bob mask!
    plane_list = []
    for ci in range(0,len(bitplanes),bitplane_size):
        plane = bitplanes[ci:ci+bitplane_size]
        if not any(plane):
            # only zeroes
            plane_list.append(None)
        else:
            plane_index = bitplane_cache.get(plane)
            if plane_index is None:
                bitplane_cache[plane] = plane_next_index
                plane_index = plane_next_index
                plane_next_index += 1
            plane_list.append(plane_index)

    return plane_list


def replace_color(img,color,replacement_color):
    rval = Image.new("RGB",img.size)
    for x in range(img.size[0]):
        for y in range(img.size[1]):
            c = (x,y)
            rgb = img.getpixel(c)
            if rgb == color:
                rgb = replacement_color
            rval.putpixel(c,rgb)
    return rval
def replace_nonblack_by(img,replacement_color):
    rval = Image.new("RGB",img.size)
    for x in range(img.size[0]):
        for y in range(img.size[1]):
            c = (x,y)
            rgb = img.getpixel(c)
            if rgb != (0,0,0):
                rgb = replacement_color
            rval.putpixel(c,rgb)
    return rval

def bob_color_change(img_to_raw):
    img_to_raw = replace_color(img_to_raw,brown_rock_color,blue_dark_mountain_color)
    #img_to_raw = replace_color(img_to_raw,almost_black_color,deep_brown_color)

    return img_to_raw

def get_sprite_clut(clut_index):
    return sprite_cluts[clut_index]

# creating the sprite configuration in the code is more flexible than with a config file


def add_sprite_block(start,end,prefix,cluts,is_sprite,mirror=False,flip=False,bob_backup=0):
    if isinstance(cluts,int):
        cluts = [cluts]
    for i in range(start,end+1):
        sprite_config[i] = {"name":f"{prefix}_{i:02x}","cluts":cluts,"is_sprite":is_sprite,"bob_backup":bob_backup,"mirror":mirror,"flip":flip}



def group_vertically(sprite1,sprite2):
    sprite_config[sprite1]["vattached"] = block_dict["sprite"]["data"][sprite2]
    attached_sprites.add(sprite2)

sprite_config = dict()
attached_sprites = set()
jeep_cluts = {0,12}

BB_SHIP = 1
BB_ROLLING_ROCK = 2
BB_WHEEL = 3

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
add_sprite_block(0x2D,0x30,"rock",4,True)
add_sprite_block(0x3E,0x3F,"explosion",1,False)
add_sprite_block(0x48,0x4A,"ship_explosion",1,False)
add_sprite_block(0x7A,0x7A,"small_explosion",1,False)
add_sprite_block(0x61,0x6F,"ground_explosion",3,True)
add_sprite_block(0x4B,0x4D,"ship_bomb",1,False,mirror=True)
add_sprite_block(0x11,0x27,"jeep_explosion",{1,13},True)
add_sprite_block(0x3D,0x3D,"mine",{3,0xA,0xB},False)
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
add_sprite_block(0x71,0x72,"space_plant_base",8,True)
add_sprite_block(0x76,0x79,"space_plant_base",8,True)
add_sprite_block(0x9,0x10,"falling_jeep",jeep_cluts,True)
add_sprite_block(5,8,"jeep_wheel",0,False)  #True,bob_backup=BB_WHEEL)

# explosions
group_vertically(0x64,0x6a)
group_vertically(0x65,0x6b)
group_vertically(0x6c,0x6d)
group_vertically(0x6e,0x6f)

group_vertically(0x68,0x66)
group_vertically(0x69,0x67)

group_vertically(0x53,0x55)      # bomb digs hole
group_vertically(0x54,0x56)      # bomb digs hole
group_vertically(0x57,0x59)      # bomb digs hole
group_vertically(0x58,0x5a)      # bomb digs hole
group_vertically(0x50,0x52)      # bomb digs hole
group_vertically(0x4F,0x51)      # bomb digs hole
group_vertically(0x5b,0x5d)      # bomb digs hole
group_vertically(0x5c,0x5e)      # bomb digs hole


# group jeep sprites to save sprites
group_vertically(0x9,0xb)       # falling jeep
group_vertically(0xa,0xc)       # falling jeep
group_vertically(0xd,0xf)       # falling jeep
group_vertically(0xe,0x10)      # falling jeep
#group_vertically(0x1,0x3)       # jeep part
#group_vertically(0x2,0x4)       # jeep part
# group explosion sprites to save sprites
group_vertically(0x1d,0x1a)       # exploding jeep
group_vertically(0x1e,0x21)       # exploding jeep
group_vertically(0x11,0x14)       # exploding jeep
group_vertically(0x12,0x15)       # exploding jeep
group_vertically(0x13,0x16)       # exploding jeep

group_vertically(0x18,0x1b)       # exploding jeep
group_vertically(0x17,0x20)       # exploding jeep
group_vertically(0x19,0x22)       # exploding jeep
group_vertically(0x1f,0x1c)       # exploding jeep


bobs_used_colors = collections.Counter()
sprites_used_colors = collections.Counter()

# pre-count colors for BOBs & sprites
for k,sprdat in enumerate(block_dict["sprite"]["data"]):
    if k in attached_sprites:
        sprites[k] = True   # note that sprite is legal but will be ignored
        continue

    sprconf = sprite_config.get(k)
    if sprconf:
        clut_range = sprconf["cluts"]
        name = sprconf["name"]
        is_sprite = sprconf["is_sprite"]
        bob_backup = sprconf["bob_backup"]
        vattached = sprconf.get("vattached")

        for cidx in clut_range:
            hsize = 32 if vattached else 16
            spritepal = get_sprite_clut(cidx)
            spritepal[0] = transparent
            d = iter(sprdat)
            for j in range(16):
                for i in range(16):
                    v = next(d)
                    color = spritepal[v]
                    if sprconf:
                        if is_sprite:
                            sprites_used_colors[color] += 1
                            if bob_backup:
                                bobs_used_colors[color] += 1
                        else:
                            bobs_used_colors[color] += 1
            if vattached:
                d = iter(vattached)
                for j in range(16,32):
                    for i in range(16):
                        v = next(d)
                        color = spritepal[v]
                        (sprites_used_colors if is_sprite else bobs_used_colors)[color] += 1

print("Bobs colors: {}".format(len(bobs_used_colors)))
print("Sprites colors: {}".format(len(sprites_used_colors)))


tile_global_palette = sorted(set(tile_palette))

def switch_values(t,a,b):
    t[a],t[b] = t[b],t[a]


# now we'd better have a 16 color palette to display sprites + backgrounds
# get a 16 global BOB palette by reusing the dark blue color slot to brown when setting the background color
# below the blue mountains also set the brown color in dyn color copperlist
#still master the order of BOB palette to have backgound colors first to save some blitting


all_bob_colors = sorted(bobs_used_colors)[1:]
all_bob_colors.remove(brown_rock_color)

# remove yellow_background_city_color
bg_copy = [x for x in background_palette if x != yellow_background_city_color]

bob_global_palette = bg_copy + all_bob_colors
if len(bob_global_palette) > 16:
    # error if not enough colors, no need to hack to shoehorn it
    # if too many colors, we can't use 4 bitplanes!
    raise Exception("global bob palette should have exactly 16 colors, found {}".format(len(bob_global_palette)))
elif len(bob_global_palette) < 16:
    # can't really happen... but
    bob_global_palette += [(1,2,3)] * (16-len(bob_global_palette))


i1 = bob_global_palette.index(dark_brown_color)
i2 = bob_global_palette.index(yellow_color)
switch_values(bob_global_palette,i1,i2)

tile_global_palette += ((254,22,11),)*(16-len(tile_global_palette))



if dump_palettes:
    bitplanelib.palette_to_image(sprite_palette,os.path.join(dump_palettes_dir,"sprite.png"))
    bitplanelib.palette_to_image(sorted(bobs_used_colors),os.path.join(dump_palettes_dir,"bobs.png"))
    bitplanelib.palette_to_image(tile_global_palette,os.path.join(dump_palettes_dir,"tile.png"))
    bitplanelib.palette_to_image(background_palette,os.path.join(dump_palettes_dir,"background.png"))
    bitplanelib.palette_to_image(bob_global_palette,os.path.join(dump_palettes_dir,"global_bobs.png"))



# dump cluts as RGB4 for sprites
with open(os.path.join(src_dir,"palette_cluts.68k"),"w") as f:
    for clut in sprite_cluts:
        rgb4 = [bitplanelib.to_rgb4_color(x) for x in clut]
        bitplanelib.dump_asm_bytes(rgb4,f,mit_format=True,size=2)



with open(os.path.join(src_dir,"tiles_palette.68k"),"w") as f:
    bitplanelib.palette_dump(tile_global_palette,f,pformat=bitplanelib.PALETTE_FORMAT_ASMGNU)
with open(os.path.join(src_dir,"bobs_palette.68k"),"w") as f:
    bitplanelib.palette_dump(bob_global_palette,f,pformat=bitplanelib.PALETTE_FORMAT_ASMGNU)

    rock_color = bitplanelib.to_rgb4_color(brown_rock_color)
    rock_color_index = bob_global_palette.index(blue_dark_mountain_color)
    f.write("rock_color:\n\t.word\t0x{:x}\n".format(rock_color))
    f.write("rock_color_register:\n\t.word\t0x180+{}\n".format(rock_color_index*2))
character_codes_list = []

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

# letters, champion level
for i in range(0x30,0x60):
    used_cluts[i].add(0x11)
    used_cluts[i].add(0)
    #used_cluts[i].add(2)
    used_cluts[i].add(0xA)
    used_cluts[i].add(0xD)

# digits
for i in range(0x30,0x3A):
    used_cluts[i].add(0)

# champion
for i in range(0x12,0x3F):
    used_cluts[i].add(8)
for i in range(0xE,0x1C):
    used_cluts[i].add(0xD)
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
for i in range(0x71,0x77):
    used_cluts[i].add(0X11)
for i in range(0x77,0x7C):
    used_cluts[i].add(0X12)
for i in range(0x87,0x8D):
    used_cluts[i].add(0X12)
used_cluts[85].add(0xF)
used_cluts[86].add(0x14)

if True:
    for k,chardat in enumerate(block_dict["tile"]["data"]):
        img = Image.new('RGB',(8,8))

        character_codes = list()

        for cidx,colors in enumerate([tile_palette[i:i+4] for i in range(0,88,4)]):
            if not used_cluts or (k in used_cluts and cidx in used_cluts[k]):
                d = iter(chardat)
                for i in range(8):
                    for j in range(8):
                        v = next(d)
                        img.putpixel((j,i),colors[v])
                if 0x68 <= k <= 0x91:
                    # moon base: make all tiles single plane with color 15 to enable all bitplanes
                    img = replace_nonblack_by(img,tile_global_palette[15])
                character_codes.append(bitplanelib.palette_image2raw(img,None,tile_global_palette,generate_mask=True))
                if dump_tiles:
                    scaled = ImageOps.scale(img,5,0)
                    scaled.save(os.path.join(dump_tiles_dir,f"char_{k:02x}_{cidx}.png"))
            else:
                character_codes.append(None)
        character_codes_list.append(character_codes)



for k,sprdat in enumerate(block_dict["sprite"]["data"]):
    if k in attached_sprites:
        sprites[k] = True   # note that sprite is legal but will be ignored
        continue

    sprconf = sprite_config.get(k)
    if sprconf:
        clut_range = sprconf["cluts"]
        name = sprconf["name"]
        is_sprite = sprconf["is_sprite"]
        bob_backup = sprconf["bob_backup"]
        vattached = sprconf.get("vattached")
        mirror = sprconf.get("mirror")
        flip = sprconf.get("flip")
    else:
        clut_range = range(0,16)
        name = f"unknown_{k:02x}"
        is_sprite = False
        bob_backup = False
        vattached = None
        mirror = False

    for cidx in clut_range:
        hsize = 32 if vattached else 16
        vsize = 16
        img = Image.new('RGB',(vsize,hsize),transparent)
        spritepal = get_sprite_clut(cidx)
        spritepal[0] = transparent
        d = iter(sprdat)
        for j in range(16):
            for i in range(16):
                v = next(d)
                color = spritepal[v]
                if sprconf:
                    (sprites_used_colors if is_sprite else bobs_used_colors)[color] += 1
                img.putpixel((i,j),color)
        if vattached:
            d = iter(vattached)
            for j in range(16,32):
                for i in range(16):
                    v = next(d)
                    color = spritepal[v]
                    (sprites_used_colors if is_sprite else bobs_used_colors)[color] += 1
                    img.putpixel((i,j),color)

        # only consider sprites/cluts which are pre-registered
        if sprconf:
            if k not in sprites:
                sprites[k] = {"is_sprite":is_sprite,"bob_backup":False,"name":name,"hsize":hsize,"vsize":vsize,"mirror":mirror,"flip":flip}
            cs = sprites[k]
            is_bob = not is_sprite or bob_backup
            if is_sprite:
                # hardware sprites only need one bitmap data, copied 8 times to be able
                # to be assigned several times. Doesn't happen a lot in this game for now
                # but at least wheels have more than 1 instance
                if "bitmap" not in cs:
                    # create entry only if not already created (multiple cluts)
                    # we must not introduce a all black or missing colors palette in here
                    # (even if the CLUT may be used for this sprite) else base image will miss colors!
                    #
                    # example: pengo all-black enemies. If this case occurs, just omit this dummy config
                    # the amiga engine will manage anyway
                    #
                    cs["bitmap"] = [bitplanelib.palette_image2sprite(img,None,spritepal,
                            palette_precision_mask=0xFF,sprite_fmode=0,with_control_words=True),None,None,None]
                    if mirror:
                        cs["bitmap"][1] = bitplanelib.palette_image2sprite(ImageOps.mirror(img),None,spritepal,
                            palette_precision_mask=0xFF,sprite_fmode=0,with_control_words=True)
                    if flip:
                        cs["bitmap"][2] = bitplanelib.palette_image2sprite(ImageOps.flip(img),None,spritepal,
                            palette_precision_mask=0xFF,sprite_fmode=0,with_control_words=True)
                        if mirror:
                            cs["bitmap"][3] = bitplanelib.palette_image2sprite(ImageOps.mirror(ImageOps.flip(img)),None,spritepal,
                                palette_precision_mask=0xFF,sprite_fmode=0,with_control_words=True)

                    cs["png"] = img
            if is_bob:
                orig_img = img
                yoffset,img = bitplanelib.autocrop_y(img,transparent)
                # change hsize
                hsize = img.size[1]

                if bob_backup:
                    # clone sprite into bob with 0x80 shift (upper 128-255 range isn't normally used)
                    if k+0x80 not in sprites:
                        src = sprites[k]
                        cs = {"is_sprite":False,"bob_backup":False,"name":src["name"]+"_bob",
                                "hsize":hsize,"vsize":src["vsize"],"yoffset":yoffset,"mirror":mirror,"flip":flip}
                        sprites[k+0x80] = cs

                # software sprites (bobs) need one copy of bitmaps per palette setup. There are 3 or 4 planes
                # (4 ATM but will switch to dual playfield)
                # but not all planes are active as game sprites have max 3 colors (+ transparent)
                if "bitmap" not in cs:
                    cs["bitmap"] = dict()
                    cs["png"] = dict()
                csb = cs["bitmap"]
                csp = cs["png"]
                cs["yoffset"] = yoffset
                cs["hsize"] = hsize

                csb[cidx] = dict()
                # prior to dump the image to amiga bitplanes, don't forget to replace brown by blue
                # as we forcefully removed it from the palette to make it fit to 16 colors, don't worry, the
                # copper will put the proper color back again

                img_to_raw = bob_color_change(img)
                if not name.startswith("jeep_part_"):  # no need to generate data for jeep parts
                    bitplanes = bitplanelib.palette_image2raw(img_to_raw,None,bob_global_palette,forced_nb_planes=NB_BOB_PLANES,
                        palette_precision_mask=0xFF,generate_mask=True,blit_pad=True,mask_color=transparent)


                    plane_list = generate_bitplanes(bitplanes)

                    csb[cidx]= [plane_list,None]  # left, no right
                    if cs["mirror"]:
                        bitplanes = bitplanelib.palette_image2raw(ImageOps.mirror(img_to_raw),None,bob_global_palette,forced_nb_planes=NB_BOB_PLANES,
                            palette_precision_mask=0xFF,generate_mask=True,blit_pad=True,mask_color=transparent)
                        plane_list = generate_bitplanes(bitplanes)
                        csb[cidx][1] = plane_list
                csp[cidx] = orig_img   # store original png so if we want to group tiles it's not broken

        if dump_sprites:
            scaled = ImageOps.scale(img,2,0)
            if sprconf:
                scaled.save(os.path.join(dump_sprites_dir,f"{name}_{cidx}.png"))
            else:
                scaled.save(os.path.join(uncategorized_dump_sprites_dir,f"sprites_{k:02x}_{cidx}.png"))


bitmaps = [sprites[i]["png"] for i in range(1,5)]
jeep_dict = dict()
# special kludge: group 4 jeep sprites into a big special bob
for clut in jeep_cluts:
    jeep_img = Image.new("RGB",(32,32))
    jeep_img.paste(bitmaps[0][clut],(0,0))
    jeep_img.paste(bitmaps[1][clut],(16,0))
    jeep_img.paste(bitmaps[2][clut],(0,16))
    jeep_img.paste(bitmaps[3][clut],(16,16))
    y_offset,jeep_img = bitplanelib.autocrop_y(jeep_img,transparent)
    bitplanes = bitplanelib.palette_image2raw(bob_color_change(jeep_img),None,bob_global_palette,
                    palette_precision_mask=0xFF,generate_mask=True,blit_pad=True,mask_color=transparent)
    jeep_dict[clut] = [generate_bitplanes(bitplanes),None]

    if dump_sprites:
        scaled = ImageOps.scale(jeep_img,2,0)
        scaled.save(os.path.join(dump_sprites_dir,f"jeep_1_{clut}.png"))



for i in range(2,5):
    sprites[i] = True  # cancel entry, but let it be seen as legal by the engine (like attached sprites)
# just replace 16x16 entry by 32x32 entry. The code will do a special operation
sprites[1]["bitmap"] = jeep_dict
sprites[1]["hsize"] = jeep_img.size[1]
sprites[1]["vsize"] = jeep_img.size[0]


with open(os.path.join(src_dir,"graphics.68k"),"w") as f:
    f.write("\t.global\tcharacter_table\n")
    f.write("\t.global\tsprite_table\n")
    f.write("\t.global\tbob_table\n")
    f.write("\t.global\tblue_mountains\n")
    f.write("\t.global\tgreen_mountains\n")
    f.write("\t.global\tgreen_city\n")
    f.write("\t.global\thardware_sprite_flag_table\n")


    hw_sprite_flag = [0]*256
    for k,v in sprite_config.items():
        sprite_type = v["is_sprite"]
        if sprite_type:
            hw_sprite_flag[k] = 1+v.get("bob_backup",0)


    f.write("\nhardware_sprite_flag_table:")
    bitplanelib.dump_asm_bytes(hw_sprite_flag,f,mit_format=True)

    f.write("character_table:\n")
    for i,c in enumerate(character_codes_list):
        # c is the list of the same character with 11 different cluts
        if c is not None:
            f.write(f"\t.long\tchar_{i}\n")
        else:
            f.write("\t.long\t0\n")
    for i,c in enumerate(character_codes_list):
        if c is not None:
            f.write(f"char_{i}:\n")
            # this is a table
            for j,cc in enumerate(c):
                if cc is None:
                    f.write(f"\t.word\t0\n")
                else:
                    f.write(f"\t.word\tchar_{i}_{j}-char_{i}\n")

            for j,cc in enumerate(c):
                if cc is not None:
                    f.write(f"char_{i}_{j}:")
                    bitplanelib.dump_asm_bytes(cc,f,mit_format=True)

    f.write("sprite_table:\n")

    sprite_names = [None]*NB_POSSIBLE_SPRITES
    for i in range(NB_POSSIBLE_SPRITES):
        sprite = sprites.get(i)
        f.write("\t.long\t")
        if sprite:
            if sprite == True:
                f.write("-1,-1,-1,-1")  # not displayed but legal
            else:
                if sprite["is_sprite"]:
                    name = sprite['name']
                    sprite_names[i] = name
                    f.write(name+"_left,")
                    if sprite["mirror"]:
                        f.write(name+"_right,")
                    else:
                        f.write("0,")
                    if sprite["flip"]:
                        f.write(name+"_flip_left,")
                        if sprite["mirror"]:
                            f.write(name+"_flip_right")
                        else:
                            f.write("0")
                    else:
                        f.write("0,0")
                else:
                    f.write("0,0,0,0")
        else:
            f.write("0,0")
        f.write("\n")

    # pointers to 8/16-group sprites for each pic
    for i in range(NB_POSSIBLE_SPRITES):
        sprite = sprites.get(i)
        name = sprite_names[i]
        if name:
            f.write(f"{name}_left:\n")
            for j in range(8):
                f.write(f"\t.long\t{name}_{j}_left\n")
            if sprite["mirror"]:
                f.write(f"{name}_right:\n")
                for j in range(8):
                    f.write(f"\t.long\t{name}_{j}_right\n")
            if sprite["flip"]:
                f.write(f"{name}_flip_left:\n")
                for j in range(8):
                    f.write(f"\t.long\t{name}_{j}_flip_left\n")
                if sprite["mirror"]:
                    f.write(f"{name}_flip_right:\n")
                    for j in range(8):
                        f.write(f"\t.long\t{name}_{j}_flip_right\n")


    f.write("bob_table:\n")

    bob_names = [None]*NB_POSSIBLE_SPRITES
    for i in range(NB_POSSIBLE_SPRITES):
        sprite = sprites.get(i)
        f.write("\t.long\t")
        if sprite:
            if sprite == True or sprite["is_sprite"]:
                f.write("-1,-1")  # hardware sprite: ignore
            else:
                name = sprite["name"]
                bob_names[i] = name
                f.write(f"{name}_left,")
                if sprite["mirror"]:
                    f.write(f"{name}_right")
                else:
                    f.write("0")

        else:
            f.write("0,0")
        f.write("\n")

    for i in range(NB_POSSIBLE_SPRITES):
        name = bob_names[i]
        if name:
            sprite = sprites.get(i)
            for k,dir in enumerate(("left","right")):
                csb = sprite["bitmap"]
                if csb:
                    vsize = sprite['vsize']//8 + 2
                    f.write(f"{name}_{dir}:\n")
                    # useless comment as code is generated but helpful when you're coding the engine...
                    f.write(f"\t* h size, v size in bytes, y offset, pad)\n")
                    f.write(f"\t.word\t{sprite['hsize']},{vsize},{sprite['yoffset']},0\n")


                for j in range(16):
                    b = csb.get(j)
                    f.write("\t.long\t")
                    if b and b[k]:
                        f.write(f"{name}_{dir}_{j}")
                    else:
                        f.write("0")   # clut not active
                    f.write("\n")

    # blitter objects (bitplanes refs, can be in fastmem)
    for i in range(NB_POSSIBLE_SPRITES):
        name = bob_names[i]
        if name:
            sprite = sprites.get(i)
            bitmap = sprite["bitmap"]

            for k,dir in enumerate(("left","right")):
                for j in range(16):
                    bm = bitmap.get(j)
                    if bm and bm[k]:

                        sprite_label = f"{name}_{dir}_{j}"
                        f.write(f"{sprite_label}:\n")
                        for plane_id in bm[k]:
                            f.write("\t.long\t")
                            if plane_id is None:
                                f.write("0")
                            else:
                                f.write(f"plane_{plane_id}")
                            f.write("\n")

    f.write("\t.section\t.datachip\n")
    # hardware sprites
    for i in range(NB_POSSIBLE_SPRITES):
        name = sprite_names[i]
        if name:
            sprite = sprites.get(i)
            for k,bitmap in zip(("left","right","flip_left","flip_right"),sprite["bitmap"]):
                if bitmap:
                    for j in range(8):
                        # clut is valid for this sprite
                        sprite_label = f"{name}_{j}_{k}"
                        f.write(f"{sprite_label}:\n\t.word\t{sprite['hsize']}")
                        bitplanelib.dump_asm_bytes(bitmap,f,mit_format=True)

    f.write("\n* bitplanes\n")
    # dump bitplanes
    for k,v in bitplane_cache.items():
        f.write(f"plane_{v}:")
        bitplanelib.dump_asm_bytes(k,f,mit_format=True)

    f.write("\n* backgrounds\n")
    backgrounds = ['blue_mountains', 'green_mountains', 'green_city']

    # we only need 8 first colors (actually even less)
    bg_palette = background_palette


    for b in backgrounds:
        f.write(f"{b}:\n")
        data = block_dict[b]["data"]
        nb_rows = len(data)
        is_green = "green" in b

        # first write number of rows, then number of bytes total, which differ from one background to another
        # = number of rows * ((512/16)+2) (there's a blit shift mask like all shiftable bobs)
        f.write(f"\t.word\t{nb_rows},{nb_rows*((512//8)+2)}")
        # then the data itself
        img = Image.new("RGB",(512,nb_rows))
        # convert data to picture, twice as large so can be blit-scrolled
        for y,d in enumerate(data):
            v = iter(d)
            for x in range(256):
                cidx = next(v)
                rgb = bg_palette[cidx]
                img.putpixel((x,y),rgb)
                img.putpixel((x+256,y),rgb)

        # replace yellow by dark green if found, we'll switch to yellow dynamically (saves 1 precious color slot
        # as both backgrounds can't be present at the same time)
        img = replace_color(img,yellow_background_city_color,green_background_mountain_color)
        # dump, we don't need a mask for the blue layer as it's behind

        raw = bitplanelib.palette_image2raw(img,None,bob_global_palette[:8],forced_nb_planes=3,
                    palette_precision_mask=0xFF,generate_mask=is_green,blit_pad=True)
        nb_planes = 4 if "green" in b else 3
        plane_size = len(raw)//nb_planes
        for z in range(nb_planes):
            f.write(f"\n* plane {z} ({plane_size} bytes)")
            dump_asm_bytes(raw[z*plane_size:(z+1)*plane_size],f)

