#include "stddef.h"
#include "stdint.h"

#include "debug.h"
#include "trap.h"

#include <core/mm/pmm.h>

#include "drivers/graphics/vesa.h"
#include "print.h"

extern "C" void KMain(void)
{
    init_idt();

    size_t        size = 0;
    memmap_entry *mmap = get_raw_memmap(&size);

    print_memmap(mmap, size);
    init_memory(mmap, size);
}
