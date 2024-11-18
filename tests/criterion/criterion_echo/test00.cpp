#include <cmath>
#include <criterion/criterion.h>

Test(misc, passing) { cr_assert(1); }

Test(misc, pi) { cr_assert(fabs(M_PI - 3.141) < 0.01); }
