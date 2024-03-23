import bitplanelib


def doit(asm_output):
    width = 32   # FMODE=1 (64 for FMODE=3)
    wmask = width-1
    scroll_table = [0]*256

    items = []
    for x in range(0,256):
        shift = (wmask-(x & wmask))
        offset = (x // width)*(width//8)
        # pre-encode shift for bplcon

        shiftval_msb = ((shift&(wmask & 0x30))>>2)
        items.append(shiftval_msb | 0xC0) # put max shift for other playfield
        shiftval_lsb = (shift&0xF)
        items.append(0xF0 | shiftval_lsb) # put max shift for other playfield

        items.append(0)
        items.append(offset)

    if asm_output:
        with open(asm_output,"w") as f:
            bitplanelib.dump_asm_bytes(bytes(items),f,True)
    return items

if __name__ == "__main__":
    doit(None)