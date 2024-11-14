include(${CMAKE_CURRENT_SOURCE_DIR}/libs/asm.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/libs/c_cpp.cmake)

set(TARGET_MESSAGES OFF)

function(VNExos_compile project_name)
    set(CURRENT_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})
    set(CURRENT_BIN_DIR ${CMAKE_BINARY_DIR}/${project_name})

    set(options LINKER)
    set(single_args)
    set(multi_args ASM_FILE C_FILE CPP_FILE)
    cmake_parse_arguments(ARG "${options}" "${single_args}" "${multi_args}" ${ARGN})
    
    file(MAKE_DIRECTORY ${CURRENT_BIN_DIR})

    set(dependencies)

    set(asm_files)
    set(c_files)
    set(cpp_files)

    if(ARG_LINKER)
        set(ASM_ELF_FLAG elf64)
    endif()

    if(ARG_ASM_FILE)
        foreach(asm_file IN LISTS ARG_ASM_FILE)
            VNExos_compile_asm(
                SOURCE_FILE     ${asm_file}
                CURRENT_SRC_DIR ${CURRENT_SRC_DIR}
                CURRENT_BIN_DIR ${CURRENT_BIN_DIR}
                FORMAT ${ASM_ELF_FLAG}
            )
            list(APPEND asm_files ${BIN_FILE})
        endforeach()
        set(ASM_FILES ${asm_files} PARENT_SCOPE)
        list(APPEND dependencies ${project_name}_asm)
    endif()
    if(ARG_C_FILE)
        foreach(c_file IN LISTS ARG_C_FILE)
            VNExos_compile_c(
                SOURCE_FILE     ${c_file}
                CURRENT_SRC_DIR ${CURRENT_SRC_DIR}
                CURRENT_BIN_DIR ${CURRENT_BIN_DIR}
            )
            list(APPEND c_files ${BIN_FILE})
        endforeach()
        set(C_FILES ${c_files} PARENT_SCOPE)
        list(APPEND dependencies ${project_name}_c)
    endif()
    if(ARG_CPP_FILE)
        foreach(cpp_file IN LISTS ARG_CPP_FILE)
            VNExos_compile_cpp(
                SOURCE_FILE     ${cpp_file}
                CURRENT_SRC_DIR ${CURRENT_SRC_DIR}
                CURRENT_BIN_DIR ${CURRENT_BIN_DIR}
            )
            list(APPEND cpp_files ${BIN_FILE})
        endforeach()
        set(CPP_FILES ${cpp_files} PARENT_SCOPE)
        list(APPEND ${project_name}_cpp)
    endif()
    VNExos_generate_target(${project_name}_objects DEPENDS ${asm_files} ${c_files} ${cpp_files})
    set(DEPENDENCE ${project_name}_objects PARENT_SCOPE)
    set(RESULT_FILES ${asm_files} ${c_files} ${cpp_files} PARENT_SCOPE)
endfunction()