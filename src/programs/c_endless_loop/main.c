#include <stdio.h>

int main(int argc, char ** argv) {
    unsigned long ticker=0;
    while(1) {
        if(++ticker%80==0) {
            printf("%lu\n",ticker/100);
        }
    }
}