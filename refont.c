#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

unsigned int o[2048];
char i[65536];
unsigned int *po;

void copychar(int x,int y) {
	char *p=i+x*16+y*256*32;

	for(y=0;y<16;y++) {
		unsigned int v=0;
		for(x=0;x<8;x++) { putchar(*p?'1':'0'); v=(v<<1)|(*p++?1:0); }
		for(x=0;x<8;x++) { putchar(*p?'1':'0'); v=(v<<1)|(*p++?1:0); }
		p+=-16+256; printf(" 0x%04x\n",v);
		for(x=0;x<8;x++) { putchar(*p?'1':'0'); v=(v<<1)|(*p++?1:0); }
		for(x=0;x<8;x++) { putchar(*p?'1':'0'); v=(v<<1)|(*p++?1:0); }
		p+=-16+256; printf(" 0x%04x\n",v);

		*po++=v;
	}
	putchar('\n');
	putchar('\n');
}

int main() {
	if(read(open("font.gray",O_RDONLY),i,65536)!=65536) abort();
	po=o;
	int x,y;
	for(y=0;y<8;y++) {
		for(x=0;x<16;x++) {
			copychar(x,y);
		}
	}

	if(write(open("font.bin",O_CREAT|O_WRONLY,0664),o,8192)!=8192) { perror("write"); abort(); }
	return 0;
}

