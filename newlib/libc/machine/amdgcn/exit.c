/*
 * Support file for amdgcn in newlib.
 * Copyright (c) 2014-2017 Mentor Graphics.
 *
 * The authors hereby grant permission to use, copy, modify, distribute,
 * and license this software and its documentation for any purpose, provided
 * that existing copyright notices are retained in all copies and that this
 * notice is included verbatim in any distributions. No written agreement,
 * license, or royalty fee is required for any of the authorized uses.
 * Modifications to this software may be copyrighted by their authors
 * and need not follow the licensing terms described here, provided that
 * the new terms are clearly indicated on the first page of each file where
 * they apply.
 */

#include <stdlib.h>

void __attribute__((noreturn))
exit (int val)
{
  /* Write the exit value to the conventional place.  */
  int *return_value;
  asm ("s_load_dwordx2	%0, s[8:9], 16 glc\n\t"
       "s_waitcnt	0" : "=Sg"(return_value));
  *return_value = val;

  /* Terminate the current kernel.  */
  asm ("s_dcache_wb");
  asm ("s_endpgm");
  __builtin_unreachable();
}
