/*
 * Copyright (c) 2004-2006 MIPS Technologies, Inc.
 * 
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 *      * Redistributions of source code must retain the above copyright
 *        notice, this list of conditions and the following disclaimer.
 *      * Redistributions in binary form must reproduce the above
 *      copyright
 *        notice, this list of conditions and the following disclaimer
 *        in the documentation and/or other materials provided with
 *        the distribution.
 *      * Neither the name of MIPS Technologies Inc. nor the names of its
 *        contributors may be used to endorse or promote products derived
 *        from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/* ffsll.c : stdlib function.  */

extern int ffs (int);

#define CNTBITS(shift)			\
    do {				\
      int __s = shift; 			\
      if (bits << (64 - (shift)) != 0)	\
  	__s = 0;			\
      cnt += __s; 			\
      bits >>= __s;			\
    } while (0)


__attribute__ ((nomips16))
int
ffsll (long long int arg)
{
#if __mips == 64 
  int lz;
  asm ("dclz %0,%1" : "=d" (lz) : "d" (arg & -arg));
  return 64 - lz;
#elif __mips64
  unsigned long long int bits = arg;
  int cnt;
  if (bits == 0)
    return 0;
  cnt = 1;
  /* unrolled loop */
  CNTBITS(32);
  CNTBITS(16);
  CNTBITS(8);
  CNTBITS(4);
  CNTBITS(2);
  CNTBITS(1);
  return cnt;
#else /* ! __mips64 */
  if (arg == 0)
    return 0;
  if ((int) arg != 0)
    return ffs ((int) arg);
  return 32 + ffs ((int) (arg >> 32));
#endif
}

#if _MIPS_SZLONG == 64
int
ffsl (long int arg)
{
    return ffsll ((long long int)arg);
}
#endif
