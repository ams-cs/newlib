/* These "functions" can't be defined directly from C.  */

	.macro sigfn name val
	.global __aeabi_\name
	.hidden __aeabi_\name
	.type __aeabi_\name, function
	.set __aeabi_\name, \val
	.endm
	
	sigfn SIG_DFL, 0
	sigfn SIG_IGN, 1
	sigfn SIG_ERR, -1
