set(CPU_FLAGS "-mthumb-interwork -mcpu=cortex-r5 -mfpu=vfpv3-d16 -marm -mfloat-abi=softfp")

include(${CMAKE_CURRENT_LIST_DIR}/../arm-none-eabi-gcc.cmake)
