import re,os,asm_utils,json

instruction_re = re.compile("(\w{4}):(.*)")
instruction_re_comment = re.compile("(\w{4}):([^;]*);(.*)")

def read_mame_disassembly(filepath):
    d = {}
    with open(filepath) as f:
        for line in f:
            m = instruction_re_comment.match(line)
            if m:
                d[m.group(1)] = {"comment":m.group(3),"code":m.group(2).strip()}
    return d

# script to auto-report comments from a commented disassembly that I
# found only recently and mine. Infuriating to miss such things but that
# can be fixed somehow

commented_file = "../src/mpatrol_z80_commented.asm"
uncommented_file = "../src/mpatrol_z80.asm"
mixed_file = "../src/mpatrol_z80_mixed.asm"

d = read_mame_disassembly(commented_file)
##with open(uncommented_file) as f, open(mixed_file,"w") as fw:
##    for line in f:
##        m = instruction_re.match(line)
##        if m:
##            key = m.group(1)
##            info = d.get(key)
##            if info:
##                comment = info["comment"]
##                if comment.strip():
##                    start = line.rstrip()
##
##                    line = start + " "*(50-len(start)) +";"+comment+"\n"
##        fw.write(line)

named_variables = {}
with open(uncommented_file) as f:
    for line in f:
        m = instruction_re.match(line)
        if m:
            key = m.group(1)
            info = d.get(key)
            if info:
                code2 = re.sub(";.*","",m.group(2))
                toks1 = info["code"].split()
                toks2 = code2.split()
                if [x.lower() for x in toks1] != [x.lower() for x in toks2]:
                    # something is different, probably a renaming
                    for t1,t2 in zip(toks1,toks2):
                        # assuming size is the same, which is true
                        if t1.lower() != t2.lower():
                            args1 = [x for x in t1.split(",") if x not in "Aa"]
                            args2 = [x for x in t2.split(",") if x not in "Aa"]
                            for a1,a2 in zip(args1,args2):
                                a1 = a1.strip("()")
                                a2 = a2.strip("()")
                                if a1.lower() != a2.lower():
                                    # is a1 meaningful?
                                    if a1 not in "Aa" and (len(a1)!=5 or a1[0] not in 'm$') and a1[0]!="$":
                                        # a2 has offset appended
                                        old_name_parts = a2.split("_")
                                        if len(old_name_parts)==1:
                                            offset = a2.strip("$")
                                        else:
                                            offset = old_name_parts[-1]

                                        a1 = re.sub("([A-Z])([a-z])",lambda m : "_"+m.group(1).lower()+m.group(2),a1.replace("?","_"))
                                        a1 = a1.strip("_")
                                        named_variables[a2] = a1+"_"+offset.lower()

with open("replacement.json","w") as f:
    json.dump(named_variables,f,indent=2)
