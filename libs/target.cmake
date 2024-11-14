function(VNExos_generate_target target_name)
    set(options ALL)
    set(single_args)
    set(multi_args DEPENDS)
    cmake_parse_arguments(ARG "${options}" "${single_args}" "${multi_args}" ${ARGN})

    if(ARG_ALL)
        set(ARG_ALL ALL)
    else()
        set(ARG_ALL)
    endif()

    if(NOT ARG_DEPENDS)
        message(FATAL_ERROR "DEPENDS argument is required.")
    endif()

    add_custom_target(${target_name} ${ARG_ALL}
        DEPENDS ${ARG_DEPENDS}
        COMMENT "[0m[97m[ [1m[93mTARGET [0m[97m] [94mBuilt target: [93m${target_name}"
    )
endfunction()