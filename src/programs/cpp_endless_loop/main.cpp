#include <iostream>

int main(int argc, char ** argv) {
    size_t count = 0;
    while (true) {
        count++;
        if(count%1000==0) {
            std::cout << ".";
        }
    }
}