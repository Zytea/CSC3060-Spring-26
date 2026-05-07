#include "data_lab.hpp"

#include <cstdint>

namespace data_lab {

int32_t add(int32_t a, int32_t b) {  // O(log N)
    uint32_t ua = static_cast<uint32_t>(a);
    uint32_t ub = static_cast<uint32_t>(b);
    uint32_t G = ua & ub;
    uint32_t P = ua ^ ub;

    G |= (P & (G << 1));
    P &= (P << 1);
    G |= (P & (G << 2));
    P &= (P << 2);
    G |= (P & (G << 4));
    P &= (P << 4);
    G |= (P & (G << 8));
    P &= (P << 8);
    G |= (P & (G << 16));
    P &= (P << 16);
    
    return static_cast<int32_t>((ua ^ ub) ^ (G << 1));
}

int32_t subtract(int32_t a, int32_t b) {  // O(log N)
  return add(a, add(~b, 1));
}

int32_t multiply(int32_t a, int32_t b) {  // O(N log N)
    uint32_t ua = static_cast<uint32_t>(a);
    uint32_t ub = static_cast<uint32_t>(b);
    uint32_t result = 0;
    for (int i = 0; i < 32; i++) {
        if (ub & 1) {
        result = static_cast<uint32_t>(
            add(static_cast<int32_t>(result), static_cast<int32_t>(ua)));
        }
        ua <<= 1;
        ub >>= 1;
    }
    return static_cast<int32_t>(result);
}

int32_t divide(int32_t a, int32_t b) {  // O(N log N)
    // remember signs
    uint32_t ua = static_cast<uint32_t>(a);
    uint32_t ub = static_cast<uint32_t>(b);
    bool negative = ((ua >> 31) & 1U) ^ ((ub >> 31) & 1U);
    // make positive
    uint32_t dividend;
    if ((ua >> 31) & 1U) {
        dividend = static_cast<uint32_t>(add(~a, 1));
    } else {
        dividend = static_cast<uint32_t>(a);
    }
    uint32_t divisor;
    if ((ub >> 31) & 1U) {
        divisor = static_cast<uint32_t>(add(~b, 1));
    } else {
        divisor = static_cast<uint32_t>(b);
    }
    // unsigned division
    uint32_t quotient = 0;
    uint32_t remainder = 0;
    for (int i = 31; i >= 0; i--) {
        remainder = (remainder << 1) | ((dividend >> i) & 1);
        int32_t temp = subtract(static_cast<int32_t>(remainder),
                                static_cast<int32_t>(divisor));
        if (!((static_cast<uint32_t>(temp) >> 31) & 1U)) {
        remainder = static_cast<uint32_t>(temp);
        quotient |= (1U << i);
        }
    }
    // apply sign
    if (negative) {
        return add(~static_cast<int32_t>(quotient), 1);
    } else {
        return static_cast<int32_t>(quotient);
    }
}

int32_t modulo(int32_t a, int32_t b) {  // O(N log N)
    return subtract(a, multiply(divide(a, b), b));
}

}  // namespace data_lab