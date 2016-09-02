#include <string.h>
#include "aeabi.h"

/* Clear memory.  */
void
__aeabi_memclr (void *dest, size_t n)
{
  __aeabi_memset (dest, n, 0);
}

/* Versions of the above which may assume memory alignment.  */
strong_alias (__aeabi_memclr, __aeabi_memclr4)
strong_alias (__aeabi_memclr, __aeabi_memclr8)
