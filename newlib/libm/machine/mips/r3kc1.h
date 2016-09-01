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
 * Copyright (c) 1996-2003 MIPS Technologies, Inc.
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
 * r3kc1.h: maths library - r3000 fpa csr bits
 */

	
/* loads of csr values 
 */
#define R3KC1_CSR_COND	0x00800000

/*
 * X the exception indicator
 * E the exception enable
 * S the stick bit
*/
#define R3KC1_CSR_ALL_X 0x0003f000
#define R3KC1_CSR_UNI_X	0x00020000
#define R3KC1_CSR_INV_X	0x00010000
#define R3KC1_CSR_DIV_X	0x00008000
#define R3KC1_CSR_OVF_X	0x00004000
#define R3KC1_CSR_UDF_X	0x00002000
#define R3KC1_CSR_INE_X	0x00001000

#define R3KC1_CSR_ALL_E 0x00000f80
#define R3KC1_CSR_INV_E	0x00000800
#define R3KC1_CSR_DIV_E	0x00000400
#define R3KC1_CSR_OVF_E	0x00000200
#define R3KC1_CSR_UDF_E	0x00000100
#define R3KC1_CSR_INE_E	0x00000080

#define R3KC1_CSR_ALL_S 0x0000007c
#define R3KC1_CSR_INV_S	0x00000040
#define R3KC1_CSR_DIV_S	0x00000020
#define R3KC1_CSR_OVF_S	0x00000010
#define R3KC1_CSR_UDF_S	0x00000008
#define R3KC1_CSR_INE_S	0x00000004

/* rounding mode */
#define R3KC1_CSR_RN	0x0	/* nearest */
#define R3KC1_CSR_RZ	0x1	/* towards zero */
#define R3KC1_CSR_RP	0x2	/* towards +Infinity */
#define R3KC1_CSR_RM	0x3	/* towards -Infinity */
#define R3KC1_CSR_RND	0x3	/* mask */
