# File: coreutils.mms
#
# Quick and dirty Make file for building Coreutils on VMS
#
# This build procedure requires the following concealed rooted
# logical names to be set up.
# LCL_ROOT: This is a read/write directory for the build output.
# VMS_ROOT: This is a read only directory for VMS specific changes
#           that have not been checked into the official repository.
# SRC_ROOT: This is a read only directory containing the files in the
#           Offical repository.
# PRJ_ROOT: This is a search list of LCL_ROOT:,VMS_ROOT:,SRC_ROOT:
#
# Copyright 2013, John Malmberg
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
# OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
# 17-Aug-2013   J. Malmberg	First pass for coreutils
##############################################################################

crepository = /repo=sys$disk:[coreutils.cxx_repository]
cnames = /name=(as_i,shor)$(crepository)
cshow = /show=(EXPA,INC)
.ifdef __IA64__
clist = /list$(cshow)
.else
clist = /list/mach$(cshow)
.endif
.ifdef __VAX__
cprefix = /pref=all
.else
cprefix = /prefix=(all,exce=(strtoimax,strtoumax))
cfloat = /FLOAT=IEEE_FLOAT/IEEE_MODE=DENORM_RESULTS
.endif
#cnowarn1 = noparmlist,questcompare2,unusedtop,unknownmacro
#cnowarn2 = intconcastsgn,controlassign,exprnotused,unreachcode
#cnowarn = $(cnowarn1),$(cnowarn2)
#cwarn = /warnings=(disable=($(cnowarn)))
#cinc1 = prj_root:[],prj_root:[.include],prj_root:[.lib.intl],prj_root:[.lib.sh]
cinc2 = /nested=none
cinc = $(cinc2)
#cdefs = /define=(_USE_STD_STAT=1,_POSIX_EXIT=1,\
#	HAVE_STRING_H=1,HAVE_STDLIB_H=1,HAVE_CONFIG_H=1,SHELL=1)
.ifdef __VAX__
cdefs1 = _POSIX_EXIT=1,HAVE_CONFIG_H=1
cmain =
.else
cdefs1 = _USE_STD_STAT,_POSIX_EXIT=1,HAVE_CONFIG_H=1
cmain = /MAIN=POSIX_EXIT
.endif
cdefs = /define=($(cdefs1))$(cmain)
cflags = $(cnames)/debu$(clist)$(cprefix)$(cwarn)$(cinc)$(cdefs)$(cfloat)
cflagsx = $(cnames)/debu$(clist)$(cwarn)$(cinc2)$(cfloat)$(cmain)

EXEEXT = .exe

#
# TPU symbols
#===================

UNIX_2_VMS = /COMM=prj_root:[.vms]unix_c_to_vms_c.tpu

EVE = EDIT/TPU/SECT=EVE$SECTION/NODISP

.SUFFIXES
.SUFFIXES .exe .olb .obj .c .def

#.SUFFIXES .1 .c .dvi .html .log .o .obj .pl .pl$(EXEEXT) \
#	.ps .sed .sh .sh$(EXEEXT) .sin .x .xpl .xpl$(EXEEXT) .y

.obj.exe
   $(LINK)$(LFLAGS)/NODEBUG/EXE=$(MMS$TARGET)/DSF=$(MMS$TARGET_NAME)\
     /MAP=$(MMS$TARGET_NAME) $(MMS$SOURCE_LIST)

.c.obj
   $define/user glthread sys$disk:[.lib.glthread]
   $define/user selinux sys$disk:[.lib.selinux]
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

.obj.olb
   @ if f$search("$(MMS$TARGET)") .eqs. "" then \
	librarian/create/object $(MMS$TARGET)
   $ librarian/replace $(MMS$TARGET) $(MMS$SOURCE_LIST)

acl_internal_h = [.lib]acl-internal.h [.lib]acl.h [.lib]error.h \
	[.lib]quote.h

argmatch_h = [.lib]argmatch.h [.lib]verify.h

argv_iter_h = [.lib]argv-iter.h [.lib]arg-nonnull.h

bitrotate_h = [.lib]bitrotate.h [.lib]stdint.h

c_strcaseeq_h = [.lib]c-strcaseeq.h [.lib]c-strcase.h [.lib]c-ctype.h

chdir_long_h = [.lib]chdir-long.h [.lib]pathmax.h

cjk_h = [.lib.uniwidth]cjk.h [.lib]streq.h

cycle_check_h = [.lib]cycle-check.h [.lib]dev-ino.h [.lib]same-inode.h \
	[.lib]stdint.h

dirent___h = [.lib]dirent--.h [.lib]dirent-safer.h

dirname_h = [.lib]dirname.h [.lib]dosname.h

fcntl___h = [.lib]fcntl--.h [.lib]fcntl-safer.h

file_set_h = [.lib]file-set.h [.lib]hash.h

fpending_h = [.lib]fpending.h [.lib]stdio_ext.h

freadahead_h = [.lib]freadahead.h [.lib]stdio_ext.h

freading_h = [.lib]freading.h [.lib]stdio_ext.h

freadptr_h = [.lib]freadptr.h [.lib]stdio_ext.h

ftoastr_h = [.lib]ftoastr.h [.lib]intprops.h

# fts__h = [.lib]fts_.h [.lib]i-ring.h

fseterr_h = [.lib]fseterr.h [.lib]stdio_ext.h

fsusage_h = [.lib]fsusage.h [.lib]stdint.h

gethrxtime_h = [.lib]gethrxtime.h [.lib]xtime.h

getopt_int.h = [.lib]getopt_int.h [.lib]getopt.h

xstrtol_h = [.lib]xstrtol.h [.lib]getopt.h

human_h = [.lib]human.h [.lib]stdint.h $(xstrtol_h)

i_ring_h = [.lib]i-ring.h [.lib]verify.h

inttostr_h = [.lib]inttostr.h [.lib]intprops.h [.lib]stdint.h

malloca_h = [.lib]malloca.h [.lib]alloca.h

mbiter_h = [.lib]mbiter.h [.lib]mbchar.h

mbuiter_h = [.lib]mbuiter.h [.lib]mbchar.h [.lib]strnlen1.h

md5_h = [.lib]md5.h [.lib]stdint.h

# pipe_h = [.lib]pipe.h [.lib]spawn-pipe.h

# printf-parse_h = [.lib]printf-parse.h [.lib]printf-args.h

# Use VMS header
# pthread_h = [.lib]pthread.h [.lib]sched.h

rand_isaac_h = [.lib]rand-isaac.h [.lib]stdint.h

randint_h = [.lib]randint.h [.lib]randread.h [.lib]stdint.h

randperm_h = [.lib]randperm.h [.lib]randint.h

readtokens0_h = [.lib]readtokens0.h [.lib]obstack.h

readutmp_h = [.lib]readutmp.h [.lib]utmp.h

regex_internal_h = [.lib]regex_internal.h [.lib]stdint.h

root_dev_ino_h = [.lib]root-dev-ino.h [.lib]dev-ino.h [.lib]same-inode.h

sha1_h = [.lib]sha1.h [.lib]stdint.h

sha256_h = [.lib]sha256.h [.lib]stdint.h

u64_h = [.lib]u64.h [.lib]stdint.h

sha512_h = [.lib]sha512.h $(u64_h)

sig2str_h = [.lib]sig2str.h [.lib]intprops.h

size_max_h = [.lib]size_max.h [.lib]stdint.h

sockets_h = [.lib]sockets.h [.lib]msvc-nothrow.h

#spawn_h = [.lib]spawn.h [.lib]sched.h

stdio___h = [.lib]stdio--.h [.lib]stdio-safer.h

stdlib___h = [.lib]stdlib--.h [.lib]stdlib-safer.h

str_two_way_h = [.lib]str-two-way.h [.lib]stdint.h

strnumcmp_in_h = [.lib]strnumcmp-in.h [.lib]strnumcmp.h

termios_h = [.vms]termios.h [.vms]vms_term.h [.vms]bits_termios.h \
	[.vms]vms_terminal_io.h

unistd___h = [.lib]unistd--.h [.lib]unistd-safer.h

unistr_h = [.lib]unistr.h [.lib]unitypes.h [.lib]unused-parameter.h

verror.h = [.lib]verror.h [.lib]error.h

w32sock_h = [.lib]w32sock.h [.lib]msvc-nothrow.h

w32spawn_h = [.lib]w32spawn.h [.lib]msvc-nothrow.h [.lib]cloexec.h \
	[.lib]xalloc.h

xalloc_h = [.lib]xalloc.h [.lib]xalloc-oversized.h

xfts_h = [.lib]xfts.h $(fts__h)

xsize_h = [.lib]xsize.h [.lib]stdint.h

selinux_at_h = [.lib]selinux-at.h [.lib.selinux]context.h \
	[.lib.selinux]selinux.h

config_h = [.lib]config.h config_vms.h [.vms]vms_coreutils_hacks.h

anytostr_c = [.lib]anytostr.c $(config_h) $(inttostr_h)

at_func_c = [.lib]at-func.c [.lib]dosname.h [.lib]openat.h \
	[.lib]openat-priv.h [.lib]save-cwd.h $(config_h)

ftoastr_c = [.lib]ftoastr.c $(config_h) $(ftoastr_h)

fts_cycle_c = [.lib]fts-cycle.c $(cycle_check_h) [.lib]hash.h

full_write_c = [.lib]full-write.c $(config_h) [.lib]full-read.h \
	[.lib]full-write.h [.lib]safe-read.h [.lib]safe-write.h

float_plus_h = [.lib]float^+.h

isnan_c = lcl_root:[.lib]isnan.c $(config_h) [.lib]float_plus.h

printf_frexp_c = [.lib]printf-frexp.c $(config_h) \
	[.lib]printf-frexpl.h [.lib]printf-frexp.h [.lib]fpucw.h

safe_read_c = [.lib]safe-read.c $(config_h) [.lib]safe-write.h \
	[.lib]safe-read.h

strtoimax_c = [.lib]strtoimax.c $(config_h) [.lib]verify.h

true_c = [.src]true.c $(config_h) $(system_h)

# [.lib]grouping.h (optional)
#strtol_c = [.lib]strtol.c $(config_h)

xstrtol_c = [.lib]xstrtol.c $(config_h) $(xstrtol_h) [.lib]intprops.h

# se-linux only
#"se-context"=[.lib]se-context.obj,
#"se-selinux"=[.lib]se-selinux.obj,\

# VMS CRTL opendir is safe enough.
#"opendir-safer"=[.lib]opendir-safer.obj,\
#"freopen-safer"=[.lib]freopen-safer.obj,\
#"dup-safer"=[.lib]dup-safer.obj,\
#"open-safer"=[.lib]open-safer.obj,\
#
# spawn not used.
#		"spawn-pipe"=[.lib]spawn-pipe.obj,\
#

lib_libcoreutils_a_OBJECTS = \
		"set-mode-acl"=[.lib]set-mode-acl.obj,\
		"copy-acl"=[.lib]copy-acl.obj,\
		"file-has-acl"=[.lib]file-has-acl.obj,\
		"allocator"=[.lib]allocator.obj,\
		"areadlink"=[.lib]areadlink.obj,\
		"areadlink-with-size"=[.lib]areadlink-with-size.obj,\
		"areadlinkat"=[.lib]areadlinkat.obj,\
		"argmatch"=[.lib]argmatch.obj,\
		"argv-iter"=[.lib]argv-iter.obj,\
		"backupfile"=[.lib]backupfile.obj,\
		"base64"=[.lib]base64.obj,\
		"binary-io"=[.lib]binary-io.obj,\
		"bitrotate"=[.lib]bitrotate.obj,\
		"buffer-lcm"=[.lib]buffer-lcm.obj,\
		"c-ctype"=[.lib]c-ctype.obj,\
		"c-strcasecmp"=[.lib]c-strcasecmp.obj,\
		"c-strncasecmp"=[.lib]c-strncasecmp.obj,\
		"c-strtod"=[.lib]c-strtod.obj,\
		"c-strtold"=[.lib]c-strtold.obj,\
		"canon-host"=[.lib]canon-host.obj,\
		"canonicalize"=[.lib]canonicalize.obj,\
		"careadlinkat"=[.lib]careadlinkat.obj,\
		"cloexec"=[.lib]cloexec.obj,\
		"close-stream"=[.lib]close-stream.obj,\
		"closein"=[.lib]closein.obj,\
		"closeout"=[.lib]closeout.obj,\
		"md5"=[.lib]md5.obj,\
		"sha1"=[.lib]sha1.obj,\
		"sha256"=[.lib]sha256.obj,\
		"sha512"=[.lib]sha512.obj,\
		"cycle-check"=[.lib]cycle-check.obj,\
		"di-set"=[.lib]di-set.obj,\
		"diacrit"=[.lib]diacrit.obj,\
		"dirname"=[.lib]dirname.obj,\
		"basename"=[.lib]basename.obj,\
		"dirname-lgpl"=[.lib]dirname-lgpl.obj,\
		"basename-lgpl"=[.lib]basename-lgpl.obj,\
		"stripslash"=[.lib]stripslash.obj,\
		"dtoastr"=[.lib]dtoastr.obj,\
		"dtotimespec"=[.lib]dtotimespec.obj,\
		"exclude"=[.lib]exclude.obj,\
		"exitfail"=[.lib]exitfail.obj,\
		"error"=[.lib]error.obj,\
		"fadvise"=[.lib]fadvise.obj,\
		"fatal-signal"=[.lib]fatal-signal.obj,\
		"chmodat"=[.lib]chmodat.obj,\
		"chownat"=[.lib]chownat.obj,\
		"creat-safer"=[.lib]creat-safer.obj,\
		fd-hook=[.lib]fd-hook.obj,\
		"fd-reopen"=[.lib]fd-reopen.obj,\
		"fd-safer-flag"=[.lib]fd-safer-flag.obj,\
		"dup-safer-flag"=[.lib]dup-safer-flag.obj,\
		"fdutimensat"=[.lib]fdutimensat.obj,\
		"file-set"=[.lib]file-set.obj,\
		"file-type"=[.lib]file-type.obj,\
		"filemode"=[.lib]filemode.obj,\
		"filenamecat"=[.lib]filenamecat.obj,\
		"filenamecat-lgpl"=[.lib]filenamecat-lgpl.obj,\
		"filevercmp"=[.lib]filevercmp.obj,\
		"fopen-safer"=[.lib]fopen-safer.obj,\
		"fprintftime"=[.lib]fprintftime.obj,\
		"freading"=[.lib]freading.obj,\
		"freadseek"=[.lib]freadseek.obj,\
		"ftoaster"=[.lib]ftoastr.obj,\
		"full-read"=[.lib]full-read.obj,\
		"full-write"=[.lib]full-write.obj,\
		"gethrxtime"=[.lib]gethrxtime.obj,\
		"xtime"=[.lib]xtime.obj,\
		"getndelim2"=[.lib]getndelim2.obj,\
		"gettime"=[.lib]gettime.obj,\
		"getugroups"=[.lib]getugroups.obj,\
		"hard-locale"=[.lib]hard-locale.obj,\
		"hash"=[.lib]hash.obj,\
		"hash-pjw"=[.lib]hash-pjw.obj,\
		"hash-triple"=[.lib]hash-triple.obj,\
		"heap"=[.lib]heap.obj,\
		"human"=[.lib]human.obj,\
		"i-ring"=[.lib]i-ring.obj,\
		"idcache"=[.lib]idcache.obj,\
		"ino-map"=[.lib]ino-map.obj,\
		"imaxtostr"=[.lib]imaxtostr.obj,\
		"inttostr"=[.lib]inttostr.obj,\
		"offtostr"=[.lib]offtostr.obj,\
		"uinttostr"=[.lib]uinttostr.obj,\
		"umaxtostr"=[.lib]umaxtostr.obj,\
		"idtoastr"=[.lib]ldtoastr.obj,\
		"linebuffer"=[.lib]linebuffer.obj,\
		"localcharset"=[.lib]localcharset.obj,\
		"lock"=[.lib.glthread]lock.obj,\
		"long-options"=[.lib]long-options.obj,\
		"malloca"=[.lib]malloca.obj,\
		"math"=[.lib]math.obj,\
		"mbchar"=[.lib]mbchar.obj,\
		"mbiter"=[.lib]mbiter.obj,\
		"mbsalign"=[.lib]mbsalign.obj,\
		"mbscasecmp"=[.lib]mbscasecmp.obj,\
		"mbslen"=[.lib]mbslen.obj,\
		"mbsstr"=[.lib]mbsstr.obj,\
		"mbswidth"=[.lib]mbswidth.obj,\
		"mbuiter"=[.lib]mbuiter.obj,\
		"memcasecmp"=[.lib]memcasecmp.obj,\
		"memchr2"=[.lib]memchr2.obj,\
		"memcmp2"=[.lib]memcmp2.obj,\
		"memcoll"=[.lib]memcoll.obj,\
		"mgetgroups"=[.lib]mgetgroups.obj,\
		"mkancesdir"=[.lib]mkancesdirs.obj,\
		"dirchownmod"=[.lib]dirchownmod.obj,\
		"mkdir-p"=[.lib]mkdir-p.obj,\
		"modechange"=[.lib]modechange.obj,\
		"mpsort"=[.lib]mpsort.obj,\
		"nproc"=[.lib]nproc.obj,\
		"openat-die"=[.lib]openat-die.obj,\
		"openat-safer"=[.lib]openat-safer.obj,\
		"parse-datetime"= [.lib]parse-datetime.obj,\
		"physmem"=[.lib]physmem.obj,\
		"pipe2"=[.lib]pipe2.obj,\
		"pipe2-safer"=[.lib]pipe2-safer.obj,\
		"posixtm"=[.lib]posixtm.obj,\
		"posixver=[.lib]posixver.obj,\
		"printf-frexp"=[.lib]printf-frexp.obj,\
		"printf-frexpl"=[.lib]printf-frexpl.obj,\
		"priv-set"=[.lib]priv-set.obj,\
		"vms_progname"=[.lib]vms_progname.obj,\
		"propername"=[.lib]propername.obj,\
		"quotearg"=[.lib]quotearg.obj,\
		"randint"=[.lib]randint.obj,\
		"randperm"=[.lib]randperm.obj,\
		"randread"=[.lib]randread.obj,\
		"rand-isacc"=[.lib]rand-isaac.obj,\
		"read-file"=[.lib]read-file.obj,\
		"readtokens"=[.lib]readtokens.obj,\
		"readtokens0"=[.lib]readtokens0.obj,\
		"root-dev-ino"=[.lib]root-dev-ino.obj,\
		"safe-read"=[.lib]safe-read.obj,\
		"safe-write"=[.lib]safe-write.obj,\
		"same"=[.lib]same.obj,\
		"save-cwd"=[.lib]save-cwd.obj,\
		"savedir"=[.lib]savedir.obj,\
		"savewd"=[.lib]savewd.obj,\
		"settime"=[.lib]settime.obj,\
		"sig-handler"=[.lib]sig-handler.obj,\
		"sockets"=[.lib]sockets.obj,\
		"stat-time"=[.lib]stat-time.obj,\
		"statat"=[.lib]statat.obj,\
		"mkstemp-safer"=[.lib]mkstemp-safer.obj,\
		"striconv"=[.lib]striconv.obj,\
		"strftime"=[.lib]strftime.obj,\
		"strnlen1"=[.lib]strnlen1.obj,\
		"strintcmp"=[.lib]strintcmp.obj,\
		"strnucmp"=[.lib]strnumcmp.obj,\
		sys_socket=[.lib]sys_socket.obj,\
		"tempname"=[.lib]tempname.obj,\
		"threadlib"=[.lib.glthread]threadlib.obj,\
		"timespec"=[.lib]timespec.obj,\
		"tls"=[.lib.glthread]tls.obj,\
		"trim"=[.lib]trim.obj,\
		"u64"=[.lib]u64.obj,\
		"unicodeio"=[.lib]unicodeio.obj,\
		"unistd"=[.lib]unistd.obj,\
		"fd-safer"=[.lib]fd-safer.obj,\
		"pipe-safer"=[.lib]pipe-safer.obj,\
		"userspec"=[.lib]userspec.obj,\
		"utimecmp"=[.lib]utimecmp.obj,\
		"utimens"=[.lib]utimens.obj,\
		"verror"=[.lib]verror.obj,\
		"version-etc"=[.lib]version-etc.obj,\
		"version-etc-fsf"=[.lib]version-etc-fsf.obj,\
		"wait-process"=[.lib]wait-process.obj,\
		"wctype-h"=[.lib]wctype-h.obj,\
		"write-any-file"=[.lib]write-any-file.obj,\
		"xmalloc"=[.lib]xmalloc.obj,\
		"xalloc-die"=[.lib]xalloc-die.obj,\
		"xfreopen"=[.lib]xfreopen.obj,\
		"xfts"=[.lib]xfts.obj,\
		"xgetcwd"=[.lib]xgetcwd.obj,\
		"xgetgroups"=[.lib]xgetgroups.obj,\
		"xgethostname"=[.lib]xgethostname.obj,\
		"xmemcoll"=[.lib]xmemcoll.obj,\
		"xnanosleep"=[.lib]xnanosleep.obj,\
		"xprintf"=[.lib]xprintf.obj,\
		"xreadlink"=[.lib]xreadlink.obj,\
		"xsize"=[.lib]xsize.obj,\
		"xstriconv"=[.lib]xstriconv.obj,\
		"xstrndup"=[.lib]xstrndup.obj,\
		"xstrtod"=[.lib]xstrtod.obj,\
		"xtrtoimax"=[.lib]xstrtoimax.obj,\
		"xstrtol"=[.lib]xstrtol.obj,\
		"xstrtou"=[.lib]xstrtoul.obj,\
		"xstrtol-error"=[.lib]xstrtol-error.obj,\
		"xstrtold"=[.lib]xstrtold.obj,\
		"xstrtoumax"=[.lib]xstrtoumax.obj,\
		"xvasprintf"=[.lib]xvasprintf.obj,\
		"xasprintf"=[.lib]xasprintf.obj,\
		"yesno"=[.lib]yesno.obj

unistr_objs =	"u8-mbtoucr"=[.lib.unistr]u8-mbtoucr.obj,\
		"u8-uctomb"=[.lib.unistr]u8-uctomb.obj,\
		"u8-utcomb-aux"=[.lib.unistr]u8-uctomb-aux.obj

uniwidth_objs =	"width"=[.lib.uniwidth]width.obj


# Template routines, do not compile.
#	"anytostr"=[.lib]anytostr.obj,\
#	"at-func"=[.lib]at-func.obj,\
#	"fnmatch_loop"=[.lib]fnmatch_loop.obj,\
#	"fts-cycle"=[.lib]fts-cycle.obj,\
#	"isnan"=[.lib]isnan.obj,\
#	"regcomp"=[.lib]regcomp.obj,\
#	"regex_internal"=[.lib]regex_internal.obj,\
#	"regexec"=[.lib]regexec.obj,\

# Substituted with static routines or hacks.
#	"freadahead"=[.lib]freadahead.obj,\
#	"freadptr"=[.lib]freadptr.obj,\
#	"fseterr"=[.lib]fseterr.obj,\

# In the VMS crtl
#	"btowc"=[.lib]btowc.obj,\
#	"closedir"=[.lib]closedir.obj,\
#	"fchown-stub"=[.lib]fchown-stub.obj,\
#	"fseeko"=[.lib]fseeko.obj,\
#	"fsync"=[.lib]fsync.obj,\
#	"ftell"=[.lib]ftell.obj,\
#	"ftello"=[.lib]ftello.obj,\
#	"gai_strerror"=[.lib]gai_strerror.obj,\
#	"getaddrinfo"=[.lib]getaddrinfo.obj,\
#	"gettimeofday"=[.lib]gettimeofday.obj,\
#	"getcwd"=[.lib]getcwd.obj,\
#	"getcwd-lgpl"=[.lib]getcwd-lgpl.obj,\
#	"gethostname"=[.lib]gethostname.obj,\
#	"getlogin"=[.lib]getlogin.obj,\
#	"inet_ntop"=[.lib]inet_ntop.obj,\
#	"isapipe"=[.lib]isapipe.obj,\
#	"isatty"=[.lib]isatty.obj,\
#	"localeconv"=[.lib]localeconv.obj,\
#	"mbrlen"=[.lib]mbrlen.obj,\
#	"mbsinit"=[.lib]mbsinit.obj,\
#	"mbsrtowcs"=[.lib]mbsrtowcs.obj,\
#	"mbtowc"=[.lib]mbtowc.obj,\
#	"memchr"=[.lib]memchr.obj,\
#	"mkstemp"=[.lib]mkstemp.obj,\
#	"mktime"=[.lib]mktime.obj,\
#	"nanosleep"=[.lib]nanosleep.obj,\
#	"nl_langinfo"=[.lib]nl_langinfo.obj,\
#	"open"=[.lib]open.obj,\
#	"opendir"=[.lib]opendir.obj,\
#	"putenv"=[.lib]putenv.obj,\
#	"select"=[.lib]select.obj,\
#	"sigaction"=[.lib]sigaction.obj,\
#	"sigprocmask"=[.lib]sigprocmask.obj,\
#	"snprintf"=[.lib]snprintf.obj,\
#	"strdup"=[.lib]strdup.obj,\
#	"strerror"=[.lib]strerror.obj,\
#	"strerror-override"=[.lib]strerror-override.obj,\
#	"strlen"=[.lib]strnlen.obj,\
#	"strncat"=[.lib]strncat.obj,\
#	"strpbrk"=[.lib]strpbrk.obj,\
#	"strstr"=[.lib]strstr.obj,\
#	"strtod"=[.lib]strtod.obj,\
#	"strtol"=[.lib]strtol.obj,\
#	"strtoul"=[.lib]strtoul.obj,\
#	"strtoll"=[.lib]strtoll.obj,\
#	"strtoull"=[.lib]strtoull.obj,\
#	"time_r"=[.lib]time_r.obj,\
#	"waitpid"=[.lib]waitpid.obj,\
#	"wcrtomb"=[.lib]wcrtomb.obj,\
#	"wcswidth"=[.lib]wcswidth.obj,\
#	"wcwidth"=[.lib]wcwidth.obj,\
#	"vfprintf"=[.lib]vfprintf.obj,\
#
#Rolled our own.
#	"fdopendir"=[.lib]fdopendir.obj,\
#	"dirfd"=[.lib]dirfd.obj,\
#
# Windows Only?
#	"msvc-nothrow"=[.lib]msvc-nothrow.obj,\
#	"readdir"=[.lib]readdir.obj,\
#	"rewinddir"=[.lib]rewinddir.obj,\
#

# We should not need these
#		"alloca"=[.lib]alloca.obj,\
#		"calloc"=[.lib]calloc.obj,\
#		"chown"=[.lib]chown.obj,\
#		"close"=[.lib]close.obj,\
#		"dup"=[.lib]dup.obj,\
#		"dup2"=[.lib]dup2.obj,\
#		"fclose="=[.lib]fclose.obj,\
#		"fdopen"=[.lib]fdopen.obj,\
#		"fflush"=[.lib]fflush.obj,\
#		"fopen"=[.lib]fopen.obj,\
#		"freopen"=[.lib]freopen.obj,\
#		"frexp"=[.lib]frexp.obj,\
#		"freexpl"=[.lib]frexpl.obj,\
#		"fseek"=[.lib]fseek.obj,\
#		"fstat"=[.lib]fstat.obj,\
#		"ftruncate"=[.lib]ftruncate.obj,\
#		"getdtablesize"=[.lib]getdtablesize.obj,\
#		"getgroups"=[.lib]getgroups.obj,\
#		"getpagesize"=[.lib]getpagesize.obj,\
#		"isnanf"=[.lib]isnanf.obj,\
#		"isnanl"=[.lib]isnanl.obj,\
#		"lchown"=[.lib]lchown.obj,\
#		"iconv"=[.lib]iconv.obj,\
#		"iconv_close"=[.lib]iconv_close.obj,\
#		"iconv_open"=[.lib]iconv_open.obj,\
#		"lseek"=[.lib]lseek.obj,\
#		"lstat"=[.lib]lstat.obj,\
#		"malloc"=[.lib]malloc.obj,\
#		"mbrtowc"=[.lib]mbrtowc.obj,\
#		"mkdir"=[.lib]mkdir.obj,\
#		"spawni"=[.lib]spawni.obj,\
#	"spawn_faction_addclose"=[.lib]spawn_faction_addclose.obj,\
#		"spawn_faction_addup2"=[.lib]spawn_faction_adddup2.obj,\
#		"spawn_faction_addopen"=[.lib]spawn_faction_addopen.obj,\
#		"spawn_faction_destroy"=[.lib]spawn_faction_destroy.obj,\
#		"spawn_faction_init"=[.lib]spawn_faction_init.obj,\
#		"spawn_attr_destroy"=[.lib]spawnattr_destroy.obj,\
#		"spawn_init"=[.lib]spawnattr_init.obj,\
#		"spawnattr_setflags"=[.lib]spawnattr_setflags.obj,\
#		"spawnattr_setsigmask"=[.lib]spawnattr_setsigmask.obj,\
#		"spawnp"=[.lib]spawnp.obj,\
#		"raise"=[.lib]raise.obj,\
#		"read"=[.lib]read.obj,\
#		"readlink"=[.lib]readlink.obj,\
#		"realloc"=[.lib]realloc.obj,\
#		"remove"=[.lib]remove.obj,\
#		"rename"=[.lib]rename.obj,\
#		"rmdir"=[.lib]rmdir.obj,\
#		"setenv"=[.lib]setenv.obj,\
#		"stat"=[.lib]stat.obj,\
#		"symlink"=[.lib]symlink.obj,\
#		"uname"=[.lib]uname.obj,\
#		"unlink"=[.lib]unlink.obj,\
#		"unsetenv"=[.lib]unsetenv.obj,\
#		"write"=[.lib]write.obj
#		"fchdir"=[.lib]fchdir.obj,\

lib1_objs = 	"acl_entries"=[.lib]acl_entries.obj,\
		"openat-proc"=[.lib]openat-proc.obj,\
		"chdir-long"=[.lib]chdir-long.obj,\
		"error"=[.lib]error.obj,\
		"euidaccess"=[.lib]euidaccess.obj,\
		"faccessat"=[.lib]faccessat.obj,\
		"fchmodat"=[.lib]fchmodat.obj,\
		"fchownat"=[.lib]fchownat.obj,\
		"fcntl"=[.lib]fcntl.obj,\
		"fdatasync"=[.lib]fdatasync.obj,\
		"fileblocks"=[.lib]fileblocks.obj,\
		"float"=[.lib]float.obj,\
		"itold"=[.lib]itold.obj,\
		"fnmatch"=[.lib]fnmatch.obj,\
		"fpending"=[.lib]fpending.obj,\
		"fpurge"=[.lib]fpurge.obj,\
		"fstatat"=[.lib]fstatat.obj,\
		"fsusage"=[.lib]fsusage.obj,\
		"fts"=[.lib]fts.obj,\
		"futimens"=[.lib]futimens.obj,\
		"getdelim"=[.lib]getdelim.obj,\
		"getfilecon"=[.lib]getfilecon.obj,\
		"getline"=[.lib]getline.obj,\
		"getloadavg"=[.lib]getloadavg.obj,\
		"getopt"=[.lib]getopt.obj,\
		"getopt1"=[.lib]getopt1.obj,\
		"getpass"=[.lib]getpass.obj,\
		"getusershell"=[.lib]getusershell.obj,\
		"group-member"=[.lib]group-member.obj,\
		"isblank"=[.lib]isblank.obj,\
		"isnand"=[.lib]isnand.obj,\
		"iswblank"=[.lib]iswblank.obj,\
		"link"=[.lib]link.obj,\
		"at-func2"=[.lib]at-func2.obj,\
		"linkat"=[.lib]linkat.obj,\
		"mbsrtowcs-state"=[.lib]mbsrtowcs-state.obj,\
		"mempcpy"=[.lib]mempcpy.obj,\
		"memrchr"=[.lib]memrchr.obj,\
		"mkfifo"=[.lib]mkfifo.obj,\
		"mknod"=[.lib]mknod.obj,\
		"mountlist"=[.lib]mountlist.obj,\
		"msvc-inval"=[.lib]msvc-inval.obj,\
		"obstack"=[.lib]obstack.obj,\
		"openat"=[.lib]openat.obj,\
		"selinex-at"=[.lib]selinux-at.obj,\
		"pthread"=[.lib]pthread.obj,\
		"rawmemchr"=[.lib]rawmemchr.obj,\
		"readlinkat"=[.lib]readlinkat.obj,\
		"vms_readutmp"=[.lib]vms_readutmp.obj,\
		"vms_getmntinfo"=[.lib]vms_getmntinfo.obj,\
		"regex"=[.lib]regex.obj,\
		"rpmatch"=[.lib]rpmatch.obj,\
		"sig2str"=[.lib]sig2str.obj,\
		"signbitd"=[.lib]signbitd.obj,\
		"signbitf"=[.lib]signbitf.obj,\
		"signbitl"=[.lib]signbitl.obj,\
		"stpcopy"=[.lib]stpcpy.obj,\
		"stpncpy"=[.lib]stpncpy.obj,\
		"strchrnul"=[.lib]strchrnul.obj,\
		"strndup"=[.lib]strndup.obj,\
		"strsignal"=[.lib]strsignal.obj,\
		"strtoimax"=[.lib]strtoimax.obj,\
		"strtoumax"=[.lib]strtoumax.obj,\
		"unlinkat"=[.lib]unlinkat.obj,\
		"utimesat"=[.lib]utimensat.obj,\
		"asnprintf"=[.lib]asnprintf.obj,\
		"printf-args"=[.lib]printf-args.obj,\
		"printf-parse"=[.lib]printf-parse.obj,\
		"vasnprintf"=[.lib]vasnprintf.obj,\
		"asprintf"=[.lib]asprintf.obj,\
		"vasprintf"=[.lib]vasprintf.obj

vms_lib_objs =  "vms_gethostid"=[.lib]vms_gethostid.obj,\
		"gnv_vms_iconv_wrapper"=[.lib]gnv_vms_iconv_wrapper.obj,\
		"vms_terminal_io"=[.lib]vms_terminal_io.obj,\
		"vms_term"=[.lib]vms_term.obj

chown_core_h = [.src]chown-core.h [.lib]dev-ino.h

copy_h = [.src]copy.h [.lib]hash.h

ioblksize_h = [.src]ioblksize.h [.lib]stat-size.h

remove_h = [.src]remove.h [.lib]dev-ino.h

system_h = [.src]system.h [.lib]pathmax.h [.lib]configmake.h \
	[.src]version.h [.lib]exitfail.h [.lib]stat-macros.h \
	[.lib]timespec.h [.lib]gettext.h [.lib]xalloc.h \
	[.lib]verify.h [.lib]unlocked-io.h [.lib]same-inode.h \
	$(dirname_h) [.lib]openat.h \
	[.lib]closein.h [.lib]closeout.h [.lib]version-etc.h \
	[.lib]progname.h [.lib]intprops.h \
	$(inttostr_h) [.lib]alloca.h

am_src___OBJECTS = [.src]lbracket.obj
src___OBJECTS = $(am_src___OBJECTS)
am__DEPENDENCIES_2 = [.src]version.obj [.lib]libcoreutils.olb \
	$(am__DEPENDENCIES_1) [.lib]libcoreutils.olb [.src]vms_crtl_init.obj
am__DEPENDENCIES_3 = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src___DEPENDENCIES = $(am__DEPENDENCIES_3)
am_src_arch_OBJECTS = [.src]uname.obj [.src]uname-arch.obj
src_arch_OBJECTS = $(am_src_arch_OBJECTS)
src_arch_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_base64_SOURCES = [.src]base64.c
src_base64_OBJECTS = [.src]base64.obj
src_base64_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_basename_SOURCES = [.src]basename.c
src_basename_OBJECTS = [.src]basename.obj
src_basename_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_cat_SOURCES = [.src]cat.c
src_cat_OBJECTS = [.src]cat.obj
src_cat_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_chcon_SOURCES = [.src]chcon.c
src_chcon_OBJECTS = [.src]chcon.obj
src_chcon_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
am_src_chgrp_OBJECTS = [.src]chgrp.obj [.src]chown-core.obj
src_chgrp_OBJECTS = $(am_src_chgrp_OBJECTS)
src_chgrp_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_chmod_SOURCES = [.src]chmod.c
src_chmod_OBJECTS = [.src]chmod.obj
src_chmod_DEPENDENCIES = $(am__DEPENDENCIES_2)
am_src_chown_OBJECTS = [.src]chown.obj [.src]chown-core.obj
src_chown_OBJECTS = $(am_src_chown_OBJECTS)
src_chown_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_chroot_SOURCES = [.src]chroot.c
src_chroot_OBJECTS = [.src]chroot.obj
src_chroot_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_cksum_SOURCES = [.src]cksum.c
src_cksum_OBJECTS = [.src]cksum.obj
src_cksum_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_comm_SOURCES = [.src]comm.c
src_comm_OBJECTS = [.src]comm.obj
src_comm_DEPENDENCIES = $(am__DEPENDENCIES_2)
am__objects_4 = [.src]copy.obj [.src]cp-hash.obj \
	[.src]extent-scan.obj
am_src_cp_OBJECTS = [.src]cp.obj $(am__objects_4)
src_cp_OBJECTS = $(am_src_cp_OBJECTS)
am__DEPENDENCIES_4 = $(am__DEPENDENCIES_1) $(am__DEPENDENCIES_1) \
	$(am__DEPENDENCIES_1) $(am__DEPENDENCIES_1) \
	$(am__DEPENDENCIES_1)
src_cp_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_4) \
	$(am__DEPENDENCIES_1)
src_csplit_SOURCES = [.src]csplit.c
src_csplit_OBJECTS = [.src]csplit.obj
src_csplit_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_cut_SOURCES = [.src]cut.c
src_cut_OBJECTS = [.src]cut.obj
src_cut_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_date_SOURCES = [.src]date.c
src_date_OBJECTS = [.src]date.obj
src_date_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_dd_SOURCES = [.src]dd.c
src_dd_OBJECTS = [.src]dd.obj
src_dd_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1) \
	$(am__DEPENDENCIES_1)
am_src_df_OBJECTS = [.src]df.obj [.src]find-mount-point.obj
src_df_OBJECTS = $(am_src_df_OBJECTS)
src_df_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
am_src_dir_OBJECTS = [.src]ls.obj [.src]ls-dir.obj
src_dir_OBJECTS = $(am_src_dir_OBJECTS)
am__DEPENDENCIES_5 = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1) \
	$(am__DEPENDENCIES_1) $(am__DEPENDENCIES_1) \
	$(am__DEPENDENCIES_1)
src_dir_DEPENDENCIES = $(am__DEPENDENCIES_5)
src_dircolors_SOURCES = [.src]dircolors.c
src_dircolors_OBJECTS = [.src]dircolors.obj
src_dircolors_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_dirname_SOURCES = [.src]dirname.c
src_dirname_OBJECTS = [.src]dirname.obj
src_dirname_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_du_SOURCES = [.src]du.c
src_du_OBJECTS = [.src]du.obj
src_du_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_echo_SOURCES = [.src]echo.c
src_echo_OBJECTS = [.src]echo.obj
src_echo_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_env_SOURCES = [.src]env.c
src_env_OBJECTS = [.src]env.obj
src_env_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_expand_SOURCES = [.src]expand.c
src_expand_OBJECTS = [.src]expand.obj
src_expand_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_expr_SOURCES = [.src]expr.c
src_expr_OBJECTS = [.src]expr.obj
src_expr_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_factor_SOURCES = [.src]factor.c
src_factor_OBJECTS = [.src]factor.obj
src_factor_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1) \
	$(am__DEPENDENCIES_1)
src_false_SOURCES = [.src]false.c
src_false_OBJECTS = [.src]false.obj
src_false_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_fmt_SOURCES = [.src]fmt.c
src_fmt_OBJECTS = [.src]fmt.obj
src_fmt_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_fold_SOURCES = [.src]fold.c
src_fold_OBJECTS = [.src]fold.obj
src_fold_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_getlimits_SOURCES = [.src]getlimits.c
src_getlimits_OBJECTS = [.src]getlimits.obj
src_getlimits_DEPENDENCIES = $(am__DEPENDENCIES_2) \
	$(am__DEPENDENCIES_1)
am__objects_5 = [.src]src_ginstall-copy.obj \
	[.src]src_ginstall-cp-hash.obj \
	[.src]src_ginstall-extent-scan.obj
am_src_ginstall_OBJECTS = [.src]src_ginstall-install.obj \
	[.src]src_ginstall-prog-fprintf.obj $(am__objects_5)
src_ginstall_OBJECTS = $(am_src_ginstall_OBJECTS)
src_ginstall_DEPENDENCIES = $(am__DEPENDENCIES_2) \
	$(am__DEPENDENCIES_4) $(am__DEPENDENCIES_1) \
	$(am__DEPENDENCIES_1)
am_src_groups_OBJECTS = [.src]groups.obj [.src]group-list.obj
src_groups_OBJECTS = $(am_src_groups_OBJECTS)
src_groups_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_head_SOURCES = [.src]head.c
src_head_OBJECTS = [.src]head.obj
src_head_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_hostid_SOURCES = [.src]hostid.c
src_hostid_OBJECTS = [.src]hostid.obj
src_hostid_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_hostname_SOURCES = [.src]hostname.c
src_hostname_OBJECTS = [.src]hostname.obj
src_hostname_DEPENDENCIES = $(am__DEPENDENCIES_2) \
	$(am__DEPENDENCIES_1)
am_src_id_OBJECTS = [.src]id.obj [.src]group-list.obj
src_id_OBJECTS = $(am_src_id_OBJECTS)
src_id_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_join_SOURCES = [.src]join.c
src_join_OBJECTS = [.src]join.obj
src_join_DEPENDENCIES = $(am__DEPENDENCIES_2)
am_src_kill_OBJECTS = [.src]kill.obj [.src]operand2sig.obj
src_kill_OBJECTS = $(am_src_kill_OBJECTS)
src_kill_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_libstdbuf_so_SOURCES = [.src]libstdbuf.c
src_libstdbuf_so_OBJECTS = [.src]src_libstdbuf_so-libstdbuf.obj
src_libstdbuf_so_DEPENDENCIES =
src_libstdbuf_so_LINK = $(CCLD) $(src_libstdbuf_so_CFLAGS) $(CFLAGS) \
	$(src_libstdbuf_so_LDFLAGS) $(LDFLAGS) -o $@
src_link_SOURCES = [.src]link.c
src_link_OBJECTS = [.src]link.obj
src_link_DEPENDENCIES = $(am__DEPENDENCIES_2)
am_src_ln_OBJECTS = [.src]ln.obj [.src]relpath.obj
src_ln_OBJECTS = $(am_src_ln_OBJECTS)
src_ln_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_logname_SOURCES = [.src]logname.c
src_logname_OBJECTS = [.src]logname.obj
src_logname_DEPENDENCIES = $(am__DEPENDENCIES_2)
am_src_ls_OBJECTS = [.src]ls.obj [.src]ls-ls.obj
src_ls_OBJECTS = $(am_src_ls_OBJECTS)
src_ls_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1) \
	$(am__DEPENDENCIES_1) $(am__DEPENDENCIES_1) \
	$(am__DEPENDENCIES_1)
src_make_prime_list_SOURCES = [.src]make-prime-list.c
src_make_prime_list_OBJECTS = [.src]make-prime-list.obj
src_make_prime_list_DEPENDENCIES =
src_md5sum_SOURCES = [.src]md5sum.c
src_md5sum_OBJECTS = [.src]src_md5sum-md5sum.obj
src_md5sum_DEPENDENCIES = $(am__DEPENDENCIES_2)
am_src_mkdir_OBJECTS = [.src]mkdir.obj [.src]prog-fprintf.obj
src_mkdir_OBJECTS = $(am_src_mkdir_OBJECTS)
src_mkdir_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_mkfifo_SOURCES = [.src]mkfifo.c
src_mkfifo_OBJECTS = [.src]mkfifo.obj
src_mkfifo_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_mknod_SOURCES = [.src]mknod.c
src_mknod_OBJECTS = [.src]mknod.obj
src_mknod_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_mktemp_SOURCES = [.src]mktemp.c
src_mktemp_OBJECTS = [.src]mktemp.obj
src_mktemp_DEPENDENCIES = $(am__DEPENDENCIES_2)
am_src_mv_OBJECTS = [.src]mv.obj [.src]remove.obj \
	$(am__objects_4)
src_mv_OBJECTS = $(am_src_mv_OBJECTS)
am__DEPENDENCIES_6 = $(am__DEPENDENCIES_1)
src_mv_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_4) \
	$(am__DEPENDENCIES_6)
src_nice_SOURCES = [.src]nice.c
src_nice_OBJECTS = [.src]nice.obj
src_nice_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_nl_SOURCES = [.src]nl.c
src_nl_OBJECTS = [.src]nl.obj
src_nl_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_nohup_SOURCES = [.src]nohup.c
src_nohup_OBJECTS = [.src]nohup.obj
src_nohup_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_nproc_SOURCES = [.src]nproc.c
src_nproc_OBJECTS = [.src]nproc.obj
src_nproc_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_numfmt_SOURCES = [.src]numfmt.c
src_numfmt_OBJECTS = [.src]numfmt.obj
src_numfmt_LDADD = $(LDADD)
src_numfmt_DEPENDENCIES = [.src]version.obj [.lib]libcoreutils.olb \
	$(am__DEPENDENCIES_1) [.lib]libcoreutils.olb
src_od_SOURCES = [.src]od.c
src_od_OBJECTS = [.src]od.obj
src_od_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_paste_SOURCES = [.src]paste.c
src_paste_OBJECTS = [.src]paste.obj
src_paste_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_pathchk_SOURCES = [.src]pathchk.c
src_pathchk_OBJECTS = [.src]pathchk.obj
src_pathchk_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_pinky_SOURCES = [.src]pinky.c
src_pinky_OBJECTS = [.src]pinky.obj
src_pinky_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_pr_SOURCES = [.src]pr.c
src_pr_OBJECTS = [.src]pr.obj
src_pr_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_printenv_SOURCES = [.src]printenv.c
src_printenv_OBJECTS = [.src]printenv.obj
src_printenv_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_printf_SOURCES = [.src]printf.c
src_printf_OBJECTS = [.src]printf.obj
src_printf_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_ptx_SOURCES = [.src]ptx.c
src_ptx_OBJECTS = [.src]ptx.obj
src_ptx_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_pwd_SOURCES = [.src]pwd.c
src_pwd_OBJECTS = [.src]pwd.obj
src_pwd_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_readlink_SOURCES = [.src]readlink.c
src_readlink_OBJECTS = [.src]readlink.obj
src_readlink_DEPENDENCIES = $(am__DEPENDENCIES_2)
am_src_realpath_OBJECTS = [.src]realpath.obj [.src]relpath.obj
src_realpath_OBJECTS = $(am_src_realpath_OBJECTS)
src_realpath_DEPENDENCIES = $(am__DEPENDENCIES_2) \
	$(am__DEPENDENCIES_1)
am_src_rm_OBJECTS = [.src]rm.obj [.src]remove.obj
src_rm_OBJECTS = $(am_src_rm_OBJECTS)
src_rm_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_6)
am_src_rmdir_OBJECTS = [.src]rmdir.obj [.src]prog-fprintf.obj
src_rmdir_OBJECTS = $(am_src_rmdir_OBJECTS)
src_rmdir_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_runcon_SOURCES = [.src]runcon.c
src_runcon_OBJECTS = [.src]runcon.obj
src_runcon_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_seq_SOURCES = [.src]seq.c
src_seq_OBJECTS = [.src]seq.obj
src_seq_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_setuidgid_SOURCES = [.src]setuidgid.c
src_setuidgid_OBJECTS = [.src]setuidgid.obj
src_setuidgid_DEPENDENCIES = $(am__DEPENDENCIES_2)
am_src_sha1sum_OBJECTS = [.src]src_sha1sum-md5sum.obj
src_sha1sum_OBJECTS = $(am_src_sha1sum_OBJECTS)
src_sha1sum_DEPENDENCIES = $(am__DEPENDENCIES_2)
am_src_sha224sum_OBJECTS = [.src]src_sha224sum-md5sum.obj
src_sha224sum_OBJECTS = $(am_src_sha224sum_OBJECTS)
src_sha224sum_DEPENDENCIES = $(am__DEPENDENCIES_2)
am_src_sha256sum_OBJECTS = [.src]src_sha256sum-md5sum.obj
src_sha256sum_OBJECTS = $(am_src_sha256sum_OBJECTS)
src_sha256sum_DEPENDENCIES = $(am__DEPENDENCIES_2)
am_src_sha384sum_OBJECTS = [.src]src_sha384sum-md5sum.obj
src_sha384sum_OBJECTS = $(am_src_sha384sum_OBJECTS)
src_sha384sum_DEPENDENCIES = $(am__DEPENDENCIES_2)
am_src_sha512sum_OBJECTS = [.src]src_sha512sum-md5sum.obj
src_sha512sum_OBJECTS = $(am_src_sha512sum_OBJECTS)
src_sha512sum_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_shred_SOURCES = [.src]shred.c
src_shred_OBJECTS = [.src]shred.obj
src_shred_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_shuf_SOURCES = [.src]shuf.c
src_shuf_OBJECTS = [.src]shuf.obj
src_shuf_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_sleep_SOURCES = [.src]sleep.c
src_sleep_OBJECTS = [.src]sleep.obj
src_sleep_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_sort_SOURCES = [.src]sort.c
src_sort_OBJECTS = [.src]sort.obj
src_sort_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1) \
	$(am__DEPENDENCIES_1) $(am__DEPENDENCIES_1)
src_split_SOURCES = [.src]split.c
src_split_OBJECTS = [.src]split.obj
src_split_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
am_src_stat_OBJECTS = [.src]stat.obj \
	[.src]find-mount-point.obj
src_stat_OBJECTS = $(am_src_stat_OBJECTS)
src_stat_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_stdbuf_SOURCES = [.src]stdbuf.c
src_stdbuf_OBJECTS = [.src]stdbuf.obj
src_stdbuf_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_stty_SOURCES = [.src]stty.c
src_stty_OBJECTS = [.src]stty.obj
src_stty_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_sum_SOURCES = [.src]sum.c
src_sum_OBJECTS = [.src]sum.obj
src_sum_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_sync_SOURCES = [.src]sync.c
src_sync_OBJECTS = [.src]sync.obj
src_sync_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_tac_SOURCES = [.src]tac.c
src_tac_OBJECTS = [.src]tac.obj
src_tac_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_tail_SOURCES = [.src]tail.c
src_tail_OBJECTS = [.src]tail.obj
src_tail_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_tee_SOURCES = [.src]tee.c
src_tee_OBJECTS = [.src]tee.obj
src_tee_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_test_SOURCES = [.src]test.c
src_test_OBJECTS = [.src]test.obj
src_test_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
am_src_timeout_OBJECTS = [.src]timeout.obj \
	[.src]operand2sig.obj
src_timeout_OBJECTS = $(am_src_timeout_OBJECTS)
src_timeout_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1) \
	$(am__DEPENDENCIES_1)
src_touch_SOURCES = [.src]touch.c
src_touch_OBJECTS = [.src]touch.obj
src_touch_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_tr_SOURCES = [.src]tr.c
src_tr_OBJECTS = [.src]tr.obj
src_tr_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_true_SOURCES = [.src]true.c
src_true_OBJECTS = [.src]true.obj
src_true_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_truncate_SOURCES = [.src]truncate.c
src_truncate_OBJECTS = [.src]truncate.obj
src_truncate_DEPENDENCIES = $(am__DEPENDENCIES_2) \
	$(am__DEPENDENCIES_1)
src_tsort_SOURCES = [.src]tsort.c
src_tsort_OBJECTS = [.src]tsort.obj
src_tsort_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_tty_SOURCES = [.src]tty.c
src_tty_OBJECTS = [.src]tty.obj
src_tty_DEPENDENCIES = $(am__DEPENDENCIES_2)
am_src_uname_OBJECTS = [.src]uname.obj [.src]uname-uname.obj
src_uname_OBJECTS = $(am_src_uname_OBJECTS)
src_uname_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_unexpand_SOURCES = [.src]unexpand.c
src_unexpand_OBJECTS = [.src]unexpand.obj
src_unexpand_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_uniq_SOURCES = [.src]uniq.c
src_uniq_OBJECTS = [.src]uniq.obj
src_uniq_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_unlink_SOURCES = [.src]unlink.c
src_unlink_OBJECTS = [.src]unlink.obj
src_unlink_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_uptime_SOURCES = [.src]uptime.c
src_uptime_OBJECTS = [.src]uptime.obj
src_uptime_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_users_SOURCES = [.src]users.c
src_users_OBJECTS = [.src]users.obj
src_users_DEPENDENCIES = $(am__DEPENDENCIES_2)
am_src_vdir_OBJECTS = [.src]ls.obj [.src]ls-vdir.obj
src_vdir_OBJECTS = $(am_src_vdir_OBJECTS)
src_vdir_DEPENDENCIES = $(am__DEPENDENCIES_5)
src_wc_SOURCES = [.src]wc.c
src_wc_OBJECTS = [.src]wc.obj
src_wc_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_who_SOURCES = [.src]who.c
src_who_OBJECTS = [.src]who.obj
src_who_DEPENDENCIES = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src_whoami_SOURCES = [.src]whoami.c
src_whoami_OBJECTS = [.src]whoami.obj
src_whoami_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_yes_SOURCES = [.src]yes.c
src_yes_OBJECTS = [.src]yes.obj
src_yes_DEPENDENCIES = $(am__DEPENDENCIES_2)

am__EXEEXT_1 = [.src]arch$(EXEEXT) [.src]hostname$(EXEEXT)
# [.src]libstdbuf_so$(EXEEXT)
am__EXEEXT_2 = [.src]chroot$(EXEEXT) [.src]df$(EXEEXT) [.src]hostid$(EXEEXT) \
	[.src]nice$(EXEEXT) [.src]pinky$(EXEEXT) \
	[.src]stdbuf$(EXEEXT) [.src]stty$(EXEEXT) [.src]uptime$(EXEEXT) \
	[.src]users$(EXEEXT) [.src]who$(EXEEXT)

am__EXEEXT_3 = [.src]base64$(EXEEXT) \
	[.src]basename$(EXEEXT) [.src]cat$(EXEEXT) [.src]chcon$(EXEEXT) \
	[.src]chgrp$(EXEEXT) [.src]chmod$(EXEEXT) [.src]chown$(EXEEXT) \
	[.src]cksum$(EXEEXT) [.src]comm$(EXEEXT) [.src]cp$(EXEEXT) \
	[.src]csplit$(EXEEXT) [.src]cut$(EXEEXT) [.src]date$(EXEEXT) \
	[.src]dd$(EXEEXT) [.src]dir$(EXEEXT) [.src]dircolors$(EXEEXT) \
	[.src]dirname$(EXEEXT) [.src]du$(EXEEXT) [.src]echo$(EXEEXT) \
	[.src]env$(EXEEXT) [.src]expand$(EXEEXT) [.src]expr$(EXEEXT) \
	[.src]factor$(EXEEXT) [.src]false$(EXEEXT) [.src]fmt$(EXEEXT) \
	[.src]fold$(EXEEXT) [.src]install$(EXEEXT) [.src]groups$(EXEEXT) \
	[.src]head$(EXEEXT) [.src]id$(EXEEXT) [.src]join$(EXEEXT) \
	[.src]kill$(EXEEXT) [.src]link$(EXEEXT) [.src]ln$(EXEEXT) \
	[.src]logname$(EXEEXT) [.src]ls$(EXEEXT) [.src]md5sum$(EXEEXT) \
	[.src]mkdir$(EXEEXT) [.src]mkfifo$(EXEEXT) [.src]mknod$(EXEEXT) \
	[.src]mktemp$(EXEEXT) [.src]mv$(EXEEXT) [.src]nl$(EXEEXT) \
	[.src]nproc$(EXEEXT) [.src]nohup$(EXEEXT) [.src]numfmt$(EXEEXT) \
	[.src]od$(EXEEXT) [.src]paste$(EXEEXT) [.src]pathchk$(EXEEXT) \
	[.src]pr$(EXEEXT) [.src]printenv$(EXEEXT) [.src]printf$(EXEEXT) \
	[.src]ptx$(EXEEXT) [.src]pwd$(EXEEXT) [.src]readlink$(EXEEXT) \
	[.src]realpath$(EXEEXT) [.src]rm$(EXEEXT) [.src]rmdir$(EXEEXT) \
	[.src]runcon$(EXEEXT) [.src]seq$(EXEEXT) [.src]sha1sum$(EXEEXT) \
	[.src]sha224sum$(EXEEXT) [.src]sha256sum$(EXEEXT) \
	[.src]sha384sum$(EXEEXT) [.src]sha512sum$(EXEEXT) \
	[.src]shred$(EXEEXT) [.src]shuf$(EXEEXT) [.src]sleep$(EXEEXT) \
	[.src]sort$(EXEEXT) [.src]split$(EXEEXT) [.src]stat$(EXEEXT) \
	[.src]sum$(EXEEXT) [.src]sync$(EXEEXT) [.src]tac$(EXEEXT) \
	[.src]tail$(EXEEXT) [.src]tee$(EXEEXT) [.src]test$(EXEEXT) \
	[.src]timeout$(EXEEXT) [.src]touch$(EXEEXT) [.src]tr$(EXEEXT) \
	[.src]true$(EXEEXT) [.src]truncate$(EXEEXT) [.src]tsort$(EXEEXT) \
	[.src]tty$(EXEEXT) [.src]uname$(EXEEXT) [.src]unexpand$(EXEEXT) \
	[.src]uniq$(EXEEXT) [.src]unlink$(EXEEXT) [.src]vdir$(EXEEXT) \
	[.src]wc$(EXEEXT) [.src]whoami$(EXEEXT) [.src]yes$(EXEEXT) \
	[.src]lbracket$(EXEEXT)

all_progs = $(am__EXEEXT_1) $(am__EXEEXT_2) $(am__EXEEXT_3)

all : [.lib]libcoreutils.olb all_programs
    @ write sys$output "Target All is up to date"

all_programs : $(all_progs)
    @ write sys$output "all programs are up to date"

[.lib]libcoreutils.olb : [.lib]libcoreutils($(lib_libcoreutils_a_OBJECTS),\
				      $(unistr_objs),$(uniwidth_objs),\
				      $(lib1_objs),$(vms_lib_objs))
    @ write sys$output "libcoreutils is up to date"


config_vms.h : [.vms]generate_config_vms_h_coreutils.com [.lib]arg-nonnull.h
        $ create/dir [.vms]/prot=o:rwed
	$ @[.vms]generate_config_vms_h_coreutils.com

[.lib]config.h : [.vms]config_h.com config_vms.h sys$disk:[]configure.
	@[.vms]config_h.com [.lib]config.hin
	$ rename sys$disk:config.h [.lib]config.h
	write sys$output "[.lib]config.h target built."

[.lib.selinux]selinux.h : [.lib]se-selinux^.in.h \
	[.vms]lib_selinux_selinux_h.tpu
    if f$search("[.lib]selinux.dir") .eqs. "" then \
	create/dir sys$disk:[.lib.selinux]/prot=o:rwed
    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
	    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.lib.selinux]context.h : [.lib]se-context^.in.h
	if f$search("[.lib]selinux.dir") .eqs. "" then \
	    create/dir sys$disk:[.lib.selinux]/prot=o:rwed
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

[.lib]configmake.h : [.vms]configmake_h.com
        @ $write sys$output "[.lib]configmake.h target"
	@[.vms]configmake_h.com

[.lib]alloca.h : [.vms]vms_alloca.h
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

[.lib]arg-nonnull.h : [.build-aux.snippet]arg-nonnull.h
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

[.lib]float_plus.h : $(float_plus_h)
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

[.lib]fnmatch.h : [.lib]fnmatch.in.h
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

[.lib]getopt.h : [.lib]getopt.in.h [.vms]lib_getopt_h.tpu
    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
	    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.lib]sched.h : [.lib]sched^.in.h [.vms]lib_sched_h.tpu
    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
	    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.lib]spawn.h : [.lib]spawn^.in.h [.vms]lib_spawn_h.tpu
    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
	    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.lib]stdalign.h : [.lib]stdalign.in.h
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

[.lib]stdint.h : [.lib]stdint^.in.h [.vms]lib_stdint_h.tpu
    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
	    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.lib]unistr.h : [.lib]unistr.in.h
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

[.lib]unitypes.h : [.lib]unitypes.in.h
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

[.lib]unused-parameter.h : [.build-aux.snippet]unused-parameter.h
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

[.lib]stdio_ext.h : [.vms]vms_stdio_ext.h
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

[.lib]uniwidth.h : [.lib]uniwidth^.in.h
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

[.lib]utmp.h : [.vms]vms_utmp.h
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

[.lib.sys]mount.h : [.vms]vms_mount.h
	if f$search("[.lib]sys.dir") .eqs. "" then \
	    create/dir sys$disk:[.lib.sys]/prot=o:rwed
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

[.lib]acl_entries.obj : [.lib]acl_entries.c $(config_h) $(acl-internal_h)

[.lib]alloca.obj : [.lib]alloca.c $(config_h)

[.lib]allocator.obj : [.lib]allocator.c $(config_h) [.lib]allocator.h

# [.lib]anytostr.obj : $(anytostr_c)

[.lib]areadlink-with-size.obj : [.lib]areadlink-with-size.c \
	$(config_h) [.lib]areadlink.h [.lib]stdint.h

[.lib]areadlink.obj : [.lib]areadlink.c $(at_func_c) $(config_h) \
	[.lib]areadlink.h [.lib]careadlinkat.h

[.lib]areadlinkat.obj : [.lib]areadlinkat.c $(config_h) \
	[.lib]areadlink.h [.lib]careadlinkat.h $(at_func_c)

[.lib]argmatch.obj : [.lib]argmatch.c $(config_h) $(argmatch_h) \
	[.lib]gettext.h [.lib]error.h [.lib]quotearg.h [.lib]quote.h \
	[.lib]unlocked-io.h [.lib]exitfail.h

[.lib]argv-iter.obj : [.lib]argv-iter.c $(config_h) $(argv_iter_h)

[.lib]asnprintf.obj : [.lib]asnprintf.c $(config_h) [.lib]vasnprintf.h

[.lib]asprintf.obj : [.lib]asprintf.c $(config_h)

[.lib]at-func2.obj : [.lib]at-func2.c $(config_h) [.lib]openat-priv.h \
	[.lib]dosname.h [.lib]filenamecat.h [.lib]openat.h \
	[.lib]same-inode.h [.lib]save-cwd.h [.vms]vms_pwd_hack.h


[.lib]backupfile.obj : [.lib]backupfile.c $(config_h) [.lib]backupfile.h \
	$(argmatch_h) $(dirname_h) [.lib]xalloc.h $(dirent___h)

[.lib]base64.obj : [.lib]base64.c $(config_h) [.lib]base64.h

[.lib]basename-lgpl.obj : [.lib]basename-lgpl.c $(config_h) $(dirname_h)

[.lib]basename.obj : [.lib]basename.c $(config_h) $(dirname_h) \
	[.lib]xalloc.h [.lib]xstrndup.h

[.lib]binary-io.obj : [.lib]binary-io.c $(config_h) [.lib]binary-io.h

[.lib]bitrotate.obj : [.lib]bitrotate.c $(config_h) $(bitrotate_h)

# Use VMS CRTL
#[.lib]btowc.obj : [.lib]btowc.c $(config_h)

[.lib]buffer-lcm.obj : [.lib]buffer-lcm.c $(config_h) [.lib]buffer-lcm.h

[.lib]c-ctype.obj : [.lib]c-ctype.c $(config_h) [.lib]c-ctype.h

[.lib]c-strcasecmp.obj : [.lib]c-strcasecmp.c $(config_h) \
	[.lib]c-strcase.h [.lib]c-ctype.h

[.lib]c-strncasecmp.obj : [.lib]c-strncasecmp.c $(config_h) \
	[.lib]c-strcase.h [.lib]c-ctype.h

[.lib]c-strtod.obj : [.lib]c-strtod.c $(config_h) [.lib]c-strtod.h

[.lib]c-strtold.obj : [.lib]c-strtold.c [.lib]c-strtod.c

[.lib]calloc.obj : [.lib]calloc.c $(config_h)

[.lib]canon-host.obj : [.lib]canon-host.c $(config_h) [.lib]canon-host.h

[.lib]canonicalize.obj : [.lib]canonicalize.c $(config_h) \
	[.lib]canonicalize.h [.lib]areadlink.h $(file_set_h) \
	[.lib]hash-triple.h [.lib]pathmax.h [.lib]xalloc.h \
	[.lib]xgetcwd.h [.lib]dosname.h [.vms]vms_pwd_hack.h


[.lib]careadlinkat.obj : [.lib]careadlinkat.c $(config_h) \
	[.lib]careadlinkat.h [.lib]allocator.h [.lib]stdint.h

[.lib]chdir-long.obj : [.lib]chdir-long.c $(config_h) $(chdir_long_h) \
	[.lib]closeout.h [.lib]error.h

[.lib]chmodat.obj : [.lib]chmodat.c $(config_h) [.lib]openat.h

[.lib]chown.obj : [.lib]chown.c $(config_h)

[.lib]chownat.obj : [.lib]chownat.c $(config_h) [.lib]openat.h

[.lib]cloexec.obj : [.lib]cloexec.c $(config_h) [.lib]cloexec.h

[.lib]close-stream.obj : [.lib]close-stream.c $(config_h) \
	[.lib]close-stream.h $(fpending_h) [.lib]unlocked-io.h

[.lib]close.obj : [.lib]close.c $(config_h) [.lib]fd-hook.h \
	[.lib]msvc-inval.h

# Use VMS CRTL
#[.lib]closedir.obj : [.lib]closedir.c $(config_h) [.lib]dirent-private.h

[.lib]closein.obj : [.lib]closein.c $(config_h) [.lib]closein.h \
	[.lib]gettext.h [.lib]close-stream.h [.lib]closeout.h \
	[.lib]error.h [.lib]exitfail.h $(freadahead_h) [.lib]quotearg.h

[.lib]closeout.obj : [.lib]closeout.c $(config_h) [.lib]closeout.h \
	[.lib]gettext.h [.lib]close-stream.h [.lib]error.h \
	[.lib]exitfail.h [.lib]quotearg.h

[.lib]copy-acl.obj : [.lib]copy-acl.c $(config_h) [.lib]acl.h \
	$(acl-internal_h) [.lib]gettext.h

[.lib]creat-safer.obj : [.lib]creat-safer.c $(config_h) \
	[.lib]fcntl-safer.h [.lib]unistd-safer.h

[.lib]cycle-check.obj : [.lib]cycle-check.c $(config_h) $(cycle_check_h)

[.lib]di-set.obj : [.lib]di-set.c $(config_h) [.lib]di-set.h \
	[.lib]hash.h [.lib]ino-map.h

[.lib]diacrit.obj : [.lib]diacrit.c $(config_h) [.lib]diacrit.h

[.lib]dirchownmod.obj : [.lib]dirchownmod.c $(config_h) \
	[.lib]dirchownmod.h [.lib]stat-macros.h

[.lib]dirfd.obj : [.lib]dirfd.c $(config_h)

[.lib]dirname-lgpl.obj : [.lib]dirname-lgpl.c $(config_h) $(dirname_h)

[.lib]dirname.obj : [.lib]dirname.c $(config_h) $(dirname_h) \
	[.lib]xalloc.h

[.lib]dtoastr.obj : [.lib]dtoastr.c $(ftoastr_h)

[.lib]dtotimespec.obj : [.lib]dtotimespec.c $(config_h) \
	[.lib]timespec.h [.lib]intprops.h

[.lib]dup-safer-flag.obj : [.lib]dup-safer-flag.c $(config_h) \
	[.lib]unistd-safer.h

[.lib]dup-safer.obj : [.lib]dup-safer.c $(config_h) \
	[.lib]unistd-safer.h

[.lib]dup.obj : [.lib]dup.c $(config_h) [.lib]msvc-inval.h

[.lib]dup2.obj : [.lib]dup2.c $(config_h) [.lib]msvc-inval.h \
	[.lib]msvc-nothrow.h

[.lib]error.obj : [.lib]error.c $(config_h) [.lib]error.h \
	[.lib]gettext.h [.lib]unlocked-io.h [.lib]msvc-nothrow.h \
	[.lib]stdint.h

[.lib]euidaccess.obj : [.lib]euidaccess.c $(config_h) [.lib]root-uid.h

[.lib]exclude.obj : [.lib]exclude.c $(config_h) [.lib]exclude.h \
	[.lib]hash.h [.lib]mbuiter.h [.lib]fnmatch.h [.lib]xalloc.h \
	[.lib]verify.h [.lib]unlocked-io.h

[.lib]exitfail.obj : [.lib]exitfail.c $(config_h) [.lib]exitfail.h

[.lib]faccessat.obj : [.lib]faccessat.c $(config_h) $(at_func_c)

[.lib]fadvise.obj : [.lib]fadvise.c $(config_h) [.lib]fadvise.h \
	[.lib]ignore-value.h

[.lib]fatal-signal.obj : [.lib]fatal-signal.c $(config_h) \
	[.lib]fatal-signal.h [.lib]sig-handler.h [.lib]xalloc.h

# Locally replaced
#[.lib]fchdir.obj : [.lib]fchdir.c $(config_h) [.lib]dosname.h \
#	[.lib]filenamecat.h [.vms]vms_pwd_hack.h

[.lib]fchmodat.obj : [.lib]fchmodat.c $(config_h) $(at_func_c)

# Use VMS CRTL
#[.lib]fchown-stub.obj : [.lib]fchown-stub.c $(config_h)

[.lib]fchownat.obj : [.lib]fchownat.c $(config_h) [.lib]openat.h \
	$(at_func_c)

[.lib]fclose.obj : [.lib]fclose.c $(config_h) $(freading_h) \
	[.lib]msvc-inval.h

[.lib]fcntl.obj : $(config_h) [.lib]msvc-nothrow.h

[.lib]fd-hook.obj : [.lib]fd-hook.c $(config_h) [.lib]fd-hook.h \
	[.vms]vms_ioctl_hack.h

[.lib]fd-reopen.obj : [.lib]fd-reopen.c $(config_h) [.lib]fd-reopen.h

[.lib]fd-safer-flag.obj : [.lib]fd-safer-flag.c $(config_h) \
	[.lib]unistd-safer.h

[.lib]fd-safer.obj : [.lib]fd-safer.c $(config_h) [.lib]unistd-safer.h

[.lib]fdatasync.obj : [.lib]fdatasync.c $(config_h)

[.lib]fdopen.obj : [.lib]fdopen.c $(config_h) [.lib]msvc-inval.h

#[.lib]fdopendir.obj : [.lib]fdopendir.c $(config_h) \
#	[.lib]openat.h [.lib]openat-priv.h [.lib]save-cwd.h $(dirent___h)

[.lib]fdutimensat.obj : [.lib]fdutimensat.c $(config_h) \
	[.lib]utimens.h

[.lib]fflush.obj : [.lib]fflush.c $(config_h) [.lib]stdio-impl.h \
	[.lib]unused-parameter.h

[.lib]file-has-acl.obj : [.lib]file-has-acl.c $(config_h) [.lib]acl.h \
	$(acl-internal_h)

[.lib]file-set.obj : [.lib]file-set.c $(config_h) $(file_set_h) \
	[.lib]hash-triple.h [.lib]xalloc.h

[.lib]file-type.obj : [.lib]file-type.c $(config_h) [.lib]file-type.h

[.lib]fileblocks.obj : [.lib]fileblocks.c $(config_h)

[.lib]filemode.obj : [.lib]filemode.c $(config_h) [.lib]filemode.h

[.lib]filenamecat-lgpl.obj : [.lib]filenamecat-lgpl.c $(config_h) \
	[.lib]filenamecat.h $(dirname_h)

[.lib]filenamecat.obj : [.lib]filenamecat.c $(config_h) \
	[.lib]filenamecat.h [.lib]xalloc.h

[.lib]filevercmp.obj : [.lib]filevercmp.c $(config_h) \
	[.lib]filevercmp.h

[.lib]float.obj : [.lib]float.c $(config_h)

[.lib]fnmatch.obj : [.lib]fnmatch.c $(config_h) [.lib]fnmatch_loop.c \
	[.lib]fnmatch.h

#[.lib]fnmatch_loop.obj : [.lib]fnmatch_loop.c

[.lib]fopen-safer.obj : [.lib]fopen-safer.c $(config_h) \
	[.lib]stdio-safer.h

# Use VMS stdio.h
[.lib]fopen.obj : [.lib]fopen.c $(config_h)

[.lib]fpending.obj : [.lib]fpending.c $(config_h) $(fpending_h)

[.lib]fprintftime.obj : [.lib]fprintftime.c [.lib]strftime.c

[.lib]fpurge.obj : [.lib]fpurge.c $(config_h) [.lib]stdio_ext.h \
	[.lib]stdio-impl.h

# Replaced with a static routine.
#[.lib]freadahead.obj : [.lib]freadahead.c $(config_h) \
#	$(freadahead_h) [.lib]stdio-impl.h

[.lib]freading.obj : [.lib]freading.c $(config_h) $(freading_h) \
	[.lib]stdio-impl.h

#[.lib]freadptr.obj : [.lib]freadptr.c $(config_h) $(freadptr_h) \
#	[.lib]stdio-impl.h

[.lib]freadseek.obj : [.lib]freadseek.c $(config_h) [.lib]freadseek.h \
	$(freadahead_h) $(freadptr_h) [.lib]stdio-impl.h

[.lib]freopen-safer.obj : [.lib]freopen-safer.c $(config_h) \
	[.lib]stdio-safer.h

# Use VMS stdio.h
[.lib]freopen.obj : [.lib]freopen.c $(config_h)

[.lib]frexp.obj : [.lib]frexp.c $(config_h) [.lib]isnanl-nolibm.h \
	[.lib]fpucw.h [.lib]isnand-nolibm.h

[.lib]frexpl.obj : [.lib]frexpl.c $(config_h) [.lib]frexp.c

[.lib]fseek.obj : [.lib]fseek.c $(config_h)

# In the VMS CRTL
#[.lib]fseeko.obj : [.lib]fseeko.c $(config_h) [.lib]stdio-impl.h

# Hacked
#[.lib]fseterr.obj : [.lib]fseterr.c $(config_h) $(fseterr_h) \
#	[.lib]stdio-impl.h

[.lib]fstat.obj : [.lib]fstat.c $(config_h) [.lib]msvc-inval.h

[.lib]fstatat.obj : [.lib]fstatat.c $(config_h) $(at_func_c)

[.lib]fsusage.obj : [.lib]fsusage.c $(config_h) $(fsusage_h) \
	[.lib]full-read.h

# Use VMS CRTL
#[.lib]fsync.obj : [.lib]fsync.c $(config_h) [.lib]msvc-nothrow.h

# Use VMS CRTL
#[.lib]ftell.obj : [.lib]ftell.c $(config_h)

# Use VMS CRTL
#[.lib]ftello.obj : [.lib]ftello.c $(config_h) [.lib]stdio-impl.h

[.lib]ftoastr.obj : $(ftoastr_c)

[.lib]ftruncate.obj : [.lib]ftruncate.c $(config_h) \
	[.lib]msvc-nothrow.h [.lib]msvc-inval.h

# Template - Not compiled.
#[.lib]fts-cycle.obj : $(fts_cycle_c)
# [.lib]getcwdat.h,stdint.h debug only

[.lib]fts.obj : [.lib]fts.c $(config_h) [.lib]fts_.h \
	$(fcntl___h) $(dirent___h) $(unistd___h) \
	[.lib]cloexec.h [.lib]openat.h [.lib]same-inode.h \
	$(fts_cycle_c) [.vms]vms_pwd_hack.h

[.lib]full-read.obj : [.lib]full-read.c $(full_write_c)

[.lib]full-write.obj : $(full_write_c)

[.lib]futimens.obj : [.lib]futimens.c $(config_h) [.lib]utimens.h

#[.lib]gai_strerror.obj : [.lib]gai_strerror.c $(config_h) \
#	[.lib]gettext.h

# Use DECC version
#[.lib]getaddrinfo.obj : [.lib]getaddrinfo.c $(config_h) \
#	[.lib]gettext.h $(sockets_h)

# Use DECC version
#[.lib]getcwd-lgpl.obj : [.lib]getcwd-lgpl.c $(config_h) \
#	[.vms]vms_pwd_hack.h

# Use DECC version
#[.lib]getcwd.obj : [.lib]getcwd.c $(config_h) [.lib]pathmax.h \
#	[.vms]vms_pwd_hack.h

[.lib]getdelim.obj : [.lib]getdelim.c $(config_h) [.lib]unlocked-io.h \
	[.lib]stdint.h

[.lib]getdtablesize.obj : [.lib]getdtablesize.c $(config_h) \
	[.lib]msvc-inval.h

[.lib]getfilecon.obj : [.lib]getfilecon.c $(config_h) \
	[.lib.selinux]selinux.h

[.lib]getgroups.obj : [.lib]getgroups.c $(config_h)

# Use VMS CRTL
#[.lib]gethostname.obj : [.lib]gethostname.c $(config_h) \
#	$(w32sock_h) $(sockets_h)

[.lib]gethrxtime.obj : [.lib]gethrxtime.c $(config_h) \
	$(gethrxtime_h) [.lib]timespec.h

[.lib]getline.obj : [.lib]getline.c $(config_h)

[.lib]getloadavg.obj : [.lib]getloadavg.c $(config_h) [.lib]intprops.h

# Use VMS CRTL
#[.lib]getlogin.obj : [.lib]getlogin.c $(config_h)

[.lib]getndelim2.obj : [.lib]getndelim2.c $(config_h) \
	[.lib]getndelim2.h [.lib]unlocked-io.h [.lib]stdint.h

[.lib]getopt.obj : [.lib]getopt.c $(config_h) [.lib]getopt.h \
	[.lib]gettext.h $(getopt_int_h)

[.lib]getopt1.obj : [.lib]getopt1.c $(config_h) $(getopt_int_h)

[.lib]getpagesize.obj : [.lib]getpagesize.c $(config_h)

[.lib]getpass.obj : [.lib]getpass.c $(config_h) [.lib]getpass.h \
	[.lib]unlocked-io.h [.lib]stdio_ext.h $(termios_h)

[.lib]gettime.obj : [.lib]gettime.c $(config_h) [.lib]timespec.h

# Use VMS CRTL
#[.lib]gettimeofday.obj : [.lib]gettimeofday.c $(config_h)

[.lib]getugroups.obj : [.lib]getugroups.c $(config_h) \
	[.lib]getugroups.h

[.lib]getusershell.obj : [.lib]getusershell.c $(config_h) \
	$(stdio___h) $(stdio___h) [.lib]xalloc.h [.lib]unlocked-io.h

[.lib]group-member.obj : [.lib]group-member.c $(config_h) \
	[.lib]xalloc-oversized.h

[.lib]hard-locale.obj : [.lib]hard-locale.c $(config_h) \
	[.lib]hard-locale.h

[.lib]hash-pjw.obj : [.lib]hash-pjw.c $(config_h) [.lib]hash-pjw.h

[.lib]hash-triple.obj : [.lib]hash-triple.c $(config_h) \
	[.lib]hash-triple.h [.lib]hash-pjw.h [.lib]same.h \
	[.lib]same-inode.h

[.lib]hash.obj : [.lib]hash.c $(config_h) [.lib]hash.h \
	$(bitrotate_h) [.lib]xalloc-oversized.h [.lib]obstack.h

[.lib]heap.obj : [.lib]heap.c $(config_h) [.lib]heap.h \
	$(stdlib___h) [.lib]xalloc.h

[.lib]human.obj : [.lib]human.c $(config_h) $(human_h)

[.lib]i-ring.obj : [.lib]i-ring.c $(config_h) $(i_ring_h)

[.lib]iconv.obj : [.lib]iconv.c $(config_h) $(unistr_h) [.lib]stdint.h

[.lib]iconv_close.obj : [.lib]iconv_close.c $(config_h) [.lib]stdint.h

[.lib]iconv_open.obj : [.lib]iconv_open.c $(config_h) \
	[.lib]c-ctype.h [.lib]c-strcase.h

[.lib]idcache.obj : [.lib]idcache.c $(config_h) [.lib]idcache.h \
	[.lib]xalloc.h [.vms]vms_pwd_hack.h

[.lib]imaxtostr.obj : [.lib]imaxtostr.c $(anytostr_c)

# Use VMS CRTL
#[.lib]inet_ntop.obj : [.lib]inet_ntop.c $(config_h)

[.lib]ino-map.obj : [.lib]ino-map.c $(config_h) [.lib]ino-map.h \
	[.lib]hash.h [.lib]verify.h

[.lib]inttostr.obj : [.lib]inttostr.c $(anytostr_c)

# Use VMS CRTL
#[.lib]isapipe.obj : [.lib]isapipe.c $(config_h) [.lib]isapipe.h \
#	[.lib]msvc-nothrow.h

# Use VMS CRTL
#[.lib]isatty.obj : [.lib]isatty.c $(config_h) \
#	[.lib]msvc-inval.h [.lib]msvc-nothrow.h

[.lib]isblank.obj : [.lib]isblank.c $(config_h)

#[.lib]isnan.obj : $(isnan_c)

lcl_root:[.lib]isnan.c : src_root:[.lib]isnan.c [.vms]lib_isnan_c.tpu
                    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
                    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.lib]isnand.obj : [.lib]isnand.c $(isnan_c)

[.lib]isnanf.obj : [.lib]isnanf.c $(isnan_c)

[.lib]isnanl.obj : [.lib]isnanl.c $(isnan_c)

[.lib]iswblank.obj : $(config_h)

[.lib]itold.obj : [.lib]itold.c $(config_h)

[.lib]lchown.obj : [.lib]lchown.c $(config_h)

[.lib]ldtoastr.obj : [.lib]ldtoastr.c $(ftoastr_c)

[.lib]linebuffer.obj : [.lib]linebuffer.c $(config_h) \
	[.lib]linebuffer.h [.lib]xalloc.h [.lib]unlocked-io.h

[.lib]link.obj : [.lib]link.c $(config_h)

[.lib]linkat.obj : [.lib]linkat.c $(config_h) \
	[.lib]areadlink.h $(dirname_h) [.lib]filenamecat.h \
	[.lib]openat-priv.h

#  [.lib]relocatable.h not currently used in localcharset.c
[.lib]localcharset.obj : [.lib]localcharset.c $(config_h) \
	[.lib]localcharset.h [.lib]configmake.h

# Use VMS CRTL
#[.lib]localeconv.obj : [.lib]localeconv.c $(config_h)

[.lib]long-options.obj : [.lib]long-options.c $(config_h) \
	[.lib]long-options.h [.lib]version-etc.h [.lib]getopt.h

[.lib]lseek.obj : [.lib]lseek.c $(config_h) [.lib]msvc-nothrow.h

[.lib]lstat.obj : [.lib]lstat.c $(config_h)

[.lib]malloc.obj : [.lib]malloc.c $(config_h)

[.lib]malloca.obj : [.lib]malloca.c $(config_h) $(malloca_h) \
	[.lib]verify.h [.lib]stdint.h

# [.lib]math.h - try to use VMS provided library instead.
[.lib]math.obj : [.lib]math.c $(config_h)

[.lib]mbchar.obj : [.lib]mbchar.c $(config_h) [.lib]mbchar.h

[.lib]mbiter.obj : [.lib]mbiter.c $(config_h) $(mbiter_h)

# Use VMS CRTL
#[.lib]mbrlen.obj : [.lib]mbrlen.c $(config_h)

[.lib]mbrtowc.obj : [.lib]mbrtowc.c $(config_h) \
	[.lib]localcharset.h [.lib]streq.h [.lib]verify.h

[.lib]mbsalign.obj : [.lib]mbsalign.c $(config_h) [.lib]mbsalign.h \
	[.lib]stdint.h

[.lib]mbscasecmp.obj : [.lib]mbscasecmp.c $(config_h) [.lib]mbuiter.h

# Use VMS CRTL
#[.lib]mbsinit.obj : [.lib]mbsinit.c $(config_h) [.lib]verify.h

[.lib]mbslen.obj : [.lib]mbslen.c $(config_h) [.lib]mbuiter.h

[.lib]mbsrtowcs-state.obj : [.lib]mbsrtowcs-state.c $(config_h)

# Use VMS CRTL
#[.lib]mbsrtowcs.obj : [.lib]mbsrtowcs.c $(config_h) \
#	[.lib]strnlen1.h [.lib]mbsrtowcs-impl.h

[.lib]mbsstr.obj : [.lib]mbsstr.c $(config_h) $(malloca_h) \
	[.lib]mbuiter.h [.lib]str-kmp.h

[.lib]mbswidth.obj : [.lib]mbswidth.c $(config_h) [.lib]mbswidth.h

# Use VMS CRTL
#[.lib]mbtowc.obj : [.lib]mbtowc.c $(config_h) [.lib]mbtowc-impl.h

[.lib]mbuiter.obj : [.lib]mbuiter.c $(config_h) [.lib]mbuiter.h

[.lib]md5.obj : [.lib]md5.c $(config_h) $(md5_h) [.lib]unlocked-io.h \
	[.lib]stdint.h [.lib]stdalign.h

[.lib]memcasecmp.obj : [.lib]memcasecmp.c $(config_h) [.lib]memcasecmp.h

# Use VMS CRTL
#[.lib]memchr.obj : [.lib]memchr.c $(config_h)

[.lib]memchr2.obj : [.lib]memchr2.c $(config_h) [.lib]memchr2.h \
	[.lib]stdint.h

[.lib]memcmp2.obj : [.lib]memcmp2.c $(config_h) [.lib]memcmp2.h

[.lib]memcoll.obj : [.lib]memcoll.c $(config_h) [.lib]memcoll.h

[.lib]mempcpy.obj : [.lib]mempcpy.c $(config_h)

[.lib]memrchr.obj : [.lib]memrchr.c $(config_h)

[.lib]mgetgroups.obj : [.lib]mgetgroups.c $(config_h) \
	[.lib]mgetgroups.h [.lib]getugroups.h [.lib]xalloc-oversized.h \
	[.lib]stdint.h

[.lib]mkancesdirs.obj : [.lib]mkancesdirs.c $(config_h) \
	[.lib]mkancesdirs.h $(dirname_h) [.lib]savewd.h

[.lib]mkdir-p.obj : [.lib]mkdir-p.c $(config_h) [.lib]mkdir-p.h \
	[.lib]gettext.h [.lib]dirchownmod.h $(dirname_h) \
	[.lib]error.h [.lib]quote.h [.lib]mkancesdirs.h [.lib]savewd.h

[.lib]mkdir.obj : [.lib]mkdir.c $(config_h) $(dirname_h)

[.lib]mkfifo.obj : [.lib]mkfifo.c $(config_h)

[.lib]mknod.obj : [.lib]mknod.c $(config_h)

[.lib]mkstemp-safer.obj : [.lib]mkstemp-safer.c $(config_h) \
	[.lib]stdlib-safer.h [.lib]unistd-safer.h

# Use VMS CRTL
#[.lib]mkstemp.obj : [.lib]mkstemp.c $(config_h) [.lib]tempname.h

# Use VMS CRTL
# [.lib]mktime.obj : [.lib]mktime.c $(config_h) [.lib]mktime-internal.h

[.lib]modechange.obj : [.lib]modechange.c $(config_h) [.lib]modechange.h \
	[.lib]stat-macros.h [.lib]xalloc.h

# use vms [.lib]stdlib.h
[.lib]mountlist.obj : [.lib]mountlist.c $(config_h) [.lib]mountlist.h \
	[.lib]unlocked-io.h [.lib.sys]mount.h

[.lib]mpsort.obj : [.lib]mpsort.c $(config_h) [.lib]mpsort.h

[.lib]msvc-inval.obj : [.lib]msvc-inval.c $(config_h) [.lib]msvc-inval.h

# Windows only
#[.lib]msvc-nothrow.obj : [.lib]msvc-nothrow.c $(config_h) \
#	[.lib]msvc-nothrow.h [.lib]msvc-inval.h

# Use VMS CRTL
#[.lib]nanosleep.obj : [.lib]nanosleep.c $(config_h) [.lib]intprops.h \
#	[.lib]sig-handler.h [.lib]verify.h

# Use VMS CRTL
#[.lib]nl_langinfo.obj : [.lib]nl_langinfo.c $(config_h)

[.lib]nproc.obj : [.lib]nproc.c $(config_h) [.lib]nproc.h [.lib]c-ctype.h \
	[.lib]sched.h

[.lib]obstack.obj : [.lib]obstack.c $(config_h) [.lib]obstack.h \
	[.lib]gettext.h [.lib]stdint.h

[.lib]offtostr.obj : [.lib]offtostr.c $(anytostr_c)

[.lib]open-safer.obj : [.lib]open-safer.c $(config_h) \
	[.lib]fcntl-safer.h [.lib]unistd-safer.h


# Use VMS CRTL / Use VMS [.lib]fcntl.h
#[.lib]open.obj : [.lib]open.c $(config_h)

[.lib]openat-die.obj : [.lib]openat-die.c $(config_h) [.lib]openat.h \
	[.lib]error.h [.lib]exitfail.h [.lib]gettext.h

[.lib]openat-proc.obj : [.lib]openat-proc.c $(config_h) \
	[.lib]openat-priv.h [.lib]intprops.h

[.lib]openat-safer.obj : [.lib]openat-safer.c $(config_h) \
	[.lib]fcntl-safer.h [.lib]unistd-safer.h

# use VMS [.lib]fcntl.h
[.lib]openat.obj : [.lib]openat.c $(config_h) \
	[.lib]openat.h [.lib]dosname.h [.lib]openat-priv.h [.lib]save-cwd.h

# Use VMS CRTL opendir
#[.lib]opendir-safer.obj : [.lib]opendir-safer.c $(config_h) \
#	[.lib]dirent-safer.h [.lib]unistd-safer.h

# Use VMS CRTL
#[.lib]opendir.obj : [.lib]opendir.c $(config_h) [.lib]dirent-private.h \
#	[.lib]filename.h

[.lib]parse-datetime.obj : [.lib]parse-datetime.c $(config_h) \
	[.lib]parse-datetime.h [.lib]intprops.h [.lib]timespec.h \
	[.lib]verify.h

[.lib]physmem.obj : [.lib]physmem.c $(config_h) [.lib]physmem.h \
	[.vms]vms_pstat_hack.h

[.lib]pipe-safer.obj : [.lib]pipe-safer.c $(config_h) [.lib]unistd-safer.h

[.lib]pipe2-safer.obj : [.lib]pipe2-safer.c $(config_h) \
	[.lib]unistd-safer.h

# pipe2 does not use [.lib]nonblocking.h
[.lib]pipe2.obj : [.lib]pipe2.c $(config_h) [.lib]binary-io.h \
	[.lib]verify.h

[.lib]posixtm.obj : [.lib]posixtm.c $(config_h) [.lib]posixtm.h \
	[.lib]unlocked-io.h

[.lib]posixver.obj : [.lib]posixver.c $(config_h) [.lib]posixver.h

[.lib]printf-args.obj : [.lib]printf-args.c $(config_h) [.lib]printf-args.h

[.lib]printf-frexp.obj : $(printf_frexp_c) $(config_h) \
	[.lib]printf-frexpl.h [.lib]printf-frexp.h [.lib]fpucw.h

[.lib]printf-frexpl.obj : [.lib]printf-frexpl.c $(config_h) \
	[.lib]printf-frexpl.h [.lib]printf-frexp.h $(printf_frexp_c)

[.lib]printf-parse.obj : [.lib]printf-parse.c $(config_h) \
	[.lib]printf-parse.h $(xsize_h) [.lib]c-ctype.h [.lib]stdint.h

[.lib]priv-set.obj : [.lib]priv-set.c $(config_h) [.lib]priv-set.h

#[.lib]progname.obj : [.lib]progname.c $(config_h) [.lib]progname.h
[.lib]vms_progname.obj : [.vms]vms_progname.c [.lib]progname.h

[.lib]propername.obj : [.lib]propername.c $(config_h) \
	[.lib]propername.h [.lib]trim.h [.lib]mbchar.h [.lib]mbuiter.h \
	[.lib]localcharset.h [.lib]c-strcase.h [.lib]xstriconv.h \
	[.lib]xalloc.h [.lib]gettext.h

# $(pthread_h) Use VMS header
[.lib]pthread.obj : [.lib]pthread.c $(config_h)

# Use VMS CRTL
#[.lib]putenv.obj : [.lib]putenv.c $(config_h)

[.lib]quotearg.obj : [.lib]quotearg.c $(config_h) [.lib]quotearg.h \
	[.lib]quote.h [.lib]xalloc.h $(c_strcaseeq_h) \
	[.lib]localcharset.h [.lib]gettext.h

[.lib]raise.obj : [.lib]raise.c $(config_h) [.lib]msvc-inval.h

[.lib]rand-isaac.obj : [.lib]rand-isaac.c $(config_h) $(rand_isaac_h)

[.lib]randint.obj : [.lib]randint.c $(config_h) $(randint_h) \
	[.lib]xalloc.h

[.lib]randperm.obj : [.lib]randperm.c $(config_h) [.lib]hash.h \
	$(randperm_h) [.lib]xalloc.h

[.lib]randread.obj : [.lib]randread.c $(config_h) [.lib]randread.h \
	[.lib]gettext.h $(rand_isaac_h) [.lib]stdio-safer.h \
	[.lib]unlocked-io.h [.lib]xalloc.h [.lib]stdalign.h

[.lib]rawmemchr.obj : [.lib]rawmemchr.c $(config_h)

# use vms [.lib]stdlib.h
[.lib]read-file.obj : [.lib]read-file.c $(config_h) [.lib]read-file.h \

[.lib]read.obj : [.lib]read.c $(config_h) [.lib]msvc-inval.h \
	[.lib]msvc-nothrow.h

# Windows only
#[.lib]readdir.obj : [.lib]readdir.c $(config_h) [.lib]dirent-private.h

[.lib]readlink.obj : [.lib]readlink.c $(config_h)

[.lib]readlinkat.obj : [.lib]readlinkat.c $(config_h) $(at_func_c)

[.lib]readtokens.obj : [.lib]readtokens.c $(config_h) [.lib]readtokens.h \
	[.lib]xalloc.h [.lib]unlocked-io.h

[.lib]readtokens0.obj : [.lib]readtokens0.c $(config_h) $(readtokens0_h)

[.lib]vms_readutmp.obj : [.vms]vms_readutmp.c $(config_h) $(readutmp_h) \
	[.lib]xalloc.h [.lib]unlocked-io.h [.lib]stdint.h

[.lib]realloc.obj : [.lib]realloc.c $(config_h)

# Template routine
#[.lib]regcomp.obj : [.lib]regcomp.c

[.lib]regex.obj : [.lib]regex.c $(config_h) $(regex_internal_h) \
	[.lib]regex_internal.c [.lib]regcomp.c [.lib]regexec.c

#[.lib]regexec.obj : [.lib]regexec.c $(config_h) [.lib]verify.h \
#	[.lib]intprops.h

# Template routine
#[.lib]regex_internal.obj : [.lib]regex_internal.c [.lib]verify.h \
#	[.lib]intprops.h

[.lib]remove.obj : [.lib]remove.c $(config_h)

[.lib]rename.obj : [.lib]rename.c $(config_h) [.lib]dirname.h \
	[.lib]same-inode.h [.vms]vms_pwd_hack.h

# Windows Only?
#[.lib]rewinddir.obj : [.lib]rewinddir.c $(config_h) [.lib]dirent-private.h

[.lib]rmdir.obj : [.lib]rmdir.c $(config_h) [.lib]dosname.h

[.lib]root-dev-ino.obj : [.lib]root-dev-ino.c $(config_h) \
	$(root_dev_ino_h)

[.lib]rpmatch.obj : [.lib]rpmatch.c $(config_h) [.lib]gettext.h

[.lib]safe-read.obj : $(safe_read_c)

[.lib]safe-write.obj : [.lib]safe-write.c $(safe_read_c)

[.lib]same.obj : [.lib]same.c $(config_h) [.lib]same.h \
	$(dirname_h) [.lib]error.h [.lib]same-inode.h

[.lib]save-cwd.obj : [.lib]save-cwd.c $(config_h) [.lib]save-cwd.h \
	$(chdir_long_h) $(unistd___h) [.lib]cloexec.h $(fcntl___h) \
	[.vms]vms_pwd_hack.h

[.lib]savedir.obj : [.lib]savedir.c $(config_h) [.lib]savedir.h \
	$(dirent___h) [.lib]xalloc.h

[.lib]savewd.obj : [.lib]savewd.c $(config_h) [.lib]savewd.h \
	[.lib]dosname.h [.lib]fcntl-safer.h

#[.lib]se-context.obj : [.lib]se-context.c $(config_h)

#[.lib]se-selinux.obj : [.lib]se-selinux.c $(config_h)

# Use VMS CRTL or the terminal replacement routine.
#[.lib]select.obj : [.lib]select.c $(config_h) \
#	[.lib]msvc-nothrow.h

[.lib]selinux-at.obj : [.lib]selinux-at.c $(config_h) \
	$(selinux_at_h) [.lib]openat.h $(dirname_h) \
	[.lib]save-cwd.h [.lib]openat-priv.h $(at_func_c)

[.lib]set-mode-acl.obj : [.lib]set-mode-acl.c \
	$(config_h) $(acl_internal_h) [.lib]gettext.h

[.lib]setenv.obj : [.lib]setenv.c $(config_h) $(malloca_h)

[.lib]settime.obj : [.lib]settime.c $(config_h) [.lib]timespec.h

[.lib]sha1.obj : [.lib]sha1.c $(config_h) $(sha1_h) [.lib]unlocked-io.h \
	[.lib]stdalign.h

[.lib]sha256.obj : [.lib]sha256.c $(config_h) $(sha256_h) \
	[.lib]unlocked-io.h [.lib]stdalign.h

[.lib]sha512.obj : [.lib]sha512.c $(config_h) $(sha512_h) \
	[.lib]unlocked-io.h [.lib]stdalign.h

[.lib]sig-handler.obj : [.lib]sig-handler.c $(config_h) [.lib]sig-handler.h

[.lib]sig2str.obj : [.lib]sig2str.c $(config_h) $(sig2str_h)

# Use VMS CRTL
#[.lib]sigaction.obj : [.lib]sigaction.c $(config_h) [.lib]stdint.h

lcl_root:[.lib]signbitd.c : src_root:[.lib]signbitd.c [.vms]lib_isnan_c.tpu
                    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
                    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.lib]signbitd.obj : lcl_root:[.lib]signbitd.c $(config_h) \
	[.lib]isnand-nolibm.h [.lib]float_plus.h

lcl_root:[.lib]signbitf.c : src_root:[.lib]signbitf.c [.vms]lib_isnan_c.tpu
                    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
                    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.lib]signbitf.obj : lcl_root:[.lib]signbitf.c $(config_h) \
	[.lib]isnanf-nolibm.h [.lib]float_plus.h

lcl_root:[.lib]signbitl.c : src_root:[.lib]signbitl.c [.vms]lib_isnan_c.tpu
                    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
                    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.lib]signbitl.obj : lcl_root:[.lib]signbitl.c $(config_h) \
	[.lib]isnanl-nolibm.h [.lib]float_plus.h

# Use VMS CRTL
#[.lib]sigprocmask.obj : [.lib]sigprocmask.c $(config_h) [.lib]msvc-inval.h

# Use VMS CRTL
#[.lib]snprintf.obj : [.lib]snprintf.c $(config_h) [.lib]vasnprintf.h

[.lib]sockets.obj : [.lib]sockets.c $(config_h) $(sockets_h) \
	[.lib]fd-hook.h [.lib]msvc-nothrow.h [.lib]w32sock.h

[.lib]spawn-pipe.obj : [.lib]spawn-pipe.c $(config_h) \
	[.lib]spawn-pipe.h [.lib]error.h [.lib]fatal-signal.h \
	[.lib]unistd-safer.h [.lib]wait-process.h [.lib]gettext.h \
	[.lib]w32spawn.h $(spawn_h)

[.lib]spawnattr_destroy.obj : [.lib]spawnattr_destroy.c $(config_h) \
	$(spawn_h)

[.lib]spawnattr_init.obj : [.lib]spawnattr_init.c $(config_h) \
	$(spawn_h)

[.lib]spawnattr_setflags.obj : [.lib]spawnattr_setflags.c $(config_h) \
	$(spawn_h)

[.lib]spawnattr_setsigmask.obj : [.lib]spawnattr_setsigmask.c $(config_h) \
	$(spawn_h)

[.lib]spawni.obj : [.lib]spawni.c $(config_h) [.lib]spawn_int.h \
	$(spawn_h)

[.lib]spawnp.obj : [.lib]spawnp.c $(config_h) [.lib]spawn_int.h \
	$(spawn_h)

[.lib]spawn_faction_addclose.obj : [.lib]spawn_faction_addclose.c \
	$(config_h) [.lib]spawn_int.h $(spawn_h)

[.lib]spawn_faction_adddup2.obj : [.lib]spawn_faction_adddup2.c \
	$(config_h) [.lib]spawn_int.h $(spawn_h)

[.lib]spawn_faction_addopen.obj : [.lib]spawn_faction_addopen.c \
	$(config_h) [.lib]spawn_int.h $(spawn_h)

[.lib]spawn_faction_destroy.obj : [.lib]spawn_faction_destroy.c \
	$(config_h) [.lib]spawn.h

[.lib]spawn_faction_init.obj : [.lib]spawn_faction_init.c \
	$(config_h) [.lib]spawn_int.h [.lib]spawn.h

[.lib]stat-time.obj : [.lib]stat-time.c $(config_h) [.lib]stat-time.h

[.lib]stat.obj : [.lib]stat.c $(config_h) [.lib]dosname.h \
	[.lib]verify.h [.lib]pathmax.h

[.lib]statat.obj : [.lib]statat.c $(config_h) [.lib]openat.h

[.lib]stpcpy.obj : [.lib]stpcpy.c $(config_h)

[.lib]stpncpy.obj : [.lib]stpncpy.c $(config_h)

[.lib]strchrnul.obj : [.lib]strchrnul.c $(config_h)

# Use VMS CRTL
#[.lib]strdup.obj : [.lib]strdup.c $(config_h)

# Use VMS CRTL
#[.lib]strerror-override.obj : [.lib]strerror-override.c \
#	$(config_h) [.lib]strerror-override.h

# Use VMS CRTL
#[.lib]strerror.obj : [.lib]strerror.c $(config_h) [.lib]intprops.h \
#	[.lib]strerror-override.h [.lib]verify.h

[.lib]strftime.obj : [.lib]strftime.c $(config_h) [.lib]fprintftime.c \
	[.lib]strftime.c

[.lib]striconv.obj : [.lib]striconv.c $(config_h) [.lib]striconv.h \
	[.lib]c-strcase.h

[.lib]strintcmp.obj : [.lib]strintcmp.c $(config_h) $(strnumcmp_in_h)

[.lib]stripslash.obj : [.lib]stripslash.c $(config_h) $(dirname_h)

# Use VMS CRTL
#[.lib]strncat.obj : [.lib]strncat.c $(config_h)

[.lib]strndup.obj : [.lib]strndup.c $(config_h)

# Use VMS CRTL
#[.lib]strnlen.obj : [.lib]strnlen.c $(config_h)

[.lib]strnlen1.obj : [.lib]strnlen1.c $(config_h) [.lib]strnlen1.h

[.lib]strnumcmp.obj : [.lib]strnumcmp.c $(config_h) $(strnumcmp_in_h)

# Use VMS CRTL
#[.lib]strpbrk.obj : [.lib]strpbrk.c $(config_h)

[.lib]strsignal.obj : [.lib]strsignal.c $(config_h) [.lib]gettext.h \
	[.lib]siglist.h [.lib.glthread]lock.h [.lib.glthread]tls.h

# Use VMS CRTL
#[.lib]strstr.obj : [.lib]strstr.c $(config_h) $(str_two_way_h)

# Use VMS CRTL
#[.lib]strtod.obj : [.lib]strtod.c $(config_h) [.lib]c-ctype.h

[.lib]strtoimax.obj : $(strtoimax_c)

# Use VMS CRTL
#[.lib]strtol.obj : $(strtol_c)

# Use VMS CRTL
#[.lib]strtoll.obj : [.lib]strtoll.c $(strtol_c)

# Use VMS CRTL
#[.lib]strtoul.obj : [.lib]strtoul.c $(strtol_c)

# Use VMS CRTL
#[.lib]strtoull.obj : [.lib]strtoull.c $(strtol_c)

[.lib]strtoumax.obj : [.lib]strtoumax.c $(strtoimax_c)

[.lib]symlink.obj : [.lib]symlink.c $(config_h)

[.lib]sys_socket.obj : [.lib]sys_socket.c $(config_h) \
	[.vms]vms_ioctl_hack.h

[.lib]tempname.obj : [.lib]tempname.c $(config_h) [.lib]tempname.h \
	[.lib]randint.h [.lib]stdint.h

[.lib]timespec.obj : [.lib]timespec.c $(config_h) [.lib]timespec.h

# Use VMS CRTL
#[.lib]time_r.obj : [.lib]time_r.c $(config_h)

[.lib]trim.obj : [.lib]trim.c $(config_h) [.lib]trim.h \
	[.lib]mbchar.h $(mbiter_h) [.lib]xalloc.h

[.lib]u64.obj : [.lib]u64.c $(config_h) $(u64_h)

[.lib]uinttostr.obj : [.lib]uinttostr.c $(anytostr_c)

[.lib]umaxtostr.obj : [.lib]umaxtostr.c $(anytostr_c)

[.lib]uname.obj : [.lib]uname.c $(config_h) [.vms]vms_sysctl_hack.h

[.lib]unicodeio.obj : [.lib]unicodeio.c $(config_h) \
	[.lib]unicodeio.h [.lib]gettext.h [.lib]localcharset.h $(unistr_h)

# [.lib]unistd.h
[.lib]unistd.obj : [.lib]unistd.c $(config_h)

[.lib]unlink.obj : [.lib]unlink.c $(config_h) [.lib]dosname.h

[.lib]unlinkat.obj : [.lib]unlinkat.c $(config_h) [.lib]dosname.h \
	[.lib]openat.h $(at_func_c)

[.lib]unsetenv.obj : [.lib]unsetenv.c $(config_h)

[.lib]userspec.obj : [.lib]userspec.c $(config_h) [.lib]userspec.h \
	[.lib]intprops.h $(inttostr_h) [.lib]xalloc.h $(xstrtol_h) \
	[.lib]gettext.h [.vms]vms_getcwd_hack.h

[.lib]utimecmp.obj : [.lib]utimecmp.c $(config_h) [.lib]utimecmp.h \
	[.lib]hash.h [.lib]intprops.h [.lib]stat-time.h [.lib]utimens.h \
	[.lib]verify.h [.lib]stdint.h

[.lib]utimens.obj : [.lib]utimens.c $(config_h) [.lib]utimens.h \
	[.lib]stat-time.h [.lib]timespec.h

[.lib]utimensat.obj : [.lib]utimensat.c $(config_h) [.lib]stat-time.h \
	[.lib]timespec.h [.lib]utimens.h $(at_func_c)

lcl_root:[.lib]vasnprintf.c : src_root:[.lib]vasnprintf.c [.vms]lib_isnan_c.tpu
                    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
                    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

# Wide char version [.lib]vasnwprintf.h [.lib]wprintf-parse.h
[.lib]vasnprintf.obj : lcl_root:[.lib]vasnprintf.c $(config_h) \
	[.lib]vasnprintf.h \
	[.lib]printf-parse.h $(xsize_h) [.lib]verify.h \
	[.lib]float_plus.h [.lib]isnand-nolibm.h [.lib]isnanl-nolibm.h \
	[.lib]fpucw.h [.lib]isnand-nolibm.h [.lib]printf-frexp.h \
	[.lib]isnanl-nolibm.h [.lib]printf-frexpl.h [.lib]fpucw.h

# Not used [.lib]vasprintf.h
[.lib]vasprintf.obj : [.lib]vasprintf.c $(config_h) \
	[.lib]vasnprintf.h

[.lib]verror.obj : [.lib]verror.c $(config_h) $(verror_h) \
	[.lib]xvasprintf.h [.lib]gettext.h

[.lib]version-etc-fsf.obj : [.lib]version-etc-fsf.c $(config_h) \
	[.lib]version-etc.h

[.lib]version-etc.obj : [.lib]version-etc.c $(config_h) \
	[.lib]version-etc.h [.lib]unlocked-io.h [.lib]gettext.h

# Use VMS CRTL
[.lib]vfprintf.obj : [.lib]vfprintf.c $(config_h) [.lib]vasnprintf.h

# Use VMS CRTL
#[.lib]vprintf.obj : [.lib]vprintf.c $(config_h)

[.lib]wait-process.obj : [.lib]wait-process.c $(config_h) \
	[.lib]wait-process.h [.lib]error.h [.lib]fatal-signal.h \
	[.lib]xalloc.h [.lib]gettext.h

# Use VMS CRTL
#[.lib]waitpid.obj : [.lib]waitpid.c $(config_h)

# Use VMS CRTL
#[.lib]wcrtomb.obj : [.lib]wcrtomb.c $(config_h)

# Use VMS CRTL
#[.lib]wcswidth.obj : [.lib]wcswidth.c $(config_h) [.lib]wcswidth-impl.h

# Use VMS [.lib]wctype.h
[.lib]wctype-h.obj : [.lib]wctype-h.c $(config_h)

# Use VMS CRTL
#[.lib]wcwidth.obj : [.lib]wcwidth.c $(config_h) \
#	[.lib]localcharset.h [.lib]streq.h [.lib]uniwidth.h

[.lib]write-any-file.obj : [.lib]write-any-file.c $(config_h) \
	[.lib]write-any-file.h [.lib]priv-set.h [.lib]root-uid.h \

[.lib]write.obj : [.lib]write.c $(config_h) [.lib]msvc-inval.h \
	[.lib]msvc-nothrow.h

[.lib]xalloc-die.obj : [.lib]xalloc-die.c $(config_h) [.lib]xalloc.h \
	[.lib]error.h [.lib]exitfail.h [.lib]gettext.h

[.lib]xasprintf.obj : [.lib]xasprintf.c $(config_h) [.lib]xvasprintf.h

[.lib]xfreopen.obj : [.lib]xfreopen.c $(config_h) [.lib]xfreopen.h \
	[.lib]error.h [.lib]exitfail.h [.lib]quote.h $(stdio___h) \
	[.lib]gettext.h

[.lib]xfts.obj : [.lib]xfts.c $(config_h) [.lib]xalloc.h $(xfts_h)

[.lib]xgetcwd.obj : [.lib]xgetcwd.c $(config_h) [.lib]xgetcwd.h \
	[.lib]xalloc.h [.vms]vms_pwd_hack.h

[.lib]xgetgroups.obj : [.lib]xgetgroups.c $(config_h) \
	[.lib]mgetgroups.h [.lib]xalloc.h

[.lib]xgethostname.obj : [.lib]xgethostname.c $(config_h) \
	[.lib]xgethostname.h [.lib]xalloc.h

[.lib]xmalloc.obj : [.lib]xmalloc.c $(config_h) [.lib]xalloc.h

[.lib]xmemcoll.obj : [.lib]xmemcoll.c $(config_h) [.lib]gettext.h \
	[.lib]error.h [.lib]exitfail.h [.lib]memcoll.h [.lib]quotearg.h \
	[.lib]xmemcoll.h

[.lib]xnanosleep.obj : [.lib]xnanosleep.c $(config_h) \
	[.lib]xnanosleep.h

[.lib]xprintf.obj : [.lib]xprintf.c $(config_h) [.lib]xprintf.h \
	[.lib]error.h [.lib]exitfail.h [.lib]gettext.h

[.lib]xreadlink.obj : [.lib]xreadlink.c $(config_h) [.lib]xreadlink.h \
	[.lib]areadlink.h [.lib]xalloc.h

[.lib]xsize.obj : [.lib]xsize.c $(config_h) $(xsize_h)

[.lib]xstriconv.obj : [.lib]xstriconv.c $(config_h) [.lib]xstriconv.h \
	[.lib]striconv.h [.lib]xalloc.h

[.lib]xstrndup.obj : [.lib]xstrndup.c $(config_h) [.lib]xstrndup.h \
	[.lib]xalloc.h

[.lib]xstrtod.obj : [.lib]xstrtod.c $(config_h) [.lib]xstrtod.h

[.lib]xstrtoimax.obj : [.lib]xstrtoimax.c $(xstrtol_c)

[.lib]xstrtol-error.obj : [.lib]xstrtol-error.c $(config_h) \
	$(xstrtol_h) [.lib]error.h [.lib]exitfail.h [.lib]gettext.h

[.lib]xstrtol.obj : $(xstrtol_c)

[.lib]xstrtold.obj : [.lib]xstrtold.c $(xstrtol_c)

[.lib]xstrtoul.obj : [.lib]xstrtoul.c $(xstrtol_c)

[.lib]xstrtoumax.obj : [.lib]xstrtoumax.c $(xstrtol_c)

[.lib]xtime.obj : [.lib]xtime.c $(config_h) [.lib]xtime.h

[.lib]xvasprintf.obj : [.lib]xvasprintf.c $(config_h) \
	[.lib]xvasprintf.h [.lib]xalloc.h $(xsize_h)

[.lib]yesno.obj : [.lib]yesno.c $(config_h) [.lib]yesno.h

[.lib.glthread]lock.obj : [.lib.glthread]lock.c $(config_h) \
	[.lib.glthread]lock.h

[.lib.glthread]threadlib.obj : [.lib.glthread]threadlib.c \
	$(config_h)

[.lib.glthread]tls.obj : [.lib.glthread]tls.c $(config_h) \
	[.lib.glthread]tls.h

[.lib.unistr]u8-mbtoucr.obj : [.lib.unistr]u8-mbtoucr.c \
	$(config_h) $(unistr_h)

[.lib.unistr]u8-uctomb-aux.obj : [.lib.unistr]u8-uctomb-aux.c \
	$(config_h) $(unistr_h)

[.lib.unistr]u8-uctomb.obj : [.lib.unistr]u8-uctomb.c $(config_h) \
	$(unistr_h)

[.lib.uniwidth]width.obj : [.lib.uniwidth]width.c $(config_h) \
	[.lib]uniwidth.h $(cjk_h)

[.src]vms_crtl_init.obj : [.vms]vms_crtl_init.c
	$(CC)$(cflagsx)/define="GNV_UNIX_TOOL=1" \
	/object=$(MMS$TARGET) $(MMS$SOURCE)

[.lib]vms_gethostid.obj : [.vms]vms_gethostid.c

[.lib]vms_getmntinfo.obj : [.vms]vms_getmntinfo.c [.lib.sys]mount.h

[.lib]vms_term.obj : [.vms]vms_term.c [.vms]vms_term.h

[.lib]vms_terminal_io.obj : [.vms]vms_terminal_io.c [.vms]vms_terminal_io.h \
	[.vms]vms_lstat_hack.h

[.lib]gnv_vms_iconv_wrapper.obj : [.vms]gnv_vms_iconv_wrapper.c

[.src]version.obj : [.src]version.c

[.src]version.c : [.vms]version_c.com sys$disk:[]configure.
	$ @[.vms]version_c.com

[.src]version.h : [.vms]version_h.com
	$ @[.vms]version_h.com

[.src]uname.obj : [.src]uname.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]quote.h [.src]uname.h

[.src]uname-arch.obj : [.src]uname-arch.c [.src]uname.h

[.src]arch$(EXEEXT) : $(src_arch_OBJECTS) $(src_arch_DEPENDENCIES) \
		$(EXTRA_src_arch_DEPENDENCIES)
	link/exe=$(MMS$TARGET) [.src]uname.obj, [.src]uname-arch.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]base64.obj : [.src]base64.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fadvise.h $(xstrtol_h) [.lib]quote.h [.lib]quotearg.h \
	[.lib]xfreopen.h [.lib]base64.h

[.src]base64$(EXEEXT) : $(src_base64_OBJECTS) $(src_base64_DEPENDENCIES) \
		$(EXTRA_src_base64_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]base64.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]basename.obj : [.src]basename.c $(config_h) [.lib]error.h \
	[.lib]quote.h

[.src]basename$(EXEEXT) : $(src_basename_OBJECTS) $(src_basename_DEPENDENCIES) \
		$(EXTRA_src_basename_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]basename.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]cat.obj : [.src]cat.c $(config_h) $(system_h) $(ioblksize_h) \
	[.lib]error.h [.lib]fadvise.h [.lib]full-write.c [.lib]quote.h \
	[.lib]safe-read.h [.lib]xfreopen.h sys$disk:[.vms]vms_ioctl_hack.h

[.src]cat$(EXEEXT) : $(src_cat_OBJECTS) $(src_cat_DEPENDENCIES) \
		$(EXTRA_src_cat_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]cat.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]chcon.obj : [.src]chcon.c $(config_h) $(system_h) [.lib]dev-ino.h \
	[.lib]error.h [.lib]ignore-value.h [.lib]quote.h [.lib]quotearg.h \
	$(root_dev_ino_h) $(xfts_h) [.lib.selinux]selinux.h \
	[.lib.selinux]context.h

[.src]chcon$(EXEEXT) : $(src_chcon_OBJECTS) $(src_chcon_DEPENDENCIES) \
		$(EXTRA_src_chcon_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]chcon.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]chgrp.obj : [.src]chgrp.c $(config_h) $(system_h) $(chown_core_h) \
	[.lib]error.h [.lib]fts_.h [.lib]quote.h $(root_dev_ino_h) \
	$(xstrtol_h)

[.src]chown-core.obj : [.src]chown-core.c $(config_h) $(system_h) \
	[.lib]error.h $(chown_core_h) [.lib]ignore-value.h [.lib]quote.h \
	$(root_dev_ino_h) $(xfts_h) [.vms]vms_pwd_hack.h

[.src]chgrp$(EXEEXT) : $(src_chgrp_OBJECTS) $(src_chgrp_DEPENDENCIES) \
		$(EXTRA_src_chgrp_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]chgrp.obj, [.src]chown-core.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]chmod.obj : [.src]chmod.c $(config_h) $(system_h) [.lib]dev-ino.h \
	[.lib]error.h [.lib]filemode.h [.lib]ignore-value.h \
	[.lib]modechange.h [.lib]quote.h [.lib]quotearg.h \
	$(root_dev_ino_h) $(xfts_h)

[.src]chmod$(EXEEXT) : $(src_chmod_OBJECTS) $(src_chmod_DEPENDENCIES) \
		$(EXTRA_src_chmod_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]chmod.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]chown.obj : [.src]chown.c  $(config_h) \
	$(system_h) $(chown_core_h) \
	[.lib]error.h [.lib]fts_.h [.lib]quote.h \
	$(root_dev_ino_h) [.lib]userspec.h

[.src]chown$(EXEEXT) : $(src_chown_OBJECTS) $(src_chown_DEPENDENCIES) \
		$(EXTRA_src_chown_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]chown.obj, [.src]chown-core.obj,\
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]chroot.obj : [.src]chroot.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]quote.h [.lib]userspec.h $(xstrtol_h)

[.src]chroot$(EXEEXT) : $(src_chroot_OBJECTS) $(src_chroot_DEPENDENCIES) \
		$(EXTRA_src_chroot_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]chroot.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]cksum.obj : [.src]cksum.c $(config_h) $(system_h) [.lib]fadvise.h \
	[.lib]xfreopen.h [.lib]long-options.h [.lib]error.h

[.src]cksum$(EXEEXT) : $(src_cksum_OBJECTS) $(src_cksum_DEPENDENCIES) \
		$(EXTRA_src_cksum_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]cksum.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]comm.obj : [.src]comm.c $(config_h) $(system_h) \
	[.lib]linebuffer.h [.lib]error.h [.lib]fadvise.h \
	[.lib]hard-locale.h [.lib]quote.h $(stdio___h) \
	[.lib]memcmp2.h [.lib]xmemcoll.h

[.src]comm$(EXEEXT) : $(src_comm_OBJECTS) $(src_comm_DEPENDENCIES) \
		$(EXTRA_src_comm_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]comm.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]cp.obj : [.src]cp.c $(config_h) $(system_h) $(argmatch_h) \
	[.lib]backupfile.h $(copy_h) [.src]cp-hash.h [.lib]error.h \
	[.lib]filenamecat.h [.lib]ignore-value.h [.lib]quote.h \
	[.lib]stat-time.h [.lib]quote.h [.lib]utimens.h [.lib]acl.h \
	[.lib.selinux]selinux.h

[.src]copy.obj : [.src]copy.c $(config_h) $(system_h) [.lib]acl.h \
	[.lib]backupfile.h [.lib]buffer-lcm.h [.lib]canonicalize.h \
	$(copy_h) [.src]cp-hash.h [.src]extent-scan.h [.lib]error.h \
	[.lib]fadvise.h $(fcntl__h) [.src]fiemap.h $(file_set_h) \
	[.lib]filemode.h [.lib]filenamecat.h [.lib]full-write.h \
	[.lib]hash-triple.h [.lib]ignore-value.h $(ioblksize_h) \
	[.lib]quote.h [.lib]same.h [.lib]savedir.h [.lib]stat-time.h \
	[.lib]utimecmp.h [.lib]utimens.h [.lib]write-any-file.h \
	[.lib]areadlink.h [.lib]yesno.h $(verror_h) \
	sys$disk:[.vms]vms_ioctl_hack.h sys$disk:[.vms]vms_rename_hack.h

[.src]src_ginstall-copy.obj : [.src]copy.c $(config_h) \
	$(system_h) [.lib]acl.h \
	[.lib]backupfile.h [.lib]buffer-lcm.h [.lib]canonicalize.h \
	$(copy_h) [.src]cp-hash.h [.src]extent-scan.h [.lib]error.h \
	[.lib]fadvise.h $(fcntl__h) [.src]fiemap.h $(file_set_h) \
	[.lib]filemode.h [.lib]filenamecat.h [.lib]full-write.h \
	[.lib]hash-triple.h [.lib]ignore-value.h $(ioblksize_h) \
	[.lib]quote.h [.lib]same.h [.lib]savedir.h [.lib]stat-time.h \
	[.lib]utimecmp.h [.lib]utimens.h [.lib]write-any-file.h \
	[.lib]areadlink.h [.lib]yesno.h $(verror_h)

[.src]cp-hash.obj : [.src]cp-hash.c $(config_h) $(system_h) [.lib]hash.h \
	[.src]cp-hash.h

[.src]src_ginstall-cp-hash.obj : [.src]cp-hash.c $(config_h) \
	$(system_h) [.lib]hash.h [.src]cp-hash.h

[.src]extent-scan.obj : [.src]extent-scan.c $(config_h) $(system_h) \
	[.src]extent-scan.h $(xstrtol_h) sys$disk:[.vms]vms_ioctl_hack.h

[.src]src_ginstall-extent-scan.obj : [.src]extent-scan.c $(config_h) \
	$(system_h) [.src]extent-scan.h $(xstrtol_h)

[.src]cp$(EXEEXT) : $(src_cp_OBJECTS) $(src_cp_DEPENDENCIES) \
		$(EXTRA_src_cp_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]cp.obj, [.src]copy.obj, \
		[.src]extent-scan.obj, [.src]cp-hash.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]csplit.obj : [.src]csplit.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]fd-reopen.h [.lib]quote.h [.lib]safe-read.h \
	$(stdio___h) $(xstrtol_h)

[.src]csplit$(EXEEXT) : $(src_csplit_OBJECTS) $(src_csplit_DEPENDENCIES) \
		$(EXTRA_src_csplit_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]csplit.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]cut.obj : [.src]cut.c $(config_h) $(signal_h) [.lib]error.h \
	[.lib]fadvise.h [.lib]getndelim2.h [.lib]hash.h \
	[.lib]quote.h [.lib]xstrndup.h

[.src]cut$(EXEEXT) : $(src_cut_OBJECTS) $(src_cut_DEPENDENCIES) \
		$(EXTRA_src_cut_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]cut.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]date.obj : [.src]date.c $(config_h) $(system_h) $(argmatch_h) \
	[.lib]error.h [.lib]parse-datetime.h [.lib]posixtm.h \
	[.lib]quote.h [.lib]stat-time.h [.lib]fprintftime.h

[.src]date$(EXEEXT) : $(src_date_OBJECTS) $(src_date_DEPENDENCIES) \
		$(EXTRA_src_date_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]date.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]dd.obj : [.src]dd.c $(config_h) $(system_h) [.lib]close-stream.h \
	$(gethrxtime_h) $(human_h) [.lib]long-options.h [.lib]error.h \
	[.lib]fd-reopen.h [.lib]quote.h [.lib]quotearg.h \
	$(xstrtol_h) [.lib]xtime.h sys$disk:[.vms]vms_ioctl_hack.h

[.src]dd$(EXEEXT) : $(src_dd_OBJECTS) $(src_dd_DEPENDENCIES) \
	$(EXTRA_src_dd_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]dd.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]df.obj : [.src]df.c $(config_h) $(system_h) [.lib]canonicalize.h \
	[.lib]error.h $(fsusage_h) $(human_h) [.lib]mbsalign.h \
	[.lib]mbswidth.h [.lib]mountlist.h [.lib]quote.h \
	[.src]find-mount-point.h

[.src]find-mount-point.obj : [.src]find-mount-point.c $(config_h) \
	$(system_h) [.lib]error.h [.lib]quote.h [.lib]save-cwd.h \
	[.lib]xgetcwd.h [.src]find-mount-point.h [.vms]vms_pwd_hack.h

[.src]df$(EXEEXT) : $(src_df_OBJECTS) $(src_df_DEPENDENCIES) \
		$(EXTRA_src_df_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]df.obj, [.src]find-mount-point.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]ls.obj : [.src]ls.c $(config_h) $(termios_h) [.lib.selinux]selinux.h \
	$(system_h) [.lib]acl.h $(argmatch_h) [.lib]dev-ino.h \
	[.lib]error.h [.lib]filenamecat.h [.lib]hard-locale.h \
	[.lib]hash.h $(human_h) [.lib]filemode.h [.lib]filevercmp.h \
	[.lib]idcache.h [.src]ls.h [.lib]mbswidth.h [.lib]mpsort.h \
	[.lib]obstack.h [.lib]quote.h [.lib]quotearg.h [.lib]stat-size.h \
	[.lib]stat-time.h [.lib]strftime.h $(xstrtol_h) \
	[.lib]areadlink.h [.lib]mbsalign.h sys$disk:[.vms]vms_ioctl_hack.h

[.src]ls-dir.obj : [.src]ls-dir.c [.src]ls.h

[.src]dir$(EXEEXT) : $(src_dir_OBJECTS) $(src_dir_DEPENDENCIES) \
		$(EXTRA_src_dir_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]ls.obj, [.src]ls-dir.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]dircolors.obj : [.src]dircolors.c $(config_h) $(system_h) \
	[.src]dircolors.c [.lib]c-strcase.h [.lib]error.h \
	[.lib]obstack.h [.lib]quote.h $(stdio___h) [.lib]xstrndup.h

[.src]dircolors$(EXEEXT) : $(src_dircolors_OBJECTS) \
		$(src_dircolors_DEPENDENCIES) \
		$(EXTRA_src_dircolors_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]dircolors.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]dirname.obj : [.src]dirname.c $(config_h) $(system_h) [.lib]error.h

[.src]dirname$(EXEEXT) : $(src_dirname_OBJECTS) $(src_dirname_DEPENDENCIES) \
		$(EXTRA_src_dirname_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]dirname.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]du.obj : [.src]du.c $(config_h) $(system_h) $(argmatch_h) \
	$(argv_iter_h) [.lib]di-set.h [.lib]error.h [.lib]exclude.h \
	[.lib]fprintftime.h $(human_h) [.lib]mountlist.h \
	[.lib]quote.h [.lib]quotearg.h [.lib]stat-size.h \
	[.lib]stat-time.h $(stdio___h) $(xfts_h) $(xstrtol_h)

[.src]du$(EXEEXT) : $(src_du_OBJECTS) $(src_du_DEPENDENCIES) \
		$(EXTRA_src_du_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]du.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]echo.obj : [.src]echo.c $(config_h) $(system_h)

[.src]echo$(EXEEXT) : $(src_echo_OBJECTS) $(src_echo_DEPENDENCIES) \
		$(EXTRA_src_echo_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]echo.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]env.obj : [.src]env.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]quote.h

[.src]env$(EXEEXT) : $(src_env_OBJECTS) $(src_env_DEPENDENCIES) \
		$(EXTRA_src_env_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]env.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]expand.obj : [.src]expand.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fadvise.h [.lib]quote.h [.lib]xstrndup.h

[.src]expand$(EXEEXT) : $(src_expand_OBJECTS) $(src_expand_DEPENDENCIES) \
		$(EXTRA_src_expand_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]expand.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib

[.src]expr.obj : [.src]expr.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]long-options.h [.lib]quotearg.h [.lib]strnumcmp.h \
	$(xstrtol_h)

[.src]expr$(EXEEXT) : $(src_expr_OBJECTS) $(src_expr_DEPENDENCIES) \
		$(EXTRA_src_expr_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]expr.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]factor.obj : [.src]factor.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]quote.h [.lib]readtokens.h $(xstrtol_h) [.src]longlong.h \
	[.src]primes.h

[.src]factor$(EXEEXT) : $(src_factor_OBJECTS) $(src_factor_DEPENDENCIES) \
		$(EXTRA_src_factor_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]factor.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]false.obj : [.src]false.c $(true_c)

[.src]false$(EXEEXT) : $(src_false_OBJECTS) $(src_false_DEPENDENCIES) \
		$(EXTRA_src_false_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]false.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]fmt.obj : [.src]fmt.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fadvise.h [.lib]quote.h $(xstrtol_h)

[.src]fmt$(EXEEXT) : $(src_fmt_OBJECTS) $(src_fmt_DEPENDENCIES) \
		$(EXTRA_src_fmt_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]fmt.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]fold.obj : [.src]fold.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fadvise.h [.lib]quote.h $(xstrtol_h)

[.src]fold$(EXEEXT) : $(src_fold_OBJECTS) $(src_fold_DEPENDENCIES) \
		$(EXTRA_src_fold_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]fold.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]getlimits.obj : [.src]getlimits.c $(config_h) $(system_h) \
	[.lib]long-options.h

[.src]getlimits$(EXEEXT) : $(src_getlimits_OBJECTS) \
		$(src_getlimits_DEPENDENCIES) \
		$(EXTRA_src_getlimits_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]getlimits.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]src_ginstall-install.obj : [.src]install.c $(config_h) \
	[.lib.selinux]selinux.h $(system_h) [.lib]backupfile.h \
	[.lib]error.h [.src]cp-hash.h \
	$(copy_h) [.lib]filenamecat.h [.lib]full-read.h [.lib]mkdir-p.h \
	[.lib]modechange.h [.src]prog-fprintf.h [.lib]quote.h \
	[.lib]quotearg.h [.lib]savewd.h [.lib]stat-time.h \
	[.lib]utimens.h $(xstrtol_h) [.vms]vms_pwd_hack.h

[.src]src_ginstall-prog-fprintf.obj : [.src]prog-fprintf.c $(config_h) \
	$(system_h) [.src]prog-fprintf.h

[.src]install$(EXEEXT) : $(src_ginstall_OBJECTS) \
		$(src_ginstall_DEPENDENCIES) \
		$(EXTRA_src_ginstall_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]src_ginstall-install.obj, \
		[.src]src_ginstall-prog-fprintf.obj, \
		[.src]src_ginstall-copy.obj, \
		[.src]src_ginstall-cp-hash.obj, \
		[.src]src_ginstall-extent-scan.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]groups.obj : [.src]groups.c $(config_h) $(system_h) \
	[.lib]error.h [.src]group-list.h [.vms]vms_pwd_hack.h


[.src]group-list.obj : [.src]group-list.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]mgetgroups.h [.lib]quote.h [.src]group-list.h \
	[.vms]vms_pwd_hack.h

[.src]groups$(EXEEXT) : $(src_groups_OBJECTS) $(src_groups_DEPENDENCIES) \
		$(EXTRA_src_groups_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]groups.obj, [.src]group-list.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib

[.src]head.obj : [.src]head.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]full-read.h [.lib]quote.h [.lib]safe-read.h \
	[.lib]xfreopen.h $(xstrtol_h)

[.src]head$(EXEEXT) : $(src_head_OBJECTS) $(src_head_DEPENDENCIES) \
	$(EXTRA_src_head_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]head.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]hostid.obj : [.src]hostid.c $(config_h) $(system_h) \
	[.lib]long-options.h [.lib]error.h [.lib]quote.h \
	[.vms]vms_pwd_hack.h

[.src]hostid$(EXEEXT) : $(src_hostid_OBJECTS) $(src_hostid_DEPENDENCIES) \
		$(EXTRA_src_hostid_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]hostid.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]hostname.obj : [.src]hostname.c $(config_h) $(system_h) \
	[.lib]long-options.h [.lib]error.h [.lib]quote.h \
	[.lib]xgethostname.h

[.src]hostname$(EXEEXT) : $(src_hostname_OBJECTS) \
		$(src_hostname_DEPENDENCIES) \
		$(EXTRA_src_hostname_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]hostname.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]id.obj : [.src]id.c $(config_h) $(system_h) \
	[.lib.selinux]selinux.h [.lib]error.h \
	[.lib]mgetgroups.h [.lib]quote.h [.src]group-list.h

[.src]id$(EXEEXT) : $(src_id_OBJECTS) $(src_id_DEPENDENCIES) \
		$(EXTRA_src_id_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]id.obj, [.src]group-list.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]join.obj : [.src]join.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]fadvise.h [.lib]hard-locale.h \
	[.lib]linebuffer.h [.lib]memcasecmp.h [.lib]quote.h \
	$(stdio___h) [.lib]xmemcoll.h $(xstrtol_h) $(argmatch_h)

[.src]join$(EXEEXT) : $(src_join_OBJECTS) $(src_join_DEPENDENCIES) \
		$(EXTRA_src_join_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]join.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]kill.obj : [.src]kill.c $(config_h) $(system_h) \
	[.lib]error.h $(sig2str_h) [.src]operand2sig.h

[.src]operand2sig.obj : [.src]operand2sig.c $(config_h) $(system_h) \
	[.lib]error.h $(sig2str_h) [.src]operand2sig.h

[.src]kill$(EXEEXT) : $(src_kill_OBJECTS) $(src_kill_DEPENDENCIES) \
		$(EXTRA_src_kill_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]kill.obj, [.src]operand2sig.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]libstdbuf_so$(EXEEXT) : $(src_libstdbuf_so_OBJECTS) \
		$(src_libstdbuf_so_DEPENDENCIES) \
		$(EXTRA_src_libstdbuf_so_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"

[.src]link.obj : [.src]link.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]long-options.h [.lib]quote.h

[.src]link$(EXEEXT) : $(src_link_OBJECTS) $(src_link_DEPENDENCIES) \
		$(EXTRA_src_link_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]link.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]ln.obj : [.src]ln.c $(config_h) $(system_h) [.lib]backupfile.h \
	[.lib]error.h [.lib]filenamecat.h [.lib]same.h [.lib]yesno.h \
	[.lib]canonicalize.h

[.src]relpath.obj : [.src]relpath.c $(config_h) $(system_h) \
	[.src]relpath.h

[.src]ln$(EXEEXT) : $(src_ln_OBJECTS) $(src_ln_DEPENDENCIES) \
		$(EXTRA_src_ln_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]ln.obj, [.src]relpath.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]logname.obj : [.src]logname.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]long-options.h [.lib]quote.h

[.src]logname$(EXEEXT) : $(src_logname_OBJECTS) \
		$(src_logname_DEPENDENCIES) \
		$(EXTRA_src_logname_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]logname.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]ls-ls.obj : [.src]ls-ls.c [.src]ls.c

[.src]ls$(EXEEXT) : $(src_ls_OBJECTS) $(src_ls_DEPENDENCIES) \
		$(EXTRA_src_ls_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]ls.obj, [.src]ls-ls.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]make-prime-list.obj : [.src]make-prime-list.c $(config_h)

[.src]make-prime-list$(EXEEXT) : $(src_make_prime_list_OBJECTS) \
		$(src_make_prime_list_DEPENDENCIES) \
		$(EXTRA_src_make_prime_list_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]make-prime-list.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]src_md5sum-md5sum.obj : [.src]md5sum.c $(config_h) $(system_h) \
	$(md5_h) $(sha1_h) $(sha256_h) $(sha512_h) [.lib]error.h \
	[.lib]fadvise.h $(stdio___h) [.lib]xfreopen.h
   $define/user glthread sys$disk:[.lib.glthread]
   $define/user selinux sys$disk:[.lib.selinux]
   $define/user decc$user_include sys$disk:[.src],sys$disk:[.lib.uniwidth]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),HASH_ALGO_MD5=1) \
	/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.src]md5sum$(EXEEXT) : $(src_md5sum_OBJECTS) $(src_md5sum_DEPENDENCIES) \
		$(EXTRA_src_md5sum_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]src_md5sum-md5sum.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]mkdir.obj : [.src]mkdir.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]mkdir-p.h [.lib]modechange.h [.src]prog-fprintf.h \
	[.lib]quote.h [.lib]savewd.h

[.src]prog-fprintf.obj : [.src]prog-fprintf.c $(config_h) $(system_h) \
	[.src]prog-fprintf.h

[.src]mkdir$(EXEEXT) : $(src_mkdir_OBJECTS) $(src_mkdir_DEPENDENCIES) \
		$(EXTRA_src_mkdir_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]mkdir.obj, prog-fprintf.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]mkfifo.obj : [.src]mkfifo.c $(config_h) $(system_h) [.lib]error.h \
	[.lib.selinux]selinux.h [.lib]modechange.h [.lib]quote.h

[.src]mkfifo$(EXEEXT) : $(src_mkfifo_OBJECTS) $(src_mkfifo_DEPENDENCIES) \
		$(EXTRA_src_mkfifo_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]mkfifo.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]mknod.obj : [.src]mknod.c $(config_h) $(system_h) \
	[.lib.selinux]selinux.h [.lib]error.h [.lib]modechange.h \
	[.lib]quote.h $(xstrtol_h)

[.src]mknod$(EXEEXT) : $(src_mknod_OBJECTS) $(src_mknod_DEPENDENCIES) \
		$(EXTRA_src_mknod_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]mknod.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]mktemp.obj : [.src]mktemp.c $(config_h) $(system_h) \
	[.lib]close-stream.h [.lib]error.h [.lib]filenamecat.h \
	[.lib]quote.h $(stdio___h) [.lib]tempname.h

[.src]mktemp$(EXEEXT) : $(src_mktemp_OBJECTS) $(src_mktemp_DEPENDENCIES) \
		$(EXTRA_src_mktemp_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]mktemp.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]mv.obj : [.src]mv.c $(config_h) [.lib.selinux]selinux.h \
	$(system_h) [.lib]backupfile.h $(copy_h) [.src]cp-hash.h \
	[.lib]error.h [.lib]filenamecat.h [.lib]quote.h \
	[.src]remove.h $(root_dev_ino_h) [.lib]priv-set.h

[.src]remove.obj : [.src]remove.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]file-type.h [.lib]ignore-value.h \
	[.lib]quote.h [.src]remove.h $(root_dev_ino_h) \
	[.lib]write-any-file.h $(xfts_h) [.lib]yesno.h

[.src]mv$(EXEEXT) : $(src_mv_OBJECTS) $(src_mv_DEPENDENCIES) \
		$(EXTRA_src_mv_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]mv.obj, [.src]remove.obj, \
		[.src]cp-hash.obj, [.src]copy.obj, \
		[.src]extent-scan.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]nice.obj : [.src]nice.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]quote.h $(xstrtol_h)

[.src]nice$(EXEEXT) : $(src_nice_OBJECTS) $(src_nice_DEPENDENCIES) \
		$(EXTRA_src_nice_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]nice.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]nl.obj : [.src]nl.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fadvise.h [.lib]linebuffer.h [.lib]quote.h \
	$(xstrtol_h)

[.src]nl$(EXEEXT) : $(src_nl_OBJECTS) $(src_nl_DEPENDENCIES) \
		$(EXTRA_src_nl_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]nl.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]nohup.obj : [.src]nohup.c $(config_h) $(system_h) \
	[.lib]cloexec.h [.lib]error.h [.lib]filenamecat.h \
	[.lib]fd-reopen.h [.lib]long-options.h [.lib]quote.h \
	$(unistd___h)

[.src]nohup$(EXEEXT) : $(src_nohup_OBJECTS) $(src_nohup_DEPENDENCIES) \
		$(EXTRA_src_nohup_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]nohup.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]nproc.obj : [.src]nproc.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]nproc.h [.lib]quote.h $(xstrtol_h)

[.src]nproc$(EXEEXT) : $(src_nproc_OBJECTS) $(src_nproc_DEPENDENCIES) \
		$(EXTRA_src_nproc_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]nproc.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]numfmt.obj : [.src]numfmt.c $(config_h) [.lib]mbsalign.h \
	$(argmatch_h) [.lib]error.h [.lib]quote.h $(system_h) \
	$(xstrtol_h) [.lib]xstrndup.h

[.src]numfmt$(EXEEXT) : $(src_numfmt_OBJECTS) $(src_numfmt_DEPENDENCIES) \
		$(EXTRA_src_numfmt_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]numfmt.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]od.obj : [.src]od.c $(config_h) $(system_h) [.lib]error.h \
	$(ftoastr_h) [.lib]quote.h [.lib]xfreopen.h [.lib]xprintf.h \
	$(xstrtol_h)

[.src]od$(EXEEXT) : $(src_od_OBJECTS) $(src_od_DEPENDENCIES) \
		$(EXTRA_src_od_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]od.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]paste.obj : [.src]paste.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fadvise.h [.lib]quotearg.h

[.src]paste$(EXEEXT) : $(src_paste_OBJECTS) $(src_paste_DEPENDENCIES) \
		$(EXTRA_src_paste_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]paste.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]pathchk.obj : [.src]pathchk.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]quote.h [.lib]quotearg.h

[.src]pathchk$(EXEEXT) : $(src_pathchk_OBJECTS) $(src_pathchk_DEPENDENCIES) \
		$(EXTRA_src_pathchk_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]pathchk.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]pinky.obj : [.src]pinky.c $(config_h) $(system_h) \
	[.lib]canon-host.h [.lib]error.h [.lib]hard-locale.h \
	$(readutmp_h) [.vms]vms_pwd_hack.h

[.src]pinky$(EXEEXT) : $(src_pinky_OBJECTS) $(src_pinky_DEPENDENCIES) \
		$(EXTRA_src_pinky_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET)/notraceback [.src]pinky.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]pr.obj : [.src]pr.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fadvise.h [.lib]hard-locale.h [.lib]mbswidth.h \
	[.lib]quote.h [.lib]stat-time.h $(stdio___h) [.lib]strftime.h \
	$(xstrtol_h)

[.src]pr$(EXEEXT) : $(src_pr_OBJECTS) $(src_pr_DEPENDENCIES) \
		$(EXTRA_src_pr_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]pr.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]printenv.obj : [.src]printenv.c $(config_h) $(system_h)

[.src]printenv$(EXEEXT) : $(src_printenv_OBJECTS) \
		$(src_printenv_DEPENDENCIES) \
		$(EXTRA_src_printenv_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]printenv.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]printf.obj : [.src]printf.c $(config_h) $(system-h) \
	[.lib]c-strtod.h [.lib]error.h [.lib]quote.h \
	[.lib]unicodeio.h [.lib]xprintf.h

[.src]printf$(EXEEXT) : $(src_printf_OBJECTS) $(src_printf_DEPENDENCIES) \
		$(EXTRA_src_printf_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]printf.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]ptx.obj : [.src]ptx.c $(config_h) $(system_h) $(argmatch_h) \
	[.lib]diacrit.h [.lib]error.h [.lib]fadvise.h \
	[.lib]quote.h [.lib]quotearg.h [.lib]read-file.h \
	$(stdio___h) $(xstrtol_h)

[.src]ptx$(EXEEXT) : $(src_ptx_OBJECTS) $(src_ptx_DEPENDENCIES) \
		$(EXTRA_src_ptx_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]ptx.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]pwd.obj : [.src]pwd.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]quote.h $(root_dev_ino_h) [.lib]xgetcwd.h [.vms]vms_pwd_hack.h

[.src]pwd$(EXEEXT) : $(src_pwd_OBJECTS) $(src_pwd_DEPENDENCIES) \
		$(EXTRA_src_pwd_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]pwd.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]readlink.obj : [.src]readlink.c $(config_h) $(system_h) \
	[.lib]canonicalize.h [.lib]error.h [.lib]areadlink.h

[.src]readlink$(EXEEXT) : $(src_readlink_OBJECTS) \
		$(src_readlink_DEPENDENCIES) \
		$(EXTRA_src_readlink_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]readlink.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]realpath.obj : [.src]realpath.c $(config_h) $(system_h) \
	[.lib]canonicalize.h [.lib]error.h [.lib]quote.h \
	[.src]relpath.h

[.src]realpath$(EXEEXT) : $(src_realpath_OBJECTS) \
		$(src_realpath_DEPENDENCIES) \
		$(EXTRA_src_realpath_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]realpath.obj, relpath.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]rm.obj : [.src]rm.c $(config_h) $(system_h) $(argmatch_h) \
	[.lib]error.h [.lib]quote.h [.lib]quotearg.h \
	$(remove_h) $(root_dev_ino_h) [.lib]yesno.h [.lib]priv-set.h

[.src]rm$(EXEEXT) : $(src_rm_OBJECTS) $(src_rm_DEPENDENCIES) \
		$(EXTRA_src_rm_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]rm.obj, [.src]remove.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]rmdir.obj : [.src]rmdir.c $(config_h) $(system_h) [.lib]error.h \
	[.src]prog-fprintf.h [.lib]quote.h

[.src]rmdir$(EXEEXT) : $(src_rmdir_OBJECTS) $(src_rmdir_DEPENDENCIES) \
		$(EXTRA_src_rmdir_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]rmdir.obj, [.src]prog-fprintf.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]runcon.obj : [.src]runcon.c $(config_h) [.lib.selinux]selinux.h \
	[.lib.selinux]context.h $(system_h) [.lib]error.h \
	[.lib]quote.h [.lib]quotearg.h

[.src]runcon$(EXEEXT) : $(src_runcon_OBJECTS) $(src_runcon_DEPENDENCIES) \
		$(EXTRA_src_runcon_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]runcon.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]seq.obj : [.src]seq.c $(config_h) $(system_h) [.lib]c-strtod.h \
	[.lib]error.h [.lib]quote.h [.lib]xstrtod.h

[.src]seq$(EXEEXT) : $(src_seq_OBJECTS) $(src_seq_DEPENDENCIES) \
		$(EXTRA_src_seq_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]seq.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]setuidgid.obj : [.src]setuidgid.c $(config_h) $(system_h) \
	[.lib]long-options.h [.lib]mgetgroups.h [.lib]quote.h \
	$(xstrtol_h) [.vms]vms_pwd_hack.h

[.src]setuidgid$(EXEEXT) : $(src_setuidgid_OBJECTS) \
		$(src_setuidgid_DEPENDENCIES) \
		$(EXTRA_src_setuidgid_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]setuidgid.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]src_sha1sum-md5sum.obj : [.src]md5sum.c $(config_h) $(system_h) \
	$(md5_h) $(sha1_h) $(sha256_h) $(sha512_h) [.lib]error.h \
	[.lib]fadvise.h $(stdio___h) [.lib]xfreopen.h
   $define/user glthread sys$disk:[.lib.glthread]
   $define/user selinux sys$disk:[.lib.selinux]
   $define/user decc$user_include sys$disk:[.src],sys$disk:[.lib.uniwidth]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),HASH_ALGO_SHA1=1) \
	/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.src]sha1sum$(EXEEXT) : $(src_sha1sum_OBJECTS) \
		$(src_sha1sum_DEPENDENCIES) \
		$(EXTRA_src_sha1sum_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]src_sha1sum-md5sum.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]src_sha224sum-md5sum.obj : [.src]md5sum.c $(config_h) $(system_h) \
	$(md5_h) $(sha1_h) $(sha256_h) $(sha512_h) [.lib]error.h \
	[.lib]fadvise.h $(stdio___h) [.lib]xfreopen.h
   $define/user glthread sys$disk:[.lib.glthread]
   $define/user selinux sys$disk:[.lib.selinux]
   $define/user decc$user_include sys$disk:[.src],sys$disk:[.lib.uniwidth]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),HASH_ALGO_SHA224=1) \
	/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.src]sha224sum$(EXEEXT) : $(src_sha224sum_OBJECTS) \
		$(src_sha224sum_DEPENDENCIES) \
		$(EXTRA_src_sha224sum_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]src_sha224sum-md5sum.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]src_sha256sum-md5sum.obj : [.src]md5sum.c $(config_h) $(system_h) \
	$(md5_h) $(sha1_h) $(sha256_h) $(sha512_h) [.lib]error.h \
	[.lib]fadvise.h $(stdio___h) [.lib]xfreopen.h
   $define/user glthread sys$disk:[.lib.glthread]
   $define/user selinux sys$disk:[.lib.selinux]
   $define/user decc$user_include sys$disk:[.src],sys$disk:[.lib.uniwidth]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),HASH_ALGO_SHA256=1) \
	/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.src]sha256sum$(EXEEXT) : $(src_sha256sum_OBJECTS) \
		$(src_sha256sum_DEPENDENCIES) \
		$(EXTRA_src_sha256sum_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]src_sha256sum-md5sum.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]src_sha384sum-md5sum.obj : [.src]md5sum.c $(config_h) $(system_h) \
	$(md5_h) $(sha1_h) $(sha256_h) $(sha512_h) [.lib]error.h \
	[.lib]fadvise.h $(stdio___h) [.lib]xfreopen.h
   $define/user glthread sys$disk:[.lib.glthread]
   $define/user selinux sys$disk:[.lib.selinux]
   $define/user decc$user_include sys$disk:[.src],sys$disk:[.lib.uniwidth]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),HASH_ALGO_SHA384=1) \
	/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.src]sha384sum$(EXEEXT) : $(src_sha384sum_OBJECTS) \
		$(src_sha384sum_DEPENDENCIES) \
		$(EXTRA_src_sha384sum_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]src_sha384sum-md5sum.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]src_sha512sum-md5sum.obj : [.src]md5sum.c $(config_h) $(system_h) \
	$(md5_h) $(sha1_h) $(sha256_h) $(sha512_h) [.lib]error.h \
	[.lib]fadvise.h $(stdio___h) [.lib]xfreopen.h
   $define/user glthread sys$disk:[.lib.glthread]
   $define/user selinux sys$disk:[.lib.selinux]
   $define/user decc$user_include sys$disk:[.src],sys$disk:[.lib.uniwidth]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),HASH_ALGO_SHA512=1) \
	/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.src]sha512sum$(EXEEXT) : $(src_sha512sum_OBJECTS) \
		$(src_sha512sum_DEPENDENCIES) \
		$(EXTRA_src_sha512sum_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]src_sha512sum-md5sum.obj , \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]shred.obj : [.src]shred.c $(config_h) $(system_h) $(xstrtol_h) \
	[.lib]error.h $(fcntl__h) $(human_h) [.lib]quotearg.h \
	[.lib]randint.h [.lib]randread.h [.lib]stat-size.h

[.src]shred$(EXEEXT) : $(src_shred_OBJECTS) $(src_shred_DEPENDENCIES) \
		$(EXTRA_src_shred_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]shred.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]shuf.obj : [.src]shuf.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]fadvise.h [.lib]getopt.h [.lib]quote.h \
	[.lib]quotearg.h [.lib]randint.h $(randperm_h) \
	[.lib]read-file.h $(stdio___h) $(xstrtol_h)

[.src]shuf$(EXEEXT) : $(src_shuf_OBJECTS) $(src_shuf_DEPENDENCIES) \
		$(EXTRA_src_shuf_DEPENDENCIES)
	link/exe=$(MMS$TARGET) [.src]shuf.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]sleep.obj : [.src]sleep.c $(config_h) $(system_h) \
	[.lib]c-strtod.h [.lib]error.h [.lib]long-options.h \
	[.lib]quote.h [.lib]xnanosleep.h [.lib]xstrtod.h

[.src]sleep$(EXEEXT) : $(src_sleep_OBJECTS) $(src_sleep_DEPENDENCIES) \
		$(EXTRA_src_sleep_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]sleep.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

#lcl_root:[.src]sort.c : src_root:[.src]sort.c src_sort_c.tpu
#                    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
#                    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.src]sort.obj : [.src]sort.c $(config_h) $(system_h) $(argmatch_h) \
	[.lib]error.h [.lib]fadvise.h [.lib]filevercmp.h \
	[.lib]hard-locale.h [.lib]hard-locale.h [.lib]heap.h \
	[.lib]ignore-value.h $(md5_h) [.lib]mbswidth.h \
	[.lib]nproc.h [.lib]physmem.h [.lib]posixver.h \
	[.lib]quote.h [.lib]quotearg.h [.lib]randread.h \
	$(readtokens0_h) $(stdio___h) $(stdlib___h) \
	[.lib]strnumcmp.h [.lib]xmemcoll.h [.lib]xnanosleep.h \
	$(xstrtol_h)

[.src]sort$(EXEEXT) : $(src_sort_OBJECTS) $(src_sort_DEPENDENCIES) \
		[.src]vms_vm_pipe.obj $(EXTRA_src_sort_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]sort.obj, sys$disk:[.src]vms_vm_pipe.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

lcl_root:[.src]split.c : src_root:[.src]split.c [.vms]src_split_c.tpu
                    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
                    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.src]split.obj : lcl_root:[.src]split.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fd-reopen.h $(fcntl___h) [.lib]full-read.h \
	[.lib]full-write.h $(ioblksize_h) [.lib]quote.h \
	[.lib]safe-read.h $(sig2str_h) [.lib]xfreopen.h \
	$(xstrtol_h)

[.src]vms_vm_pipe.obj : [.vms]vms_vm_pipe.c

[.src]split$(EXEEXT) : $(src_split_OBJECTS) $(src_split_DEPENDENCIES) \
		$(EXTRA_src_split_DEPENDENCIES) [.src]vms_vm_pipe.obj
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]split.obj, \
		sys$disk:[.src]vms_vm_pipe.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]stat.obj : [.src]stat.c $(config_h) [.lib.selinux]selinux.h \
	$(system_h) [.lib]areadlink.h [.lib]error.h \
	[.lib]file-type.h [.lib]filemode.h [.src]fs.h [.lib]getopt.h \
	[.lib]mountlist.h [.lib]quote.h [.lib]quotearg.h \
	[.lib]stat-size.h [.lib]stat-time.h [.src]find-mount-point.h \
	[.lib]xvasprintf.h [.lib]stdalign.h [.lib]alloca.h \
	[.vms]vms_pwd_hack.h

[.src]stat$(EXEEXT) : $(src_stat_OBJECTS) $(src_stat_DEPENDENCIES) \
		$(EXTRA_src_stat_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]stat.obj, [.src]find-mount-point.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

# quota.h
[.src]stdbuf.obj : [.src]stdbuf.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]filenamecat.h [.lib]xreadlink.h \
	$(xstrtol_h) [.lib]c-ctype.h

[.src]stdbuf$(EXEEXT) : $(src_stdbuf_OBJECTS) $(src_stdbuf_DEPENDENCIES) \
		$(EXTRA_src_stdbuf_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]stdbuf.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]stty.obj : [.src]stty.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fd-reopen.h [.lib]quote.h $(xstrtol_h) $(termios_h) \
	sys$disk:[.vms]vms_ioctl_hack.h [.vms]vms_ttyname_hack.h

[.src]stty$(EXEEXT) : $(src_stty_OBJECTS) $(src_stty_DEPENDENCIES) \
		$(EXTRA_src_stty_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]stty.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]sum.obj : [.src]sum.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fadvise.h $(human_h) [.lib]safe-read.h [.lib]xfreopen.h

[.src]sum$(EXEEXT) : $(src_sum_OBJECTS) $(src_sum_DEPENDENCIES) \
		$(EXTRA_src_sum_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]sum.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]sync.obj : [.src]sync.c $(config_h) $(system_h) [.lib]long-options.h

[.src]sync$(EXEEXT) : $(src_sync_OBJECTS) $(src_sync_DEPENDENCIES) \
		$(EXTRA_src_sync_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]sync.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]tac.obj : [.src]tac.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]filenamecat.h [.lib]quote.h [.lib]quotearg.h \
	[.lib]safe-read.h $(stdlib___h) [.lib]xfreopen.h

[.src]tac$(EXEEXT) : $(src_tac_OBJECTS) $(src_tac_DEPENDENCIES) \
		$(EXTRA_src_tac_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]tac.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]tail.obj : [.src]tail.c $(config_h) $(system_h) $(argmatch_h) \
	[.lib]c-strtod.h [.lib]dosname.h $(fcntl___h) [.lib]isapipe.h \
	[.lib]posixver.h [.lib]quote.h [.lib]safe-read.h [.lib]stat-time.h \
	[.lib]xfreopen.h [.lib]xnanosleep.h $(xstrtol_h) [.lib]xstrtod.h \
	[.lib]hash.h [.src]fs.h [.src]fs-is-local.h

[.src]tail$(EXEEXT) : $(src_tail_OBJECTS) $(src_tail_DEPENDENCIES) \
		$(EXTRA_src_tail_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]tail.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]tee.obj : [.src]tee.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fadvise.h $(stdio___h) [.lib]xfreopen.h

[.src]tee$(EXEEXT) : $(src_tee_OBJECTS) $(src_tee_DEPENDENCIES) \
		$(EXTRA_src_tee_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]tee.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj


[.src]test.obj : [.src]test.c $(config_h) $(system_h) [.lib]quote.h \
	[.lib]stat-time.h [.lib]strnumcmp.h

[.src]test$(EXEEXT) : $(src_test_OBJECTS) $(src_test_DEPENDENCIES) \
		$(EXTRA_src_test_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]test.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]lbracket.obj : [.src]lbracket.c [.src]test.c \
	$(config_h) $(system_h) [.lib]quote.h \
	[.lib]stat-time.h [.lib]strnumcmp.h

[.src]lbracket$(EXEEXT) : $(src___OBJECTS) $(src_test_DEPENDENCIES) \
		$(EXTRA_src___DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]lbracket.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj
        if f$search("[.src]^[.exe") .nes. "" then delete [.src]^[.exe;*
        copy $(MMS$TARGET) [.src]^[.exe

[.src]timeout.obj : [.src]timeout.c $(config_h) $(system_h) \
	[.lib]c-strtod.h [.lib]xstrtod.h $(sig2str_h) [.lib]xstrtod.h \
	$(sig2str_h) [.src]operand2sig.h [.lib]error.h [.lib]quote.h

[.src]timeout$(EXEEXT) : $(src_timeout_OBJECTS) \
		$(src_timeout_DEPENDENCIES) \
		$(EXTRA_src_timeout_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]timeout.obj, [.src]operand2sig.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]touch.obj : [.src]touch.c $(config_h) $(system_h) $(argmatch_h) \
	[.lib]error.h [.lib]fd-reopen.h [.lib]parse-datetime.h \
	[.lib]posixtm.h [.lib]posixver.h [.lib]quote.h \
	[.lib]stat-time.h [.lib]utimens.h

[.src]touch$(EXEEXT) : $(src_touch_OBJECTS) $(src_touch_DEPENDENCIES) \
		$(EXTRA_src_touch_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]touch.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]tr.obj : [.src]tr.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fadvise.h [.lib]quote.h [.lib]safe-read.h \
	[.lib]xfreopen.h $(xstrtol_h)

[.src]tr$(EXEEXT) : $(src_tr_OBJECTS) $(src_tr_DEPENDENCIES) \
		$(EXTRA_src_tr_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]tr.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]true.obj : [.src]true.c $(config_h) $(system_h)

[.src]true$(EXEEXT) : $(src_true_OBJECTS) $(src_true_DEPENDENCIES) \
		$(EXTRA_src_true_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]true.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]truncate.obj : [.src]truncate.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]quote.h [.lib]stat-size.h $(xstrtol_h)

[.src]truncate$(EXEEXT) : $(src_truncate_OBJECTS) \
		$(src_truncate_DEPENDENCIES) \
		$(EXTRA_src_truncate_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]truncate.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]tsort.obj : [.src]tsort.c $(config_h) $(system_h) \
	[.lib]long-options.h [.lib]error.h [.lib]fadvise.h \
	[.lib]quote.h [.lib]readtokens.h $(stdio___h)

[.src]tsort$(EXEEXT) : $(src_tsort_OBJECTS) $(src_tsort_DEPENDENCIES) \
		$(EXTRA_src_tsort_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]tsort.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]tty.obj : [.src]tty.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]quote.h

[.src]tty$(EXEEXT) : $(src_tty_OBJECTS) $(src_tty_DEPENDENCIES) \
		$(EXTRA_src_tty_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]tty.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]uname-uname.obj : [.src]uname-uname.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]quote.h [.src]uname.h

[.src]uname$(EXEEXT) : $(src_uname_OBJECTS) $(src_uname_DEPENDENCIES) \
		$(EXTRA_src_uname_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]uname.obj, [.src]uname-uname.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]unexpand.obj : [.src]unexpand.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]fadvise.h [.lib]quote.h [.lib]xstrndup.h

[.src]unexpand$(EXEEXT) : $(src_unexpand_OBJECTS) \
		$(src_unexpand_DEPENDENCIES) \
		$(EXTRA_src_unexpand_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]unexpand.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]uniq.obj : [.src]uniq.c $(config_h) $(system_h) $(argmatch_h) \
	[.lib]linebuffer.h [.lib]error.h [.lib]fadvise.h \
	[.lib]hard-locale.h [.lib]posixver.h [.lib]quote.h \
	$(stdio___h) [.lib]xmemcoll.h $(xstrtol_h) [.lib]memcasecmp.h

[.src]uniq$(EXEEXT) : $(src_uniq_OBJECTS) $(src_uniq_DEPENDENCIES) \
		$(EXTRA_src_uniq_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]uniq.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]unlink.obj : [.src]unlink.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]long-options.h [.lib]quote.h

[.src]unlink$(EXEEXT) : $(src_unlink_OBJECTS) $(src_unlink_DEPENDENCIES) \
		$(EXTRA_src_unlink_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]unlink.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]uptime.obj : [.src]uptime.c $(config_h) $(system_h) [.lib]c-strtod.h \
	[.lib]error.h [.lib]long-options.h [.lib]quote.h $(readutmp_h) \
	[.lib]fprintftime.h

[.src]uptime$(EXEEXT) : $(src_uptime_OBJECTS) $(src_uptime_DEPENDENCIES) \
		$(EXTRA_src_uptime_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]uptime.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]users.obj : [.src]users.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]long-options.h [.lib]quote.h $(readutmp_h)

[.src]users$(EXEEXT) : $(src_users_OBJECTS) $(src_users_DEPENDENCIES) \
		$(EXTRA_src_users_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET)/notraceback [.src]users.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]ls-vdir.obj : [.src]ls-vdir.c [.src]ls.h

[.src]vdir$(EXEEXT) : $(src_vdir_OBJECTS) $(src_vdir_DEPENDENCIES) \
		$(EXTRA_src_vdir_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]ls.obj, [.src]ls-vdir.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]wc.obj : [.src]wc.c $(config_h) $(system_h) $(argv_iter_h) \
	[.lib]error.h [.lib]fadvise.h [.lib]mbchar.h [.lib]physmem.h \
	[.lib]quote.h [.lib]quotearg.h $(readtokens0_h) \
	[.lib]safe-read.h [.lib]xfreopen.h

[.src]wc$(EXEEXT) : $(src_wc_OBJECTS) $(src_wc_DEPENDENCIES) \
		$(EXTRA_src_wc_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]wc.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]who.obj : [.src]who.c $(config_h) $(system_h) [.lib]c-ctype.h \
	[.lib]canon-host.h $(readutmp_h) [.lib]error.h \
	[.lib]hard-locale.h [.lib]quote.h

[.src]who$(EXEEXT) : $(src_who_OBJECTS) $(src_who_DEPENDENCIES) \
		$(EXTRA_src_who_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET)/notraceback [.src]who.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]whoami.obj : [.src]whoami.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]long-options.h [.lib]quote.h [.vms]vms_pwd_hack.h


[.src]whoami$(EXEEXT) : $(src_whoami_OBJECTS) $(src_whoami_DEPENDENCIES) \
		$(EXTRA_src_whoami_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]whoami.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj

[.src]yes.obj : [.src]yes.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]long-options.h

[.src]yes$(EXEEXT) : $(src_yes_OBJECTS) $(src_yes_DEPENDENCIES) \
		$(EXTRA_src_yes_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]yes.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		sys$disk:[.src]vms_crtl_init.obj


## TEST section
##

[.lib]test-physmem.obj : [.lib]physmem.c $(config_h) [.lib]physmem.h \
	[.vms]vms_pstat_hack.h
   $(CC)$(CFLAGS)/define=($(cdefs1),DEBUG=1) \
	/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-fchdir.obj : [.gnulib-tests]test-fchdir.c \
	[.vms]vms_getcwd_hack.h

[.gnulib-tests]test-getcwd-lgpl.obj : [.gnulib-tests]test-getcwd-lgpl.c \
	[.vms]vms_getcwd_hack.h

[.gnulib-tests]test-getcwd.obj : [.gnulib-tests]test-getcwd.c \
	[.vms]vms_getcwd_hack.h

[.gnulib-tests]ioctl.obj : [.gnulib-tests]ioctl.c \
	sys$disk:[.vms]vms_ioctl_hack.h

[.gnulib-tests]test-ioctl.obj : [.gnulib-tests]test-ioctl.c \
	sys$disk:[.vms]vms_ioctl_hack.h

[.gnulib-tests]test-sys_ioctl.obj : [.gnulib-tests]test-sys_ioctl.c \
	sys$disk:[.vms]vms_ioctl_hack.h

[.gnulib-tests]test-linkat.obj : [.gnulib-tests]test-linkat.c \
	sys$disk:[.vms]vms_getcwd_hack.h sys$disk:[.vms]vms_rename_hack.h

[.gnulib-tests]test-rename.obj : [.gnulib-tests]test-rename.c \
	sys$disk:[.vms]vms_rename_hack.h

[.gnulib-tests]test-stat-time.obj : [.gnulib-tests]test-stat-time.c \
	sys$disk:[.vms]vms_rename_hack.h

[.gnulib-tests]test-userspec.obj : [.gnulib-tests]test-userspec.c \
	sys$disk:[.vms]vms_pwd_hack.h