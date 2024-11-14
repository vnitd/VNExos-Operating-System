function(VNExos_compile_c)
    set(options)
    set(single_args SOURCE_FILE CURRENT_SRC_DIR CURRENT_BIN_DIR)
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
    
    if(file_ext STREQUAL ".c" OR file_ext STREQUAL ".C")
        set(c_file ${ARG_CURRENT_SRC_DIR}/${ARG_SOURCE_FILE})
        set(bin_file ${BIN_DIRECTION}/${file_name}.o)

        add_custom_command(
            OUTPUT  ${bin_file}
            COMMAND ${C_COMMAND} ${C_FLAGS} -I${ARG_CURRENT_SRC_DIR} -o ${bin_file} -c ${c_file}
            DEPENDS ${c_file}
            COMMENT "[0m[97m[ [1m[91mC      [0m[97m] [94mBuilt object: ${bin_file}"
        )

        set(result_files ${bin_file})
    else()
        message(FATAL_ERROR "Accept `.c` extension only.")
    endif()
    set(BIN_FILE ${result_files} PARENT_SCOPE)
endfunction()

function(VNExos_compile_cpp)
    set(options)
    set(single_args SOURCE_FILE CURRENT_SRC_DIR CURRENT_BIN_DIR)
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
    
    if(file_ext STREQUAL ".cpp" OR file_ext STREQUAL ".CPP"
        OR file_ext STREQUAL ".cxx" OR file_ext STREQUAL ".CXX"
        OR file_ext STREQUAL ".cc" OR file_ext STREQUAL ".CC")
        set(cpp_file ${ARG_CURRENT_SRC_DIR}/${ARG_SOURCE_FILE})
        set(bin_file ${BIN_DIRECTION}/${file_name}.o)

        add_custom_command(
            OUTPUT  ${bin_file}
            COMMAND ${CPP_COMMAND} ${CPP_FLAGS} -I${ARG_CURRENT_SRC_DIR} -o ${bin_file} -c ${cpp_file}
            DEPENDS ${cpp_file}
            COMMENT "[0m[97m[ [1m[91mCPP    [0m[97m] [94mBuilt object: ${bin_file}"
        )

        set(result_files ${bin_file})
    else()
        message(FATAL_ERROR "Accept `.c`, `.cxx` or `.cc` extensions only.")
    endif()
    set(BIN_FILE ${result_files} PARENT_SCOPE)
endfunction()

