## Process this file with automake to generate Makefile.in

AUTOMAKE_OPTIONS = cygnus

INCLUDES = $(NEWLIB_CFLAGS) $(CROSS_CFLAGS) $(TARGET_CFLAGS) -I$(newlib_basedir)/libc/machine/arm

AM_CCASFLAGS = $(INCLUDES)

noinst_LIBRARIES = lib.a

if MAY_SUPPLY_SYSCALLS
extra_objs = $(lpfx)libcfunc.o $(lpfx)trap.o $(lpfx)syscalls.o
else
extra_objs =
endif

if USE_LIBTOOL
noinst_LTLIBRARIES = libarm.la
EXTRA_libarm_la_SOURCES = trap.S syscalls.c libcfunc.c
noinst_DATA = objectlist.awk.in
else
lib_a_LIBADD = $(extra_objs)
EXTRA_lib_a_SOURCES = trap.S syscalls.c libcfunc.c
lib_a_DEPENDENCIES = $(extra_objs)
lib_a_CCASFLAGS = $(AM_CCASFLAGS)
lib_a_CFLAGS = $(AM_CFLAGS)
endif

if MAY_SUPPLY_SYSCALLS
all-local: crt0.o
endif

include $(srcdir)/../../../Makefile.shared

ACLOCAL_AMFLAGS = -I ../../.. -I ../../../..
CONFIG_STATUS_DEPENDENCIES = $(newlib_basedir)/configure.host
