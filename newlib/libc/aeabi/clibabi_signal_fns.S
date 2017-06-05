/* These "functions" can't be defined directly from C.  */

	.macro sigfn name val
	.global __aeabi_\name
	.hidden __aeabi_\name
#if defined(CLANG_IAS)
	.type __aeabi_\name, %function
#else
	.type __aeabi_\name, function
#endif
	.set __aeabi_\name, \val
	.endm
	
	sigfn SIG_DFL, 0
	sigfn SIG_IGN, 1
	sigfn SIG_ERR, -1
