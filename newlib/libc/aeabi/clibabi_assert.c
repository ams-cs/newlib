#include <assert.h>
#include "hidden.h"

HIDDEN void
__aeabi_assert (const char *expr, const char *file, int line)
{
  __assert (file, line, expr);
}
