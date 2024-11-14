add_subdirectory(kernel)
add_subdirectory(boot)

VNExos_generate_target(src DEPENDS ${BOOT_DEPEND} ${KERNEL_DEPEND})
