#include <stdio.h>

int main() {
    unsigned int* led = (unsigned int*)0xc000fe00;
    unsigned int val;
    unsigned int timer,timer2;
    val = 0;
    while(1) {
        timer = 0;
	timer2 = 0;
        while(timer2 < 90) {
            while(timer < 1000000) {
                timer++;
	    }
            timer2++;
	}
	val++;
	*led = val & 0x7;
    }
}
