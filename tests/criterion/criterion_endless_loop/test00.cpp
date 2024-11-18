#include <cmath>
#include <criterion/criterion.h>

Test(failing, endlessloop) { 
    unsigned long int ticker=0;
    while(1) {
        if(++ticker%100==0) {
            printf("%lu\n",ticker/100);
        }
    }
}
