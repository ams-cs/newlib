#include <setjmp.h>
#include "hidden.h"

/* __aeabi_JMP_BUF_SIZE is measured in 8-byte double-words.  This
   definition accommodates systems where _JBTYPE is larger than a
   word.  */

const int __aeabi_JMP_BUF_SIZE HIDDEN =
#ifndef _JBTYPE
  /* _JBLEN measures 4-byte words.  */
  (_JBLEN + 1) / 2;
#else
  ((sizeof (jmp_buf) + 7) & ~7) / (8 / sizeof (_JBTYPE));
#endif
