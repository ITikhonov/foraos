AS=bin/as

all: custom.bin

custom.bin: custom
	bin/objcopy -O binary custom custom.bin

custom: custom.o
	bin/ld -o custom custom.o


install:
	sudo mount /dev/sdb1 /mnt
	cp custom.bin /mnt/zImage
	cp 1/Initramfs-2.6.27.10-omap1.cpio.gz /mnt/initramfs.cpio.gz
	sudo umount /mnt
