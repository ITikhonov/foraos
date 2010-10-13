PREDEFINED 'ATOM' 'EXIT' 'SAVE' 'RUN' 'PAGE0' 'PAGE1' 'PAGE2' 'PAGE3'

# * Coordinates:
#    Touch: packed word [x:y]
#    Cell: [Y] [X]
#    Screen: framebuffer address in  A
#    Area: indirect through calling UP*

# * Conversions:
#    Touch -> Cell (once in up)
#    Cell -> Screen (CELL)
#    Touch -> Screen (SETCELL, once in hover)
#    Cell -> Area (once in UP)


# Name: [address into dictionary]
# Atom: packed 16-bit [dictionary no 1-based:atom no]
#	with	0x00 dictionary is a same definition belongs to
#		0x80 dictionary is a number indicator

# Edited: [address of code block]
# Cursor: [i] index of 16-bit atom in code block, with 0xffffffff being no cursor
# Code: [address in dictionary]
# Dict: [i] dict no 0-based

# * Conversions:
#    Atom -> Name (once in DRAWCODE)
#    Atom -> Number (once in DRAWCODE)
#    Cell -> Dict (once in UPRIGHT)
#    Cell -> Atom (once in CODEADD)
#    Cell -> Edited (once in NAMECHNG)
#    Cell -> Cursor (once in CODESEL)
#    (Edited,Cursor) -> Code (once in CODEADD)

# Area behaviour:
#    Touching NAMES yields atom to be inserted into code or selected as edited
#    Touching CODE sets position where atoms will be inserted
#    Touching DICT will change atoms shown in NAMES

INIT FB >A DRAWALL
UP DUP CELLX >A CELLY A> UPNAMES UPRIGHT UPCODE UPESC DROP DROP CLEAR
DOWN HOVER

# up handling words takes cell in two words on stack Y X

UPNAMES OVER f CMP HI? ; DUP 7 CMP HI? ; NAMESEL
UPRIGHT DUP 9 CMP NE? ; RIGHTRUN
RIGHTRUN OVER CURDICT ! DRAWNAMS
UPCODE OVER 11 CMP LS? ; OVER OVER CODESEL
UPESC DUP 8 CMP NE? ; ESCAPE

ESCAPE CODECLR ffffffff CODEPOS !

NAMESEL CODEPOS @ ffffffff CMP EQ? : NAMECHNG CODEADD

NAMECHNG OVER 3 LSL OVER + 5 LSL CCODE + DUP CODEBASE ! DRAWCODE

CODESEL CODECLR CODESET CODEHGLT

CODECLR ffffffff CODEPOS @ CMP EQ? ; 12 D> CELL HIGHLGHT
CODESET DUP CODEPOS !
CODEHGLT 12 CODEPOS @ CELL HIGHLGHT

CODEADD OVER OVER XYNAME DUP CODESAVE CODERDRW CODENEXT


CODESAVE CODEBASE @ CODEPOS @ 1 LSL + W!
CODENEXT HIGHLGHT CODEPOS @ 1 + CODEPOS !
CODERDRW 12 CODEPOS @ CELL 3 LSL CNAMES + DRAWNAME

XYNAME SWAP 3 LSL +

CODEBASE VAR 0
CODEPOS VAR ffffffff

DUMP FB >A RASTNUM

FB 48050480 @
DOT DUP Y c80 * >A X 4 * A> + FB + >A ffffffff A!
X HIGHER
Y LOWER

CHAR GLYPH RAST DROP c7e0 A-
RAST RAST32 RAST32 RAST32 RAST32 RAST32 RAST32 RAST32 RAST32 RAST32 RAST32 RAST32 RAST32 RAST32 RAST32 RAST32 RAST32
RAST32 DUP @ RASTROW DROP 4 +
RASTROW RAST16 c60 A+
RAST16 RAST1 RAST1 RAST1 RAST1 RAST1 RAST1 RAST1 RAST1
RAST1 2 LSL CS? : FG BG @ A!+

RASTNAME DUP @ NAME32 4 + @ NAME32
NAME32 NAME8 NAME8 NAME8 NAME8 DROP
NAME8 DUP ff AND CHAR 8 LSR

RASTNUM RASTDGIT RASTDGIT RASTDGIT RASTDGIT RASTDGIT RASTDGIT RASTDGIT RASTDGIT DROP
RASTDGIT 1c ROR DUP f AND 30 + DUP 39 CMP HI? 7 HI? + CHAR 


DRAWALL DRAWNAMS DRAWRGHT

DRAWNAMS FB >A CNAMES ALLROWS DROP
ALLROWS TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW
TOPROW COL COL COL COL COL COL COL COL NEXTROW
COL DUP DRAWNAME 8 +
DRAWNAME RASTNAME DSPACE 
DSPACE 20 DUP CHAR CHAR
NEXTROW be00 A+

DRAWRGHT FB b40 + >A NAMES 40 + RIGHT RIGHT RIGHT RIGHT RIGHT RIGHT RIGHT RIGHT DROP
RIGHT DUP DRAWNAME 8 + c6c0 A+

DRAWCODE FB e1000 + >A ALLCODE
ALLCODE CODE1 CODE1 CODE1 CODE1 NEXTROW CODE1 CODE1 CODE1 CODE1 DROP
CODE1 DUP @ DUP LOWER DRAWCOD1 HIGHER DRAWCOD1 4 +
DRAWCOD1 8000 TST EQ? : CODENAME CODENUM 
CODENAME INDICT DRAWNAME
CODENUM 7fff AND 2 LSL CNUMBERS + @ RASTNUM DSPACE

CELLX X 3334 * 14 LSR
CELLY Y 4 LSR
CELL 140 * >A c800 * A+ FB A+
SETCELL DUP CELLY c800 * >A CELLX 140 * A+ FB A+
HIGHLGHT XOR1ROW XOR1ROW XOR1ROW XOR1ROW XOR1ROW XOR1ROW XOR1ROW XOR1ROW XOR1ROW XOR1ROW XOR1ROW XOR1ROW XOR1ROW XOR1ROW XOR1ROW XOR1ROW
XOR1ROW XORROW XORROW XORROW XORROW XORROW XORROW XORROW XORROW XORROW XORROW b40 A+
XORROW NOTA+ NOTA+ NOTA+ NOTA+ NOTA+ NOTA+ NOTA+ NOTA+
NOTA+ A@ NOT A!+

HOVER SETCELL A> CELLOVER @ CMP EQ? ; D> SELECT DESELECT
SELECT A> HIGHLGHT CELLOVER !
DESELECT DUP >A 0 CMP EQ? ; HIGHLGHT
CLEAR CELLOVER @ DESELECT 0 CELLOVER !


BG VAR 0
FG VAR ffffffff
CELLOVER VAR 0


FONT N@ 200 +
GLYPH 6 LSL FONT +
CODE N@ 2200 +
NAMES N@ 3200 +
NUMBERS N@

CNAMES CURDICT @ 3600 * NAMES +
CCODE CURDICT @ 3600 * CODE +
CNUMBERS CURDICT @ 3600 * NUMBERS +

ADDRS NOTIMPL
COMPILED NOTIMPL
NOTIMPL ;

INDICT DUP ff AND 3 LSL SWAP DICT + NAMES +

DICT 7f00 TST EQ? : CURRENT OTHER
CURRENT DROP CURDICT @ 3600 *
OTHER 8 LSR 1 - 3600 *
CURDICT VAR 0

