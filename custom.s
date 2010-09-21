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
	bl	backlightoff
	bl	break

	ldr	r8,DISPC_GFX_BA0
	ldr	r8,[r8]
	mvn	r0,#0
	str	r0,[r8]

	ldr	r8,DISPC_GFX_ATTRIBUTES
	ldr	r8,[r8]
	bl	show
	b	realstart
DISPC_CONTROL:	.word 0x48050440
DISPC_VID1_BA0: .word 0x480504bc
DISPC_GFX_BA0:	.word 0x48050480
DISPC_GFX_ATTRIBUTES:	.word 0x480504A0

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

showone:
	push	{lr}
	lsls	r8,#1
	blcs	one
	blcc	zero
	pop	{lr}
	bx	lr

break:
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

zero:
	push	{lr}
	bl	backlighton
	bl	sleep
	bl	backlightoff
	bl	sleep
	pop	{lr}
	bx	lr

one:
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
