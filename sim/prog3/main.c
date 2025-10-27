// GCD program for prog3
// Reads two unsigned 32-bit integers div1 and div2 (placed in .rodata via data.S)
// Computes their greatest common divisor using the iterative Euclidean algorithm
// Stores the result at symbol _test_start (in _test section per link.ld)
// Division and modulo operations follow C99 semantics for unsigned integers.

#include <stdint.h>

static uint32_t gcd_u32(uint32_t a, uint32_t b) {
    // Handle zero cases explicitly (gcd(0, b) = b, gcd(a, 0) = a, gcd(0,0)=0)
    if (a == 0) return b;
    if (b == 0) return a;
    while (b != 0) {
        uint32_t r = a % b; // C99 ensures (a/b)*b + (a%b) == a
        a = b;
        b = r;
    }
    return a;
}

int main(void) {
    extern uint32_t div1;       // first operand (unsigned 32-bit)
    extern uint32_t div2;       // second operand (unsigned 32-bit)
    extern uint32_t _test_start; // destination for result

    uint32_t a = div1;
    uint32_t b = div2;
    uint32_t g = gcd_u32(a, b);

    *(&_test_start) = g; // store result

    return 0;
}
