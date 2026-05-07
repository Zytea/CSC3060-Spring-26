cmake_minimum_required(VERSION 3.30)
project(data_lab LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.17.0.zip
)
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# Library target
add_library(data_lab src/data_lab.cpp)
target_include_directories(data_lab PUBLIC include)

# Test target
enable_testing()
add_executable(test_data_lab
  test/test_data_lab.cpp
  test/mystery_test.cpp
)
target_link_libraries(test_data_lab data_lab gtest_main)
add_test(NAME DataLabTests COMMAND test_data_lab)