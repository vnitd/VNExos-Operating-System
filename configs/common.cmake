set(GLOBAL_BIN_DIR ${CMAKE_BINARY_DIR}/bin)
set(GLOBAL_TMP_DIR ${CMAKE_BINARY_DIR}/tmp)

set(ASM_COMMAND    "nasm")

set(C_COMMAND      "gcc")
set(C_FLAGS        "-std=c17" "-mcmodel=large" "-ffreestanding" "-fno-stack-protector" "-mno-red-zone")

set(CPP_COMMAND    "g++")
set(CPP_FLAGS      "-std=c++17" "-mcmodel=large" "-ffreestanding" "-fno-stack-protector" "-mno-red-zone")

set(LD_COMMAND     "ld")
set(LD_FLAGS       "")
set(LD_SCRIPT      "linker.ld")
set(OBJCP_COMMAND  "objcopy")
