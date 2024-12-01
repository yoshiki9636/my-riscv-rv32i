#include <stdio.h>

//#define LP 10
#define LP 1000000
#define LP2 200
void pass();
void fail(unsigned int val1, unsigned int val2, unsigned int val3);
void wait();

int main() {
    unsigned int* led = (unsigned int*)0xc000fe00;
    unsigned int* st_point =  (unsigned int*)0x8000;
	*led = 0x7;
	//for(int i = 0x01000; i < 0x04000000; i += 4) {
	for(unsigned int i = 0; i < 1; i++) {
		*st_point = i;
		st_point++;
	}
	*led = 0x6;
	st_point =  (unsigned int*)0x8000;
	//for(int i = 0x01000; i < 0x04000000; i += 4) {
	for(unsigned int i = 0; i < 1; i++) {
		unsigned int j = *st_point;
		st_point++;
		if (i != j) {
			fail(1,i,j);
		}
	}
	pass();

}

void pass() {
    unsigned int* led = (unsigned int*)0xc000fe00;
    unsigned int val;
    unsigned int timer,timer2;
    val = 0;
    while(1) {
        timer = 0;
		timer2 = 0;
        while(timer2 < LP2) {
            while(timer < LP) {
                timer++;
	    	}
            timer2++;
		}
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
        timer = 0;
		timer2 = 0;
        while(timer2 < LP2) {
            while(timer < LP) {
                timer++;
	    	}
            timer2++;
		}
		*led =val1 & 0x7777;
        timer = 0;
		timer2 = 0;
        while(timer2 < LP2) {
            while(timer < LP) {
                timer++;
	    	}
            timer2++;
		}
		*led = 0x0;
        timer = 0;
		timer2 = 0;
        while(timer2 < LP2) {
            while(timer < LP) {
                timer++;
	    	}
            timer2++;
		}
		*led =val2 & 0x7777;
        timer = 0;
		timer2 = 0;
        while(timer2 < LP2) {
            while(timer < LP) {
                timer++;
	    	}
            timer2++;
		}
		*led = 0x0;
        timer = 0;
		timer2 = 0;
        while(timer2 < LP2) {
            while(timer < LP) {
                timer++;
	    	}
            timer2++;
		}
		*led = val3 & 0x7777;
        timer = 0;
		timer2 = 0;
        while(timer2 < LP2) {
            while(timer < LP) {
                timer++;
	    	}
            timer2++;
		}
		*led = 0x0;
        timer = 0;
		timer2 = 0;
        while(timer2 < LP2) {
            while(timer < LP) {
                timer++;
	    	}
            timer2++;
		}
		*led = 0x7777;
        timer = 0;
		timer2 = 0;
        while(timer2 < LP2) {
            while(timer < LP) {
                timer++;
	    	}
            timer2++;
		}

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

