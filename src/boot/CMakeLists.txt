project(boot)

VNExos_compile(${PROJECT_NAME}
    ASM_FILE boot_1st.asm
    ASM_FILE boot_2nd.asm
)

set(PROJECT_BIN ${PROJECT_NAME}.bin)

add_custom_command(
    OUTPUT ${PROJECT_BIN}
    COMMAND cat ${ASM_FILES} > ${GLOBAL_BIN_DIR}/${PROJECT_BIN}
    DEPENDS ${DEPENDENCE}
    COMMENT "[0m[97m[ [1mBIN    [0m[97m] [94mBuilt bin: [97mboot.bin"
)
VNExos_generate_target(${PROJECT_NAME}_bin DEPENDS ${PROJECT_BIN})
set(BOOT_DEPENDENCE ${PROJECT_NAME}_bin)
set(BOOT_BIN ${GLOBAL_BIN_DIR}/${PROJECT_BIN})

VNExos_add_to_disk(${BOOT_BIN}
    DEPENDS img ${BOOT_DEPENDENCE}
    ADDRESS 0
    SIZE 5
)
VNExos_generate_target(${PROJECT_NAME}_disk DEPENDS ${ADD_DEPENDENCE})
set(BOOT_DEPEND ${PROJECT_NAME}_disk PARENT_SCOPE)