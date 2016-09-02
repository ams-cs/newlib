/* A generator program for tables for ctype.h "is*" functions, compatible with
   ARM's C-library ABI.  Newlib's existing tables can't be used as-is, because
   the bitmasks used have a layout incompatible with ARM's definition.  */

#include <ctype.h>

#define A	1	/* Alphabetic.  */
#define X	2	/* A-F a-f 0-9. */
#define P	4	/* Punctuation.  */
#define B	8	/* Printable blank.  */
#define S	16	/* Whitespace.  */
#define L	32	/* Lower case letter.  */
#define U	64	/* Upper case letter.  */
#define C	128	/* Control chars.  */

int
main (char *argv[], int argc)
{
  unsigned int i;

  puts (
"/* The following tables can't be aliased directly with Newlib's __ctype_ptr,");
  puts (
"   because the bitmasks used (although similar) are not identical to those");
  puts (
"   defined by ARM's C-library ABI.\n");
  puts (
"   This file can be regenerated using the clibabi_ctype-gen.c program.  */\n");

  puts ("#include \"hidden.h\"");
  puts ("#include \"aeabi.h\"\n");
  
  puts ("const unsigned char __aeabi_ctype_table_C[257] HIDDEN =");
  puts ("{");

  puts ("  0,");

  for (i = 0; i < 256; i++)
    {
      unsigned int bits;
      
      bits = isalpha (i) ? A : 0;
      bits |= isxdigit (i) ? X : 0;
      bits |= ispunct (i) ? P : 0;
      bits |= isblank (i) ? B : 0;
      bits |= isspace (i) ? S : 0;
      bits |= islower (i) ? L : 0;
      bits |= isupper (i) ? U : 0;
      bits |= iscntrl (i) ? C : 0;
      
      printf ("%s0x%.2x%s%c", ((i & 7) == 0) ? "  " : "", bits,
	      (i != 255) ? "," : "", ((i & 7) == 7) ? '\n' : ' ');
    }

  puts ("};\n");
  
  puts ("strong_alias (__aeabi_ctype_table_C, __aeabi_ctype_table_) HIDDEN;");
  
  return 0;
}
