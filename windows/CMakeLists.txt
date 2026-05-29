cmake_minimum_required(VERSION 3.14)
project(crux LANGUAGES CXX)

set(BINARY_NAME "crux")
set(BINARY_NAME_LIB "crux_lib")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_C_VISIBILITY_PRESET hidden)

set(PROJECT_BUILD_DIR "${PROJECT_SOURCE_DIR}/build")

set(FLUTTER_MANAGED_DIR "${PROJECT_SOURCE_DIR}/flutter")

# Flutter library and tool build rules.
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Application build
add_executable(${BINARY_NAME}
        "runner.cpp"
)
target_compile_definitions(${BINARY_NAME} PRIVATE)
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)

add_dependencies(${BINARY_NAME} flutter_assemble)