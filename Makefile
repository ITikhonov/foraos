AS=bin/as
ASFLAGS=-march=armv7-a -mcpu=cortex-a8 -mfpu=neon

all: custom.bin

custom.bin: custom
	bin/objcopy -O binary custom custom.bin

custom: custom.o
	bin/ld -o custom custom.o

custom.o: core.dict compiled.bin

core.dict: core.fth compile.py font.bin
	python ./compile.py core.fth

ui.dict: core.fth compile.py font.bin
	python ./compile.py ui.fth

linked: core.dict ui.dict core.link ui.link
	python link.py core ui
	touch linked

core.fth: sample.txt

install: all
	while ! sudo mount /dev/sdb1 /mnt; do sleep 1; done
	cp custom.bin /mnt/zImage
	cp 1/Initramfs-2.6.27.10-omap1.cpio.gz /mnt/initramfs.cpio.gz
	sudo umount /mnt

wayback:
	for i in 0 1 2 3 4 5 6 7 8 9; do sleep 1; sudo mount /dev/sdb1 /mnt; done
	cp 1/zImage-2.6.27.10-omap1 /mnt/zImage
	cp 1/Initramfs-2.6.27.10-omap1.cpio.gz /mnt/initramfs.cpio.gz
	sudo umount /mnt

font.bin: font.gray refont
	./refont

sample.txt: sample.o
	bin/objdump -D sample.o > sample.txt
	cat sample.txt

compiled.bin: codegen.py linked
	python codegen.py core.dict ui.dict
	$(AS) -o compiled.o empty.s
	bin/objcopy --add-section raw=compiled.bin compiled.o
	bin/objdump -D compiled.o > compiled.txt



