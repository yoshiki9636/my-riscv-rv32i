#include <stdio.h>
#include <math.h>

//#define LP 10
#define LP 1000000
#define LP2 200
#define YSIZE 16
#define XSIZE 16
#define ZSIZE 16
// workaround for libm_nano.a
int __errno;
void pass();
void wait();
int mat_mul( double* mat1, double* mat2, double* result, int x, int y, int z);
int matrix_print( double* mat, int x, int y);
int double_print( char* cbuf, double value, int digit );
void uprint( char* buf, int length, int ret );

int main() {
	double mat1[ZSIZE*YSIZE];
	double mat2[XSIZE*ZSIZE];
	double result[XSIZE*YSIZE];
	
	for (int j = 0; j < YSIZE; j++) {
		for (int i = 0; i < ZSIZE; i++) {
			mat1[j*ZSIZE+i] = sqrt((double)(j*ZSIZE+i+1));
		}
	}
	for (int j = 0; j < ZSIZE; j++) {
		for (int i = 0; i < XSIZE; i++) {
			mat2[j*XSIZE+i] = sqrt((double)(j*XSIZE+i+21));
		}
	}
	for (int j = 0; j < YSIZE; j++) {
		for (int i = 0; i < XSIZE; i++) {
			result[j*XSIZE+i] = 0.0;
		}
	}

	mat_mul( mat1, mat2, result, XSIZE, YSIZE, ZSIZE);

	uprint( "mat1\n", 6, 0 );
	matrix_print( mat1, ZSIZE, YSIZE);
	uprint( "\nmat2\n", 8, 0 );
	matrix_print( mat2, XSIZE, ZSIZE);
	uprint( "\nresult\n", 10, 0 );
	matrix_print( result, XSIZE, YSIZE);
	pass();
	return 0;
}

int mat_mul( double* mat1, double* mat2, double* result, int x, int y, int z) {
	for(int j = 0; j < y; j++) {
		for(int i = 0; i < x; i++) {
			for(int k = 0; k < z; k++) {
				result[j*x+i] += mat1[j*z+k] * mat2[k*x+i];
			}
		}
	}
	return 0;
}

int matrix_print( double* mat, int x, int y) {
	char cbuf2[32];
	for(int j = 0; j < y; j++) {
		for(int i = 0; i < x; i++) {
			int length = double_print( cbuf2, mat[j*x+i], 9 );
			if ( i == x - 1 ) {
				uprint( cbuf2, length, 1 );
			}
			else {
				uprint( cbuf2, length, 2 );
			}
		}
	}
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

void uprint( char* buf, int length, int ret ) {
    unsigned int* led = (unsigned int*)0xc000fe00;
    unsigned int* uart_out = (unsigned int*)0xc000fc00;
    unsigned int* uart_status = (unsigned int*)0xc000fc04;

	for (int i = 0; i < length + 3; i++) {
		unsigned int flg = 1;
		while(flg == 1) {
			flg = *uart_status;
		}
		*uart_out = (i == length+2) ? 0 :
		            ((i == length+1)&&(ret != 1)) ? 0 :
		            ((i == length+1)&&(ret == 1)) ? 0x0a :
		            ((i == length)&&(ret == 0)) ? 0 :
		            ((i == length)&&(ret == 1)) ? 0x0d :
		            ((i == length)&&(ret == 2)) ? 0x20 : buf[i];
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

