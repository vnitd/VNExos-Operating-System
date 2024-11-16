#include "pmm.h"
#include <debug.h>
#include <print.h>

#define memmap_max_entries ((size_t)0xffff)

memmap_entry memmap[memmap_max_entries];
size_t		 memmap_entries = 0;

static void pmm_insert_entry(memmap_entry *m, size_t count, size_t index, memmap_entry *s)
{
	memmap_entry entry = *s;
	memmap_entry tmp_entry = *s;
	for (size_t i = index; i < count; i++)
	{
		tmp_entry = m[i];
		m[i] = entry;
		entry = tmp_entry;
	}
}

static bool pmm_new_entry(memmap_entry *m, size_t *count, uint64_t base, uint64_t length, uint32_t type)
{
	uint64_t top = base + length;

	for (size_t i = 0; i < *count; i++)
	{
		uint64_t entry_base = m[i].base;
		uint64_t entry_top = m[i].base + m[i].length;
		uint32_t entry_type = m[i].type;

		// lay in the middle and top of entry
		if (base > entry_base && base + length <= entry_top)
		{
			ASSERT((*count) + 1 < memmap_max_entries);

			m[i].length = base - entry_base;
			memmap_entry memmap = {base, length, type};
			pmm_insert_entry(m, ++(*count), ++i, &memmap);
			if (base + length < entry_top)
			{
				memmap = {base + length, entry_top - base - length, entry_type};
				pmm_insert_entry(m, ++(*count), ++i, &memmap);
			}
			return true;
		}
		// lay in the bottom of entry or whole of the entry
		if (base == entry_base && base + length <= entry_top)
		{
			ASSERT((*count) + 1 < memmap_max_entries);
			m[i].length = length;
			m[i].type = type;
			if (base + length < entry_top)
			{
				memmap_entry memmap = {base + length, entry_top - base - length, entry_type};
				pmm_insert_entry(m, ++(*count), ++i, &memmap);
			}
			return true;
		}
	}
	return false;
}

meminfo mmap_get_info(size_t mmap_count, memmap_entry *mmap)
{
	meminfo info = {};

	for (size_t i = 0; i < mmap_count; i++)
	{
		if (mmap[i].type == MEMMAP_USABLE)
		{
			// NOTE: Upper memory starts at address 1MiB and the
			// value of uppermem is the address of the first upper memory
			// hole minus 1MiB.
			if (mmap[i].base < 0x100000)
			{
				if (mmap[i].base + mmap[i].length > 0x100000)
				{
					size_t low_len = 0x100000 - mmap[i].base;

					info.lowermem += low_len;
					info.uppermem += mmap[i].length - low_len;
				}
				else
				{
					info.lowermem += mmap[i].length;
				}
			}
			else
			{
				info.uppermem += mmap[i].length;
			}
		}
	}

	return info;
}

static const char *memmap_type(uint32_t type)
{
	switch (type)
	{
	case MEMMAP_USABLE:
		return "Usable RAM";
	case MEMMAP_RESERVED:
		return "Reserved";
	case MEMMAP_ACPI_RECLAIMABLE:
		return "ACPI reclaimable";
	case MEMMAP_ACPI_NVS:
		return "ACPI NVS";
	case MEMMAP_BAD_MEMORY:
		return "Bad memory";
	case MEMMAP_FRAMEBUFFER:
		return "Framebuffer";
	case MEMMAP_BOOTLOADER_RECLAIMABLE:
		return "Bootloader reclaimable";
	case MEMMAP_KERNEL_AND_MODULES:
		return "Kernel/Modules";
	case MEMMAP_EFI_RECLAIMABLE:
		return "EFI reclaimable";
	default:
		return "???";
	}
}

void print_memmap(memmap_entry *mm, size_t size)
{
	pmm_new_entry(mm, (size_t *)MEMMAP_SIZE_ADDR, 0x7c00, 0xa00, MEMMAP_BOOTLOADER_RECLAIMABLE);
	size += 2;

	uint64_t total = 0,
			 total_usable = 0;
	for (size_t i = 0; i < size; i++)
	{
		printk("[%x -> %x] : %x  <%s (%x)>\n",
			   mm[i].base,
			   mm[i].base + mm[i].length,
			   mm[i].length,
			   memmap_type(mm[i].type), mm[i].type);
		total += mm[i].length;
		if (mm[i].type == 1)
			total_usable += mm[i].length;
	}
	printk("Total memory: %uMB/%uMB", total_usable / 1024 / 1024, total / 1024 / 1024);
}

memmap_entry *get_raw_memmap(size_t *entry_count)
{
	*entry_count = *(size_t *)MEMMAP_SIZE_ADDR;
	return (memmap_entry *)MEMMAP_ENTRIES_ADDR;
}
