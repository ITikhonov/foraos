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
	bl	vauxinit
	bl	spiinit
	bl	tsinit
	mov	r0,#0
	push	{r0}
	bl dot

	bl touchscreen
	
	ldr	r1,DISPC_GFX_BA0
	ldr	r1,[r1]
	str	r1,TS_PNTR

	#bl	drawnames

.rs.loop:
	#bl	touchscreen
	#bl	drawtouch

	bl	tsirq
	pop	{r1}
	add	r1,#1
	push	{r1}
	bl	dumpall

	b	.rs.loop
DISPC_GFX_BA0:	.word 0x48050480

touchscreen:
	push {lr}
	mov	r0,#0b10010000
	bl spiwrite; bl spiread
	lsr r0,#11
	str r0,TS_YLST

	mov	r0,#0b11010000
	bl spiwrite; bl spiread
	lsr r0,#11
	str r0,TS_XLST

	pop {pc}
TS_XMIN:.word 0
TS_XMAX:.word 0
TS_YMIN:.word 0
TS_YMAX:.word 0
TS_XLST:.word 0
TS_YLST:.word 0
TS_PNTR:.word 0

drawtouch:
	push {lr}

	# x*800/4096
	ldr r0,TS_XLST
	mov r1,#800
	add r1,#45
	mul r0,r1,r0
	lsr r0,#12
	subs r0,#20
	movmi r0,#0
	cmp r0,#800
	movpl r0,#800
	subpl r0,#1

	# y*600/4096
	ldr r2,TS_YLST
	mov r1,#480
	add r1,#65
	mul r2,r1,r2
	lsr r2,#12
	subs r2,#35
	movmi r2,#0
	cmp r2,#480
	movpl r2,#480
	subpl r2,#1
	
	str r0,TS_XMIN
	str r2,TS_YMIN

	mov	r1,#(800*4)
	mul	r2,r1,r2

	ldr	r1,DISPC_GFX_BA0
	ldr	r1,[r1]

	add	r1,r2

	add	r1,r0,lsl #2
	mvn	r0,#0
	str	r0,[r1]


	ldr	r0,TS_PNTR
	cmp	r0,r1
	popeq	{pc}
	mov	r3,#0
	str	r3,[r0]
	str	r1,TS_PNTR

	pop {pc}

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
	push {lr}
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
	add r9,#800
	ldr r1,TS_XLST;mov r0,r9;bl dump;add r9,#800
	ldr r1,TS_YLST;mov r0,r9;bl dump;add r9,#800
	add r9,#800
	ldr r1,TS_XMIN;mov r0,r9;bl dump;add r9,#800
	ldr r1,TS_YMIN;mov r0,r9;bl dump;add r9,#800
	add r9,#800
	ldr r1,TS_XMAX;mov r0,r9;bl dump;add r9,#800
	ldr r1,TS_YMAX;mov r0,r9;bl dump;add r9,#800

	pop {pc}
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
	orr r1,#15<<2  /* 32 divider 1.5Mhz */
	orr r1,#1<<6  /* EPOL */
	orr r1,#31<<7  /* 8-bit word length */
	#orr r1,#2<<12 /* transmit only */
	orr r1,#1<<16 /* no transmission on Slave Output */
	orr r1,#1<<20 /* Force */
	str r1,[r0]

	#MCSPI_CH0CTRL =1
	ldr r0,MCSPI_CH0CTRL
	mov r1,#1
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
	push {lr}

	ldr r0,MCSPI_CH0STAT
.rx.loop:
	ldr r1,[r0]
	tst r1,#1
	beq .rx.loop

	ldr r1,MCSPI_RX0
	ldr r9,[r1]

	mov r0,r9
	pop {pc}

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
	mvncs r3,#0
	movcc r3,#0
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

cacheflush:
	mcr	p15,0,r0,c7,c5,0
	bx lr

tsinit:
	ldr	r0,GPIO11MUX
	ldr	r1,[r0]
	mov	r1,#0b1011100000000
	orr	r1,#0b100
	str	r1,[r0]

	ldr	r0,GPIO_OE1
	ldr	r1,[r0]
	orr	r1,#1<<11
	str	r1,[r0]

	bx	lr

tsirq:
	ldr	r0,GPIO_DATAIN1
	ldr	r0,[r0]
	ands	r0,#(1<<11)
	bx	lr

GPIO11MUX:.word 0x48002A24 
GPIO_OE1:.word 0x48310034
GPIO_DATAIN1:.word 0x48310038



# ---------------------------
halt:	b halt

FONT: .incbin "font.bin"
.align 4
FORTH: .incbin "code.bin"
.align 4
NAMES: .incbin "names.bin"

.align 4
end:

