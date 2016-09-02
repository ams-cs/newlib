## Process this file with automake to generate Makefile.in

AUTOMAKE_OPTIONS = cygnus

INCLUDES = $(NEWLIB_CFLAGS) $(CROSS_CFLAGS) $(TARGET_CFLAGS)

LIB_SOURCES = aeabi_atexit.c aeabi_memclr.c aeabi_memcpy.c \
		aeabi_memmove.c aeabi_memset.c clibabi_assert.c \
		clibabi_ctype.c clibabi_errno.c clibabi_limits.c \
		clibabi_locale.c clibabi_math.c clibabi_setjmp.c \
		clibabi_signal.c clibabi_signal_fns.S clibabi_stdio.c \
		clibabi_stdlib.c clibabi_time.c
libaeabi_la_LDFLAGS = -Xcompiler -nostdlib

if USE_LIBTOOL
noinst_LTLIBRARIES = libaeabi.la
libaeabi_la_SOURCES = $(LIB_SOURCES)
noinst_DATA = objectlist.awk.in
else
noinst_LIBRARIES = lib.a
lib_a_SOURCES = $(LIB_SOURCES)
lib_a_CFLAGS = $(AM_CFLAGS)
lib_a_CCASFLAGS = $(AM_CCASFLAGS)
noinst_DATA =
endif # USE_LIBTOOL

include $(srcdir)/../../Makefile.shared

# No documentation for this subdirectory.
doc:

