function(VNExos_compile_asm)
    set(options)
    set(single_args SOURCE_FILE CURRENT_SRC_DIR CURRENT_BIN_DIR FORMAT)
    set(multi_args)
    cmake_parse_arguments(ARG "${options}" "${single_args}" "${multi_args}" ${ARGN})

    if(NOT ARG_SOURCE_FILE)
        message(FATAL_ERROR "SOURCE_FILE is required.")
    endif()
    if(NOT ARG_CURRENT_SRC_DIR)
        message(FATAL_ERROR "CURRENT_SRC_DIR is required.")
    endif()
    if(NOT ARG_CURRENT_BIN_DIR)
        message(FATAL_ERROR "CURRENT_BIN_DIR is required.")
    endif()
    if(NOT ARG_FORMAT)
        set(ARG_FORMAT bin)
    endif()

    get_filename_component(file_ext ${ARG_SOURCE_FILE} LAST_EXT)
    get_filename_component(file_name ${ARG_SOURCE_FILE} NAME_WE)
    get_filename_component(file_dir ${ARG_SOURCE_FILE} DIRECTORY)

    if(file_dir)
        set(BIN_DIRECTION ${CURRENT_BIN_DIR}/${file_dir})
        file(MAKE_DIRECTORY ${BIN_DIRECTION})
    else()
        set(BIN_DIRECTION ${CURRENT_BIN_DIR})
    endif()

    set(result_files)
    
    if(file_ext STREQUAL ".asm" OR file_ext STREQUAL ".s" OR file_ext STREQUAL ".ASM" OR file_ext STREQUAL ".S")
        set(asm_file ${ARG_CURRENT_SRC_DIR}/${ARG_SOURCE_FILE})
        set(bin_file ${BIN_DIRECTION}/${file_name}.s.o)

        add_custom_command(
            OUTPUT  ${bin_file}
            COMMAND ${ASM_COMMAND} -f ${ARG_FORMAT} -o ${bin_file} ${asm_file}
            DEPENDS ${asm_file}
            COMMENT "[0m[97m[ [1m[30mASM    [0m[97m] [94mBuilt object: ${bin_file} [${ARG_FORMAT}]"
        )

        set(result_files ${bin_file})
    else()
        message(FATAL_ERROR "Accept `.asm` or `.s` extensions only.")
    endif()
    set(BIN_FILE ${result_files} PARENT_SCOPE)
endfunction()
