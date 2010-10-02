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
	bl forthinit

	bl drawall
.rs.loop:
	bl touchscreen
	b .rs.loop


tsup:
	push {lr}

	mov r0,#0
	str r0,TS_PRES 

	ldr r0,ALPHABET_ON
	cmp r0,#0
	popne {lr}
	bne up_alphabet

	ldr r0,SELECT
	bl select
	pop {lr}
	add pc,r2,lsl #2
	bx lr
	b up_right
	b up_pad
	b up_name


	pop {pc}

up_alphabet:
	push {lr}

	ldr r0,ALPHA_SELECT
	uxth r1,r0,ror #16
	uxth r0,r0

	cmp r0,#8
	bhs .up_alphabet_off
	cmp r1,#16
	bhs .up_alphabet_off

	add r1,r0,lsl #4 /* symbol */

	ldr r2,ALPHA_NAME
	adrl r3,NAMES
	add r0,r3,r2,lsl #3

	ldr r3,ALPHA_LEN
	strb r1,[r0,r3]
	add r3,#1
	str r3,ALPHA_LEN

	mov r0,#0xc00
	mov r1,r2
	bl drawname

	pop {pc}

.up_alphabet_off:
	mov r0,#0
	str r0,ALPHABET_ON
	bl drawall
	pop {pc}

ALPHA_NAME: .word 0

up_name:
	push {lr}
	add r1,r0,lsl #2

	ldr r2,PAD_AT
	cmn r2,#1
	bne .up_name.edit

	str r1,ALPHA_NAME

	adrl r0,FORTH
	add r0,r1,lsl #5
	bl topad
	bl drawpad

	ldr r0,SELECT
	bl redraw
	mvn r0,#0
	str r0,SELECT

	mov r0,#8
	bl redraw

	pop {pc}

.up_name.edit:
	adrl r0,PAD
	add r0,r2,lsl #1
	strh r1,[r0]

	mov r0,r2,lsr #2
	add r0,#9
	and r2,#3
	orr r0,r2,lsl #16

	bl redraw

	ldr r2,PAD_AT
	add r2,#1
	str r2,PAD_AT


	mov r0,r2,lsr #2
	add r0,#9
	and r2,#3
	orr r0,r2,lsl #16

	mov r1,#0xaa
	orr r1,#0xaa00
	orr r1,#0xaa0000
	orr r1,#0xaa000000
	str r1,DRAW_BG
	bl redraw
	mov r1,#0
	str r1,DRAW_BG

	pop {pc}

up_right:
	add pc,r0,lsl #2
	nop
	b right_atom
	b right_exit
	b right_save
	b right_run
	bx lr

	bx lr
	bx lr
	bx lr
	bx lr
	bx lr

	bx lr
	bx lr
	bx lr
	bx lr
	bx lr


right_atom:
	push {lr}
	mov r0,#1
	str r0,ALPHABET_ON
	mov r0,#0
	str r0,ALPHA_LEN
	bl draw_alphabet
	pop {lr}

right_exit:
	push {lr}

	ldr r2,PAD_AT
	cmn r2,#1
	beq .right_exit.skipclear

	mov r0,r2,lsr #2
	add r0,#9
	and r2,#3
	orr r0,r2,lsl #16
	bl redraw

	mvn r0,#0
	str r0,PAD_AT
.right_exit.skipclear:

	pop {pc}


right_save:
	push {lr}
	ldr r1,ALPHA_NAME
	adrl r0,FORTH
	add r0,r1,lsl #5
	bl frompad
	pop {pc}

right_run:
	push {lr}
	bl compile
	bl cacheflush
	bl run
	pop {pc}

compile:
	push {r8,r9,lr}
	adrl r8,COMPILED
	adrl r9,PAD
	bl .compile.one ; bl .compile.one ; bl .compile.one ; bl .compile.one
	bl .compile.one ; bl .compile.one ; bl .compile.one ; bl .compile.one
	bl .compile.one ; bl .compile.one ; bl .compile.one ; bl .compile.one
	bl .compile.one ; bl .compile.one ; bl .compile.one ; bl .compile.one

	ldr r3,BXLR
	str r3,[r8]

	pop {r8,r9,pc}

BXLR: bx lr

.compile.one:
	push {lr}
	ldrh r0,[r9],#2

	adrl r1,FORTH
	add r1,r0,lsl #5

	ldrh r2,[r1]
	cmp r2,#0
	popeq {pc}
	cmp r2,#1
	beq .compile.one.native
	cmp r2,#2
	beq .compile.one.number
	pop {pc}

.compile.one.native:
	ldrh r0,[r1,#2]
	bl .tonum
	str r0,[r8],#4
	pop {pc}

.compile.one.number:
	push {r0}
	ldrh r0,[r1,#2]
	bl .tonum

	pop {r1}
	adrl r2,NUMBERS
	str r0,[r2,r1,lsl #2]

	ldr r2,LOADNUM
	add r2,r1,lsl #2
	str r2,[r8],#4

	pop {pc}

LOADNUM: .word 0xe59a0000

DISPC_GFX_BA0: .word 0x48050480

.tonum:
	push {r8,r9,lr}
	adrl r8,NAMES
	add r8,r0,lsl #3

	ldr r0,[r8]
	bl .hextoh
	mov r9,r0

	ldr r0,[r8,#4]
	bl .hextoh

	pkhbt r0,r0,r9,lsl #16
	pop {r8,r9,pc}

.hextoh:
	push {lr}
	bl .digit; bl .digit; bl .digit; bl .digit
	mov r0,r1
	pop {pc}

.digit:
	and r2,r0,#0xff
	cmp r2,#61
	subhs r2,#0x57
	sublo r2,#0x30
	orr r1,r2,r1,lsl #4
	mov r0,r0,ror #8
	bx lr


dumpcode:
	push {r8,lr}

	adrl r8,COMPILED
	mov r0,#0x900
	ldr r1,[r8],#4; bl drawnum; ldr r1,[r8],#4; bl drawnum; ldr r1,[r8],#4; bl drawnum; ldr r1,[r8],#4; bl drawnum; 
	ldr r1,[r8],#4; bl drawnum; ldr r1,[r8],#4; bl drawnum; ldr r1,[r8],#4; bl drawnum; ldr r1,[r8],#4; bl drawnum; 
	ldr r1,[r8],#4; bl drawnum; ldr r1,[r8],#4; bl drawnum; ldr r1,[r8],#4; bl drawnum; ldr r1,[r8],#4; bl drawnum; 
	ldr r1,[r8],#4; bl drawnum; ldr r1,[r8],#4; bl drawnum; ldr r1,[r8],#4; bl drawnum; ldr r1,[r8],#4; bl drawnum; 
	
	pop {r8,pc}

frompad:
	push {lr}
	adrl r1,PAD
	bl .frompad.one; bl .frompad.one; bl .frompad.one; bl .frompad.one
	bl .frompad.one; bl .frompad.one; bl .frompad.one; bl .frompad.one
	pop {pc}

.frompad.one:
	ldr r2,[r1],#4
	str r2,[r0],#4
	bx lr
	

up_pad:
	push {lr}
	ldr r2,PAD_AT
	cmn r2,#1
	beq .up_pad.skipclear

	push {r0,r1}
	mov r0,r2,lsr #2
	add r0,#9
	and r2,#3
	orr r0,r2,lsl #16
	bl redraw
	pop {r0,r1}

.up_pad.skipclear:
	sub r0,#9
	add r1,r0,lsl #2
	str r1,PAD_AT

	mvn r0,#0
	str r0,SELECT
	pop {pc}

ALPHABET_ON: .word 0
PAD_AT: .word 0xffffffff

draw_alphabet:
	push {r8,lr}
	mov r8,#0
	bl .redraw_alpha_row
	bl .redraw_alpha_row
	bl .redraw_alpha_row
	bl .redraw_alpha_row
	bl .redraw_alpha_row
	bl .redraw_alpha_row
	bl .redraw_alpha_row
	bl .redraw_alpha_row
	pop {r8,pc}

.redraw_alpha_row:
	push {lr}
	orr r0,r8,#0x00000; bl redraw_alphabet
	orr r0,r8,#0x10000; bl redraw_alphabet
	orr r0,r8,#0x20000; bl redraw_alphabet
	orr r0,r8,#0x30000; bl redraw_alphabet
	orr r0,r8,#0x40000; bl redraw_alphabet
	orr r0,r8,#0x50000; bl redraw_alphabet
	orr r0,r8,#0x60000; bl redraw_alphabet
	orr r0,r8,#0x70000; bl redraw_alphabet
	orr r0,r8,#0x80000; bl redraw_alphabet
	orr r0,r8,#0x90000; bl redraw_alphabet
	orr r0,r8,#0xa0000; bl redraw_alphabet
	orr r0,r8,#0xb0000; bl redraw_alphabet
	orr r0,r8,#0xc0000; bl redraw_alphabet
	orr r0,r8,#0xd0000; bl redraw_alphabet
	orr r0,r8,#0xe0000; bl redraw_alphabet
	orr r0,r8,#0xf0000; bl redraw_alphabet
	add r8,#1
	pop {pc}

redraw_alphabet:
	uxth r1,r0,ror #16
	uxth r0,r0
	cmp r0,#8
	bxhs lr
	cmp r1,#16
	bxhs lr
	push {lr}

	mov r2,r0
	add r0,r1,r0,lsl #8
	add r1,r2,lsl #4 /* symbol */
	ldr r4,DRAW_FG
	ldr r5,DRAW_BG
	bl drawchar
	pop {pc}

ALPHA_WORD: .word 0,0
ALPHA_LEN: .word 0

alphabet_down:
	push {lr}
	bl ts_to_sc

	uxth r1,r0,ror #16
	uxth r0,r0

	lsr r0,#5
	lsr r1,#4

	pkhbt r0,r0,r1,lsl #16

	ldr r1,ALPHA_SELECT
	cmp r0,r1
	popeq {pc}

	str r0,ALPHA_SELECT

	push {r0}
	mov r0,r1
	bl redraw_alphabet
	pop {r0}

	mov r1,#0xaa
	orr r1,#0xaa00
	orr r1,#0xaa0000
	orr r1,#0xaa000000
	str r1,DRAW_BG
	bl redraw_alphabet
	mov r1,#0
	str r1,DRAW_BG
	
	pop {pc}

ALPHA_SELECT: .word 0

draw_stack:
	push {r8,lr}
	ldr r8,STACKP
	adrl r0,STACK
	sub r8,r0
	asr r8,#2

	cmp r8,#0
	popmi {r8,pc}; mov r0,#0xe00; add r0,#0x2a; ldr r1,STACK+1*4; bl drawnum; subs r8,#1
	popmi {r8,pc}; mov r0,#0xd00; add r0,#0x2a; ldr r1,STACK+2*4; bl drawnum; subs r8,#1
	popmi {r8,pc}; mov r0,#0xc00; add r0,#0x2a; ldr r1,STACK+3*4; bl drawnum; subs r8,#1
	popmi {r8,pc}; mov r0,#0xb00; add r0,#0x2a; ldr r1,STACK+4*4; bl drawnum; subs r8,#1
	popmi {r8,pc}; mov r0,#0xa00; add r0,#0x2a; ldr r1,STACK+5*4; bl drawnum; subs r8,#1
	popmi {r8,pc}; mov r0,#0x900; add r0,#0x2a; ldr r1,STACK+6*4; bl drawnum; subs r8,#1
	popmi {r8,pc}; mov r0,#0x800; add r0,#0x2a; ldr r1,STACK+7*4; bl drawnum; subs r8,#1
	popmi {r8,pc}; mov r0,#0x700; add r0,#0x2a; ldr r1,STACK+7*4; bl drawnum; subs r8,#1

	pop {r8,pc}

topad:
	push {lr}
	adrl r1,PAD
	bl .topad.one; bl .topad.one; bl .topad.one; bl .topad.one
	bl .topad.one; bl .topad.one; bl .topad.one; bl .topad.one
	pop {pc}

.topad.one:
	ldr r2,[r0],#4
	str r2,[r1],#4
	bx lr

tsdown:
	str	r0,TS_POINT
	ldr r1,ALPHABET_ON
	cmp r1,#0
	beq draw_hightlight
	b alphabet_down

draw_hightlight:
	push {r8,r9,lr}
	bl ts_to_sc

	# row = y/32, col=x/16
	# word = row*5 + col/10

	uxth r1,r0 		/* Y */
	lsr r1,r1,#5

	uxth r2,r0,ror #16	/* X */
	lsr r2,#4
	cmp r2, #9; movls r2,#0; bls .draw_hightlight.div
	cmp r2,#19; movls r2,#1; bls .draw_hightlight.div
	cmp r2,#29; movls r2,#2; bls .draw_hightlight.div
	cmp r2,#39; movls r2,#3; bls .draw_hightlight.div
	mov r2,#4
	.draw_hightlight.div:

	pkhbt   r0,r1,r2,lsl #16

	ldr r9,SELECT
	cmp r9,r0
	popeq {r8,r9,pc}

	mov r8,r0

	mov r3,#0xaa
	orr r3,#0xaa00
	orr r3,#0xaa0000
	orr r3,#0xaa000000
	str r3,DRAW_BG

	bl redraw
	
	mov r3,#0
	str r3,DRAW_BG

	str r8,SELECT
	cmn r9,#1
	popeq {r8,r9,pc}

	mov r0,r9
	bl redraw

	pop {r8,r9,pc}

select:
	uxth r1,r0,ror #16
	uxth r0,r0
	# r0=y, r1=x

	cmp r1,#4
	movhs r2,#0 /* right */
	bxhs lr

	cmp r0,#8
	moveq r2,#3 /* separator */
	bxeq lr
	movhs r2,#1 /* pad */
	movlo r2,#2 /* names */

	cmp r0,#13
	movhs r2,#-1
	bx lr


redraw:
	push {lr}
	bl select
	pop {lr}
	add pc,r2,lsl #2
	bx lr
	b redraw_right
	b redraw_pad
	b redraw_name
	b redraw_eight

redraw_eight:
	push {lr}
	cmp r1,#0
	popne {pc}
	mov r0,#0x800
	ldr r1,ALPHA_NAME
	bl drawname
	pop {pc}

redraw_right:
	push {lr}
	cmp r0,#4
	pophs {pc}
	bl cell_to_xy
	add r1,r0,#3
	mov r0,r2
	bl drawname
	pop {pc}

redraw_name:
	push {lr}
	bl cell_to_xy
	add r3,r1,r0,lsl #2
	mov r0,r2
	mov r1,r3
	bl drawname
	pop {pc}

# r1=x, r0=y
cell_to_xy:
	mov r2,r1,lsl #3; add r2,r1; add r2,r1 /* X*10 */
	orr r2,r0,lsl #8
	bx lr

redraw_pad:
	push {lr}
	bl cell_to_xy

	sub r0,#9
	add r1,r0,lsl #2
	mov r0,r1

	adrl r1,PAD
	add r1,r0,lsl #1
	ldrh r1,[r1]
	mov r0,r2
	bl drawname

	pop {pc}

SELECT: .word 0xffffffff

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
DRAW_FG:.word 0xFFFFFFFF
DRAW_BG:.word 0

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

drawall:
	push {r8,lr}
	mov r8,#0
	bl .drawrow; bl .drawrow; bl .drawrow; bl .drawrow; bl .drawrow;
	bl .drawrow; bl .drawrow; bl .drawrow; bl .drawrow; bl .drawrow;
	bl .drawrow; bl .drawrow; bl .drawrow; bl .drawrow; bl .drawrow;
	pop {r8,pc}
.drawrow:
	push {lr}
	orr r0,r8,#0x00000; bl redraw
	orr r0,r8,#0x10000; bl redraw
	orr r0,r8,#0x20000; bl redraw
	orr r0,r8,#0x30000; bl redraw
	orr r0,r8,#0x40000; bl redraw
	add r8,#0x1
	pop {pc}

drawname:
	push {r8,lr}

	ldr r4,DRAW_FG
	ldr r5,DRAW_BG

	tst r1,#0x8000
	bne .drawname.num

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

.drawname.num:
	adrl r8,NUMBERS
	bic r1,#0x8000
	ldr r1,[r8,r1,lsl #2]

	bl drawnum

	mov r1,#0x20
	bl drawchar
	bl drawchar
	pop {r8,pc}

drawpad:
	push {r8,lr}
	mov r8,#0x9
	bl .drawrow; bl .drawrow; bl .drawrow; bl .drawrow
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

forthinit:
	adr r0,STACK
	str r0,STACKP
	bx lr

# r0 is TOS
# r1 is A register
# r10 is data pool base
# r11 is data stack register
run:
	push {r10,r11,lr}
	adrl r10,NUMBERS
	ldr r11,STACKP
	ldr r0,[r11],#-4

	bl COMPILED

	str r0,[r11,#4]!
	str r11,STACKP

	bl draw_stack

	pop {r10,r11,pc}


PAD: .fill 16,2,0
STACKP: .word 0
STACK: .word 0,0,0,0,0,0,0,0

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

