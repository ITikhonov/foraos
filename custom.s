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
	bl	sleep
	bl	sleep
	bl	sleep
	bl	sleep
	bl	sleep
	mov	r0,0xaaaaaaa


rloop:
	bl	zero
	bl	one
	b	rloop

zero:
	stmia	sp!,{lr}
	bl	backlighton
	bl	sleep
	bl	backlightoff
	bl	sleep
	ldmdb	sp!,{lr}
	bx	lr

one:
	stmia	sp!,{lr}
	bl	backlighton
	bl	sleep
	bl	sleep
	bl	backlightoff
	bl	sleep
	ldmdb	sp!,{lr}
	bx	lr

sleep:
	ldr	r0,COUNTER
loop:
	subs	r0,#1
	bne	loop
	bx	lr
COUNTER:.word 0x2000000

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
