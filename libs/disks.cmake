function(VNExos_generate_img_file file_name)
    add_custom_command(
        OUTPUT  ${file_name}
        COMMAND dd if=/dev/zero of=${CMAKE_SOURCE_DIR}/${file_name} bs=512 count=20160
        COMMENT "[0m[97m[ [1m[96mIMG    [0m[97m] [94mGenerated img file: [97m${file_name}"
    )
    set(IMG_FILE ${file_name} PARENT_SCOPE)
endfunction()

function(VNExos_add_to_disk file)
    set(options)
    set(single_args ADDRESS SIZE)
    set(multi_args DEPENDS)
    cmake_parse_arguments(ARG "${options}" "${single_args}" "${multi_args}" ${ARGN})

    if(NOT ARG_DEPENDS)
        message(FATAL_ERROR "DEPENDS argument is required.")
    endif()

    if(NOT ARG_ADDRESS)
        set(ARG_ADDRESS 0)
    endif()

    if(NOT ARG_SIZE)
        set(ARG_SIZE 0)
    endif()

    add_custom_command(
        OUTPUT  add_${file}
        COMMAND dd if=${file} of=${CMAKE_SOURCE_DIR}/${IMG_FILE} count=${ARG_SIZE} seek=${ARG_ADDRESS} bs=512 conv=notrunc
        DEPENDS ${ARG_DEPENDS}
        COMMENT "[0m[97m[ [1m[96mIMG    [0m[97m] [94mAdded [95m${file}[94m into [97m${IMG_FILE}"
    )
    set(ADD_DEPENDENCE add_${file} PARENT_SCOPE)
endfunction()

function(VNExos_convert_to_iso file)
    set(options)
    set(single_args)
    set(multi_args DEPENDS)
    cmake_parse_arguments(ARG "${options}" "${single_args}" "${multi_args}" ${ARGN})

    if(NOT ARG_DEPENDS)
        message(FATAL_ERROR "DEPENDS argument is required.")
    endif()

    add_custom_command(
        OUTPUT  mk_iso_folder
        COMMAND mkdir ./iso && cp ${CMAKE_SOURCE_DIR}/${IMG_FILE} ./iso/bin && mkisofs -b bin -o ${CMAKE_SOURCE_DIR}/${file} ./iso && rm -rf ./iso
        DEPENDS ${ARG_DEPENDS}
        COMMENT "[0m[97m[ [1m[96mISO    [0m[97m] [94mMade iso [95m${file}"
    )
    set(ISO_DEPENDENCE mk_iso_folder PARENT_SCOPE)
endfunction()