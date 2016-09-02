#include <string.h>
#include "aeabi.h"

/* Set memory like memset, but different argument order and no return
   value required.  */
#if defined(__ARM_NEON__)
  void __attribute__((naked))
  __aeabi_memset (void *dest, size_t n, int c)
  {
    asm("fmrx	r3, fpscr\n\t"
        "push	{r3, lr}\n\t"
        "vpush	{d0-d7}\n\t"
        "vpush	{d16-d31}\n\t"
        "mov	r3, r1\n\t"
        "mov	r1, r2\n\t"
        "mov	r2, r3\n\t"
        "bl	memset\n\t"
        "vpop	{d16-d31}\n\t"
        "vpop	{d0-d7}\n\t"
        "pop	{r3, lr}\n\t"
        "fmxr	fpscr, r3\n\t"
        "bx	lr");
  }
#else
  void
  __aeabi_memset (void *dest, size_t n, int c)
  {
    memset (dest, c, n);
  }
#endif

/* Versions of the above which may assume memory alignment.  */
strong_alias (__aeabi_memset, __aeabi_memset4)
strong_alias (__aeabi_memset, __aeabi_memset8)
