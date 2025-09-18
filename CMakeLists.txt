cmake_minimum_required(VERSION 4.1)
include(FetchContent)



project(test C)

FetchContent_Declare(bsp
    GIT_REPOSITORY https://github.com/jasonpcarroll/TI-RM57-BSP.git
    GIT_TAG        main
    GIT_PROGRESS   target_include_directories
)

FetchContent_MakeAvailable(bsp)