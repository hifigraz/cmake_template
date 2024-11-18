#include <cmath>
#include <criterion/criterion.h>

#include <test_cpp_lib.hpp>

Test(cpp, sayyeah) { 
    sayyeah();
    cr_assert(1);
}
