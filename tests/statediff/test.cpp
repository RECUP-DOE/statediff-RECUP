#include <iostream>
#include <cassert> 

void test_functionality() {
    std::cout << "Running basic test...\n";
    assert(1 + 1 == 2);
    std::cout << "Test passed!\n";
}

int main() {
    test_functionality();
    return 0;
}
