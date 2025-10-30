#-------------------------------------------------------------------------------
# Base toolchain file for gcc compiler.
#
#
# NOTE: This should not be used standalone. It is meant to be included in a 
# target toolchain file in the supported-targets subdirectory after
# the CPU_FLAGS variable is set for the specific target.
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Set compiler/assembler flags
#-------------------------------------------------------------------------------

# Note: CPU_FLAGS can be specified from command line, a CMake Preset, or 
# can comes from another toolchain file that includes this one after 
# setting CPU_FLAGS.

set(COMPILER_FLAGS)
set(ASSEMBLER_FLAGS)

set(CMAKE_C_FLAGS_DEBUG "-g")

#-------------------------------------------------------------------------------
# Check if toolchain is installed, otherwise install it to build directory.
#-------------------------------------------------------------------------------

set(C_COMPILER_PATH gcc)
set(C_DEBUGGER_PATH gdb)
set(ASM_COMPILER_PATH gcc)
set(ASM_DEBUGGER_PATH gdb)
set(CXX_COMPILER_PATH g++)
set(CXX_DEBUGGER_PATH gdb)
set(AR_PATH gcc-ar)
set(RANLIB_PATH gcc-ranlib)
set(OBJCOPY_PATH objcopy)
set(SIZE_UTIL_PATH size)

set(TOOLCHAIN_NEEDED_BINS
    ${C_COMPILER_PATH}
    ${C_DEBUGGER_PATH}
    ${ASM_COMPILER_PATH}
    ${ASM_DEBUGGER_PATH}
    ${CXX_COMPILER_PATH}
    ${CXX_DEBUGGER_PATH}
    ${AR_PATH}
    ${RANLIB_PATH}
    ${OBJCOPY_PATH}
    ${SIZE_UTIL_PATH}
)

set(TOOLCHAIN_FOUND TRUE)

foreach(TOOLCHAIN_NEEDED_BIN ${TOOLCHAIN_NEEDED_BINS})
    find_program(${TOOLCHAIN_NEEDED_BIN}_BIN_PATH ${TOOLCHAIN_NEEDED_BIN} NO_CACHE)
    if (NOT ${TOOLCHAIN_NEEDED_BIN}_BIN_PATH)
        set(TOOLCHAIN_FOUND FALSE)
    endif()
endforeach()

set(TOOLCHAIN_FOUND FALSE)

if(NOT TOOLCHAIN_FOUND)
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
        execute_process(COMMAND uname -m OUTPUT_VARIABLE HOST_ARCH OUTPUT_STRIP_TRAILING_WHITESPACE)
        if(HOST_ARCH STREQUAL "x86_64")
            set(TOOLCHAIN_URL "https://github.com/xpack-dev-tools/gcc-xpack/releases/download/v15.2.0-1/xpack-gcc-15.2.0-1-linux-x64.tar.gz")
            set(TOOLCHAIN_FOLDER "xpack-gcc-15.2.0-1")
        elseif(HOST_ARCH STREQUAL "aarch64")
            set(TOOLCHAIN_URL "https://github.com/xpack-dev-tools/gcc-xpack/releases/download/v15.2.0-1/xpack-gcc-15.2.0-1-linux-arm64.tar.gz")
            set(TOOLCHAIN_FOLDER "xpack-gcc-15.2.0-1")
        endif()
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
        set(EXECUTABLE_ENDING ".exe")
        set(HOST_ARCH $ENV{PROCESSOR_ARCHITECTURE})
        if(HOST_ARCH STREQUAL "AMD64")
            set(HOST_ARCH "x86_64")
        endif()
        if(HOST_ARCH STREQUAL "x86_64")
            set(TOOLCHAIN_URL "https://github.com/brechtsanders/winlibs_mingw/releases/download/15.2.0posix-13.0.0-ucrt-r2/winlibs-x86_64-posix-seh-gcc-15.2.0-mingw-w64ucrt-13.0.0-r2.zip")
            set(TOOLCHAIN_FOLDER "mingw64")
        endif()
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
        message("Add GCC tools yourself!")
        return()
    endif()
    
    # Download and extract toolchain if not present
    set(TOOLCHAIN_DIR "${CMAKE_BINARY_DIR}/${TOOLCHAIN_FOLDER}")
    if(NOT EXISTS "${TOOLCHAIN_DIR}")
        message(STATUS "Downloading GCC toolchain for ${CMAKE_HOST_SYSTEM_NAME} ${HOST_ARCH}...")
        get_filename_component(ARCHIVE_NAME "${TOOLCHAIN_URL}" NAME)
        file(DOWNLOAD "${TOOLCHAIN_URL}" "${CMAKE_BINARY_DIR}/${ARCHIVE_NAME}" SHOW_PROGRESS)
        execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf "${ARCHIVE_NAME}" WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")
        file(REMOVE "${CMAKE_BINARY_DIR}/${ARCHIVE_NAME}")
    endif()

    set(C_COMPILER_PATH "${TOOLCHAIN_DIR}/bin/gcc${EXECUTABLE_ENDING}")
    set(C_DEBUGGER_PATH "${TOOLCHAIN_DIR}/bin/gdb${EXECUTABLE_ENDING}")
    set(ASM_COMPILER_PATH "${TOOLCHAIN_DIR}/bin/gcc${EXECUTABLE_ENDING}")
    set(ASM_DEBUGGER_PATH "${TOOLCHAIN_DIR}/bin/gdb${EXECUTABLE_ENDING}")
    set(CXX_COMPILER_PATH "${TOOLCHAIN_DIR}/bin/g++${EXECUTABLE_ENDING}")
    set(CXX_DEBUGGER_PATH "${TOOLCHAIN_DIR}/bin/gdb${EXECUTABLE_ENDING}")
    set(AR_PATH "${TOOLCHAIN_DIR}/bin/gcc-ar${EXECUTABLE_ENDING}")
    set(RANLIB_PATH "${TOOLCHAIN_DIR}/bin/gcc-ranlib${EXECUTABLE_ENDING}")
    set(OBJCOPY_PATH "${TOOLCHAIN_DIR}/bin/objcopy${EXECUTABLE_ENDING}")
    set(SIZE_UTIL_PATH "${TOOLCHAIN_DIR}/bin/size${EXECUTABLE_ENDING}")
endif()


#-------------------------------------------------------------------------------
# Set program paths for CMake
#-------------------------------------------------------------------------------

set(CMAKE_C_COMPILER ${C_COMPILER_PATH} ${COMPILER_FLAGS})
set(CMAKE_C_DEBUGGER ${C_DEBUGGER_PATH})
set(CMAKE_ASM_COMPILER ${ASM_COMPILER_PATH} ${ASSEMBLER_FLAGS})
set(CMAKE_ASM_DEBUGGER ${ASM_DEBUGGER_PATH})
set(CMAKE_CXX_COMPILER ${CXX_COMPILER_PATH} ${COMPILER_FLAGS})
set(CMAKE_CXX_DEBUGGER ${CXX_DEBUGGER_PATH})
set(CMAKE_AR ${AR_PATH})
set(CMAKE_RANLIB ${RANLIB_PATH})
set(CMAKE_OBJCOPY ${OBJCOPY_PATH})
set(CMAKE_SIZE_UTIL ${SIZE_UTIL_PATH})
