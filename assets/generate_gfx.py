# generate equivalent of Mark C format _gfx.* from MAME tilesaving edition gfxrips

from PIL import Image,ImageOps
import os,glob,collections,itertools,bitplanelib

this_dir = os.path.abspath(os.path.dirname(__file__))
game_name = "mpatrol"
indir = os.path.join(this_dir,game_name)
palette_name = "palette0 *_0000.txt"
groups = {0:{"name":"tile"},1:{"name":"sprite"}}
text_bitmap = " .=#"



def process_background_layer(layer_image_path,global_palette):
    img = Image.open(layer_image_path)

    # collect colors. 4 max
    palette = set()
    matrix = []
    for y in range(img.size[1]):
        line_colors = set()
        line = []
        for x in range(img.size[0]):
            pixel = img.getpixel((x,y))
            line.append(pixel)
            line_colors.add(pixel)
            palette.add(pixel)
        matrix.append(line)
        xx = set(line_colors)
        if y>10 and len(xx)==1:
            # from now on only uniform color: stop there
            matrix.pop()
            break

    # convert RGB to palette
    palette = sorted(palette)  # black is first this way
    if len(palette)>4:
        raise Exception(f"Palette is too big for {layer_image_path}")

    # quick lookup
    palette = {rgb:i for i,rgb in enumerate(global_palette)}
    matrix = [[palette[x] for x in line] for line in matrix]
    return matrix

global_background_palette = set()

backgrounds = ["green_mountains","blue_mountains","green_city"]

# we need a global palette for the backgrounds
for image in backgrounds:
    global_background_palette.update(bitplanelib.palette_extract(os.path.join(indir,image+".png")))

global_background_palette = sorted(global_background_palette)

background_dict = {image:process_background_layer(os.path.join(indir,image+".png"),global_background_palette) for image in backgrounds}

def read_palette(palette_name):
    # dumped text file has a damn BOM
    palette_file = glob.glob(os.path.join(indir,palette_name))
    if not palette_file:
        raise Exception(f"Cannot locate palette wildcard {palette_name} in {indir}")
    with open(palette_file[0],encoding='utf-8-sig') as f:
        line = next(f).split()
        nb_colors = int(line[0])
        next(f)
        next(f)
        palette = []
        for line in f:
            toks = line.strip().split(",")
            r,g,b,a = map(int,toks)
            palette.append((r,g,b))
    return palette

sprites_palette = read_palette("palette0 colors 32_0000.txt")[:16]
tiles_palette = read_palette("palette1 512_0000.txt")[:88]
raw_sc = read_palette("palette0 pens 256_0000.txt")[:128]
sprite_cluts = []
# skip every odd clut (black)
for i in range(0,128,8):
    sprite_cluts.extend(raw_sc[i:i+4])

def get_sprite_clut(tile_group_index,clut_index):
    return sprite_cluts[clut_index*4:clut_index*4+4]
def get_tile_clut(tile_group_index,clut_index):
    # for this game it's just palette blocks in order
    return tiles_palette[clut_index*4:clut_index*4+4]


def load_tileset(sheet_name):
    gfxset_file = os.path.join(indir,sheet_name)
    img = Image.open(gfxset_file)
    nbc = count_color(img)
    if nbc != 4:
        raise Exception(f"{sheet_name}: not enough colors, pick another image")
    return img

def count_color(image):
    rval = set()
    for x in range(image.size[0]):
        for y in range(image.size[1]):
            p = image.getpixel((x,y))
            rval.add(p)

    return len(rval)

def write_tiles(blocks,size,f):
    for i,data in enumerate(blocks):
        f.write(f"  // ${i:X}\n  {{\n   ")
        offset = 0
        for k in range(size[1]):
            for j in range(size[0]):
                f.write("0x{:02d},".format(data[offset+j]))
            f.write("    // ")
            for j in range(size[0]):
                f.write(text_bitmap[data[offset+j]])
            f.write("\n   ")
            offset+=size[0]
        f.write("   },\n")


# I did the color lookup manually to pick sprite sheets with 4 distinct colors
# (with less colors it's not possible to rebuild the actual data)
max_col_image = dict()

sprite_pic = load_tileset("sprites.png")

max_col_image[1] = {"clut_index":1, "pic":sprite_pic, "tile_size":16,"get_clut":get_sprite_clut}

tile_pic = load_tileset("tiles.png")
max_col_image[0] = {"clut_index":0, "pic":tile_pic, "tile_size":8,"get_clut":get_tile_clut}


blocks = []
for k,v in max_col_image.items():
    block = []

    clut_index = v["clut_index"]
    w = h = v["tile_size"]
    img = v["pic"]
    nb_cols = img.size[0]//w
    nb_rows = img.size[1]//h
    nb_items = nb_cols*nb_rows
    groups[k]["dims"] = (w,h)

    get_clut = v["get_clut"]
    clut = get_clut(k,clut_index)
    for sy in range(0,img.size[1],h):
        for sx in range(0,img.size[0],w):
            # for each tile
            data = []
            # all tiles & sprites are flipped & mirrored in MAME dump
            for y in range(sy,sy+h):
                for x in range(sx,sx+w):
                    rgb = img.getpixel((x,y))
                    try:
                        idx = clut.index(rgb)
                    except ValueError:
                        print(f"Warning: '{v}': {sx//w},{sy//h}: {rgb} not in clut {clut}")
                    data.append(idx)
            block.append(data)
    groups[k]["data"] = block

if True:
    with open(os.path.join(this_dir,f"{game_name}_gfx.h"),"w") as f:
        inc_protect = f"__{game_name.upper()}_GFX_H__"
        f.write(f"""#ifndef {inc_protect}
#define {inc_protect}

#define NUM_TILES_COLOURS {len(tiles_palette)}
#define NUM_SPRITES_COLOURS {len(sprites_palette)}

#define NUM_TILES {len(groups[0]["data"])*2}
#define NUM_SPRITES {len(groups[1]["data"])}

#endif //  {inc_protect}
"""
)
    with open(os.path.join(this_dir,f"{game_name}_gfx.c"),"w") as f:
        f.write(f"""#include "{game_name}_gfx.h"

    // tile data
    """)
        tiles = groups[0]
        size = tiles["dims"]
        nb = size[0]*size[1]
        f.write(f"uint8_t tile[NUM_TILES][{nb}] =\n{{")
        blocks = groups[0]["data"]
        write_tiles(blocks,size,f)

        f.write("""};\n
    // sprite data
    """)
        tiles = groups[1]
        size = tiles["dims"]
        nb = size[0]*size[1]
        f.write(f"uint8_t sprite[NUM_SPRITES][{nb}] =\n{{")
        blocks = tiles["data"]
        write_tiles(blocks,size,f)

        f.write("""};\n   // cluts

    uint8_t sprite_clut[NUM_CLUTS][4] =
    {
      """)

        nb_items=0
        for i in range(0,len(sprite_cluts),4):
            f.write("{")
            for j in range(4):
                color = sprite_cluts[i+j]
                idx = sprites_palette.index(color)
                f.write("{}".format(idx))
                if j != 3:
                    f.write(",")
            f.write("},\n")

        f.write("""};\n   // palette

    uint8_t sprite_palette[NUM_SPRITES_COLOURS][3] =
    {
      """)

        nb_items=0
        for p in sprites_palette:
            f.write("{{ {:3d},{:3d},{:3d} }},".format(*p))
            nb_items+=1
            if nb_items==4:
                nb_items=0
                f.write("\n  ")
            else:
                f.write("  ")

        f.write("""};\n   // palette

    uint8_t tile_palette[NUM_TILES_COLOURS][3] =
    {
      """)

        nb_items=0
        for p in tiles_palette:
            f.write("{{ {:3d},{:3d},{:3d} }},".format(*p))
            nb_items+=1
            if nb_items==4:
                nb_items=0
                f.write("\n  ")
            else:
                f.write("  ")
        f.write("\n};\n")

        f.write(f"""uint8_t background_palette[8][3] =
    {{
""")

        for p in global_background_palette:
            f.write("{{ {:3d},{:3d},{:3d} }},".format(*p))
        f.write("\n};\n")

        for image,matrix in background_dict.items():
            f.write(f"""uint8_t {image}[256][{len(matrix)}] =
    {{
""")
            for row in matrix:
                f.write("  {\n    ")
                nb_elts = 0
                for elt in row:
                    f.write(f"0x{elt:02x},")
                    nb_elts += 1
                    if nb_elts == 16:
                        nb_elts = 0
                        f.write("\n    ")
                f.write("  },\n")
            f.write("\n  };\n")


