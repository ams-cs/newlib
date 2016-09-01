/* Copyright (c) 2009 CodeSourcery, Inc.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of CodeSourcery nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY CODESOURCERY, INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL CODESOURCERY BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
/*
 * Copyright (c) 1996-2006 MIPS Technologies, Inc.
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

/*
 * rint.S: maths library
 */

	
#if !defined(__SOFT_FLOAT) && !defined(__SINGLE_FLOAT)

#include <mips/asm.h>
#include <mips/regdef.h>

	.set	nomips16

#undef use_gp64
#if ((__mipsfp64 || __mips_fpr == 64) && __mips >= 3 && __mips != 32)
#define use_gp64 1
#else	
#define use_gp64 0
#endif
		
	.rdata
b52:	/* 2^52 */
	.dword	0x4330000000000000

	.text
	.align	2

LEAF(rint)
	.set noreorder
	l.d	$f4,b52
	abs.d	$f2,$f12
	c.olt.d	$f2,$f4			/* if |arg| >= 2^52 || Nan */
#if __mipsfp64 || __mips_fpr == 64
# if use_gp64
	dmfc1	t0,$f12
# elif __mips == 32 && __mips_isa_rev >= 2
	mfhc1	t0,$f12			/* high-order word */ 
	mfc1	t1,$f12			/* low-order word */ 
# else	
#  error cannot handle 64-bit fpr	
# endif 
#else /* __mips_fpr != 64 */
	mfc1	t0,$f13			/* high-order word */ 
	mfc1	t1,$f12			/* low-order word */ 
#endif
	bc1f	9f			/* then done */
	mov.d	$f0,$f12		/* BDSLOT: return (arg) */

	bgez	t0,2f			/* if arg < 0, negate result */
#if use_gp64
	dsll	t0,1			/* BDSLOT: drop sign */
#else
	sll	t0,1			/* BDSLOT: drop sign */
#endif

	/* negative arg */
	beqz	t0,3f			/* if exp+mhi == 0  (could be -0) */
	nop

	/* negative arg */
1:	sub.d	$f0,$f12,$f4		/* bias */
	b	9f
	add.d	$f0,$f4			/* unbias */

	/* positive arg */
2:	add.d	$f0,$f12,$f4		/* bias */
	b	9f
	sub.d	$f0,$f4			/* unbias */

3:	
#if ! use_gp64
	/* may be -0: check low order word */
	bnez	t1,1b			/* non-zero: normal -ve arg */
	nop				/* else return -0 */
#endif

9:	j	ra
	nop
	.set reorder
	END(rint)

#endif /* !__SOFT_FLOAT */
