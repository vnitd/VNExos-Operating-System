#ifndef _PRINT_H_
#define _PRINT_H_

#define LINE_SIZE 160

struct ScreenBuffer
{
	char *buffer;
	int	  column;
	int	  row;
};

#ifdef __cplusplus
extern "C"
#endif
	int
	printk(const char *format, ...);

#endif