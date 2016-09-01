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
 * sqrt.S: maths library
 */

	
#if !defined(__SOFT_FLOAT) && !defined(__SINGLE_FLOAT)

#include <mips/asm.h>
#include <mips/regdef.h>
#include <sys/errno.h>
#include "r3kc1.h"
	
	.weakext __sdethread_set_errno
	
	.set	nomips16
	
#if __mips >= 2
	
LEAF(sqrt)
	sqrt.d	$f0,$f12
	li	a0,EDOM
	c.eq.d	$f0,$f0
	bc1f	1f
	j	ra
1:	la	t0,__sdethread_set_errno
	beqz	t0,2f
	j	__sdethread_set_errno
2:	sw	a0,errno	
	j	ra
END(sqrt)
	
#else
	
	.sdata
	.align 3
b54:	
	/* 2**54 */
#if defined(MIPSEB) || defined(__MIPSEB__)
	.word	0x43500000
	.word	0x00000000
#else
	.word	0x00000000
	.word	0x43500000
#endif

	.rdata
	.align	2
table:
	.word 	0, 1204, 3062, 5746, 9193, 13348, 18162, 23592 
	.word	29598, 36145, 43202, 50740, 58733, 67158, 75992
	.word	85215, 83599, 71378, 60428, 50647, 41945, 34246
	.word	27478, 21581, 16499, 12183, 8588, 5674, 3403
	.word	1742, 661, 130

	.text
#define x	$f12
#define x_lo	$f12
#define x_hi	$f13

#define y	$f0
#define y_lo	$f0
#define y_hi	$f1

#define t	$f2
#define t_lo	$f2
#define t_hi	$f3

#define z	$f4
#define fzero	$f6
#define tmp	$f6

#define mx	t0
#define scalx	t1
#define mexp	t2
#define ofsr	t3
#define T1	t4
#define T2	t5
#define carry	t6

#ifdef TEST
#define sqrt	newsqrt
#endif

LEAF(sqrt)
	li.d	fzero,0.0

	/*mx=px[n0]&mexp;  get exponent */
	mfc1	T1,x_hi
	li	mexp,0x7ff00000
	and	mx,T1,mexp

	/* x == INF or NAN? */
	bne	mx,mexp,..isnum
	/* yes, but which */
	mfc1	T2,x_lo			/* get low part */
	and	mx,T1,~0xfff00000	/* mask off sign & exponent */
	or	mx,T2			/* combine high and low mantissa */
	bnez	mx,..retx		/* !=0:  NaN - return x */
	bltz	T1,..nan		/* <0:  -INF - return Nan */
	
..retx:	
	mov.d	y,x
	b 	..ret
	
..nan:	
	div.d	y,fzero,fzero
	li	a0,EDOM
	j	__sdethread_set_errno

..isnum:	
	/*if(x==0.0) return(x);  sqrt(+-0) = +-0 */
	c.eq.d	x,fzero
	bc1t	..retx

	/* if(x<0) return((x-x)/(x-x)); sqrt(negative) is invalid */
	c.lt.d	x,fzero
	bc1t	..nan
#undef fzero

	/* save old fsr; switch off INX enable & flag; set RN rounding */
1:	cfc1	ofsr,$31
	and	T1,ofsr,~(R3KC1_CSR_INE_E | R3KC1_CSR_INE_S | R3KC1_CSR_RND)
	/*or	T1,R3KC1_CSR_RN*/
	.set noreorder
	ctc1	T1,$31
	nop
	.set reorder

	move	scalx,$0

	/* subnormal number, scale up x to x*2**54 */
	bnez	mx,1f
	l.d	tmp,b54
	mul.d	x,tmp
	subu	scalx,0x01b00000
	
	/* scale x to avoid intermediate over/underflow:
	 * if (x > 2**512) x=x/2**512; if (x < 2**-512) x=x*2**512 */
	/* if(mx>0x5ff00000) {px[n0] -= 0x20000000; scalx+= 0x10000000;} */
1:	ble	mx,0x5ff00000,1f
	mfc1	T1,x_hi
	subu	T1,0x20000000
	mtc1	T1,x_hi
	addu	scalx,0x10000000

	/*if(mx<0x1ff00000) {px[n0] += 0x20000000; scalx-= 0x10000000;}*/
1:	bge	mx,0x1ff00000,1f
	mfc1	T1,x_hi
	addu	T1,0x20000000
	mtc1	T1,x_hi
	subu	scalx,0x10000000

	/* magic initial approximation to almost 8 sig. bits */
        /*py[n0]=(py[n0]>>1)+0x1ff80000;*/
1:	mov.d	y,x
	mfc1	T1,y_hi
	srl	T1,1
	addu	T1,0x1ff80000
	/* py[n0]=py[n0]-table[(py[n0]>>15)&31]; */
	srl	T2,T1,13
	and	T2,(31<<2)
	lw	T2,table(T2)
	subu	T1,T2		
	mtc1	T1,y_hi

	/* Heron's rule once with correction to improve to ~18 sig. bits */
	/* t=x/y; y=y+t; py[n0]=py[n0]-0x00100006; py[n1]=0; */
	div.d	t,x,y
	add.d	y,t
	mfc1	T1,y_hi
	subu	T1,0x00100006
	mtc1	T1,y_hi
	mtc1	$0,y_lo

	/* triple to almost 56 sig. bits: y ~= sqrt(x) to within 1 ulp */
	/* t=y*y; z=t;  pt[n0]+=0x00100000; t+=z; z=(x-z)*y; */
	mul.d	t,y,y
	mov.d	z,t
	mfc1	T1,t_hi
	addu	T1,0x00100000
	mtc1	T1,t_hi
	add.d	t,z
	sub.d	tmp,x,z
	mul.d	z,tmp,y

	/* t=z/(t+x) ;  pt[n0]+=0x00100000; y+=t; */
	add.d	tmp,t,x
	div.d	t,z,tmp
	mfc1	T1,t_hi
	addu	T1,0x00100000
	mtc1	T1,t_hi
	add.d	y,t

	/* twiddle last bit to force y correctly rounded */ 
	/* set RZ, clear INEX flag, restore INEX enable */
	and	T1,ofsr,~(R3KC1_CSR_INE_S | R3KC1_CSR_RND)
	or	T1,R3KC1_CSR_RZ
	.set noreorder
	ctc1	T1,$31
	nop
	.set reorder

	/* t=x/y; ...chopped quotient, possibly inexact */
	div.d	t,x,y

	/* get the inexact flag */
	cfc1	T1,$31
	and	T1,R3KC1_CSR_INE_S
	bnez	T1,..inexact

	/* EXACT */
	/* if (t == y) goto end */
	c.eq.d	t,y
	bc1t	..sqend

	/* t = t-ulp */
	mfc1	T1,t_lo
	subu	T2,T1,1
	mtc1	T2,t_lo
	sgtu	carry,T2,T1
	mfc1	T1,t_hi
	subu	T1,carry
	mtc1	T1,t_hi

..inexact:
	/* set INX (cause & flag) */
	or	ofsr,(R3KC1_CSR_INE_X | R3KC1_CSR_INE_S)

	/* get original rounding mode */
	and	T1,ofsr,R3KC1_CSR_RND
	beq	T1,R3KC1_CSR_RN,..bumpt
	bne	T1,R3KC1_CSR_RP,..nobump

	/* y=y+ulp; */
	mfc1	T1,y_lo
	addu	T2,T1,1
	mtc1	T2,y_lo
	sltu	carry,T2,T1
	mfc1	T1,y_hi
	addu	T1,carry
	mtc1	T1,y_hi

..bumpt:
	/* t=t+ulp; */
	mfc1	T1,t_lo
	addu	T2,T1,1
	mtc1	T2,t_lo
	sltu	carry,T2,T1
	mfc1	T1,t_hi
	addu	T1,carry
	mtc1	T1,t_hi

..nobump:	
	/* y=y+t; ...chopped sum */
	add.d	y,t

    	/* adjust scalx for correctly rounded sqrt(x) */
	subu	scalx,0x00100000

..sqend:
	/* py[n0]=py[n0]+scalx; ...scale back y */
	mfc1	T1,y_hi
	addu	T1,scalx
	mtc1	T1,y_hi

	/* restore rounding mode and possibly set inexact */
	.set noreorder
	ctc1	ofsr,$31
	nop
	.set reorder

..ret:	j	ra
	END(sqrt)
	
#endif /* __mips < 2 */
	
#endif /* !__SOFT_FLOAT */
