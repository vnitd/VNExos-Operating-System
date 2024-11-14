#include "debug.h"
#include "print.h"

void error_check(char *file, uint64_t line)
{
	printk("\n========================================");
	printk("\n              ERROR CHECK");
	printk("\n========================================\n");
	printk("Assertion failed [%s:%u]", file, line);

	while (1)
		;
}
