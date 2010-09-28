.section ".start", #alloc, #execinstr

start:
	mov r0,r0
	mov r0,r0
	mov r0,r0
	mov r0,r0
	mov r0,r0
	mov r0,r0
	mov r0,r0
	mov r0,r0

	b realstart
	.word 0x016f2818
	.word start
	.word end


realstart:
	bl	vfpinit
	bl	vauxinit
	bl	spiinit
	bl	tsinit

	mvn	r0,#0

	ldr	r1,DISPC_GFX_BA0
	ldr	r1,[r1]

	mov	r2,#0x5d00
	add	r2,#0x00de
	lsl	r2,#2
	add	r2,r1
	str	r0,[r2]

	mov	r2,#0x6000
	add	r2,#0x00c2
	lsl	r2,#2
	add	r2,r1
	str	r0,[r2]

	mov	r2,#0x30000
	add	r2,#0x0a900
	add	r2,#0x0009e
	lsl	r2,#2
	add	r2,r1
	str	r0,[r2]


	mov	r0,#0
	mov	r9,#0

	# 30:30 = (30*800+30)*4

	bl	drawnames

.rs.loop:
	bl	touchscreen


	mov	r0,#0xc00
	add	r0,#9
	ldr	r1,TS_UP
	bl	drawnum

	mov	r0,#0xd00;
	ldr r1,TS_POOL; bl drawnum; add r0,#1
	ldr r1,TS_POOL+4; bl drawnum; add r0,#1
	ldr r1,TS_POOL+8; bl drawnum; add r0,#1
	ldr r1,TS_POOL+12; bl drawnum;

	mov	r0,#0xe00;
	ldr r1,TS_POOL+16; bl drawnum; add r0,#1
	ldr r1,TS_POOL+20; bl drawnum; add r0,#1
	ldr r1,TS_POOL+24; bl drawnum; add r0,#1
	ldr r1,TS_POOL+28; bl drawnum;

	#add	r9,#1
	#mov	r1,r9
	#bl	dumpall

	b	.rs.loop
DISPC_GFX_BA0:	.word 0x48050480

tsup:
	ldr r0,TS_POINT
	str r0,TS_UP
	bx lr

tsdown:
	push {lr}
	str	r0,TS_POINT

	mov	r1,r0
	mov	r0,#0xc00
	bl	drawnum

	ldr r0,TS_POINT
	bl ts_to_sc
	mov	r1,r0
	mov	r0,#0xc00
	add	r0,#20
	bl	drawnum

	bl draw_hightlight

	mov r0,#0
	str r0,TS_UP
	pop {pc}

draw_hightlight:
	push {lr}
	ldr r0,TS_POINT
	bl ts_to_sc

	# row = y/32, col=x/16
	# word = row*5 + col/10

	uxth r1,r0 		/* Y */
	lsr r2,r1,#5

	uxth r1,r0,ror #16	/* X */
	lsr r1,#4
	cmp r1, #9; movls r1,#0; bls .draw_hightlight.div
	cmp r1,#19; movls r1,#1; bls .draw_hightlight.div
	cmp r1,#29; movls r1,#2; bls .draw_hightlight.div
	cmp r1,#39; movls r1,#3; bls .draw_hightlight.div
	mov r1,#4
.draw_hightlight.div:

	mov r3,r2,lsl #2; add r3,r2 /* Y*4+Y */
	add r3,r1 /* +X */

	mov r4,r1,lsl #3; add r4,r1; add r4,r1 /* X*8+X+X */

	mov r0,r4
	orr r0,r2,lsl #8
	mov r1,r3

	mov r3,#0xaa
	orr r3,#0xaa00
	orr r3,#0xaa0000
	orr r3,#0xaa000000
	str r3,DRAW_BG
	bl drawname
	mov r3,#0
	str r3,DRAW_BG

	pop {pc}

/* 
   tsup - when screen was touched and not touched any more
   tsdown - when screen was not touched and touched now

   BEFORE LOAD: if PRESS and !IRQ - tsup, ret
		if !IRQ - ret

   AFTER  LOAD: if !IRQ - tsup, ret
   AFTER VALID: tsdown

 */
touchscreen:
	push {lr}

	bl tsirq
	bne .touchscreen.up

	bl tsload

	bl tsirq
	popne {pc}

	bl tsvalidate
	popeq {pc}

	str r0,TS_PRES
	bl tsdown
	
	pop {pc}

.touchscreen.up:
	ldr r0,TS_PRES
	cmp r0,#0
	blne tsup
	pop {pc}
	

tsload:
	push {r9,r10,lr}
	adr r9,TS_POOL
	mov r10,#0
	bl .tsone; bl .tsone; bl .tsone; bl .tsone
	bl .tsone; bl .tsone; bl .tsone; bl .tsone
	lsr r10,#3; bic r10,#0xf000
	str r10,TS_AVG
	mov r0,r10
	pop {r9,r10,pc}

tsvalidate:
	push {r9,r10,r11,lr}
	mov r10,r0
	# validate data, use r10 as average
	adr r9,TS_POOL
	mov r11,#0
	bl .tsone2; bl .tsone2; bl .tsone2; bl .tsone2
	bl .tsone2; bl .tsone2; bl .tsone2; bl .tsone2
	# r10 is zero if some data invalid, r11 is sum of valid
	cmp r10,#0
	mvneq r0,#0
	popeq {r9,r10,r11,pc}
	
	lsr r11,#3; bic r11,#0xf000
	mov r0,r11
	pop {r9,r10,r11,pc}

.tsone:
	push {r8,lr}
	mov r0,#0b10010000 /* Y */
	bl spiwrite; bl spiread
	mov r8,r0,lsr #11

	mov r0,#0b11010000 /* X */
	bl spiwrite; bl spiread
	orr r8,r0,lsl #5

	str r8,[r9],#4
	uadd16 r10,r10,r8

	pop {r8,pc}

# r9 is POOL pointr, r10 is average, r11 is accumulator
.tsone2:
	push {lr}

	ldr r0,[r9],#4
	ssub16 r1,r10,r0

	# lower part
	sxth r2,r1
	cmp r2,#5; bgt .tsone2.out
	cmp r2,#-5; blt .tsone2.out

	# higher part
	sxth r2,r1,ror #16
	cmp r2,#5; bgt .tsone2.out
	cmp r2,#-5; blt .tsone2.out

	uadd16 r11,r11,r0

	pop {pc}

.tsone2.out:
	mov r10,#0
	pop {pc}


TS_POINT:.word 0
TS_AVG:.word 0
TS_POOL:.word 0,0,0,0,0,0,0,0
TS_N:.word 0
TS_PRES:.word 0
TS_UP:.word 0

vauxinit:
	ldr	r0,GPIO54MUX
	ldr	r1,[r0]
	mov	r1,#0b100
	str	r1,[r0]

	ldr	r0,GPIO_OE2
	ldr	r1,[r0]
	bic	r1,#1<<22
	str	r1,[r0]

	ldr	r0,GPIO_CLROUT2
	ldr	r1,[r0]
	mov	r1,#1<<22
	str	r1,[r0]

	bx	lr
GPIO54MUX:.word 0x480020B4 
GPIO_OE2:.word 0x49050034 
GPIO_CLROUT2:.word 0x49050090 
 

dot:
	ldr	r1,DISPC_GFX_BA0
	ldr	r1,[r1]
	add	r1,r0,lsl #4
	mvn	r0,#0
	str	r0,[r1];add	r1,#4
	str	r0,[r1];add	r1,#4
	str	r0,[r1];add	r1,#0xc70; add r1,#8

	str	r0,[r1];add	r1,#4
	str	r0,[r1];add	r1,#4
	str	r0,[r1];add	r1,#0xc70; add r1,#8

	str	r0,[r1];add	r1,#4
	str	r0,[r1];add	r1,#4
	str	r0,[r1];add	r1,#0xc70; add r1,#8

	bx	lr

line:
	ldr	r1,DISPC_GFX_BA0
	ldr	r1,[r1]
	add	r1,r0,lsl #4
	mvn	r0,#0
	str	r0,[r1];add	r1,#4
	str	r0,[r1];add	r1,#4
	str	r0,[r1];add	r1,#0xc70; add r1,#8

	mov	r0,#0
	str	r0,[r1];add	r1,#4
	str	r0,[r1];add	r1,#4
	str	r0,[r1];add	r1,#0xc70; add r1,#8

	str	r0,[r1];add	r1,#4
	str	r0,[r1];add	r1,#4
	str	r0,[r1];add	r1,#0xc70; add r1,#8

	bx	lr


dump:
	push	{r8,r9,lr}
	mov	r8,r0
	mov	r9,r1

	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#2

	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#2

	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#2

	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line; add r8,#1
	lsls	r9,#1; mov r0,r8; blcs dot; blcc line;
	pop	{r8,r9,pc}

wholescreen:
	push	{lr}
	ldr	r9,DISPC_GFX_BA0
	ldr	r9,[r9]
	mov	r10,#0
.wh.loop:
	bl	row
	add	r10,#1
	cmp	r10,#600
	bne	.wh.loop
	pop	{lr}
	bx	lr

row:
	push	{lr}
	mov	r11,#0
	
.row.loop:
	bl	pixel

	add	r11,#1
	add	r9,#4
	cmp	r11,#800
	bne	.row.loop
	pop	{lr}
	bx	lr

MB_ONE_X:	.word	0xff
MB_ONE_Y:	.word	0xff

# x in r11, y in r10
falloff:
	ldr	r2,MB_ONE_X
	sub	r2,r11
	mul	r0,r2,r2

	ldr	r2,MB_ONE_Y
	sub	r2,r10
	mla	r0,r2,r2,r0
	bx	lr

pixel:
	push	{lr}

	bl	falloff
	cmp	r0,#30
	mvnls	r0,#0
	movhi	r0,#0
	str	r0,[r9]

	pop	{lr}
	bx	lr

sleep:
	ldr	r0,COUNTER
loop:
	subs	r0,#1
	bne	loop
	bx	lr
COUNTER:.word 0x8000000

backlighton:
	ldr	r0,GPT10_CLR
	ldr	r1,[r0]
	orr	r1,#1
	str	r1,[r0]
	bx	lr

backlightoff:
	ldr	r0,GPT10_CLR
	ldr	r1,[r0]
	bic	r1,#1
	str	r1,[r0]
	bx	lr

GPT10_CLR:.word 0x48086024 


reboot:
	ldr	r0,PRCCTRL
	mov	r1,#4
	str	r1,[r0]
	b halt
PRCCTRL: .word 0x48307250

# --------------------------------------

dumpall:
	push {r9,lr}
	push {r1}
	push {r0}
	mov r9,#800

	ldr r1,PRCM.CM_FCLKEN1_CORE;ldr r1,[r1];mov r0,r9;bl dump;add r9,#800
	ldr r1,PRCM.CM_ICLKEN1_CORE;ldr r1,[r1];mov r0,r9;bl dump;add r9,#800
	add r9,#800
	ldr r1,MCSPI_SYSCONFIG;ldr r1,[r1];mov r0,r9;bl dump;add r9,#800
	ldr r1,MCSPI_SYSSTATUS;ldr r1,[r1];mov r0,r9;bl dump;add r9,#800
	ldr r1,MCSPI_MODULCTRL;ldr r1,[r1];mov r0,r9;bl dump;add r9,#800
	add r9,#800
	ldr r1,MCSPI_CH0CTRL;ldr r1,[r1];mov r0,r9;bl dump;add r9,#800
	ldr r1,MCSPI_CH0CONF;ldr r1,[r1];mov r0,r9;bl dump;add r9,#800
	ldr r1,MCSPI_CH0STAT;ldr r1,[r1];mov r0,r9;bl dump;add r9,#800
	add r9,#800
	pop {r0}
	mov r1,r0;mov r0,r9;bl dump;add r9,#800
	pop {r1}
	mov r0,r9;bl dump;add r9,#800
	ldr r1,PADCONF_CLK;ldr r1,[r1];mov r0,r9;bl dump;add r9,#800
	ldr r1,PADCONF_SOMI;ldr r1,[r1];mov r0,r9;bl dump;add r9,#800

	pop {r9,pc}
MCSPI_SYST:.word 0x48098024
PADCONF_CLK:.word 0x480021C8   /* 00010111 00000000 00010111 00000000 */
                               /*       simo                clk       */
PADCONF_SOMI:.word 0x480021CC  /* 00010110 00001000 00010111 00000000 */
                               /*       somi                cs0       */


spiinit:
	push {lr}

	#PRCM.CM_FCLKEN1_CORE[18???]=1
	ldr r0,PRCM.CM_FCLKEN1_CORE
	ldr r1,[r0]
	orr r1,#1<<18
	str r1,[r0]

	#PRCM.CM_ICLKEN1_CORE[18???]=1
	ldr r0,PRCM.CM_ICLKEN1_CORE
	ldr r1,[r0]
	orr r1,#0x40000
	str r1,[r0]

	#MCSPI_SYSCONFIG[1]=1 // reset
	ldr r0,MCSPI_SYSCONFIG
	ldr r1,[r0]
	orr r1,#0x2
	str r1,[r0]

	#read till SPIm.MCSPI_SYSSTATUS[0]=1
	ldr r0,MCSPI_SYSSTATUS

.spiinit.wait:
	ldr r1,[r0]
	tst r1,#1
	beq .spiinit.wait

	#MCSPI_CH0CTRL =0
	ldr r0,MCSPI_CH0CTRL
	mov r1,#0
	str r1,[r0]
	
	#MCSPI_IRQENABLE =0
	ldr r0,MCSPI_IRQENABLE
	mov r1,#0
	str r1,[r0]
	
	#MCSPI_IRQSTATUS =0x0001 777F
	ldr r0,MCSPI_IRQSTATUS
	mvn r1,#0
	str r1,[r0]


	#MCSPI_MODULCTRL =1
	ldr r0,MCSPI_MODULCTRL
	mov r1,#1
	str r1,[r0]

	#MCSPI_CHxCONF =0x0011 24D3 ???
	ldr r0,MCSPI_CH0CONF
	mov r1,#0
	orr r1,#13<<2  /* 32 divider 1.5Mhz */
	orr r1,#1<<6  /* EPOL */
	orr r1,#31<<7  /* 8-bit word length */
	#orr r1,#2<<12 /* transmit only */
	orr r1,#1<<16 /* no transmission on Slave Output */
	orr r1,#1<<20 /* Force */
	str r1,[r0]


	pop {pc}
	
PRCM.CM_FCLKEN1_CORE:.word 0x48004A00
PRCM.CM_ICLKEN1_CORE:.word 0x48004A10
MCSPI_SYSCONFIG:.word 0x48098010
MCSPI_SYSSTATUS:.word 0x48098014
MCSPI_CH0CTRL:.word 0x48098034 
MCSPI_IRQENABLE:.word 0x4809801C
MCSPI_IRQSTATUS:.word 0x48098018

spiwrite:
	push {r9,lr}
	mov r9,r0

	ldr r0,MCSPI_IRQSTATUS
	mvn r1,#0
	str r1,[r0]

	ldr r0,MCSPI_CH0STAT
	ldr r1,[r0]
	tst r1,#1
	beq .r.skip
	ldr r0,MCSPI_RX0
	ldr r1,[r0]
.r.skip:

	#MCSPI_CH0CTRL =1
	ldr r0,MCSPI_CH0CTRL
	mov r1,#1
	str r1,[r0]

	ldr r0,MCSPI_TX0
	mov r1,r9,lsl #24
	str r1,[r0]

	pop {r9,pc}
	
MCSPI_MODULCTRL:.word 0x48098028
MCSPI_CH0CONF:.word 0x4809802C 
MCSPI_TX0:.word 0x48098038 
MCSPI_CH0STAT:.word 0x48098030 
MCSPI_RX0:.word 0x4809803C 

spiread:
	push {r9,lr}

	ldr r0,MCSPI_CH0STAT
.rx.loop:
	ldr r1,[r0]
	tst r1,#1
	beq .rx.loop

	ldr r1,MCSPI_RX0
	ldr r9,[r1]

	ldr r0,MCSPI_CH0CTRL
	mov r1,#0
	str r1,[r0]

	mov r0,r9
	pop {r9,pc}

char:
	push {lr}
	adrl r2,FONT
	and r1,#0xff
	add r2,r1,lsl #6

	bl tworows; bl tworows; bl tworows; bl tworows
	bl tworows; bl tworows; bl tworows; bl tworows
	bl tworows; bl tworows; bl tworows; bl tworows
	bl tworows; bl tworows; bl tworows; bl tworows

	pop {pc}

tworows:
	push {lr}
	ldr r1,[r2]
	add r2,#4
	bl charpixel; bl charpixel; bl charpixel; bl charpixel
	bl charpixel; bl charpixel; bl charpixel; bl charpixel
	bl charpixel; bl charpixel; bl charpixel; bl charpixel
	bl charpixel; bl charpixel; bl charpixel; bl charpixel
	add r0,#(800*4-16*4)
	bl charpixel; bl charpixel; bl charpixel; bl charpixel
	bl charpixel; bl charpixel; bl charpixel; bl charpixel
	bl charpixel; bl charpixel; bl charpixel; bl charpixel
	bl charpixel; bl charpixel; bl charpixel; bl charpixel
	add r0,#(800*4-16*4)
	pop {pc}

charpixel:
	lsls r1,#1
	movcs r3,r4
	movcc r3,r5
	str r3,[r0]
	add r0,#4
	bx lr

drawchar:
	push {r1,r8,lr}
	# r0= y*256+x
	# a = y*800*4*32 + x*4*16
	# a'= (y*800*2+x)*4*16
	mov r8,r0
	lsr r0,#8
	mov r2,#800*2
	mul r0,r2,r0
	and r2,r8,#0xff
	cmp r2,#49
	andeq r8,#0xff00
	addeq r8,#0x100
	addne r8,#1

	add r0,r2
	lsl r0,#6
	ldr	r2,DISPC_GFX_BA0
	ldr	r2,[r2]
	add	r0,r2
	bl char

	mov r0,r8
	pop {r1,r8,pc}

drawnames:
	push {r8,lr}
	adrl r8,FORTH
	mov r0,#0

.drawnames.loop:
	ldr r1,[r8]

	cmp r1,#0
	popeq {r8,pc}

	uxtah r8,r8,r1
	lsr r1,#16
	bl drawname
	b .drawnames.loop

	pop {r8,pc}

drawname:
	push {r8,lr}

	ldr r4,DRAW_FG
	ldr r5,DRAW_BG

	adrl r8,NAMES
	add r8,r1,lsl #3

	ldr r1,[r8],#4
	bl drawchar
	lsr r1,#8; bl drawchar
	lsr r1,#8; bl drawchar
	lsr r1,#8; bl drawchar

	ldr r1,[r8]
	bl drawchar
	lsr r1,#8; bl drawchar
	lsr r1,#8; bl drawchar
	lsr r1,#8; bl drawchar

	mov r1,#0x20
	bl drawchar
	bl drawchar

	pop {r8,pc}

drawnum:
	push {r8,lr}
	ldr r4,DRAW_FG
	ldr r5,DRAW_BG

	mov r8,r1
	ror r8,#28; and r1,r8,#0xf; add r1,#0x30; cmp r1,#0x3a; addge r1,#7; bl drawchar
	ror r8,#28; and r1,r8,#0xf; add r1,#0x30; cmp r1,#0x3a; addge r1,#7; bl drawchar
	ror r8,#28; and r1,r8,#0xf; add r1,#0x30; cmp r1,#0x3a; addge r1,#7; bl drawchar
	ror r8,#28; and r1,r8,#0xf; add r1,#0x30; cmp r1,#0x3a; addge r1,#7; bl drawchar

	ror r8,#28; and r1,r8,#0xf; add r1,#0x30; cmp r1,#0x3a; addge r1,#7; bl drawchar
	ror r8,#28; and r1,r8,#0xf; add r1,#0x30; cmp r1,#0x3a; addge r1,#7; bl drawchar
	ror r8,#28; and r1,r8,#0xf; add r1,#0x30; cmp r1,#0x3a; addge r1,#7; bl drawchar
	ror r8,#28; and r1,r8,#0xf; add r1,#0x30; cmp r1,#0x3a; addge r1,#7; bl drawchar
	pop {r8,pc}

DRAW_FG:.word 0xFFFFFFFF
DRAW_BG:.word 0

cacheflush:
	mcr	p15,0,r0,c7,c5,0
	bx lr

tsinit:
	push	{lr}
	ldr	r0,GPIO11MUX
	ldr	r1,[r0]
	mov	r1,#0b1011100000000
	orr	r1,#0b100
	str	r1,[r0]

	ldr	r0,GPIO_OE1
	ldr	r1,[r0]
	orr	r1,#1<<11
	str	r1,[r0]

	mov	r0,#0b10010000
	bl spiwrite; bl spiread
	pop	{pc}

tsirq:
	push	{r9,lr}
	ldr	r9,GPIO_DATAIN1
	ldr	r9,[r9]
	ands	r9,#(1<<11)
	pop	{r9,pc}

GPIO11MUX:.word 0x48002A24 
GPIO_OE1:.word 0x48310034
GPIO_DATAIN1:.word 0x48310038

vfpinit:
        mrc p15, 0, r1, c1, c0, 2
        orr r1, r1, #(0xf << 20)
        mcr p15, 0, r1, c1, c0, 2
        mov r1, #0
        mcr p15, 0, r1, c7, c5, 4

	mov r0,#0x40000000
	fmxr fpexc, r0
	bx lr

ts_to_sc:
	uxth r1,r0 /* Y */
	vmov    s0, r1
	vcvt.f32.u32    s0, s0
	vldr    s1, TS_Y0
	vadd.f32        s0, s0, s1
	vldr    s1, TS_YD
	vdiv.f32        s0, s0, s1
	vcvt.u32.f32   s0, s0
	vmov    r2, s0

	uxth    r1, r0, ror #16 /* X */
	vmov    s0, r1
	vcvt.f32.u32    s0, s0
	vldr    s1, TS_X0
	vadd.f32        s0, s0, s1
	vldr    s1, TS_XD
	vdiv.f32        s0, s0, s1
	vcvt.u32.f32   s0, s0
	vmov    r1, s0
	pkhbt   r0, r2, r1, lsl #16

	bx lr
	

TS_XD: .float 4.85135135135
TS_YD: .float 7.68888888889
TS_X0: .float -107.459459459
TS_Y0: .float -166.333333333

# ---------------------------
halt:	b halt

FONT: .incbin "font.bin"
.align 4
FORTH: .incbin "code.bin"
.align 4
NAMES: .incbin "names.bin"

.align 4
end:

