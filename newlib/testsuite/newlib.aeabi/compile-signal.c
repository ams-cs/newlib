#undef _AEABI_PORTABILITY_LEVEL
#define _AEABI_PORTABILITY_LEVEL 1
#undef _AEABI_PORTABLE

#include <signal.h>

#ifndef _AEABI_PORTABLE
#error "AEABI not supported by signal.h"
#endif
