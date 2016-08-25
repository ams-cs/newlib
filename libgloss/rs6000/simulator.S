/*
 * simulator.S -- PowerPC simulator system calls.
 *
 * Copyright (c) 1995, 2000, 2001 Cygnus Support
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

#include "ppc-asm.h"

FUNC_START(_exit)
#ifdef __VLE__
	.section .text_vle
	se_li	r0, 1
	se_sc
#else
	li	r0, 1
	sc
#endif

/*
 * Insure that the debugger tells the client that the PC is in _exit,
 * not whatever function happens to follow this function.
 */

0:	trap
#ifdef __VLE__
	se_b	0b			/* we never should return, but... */
#else
	b	0b			/* we never should return, but... */
#endif
FUNC_END(_exit)

FUNC_START(read)
#ifdef __VLE__
	se_li	r0,3
	se_sc
	se_bns 0f
	e_b	FUNC_NAME(_cerror)
0:	se_blr
#else
	li	r0,3
	sc
	bnslr+
	b	FUNC_NAME(_cerror)
#endif
FUNC_END(read)

FUNC_START(write)
#ifdef __VLE__
	se_li	r0,4
	se_sc
	se_bns 0f
	e_b	FUNC_NAME(_cerror)
0:	se_blr
#else
	li	r0,4
	sc
	bnslr+
	b	FUNC_NAME(_cerror)
#endif
FUNC_END(write)

FUNC_START(open)
#ifdef __VLE__
	se_li	r0,5
	se_sc
	se_bns 0f
	e_b	FUNC_NAME(_cerror)
0:	se_blr
#else
	li	r0,5
	sc
	bnslr+
	b	FUNC_NAME(_cerror)
#endif
FUNC_END(open)

FUNC_START(close)
#ifdef __VLE__
	se_li	r0,6
	se_sc
	se_bns 0f
	e_b	FUNC_NAME(_cerror)
0:	se_blr
#else
	li	r0,6
	sc
	bnslr+
	b	FUNC_NAME(_cerror)
#endif
FUNC_END(close)

FUNC_START(brk)
#ifdef __VLE__
	se_li	r0,17
	se_sc
	se_bns 0f
	e_b	FUNC_NAME(_cerror)
0:	se_blr
#else
	li	r0,17
	sc
	bnslr+
	b	FUNC_NAME(_cerror)
#endif
FUNC_END(brk)

FUNC_START(access)
#ifdef __VLE__
	se_li	r0,33
	se_sc
	se_bns 0f
	e_b	FUNC_NAME(_cerror)
0:	se_blr
#else
	li	r0,33
	sc
	bnslr+
	b	FUNC_NAME(_cerror)
#endif
FUNC_END(access)

FUNC_START(dup)
#ifdef __VLE__
	se_li	r0,41
	se_sc
	se_bns 0f
	e_b	FUNC_NAME(_cerror)
0:	se_blr
#else
	li	r0,41
	sc
	bnslr+
	b	FUNC_NAME(_cerror)
#endif
FUNC_END(dup)

FUNC_START(gettimeofday)
#ifdef __VLE__
	se_li	r0,116
	se_sc
	se_bns	0f
	e_b	FUNC_NAME(_cerror)
0:	se_blr
#else
	li	r0,116
	sc
	bns+	0f
	b	FUNC_NAME(_cerror)
0:	blr
#endif
FUNC_END(gettimeofday)

FUNC_START(lseek)
#ifdef __VLE__
	e_li	r0,199
	se_sc
	se_bns 0f
	e_b	FUNC_NAME(_cerror)
0:	se_blr
#else
	li	r0,199
	sc
	bnslr+
	b	FUNC_NAME(_cerror)
#endif
FUNC_END(lseek)
