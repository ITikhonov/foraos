PREDEFINED '' 'NATIVE' 'COND' 'VAR' ':' '' '' ''
PREDEFINED 'CORE' 'UI' '' '' '' '' '' ''
PREDEFINED 'INIT' 'UP' 'DOWN'

NATIVE ;
COND ;
VAR ;
: ;
CORE ;
UI ;

INIT UI\INIT
UP UI\UP
DOWN UI\DOWN

+ >D D+
- >D D-
* >D D*
LSL >D DLSL
LSR >D DLSR
AND >D DAND
OR >D DOR
HILO16 >D DHILO16
CMP >D DCMP
ROR >D DROR
CALL >D DCALL
TST >D DTST

! >A A!
W! >A AW!
W!+ >A AW!+

@ NATIVE e5900000
>A NATIVE e1a01000 DROP
A> NATIVE DUP e1a00001
A! NATIVE e5810000 DROP
DROP NATIVE e41b0004
DUP NATIVE e5ab0004
LOWER NATIVE e6ff0070
HIGHER NATIVE e6ff0870
>D NATIVE e1a02000 DROP
D+ NATIVE e0900002
D- NATIVE e0500002
D* NATIVE e0100092
DLSL NATIVE e1b00210
DLSR NATIVE e1b00230
DAND NATIVE e0100002
N@ NATIVE DUP e1a0000a
A!+ NATIVE e4810004 DROP
CS? COND 20000000
CC? COND 30000000
EQ? COND 00000000
A+ NATIVE e0911000 DROP
A- NATIVE e0511000 DROP
DCMP NATIVE e1500002 DROP
; NATIVE e8bd8000
^ NATIVE e8bd4000
A@ NATIVE DUP e5910000
NOT NATIVE e1e00000
DHILO16 NATIVE e6820810
D> NATIVE DUP e1a00002
DROR NATIVE e1a00270
HI? COND 80000000
LS? COND 90000000
NE? COND 10000000
SWAP NATIVE e59b2000 e58b0000 e1a00002
OVER NATIVE DUP e51b0004
DCALL NATIVE e12fff32
DTST NATIVE e1100002
AW! NATIVE e1c100b0
DOR NATIVE e1900002
AW!+ NATIVE e0c100b2