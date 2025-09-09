#ifndef __CORE_MM_PMM_H__
#define __CORE_MM_PMM_H__

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

typedef struct memmap_entry_t
{
    uint64_t base;
    uint64_t length;
    uint32_t type;
} __attribute__((packed)) memmap_entry;

typedef struct mem_free_t
{
    uint64_t address;
    uint64_t length;
} mem_free;

typedef struct mem_page_t
{
    mem_page_t *next;
} mem_page;

#define MEMMAP_SIZE_ADDR    0x9000
#define MEMMAP_ENTRIES_ADDR 0x9008

#define MEMMAP_USABLE                 1
#define MEMMAP_RESERVED               2
#define MEMMAP_ACPI_RECLAIMABLE       3
#define MEMMAP_ACPI_NVS               4
#define MEMMAP_BAD_MEMORY             5
#define MEMMAP_BOOTLOADER_RECLAIMABLE 0x1000
#define MEMMAP_KERNEL_AND_MODULES     0x1001
#define MEMMAP_FRAMEBUFFER            0x1002
#define MEMMAP_EFI_RECLAIMABLE        0x2000

#define PAGE_SIZE  (2 * 1024 * 1024)
#define PA_UP(v)   ((((uint64_t)v + PAGE_SIZE - 1) >> 21) << 21)
#define PA_DOWN(v) (((uint64_t)v >> 21) << 21)
#define P2V(p)     ((uint64_t)(p) + 0xffff800000000000)
#define V2P(v)     ((uint64_t)(v) - 0xffff800000000000)

typedef struct meminfo_t
{
    size_t uppermem;
    size_t lowermem;
} meminfo;

meminfo mmap_get_info(size_t mmap_count, memmap_entry *mmap);
void    print_memmap(memmap_entry *mm, size_t size);

memmap_entry *get_raw_memmap(size_t *entry_count);
void          init_memory(memmap_entry *mm, size_t size);

void *kalloc(void);
void  kfree(uint64_t v);

#endif // !__CORE_MM_PMM_H__