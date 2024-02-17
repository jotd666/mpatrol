import json,re

with open("rep.json") as f:
    repdict = json.load(f)

def replace(infile,outfile):
    with open(infile) as f:
        contents = f.read()
    for k,v in repdict.items():
        k = r"\b{}\b".format(re.escape(k))
        contents = re.sub(k,v,contents)
    with open(outfile,"w") as f:
        f.write(contents)

replace("../src/mpatrol.68k","../src/mpatrol_named.68k")
replace("../src/mpatrol_game_ram.68k","../src/mpatrol_game_ram_named.68k")
replace("../src/mpatrol_z80.asm","../src/mpatrol_z80_named.asm")
