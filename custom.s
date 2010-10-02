# X coodinate in high part, in higher register (r1)
# Y coodinate in lower part, in lower register (r0)

# rework plan:
# drawing
# ts

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
	bl vfpinit
	bl vauxinit
	bl spiinit
	bl tsinit

.rs.loop:
	bl touchscreen
	b .rs.loop


DISPC_GFX_BA0: .word 0x48050480

tsup:
	push {lr}
	bl ts_to_sc
	ldr r1,DISPC_GFX_BA0
	ldr r1,[r1]
	uxth r2,r0
	mov r3,#800*4
	mla r1,r3,r2,r1

	uxth r2,r0,ror#16
	add r1,r2,lsl#2

	mvn r0,#0
	str r0,[r1]
	
	pop {pc}

tsdown:
	push {lr}
	bl ts_to_sc
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
	mov r0,#0
	str r0,TS_PRES
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

.align 4
FONT: .incbin "font.bin"
.align 4
FORTH: .incbin "code.bin"
.align 4
NAMES: .incbin "names.bin"
NUMBERS: .incbin "numbers.bin"

COMPILED: .fill 1024,4,0


.align 4
end:

