import os,re

with open("../src/mpatrol.68k") as f:
    rams = set(re.findall("unknown_\w*E\w\w\w",f.read()))


varlist = {int(x.rsplit("_")[-1],16):x  for x in rams}


prev_offset = 0

with open("out.68k","w") as f:
    lst = []
    variables = []
    next_align = False
    for k,v in sorted(varlist.items()):
        if prev_offset:
            sz = str(k-prev_offset)

            lst.append(f"\tds.b\t{sz}\n")
        if v.startswith("$"):
            v = f"unknown_{v[1:].upper()}"

        variables.append(v)



        lst.append(f"{v}:\n")


        prev_offset = k

    lst.append(f"\tds.b\t{k-prev_offset}\n")
    for k in sorted(variables):
        f.write(f"\t.global\t{k}\n")
    f.write("\n")

    f.writelines(lst)