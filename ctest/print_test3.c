#include <stdio.h>

//#define LP 10
#define LP 1000000
#define LP2 200
void pass();
//void fail();
void wait();
//int int_print( char* cbuf, int value, int type );
int float_print( char* cbuf, float value, int digit );
void uprint( char* buf, int length );

int main() {
	//char cbuf[15] = "Hello World!!\n";
	char cbuf2[32];

	//int a = -12345;
	float b = 543.21;

/*
	int length = int_print( cbuf2, a, 0 );
	if (length > 10) {
		fail();
	}
	uprint( cbuf2, length );
*/

	int length = float_print( cbuf2, b, 8 );
	//if (length > 10) {
		//fail();
	//}
	uprint( cbuf2, length );
	pass();
	return 0;

}

/*
int int_print( char* cbuf, int value, int type ) {
	// type 0 : digit  1:hex
	unsigned char buf[32];
	int ofs = 0;
	int cntr = 0;
	if (type == 0) { // int
		if (value < 0) {
			cbuf[ofs++] = 0x2d;
			value = -value;
		}
		while(value > 0) {
			buf[cntr++] = (unsigned char)(value % 10);
			value = value / 10;
		}
		for(int i = cntr - 1; i >= 0; i--) {	
			cbuf[ofs++] = buf[i] + 0x30;
		}	
	}
	else { //unsinged int
		unsigned int uvalue = (unsigned int)value;
		while(uvalue > 0) {
			buf[cntr++] = (unsigned char)(uvalue % 10);
			uvalue = uvalue / 10;
		}
		for(int i = cntr - 1; i >= 0; i--) {	
			cbuf[ofs++] = buf[i] + 0x30;
		}	
	}
	return ofs;	
}
*/

int float_print( char* cbuf, float value, int digit ) {
    unsigned int* led = (unsigned int*)0xc000fe00;
	// type 0 : digit  1:hex
	unsigned char buf[32];

	int ofs = 0;
	int cntr = 0;
	
	if (value < 0) {
		cbuf[ofs++] = 0x2d;
		value = -value;
	}
	float mug = 1.0;
	while(value > mug) {
		mug *= 10.0;
	}
	mug /= 10.0;
	for(int i = 0; i < digit; i++) {	
		float a = value / mug;
		buf[cntr++] = (unsigned char)a;
		value = value - a * mug;
		if (mug == 1) {
			buf[cntr++] = 0xff; // for preiod
		}
		mug /= 10.0;
		*led = i;
	}
	for(int i = 0; i < cntr; i++) {	
		if (buf[i] == 0xff) {
			cbuf[ofs++] = 0x2e;
		}
		else {
			cbuf[ofs++] = buf[i] + 0x30;
		}
		*led = i;
	}	
	return ofs;	
}


void uprint( char* buf, int length ) {
    unsigned int* led = (unsigned int*)0xc000fe00;
    unsigned int* uart_out = (unsigned int*)0xc000fc00;
    unsigned int* uart_status = (unsigned int*)0xc000fc04;

	for (int i = 0; i < length + 1; i++) {
		unsigned int flg = 1;
		while(flg == 1) {
			flg = *uart_status;
		}
		*uart_out = (i == length) ? 0 : buf[i];
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

/*
void fail() {
    unsigned int* led = (unsigned int*)0xc000fe00;
    unsigned int val;
    unsigned int timer,timer2;
    val = 0;
    while(1) {
		wait();
		val++;
		*led = val & 0x1111;
    }
}
*/

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

