import os,re,bitplanelib,ast,json
from PIL import Image,ImageOps


import collections



this_dir = os.path.dirname(__file__)
src_dir = os.path.join(this_dir,"../../src/amiga")
dump_dir = os.path.join(this_dir,"dumps")
dump_tiles_dir = os.path.join(dump_dir,"tiles")
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

dump_tiles = False
dump_sprites = True

if dump_tiles:
    if not os.path.exists(dump_dir):
        os.mkdir(dump_dir)
    if not os.path.exists(dump_tiles_dir):
        os.mkdir(dump_tiles_dir)

if dump_sprites:
    if not os.path.exists(dump_dir):
        os.mkdir(dump_dir)
    ensure_empty(dump_dir)
    ensure_empty(dump_sprites_dir)
    ensure_empty(uncategorized_dump_sprites_dir)


NB_POSSIBLE_SPRITES = 128  #64+64 alternate

rw_json = os.path.join(this_dir,"used_cluts.json")
if os.path.exists(rw_json):
    with open(rw_json) as f:
        used_cluts = json.load(f)
    # key as integer, list as set for faster lookup (not that it matters...)
    used_cluts = {int(k):set(v) for k,v in used_cluts.items()}
else:
    print("Warning: no {} file, no tile/clut filter, expect BIG graphics.68k file")
    used_cluts = None



def dump_asm_bytes(*args,**kwargs):
    bitplanelib.dump_asm_bytes(*args,**kwargs,mit_format=True)


opposite = {"left":"right","right":"left"}

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
# dict_keys(['tile', 'sprite', 'sprite_clut', 'sprite_palette', 'tile_palette'])

# 88 colors but only 15 unique colors, but organized like linear cluts which probably explains
# the high number of color slots but low number of colors. 88 = 11 cluts for 4 consecutive colors
tile_palette = [tuple(x) for x in block_dict['tile_palette']["data"]]
# 16 colors for sprite palette (uses indexed CLUTs)
sprite_palette = [tuple(x) for x in block_dict['sprite_palette']["data"]]
# cluts
sprite_cluts = [[sprite_palette[i] for i in clut] for clut in block_dict['sprite_clut']["data"]]


def dump_rgb_cluts(rgb_cluts,name):
    out = os.path.join(dump_dir,f"{name}_cluts.png")
    w = 16
    nb_clut_per_row = 4
    img = Image.new("RGB",(w*(nb_clut_per_row+1)*4,w*len(rgb_cluts)//nb_clut_per_row))
    x = 0
    y = 0
    row_count = 0
    for clut in rgb_cluts:
        # undo the clut correction so it's the same as MAME
        for color in [clut[0],clut[2],clut[1],clut[3]]:
            for dx in range(w):
                for dy in range(w):
                    img.putpixel((x+dx,y+dy),color)
            x += dx
        row_count += 1
        if row_count == 4:
            x = 0
            y += dy
            row_count = 0

    img.save(out)




### dump cluts as RGB4 for sprites
##with open(os.path.join(src_dir,"palette_cluts.68k"),"w") as f:
##    for the_type,rgb_cluts in [("normal",rgb_cluts_normal),("alt",rgb_cluts_alt)]:
##        f.write(f"{the_type}_cluts:")
##        for clut in rgb_cluts:
##            rgb4 = [bitplanelib.to_rgb4_color(x) for x in clut]
##            bitplanelib.dump_asm_bytes(rgb4,f,mit_format=True,size=2)


tile_global_palette = sorted(set(tile_palette))
tile_global_palette.append((255,255,255))

with open(os.path.join(src_dir,"palette.68k"),"w") as f:
    bitplanelib.palette_dump(tile_global_palette,f,pformat=bitplanelib.PALETTE_FORMAT_ASMGNU)

character_codes_list = []

if False:
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
                character_codes.append(bitplanelib.palette_image2raw(img,None,tile_global_palette))
            else:
                character_codes.append(None)
            if dump_tiles:
                scaled = ImageOps.scale(img,5,0)
                scaled.save(os.path.join(dump_tiles_dir,f"char_{k:02x}_{cidx}.png"))
        character_codes_list.append(character_codes)

def get_sprite_clut(clut_index):
    return sprite_cluts[clut_index]

# creating the sprite configuration in the code is more flexible than with a config file

sprite_config = dict()
jeep_cluts = {0,12}

def add_sprite_block(start,end,prefix,cluts,is_sprite):
    if isinstance(cluts,int):
        cluts = [cluts]
    for i in range(start,end+1):
        sprite_config[i] = {"name":f"{prefix}_{i:02x}","cluts":cluts,"is_sprite":True}

add_sprite_block(0xA,0x10,"falling_jeep_part_",jeep_cluts,True)
add_sprite_block(1,4,"jeep_part_",jeep_cluts,True)
add_sprite_block(5,8,"jeep_wheel_",0,True)  # todo extract black vs background
add_sprite_block(0x42,0x42,"saucer",7,False)
add_sprite_block(0x43,0x44,"hole_making_ship",7,False)
add_sprite_block(0x45,0x47,"ovoid_ship",7,False)
add_sprite_block(0x38,0x38,"tank",7,False)
add_sprite_block(0x3A,0x3B,"missile",9,False)  # todo extract black
add_sprite_block(0x7B,0x7C,"missile",9,False)  # todo extract black
add_sprite_block(0x7E,0x7E,"score_800",14,False)
add_sprite_block(0x7D,0x7D,"score_500",14,False)
add_sprite_block(0x31,0x34,"rock_ball",4,False)
add_sprite_block(0x36,0x37,"rock_ball",4,False)
add_sprite_block(0x40,0x41,"medium_explosion",1,False)
add_sprite_block(0x2a,0x2c,"shot_explosion",7,False)
add_sprite_block(0x2D,0x30,"rock",4,False)
add_sprite_block(0x3E,0x3F,"explosion",7,False)
add_sprite_block(0x48,0x4A,"ship_explosion",1,False)
add_sprite_block(0x7A,0x7A,"small_explosion",1,False)
add_sprite_block(0x61,0x6F,"ground_explosion",3,False)
add_sprite_block(0x4B,0x4D,"ship_bomb",3,False)
add_sprite_block(0x11,0x27,"jeep_explosion",{1,13},False)
add_sprite_block(0x3D,0x3D,"mine",{3,10},False)

transparent = (60,100,200)

# brutal dump of all sprites in all cluts
for k,sprdat in enumerate(block_dict["sprite"]["data"]):
    sprconf = sprite_config.get(k)
    if sprconf:
        clut_range = sprconf["cluts"]
        name = sprconf["name"]
    else:
        clut_range = range(0,15)
        name = f"unknown_{k:02x}"

    for cidx in clut_range:
        img = Image.new('RGB',(16,16),transparent)
        spritepal = get_sprite_clut(cidx)
        spritepal[0] = transparent
        d = iter(sprdat)
        for j in range(16):
            for i in range(16):
                v = next(d)
                img.putpixel((i,j),spritepal[v])

        if dump_sprites:
            scaled = ImageOps.scale(img,2,0)
            if sprconf:
                scaled.save(os.path.join(dump_sprites_dir,f"{name}_{cidx}.png"))
            else:
                scaled.save(os.path.join(uncategorized_dump_sprites_dir,f"sprites_{k:02x}_{cidx}.png"))

if False:



    sprites = collections.defaultdict(dict)

    clut_index = 12  # temp

    bg_cluts_bank_0 = [[tuple(palette[pidx]) for pidx in clut] for clut in bg_cluts[0:16]]
    # second bank
    bg_cluts_bank_1 = [[tuple(palette[pidx]) for pidx in clut] for clut in bg_cluts[16:]]


    # pick a clut index with different colors
    # it doesn't matter which one
    for clut in bg_cluts:
        if len(clut)==len(set(clut)):
            spritepal = clut
            break
    else:
        # can't happen
        raise Exception("no way jose")

    # convert our picked palette to RGB
    spritepal = [tuple(palette[pidx]) for pidx in spritepal]

    for k,data in sprite_config.items():
        sprdat = block_dict["sprite"]["data"][k]

        d = iter(sprdat)
        img = Image.new('RGB',(16,16))
        y_start = 0


        for i in range(16):
            for j in range(16):
                v = next(d)
                if j >= y_start:
                    img.putpixel((j,i),spritepal[v])

        spr = sprites[k]
        spr["name"] = data['name']
        mirror = any(x in data["name"] for x in ("left","right"))

        right = None
        outname = f"{k:02x}_{clut_index}_{data['name']}.png"

        left = bitplanelib.palette_image2sprite(img,None,spritepal)
        if mirror:
            right = bitplanelib.palette_image2sprite(ImageOps.mirror(img),None,spritepal)

        spr["left"] = left
        spr["right"] = right

        if dump_it:
            scaled = ImageOps.scale(img,5,0)
            scaled.save(os.path.join(dump_dir,outname))



with open(os.path.join(src_dir,"graphics.68k"),"w") as f:
    f.write("\t.global\tcharacter_table\n")
    f.write("\t.global\tsprite_table\n")

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
    import sys
    sys.exit(0)
    f.write("sprite_table:\n")

    sprite_names = [None]*NB_POSSIBLE_SPRITES
    for i in range(NB_POSSIBLE_SPRITES):
        sprite = sprites.get(i)
        f.write("\t.long\t")
        if sprite:
            name = f"{sprite['name']}_{i:02x}"
            sprite_names[i] = name
            f.write(name)
        else:
            f.write("0")
        f.write("\n")

    for i in range(NB_POSSIBLE_SPRITES):
        sprite = sprites.get(i)
        if sprite:
            name = sprite_names[i]
            f.write(f"{name}:\n")
            for j in range(8):
                f.write("\t.long\t")
                f.write(f"{name}_{j}")
                f.write("\n")

    for i in range(NB_POSSIBLE_SPRITES):
        sprite = sprites.get(i)
        if sprite:
            name = sprite_names[i]
            for j in range(8):
                f.write(f"{name}_{j}:\n")

                for d in ["left","right"]:
                    bitmap = sprite[d]
                    if bitmap:
                        f.write(f"\t.long\t{name}_{j}_sprdata\n".replace(d,opposite[d]))
                    else:
                        # same for both
                        f.write(f"\t.long\t{name}_{j}_sprdata\n")

    f.write("\t.section\t.datachip\n")

    for i in range(256):
        sprite = sprites.get(i)
        if sprite:
            name = sprite_names[i]
            for j in range(8):
                # clut is valid for this sprite

                for d in ["left","right"]:
                    bitmap = sprite[d]
                    if bitmap:
                        sprite_label = f"{name}_{j}_sprdata".replace(d,opposite[d])
                        f.write(f"{sprite_label}:\n\t.long\t0\t| control word")
                        bitplanelib.dump_asm_bytes(sprite[d],f,mit_format=True)
                        f.write("\t.long\t0\n")
