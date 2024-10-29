#include "include/echo.h"
#include <iostream>

void echo(std::string echo_string) {
  std::cout << "The echo says " << echo_string << std::endl;
}

void echo2() { echo("2"); }
