import os,re,bitplanelib,ast
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


NB_POSSIBLE_SPRITES = 128

rw_json = os.path.join(this_dir,"used_cluts.json")
if os.path.exists(rw_json):
    with open(rw_json) as f:
        used_cluts = json.load(f)
    # key as integer, list as set for faster lookup (not that it matters...)
    used_cluts = {int(k):set(v) for k,v in used_cluts.items()}
else:
    print(f"Warning: no {rw_json} file, no tile/clut filter, expect BIG graphics.68k file")
    used_cluts = None



def dump_asm_bytes(*args,**kwargs):
    bitplanelib.dump_asm_bytes(*args,**kwargs,mit_format=True)



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


##def dump_rgb_cluts(rgb_cluts,name):
##    out = os.path.join(dump_dir,f"{name}_cluts.png")
##    w = 16
##    nb_clut_per_row = 4
##    img = Image.new("RGB",(w*(nb_clut_per_row+1)*4,w*len(rgb_cluts)//nb_clut_per_row))
##    x = 0
##    y = 0
##    row_count = 0
##    for clut in rgb_cluts:
##        # undo the clut correction so it's the same as MAME
##        for color in [clut[0],clut[2],clut[1],clut[3]]:
##            for dx in range(w):
##                for dy in range(w):
##                    img.putpixel((x+dx,y+dy),color)
##            x += dx
##        row_count += 1
##        if row_count == 4:
##            x = 0
##            y += dy
##            row_count = 0
##
##    img.save(out)




# dump cluts as RGB4 for sprites
with open(os.path.join(src_dir,"palette_cluts.68k"),"w") as f:
    f.write(f"sprite_cluts:")
    for clut in sprite_cluts:
        rgb4 = [bitplanelib.to_rgb4_color(x) for x in clut]
        bitplanelib.dump_asm_bytes(rgb4,f,mit_format=True,size=2)


tile_global_palette = sorted(set(tile_palette))
tile_global_palette.append((255,255,255))

with open(os.path.join(src_dir,"palette.68k"),"w") as f:
    bitplanelib.palette_dump(tile_global_palette,f,pformat=bitplanelib.PALETTE_FORMAT_ASMGNU)

character_codes_list = []

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
attached_sprites = set()
jeep_cluts = {0,12}

def add_sprite_block(start,end,prefix,cluts,is_sprite):
    if isinstance(cluts,int):
        cluts = [cluts]
    for i in range(start,end+1):
        sprite_config[i] = {"name":f"{prefix}_{i:02x}","cluts":cluts,"is_sprite":is_sprite}


def group_vertically(sprite1,sprite2):
    sprite_config[sprite1]["vattached"] = block_dict["sprite"]["data"][sprite2]
    attached_sprites.add(sprite2)

# jeep is made of sprites: 5 sprites needed, 6 color slots
# so we can allow 2 more sprites but they must have same CLUT...
# missile qualifies (made of 2 sprites)
# tank qualifies (there can be 2 tanks at once)

add_sprite_block(0x9,0x10,"falling_jeep",jeep_cluts,True)
add_sprite_block(1,4,"jeep_part",jeep_cluts,True)
add_sprite_block(5,8,"jeep_wheel",0,True)
add_sprite_block(0x42,0x42,"saucer",7,False)
add_sprite_block(0x43,0x44,"hole_making_ship",7,False)
add_sprite_block(0x45,0x47,"ovoid_ship",7,False)
add_sprite_block(0x38,0x38,"tank",7,True)
add_sprite_block(0x3A,0x3B,"missile",9,True)
add_sprite_block(0x7B,0x7C,"missile",9,True)
add_sprite_block(0x7E,0x7E,"points",{14,15},False)  # 800,1000
add_sprite_block(0x7D,0x7D,"points",{14,15},False)  # 300,500

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
add_sprite_block(0x11,0x27,"jeep_explosion",{1,13},True)
add_sprite_block(0x3D,0x3D,"mine",{3,10},False)
add_sprite_block(0x39,0x39,"tank_shot",4,True)   # maybe wrong clut
add_sprite_block(0x3C,0x3C,"missile_shot",4,False)   # maybe wrong clut
add_sprite_block(0,0,"blank",0,False)   # maybe wrong clut
add_sprite_block(0x28,0x28,"jeep_shot",14,False)   # maybe wrong clut
add_sprite_block(0x35,0x35,"ground_digging_bomb",14,False)   # maybe wrong clut

# group jeep sprites to save sprites
group_vertically(0x9,0xb)
group_vertically(0xa,0xc)
group_vertically(0xd,0xf)
group_vertically(0xe,0x10)
group_vertically(0x1,0x3)
group_vertically(0x2,0x4)

transparent = (60,100,200)

bobs_used_colors = collections.Counter()
sprites_used_colors = collections.Counter()

sprites = dict()

for k,sprdat in enumerate(block_dict["sprite"]["data"]):
    if k in attached_sprites:
        sprites[k] = True   # note that sprite is legal but will be ignored
        continue

    sprconf = sprite_config.get(k)
    if sprconf:
        clut_range = sprconf["cluts"]
        name = sprconf["name"]
        is_sprite = sprconf["is_sprite"]
        vattached = sprconf.get("vattached")
    else:
        clut_range = range(0,16)
        name = f"unknown_{k:02x}"
        is_sprite = False
        vattached = None

    for cidx in clut_range:
        hsize = 32 if vattached else 16
        img = Image.new('RGB',(16,hsize),transparent)
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
            if is_sprite:
                sdata = bitplanelib.palette_image2sprite(img,None,spritepal,
                        palette_precision_mask=0xFF,sprite_fmode=0,with_control_words=True)
            else:
                sdata = bitplanelib.palette_image2raw(img,None,spritepal,forced_nb_planes=4,
                    palette_precision_mask=0xFF,generate_mask=True,blit_pad=True,mask_color=transparent)
            sprites[k] = {"is_sprite":is_sprite,"name":name,"bitmap":sdata,"hsize":hsize}

        if dump_sprites:
            scaled = ImageOps.scale(img,2,0)
            if sprconf:
                scaled.save(os.path.join(dump_sprites_dir,f"{name}_{cidx}.png"))
            else:
                scaled.save(os.path.join(uncategorized_dump_sprites_dir,f"sprites_{k:02x}_{cidx}.png"))

print("Bobs colors: {}".format(len(bobs_used_colors)))
print("Sprites colors: {}".format(len(sprites_used_colors)))

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

    f.write("sprite_table:\n")

    sprite_names = [None]*NB_POSSIBLE_SPRITES
    for i in range(NB_POSSIBLE_SPRITES):
        sprite = sprites.get(i)
        f.write("\t.long\t")
        if sprite:
            if sprite == True:
                f.write("-1")  # not displayed but legal
            else:
                if sprite["is_sprite"]:
                    name = sprite['name']
                    sprite_names[i] = name
                    f.write(name)
                else:
                    f.write("0")
        else:
            f.write("0")
        f.write("\n")

    for i in range(NB_POSSIBLE_SPRITES):
        name = sprite_names[i]
        if name:
            f.write(f"{name}:\n")
            for j in range(8):
                f.write("\t.long\t")
                f.write(f"{name}_{j}")
                f.write("\n")


    f.write("\t.section\t.datachip\n")

    for i in range(NB_POSSIBLE_SPRITES):
        name = sprite_names[i]
        if name:
            sprite = sprites.get(i)
            for j in range(8):
                # clut is valid for this sprite
                bitmap = sprite["bitmap"]
                sprite_label = f"{name}_{j}"
                f.write(f"{sprite_label}:\n\t.word\t{sprite['hsize']}")
                bitplanelib.dump_asm_bytes(bitmap,f,mit_format=True)
