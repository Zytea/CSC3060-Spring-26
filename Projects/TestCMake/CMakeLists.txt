cmake_minimum_required(VERSION 3.10)
project(data_lab LANGUAGES CXX)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 必须在 project 之后引入 FetchContent
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/heads/main.zip
)

# 核心修复：强制 GoogleTest 使用与项目相同的动态运行时库
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(googletest)

# 1. 定义库目标
add_library(data_lab src/data_lab.cpp)
target_include_directories(data_lab PUBLIC include)

# 2. 启用测试
enable_testing()

# 3. 定义测试可执行文件
add_executable(test_data_lab test/test_data_lab.cpp)

# 4. 链接库
# 注意：在 Windows 上有时需要显式链接静态库，确保顺序正确
target_link_libraries(test_data_lab data_lab gtest_main gtest)

# 5. 注册测试
add_test(NAME DataLabTests COMMAND test_data_lab)