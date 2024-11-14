function(VNExos_kernel_linker)
    set(options)
    set(single_args)
    set(multi_args SOURCE_FILES)
    cmake_parse_arguments(ARG "${options}" "${single_args}" "${multi_args}" ${ARGN})

    if(NOT ARG_SOURCE_FILES)
        message(FATAL_ERROR "SOURCE_FILES is required.")
    endif()

    set(CURRENT_BIN_DIR ${CMAKE_BINARY_DIR}/${project_name})
    set(result_files)

    set(tmp_file ${GLOBAL_TMP_DIR}/${PROJECT_NAME}.o)
    set(bin_file ${GLOBAL_BIN_DIR}/${PROJECT_NAME}.bin)

    add_custom_command(
        OUTPUT  ${tmp_file}
        COMMAND ${LD_COMMAND} ${LD_FLAGS} -T ${CMAKE_CURRENT_SOURCE_DIR}/${LD_SCRIPT} -o ${tmp_file} ${ARG_SOURCE_FILES}
        DEPENDS ${ARG_SOURCE_FILES}
        COMMENT "[0m[97m[ [1m[92mLINKER [0m[97m] [94mBuilt object: ${tmp_file}"
    )
    add_custom_command(
        OUTPUT  ${bin_file}
        COMMAND ${OBJCP_COMMAND} -O binary ${tmp_file} ${bin_file}
        DEPENDS ${tmp_file}
        COMMENT "[0m[97m[ [1mBIN    [0m[97m] [94mBuilt bin: [97m${bin_file}"
    )

    set(result_file ${bin_file})
    set(BIN_FILE ${result_file} PARENT_SCOPE)
endfunction()

