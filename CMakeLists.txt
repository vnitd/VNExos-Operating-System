# minimum required
cmake_minimum_required(VERSION 3.20)

# setup paths
set(CONFIG_DIR  ${CMAKE_SOURCE_DIR}/configs)
set(LIBRARY_DIR ${CMAKE_SOURCE_DIR}/libs)

# include configs
include(${CONFIG_DIR}/settings.cmake)
include(${CONFIG_DIR}/common.cmake)

# setup project
project(VNExos VERSION 0.1 LANGUAGES C CXX ASM DESCRIPTION "Vietnam Operating System")

# include libs
include(${LIBRARY_DIR}/target.cmake)
include(${LIBRARY_DIR}/compile.cmake)
include(${LIBRARY_DIR}/linker.cmake)
include(${LIBRARY_DIR}/disks.cmake)

# create neccessary folder
file(MAKE_DIRECTORY ${GLOBAL_BIN_DIR})
file(MAKE_DIRECTORY ${GLOBAL_TMP_DIR})

# create img file
VNExos_generate_img_file(${PROJECT_NAME}_v${PROJECT_VERSION}.img)
VNExos_generate_target(img DEPENDS ${IMG_FILE})

add_subdirectory(src)

# VNExos_convert_to_iso(${PROJECT_NAME}_v${PROJECT_VERSION}.iso DEPENDS src)
# VNExos_generate_target(root ALL DEPENDS ${ISO_DEPENDENCE})
VNExos_generate_target(root ALL DEPENDS src)
