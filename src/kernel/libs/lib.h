#ifndef _LIB_H_
#define _LIB_H_

#ifdef __cplusplus
extern "C"
{
#endif
    void memset(void *buffer, char value, int size);
    void memmov(void *dst, void *src, int size);
    void memcpy(void *dst, void *src, int size);
    int  memcmp(void *src1, void *src2, int size);
#ifdef __cplusplus
}
#endif

#endif // !_LIB_H_