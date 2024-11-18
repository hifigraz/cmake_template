#include <math.h>
#include <criterion/criterion.h>
#include <test_c_lib.h>

Test(misc, passing) { cr_assert(1); }

Test(misc, pi) { cr_assert(fabs(M_PI - 3.141) < 0.01); }

Test(misc, say_hello) {
    say_hello();
    cr_assert(1);
}