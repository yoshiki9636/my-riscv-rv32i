#include <stdio.h>
#include <math.h>

//#define LP 10
#define LP 1000000
#define LP2 200
// workaround for libm_nano.a
int __errno;
void pass();
void wait();
int double_print( char* cbuf, double value, int digit );
void uprint( char* buf, int length );

int main() {
	char cbuf2[32];

	for (int i = 1; i < 11; i++) {
		double b = sqrt((double)i);
		//double b = sqrt(2.0);
		int length = double_print( cbuf2, b, 9 );

		uprint( cbuf2, length );
	}
	pass();
	return 0;
}

int double_print( char* cbuf, double value, int digit ) {
	// type 0 : digit  1:hex
	unsigned char buf[32];

	int cntr = 0;
	
	if (value < 0) {
		buf[cntr++] = 0xfe; // for minus
		value = -value;
	}
	double mug = 1.0;
	while(value >= mug) {
		mug *= 10.0;
	}
	mug /= 10.0;
	for(int i = 0; i < digit; i++) {	
		unsigned char a =(unsigned char)(value / mug);
		buf[cntr++] = a;
		value = value - (double)a * mug;
		if (mug == 1.0) {
			buf[cntr++] = 0xff; // for preiod
		}
		mug /= 10.0;
	}
	if (mug >= 1.0) {
		while(mug >= 1.0) {
			unsigned char a =(unsigned char)(value / mug);
			buf[cntr++] = a;
			value = value - (double)a * mug;
			mug /= 10.0;
		}
	}
	for(int i = 0; i < cntr; i++) {	
		if (buf[i] == 0xff) {
			cbuf[i] = 0x2e;
		}
		else if (buf[i] == 0xfe) {
			cbuf[i] = 0x2d;
		}
		else {
			cbuf[i] = buf[i] + 0x30;
		}
	}	
	return cntr;	
}

void uprint( char* buf, int length ) {
    unsigned int* led = (unsigned int*)0xc000fe00;
    unsigned int* uart_out = (unsigned int*)0xc000fc00;
    unsigned int* uart_status = (unsigned int*)0xc000fc04;

	for (int i = 0; i < length + 3; i++) {
		unsigned int flg = 1;
		while(flg == 1) {
			flg = *uart_status;
		}
		*uart_out = (i == length+2) ? 0 :
		            (i == length+1) ? 0x0a :
		            (i == length) ? 0x0d : buf[i];
		*led = i;
	}
	//return 0;
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

