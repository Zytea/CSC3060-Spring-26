#include <gtest/gtest.h>
#include "data_lab.hpp"

// 定义一个测试套件 AddTest，测试用例名为 AddPositiveNumbers
TEST(AddTest, AddPositiveNumbers) {
    // 使用 EXPECT_EQ 宏断言结果是否相等
    EXPECT_EQ(data_lab::add(2, 3), 5);
    EXPECT_EQ(data_lab::add(10, 20), 30);
    EXPECT_EQ(data_lab::add(100, 200), 300);
}