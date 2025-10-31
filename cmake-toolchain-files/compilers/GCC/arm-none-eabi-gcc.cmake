# -------------------------------------------------------------------------------
# Base toolchain file for arm-none-eabi-gcc compiler.
#
# NOTE: This should not be used standalone. It is meant to be included in a
# target toolchain file in the supported-targets subdirectory after the
# CPU_FLAGS variable is set for the specific target.
# -------------------------------------------------------------------------------

set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_SYSTEM_NAME Generic-ELF)

# Need this or CMake will not pass test compilation
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# -------------------------------------------------------------------------------
# Set compiler/assembler flags
# -------------------------------------------------------------------------------

# Note: CPU_FLAGS can be specified from command line, a CMake Preset, or can
# comes from another toolchain file that includes this one after setting
# CPU_FLAGS.

set(COMPILER_FLAGS "${CPU_FLAGS}"
                   "-specs=nano.specs -fdata-sections -ffunction-sections")
set(ASSEMBLER_FLAGS "${CPU_FLAGS}")

set(CMAKE_C_FLAGS_DEBUG "-g")

# -------------------------------------------------------------------------------
# Check if toolchain is installed, otherwise install it to build directory.
# -------------------------------------------------------------------------------

set(C_COMPILER_PATH arm-none-eabi-gcc)
set(C_DEBUGGER_PATH arm-none-eabi-gdb)
set(ASM_COMPILER_PATH arm-none-eabi-gcc)
set(ASM_DEBUGGER_PATH arm-none-eabi-gdb)
set(CXX_COMPILER_PATH arm-none-eabi-g++)
set(CXX_DEBUGGER_PATH arm-none-eabi-gdb)
set(AR_PATH arm-none-eabi-gcc-ar)
set(RANLIB_PATH arm-none-eabi-gcc-ranlib)
set(OBJCOPY_PATH arm-none-eabi-objcopy)
set(SIZE_UTIL_PATH arm-none-eabi-size)

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
    ${SIZE_UTIL_PATH})

set(TOOLCHAIN_FOUND TRUE)

foreach(TOOLCHAIN_NEEDED_BIN ${TOOLCHAIN_NEEDED_BINS})
  find_program(${TOOLCHAIN_NEEDED_BIN}_BIN_PATH ${TOOLCHAIN_NEEDED_BIN}
               NO_CACHE)
  if(NOT ${TOOLCHAIN_NEEDED_BIN}_BIN_PATH)
    set(TOOLCHAIN_FOUND FALSE)
  endif()
endforeach()

set(TOOLCHAIN_FOUND FALSE)

if(NOT TOOLCHAIN_FOUND)
  if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    execute_process(
      COMMAND uname -m
      OUTPUT_VARIABLE HOST_ARCH
      OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(HOST_ARCH STREQUAL "x86_64")
      set(TOOLCHAIN_URL
          "https://developer.arm.com/-/media/Files/downloads/gnu/14.3.rel1/binrel/arm-gnu-toolchain-14.3.rel1-x86_64-arm-none-eabi.tar.xz"
      )
      set(TOOLCHAIN_FOLDER "arm-gnu-toolchain-14.3.rel1-x86_64-arm-none-eabi")
    elseif(HOST_ARCH STREQUAL "aarch64")
      set(TOOLCHAIN_URL
          "https://developer.arm.com/-/media/Files/downloads/gnu/14.3.rel1/binrel/arm-gnu-toolchain-14.3.rel1-aarch64-arm-none-eabi.tar.xz"
      )
      set(TOOLCHAIN_FOLDER "arm-gnu-toolchain-14.3.rel1-aarch64-arm-none-eabi")
    endif()
  elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set(EXECUTABLE_ENDING ".exe")
    set(HOST_ARCH $ENV{PROCESSOR_ARCHITECTURE})
    if(HOST_ARCH STREQUAL "AMD64")
      set(HOST_ARCH "x86_64")
    endif()
    if(HOST_ARCH STREQUAL "x86_64")
      set(TOOLCHAIN_URL
          "https://developer.arm.com/-/media/Files/downloads/gnu/14.3.rel1/binrel/arm-gnu-toolchain-14.3.rel1-mingw-w64-i686-arm-none-eabi.zip"
      )
      set(TOOLCHAIN_FOLDER
          "arm-gnu-toolchain-14.3.rel1-mingw-w64-i686-arm-none-eabi")
    endif()
  elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
    execute_process(
      COMMAND uname -m
      OUTPUT_VARIABLE HOST_ARCH
      OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(HOST_ARCH STREQUAL "x86_64")
      set(TOOLCHAIN_URL
          "https://developer.arm.com/-/media/Files/downloads/gnu/14.3.rel1/binrel/arm-gnu-toolchain-14.3.rel1-darwin-x86_64-arm-none-eabi.tar.xz"
      )
      set(TOOLCHAIN_FOLDER
          "arm-gnu-toolchain-14.3.rel1-darwin-x86_64-arm-none-eabi")
    elseif(HOST_ARCH STREQUAL "arm64")
      set(TOOLCHAIN_URL
          "https://developer.arm.com/-/media/Files/downloads/gnu/14.3.rel1/binrel/arm-gnu-toolchain-14.3.rel1-darwin-arm64-arm-none-eabi.tar.xz"
      )
      set(TOOLCHAIN_FOLDER
          "arm-gnu-toolchain-14.3.rel1-darwin-arm64-arm-none-eabi")
    endif()
  endif()

  # Download and extract toolchain if not present
  set(TOOLCHAIN_DIR "${CMAKE_BINARY_DIR}/${TOOLCHAIN_FOLDER}")
  if(NOT EXISTS "${TOOLCHAIN_DIR}")
    message(
      STATUS
        "Downloading ARM toolchain for ${CMAKE_HOST_SYSTEM_NAME} ${HOST_ARCH}..."
    )
    get_filename_component(ARCHIVE_NAME "${TOOLCHAIN_URL}" NAME)
    file(DOWNLOAD "${TOOLCHAIN_URL}" "${CMAKE_BINARY_DIR}/${ARCHIVE_NAME}"
         SHOW_PROGRESS)

    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
      file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/${TOOLCHAIN_FOLDER}")
      execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xf "${ARCHIVE_NAME}"
        WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/${TOOLCHAIN_FOLDER}")

    else()
      execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf "${ARCHIVE_NAME}"
                      WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")
    endif()

    file(REMOVE "${CMAKE_BINARY_DIR}/${ARCHIVE_NAME}")
  endif()

  set(C_COMPILER_PATH
      "${TOOLCHAIN_DIR}/bin/arm-none-eabi-gcc${EXECUTABLE_ENDING}")
  set(C_DEBUGGER_PATH
      "${TOOLCHAIN_DIR}/bin/arm-none-eabi-gdb${EXECUTABLE_ENDING}")
  set(ASM_COMPILER_PATH
      "${TOOLCHAIN_DIR}/bin/arm-none-eabi-gcc${EXECUTABLE_ENDING}")
  set(ASM_DEBUGGER_PATH
      "${TOOLCHAIN_DIR}/bin/arm-none-eabi-gdb${EXECUTABLE_ENDING}")
  set(CXX_COMPILER_PATH
      "${TOOLCHAIN_DIR}/bin/arm-none-eabi-g++${EXECUTABLE_ENDING}")
  set(CXX_DEBUGGER_PATH
      "${TOOLCHAIN_DIR}/bin/arm-none-eabi-gdb${EXECUTABLE_ENDING}")
  set(AR_PATH "${TOOLCHAIN_DIR}/bin/arm-none-eabi-gcc-ar${EXECUTABLE_ENDING}")
  set(RANLIB_PATH
      "${TOOLCHAIN_DIR}/bin/arm-none-eabi-gcc-ranlib${EXECUTABLE_ENDING}")
  set(OBJCOPY_PATH
      "${TOOLCHAIN_DIR}/bin/arm-none-eabi-objcopy${EXECUTABLE_ENDING}")
  set(SIZE_UTIL_PATH
      "${TOOLCHAIN_DIR}/bin/arm-none-eabi-size${EXECUTABLE_ENDING}")
endif()

# -------------------------------------------------------------------------------
# Set program paths for CMake
# -------------------------------------------------------------------------------

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
