PREDEFINED 'ATOM' 'EXIT' 'SAVE' 'RUN' 'PAGE0' 'PAGE1' 'PAGE2' 'PAGE3'

INIT FB >A DRAWALL
UP DUP CELLX >A CELLY A> UPNAMES UPRIGHT UPCODE DROP DROP CLEAR
DOWN HOVER

UPNAMES OVER f CMP HI? ; DUP 7 CMP HI? ; NAMESEL
NAMESEL OVER 3 LSL OVER + 5 LSL CODE + DRAWCODE
UPRIGHT DUP 9 CMP NE? ; RIGHTRUN
RIGHTRUN OVER 4 + 2 LSL ADDRS + @ 2 LSL COMPILED + CALL
UPCODE OVER 11 CMP LS? ; OVER OVER CODESEL

CODESEL CELL HIGHLGHT

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

DRAWNAMS FB >A PAGE @ ALLROWS DROP
ALLROWS TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW TOPROW
TOPROW COL COL COL COL COL COL COL COL NEXTROW
COL DUP DRAWNAME 8 +
DRAWNAME NAMES + RASTNAME DSPACE 
DSPACE 20 DUP CHAR CHAR
NEXTROW be00 A+

DRAWRGHT FB b40 + >A 20 RIGHT RIGHT RIGHT RIGHT RIGHT RIGHT RIGHT RIGHT DROP
RIGHT DUP DRAWNAME 8 + c6c0 A+

DRAWCODE FB e1000 + >A ALLCODE
ALLCODE CODE1 CODE1 CODE1 CODE1 NEXTROW CODE1 CODE1 CODE1 CODE1 DROP
CODE1 DUP @ DUP LOWER DRAWCOD1 HIGHER DRAWCOD1 4 +
DRAWCOD1 8000 TST EQ? : CODENAME CODENUM 
CODENAME 3 LSL DRAWNAME
CODENUM 7fff AND 2 LSL NUMBERS + @ RASTNUM DSPACE

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
PAGE VAR 0


FONT N@ 200 +
GLYPH 6 LSL FONT +
CODE N@ 2200 +
NAMES N@ 3200 +
ADDRS N@ 3600 +
COMPILED N@ 3800 +
NUMBERS N@

