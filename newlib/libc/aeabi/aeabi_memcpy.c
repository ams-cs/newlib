#include <string.h>
#include "aeabi.h"

/* Copy memory like memcpy, but no return value required.  */
#if defined(__ARM_NEON__)
  void __attribute__((naked))
  __aeabi_memcpy (void *dest, const void *src, size_t n)
  {
    asm("fmrx	r3, fpscr\n\t"
        "push	{r3, lr}\n\t"
        "vpush	{d0-d7}\n\t"
        "vpush	{d16-d31}\n\t"
        "bl	memcpy\n\t"
        "vpop	{d16-d31}\n\t"
        "vpop	{d0-d7}\n\t"
        "pop	{r3, lr}\n\t"
        "fmxr	fpscr, r3\n\t"
        "bx	lr");
  }
#else
  void
  __aeabi_memcpy (void *dest, const void *src, size_t n)
  {
    memcpy (dest, src, n);
  }
#endif

/* Versions of the above which may assume memory alignment.  */
strong_alias (__aeabi_memcpy, __aeabi_memcpy4)
strong_alias (__aeabi_memcpy, __aeabi_memcpy8)
