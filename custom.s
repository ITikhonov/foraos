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
	bl	sleep
	b	backlight

sleep:
	ldr	r4,COUNTER
loop:
	subs	r4,#1
	bne	loop
	bx	lr
COUNTER:.word 0x2000000

backlight:
	ldr	r0,GPT10_CLR
	ldr	r1,[r0]
	eor	r1,#1
	str	r1,[r0]
	b	realstart
GPT10_CLR:.word 0x48086024 


reboot:
	ldr	r0,PRCCTRL
	mov	r1,#4
	str	r1,[r0]
	b halt
PRCCTRL: .word 0x48307250


halt:	b halt

end:
