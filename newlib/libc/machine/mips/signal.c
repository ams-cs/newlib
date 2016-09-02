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
 * signals.c: POSIX-like signal handling
 */


#include <stdio.h>
#include <machine/signal.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <mips/cpu.h>
#include <mips/xcpt.h>

/*
 * Signal properties and actions.
 * The array below categorises the signals and their default actions
 * according to the following properties:
 */
#define	SA_KILL		0x01		/* terminates process by default */
#define	SA_IGNORE	0x02		/* ignore by default */
#define	SA_CANTMASK	0x04		/* non-maskable, catchable */
#define	SA_ABORT	0x08		/* trap into monitor */

static const unsigned char sigprop[NSIG + 1] = {
	0,			/* unused */
	SA_KILL,		/* SIGHUP */
	SA_KILL,		/* SIGINT */
	SA_KILL|SA_ABORT,	/* SIGQUIT */
	SA_KILL|SA_ABORT,	/* SIGILL */
	SA_KILL|SA_ABORT,	/* SIGTRAP */
	SA_KILL|SA_ABORT,	/* SIGABRT */
	SA_KILL|SA_ABORT,	/* SIGEMT */
	SA_KILL|SA_ABORT,	/* SIGFPE */
	SA_KILL,		/* SIGKILL */
	SA_KILL|SA_ABORT,	/* SIGBUS */
	SA_KILL|SA_ABORT,	/* SIGSEGV */
	SA_KILL|SA_ABORT,	/* SIGSYS */
	SA_KILL,		/* SIGPIPE */
	SA_KILL,		/* SIGALRM */
	SA_KILL,		/* SIGTERM */
	SA_IGNORE,		/* SIGURG */
	0,			/* SIGSTOP */
	0,			/* SIGTSTP */
	SA_IGNORE,		/* SIGCONT */
	SA_IGNORE,		/* SIGCHLD */
	0,			/* SIGTTIN */
	0,			/* SIGTTOU */
	SA_IGNORE,		/* SIGIO */
	SA_KILL,		/* SIGXCPU */
	SA_KILL,		/* SIGXFSZ */
	SA_KILL,		/* SIGVTALRM */
	SA_KILL,		/* SIGPROF */
	SA_IGNORE,		/* SIGWINCH  */
	SA_IGNORE,		/* SIGINFO */
	SA_KILL,		/* SIGUSR1 */
	SA_KILL,		/* SIGUSR2 */
};

#define sigset(s)	((sigset_t)1 << ((s)-1))
#define	sigcantmask	(sigset(SIGKILL)|sigset(SIGSTOP))
#define	sigignore	(sigset(SIGURG)|sigset(SIGCONT)|sigset(SIGCHLD)\
			 |sigset(SIGIO)|sigset(SIGWINCH)|sigset(SIGINFO))

static struct sigaction sigtab[NSIG];
static int	sigsuspended;
static sigset_t	sigpend = 0;
static sigset_t	sigign = sigignore;
static sigset_t	sigcatch = 0;
static sigset_t sigmasks = 0;
static sigset_t sigsuspmask;

static int	issig (void);
static void	psig (int sig, struct xcptcontext *xcp);

/* This variable is shared with tty.c */
volatile int	 _sig_interrupt_syscall  __attribute__ ((weak));

/*
 * Install a signal handler (POSIX style).
 */
int
sigaction (int sig, const struct sigaction *nsa, struct sigaction *osa)
{
    int sr;
    sigset_t bit;
    
    if (sig <= 0 || sig >= NSIG || sig == SIGKILL || sig == SIGSTOP) {
	errno = EINVAL;
	return -1;
    }

    if (osa)
	*osa = sigtab[sig];

    if (!nsa)
	return 0;

    bit = sigset (sig);

    sr = _mips_intdisable ();
    sigtab[sig].sa_handler = nsa->sa_handler;
    sigtab[sig].sa_mask = nsa->sa_mask &~ sigcantmask;
    sigtab[sig].sa_flags = nsa->sa_flags;

    /*
     * Set bit in ignore for signals that are set to SIG_IGN,
     * and for signals set to SIG_DFL where the default is to ignore.
     */
    if (nsa->sa_handler == SIG_IGN ||
	(sigprop[sig] & SA_IGNORE && nsa->sa_handler == SIG_DFL)) {
	sigpend &= ~bit;		/* never to be seen again */
	sigcatch &= ~bit;
	sigign |= bit;
    } else {
	sigign &= ~bit;
	if (nsa->sa_handler == SIG_DFL)
	    sigcatch &= ~bit;
	else 
	    sigcatch |= bit;
    }

    _xcpt_sigcatch (sig, sigcatch & bit);
    _mips_intrestore (sr);
    return 0;
}


/*
 * Install a signal handler (old-fashioned style).
 */
void (*signal (int sig, void (*handler) (int))) (int) 
{
    struct sigaction nsa, osa;
    nsa.sa_handler = handler;
    sigemptyset (&nsa.sa_mask);
    nsa.sa_flags = 0;
    if (sigaction (sig, &nsa, &osa) < 0)
	return SIG_ERR;
    return osa.sa_handler;
}


/*
 * Fatal signal handler.
 */
static void
sigexit (struct xcptcontext *xcp, int sig)
{
#if 0
    extern const char * const sys_siglist[];
#endif
    extern int _ram_based;

    if (xcp /*&& sig != SIGKILL*/)
	xcpt_show (xcp);
#if 0
    if (sig != 0)
	_mon_printf ("Signal: %s\r\n",
		     (sig > 0 && sig < NSIG) ? sys_siglist[sig]
		     : "bad signal number");
#endif
    if ((sig < 0 || sig >= NSIG || (sigprop[sig] & SA_ABORT))
        && _ram_based && sig != SIGABRT) {
	/* allow monitor to catch and then gdb can trace back */
	_xcpt_sigcatch (SIGILL, 0);
	abort ();
    }
    _exit (sig << 8);
}


/* 
 * When this function gets called on an exception stack
 * (which with xcptlowb.s will also be the "user" stack),
 * it arranges a call to the specified signal handler
 * by building a stack frame on the user stack that
 * will allow us to pick up the pieces if the signal handler 
 * returns.
 */

/* magic number to check for in saved stack frame */
#define SIG_MAGIC	0x7003301

/* function to catch end of signal function (via syscall) */
static void sig_restore (struct xcptcontext *);

/* previous syscall handler */
static struct xcptaction sigret_osys;


static void
sendsig (struct sigaction *sa, int sig, sigset_t returnmask, 
	 struct xcptcontext *xcp)
{
    extern void _sigtramp (void);
    struct xcptcontext sigctx;
    struct xcptcontext *scp;

    /* if this is a non-restarting signal, indicate to any slow
       system call that it should now be terminate. */
    if (!(sa->sa_flags & SA_RESTART))
	_sig_interrupt_syscall = 1;

    if (!xcp) {
	/* not called at exception level, do it the simple way! */
	(*sa->sa_sigaction) (sig, NULL, NULL);
	sigmasks = returnmask;
	return;
    }

    /* 
     * Copy the current exception context onto the user stack
     */
    if (XCP_USRSTACK (xcp)) {
	/* we're also running on the user stack, so just use the
	   context in our local stack frame. */
	scp = &sigctx;
    }
    else {
	/* we're on a different stack: allocate a new context just
	   below the user's current stack pointer */
	scp = (struct xcptcontext *) 
	    (((long)xcp->regs[29] - sizeof (struct xcptcontext)) & ~15);
    }

    if (!IS_KVA01 (scp))
	/* $sp is not sensible */
	sigexit (xcp, sig);

    /* save current xception context, and flag saved copy */
    memcpy ((void *)scp, xcp, sizeof(struct xcptcontext));
    scp->xclass = SIG_MAGIC;	/* paranoia check */
    scp->vaddr = returnmask;	/* remember signal mask */

    /* 
     * Now arrange that the current exception frame returns
     * to the signal trampoline, which will in turn call the
     * signal handler whose address is in $a2.
     */
    xcp->regs[4]  = sig;			/* a0 = signo */
    xcp->regs[5]  = VA_TO_REG (scp);		/* a1 = scp */
    xcp->regs[6]  = VA_TO_REG (sa->sa_handler);	/* a2 = sig handler */
    xcp->regs[7]  = VA_TO_REG (sig_restore);	/* a3 = sig cleanup */
#if _MIPS_SIM==_ABIO32
    xcp->regs[29] = VA_TO_REG (scp) - 16;	/* sp = scp - argsave */
#elif _MIPS_SIM==_ABIO64
    xcp->regs[29] = VA_TO_REG (scp) - 32;	/* sp = scp - argsave */
#elif _MIPS_SIM==_ABIN32 || _MIPS_SIM==_ABI64 || _MIPS_SIM==_ABIEABI
    xcp->regs[29] = VA_TO_REG (scp) - 0;	/* sp = scp - argsave */
#else
#error unknown abi
#endif
    xcp->regs[31] = 0;				/* ra = 0 (stops backtrace) */
    xcp->epc      = VA_TO_REG (_sigtramp);	/* pc = trampoline */
}


/* 
 * Implement the return from a signal handler.  Called from _sigtramp
 * after the user handler returns - note that we are now on the user
 * stack.
 */
static void
sig_restore (struct xcptcontext *scp)
{
    /* check that we've still got a valid signalreturn frame */
    if (scp->xclass != SIG_MAGIC)
	sigexit (scp, SIGKILL);
    scp->xclass = 0;

    /* restore previous signal mask */
    sigmasks = scp->vaddr;	

    /* return from *original* exception */
    xcptrestore (scp);
}


int ffsll (long long int arg);

static int
issig ()
{

    int sr = _mips_intdisable ();
    unsigned sig;
    sigset_t mask;

    for (;;) {
	mask = sigpend &~ sigmasks;
	if (mask == 0) {
	    _mips_intrestore (sr);
	    return (0);
	}
	if (sizeof (mask) <= sizeof (int))
	    sig = ffs (mask);
	else
	    sig = (ffsll (mask));
	mask = sigset (sig);
	if (!(mask & sigign)) {
	    _mips_intrestore (sr);
	    return (sig);
	}
	sigpend &= ~mask;
    }
}

static void
psig (int sig, struct xcptcontext *xcp)
{
    struct sigaction *sa = &sigtab[sig];
    int mask, returnmask;
    int sr;

    mask = sigset (sig);
    sr = _mips_intdisable ();
    sigpend &= ~mask;
    if (sa->sa_handler == SIG_DFL) {
	/* ignorable signals have been ignored in issig() */
	sigexit (xcp, sig);
    } else {
	if (sigsuspended) {
	    returnmask = sigsuspmask;
	    sigsuspended = 0;
	} else
	  returnmask = sigmasks;
	sigmasks |= sa->sa_mask | mask;
	sendsig (sa, sig, returnmask, xcp);
    }
}


void
_sig_deliver (struct xcptcontext *xcp)
{
    int sig;
    if ((sig = issig ()))
	psig (sig, xcp);
}


void
_sig_raise (pid_t pgrp, int sig, struct xcptcontext *xcp)
{
    sigset_t bit;

    if (sig <= 0 || sig >= NSIG)
	sigexit (xcp, sig);	/* fatal error */
    
    bit = sigset (sig);
    if (sigign & bit)
	return;

    sigpend |= bit;
    if ((sigmasks & bit) || xcp)
	return;

    while ((sig = issig ()))
	psig (sig, 0);
}



/*
 * POSIX style signal mask manipulation functions 
 */

int
sigprocmask (int op, const sigset_t *nmask, sigset_t *omask)
{
    extern int errno;
    int rv = 0;

    if (omask)
	*omask = sigmasks;

    if (nmask) {
	int sr = _mips_intdisable ();

	switch (op) {
	case SIG_BLOCK:
	    sigmasks |= *nmask &~ sigcantmask;
	    break;
	case SIG_UNBLOCK:
	    sigmasks &= ~*nmask;
	    break;
	case SIG_SETMASK:
	    sigmasks = *nmask &~ sigcantmask;
	    break;
	default:
	    errno = EINVAL;
	    rv = -1;
	    break;
	}
#define XCPTSYS 8
	if (sigret_osys.xa_handler && op == SIG_SETMASK) {
	    /* XXX guess that this is a longjmp and clear the sigreturn catch */
	    xcptaction (XCPTSYS, &sigret_osys, 0);
	    sigret_osys.xa_handler = 0;
	}

	_mips_intrestore (sr);

	if (rv == 0) {
	    int sig;
	    while ((sig = issig ()))
		psig (sig, 0);
	}
    }

    return rv;
}


int
sigpending (sigset_t *pending)
{
    *pending = sigpend;
    return 0;
}

__attribute__ ((common)) void (*__scandevs) (void);

int
sigsuspend (const sigset_t *nmask)
{
    int sr = _mips_intdisable ();
    extern int errno;
    int sig;

    sigsuspmask = sigmasks;
    sigmasks = *nmask & ~sigcantmask;
    sigsuspended = 1;
    _mips_intrestore (sr);

    while (sigsuspended) {
	if (__scandevs)
	    __scandevs ();
	if ((sig = issig ()))
	    psig (sig, 0);
    }

    errno = EINTR;
    return -1;
}	


int
raise (int sig)
{
    if (sig <= 0 || sig >= NSIG) {
	extern int errno;
	errno = EINVAL;
	return -1;
    }
    
    _sig_raise (0, sig, 0);
    return 0;
}
