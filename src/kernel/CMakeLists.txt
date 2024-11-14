project(kernel)

VNExos_compile(${PROJECT_NAME}
    LINKER
    ASM_FILE kernel.asm
    ASM_FILE trap.asm
    ASM_FILE libs/lib.asm
    C_FILE   trap.c
    C_FILE   print.c
    C_FILE   debug.c
    CPP_FILE core/mm/pmm.cpp
    CPP_FILE main.cpp
)

set(PROJECT_BIN ${PROJECT_NAME}.bin)

VNExos_kernel_linker(SOURCE_FILES ${RESULT_FILES})
VNExos_generate_target(${PROJECT_NAME}_bin DEPENDS ${BIN_FILE})

set(KERNEL_DEPENDENCE ${PROJECT_NAME}_bin)
set(KERNEL_BIN ${GLOBAL_BIN_DIR}/${PROJECT_BIN})

VNExos_add_to_disk(${KERNEL_BIN}
    DEPENDS img ${KERNEL_DEPENDENCE}
    ADDRESS 5
    SIZE 100
)
VNExos_generate_target(${PROJECT_NAME}_disk DEPENDS ${ADD_DEPENDENCE})
set(KERNEL_DEPEND ${PROJECT_NAME}_disk PARENT_SCOPE)