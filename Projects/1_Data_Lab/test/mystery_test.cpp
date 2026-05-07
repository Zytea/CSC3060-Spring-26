#include <gtest/gtest.h>

#include <climits>
#include <cstddef>
#include <cstdint>

#include "data_lab.hpp"

// ============================================================
// Algorithm 1: Linear congruential generator
// ============================================================
int32_t lcg(int32_t seed, size_t iterations)
{
    constexpr int32_t multiplier = 1140671485; // a
    constexpr int32_t increment = 12820163;    // c
    constexpr int32_t MOD = 1 << 24;           // m

    int32_t value = seed; // X1

    for (size_t i = 0; i < iterations; ++i)
    {
        // aX + c
        value = data_lab::add(data_lab::multiply(multiplier, value), increment);

        // mod m
        value = data_lab::modulo(value, MOD);
    }

    return value;
}

// ============================================================
// Algorithm 2: Unnamed checksum
// ============================================================
int32_t checksum(const std::string input)
{
    int32_t sum = 12345;

    for (const auto &ch : input)
    {
        int32_t num = static_cast<uint8_t>(ch);
        sum = data_lab::add(
            sum, data_lab::modulo(data_lab::multiply(sum, num), num | (num << 12)));
    }
    return sum;
}

// ============================================================
// Algorithm 3: Modified Fibonacci sequence
// ============================================================
int32_t fibonacci(size_t rounds)
{
    constexpr size_t FREQ = 3;

    int32_t a = 0;
    int32_t b = 1;
    for (size_t i = 0; i < rounds; ++i)
    {
        int32_t tmp = data_lab::add(a, b);
        a = b;
        b = tmp;

        if (i % FREQ == 0)
        {
            a = data_lab::subtract(a, data_lab::modulo(a | b, (a & b) + 1));
            b = data_lab::add(b, data_lab::divide(a | b, (a & b) + 1));
        }
    }
    return b;
}

// Algo 1
TEST(Algorithm1Test, Test0) { EXPECT_EQ(lcg(10, 10), -12069348); }
TEST(Algorithm1Test, Test1) { EXPECT_EQ(lcg(100, 100), -6200); }
TEST(Algorithm1Test, Test2) { EXPECT_EQ(lcg(1000, 1000), 10731152); }
TEST(Algorithm1Test, Test3) { EXPECT_EQ(lcg(2026, 5000), 13504114); }
TEST(Algorithm1Test, Test4) { EXPECT_EQ(lcg(3060, 12345), -10460417); }
TEST(Algorithm1Test, Test5) { EXPECT_EQ(lcg(-3060, 23456), 2374316); }
TEST(Algorithm1Test, Test6) { EXPECT_EQ(lcg(20263060, 34567), 11485517); }
TEST(Algorithm1Test, Test7) { EXPECT_EQ(lcg(-20263060, 34567), -2653691); }
TEST(Algorithm1Test, Test8) { EXPECT_EQ(lcg(INT_MAX, 34567), 8802868); }
TEST(Algorithm1Test, Test9) { EXPECT_EQ(lcg(INT_MIN, 34567), -12361303); }

// Algo 2
TEST(Algorithm2Test, Test0) { EXPECT_EQ(checksum("Hello, world!"), 2215134); }
TEST(Algorithm2Test, Test1) { EXPECT_EQ(checksum("Hello, world"), 2156790); }
TEST(Algorithm2Test, Test2) { EXPECT_EQ(checksum("Hello world!"), 2324699); }
TEST(Algorithm2Test, Test3) { EXPECT_EQ(checksum("Hello world"), 2275331); }
TEST(Algorithm2Test, Test4)
{
    EXPECT_EQ(checksum("TEST(Algorithm1Test, Test9) { EXPECT_EQ(lcg(INT_MIN, "
                       "34567), -12361303); }"),
              11409958);
}
TEST(Algorithm2Test, Test5)
{
    EXPECT_EQ(checksum("TEST(Algorithm3Test, Test9) { "
                       "EXPECT_EQ(fibonacci(654321), -2004343542); }"),
              10618404);
}
TEST(Algorithm2Test, Test6)
{
    EXPECT_EQ(checksum("Algorithm 2: Unnamed checksum"), 6614819);
}
TEST(Algorithm2Test, Test7)
{
    EXPECT_EQ(checksum("for (size_t i = 0; i < rounds; ++i)"), 4218210);
}
TEST(Algorithm2Test, Test8)
{
    EXPECT_EQ(
        checksum(
            "TEST(AddTest, RandomNumber1) {EXPECT_EQ(data_lab::add(-894229282, "
            "-1769294128), 1631443886);}"),
        14348901);
}
TEST(Algorithm2Test, Test9)
{
    EXPECT_EQ(checksum("CSC3060 Project 1 - Data Lab"), 4610383);
}

// ALgo 3
TEST(Algorithm3Test, Test0) { EXPECT_EQ(fibonacci(10), 141); }
TEST(Algorithm3Test, Test1) { EXPECT_EQ(fibonacci(50), 1758101640); }
TEST(Algorithm3Test, Test2) { EXPECT_EQ(fibonacci(1000), 529998471); }
TEST(Algorithm3Test, Test3) { EXPECT_EQ(fibonacci(2026), -1558550099); }
TEST(Algorithm3Test, Test4) { EXPECT_EQ(fibonacci(3060), 213756210); }
TEST(Algorithm3Test, Test5) { EXPECT_EQ(fibonacci(10000), 1254696284); }
TEST(Algorithm3Test, Test6) { EXPECT_EQ(fibonacci(50000), -1872755544); }
TEST(Algorithm3Test, Test7) { EXPECT_EQ(fibonacci(123456), 1732317026); }
TEST(Algorithm3Test, Test8) { EXPECT_EQ(fibonacci(222222), -2011691744); }
TEST(Algorithm3Test, Test9) { EXPECT_EQ(fibonacci(654321), -996764637); }