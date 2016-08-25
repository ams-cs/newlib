/*
 * crt0.S -- startup file for PowerPC systems.
 *
 * Copyright (c) 1995 Cygnus Support
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

	.file	"crt0.S"
	.section ".got2","aw"
	.align	2

.LCTOC1 = .+32768

	.extern	FUNC_NAME(atexit)
	.globl	FUNC_NAME(__atexit)
	.section ".sdata","aw"
	.align	2
FUNC_NAME(__atexit):			/* tell C's eabi-ctor's we have an atexit function */
	.long	FUNC_NAME(atexit)@fixup	/* and that it is to register __do_global_dtors */

	.section ".fixup","aw"
	.align	2
	.long	FUNC_NAME(__atexit)

	.section ".got2","aw"
.Ltable = .-.LCTOC1
	.long	.LCTOC1			/* address we think .LCTOC1 is loaded at */

.Lsbss_start = .-.LCTOC1
	.long	__sbss_start

.Lsbss_end = .-.LCTOC1
	.long	__sbss_end

.Lbss_start = .-.LCTOC1
	.long	__bss_start

.Lend = .-.LCTOC1
	.long	_end

.Lstack = .-.LCTOC1			/* stack address if set by user */
	.long	__stack

#ifdef __VLE__
	.section .text_vle
#else
	.text
#endif
.Lptr:
	.long .LCTOC1-.Laddr

	.globl	_start
	.type	_start,@function
#ifdef __VLE__
_start:
	se_bl	.Laddr			/* get current address */
.Laddr:
	se_mflr	r4			/* real address of .Laddr */
	e_lwz	r5,(.Lptr-.Laddr)(r4)	/* linker generated address of .LCTOC1 */
	se_add	r5,r4			/* correct to real pointer */
	e_lwz	r4,.Ltable(r5)		/* get linker's idea of where .Laddr is */
	se_subf	r4,r5			/* calculate difference between where linked and current */

	/* clear bss and sbss */
	e_lwz	r6,.Lbss_start(r5)	/* calculate beginning of the BSS */
	e_lwz	r7,.Lend(r5)		/* calculate end of the BSS */
	se_add	r6,r4			/* adjust pointers */
	se_add	r7,r4

	se_cmpl  r6,r7
	se_bt	cr0,.Ldone1

	subf	r8,r6,r7		/* number of bytes to zero */
	e_srwi	r0,r8,2			/* number of words to zero */
	se_mtctr	r0
	se_li	r0,0			/* zero to clear memory */
	e_add16i r6,r6,-4		/* adjust so we can use stwu */
.Lloop:
	e_stwu	r0,4(r6)		/* zero bss */
	e_bdnz	.Lloop

.Ldone1:

	e_lwz	r6,.Lsbss_start(r5)	/* calculate beginning of the SBSS */
	e_lwz	r7,.Lsbss_end(r5)	/* calculate end of the SBSS */
	se_add	r6,r4			/* adjust pointers */
	se_add	r7,r4

	se_cmpl  r6,r7
	se_bt	cr0, .Ldone

	subf	r8,r6,r7		/* number of bytes to zero */
	e_srwi	r0,r8,2			/* number of words to zero */
	se_mtctr r0
	se_li	r0,0			/* zero to clear memory */
	e_add16i r6,r6,-4		/* adjust so we can use stwu */
.Lloop2:
	e_stwu	r0,4(r6)		/* zero bss */
	e_bdnz	.Lloop2

.Ldone:

	e_lwz	r0,.Lstack(r5)		/* stack address or 0 */
	se_cmpli r0,0			/* equal to 0? */
/* check */
	se_bf	cr0,.Lnostack		/* use default stack if == 0 */
	se_mr	sp,r0			/* use user defined stack */

.Lnostack:
	/* set up initial stack frame */
	e_add16i sp,sp,-4		/* make sure we don't overwrite debug mem */
	e_lis	r0,0
	se_stw	r0,0(sp)		/* clear back chain */
	e_stwu	sp,-64(sp)		/* push another stack frame */

	/* Let her rip */
	e_bl	FUNC_NAME(main)

	/* return value from main is argument to exit */
	e_bl	FUNC_NAME(exit)
	trap

#else /* Not __VLE__ */

_start:
	bl	.Laddr			/* get current address */
.Laddr:
	mflr	r4			/* real address of .Laddr */
	lwz	r5,(.Lptr-.Laddr)(r4)	/* linker generated address of .LCTOC1 */
	add	r5,r5,r4		/* correct to real pointer */
	lwz	r4,.Ltable(r5)		/* get linker's idea of where .Laddr is */
	subf	r4,r4,r5		/* calculate difference between where linked and current */

	/* clear bss and sbss */
	lwz	r6,.Lbss_start(r5)	/* calculate beginning of the BSS */
	lwz	r7,.Lend(r5)		/* calculate end of the BSS */
	add	r6,r6,r4		/* adjust pointers */
	add	r7,r7,r4

	cmplw	1,r6,r7
	bc	4,4,.Ldone1

	subf	r8,r6,r7		/* number of bytes to zero */
	srwi	r9,r8,2			/* number of words to zero */
	mtctr	r9
	li	r0,0			/* zero to clear memory */
	addi	r6,r6,-4		/* adjust so we can use stwu */
.Lloop:
	stwu	r0,4(r6)		/* zero bss */
	bdnz	.Lloop

.Ldone1:

	lwz	r6,.Lsbss_start(r5)	/* calculate beginning of the SBSS */
	lwz	r7,.Lsbss_end(r5)	/* calculate end of the SBSS */
	add	r6,r6,r4		/* adjust pointers */
	add	r7,r7,r4

	cmplw	1,r6,r7
	bc	4,4,.Ldone

	subf	r8,r6,r7		/* number of bytes to zero */
	srwi	r9,r8,2			/* number of words to zero */
	mtctr	r9
	li	r0,0			/* zero to clear memory */
	addi	r6,r6,-4		/* adjust so we can use stwu */
.Lloop2:
	stwu	r0,4(r6)		/* zero bss */
	bdnz	.Lloop2

.Ldone:

	lwz	r0,.Lstack(r5)		/* stack address or 0 */
	cmplwi	1,r0,0			/* equal to 0? */
	bc	12,6,.Lnostack		/* use default stack if == 0 */
	mr	sp,r0			/* use user defined stack */

.Lnostack:
	/* set up initial stack frame */
	addi	sp,sp,-4		/* make sure we don't overwrite debug mem */
	lis	r0,0
	stw	r0,0(sp)		/* clear back chain */
	stwu	sp,-64(sp)		/* push another stack frame */

	/* Let her rip */
	bl	FUNC_NAME(main)

	/* return value from main is argument to exit */
	bl	FUNC_NAME(exit)
	trap
#endif
.Lstart:
	.size	_start,.Lstart-_start
