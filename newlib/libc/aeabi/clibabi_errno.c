#include <errno.h>
#include "aeabi.h"
#include "hidden.h"

HIDDEN volatile int *
__aeabi_errno_addr (void)
{
  return &errno;
}

strong_alias (__aeabi_errno_addr, __rt_errno_addr)

/* Link-time constants.  */

const int __aeabi_EDOM HIDDEN = EDOM;
const int __aeabi_ERANGE HIDDEN = ERANGE;
const int __aeabi_EILSEQ HIDDEN = EILSEQ;
