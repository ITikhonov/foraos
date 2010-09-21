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
	bl	wholescreen
	b	halt
DISPC_GFX_BA0:	.word 0x48050480

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


pixel:
	mvn	r0,#0
	str	r0,[r9]
	bx	lr


show:
	push	{lr}
	bl	showone
	bl	showone
	bl	showone
	bl	showone
	bl	showone
	bl	showone
	bl	showone
	bl	showone

	bl	showone
	bl	showone
	bl	showone
	bl	showone
	bl	showone
	bl	showone
	bl	showone
	bl	showone

	bl	showone
	bl	showone
	bl	showone
	bl	showone
	bl	showone
	bl	showone
	bl	showone
	bl	showone

	bl	showone
	bl	showone
	bl	showone
	bl	showone
	bl	showone
	bl	showone
	bl	showone
	bl	showone

	bl	break
	pop	{lr}
	bx	lr

showoneb:
	push	{lr}
	lsls	r8,#1
	blcs	one
	blcc	zero
	pop	{lr}
	bx	lr

breakb:
	push	{lr}
	bl	sleep
	bl	sleep
	bl	sleep
	bl	sleep
	pop	{lr}
	bx	lr

rloop:
	bl	zero
	bl	one
	b	rloop

zerob:
	push	{lr}
	bl	backlighton
	bl	sleep
	bl	backlightoff
	bl	sleep
	pop	{lr}
	bx	lr

oneb:
	push	{lr}
	bl	backlighton
	bl	sleep
	bl	sleep
	bl	backlightoff
	bl	sleep
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


halt:	b halt

end:
