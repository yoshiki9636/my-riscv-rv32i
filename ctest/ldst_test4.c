#include <stdio.h>

//#define LP 10
#define LP 1000000
#define LP2 200
#define TESTNUM 0x4000
void pass();
void fail(unsigned int val1, unsigned int val2, unsigned int val3);
void wait();

unsigned char bufa[TESTNUM];
unsigned char bufb[TESTNUM];

int main() {
    unsigned int* led = (unsigned int*)0xc000fe00;
	*led = 0x7;
	for(unsigned int i = 0; i < TESTNUM; i++) {
		bufa[i] = (unsigned char)(i & 0xff);
		//wait();
	}
	*led = 0x6;
	for(unsigned int i = 0; i < TESTNUM; i++) {
		//bufb[i] = i;
		bufb[i] = (unsigned char)((TESTNUM - 1 - i) & 0xff);
		//wait();
	}
	*led = 0x5;
	for(unsigned int i = 0; i < TESTNUM; i++) {
		*led = i;
		unsigned char c = bufb[TESTNUM-1-i];
		//unsigned int c = 0x20000 + TESTNUM - 1 - bufb[i];
		//unsigned int c = (0xffff) & ( TESTNUM - 1 - bufb[i]);
		if (bufa[i] != c) {
		//if (bufa[i] != bufb[i]) {
		//if (bufa[i] != ((TESTNUM - 1) & (TESTNUM - 1 - bufb[i]))) {
			//fail(i,bufa[i],bufb[i]);
			//fail(i,bufa[i],(TESTNUM - 1 - bufb[i]));
			//fail(i,bufa[i]>>1,(TESTNUM - 1 - bufb[i])>>1);
			fail(i,(unsigned char)bufa[i],(unsigned char)c);
		}
	}
	//fail(1,bufa[0],bufb[0]);
	pass();
	return 0;

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

void fail(unsigned int val1, unsigned int val2, unsigned int val3) {
    unsigned int* led = (unsigned int*)0xc000fe00;
    unsigned int val;
    unsigned int timer,timer2;
    val = 0;
    unsigned int sw = 0;
    while(1) {
		*led = 0x0;
		wait();
		*led =val1 & 0x7777;
		//*led =val & 0x7777;
		wait();
		*led = 0x0;
		wait();
		//*led = (val2 & 0x77777777) >> 16;
		*led = (bufa[val&0x3] & 0x77777777 ) >> 16;
		//*led =bufa[val&0xf] & 0x7777;
		wait();
		*led = 0x0;
		wait();
		//*led = val3 & 0x7777;
		//*led = (val3 & 0x77777777) >> 16;
		*led = (bufb[val&0x3] & 0x77777777 ) >> 16;
		//*led =bufb[val&0xf] & 0x7777;
		wait();
		*led = 0x0;
		wait();
		*led = 0x7777;
		wait();

		val++;
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

