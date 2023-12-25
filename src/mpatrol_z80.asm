;
; Moon Patrol disassembly by JOTD
;
;/***************************************************************************
;
;    Irem M52 hardware
;
;****************************************************************************
;
;    Moon Patrol memory map
;
;    driver by Nicola Salmoria
;
;    0000-3fff ROM
;    8000-83ff Video RAM
;    8400-87ff Color RAM
;    e000-e7ff RAM
;
;
;    read:
;    8800      protection
;    d000      IN0
;    d001      IN1
;    d002      IN2
;    d003      DSW1
;    d004      DSW2
;
;    write:
;    c800-c8ff sprites
;    d000      sound command
;    d001      flip screen
;
;    I/O ports
;    write:
;    10-1f     scroll registers
;    40        background #1 x position
;    60        background #1 y position
;    80        background #2 x position
;    a0        background #2 y position
;    c0        background control


0000: F3          di
0001: 31 00 E8    ld   sp,$E800
0004: ED 56       im   1
0006: 3A 04 D0    ld   a,($D004)
0009: A7          and  a
000A: F2 00 33    jp   p,service_mode_3300
000D: CD F4 05    call clear_ram_05f4
0010: CD F2 06    call $06F2
0013: CD 29 0D    call $0D29
0016: C3 68 00    jp   $0068

; < HL: jump table
; < A: index
0028: 87          add  a,a
0029: 5F          ld   e,a
002A: 16 00       ld   d,$00
002C: 19          add  hl,de
002D: 5E          ld   e,(hl)
002E: 23          inc  hl
002F: 56          ld   d,(hl)
0030: EB          ex   de,hl
0031: E9          jp   (hl)

0038: 08          ex   af,af'
0039: D9          exx
003A: CD 6D 05    call $056D
003D: 21 4E E0    ld   hl,$E04E
0040: 34          inc  (hl)
0041: 7E          ld   a,(hl)
0042: 23          inc  hl
0043: E6 0F       and  $0F
0045: 20 01       jr   nz,$0048
0047: 34          inc  (hl)
0048: 23          inc  hl
0049: 35          dec  (hl)
004A: 23          inc  hl
004B: 35          dec  (hl)
004C: 3A 04 D0    ld   a,($D004)
004F: A7          and  a
0050: FA 93 00    jp   m,$0093
0053: 21 4E E0    ld   hl,$E04E
0056: 34          inc  (hl)
0057: 01 03 00    ld   bc,$0003
005A: 21 4E E0    ld   hl,$E04E
005D: 35          dec  (hl)
005E: 10 FE       djnz $005E
0060: 0D          dec  c
0061: 20 FB       jr   nz,$005E
0063: D9          exx
0064: 08          ex   af,af'
0065: FB          ei
0066: FB          ei
0067: C9          ret

0068: FB          ei
0069: CD 8A 0B    call display_status_bar_0b8a
006C: 3E 01       ld   a,$01
006E: 32 4D E0    ld   ($E04D),a
0071: 32 0F E5    ld   ($E50F),a
0074: 3C          inc  a
0075: 32 08 E5    ld   ($E508),a
0078: C3 B7 0B    jp   $0BB7
007B: 06 00       ld   b,$00
007D: AF          xor  a
007E: 32 4D E0    ld   ($E04D),a
0081: 21 46 E0    ld   hl,$E046
0084: 70          ld   (hl),b
0085: FB          ei
0086: CD 45 07    call $0745
0089: CD 8A 0B    call display_status_bar_0b8a
008C: C3 B7 0B    jp   $0BB7
008F: 06 04       ld   b,$04
0091: 18 EA       jr   $007D
0093: CD CB 05    call $05CB
0096: 3A 00 D0    ld   a,($D000)
0099: 2F          cpl
009A: 32 53 E0    ld   ($E053),a
009D: CB 4F       bit  1,a
009F: 28 15       jr   z,$00B6
00A1: 3A 04 D0    ld   a,($D004)
00A4: CB 67       bit  4,a
00A6: 20 0E       jr   nz,$00B6
00A8: 21 46 E0    ld   hl,$E046
00AB: CB 4E       bit  1,(hl)
00AD: 20 07       jr   nz,$00B6
00AF: 3A 00 D0    ld   a,($D000)
00B2: E6 01       and  $01
00B4: 20 F9       jr   nz,$00AF
00B6: 3A 04 D0    ld   a,($D004)
00B9: CB 5F       bit  3,a
00BB: 20 06       jr   nz,$00C3
00BD: 21 F3 E0    ld   hl,$E0F3
00C0: 34          inc  (hl)
00C1: CB 46       bit  0,(hl)
00C3: FD E5       push iy
00C5: DD E5       push ix
00C7: CD 0E 04    call $040E
00CA: 3A 41 E0    ld   a,($E041)
00CD: A7          and  a
00CE: 20 05       jr   nz,$00D5
00D0: 3E 02       ld   a,$02
00D2: 32 48 E0    ld   ($E048),a
00D5: 21 46 E0    ld   hl,$E046
00D8: 46          ld   b,(hl)
00D9: CB 78       bit  7,b
00DB: 20 15       jr   nz,$00F2
00DD: CB 48       bit  1,b
00DF: 20 1B       jr   nz,$00FC
00E1: 3A 48 E0    ld   a,($E048)
00E4: A7          and  a
00E5: 20 1D       jr   nz,$0104
00E7: CB 50       bit  2,b
00E9: 20 11       jr   nz,$00FC
00EB: 3A 47 E0    ld   a,($E047)
00EE: A7          and  a
00EF: C2 8F 00    jp   nz,$008F
00F2: CB 40       bit  0,b
00F4: 28 06       jr   z,$00FC
00F6: CD 7A 04    call $047A
00F9: CD EC 01    call $01EC
00FC: DD E1       pop  ix
00FE: FD E1       pop  iy
0100: D9          exx
0101: 08          ex   af,af'
0102: FB          ei
0103: C9          ret
0104: 36 02       ld   (hl),$02
0106: 31 00 E8    ld   sp,$E800
0109: FB          ei
010A: CD 29 0D    call $0D29
010D: CD 33 05    call $0533
0110: 28 FB       jr   z,$010D
0112: CD 38 0B    call $0B38
0115: C3 B7 0B    jp   $0BB7
0118: 31 00 E8    ld   sp,$E800
011B: 21 46 E0    ld   hl,$E046
011E: 35          dec  (hl)
011F: FB          ei
0120: F2 68 00    jp   p,$0068
0123: CD 96 0B    call $0B96
0126: AF          xor  a
0127: 32 A6 E1    ld   ($E1A6),a
012A: 21 15 E5    ld   hl,nb_lives_E515
012D: 35          dec  (hl)
012E: 28 1B       jr   z,$014B
0130: CD D5 06    call $06D5
0133: 21 46 E0    ld   hl,$E046
0136: CB 66       bit  4,(hl)
0138: CA B7 0B    jp   z,$0BB7
013B: CD 03 06    call $0603
013E: 3A 15 E5    ld   a,(nb_lives_E515)
0141: A7          and  a
0142: C2 B7 0B    jp   nz,$0BB7
0145: CD 03 06    call $0603
0148: C3 B7 0B    jp   $0BB7
014B: 3E 1B       ld   a,$1B
014D: CD 75 0D    call $0D75
0150: 21 46 E0    ld   hl,$E046
0153: CB 66       bit  4,(hl)
0155: 28 1F       jr   z,$0176
0157: 21 ED 2A    ld   hl,$2AED
015A: CD 4E 03    call $034E
015D: 3A 46 E0    ld   a,($E046)
0160: 1F          rra
0161: 1F          rra
0162: 1F          rra
0163: E6 01       and  $01
0165: 3C          inc  a
0166: CD BD 03    call $03BD
0169: CD 03 06    call $0603
016C: CD E4 05    call $05E4
016F: 3A 15 E5    ld   a,(nb_lives_E515)
0172: A7          and  a
0173: C2 B7 0B    jp   nz,$0BB7
0176: 21 02 2B    ld   hl,$2B02
0179: CD 4E 03    call $034E
017C: CD 1C 06    call $061C
017F: 28 03       jr   z,$0184
0181: CD 03 06    call $0603
0184: CD E8 05    call $05E8
0187: CD 29 0D    call $0D29
018A: 21 2A 2A    ld   hl,$2A2A
018D: CD 00 03    call $0300
0190: 3E 11       ld   a,$11
0192: A7          and  a
0193: 28 3D       jr   z,$01D2
0195: 3D          dec  a
0196: 27          daa
0197: 32 54 E0    ld   ($E054),a
019A: 11 33 82    ld   de,$8233
019D: 0E 02       ld   c,$02
019F: CD AE 03    call $03AE
01A2: 3E 40       ld   a,$40
01A4: 32 50 E0    ld   ($E050),a
01A7: 3A 50 E0    ld   a,($E050)
01AA: A7          and  a
01AB: 3A 54 E0    ld   a,($E054)
01AE: 28 E2       jr   z,$0192
01B0: 3A 48 E0    ld   a,($E048)
01B3: A7          and  a
01B4: 20 0B       jr   nz,$01C1
01B6: 21 57 2C    ld   hl,$2C57
01B9: CD 74 03    call $0374
01BC: CD 27 05    call $0527
01BF: 18 E6       jr   $01A7
01C1: CD 33 05    call $0533
01C4: 28 E1       jr   z,$01A7
01C6: CD DA 01    call $01DA
01C9: CD DA 01    call $01DA
01CC: CD BF 0C    call $0CBF
01CF: C3 B7 0B    jp   $0BB7

01D2: F3          di
01D3: AF          xor  a
01D4: 32 46 E0    ld   ($E046),a
01D7: C3 68 00    jp   $0068

01DA: 3A 40 E0    ld   a,($E040)
01DD: 32 15 E5    ld   (nb_lives_E515),a
01E0: 21 00 00    ld   hl,$0000
01E3: 22 00 E5    ld   ($E500),hl
01E6: 22 02 E5    ld   ($E502),hl
01E9: C3 03 06    jp   $0603

01EC: DD 21 00 E3 ld   ix,$E300
01F0: 3E 20       ld   a,$20
01F2: 32 E8 E0    ld   ($E0E8),a
01F5: DD 7E 00    ld   a,(ix+$00)
01F8: 3D          dec  a
01F9: FA 00 02    jp   m,$0200
01FC: 21 0C 02    ld   hl,jump_table_020C
01FF: EF          rst  $28			; use jump table
0200: 11 10 00    ld   de,$0010
0203: DD 19       add  ix,de
0205: 21 E8 E0    ld   hl,$E0E8
0208: 35          dec  (hl)
0209: 20 EA       jr   nz,$01F5
020B: C9          ret

jump_table_020C:
	.word	$1311,$1331,$1370,$1388,$13BC,$13C2,$13EB,$1421
	.word	$1809,$15E0,$15FA,$162D,$162D,$1649,$165D,$168F
	.word	$193D,$1957,$195E,$19D1,$1A2F,$1A44,$1A92,$1AB9
	.word	$1AF0,$1B01,$1B27,$1433,$18E0,$1EAA,$1F28,$20AC
	.word	$20C4,$1EAA,$1F28,$2000,$201A,$1EA4,$1F28,$204D
	.word	$209C,$1D23,$1DF3,$1E51,$1E9B,$1C9B,$1CBC,$1E14
	.word	$1E29


0273: 21 CD 3A    ld   hl,$3ACD
0276: 1B          dec  de
0277: CD C7 1B    call $1BC7
027A: CD A7 12    call $12A7
027D: CD E7 12    call $12E7
0280: CD DC 0D    call $0DDC
0283: 3A CF E1    ld   a,($E1CF)
0286: 21 D0 E1    ld   hl,$E1D0
0289: BE          cp   (hl)
028A: 28 E2       jr   z,$026E
028C: 5F          ld   e,a
028D: 16 E6       ld   d,$E6
028F: DD 21 00 00 ld   ix,$0000
0293: DD 19       add  ix,de
0295: DD 4E 00    ld   c,(ix+$00)
0298: CB 21       sla  c
029A: 20 11       jr   nz,$02AD
029C: 21 CF E1    ld   hl,$E1CF
029F: BE          cp   (hl)
02A0: 20 03       jr   nz,$02A5
02A2: C6 04       add  a,$04
02A4: 77          ld   (hl),a
02A5: DD E5       push ix
02A7: C1          pop  bc
02A8: 79          ld   a,c
02A9: C6 04       add  a,$04
02AB: 18 D9       jr   $0286
02AD: 06 00       ld   b,$00
02AF: DD 70 00    ld   (ix+$00),b
02B2: DD 7E 01    ld   a,(ix+$01)
02B5: 21 A5 02    ld   hl,$02A5
02B8: E5          push hl
02B9: 21 D3 02    ld   hl,jump_table_02D3
02BC: 09          add  hl,bc
02BD: 4E          ld   c,(hl)
02BE: 23          inc  hl
02BF: 66          ld   h,(hl)
02C0: 69          ld   l,c
02C1: E9          jp   (hl)

02C2: 21 D0 E1    ld   hl,$E1D0
02C5: 6E          ld   l,(hl)
02C6: 26 E6       ld   h,$E6
02C8: 71          ld   (hl),c
02C9: 23          inc  hl
02CA: 77          ld   (hl),a
02CB: 23          inc  hl
02CC: 73          ld   (hl),e
02CD: 23          inc  hl
02CE: 72          ld   (hl),d
02CF: 2C          inc  l
02D0: 7D          ld   a,l
02D1: 32 D0 E1    ld   ($E1D0),a
02D4: C9          ret
; the jump table

jump_table_02D3
	.word	0		; overlaps ret instruction, probably never used
	.word	$0622
	.word	$02FA
	.word	$02ED
	.word	$0322
	.word	$032F
	.word	$0367
	.word	$0361
	.word	$0337
	.word	$0DA6
	.word	$1201
	.word	display_title_1218


02ED: 3A 4E E0    ld   a,($E04E)
02F0: DD 86 01    add  a,(ix+$01)
02F3: DD 77 01    ld   (ix+$01),a
02F6: DD 36 00 04 ld   (ix+$00),$04
02FA: DD 6E 02    ld   l,(ix+$02)
02FD: DD 66 03    ld   h,(ix+$03)
0300: CD DB 03    call $03DB
0303: 7E          ld   a,(hl)
0304: 06 12       ld   b,$12
0306: FE 26       cp   $26
0308: 28 06       jr   z,$0310
030A: 06 30       ld   b,$30
030C: FE 27       cp   $27
030E: 20 0D       jr   nz,$031D
0310: 23          inc  hl
0311: 78          ld   a,b
0312: 32 50 E0    ld   ($E050),a
0315: 3A 50 E0    ld   a,($E050)
0318: A7          and  a
0319: 20 FA       jr   nz,$0315
031B: 18 E6       jr   $0303
031D: CD C9 03    call $03C9
0320: 18 E1       jr   $0303
0322: 3A 4E E0    ld   a,($E04E)
0325: DD BE 01    cp   (ix+$01)
0328: 28 05       jr   z,$032F
032A: DD 36 00 04 ld   (ix+$00),$04
032E: C9          ret
032F: DD 6E 02    ld   l,(ix+$02)
0332: DD 66 03    ld   h,(ix+$03)
0335: 18 44       jr   $037B
0337: 3A 50 E0    ld   a,($E050)
033A: A7          and  a
033B: 20 0C       jr   nz,$0349
033D: CD 2F 03    call $032F
0340: DD 35 01    dec  (ix+$01)
0343: C8          ret  z
0344: 3E 04       ld   a,$04
0346: 32 50 E0    ld   ($E050),a
0349: DD 36 00 07 ld   (ix+$00),$07
034D: C9          ret
034E: CD DB 03    call $03DB
0351: CD C9 03    call $03C9
0354: 3E 03       ld   a,$03
0356: 32 50 E0    ld   ($E050),a
0359: 3A 50 E0    ld   a,($E050)
035C: A7          and  a
035D: 20 FA       jr   nz,$0359
035F: 18 F0       jr   $0351
0361: 3A 50 E0    ld   a,($E050)
0364: A7          and  a
0365: 20 08       jr   nz,$036F
0367: 3E 04       ld   a,$04
0369: 32 50 E0    ld   ($E050),a
036C: CD FA 02    call $02FA
036F: DD 36 00 08 ld   (ix+$00),$08
0373: C9          ret
0374: 3A 4E E0    ld   a,($E04E)
0377: CB 67       bit  4,a
0379: 20 85       jr   nz,$0300
037B: CD DB 03    call $03DB
037E: 7E          ld   a,(hl)
037F: 23          inc  hl
0380: FE 21       cp   $21
0382: C8          ret  z
0383: FE 23       cp   $23
0385: 28 09       jr   z,$0390
0387: FE 22       cp   $22
0389: 28 F0       jr   z,$037B
038B: AF          xor  a
038C: 12          ld   (de),a
038D: 13          inc  de
038E: 18 EE       jr   $037E
0390: 23          inc  hl
0391: 18 EB       jr   $037E
0393: 7E          ld   a,(hl)
0394: 13          inc  de
0395: E6 0F       and  $0F
0397: 28 04       jr   z,$039D
0399: 1B          dec  de
039A: CD A6 03    call $03A6
039D: 2B          dec  hl
039E: 7E          ld   a,(hl)
039F: 1F          rra
03A0: 1F          rra
03A1: 1F          rra
03A2: 1F          rra
03A3: CD A7 03    call $03A7
03A6: 7E          ld   a,(hl)
03A7: E6 0F       and  $0F
03A9: C6 30       add  a,$30
03AB: 12          ld   (de),a
03AC: 13          inc  de
03AD: C9          ret
03AE: FD 21 00 04 ld   iy,$0400
03B2: FD 19       add  iy,de
03B4: F5          push af
03B5: 1F          rra
03B6: 1F          rra
03B7: 1F          rra
03B8: 1F          rra
03B9: CD BD 03    call $03BD
03BC: F1          pop  af
03BD: E6 0F       and  $0F
03BF: C6 30       add  a,$30
03C1: 12          ld   (de),a
03C2: FD 71 00    ld   (iy+$00),c
03C5: 13          inc  de
03C6: FD 23       inc  iy
03C8: C9          ret
03C9: 7E          ld   a,(hl)
03CA: 23          inc  hl
03CB: FE 21       cp   $21
03CD: 28 33       jr   z,$0402
03CF: FE 23       cp   $23
03D1: 28 12       jr   z,$03E5
03D3: FE 25       cp   $25
03D5: 28 2D       jr   z,$0404
03D7: FE 22       cp   $22
03D9: 20 E6       jr   nz,$03C1
03DB: 5E          ld   e,(hl)
03DC: 23          inc  hl
03DD: 56          ld   d,(hl)
03DE: 23          inc  hl
03DF: FD 21 00 04 ld   iy,$0400
03E3: FD 19       add  iy,de
03E5: 4E          ld   c,(hl)
03E6: 23          inc  hl
03E7: 3A F9 E0    ld   a,($E0F9)
03EA: A7          and  a
03EB: C8          ret  z
03EC: 79          ld   a,c
03ED: A7          and  a
03EE: C8          ret  z
03EF: FE 03       cp   $03
03F1: 38 0B       jr   c,$03FE
03F3: FE 06       cp   $06
03F5: 28 03       jr   z,$03FA
03F7: FE 09       cp   $09
03F9: C0          ret  nz
03FA: C6 05       add  a,$05
03FC: 4F          ld   c,a
03FD: C9          ret
03FE: C6 0B       add  a,$0B
0400: 4F          ld   c,a
0401: C9          ret
0402: E1          pop  hl
0403: C9          ret
0404: 46          ld   b,(hl)
0405: 23          inc  hl
0406: 7E          ld   a,(hl)
0407: 23          inc  hl
0408: CD C1 03    call $03C1
040B: 10 FB       djnz $0408
040D: C9          ret
040E: 21 3E E0    ld   hl,$E03E
0411: 11 41 E0    ld   de,$E041
0414: 3A 00 D0    ld   a,($D000)
0417: 01 02 00    ld   bc,$0002
041A: CD 34 04    call $0434
041D: 21 3F E0    ld   hl,$E03F
0420: 13          inc  de
0421: 3A 02 D0    ld   a,($D002)
0424: 1F          rra
0425: F6 04       or   $04
0427: 0E 20       ld   c,$20
0429: CD 34 04    call $0434
042C: 3A 4C E0    ld   a,($E04C)
042F: B0          or   b
0430: 32 01 D0    ld   ($D001),a
0433: C9          ret
0434: 1F          rra
0435: 1F          rra
0436: 1F          rra
0437: CB 16       rl   (hl)
0439: 1F          rra
043A: CB 16       rl   (hl)
043C: 7E          ld   a,(hl)
043D: E6 55       and  $55
043F: FE 54       cp   $54
0441: 28 0E       jr   z,$0451
0443: 7E          ld   a,(hl)
0444: E6 AA       and  $AA
0446: C0          ret  nz
0447: 21 ED E0    ld   hl,$E0ED
044A: 34          inc  (hl)
044B: 7E          ld   a,(hl)
044C: E6 0F       and  $0F
044E: C0          ret  nz
044F: 18 19       jr   $046A
0451: 78          ld   a,b
0452: B1          or   c
0453: 47          ld   b,a
0454: 3E 13       ld   a,$13
0456: CD 7D 0D    call $0D7D
0459: 1A          ld   a,(de)
045A: FE 01       cp   $01
045C: 28 11       jr   z,$046F
045E: FE 08       cp   $08
0460: 30 0B       jr   nc,$046D
0462: 21 47 E0    ld   hl,$E047
0465: 34          inc  (hl)
0466: BE          cp   (hl)
0467: C0          ret  nz
0468: AF          xor  a
0469: 77          ld   (hl),a
046A: 3C          inc  a
046B: 18 02       jr   $046F
046D: D6 08       sub  $08
046F: 21 48 E0    ld   hl,$E048
0472: 86          add  a,(hl)
0473: 27          daa
0474: 30 02       jr   nc,$0478
0476: 3E 99       ld   a,$99
0478: 77          ld   (hl),a
0479: C9          ret
047A: 3A 46 E0    ld   a,($E046)
047D: 07          rlca
047E: 30 5B       jr   nc,$04DB
0480: 11 01 D0    ld   de,$D001
0483: CB 67       bit  4,a
0485: 28 07       jr   z,$048E
0487: 3A 43 E0    ld   a,($E043)
048A: 3D          dec  a
048B: 28 01       jr   z,$048E
048D: 13          inc  de
048E: 21 4A E0    ld   hl,$E04A
0491: 7E          ld   a,(hl)
0492: 23          inc  hl
0493: 77          ld   (hl),a
0494: 2B          dec  hl
0495: 1A          ld   a,(de)
0496: 2F          cpl
0497: 77          ld   (hl),a
0498: 2B          dec  hl
0499: E6 03       and  $03
049B: 77          ld   (hl),a
049C: C9          ret
049D: 3A 0B E5    ld   a,($E50B)
04A0: 2A F7 E0    ld   hl,($E0F7)
04A3: BE          cp   (hl)
04A4: 20 13       jr   nz,$04B9
04A6: 23          inc  hl
04A7: 7E          ld   a,(hl)
04A8: 54          ld   d,h
04A9: 5D          ld   e,l
04AA: 23          inc  hl
04AB: 22 F7 E0    ld   ($E0F7),hl
04AE: A7          and  a
04AF: 28 04       jr   z,$04B5
04B1: FE FF       cp   $FF
04B3: 20 D9       jr   nz,$048E
04B5: 32 E0 E1    ld   ($E1E0),a
04B8: C9          ret
04B9: 21 4A E0    ld   hl,$E04A
04BC: 3A E0 E1    ld   a,($E1E0)
04BF: A7          and  a
04C0: 28 13       jr   z,$04D5
04C2: 3A 4E E0    ld   a,($E04E)
04C5: 07          rlca
04C6: 47          ld   b,a
04C7: E6 01       and  $01
04C9: 3C          inc  a
04CA: 32 49 E0    ld   ($E049),a
04CD: 78          ld   a,b
04CE: E6 1E       and  $1E
04D0: 20 03       jr   nz,$04D5
04D2: 36 20       ld   (hl),$20
04D4: C9          ret
04D5: 7E          ld   a,(hl)
04D6: 36 FF       ld   (hl),$FF
04D8: 23          inc  hl
04D9: 77          ld   (hl),a
04DA: C9          ret
04DB: 21 4D E0    ld   hl,$E04D
04DE: 3A 4E E0    ld   a,($E04E)
04E1: 47          ld   b,a
04E2: 7E          ld   a,(hl)
04E3: A7          and  a
04E4: 28 B7       jr   z,$049D
04E6: FE 50       cp   $50
04E8: 28 1D       jr   z,$0507
04EA: CB 18       rr   b
04EC: 38 05       jr   c,$04F3
04EE: CB 18       rr   b
04F0: 38 01       jr   c,$04F3
04F2: 34          inc  (hl)
04F3: 0E 02       ld   c,$02
04F5: 21 49 E0    ld   hl,$E049
04F8: FE 18       cp   $18
04FA: 38 01       jr   c,$04FD
04FC: 0D          dec  c
04FD: 71          ld   (hl),c
04FE: 23          inc  hl
04FF: 36 00       ld   (hl),$00
0501: FE B0       cp   $B0
0503: D8          ret  c
0504: C3 7B 00    jp   $007B
0507: 21 00 E3    ld   hl,$E300
050A: 7E          ld   a,(hl)
050B: FE 04       cp   $04
050D: 20 0C       jr   nz,$051B
050F: 3A 09 E3    ld   a,($E309)
0512: 17          rla
0513: D8          ret  c
0514: 36 08       ld   (hl),$08
0516: 0E 0A       ld   c,$0A
0518: C3 C2 02    jp   $02C2
051B: FE 08       cp   $08
051D: C8          ret  z
051E: 21 4A E0    ld   hl,$E04A
0521: 36 20       ld   (hl),$20
0523: 23          inc  hl
0524: 36 00       ld   (hl),$00
0526: C9          ret
0527: 21 E2 2A    ld   hl,$2AE2
052A: CD 00 03    call $0300
052D: 3A 48 E0    ld   a,($E048)
0530: C3 AE 03    jp   $03AE
0533: 21 D1 2A    ld   hl,$2AD1
0536: CD 74 03    call $0374
0539: CD 27 05    call $0527
053C: 21 86 2A    ld   hl,$2A86
053F: 3A 48 E0    ld   a,($E048)
0542: 3D          dec  a
0543: 28 03       jr   z,$0548
0545: 21 97 2A    ld   hl,$2A97
0548: CD 00 03    call $0300
054B: 3A 53 E0    ld   a,($E053)
054E: E6 03       and  $03
0550: C8          ret  z
0551: 1F          rra
0552: 3A 48 E0    ld   a,($E048)
0555: 06 80       ld   b,$80
0557: 38 06       jr   c,$055F
0559: D6 01       sub  $01
055B: 27          daa
055C: C8          ret  z
055D: 06 90       ld   b,$90
055F: D6 01       sub  $01
0561: 27          daa
0562: F3          di
0563: 32 48 E0    ld   ($E048),a
0566: 78          ld   a,b
0567: 32 46 E0    ld   ($E046),a
056A: 3C          inc  a
056B: FB          ei
056C: C9          ret
056D: 21 00 E1    ld   hl,$E100
0570: 11 40 C8    ld   de,$C840
0573: 01 40 00    ld   bc,$0040
0576: ED B0       ldir
0578: 1E 20       ld   e,$20
057A: 0E 20       ld   c,$20
057C: ED B0       ldir
057E: 1E C0       ld   e,$C0
0580: 0E 40       ld   c,$40
0582: ED B0       ldir
0584: 11 A0 C8    ld   de,$C8A0
0587: 0E 20       ld   c,$20
0589: ED B0       ldir
058B: 0E 1C       ld   c,$1C
058D: 7E          ld   a,(hl)
058E: 06 04       ld   b,$04
0590: ED 79       out  (c),a
0592: 0C          inc  c
0593: 10 FB       djnz $0590
0595: 23          inc  hl
0596: 3A C3 E1    ld   a,($E1C3)
0599: A7          and  a
059A: 28 2B       jr   z,$05C7
059C: 7E          ld   a,(hl)
059D: E6 7F       and  $7F
059F: 01 40 00    ld   bc,$0040
05A2: CB 3F       srl  a
05A4: 30 01       jr   nc,$05A7
05A6: 04          inc  b
05A7: 20 F9       jr   nz,$05A2
05A9: 7E          ld   a,(hl)
05AA: 07          rlca
05AB: E6 01       and  $01
05AD: A8          xor  b
05AE: 5F          ld   e,a
05AF: ED A3       outi
05B1: 3A 00 88    ld   a,($8800)
05B4: E6 07       and  $07
05B6: BB          cp   e
05B7: C2 C3 00    jp   nz,$00C3
05BA: 0E 80       ld   c,$80
05BC: ED A3       outi
05BE: 0E 60       ld   c,$60
05C0: ED A3       outi
05C2: 0E A0       ld   c,$A0
05C4: ED A3       outi
05C6: 7E          ld   a,(hl)
05C7: 2F          cpl
05C8: D3 C0       out  ($C0),a
05CA: C9          ret
05CB: 2A DD E1    ld   hl,($E1DD)
05CE: 7D          ld   a,l
05CF: BC          cp   h
05D0: C8          ret  z
05D1: 26 E0       ld   h,$E0
05D3: 7E          ld   a,(hl)
05D4: 32 00 D0    ld   ($D000),a
05D7: CB FF       set  7,a
05D9: 32 00 D0    ld   ($D000),a
05DC: 7D          ld   a,l
05DD: 3C          inc  a
05DE: E6 07       and  $07
05E0: 32 DD E1    ld   ($E1DD),a
05E3: C9          ret
05E4: 3E 40       ld   a,$40
05E6: 18 02       jr   $05EA
05E8: 3E C0       ld   a,$C0
05EA: 32 50 E0    ld   ($E050),a
05ED: 3A 50 E0    ld   a,($E050)
05F0: A7          and  a
05F1: 20 FA       jr   nz,$05ED
05F3: C9          ret

clear_ram_05f4:
05F4: 21 00 E0    ld   hl,$E000
05F7: 01 00 07    ld   bc,$0700
; < HL: start
; < BC: length
clear_area_05fa:
05FA: 36 00       ld   (hl),$00
05FC: 23          inc  hl
05FD: 0B          dec  bc
05FE: 78          ld   a,b
05FF: B1          or   c
0600: 20 F8       jr   nz,clear_area_05fa
0602: C9          ret

0603: 21 46 E0    ld   hl,$E046
0606: 7E          ld   a,(hl)
0607: EE 08       xor  $08
0609: 77          ld   (hl),a
060A: 21 00 E5    ld   hl,$E500
060D: 11 18 E5    ld   de,$E518
0610: 06 18       ld   b,$18
0612: 1A          ld   a,(de)
0613: 4F          ld   c,a
0614: 7E          ld   a,(hl)
0615: 12          ld   (de),a
0616: 71          ld   (hl),c
0617: 23          inc  hl
0618: 13          inc  de
0619: 10 F7       djnz $0612
061B: C9          ret
061C: 3A 46 E0    ld   a,($E046)
061F: CB 5F       bit  3,a
0621: C9          ret
0622: 4F          ld   c,a
0623: 81          add  a,c
0624: 81          add  a,c
0625: 4F          ld   c,a
0626: 06 00       ld   b,$00
0628: 21 0C 2A    ld   hl,$2A0C
062B: 09          add  hl,bc
062C: 3A 46 E0    ld   a,($E046)
062F: A7          and  a
0630: F0          ret  p
0631: 11 00 E5    ld   de,$E500
0634: 06 03       ld   b,$03
0636: A7          and  a
0637: 1A          ld   a,(de)
0638: 8E          adc  a,(hl)
0639: 27          daa
063A: 12          ld   (de),a
063B: 13          inc  de
063C: 23          inc  hl
063D: 10 F8       djnz $0637
063F: CD AF 06    call $06AF
0642: 06 03       ld   b,$03
0644: 11 00 E5    ld   de,$E500
0647: 21 08 E0    ld   hl,$E008
064A: A7          and  a
064B: 1A          ld   a,(de)
064C: 9E          sbc  a,(hl)
064D: 23          inc  hl
064E: 13          inc  de
064F: 10 FA       djnz $064B
0651: 38 15       jr   c,$0668
0653: 2A 00 E5    ld   hl,($E500)
0656: 22 08 E0    ld   ($E008),hl
0659: 3A 02 E5    ld   a,($E502)
065C: 32 0A E0    ld   ($E00A),a
065F: 3A 0E E5    ld   a,($E50E)
0662: 32 0B E0    ld   ($E00B),a
0665: CD 85 06    call $0685
0668: 11 84 80    ld   de,$8084
066B: CD 1C 06    call $061C
066E: 28 03       jr   z,$0673
0670: 11 A4 80    ld   de,$80A4
0673: 21 02 E5    ld   hl,$E502
0676: 0E 01       ld   c,$01
0678: CD E7 03    call $03E7
067B: 06 03       ld   b,$03
067D: 7E          ld   a,(hl)
067E: CD AE 03    call $03AE
0681: 2B          dec  hl
0682: 10 F9       djnz $067D
0684: C9          ret
0685: 21 0B E0    ld   hl,$E00B
0688: 7E          ld   a,(hl)
0689: 0E 09       ld   c,$09
068B: FE 1B       cp   $1B
068D: 38 04       jr   c,$0693
068F: D6 1A       sub  $1A
0691: 0E 06       ld   c,$06
0693: C6 40       add  a,$40
0695: 32 4A 80    ld   ($804A),a
0698: 3A F9 E0    ld   a,($E0F9)
069B: 1F          rra
069C: 79          ld   a,c
069D: 30 02       jr   nc,$06A1
069F: C6 05       add  a,$05
06A1: 32 4A 84    ld   ($844A),a
06A4: 11 43 80    ld   de,$8043
06A7: 0E 09       ld   c,$09
06A9: CD E7 03    call $03E7
06AC: 2B          dec  hl
06AD: 18 CC       jr   $067B
06AF: 2A 01 E5    ld   hl,($E501)
06B2: 3A 45 E0    ld   a,($E045)
06B5: 3D          dec  a
06B6: F8          ret  m
06B7: 3D          dec  a
06B8: 28 01       jr   z,$06BB
06BA: 24          inc  h
06BB: CB 2C       sra  h
06BD: 25          dec  h
06BE: 3C          inc  a
06BF: 7C          ld   a,h
06C0: 20 05       jr   nz,$06C7
06C2: A7          and  a
06C3: 28 02       jr   z,$06C7
06C5: 3E FE       ld   a,$FE
06C7: 21 03 E5    ld   hl,$E503
06CA: BE          cp   (hl)
06CB: C0          ret  nz
06CC: 7E          ld   a,(hl)
06CD: FE 03       cp   $03
06CF: C8          ret  z
06D0: 34          inc  (hl)
06D1: 21 15 E5    ld   hl,nb_lives_E515
06D4: 34          inc  (hl)
06D5: 3A 15 E5    ld   a,(nb_lives_E515)
06D8: 3D          dec  a
06D9: 28 03       jr   z,$06DE
06DB: 4F          ld   c,a
06DC: 3E 01       ld   a,$01
06DE: 21 7C 80    ld   hl,$807C
06E1: CD EC 06    call $06EC
06E4: CD EC 06    call $06EC
06E7: 28 03       jr   z,$06EC
06E9: 79          ld   a,c
06EA: C6 30       add  a,$30
06EC: 77          ld   (hl),a
06ED: 23          inc  hl
06EE: A7          and  a
06EF: C8          ret  z
06F0: 3C          inc  a
06F1: C9          ret

06F2: 21 40 E0    ld   hl,$E040
06F5: 3A 03 D0    ld   a,($D003)
06F8: 47          ld   b,a
06F9: 3C          inc  a
06FA: E6 03       and  $03
06FC: 20 02       jr   nz,$0700
06FE: 3E 05       ld   a,$05
0700: 77          ld   (hl),a
0701: 23          inc  hl
0702: 78          ld   a,b
0703: 0F          rrca
0704: 0F          rrca
0705: 47          ld   b,a
0706: E6 03       and  $03
0708: 32 45 E0    ld   ($E045),a
070B: 3A 04 D0    ld   a,($D004)
070E: CB 57       bit  2,a
0710: 78          ld   a,b
0711: 28 1F       jr   z,$0732
0713: 1F          rra
0714: 1F          rra
0715: ED 44       neg
0717: E6 0F       and  $0F
0719: CB 5F       bit  3,a
071B: 28 01       jr   z,$071E
071D: 3C          inc  a
071E: 77          ld   (hl),a
071F: 23          inc  hl
0720: 77          ld   (hl),a
0721: 3A 04 D0    ld   a,($D004)
0724: 2F          cpl
0725: 1F          rra
0726: 47          ld   b,a
0727: E6 01       and  $01
0729: 23          inc  hl
072A: 77          ld   (hl),a
072B: 78          ld   a,b
072C: 1F          rra
072D: E6 01       and  $01
072F: 23          inc  hl
0730: 77          ld   (hl),a
0731: C9          ret
0732: 1F          rra
0733: 1F          rra
0734: 2F          cpl
0735: 47          ld   b,a
0736: 3C          inc  a
0737: E6 03       and  $03
0739: 77          ld   (hl),a
073A: 78          ld   a,b
073B: 1F          rra
073C: 1F          rra
073D: E6 03       and  $03
073F: FE 02       cp   $02
0741: DE F5       sbc  a,$F5
0743: 18 DA       jr   $071F
0745: CD 29 0D    call $0D29
0748: 21 97 2C    ld   hl,$2C97
074B: CD 00 03    call $0300
074E: CD 27 05    call $0527
0751: 21 57 2C    ld   hl,$2C57
0754: CD 4E 03    call $034E
0757: 11 54 E0    ld   de,$E054
075A: 01 20 00    ld   bc,$0020
075D: 3A 44 E0    ld   a,($E044)
0760: A7          and  a
0761: 20 34       jr   nz,$0797
0763: CD 9F 07    call $079F
0766: CD E8 07    call $07E8
0769: 7E          ld   a,(hl)
076A: FE 32       cp   $32
076C: 20 20       jr   nz,$078E
076E: 3E 53       ld   a,$53
0770: 32 5F E0    ld   ($E05F),a
0773: 32 68 E0    ld   ($E068),a
0776: 21 62 E0    ld   hl,$E062
0779: 7E          ld   a,(hl)
077A: 87          add  a,a
077B: D6 30       sub  $30
077D: FE 3A       cp   $3A
077F: 38 06       jr   c,$0787
0781: D6 0A       sub  $0A
0783: 77          ld   (hl),a
0784: 2B          dec  hl
0785: 3E 31       ld   a,$31
0787: 77          ld   (hl),a
0788: 21 54 E0    ld   hl,$E054
078B: CD 4E 03    call $034E
078E: 3A 47 E0    ld   a,($E047)
0791: A7          and  a
0792: 20 FA       jr   nz,$078E
0794: C3 E8 05    jp   $05E8
0797: CD D3 07    call $07D3
079A: CD DD 07    call $07DD
079D: 18 E9       jr   $0788
079F: 21 67 2C    ld   hl,$2C67
07A2: ED B0       ldir
07A4: 21 57 E0    ld   hl,$E057
07A7: 3A 41 E0    ld   a,($E041)
07AA: 11 08 00    ld   de,$0008
07AD: FE 08       cp   $08
07AF: 38 12       jr   c,$07C3
07B1: C6 28       add  a,$28
07B3: 77          ld   (hl),a
07B4: 19          add  hl,de
07B5: 36 53       ld   (hl),$53
07B7: 23          inc  hl
07B8: 23          inc  hl
07B9: 23          inc  hl
07BA: 36 31       ld   (hl),$31
07BC: 11 06 00    ld   de,$0006
07BF: 19          add  hl,de
07C0: 36 00       ld   (hl),$00
07C2: C9          ret
07C3: 3D          dec  a
07C4: C8          ret  z
07C5: 11 0B 00    ld   de,$000B
07C8: 19          add  hl,de
07C9: C6 31       add  a,$31
07CB: 77          ld   (hl),a
07CC: 11 06 00    ld   de,$0006
07CF: 19          add  hl,de
07D0: 36 53       ld   (hl),$53
07D2: C9          ret
07D3: 21 7D 2C    ld   hl,$2C7D
07D6: ED B0       ldir
07D8: 21 5B E0    ld   hl,$E05B
07DB: 18 CA       jr   $07A7
07DD: CD E8 07    call $07E8
07E0: 21 5B E0    ld   hl,$E05B
07E3: 3A 42 E0    ld   a,($E042)
07E6: 18 C2       jr   $07AA
07E8: 21 54 E0    ld   hl,$E054
07EB: CD 4E 03    call $034E
07EE: 2A 54 E0    ld   hl,($E054)
07F1: 11 40 00    ld   de,$0040
07F4: 19          add  hl,de
07F5: 22 54 E0    ld   ($E054),hl
07F8: 21 57 E0    ld   hl,$E057
07FB: 34          inc  (hl)
07FC: C9          ret
07FD: 21 77 E2    ld   hl,$E277
0800: 06 07       ld   b,$07
0802: 7E          ld   a,(hl)
0803: A7          and  a
0804: 28 0B       jr   z,$0811
0806: 2B          dec  hl
0807: 10 F9       djnz $0802
0809: C9          ret
080A: 21 61 E2    ld   hl,$E261
080D: 06 12       ld   b,$12
080F: 18 F1       jr   $0802
0811: 34          inc  (hl)
0812: 7D          ld   a,l
0813: D6 50       sub  $50
0815: 87          add  a,a
0816: 87          add  a,a
0817: DD 77 01    ld   (ix+$01),a
081A: C9          ret
081B: DD 7E 07    ld   a,(ix+$07)
081E: E6 F8       and  $F8
0820: 6F          ld   l,a
0821: 26 20       ld   h,$20
0823: 29          add  hl,hl
0824: 29          add  hl,hl
0825: DD 7E 03    ld   a,(ix+$03)
0828: 1F          rra
0829: 57          ld   d,a
082A: 1F          rra
082B: 1F          rra
082C: E6 1F       and  $1F
082E: 85          add  a,l
082F: 6F          ld   l,a
0830: C9          ret
0831: 3A 00 E3    ld   a,($E300)
0834: FE 06       cp   $06
0836: 30 7A       jr   nc,$08B2
0838: 3A E2 E1    ld   a,($E1E2)
083B: DD 96 0F    sub  (ix+$0f)
083E: ED 44       neg
0840: DD 77 03    ld   (ix+$03),a
0843: FE E0       cp   $E0
0845: 38 6D       jr   c,$08B4
0847: DD 4E 0B    ld   c,(ix+$0b)
084A: 0D          dec  c
084B: 20 6B       jr   nz,$08B8
084D: FE E8       cp   $E8
084F: 30 67       jr   nc,$08B8
0851: E1          pop  hl
0852: DD 36 00 00 ld   (ix+$00),$00
0856: DD 7E 0D    ld   a,(ix+$0d)
0859: 37          scf
085A: 17          rla
085B: D8          ret  c
085C: 37          scf
085D: 17          rla
085E: 21 18 2E    ld   hl,$2E18
0861: 30 01       jr   nc,$0864
0863: 24          inc  h
0864: 5F          ld   e,a
0865: 16 00       ld   d,$00
0867: 19          add  hl,de
0868: 46          ld   b,(hl)
0869: DD 5E 01    ld   e,(ix+$01)
086C: 16 E1       ld   d,$E1
086E: 78          ld   a,b
086F: 17          rla
0870: 30 10       jr   nc,$0882
0872: 06 01       ld   b,$01
0874: 17          rla
0875: 38 27       jr   c,$089E
0877: 7B          ld   a,e
0878: FE 60       cp   $60
087A: 38 06       jr   c,$0882
087C: 62          ld   h,d
087D: D6 5E       sub  $5E
087F: 6F          ld   l,a
0880: 36 00       ld   (hl),$00
0882: FD 21 00 00 ld   iy,$0000
0886: FD 19       add  iy,de
0888: 7B          ld   a,e
0889: 1F          rra
088A: 1F          rra
088B: E6 3F       and  $3F
088D: C6 50       add  a,$50
088F: 6F          ld   l,a
0890: 26 E2       ld   h,$E2
0892: 11 04 00    ld   de,$0004
0895: FD 72 02    ld   (iy+$02),d
0898: FD 19       add  iy,de
089A: 10 F9       djnz $0895
089C: 72          ld   (hl),d
089D: C9          ret
089E: CD 82 08    call $0882
08A1: 21 74 E1    ld   hl,$E174
08A4: 01 00 18    ld   bc,$1800
08A7: 71          ld   (hl),c
08A8: 23          inc  hl
08A9: 10 FC       djnz $08A7
08AB: 21 D1 E1    ld   hl,$E1D1
08AE: 70          ld   (hl),b
08AF: 23          inc  hl
08B0: 70          ld   (hl),b
08B1: C9          ret
08B2: E1          pop  hl
08B3: C9          ret
08B4: DD 36 0B 01 ld   (ix+$0b),$01
08B8: DD 7E 0D    ld   a,(ix+$0d)
08BB: 07          rlca
08BC: D8          ret  c
08BD: 17          rla
08BE: 21 18 2E    ld   hl,$2E18
08C1: 30 01       jr   nc,$08C4
08C3: 24          inc  h
08C4: 5F          ld   e,a
08C5: 16 00       ld   d,$00
08C7: 19          add  hl,de
08C8: DD 5E 01    ld   e,(ix+$01)
08CB: 16 E1       ld   d,$E1
08CD: FD 21 00 00 ld   iy,$0000
08D1: FD 19       add  iy,de
08D3: 56          ld   d,(hl)
08D4: 23          inc  hl
08D5: 5E          ld   e,(hl)
08D6: 23          inc  hl
08D7: 4E          ld   c,(hl)
08D8: 06 00       ld   b,$00
08DA: 21 F5 08    ld   hl,$08F5
08DD: 09          add  hl,bc
08DE: 4E          ld   c,(hl)
08DF: 23          inc  hl
08E0: 66          ld   h,(hl)
08E1: 69          ld   l,c
08E2: DD 4E 03    ld   c,(ix+$03)
08E5: DD 7E 07    ld   a,(ix+$07)
08E8: CD ED 08    call $08ED
08EB: AF          xor  a
08EC: E9          jp   (hl)
08ED: 2F          cpl
08EE: 47          ld   b,a
08EF: 3A 3C E0    ld   a,($E03C)
08F2: 80          add  a,b
08F3: 47          ld   b,a
08F4: C9          ret
08F5: 69          ld   l,c
08F6: 09          add  hl,bc
08F7: 5A          ld   e,d
08F8: 09          add  hl,bc
08F9: CF          rst  $08
08FA: 09          add  hl,bc
08FB: CD 09 F5    call $F509
08FE: 0A          ld   a,(bc)
08FF: 43          ld   b,e
0900: 09          add  hl,bc
0901: E2 0A 90    jp   po,$900A
0904: 0A          ld   a,(bc)
0905: 56          ld   d,(hl)
0906: 0A          ld   a,(bc)
0907: B7          or   a
0908: 0A          ld   a,(bc)
0909: 52          ld   d,d
090A: 0A          ld   a,(bc)
090B: 9F          sbc  a,a
090C: 0A          ld   a,(bc)
090D: C9          ret
090E: 09          add  hl,bc
090F: 25          dec  h
0910: 0B          dec  bc
0911: 76          halt
0912: 09          add  hl,bc
0913: 97          sub  a
0914: 09          add  hl,bc
0915: BA          cp   d
0916: 09          add  hl,bc
0917: 1E 0A       ld   e,$0A
0919: 44          ld   b,h
091A: 0A          ld   a,(bc)
091B: 34          inc  (hl)
091C: 09          add  hl,bc
091D: 25          dec  h
091E: 09          add  hl,bc
091F: 1D          dec  e
0920: 0B          dec  bc
0921: B0          or   b
0922: 09          add  hl,bc
0923: 83          add  a,e
0924: 09          add  hl,bc
0925: DD 34 0A    inc  (ix+$0a)
0928: DD 7E 0A    ld   a,(ix+$0a)
092B: E6 1F       and  $1F
092D: FE 0B       cp   $0B
092F: 38 38       jr   c,$0969
0931: 1C          inc  e
0932: 18 35       jr   $0969
0934: 3A 4E E0    ld   a,($E04E)
0937: E6 03       and  $03
0939: 28 01       jr   z,$093C
093B: 14          inc  d
093C: CD 69 09    call $0969
093F: 16 3B       ld   d,$3B
0941: 18 1B       jr   $095E
0943: FD 21 A4 E1 ld   iy,$E1A4
0947: FD 77 0A    ld   (iy+$0a),a
094A: FD 77 0E    ld   (iy+$0e),a
094D: FD 77 12    ld   (iy+$12),a
0950: FD 77 16    ld   (iy+$16),a
0953: CD 95 0A    call $0A95
0956: 3E F8       ld   a,$F8
0958: 80          add  a,b
0959: 47          ld   b,a
095A: CD 69 09    call $0969
095D: 14          inc  d
095E: 3E 10       ld   a,$10
0960: 81          add  a,c
0961: 4F          ld   c,a
0962: 21 04 00    ld   hl,$0004
0965: EB          ex   de,hl
0966: FD 19       add  iy,de
0968: EB          ex   de,hl
0969: DD 7E 0B    ld   a,(ix+$0b)
096C: A7          and  a
096D: 79          ld   a,c
096E: 20 35       jr   nz,$09A5
0970: C6 08       add  a,$08
0972: FE 20       cp   $20
0974: 38 35       jr   c,$09AB
0976: FD 70 00    ld   (iy+$00),b
0979: FD 73 01    ld   (iy+$01),e
097C: FD 72 02    ld   (iy+$02),d
097F: FD 71 03    ld   (iy+$03),c
0982: C9          ret
0983: DD 7E 08    ld   a,(ix+$08)
0986: 1E 07       ld   e,$07
0988: CB 3F       srl  a
098A: CB 13       rl   e
098C: C6 7A       add  a,$7A
098E: 57          ld   d,a
098F: 78          ld   a,b
0990: FE 80       cp   $80
0992: D2 25 0B    jp   nc,$0B25
0995: 18 DF       jr   $0976
0997: 3E 08       ld   a,$08
0999: 80          add  a,b
099A: 47          ld   b,a
099B: FD 21 74 E1 ld   iy,$E174
099F: 79          ld   a,c
09A0: FE F8       cp   $F8
09A2: D0          ret  nc
09A3: 18 D1       jr   $0976
09A5: C6 08       add  a,$08
09A7: FE F0       cp   $F0
09A9: 38 CB       jr   c,$0976
09AB: FD 36 02 00 ld   (iy+$02),$00
09AF: C9          ret
09B0: 3A 4E E0    ld   a,($E04E)
09B3: CB 57       bit  2,a
09B5: 28 BF       jr   z,$0976
09B7: 14          inc  d
09B8: 18 BC       jr   $0976
09BA: 3E 0E       ld   a,$0E
09BC: 80          add  a,b
09BD: 60          ld   h,b
09BE: 47          ld   b,a
09BF: 2E 01       ld   l,$01
09C1: CD E4 09    call $09E4
09C4: 11 08 76    ld   de,$7608
09C7: 18 11       jr   $09DA
09C9: 3E 0A       ld   a,$0A
09CB: 18 02       jr   $09CF
09CD: 3E 05       ld   a,$05
09CF: 80          add  a,b
09D0: 60          ld   h,b
09D1: 47          ld   b,a
09D2: 2E 01       ld   l,$01
09D4: CD E4 09    call $09E4
09D7: 11 08 71    ld   de,$7108
09DA: 44          ld   b,h
09DB: 21 08 00    ld   hl,$0008
09DE: EB          ex   de,hl
09DF: FD 19       add  iy,de
09E1: EB          ex   de,hl
09E2: 2E 00       ld   l,$00
09E4: CD 69 09    call $0969
09E7: FD 70 04    ld   (iy+$04),b
09EA: 2D          dec  l
09EB: 20 29       jr   nz,$0A16
09ED: 3E 40       ld   a,$40
09EF: AB          xor  e
09F0: FD 77 05    ld   (iy+$05),a
09F3: 3E 08       ld   a,$08
09F5: FD 72 06    ld   (iy+$06),d
09F8: 81          add  a,c
09F9: FD 77 07    ld   (iy+$07),a
09FC: C6 08       add  a,$08
09FE: FE F8       cp   $F8
0A00: 30 0A       jr   nc,$0A0C
0A02: FE 20       cp   $20
0A04: D0          ret  nc
0A05: DD 7E 0B    ld   a,(ix+$0b)
0A08: A7          and  a
0A09: 28 06       jr   z,$0A11
0A0B: C9          ret
0A0C: DD 7E 0B    ld   a,(ix+$0b)
0A0F: A7          and  a
0A10: C8          ret  z
0A11: FD 36 06 00 ld   (iy+$06),$00
0A15: C9          ret
0A16: 14          inc  d
0A17: FD 73 05    ld   (iy+$05),e
0A1A: 3E 10       ld   a,$10
0A1C: 18 D7       jr   $09F5
0A1E: C5          push bc
0A1F: D5          push de
0A20: 21 02 08    ld   hl,$0802
0A23: 09          add  hl,bc
0A24: 44          ld   b,h
0A25: 4D          ld   c,l
0A26: 79          ld   a,c
0A27: C6 08       add  a,$08
0A29: FE D0       cp   $D0
0A2B: 30 11       jr   nc,$0A3E
0A2D: CD 83 09    call $0983
0A30: 11 04 00    ld   de,$0004
0A33: FD 19       add  iy,de
0A35: D1          pop  de
0A36: C1          pop  bc
0A37: 2E 00       ld   l,$00
0A39: FD 75 0A    ld   (iy+$0a),l
0A3C: 18 A6       jr   $09E4
0A3E: FD 36 02 00 ld   (iy+$02),$00
0A42: 18 EC       jr   $0A30
0A44: 32 A6 E1    ld   ($E1A6),a
0A47: 32 AA E1    ld   ($E1AA),a
0A4A: 32 AE E1    ld   ($E1AE),a
0A4D: CD 95 0A    call $0A95
0A50: 18 10       jr   $0A62
0A52: 3E 18       ld   a,$18
0A54: 18 02       jr   $0A58
0A56: 3E 0D       ld   a,$0D
0A58: FD 21 74 E1 ld   iy,$E174
0A5C: 80          add  a,b
0A5D: 47          ld   b,a
0A5E: 3E F8       ld   a,$F8
0A60: 81          add  a,c
0A61: 4F          ld   c,a
0A62: AF          xor  a
0A63: CD 6F 0A    call $0A6F
0A66: EB          ex   de,hl
0A67: 11 08 00    ld   de,$0008
0A6A: FD 19       add  iy,de
0A6C: EB          ex   de,hl
0A6D: 3E 10       ld   a,$10
0A6F: 81          add  a,c
0A70: 6F          ld   l,a
0A71: FD 77 03    ld   (iy+$03),a
0A74: FD 77 07    ld   (iy+$07),a
0A77: FD 70 00    ld   (iy+$00),b
0A7A: 3E F0       ld   a,$F0
0A7C: 80          add  a,b
0A7D: FD 77 04    ld   (iy+$04),a
0A80: FD 73 01    ld   (iy+$01),e
0A83: FD 73 05    ld   (iy+$05),e
0A86: FD 72 02    ld   (iy+$02),d
0A89: 14          inc  d
0A8A: 14          inc  d
0A8B: FD 72 06    ld   (iy+$06),d
0A8E: 15          dec  d
0A8F: C9          ret
0A90: CD 95 0A    call $0A95
0A93: 18 CD       jr   $0A62
0A95: 3A F9 E0    ld   a,($E0F9)
0A98: 1F          rra
0A99: D0          ret  nc
0A9A: 7B          ld   a,e
0A9B: F6 0C       or   $0C
0A9D: 5F          ld   e,a
0A9E: C9          ret
0A9F: FD 21 74 E1 ld   iy,$E174
0AA3: FD 36 0A 00 ld   (iy+$0a),$00
0AA7: FD 36 0E 00 ld   (iy+$0e),$00
0AAB: 3E 18       ld   a,$18
0AAD: 80          add  a,b
0AAE: 47          ld   b,a
0AAF: AF          xor  a
0AB0: CD 6F 0A    call $0A6F
0AB3: FD 72 06    ld   (iy+$06),d
0AB6: C9          ret
0AB7: 3E 18       ld   a,$18
0AB9: 80          add  a,b
0ABA: 47          ld   b,a
0ABB: FD 21 74 E1 ld   iy,$E174
0ABF: 3E F8       ld   a,$F8
0AC1: CD CD 0A    call $0ACD
0AC4: 21 0C 00    ld   hl,$000C
0AC7: EB          ex   de,hl
0AC8: FD 19       add  iy,de
0ACA: EB          ex   de,hl
0ACB: 3E 08       ld   a,$08
0ACD: CD 6F 0A    call $0A6F
0AD0: FD 75 0B    ld   (iy+$0b),l
0AD3: D6 10       sub  $10
0AD5: FD 77 08    ld   (iy+$08),a
0AD8: FD 77 09    ld   (iy+$09),a
0ADB: 7A          ld   a,d
0ADC: C6 03       add  a,$03
0ADE: FD 77 0A    ld   (iy+$0a),a
0AE1: C9          ret
0AE2: FD 21 A4 E1 ld   iy,$E1A4
0AE6: FD 77 06    ld   (iy+$06),a
0AE9: CD 95 0A    call $0A95
0AEC: 21 08 F8    ld   hl,$F808
0AEF: 09          add  hl,bc
0AF0: 44          ld   b,h
0AF1: 4D          ld   c,l
0AF2: C3 76 09    jp   $0976
0AF5: FD 21 A4 E1 ld   iy,$E1A4
0AF9: FD 36 1A 00 ld   (iy+$1a),$00
0AFD: CD 95 0A    call $0A95
0B00: 3E F8       ld   a,$F8
0B02: CD 13 0B    call $0B13
0B05: 3E 08       ld   a,$08
0B07: CD 0C 0B    call $0B0C
0B0A: 3E 18       ld   a,$18
0B0C: EB          ex   de,hl
0B0D: 11 08 00    ld   de,$0008
0B10: FD 19       add  iy,de
0B12: EB          ex   de,hl
0B13: CD 6F 0A    call $0A6F
0B16: 7A          ld   a,d
0B17: C6 02       add  a,$02
0B19: FD 77 06    ld   (iy+$06),a
0B1C: C9          ret
0B1D: 3A 4E E0    ld   a,($E04E)
0B20: CB 4F       bit  1,a
0B22: 28 01       jr   z,$0B25
0B24: 1C          inc  e
0B25: CD 76 09    call $0976
0B28: DD 7E 01    ld   a,(ix+$01)
0B2B: FE 60       cp   $60
0B2D: D8          ret  c
0B2E: EB          ex   de,hl
0B2F: 11 A0 FF    ld   de,$FFA0
0B32: FD 19       add  iy,de
0B34: EB          ex   de,hl
0B35: C3 76 09    jp   $0976
0B38: CD 8E 0C    call $0C8E
0B3B: CD BF 0C    call $0CBF
0B3E: 3A 04 D0    ld   a,($D004)
0B41: CB 6F       bit  5,a
0B43: C0          ret  nz
0B44: 21 A9 2A    ld   hl,$2AA9
0B47: CD 00 03    call $0300
0B4A: 3E FF       ld   a,$FF
0B4C: 32 51 E0    ld   ($E051),a
0B4F: 21 53 E0    ld   hl,$E053
0B52: 7E          ld   a,(hl)
0B53: 4E          ld   c,(hl)
0B54: A9          xor  c
0B55: A1          and  c
0B56: 1F          rra
0B57: 38 08       jr   c,$0B61
0B59: 3A 51 E0    ld   a,($E051)
0B5C: 47          ld   b,a
0B5D: 79          ld   a,c
0B5E: 10 F3       djnz $0B53
0B60: C9          ret
0B61: 21 0E E5    ld   hl,$E50E
0B64: 7E          ld   a,(hl)
0B65: 3C          inc  a
0B66: FE 34       cp   $34
0B68: 30 E0       jr   nc,$0B4A
0B6A: 77          ld   (hl),a
0B6B: 2A 16 E5    ld   hl,($E516)
0B6E: 46          ld   b,(hl)
0B6F: 23          inc  hl
0B70: 7E          ld   a,(hl)
0B71: E6 7F       and  $7F
0B73: 23          inc  hl
0B74: FE 06       cp   $06
0B76: 20 F6       jr   nz,$0B6E
0B78: 78          ld   a,b
0B79: 32 0B E5    ld   ($E50B),a
0B7C: 22 16 E5    ld   ($E516),hl
0B7F: 32 23 E5    ld   ($E523),a
0B82: 22 2E E5    ld   ($E52E),hl
0B85: CD 12 0D    call $0D12
0B88: 18 C0       jr   $0B4A

display_status_bar_0b8a:
0B8A: CD B1 0C    call $0CB1
0B8D: 21 94 26    ld   hl,$2694
0B90: 22 16 E5    ld   ($E516),hl
0B93: C3 BF 0C    jp   $0CBF
0B96: 2A 16 E5    ld   hl,($E516)
0B99: 2B          dec  hl
0B9A: 7E          ld   a,(hl)
0B9B: 2B          dec  hl
0B9C: E6 7F       and  $7F
0B9E: FE 06       cp   $06
0BA0: 20 F7       jr   nz,$0B99
0BA2: 11 DC E1    ld   de,$E1DC
0BA5: EB          ex   de,hl
0BA6: 7E          ld   a,(hl)
0BA7: 36 00       ld   (hl),$00
0BA9: EB          ex   de,hl
0BAA: A7          and  a
0BAB: 20 EC       jr   nz,$0B99
0BAD: 7E          ld   a,(hl)
0BAE: 32 0B E5    ld   ($E50B),a
0BB1: 23          inc  hl
0BB2: 23          inc  hl
0BB3: 22 16 E5    ld   ($E516),hl
0BB6: C9          ret
0BB7: 21 00 E1    ld   hl,$E100
0BBA: 01 00 04    ld   bc,$0400
0BBD: CD FA 05    call clear_area_05fa
0BC0: DD 21 00 E3 ld   ix,$E300
0BC4: DD 36 00 01 ld   (ix+$00),$01
0BC8: DD 36 10 09 ld   (ix+$10),$09
0BCC: DD 36 01 B0 ld   (ix+$01),$B0
0BD0: DD 36 21 A0 ld   (ix+$21),$A0
0BD4: DD 21 70 E3 ld   ix,$E370
0BD8: 3E 60       ld   a,$60
0BDA: 06 09       ld   b,$09
0BDC: 11 10 00    ld   de,$0010
0BDF: DD 77 01    ld   (ix+$01),a
0BE2: DD 19       add  ix,de
0BE4: C6 04       add  a,$04
0BE6: 10 F7       djnz $0BDF
0BE8: CD 96 0B    call $0B96
0BEB: 2B          dec  hl
0BEC: 46          ld   b,(hl)
0BED: 3E 04       ld   a,$04
0BEF: 21 00 C0    ld   hl,$C000
0BF2: 05          dec  b
0BF3: F2 FA 0B    jp   p,$0BFA
0BF6: 3E 07       ld   a,$07
0BF8: 26 A8       ld   h,$A8
0BFA: 32 14 E5    ld   ($E514),a
0BFD: 22 06 E3    ld   ($E306),hl
0C00: 3E 02       ld   a,$02
0C02: 32 08 E5    ld   ($E508),a
0C05: CD 8D 0D    call draw_ground_0d8d
0C08: 3A 13 E5    ld   a,($E513)
0C0B: 3D          dec  a
0C0C: FE 05       cp   $05
0C0E: CE 00       adc  a,$00
0C10: 06 FB       ld   b,$FB
0C12: 1F          rra
0C13: 38 01       jr   c,$0C16
0C15: 04          inc  b
0C16: 78          ld   a,b
0C17: 32 C5 E1    ld   ($E1C5),a
0C1A: CD 81 29    call $2981
0C1D: A7          and  a
0C1E: 20 5F       jr   nz,$0C7F
0C20: 21 0F E5    ld   hl,$E50F
0C23: CB 46       bit  0,(hl)
0C25: 20 58       jr   nz,$0C7F
0C27: 34          inc  (hl)
0C28: 3A 10 E5    ld   a,(time_bcd_e510)
0C2B: A7          and  a
0C2C: 28 58       jr   z,$0C86
0C2E: 21 5F 2A    ld   hl,$2A5F
0C31: CD 00 03    call $0300
0C34: 3A 10 E5    ld   a,(time_bcd_e510)
0C37: FE 04       cp   $04
0C39: 38 02       jr   c,$0C3D
0C3B: 3E 03       ld   a,$03
0C3D: C6 30       add  a,$30
0C3F: 32 56 81    ld   ($8156),a
0C42: 3E 1C       ld   a,$1C
0C44: CD 6F 0D    call $0D6F
0C47: 3E 40       ld   a,$40
0C49: 32 0A E3    ld   ($E30A),a
0C4C: 0E 68       ld   c,$68
0C4E: 21 B6 30    ld   hl,$30B6
0C51: 46          ld   b,(hl)
0C52: CB 78       bit  7,b
0C54: 20 14       jr   nz,$0C6A
0C56: 23          inc  hl
0C57: 5E          ld   e,(hl)
0C58: 23          inc  hl
0C59: 7E          ld   a,(hl)
0C5A: 23          inc  hl
0C5B: EB          ex   de,hl
0C5C: 26 83       ld   h,$83
0C5E: 71          ld   (hl),c
0C5F: 26 87       ld   h,$87
0C61: 70          ld   (hl),b
0C62: 0C          inc  c
0C63: 2C          inc  l
0C64: BD          cp   l
0C65: 20 F5       jr   nz,$0C5C
0C67: EB          ex   de,hl
0C68: 18 E7       jr   $0C51
0C6A: 3E D3       ld   a,$D3
0C6C: 21 D8 30    ld   hl,$30D8
0C6F: 11 10 E2    ld   de,$E210
0C72: 46          ld   b,(hl)
0C73: CB 78       bit  7,b
0C75: 20 08       jr   nz,$0C7F
0C77: 12          ld   (de),a
0C78: 13          inc  de
0C79: 10 FC       djnz $0C77
0C7B: 3C          inc  a
0C7C: 23          inc  hl
0C7D: 18 F3       jr   $0C72
0C7F: 21 46 E0    ld   hl,$E046
0C82: 34          inc  (hl)
0C83: C3 6E 02    jp   $026E
0C86: 21 47 2A    ld   hl,$2A47
0C89: CD 00 03    call $0300
0C8C: 18 B4       jr   $0C42
0C8E: AF          xor  a
0C8F: 32 4D E0    ld   ($E04D),a
0C92: CD 95 0C    call $0C95
0C95: CD 03 06    call $0603
0C98: 21 00 E5    ld   hl,$E500
0C9B: 01 16 00    ld   bc,$0016
0C9E: CD FA 05    call clear_area_05fa
0CA1: 32 0F E5    ld   ($E50F),a
0CA4: 3A 40 E0    ld   a,($E040)
0CA7: 32 15 E5    ld   (nb_lives_E515),a
0CAA: 21 62 21    ld   hl,$2162
0CAD: 22 16 E5    ld   ($E516),hl
0CB0: C9          ret
0CB1: 21 DE 26    ld   hl,$26DE
0CB4: 22 F7 E0    ld   ($E0F7),hl
0CB7: 21 03 E5    ld   hl,$E503
0CBA: 01 11 00    ld   bc,$0011
0CBD: 18 DF       jr   $0C9E
0CBF: CD 29 0D    call $0D29
0CC2: 21 21 84    ld   hl,$8421
0CC5: 0E 06       ld   c,$06
0CC7: 3A 0E E5    ld   a,($E50E)
0CCA: FE 1A       cp   $1A
0CCC: 3E 00       ld   a,$00
0CCE: 38 01       jr   c,$0CD1
0CD0: 3C          inc  a
0CD1: 32 F9 E0    ld   ($E0F9),a
0CD4: C5          push bc
0CD5: 0E 01       ld   c,$01
0CD7: CD E7 03    call $03E7
0CDA: 79          ld   a,c
0CDB: C1          pop  bc
0CDC: 06 1E       ld   b,$1E
0CDE: 77          ld   (hl),a
0CDF: 23          inc  hl
0CE0: 10 FC       djnz $0CDE
0CE2: 23          inc  hl
0CE3: 23          inc  hl
0CE4: 0D          dec  c
0CE5: 20 F5       jr   nz,$0CDC
0CE7: 21 0F 2B    ld   hl,$2B0F
0CEA: CD 00 03    call $0300
0CED: CD 68 06    call $0668
0CF0: CD 85 06    call $0685
0CF3: 3A 46 E0    ld   a,($E046)
0CF6: CB 67       bit  4,a
0CF8: 28 0F       jr   z,$0D09
0CFA: CD 03 06    call $0603
0CFD: CD 68 06    call $0668
0D00: CD 03 06    call $0603
0D03: 21 72 2B    ld   hl,$2B72
0D06: CD 00 03    call $0300
0D09: CD D5 06    call $06D5
0D0C: CD 2C 21    call $212C
0D0F: CD 8A 29    call $298A
0D12: 3A 0E E5    ld   a,($E50E)
0D15: 0E 02       ld   c,$02
0D17: FE 1A       cp   $1A
0D19: 38 04       jr   c,$0D1F
0D1B: D6 1A       sub  $1A
0D1D: 0E 07       ld   c,$07
0D1F: C6 40       add  a,$40
0D21: 32 52 80    ld   ($8052),a
0D24: 79          ld   a,c
0D25: 32 52 84    ld   ($8452),a
0D28: C9          ret

0D29: 21 00 80    ld   hl,$8000
0D2C: 01 00 08    ld   bc,$0800
0D2F: CD FA 05    call clear_area_05fa	; clear screen
0D32: 21 00 E1    ld   hl,$E100
0D35: 01 C6 00    ld   bc,$00C6
0D38: CD FA 05    call clear_area_05fa	; clear part of RAM
0D3B: 3A 43 E0    ld   a,($E043)
0D3E: 3D          dec  a
0D3F: 28 09       jr   z,$0D4A
0D41: 21 46 E0    ld   hl,$E046
0D44: AF          xor  a
0D45: CB 5E       bit  3,(hl)
0D47: 28 01       jr   z,$0D4A
0D49: 3C          inc  a
0D4A: 32 4C E0    ld   ($E04C),a
0D4D: 21 04 D0    ld   hl,$D004
0D50: AE          xor  (hl)
0D51: 21 3C E0    ld   hl,$E03C
0D54: 36 EF       ld   (hl),$EF
0D56: 16 FF       ld   d,$FF
0D58: 1F          rra
0D59: 30 03       jr   nc,$0D5E
0D5B: 14          inc  d
0D5C: 36 F1       ld   (hl),$F1
0D5E: 23          inc  hl
0D5F: 72          ld   (hl),d
0D60: 01 00 40    ld   bc,$4000
0D63: AF          xor  a
0D64: ED 79       out  (c),a
0D66: 0C          inc  c
0D67: 10 FB       djnz $0D64
0D69: F3          di
0D6A: CD 7D 0D    call $0D7D
0D6D: FB          ei
0D6E: C9          ret

0D6F: F3          di
0D70: CD 75 0D    call $0D75
0D73: FB          ei
0D74: C9          ret

0D75: E5          push hl
0D76: 21 46 E0    ld   hl,$E046
0D79: CB 7E       bit  7,(hl)
0D7B: E1          pop  hl
0D7C: F0          ret  p
0D7D: E5          push hl
0D7E: 2A DE E1    ld   hl,($E1DE)
0D81: 26 E0       ld   h,$E0
0D83: 77          ld   (hl),a
0D84: 7D          ld   a,l
0D85: 3C          inc  a
0D86: E6 07       and  $07
0D88: 32 DE E1    ld   ($E1DE),a
0D8B: E1          pop  hl
0D8C: C9          ret

draw_ground_0d8d:
0D8D: CD 48 29    call $2948
0D90: CD C2 0C    call $0CC2
0D93: 06 20       ld   b,$20
0D95: C5          push bc
0D96: CD 06 11    call $1106
0D99: 21 E2 E1    ld   hl,$E1E2
0D9C: 7E          ld   a,(hl)
0D9D: C6 08       add  a,$08
0D9F: 77          ld   (hl),a
0DA0: C1          pop  bc
0DA1: 10 F2       djnz $0D95
0DA3: C3 3B 0D    jp   $0D3B
0DA6: DD 5E 02    ld   e,(ix+$02)
0DA9: DD 56 03    ld   d,(ix+$03)
0DAC: 01 4A 30    ld   bc,$304A
0DAF: 81          add  a,c
0DB0: 4F          ld   c,a
0DB1: 0A          ld   a,(bc)
0DB2: 4F          ld   c,a
0DB3: EB          ex   de,hl
0DB4: 11 20 00    ld   de,$0020
0DB7: 7E          ld   a,(hl)
0DB8: A7          and  a
0DB9: 20 03       jr   nz,$0DBE
0DBB: 19          add  hl,de
0DBC: 18 F9       jr   $0DB7
0DBE: 22 54 E0    ld   ($E054),hl
0DC1: 0A          ld   a,(bc)
0DC2: 03          inc  bc
0DC3: 3D          dec  a
0DC4: C8          ret  z
0DC5: F2 CD 0D    jp   p,$0DCD
0DC8: 3C          inc  a
0DC9: 77          ld   (hl),a
0DCA: 19          add  hl,de
0DCB: 18 F4       jr   $0DC1
0DCD: 3A 54 E0    ld   a,($E054)
0DD0: 3C          inc  a
0DD1: 6F          ld   l,a
0DD2: E6 1F       and  $1F
0DD4: 20 E8       jr   nz,$0DBE
0DD6: 7D          ld   a,l
0DD7: D6 20       sub  $20
0DD9: 6F          ld   l,a
0DDA: 18 E2       jr   $0DBE
0DDC: CD 5B 12    call $125B
0DDF: 3A E2 E1    ld   a,($E1E2)
0DE2: 21 09 E5    ld   hl,$E509
0DE5: 47          ld   b,a
0DE6: AE          xor  (hl)
0DE7: E6 F8       and  $F8
0DE9: C8          ret  z
0DEA: 78          ld   a,b
0DEB: E6 F8       and  $F8
0DED: 77          ld   (hl),a
0DEE: CD 06 11    call $1106
0DF1: 3A 4D E0    ld   a,($E04D)
0DF4: A7          and  a
0DF5: C0          ret  nz
0DF6: 21 0B E5    ld   hl,$E50B
0DF9: 34          inc  (hl)
0DFA: 7E          ld   a,(hl)
0DFB: 5F          ld   e,a
0DFC: A7          and  a
0DFD: 28 07       jr   z,$0E06
0DFF: E6 1F       and  $1F
0E01: 20 03       jr   nz,$0E06
0E03: CD D6 29    call $29D6
0E06: 7B          ld   a,e
0E07: 2A 16 E5    ld   hl,($E516)
0E0A: BE          cp   (hl)
0E0B: 20 0B       jr   nz,$0E18
0E0D: 23          inc  hl
0E0E: 7E          ld   a,(hl)
0E0F: E6 7F       and  $7F
0E11: 32 D7 E1    ld   ($E1D7),a
0E14: 23          inc  hl
0E15: 22 16 E5    ld   ($E516),hl
0E18: 21 D7 E1    ld   hl,$E1D7
0E1B: 7E          ld   a,(hl)
0E1C: 3D          dec  a
0E1D: F8          ret  m
0E1E: 36 00       ld   (hl),$00
0E20: FE 18       cp   $18
0E22: D2 45 0F    jp   nc,$0F45
0E25: FE 17       cp   $17
0E27: 28 26       jr   z,$0E4F
0E29: D6 06       sub  $06
0E2B: FA 8A 0E    jp   m,$0E8A
0E2E: D6 07       sub  $07
0E30: FA F0 0E    jp   m,$0EF0
0E33: 87          add  a,a
0E34: 87          add  a,a
0E35: 87          add  a,a
0E36: 5F          ld   e,a
0E37: 16 00       ld   d,$00
0E39: FD 21 00 10 ld   iy,$1000
0E3D: FD 19       add  iy,de
0E3F: CD 93 0E    call $0E93
0E42: FD 7E 06    ld   a,(iy+$06)
0E45: A7          and  a
0E46: 28 03       jr   z,$0E4B
0E48: CD FD 07    call $07FD
0E4B: DD 71 00    ld   (ix+$00),c
0E4E: C9          ret

0E4F: 3E 19       ld   a,$19
0E51: 32 70 E3    ld   ($E370),a
0E54: C9          ret

0E55: 3E 01       ld   a,$01
0E57: 32 DC E1    ld   ($E1DC),a
0E5A: 2A E4 E0    ld   hl,($E0E4)
0E5D: 7D          ld   a,l
0E5E: E6 1F       and  $1F
0E60: F6 C0       or   $C0
0E62: 6F          ld   l,a
0E63: 36 0A       ld   (hl),$0A
0E65: 01 20 00    ld   bc,$0020
0E68: 5D          ld   e,l
0E69: 09          add  hl,bc
0E6A: 36 0B       ld   (hl),$0B
0E6C: 7B          ld   a,e
0E6D: 3D          dec  a
0E6E: E6 1F       and  $1F
0E70: F6 C0       or   $C0
0E72: 6F          ld   l,a
0E73: CD 81 29    call $2981
0E76: C6 41       add  a,$41
0E78: 77          ld   (hl),a
0E79: 22 DA E1    ld   ($E1DA),hl
0E7C: 09          add  hl,bc
0E7D: 36 F2       ld   (hl),$F2
0E7F: 01 E0 03    ld   bc,$03E0
0E82: 09          add  hl,bc
0E83: 3A F9 E0    ld   a,($E0F9)
0E86: C6 05       add  a,$05
0E88: 77          ld   (hl),a
0E89: C9          ret

0E8A: 3C          inc  a
0E8B: 28 C8       jr   z,$0E55
0E8D: C6 05       add  a,$05
0E8F: 32 08 E5    ld   ($E508),a
0E92: C9          ret

0E93: FD 7E 00    ld   a,(iy+$00)
0E96: FE 02       cp   $02
0E98: 28 1B       jr   z,$0EB5
0E9A: FE 07       cp   $07
0E9C: 38 1C       jr   c,$0EBA
0E9E: 16 00       ld   d,$00
0EA0: FD 5E 05    ld   e,(iy+$05)
0EA3: DD 21 70 E3 ld   ix,$E370
0EA7: FD 46 04    ld   b,(iy+$04)
0EAA: DD 7E 00    ld   a,(ix+$00)
0EAD: A7          and  a
0EAE: 28 13       jr   z,$0EC3
0EB0: DD 19       add  ix,de
0EB2: 10 F6       djnz $0EAA
0EB4: C9          ret

0EB5: 21 D7 E1    ld   hl,$E1D7
0EB8: 36 11       ld   (hl),$11
0EBA: 11 F0 FF    ld   de,$FFF0
0EBD: DD 21 F0 E4 ld   ix,$E4F0
0EC1: 18 E4       jr   $0EA7
0EC3: FD 7E 00    ld   a,(iy+$00)
0EC6: DD 77 0C    ld   (ix+$0c),a
0EC9: FD 7E 01    ld   a,(iy+$01)
0ECC: DD 77 0D    ld   (ix+$0d),a
0ECF: 3A 09 E5    ld   a,($E509)
0ED2: D6 02       sub  $02
0ED4: DD 77 0F    ld   (ix+$0f),a
0ED7: CD 3D 15    call $153D
0EDA: FD 86 03    add  a,(iy+$03)
0EDD: DD 77 07    ld   (ix+$07),a
0EE0: DD 36 0B 00 ld   (ix+$0b),$00
0EE4: DD 36 03 00 ld   (ix+$03),$00
0EE8: DD 36 0E 00 ld   (ix+$0e),$00
0EEC: FD 4E 02    ld   c,(iy+$02)
0EEF: C9          ret

0EF0: 3C          inc  a
0EF1: CA 40 0F    jp   z,$0F40
0EF4: F5          push af
0EF5: FD 21 4E 10 ld   iy,$104E
0EF9: CD BA 0E    call $0EBA
0EFC: F1          pop  af
0EFD: C6 86       add  a,$86
0EFF: DD 77 0D    ld   (ix+$0d),a
0F02: DD 71 00    ld   (ix+$00),c
0F05: 21 4A 30    ld   hl,$304A
0F08: 85          add  a,l
0F09: C6 80       add  a,$80
0F0B: 6F          ld   l,a
0F0C: 6E          ld   l,(hl)
0F0D: FD 2A E4 E0 ld   iy,($E0E4)
0F11: 11 20 00    ld   de,$0020
0F14: 7E          ld   a,(hl)
0F15: 23          inc  hl
0F16: 3D          dec  a
0F17: F2 22 0F    jp   p,$0F22
0F1A: 3C          inc  a
0F1B: FD 77 00    ld   (iy+$00),a
0F1E: FD 19       add  iy,de
0F20: 18 F2       jr   $0F14
0F22: C8          ret  z
0F23: 22 E6 E0    ld   ($E0E6),hl
0F26: 3D          dec  a
0F27: 28 11       jr   z,$0F3A
0F29: FD 21 55 10 ld   iy,$1055
0F2D: CD 9E 0E    call $0E9E
0F30: DD 36 0A 00 ld   (ix+$0a),$00
0F34: DD 34 0E    inc  (ix+$0e)
0F37: DD 71 00    ld   (ix+$00),c
0F3A: 3E 0D       ld   a,$0D
0F3C: 32 D7 E1    ld   ($E1D7),a
0F3F: C9          ret

0F40: 2A E6 E0    ld   hl,($E0E6)
0F43: 18 C8       jr   $0F0D
0F45: D6 1F       sub  $1F
0F47: FA B7 0F    jp   m,$0FB7
0F4A: 21 C5 E1    ld   hl,$E1C5
0F4D: 0E FF       ld   c,$FF
0F4F: 23          inc  hl
0F50: 0C          inc  c
0F51: D6 08       sub  $08
0F53: F2 4F 0F    jp   p,$0F4F
0F56: C6 08       add  a,$08
0F58: 28 10       jr   z,$0F6A
0F5A: 77          ld   (hl),a
0F5B: 23          inc  hl
0F5C: 23          inc  hl
0F5D: 23          inc  hl
0F5E: 77          ld   (hl),a
0F5F: 23          inc  hl
0F60: 23          inc  hl
0F61: 23          inc  hl
0F62: 77          ld   (hl),a
0F63: 0D          dec  c
0F64: F8          ret  m
0F65: 21 D6 E1    ld   hl,$E1D6
0F68: 34          inc  (hl)
0F69: C9          ret
0F6A: 77          ld   (hl),a
0F6B: FD 21 70 E3 ld   iy,$E370
0F6F: 11 10 00    ld   de,$0010
0F72: 06 19       ld   b,$19
0F74: 0D          dec  c
0F75: FA A5 0F    jp   m,$0FA5
0F78: FD 7E 00    ld   a,(iy+$00)
0F7B: D6 22       sub  $22
0F7D: FE 06       cp   $06
0F7F: 30 19       jr   nc,$0F9A
0F81: 6F          ld   l,a
0F82: CB 4D       bit  1,l
0F84: 20 14       jr   nz,$0F9A
0F86: 61          ld   h,c
0F87: FD 7E 0D    ld   a,(iy+$0d)
0F8A: FE 2A       cp   $2A
0F8C: 20 01       jr   nz,$0F8F
0F8E: 24          inc  h
0F8F: 25          dec  h
0F90: 20 08       jr   nz,$0F9A
0F92: CB 55       bit  2,l
0F94: 20 09       jr   nz,$0F9F
0F96: FD 36 00 24 ld   (iy+$00),$24
0F9A: FD 19       add  iy,de
0F9C: 10 DA       djnz $0F78
0F9E: C9          ret
0F9F: FD 36 0F 01 ld   (iy+$0f),$01
0FA3: 18 F5       jr   $0F9A
0FA5: FD 7E 00    ld   a,(iy+$00)
0FA8: D6 1E       sub  $1E
0FAA: FE 02       cp   $02
0FAC: 30 04       jr   nc,$0FB2
0FAE: FD 36 00 24 ld   (iy+$00),$24
0FB2: FD 19       add  iy,de
0FB4: 10 EF       djnz $0FA5
0FB6: C9          ret
0FB7: C6 08       add  a,$08
0FB9: FE 04       cp   $04
0FBB: 30 08       jr   nc,$0FC5
0FBD: 21 0B E5    ld   hl,$E50B
0FC0: 46          ld   b,(hl)
0FC1: 23          inc  hl
0FC2: 70          ld   (hl),b
0FC3: 23          inc  hl
0FC4: 77          ld   (hl),a
0FC5: 3A D5 E1    ld   a,($E1D5)
0FC8: A7          and  a
0FC9: C8          ret  z
0FCA: 5F          ld   e,a
0FCB: 16 00       ld   d,$00
0FCD: FD 21 FF E3 ld   iy,$E3FF
0FD1: FD 19       add  iy,de
0FD3: 21 70 E3    ld   hl,$E370
0FD6: 1E 10       ld   e,$10
0FD8: 01 3A 05    ld   bc,$053A
0FDB: 7E          ld   a,(hl)
0FDC: A7          and  a
0FDD: CA 5D 10    jp   z,$105D

1030: 04          inc  b
1031: 12          ld   (de),a
1032: 16 F4       ld   d,$F4
1034: 18 10       jr   $1046

1036: 01 00 05    ld   bc,$0500
1039: 16 16       ld   d,$16
103B: F2 18 10    jp   p,$1018
103E: 01 00 06    ld   bc,$0600
1041: 1B          dec  de
1042: 16 F0       ld   d,$F0
1044: 18 10       jr   $1056


105D: EB          ex   de,hl
105E: DD 21 00 00 ld   ix,$0000
1062: DD 19       add  ix,de
1064: DD 71 0D    ld   (ix+$0d),c
1067: DD 36 09 00 ld   (ix+$09),$00
106B: DD 36 08 00 ld   (ix+$08),$00
106F: FD 56 07    ld   d,(iy+$07)
1072: DD 72 07    ld   (ix+$07),d
1075: FD 7E 00    ld   a,(iy+$00)
1078: D6 1E       sub  $1E
107A: FE 0A       cp   $0A
107C: D0          ret  nc
107D: CB 4F       bit  1,a
107F: C0          ret  nz
1080: FD 7E 03    ld   a,(iy+$03)
1083: D6 10       sub  $10
1085: FE E0       cp   $E0
1087: D0          ret  nc
1088: 79          ld   a,c
1089: FE 3A       cp   $3A
108B: 28 36       jr   z,$10C3
108D: CD 92 20    call $2092
1090: ED 5F       ld   a,r
1092: E6 7F       and  $7F
1094: 47          ld   b,a
1095: 3A 03 E3    ld   a,($E303)
1098: 80          add  a,b
1099: D6 2F       sub  $2F
109B: 4F          ld   c,a
109C: DD 96 03    sub  (ix+$03)
109F: C6 08       add  a,$08
10A1: FE 11       cp   $11
10A3: 79          ld   a,c
10A4: 30 03       jr   nc,$10A9
10A6: EE 10       xor  $10
10A8: 4F          ld   c,a
10A9: FD BE 03    cp   (iy+$03)
10AC: 17          rla
10AD: DD 77 0C    ld   (ix+$0c),a
10B0: 79          ld   a,c
10B1: CD 38 15    call $1538
10B4: 92          sub  d
10B5: 1F          rra
10B6: 1F          rra
10B7: 1F          rra
10B8: E6 1F       and  $1F
10BA: C6 02       add  a,$02
10BC: 41          ld   b,c
10BD: CB 38       srl  b
10BF: 0E 2E       ld   c,$2E
10C1: 18 0F       jr   $10D2
10C3: 01 2A 8F    ld   bc,$8F2A
10C6: CB 3A       srl  d
10C8: CB 3A       srl  d
10CA: CB 3A       srl  d
10CC: 3A 14 E5    ld   a,($E514)
10CF: EE 1F       xor  $1F
10D1: 92          sub  d
10D2: 21 00 31    ld   hl,$3100
10D5: 85          add  a,l
10D6: 6F          ld   l,a
10D7: 56          ld   d,(hl)
10D8: FD 7E 03    ld   a,(iy+$03)
10DB: DD 77 03    ld   (ix+$03),a
10DE: CB 3F       srl  a
10E0: 90          sub  b
10E1: 30 02       jr   nc,$10E5
10E3: ED 44       neg
10E5: 1E FF       ld   e,$FF
10E7: 1C          inc  e
10E8: 92          sub  d
10E9: 30 FC       jr   nc,$10E7
10EB: 82          add  a,d
10EC: DD 73 05    ld   (ix+$05),e
10EF: 06 08       ld   b,$08
10F1: CB 27       sla  a
10F3: BA          cp   d
10F4: CB 13       rl   e
10F6: CB 43       bit  0,e
10F8: 20 01       jr   nz,$10FB
10FA: 92          sub  d
10FB: 10 F4       djnz $10F1
10FD: 7B          ld   a,e
10FE: 2F          cpl
10FF: DD 77 04    ld   (ix+$04),a
1102: DD 71 00    ld   (ix+$00),c
1105: C9          ret
1106: 21 D9 E1    ld   hl,$E1D9
1109: 7E          ld   a,(hl)
110A: A7          and  a
110B: C2 9A 11    jp   nz,$119A
110E: 3A 08 E5    ld   a,($E508)
1111: FE 03       cp   $03
1113: 30 79       jr   nc,$118E
1115: 47          ld   b,a
1116: 05          dec  b
1117: 21 B4 2C    ld   hl,$2CB4
111A: 3A E2 E1    ld   a,($E1E2)
111D: 1F          rra
111E: 1F          rra
111F: 1F          rra
1120: E6 1F       and  $1F
1122: 85          add  a,l
1123: 10 02       djnz $1127
1125: C6 20       add  a,$20
1127: 6F          ld   l,a
1128: 4E          ld   c,(hl)
1129: 3A E2 E1    ld   a,($E1E2)
112C: 1F          rra
112D: 1F          rra
112E: 1F          rra
112F: E6 1F       and  $1F
1131: 5F          ld   e,a
1132: 16 83       ld   d,$83
1134: FD 21 00 04 ld   iy,$0400
1138: FD 19       add  iy,de
113A: EB          ex   de,hl
113B: 11 20 00    ld   de,$0020
113E: 06 07       ld   b,$07
1140: 3A 14 E5    ld   a,($E514)
1143: B8          cp   b
1144: 28 07       jr   z,$114D
1146: 36 00       ld   (hl),$00
1148: 19          add  hl,de
1149: FD 19       add  iy,de
114B: 10 F6       djnz $1143
114D: 22 E4 E0    ld   ($E0E4),hl
1150: 71          ld   (hl),c
1151: FD 36 00 04 ld   (iy+$00),$04
1155: 19          add  hl,de
1156: FD 19       add  iy,de
1158: 36 F3       ld   (hl),$F3
115A: FD 36 00 04 ld   (iy+$00),$04
115E: 10 F5       djnz $1155
1160: 3A E2 E1    ld   a,($E1E2)
1163: 1F          rra
1164: 1F          rra
1165: E6 3E       and  $3E
1167: C6 00       add  a,$00
1169: 6F          ld   l,a
116A: 26 E2       ld   h,$E2
116C: 3A 14 E5    ld   a,($E514)
116F: EE 1F       xor  $1F
1171: 57          ld   d,a
1172: FD 21 24 2C ld   iy,$2C24
1176: FD 09       add  iy,bc
1178: FD 7E 00    ld   a,(iy+$00)
117B: 5F          ld   e,a
117C: E6 70       and  $70
117E: 07          rlca
117F: B2          or   d
1180: 07          rlca
1181: 07          rlca
1182: 07          rlca
1183: 77          ld   (hl),a
1184: E6 F8       and  $F8
1186: 57          ld   d,a
1187: 7B          ld   a,e
1188: E6 07       and  $07
118A: B2          or   d
118B: 23          inc  hl
118C: 77          ld   (hl),a
118D: C9          ret
118E: 87          add  a,a
118F: C6 7A       add  a,$7A
1191: 77          ld   (hl),a
1192: 87          add  a,a
1193: 28 02       jr   z,$1197
1195: 3E 0A       ld   a,$0A
1197: 32 D8 E1    ld   ($E1D8),a
119A: 4E          ld   c,(hl)
119B: CB 19       rr   c
119D: D8          ret  c
119E: CB 19       rr   c
11A0: 21 D8 E1    ld   hl,$E1D8
11A3: 35          dec  (hl)
11A4: F2 B6 11    jp   p,$11B6
11A7: 36 0B       ld   (hl),$0B
11A9: 3A 14 E5    ld   a,($E514)
11AC: 38 3C       jr   c,$11EA
11AE: FE 07       cp   $07
11B0: 28 3E       jr   z,$11F0
11B2: 3E 0B       ld   a,$0B
11B4: 18 27       jr   $11DD
11B6: 7E          ld   a,(hl)
11B7: 21 14 E5    ld   hl,$E514
11BA: 30 1C       jr   nc,$11D8
11BC: A7          and  a
11BD: 20 01       jr   nz,$11C0
11BF: 35          dec  (hl)
11C0: C6 F3       add  a,$F3
11C2: FE FC       cp   $FC
11C4: 38 02       jr   c,$11C8
11C6: D6 0C       sub  $0C
11C8: 4F          ld   c,a
11C9: C6 03       add  a,$03
11CB: FA C9 11    jp   m,$11C9
11CE: C2 29 11    jp   nz,$1129
11D1: 79          ld   a,c
11D2: D6 10       sub  $10
11D4: 4F          ld   c,a
11D5: C3 29 11    jp   $1129
11D8: FE 09       cp   $09
11DA: 20 01       jr   nz,$11DD
11DC: 34          inc  (hl)
11DD: 2F          cpl
11DE: C6 F2       add  a,$F2
11E0: FE F0       cp   $F0
11E2: 30 02       jr   nc,$11E6
11E4: C6 0C       add  a,$0C
11E6: 4F          ld   c,a
11E7: C3 29 11    jp   $1129
11EA: FE 04       cp   $04
11EC: 3E 0B       ld   a,$0B
11EE: 20 D0       jr   nz,$11C0
11F0: 21 D9 E1    ld   hl,$E1D9
11F3: 34          inc  (hl)
11F4: 2A E1 E1    ld   hl,($E1E1)
11F7: 22 F1 E0    ld   ($E0F1),hl
11FA: 21 00 00    ld   hl,$0000
11FD: 22 EF E0    ld   ($E0EF),hl
1200: C9          ret

1201: 21 44 2D    ld   hl,$2D44
1204: ED 53 EB E0 ld   ($E0EB),de
1208: 22 E9 E0    ld   ($E0E9),hl
120B: 3A 4E E0    ld   a,($E04E)
120E: C6 03       add  a,$03
1210: DD 77 01    ld   (ix+$01),a
1213: DD 36 00 0B ld   (ix+$00),$0B
1217: C9          ret

display_title_1218:
1218: 3A 4E E0    ld   a,($E04E)
121B: DD BE 01    cp   (ix+$01)
121E: 20 F3       jr   nz,$1213
1220: 2A EB E0    ld   hl,($E0EB)
1223: 23          inc  hl
1224: 22 EB E0    ld   ($E0EB),hl
1227: 2B          dec  hl
1228: EB          ex   de,hl
1229: FD 21 00 04 ld   iy,$0400
122D: FD 19       add  iy,de
122F: 2A E9 E0    ld   hl,($E0E9)
1232: 01 20 00    ld   bc,$0020
1235: 7E          ld   a,(hl)
1236: 23          inc  hl
1237: 3D          dec  a
1238: FE 03       cp   $03
123A: 38 0D       jr   c,$1249
123C: 3C          inc  a
; write "moon patrol" title loop
123D: 12          ld   (de),a
123E: FD 36 00 80 ld   (iy+$00),$80
1242: EB          ex   de,hl
1243: 09          add  hl,bc
1244: EB          ex   de,hl
1245: FD 09       add  iy,bc
1247: 18 EC       jr   $1235
1249: 3D          dec  a
124A: FA 55 12    jp   m,$1255
124D: 28 B9       jr   z,$1208
124F: 5E          ld   e,(hl)
1250: 23          inc  hl
1251: 56          ld   d,(hl)
1252: 23          inc  hl
1253: 18 AF       jr   $1204
1255: 21 97 2C    ld   hl,$2C97
1258: C3 00 03    jp   $0300

125B: 3A 0D E5    ld   a,($E50D)
125E: 3D          dec  a
125F: F8          ret  m
1260: 21 AB 2C    ld   hl,$2CAB
1263: 3A 4E E0    ld   a,($E04E)
1266: E6 3F       and  $3F
1268: 28 1B       jr   z,$1285
126A: E6 1F       and  $1F
126C: C0          ret  nz
126D: CD 7B 03    call $037B
1270: CD 88 12    call $1288
1273: 36 02       ld   (hl),$02
1275: EB          ex   de,hl
1276: 36 12       ld   (hl),$12
1278: 21 0B E5    ld   hl,$E50B
127B: 7E          ld   a,(hl)
127C: 23          inc  hl
127D: 96          sub  (hl)
127E: FE 40       cp   $40
1280: D8          ret  c
1281: 23          inc  hl
1282: 36 00       ld   (hl),$00
1284: C9          ret
1285: CD 00 03    call $0300
1288: 3A 0D E5    ld   a,($E50D)
128B: 21 55 80    ld   hl,$8055
128E: 01 02 13    ld   bc,$1302
1291: 11 20 00    ld   de,$0020
1294: 3D          dec  a
1295: 28 08       jr   z,$129F
1297: 19          add  hl,de
1298: 0C          inc  c
1299: 05          dec  b
129A: 3D          dec  a
129B: 28 02       jr   z,$129F
129D: 04          inc  b
129E: 19          add  hl,de
129F: 70          ld   (hl),b
12A0: 11 00 04    ld   de,$0400
12A3: EB          ex   de,hl
12A4: 19          add  hl,de
12A5: 71          ld   (hl),c
12A6: C9          ret
12A7: 21 70 E3    ld   hl,$E370
12AA: 11 10 00    ld   de,$0010
12AD: 01 02 19    ld   bc,$1902
12B0: 7E          ld   a,(hl)
12B1: FE 14       cp   $14
12B3: 28 2A       jr   z,$12DF
12B5: FE 1E       cp   $1E
12B7: 38 1B       jr   c,$12D4
12B9: FE 20       cp   $20
12BB: 38 08       jr   c,$12C5
12BD: FE 22       cp   $22
12BF: 38 13       jr   c,$12D4
12C1: FE 2A       cp   $2A
12C3: 30 0F       jr   nc,$12D4
12C5: 3A DF E1    ld   a,($E1DF)
12C8: 1F          rra
12C9: 1F          rra
12CA: D8          ret  c
12CB: 79          ld   a,c
12CC: 32 DF E1    ld   ($E1DF),a
12CF: C6 15       add  a,$15
12D1: C3 6F 0D    jp   $0D6F
12D4: 19          add  hl,de
12D5: 10 D9       djnz $12B0
12D7: 3A DF E1    ld   a,($E1DF)
12DA: A7          and  a
12DB: C8          ret  z
12DC: AF          xor  a
12DD: 18 ED       jr   $12CC
12DF: 3A DF E1    ld   a,($E1DF)
12E2: 1F          rra
12E3: 0D          dec  c
12E4: 30 E5       jr   nc,$12CB
12E6: C9          ret
12E7: 3A DC E1    ld   a,($E1DC)
12EA: A7          and  a
12EB: C8          ret  z
12EC: 3A 4E E0    ld   a,($E04E)
12EF: E6 0F       and  $0F
12F1: 28 04       jr   z,$12F7
12F3: E6 07       and  $07
12F5: C0          ret  nz
12F6: 3C          inc  a
12F7: 3C          inc  a
12F8: 4F          ld   c,a
12F9: 2A DA E1    ld   hl,($E1DA)
12FC: 7E          ld   a,(hl)
12FD: D6 5A       sub  $5A
12FF: 28 0A       jr   z,$130B
1301: 3C          inc  a
1302: 06 04       ld   b,$04
1304: C6 05       add  a,$05
1306: 28 03       jr   z,$130B
1308: 10 FA       djnz $1304
130A: C9          ret
130B: 11 00 04    ld   de,$0400
130E: 19          add  hl,de
130F: 71          ld   (hl),c
1310: C9          ret
1311: 21 00 40    ld   hl,$4000
1314: 22 02 E3    ld   ($E302),hl
1317: 3A 4E E0    ld   a,($E04E)
131A: E6 03       and  $03
131C: 20 48       jr   nz,$1366
131E: DD 35 0A    dec  (ix+$0a)
1321: F2 66 13    jp   p,$1366
1324: 21 5F 2A    ld   hl,$2A5F
1327: CD 7B 03    call $037B
132A: 3E 18       ld   a,$18
132C: CD 75 0D    call $0D75
132F: 18 29       jr   $135A
1331: CD 48 15    call $1548
1334: 07          rlca
1335: 07          rlca
1336: 30 2B       jr   nc,$1363
1338: 2A 1A E3    ld   hl,($E31A)
133B: 11 79 FF    ld   de,$FF79
133E: 19          add  hl,de
133F: 7C          ld   a,h
1340: A7          and  a
1341: 20 05       jr   nz,$1348
1343: 7D          ld   a,l
1344: FE D1       cp   $D1
1346: 38 02       jr   c,$134A
1348: 3E D1       ld   a,$D1
134A: 5F          ld   e,a
134B: CB 3B       srl  e
134D: 83          add  a,e
134E: 2F          cpl
134F: 6F          ld   l,a
1350: 3E FF       ld   a,$FF
1352: DE 00       sbc  a,$00
1354: 67          ld   h,a
1355: 2B          dec  hl
1356: 67          ld   h,a
1357: 22 08 E3    ld   ($E308),hl
135A: DD 34 00    inc  (ix+$00)
135D: CD 76 15    call $1576
1360: C3 B8 08    jp   $08B8
1363: CD 8A 14    call $148A
1366: CD 33 15    call $1533
1369: D6 1C       sub  $1C
136B: 32 07 E3    ld   ($E307),a
136E: 18 ED       jr   $135D
1370: DD 34 00    inc  (ix+$00)
1373: 3E 14       ld   a,$14
1375: CD 75 0D    call $0D75
1378: CD 48 15    call $1548
137B: 2A 0E E3    ld   hl,($E30E)
137E: CD A4 14    call $14A4
1381: CD 33 15    call $1533
1384: D6 1E       sub  $1E
1386: 18 E3       jr   $136B
1388: CD 48 15    call $1548
138B: 2A 0E E3    ld   hl,($E30E)
138E: CD A4 14    call $14A4
1391: 2A 06 E3    ld   hl,($E306)
1394: ED 5B 08 E3 ld   de,($E308)
1398: 19          add  hl,de
1399: 22 06 E3    ld   ($E306),hl
139C: 21 0C 00    ld   hl,$000C
139F: 19          add  hl,de
13A0: 22 08 E3    ld   ($E308),hl
13A3: CB 14       rl   h
13A5: 38 0F       jr   c,$13B6
13A7: CD 33 15    call $1533
13AA: D6 1D       sub  $1D
13AC: 47          ld   b,a
13AD: 3A 07 E3    ld   a,($E307)
13B0: B8          cp   b
13B1: 38 03       jr   c,$13B6
13B3: DD 34 00    inc  (ix+$00)
13B6: CD AC 15    call $15AC
13B9: C3 B8 08    jp   $08B8
13BC: DD 36 00 02 ld   (ix+$00),$02
13C0: 18 B6       jr   $1378
13C2: 2A 02 E3    ld   hl,($E302)
13C5: ED 5B 04 E3 ld   de,($E304)
13C9: 19          add  hl,de
13CA: 22 02 E3    ld   ($E302),hl
13CD: 2A 06 E3    ld   hl,($E306)
13D0: ED 5B 08 E3 ld   de,($E308)
13D4: 19          add  hl,de
13D5: 22 06 E3    ld   ($E306),hl
13D8: CD B8 08    call $08B8
13DB: DD 35 0A    dec  (ix+$0a)
13DE: C0          ret  nz
13DF: DD 34 00    inc  (ix+$00)
13E2: DD 36 0D 03 ld   (ix+$0d),$03
13E6: 3E 1F       ld   a,$1F
13E8: C3 75 0D    jp   $0D75
13EB: AF          xor  a
13EC: 32 A2 E1    ld   ($E1A2),a
13EF: DD 35 0A    dec  (ix+$0a)
13F2: F0          ret  p
13F3: DD 7E 0D    ld   a,(ix+$0d)
13F6: FE 09       cp   $09
13F8: D2 18 01    jp   nc,$0118
13FB: FE 05       cp   $05
13FD: 38 0B       jr   c,$140A
13FF: CD B8 08    call $08B8
1402: DD 34 0D    inc  (ix+$0d)
1405: DD 36 0A 0E ld   (ix+$0a),$0E
1409: C9          ret
140A: DD CB 0A 4E bit  1,(ix+$0a)
140E: C0          ret  nz
140F: EE 07       xor  $07
1411: DD 77 0D    ld   (ix+$0d),a
1414: DD 7E 0A    ld   a,(ix+$0a)
1417: FE C0       cp   $C0
1419: D2 B8 08    jp   nc,$08B8
141C: DD 36 0D 05 ld   (ix+$0d),$05
1420: C9          ret

1421: DD 35 0A    dec  (ix+$0a)
1424: DD 7E 0A    ld   a,(ix+$0a)
1427: FE 50       cp   $50
1429: D0          ret  nc
142A: 21 4D E0    ld   hl,$E04D
142D: 34          inc  (hl)
142E: DD 36 00 04 ld   (ix+$00),$04
1432: C9          ret
1433: CD DB 20    call $20DB
1436: 22 D6 E0    ld   ($E0D6),hl
1439: 7C          ld   a,h
143A: D6 08       sub  $08
143C: FE F0       cp   $F0
143E: D2 52 08    jp   nc,$0852
1441: 2A D8 E0    ld   hl,($E0D8)
1444: 23          inc  hl
1445: CB 7C       bit  7,h
1447: 20 02       jr   nz,$144B
1449: 2B          dec  hl
144A: 2B          dec  hl
144B: 22 D8 E0    ld   ($E0D8),hl
144E: 2A DA E0    ld   hl,($E0DA)
1451: ED 5B DC E0 ld   de,($E0DC)
1455: 19          add  hl,de
1456: 4C          ld   c,h
1457: 22 DA E0    ld   ($E0DA),hl
145A: 21 24 00    ld   hl,$0024
145D: 19          add  hl,de
145E: 22 DC E0    ld   ($E0DC),hl
1461: CB 14       rl   h
1463: 38 1F       jr   c,$1484
1465: C6 0B       add  a,$0B
1467: CD 38 15    call $1538
146A: D6 08       sub  $08
146C: B9          cp   c
146D: 30 15       jr   nc,$1484
146F: ED 5B DC E0 ld   de,($E0DC)
1473: 21 00 00    ld   hl,$0000
1476: ED 52       sbc  hl,de
1478: CB 3A       srl  d
147A: CB 1B       rr   e
147C: CB 3A       srl  d
147E: CB 1B       rr   e
1480: 19          add  hl,de
1481: 22 DC E0    ld   ($E0DC),hl
1484: CD B8 08    call $08B8
1487: C3 EF 20    jp   $20EF
148A: 3A 49 E0    ld   a,($E049)
148D: 87          add  a,a
148E: 21 28 30    ld   hl,$3028
1491: 85          add  a,l
1492: 6F          ld   l,a
1493: 5E          ld   e,(hl)
1494: 23          inc  hl
1495: 66          ld   h,(hl)
1496: 2E 00       ld   l,$00
1498: 22 0E E3    ld   ($E30E),hl
149B: AF          xor  a
149C: CB 13       rl   e
149E: 17          rla
149F: 57          ld   d,a
14A0: ED 53 1C E3 ld   ($E31C),de
14A4: ED 5B 02 E3 ld   de,($E302)
14A8: AF          xor  a
14A9: ED 52       sbc  hl,de
14AB: 4F          ld   c,a
14AC: 7C          ld   a,h
14AD: 30 03       jr   nc,$14B2
14AF: ED 44       neg
14B1: 0C          inc  c
14B2: FE 18       cp   $18
14B4: 38 02       jr   c,$14B8
14B6: 3E 18       ld   a,$18
14B8: 21 30 30    ld   hl,$3030
14BB: 85          add  a,l
14BC: 6F          ld   l,a
14BD: 5E          ld   e,(hl)
14BE: 16 00       ld   d,$00
14C0: 2A 04 E3    ld   hl,($E304)
14C3: 7C          ld   a,h
14C4: A7          and  a
14C5: F2 D4 14    jp   p,$14D4
14C8: 0D          dec  c
14C9: 20 11       jr   nz,$14DC
14CB: 2F          cpl
14CC: 67          ld   h,a
14CD: 7D          ld   a,l
14CE: 2F          cpl
14CF: 6F          ld   l,a
14D0: 23          inc  hl
14D1: EB          ex   de,hl
14D2: 18 03       jr   $14D7
14D4: 0D          dec  c
14D5: 28 57       jr   z,$152E
14D7: A7          and  a
14D8: ED 52       sbc  hl,de
14DA: 30 52       jr   nc,$152E
14DC: 11 02 00    ld   de,$0002
14DF: 3A 4E E0    ld   a,($E04E)
14E2: 1F          rra
14E3: 2A 04 E3    ld   hl,($E304)
14E6: ED 5A       adc  hl,de
14E8: 22 04 E3    ld   ($E304),hl
14EB: ED 5B 02 E3 ld   de,($E302)
14EF: 19          add  hl,de
14F0: 22 02 E3    ld   ($E302),hl
14F3: 54          ld   d,h
14F4: 21 DC E1    ld   hl,$E1DC
14F7: 7E          ld   a,(hl)
14F8: 3D          dec  a
14F9: C0          ret  nz
14FA: 3A 0B E5    ld   a,($E50B)
14FD: 87          add  a,a
14FE: 87          add  a,a
14FF: 87          add  a,a
1500: C6 08       add  a,$08
1502: 82          add  a,d
1503: D0          ret  nc
1504: 36 00       ld   (hl),$00
1506: 21 0E E5    ld   hl,$E50E
1509: 34          inc  (hl)
150A: 7E          ld   a,(hl)
150B: 06 09       ld   b,$09
150D: FE 19       cp   $19
150F: 28 0F       jr   z,$1520
1511: 38 01       jr   c,$1514
1513: 3D          dec  a
1514: D6 05       sub  $05
1516: CA C0 27    jp   z,$27C0
1519: 10 F9       djnz $1514
151B: FE 06       cp   $06
151D: CA C0 27    jp   z,$27C0
1520: 3E 10       ld   a,$10
1522: CD 75 0D    call $0D75
1525: AF          xor  a
1526: 0E 01       ld   c,$01
1528: CD C2 02    call $02C2
152B: C3 12 0D    jp   $0D12
152E: 11 FD FF    ld   de,$FFFD
1531: 18 AC       jr   $14DF
1533: 3A 03 E3    ld   a,($E303)
1536: C6 20       add  a,$20
1538: 47          ld   b,a
1539: 3A E2 E1    ld   a,($E1E2)
153C: 80          add  a,b
153D: C6 06       add  a,$06
153F: CB 3F       srl  a
1541: CB 3F       srl  a
1543: 6F          ld   l,a
1544: 26 E2       ld   h,$E2
1546: 7E          ld   a,(hl)
1547: C9          ret
1548: 2A 4A E0    ld   hl,($E04A)
154B: 7C          ld   a,h
154C: AD          xor  l
154D: A5          and  l
154E: 07          rlca
154F: D0          ret  nc
1550: 4F          ld   c,a
1551: 3A 20 E3    ld   a,($E320)
1554: A7          and  a
1555: 20 05       jr   nz,$155C
1557: 3E 0A       ld   a,$0A
1559: 32 20 E3    ld   ($E320),a
155C: 21 30 E3    ld   hl,$E330
155F: 06 04       ld   b,$04
1561: 11 10 00    ld   de,$0010
1564: 7E          ld   a,(hl)
1565: A7          and  a
1566: 28 05       jr   z,$156D
1568: 19          add  hl,de
1569: 10 F9       djnz $1564
156B: 79          ld   a,c
156C: C9          ret
156D: 36 0E       ld   (hl),$0E
156F: 3E 12       ld   a,$12
1571: CD 75 0D    call $0D75
1574: 79          ld   a,c
1575: C9          ret
1576: 3A 03 E3    ld   a,($E303)
1579: 4F          ld   c,a
157A: C6 04       add  a,$04
157C: CD 38 15    call $1538
157F: D6 09       sub  $09
1581: CD C9 15    call $15C9
1584: 7A          ld   a,d
1585: EE 03       xor  $03
1587: 57          ld   d,a
1588: 3E 09       ld   a,$09
158A: CD 92 15    call $1592
158D: 2C          inc  l
158E: 14          inc  d
158F: 14          inc  d
1590: 3E 0D       ld   a,$0D
1592: 81          add  a,c
1593: 4F          ld   c,a
1594: 2C          inc  l
1595: 2C          inc  l
1596: 7D          ld   a,l
1597: E6 3F       and  $3F
1599: 6F          ld   l,a
159A: 7E          ld   a,(hl)
159B: D6 09       sub  $09
159D: CD ED 08    call $08ED
15A0: 47          ld   b,a
15A1: FD 23       inc  iy
15A3: FD 23       inc  iy
15A5: FD 23       inc  iy
15A7: FD 23       inc  iy
15A9: C3 76 09    jp   $0976
15AC: 3A 03 E3    ld   a,($E303)
15AF: 4F          ld   c,a
15B0: 3A 07 E3    ld   a,($E307)
15B3: C6 11       add  a,$11
15B5: CD C9 15    call $15C9
15B8: 7A          ld   a,d
15B9: EE 03       xor  $03
15BB: 57          ld   d,a
15BC: 3E 09       ld   a,$09
15BE: CD C5 15    call $15C5
15C1: 14          inc  d
15C2: 14          inc  d
15C3: 3E 0D       ld   a,$0D
15C5: 81          add  a,c
15C6: 4F          ld   c,a
15C7: 18 D8       jr   $15A1
15C9: 0C          inc  c
15CA: CD ED 08    call $08ED
15CD: 47          ld   b,a
15CE: 11 00 05    ld   de,$0500
15D1: 3A E2 E1    ld   a,($E1E2)
15D4: CB 67       bit  4,a
15D6: 20 01       jr   nz,$15D9
15D8: 14          inc  d
15D9: FD 21 A4 E1 ld   iy,$E1A4
15DD: C3 76 09    jp   $0976
15E0: DD 36 0A 0C ld   (ix+$0a),$0C
15E4: 3A 07 E3    ld   a,($E307)
15E7: C6 0A       add  a,$0A
15E9: 32 27 E3    ld   ($E327),a
15EC: 2A 02 E3    ld   hl,($E302)
15EF: 11 00 1C    ld   de,$1C00
15F2: 19          add  hl,de
15F3: 22 22 E3    ld   ($E322),hl
15F6: DD 34 00    inc  (ix+$00)
15F9: C9          ret
15FA: DD 35 0A    dec  (ix+$0a)
15FD: 28 19       jr   z,$1618
15FF: 2A 22 E3    ld   hl,($E322)
1602: 11 5D 04    ld   de,$045D
1605: 19          add  hl,de
1606: 22 22 E3    ld   ($E322),hl
1609: DD 7E 0A    ld   a,(ix+$0a)
160C: 1F          rra
160D: 3E 09       ld   a,$09
160F: 38 01       jr   c,$1612
1611: 3C          inc  a
1612: DD 77 0D    ld   (ix+$0d),a
1615: C3 B8 08    jp   $08B8
1618: DD 34 00    inc  (ix+$00)
161B: DD 36 0A 03 ld   (ix+$0a),$03
161F: DD 36 0D 0B ld   (ix+$0d),$0B
1623: 3A E2 E1    ld   a,($E1E2)
1626: DD 86 03    add  a,(ix+$03)
1629: DD 77 0F    ld   (ix+$0f),a
162C: C9          ret
162D: CD 31 08    call $0831
1630: DD 35 0A    dec  (ix+$0a)
1633: F0          ret  p
1634: DD 7E 0D    ld   a,(ix+$0d)
1637: FE 0D       cp   $0D
1639: CA 52 08    jp   z,$0852
163C: FE 29       cp   $29
163E: CA 52 08    jp   z,$0852
1641: DD 34 0D    inc  (ix+$0d)
1644: DD 36 0A 03 ld   (ix+$0a),$03
1648: C9          ret
1649: 3A 03 E3    ld   a,($E303)
164C: C6 0A       add  a,$0A
164E: DD 77 03    ld   (ix+$03),a
1651: 3A 07 E3    ld   a,($E307)
1654: C6 02       add  a,$02
1656: DD 77 07    ld   (ix+$07),a
1659: DD 34 00    inc  (ix+$00)
165C: C9          ret
165D: 3A 00 E3    ld   a,($E300)
1660: FE 06       cp   $06
1662: 30 2B       jr   nc,$168F
1664: DD 7E 07    ld   a,(ix+$07)
1667: D6 03       sub  $03
1669: FE 3A       cp   $3A
166B: 38 22       jr   c,$168F
166D: DD 77 07    ld   (ix+$07),a
1670: CD 1B 08    call $081B
1673: DD 7E 07    ld   a,(ix+$07)
1676: 1F          rra
1677: 1F          rra
1678: 1F          rra
1679: 7A          ld   a,d
167A: 17          rla
167B: E6 07       and  $07
167D: F6 60       or   $60
167F: 77          ld   (hl),a
1680: 11 00 04    ld   de,$0400
1683: 19          add  hl,de
1684: 36 00       ld   (hl),$00
1686: 1F          rra
1687: D0          ret  nc
1688: 11 20 FC    ld   de,$FC20
168B: 19          add  hl,de
168C: 36 00       ld   (hl),$00
168E: C9          ret
168F: CD 1B 08    call $081B
1692: 36 00       ld   (hl),$00
1694: DD 36 00 00 ld   (ix+$00),$00
1698: C9          ret
1699: DD 4E 03    ld   c,(ix+$03)
169C: DD 7E 0C    ld   a,(ix+$0c)
169F: 87          add  a,a
16A0: 87          add  a,a
16A1: 87          add  a,a
16A2: 21 1C 31    ld   hl,$311C
16A5: 85          add  a,l
16A6: 6F          ld   l,a
16A7: 3A 20 E3    ld   a,($E320)
16AA: 11 04 F8    ld   de,$F804
16AD: D6 0B       sub  $0B
16AF: 28 06       jr   z,$16B7
16B1: 3D          dec  a
16B2: 20 17       jr   nz,$16CB
16B4: 11 0A F0    ld   de,$F00A
16B7: 3A 23 E3    ld   a,($E323)
16BA: 82          add  a,d
16BB: 91          sub  c
16BC: FE E8       cp   $E8
16BE: 38 0B       jr   c,$16CB
16C0: 3A 27 E3    ld   a,($E327)
16C3: DD 96 07    sub  (ix+$07)
16C6: 86          add  a,(hl)
16C7: 83          add  a,e
16C8: F2 4E 17    jp   p,$174E
16CB: DD 7E 0C    ld   a,(ix+$0c)
16CE: A7          and  a
16CF: F8          ret  m
16D0: 23          inc  hl
16D1: 3A 03 E3    ld   a,($E303)
16D4: 91          sub  c
16D5: 86          add  a,(hl)
16D6: 23          inc  hl
16D7: 46          ld   b,(hl)
16D8: 23          inc  hl
16D9: B8          cp   b
16DA: 38 05       jr   c,$16E1
16DC: 96          sub  (hl)
16DD: 30 01       jr   nc,$16E0
16DF: AF          xor  a
16E0: 80          add  a,b
16E1: 23          inc  hl
16E2: BE          cp   (hl)
16E3: D2 C4 17    jp   nc,$17C4
16E6: 23          inc  hl
16E7: 46          ld   b,(hl)
16E8: 23          inc  hl
16E9: 86          add  a,(hl)
16EA: 6F          ld   l,a
16EB: 24          inc  h
16EC: 3A 07 E3    ld   a,($E307)
16EF: 86          add  a,(hl)
16F0: DD 96 07    sub  (ix+$07)
16F3: 3D          dec  a
16F4: 80          add  a,b
16F5: F8          ret  m
16F6: 3A 04 D0    ld   a,($D004)
16F9: CB 77       bit  6,a
16FB: C8          ret  z
16FC: E1          pop  hl
16FD: 3E 07       ld   a,$07
16FF: 32 00 E3    ld   ($E300),a
1702: 3E 03       ld   a,$03
1704: 32 0D E3    ld   ($E30D),a
1707: AF          xor  a
1708: 32 0A E3    ld   ($E30A),a
170B: 32 B0 E3    ld   ($E3B0),a
170E: 32 72 E1    ld   ($E172),a
1711: CD 52 08    call $0852
1714: 06 03       ld   b,$03
1716: 3A 07 E3    ld   a,($E307)
1719: C6 14       add  a,$14
171B: 4F          ld   c,a
171C: 3A 03 E3    ld   a,($E303)
171F: 21 D3 E1    ld   hl,$E1D3
1722: 34          inc  (hl)
1723: 21 C0 E3    ld   hl,$E3C0
1726: FD 21 DF 30 ld   iy,$30DF
172A: 36 1C       ld   (hl),$1C
172C: 23          inc  hl
172D: 23          inc  hl
172E: 23          inc  hl
172F: 77          ld   (hl),a
1730: C6 10       add  a,$10
1732: CD F8 17    call $17F8
1735: 71          ld   (hl),c
1736: CD F8 17    call $17F8
1739: 23          inc  hl
173A: 23          inc  hl
173B: FD 5E 00    ld   e,(iy+$00)
173E: 73          ld   (hl),e
173F: FD 23       inc  iy
1741: 23          inc  hl
1742: 23          inc  hl
1743: 23          inc  hl
1744: 10 E4       djnz $172A
1746: CD A1 08    call $08A1
1749: 3E 1F       ld   a,$1F
174B: C3 75 0D    jp   $0D75
174E: 3A E2 E1    ld   a,($E1E2)
1751: DD 86 03    add  a,(ix+$03)
1754: 32 2F E3    ld   ($E32F),a
1757: 3E 0D       ld   a,$0D
1759: 32 20 E3    ld   ($E320),a
175C: 3E 26       ld   a,$26
175E: 32 2D E3    ld   ($E32D),a
1761: 3E 03       ld   a,$03
1763: 32 2A E3    ld   ($E32A),a
1766: 3E 01       ld   a,$01
1768: CD 75 0D    call $0D75
176B: 11 07 00    ld   de,$0007
176E: 19          add  hl,de
176F: 7E          ld   a,(hl)
1770: E6 0F       and  $0F
1772: 0E 01       ld   c,$01
1774: FE 0E       cp   $0E
1776: 30 07       jr   nc,$177F
1778: CD C2 02    call $02C2
177B: E1          pop  hl
177C: C3 52 08    jp   $0852
177F: 20 13       jr   nz,$1794
1781: CD F0 17    call $17F0
1784: C6 05       add  a,$05
1786: DD 77 08    ld   (ix+$08),a
1789: CD C2 02    call $02C2
178C: DD 34 00    inc  (ix+$00)
178F: DD 36 0A 00 ld   (ix+$0a),$00
1793: C9          ret
1794: CD 56 08    call $0856
1797: CD F0 17    call $17F0
179A: 21 10 FB    ld   hl,$FB10
179D: C6 06       add  a,$06
179F: DD 77 08    ld   (ix+$08),a
17A2: E5          push hl
17A3: CD C2 02    call $02C2
17A6: E1          pop  hl
17A7: DD 7E 07    ld   a,(ix+$07)
17AA: 84          add  a,h
17AB: DD 77 07    ld   (ix+$07),a
17AE: DD 7E 03    ld   a,(ix+$03)
17B1: 85          add  a,l
17B2: DD 77 03    ld   (ix+$03),a
17B5: DD 36 0D 54 ld   (ix+$0d),$54
17B9: DD 36 00 21 ld   (ix+$00),$21
17BD: DD 36 0A 3B ld   (ix+$0a),$3B
17C1: C3 56 08    jp   $0856
17C4: 47          ld   b,a
17C5: DD 7E 0C    ld   a,(ix+$0c)
17C8: C6 80       add  a,$80
17CA: 4F          ld   c,a
17CB: FE 8B       cp   $8B
17CD: 28 1B       jr   z,$17EA
17CF: FE 8E       cp   $8E
17D1: 28 17       jr   z,$17EA
17D3: 78          ld   a,b
17D4: 96          sub  (hl)
17D5: FE 04       cp   $04
17D7: D0          ret  nc
17D8: DD 71 0C    ld   (ix+$0c),c
17DB: 23          inc  hl
17DC: 23          inc  hl
17DD: 23          inc  hl
17DE: 7E          ld   a,(hl)
17DF: 1F          rra
17E0: 1F          rra
17E1: 1F          rra
17E2: 1F          rra
17E3: E6 0F       and  $0F
17E5: 0E 01       ld   c,$01
17E7: C3 C2 02    jp   $02C2
17EA: 78          ld   a,b
17EB: FE FC       cp   $FC
17ED: 30 E9       jr   nc,$17D8
17EF: C9          ret
17F0: ED 5F       ld   a,r
17F2: E6 03       and  $03
17F4: C0          ret  nz
17F5: 3E 02       ld   a,$02
17F7: C9          ret
17F8: 23          inc  hl
17F9: FD 5E 00    ld   e,(iy+$00)
17FC: 73          ld   (hl),e
17FD: 23          inc  hl
17FE: FD 5E 01    ld   e,(iy+$01)
1801: 73          ld   (hl),e
1802: 23          inc  hl
1803: 23          inc  hl
1804: FD 23       inc  iy
1806: FD 23       inc  iy
1808: C9          ret
1809: 3A 00 E3    ld   a,($E300)
180C: FE 06       cp   $06
180E: D0          ret  nc
180F: FE 01       cp   $01
1811: 26 00       ld   h,$00
1813: 28 76       jr   z,$188B
1815: 2A 1C E3    ld   hl,($E31C)
1818: ED 5B 1A E3 ld   de,($E31A)
181C: 7A          ld   a,d
181D: A7          and  a
181E: FA 23 18    jp   m,$1823
1821: ED 52       sbc  hl,de
1823: 21 03 00    ld   hl,$0003
1826: 30 03       jr   nc,$182B
1828: 21 FE FF    ld   hl,$FFFE
182B: 3A 4E E0    ld   a,($E04E)
182E: 1F          rra
182F: 38 01       jr   c,$1832
1831: 1D          dec  e
1832: 19          add  hl,de
1833: 22 1A E3    ld   ($E31A),hl
1836: ED 5B 04 E3 ld   de,($E304)
183A: A7          and  a
183B: ED 52       sbc  hl,de
183D: 22 14 E3    ld   ($E314),hl
1840: EB          ex   de,hl
1841: 2A E1 E1    ld   hl,($E1E1)
1844: 19          add  hl,de
1845: 22 E1 E1    ld   ($E1E1),hl
1848: 3A D9 E1    ld   a,($E1D9)
184B: 1F          rra
184C: 30 3D       jr   nc,$188B
184E: 2A EF E0    ld   hl,($E0EF)
1851: 19          add  hl,de
1852: 7C          ld   a,h
1853: C6 06       add  a,$06
1855: FE 0C       cp   $0C
1857: 38 17       jr   c,$1870
1859: D6 12       sub  $12
185B: 67          ld   h,a
185C: E5          push hl
185D: 21 3F E2    ld   hl,$E23F
1860: 11 42 E2    ld   de,$E242
1863: 01 40 00    ld   bc,$0040
1866: ED B8       lddr
1868: 21 42 E2    ld   hl,$E242
186B: 0E 03       ld   c,$03
186D: ED B8       lddr
186F: E1          pop  hl
1870: 22 EF E0    ld   ($E0EF),hl
1873: ED 5B F1 E0 ld   de,($E0F1)
1877: 19          add  hl,de
1878: 3A 08 E5    ld   a,($E508)
187B: FE 03       cp   $03
187D: 30 0C       jr   nc,$188B
187F: 3A E2 E1    ld   a,($E1E2)
1882: 94          sub  h
1883: FE F4       cp   $F4
1885: 38 04       jr   c,$188B
1887: AF          xor  a
1888: 32 D9 E1    ld   ($E1D9),a
188B: 7C          ld   a,h
188C: 2F          cpl
188D: 21 3D E0    ld   hl,$E03D
1890: 86          add  a,(hl)
1891: 32 C0 E1    ld   ($E1C0),a
1894: 2A 14 E3    ld   hl,($E314)
1897: 54          ld   d,h
1898: 5D          ld   e,l
1899: CB 3C       srl  h
189B: CB 1D       rr   l
189D: 19          add  hl,de
189E: CB 3C       srl  h
18A0: CB 1D       rr   l
18A2: CB 3C       srl  h
18A4: CB 1D       rr   l
18A6: EB          ex   de,hl
18A7: 2A 04 E5    ld   hl,($E504)
18AA: 19          add  hl,de
18AB: 22 04 E5    ld   ($E504),hl
18AE: 7C          ld   a,h
18AF: 2F          cpl
18B0: 32 C1 E1    ld   ($E1C1),a
18B3: CB 3A       srl  d
18B5: CB 1B       rr   e
18B7: 2A 06 E5    ld   hl,($E506)
18BA: 19          add  hl,de
18BB: 22 06 E5    ld   ($E506),hl
18BE: 7C          ld   a,h
18BF: 2F          cpl
18C0: 32 C2 E1    ld   ($E1C2),a
18C3: CD 33 15    call $1533
18C6: FE C4       cp   $C4
18C8: 30 02       jr   nc,$18CC
18CA: 3E C4       ld   a,$C4
18CC: C6 28       add  a,$28
18CE: 30 01       jr   nc,$18D1
18D0: AF          xor  a
18D1: 47          ld   b,a
18D2: C6 94       add  a,$94
18D4: 32 C3 E1    ld   ($E1C3),a
18D7: CB 28       sra  b
18D9: 78          ld   a,b
18DA: C6 72       add  a,$72
18DC: 32 C4 E1    ld   ($E1C4),a
18DF: C9          ret
18E0: CD 31 08    call $0831
18E3: CD 99 16    call $1699
18E6: DD 35 0A    dec  (ix+$0a)
18E9: F0          ret  p
18EA: DD 34 0A    inc  (ix+$0a)
18ED: DD 7E 03    ld   a,(ix+$03)
18F0: FE E0       cp   $E0
18F2: D0          ret  nc
18F3: DD 7E 0C    ld   a,(ix+$0c)
18F6: 17          rla
18F7: D8          ret  c
18F8: 3A C0 E3    ld   a,($E3C0)
18FB: A7          and  a
18FC: C0          ret  nz
18FD: FD 21 70 E3 ld   iy,$E370
1901: 11 10 00    ld   de,$0010
1904: 06 05       ld   b,$05
1906: FD 7E 00    ld   a,(iy+$00)
1909: FE 1D       cp   $1D
190B: 20 0D       jr   nz,$191A
190D: FD 7E 0C    ld   a,(iy+$0c)
1910: 17          rla
1911: 38 07       jr   c,$191A
1913: DD 7E 03    ld   a,(ix+$03)
1916: FD 96 03    sub  (iy+$03)
1919: D8          ret  c
191A: FD 19       add  iy,de
191C: 10 E8       djnz $1906
191E: DD 7E 07    ld   a,(ix+$07)
1921: FD 77 07    ld   (iy+$07),a
1924: DD 7E 0F    ld   a,(ix+$0f)
1927: D6 04       sub  $04
1929: FD 77 0F    ld   (iy+$0f),a
192C: FD 36 00 11 ld   (iy+$00),$11
1930: FD 36 0D 22 ld   (iy+$0d),$22
1934: FD 36 0C 0C ld   (iy+$0c),$0C
1938: DD 36 0A 43 ld   (ix+$0a),$43
193C: C9          ret
193D: 3A 00 E3    ld   a,($E300)
1940: FE 06       cp   $06
1942: D0          ret  nc
1943: DD 7E 04    ld   a,(ix+$04)
1946: C6 DD       add  a,$DD
1948: DD 77 04    ld   (ix+$04),a
194B: 30 03       jr   nc,$1950
194D: DD 35 0F    dec  (ix+$0f)
1950: CD 38 08    call $0838
1953: CD 99 16    call $1699
1956: C9          ret
1957: CD 31 08    call $0831
195A: CD 99 16    call $1699
195D: C9          ret
195E: CD 31 08    call $0831
1961: DD 7E 0C    ld   a,(ix+$0c)
1964: A7          and  a
1965: C0          ret  nz
1966: DD 7E 0D    ld   a,(ix+$0d)
1969: 07          rlca
196A: 07          rlca
196B: E6 1C       and  $1C
196D: 21 00 2E    ld   hl,$2E00
1970: 85          add  a,l
1971: 6F          ld   l,a
1972: 3A 03 E3    ld   a,($E303)
1975: DD 96 03    sub  (ix+$03)
1978: 86          add  a,(hl)
1979: 23          inc  hl
197A: BE          cp   (hl)
197B: 30 45       jr   nc,$19C2
197D: 47          ld   b,a
197E: 3A 00 E3    ld   a,($E300)
1981: FE 04       cp   $04
1983: C8          ret  z
1984: 3A 04 D0    ld   a,($D004)
1987: CB 77       bit  6,a
1989: C8          ret  z
198A: 78          ld   a,b
198B: 46          ld   b,(hl)
198C: 0E 02       ld   c,$02
198E: CB 38       srl  b
1990: 50          ld   d,b
1991: CB 38       srl  b
1993: BA          cp   d
1994: 38 04       jr   c,$199A
1996: 78          ld   a,b
1997: 82          add  a,d
1998: 47          ld   b,a
1999: 0D          dec  c
199A: DD 7E 03    ld   a,(ix+$03)
199D: 80          add  a,b
199E: D6 1C       sub  $1C
19A0: 32 03 E3    ld   ($E303),a
19A3: 79          ld   a,c
19A4: 32 0D E3    ld   ($E30D),a
19A7: 3D          dec  a
19A8: 3D          dec  a
19A9: 32 05 E3    ld   ($E305),a
19AC: 3E 80       ld   a,$80
19AE: 32 04 E3    ld   ($E304),a
19B1: 23          inc  hl
19B2: 7E          ld   a,(hl)
19B3: 32 0A E3    ld   ($E30A),a
19B6: 21 00 02    ld   hl,$0200
19B9: 22 08 E3    ld   ($E308),hl
19BC: 3E 06       ld   a,$06
19BE: 32 00 E3    ld   ($E300),a
19C1: C9          ret
19C2: 96          sub  (hl)
19C3: FE 04       cp   $04
19C5: D0          ret  nc
19C6: DD 34 0C    inc  (ix+$0c)
19C9: 23          inc  hl
19CA: 23          inc  hl
19CB: 7E          ld   a,(hl)
19CC: 0E 01       ld   c,$01
19CE: C3 C2 02    jp   $02C2
19D1: DD 35 0A    dec  (ix+$0a)
19D4: F2 0D 1A    jp   p,$1A0D
19D7: DD 7E 0E    ld   a,(ix+$0e)
19DA: 47          ld   b,a
19DB: 3C          inc  a
19DC: 0E 07       ld   c,$07
19DE: FE 06       cp   $06
19E0: 38 0B       jr   c,$19ED
19E2: 3A 4E E0    ld   a,($E04E)
19E5: E6 30       and  $30
19E7: 20 02       jr   nz,$19EB
19E9: 3E 30       ld   a,$30
19EB: 4F          ld   c,a
19EC: AF          xor  a
19ED: DD 77 0E    ld   (ix+$0e),a
19F0: DD 71 0A    ld   (ix+$0a),c
19F3: 78          ld   a,b
19F4: FE 04       cp   $04
19F6: 38 04       jr   c,$19FC
19F8: EE 07       xor  $07
19FA: 3D          dec  a
19FB: 47          ld   b,a
19FC: C6 06       add  a,$06
19FE: DD 46 0C    ld   b,(ix+$0c)
1A01: 04          inc  b
1A02: FA 08 1A    jp   m,$1A08
1A05: DD 77 0C    ld   (ix+$0c),a
1A08: C6 45       add  a,$45
1A0A: DD 77 0D    ld   (ix+$0d),a
1A0D: 3A 20 E3    ld   a,($E320)
1A10: FE 0F       cp   $0F
1A12: 38 0E       jr   c,$1A22
1A14: C0          ret  nz
1A15: 3A 03 E3    ld   a,($E303)
1A18: DD 96 03    sub  (ix+$03)
1A1B: C6 10       add  a,$10
1A1D: FE 30       cp   $30
1A1F: DA FD 16    jp   c,$16FD
1A22: CD 38 08    call $0838
1A25: DD 7E 0C    ld   a,(ix+$0c)
1A28: FE 06       cp   $06
1A2A: C8          ret  z
1A2B: CD 99 16    call $1699
1A2E: C9          ret
1A2F: CD 31 08    call $0831
1A32: DD 35 0A    dec  (ix+$0a)
1A35: F0          ret  p
1A36: DD 7E 0D    ld   a,(ix+$0d)
1A39: FE 4A       cp   $4A
1A3B: C8          ret  z
1A3C: DD 35 0D    dec  (ix+$0d)
1A3F: DD 36 0A 07 ld   (ix+$0a),$07
1A43: C9          ret
1A44: 3A 00 E3    ld   a,($E300)
1A47: FE 06       cp   $06
1A49: D0          ret  nc
1A4A: DD 35 0E    dec  (ix+$0e)
1A4D: F2 66 1A    jp   p,$1A66
1A50: DD 36 0E 06 ld   (ix+$0e),$06
1A54: DD 7E 0D    ld   a,(ix+$0d)
1A57: 3D          dec  a
1A58: 01 03 00    ld   bc,$0003
1A5B: 21 8E 1A    ld   hl,$1A8E
1A5E: ED B1       cpir
1A60: 20 01       jr   nz,$1A63
1A62: 7E          ld   a,(hl)
1A63: DD 77 0D    ld   (ix+$0d),a
1A66: DD 7E 04    ld   a,(ix+$04)
1A69: C6 C0       add  a,$C0
1A6B: DD 77 04    ld   (ix+$04),a
1A6E: 30 03       jr   nc,$1A73
1A70: DD 35 0F    dec  (ix+$0f)
1A73: CD 38 08    call $0838
1A76: DD 7E 0C    ld   a,(ix+$0c)
1A79: D6 04       sub  $04
1A7B: CB 27       sla  a
1A7D: C6 0C       add  a,$0C
1A7F: 4F          ld   c,a
1A80: DD 7E 03    ld   a,(ix+$03)
1A83: CD 38 15    call $1538
1A86: 91          sub  c
1A87: DD 77 07    ld   (ix+$07),a
1A8A: CD 99 16    call $1699
1A8D: C9          ret
1A8E: 11 15 1A    ld   de,$1A15
1A91: 20 DD       jr   nz,$1A70
1A93: 36 0B       ld   (hl),$0B
1A95: 01 3A 00    ld   bc,$003A
1A98: E3          ex   (sp),hl
1A99: FE 06       cp   $06
1A9B: D0          ret  nc
1A9C: 2A 72 E3    ld   hl,($E372)
1A9F: 7C          ld   a,h
1AA0: FE 08       cp   $08
1AA2: 28 09       jr   z,$1AAD
1AA4: 11 70 00    ld   de,$0070
1AA7: 19          add  hl,de
1AA8: 22 72 E3    ld   ($E372),hl
1AAB: 18 2C       jr   $1AD9
1AAD: DD 36 0A 00 ld   (ix+$0a),$00
1AB1: DD 34 00    inc  (ix+$00)
1AB4: DD 36 0E 80 ld   (ix+$0e),$80
1AB8: C9          ret
1AB9: 3A 4E E0    ld   a,($E04E)
1ABC: 1F          rra
1ABD: D8          ret  c
1ABE: 3A 00 E3    ld   a,($E300)
1AC1: FE 06       cp   $06
1AC3: D0          ret  nc
1AC4: 3A 4E E0    ld   a,($E04E)
1AC7: 47          ld   b,a
1AC8: E6 03       and  $03
1ACA: 20 0D       jr   nz,$1AD9
1ACC: DD 34 03    inc  (ix+$03)
1ACF: CB 68       bit  5,b
1AD1: 28 06       jr   z,$1AD9
1AD3: DD 35 03    dec  (ix+$03)
1AD6: DD 35 03    dec  (ix+$03)
1AD9: 3A 4E E0    ld   a,($E04E)
1ADC: E6 07       and  $07
1ADE: 20 0D       jr   nz,$1AED
1AE0: DD 7E 03    ld   a,(ix+$03)
1AE3: C6 18       add  a,$18
1AE5: CD 38 15    call $1538
1AE8: D6 10       sub  $10
1AEA: DD 77 07    ld   (ix+$07),a
1AED: C3 B8 08    jp   $08B8
1AF0: DD 35 0E    dec  (ix+$0e)
1AF3: 20 CF       jr   nz,$1AC4
1AF5: DD 36 0A 58 ld   (ix+$0a),$58
1AF9: DD 34 00    inc  (ix+$00)
1AFC: DD 36 0D 52 ld   (ix+$0d),$52
1B00: C9          ret
1B01: DD 35 0A    dec  (ix+$0a)
1B04: 28 15       jr   z,$1B1B
1B06: 2A 72 E3    ld   hl,($E372)
1B09: 11 80 01    ld   de,$0180
1B0C: 19          add  hl,de
1B0D: 22 72 E3    ld   ($E372),hl
1B10: 7C          ld   a,h
1B11: FE F0       cp   $F0
1B13: D2 52 08    jp   nc,$0852
1B16: CD 99 16    call $1699
1B19: 18 BE       jr   $1AD9
1B1B: DD 34 00    inc  (ix+$00)
1B1E: DD 36 0A 6E ld   (ix+$0a),$6E
1B22: DD 36 0D 23 ld   (ix+$0d),$23
1B26: C9          ret
1B27: CD 99 16    call $1699
1B2A: DD 35 0A    dec  (ix+$0a)
1B2D: 20 95       jr   nz,$1AC4
1B2F: DD 35 00    dec  (ix+$00)
1B32: DD 35 0B    dec  (ix+$0b)
1B35: DD 36 0D 52 ld   (ix+$0d),$52
1B39: C9          ret
1B3A: 21 EE E0    ld   hl,$E0EE
1B3D: 3A 4E E0    ld   a,($E04E)
1B40: 96          sub  (hl)
1B41: F8          ret  m
1B42: 01 00 10    ld   bc,$1000
1B45: ED 5F       ld   a,r
1B47: E6 F0       and  $F0
1B49: 26 E4       ld   h,$E4
1B4B: 51          ld   d,c
1B4C: 59          ld   e,c
1B4D: 6F          ld   l,a
1B4E: 7E          ld   a,(hl)
1B4F: D6 1E       sub  $1E
1B51: FE 0A       cp   $0A
1B53: 30 0A       jr   nc,$1B5F
1B55: CB 4F       bit  1,a
1B57: 20 06       jr   nz,$1B5F
1B59: FE 04       cp   $04
1B5B: 38 63       jr   c,$1BC0
1B5D: 0C          inc  c
1B5E: 5D          ld   e,l
1B5F: 7D          ld   a,l
1B60: C6 10       add  a,$10
1B62: 10 E9       djnz $1B4D
1B64: ED 53 D4 E1 ld   ($E1D4),de
1B68: 0D          dec  c
1B69: F8          ret  m
1B6A: 3A 10 E5    ld   a,(time_bcd_e510)
1B6D: E6 03       and  $03
1B6F: FE 01       cp   $01
1B71: 89          adc  a,c
1B72: 4F          ld   c,a
1B73: FE 09       cp   $09
1B75: DA 7A 1B    jp   c,$1B7A
1B78: 0E 08       ld   c,$08
1B7A: 21 FF 2F    ld   hl,$2FFF
1B7D: 09          add  hl,bc
1B7E: 4E          ld   c,(hl)
1B7F: 06 05       ld   b,$05
1B81: 21 70 E3    ld   hl,$E370
1B84: 11 00 00    ld   de,$0000
1B87: 7E          ld   a,(hl)
1B88: A7          and  a
1B89: 28 39       jr   z,$1BC4
1B8B: D6 2F       sub  $2F
1B8D: 20 01       jr   nz,$1B90
1B8F: 14          inc  d
1B90: 7D          ld   a,l
1B91: C6 10       add  a,$10
1B93: 6F          ld   l,a
1B94: 10 F1       djnz $1B87
1B96: 7A          ld   a,d
1B97: B9          cp   c
1B98: D0          ret  nc
1B99: 1C          inc  e
1B9A: 1D          dec  e
1B9B: C8          ret  z
1B9C: ED 5F       ld   a,r
1B9E: E6 0F       and  $0F
1BA0: C6 19       add  a,$19
1BA2: 21 4E E0    ld   hl,$E04E
1BA5: 86          add  a,(hl)
1BA6: 32 EE E0    ld   ($E0EE),a
1BA9: 16 00       ld   d,$00
1BAB: DD 21 00 E3 ld   ix,$E300
1BAF: DD 19       add  ix,de
1BB1: 21 D4 E1    ld   hl,$E1D4
1BB4: 5E          ld   e,(hl)
1BB5: FD 21 00 E4 ld   iy,$E400
1BB9: FD 19       add  iy,de
1BBB: 0E 3B       ld   c,$3B
1BBD: C3 64 10    jp   $1064
1BC0: 55          ld   d,l
1BC1: 14          inc  d
1BC2: 18 9B       jr   $1B5F
1BC4: 5D          ld   e,l
1BC5: 18 C9       jr   $1B90
1BC7: 3A 4E E0    ld   a,($E04E)
1BCA: 21 52 E0    ld   hl,$E052
1BCD: AE          xor  (hl)
1BCE: E6 1F       and  $1F
1BD0: C0          ret  nz
1BD1: ED 5F       ld   a,r
1BD3: 77          ld   (hl),a
1BD4: 21 C6 E1    ld   hl,$E1C6
1BD7: 06 03       ld   b,$03
1BD9: 7E          ld   a,(hl)
1BDA: A7          and  a
1BDB: 20 04       jr   nz,$1BE1
1BDD: 23          inc  hl
1BDE: 10 F9       djnz $1BD9
1BE0: C9          ret
1BE1: DD 21 00 E4 ld   ix,$E400
1BE5: 04          inc  b
1BE6: 78          ld   a,b
1BE7: 48          ld   c,b
1BE8: 06 10       ld   b,$10
1BEA: FE 04       cp   $04
1BEC: 28 0F       jr   z,$1BFD
1BEE: 3A D6 E1    ld   a,($E1D6)
1BF1: 3D          dec  a
1BF2: FA FD 1B    jp   m,$1BFD
1BF5: 0D          dec  c
1BF6: 0D          dec  c
1BF7: DD 21 70 E3 ld   ix,$E370
1BFB: 06 05       ld   b,$05
1BFD: 11 10 00    ld   de,$0010
1C00: DD 7E 00    ld   a,(ix+$00)
1C03: A7          and  a
1C04: 28 05       jr   z,$1C0B
1C06: DD 19       add  ix,de
1C08: 10 F6       djnz $1C00
1C0A: C9          ret
1C0B: 35          dec  (hl)
1C0C: 79          ld   a,c
1C0D: FE 02       cp   $02
1C0F: 30 43       jr   nc,$1C54
1C11: ED 5F       ld   a,r
1C13: E6 1F       and  $1F
1C15: C6 20       add  a,$20
1C17: DD 77 0F    ld   (ix+$0f),a
1C1A: 21 D6 E1    ld   hl,$E1D6
1C1D: 35          dec  (hl)
1C1E: ED 5F       ld   a,r
1C20: E6 1E       and  $1E
1C22: 5F          ld   e,a
1C23: 16 00       ld   d,$00
1C25: FE 0E       cp   $0E
1C27: 3E 82       ld   a,$82
1C29: 38 04       jr   c,$1C2F
1C2B: ED 5F       ld   a,r
1C2D: E6 80       and  $80
1C2F: DD 77 0C    ld   (ix+$0c),a
1C32: 21 08 30    ld   hl,$3008
1C35: 19          add  hl,de
1C36: 7E          ld   a,(hl)
1C37: DD 77 07    ld   (ix+$07),a
1C3A: 23          inc  hl
1C3B: 7E          ld   a,(hl)
1C3C: DD 77 03    ld   (ix+$03),a
1C3F: 06 00       ld   b,$00
1C41: 21 59 1C    ld   hl,$1C59
1C44: 09          add  hl,bc
1C45: 09          add  hl,bc
1C46: 7E          ld   a,(hl)
1C47: DD 77 0D    ld   (ix+$0d),a
1C4A: DD 36 0E 00 ld   (ix+$0e),$00
1C4E: 23          inc  hl
1C4F: 7E          ld   a,(hl)
1C50: DD 77 00    ld   (ix+$00),a
1C53: C9          ret
1C54: CD 0A 08    call $080A
1C57: 18 C5       jr   $1C1E
1C59: 2B          dec  hl
1C5A: 26 2A       ld   h,$2A
1C5C: 26 2B       ld   h,$2B
1C5E: 22 2A 22    ld   ($222A),hl
1C61: 31 1E DD    ld   sp,$DD1E
1C64: 7E          ld   a,(hl)
1C65: 0D          dec  c
1C66: FE 2B       cp   $2B
1C68: D8          ret  c
1C69: DD CB 0E 7E bit  7,(ix+$0e)
1C6D: 20 18       jr   nz,$1C87
1C6F: DD 35 0E    dec  (ix+$0e)
1C72: F0          ret  p
1C73: DD 34 0D    inc  (ix+$0d)
1C76: FE 2F       cp   $2F
1C78: 28 1C       jr   z,$1C96
1C7A: FE 34       cp   $34
1C7C: 20 04       jr   nz,$1C82
1C7E: DD 36 0D 31 ld   (ix+$0d),$31
1C82: DD 36 0E 08 ld   (ix+$0e),$08
1C86: C9          ret
1C87: DD 34 0E    inc  (ix+$0e)
1C8A: F8          ret  m
1C8B: DD 35 0D    dec  (ix+$0d)
1C8E: FE 2C       cp   $2C
1C90: 28 F0       jr   z,$1C82
1C92: FE 32       cp   $32
1C94: 28 EC       jr   z,$1C82
1C96: DD 36 0E F8 ld   (ix+$0e),$F8
1C9A: C9          ret
1C9B: DD 6E 04    ld   l,(ix+$04)
1C9E: DD 66 05    ld   h,(ix+$05)
1CA1: CB 3C       srl  h
1CA3: CB 1D       rr   l
1CA5: DD CB 0C 46 bit  0,(ix+$0c)
1CA9: 28 07       jr   z,$1CB2
1CAB: EB          ex   de,hl
1CAC: 21 00 00    ld   hl,$0000
1CAF: A7          and  a
1CB0: ED 52       sbc  hl,de
1CB2: DD 75 04    ld   (ix+$04),l
1CB5: DD 74 05    ld   (ix+$05),h
1CB8: DD 34 00    inc  (ix+$00)
1CBB: C9          ret
1CBC: 0E 3D       ld   c,$3D
1CBE: DD 7E 09    ld   a,(ix+$09)
1CC1: A7          and  a
1CC2: 20 13       jr   nz,$1CD7
1CC4: 0E 3B       ld   c,$3B
1CC6: DD 46 05    ld   b,(ix+$05)
1CC9: CB 10       rl   b
1CCB: 30 02       jr   nc,$1CCF
1CCD: 0E 50       ld   c,$50
1CCF: DD 7E 08    ld   a,(ix+$08)
1CD2: FE 60       cp   $60
1CD4: 38 01       jr   c,$1CD7
1CD6: 0C          inc  c
1CD7: DD 71 0D    ld   (ix+$0d),c
1CDA: CD FB 20    call $20FB
1CDD: 7C          ld   a,h
1CDE: FE 06       cp   $06
1CE0: DA 52 08    jp   c,$0852
1CE3: 01 05 00    ld   bc,$0005
1CE6: 22 D6 E0    ld   ($E0D6),hl
1CE9: 7C          ld   a,h
1CEA: 2A DC E0    ld   hl,($E0DC)
1CED: 09          add  hl,bc
1CEE: 22 DC E0    ld   ($E0DC),hl
1CF1: ED 5B DA E0 ld   de,($E0DA)
1CF5: 19          add  hl,de
1CF6: 22 DA E0    ld   ($E0DA),hl
1CF9: 54          ld   d,h
1CFA: CD 38 15    call $1538
1CFD: D6 08       sub  $08
1CFF: BA          cp   d
1D00: CD EF 20    call $20EF
1D03: 30 35       jr   nc,$1D3A
1D05: DD 77 07    ld   (ix+$07),a
1D08: DD 34 00    inc  (ix+$00)
1D0B: DD 36 0B 00 ld   (ix+$0b),$00
1D0F: DD 7E 00    ld   a,(ix+$00)
1D12: FE 2A       cp   $2A
1D14: 3E 03       ld   a,$03
1D16: 20 05       jr   nz,$1D1D
1D18: DD 36 00 30 ld   (ix+$00),$30
1D1C: 3D          dec  a
1D1D: CD 75 0D    call $0D75
1D20: C3 56 08    jp   $0856
1D23: CD DB 20    call $20DB
1D26: ED 5B 14 E3 ld   de,($E314)
1D2A: CB 2A       sra  d
1D2C: CB 1B       rr   e
1D2E: ED 52       sbc  hl,de
1D30: 11 8E 00    ld   de,$008E
1D33: ED 52       sbc  hl,de
1D35: 01 10 00    ld   bc,$0010
1D38: 18 AC       jr   $1CE6
1D3A: 3A 00 E3    ld   a,($E300)
1D3D: FE 06       cp   $06
1D3F: D2 B8 08    jp   nc,$08B8
1D42: 21 05 06    ld   hl,$0605
1D45: DD 7E 00    ld   a,(ix+$00)
1D48: FE 2A       cp   $2A
1D4A: 30 03       jr   nc,$1D4F
1D4C: 21 0B 02    ld   hl,$020B
1D4F: FD 21 30 E3 ld   iy,$E330
1D53: 11 10 00    ld   de,$0010
1D56: 06 04       ld   b,$04
1D58: FD 7E 00    ld   a,(iy+$00)
1D5B: FE 0F       cp   $0F
1D5D: 20 14       jr   nz,$1D73
1D5F: FD 7E 07    ld   a,(iy+$07)
1D62: DD 96 07    sub  (ix+$07)
1D65: FE 0A       cp   $0A
1D67: 30 0A       jr   nc,$1D73
1D69: FD 7E 03    ld   a,(iy+$03)
1D6C: DD 96 03    sub  (ix+$03)
1D6F: 94          sub  h
1D70: BD          cp   l
1D71: 38 2B       jr   c,$1D9E
1D73: FD 19       add  iy,de
1D75: 10 E1       djnz $1D58
1D77: 3A 07 E3    ld   a,($E307)
1D7A: DD 96 07    sub  (ix+$07)
1D7D: FE F0       cp   $F0
1D7F: DA B8 08    jp   c,$08B8
1D82: 57          ld   d,a
1D83: 3A 03 E3    ld   a,($E303)
1D86: DD 96 03    sub  (ix+$03)
1D89: D6 04       sub  $04
1D8B: FE EA       cp   $EA
1D8D: DA B8 08    jp   c,$08B8
1D90: 3A 04 D0    ld   a,($D004)
1D93: CB 77       bit  6,a
1D95: CA B8 08    jp   z,$08B8
1D98: CD 52 08    call $0852
1D9B: C3 FD 16    jp   $16FD
1D9E: FD 34 00    inc  (iy+$00)
1DA1: DD 7E 0D    ld   a,(ix+$0d)
1DA4: FE 37       cp   $37
1DA6: 38 11       jr   c,$1DB9
1DA8: DD 36 0C 00 ld   (ix+$0c),$00
1DAC: DD 36 00 2D ld   (ix+$00),$2D
1DB0: DD 36 0A 0A ld   (ix+$0a),$0A
1DB4: DD 36 0D 4F ld   (ix+$0d),$4F
1DB8: C9          ret
1DB9: 21 C9 E1    ld   hl,$E1C9
1DBC: 01 01 05    ld   bc,$0501
1DBF: FE 31       cp   $31
1DC1: 30 07       jr   nc,$1DCA
1DC3: 23          inc  hl
1DC4: 05          dec  b
1DC5: FE 2A       cp   $2A
1DC7: 28 01       jr   z,$1DCA
1DC9: 23          inc  hl
1DCA: 3E 11       ld   a,$11
1DCC: CD 75 0D    call $0D75
1DCF: 35          dec  (hl)
1DD0: 20 08       jr   nz,$1DDA
1DD2: 23          inc  hl
1DD3: 23          inc  hl
1DD4: 23          inc  hl
1DD5: 7E          ld   a,(hl)
1DD6: FE 03       cp   $03
1DD8: 30 11       jr   nc,$1DEB
1DDA: DD 36 00 20 ld   (ix+$00),$20
1DDE: DD 36 0A 06 ld   (ix+$0a),$06
1DE2: DD 36 0D 37 ld   (ix+$0d),$37
1DE6: 78          ld   a,b
1DE7: CD C2 02    call $02C2
1DEA: C9          ret
1DEB: 21 00 FC    ld   hl,$FC00
1DEE: D6 02       sub  $02
1DF0: C3 9D 17    jp   $179D
1DF3: DD 36 0D 3E ld   (ix+$0d),$3E
1DF7: CD 23 16    call $1623
1DFA: D6 03       sub  $03
1DFC: E6 F8       and  $F8
1DFE: C6 06       add  a,$06
1E00: DD 77 0F    ld   (ix+$0f),a
1E03: 21 D1 E1    ld   hl,$E1D1
1E06: 7E          ld   a,(hl)
1E07: A7          and  a
1E08: 28 13       jr   z,$1E1D
1E0A: 23          inc  hl
1E0B: 36 01       ld   (hl),$01
1E0D: 23          inc  hl
1E0E: 7E          ld   a,(hl)
1E0F: A7          and  a
1E10: C8          ret  z
1E11: C3 52 08    jp   $0852
1E14: DD 36 0D 43 ld   (ix+$0d),$43
1E18: CD 23 16    call $1623
1E1B: 18 E6       jr   $1E03
1E1D: 34          inc  (hl)
1E1E: DD 34 00    inc  (ix+$00)
1E21: DD 36 0A 04 ld   (ix+$0a),$04
1E25: CD 31 08    call $0831
1E28: C9          ret
1E29: 21 D2 E1    ld   hl,$E1D2
1E2C: 7E          ld   a,(hl)
1E2D: 23          inc  hl
1E2E: B6          or   (hl)
1E2F: A7          and  a
1E30: C2 52 08    jp   nz,$0852
1E33: DD 7E 03    ld   a,(ix+$03)
1E36: FE F8       cp   $F8
1E38: D2 52 08    jp   nc,$0852
1E3B: DD 35 0A    dec  (ix+$0a)
1E3E: 20 E5       jr   nz,$1E25
1E40: DD 7E 0D    ld   a,(ix+$0d)
1E43: FE 49       cp   $49
1E45: CA 52 08    jp   z,$0852
1E48: DD 34 0D    inc  (ix+$0d)
1E4B: DD 36 0A 05 ld   (ix+$0a),$05
1E4F: 18 D4       jr   $1E25
1E51: 3A D3 E1    ld   a,($E1D3)
1E54: A7          and  a
1E55: C2 52 08    jp   nz,$0852
1E58: DD 35 0A    dec  (ix+$0a)
1E5B: 20 C8       jr   nz,$1E25
1E5D: DD 7E 0D    ld   a,(ix+$0d)
1E60: FE 42       cp   $42
1E62: 30 1F       jr   nc,$1E83
1E64: DD 34 0D    inc  (ix+$0d)
1E67: FE 3F       cp   $3F
1E69: 20 12       jr   nz,$1E7D
1E6B: DD 7E 0F    ld   a,(ix+$0f)
1E6E: 1F          rra
1E6F: 1F          rra
1E70: 1F          rra
1E71: E6 1F       and  $1F
1E73: 5F          ld   e,a
1E74: 16 83       ld   d,$83
1E76: 0E 09       ld   c,$09
1E78: 3E 01       ld   a,$01
1E7A: CD C2 02    call $02C2
1E7D: DD 36 0A 02 ld   (ix+$0a),$02
1E81: 18 A2       jr   $1E25
1E83: DD 7E 07    ld   a,(ix+$07)
1E86: C6 08       add  a,$08
1E88: DD 77 07    ld   (ix+$07),a
1E8B: CD 56 08    call $0856
1E8E: DD 36 0C 00 ld   (ix+$0c),$00
1E92: DD 36 0D 81 ld   (ix+$0d),$81
1E96: DD 36 00 13 ld   (ix+$00),$13
1E9A: C9          ret
1E9B: DD 35 0A    dec  (ix+$0a)
1E9E: CA 52 08    jp   z,$0852
1EA1: C3 B8 08    jp   $08B8
1EA4: DD 35 0F    dec  (ix+$0f)
1EA7: CA 4D 20    jp   z,$204D
1EAA: DD 34 00    inc  (ix+$00)
1EAD: DD 7E 0C    ld   a,(ix+$0c)
1EB0: CB 27       sla  a
1EB2: 28 3D       jr   z,$1EF1
1EB4: 3F          ccf
1EB5: 1F          rra
1EB6: E6 80       and  $80
1EB8: DD 77 0C    ld   (ix+$0c),a
1EBB: 4F          ld   c,a
1EBC: ED 5F       ld   a,r
1EBE: E6 3F       and  $3F
1EC0: 5F          ld   e,a
1EC1: 16 00       ld   d,$00
1EC3: 21 26 01    ld   hl,$0126
1EC6: 19          add  hl,de
1EC7: 0C          inc  c
1EC8: F2 D2 1E    jp   p,$1ED2
1ECB: EB          ex   de,hl
1ECC: A7          and  a
1ECD: 21 00 00    ld   hl,$0000
1ED0: ED 52       sbc  hl,de
1ED2: DD 74 05    ld   (ix+$05),h
1ED5: DD 75 04    ld   (ix+$04),l
1ED8: EE 3F       xor  $3F
1EDA: D6 20       sub  $20
1EDC: 87          add  a,a
1EDD: DD 77 08    ld   (ix+$08),a
1EE0: 3E 00       ld   a,$00
1EE2: DE 00       sbc  a,$00
1EE4: DD 77 09    ld   (ix+$09),a
1EE7: ED 5F       ld   a,r
1EE9: E6 7F       and  $7F
1EEB: C6 20       add  a,$20
1EED: DD 77 0A    ld   (ix+$0a),a
1EF0: C9          ret
1EF1: 06 01       ld   b,$01
1EF3: DD 7E 07    ld   a,(ix+$07)
1EF6: FE 44       cp   $44
1EF8: 38 0C       jr   c,$1F06
1EFA: 06 03       ld   b,$03
1EFC: FE 58       cp   $58
1EFE: 30 06       jr   nc,$1F06
1F00: ED 5F       ld   a,r
1F02: E6 02       and  $02
1F04: 3C          inc  a
1F05: 47          ld   b,a
1F06: 78          ld   a,b
1F07: DD 86 0C    add  a,(ix+$0c)
1F0A: DD 77 0C    ld   (ix+$0c),a
1F0D: ED 5F       ld   a,r
1F0F: E6 0F       and  $0F
1F11: C6 24       add  a,$24
1F13: DD 77 0B    ld   (ix+$0b),a
1F16: 21 66 01    ld   hl,$0166
1F19: DD 75 04    ld   (ix+$04),l
1F1C: DD 74 05    ld   (ix+$05),h
1F1F: DD 36 08 00 ld   (ix+$08),$00
1F23: DD 36 09 00 ld   (ix+$09),$00
1F27: C9          ret
1F28: CD 63 1C    call $1C63
1F2B: CD DB 20    call $20DB
1F2E: DD 7E 0C    ld   a,(ix+$0c)
1F31: CB 27       sla  a
1F33: 20 52       jr   nz,$1F87
1F35: DD 35 0A    dec  (ix+$0a)
1F38: 28 49       jr   z,$1F83
1F3A: 2A D6 E0    ld   hl,($E0D6)
1F3D: ED 5B D8 E0 ld   de,($E0D8)
1F41: 19          add  hl,de
1F42: 7A          ld   a,d
1F43: ED 5B 04 E3 ld   de,($E304)
1F47: ED 52       sbc  hl,de
1F49: 22 D6 E0    ld   ($E0D6),hl
1F4C: 17          rla
1F4D: 38 2F       jr   c,$1F7E
1F4F: DD 7E 0D    ld   a,(ix+$0d)
1F52: 06 A0       ld   b,$A0
1F54: D6 2A       sub  $2A
1F56: 28 08       jr   z,$1F60
1F58: 06 80       ld   b,$80
1F5A: D6 07       sub  $07
1F5C: 38 02       jr   c,$1F60
1F5E: 06 D0       ld   b,$D0
1F60: 7C          ld   a,h
1F61: B8          cp   b
1F62: 30 1F       jr   nc,$1F83
1F64: 2A DA E0    ld   hl,($E0DA)
1F67: ED 5B DC E0 ld   de,($E0DC)
1F6B: 19          add  hl,de
1F6C: 22 DA E0    ld   ($E0DA),hl
1F6F: 7C          ld   a,h
1F70: FE 38       cp   $38
1F72: 38 0F       jr   c,$1F83
1F74: FE 70       cp   $70
1F76: 30 0B       jr   nc,$1F83
1F78: CD EF 20    call $20EF
1F7B: C3 4C 1D    jp   $1D4C
1F7E: 7C          ld   a,h
1F7F: FE 16       cp   $16
1F81: 30 E1       jr   nc,$1F64
1F83: DD 35 00    dec  (ix+$00)
1F86: C9          ret
1F87: 2A D8 E0    ld   hl,($E0D8)
1F8A: DD 5E 0B    ld   e,(ix+$0b)
1F8D: 16 00       ld   d,$00
1F8F: A7          and  a
1F90: ED 52       sbc  hl,de
1F92: 22 D8 E0    ld   ($E0D8),hl
1F95: 30 16       jr   nc,$1FAD
1F97: DD 7E 03    ld   a,(ix+$03)
1F9A: D6 30       sub  $30
1F9C: FE 40       cp   $40
1F9E: 3E 00       ld   a,$00
1FA0: 30 04       jr   nc,$1FA6
1FA2: ED 5F       ld   a,r
1FA4: E6 80       and  $80
1FA6: DD 86 0C    add  a,(ix+$0c)
1FA9: 3C          inc  a
1FAA: DD 77 0C    ld   (ix+$0c),a
1FAD: EB          ex   de,hl
1FAE: 2A D6 E0    ld   hl,($E0D6)
1FB1: ED 52       sbc  hl,de
1FB3: DD 7E 0C    ld   a,(ix+$0c)
1FB6: 07          rlca
1FB7: 38 02       jr   c,$1FBB
1FB9: 19          add  hl,de
1FBA: 19          add  hl,de
1FBB: ED 5B 04 E3 ld   de,($E304)
1FBF: ED 52       sbc  hl,de
1FC1: 22 D6 E0    ld   ($E0D6),hl
1FC4: 2A DC E0    ld   hl,($E0DC)
1FC7: DD 5E 0B    ld   e,(ix+$0b)
1FCA: 16 00       ld   d,$00
1FCC: 0F          rrca
1FCD: 3D          dec  a
1FCE: 0F          rrca
1FCF: 30 1A       jr   nc,$1FEB
1FD1: A7          and  a
1FD2: ED 52       sbc  hl,de
1FD4: 38 AD       jr   c,$1F83
1FD6: 22 DC E0    ld   ($E0DC),hl
1FD9: EB          ex   de,hl
1FDA: 2A DA E0    ld   hl,($E0DA)
1FDD: A7          and  a
1FDE: ED 52       sbc  hl,de
1FE0: 0F          rrca
1FE1: 38 02       jr   c,$1FE5
1FE3: 19          add  hl,de
1FE4: 19          add  hl,de
1FE5: 22 DA E0    ld   ($E0DA),hl
1FE8: C3 78 1F    jp   $1F78
1FEB: 19          add  hl,de
1FEC: 18 E8       jr   $1FD6

2000: DD 34 00    inc  (ix+$00)
2003: DD 7E 0C    ld   a,(ix+$0c)
2006: E6 7F       and  $7F
2008: C8          ret  z
2009: CD 28 1F    call $1F28
200C: DD 7E 00    ld   a,(ix+$00)
200F: FE 25       cp   $25
2011: CA 83 1F    jp   z,$1F83
2014: FE 24       cp   $24
2016: CA AA 1E    jp   z,$1EAA
2019: C9          ret
201A: CD 63 1C    call $1C63
201D: CD DB 20    call $20DB
2020: 22 D6 E0    ld   ($E0D6),hl
2023: 7C          ld   a,h
2024: D6 08       sub  $08
2026: FE F0       cp   $F0
2028: D2 52 08    jp   nc,$0852
202B: ED 5B DC E0 ld   de,($E0DC)
202F: 2A DA E0    ld   hl,($E0DA)
2032: 19          add  hl,de
2033: 22 DA E0    ld   ($E0DA),hl
2036: 7C          ld   a,h
2037: FE 30       cp   $30
2039: DA 52 08    jp   c,$0852
203C: 7A          ld   a,d
203D: A7          and  a
203E: FA 78 1F    jp   m,$1F78
2041: 21 00 00    ld   hl,$0000
2044: A7          and  a
2045: ED 52       sbc  hl,de
2047: 22 DC E0    ld   ($E0DC),hl
204A: C3 78 1F    jp   $1F78
204D: 3A 03 E3    ld   a,($E303)
2050: 16 00       ld   d,$00
2052: C6 10       add  a,$10
2054: DD 96 03    sub  (ix+$03)
2057: 30 03       jr   nc,$205C
2059: ED 44       neg
205B: 15          dec  d
205C: 1F          rra
205D: 1F          rra
205E: 1F          rra
205F: E6 1E       and  $1E
2061: 4F          ld   c,a
2062: 06 00       ld   b,$00
2064: 21 24 2D    ld   hl,$2D24
2067: 09          add  hl,bc
2068: FE 12       cp   $12
206A: 38 01       jr   c,$206D
206C: 04          inc  b
206D: 7E          ld   a,(hl)
206E: CB 7A       bit  7,d
2070: 28 06       jr   z,$2078
2072: 2F          cpl
2073: 5F          ld   e,a
2074: 78          ld   a,b
2075: 2F          cpl
2076: 47          ld   b,a
2077: 7B          ld   a,e
2078: DD 77 04    ld   (ix+$04),a
207B: DD 70 05    ld   (ix+$05),b
207E: 23          inc  hl
207F: 5E          ld   e,(hl)
2080: 16 00       ld   d,$00
2082: 79          ld   a,c
2083: FE 0A       cp   $0A
2085: 30 01       jr   nc,$2088
2087: 14          inc  d
2088: DD 72 09    ld   (ix+$09),d
208B: DD 73 08    ld   (ix+$08),e
208E: DD 36 00 29 ld   (ix+$00),$29
2092: 2A 1A E3    ld   hl,($E31A)
2095: DD 75 0B    ld   (ix+$0b),l
2098: DD 74 0F    ld   (ix+$0f),h
209B: C9          ret
209C: CD 63 1C    call $1C63
209F: CD FB 20    call $20FB
20A2: 22 D6 E0    ld   ($E0D6),hl
20A5: 7C          ld   a,h
20A6: 2A DC E0    ld   hl,($E0DC)
20A9: C3 F1 1C    jp   $1CF1
20AC: DD 35 0A    dec  (ix+$0a)
20AF: C2 B8 08    jp   nz,$08B8
20B2: DD 36 0A 06 ld   (ix+$0a),$06
20B6: DD 7E 0D    ld   a,(ix+$0d)
20B9: FE 39       cp   $39
20BB: D2 52 08    jp   nc,$0852
20BE: DD 34 0D    inc  (ix+$0d)
20C1: C3 B8 08    jp   $08B8
20C4: DD 35 0A    dec  (ix+$0a)
20C7: C2 B8 08    jp   nz,$08B8
20CA: DD 7E 07    ld   a,(ix+$07)
20CD: FE 80       cp   $80
20CF: D2 52 08    jp   nc,$0852
20D2: 06 80       ld   b,$80
20D4: DD 36 00 00 ld   (ix+$00),$00
20D8: C3 69 08    jp   $0869
20DB: DD E5       push ix
20DD: E1          pop  hl
20DE: 11 D4 E0    ld   de,$E0D4
20E1: 01 0A 00    ld   bc,$000A
20E4: ED B0       ldir
20E6: ED 5B D6 E0 ld   de,($E0D6)
20EA: 2A D8 E0    ld   hl,($E0D8)
20ED: 19          add  hl,de
20EE: C9          ret
20EF: DD E5       push ix
20F1: D1          pop  de
20F2: 21 D4 E0    ld   hl,$E0D4
20F5: 01 0A 00    ld   bc,$000A
20F8: ED B0       ldir
20FA: C9          ret
20FB: CD DB 20    call $20DB
20FE: EB          ex   de,hl
20FF: DD 6E 0B    ld   l,(ix+$0b)
2102: DD 66 0F    ld   h,(ix+$0f)
2105: ED 4B 1A E3 ld   bc,($E31A)
2109: ED 42       sbc  hl,bc
210B: 19          add  hl,de
210C: C9          ret
210D: 21 51 E0    ld   hl,$E051
2110: 3A 00 E3    ld   a,($E300)
2113: 3D          dec  a
2114: 28 11       jr   z,$2127
2116: 7E          ld   a,(hl)
2117: A7          and  a
2118: F0          ret  p
2119: 21 11 E5    ld   hl,time_bcd_e511
211C: 3E 01       ld   a,$01
211E: 86          add  a,(hl)
211F: 27          daa
2120: 77          ld   (hl),a
2121: 23          inc  hl
2122: 7E          ld   a,(hl)
2123: CE 00       adc  a,$00
2125: 27          daa
2126: 77          ld   (hl),a
2127: 3E 37       ld   a,$37
2129: 32 51 E0    ld   ($E051),a
212C: 11 90 80    ld   de,$8090
212F: FD 21 90 84 ld   iy,$8490
2133: 0E 02       ld   c,$02
2135: CD E7 03    call $03E7
2138: 3A 12 E5    ld   a,($E512)
213B: CD BD 03    call $03BD
213E: 3A 11 E5    ld   a,(time_bcd_e511)
2141: C3 AE 03    jp   $03AE

27C0: 21 46 E0    ld   hl,$E046
27C3: 35          dec  (hl)
27C4: FB          ei
27C5: 78          ld   a,b
27C6: 32 13 E5    ld   ($E513),a
27C9: FE 05       cp   $05
27CB: CA D2 27    jp   z,$27D2
27CE: A7          and  a
27CF: C2 5E 28    jp   nz,$285E
27D2: CD FA 29    call $29FA
27D5: 3E 1E       ld   a,$1E
27D7: CD 75 0D    call $0D75
27DA: 21 0F E5    ld   hl,$E50F
27DD: 36 00       ld   (hl),$00
27DF: 23          inc  hl
27E0: 34          inc  (hl)
27E1: CD 48 29    call $2948
27E4: CD E8 05    call $05E8
27E7: 21 24 2C    ld   hl,$2C24
27EA: CD 00 03    call $0300
27ED: CD BA 28    call $28BA
27F0: 21 0C 2C    ld   hl,$2C0C
27F3: CD 00 03    call $0300
27F6: 3A 13 E5    ld   a,($E513)
27F9: 17          rla
27FA: 17          rla
27FB: 17          rla
27FC: 17          rla
27FD: 26 00       ld   h,$00
27FF: E6 F0       and  $F0
2801: 6F          ld   l,a
2802: 20 01       jr   nz,$2805
2804: 24          inc  h
2805: 22 98 E0    ld   ($E098),hl
2808: CD 71 29    call $2971
280B: 2A 96 E0    ld   hl,($E096)
280E: 56          ld   d,(hl)
280F: 2B          dec  hl
2810: 5E          ld   e,(hl)
2811: 2A 11 E5    ld   hl,(time_bcd_e511)
2814: A7          and  a
2815: ED 52       sbc  hl,de
2817: 30 0E       jr   nc,$2827
2819: 19          add  hl,de
281A: EB          ex   de,hl
281B: 2A 96 E0    ld   hl,($E096)
281E: 72          ld   (hl),d
281F: 2B          dec  hl
2820: 73          ld   (hl),e
2821: 21 39 2C    ld   hl,$2C39
2824: CD 4E 03    call $034E
2827: 2A 94 E0    ld   hl,($E094)
282A: ED 5B 11 E5 ld   de,(time_bcd_e511)
282E: 7D          ld   a,l
282F: D6 01       sub  $01
2831: 27          daa
2832: 6F          ld   l,a
2833: 30 01       jr   nc,$2836
2835: 25          dec  h
2836: 22 94 E0    ld   ($E094),hl
2839: A7          and  a
283A: ED 52       sbc  hl,de
283C: 38 50       jr   c,$288E
283E: CD 68 29    call $2968
2841: 2A 98 E0    ld   hl,($E098)
2844: 7D          ld   a,l
2845: C6 01       add  a,$01
2847: 27          daa
2848: 6F          ld   l,a
2849: 30 01       jr   nc,$284C
284B: 24          inc  h
284C: 22 98 E0    ld   ($E098),hl
284F: CD 71 29    call $2971
2852: 3E 10       ld   a,$10
2854: CD 75 0D    call $0D75
2857: 3E 0C       ld   a,$0C
2859: CD EA 05    call $05EA
285C: 18 C9       jr   $2827
285E: 3E 1D       ld   a,$1D
2860: CD 75 0D    call $0D75
2863: CD D6 29    call $29D6
2866: CD 12 0D    call $0D12
2869: CD 48 29    call $2948
286C: 3E 30       ld   a,$30
286E: CD EA 05    call $05EA
2871: CD BA 28    call $28BA
2874: 38 0D       jr   c,$2883
2876: 21 E4 2B    ld   hl,$2BE4
2879: CD 4E 03    call $034E
287C: 3A F9 E0    ld   a,($E0F9)
287F: 3C          inc  a
2880: C3 F9 27    jp   $27F9
2883: 21 F9 2B    ld   hl,$2BF9
2886: CD 4E 03    call $034E
2889: CD E8 05    call $05E8
288C: 18 0E       jr   $289C
288E: CD E8 05    call $05E8
2891: 11 01 E5    ld   de,$E501
2894: 21 98 E0    ld   hl,$E098
2897: 06 02       ld   b,$02
2899: CD 36 06    call $0636
289C: 21 00 00    ld   hl,$0000
289F: 22 11 E5    ld   (time_bcd_e511),hl
28A2: 21 13 E5    ld   hl,$E513
28A5: 7E          ld   a,(hl)
28A6: A7          and  a
28A7: C2 B7 0B    jp   nz,$0BB7
28AA: 36 05       ld   (hl),$05
28AC: 21 A2 23    ld   hl,$23A2
28AF: 22 16 E5    ld   ($E516),hl
28B2: 3E 1A       ld   a,$1A
28B4: 32 0E E5    ld   ($E50E),a
28B7: C3 B7 0B    jp   $0BB7
28BA: CD E8 05    call $05E8
28BD: CD 5A 29    call $295A
28C0: 3A 10 E5    ld   a,(time_bcd_e510)
28C3: D6 02       sub  $02
28C5: 28 07       jr   z,$28CE
28C7: 3E 0A       ld   a,$0A
28C9: FA CE 28    jp   m,$28CE
28CC: 3E 05       ld   a,$05
28CE: 5F          ld   e,a
28CF: 3A 13 E5    ld   a,($E513)
28D2: 01 80 00    ld   bc,$0080
28D5: FE 08       cp   $08
28D7: 30 09       jr   nc,$28E2
28D9: 01 00 01    ld   bc,$0100
28DC: FE 03       cp   $03
28DE: 30 02       jr   nc,$28E2
28E0: 0E 20       ld   c,$20
28E2: ED 43 94 E0 ld   ($E094),bc
28E6: 83          add  a,e
28E7: 87          add  a,a
28E8: 5F          ld   e,a
28E9: FE 0A       cp   $0A
28EB: 20 09       jr   nz,$28F6
28ED: 3A 10 E5    ld   a,(time_bcd_e510)
28F0: FE 03       cp   $03
28F2: 28 02       jr   z,$28F6
28F4: 1E 14       ld   e,$14
28F6: 16 00       ld   d,$00
28F8: 21 0C E0    ld   hl,$E00C
28FB: 19          add  hl,de
28FC: 7E          ld   a,(hl)
28FD: 23          inc  hl
28FE: 22 96 E0    ld   ($E096),hl
2901: B6          or   (hl)
2902: 20 03       jr   nz,$2907
2904: 70          ld   (hl),b
2905: 2B          dec  hl
2906: 71          ld   (hl),c
2907: 21 79 2B    ld   hl,$2B79
290A: CD 4E 03    call $034E
290D: CD 81 29    call $2981
2910: A7          and  a
2911: 20 02       jr   nz,$2915
2913: 3E 1A       ld   a,$1A
2915: C6 40       add  a,$40
2917: 1B          dec  de
2918: 1B          dec  de
2919: 12          ld   (de),a
291A: 21 94 2B    ld   hl,$2B94
291D: CD 4E 03    call $034E
2920: 21 12 E5    ld   hl,$E512
2923: 13          inc  de
2924: CD 9A 03    call $039A
2927: 21 B0 2B    ld   hl,$2BB0
292A: CD 4E 03    call $034E
292D: CD 68 29    call $2968
2930: 21 CC 2B    ld   hl,$2BCC
2933: CD 4E 03    call $034E
2936: 2A 96 E0    ld   hl,($E096)
2939: 13          inc  de
293A: CD 9A 03    call $039A
293D: 2A 94 E0    ld   hl,($E094)
2940: ED 5B 11 E5 ld   de,(time_bcd_e511)
2944: A7          and  a
2945: ED 52       sbc  hl,de
2947: C9          ret
2948: 21 00 E1    ld   hl,$E100
294B: 01 A4 00    ld   bc,$00A4
294E: CD FA 05    call clear_area_05fa
2951: 01 20 02    ld   bc,$0220
2954: 21 E0 80    ld   hl,$80E0
2957: C3 FA 05    jp   clear_area_05fa
295A: 21 00 E1    ld   hl,$E100
295D: 01 C6 00    ld   bc,$00C6
2960: CD FA 05    call clear_area_05fa
2963: 01 20 03    ld   bc,$0320
2966: 18 EC       jr   $2954
2968: 11 D9 81    ld   de,$81D9
296B: 21 95 E0    ld   hl,$E095
296E: C3 9A 03    jp   $039A
2971: 21 99 E0    ld   hl,$E099
2974: 11 97 82    ld   de,$8297
2977: CD 93 03    call $0393
297A: EB          ex   de,hl
297B: 36 30       ld   (hl),$30
297D: 23          inc  hl
297E: 36 30       ld   (hl),$30
2980: C9          ret
2981: 3A 0E E5    ld   a,($E50E)
2984: FE 1A       cp   $1A
2986: D8          ret  c
2987: D6 1A       sub  $1A
2989: C9          ret
298A: 21 CC 80    ld   hl,$80CC
298D: 11 CC 84    ld   de,$84CC
2990: 01 02 10    ld   bc,$1002
2993: CD E7 03    call $03E7
2996: 79          ld   a,c
2997: 36 21       ld   (hl),$21
2999: 12          ld   (de),a
299A: 23          inc  hl
299B: 13          inc  de
299C: 10 F9       djnz $2997
299E: 21 CC 80    ld   hl,$80CC
29A1: 06 05       ld   b,$05
29A3: 34          inc  (hl)
29A4: 23          inc  hl
29A5: 23          inc  hl
29A6: 23          inc  hl
29A7: 10 FA       djnz $29A3
29A9: 36 1B       ld   (hl),$1B
29AB: CD 81 29    call $2981
29AE: 21 CC 80    ld   hl,$80CC
29B1: 06 05       ld   b,$05
29B3: FE 05       cp   $05
29B5: 38 0C       jr   c,$29C3
29B7: 16 03       ld   d,$03
29B9: 36 29       ld   (hl),$29
29BB: 23          inc  hl
29BC: 15          dec  d
29BD: 20 FA       jr   nz,$29B9
29BF: D6 05       sub  $05
29C1: 10 F0       djnz $29B3
29C3: 57          ld   d,a
29C4: 87          add  a,a
29C5: 87          add  a,a
29C6: 82          add  a,d
29C7: 5F          ld   e,a
29C8: FE 08       cp   $08
29CA: 38 10       jr   c,$29DC
29CC: 28 01       jr   z,$29CF
29CE: 3D          dec  a
29CF: 36 29       ld   (hl),$29
29D1: 23          inc  hl
29D2: D6 08       sub  $08
29D4: 18 F2       jr   $29C8
29D6: 2A F4 E0    ld   hl,($E0F4)
29D9: 3A F6 E0    ld   a,($E0F6)
29DC: 3C          inc  a
29DD: 57          ld   d,a
29DE: C6 21       add  a,$21
29E0: CB 66       bit  4,(hl)
29E2: 28 07       jr   z,$29EB
29E4: D6 06       sub  $06
29E6: FE 20       cp   $20
29E8: 20 01       jr   nz,$29EB
29EA: 3D          dec  a
29EB: 77          ld   (hl),a
29EC: 7A          ld   a,d
29ED: FE 08       cp   $08
29EF: 38 02       jr   c,$29F3
29F1: AF          xor  a
29F2: 2C          inc  l
29F3: 32 F6 E0    ld   ($E0F6),a
29F6: 22 F4 E0    ld   ($E0F4),hl
29F9: C9          ret
29FA: 21 CC 80    ld   hl,$80CC
29FD: 06 0F       ld   b,$0F
29FF: 36 29       ld   (hl),$29
2A01: 23          inc  hl
2A02: 10 FB       djnz $29FF
2A04: 36 1F       ld   (hl),$1F
2A06: 3E 5A       ld   a,$5A
2A08: 32 52 80    ld   ($8052),a
2A0B: C9          ret


service_mode_3300:
3300: 3E FF       ld   a,$FF
3302: D3 C0       out  ($C0),a
3304: 32 C5 E1    ld   ($E1C5),a
3307: 21 00 E1    ld   hl,$E100
330A: 36 00       ld   (hl),$00
330C: 54          ld   d,h
330D: 5D          ld   e,l
330E: 13          inc  de
330F: 01 CF 00    ld   bc,$00CF
3312: ED B0       ldir
3314: 3E 01       ld   a,$01
3316: 57          ld   d,a
3317: 01 00 08    ld   bc,$0800
331A: 21 00 E0    ld   hl,$E000
331D: 7A          ld   a,d
331E: 77          ld   (hl),a
331F: 5E          ld   e,(hl)
3320: BB          cp   e
3321: C2 BB 34    jp   nz,$34BB
3324: 23          inc  hl
3325: 0B          dec  bc
3326: 79          ld   a,c
3327: B0          or   b
3328: 20 F3       jr   nz,$331D
332A: 7A          ld   a,d
332B: 07          rlca
332C: 30 E8       jr   nc,$3316
332E: 16 55       ld   d,$55
3330: 7A          ld   a,d
3331: 01 00 08    ld   bc,$0800
3334: 21 00 E0    ld   hl,$E000
3337: 77          ld   (hl),a
3338: 23          inc  hl
3339: 3C          inc  a
333A: 5F          ld   e,a
333B: 0B          dec  bc
333C: 79          ld   a,c
333D: B0          or   b
333E: 28 09       jr   z,$3349
3340: 7B          ld   a,e
3341: FE AB       cp   $AB
3343: 20 F2       jr   nz,$3337
3345: 3E 55       ld   a,$55
3347: 18 EE       jr   $3337
3349: 7A          ld   a,d
334A: 01 00 08    ld   bc,$0800
334D: 21 00 E0    ld   hl,$E000
3350: BE          cp   (hl)
3351: 20 19       jr   nz,$336C
3353: 23          inc  hl
3354: 3C          inc  a
3355: 5F          ld   e,a
3356: 0B          dec  bc
3357: 79          ld   a,c
3358: B0          or   b
3359: 28 09       jr   z,$3364
335B: 7B          ld   a,e
335C: FE AB       cp   $AB
335E: 20 F0       jr   nz,$3350
3360: 3E 55       ld   a,$55
3362: 18 EC       jr   $3350
3364: 14          inc  d
3365: 7A          ld   a,d
3366: FE AB       cp   $AB
3368: 20 C6       jr   nz,$3330
336A: 18 09       jr   $3375
336C: 5E          ld   e,(hl)
336D: 57          ld   d,a
336E: AF          xor  a
336F: C3 BB 34    jp   $34BB
3372: 7A          ld   a,d
3373: 18 DE       jr   $3353
3375: 31 00 E8    ld   sp,$E800
3378: 3E 01       ld   a,$01
337A: 57          ld   d,a
337B: 01 00 08    ld   bc,$0800
337E: 21 00 80    ld   hl,$8000
3381: 7A          ld   a,d
3382: 77          ld   (hl),a
3383: 5E          ld   e,(hl)
3384: BB          cp   e
3385: 28 08       jr   z,$338F
3387: CD 3B 35    call $353B
338A: CB 4F       bit  1,a
338C: CA F5 33    jp   z,$33F5
338F: 23          inc  hl
3390: 0B          dec  bc
3391: 79          ld   a,c
3392: B0          or   b
3393: 20 EC       jr   nz,$3381
3395: 7A          ld   a,d
3396: 07          rlca
3397: 30 E1       jr   nc,$337A
3399: 16 55       ld   d,$55
339B: 7A          ld   a,d
339C: 01 00 08    ld   bc,$0800
339F: 21 00 80    ld   hl,$8000
33A2: 77          ld   (hl),a
33A3: 23          inc  hl
33A4: 3C          inc  a
33A5: 5F          ld   e,a
33A6: 0B          dec  bc
33A7: 79          ld   a,c
33A8: B0          or   b
33A9: 28 09       jr   z,$33B4
33AB: 7B          ld   a,e
33AC: FE AB       cp   $AB
33AE: 20 F2       jr   nz,$33A2
33B0: 3E 55       ld   a,$55
33B2: 18 EE       jr   $33A2
33B4: 7A          ld   a,d
33B5: 01 00 08    ld   bc,$0800
33B8: 21 00 80    ld   hl,$8000
33BB: BE          cp   (hl)
33BC: 20 19       jr   nz,$33D7
33BE: 23          inc  hl
33BF: 3C          inc  a
33C0: 5F          ld   e,a
33C1: 0B          dec  bc
33C2: 79          ld   a,c
33C3: B0          or   b
33C4: 28 09       jr   z,$33CF
33C6: 7B          ld   a,e
33C7: FE AB       cp   $AB
33C9: 20 F0       jr   nz,$33BB
33CB: 3E 55       ld   a,$55
33CD: 18 EC       jr   $33BB
33CF: 14          inc  d
33D0: 7A          ld   a,d
33D1: FE AB       cp   $AB
33D3: 20 C6       jr   nz,$339B
33D5: 18 0D       jr   $33E4
33D7: 5E          ld   e,(hl)
33D8: 57          ld   d,a
33D9: CD 37 35    call $3537
33DC: CB 4F       bit  1,a
33DE: CA F5 33    jp   z,$33F5
33E1: 7A          ld   a,d
33E2: 18 DA       jr   $33BE
33E4: DD 21 EB 33 ld   ix,$33EB
33E8: C3 B1 35    jp   $35B1
33EB: 21 66 3A    ld   hl,$3A66
33EE: DD 21 F5 33 ld   ix,$33F5
33F2: C3 65 34    jp   $3465
33F5: 21 00 E1    ld   hl,$E100
33F8: 36 00       ld   (hl),$00
33FA: 54          ld   d,h
33FB: 5D          ld   e,l
33FC: 13          inc  de
33FD: 01 CF 00    ld   bc,$00CF
3400: ED B0       ldir
3402: 21 00 00    ld   hl,$0000
3405: AF          xor  a
3406: 32 00 E7    ld   ($E700),a
3409: 06 00       ld   b,$00
340B: 0E 10       ld   c,$10
340D: AF          xor  a
340E: AE          xor  (hl)
340F: 23          inc  hl
3410: 10 FC       djnz $340E
3412: 0D          dec  c
3413: 20 F9       jr   nz,$340E
3415: E5          push hl
3416: CD 35 34    call $3435
3419: E1          pop  hl
341A: 3A 00 E7    ld   a,($E700)
341D: 3C          inc  a
341E: FE 04       cp   $04
3420: 20 E4       jr   nz,$3406
3422: AF          xor  a
3423: D3 1C       out  ($1C),a
3425: FB          ei
3426: 3A 00 D0    ld   a,($D000)
3429: CB 4F       bit  1,a
342B: 20 F9       jr   nz,$3426
342D: 3E 03       ld   a,$03
342F: 32 01 E7    ld   ($E701),a
3432: C3 CD 35    jp   $35CD
3435: F5          push af
3436: FE FF       cp   $FF
3438: 28 02       jr   z,$343C
343A: 0E 08       ld   c,$08
343C: 21 86 3A    ld   hl,$3A86
343F: 09          add  hl,bc
3440: EB          ex   de,hl
3441: 3A 00 E7    ld   a,($E700)
3444: 0F          rrca
3445: 0F          rrca
3446: 4F          ld   c,a
3447: 21 C4 80    ld   hl,$80C4
344A: 09          add  hl,bc
344B: E5          push hl
344C: EB          ex   de,hl
344D: 0E 08       ld   c,$08
344F: ED B0       ldir
3451: 13          inc  de
3452: 13          inc  de
3453: D5          push de
3454: FD E1       pop  iy
3456: DD E1       pop  ix
3458: F1          pop  af
3459: CD 9A 34    call $349A
345C: 3A 00 E7    ld   a,($E700)
345F: C6 30       add  a,$30
3461: DD 77 03    ld   (ix+$03),a
3464: C9          ret
3465: 7E          ld   a,(hl)
3466: 23          inc  hl
3467: FE 00       cp   $00
3469: 28 0B       jr   z,$3476
346B: 5E          ld   e,(hl)
346C: 23          inc  hl
346D: 56          ld   d,(hl)
346E: 23          inc  hl
346F: 4F          ld   c,a
3470: 06 00       ld   b,$00
3472: ED B0       ldir
3474: 18 EF       jr   $3465
3476: DD E9       jp   (ix)
3478: 0F          rrca
3479: 0F          rrca
347A: 0F          rrca
347B: 0F          rrca
347C: E6 0F       and  $0F
347E: C6 30       add  a,$30
3480: FE 3A       cp   $3A
3482: 38 02       jr   c,$3486
3484: C6 07       add  a,$07
3486: FD 77 00    ld   (iy+$00),a
3489: DD E9       jp   (ix)
348B: E6 0F       and  $0F
348D: C6 30       add  a,$30
348F: FE 3A       cp   $3A
3491: 38 02       jr   c,$3495
3493: C6 07       add  a,$07
3495: FD 77 01    ld   (iy+$01),a
3498: DD E9       jp   (ix)
349A: F5          push af
349B: 0F          rrca
349C: 0F          rrca
349D: 0F          rrca
349E: 0F          rrca
349F: E6 0F       and  $0F
34A1: C6 30       add  a,$30
34A3: FE 3A       cp   $3A
34A5: 38 02       jr   c,$34A9
34A7: C6 07       add  a,$07
34A9: FD 77 00    ld   (iy+$00),a
34AC: F1          pop  af
34AD: E6 0F       and  $0F
34AF: C6 30       add  a,$30
34B1: FE 3A       cp   $3A
34B3: 38 02       jr   c,$34B7
34B5: C6 07       add  a,$07
34B7: FD 77 01    ld   (iy+$01),a
34BA: C9          ret
34BB: 08          ex   af,af'
34BC: D9          exx
34BD: DD 21 C4 34 ld   ix,$34C4
34C1: C3 B1 35    jp   $35B1
34C4: 21 72 3A    ld   hl,$3A72
34C7: DD 21 CE 34 ld   ix,$34CE
34CB: C3 65 34    jp   $3465
34CE: D9          exx
34CF: FD 21 8F 80 ld   iy,$808F
34D3: DD 21 DB 34 ld   ix,$34DB
34D7: 7C          ld   a,h
34D8: C3 78 34    jp   $3478
34DB: DD 21 E3 34 ld   ix,$34E3
34DF: 7C          ld   a,h
34E0: C3 8B 34    jp   $348B
34E3: FD 23       inc  iy
34E5: FD 23       inc  iy
34E7: DD 21 EF 34 ld   ix,$34EF
34EB: 7D          ld   a,l
34EC: C3 78 34    jp   $3478
34EF: DD 21 F7 34 ld   ix,$34F7
34F3: 7D          ld   a,l
34F4: C3 8B 34    jp   $348B
34F7: FD 21 95 80 ld   iy,$8095
34FB: DD 21 03 35 ld   ix,$3503
34FF: 7A          ld   a,d
3500: C3 78 34    jp   $3478
3503: DD 21 0B 35 ld   ix,$350B
3507: 7A          ld   a,d
3508: C3 8B 34    jp   $348B
350B: FD 21 99 80 ld   iy,$8099
350F: DD 21 17 35 ld   ix,$3517
3513: 7B          ld   a,e
3514: C3 78 34    jp   $3478
3517: 7B          ld   a,e
3518: DD 21 1F 35 ld   ix,$351F
351C: C3 8B 34    jp   $348B
351F: 3A 00 D0    ld   a,($D000)
3522: CB 47       bit  0,a
3524: CA 2F 35    jp   z,$352F
3527: CB 4F       bit  1,a
3529: 20 F4       jr   nz,$351F
352B: 08          ex   af,af'
352C: C3 F5 33    jp   $33F5
352F: 08          ex   af,af'
3530: B7          or   a
3531: CA 72 33    jp   z,$3372
3534: C3 24 33    jp   $3324
3537: E5          push hl
3538: D9          exx
3539: 18 09       jr   $3544
353B: E5          push hl
353C: D9          exx
353D: DD 21 44 35 ld   ix,$3544
3541: C3 B1 35    jp   $35B1
3544: 21 00 80    ld   hl,$8000
3547: 11 00 E0    ld   de,$E000
354A: 01 A0 04    ld   bc,$04A0
354D: ED B0       ldir
354F: 21 00 80    ld   hl,$8000
3552: 36 00       ld   (hl),$00
3554: 54          ld   d,h
3555: 5D          ld   e,l
3556: 13          inc  de
3557: 01 9F 04    ld   bc,$049F
355A: ED B0       ldir
355C: 21 72 3A    ld   hl,$3A72
355F: DD 21 66 35 ld   ix,$3566
3563: C3 65 34    jp   $3465
3566: D9          exx
3567: FD 21 8F 80 ld   iy,$808F
356B: 7C          ld   a,h
356C: CD 9A 34    call $349A
356F: FD 23       inc  iy
3571: FD 23       inc  iy
3573: 7D          ld   a,l
3574: CD 9A 34    call $349A
3577: FD 21 95 80 ld   iy,$8095
357B: 7A          ld   a,d
357C: CD 9A 34    call $349A
357F: FD 21 99 80 ld   iy,$8099
3583: 7B          ld   a,e
3584: CD 9A 34    call $349A
3587: E1          pop  hl
3588: 3A 00 D0    ld   a,($D000)
358B: CB 47       bit  0,a
358D: 28 06       jr   z,$3595
358F: CB 4F       bit  1,a
3591: 28 10       jr   z,$35A3
3593: 18 F3       jr   $3588
3595: D9          exx
3596: 21 00 E0    ld   hl,$E000
3599: 11 00 80    ld   de,$8000
359C: 01 A0 04    ld   bc,$04A0
359F: ED B0       ldir
35A1: D9          exx
35A2: C9          ret
35A3: 21 A0 84    ld   hl,$84A0
35A6: 36 00       ld   (hl),$00
35A8: 54          ld   d,h
35A9: 5D          ld   e,l
35AA: 13          inc  de
35AB: 01 5F 03    ld   bc,$035F
35AE: ED B0       ldir
35B0: C9          ret
35B1: 21 00 84    ld   hl,$8400
35B4: 01 FF 03    ld   bc,$03FF
35B7: 36 00       ld   (hl),$00
35B9: 54          ld   d,h
35BA: 5D          ld   e,l
35BB: 13          inc  de
35BC: ED B0       ldir
35BE: 21 00 80    ld   hl,$8000
35C1: 01 FF 03    ld   bc,$03FF
35C4: 36 00       ld   (hl),$00
35C6: 54          ld   d,h
35C7: 5D          ld   e,l
35C8: 13          inc  de
35C9: ED B0       ldir
35CB: DD E9       jp   (ix)
35CD: CD AD 38    call $38AD
35D0: 21 BF 3E    ld   hl,$3EBF
35D3: CD 08 39    call $3908
35D6: 3A 01 E7    ld   a,($E701)
35D9: 06 02       ld   b,$02
35DB: CD 1C 39    call $391C
35DE: 3A 00 D0    ld   a,($D000)
35E1: CB 47       bit  0,a
35E3: 20 14       jr   nz,$35F9
35E5: 3A 01 E7    ld   a,($E701)
35E8: 07          rlca
35E9: 4F          ld   c,a
35EA: 06 00       ld   b,$00
35EC: DD 21 96 3A ld   ix,jump_table_3A96
35F0: DD 09       add  ix,bc
35F2: DD 6E 00    ld   l,(ix+$00)
35F5: DD 66 01    ld   h,(ix+$01)
35F8: E9          jp   (hl)

35F9: DD 21 02 E7 ld   ix,$E702
35FD: CD DD 38    call $38DD
3600: 47          ld   b,a
3601: E6 55       and  $55
3603: FE 55       cp   $55
3605: 28 09       jr   z,$3610
3607: 78          ld   a,b
3608: E6 AA       and  $AA
360A: FE AA       cp   $AA
360C: 28 13       jr   z,$3621
360E: 18 CE       jr   $35DE
3610: DD 36 00 55 ld   (ix+$00),$55
3614: DD 36 01 08 ld   (ix+$01),$08
3618: DD 36 02 01 ld   (ix+$02),$01
361C: CD 32 36    call $3632
361F: 18 BD       jr   $35DE
3621: DD 36 00 AA ld   (ix+$00),$AA
3625: DD 36 01 03 ld   (ix+$01),$03
3629: DD 36 02 FF ld   (ix+$02),$FF
362D: CD 32 36    call $3632
3630: 18 AC       jr   $35DE
3632: DD 56 00    ld   d,(ix+$00)
3635: 1E 02       ld   e,$02
3637: CD C8 38    call $38C8
363A: 28 0E       jr   z,$364A
363C: CD 4E 36    call $364E
363F: DD 56 00    ld   d,(ix+$00)
3642: 1E 01       ld   e,$01
3644: CD C8 38    call $38C8
3647: 20 F3       jr   nz,$363C
3649: C9          ret
364A: CD 4E 36    call $364E
364D: C9          ret
364E: 3A 01 E7    ld   a,($E701)
3651: DD BE 01    cp   (ix+$01)
3654: C8          ret  z
3655: 06 00       ld   b,$00
3657: CD 1C 39    call $391C
365A: DD 86 02    add  a,(ix+$02)
365D: 32 01 E7    ld   ($E701),a
3660: 06 02       ld   b,$02
3662: CD 1C 39    call $391C
3665: C9          ret

3666: CD AD 38    call $38AD
3669: 21 10 3B    ld   hl,$3B10
366C: CD 08 39    call $3908
366F: 3A 03 D0    ld   a,($D003)
3672: 21 CB 80    ld   hl,$80CB
3675: CD B2 36    call $36B2
3678: 3A 04 D0    ld   a,($D004)
367B: 21 0B 81    ld   hl,$810B
367E: CD B2 36    call $36B2
3681: DD 21 AC 3A ld   ix,$3AAC
3685: FD 21 A8 3A ld   iy,$3AA8
3689: 3A 03 D0    ld   a,($D003)
368C: EE FF       xor  $FF
368E: 06 02       ld   b,$02
3690: CD C6 36    call $36C6
3693: DD 21 F8 3A ld   ix,$3AF8
3697: FD 21 F4 3A ld   iy,$3AF4
369B: 3A 04 D0    ld   a,($D004)
369E: EE FF       xor  $FF
36A0: 06 01       ld   b,$01
36A2: CD C5 36    call $36C5
36A5: CD EC 36    call $36EC
36A8: 3A 00 D0    ld   a,($D000)
36AB: CB 4F       bit  1,a
36AD: 20 C0       jr   nz,$366F
36AF: C3 CD 35    jp   $35CD
36B2: EE FF       xor  $FF
36B4: 06 08       ld   b,$08
36B6: 0F          rrca
36B7: 38 04       jr   c,$36BD
36B9: 36 30       ld   (hl),$30
36BB: 18 02       jr   $36BF
36BD: 36 31       ld   (hl),$31
36BF: 23          inc  hl
36C0: 23          inc  hl
36C1: 10 F3       djnz $36B6
36C3: C9          ret
36C4: 0F          rrca
36C5: 0F          rrca
36C6: 4F          ld   c,a
36C7: C5          push bc
36C8: DD A6 00    and  (ix+$00)
36CB: DD 86 01    add  a,(ix+$01)
36CE: DD 23       inc  ix
36D0: DD 23       inc  ix
36D2: 4F          ld   c,a
36D3: 06 00       ld   b,$00
36D5: FD 6E 00    ld   l,(iy+$00)
36D8: FD 66 01    ld   h,(iy+$01)
36DB: 09          add  hl,bc
36DC: 4E          ld   c,(hl)
36DD: FD 6E 02    ld   l,(iy+$02)
36E0: FD 66 03    ld   h,(iy+$03)
36E3: 09          add  hl,bc
36E4: CD 11 39    call $3911
36E7: C1          pop  bc
36E8: 79          ld   a,c
36E9: 10 D9       djnz $36C4
36EB: C9          ret
36EC: 3A 04 D0    ld   a,($D004)
36EF: CB 57       bit  2,a
36F1: CA 06 37    jp   z,$3706
36F4: 21 77 3B    ld   hl,$3B77
36F7: CD 08 39    call $3908
36FA: DD 21 99 3B ld   ix,$3B99
36FE: FD 21 9B 3B ld   iy,$3B9B
3702: 06 01       ld   b,$01
3704: 18 10       jr   $3716
3706: 21 7F 3C    ld   hl,$3C7F
3709: CD 08 39    call $3908
370C: DD 21 92 3C ld   ix,$3C92
3710: FD 21 96 3C ld   iy,$3C96
3714: 06 02       ld   b,$02
3716: 3A 03 D0    ld   a,($D003)
3719: EE FF       xor  $FF
371B: 0F          rrca
371C: 0F          rrca
371D: CD C4 36    call $36C4
3720: C9          ret

3721: AF          xor  a
3722: 32 0F E7    ld   ($E70F),a
3725: 67          ld   h,a
3726: 6F          ld   l,a
3727: 22 0D E7    ld   ($E70D),hl
372A: CD AD 38    call $38AD
372D: 21 22 3D    ld   hl,$3D22
3730: CD 08 39    call $3908
3733: 3A 00 D0    ld   a,($D000)
3736: 21 CB 80    ld   hl,$80CB
3739: CD B2 36    call $36B2
373C: 3A 01 D0    ld   a,($D001)
373F: 21 0B 81    ld   hl,$810B
3742: CD B2 36    call $36B2
3745: 3A 02 D0    ld   a,($D002)
3748: 21 4B 81    ld   hl,$814B
374B: CD B2 36    call $36B2
374E: CD 8C 37    call $378C
3751: 3A 0D E7    ld   a,($E70D)
3754: 21 8C 81    ld   hl,$818C
3757: CD 7A 37    call $377A
375A: 23          inc  hl
375B: 3A 0E E7    ld   a,($E70E)
375E: CD 7A 37    call $377A
3761: 3A 00 D0    ld   a,($D000)
3764: CB 4F       bit  1,a
3766: 20 CB       jr   nz,$3733
3768: 3A 01 D0    ld   a,($D001)
376B: CB 4F       bit  1,a
376D: 20 C4       jr   nz,$3733
376F: CD AD 38    call $38AD
3772: 3E 01       ld   a,$01
3774: CD 3C 39    call $393C
3777: C3 CD 35    jp   $35CD
377A: F5          push af
377B: 0F          rrca
377C: 0F          rrca
377D: 0F          rrca
377E: 0F          rrca
377F: E6 0F       and  $0F
3781: C6 30       add  a,$30
3783: 77          ld   (hl),a
3784: 23          inc  hl
3785: F1          pop  af
3786: E6 0F       and  $0F
3788: C6 30       add  a,$30
378A: 77          ld   (hl),a
378B: C9          ret
378C: 21 0F E7    ld   hl,$E70F
378F: 3A 4E E0    ld   a,($E04E)
3792: E6 C0       and  $C0
3794: BE          cp   (hl)
3795: C8          ret  z
3796: 32 0F E7    ld   ($E70F),a
3799: 3A 0E E7    ld   a,($E70E)
379C: C6 01       add  a,$01
379E: 27          daa
379F: 32 0E E7    ld   ($E70E),a
37A2: D0          ret  nc
37A3: 3A 0D E7    ld   a,($E70D)
37A6: C6 01       add  a,$01
37A8: 27          daa
37A9: 32 0D E7    ld   ($E70D),a
37AC: C9          ret

37AD: 2A 53 3D    ld   hl,($3D53)
37B0: 22 06 E7    ld   ($E706),hl
37B3: 21 68 3D    ld   hl,$3D68
37B6: FD 21 57 3D ld   iy,$3D57
37BA: CD C0 37    call $37C0
37BD: C3 CD 35    jp   $35CD
37C0: FD 22 0B E7 ld   ($E70B),iy
37C4: E5          push hl
37C5: CD AD 38    call $38AD
37C8: E1          pop  hl
37C9: CD 08 39    call $3908
37CC: DD 21 08 E7 ld   ix,$E708
37D0: 3E 01       ld   a,$01
37D2: 32 05 E7    ld   ($E705),a
37D5: 06 02       ld   b,$02
37D7: CD 23 39    call $3923
37DA: 3E 01       ld   a,$01
37DC: 0E 40       ld   c,$40
37DE: CD 3E 39    call $393E
37E1: CD 72 38    call $3872
37E4: CD 7D 38    call $387D
37E7: 3E FF       ld   a,$FF
37E9: 32 11 E7    ld   ($E711),a
37EC: 3A 00 D0    ld   a,($D000)
37EF: CB 4F       bit  1,a
37F1: 28 4A       jr   z,$383D
37F3: CD F2 38    call $38F2
37F6: E6 AA       and  $AA
37F8: FE 2A       cp   $2A
37FA: 28 13       jr   z,$380F
37FC: CD DD 38    call $38DD
37FF: 47          ld   b,a
3800: E6 55       and  $55
3802: FE 55       cp   $55
3804: 28 11       jr   z,$3817
3806: 78          ld   a,b
3807: E6 AA       and  $AA
3809: FE AA       cp   $AA
380B: 28 1D       jr   z,$382A
380D: 18 DD       jr   $37EC
380F: CD 72 38    call $3872
3812: CD 7D 38    call $387D
3815: 18 D5       jr   $37EC
3817: DD 36 00 55 ld   (ix+$00),$55
381B: 3A 06 E7    ld   a,($E706)
381E: DD 77 01    ld   (ix+$01),a
3821: DD 36 02 01 ld   (ix+$02),$01
3825: CD 4F 38    call $384F
3828: 18 C2       jr   $37EC
382A: DD 36 00 AA ld   (ix+$00),$AA
382E: 3A 07 E7    ld   a,($E707)
3831: DD 77 01    ld   (ix+$01),a
3834: DD 36 02 FF ld   (ix+$02),$FF
3838: CD 4F 38    call $384F
383B: 18 AF       jr   $37EC
383D: CD 72 38    call $3872
3840: 3E 01       ld   a,$01
3842: 0E 20       ld   c,$20
3844: CD 3E 39    call $393E
3847: 3A 00 D0    ld   a,($D000)
384A: CB 4F       bit  1,a
384C: 20 9E       jr   nz,$37EC
384E: C9          ret
384F: CD 72 38    call $3872
3852: DD 56 00    ld   d,(ix+$00)
3855: 1E 02       ld   e,$02
3857: CD C8 38    call $38C8
385A: 28 0F       jr   z,$386B
385C: CD 95 38    call $3895
385F: DD 56 00    ld   d,(ix+$00)
3862: 1E 01       ld   e,$01
3864: CD C8 38    call $38C8
3867: 20 F3       jr   nz,$385C
3869: 18 03       jr   $386E
386B: CD 95 38    call $3895
386E: CD 7D 38    call $387D
3871: C9          ret
3872: 3E 00       ld   a,$00
3874: 32 00 D0    ld   ($D000),a
3877: CB FF       set  7,a
3879: 32 00 D0    ld   ($D000),a
387C: C9          ret
387D: 3A 05 E7    ld   a,($E705)
3880: 4F          ld   c,a
3881: 06 00       ld   b,$00
3883: FD 2A 0B E7 ld   iy,($E70B)
3887: FD 09       add  iy,bc
3889: FD 7E 00    ld   a,(iy+$00)
388C: 32 00 D0    ld   ($D000),a
388F: CB FF       set  7,a
3891: 32 00 D0    ld   ($D000),a
3894: C9          ret
3895: 3A 05 E7    ld   a,($E705)
3898: DD BE 01    cp   (ix+$01)
389B: C8          ret  z
389C: 06 00       ld   b,$00
389E: CD 23 39    call $3923
38A1: DD 86 02    add  a,(ix+$02)
38A4: 32 05 E7    ld   ($E705),a
38A7: 06 02       ld   b,$02
38A9: CD 23 39    call $3923
38AC: C9          ret
38AD: 21 00 80    ld   hl,$8000
38B0: 01 FF 03    ld   bc,$03FF
38B3: 36 00       ld   (hl),$00
38B5: 54          ld   d,h
38B6: 5D          ld   e,l
38B7: 13          inc  de
38B8: ED B0       ldir
38BA: 21 00 84    ld   hl,$8400
38BD: 01 FF 03    ld   bc,$03FF
38C0: 36 00       ld   (hl),$00
38C2: 54          ld   d,h
38C3: 5D          ld   e,l
38C4: 13          inc  de
38C5: ED B0       ldir
38C7: C9          ret
38C8: 0E 00       ld   c,$00
38CA: 06 0C       ld   b,$0C
38CC: CD E2 38    call $38E2
38CF: A2          and  d
38D0: C8          ret  z
38D1: 10 F9       djnz $38CC
38D3: 0D          dec  c
38D4: 20 F4       jr   nz,$38CA
38D6: 1D          dec  e
38D7: 20 EF       jr   nz,$38C8
38D9: 3E FF       ld   a,$FF
38DB: A2          and  d
38DC: C9          ret
38DD: CD E2 38    call $38E2
38E0: 18 1F       jr   $3901
38E2: 21 10 E7    ld   hl,$E710
38E5: 3A 01 D0    ld   a,($D001)
38E8: 1F          rra
38E9: CB 16       rl   (hl)
38EB: 1F          rra
38EC: CB 16       rl   (hl)
38EE: 7E          ld   a,(hl)
38EF: EE FF       xor  $FF
38F1: C9          ret
38F2: 21 11 E7    ld   hl,$E711
38F5: 3A 00 D0    ld   a,($D000)
38F8: 1F          rra
38F9: CB 16       rl   (hl)
38FB: 1F          rra
38FC: CB 16       rl   (hl)
38FE: 7E          ld   a,(hl)
38FF: EE FF       xor  $FF
3901: F5          push af
3902: AF          xor  a
3903: 3D          dec  a
3904: 20 FD       jr   nz,$3903
3906: F1          pop  af
3907: C9          ret
3908: 7E          ld   a,(hl)
3909: FE 00       cp   $00
390B: C8          ret  z
390C: CD 11 39    call $3911
390F: 18 F7       jr   $3908
3911: 4E          ld   c,(hl)
3912: 06 00       ld   b,$00
3914: 23          inc  hl
3915: 5E          ld   e,(hl)
3916: 23          inc  hl
3917: 56          ld   d,(hl)
3918: 23          inc  hl
3919: ED B0       ldir
391B: C9          ret
391C: 4F          ld   c,a
391D: D6 03       sub  $03
391F: 07          rlca
3920: 3C          inc  a
3921: 18 01       jr   $3924
3923: 4F          ld   c,a
3924: C5          push bc
3925: 0E 64       ld   c,$64
3927: 06 00       ld   b,$00
3929: 60          ld   h,b
392A: 07          rlca
392B: 07          rlca
392C: 07          rlca
392D: 6F          ld   l,a
392E: 29          add  hl,hl
392F: 29          add  hl,hl
3930: 09          add  hl,bc
3931: EB          ex   de,hl
3932: 21 00 84    ld   hl,$8400
3935: 19          add  hl,de
3936: C1          pop  bc
3937: 70          ld   (hl),b
3938: 23          inc  hl
3939: 70          ld   (hl),b
393A: 79          ld   a,c
393B: C9          ret
393C: 0E 00       ld   c,$00
393E: 06 00       ld   b,$00
3940: 10 FE       djnz $3940
3942: 0D          dec  c
3943: 20 F9       jr   nz,$393E
3945: 3D          dec  a
3946: 20 F4       jr   nz,$393C
3948: C9          ret
3949: C5          push bc
394A: 0E 00       ld   c,$00
394C: 06 00       ld   b,$00
394E: 10 FE       djnz $394E
3950: F5          push af
3951: 3A 00 D0    ld   a,($D000)
3954: CB 4F       bit  1,a
3956: 28 09       jr   z,$3961
3958: F1          pop  af
3959: 0D          dec  c
395A: 20 F0       jr   nz,$394C
395C: 3D          dec  a
395D: 20 EB       jr   nz,$394A
395F: C1          pop  bc
3960: C9          ret
3961: F1          pop  af
3962: C1          pop  bc
3963: 06 01       ld   b,$01
3965: C9          ret

3966: CD AD 38    call $38AD
3969: 11 00 E1    ld   de,$E100
396C: 21 6D 3E    ld   hl,$3E6D
396F: 01 10 00    ld   bc,$0010
3972: ED B0       ldir
3974: 11 60 E1    ld   de,$E160
3977: 21 7D 3E    ld   hl,$3E7D
397A: 01 10 00    ld   bc,$0010
397D: ED B0       ldir
397F: 3A 00 D0    ld   a,($D000)
3982: CB 4F       bit  1,a
3984: 20 F9       jr   nz,$397F
3986: 21 00 E1    ld   hl,$E100
3989: 36 00       ld   (hl),$00
398B: 54          ld   d,h
398C: 5D          ld   e,l
398D: 13          inc  de
398E: 01 BF 00    ld   bc,$00BF
3991: ED B0       ldir
3993: C3 CD 35    jp   $35CD
3996: 3E 01       ld   a,$01
3998: 32 12 E7    ld   ($E712),a
399B: AF          xor  a
399C: 32 11 E7    ld   ($E711),a
399F: 18 2A       jr   $39CB
39A1: 3A 00 D0    ld   a,($D000)
39A4: CB 4F       bit  1,a
39A6: CA CD 35    jp   z,$35CD
39A9: CD F2 38    call $38F2
39AC: E6 AA       and  $AA
39AE: FE 2A       cp   $2A
39B0: 20 EF       jr   nz,$39A1
39B2: 3A 12 E7    ld   a,($E712)
39B5: 3C          inc  a
39B6: 32 12 E7    ld   ($E712),a
39B9: FE 01       cp   $01
39BB: 28 0E       jr   z,$39CB
39BD: FE 02       cp   $02
39BF: CA E8 39    jp   z,$39E8
39C2: FE 03       cp   $03
39C4: CA 13 3A    jp   z,$3A13
39C7: D6 03       sub  $03
39C9: 18 EB       jr   $39B6
39CB: CD AD 38    call $38AD
39CE: 21 1C 81    ld   hl,$811C
39D1: 06 1A       ld   b,$1A
39D3: 3E 5A       ld   a,$5A
39D5: 77          ld   (hl),a
39D6: 2B          dec  hl
39D7: 3D          dec  a
39D8: 10 FB       djnz $39D5
39DA: 21 0C 82    ld   hl,$820C
39DD: 06 0A       ld   b,$0A
39DF: 3E 39       ld   a,$39
39E1: 77          ld   (hl),a
39E2: 2B          dec  hl
39E3: 3D          dec  a
39E4: 10 FB       djnz $39E1
39E6: 18 B9       jr   $39A1
39E8: CD BA 38    call $38BA
39EB: 21 20 80    ld   hl,$8020
39EE: 36 F3       ld   (hl),$F3
39F0: 54          ld   d,h
39F1: 5D          ld   e,l
39F2: 13          inc  de
39F3: 01 BF 03    ld   bc,$03BF
39F6: ED B0       ldir
39F8: 21 8D 3E    ld   hl,$3E8D
39FB: 06 0A       ld   b,$0A
39FD: C5          push bc
39FE: 5E          ld   e,(hl)
39FF: 23          inc  hl
3A00: 56          ld   d,(hl)
3A01: 23          inc  hl
3A02: 46          ld   b,(hl)
3A03: 23          inc  hl
3A04: 4E          ld   c,(hl)
3A05: 23          inc  hl
3A06: 7E          ld   a,(hl)
3A07: 23          inc  hl
3A08: EB          ex   de,hl
3A09: CD 23 3A    call $3A23
3A0C: EB          ex   de,hl
3A0D: C1          pop  bc
3A0E: 10 ED       djnz $39FD
3A10: C3 A1 39    jp   $39A1
3A13: 21 20 84    ld   hl,$8420
3A16: 36 0C       ld   (hl),$0C
3A18: 54          ld   d,h
3A19: 5D          ld   e,l
3A1A: 13          inc  de
3A1B: 01 BF 03    ld   bc,$03BF
3A1E: ED B0       ldir
3A20: C3 A1 39    jp   $39A1
3A23: C5          push bc
3A24: E5          push hl
3A25: 77          ld   (hl),a
3A26: 23          inc  hl
3A27: 10 FC       djnz $3A25
3A29: E1          pop  hl
3A2A: 0E 20       ld   c,$20
3A2C: 09          add  hl,bc
3A2D: C1          pop  bc
3A2E: 0D          dec  c
3A2F: 20 F2       jr   nz,$3A23
3A31: C9          ret

3A32: CD AD 38    call $38AD
3A35: 21 20 80    ld   hl,$8020
3A38: 0E 1E       ld   c,$1E
3A3A: 06 0F       ld   b,$0F
3A3C: C5          push bc
3A3D: 06 00       ld   b,$00
3A3F: 36 94       ld   (hl),$94
3A41: 54          ld   d,h
3A42: 5D          ld   e,l
3A43: 23          inc  hl
3A44: 36 93       ld   (hl),$93
3A46: 23          inc  hl
3A47: EB          ex   de,hl
3A48: ED B0       ldir
3A4A: EB          ex   de,hl
3A4B: 0E 1E       ld   c,$1E
3A4D: 36 96       ld   (hl),$96
3A4F: 54          ld   d,h
3A50: 5D          ld   e,l
3A51: 23          inc  hl
3A52: 36 95       ld   (hl),$95
3A54: 23          inc  hl
3A55: EB          ex   de,hl
3A56: ED B0       ldir
3A58: EB          ex   de,hl
3A59: C1          pop  bc
3A5A: 10 E0       djnz $3A3C
3A5C: 3A 00 D0    ld   a,($D000)
3A5F: CB 4F       bit  1,a
3A61: 20 F9       jr   nz,$3A5C
3A63: C3 CD 35    jp   $35CD

jump_table_3A96:
	.word	$0000 
	.word	$0000 
	.word	$0000 
	.word	$3666 
	.word	$3721
	.word	$37AD
	.word	$3966
	.word	$3996 
	.word	$3A32 
 
 