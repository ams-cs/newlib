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
 * Copyright (c) 1996-2007 MIPS Technologies, Inc.
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
 * drem.S: maths library
 */

	
#if !defined(__SOFT_FLOAT) && !defined(__SINGLE_FLOAT)

#include <mips/asm.h>
#include <mips/regdef.h>
#include <mips/fpa.h>
	
	.set	nomips16

#if (__mipsfp64 || __mips_fpr == 64) && __mips >= 3 && __mips != 32
	
#define USE64	
#define MSIGN		0x8000000000000000
#define MEXP		0x7ff0000000000000
#define M25		0x0190000000000000
#define M57		0x0390000000000000

#define rli		dli
#define raddu		daddu
#define rsubu		dsubu

#define gethi(gr,fr)	dmfc1	gr,fr
#define getlo(gr,fr)	dmfc1	gr,fr
#define puthi(gr,fr)	dmtc1	gr,fr
#define putlo(gr,fr)	dmtc1	gr,fr
#define savehi(fr)	
#define resthi(fr)	

#else

#define MSIGN		0x80000000
#define MEXP		0x7ff00000
#define M25		0x01900000
#define M57		0x03900000

#define rli		li
#define raddu		addu
#define rsubu		subu

#if (__mipsfp64 || __mips_fpr == 64) && __mips == 32 && __mips_isa_rev >= 2
#define USE64	
#define gethi(gr,fr)	mfhc1	gr,fr
#define getlo(gr,fr)	mfc1	gr,fr
#define puthi(gr,fr)	mthc1	gr,fr
#define putlo(gr,fr)	mtc1	gr,fr
#define savehi(fr)	gethi(THI,fr)
#define resthi(fr)	puthi(THI,fr)
#else	
#undef USE64	
#define gethi(gr,fr)	mfc1	gr,_ASMCONCAT(fr,_hi)
#define getlo(gr,fr)	mfc1	gr,_ASMCONCAT(fr,_lo)
#define puthi(gr,fr)	mtc1	gr,_ASMCONCAT(fr,_hi)
#define putlo(gr,fr)	mtc1	gr,_ASMCONCAT(fr,_lo)
#define savehi(fr)	
#define resthi(fr)	
#endif
	
#endif
		
	.text
	
#if  (defined _ABIN32 && _MIPS_SIM == _ABIN32) \
     || (defined _ABI64 && _MIPS_SIM == _ABI64)
#define y	$f13
#else
#define y	$f14
#endif
			
#define x	$f0
#define t	$f2
#define u	$f4
#define fzero	$f6
	
#ifndef USE64
#ifdef __STDC__	
#define $f0_lo	 $f0
#define $f0_hi	 $f1
#define $f2_lo	 $f2
#define $f2_hi	 $f3
#define $f4_lo	 $f4
#define $f4_hi	 $f5
#define $f6_lo	 $f6
#define $f6_hi	 $f7
#define $f8_lo	 $f8
#define $f8_hi	 $f9
#define $f10_lo	 $f10
#define $f10_hi	 $f11
#define $f12_lo	 $f12
#define $f12_hi	 $f13
#define $f14_lo	 $f14
#define $f14_hi	 $f15
#else
#define y_lo	 $f14
#define y_hi	 $f15
#define x_lo	 $f0
#define x_hi	 $f1
#define t_lo	 $f2
#define t_hi	 $f3
#define u_lo	 $f4
#define u_hi	 $f5
#define fzero_lo $f6
#define fzero_hi $f7
#endif	
#endif	
	
#define y1	$f8
#define n	$f10
#define tmp	$f12

#define xexp	t0
#define yexp	t1
#define nx	t2
#define nf	t3
#define sign	ta0
#define mexp	ta1
#define ofsr	ta2
#define nint	ta3
#define T1	v0
#define T2	v1
#define THI	t8

LEAF(drem)
	mov.d	x,$f12
	li.d	fzero,0.0
	
	c.eq.d	x,x
	bc1t	1f
	b	..ret

1:	c.eq.d	y,y
	bc1t	1f
	mov.d	x,y
	b	..ret

1:	gethi	(xexp,x)
	rli	T1,MSIGN
	rli	mexp,MEXP
	and	sign,xexp,T1
	and	xexp,mexp

	bne	xexp,mexp,1f
	div.d	x,fzero,fzero
	b	..ret

1:	c.eq.d	y,fzero
	bc1f	1f
	div.d	x,y,y
	b	..ret

	/* save old fsr; switch off INX enable & flag */
1:	cfc1	ofsr,$31
	and	T1,ofsr,~(FPA_CSR_INE_E | FPA_CSR_INE_S)
	.set	noreorder
	ctc1	T1,$31
	nop
	.set reorder

	gethi	(yexp,y)
	and	yexp,mexp
	move	nx,$0

	rli	T2,M57
	bnez	yexp,1f
	li.d	t,1.0
	gethi	(T1,t)
	raddu	T1,T2
	puthi	(T1,t)
	mul.d	y,t
	move	nx,T2

1:	bgt	yexp,T2,1f
	gethi	(T1,y)
	raddu	nx,T2
	raddu	T1,T2
	puthi	(T1,y)
	raddu	yexp,T2

1:	move	nf,nx
	abs.d	y,y
	abs.d	x,x
	
	mov.d	t,y
	getlo	(T1,t)
	savehi	(t)
	rli	T2,~0x07ffffff
	and	T1,T2
	putlo	(T1,t)
	resthi	(t)
	mov.d	y1,t

..loop:
	c.le.d	x,y
	bc1t	..endloop

	mov.d	t,y
	mov.d	u,y1
	gethi	(xexp,x)
	and	xexp,mexp
	
	rsubu	T1,xexp,yexp
	rli	T2,M25
	rsubu	T1,T2
	blez	T1,1f
	
	gethi	(T2,t)
	raddu	T2,T1
	puthi	(T2,t)

	gethi	(T2,u)
	raddu	T2,T1
	puthi	(T2,u)

1:	div.d	n,x,t
	trunc.w.d n,n,T1
	mfc1	nint,n
	cvt.d.w	n,n
	mul.d	tmp,n,u
	sub.d	x,tmp
	sub.d	tmp,t,u
	mul.d	tmp,n
	sub.d	x,tmp
	b	..loop
..endloop:

	beqz	nx,1f
	li.d	t,1.0
	gethi	(T1,t)
	raddu	T1,nx
	puthi	(T1,t)
	mul.d	x,t
	move	nx,$0
	b	..loop

1:	li.d	tmp,2.0
	div.d	tmp,y,tmp
	c.le.d	x,tmp
	bc1f	1f
	c.eq.d	x,tmp
	bc1f	2f
	and	nint,1
	beqz	nint,2f
1:	sub.d	x,y

2:	gethi	(T1,x)
	xor	T1,sign
	puthi	(T1,x)

	beqz	nf,1f
	li.d	t,1.0
	gethi	(T1,t)
	rsubu	T1,nf
	puthi	(T1,t)
	mul.d	x,t
1:
	/* restore fsr */
	.set noreorder
	ctc1	ofsr,$31
	nop
	.set reorder

..ret:	j	ra
	END(drem)

#endif /* !__SOFT_FLOAT */
