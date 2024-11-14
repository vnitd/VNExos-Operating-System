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

#define MEMMAP_SIZE_ADDR	0x9000
#define MEMMAP_ENTRIES_ADDR 0x9008

#define MEMMAP_USABLE				  1
#define MEMMAP_RESERVED				  2
#define MEMMAP_ACPI_RECLAIMABLE		  3
#define MEMMAP_ACPI_NVS				  4
#define MEMMAP_BAD_MEMORY			  5
#define MEMMAP_BOOTLOADER_RECLAIMABLE 0x1000
#define MEMMAP_KERNEL_AND_MODULES	  0x1001
#define MEMMAP_FRAMEBUFFER			  0x1002
#define MEMMAP_EFI_RECLAIMABLE		  0x2000

typedef struct meminfo_t
{
	size_t uppermem;
	size_t lowermem;
} meminfo;

meminfo mmap_get_info(size_t mmap_count, memmap_entry *mmap);
void	print_memmap(memmap_entry *mm, size_t size);

memmap_entry *get_raw_memmap(size_t *entry_count);

#endif // !__CORE_MM_PMM_H__