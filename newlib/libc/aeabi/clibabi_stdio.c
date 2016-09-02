#include <stdio.h>
#include "aeabi.h"
#include "hidden.h"

FILE *__aeabi_stdin HIDDEN;
FILE *__aeabi_stdout HIDDEN;
FILE *__aeabi_stderr HIDDEN;

static void __attribute__ ((used))
setup_aeabi_stdio (void)
{
  __aeabi_stdin = stdin;
  __aeabi_stdout = stdout;
  __aeabi_stderr = stderr;
}

static void (*fp) (void) __attribute__ ((used, section (".preinit_array")))
  = setup_aeabi_stdio;

const int __aeabi_IOFBF HIDDEN = _IOFBF;
const int __aeabi_IOLBF HIDDEN = _IOLBF;
const int __aeabi_IONBF HIDDEN = _IONBF;

const int __aeabi_BUFSIZ HIDDEN = BUFSIZ;

const int __aeabi_FOPEN_MAX HIDDEN = FOPEN_MAX;

const int __aeabi_TMP_MAX HIDDEN = TMP_MAX;

const int __aeabi_FILENAME_MAX HIDDEN = FILENAME_MAX;
const int __aeabi_L_tmpnam HIDDEN = L_tmpnam;
