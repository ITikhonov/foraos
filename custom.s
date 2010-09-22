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
	bl	spiinit
	mov	r0,#0; bl dot
.rs.loop:
	bl	spiwrite
	mov	r0,#4; bl dot

	push {r0,r1}
	bl dumpall
	pop {r0,r1}

	bl	spiread
	mov	r0,#6; bl dot
	b	halt
	b	.rs.loop
DISPC_GFX_BA0:	.word 0x48050480

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

	pop {pc}

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

	pop {pc}
	
PRCM.CM_FCLKEN1_CORE:.word 0x48004A00
PRCM.CM_ICLKEN1_CORE:.word 0x48004A10
MCSPI_SYSCONFIG:.word 0x48098010
MCSPI_SYSSTATUS:.word 0x48098014
MCSPI_CH0CTRL:.word 0x48098034 
MCSPI_IRQENABLE:.word 0x4809801C
MCSPI_IRQSTATUS:.word 0x48098018

spiwrite:
	push {lr}

	#MCSPI_MODULCTRL =1
	ldr r0,MCSPI_MODULCTRL
	mov r1,#1
	str r1,[r0]

	#MCSPI_CHxCONF =0x0011 24D3 ???
	ldr r0,MCSPI_CH0CONF
	mov r1,#0
	orr r1,#5<<2  /* 32 divider 1.5Mhz */
	orr r1,#7<<7  /* 8-bit word length */
	orr r1,#2<<12 /* transmit only */
	orr r1,#1<<16 /* no transmission on Slave Output */
	orr r1,#1<<20 /* Force */
	str r1,[r0]

	#MCSPI_CH0CTRL =1
	ldr r0,MCSPI_CH0CTRL
	mov r1,#1
	str r1,[r0]

	#MCSPI_TXx =byte
	ldr r0,MCSPI_TX0
	mov r1,#0b10010000
	str r1,[r0]

	#poll MCSPI_CHxSTAT[1] TXS =1
	ldr r0,MCSPI_CH0STAT
.tx.loop:
	ldr r1,[r0]
	tst r1,#2
	beq .tx.loop

	#MCSPI_CH0CTRL =0
	ldr r0,MCSPI_CH0CTRL
	mov r1,#0
	str r1,[r0]


	pop {pc}
	
MCSPI_MODULCTRL:.word 0x48098028
MCSPI_CH0CONF:.word 0x4809802C 
MCSPI_TX0:.word 0x48098038 
MCSPI_CH0STAT:.word 0x48098030 
MCSPI_RX0:.word 0x4809803C 

spiread:
	ldr r0,MCSPI_CH0STAT
	ldr r1,[r0]
	tst r1,#1
	beq .r.skip

	ldr r0,MCSPI_RX0
	ldr r1,[r0]

.r.skip:
	#MCSPI_CHxCONF =0x0011 24D3 ???
	ldr r0,MCSPI_CH0CONF
	mov r1,#0
	orr r1,#5<<2  /* 32 divider 1.5Mhz */
	orr r1,#11<<5  /* 12-bit word length */
	orr r1,#1<<12 /* receive only */
	orr r1,#1<<17 /* no transmission on dpe1 */
	orr r1,#1<<18 /* receive on dpe1 */
	orr r1,#1<<20 /* Force */
	str r1,[r0]

	#MCSPI_CH0CTRL =1
	ldr r0,MCSPI_CH0CTRL
	mov r1,#0
	str r1,[r0]

	#MCSPI_CH0CTRL =0
	ldr r0,MCSPI_CH0CTRL
	mov r1,#0
	str r1,[r0]

	#poll MCSPI_CHxSTAT[1] RXS =1
	ldr r0,MCSPI_CH0STAT
.rx.loop:
	ldr r1,[r0]
	tst r1,#1
	beq .rx.loop

	ldr r1,MCSPI_RX0
	ldr r0,[r1]

	bx lr

# ---------------------------
halt:	b halt

end:

