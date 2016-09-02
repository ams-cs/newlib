#include <locale.h>
#include "hidden.h"

struct __aeabi_lconv
{
  char *decimal_point;
  char *thousands_sep;
  char *grouping;
  char *int_curr_symbol;
  char *currency_symbol;
  char *mon_decimal_point;
  char *mon_thousands_sep;
  char *mon_grouping;
  char *positive_sign;
  char *negative_sign;
  char int_frac_digits;
  char frac_digits;
  char p_cs_precedes;
  char p_sep_by_space;
  char n_cs_precedes;
  char n_sep_by_space;
  char p_sign_posn;
  char n_sign_posn;
  
  /* The following fields are added by C99.  */
  char int_p_cs_precedes;
  char int_n_cs_precedes;
  char int_p_sep_by_space;
  char int_n_sep_by_space;
  char int_p_sign_posn;
  char int_n_sign_posn;
};

HIDDEN struct __aeabi_lconv *
__aeabi_localeconv (void)
{
  static struct __aeabi_lconv a;
  struct lconv *l;
  
  l = localeconv ();
  
  /* The first fields of __aeabi_lconv and lconv are the same, but the former
     is bigger because of the (unsupported in Newlib) C99 fields.  */
  memset ((void*) &a, '\0', sizeof (a));
  memcpy ((void*) &a, (void*) l,
          (sizeof (a) < sizeof (*l)) ? sizeof (a) : sizeof (*l));

  return &a;
}

const int __aeabi_LC_COLLATE HIDDEN = LC_COLLATE;
const int __aeabi_LC_CTYPE HIDDEN = LC_CTYPE;
const int __aeabi_LC_MONETARY HIDDEN = LC_MONETARY;
const int __aeabi_LC_NUMERIC HIDDEN = LC_NUMERIC;
const int __aeabi_LC_TIME HIDDEN = LC_TIME;
const int __aeabi_LC_ALL HIDDEN = LC_ALL;
