import os,re,bitplanelib,ast
from PIL import Image,ImageOps


import collections


transparent = (60,100,200)  # whatever is not a used RGB is ok

this_dir = os.path.dirname(__file__)
src_dir = os.path.join(this_dir,"../../src/amiga")
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

dump_tiles = False
dump_sprites = False
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


NB_POSSIBLE_SPRITES = 128
NB_BOB_PLANES = 4

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

# cluts
sprite_cluts = [[sprite_palette[i] for i in clut] for clut in block_dict['sprite_clut']["data"]]

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

def get_sprite_clut(clut_index):
    return sprite_cluts[clut_index]

# creating the sprite configuration in the code is more flexible than with a config file


def add_sprite_block(start,end,prefix,cluts,is_sprite):
    if isinstance(cluts,int):
        cluts = [cluts]
    for i in range(start,end+1):
        sprite_config[i] = {"name":f"{prefix}_{i:02x}","cluts":cluts,"is_sprite":is_sprite}


def group_vertically(sprite1,sprite2):
    sprite_config[sprite1]["vattached"] = block_dict["sprite"]["data"][sprite2]
    attached_sprites.add(sprite2)

sprite_config = dict()
attached_sprites = set()
jeep_cluts = {0,12}

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
add_sprite_block(0x4B,0x4D,"ship_bomb",1,False)
add_sprite_block(0x11,0x27,"jeep_explosion",{1,13},True)
add_sprite_block(0x3D,0x3D,"mine",{3,10},False)
add_sprite_block(0x39,0x39,"tank_shot",4,True)
add_sprite_block(0x73,0x75,"trap",2,False)
add_sprite_block(0x3C,0x3C,"missile_shot",4,False)   # maybe wrong clut
add_sprite_block(0,0,"blank",0,False)   # maybe wrong clut
add_sprite_block(0x28,0x29,"jeep_shot",14,False)   # maybe wrong clut
add_sprite_block(0x35,0x35,"ground_digging_bomb",14,False)   # maybe wrong clut

# group jeep sprites to save sprites
group_vertically(0x9,0xb)
group_vertically(0xa,0xc)
group_vertically(0xd,0xf)
group_vertically(0xe,0x10)
group_vertically(0x1,0x3)
group_vertically(0x2,0x4)


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
                        (sprites_used_colors if is_sprite else bobs_used_colors)[color] += 1
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

brown_rock_color = (0x84,0x51,0x00)
blue_dark_mountain_color = (0,0,0xFF)

all_bob_colors = sorted(bobs_used_colors)[1:]
all_bob_colors.remove(brown_rock_color)

bob_global_palette = background_palette + all_bob_colors
if len(bob_global_palette) != 16:
    # error if not enough colors, no need to hack to shoehorn it
    # if too many colors, we can't use 4 bitplanes!
    raise Exception("global bob palette should have exactly 16 colors, found {}".format(len(bob_global_palette)))

# hack to make tile & sprite palette partially match for "moon patrol" approx colors
# one thing we can't do: change order of colors for first half of bob palette (mountains)
# for tiles we have no constraints
#switch_values(tile_global_palette,3,5)
switch_values(bob_global_palette,14,15)
# same for ground (same pos)

orange_color_index = 12
switch_values(bob_global_palette,6,orange_color_index)
# then remove 0,0,26 color which is very close from another to set orange
almost_black_color = bob_global_palette[orange_color_index]
bob_global_palette[orange_color_index] =tile_global_palette[orange_color_index]
deep_brown_color = bob_global_palette[orange_color_index]
# needed to have exactly 16 colors
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
                character_codes.append(bitplanelib.palette_image2raw(img,None,tile_global_palette,generate_mask=True))
            else:
                character_codes.append(None)
            if dump_tiles:
                scaled = ImageOps.scale(img,5,0)
                scaled.save(os.path.join(dump_tiles_dir,f"char_{k:02x}_{cidx}.png"))
        character_codes_list.append(character_codes)




bitplane_cache = dict()
plane_next_index = 0


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
            if k not in sprites:
                sprites[k] = {"is_sprite":is_sprite,"name":name,"hsize":hsize}
            cs = sprites[k]

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
                    cs["bitmap"] = bitplanelib.palette_image2sprite(img,None,spritepal,
                            palette_precision_mask=0xFF,sprite_fmode=0,with_control_words=True)
            else:
                # software sprites (bobs) need one copy of bitmaps per palette setup. There are 3 or 4 planes
                # (4 ATM but will switch to dual playfield)
                # but not all planes are active as game sprites have max 3 colors (+ transparent)
                if "bitmap" not in cs:
                    cs["bitmap"] = dict()

                csb = cs["bitmap"]

                # prior to dump the image to amiga bitplanes, don't forget to replace brown by blue
                # as we forcefully removed it from the palette to make it fit to 16 colors, don't worry, the
                # copper will put the proper color back again
                img_to_raw = replace_color(img,brown_rock_color,blue_dark_mountain_color)
                img_to_raw = replace_color(img_to_raw,almost_black_color,deep_brown_color)

                bitplanes = bitplanelib.palette_image2raw(img_to_raw,None,bob_global_palette,forced_nb_planes=NB_BOB_PLANES,
                    palette_precision_mask=0xFF,generate_mask=True,blit_pad=True,mask_color=transparent)
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

                csb[cidx] = plane_list
        if dump_sprites:
            scaled = ImageOps.scale(img,2,0)
            if sprconf:
                scaled.save(os.path.join(dump_sprites_dir,f"{name}_{cidx}.png"))
            else:
                scaled.save(os.path.join(uncategorized_dump_sprites_dir,f"sprites_{k:02x}_{cidx}.png"))


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
            hw_sprite_flag[k] = 1


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

    f.write("bob_table:\n")

    bob_names = [None]*NB_POSSIBLE_SPRITES
    for i in range(NB_POSSIBLE_SPRITES):
        sprite = sprites.get(i)
        f.write("\t.long\t")
        if sprite:
            if sprite == True or sprite["is_sprite"]:
                f.write("-1")  # hardware sprite: ignore
            else:
                name = sprite["name"]
                bob_names[i] = name
                f.write(name)

        else:
            f.write("0")
        f.write("\n")

    for i in range(NB_POSSIBLE_SPRITES):
        name = bob_names[i]
        if name:
            sprite = sprites.get(i)
            f.write(f"{name}:\n")
            csb = sprite["bitmap"]
            for j in range(16):
                b = csb.get(j)
                f.write("\t.long\t")
                if b:
                    f.write(f"{name}_{j}")
                else:
                    f.write("0")   # clut not active
                f.write("\n")

    # blitter objects (bitplanes refs, can be in fastmem)
    for i in range(NB_POSSIBLE_SPRITES):
        name = bob_names[i]
        if name:
            sprite = sprites.get(i)
            bitmap = sprite["bitmap"]
            for j in range(16):
                bm = bitmap.get(j)
                if bm:
                    sprite_label = f"{name}_{j}"
                    f.write(f"{sprite_label}:\n")
                    for plane_id in bm:
                        f.write("\t.long\t")
                        if plane_id is None:
                            f.write("0")
                        else:
                            f.write(f"plane_{plane_id}")
                        f.write("\n")

    f.write("\t.section\t.datachip\n")
    # sprites
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

    f.write("\n* bitplanes\n")
    # dump bitplanes
    for k,v in bitplane_cache.items():
        f.write(f"plane_{v}:")
        bitplanelib.dump_asm_bytes(k,f,mit_format=True)

    f.write("\n* backgrounds\n")
    backgrounds = ['blue_mountains', 'green_mountains', 'green_city']

    # we only need 8 first colors (actually even less)
    bg_palette = bob_global_palette[:8]

    for b in backgrounds:
        f.write(f"{b}:\n")
        data = block_dict[b]["data"]
        nb_rows = len(data)
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
        # dump, we don't need a mask for the blue layer as it's behind

        raw = bitplanelib.palette_image2raw(img,None,bg_palette,forced_nb_planes=3,
                    palette_precision_mask=0xFF,generate_mask="green" in b,blit_pad=True)
        nb_planes = 4 if "green" in b else 3
        plane_size = len(raw)//nb_planes
        for z in range(nb_planes):
            f.write(f"\n* plane {z} ({plane_size} bytes)")
            dump_asm_bytes(raw[z*plane_size:(z+1)*plane_size],f)
