cmake_minimum_required(VERSION 3.25)
project(HipNixBoilerplate LANGUAGES CXX HIP)
find_package(hip REQUIRED)

# Generate compile_commands.json for clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 17)

add_library(cpp_lib src/utils.cpp)
target_include_directories(cpp_lib PUBLIC include)

add_executable(hip_app src/main.hip)

target_link_libraries(hip_app PRIVATE hip::host)

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    target_compile_options(hip_app PRIVATE --offload-arch=native)
endif()

