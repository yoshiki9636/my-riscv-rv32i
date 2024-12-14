#include <stdio.h>
#include <string.h>

//#define LP 10
#define LP 1000000
#define LP2 200
void pass();
void uprint( char* buf, int length, int ret );
void wait();

int main() {
	char src[] = "This is bare-metal c test program!!!zzzzzzzzzzzzzzzzzzzzzzzzzzz";
	char dest[64]; 

	memset( dest, 0x41, 64);
	uprint( dest, 64, 2 );

	uprint( src, 64, 2 );

	for (int i = 5; i < 25; i = i + 3) {
		memset( dest, 0x41, 64);
		memcpy( &dest[i], src, i);
		uprint( dest, 64, 2 );
	}

	pass();
	return 0;

}

void uprint( char* buf, int length, int ret ) {
    unsigned int* led = (unsigned int*)0xc000fe00;
    unsigned int* uart_out = (unsigned int*)0xc000fc00;
    unsigned int* uart_status = (unsigned int*)0xc000fc04;

	for (int i = 0; i < length + ret; i++) {
		unsigned int flg = 1;
		while(flg == 1) {
			flg = *uart_status;
		}
        *uart_out = ((i == length+1)&&(ret == 2)) ? 0x0a :
                    ((i == length)&&(ret == 1)) ? 0x20 :
                    ((i == length)&&(ret == 2)) ? 0x0d : buf[i];
		*led = i;
	}
}

void pass() {
    unsigned int* led = (unsigned int*)0xc000fe00;
    unsigned int val;
    unsigned int timer,timer2;
    val = 0;
    while(1) {
		wait();
		val++;
		*led = val & 0x7777;
    }
}

void wait() {
    unsigned int timer,timer2;
    timer = 0;
	timer2 = 0;
    while(timer2 < LP2) {
        while(timer < LP) {
            timer++;
    	}
        timer2++;
	}
}

