import re,os,asm_utils

instruction_re = re.compile("(\w{4}):(.*)")
instruction_re_comment = re.compile("(\w{4}):([^;]*);(.*)")

def read_mame_disassembly(filepath):
    d = {}
    with open(filepath) as f:
        for line in f:
            m = instruction_re_comment.match(line)
            if m:
                d[m.group(1)] = m.group(3)
    return d

# script to auto-report comments from a commented disassembly that I
# found only recently and mine. Infuriating to miss such things but that
# can be fixed somehow

commented_file = "../src/mpatrol_z80_commented.asm"
uncommented_file = "../src/mpatrol_z80.asm"
mixed_file = "../src/mpatrol_z80_mixed.asm"

d = read_mame_disassembly(commented_file)
with open(uncommented_file) as f, open(mixed_file,"w") as fw:
    for line in f:
        m = instruction_re.match(line)
        if m:
            key = m.group(1)
            comment = d.get(key,"")
            if comment.strip():
                start = line.rstrip()

                line = start + " "*(50-len(start)) +";"+comment+"\n"
        fw.write(line)
