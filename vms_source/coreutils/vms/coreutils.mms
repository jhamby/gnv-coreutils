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
# 16-Aug-2017   J. Malmberg	Add vms_execvp wrapper
##############################################################################

crepository = /repo=sys$disk:[coreutils.cxx_repository]
cnames = /name=(as_i,shor)$(crepository)
#cshow = /show=(EXPA,INC)
clist = /list$(cshow)
cprefix = /pref=all
cfloat = /FLOAT=IEEE_FLOAT/IEEE_MODE=DENORM_RESULTS
cnowarn1 = questcompare1,unknownmacro,intconcastsgn,intconstsign,falloffend,subscrbounds1
cnowarn2 = boolexprconst,knrfunc,embedcomment,nestedcomment,uninit2,intoverfl
cnowarn = $(cnowarn1),$(cnowarn2)
cwarn1 = defunct,obsolescent,questcode
cwarn = /warnings=(enable=($(cwarn1)),disable=($(cnowarn)))
#cinc1 = prj_root:[],prj_root:[.include],prj_root:[.lib.intl],prj_root:[.lib.sh]
cinc2 = /nested=none/assume=noheader_type_def
cinc = $(cinc2)
#cdefs = /define=(_USE_STD_STAT=1,_POSIX_EXIT=1,\
#	HAVE_STRING_H=1,HAVE_STDLIB_H=1,HAVE_CONFIG_H=1,SHELL=1)
.ifdef __VAX__
cdefs1 = _POSIX_EXIT=1,HAVE_CONFIG_H=1
cmain =
.else
cdefs1 = _USE_STD_STAT=1,_POSIX_EXIT=1,HAVE_CONFIG_H=1,__NEW_STARLET=1,"lint"=1
cmain = /MAIN=POSIX_EXIT/REENTR=MULTITHREAD
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
   $define/user glthread sys$disk:[.lib.glthread],sys$disk:[.gnulib-tests.glthread]
   $define/user selinux sys$disk:[.lib.selinux]
   $define/user sys sys$disk:[.lib.sys]
   $define/user malloc sys$disk:[.lib.malloc]
   $define/user unictype sys$disk:[.lib.unictype]
   $define/user uniwidth sys$disk:[.lib.uniwidth]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
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

bitrotate_h = [.lib]bitrotate.h

c_strcaseeq_h = [.lib]c-strcaseeq.h [.lib]c-strcase.h [.lib]c-ctype.h

chdir_long_h = [.lib]chdir-long.h [.lib]pathmax.h

cjk_h = [.lib.uniwidth]cjk.h [.lib]streq.h

cycle_check_h = [.lib]cycle-check.h [.lib]dev-ino.h [.lib]same-inode.h

dirent___h = [.lib]dirent--.h [.lib]dirent-safer.h

dirname_h = [.lib]dirname.h

fcntl___h = [.lib]fcntl--.h [.lib]fcntl-safer.h

file_set_h = [.lib]file-set.h [.lib]hash.h

fpending_h = [.lib]fpending.h [.lib]stdio_ext.h

freadahead_h = [.lib]freadahead.h [.lib]stdio_ext.h

freading_h = [.lib]freading.h [.lib]stdio_ext.h

freadptr_h = [.lib]freadptr.h [.lib]stdio_ext.h

ftoastr_h = [.lib]ftoastr.h [.lib]intprops.h

# fts__h = [.lib]fts_.h [.lib]i-ring.h

fseterr_h = [.lib]fseterr.h [.lib]stdio_ext.h

fsusage_h = [.lib]fsusage.h

gethrxtime_h = [.lib]gethrxtime.h [.lib]xtime.h

gl_linked_list_h = [.lib]gl_linked_list.h [.lib]gl_list.h

xstrtol_h = [.lib]xstrtol.h [.lib]getopt.h

human_h = [.lib]human.h $(xstrtol_h)

i_ring_h = [.lib]i-ring.h [.lib]verify.h

inttostr_h = [.lib]inttostr.h [.lib]intprops.h

malloca_h = [.lib]malloca.h [.lib]alloca.h

mbiter_h = [.lib]mbiter.h [.lib]mbchar.h

mbuiter_h = [.lib]mbuiter.h [.lib]mbchar.h [.lib]strnlen1.h

md5_h = [.lib]md5.h

# pipe_h = [.lib]pipe.h [.lib]spawn-pipe.h

# printf-parse_h = [.lib]printf-parse.h [.lib]printf-args.h

# Use VMS header
# pthread_h = [.lib]pthread.h [.lib]sched.h

rand_isaac_h = [.lib]rand-isaac.h

randint_h = [.lib]randint.h [.lib]randread.h

randperm_h = [.lib]randperm.h [.lib]randint.h

readtokens0_h = [.lib]readtokens0.h [.lib]obstack.h

readutmp_h = [.lib]readutmp.h [.lib]utmp.h

regex_internal_h = [.lib]regex_internal.h

root_dev_ino_h = [.lib]root-dev-ino.h [.lib]dev-ino.h [.lib]same-inode.h

sha1_h = [.lib]sha1.h

sha256_h = [.lib]sha256.h

u64_h = [.lib]u64.h

sha512_h = [.lib]sha512.h $(u64_h)

sig2str_h = [.lib]sig2str.h [.lib]intprops.h

size_max_h = [.lib]size_max.h

sockets_h = [.lib]sockets.h [.lib]msvc-nothrow.h

#spawn_h = [.lib]spawn.h [.lib]sched.h

stdio___h = [.lib]stdio--.h [.lib]stdio-safer.h

stdlib___h = [.lib]stdlib--.h [.lib]stdlib-safer.h

str_two_way_h = [.lib]str-two-way.h

strnumcmp_in_h = [.lib]strnumcmp-in.h [.lib]strnumcmp.h

termios_h = [.vms]termios.h [.vms]vms_term.h [.vms]bits_termios.h \
	[.vms]vms_terminal_io.h

unistd___h = [.lib]unistd--.h [.lib]unistd-safer.h

unistr_h = [.lib]unistr.h [.lib]unitypes.h

verror.h = [.lib]verror.h [.lib]error.h

w32sock_h = [.lib]w32sock.h [.lib]msvc-nothrow.h

w32spawn_h = [.lib]w32spawn.h [.lib]msvc-nothrow.h [.lib]cloexec.h \
	[.lib]xalloc.h

xalloc_h = [.lib]xalloc.h [.lib]xalloc-oversized.h

xfts_h = [.lib]xfts.h $(fts__h)

xsize_h = [.lib]xsize.h

selinux_at_h = [.lib]selinux-at.h [.lib.selinux]context.h \
	[.lib.selinux]selinux.h

config_h = [.lib]config.h config_vms.h [.vms]vms_coreutils_hacks.h

xdectoint_c = $(config_h) [.lib]xdectoint.h $(xstrtol_h)

anytostr_c = [.lib]anytostr.c $(config_h) $(inttostr_h)

at_func_c = [.lib]at-func.c [.lib]openat.h \
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

true_c = [.src]true.c $(config_h) $(system_h)

# [.lib]grouping.h (optional)
#strtol_c = [.lib]strtol.c $(config_h)

xstrtol_c = [.lib]xstrtol.c $(config_h) $(xstrtol_h) [.lib]intprops.h

# se-linux only
#"se-context"=[.lib]se-context.obj,
#"se-selinux"=[.lib]se-selinux.obj,\

# VMS CRTL opendir is safe enough.
#"opendir-safer"=[.lib]opendir-safer.obj,\
#"open-safer"=[.lib]open-safer.obj,\
#
# spawn not used.
#		"spawn-pipe"=[.lib]spawn-pipe.obj,\
#

lib_libcoreutils_a_OBJECTS = \
		"set-acl"=[.lib]set-acl.obj,\
		"copy-acl"=[.lib]copy-acl.obj,\
		"file-has-acl"=[.lib]file-has-acl.obj,\
		"acl-internal"=[.lib]acl-internal.obj,\
		"get-permissions"=[.lib]get-permissions.obj,\
		"set-permissions"=[.lib]set-permissions.obj,\
		"alignalloc"=[.lib]alignalloc.obj,\
		"allocator"=[.lib]allocator.obj,\
		"areadlink"=[.lib]areadlink.obj,\
		"areadlink-with-size"=[.lib]areadlink-with-size.obj,\
		"areadlinkat"=[.lib]areadlinkat.obj,\
		"areadlinkat-with-size"=[.lib]areadlinkat-with-size.obj,\
		"argmatch"=[.lib]argmatch.obj,\
		"argv-iter"=[.lib]argv-iter.obj,\
		"backup-find"=[.lib]backup-find.obj,\
		"backup-rename"=[.lib]backup-rename.obj,\
		"backupfile"=[.lib]backupfile.obj,\
		"base32"=[.lib]base32.obj,\
		"base64"=[.lib]base64.obj,\
		"bitrotate"=[.lib]bitrotate.obj,\
		"buffer-lcm"=[.lib]buffer-lcm.obj,\
		"canon-host"=[.lib]canon-host.obj,\
		"canonicalize"=[.lib]canonicalize.obj,\
		"careadlinkat"=[.lib]careadlinkat.obj,\
		"cloexec"=[.lib]cloexec.obj,\
		"close-stream"=[.lib]close-stream.obj,\
		"closein"=[.lib]closein.obj,\
		"closeout"=[.lib]closeout.obj,\
		"copy-file-range"=[.lib]copy-file-range.obj,\
		"c-strcasecmp"=[.lib]c-strcasecmp.obj,\
		"c-strncasecmp"=[.lib]c-strncasecmp.obj,\
		"md5"=[.lib]md5.obj,\
		"md5-stream"=[.lib]md5-stream.obj,\
		"sha1"=[.lib]sha1.obj,\
		"sha1-stream"=[.lib]sha1-stream.obj,\
		"sha256"=[.lib]sha256.obj,\
		"sha256-stream"=[.lib]sha256-stream.obj,\
		"sha512"=[.lib]sha512.obj,\
		"sha512-stream"=[.lib]sha512-stream.obj,\
		"sm3"=[.lib]sm3.obj,\
		"sm3-stream"=[.lib]sm3-stream.obj,\
		"cycle-check"=[.lib]cycle-check.obj,\
		"di-set"=[.lib]di-set.obj,\
		"dirname"=[.lib]dirname.obj,\
		"basename"=[.lib]basename.obj,\
		"dirname-lgpl"=[.lib]dirname-lgpl.obj,\
		"basename-lgpl"=[.lib]basename-lgpl.obj,\
		"stripslash"=[.lib]stripslash.obj,\
		"dtoastr"=[.lib]dtoastr.obj,\
		"dtotimespec"=[.lib]dtotimespec.obj,\
		"exclude"=[.lib]exclude.obj,\
		"explicit_bzero"=[.lib]explicit_bzero.obj,\
		"exitfail"=[.lib]exitfail.obj,\
		"error"=[.lib]error.obj,\
		"fadvise"=[.lib]fadvise.obj,\
		"chmodat"=[.lib]chmodat.obj,\
		"chownat"=[.lib]chownat.obj,\
		"c-strtod"=[.lib]c-strtod.obj,\
		"c-strtold"=[.lib]c-strtold.obj,\
		"cl-strtod"=[.lib]cl-strtod.obj,\
		"cl-strtold"=[.lib]cl-strtold.obj,\
		"creat-safer"=[.lib]creat-safer.obj,\
		"fd-hook"=[.lib]fd-hook.obj,\
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
		"freadahead"=[.lib]freadahead.obj,\
		"freading"=[.lib]freading.obj,\
		"freadseek"=[.lib]freadseek.obj,\
		"freopen-safer"=[.lib]freopen-safer.obj,\
		"ftoaster"=[.lib]ftoastr.obj,\
		"full-read"=[.lib]full-read.obj,\
		"full-write"=[.lib]full-write.obj,\
		"gethrxtime"=[.lib]gethrxtime.obj,\
		"xtime"=[.lib]xtime.obj,\
		"getndelim2"=[.lib]getndelim2.obj,\
		"getrandom"=[.lib]getrandom.obj,\
		"gettime"=[.lib]gettime.obj,\
		"gettime-res"=[.lib]gettime-res.obj,\
		"getugroups"=[.lib]getugroups.obj,\
		"hard-locale"=[.lib]hard-locale.obj,\
		"hash"=[.lib]hash.obj,\
		"hash-pjw"=[.lib]hash-pjw.obj,\
		"hash-triple"=[.lib]hash-triple.obj,\
		"hash-triple-simple"=[.lib]hash-triple-simple.obj,\
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
		"lchmod"=[.lib]lchmod.obj,\
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
		"mkdirat"=[.lib]mkdirat.obj,\
		"mktime"=[.lib]mktime.obj,\
		"modechange"=[.lib]modechange.obj,\
		"mpsort"=[.lib]mpsort.obj,\
		"nproc"=[.lib]nproc.obj,\
		"nstrftime"=[.lib]nstrftime.obj,\
		"openat-die"=[.lib]openat-die.obj,\
		"openat-safer"=[.lib]openat-safer.obj,\
		"opendirat"=[.lib]opendirat.obj,\
		"parse-datetime"= [.lib]parse-datetime.obj,\
		"physmem"=[.lib]physmem.obj,\
		"posixtm"=[.lib]posixtm.obj,\
		"posixver=[.lib]posixver.obj,\
		"printf-frexp"=[.lib]printf-frexp.obj,\
		"printf-frexpl"=[.lib]printf-frexpl.obj,\
		"priv-set"=[.lib]priv-set.obj,\
		"vms_progname"=[.lib]vms_progname.obj,\
		"propername"=[.lib]propername.obj,\
		"qcopy-acl"=[.lib]qcopy-acl.obj,\
		"qset-acl"=[.lib]qset-acl.obj,\
		"quotearg"=[.lib]quotearg.obj,\
		"randint"=[.lib]randint.obj,\
		"randperm"=[.lib]randperm.obj,\
		"randread"=[.lib]randread.obj,\
		"rawmemchr"=[.lib]rawmemchr.obj,\
		"reallocarray"=[.lib]reallocarray.obj,\
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
		"mkstemp-safer"=[.lib]mkstemp-safer.obj,\
		"setlocale-lock"=[.lib]setlocale-lock.obj,\
		"setlocale_null"=[.lib]setlocale_null.obj,\
		"striconv"=[.lib]striconv.obj,\
		"strnlen1"=[.lib]strnlen1.obj,\
		"strintcmp"=[.lib]strintcmp.obj,\
		"strnucmp"=[.lib]strnumcmp.obj,\
		"sys_socket"=[.lib]sys_socket.obj,\
		"targetdir"=[.lib]targetdir.obj,\
		"tempname"=[.lib]tempname.obj,\
		"threadlib"=[.lib.glthread]threadlib.obj,\
		"timegm"=[.lib]timegm.obj,\
		"timespec"=[.lib]timespec.obj,\
		"time_rz"=[.lib]time_rz.obj,\
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
		"wmempcpy"=[.lib]wmempcpy.obj,\
		"write-any-file"=[.lib]write-any-file.obj,\
		"xdectoimax"=[.lib]xdectoimax.obj,\
		"xdectoumax"=[.lib]xdectoumax.obj,\
		"xmalloc"=[.lib]xmalloc.obj,\
		"xalignalloc"=[.lib]xalignalloc.obj,\
		"xalloc-die"=[.lib]xalloc-die.obj,\
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

# Removed.
#		"gl_linked_list"=[.lib]gl_linked_list.obj

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
		"freadahead"=[.lib]freadahead.obj,\
		"freadptr"=[.lib]freadptr.obj,\
		"fseterr"=[.lib]fseterr.obj,\
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
		"isnand"=[.lib]isnand.obj,\
		"link"=[.lib]link.obj,\
		"at-func2"=[.lib]at-func2.obj,\
		"linkat"=[.lib]linkat.obj,\
		"mbsrtowcs-state"=[.lib]mbsrtowcs-state.obj,\
		"mempcpy"=[.lib]mempcpy.obj,\
		"memrchr"=[.lib]memrchr.obj,\
		"mkfifo"=[.lib]mkfifo.obj,\
		"mkfifoat"=[.lib]mkfifoat.obj,\
		"mknod"=[.lib]mknod.obj,\
		"mknodat"=[.lib]mknodat.obj,\
		"mountlist"=[.lib]mountlist.obj,\
		"msvc-inval"=[.lib]msvc-inval.obj,\
		"obstack"=[.lib]obstack.obj,\
		"openat"=[.lib]openat.obj,\
		"selinex-at"=[.lib]selinux-at.obj,\
		"pthread-cond"=[.lib]pthread-cond.obj,\
		"pthread-thread"=[.lib]pthread-thread.obj,\
		"pthread_mutex_timedlock"=[.lib]pthread_mutex_timedlock.obj,\
		"pthread_sigmask"=[.lib]pthread_sigmask.obj,\
		"readlinkat"=[.lib]readlinkat.obj,\
		"vms_readutmp"=[.lib]vms_readutmp.obj,\
		"vms_getmntinfo"=[.lib]vms_getmntinfo.obj,\
		"regex"=[.lib]regex.obj,\
		"renameat"=[.lib]renameat.obj,\
		"renameatu"=[.lib]renameatu.obj,\
		"rpmatch"=[.lib]rpmatch.obj,\
		"sig2str"=[.lib]sig2str.obj,\
		"signbitd"=[.lib]signbitd.obj,\
		"signbitf"=[.lib]signbitf.obj,\
		"signbitl"=[.lib]signbitl.obj,\
		"stpncpy"=[.lib]stpncpy.obj,\
		"strsignal"=[.lib]strsignal.obj,\
		"symlinkat"=[.lib]symlinkat.obj,\
		"unlinkat"=[.lib]unlinkat.obj,\
		"unlinkdir"=[.lib]unlinkdir.obj,\
		"unsetenv"=[.lib]unsetenv.obj,\
		"utimesat"=[.lib]utimensat.obj,\
		"asnprintf"=[.lib]asnprintf.obj,\
		"printf-args"=[.lib]printf-args.obj,\
		"printf-parse"=[.lib]printf-parse.obj,\
		"vasnprintf"=[.lib]vasnprintf.obj,\
		"asprintf"=[.lib]asprintf.obj,\
		"vasprintf"=[.lib]vasprintf.obj,\
		"dynarray_at_failure"=[.lib.malloc]dynarray_at_failure.obj,\
		"dynarray_emplace_enlarge"=[.lib.malloc]dynarray_emplace_enlarge.obj,\
		"dynarray_finalize"=[.lib.malloc]dynarray_finalize.obj,\
		"dynarray_resize"=[.lib.malloc]dynarray_resize.obj,\
		"dynarray_resize_clear"=[.lib.malloc]dynarray_resize_clear.obj,\
		"scratch_buffer_dupfree"=[.lib.malloc]scratch_buffer_dupfree.obj,\
		"scratch_buffer_grow"=[.lib.malloc]scratch_buffer_grow.obj,\
		"scratch_buffer_grow_preserve"=[.lib.malloc]scratch_buffer_grow_preserve.obj,\
		"scratch_buffer_set_array_size"=[.lib.malloc]scratch_buffer_set_array_size.obj

vms_lib_objs =  "vms_execvp_hack"=[.lib]vms_execvp_hack.obj,\
		"vms_gethostid"=[.lib]vms_gethostid.obj,\
		"vms_get_foreign_cmd"=[.lib]vms_get_foreign_cmd.obj,\
		"gnv_vms_iconv_wrapper"=[.lib]gnv_vms_iconv_wrapper.obj,\
		"vms_fname_to_unix"=[.lib]vms_fname_to_unix.obj,\
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
	$(am__DEPENDENCIES_1) [.lib]libcoreutils.olb [.src]vms_crtl_init.obj \
	[.src]vms_crtl_values.obj
am__DEPENDENCIES_3 = $(am__DEPENDENCIES_2) $(am__DEPENDENCIES_1)
src___DEPENDENCIES = $(am__DEPENDENCIES_3)
am_src_arch_OBJECTS = [.src]uname.obj [.src]uname-arch.obj
src_arch_OBJECTS = $(am_src_arch_OBJECTS)
src_arch_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_b2sum_SOURCES = [.src]digest.c [.src.blake2]blake2b-ref.c \
	[.src.blake2]b2sum.c
src_b2sum_OBJECTS = [.src]src_b2sum-digest.obj [.src.blake2]blake2b-ref.obj \
	[.src.blake2]b2sum.obj
src_b2sum_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_base32_SOURCES = [.src]base32-basenc.c
src_base32_OBJECTS = [.src]base32-basenc.obj
src_base32_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_base64_SOURCES = [.src]base64-basenc.c
src_base64_OBJECTS = [.src]base64-basenc.obj
src_base64_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_basename_SOURCES = [.src]basename.c
src_basename_OBJECTS = [.src]basename.obj
src_basename_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_basenc_SOURCES = [.src]basenc-basenc.c
src_basenc_OBJECTS = [.src]basenc-basenc.obj
src_basenc_DEPENDENCIES = $(am__DEPENDENCIES_2)
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
src_cksum_OBJECTS = [.src]cksum.obj [.src]crctab.obj [.src.blake2]blake2b-ref.obj \
		    $(src_b2sum_OBJECTS) [.src]sum.obj [.src]src_cksum-digest.obj
src_cksum_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_comm_SOURCES = [.src]comm.c
src_comm_OBJECTS = [.src]comm.obj
src_comm_DEPENDENCIES = $(am__DEPENDENCIES_2)
am__objects_4 = [.src]copy.obj [.src]cp-hash.obj [.src]force-link.obj
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
src_cut_SOURCES = [.src]cut.c [.src]set-fields.c
src_cut_OBJECTS = [.src]cut.obj [.src]set-fields.obj
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
src_env_OBJECTS = [.src]env.obj [.src]operand2sig.obj
src_env_DEPENDENCIES = $(am__DEPENDENCIES_2)
src_expand_SOURCES = [.src]expand.c
src_expand_OBJECTS = [.src]expand.obj [.src]expand-common.obj
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
	[.src]src_ginstall-cp-hash.obj
am_src_ginstall_OBJECTS = [.src]src_ginstall-install.obj \
	[.src]src_ginstall-prog-fprintf.obj [.src]force-link.obj $(am__objects_5)
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
am_src_ln_OBJECTS = [.src]ln.obj [.src]relpath.obj [.src]force-link.obj
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
src_md5sum_OBJECTS = [.src]src_md5sum-digest.obj
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
am_src_mv_OBJECTS = [.src]mv.obj [.src]remove.obj [.src]force-link.obj \
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
src_numfmt_SOURCES = [.src]numfmt.c [.src]set-fields.c
src_numfmt_OBJECTS = [.src]numfmt.obj [.src]set-fields.obj
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
am_src_sha1sum_OBJECTS = [.src]src_sha1sum-digest.obj
src_sha1sum_OBJECTS = $(am_src_sha1sum_OBJECTS)
src_sha1sum_DEPENDENCIES = $(am__DEPENDENCIES_2)
am_src_sha224sum_OBJECTS = [.src]src_sha224sum-digest.obj
src_sha224sum_OBJECTS = $(am_src_sha224sum_OBJECTS)
src_sha224sum_DEPENDENCIES = $(am__DEPENDENCIES_2)
am_src_sha256sum_OBJECTS = [.src]src_sha256sum-digest.obj
src_sha256sum_OBJECTS = $(am_src_sha256sum_OBJECTS)
src_sha256sum_DEPENDENCIES = $(am__DEPENDENCIES_2)
am_src_sha384sum_OBJECTS = [.src]src_sha384sum-digest.obj
src_sha384sum_OBJECTS = $(am_src_sha384sum_OBJECTS)
src_sha384sum_DEPENDENCIES = $(am__DEPENDENCIES_2)
am_src_sha512sum_OBJECTS = [.src]src_sha512sum-digest.obj
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
src_unexpand_OBJECTS = [.src]unexpand.obj [.src]expand-common.obj
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

# NOTE: temporarily remove "expr" and "factor" until I can add libgmp.
am__EXEEXT_3 = \
	[.src]b2sum$(EXEEXT) [.src]basename$(EXEEXT) \
	[.src]cat$(EXEEXT) [.src]chcon$(EXEEXT) \
	[.src]chgrp$(EXEEXT) [.src]chmod$(EXEEXT) [.src]chown$(EXEEXT) \
	[.src]cksum$(EXEEXT) [.src]comm$(EXEEXT) [.src]cp$(EXEEXT) \
	[.src]csplit$(EXEEXT) [.src]cut$(EXEEXT) [.src]date$(EXEEXT) \
	[.src]dd$(EXEEXT) [.src]dir$(EXEEXT) [.src]dircolors$(EXEEXT) \
	[.src]dirname$(EXEEXT) [.src]du$(EXEEXT) [.src]echo$(EXEEXT) \
	[.src]env$(EXEEXT) [.src]expand$(EXEEXT) \
	[.src]false$(EXEEXT) [.src]fmt$(EXEEXT) \
	[.src]fold$(EXEEXT) [.src]getlimits$(EXEEXT) \
	[.src]ginstall$(EXEEXT) [.src]groups$(EXEEXT) \
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

# ifdef an incompatible, but optional, use of fork()
lcl_root:[.lib]savewd.c : src_root:[.lib]savewd.c [.vms]lib_savewd_c.tpu
                    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
                    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

lcl_root:[.lib]scratch_buffer.h : src_root:[.lib]scratch_buffer.h \
	 [.vms]lib_scratch_buffer_h.tpu
                    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
                    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

lcl_root:[.lib.malloc]dynarray.gl.h : [.lib.malloc]dynarray.h \
	[.vms]lib_malloc_dynarray_gl_h.tpu
    if f$search("[.lib]malloc.dir") .eqs. "" then \
	create/dir sys$disk:[.lib.malloc]/prot=o:rwed
    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
	    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

lcl_root:[.lib.malloc]dynarray-skeleton.gl.h : [.lib.malloc]dynarray-skeleton.c \
	[.vms]lib_malloc_dynarray-skeleton_gl_h.tpu
    if f$search("[.lib]malloc.dir") .eqs. "" then \
	create/dir sys$disk:[.lib.malloc]/prot=o:rwed
    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
	    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

lcl_root:[.lib.malloc]scratch_buffer_gl.h : [.lib.malloc]scratch_buffer.h \
	[.vms]lib_malloc_scratch_buffer_gl_h.tpu
    if f$search("[.lib]malloc.dir") .eqs. "" then \
	create/dir sys$disk:[.lib.malloc]/prot=o:rwed
    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
	    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

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

[.lib.selinux]label.h : [.lib]se-label^.in.h
	if f$search("[.lib]selinux.dir") .eqs. "" then \
	    create/dir sys$disk:[.lib.selinux]/prot=o:rwed
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

lcl_root:[.lib.sys]random.h : [.lib]sys_random^.in.h [.vms]lib_sys_random_h.tpu
    if f$search("[.lib]sys.dir") .eqs. "" then \
	create/dir sys$disk:[.lib.sys]/prot=o:rwed
    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
	    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.lib]configmake.h : [.vms]configmake_h.com
        @ $write sys$output "[.lib]configmake.h target"
	@[.vms]configmake_h.com

[.lib]alloca.h : [.vms]vms_alloca.h
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

[.lib]byteswap.h : [.lib]byteswap.in.h
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

[.lib]float_plus.h : $(float_plus_h)
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

[.lib]fnmatch.h : [.lib]fnmatch.in.h [.vms]lib_fnmatch_h.tpu
    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
	    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.lib]getopt.h : [.lib]getopt.in.h [.vms]lib_getopt_h.tpu
    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
	    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.lib]getopt-cdefs.h : [.lib]getopt-cdefs.in.h [.vms]lib_getopt_cdefs_h.tpu
    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
	    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

lcl_root:[.lib]sched.h : [.lib]sched^.in.h [.vms]lib_sched_h.tpu
    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
	    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.lib]spawn.h : [.lib]spawn^.in.h [.vms]lib_spawn_h.tpu
    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
	    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.lib]stdalign.h : [.lib]stdalign.in.h
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

[.lib]unistr.h : [.lib]unistr.in.h
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

[.lib]unitypes.h : [.lib]unitypes.in.h
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

[.lib]alignalloc.obj : [.lib]alignalloc.c $(config_h) [.lib]stdalign.h

[.lib]alloca.obj : [.lib]alloca.c $(config_h)

[.lib]allocator.obj : [.lib]allocator.c $(config_h) [.lib]allocator.h

# [.lib]anytostr.obj : $(anytostr_c)

[.lib]areadlink-with-size.obj : [.lib]areadlink-with-size.c \
	$(config_h) [.lib]areadlink.h

[.lib]areadlink.obj : [.lib]areadlink.c $(at_func_c) $(config_h) \
	[.lib]areadlink.h [.lib]careadlinkat.h

[.lib]areadlinkat.obj : [.lib]areadlinkat.c $(config_h) \
	[.lib]areadlink.h [.lib]careadlinkat.h $(at_func_c)

[.lib]areadlinkat-with-size.obj : [.lib]areadlinkat-with-size.c \
	$(config_h) [.lib]areadlink.h

[.lib]argmatch.obj : [.lib]argmatch.c $(config_h) $(argmatch_h) \
	[.lib]gettext.h [.lib]error.h [.lib]quotearg.h [.lib]quote.h \
	[.lib]unlocked-io.h [.lib]exitfail.h

[.lib]argv-iter.obj : [.lib]argv-iter.c $(config_h) $(argv_iter_h)

[.lib]asnprintf.obj : [.lib]asnprintf.c $(config_h) [.lib]vasnprintf.h

[.lib]asprintf.obj : [.lib]asprintf.c $(config_h)

[.lib]at-func2.obj : [.lib]at-func2.c $(config_h) [.lib]openat-priv.h \
	[.lib]filenamecat.h [.lib]openat.h \
	[.lib]same-inode.h [.lib]save-cwd.h [.vms]vms_pwd_hack.h

[.lib]backup-find.obj : [.lib]backup-find.c $(config_h) [.lib]backup-internal.h

[.lib]backup-rename.obj : [.lib]backup-rename.c $(config_h) [.lib]backup-internal.h

[.lib]backupfile.obj : [.lib]backupfile.c $(config_h) [.lib]backupfile.h \
	$(argmatch_h) $(dirname_h) [.lib]xalloc.h $(dirent___h)

[.lib]base32.obj : [.lib]base32.c $(config_h)

[.lib]base32-basenc.obj : [.lib]base32-basenc.c $(config_h)

[.lib]base64.obj : [.lib]base64.c $(config_h)

[.lib]base64-basenc.obj : [.lib]base64-basenc.c $(config_h)

[.lib]basename-lgpl.obj : [.lib]basename-lgpl.c $(config_h) $(dirname_h)

[.lib]basename.obj : [.lib]basename.c $(config_h) $(dirname_h) \
	[.lib]xalloc.h

#[.lib]binary-io.obj : [.lib]binary-io.c $(config_h) [.lib]binary-io.h

[.lib]bitrotate.obj : [.lib]bitrotate.c $(config_h) $(bitrotate_h)

# Use VMS CRTL
#[.lib]btowc.obj : [.lib]btowc.c $(config_h)

[.lib]buffer-lcm.obj : [.lib]buffer-lcm.c $(config_h) [.lib]buffer-lcm.h

[.lib]c-strcasecmp.obj : [.lib]c-strcasecmp.c $(config_h)

[.lib]c-strncasecmp.obj : [.lib]c-strncasecmp.c $(config_h)

[.lib]calloc.obj : [.lib]calloc.c $(config_h)

[.lib]canon-host.obj : [.lib]canon-host.c $(config_h) [.lib]canon-host.h

[.lib]canonicalize.obj : [.lib]canonicalize.c $(config_h) \
	[.lib]canonicalize.h [.lib]areadlink.h $(file_set_h) \
	[.lib]hash-triple.h [.lib]pathmax.h [.lib]xalloc.h \
	[.lib]xgetcwd.h [.vms]vms_pwd_hack.h lcl_root:[.lib.malloc]scratch_buffer_gl.h \
	lcl_root:[.lib]scratch_buffer.h


[.lib]careadlinkat.obj : [.lib]careadlinkat.c $(config_h) \
	[.lib]careadlinkat.h [.lib]allocator.h

[.lib]chdir-long.obj : [.lib]chdir-long.c $(config_h) $(chdir_long_h) \
	[.lib]closeout.h [.lib]error.h

[.lib]chmodat.obj : [.lib]chmodat.c $(config_h) [.lib]openat.h

[.lib]chown.obj : [.lib]chown.c $(config_h)

[.lib]chownat.obj : [.lib]chownat.c $(config_h) [.lib]openat.h

[.lib]c-strtod.obj : [.lib]c-strtod.c $(config_h)

[.lib]c-strtold.obj : [.lib]c-strtold.c $(config_h)

[.lib]cl-strtod.obj : [.lib]cl-strtod.c $(config_h)

[.lib]cl-strtold.obj : [.lib]cl-strtold.c $(config_h)

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
	[.lib]gettext.h [.lib]unlocked-io.h [.lib]msvc-nothrow.h

[.lib]euidaccess.obj : [.lib]euidaccess.c $(config_h) [.lib]root-uid.h

[.lib]exclude.obj : [.lib]exclude.c $(config_h) [.lib]exclude.h \
	[.lib]hash.h [.lib]mbuiter.h [.lib]fnmatch.h [.lib]xalloc.h \
	[.lib]verify.h [.lib]unlocked-io.h

[.lib]explicit_bzero.obj : [.lib]explicit_bzero.c $(config_h)

[.lib]exitfail.obj : [.lib]exitfail.c $(config_h) [.lib]exitfail.h

[.lib]faccessat.obj : [.lib]faccessat.c $(config_h) $(at_func_c)

[.lib]fadvise.obj : [.lib]fadvise.c $(config_h) [.lib]fadvise.h \
	[.lib]ignore-value.h

#[.lib]fatal-signal.obj : [.lib]fatal-signal.c $(config_h) \
#	[.lib]fatal-signal.h [.lib]sig-handler.h [.lib]xalloc.h

# Locally replaced
#[.lib]fchdir.obj : [.lib]fchdir.c $(config_h) \
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

[.lib]fflush.obj : [.lib]fflush.c $(config_h) [.lib]stdio-impl.h

[.lib]file-has-acl.obj : [.lib]file-has-acl.c $(config_h) \
	$(acl-internal_h)

[.lib]acl-internal.obj : [.lib]acl-internal.c $(config_h) $(acl_internal.h)

[.lib]set-permissions.obj : [.lib]set-permissions.c $(config_h) \
	$(acl_internal.h)

[.lib]get-permissions.obj : [.lib]get-permissions.c $(config_h) \
	$(acl_internal.h)

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

[.lib]fprintftime.obj : [.lib]fprintftime.c

[.lib]fpurge.obj : [.lib]fpurge.c $(config_h) [.lib]stdio_ext.h \
	[.lib]stdio-impl.h

[.lib]freadahead.obj : [.lib]freadahead.c $(config_h) \
	$(freadahead_h) [.lib]stdio-impl.h

[.lib]freading.obj : [.lib]freading.c $(config_h) $(freading_h) \
	[.lib]stdio-impl.h

[.lib]freadptr.obj : [.lib]freadptr.c $(config_h) $(freadptr_h) \
	[.lib]stdio-impl.h

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

[.lib]fseterr.obj : [.lib]fseterr.c $(config_h) $(fseterr_h) \
	[.lib]stdio-impl.h

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
# [.lib]getcwdat.h debug only

[.lib]fts.obj : [.lib]fts.c $(config_h) [.lib]fts_.h \
	$(fcntl___h) $(dirent___h) $(unistd___h) \
	[.lib]cloexec.h [.lib]openat.h [.lib]same-inode.h \
	$(fts_cycle_c) [.vms]vms_pwd_hack.h [.lib]stdalign.h

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

[.lib]getdelim.obj : [.lib]getdelim.c $(config_h) [.lib]unlocked-io.h

[.lib]getdtablesize.obj : [.lib]getdtablesize.c $(config_h) \
	[.lib]msvc-inval.h

[.lib]getfilecon.obj : [.lib]getfilecon.c $(config_h) \
	[.lib.selinux]selinux.h [.lib.selinux]label.h

[.lib]getgroups.obj : [.lib]getgroups.c $(config_h)

# Use VMS CRTL
#[.lib]gethostname.obj : [.lib]gethostname.c $(config_h) \
#	$(w32sock_h) $(sockets_h)

[.lib]gethrxtime.obj : [.lib]gethrxtime.c $(config_h) \
	$(gethrxtime_h) [.lib]timespec.h

#[.lib]gl_linked_list.obj : [.lib]gl_linked_list.c $(config_h) \
#	$(gl_linked_list_h) [.lib]gl_anylinked_list1.h \
#        [.lib]gl_anylinked_list2.h

[.lib]getline.obj : [.lib]getline.c $(config_h)

lcl_root:[.lib]getloadavg.c : src_root:[.lib]getloadavg.c [.vms]lib_getloadavg_c.tpu
                    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
                    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.lib]getloadavg.obj : lcl_root:[.lib]getloadavg.c $(config_h) [.lib]intprops.h

# Use VMS CRTL
#[.lib]getlogin.obj : [.lib]getlogin.c $(config_h)

[.lib]getndelim2.obj : [.lib]getndelim2.c $(config_h) \
	[.lib]getndelim2.h [.lib]unlocked-io.h

[.lib]getopt.obj : [.lib]getopt.c $(config_h) [.lib]getopt.h \
	[.lib]gettext.h [.lib]getopt-cdefs.h

[.lib]getopt1.obj : [.lib]getopt1.c $(config_h) $(getopt_int_h)

[.lib]getpagesize.obj : [.lib]getpagesize.c $(config_h)

[.lib]getpass.obj : [.lib]getpass.c $(config_h) [.lib]getpass.h \
	[.lib]unlocked-io.h [.lib]stdio_ext.h $(termios_h)

[.lib]getrandom.obj : [.lib]getrandom.c $(config_h) lcl_root:[.lib.sys]random.h

[.lib]gettime.obj : [.lib]gettime.c $(config_h) [.lib]timespec.h

[.lib]gettime-res.obj : [.lib]gettime-res.c $(config_h) [.lib]timespec.h

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

[.lib]iconv.obj : [.lib]iconv.c $(config_h) $(unistr_h)

[.lib]iconv_close.obj : [.lib]iconv_close.c $(config_h)

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

#[.lib]isnan.obj : $(isnan_c)

lcl_root:[.lib]isnan.c : src_root:[.lib]isnan.c [.vms]lib_isnan_c.tpu
                    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
                    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.lib]isnand.obj : [.lib]isnand.c $(isnan_c)

[.lib]isnanf.obj : [.lib]isnanf.c $(isnan_c)

[.lib]isnanl.obj : [.lib]isnanl.c $(isnan_c)

[.lib]itold.obj : [.lib]itold.c $(config_h)

[.lib]lchown.obj : [.lib]lchown.c $(config_h)

[.lib]ldtoastr.obj : [.lib]ldtoastr.c $(config_h) $(ftoastr_c)

[.lib]lchmod.obj : [.lib]lchmod.c $(config_h)

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
	[.lib]long-options.h [.lib]version-etc.h [.lib]getopt.h \
	[.lib]getopt-cdefs.h

[.lib]lseek.obj : [.lib]lseek.c $(config_h) [.lib]msvc-nothrow.h

[.lib]lstat.obj : [.lib]lstat.c $(config_h)

[.lib]malloc.obj : [.lib]malloc.c $(config_h)

[.lib]malloca.obj : [.lib]malloca.c $(config_h) $(malloca_h) \
	[.lib]verify.h

# [.lib]math.h - try to use VMS provided library instead.
[.lib]math.obj : [.lib]math.c $(config_h)

[.lib]mbchar.obj : [.lib]mbchar.c $(config_h) [.lib]mbchar.h

[.lib]mbiter.obj : [.lib]mbiter.c $(config_h) $(mbiter_h)

# Use VMS CRTL
#[.lib]mbrlen.obj : [.lib]mbrlen.c $(config_h)

[.lib]mbrtowc.obj : [.lib]mbrtowc.c $(config_h) \
	[.lib]localcharset.h [.lib]streq.h [.lib]verify.h

[.lib]mbsalign.obj : [.lib]mbsalign.c $(config_h) [.lib]mbsalign.h

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
	[.lib]stdalign.h [.lib]byteswap.h

[.lib]memcasecmp.obj : [.lib]memcasecmp.c $(config_h) [.lib]memcasecmp.h

# Use VMS CRTL
#[.lib]memchr.obj : [.lib]memchr.c $(config_h)

[.lib]memchr2.obj : [.lib]memchr2.c $(config_h) [.lib]memchr2.h

[.lib]memcmp2.obj : [.lib]memcmp2.c $(config_h) [.lib]memcmp2.h

[.lib]memcoll.obj : [.lib]memcoll.c $(config_h) [.lib]memcoll.h

[.lib]mempcpy.obj : [.lib]mempcpy.c $(config_h)

[.lib]memrchr.obj : [.lib]memrchr.c $(config_h)

[.lib]mgetgroups.obj : [.lib]mgetgroups.c $(config_h) \
	[.lib]mgetgroups.h [.lib]getugroups.h [.lib]xalloc-oversized.h

[.lib]mkancesdirs.obj : [.lib]mkancesdirs.c $(config_h) \
	[.lib]mkancesdirs.h $(dirname_h) [.lib]savewd.h

[.lib]mkdir-p.obj : [.lib]mkdir-p.c $(config_h) [.lib]mkdir-p.h \
	[.lib]gettext.h [.lib]dirchownmod.h $(dirname_h) \
	[.lib]error.h [.lib]quote.h [.lib]mkancesdirs.h [.lib]savewd.h

[.lib]mkdirat.obj : [.lib]mkdirat.c $(config_h) $(dirname_h)

[.lib]mkfifo.obj : [.lib]mkfifo.c $(config_h)

[.lib]mknod.obj : [.lib]mknod.c $(config_h)

[.lib]mknodat.obj : [.lib]mknodat.c $(config_h)

[.lib]mkstemp-safer.obj : [.lib]mkstemp-safer.c $(config_h) \
	[.lib]stdlib-safer.h [.lib]unistd-safer.h

# Use VMS CRTL
#[.lib]mkstemp.obj : [.lib]mkstemp.c $(config_h) [.lib]tempname.h

# Can not Use VMS CRTL
[.lib]mktime.obj : [.lib]mktime.c $(config_h) [.lib]mktime-internal.h

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
	lcl_root:[.lib]sched.h

[.lib]nstrftime.obj : [.lib]nstrftime.c $(config_h)

[.lib]obstack.obj : [.lib]obstack.c $(config_h) [.lib]obstack.h \
	[.lib]gettext.h

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
	[.lib]openat.h [.lib]openat-priv.h [.lib]save-cwd.h

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

#[.lib]pipe2-safer.obj : [.lib]pipe2-safer.c $(config_h) \
#	[.lib]unistd-safer.h

# pipe2 does not use [.lib]nonblocking.h
#[.lib]pipe2.obj : [.lib]pipe2.c $(config_h) \
#	[.lib]verify.h

[.lib]posixtm.obj : [.lib]posixtm.c $(config_h) [.lib]posixtm.h \
	[.lib]unlocked-io.h

[.lib]posixver.obj : [.lib]posixver.c $(config_h) [.lib]posixver.h

[.lib]printf-args.obj : [.lib]printf-args.c $(config_h) [.lib]printf-args.h

[.lib]printf-frexp.obj : $(printf_frexp_c) $(config_h) \
	[.lib]printf-frexpl.h [.lib]printf-frexp.h [.lib]fpucw.h

[.lib]printf-frexpl.obj : [.lib]printf-frexpl.c $(config_h) \
	[.lib]printf-frexpl.h [.lib]printf-frexp.h $(printf_frexp_c)

[.lib]printf-parse.obj : [.lib]printf-parse.c $(config_h) \
	[.lib]printf-parse.h $(xsize_h) [.lib]c-ctype.h

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

[.lib]qcopy-acl.obj : [.lib]qcopy-acl.c $(config_h) [.lib]acl.h \
	$(acl-internal_h)

[.lib]qset-acl.obj : [.lib]qset-acl.c $(config_h) [.lib]acl.h \
	$(acl-internal_h)

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
	[.lib]unlocked-io.h [.lib]xalloc.h [.lib]stdalign.h \
	lcl_root:[.lib.sys]random.h

[.lib]rawmemchr.obj : [.lib]rawmemchr.c $(config_h) [.lib]stdalign.h

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
	[.lib]xalloc.h [.lib]unlocked-io.h

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

[.lib]renameat.obj : [.lib]renameat.c $(config_h)

[.lib]renameatu.obj : [.lib]renameatu.c $(config_h) [.lib]renameatu.h

# Windows Only?
#[.lib]rewinddir.obj : [.lib]rewinddir.c $(config_h) [.lib]dirent-private.h

[.lib]rmdir.obj : [.lib]rmdir.c $(config_h)

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

[.lib]savewd.obj : lcl_root:[.lib]savewd.c $(config_h) [.lib]savewd.h \
	[.lib]fcntl-safer.h

#[.lib]se-context.obj : [.lib]se-context.c $(config_h)

#[.lib]se-selinux.obj : [.lib]se-selinux.c $(config_h)

# Use VMS CRTL or the terminal replacement routine.
#[.lib]select.obj : [.lib]select.c $(config_h) \
#	[.lib]msvc-nothrow.h

[.lib]selinux-at.obj : [.lib]selinux-at.c $(config_h) \
	$(selinux_at_h) [.lib]openat.h $(dirname_h) \
	[.lib]save-cwd.h [.lib]openat-priv.h $(at_func_c)

[.lib]set-acl.obj : [.lib]set-acl.c \
	$(config_h) $(acl_internal_h) [.lib]gettext.h

[.lib]setenv.obj : [.lib]setenv.c $(config_h) $(malloca_h)

[.lib]settime.obj : [.lib]settime.c $(config_h) [.lib]timespec.h

[.lib]sha1.obj : [.lib]sha1.c $(config_h) $(sha1_h) [.lib]unlocked-io.h \
	[.lib]stdalign.h [.lib]byteswap.h

[.lib]sha1-stream.obj : [.lib]sha1-stream.c $(config_h) $(sha1_h) [.lib]unlocked-io.h \
	[.lib]stdalign.h [.lib]byteswap.h

[.lib]sha256.obj : [.lib]sha256.c $(config_h) $(sha256_h) \
	[.lib]unlocked-io.h [.lib]stdalign.h [.lib]byteswap.h

[.lib]sha256-stream.obj : [.lib]sha256-stream.c $(config_h) $(sha256_h) \
	[.lib]unlocked-io.h [.lib]stdalign.h [.lib]byteswap.h

[.lib]sha512.obj : [.lib]sha512.c $(config_h) $(sha512_h) \
	[.lib]unlocked-io.h [.lib]stdalign.h [.lib]byteswap.h

[.lib]sha512-stream.obj : [.lib]sha512-stream.c $(config_h) $(sha512_h) \
	[.lib]unlocked-io.h [.lib]stdalign.h [.lib]byteswap.h

[.lib]sm3.obj : [.lib]sm3.c $(config_h) [.lib]sm3.h \
	[.lib]unlocked-io.h [.lib]stdalign.h [.lib]byteswap.h

[.lib]sm3-stream.obj : [.lib]sm3-stream.c $(config_h) [.lib]sm3.h \
	[.lib]unlocked-io.h [.lib]stdalign.h [.lib]byteswap.h

[.lib]sig-handler.obj : [.lib]sig-handler.c $(config_h) [.lib]sig-handler.h

[.lib]sig2str.obj : [.lib]sig2str.c $(config_h) $(sig2str_h)

# Use VMS CRTL
#[.lib]sigaction.obj : [.lib]sigaction.c $(config_h)

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
	[.lib]spawn-pipe.h [.lib]error.h \
	[.lib]unistd-safer.h [.lib]gettext.h \
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

[.lib]stat.obj : [.lib]stat.c $(config_h) \
	[.lib]verify.h [.lib]pathmax.h

[.lib]statat.obj : [.lib]statat.c $(config_h) [.lib]openat.h

[.lib]stpncpy.obj : [.lib]stpncpy.c $(config_h)

#[.lib]strchrnul.obj : [.lib]strchrnul.c $(config_h)

# Use VMS CRTL
#[.lib]strdup.obj : [.lib]strdup.c $(config_h)

# Use VMS CRTL
#[.lib]strerror-override.obj : [.lib]strerror-override.c \
#	$(config_h) [.lib]strerror-override.h

# Use VMS CRTL
#[.lib]strerror.obj : [.lib]strerror.c $(config_h) [.lib]intprops.h \
#	[.lib]strerror-override.h [.lib]verify.h

[.lib]striconv.obj : [.lib]striconv.c $(config_h) [.lib]striconv.h \
	[.lib]c-strcase.h

[.lib]strintcmp.obj : [.lib]strintcmp.c $(config_h) $(strnumcmp_in_h)

[.lib]stripslash.obj : [.lib]stripslash.c $(config_h) $(dirname_h)

# Use VMS CRTL
#[.lib]strncat.obj : [.lib]strncat.c $(config_h)

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

# Use VMS CRTL
#[.lib]strtol.obj : $(strtol_c)

# Use VMS CRTL
#[.lib]strtoll.obj : [.lib]strtoll.c $(strtol_c)

# Use VMS CRTL
#[.lib]strtoul.obj : [.lib]strtoul.c $(strtol_c)

# Use VMS CRTL
#[.lib]strtoull.obj : [.lib]strtoull.c $(strtol_c)

[.lib]symlinkat.obj : [.lib]symlinkat.c $(config_h)

[.lib]sys_socket.obj : [.lib]sys_socket.c $(config_h) \
	[.vms]vms_ioctl_hack.h

[.lib]targetdir.obj : [.lib]targetdir.c $(config_h) [.lib]targetdir.h

[.lib]tempname.obj : [.lib]tempname.c $(config_h) [.lib]tempname.h \
	[.lib]randint.h lcl_root:[.lib.sys]random.h [.lib]stdalign.h

[.lib]timegm.obj : [.lib]timegm.c $(config_h) [.lib]mktime-internal.h

[.lib]timespec.obj : [.lib]timespec.c $(config_h) [.lib]timespec.h

# Use VMS CRTL
#[.lib]time_r.obj : [.lib]time_r.c $(config_h)

[.lib]time_rz.obj : [.lib]time_rz.c $(config_h) [.lib]time-internal.h

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

[.lib]unlink.obj : [.lib]unlink.c $(config_h)

[.lib]unlinkat.obj : [.lib]unlinkat.c $(config_h) \
	[.lib]openat.h $(at_func_c)

[.lib]unlinkdir.obj : [.lib]unlinkdir.c $(config_h)

[.lib]unsetenv.obj : [.lib]unsetenv.c $(config_h)

[.lib]userspec.obj : [.lib]userspec.c $(config_h) [.lib]userspec.h \
	[.lib]intprops.h $(inttostr_h) [.lib]xalloc.h $(xstrtol_h) \
	[.lib]gettext.h

[.lib]utimecmp.obj : [.lib]utimecmp.c $(config_h) [.lib]utimecmp.h \
	[.lib]hash.h [.lib]intprops.h [.lib]stat-time.h [.lib]utimens.h \
	[.lib]verify.h

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

#[.lib]wait-process.obj : [.lib]wait-process.c $(config_h) \
#	[.lib]wait-process.h [.lib]error.h \
#	[.lib]xalloc.h [.lib]gettext.h

# Use VMS CRTL
#[.lib]waitpid.obj : [.lib]waitpid.c $(config_h)

# Use VMS CRTL
#[.lib]wcrtomb.obj : [.lib]wcrtomb.c $(config_h)

# Use VMS CRTL
#[.lib]wcswidth.obj : [.lib]wcswidth.c $(config_h) [.lib]wcswidth-impl.h

# Use VMS [.lib]wctype.h
#[.lib]wctype-h.obj : [.lib]wctype-h.c $(config_h)

# Use VMS CRTL
#[.lib]wcwidth.obj : [.lib]wcwidth.c $(config_h) \
#	[.lib]localcharset.h [.lib]streq.h [.lib]uniwidth.h

[.lib]wmempcpy.obj : [.lib]wmempcpy.c $(config_h)

[.lib]write-any-file.obj : [.lib]write-any-file.c $(config_h) \
	[.lib]write-any-file.h [.lib]priv-set.h [.lib]root-uid.h \

[.lib]write.obj : [.lib]write.c $(config_h) [.lib]msvc-inval.h \
	[.lib]msvc-nothrow.h

[.lib]xalloc-die.obj : [.lib]xalloc-die.c $(config_h) [.lib]xalloc.h \
	[.lib]error.h [.lib]exitfail.h [.lib]gettext.h

[.lib]xasprintf.obj : [.lib]xasprintf.c $(config_h) [.lib]xvasprintf.h

[.lib]xfts.obj : [.lib]xfts.c $(config_h) [.lib]xalloc.h $(xfts_h)

[.lib]xgetcwd.obj : [.lib]xgetcwd.c $(config_h) [.lib]xgetcwd.h \
	[.lib]xalloc.h [.vms]vms_pwd_hack.h

[.lib]xgetgroups.obj : [.lib]xgetgroups.c $(config_h) \
	[.lib]mgetgroups.h [.lib]xalloc.h

[.lib]xgethostname.obj : [.lib]xgethostname.c $(config_h) \
	[.lib]xgethostname.h [.lib]xalloc.h

[.lib]xdectoimax.obj : [.lib]xdectoimax.c $(xdectoint_c)

[.lib]xdectoumax.obj : [.lib]xdectoumax.c $(xdectoint_c)

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

[.src]vms_crtl_values.obj : [.vms]vms_crtl_values.c

[.lib]vms_execvp_hack.obj : [.vms]vms_execvp_hack.c

[.lib]vms_gethostid.obj : [.vms]vms_gethostid.c

[.lib]vms_get_foreign_cmd.obj : [.vms]vms_get_foreign_cmd.c

[.lib]vms_getmntinfo.obj : [.vms]vms_getmntinfo.c [.lib.sys]mount.h

[.lib]vms_fname_to_unix.obj : [.vms]vms_fname_to_unix.c

[.lib]vms_term.obj : [.vms]vms_term.c [.vms]vms_term.h

[.lib]vms_terminal_io.obj : [.vms]vms_terminal_io.c [.vms]vms_terminal_io.h

[.lib]gnv_vms_iconv_wrapper.obj : [.vms]gnv_vms_iconv_wrapper.c

# New files for coreutils 9.1.

[.lib.malloc]dynarray_at_failure.obj : [.lib.malloc]dynarray_at_failure.c \
	[.lib.malloc]dynarray.h lcl_root:[.lib.malloc]dynarray.gl.h \
	lcl_root:[.lib.malloc]dynarray-skeleton.gl.h

[.lib.malloc]dynarray_emplace_enlarge.obj : [.lib.malloc]dynarray_emplace_enlarge.c \
	[.lib.malloc]dynarray.h lcl_root:[.lib.malloc]dynarray.gl.h \
	lcl_root:[.lib.malloc]dynarray-skeleton.gl.h

[.lib.malloc]dynarray_finalize.obj : [.lib.malloc]dynarray_finalize.c \
	[.lib.malloc]dynarray.h lcl_root:[.lib.malloc]dynarray.gl.h \
	lcl_root:[.lib.malloc]dynarray-skeleton.gl.h

[.lib.malloc]dynarray_resize.obj : [.lib.malloc]dynarray_resize.c \
	[.lib.malloc]dynarray.h lcl_root:[.lib.malloc]dynarray.gl.h \
	lcl_root:[.lib.malloc]dynarray-skeleton.gl.h

[.lib.malloc]dynarray_resize_clear.obj : [.lib.malloc]dynarray_resize_clear.c \
	[.lib.malloc]dynarray.h lcl_root:[.lib.malloc]dynarray.gl.h \
	lcl_root:[.lib.malloc]dynarray-skeleton.gl.h

[.lib.malloc]scratch_buffer_dupfree.obj : [.lib.malloc]scratch_buffer_dupfree.c \
	lcl_root:[.lib.malloc]scratch_buffer_gl.h lcl_root:[.lib]scratch_buffer.h

[.lib.malloc]scratch_buffer_grow.obj : [.lib.malloc]scratch_buffer_grow.c \
	lcl_root:[.lib.malloc]scratch_buffer_gl.h lcl_root:[.lib]scratch_buffer.h

[.lib.malloc]scratch_buffer_grow_preserve.obj : lcl_root:[.lib.malloc]scratch_buffer_gl.h \
	[.lib.malloc]scratch_buffer_grow_preserve.c lcl_root:[.lib]scratch_buffer.h

[.lib.malloc]scratch_buffer_set_array_size.obj : lcl_root:[.lib.malloc]scratch_buffer_gl.h \
	[.lib.malloc]scratch_buffer_set_array_size.c lcl_root:[.lib]scratch_buffer.h

[.src]version.obj : [.src]version.c

[.src]version.c : [.vms]version_c.com sys$disk:[]configure.
	$ @[.vms]version_c.com

[.src]version.h : [.vms]version_h.com
	$ @[.vms]version_h.com

[.src]uname.obj : [.src]uname.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]quote.h [.src]uname.h

[.src]uname-arch.obj : [.src]uname-arch.c [.src]uname.h

crtl_init = sys$disk:[.src]vms_crtl_init.obj, sys$disk:[.src]vms_crtl_values.obj

[.src]arch$(EXEEXT) : $(src_arch_OBJECTS) $(src_arch_DEPENDENCIES) \
		$(EXTRA_src_arch_DEPENDENCIES)
	link/exe=$(MMS$TARGET) [.src]uname.obj, [.src]uname-arch.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src.blake2]b2sum.obj : [.src.blake2]b2sum.c $(config_h) $(system_h) \
	$(md5_h) $(sha1_h) $(sha256_h) $(sha512_h) [.lib]error.h \
	[.lib]fadvise.h $(stdio___h)
   $define/user glthread sys$disk:[.lib.glthread]
   $define/user selinux sys$disk:[.lib.selinux]
   $define/user blake2 sys$disk:[.src.blake2]
   $define/user decc$user_include sys$disk:[.src],sys$disk:[.src.blake2]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),HASH_ALGO_BLAKE2=1) \
	/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.src]src_b2sum-digest.obj : [.src]digest.c $(config_h) $(system_h) \
	$(md5_h) $(sha1_h) $(sha256_h) $(sha512_h) [.lib]error.h \
	[.lib]fadvise.h $(stdio___h)
   $define/user glthread sys$disk:[.lib.glthread]
   $define/user selinux sys$disk:[.lib.selinux]
   $define/user blake2 sys$disk:[.src.blake2]
   $define/user decc$user_include sys$disk:[.src],sys$disk:[.lib.uniwidth]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),HASH_ALGO_BLAKE2=1) \
	/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.src]b2sum$(EXEEXT) : $(src_b2sum_OBJECTS) $(src_b2sum_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src.blake2]b2sum.obj, [.src]src_b2sum-digest.obj, \
		[.src.blake2]blake2b-ref.obj, [.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]base64.obj : [.src]base64.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fadvise.h $(xstrtol_h) [.lib]quote.h [.lib]quotearg.h \
	[.lib]base64.h

[.src]base64$(EXEEXT) : $(src_base64_OBJECTS) $(src_base64_DEPENDENCIES) \
		$(EXTRA_src_base64_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]base64.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]basename.obj : [.src]basename.c $(config_h) [.lib]error.h \
	[.lib]quote.h

[.src]basename$(EXEEXT) : $(src_basename_OBJECTS) $(src_basename_DEPENDENCIES) \
		$(EXTRA_src_basename_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]basename.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src.blake2]blake2b-ref.obj : [.src.blake2]blake2b-ref.c $(config_h) [.src.blake2]blake2.h \
	[.src.blake2]blake2-impl.h
   $define/user blake2 sys$disk:[.src.blake2]
   $define/user decc$user_include sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.src.blake2]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),HASH_ALGO_BLAKE2=1) \
	/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.src]cat.obj : [.src]cat.c $(config_h) $(system_h) $(ioblksize_h) \
	[.lib]error.h [.lib]fadvise.h [.lib]full-write.c [.lib]quote.h \
	[.lib]safe-read.h sys$disk:[.vms]vms_ioctl_hack.h

[.src]cat$(EXEEXT) : $(src_cat_OBJECTS) $(src_cat_DEPENDENCIES) \
		$(EXTRA_src_cat_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]cat.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]chcon.obj : [.src]chcon.c $(config_h) $(system_h) [.lib]dev-ino.h \
	[.lib]error.h [.lib]ignore-value.h [.lib]quote.h [.lib]quotearg.h \
	$(root_dev_ino_h) $(xfts_h) [.lib.selinux]selinux.h \
	[.lib.selinux]context.h

[.src]chcon$(EXEEXT) : $(src_chcon_OBJECTS) $(src_chcon_DEPENDENCIES) \
		$(EXTRA_src_chcon_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]chcon.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

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
		$(crtl_init)

[.src]chmod.obj : [.src]chmod.c $(config_h) $(system_h) [.lib]dev-ino.h \
	[.lib]error.h [.lib]filemode.h [.lib]ignore-value.h \
	[.lib]modechange.h [.lib]quote.h [.lib]quotearg.h \
	$(root_dev_ino_h) $(xfts_h)

[.src]chmod$(EXEEXT) : $(src_chmod_OBJECTS) $(src_chmod_DEPENDENCIES) \
		$(EXTRA_src_chmod_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]chmod.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]chown.obj : [.src]chown.c  $(config_h) \
	$(system_h) $(chown_core_h) \
	[.lib]error.h [.lib]fts_.h [.lib]quote.h \
	$(root_dev_ino_h) [.lib]userspec.h

[.src]chown$(EXEEXT) : $(src_chown_OBJECTS) $(src_chown_DEPENDENCIES) \
		$(EXTRA_src_chown_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]chown.obj, [.src]chown-core.obj,\
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]chroot.obj : [.src]chroot.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]quote.h [.lib]userspec.h $(xstrtol_h)

[.src]chroot$(EXEEXT) : $(src_chroot_OBJECTS) $(src_chroot_DEPENDENCIES) \
		$(EXTRA_src_chroot_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]chroot.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]src_cksum-digest.obj : [.src]digest.c $(config_h) $(system_h) \
	$(md5_h) $(sha1_h) $(sha256_h) $(sha512_h) [.lib]error.h \
	[.lib]fadvise.h $(stdio___h)
   $define/user glthread sys$disk:[.lib.glthread]
   $define/user selinux sys$disk:[.lib.selinux]
   $define/user blake2 sys$disk:[.src.blake2]
   $define/user decc$user_include sys$disk:[.src],sys$disk:[.lib.uniwidth]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),HASH_ALGO_CKSUM=1) \
	/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.src]cksum.obj : [.src]cksum.c $(config_h) $(system_h) [.lib]fadvise.h \
	[.lib]long-options.h [.lib]error.h

[.src]cksum$(EXEEXT) : $(src_cksum_OBJECTS) $(src_cksum_DEPENDENCIES) \
		$(EXTRA_src_cksum_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]cksum.obj, \
		[.src.blake2]blake2b-ref.obj, [.src.blake2]b2sum.obj, \
		[.src]crctab.obj, [.src]sum.obj, [.src]src_cksum-digest.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]comm.obj : [.src]comm.c $(config_h) $(system_h) \
	[.lib]linebuffer.h [.lib]error.h [.lib]fadvise.h \
	[.lib]hard-locale.h [.lib]quote.h $(stdio___h) \
	[.lib]memcmp2.h [.lib]xmemcoll.h

[.src]comm$(EXEEXT) : $(src_comm_OBJECTS) $(src_comm_DEPENDENCIES) \
		$(EXTRA_src_comm_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]comm.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]cp.obj : [.src]cp.c $(config_h) $(system_h) $(argmatch_h) \
	[.lib]backupfile.h $(copy_h) [.src]cp-hash.h [.lib]error.h \
	[.lib]filenamecat.h [.lib]ignore-value.h [.lib]quote.h \
	[.lib]stat-time.h [.lib]quote.h [.lib]utimens.h [.lib]acl.h \
	[.lib.selinux]selinux.h [.lib.selinux]label.h

[.src]copy.obj : [.src]copy.c $(config_h) $(system_h) [.lib]acl.h \
	[.lib]backupfile.h [.lib]buffer-lcm.h [.lib]canonicalize.h \
	$(copy_h) [.src]cp-hash.h [.lib]error.h \
	[.lib]fadvise.h $(fcntl__h) $(file_set_h) \
	[.lib]filemode.h [.lib]filenamecat.h [.lib]full-write.h \
	[.lib]hash-triple.h [.lib]ignore-value.h $(ioblksize_h) \
	[.lib]quote.h [.lib]same.h [.lib]savedir.h [.lib]stat-time.h \
	[.lib]utimecmp.h [.lib]utimens.h [.lib]write-any-file.h \
	[.lib]areadlink.h [.lib]yesno.h $(verror_h) \
	sys$disk:[.vms]vms_ioctl_hack.h sys$disk:[.vms]vms_rename_hack.h

[.src]src_ginstall-copy.obj : [.src]copy.c $(config_h) \
	$(system_h) [.lib]acl.h [.lib.selinux]selinux.h [.lib.selinux]label.h \
	[.lib]backupfile.h [.lib]buffer-lcm.h [.lib]canonicalize.h \
	$(copy_h) [.src]cp-hash.h [.lib]error.h \
	[.lib]fadvise.h $(fcntl__h) $(file_set_h) \
	[.lib]filemode.h [.lib]filenamecat.h [.lib]full-write.h \
	[.lib]hash-triple.h [.lib]ignore-value.h $(ioblksize_h) \
	[.lib]quote.h [.lib]same.h [.lib]savedir.h [.lib]stat-time.h \
	[.lib]utimecmp.h [.lib]utimens.h [.lib]write-any-file.h \
	[.lib]areadlink.h [.lib]yesno.h $(verror_h)

[.src]cp-hash.obj : [.src]cp-hash.c $(config_h) $(system_h) [.lib]hash.h \
	[.src]cp-hash.h

[.src]src_ginstall-cp-hash.obj : [.src]cp-hash.c $(config_h) \
	$(system_h) [.lib]hash.h [.src]cp-hash.h

[.src]cp$(EXEEXT) : $(src_cp_OBJECTS) $(src_cp_DEPENDENCIES) \
		$(EXTRA_src_cp_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]cp.obj, [.src]copy.obj, \
		[.src]cp-hash.obj, [.src]force-link.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]csplit.obj : [.src]csplit.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]fd-reopen.h [.lib]quote.h [.lib]safe-read.h \
	$(stdio___h) $(xstrtol_h)

[.src]csplit$(EXEEXT) : $(src_csplit_OBJECTS) $(src_csplit_DEPENDENCIES) \
		$(EXTRA_src_csplit_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]csplit.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]set-fields.obj : [.src]set-fields.c $(config_h) [.lib]quote.h \
	[.src]set-fields.h

[.src]cut.obj : [.src]cut.c $(config_h) $(signal_h) [.lib]error.h \
	[.lib]fadvise.h [.lib]getndelim2.h [.lib]hash.h \
	[.lib]quote.h

[.src]cut$(EXEEXT) : $(src_cut_OBJECTS) $(src_cut_DEPENDENCIES) \
		$(EXTRA_src_cut_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]cut.obj, [.src]set-fields.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]date.obj : [.src]date.c $(config_h) $(system_h) $(argmatch_h) \
	[.lib]error.h [.lib]parse-datetime.h [.lib]posixtm.h \
	[.lib]quote.h [.lib]stat-time.h [.lib]fprintftime.h

[.src]date$(EXEEXT) : $(src_date_OBJECTS) $(src_date_DEPENDENCIES) \
		$(EXTRA_src_date_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]date.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]dd.obj : [.src]dd.c $(config_h) $(system_h) [.lib]close-stream.h \
	$(gethrxtime_h) $(human_h) [.lib]long-options.h [.lib]error.h \
	[.lib]fd-reopen.h [.lib]quote.h [.lib]quotearg.h \
	$(xstrtol_h) [.lib]xtime.h sys$disk:[.vms]vms_ioctl_hack.h

[.src]dd$(EXEEXT) : $(src_dd_OBJECTS) $(src_dd_DEPENDENCIES) \
	$(EXTRA_src_dd_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]dd.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

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
		$(crtl_init)

[.src]ls.obj : [.src]ls.c $(config_h) $(termios_h) [.lib.selinux]selinux.h \
	$(system_h) [.lib]acl.h $(argmatch_h) [.lib]dev-ino.h \
	[.lib]error.h [.lib]filenamecat.h [.lib]hard-locale.h \
	[.lib]hash.h $(human_h) [.lib]filemode.h [.lib]filevercmp.h \
	[.lib]idcache.h [.src]ls.h [.lib]mbswidth.h [.lib]mpsort.h \
	[.lib]obstack.h [.lib]quote.h [.lib]quotearg.h [.lib]stat-size.h \
	[.lib]stat-time.h [.lib]strftime.h $(xstrtol_h) [.lib.selinux]label.h \
	[.lib]areadlink.h [.lib]mbsalign.h sys$disk:[.vms]vms_ioctl_hack.h

[.src]ls-dir.obj : [.src]ls-dir.c [.src]ls.h

[.src]dir$(EXEEXT) : $(src_dir_OBJECTS) $(src_dir_DEPENDENCIES) \
		$(EXTRA_src_dir_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]ls.obj, [.src]ls-dir.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]dircolors.obj : [.src]dircolors.c $(config_h) $(system_h) \
	[.src]dircolors.c [.lib]c-strcase.h [.lib]error.h \
	[.lib]obstack.h [.lib]quote.h $(stdio___h)

[.src]dircolors$(EXEEXT) : $(src_dircolors_OBJECTS) \
		$(src_dircolors_DEPENDENCIES) \
		$(EXTRA_src_dircolors_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]dircolors.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]dirname.obj : [.src]dirname.c $(config_h) $(system_h) [.lib]error.h

[.src]dirname$(EXEEXT) : $(src_dirname_OBJECTS) $(src_dirname_DEPENDENCIES) \
		$(EXTRA_src_dirname_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]dirname.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

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
		$(crtl_init)

[.src]echo.obj : [.src]echo.c $(config_h) $(system_h)

[.src]echo$(EXEEXT) : $(src_echo_OBJECTS) $(src_echo_DEPENDENCIES) \
		$(EXTRA_src_echo_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]echo.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]env.obj : [.src]env.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]quote.h

[.src]env$(EXEEXT) : $(src_env_OBJECTS) $(src_env_DEPENDENCIES) \
		$(EXTRA_src_env_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]env.obj, [.src]operand2sig.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]expand-common.obj : [.src]expand-common.c [.src]expand-common.h \
        $(config_h) $(system_h) [.src]die.h [.lib]error.h \
        [.lib]fadvise.h [.lib]quote.h

[.src]expand.obj : [.src]expand.c $(config_h) [.src]expand-common.h \
        $(system_h) [.lib]error.h \
	[.lib]fadvise.h [.lib]quote.h

[.src]expand$(EXEEXT) : $(src_expand_OBJECTS) $(src_expand_DEPENDENCIES) \
		$(EXTRA_src_expand_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]expand.obj, [.src]expand-common.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]expr.obj : [.src]expr.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]long-options.h [.lib]quotearg.h [.lib]strnumcmp.h \
	$(xstrtol_h)

[.src]expr$(EXEEXT) : $(src_expr_OBJECTS) $(src_expr_DEPENDENCIES) \
		$(EXTRA_src_expr_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]expr.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]factor.obj : [.src]factor.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]quote.h [.lib]readtokens.h $(xstrtol_h) [.src]longlong.h \
	[.src]primes.h

[.src]factor$(EXEEXT) : $(src_factor_OBJECTS) $(src_factor_DEPENDENCIES) \
		$(EXTRA_src_factor_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]factor.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]false.obj : [.src]false.c $(true_c)

[.src]false$(EXEEXT) : $(src_false_OBJECTS) $(src_false_DEPENDENCIES) \
		$(EXTRA_src_false_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]false.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]fmt.obj : [.src]fmt.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fadvise.h [.lib]quote.h $(xstrtol_h)

[.src]fmt$(EXEEXT) : $(src_fmt_OBJECTS) $(src_fmt_DEPENDENCIES) \
		$(EXTRA_src_fmt_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]fmt.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]fold.obj : [.src]fold.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fadvise.h [.lib]quote.h $(xstrtol_h)

[.src]fold$(EXEEXT) : $(src_fold_OBJECTS) $(src_fold_DEPENDENCIES) \
		$(EXTRA_src_fold_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]fold.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]force-link.obj : [.src]force-link.c $(config_h) [.src]force-link.h

[.src]getlimits.obj : [.src]getlimits.c $(config_h) $(system_h) \
	[.lib]long-options.h

[.src]getlimits$(EXEEXT) : $(src_getlimits_OBJECTS) \
		$(src_getlimits_DEPENDENCIES) \
		$(EXTRA_src_getlimits_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]getlimits.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# Note: vfork() should work in place of fork()
[.src]src_ginstall-install.obj : [.src]install.c $(config_h) \
	[.lib.selinux]selinux.h $(system_h) [.lib]backupfile.h \
	[.lib]error.h [.src]cp-hash.h \
	$(copy_h) [.lib]filenamecat.h [.lib]full-read.h [.lib]mkdir-p.h \
	[.lib]modechange.h [.src]prog-fprintf.h [.lib]quote.h \
	[.lib]quotearg.h [.lib]savewd.h [.lib]stat-time.h \
	[.lib]utimens.h $(xstrtol_h) [.vms]vms_pwd_hack.h
   $define/user glthread sys$disk:[.lib.glthread]
   $define/user selinux sys$disk:[.lib.selinux]
   $define/user decc$user_include sys$disk:[.src]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),"fork"="vfork") \
	/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.src]src_ginstall-prog-fprintf.obj : [.src]prog-fprintf.c $(config_h) \
	$(system_h) [.src]prog-fprintf.h

[.src]ginstall$(EXEEXT) : $(src_ginstall_OBJECTS) \
		$(src_ginstall_DEPENDENCIES) \
		$(EXTRA_src_ginstall_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]src_ginstall-install.obj, \
		[.src]src_ginstall-prog-fprintf.obj, \
		[.src]src_ginstall-copy.obj, \
		[.src]src_ginstall-cp-hash.obj, \
		[.src]force-link.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]groups.obj : [.src]groups.c $(config_h) $(system_h) \
	[.lib]error.h [.src]group-list.h [.vms]vms_pwd_hack.h


[.src]group-list.obj : [.src]group-list.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]mgetgroups.h [.lib]quote.h [.src]group-list.h \
	[.vms]vms_pwd_hack.h

[.src]groups$(EXEEXT) : $(src_groups_OBJECTS) $(src_groups_DEPENDENCIES) \
		$(EXTRA_src_groups_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]groups.obj, [.src]group-list.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]head.obj : [.src]head.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]full-read.h [.lib]quote.h [.lib]safe-read.h \
	$(xstrtol_h)

[.src]head$(EXEEXT) : $(src_head_OBJECTS) $(src_head_DEPENDENCIES) \
	$(EXTRA_src_head_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]head.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]hostid.obj : [.src]hostid.c $(config_h) $(system_h) \
	[.lib]long-options.h [.lib]error.h [.lib]quote.h \
	[.vms]vms_pwd_hack.h

[.src]hostid$(EXEEXT) : $(src_hostid_OBJECTS) $(src_hostid_DEPENDENCIES) \
		$(EXTRA_src_hostid_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]hostid.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]hostname.obj : [.src]hostname.c $(config_h) $(system_h) \
	[.lib]long-options.h [.lib]error.h [.lib]quote.h \
	[.lib]xgethostname.h

[.src]hostname$(EXEEXT) : $(src_hostname_OBJECTS) \
		$(src_hostname_DEPENDENCIES) \
		$(EXTRA_src_hostname_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]hostname.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]id.obj : [.src]id.c $(config_h) $(system_h) \
	[.lib.selinux]selinux.h [.lib]error.h \
	[.lib]mgetgroups.h [.lib]quote.h [.src]group-list.h

[.src]id$(EXEEXT) : $(src_id_OBJECTS) $(src_id_DEPENDENCIES) \
		$(EXTRA_src_id_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]id.obj, [.src]group-list.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]join.obj : [.src]join.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]fadvise.h [.lib]hard-locale.h \
	[.lib]linebuffer.h [.lib]memcasecmp.h [.lib]quote.h \
	$(stdio___h) [.lib]xmemcoll.h $(xstrtol_h) $(argmatch_h)

[.src]join$(EXEEXT) : $(src_join_OBJECTS) $(src_join_DEPENDENCIES) \
		$(EXTRA_src_join_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]join.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]kill.obj : [.src]kill.c $(config_h) $(system_h) \
	[.lib]error.h $(sig2str_h) [.src]operand2sig.h

[.src]operand2sig.obj : [.src]operand2sig.c $(config_h) $(system_h) \
	[.lib]error.h $(sig2str_h) [.src]operand2sig.h

[.src]kill$(EXEEXT) : $(src_kill_OBJECTS) $(src_kill_DEPENDENCIES) \
		$(EXTRA_src_kill_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]kill.obj, [.src]operand2sig.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

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
		$(crtl_init)

[.src]ln.obj : [.src]ln.c $(config_h) $(system_h) [.lib]backupfile.h \
	[.lib]error.h [.lib]filenamecat.h [.lib]same.h [.lib]yesno.h \
	[.lib]canonicalize.h

[.src]relpath.obj : [.src]relpath.c $(config_h) $(system_h) \
	[.src]relpath.h

[.src]ln$(EXEEXT) : $(src_ln_OBJECTS) $(src_ln_DEPENDENCIES) \
		$(EXTRA_src_ln_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]ln.obj, [.src]relpath.obj, [.src]force-link.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]logname.obj : [.src]logname.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]long-options.h [.lib]quote.h

[.src]logname$(EXEEXT) : $(src_logname_OBJECTS) \
		$(src_logname_DEPENDENCIES) \
		$(EXTRA_src_logname_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]logname.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]ls-ls.obj : [.src]ls-ls.c [.src]ls.c

[.src]ls$(EXEEXT) : $(src_ls_OBJECTS) $(src_ls_DEPENDENCIES) \
		$(EXTRA_src_ls_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]ls.obj, [.src]ls-ls.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]make-prime-list.obj : [.src]make-prime-list.c $(config_h)

[.src]make-prime-list$(EXEEXT) : $(src_make_prime_list_OBJECTS) \
		$(src_make_prime_list_DEPENDENCIES) \
		$(EXTRA_src_make_prime_list_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]make-prime-list.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]src_md5sum-digest.obj : [.src]digest.c $(config_h) $(system_h) \
	$(md5_h) $(sha1_h) $(sha256_h) $(sha512_h) [.lib]error.h \
	[.lib]fadvise.h $(stdio___h)
   $define/user glthread sys$disk:[.lib.glthread]
   $define/user selinux sys$disk:[.lib.selinux]
   $define/user decc$user_include sys$disk:[.src],sys$disk:[.lib.uniwidth]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),HASH_ALGO_MD5=1) \
	/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.src]md5sum$(EXEEXT) : $(src_md5sum_OBJECTS) $(src_md5sum_DEPENDENCIES) \
		$(EXTRA_src_md5sum_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]src_md5sum-digest.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

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
		$(crtl_init)

[.src]mkfifo.obj : [.src]mkfifo.c $(config_h) $(system_h) [.lib]error.h \
	[.lib.selinux]selinux.h [.lib]modechange.h [.lib]quote.h

[.src]mkfifo$(EXEEXT) : $(src_mkfifo_OBJECTS) $(src_mkfifo_DEPENDENCIES) \
		$(EXTRA_src_mkfifo_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]mkfifo.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]mknod.obj : [.src]mknod.c $(config_h) $(system_h) \
	[.lib.selinux]selinux.h [.lib]error.h [.lib]modechange.h \
	[.lib]quote.h $(xstrtol_h)

[.src]mknod$(EXEEXT) : $(src_mknod_OBJECTS) $(src_mknod_DEPENDENCIES) \
		$(EXTRA_src_mknod_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]mknod.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]mktemp.obj : [.src]mktemp.c $(config_h) $(system_h) \
	[.lib]close-stream.h [.lib]error.h [.lib]filenamecat.h \
	[.lib]quote.h $(stdio___h) [.lib]tempname.h

[.src]mktemp$(EXEEXT) : $(src_mktemp_OBJECTS) $(src_mktemp_DEPENDENCIES) \
		$(EXTRA_src_mktemp_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]mktemp.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

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
		[.src]cp-hash.obj, [.src]copy.obj, [.src]force-link.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]nice.obj : [.src]nice.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]quote.h $(xstrtol_h)

[.src]nice$(EXEEXT) : $(src_nice_OBJECTS) $(src_nice_DEPENDENCIES) \
		$(EXTRA_src_nice_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]nice.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]nl.obj : [.src]nl.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fadvise.h [.lib]linebuffer.h [.lib]quote.h \
	$(xstrtol_h)

[.src]nl$(EXEEXT) : $(src_nl_OBJECTS) $(src_nl_DEPENDENCIES) \
		$(EXTRA_src_nl_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]nl.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]nohup.obj : [.src]nohup.c $(config_h) $(system_h) \
	[.lib]cloexec.h [.lib]error.h [.lib]filenamecat.h \
	[.lib]fd-reopen.h [.lib]long-options.h [.lib]quote.h \
	$(unistd___h)

[.src]nohup$(EXEEXT) : $(src_nohup_OBJECTS) $(src_nohup_DEPENDENCIES) \
		$(EXTRA_src_nohup_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]nohup.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]nproc.obj : [.src]nproc.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]nproc.h [.lib]quote.h $(xstrtol_h)

[.src]nproc$(EXEEXT) : $(src_nproc_OBJECTS) $(src_nproc_DEPENDENCIES) \
		$(EXTRA_src_nproc_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]nproc.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]numfmt.obj : [.src]numfmt.c $(config_h) [.lib]mbsalign.h \
	$(argmatch_h) [.lib]error.h [.lib]quote.h $(system_h) \
	$(xstrtol_h)

[.src]numfmt$(EXEEXT) : $(src_numfmt_OBJECTS) $(src_numfmt_DEPENDENCIES) \
		$(EXTRA_src_numfmt_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]numfmt.obj, [.src]set-fields.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]od.obj : [.src]od.c $(config_h) $(system_h) [.lib]error.h \
	$(ftoastr_h) [.lib]quote.h [.lib]xprintf.h \
	$(xstrtol_h)

[.src]od$(EXEEXT) : $(src_od_OBJECTS) $(src_od_DEPENDENCIES) \
		$(EXTRA_src_od_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]od.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]paste.obj : [.src]paste.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fadvise.h [.lib]quotearg.h

[.src]paste$(EXEEXT) : $(src_paste_OBJECTS) $(src_paste_DEPENDENCIES) \
		$(EXTRA_src_paste_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]paste.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]pathchk.obj : [.src]pathchk.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]quote.h [.lib]quotearg.h

[.src]pathchk$(EXEEXT) : $(src_pathchk_OBJECTS) $(src_pathchk_DEPENDENCIES) \
		$(EXTRA_src_pathchk_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]pathchk.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]pinky.obj : [.src]pinky.c $(config_h) $(system_h) \
	[.lib]canon-host.h [.lib]error.h [.lib]hard-locale.h \
	$(readutmp_h) [.vms]vms_pwd_hack.h

[.src]pinky$(EXEEXT) : $(src_pinky_OBJECTS) $(src_pinky_DEPENDENCIES) \
		$(EXTRA_src_pinky_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET)/notraceback [.src]pinky.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]pr.obj : [.src]pr.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fadvise.h [.lib]hard-locale.h [.lib]mbswidth.h \
	[.lib]quote.h [.lib]stat-time.h $(stdio___h) [.lib]strftime.h \
	$(xstrtol_h)

[.src]pr$(EXEEXT) : $(src_pr_OBJECTS) $(src_pr_DEPENDENCIES) \
		$(EXTRA_src_pr_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]pr.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]printenv.obj : [.src]printenv.c $(config_h) $(system_h)

[.src]printenv$(EXEEXT) : $(src_printenv_OBJECTS) \
		$(src_printenv_DEPENDENCIES) \
		$(EXTRA_src_printenv_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]printenv.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]printf.obj : [.src]printf.c $(config_h) $(system-h) \
	[.lib]c-strtod.h [.lib]error.h [.lib]quote.h \
	[.lib]unicodeio.h [.lib]xprintf.h

[.src]printf$(EXEEXT) : $(src_printf_OBJECTS) $(src_printf_DEPENDENCIES) \
		$(EXTRA_src_printf_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]printf.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]ptx.obj : [.src]ptx.c $(config_h) $(system_h) $(argmatch_h) \
	[.lib]error.h [.lib]fadvise.h \
	[.lib]quote.h [.lib]quotearg.h [.lib]read-file.h \
	$(stdio___h) $(xstrtol_h)

[.src]ptx$(EXEEXT) : $(src_ptx_OBJECTS) $(src_ptx_DEPENDENCIES) \
		$(EXTRA_src_ptx_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]ptx.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]pwd.obj : [.src]pwd.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]quote.h $(root_dev_ino_h) [.lib]xgetcwd.h [.vms]vms_pwd_hack.h

[.src]pwd$(EXEEXT) : $(src_pwd_OBJECTS) $(src_pwd_DEPENDENCIES) \
		$(EXTRA_src_pwd_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]pwd.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]readlink.obj : [.src]readlink.c $(config_h) $(system_h) \
	[.lib]canonicalize.h [.lib]error.h [.lib]areadlink.h

[.src]readlink$(EXEEXT) : $(src_readlink_OBJECTS) \
		$(src_readlink_DEPENDENCIES) \
		$(EXTRA_src_readlink_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]readlink.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]realpath.obj : [.src]realpath.c $(config_h) $(system_h) \
	[.lib]canonicalize.h [.lib]error.h [.lib]quote.h \
	[.src]relpath.h

[.src]realpath$(EXEEXT) : $(src_realpath_OBJECTS) \
		$(src_realpath_DEPENDENCIES) \
		$(EXTRA_src_realpath_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]realpath.obj, relpath.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]rm.obj : [.src]rm.c $(config_h) $(system_h) $(argmatch_h) \
	[.lib]error.h [.lib]quote.h [.lib]quotearg.h \
	$(remove_h) $(root_dev_ino_h) [.lib]yesno.h [.lib]priv-set.h

[.src]rm$(EXEEXT) : $(src_rm_OBJECTS) $(src_rm_DEPENDENCIES) \
		$(EXTRA_src_rm_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]rm.obj, [.src]remove.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]rmdir.obj : [.src]rmdir.c $(config_h) $(system_h) [.lib]error.h \
	[.src]prog-fprintf.h [.lib]quote.h

[.src]rmdir$(EXEEXT) : $(src_rmdir_OBJECTS) $(src_rmdir_DEPENDENCIES) \
		$(EXTRA_src_rmdir_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]rmdir.obj, [.src]prog-fprintf.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]runcon.obj : [.src]runcon.c $(config_h) [.lib.selinux]selinux.h \
	[.lib.selinux]context.h $(system_h) [.lib]error.h \
	[.lib]quote.h [.lib]quotearg.h

[.src]runcon$(EXEEXT) : $(src_runcon_OBJECTS) $(src_runcon_DEPENDENCIES) \
		$(EXTRA_src_runcon_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]runcon.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]seq.obj : [.src]seq.c $(config_h) $(system_h) [.lib]c-strtod.h \
	[.lib]error.h [.lib]quote.h [.lib]xstrtod.h

[.src]seq$(EXEEXT) : $(src_seq_OBJECTS) $(src_seq_DEPENDENCIES) \
		$(EXTRA_src_seq_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]seq.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]setuidgid.obj : [.src]setuidgid.c $(config_h) $(system_h) \
	[.lib]long-options.h [.lib]mgetgroups.h [.lib]quote.h \
	$(xstrtol_h) [.vms]vms_pwd_hack.h

[.src]setuidgid$(EXEEXT) : $(src_setuidgid_OBJECTS) \
		$(src_setuidgid_DEPENDENCIES) \
		$(EXTRA_src_setuidgid_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]setuidgid.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]src_sha1sum-digest.obj : [.src]digest.c $(config_h) $(system_h) \
	$(md5_h) $(sha1_h) $(sha256_h) $(sha512_h) [.lib]error.h \
	[.lib]fadvise.h $(stdio___h)
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
	link/exe=$(MMS$TARGET) [.src]src_sha1sum-digest.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]src_sha224sum-digest.obj : [.src]digest.c $(config_h) $(system_h) \
	$(md5_h) $(sha1_h) $(sha256_h) $(sha512_h) [.lib]error.h \
	[.lib]fadvise.h $(stdio___h)
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
	link/exe=$(MMS$TARGET) [.src]src_sha224sum-digest.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]src_sha256sum-digest.obj : [.src]md5sum.c $(config_h) $(system_h) \
	$(md5_h) $(sha1_h) $(sha256_h) $(sha512_h) [.lib]error.h \
	[.lib]fadvise.h $(stdio___h)
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
	link/exe=$(MMS$TARGET) [.src]src_sha256sum-digest.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]src_sha384sum-digest.obj : [.src]md5sum.c $(config_h) $(system_h) \
	$(md5_h) $(sha1_h) $(sha256_h) $(sha512_h) [.lib]error.h \
	[.lib]fadvise.h $(stdio___h)
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
	link/exe=$(MMS$TARGET) [.src]src_sha384sum-digest.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]src_sha512sum-digest.obj : [.src]md5sum.c $(config_h) $(system_h) \
	$(md5_h) $(sha1_h) $(sha256_h) $(sha512_h) [.lib]error.h \
	[.lib]fadvise.h $(stdio___h)
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
	link/exe=$(MMS$TARGET) [.src]src_sha512sum-digest.obj , \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]shred.obj : [.src]shred.c $(config_h) $(system_h) $(xstrtol_h) \
	[.lib]error.h $(fcntl__h) $(human_h) [.lib]quotearg.h \
	[.lib]randint.h [.lib]randread.h [.lib]stat-size.h

[.src]shred$(EXEEXT) : $(src_shred_OBJECTS) $(src_shred_DEPENDENCIES) \
		$(EXTRA_src_shred_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]shred.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]shuf.obj : [.src]shuf.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]fadvise.h [.lib]getopt.h [.lib]quote.h \
	[.lib]quotearg.h [.lib]randint.h $(randperm_h) \
	[.lib]read-file.h $(stdio___h) $(xstrtol_h) [.lib]getopt-cdefs.h

[.src]shuf$(EXEEXT) : $(src_shuf_OBJECTS) $(src_shuf_DEPENDENCIES) \
		$(EXTRA_src_shuf_DEPENDENCIES)
	link/exe=$(MMS$TARGET) [.src]shuf.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]sleep.obj : [.src]sleep.c $(config_h) $(system_h) \
	[.lib]c-strtod.h [.lib]error.h [.lib]long-options.h \
	[.lib]quote.h [.lib]xnanosleep.h [.lib]xstrtod.h

[.src]sleep$(EXEEXT) : $(src_sleep_OBJECTS) $(src_sleep_DEPENDENCIES) \
		$(EXTRA_src_sleep_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]sleep.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

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
		$(crtl_init)

lcl_root:[.src]split.c : src_root:[.src]split.c [.vms]src_split_c.tpu
                    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
                    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.src]split.obj : lcl_root:[.src]split.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fd-reopen.h $(fcntl___h) [.lib]full-read.h \
	[.lib]full-write.h $(ioblksize_h) [.lib]quote.h \
	[.lib]safe-read.h $(sig2str_h) \
	$(xstrtol_h)

[.src]vms_vm_pipe.obj : [.vms]vms_vm_pipe.c

[.src]split$(EXEEXT) : $(src_split_OBJECTS) $(src_split_DEPENDENCIES) \
		$(EXTRA_src_split_DEPENDENCIES) [.src]vms_vm_pipe.obj
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]split.obj, \
		sys$disk:[.src]vms_vm_pipe.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]stat.obj : [.src]stat.c $(config_h) [.lib.selinux]selinux.h \
	$(system_h) [.lib]areadlink.h [.lib]error.h \
	[.lib]file-type.h [.lib]filemode.h [.src]fs.h [.lib]getopt.h \
	[.lib]mountlist.h [.lib]quote.h [.lib]quotearg.h \
	[.lib]stat-size.h [.lib]stat-time.h [.src]find-mount-point.h \
	[.lib]xvasprintf.h [.lib]stdalign.h [.lib]alloca.h \
	[.vms]vms_pwd_hack.h [.lib]getopt-cdefs.h

[.src]stat$(EXEEXT) : $(src_stat_OBJECTS) $(src_stat_DEPENDENCIES) \
		$(EXTRA_src_stat_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]stat.obj, [.src]find-mount-point.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# quota.h
[.src]stdbuf.obj : [.src]stdbuf.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]filenamecat.h [.lib]xreadlink.h \
	$(xstrtol_h) [.lib]c-ctype.h

[.src]stdbuf$(EXEEXT) : $(src_stdbuf_OBJECTS) $(src_stdbuf_DEPENDENCIES) \
		$(EXTRA_src_stdbuf_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]stdbuf.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]stty.obj : [.src]stty.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fd-reopen.h [.lib]quote.h $(xstrtol_h) $(termios_h) \
	sys$disk:[.vms]vms_ioctl_hack.h [.vms]vms_ttyname_hack.h

[.src]stty$(EXEEXT) : $(src_stty_OBJECTS) $(src_stty_DEPENDENCIES) \
		$(EXTRA_src_stty_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]stty.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]src_sum-digest.obj : [.src]digest.c $(config_h) $(system_h) \
	$(md5_h) $(sha1_h) $(sha256_h) $(sha512_h) [.lib]error.h \
	[.lib]fadvise.h $(stdio___h)
   $define/user glthread sys$disk:[.lib.glthread]
   $define/user selinux sys$disk:[.lib.selinux]
   $define/user blake2 sys$disk:[.src.blake2]
   $define/user decc$user_include sys$disk:[.src],sys$disk:[.lib.uniwidth]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),HASH_ALGO_SUM=1) \
	/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.src]sum.obj : [.src]sum.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fadvise.h $(human_h) [.lib]safe-read.h

[.src]sum$(EXEEXT) : $(src_sum_OBJECTS) $(src_sum_DEPENDENCIES) \
		$(EXTRA_src_sum_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]sum.obj, [.src]src_sum-digest.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]sync.obj : [.src]sync.c $(config_h) $(system_h) [.lib]long-options.h

[.src]sync$(EXEEXT) : $(src_sync_OBJECTS) $(src_sync_DEPENDENCIES) \
		$(EXTRA_src_sync_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]sync.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]tac.obj : [.src]tac.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]filenamecat.h [.lib]quote.h [.lib]quotearg.h \
	[.lib]safe-read.h $(stdlib___h)

[.src]tac$(EXEEXT) : $(src_tac_OBJECTS) $(src_tac_DEPENDENCIES) \
		$(EXTRA_src_tac_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]tac.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]tail.obj : [.src]tail.c $(config_h) $(system_h) $(argmatch_h) \
	[.lib]c-strtod.h $(fcntl___h) [.lib]isapipe.h \
	[.lib]posixver.h [.lib]quote.h [.lib]safe-read.h [.lib]stat-time.h \
	[.lib]xnanosleep.h $(xstrtol_h) [.lib]xstrtod.h \
	[.lib]hash.h [.src]fs.h [.src]fs-is-local.h

[.src]tail$(EXEEXT) : $(src_tail_OBJECTS) $(src_tail_DEPENDENCIES) \
		$(EXTRA_src_tail_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]tail.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]tee.obj : [.src]tee.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fadvise.h $(stdio___h)

[.src]tee$(EXEEXT) : $(src_tee_OBJECTS) $(src_tee_DEPENDENCIES) \
		$(EXTRA_src_tee_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]tee.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)


[.src]test.obj : [.src]test.c $(config_h) $(system_h) [.lib]quote.h \
	[.lib]stat-time.h [.lib]strnumcmp.h

[.src]test$(EXEEXT) : $(src_test_OBJECTS) $(src_test_DEPENDENCIES) \
		$(EXTRA_src_test_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]test.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]lbracket.obj : [.src]lbracket.c [.src]test.c \
	$(config_h) $(system_h) [.lib]quote.h \
	[.lib]stat-time.h [.lib]strnumcmp.h

[.src]lbracket$(EXEEXT) : $(src___OBJECTS) $(src_test_DEPENDENCIES) \
		$(EXTRA_src___DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]lbracket.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)
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
		$(crtl_init)

[.src]touch.obj : [.src]touch.c $(config_h) $(system_h) $(argmatch_h) \
	[.lib]error.h [.lib]fd-reopen.h [.lib]parse-datetime.h \
	[.lib]posixtm.h [.lib]posixver.h [.lib]quote.h \
	[.lib]stat-time.h [.lib]utimens.h

[.src]touch$(EXEEXT) : $(src_touch_OBJECTS) $(src_touch_DEPENDENCIES) \
		$(EXTRA_src_touch_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]touch.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]tr.obj : [.src]tr.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]fadvise.h [.lib]quote.h [.lib]safe-read.h \
	$(xstrtol_h)

[.src]tr$(EXEEXT) : $(src_tr_OBJECTS) $(src_tr_DEPENDENCIES) \
		$(EXTRA_src_tr_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]tr.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]true.obj : [.src]true.c $(config_h) $(system_h)

[.src]true$(EXEEXT) : $(src_true_OBJECTS) $(src_true_DEPENDENCIES) \
		$(EXTRA_src_true_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]true.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]truncate.obj : [.src]truncate.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]quote.h [.lib]stat-size.h $(xstrtol_h)

[.src]truncate$(EXEEXT) : $(src_truncate_OBJECTS) \
		$(src_truncate_DEPENDENCIES) \
		$(EXTRA_src_truncate_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]truncate.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]tsort.obj : [.src]tsort.c $(config_h) $(system_h) \
	[.lib]long-options.h [.lib]error.h [.lib]fadvise.h \
	[.lib]quote.h [.lib]readtokens.h $(stdio___h)

[.src]tsort$(EXEEXT) : $(src_tsort_OBJECTS) $(src_tsort_DEPENDENCIES) \
		$(EXTRA_src_tsort_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]tsort.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]tty.obj : [.src]tty.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]quote.h

[.src]tty$(EXEEXT) : $(src_tty_OBJECTS) $(src_tty_DEPENDENCIES) \
		$(EXTRA_src_tty_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]tty.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]uname-uname.obj : [.src]uname-uname.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]quote.h [.src]uname.h

[.src]uname$(EXEEXT) : $(src_uname_OBJECTS) $(src_uname_DEPENDENCIES) \
		$(EXTRA_src_uname_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]uname.obj, [.src]uname-uname.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]unexpand.obj : [.src]unexpand.c [.src]expand-common.h \
        $(config_h) $(system_h) \
	[.lib]error.h [.lib]fadvise.h [.lib]quote.h

[.src]unexpand$(EXEEXT) : $(src_unexpand_OBJECTS) \
		$(src_unexpand_DEPENDENCIES) \
		$(EXTRA_src_unexpand_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]unexpand.obj, [.src]expand-common.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]uniq.obj : [.src]uniq.c $(config_h) $(system_h) $(argmatch_h) \
	[.lib]linebuffer.h [.lib]error.h [.lib]fadvise.h \
	[.lib]hard-locale.h [.lib]posixver.h [.lib]quote.h \
	$(stdio___h) [.lib]xmemcoll.h $(xstrtol_h) [.lib]memcasecmp.h

[.src]uniq$(EXEEXT) : $(src_uniq_OBJECTS) $(src_uniq_DEPENDENCIES) \
		$(EXTRA_src_uniq_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]uniq.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]unlink.obj : [.src]unlink.c $(config_h) $(system_h) \
	[.lib]error.h [.lib]long-options.h [.lib]quote.h

[.src]unlink$(EXEEXT) : $(src_unlink_OBJECTS) $(src_unlink_DEPENDENCIES) \
		$(EXTRA_src_unlink_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]unlink.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]uptime.obj : [.src]uptime.c $(config_h) $(system_h) [.lib]c-strtod.h \
	[.lib]error.h [.lib]long-options.h [.lib]quote.h $(readutmp_h) \
	[.lib]fprintftime.h

[.src]uptime$(EXEEXT) : $(src_uptime_OBJECTS) $(src_uptime_DEPENDENCIES) \
		$(EXTRA_src_uptime_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]uptime.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]users.obj : [.src]users.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]long-options.h [.lib]quote.h $(readutmp_h)

[.src]users$(EXEEXT) : $(src_users_OBJECTS) $(src_users_DEPENDENCIES) \
		$(EXTRA_src_users_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET)/notraceback [.src]users.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]ls-vdir.obj : [.src]ls-vdir.c [.src]ls.h

[.src]vdir$(EXEEXT) : $(src_vdir_OBJECTS) $(src_vdir_DEPENDENCIES) \
		$(EXTRA_src_vdir_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]ls.obj, [.src]ls-vdir.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]wc.obj : [.src]wc.c $(config_h) $(system_h) $(argv_iter_h) \
	[.lib]error.h [.lib]fadvise.h [.lib]mbchar.h [.lib]physmem.h \
	[.lib]quote.h [.lib]quotearg.h $(readtokens0_h) \
	[.lib]safe-read.h

[.src]wc$(EXEEXT) : $(src_wc_OBJECTS) $(src_wc_DEPENDENCIES) \
		$(EXTRA_src_wc_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]wc.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]who.obj : [.src]who.c $(config_h) $(system_h) [.lib]c-ctype.h \
	[.lib]canon-host.h $(readutmp_h) [.lib]error.h \
	[.lib]hard-locale.h [.lib]quote.h

[.src]who$(EXEEXT) : $(src_who_OBJECTS) $(src_who_DEPENDENCIES) \
		$(EXTRA_src_who_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET)/notraceback [.src]who.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]whoami.obj : [.src]whoami.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]long-options.h [.lib]quote.h [.vms]vms_pwd_hack.h


[.src]whoami$(EXEEXT) : $(src_whoami_OBJECTS) $(src_whoami_DEPENDENCIES) \
		$(EXTRA_src_whoami_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]whoami.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.src]yes.obj : [.src]yes.c $(config_h) $(system_h) [.lib]error.h \
	[.lib]long-options.h

[.src]yes$(EXEEXT) : $(src_yes_OBJECTS) $(src_yes_DEPENDENCIES) \
		$(EXTRA_src_yes_DEPENDENCIES)
	write sys$output "$(MMS$TARGET) target"
	link/exe=$(MMS$TARGET) [.src]yes.obj, \
		[.src]version.obj, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

##
## TEST section
## libtests.olb
##

gnulib_libtests_a_OBJECTS = \
		"ioctl"=[.gnulib-tests]ioctl.obj,\
		"localename"=[.gnulib-tests]localename.obj,\
		"localename-table"=[.gnulib-tests]localename-table.obj,\
		"thread"=[.gnulib-tests.glthread]thread.obj,\
		"timespec-add"=[.gnulib-tests]timespec-add.obj,\
		"timespec-sub"=[.gnulib-tests]timespec-sub.obj,\
		"tmpdir"=[.gnulib-tests]tmpdir.obj,\
		"vma-iter"=[.gnulib-tests]vma-iter.obj

[.gnulib-tests]ioctl.obj : [.gnulib-tests]ioctl.c

[.gnulib-tests]localename.obj : [.gnulib-tests]localename.c
   $define/user glthread sys$disk:[.lib.glthread]
   $define/user sys sys$disk:[.lib.sys]
   $define/user malloc sys$disk:[.lib.malloc]
   $define/user unictype sys$disk:[.lib.unictype]
   $define/user uniwidth sys$disk:[.lib.uniwidth]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),LOCALENAME_ENHANCE_LOCALE_FUNCS=0)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]localename-table.obj : [.gnulib-tests]localename-table.c

[.gnulib-tests.glthread]thread.obj : [.gnulib-tests.glthread]thread.c \
	[.gnulib-tests.glthread]thread.h [.gnulib-tests.glthread]yield.h
   $define/user glthread sys$disk:[.lib.glthread],sys$disk:[.gnulib-tests.glthread]
   $define/user sys sys$disk:[.lib.sys]
   $define/user malloc sys$disk:[.lib.malloc]
   $define/user unictype sys$disk:[.lib.unictype]
   $define/user uniwidth sys$disk:[.lib.uniwidth]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]timespec-add.obj : [.gnulib-tests]timespec-add.c

[.gnulib-tests]timespec-sub.obj : [.gnulib-tests]timespec-sub.c

[.gnulib-tests]tmpdir.obj : [.gnulib-tests]tmpdir.c [.gnulib-tests]tmpdir.h

[.gnulib-tests]vma-iter.obj : [.gnulib-tests]vma-iter.c

[.gnulib-tests]libtests.olb : [.gnulib-tests]libtests($(gnulib_libtests_a_OBJECTS))
    @ write sys$output "libtests is up to date"

##
## gnulib-tests target and individual tests
##

# TODO: fix unsetenv compile failure (void return value).
gnulib-tests : [.gnulib-tests]test-accept. [.gnulib-tests]test-alignalloc. \
	[.gnulib-tests]test-alignof. [.gnulib-tests]test-alloca-opt. \
	[.gnulib-tests]test-areadlink. [.gnulib-tests]test-areadlink-with-size. \
	[.gnulib-tests]test-areadlinkat. [.gnulib-tests]test-areadlinkat-with-size. \
	[.gnulib-tests]test-argmatch. [.gnulib-tests]test-argv-iter. \
	[.gnulib-tests]test-arpa_inet. [.gnulib-tests]test-base32. \
	[.gnulib-tests]test-base64. [.gnulib-tests]test-bind. \
	[.gnulib-tests]test-bitrotate. [.gnulib-tests]test-byteswap. \
	[.gnulib-tests]test-c-ctype. [.gnulib-tests]test-calloc-gnu. \
	[.gnulib-tests]test-canonicalize. [.gnulib-tests]test-chdir. \
	[.gnulib-tests]test-chown. [.gnulib-tests]test-cloexec. \
	[.gnulib-tests]test-close. [.gnulib-tests]test-connect. \
	[.gnulib-tests]test-count-leading-zeros. [.gnulib-tests]test-md5-buffer. \
	[.gnulib-tests]test-md5-stream. [.gnulib-tests]test-sha1-buffer. \
	[.gnulib-tests]test-sha1-stream. [.gnulib-tests]test-sha256-stream. \
	[.gnulib-tests]test-sha512-stream. [.gnulib-tests]test-sm3-buffer. \
	[.gnulib-tests]test-ctype. [.gnulib-tests]test-di-set. \
	[.gnulib-tests]test-dirent-safer. [.gnulib-tests]test-dirent. \
	[.gnulib-tests]test-dirname. [.gnulib-tests]test-dup. \
	[.gnulib-tests]test-dup2. [.gnulib-tests]test-dynarray. \
	[.gnulib-tests]test-environ. \
	[.gnulib-tests]test-explicit_bzero. [.gnulib-tests]test-faccessat. \
	[.gnulib-tests]test-fadvise. [.gnulib-tests]test-fchdir. \
	[.gnulib-tests]test-fchmodat. [.gnulib-tests]test-fchownat. \
	[.gnulib-tests]test-fclose. \
	[.gnulib-tests]test-fcntl-safer. [.gnulib-tests]test-fcntl. \
	[.gnulib-tests]test-fdopen. \
	[.gnulib-tests]test-fdopendir. [.gnulib-tests]test-fdutimensat. \
	[.gnulib-tests]test-fflush. [.gnulib-tests]test-fgetc. \
	[.gnulib-tests]test-filenamecat. [.gnulib-tests]test-filevercmp. \
	[.gnulib-tests]test-float. [.gnulib-tests]test-fnmatch-h. \
	[.gnulib-tests]test-fopen-gnu. [.gnulib-tests]test-fopen-safer. \
	[.gnulib-tests]test-fopen. [.gnulib-tests]test-fpurge. \
	[.gnulib-tests]test-fputc. [.gnulib-tests]test-fread. \
	[.gnulib-tests]test-freading. [.gnulib-tests]test-free. \
	[.gnulib-tests]test-freopen-safer. [.gnulib-tests]test-freopen. \
	[.gnulib-tests]test-fseterr. [.gnulib-tests]test-fstat. \
	[.gnulib-tests]test-fstatat. [.gnulib-tests]test-fsync. \
	[.gnulib-tests]test-ftell3. [.gnulib-tests]test-ftello3. \
	[.gnulib-tests]test-futimens. [.gnulib-tests]test-fwrite. \
	[.gnulib-tests]test-getaddrinfo. [.gnulib-tests]test-getcwd-lgpl. \
	[.gnulib-tests]test-getdelim. [.gnulib-tests]test-getdtablesize. \
	[.gnulib-tests]test-getgroups. [.gnulib-tests]test-gethostname. \
	[.gnulib-tests]test-getline. [.gnulib-tests]test-getloadavg. \
	[.gnulib-tests]test-getlogin. [.gnulib-tests]test-getndelim2. \
	[.gnulib-tests]test-getopt-gnu. [.gnulib-tests]test-getopt-posix. \
	[.gnulib-tests]test-getprogname. [.gnulib-tests]test-getrandom. \
	[.gnulib-tests]test-getrusage. [.gnulib-tests]test-gettimeofday. \
	[.gnulib-tests]test-hard-locale. [.gnulib-tests]test-hash. \
	[.gnulib-tests]test-i-ring. [.gnulib-tests]test-iconv-h. \
	[.gnulib-tests]test-iconv. [.gnulib-tests]test-ignore-value. \
	[.gnulib-tests]test-inet_ntop. [.gnulib-tests]test-inet_pton. \
	[.gnulib-tests]test-ino-map. [.gnulib-tests]test-intprops. \
	[.gnulib-tests]test-inttostr. [.gnulib-tests]test-inttypes. \
	[.gnulib-tests]test-isatty. \
	[.gnulib-tests]test-isblank. [.gnulib-tests]test-isnand-nolibm. \
	[.gnulib-tests]test-isnanf-nolibm. [.gnulib-tests]test-isnanl-nolibm. \
	[.gnulib-tests]test-iswblank. [.gnulib-tests]test-langinfo. \
	[.gnulib-tests]test-lchmod. [.gnulib-tests]test-lchown. \
	[.gnulib-tests]test-limits-h. \
	[.gnulib-tests]test-link. [.gnulib-tests]test-linkat. \
	[.gnulib-tests]test-listen. \
	[.gnulib-tests]test-localename. \
	[.gnulib-tests]test-rwlock1. [.gnulib-tests]test-lock. \
	[.gnulib-tests]test-once1. [.gnulib-tests]test-once2. \
	[.gnulib-tests]test-lstat. [.gnulib-tests]test-malloc-gnu. \
	[.gnulib-tests]test-malloca. [.gnulib-tests]test-math. \
	[.gnulib-tests]test-mbsalign. [.gnulib-tests]test-mbsstr1. \
	[.gnulib-tests]test-memcasecmp. [.gnulib-tests]test-memchr. \
	[.gnulib-tests]test-memchr2. [.gnulib-tests]test-memcoll. \
	[.gnulib-tests]test-memrchr. [.gnulib-tests]test-mkdir. \
	[.gnulib-tests]test-mkdirat. [.gnulib-tests]test-mkfifo. \
	[.gnulib-tests]test-mkfifoat. [.gnulib-tests]test-mknod. \
	[.gnulib-tests]test-nanosleep. [.gnulib-tests]test-netdb. \
	[.gnulib-tests]test-netinet_in. \
	[.gnulib-tests]test-nstrftime. [.gnulib-tests]test-open. \
	[.gnulib-tests]test-openat-safer. [.gnulib-tests]test-openat. \
	[.gnulib-tests]test-parse-datetime. [.gnulib-tests]test-pathmax. \
	[.gnulib-tests]test-perror2. [.gnulib-tests]test-pipe. \
	[.gnulib-tests]test-posix_memalign. \
	[.gnulib-tests]test-posixtm. [.gnulib-tests]test-printf-frexp. \
	[.gnulib-tests]test-printf-frexpl. [.gnulib-tests]test-priv-set. \
	[.gnulib-tests]test-pthread-cond. \
	[.gnulib-tests]test-pthread-mutex. \
	[.gnulib-tests]test-pthread-thread. [.gnulib-tests]test-pthread_sigmask1. \
	[.gnulib-tests]test-quotearg-simple. \
	[.gnulib-tests]test-raise. [.gnulib-tests]test-rand-isaac. \
	[.gnulib-tests]test-read. [.gnulib-tests]test-readlink. \
	[.gnulib-tests]test-realloc-gnu. [.gnulib-tests]test-reallocarray. \
	[.gnulib-tests]test-regex. [.gnulib-tests]test-remove. \
	[.gnulib-tests]test-rename. [.gnulib-tests]test-renameat. \
	[.gnulib-tests]test-renameatu. [.gnulib-tests]test-rmdir. \
	[.gnulib-tests]test-sched. [.gnulib-tests]test-scratch-buffer. \
	[.gnulib-tests]test-setenv. \
	[.gnulib-tests]test-setlocale_null. [.gnulib-tests]test-setlocale_null-mt-one. \
	[.gnulib-tests]test-setlocale_null-mt-all. [.gnulib-tests]test-setsockopt. \
	[.gnulib-tests]test-sigaction. [.gnulib-tests]test-signal-h. \
	[.gnulib-tests]test-sigprocmask. \
	[.gnulib-tests]test-sleep. [.gnulib-tests]test-snprintf. \
	[.gnulib-tests]test-sockets. [.gnulib-tests]test-stat. \
	[.gnulib-tests]test-stat-time. [.gnulib-tests]test-stdalign. \
	[.gnulib-tests]test-stdbool. [.gnulib-tests]test-stddef. \
	[.gnulib-tests]test-stdio. \
	[.gnulib-tests]test-stdlib. [.gnulib-tests]test-strerror. \
	[.gnulib-tests]test-strerror_r. [.gnulib-tests]test-striconv. \
	[.gnulib-tests]test-string. [.gnulib-tests]test-strncat. \
	[.gnulib-tests]test-strnlen. [.gnulib-tests]test-strsignal. \
	[.gnulib-tests]test-strtod. [.gnulib-tests]test-strtoimax. \
	[.gnulib-tests]test-strtold. [.gnulib-tests]test-strtoll. \
	[.gnulib-tests]test-strtoull. [.gnulib-tests]test-strtoumax. \
	[.gnulib-tests]test-symlink. [.gnulib-tests]test-symlinkat. \
	[.gnulib-tests]test-sys_ioctl. [.gnulib-tests]test-sys_random. \
	[.gnulib-tests]test-sys_resource. \
	[.gnulib-tests]test-sys_socket. [.gnulib-tests]test-sys_stat. \
	[.gnulib-tests]test-sys_time. [.gnulib-tests]test-sys_types. \
	[.gnulib-tests]test-sys_uio. [.gnulib-tests]test-sys_utsname. \
	[.gnulib-tests]test-sys_wait. [.gnulib-tests]test-termios. \
	[.gnulib-tests]test-thread_self. [.gnulib-tests]test-thread_create. \
	[.gnulib-tests]test-timespec. \
	[.gnulib-tests]test-tls. [.gnulib-tests]test-u64. \
	[.gnulib-tests]test-uname. [.gnulib-tests]test-dup-safer. \
	[.gnulib-tests]test-unistd. [.gnulib-tests.unistr]test-u8-mbtoucr. \
	[.gnulib-tests.unistr]test-u8-uctomb. [.gnulib-tests.uniwidth]test-uc_width. \
	[.gnulib-tests.uniwidth]test-uc_width2. \
	[.gnulib-tests]test-unlink. [.gnulib-tests]test-unlinkat. \
	[.gnulib-tests]test-userspec. \
	[.gnulib-tests]test-usleep. [.gnulib-tests]test-utime-h. \
	[.gnulib-tests]test-utime. [.gnulib-tests]test-utimens. \
	[.gnulib-tests]test-utimensat. [.gnulib-tests]test-vasnprintf. \
	[.gnulib-tests]test-vasprintf-posix. [.gnulib-tests]test-vasprintf. \
	[.gnulib-tests]test-verify. [.gnulib-tests]test-wchar. \
	[.gnulib-tests]test-wctype-h. [.gnulib-tests]test-wcwidth. \
	[.gnulib-tests]test-write. [.gnulib-tests]test-xvasprintf. \
	[.gnulib-tests]test-yesno.
    @ write sys$output "gnulib-tests is up to date"

[.gnulib-tests]test-accept.obj : [.gnulib-tests]test-accept.c

[.gnulib-tests]test-accept. : [.gnulib-tests]test-accept.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-accept.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-alignalloc.obj : [.gnulib-tests]test-alignalloc.c

[.gnulib-tests]test-alignalloc. : [.gnulib-tests]test-alignalloc.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-alignalloc.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-alignof.obj : [.gnulib-tests]test-alignof.c

[.gnulib-tests]test-alignof. : [.gnulib-tests]test-alignof.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-alignof.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-alloca-opt.obj : [.gnulib-tests]test-alloca-opt.c

[.gnulib-tests]test-alloca-opt. : [.gnulib-tests]test-alloca-opt.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-alloca-opt.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-areadlink.obj : [.gnulib-tests]test-areadlink.c

[.gnulib-tests]test-areadlink. : [.gnulib-tests]test-areadlink.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-areadlink.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-areadlink-with-size.obj : [.gnulib-tests]test-areadlink-with-size.c

[.gnulib-tests]test-areadlink-with-size. : [.gnulib-tests]test-areadlink-with-size.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-areadlink-with-size.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-areadlinkat.obj : [.gnulib-tests]test-areadlinkat.c

[.gnulib-tests]test-areadlinkat. : [.gnulib-tests]test-areadlinkat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-areadlinkat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-areadlinkat-with-size.obj : [.gnulib-tests]test-areadlinkat-with-size.c

[.gnulib-tests]test-areadlinkat-with-size. : [.gnulib-tests]test-areadlinkat-with-size.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-areadlinkat-with-size.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-argmatch.obj : [.gnulib-tests]test-argmatch.c

[.gnulib-tests]test-argmatch. : [.gnulib-tests]test-argmatch.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-argmatch.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-argv-iter.obj : [.gnulib-tests]test-argv-iter.c

[.gnulib-tests]test-argv-iter. : [.gnulib-tests]test-argv-iter.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-argv-iter.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-arpa_inet.obj : [.gnulib-tests]test-arpa_inet.c

[.gnulib-tests]test-arpa_inet. : [.gnulib-tests]test-arpa_inet.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-arpa_inet.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-base32.obj : [.gnulib-tests]test-base32.c

[.gnulib-tests]test-base32. : [.gnulib-tests]test-base32.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-base32.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-base64.obj : [.gnulib-tests]test-base64.c

[.gnulib-tests]test-base64. : [.gnulib-tests]test-base64.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-base64.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-bind.obj : [.gnulib-tests]test-bind.c

[.gnulib-tests]test-bind. : [.gnulib-tests]test-bind.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-bind.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-bitrotate.obj : [.gnulib-tests]test-bitrotate.c

[.gnulib-tests]test-bitrotate. : [.gnulib-tests]test-bitrotate.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-bitrotate.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-byteswap.obj : [.gnulib-tests]test-byteswap.c

[.gnulib-tests]test-byteswap. : [.gnulib-tests]test-byteswap.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-byteswap.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-c-ctype.obj : [.gnulib-tests]test-c-ctype.c

[.gnulib-tests]test-c-ctype. : [.gnulib-tests]test-c-ctype.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-c-ctype.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-calloc-gnu.obj : [.gnulib-tests]test-calloc-gnu.c

[.gnulib-tests]test-calloc-gnu. : [.gnulib-tests]test-calloc-gnu.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-calloc-gnu.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-canonicalize.obj : [.gnulib-tests]test-canonicalize.c

[.gnulib-tests]test-canonicalize. : [.gnulib-tests]test-canonicalize.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-canonicalize.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-chdir.obj : [.gnulib-tests]test-chdir.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),_POSIX_C_SOURCE=1)$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-chdir. : [.gnulib-tests]test-chdir.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-chdir.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-chown.obj : [.gnulib-tests]test-chown.c

[.gnulib-tests]test-chown. : [.gnulib-tests]test-chown.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-chown.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-cloexec.obj : [.gnulib-tests]test-cloexec.c

[.gnulib-tests]test-cloexec. : [.gnulib-tests]test-cloexec.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-cloexec.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-close.obj : [.gnulib-tests]test-close.c

[.gnulib-tests]test-close. : [.gnulib-tests]test-close.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-close.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-connect.obj : [.gnulib-tests]test-connect.c

[.gnulib-tests]test-connect. : [.gnulib-tests]test-connect.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-connect.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-count-leading-zeros.obj : [.gnulib-tests]test-count-leading-zeros.c

[.gnulib-tests]test-count-leading-zeros. : [.gnulib-tests]test-count-leading-zeros.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-count-leading-zeros.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-md5-buffer.obj : [.gnulib-tests]test-md5-buffer.c

[.gnulib-tests]test-md5-buffer. : [.gnulib-tests]test-md5-buffer.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-md5-buffer.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-md5-stream.obj : [.gnulib-tests]test-md5-stream.c

[.gnulib-tests]test-md5-stream. : [.gnulib-tests]test-md5-stream.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-md5-stream.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sha1-buffer.obj : [.gnulib-tests]test-sha1-buffer.c

[.gnulib-tests]test-sha1-buffer. : [.gnulib-tests]test-sha1-buffer.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sha1-buffer.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sha1-stream.obj : [.gnulib-tests]test-sha1-stream.c

[.gnulib-tests]test-sha1-stream. : [.gnulib-tests]test-sha1-stream.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sha1-stream.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sha256-stream.obj : [.gnulib-tests]test-sha256-stream.c

[.gnulib-tests]test-sha256-stream. : [.gnulib-tests]test-sha256-stream.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sha256-stream.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sha512-stream.obj : [.gnulib-tests]test-sha512-stream.c

[.gnulib-tests]test-sha512-stream. : [.gnulib-tests]test-sha512-stream.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sha512-stream.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sm3-buffer.obj : [.gnulib-tests]test-sm3-buffer.c

[.gnulib-tests]test-sm3-buffer. : [.gnulib-tests]test-sm3-buffer.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sm3-buffer.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-ctype.obj : [.gnulib-tests]test-ctype.c

[.gnulib-tests]test-ctype. : [.gnulib-tests]test-ctype.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-ctype.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-di-set.obj : [.gnulib-tests]test-di-set.c

[.gnulib-tests]test-di-set. : [.gnulib-tests]test-di-set.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-di-set.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-dirent-safer.obj : [.gnulib-tests]test-dirent-safer.c

[.gnulib-tests]test-dirent-safer. : [.gnulib-tests]test-dirent-safer.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-dirent-safer.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-dirent.obj : [.gnulib-tests]test-dirent.c

[.gnulib-tests]test-dirent. : [.gnulib-tests]test-dirent.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-dirent.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-dirname.obj : [.gnulib-tests]test-dirname.c

[.gnulib-tests]test-dirname. : [.gnulib-tests]test-dirname.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-dirname.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-dup.obj : [.gnulib-tests]test-dup.c

[.gnulib-tests]test-dup. : [.gnulib-tests]test-dup.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-dup.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-dup2.obj : [.gnulib-tests]test-dup2.c

[.gnulib-tests]test-dup2. : [.gnulib-tests]test-dup2.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-dup2.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-dynarray.obj : [.gnulib-tests]test-dynarray.c \
	[.lib]dynarray.h lcl_root:[.lib.malloc]dynarray.gl.h \
	lcl_root:[.lib.malloc]dynarray-skeleton.gl.h

[.gnulib-tests]test-dynarray. : [.gnulib-tests]test-dynarray.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-dynarray.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-environ.obj : [.gnulib-tests]test-environ.c

[.gnulib-tests]test-environ. : [.gnulib-tests]test-environ.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-environ.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# <errno.h> is missing declarations for ENOLINK, EPROTO, EMULTIHOP, EOWNERDEAD, ENOTRECOVERABLE

#[.gnulib-tests]test-errno.obj : [.gnulib-tests]test-errno.c

#[.gnulib-tests]test-errno. : [.gnulib-tests]test-errno.obj [.gnulib-tests]libtests.olb
#	link/exe=$(MMS$TARGET) [.gnulib-tests]test-errno.obj, \
#		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
#		$(crtl_init)

[.gnulib-tests]test-explicit_bzero.obj : [.gnulib-tests]test-explicit_bzero.c

[.gnulib-tests]test-explicit_bzero. : [.gnulib-tests]test-explicit_bzero.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-explicit_bzero.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-faccessat.obj : [.gnulib-tests]test-faccessat.c

[.gnulib-tests]test-faccessat. : [.gnulib-tests]test-faccessat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-faccessat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fadvise.obj : [.gnulib-tests]test-fadvise.c

[.gnulib-tests]test-fadvise. : [.gnulib-tests]test-fadvise.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fadvise.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fchdir.obj : [.gnulib-tests]test-fchdir.c

[.gnulib-tests]test-fchdir. : [.gnulib-tests]test-fchdir.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fchdir.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fchmodat.obj : [.gnulib-tests]test-fchmodat.c

[.gnulib-tests]test-fchmodat. : [.gnulib-tests]test-fchmodat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fchmodat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fchownat.obj : [.gnulib-tests]test-fchownat.c

[.gnulib-tests]test-fchownat. : [.gnulib-tests]test-fchownat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fchownat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fclose.obj : [.gnulib-tests]test-fclose.c

[.gnulib-tests]test-fclose. : [.gnulib-tests]test-fclose.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fclose.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# <fcntl.h> is missing declarations for O_IGNORE_CTTY, O_NOLINK, O_NOTRANS, O_TTY_INIT, O_EXEC

#[.gnulib-tests]test-fcntl-h.obj : [.gnulib-tests]test-fcntl-h.c

#[.gnulib-tests]test-fcntl-h. : [.gnulib-tests]test-fcntl-h.obj [.gnulib-tests]libtests.olb
#	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fcntl-h.obj, \
#		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
#		$(crtl_init)

[.gnulib-tests]test-fcntl-safer.obj : [.gnulib-tests]test-fcntl-safer.c

[.gnulib-tests]test-fcntl-safer. : [.gnulib-tests]test-fcntl-safer.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fcntl-safer.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fcntl.obj : [.gnulib-tests]test-fcntl.c

[.gnulib-tests]test-fcntl. : [.gnulib-tests]test-fcntl.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fcntl.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# This is a synonym for fsync() on VMS
#[.gnulib-tests]test-fdatasync.obj : [.gnulib-tests]test-fdatasync.c

#[.gnulib-tests]test-fdatasync. : [.gnulib-tests]test-fdatasync.obj [.gnulib-tests]libtests.olb
#	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fdatasync.obj, \
#		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
#		$(crtl_init)

[.gnulib-tests]test-fdopen.obj : [.gnulib-tests]test-fdopen.c

[.gnulib-tests]test-fdopen. : [.gnulib-tests]test-fdopen.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fdopen.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fdopendir.obj : [.gnulib-tests]test-fdopendir.c

[.gnulib-tests]test-fdopendir. : [.gnulib-tests]test-fdopendir.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fdopendir.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fdutimensat.obj : [.gnulib-tests]test-fdutimensat.c

[.gnulib-tests]test-fdutimensat. : [.gnulib-tests]test-fdutimensat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fdutimensat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fflush.obj : [.gnulib-tests]test-fflush.c

[.gnulib-tests]test-fflush. : [.gnulib-tests]test-fflush.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fflush.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fgetc.obj : [.gnulib-tests]test-fgetc.c

[.gnulib-tests]test-fgetc. : [.gnulib-tests]test-fgetc.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fgetc.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-filenamecat.obj : [.gnulib-tests]test-filenamecat.c

[.gnulib-tests]test-filenamecat. : [.gnulib-tests]test-filenamecat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-filenamecat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-filevercmp.obj : [.gnulib-tests]test-filevercmp.c

[.gnulib-tests]test-filevercmp. : [.gnulib-tests]test-filevercmp.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-filevercmp.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-float.obj : [.gnulib-tests]test-float.c

[.gnulib-tests]test-float. : [.gnulib-tests]test-float.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-float.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fnmatch-h.obj : [.gnulib-tests]test-fnmatch-h.c

[.gnulib-tests]test-fnmatch-h. : [.gnulib-tests]test-fnmatch-h.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fnmatch-h.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fopen-gnu.obj : [.gnulib-tests]test-fopen-gnu.c

[.gnulib-tests]test-fopen-gnu. : [.gnulib-tests]test-fopen-gnu.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fopen-gnu.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fopen-safer.obj : [.gnulib-tests]test-fopen-safer.c

[.gnulib-tests]test-fopen-safer. : [.gnulib-tests]test-fopen-safer.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fopen-safer.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fopen.obj : [.gnulib-tests]test-fopen.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),_POSIX_C_SOURCE=1)$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-fopen. : [.gnulib-tests]test-fopen.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fopen.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fpurge.obj : [.gnulib-tests]test-fpurge.c

[.gnulib-tests]test-fpurge. : [.gnulib-tests]test-fpurge.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fpurge.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fputc.obj : [.gnulib-tests]test-fputc.c

[.gnulib-tests]test-fputc. : [.gnulib-tests]test-fputc.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fputc.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fread.obj : [.gnulib-tests]test-fread.c

[.gnulib-tests]test-fread. : [.gnulib-tests]test-fread.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fread.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-freading.obj : [.gnulib-tests]test-freading.c

[.gnulib-tests]test-freading. : [.gnulib-tests]test-freading.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-freading.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-free.obj : [.gnulib-tests]test-free.c

[.gnulib-tests]test-free. : [.gnulib-tests]test-free.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-free.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-freopen-safer.obj : [.gnulib-tests]test-freopen-safer.c

[.gnulib-tests]test-freopen-safer. : [.gnulib-tests]test-freopen-safer.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-freopen-safer.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-freopen.obj : [.gnulib-tests]test-freopen.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),_POSIX_C_SOURCE=1)$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-freopen. : [.gnulib-tests]test-freopen.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-freopen.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fseterr.obj : [.gnulib-tests]test-fseterr.c

[.gnulib-tests]test-fseterr. : [.gnulib-tests]test-fseterr.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fseterr.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fstat.obj : [.gnulib-tests]test-fstat.c

[.gnulib-tests]test-fstat. : [.gnulib-tests]test-fstat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fstat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fstatat.obj : [.gnulib-tests]test-fstatat.c

[.gnulib-tests]test-fstatat. : [.gnulib-tests]test-fstatat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fstatat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fsync.obj : [.gnulib-tests]test-fsync.c

[.gnulib-tests]test-fsync. : [.gnulib-tests]test-fsync.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fsync.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-ftell3.obj : [.gnulib-tests]test-ftell3.c

[.gnulib-tests]test-ftell3. : [.gnulib-tests]test-ftell3.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-ftell3.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-ftello3.obj : [.gnulib-tests]test-ftello3.c

[.gnulib-tests]test-ftello3. : [.gnulib-tests]test-ftello3.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-ftello3.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-futimens.obj : [.gnulib-tests]test-futimens.c

[.gnulib-tests]test-futimens. : [.gnulib-tests]test-futimens.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-futimens.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-fwrite.obj : [.gnulib-tests]test-fwrite.c

[.gnulib-tests]test-fwrite. : [.gnulib-tests]test-fwrite.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-fwrite.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-getaddrinfo.obj : [.gnulib-tests]test-getaddrinfo.c

[.gnulib-tests]test-getaddrinfo. : [.gnulib-tests]test-getaddrinfo.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-getaddrinfo.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-getcwd-lgpl.obj : [.gnulib-tests]test-getcwd-lgpl.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),_POSIX_C_SOURCE=1)$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-getcwd-lgpl. : [.gnulib-tests]test-getcwd-lgpl.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-getcwd-lgpl.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-getdelim.obj : [.gnulib-tests]test-getdelim.c

[.gnulib-tests]test-getdelim. : [.gnulib-tests]test-getdelim.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-getdelim.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-getdtablesize.obj : [.gnulib-tests]test-getdtablesize.c

[.gnulib-tests]test-getdtablesize. : [.gnulib-tests]test-getdtablesize.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-getdtablesize.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-getgroups.obj : [.gnulib-tests]test-getgroups.c

[.gnulib-tests]test-getgroups. : [.gnulib-tests]test-getgroups.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-getgroups.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-gethostname.obj : [.gnulib-tests]test-gethostname.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),HOST_NAME_MAX=64)$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-gethostname. : [.gnulib-tests]test-gethostname.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-gethostname.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-getline.obj : [.gnulib-tests]test-getline.c

[.gnulib-tests]test-getline. : [.gnulib-tests]test-getline.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-getline.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-getloadavg.obj : [.gnulib-tests]test-getloadavg.c

[.gnulib-tests]test-getloadavg. : [.gnulib-tests]test-getloadavg.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-getloadavg.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-getlogin.obj : [.gnulib-tests]test-getlogin.c

[.gnulib-tests]test-getlogin. : [.gnulib-tests]test-getlogin.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-getlogin.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-getndelim2.obj : [.gnulib-tests]test-getndelim2.c

[.gnulib-tests]test-getndelim2. : [.gnulib-tests]test-getndelim2.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-getndelim2.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-getopt-gnu.obj : [.gnulib-tests]test-getopt-gnu.c

[.gnulib-tests]test-getopt-gnu. : [.gnulib-tests]test-getopt-gnu.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-getopt-gnu.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-getopt-posix.obj : [.gnulib-tests]test-getopt-posix.c

[.gnulib-tests]test-getopt-posix. : [.gnulib-tests]test-getopt-posix.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-getopt-posix.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-getprogname.obj : [.gnulib-tests]test-getprogname.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),EXEEXT="""""")$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-getprogname. : [.gnulib-tests]test-getprogname.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-getprogname.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-getrandom.obj : [.gnulib-tests]test-getrandom.c

[.gnulib-tests]test-getrandom. : [.gnulib-tests]test-getrandom.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-getrandom.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-getrusage.obj : [.gnulib-tests]test-getrusage.c

[.gnulib-tests]test-getrusage. : [.gnulib-tests]test-getrusage.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-getrusage.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-gettimeofday.obj : [.gnulib-tests]test-gettimeofday.c

[.gnulib-tests]test-gettimeofday. : [.gnulib-tests]test-gettimeofday.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-gettimeofday.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-hard-locale.obj : [.gnulib-tests]test-hard-locale.c

[.gnulib-tests]test-hard-locale. : [.gnulib-tests]test-hard-locale.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-hard-locale.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-hash.obj : [.gnulib-tests]test-hash.c

[.gnulib-tests]test-hash. : [.gnulib-tests]test-hash.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-hash.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-i-ring.obj : [.gnulib-tests]test-i-ring.c

[.gnulib-tests]test-i-ring. : [.gnulib-tests]test-i-ring.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-i-ring.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-iconv-h.obj : [.gnulib-tests]test-iconv-h.c

[.gnulib-tests]test-iconv-h. : [.gnulib-tests]test-iconv-h.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-iconv-h.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-iconv.obj : [.gnulib-tests]test-iconv.c

[.gnulib-tests]test-iconv. : [.gnulib-tests]test-iconv.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-iconv.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-ignore-value.obj : [.gnulib-tests]test-ignore-value.c

[.gnulib-tests]test-ignore-value. : [.gnulib-tests]test-ignore-value.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-ignore-value.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-inet_ntop.obj : [.gnulib-tests]test-inet_ntop.c

[.gnulib-tests]test-inet_ntop. : [.gnulib-tests]test-inet_ntop.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-inet_ntop.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-inet_pton.obj : [.gnulib-tests]test-inet_pton.c

[.gnulib-tests]test-inet_pton. : [.gnulib-tests]test-inet_pton.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-inet_pton.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-ino-map.obj : [.gnulib-tests]test-ino-map.c

[.gnulib-tests]test-ino-map. : [.gnulib-tests]test-ino-map.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-ino-map.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-intprops.obj : [.gnulib-tests]test-intprops.c

[.gnulib-tests]test-intprops. : [.gnulib-tests]test-intprops.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-intprops.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-inttostr.obj : [.gnulib-tests]test-inttostr.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/nowarn$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-inttostr. : [.gnulib-tests]test-inttostr.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-inttostr.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-inttypes.obj : [.gnulib-tests]test-inttypes.c

[.gnulib-tests]test-inttypes. : [.gnulib-tests]test-inttypes.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-inttypes.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

#[.gnulib-tests]test-ioctl.obj : [.gnulib-tests]test-ioctl.c \
#	sys$disk:[.vms]vms_ioctl_hack.h

#[.gnulib-tests]test-ioctl. : [.gnulib-tests]test-ioctl.obj [.gnulib-tests]libtests.olb
#	link/exe=$(MMS$TARGET) [.gnulib-tests]test-ioctl.obj, \
#		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
#		$(crtl_init)

[.gnulib-tests]test-isatty.obj : [.gnulib-tests]test-isatty.c

[.gnulib-tests]test-isatty. : [.gnulib-tests]test-isatty.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-isatty.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-isblank.obj : [.gnulib-tests]test-isblank.c

[.gnulib-tests]test-isblank. : [.gnulib-tests]test-isblank.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-isblank.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# ignore divide by zero warning
[.gnulib-tests]test-isnand-nolibm.obj : [.gnulib-tests]test-isnand-nolibm.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/nowarn$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-isnand-nolibm. : [.gnulib-tests]test-isnand-nolibm.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-isnand-nolibm.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# ignore divide by zero warning
[.gnulib-tests]test-isnanf-nolibm.obj : [.gnulib-tests]test-isnanf-nolibm.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/nowarn$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-isnanf-nolibm. : [.gnulib-tests]test-isnanf-nolibm.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-isnanf-nolibm.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# ignore divide by zero warning
[.gnulib-tests]test-isnanl-nolibm.obj : [.gnulib-tests]test-isnanl-nolibm.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/nowarn$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-isnanl-nolibm. : [.gnulib-tests]test-isnanl-nolibm.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-isnanl-nolibm.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-iswblank.obj : [.gnulib-tests]test-iswblank.c

[.gnulib-tests]test-iswblank. : [.gnulib-tests]test-iswblank.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-iswblank.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-langinfo.obj : [.gnulib-tests]test-langinfo.c

[.gnulib-tests]test-langinfo. : [.gnulib-tests]test-langinfo.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-langinfo.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-lchmod.obj : [.gnulib-tests]test-lchmod.c

[.gnulib-tests]test-lchmod. : [.gnulib-tests]test-lchmod.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-lchmod.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-lchown.obj : [.gnulib-tests]test-lchown.c

[.gnulib-tests]test-lchown. : [.gnulib-tests]test-lchown.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-lchown.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

#[.gnulib-tests]test-libgmp.obj : [.gnulib-tests]test-libgmp.c

#[.gnulib-tests]test-libgmp. : [.gnulib-tests]test-libgmp.obj [.gnulib-tests]libtests.olb
#	link/exe=$(MMS$TARGET) [.gnulib-tests]test-libgmp.obj, \
#		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
#		$(crtl_init)

[.gnulib-tests]test-limits-h.obj : [.gnulib-tests]test-limits-h.c

[.gnulib-tests]test-limits-h. : [.gnulib-tests]test-limits-h.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-limits-h.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-link.obj : [.gnulib-tests]test-link.c

[.gnulib-tests]test-link. : [.gnulib-tests]test-link.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-link.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-linkat.obj : [.gnulib-tests]test-linkat.c

[.gnulib-tests]test-linkat. : [.gnulib-tests]test-linkat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-linkat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-listen.obj : [.gnulib-tests]test-listen.c

[.gnulib-tests]test-listen. : [.gnulib-tests]test-listen.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-listen.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

#[.gnulib-tests]test-locale.obj : [.gnulib-tests]test-locale.c

#[.gnulib-tests]test-locale. : [.gnulib-tests]test-locale.obj [.gnulib-tests]libtests.olb
#	link/exe=$(MMS$TARGET) [.gnulib-tests]test-locale.obj, \
#		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
#		$(crtl_init)

#[.gnulib-tests]test-localeconv.obj : [.gnulib-tests]test-localeconv.c

#[.gnulib-tests]test-localeconv. : [.gnulib-tests]test-localeconv.obj [.gnulib-tests]libtests.olb
#	link/exe=$(MMS$TARGET) [.gnulib-tests]test-localeconv.obj, \
#		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
#		$(crtl_init)

[.gnulib-tests]test-localename.obj : [.gnulib-tests]test-localename.c

[.gnulib-tests]test-localename. : [.gnulib-tests]test-localename.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-localename.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# ignore "missing return" warning.
[.gnulib-tests]test-rwlock1.obj : [.gnulib-tests]test-rwlock1.c
   $define/user glthread sys$disk:[.lib.glthread],sys$disk:[.gnulib-tests.glthread]
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/nowarn$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-rwlock1. : [.gnulib-tests]test-rwlock1.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-rwlock1.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# ignore volatile qualifier mismatch
[.gnulib-tests]test-lock.obj : [.gnulib-tests]test-lock.c
   $define/user glthread sys$disk:[.lib.glthread],sys$disk:[.gnulib-tests.glthread]
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/nowarn$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-lock. : [.gnulib-tests]test-lock.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-lock.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-once.obj : [.gnulib-tests]test-once.c

[.gnulib-tests]test-once1. : [.gnulib-tests]test-once.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-once.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# Not sure why this gets compiled as two executables.
[.gnulib-tests]test-once2. : [.gnulib-tests]test-once.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-once.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-lstat.obj : [.gnulib-tests]test-lstat.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/nowarn$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-lstat. : [.gnulib-tests]test-lstat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-lstat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-malloc-gnu.obj : [.gnulib-tests]test-malloc-gnu.c

[.gnulib-tests]test-malloc-gnu. : [.gnulib-tests]test-malloc-gnu.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-malloc-gnu.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-malloca.obj : [.gnulib-tests]test-malloca.c

[.gnulib-tests]test-malloca. : [.gnulib-tests]test-malloca.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-malloca.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-math.obj : [.gnulib-tests]test-math.c

[.gnulib-tests]test-math. : [.gnulib-tests]test-math.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-math.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-mbsalign.obj : [.gnulib-tests]test-mbsalign.c

[.gnulib-tests]test-mbsalign. : [.gnulib-tests]test-mbsalign.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-mbsalign.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-mbsstr1.obj : [.gnulib-tests]test-mbsstr1.c

[.gnulib-tests]test-mbsstr1. : [.gnulib-tests]test-mbsstr1.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-mbsstr1.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-memcasecmp.obj : [.gnulib-tests]test-memcasecmp.c

[.gnulib-tests]test-memcasecmp. : [.gnulib-tests]test-memcasecmp.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-memcasecmp.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-memchr.obj : [.gnulib-tests]test-memchr.c

[.gnulib-tests]test-memchr. : [.gnulib-tests]test-memchr.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-memchr.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-memchr2.obj : [.gnulib-tests]test-memchr2.c

[.gnulib-tests]test-memchr2. : [.gnulib-tests]test-memchr2.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-memchr2.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-memcoll.obj : [.gnulib-tests]test-memcoll.c

[.gnulib-tests]test-memcoll. : [.gnulib-tests]test-memcoll.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-memcoll.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-memrchr.obj : [.gnulib-tests]test-memrchr.c

[.gnulib-tests]test-memrchr. : [.gnulib-tests]test-memrchr.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-memrchr.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-mkdir.obj : [.gnulib-tests]test-mkdir.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),_POSIX_C_SOURCE=1)$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-mkdir. : [.gnulib-tests]test-mkdir.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-mkdir.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-mkdirat.obj : [.gnulib-tests]test-mkdirat.c

[.gnulib-tests]test-mkdirat. : [.gnulib-tests]test-mkdirat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-mkdirat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-mkfifo.obj : [.gnulib-tests]test-mkfifo.c

[.gnulib-tests]test-mkfifo. : [.gnulib-tests]test-mkfifo.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-mkfifo.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-mkfifoat.obj : [.gnulib-tests]test-mkfifoat.c

[.gnulib-tests]test-mkfifoat. : [.gnulib-tests]test-mkfifoat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-mkfifoat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-mknod.obj : [.gnulib-tests]test-mknod.c

[.gnulib-tests]test-mknod. : [.gnulib-tests]test-mknod.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-mknod.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# ignore prototype mismatch
[.gnulib-tests]test-nanosleep.obj : [.gnulib-tests]test-nanosleep.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/nowarn$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-nanosleep. : [.gnulib-tests]test-nanosleep.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-nanosleep.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-netdb.obj : [.gnulib-tests]test-netdb.c

[.gnulib-tests]test-netdb. : [.gnulib-tests]test-netdb.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-netdb.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-netinet_in.obj : [.gnulib-tests]test-netinet_in.c

[.gnulib-tests]test-netinet_in. : [.gnulib-tests]test-netinet_in.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-netinet_in.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# compile failure: missing ALTMON_2 in langinfo.h.
#[.gnulib-tests]test-nl_langinfo-mt.obj : [.gnulib-tests]test-nl_langinfo-mt.c

#[.gnulib-tests]test-nl_langinfo-mt. : [.gnulib-tests]test-nl_langinfo-mt.obj [.gnulib-tests]libtests.olb
#	link/exe=$(MMS$TARGET) [.gnulib-tests]test-nl_langinfo-mt.obj, \
#		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
#		$(crtl_init)

[.gnulib-tests]test-nstrftime.obj : [.gnulib-tests]test-nstrftime.c

[.gnulib-tests]test-nstrftime. : [.gnulib-tests]test-nstrftime.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-nstrftime.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-open.obj : [.gnulib-tests]test-open.c

[.gnulib-tests]test-open. : [.gnulib-tests]test-open.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-open.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-openat-safer.obj : [.gnulib-tests]test-openat-safer.c

[.gnulib-tests]test-openat-safer. : [.gnulib-tests]test-openat-safer.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-openat-safer.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-openat.obj : [.gnulib-tests]test-openat.c

[.gnulib-tests]test-openat. : [.gnulib-tests]test-openat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-openat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-parse-datetime.obj : [.gnulib-tests]test-parse-datetime.c

[.gnulib-tests]test-parse-datetime. : [.gnulib-tests]test-parse-datetime.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-parse-datetime.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-pathmax.obj : [.gnulib-tests]test-pathmax.c

[.gnulib-tests]test-pathmax. : [.gnulib-tests]test-pathmax.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-pathmax.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-perror2.obj : [.gnulib-tests]test-perror2.c

[.gnulib-tests]test-perror2. : [.gnulib-tests]test-perror2.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-perror2.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-pipe.obj : [.gnulib-tests]test-pipe.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),_POSIX_C_SOURCE=1)$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-pipe. : [.gnulib-tests]test-pipe.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-pipe.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

#[.gnulib-tests]test-pipe2.obj : [.gnulib-tests]test-pipe2.c

#[.gnulib-tests]test-pipe2. : [.gnulib-tests]test-pipe2.obj [.gnulib-tests]libtests.olb
#	link/exe=$(MMS$TARGET) [.gnulib-tests]test-pipe2.obj, \
#		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
#		$(crtl_init)

[.gnulib-tests]test-posix_memalign.obj : [.gnulib-tests]test-posix_memalign.c

[.gnulib-tests]test-posix_memalign. : [.gnulib-tests]test-posix_memalign.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-posix_memalign.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-posixtm.obj : [.gnulib-tests]test-posixtm.c

[.gnulib-tests]test-posixtm. : [.gnulib-tests]test-posixtm.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-posixtm.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-printf-frexp.obj : [.gnulib-tests]test-printf-frexp.c

[.gnulib-tests]test-printf-frexp. : [.gnulib-tests]test-printf-frexp.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-printf-frexp.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-printf-frexpl.obj : [.gnulib-tests]test-printf-frexpl.c

[.gnulib-tests]test-printf-frexpl. : [.gnulib-tests]test-printf-frexpl.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-printf-frexpl.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-priv-set.obj : [.gnulib-tests]test-priv-set.c

[.gnulib-tests]test-priv-set. : [.gnulib-tests]test-priv-set.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-priv-set.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

#[.gnulib-tests]test-pselect.obj : [.gnulib-tests]test-pselect.c

#[.gnulib-tests]test-pselect. : [.gnulib-tests]test-pselect.obj [.gnulib-tests]libtests.olb
#	link/exe=$(MMS$TARGET) [.gnulib-tests]test-pselect.obj, \
#		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
#		$(crtl_init)

[.gnulib-tests]test-pthread-cond.obj : [.gnulib-tests]test-pthread-cond.c

[.gnulib-tests]test-pthread-cond. : [.gnulib-tests]test-pthread-cond.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-pthread-cond.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# Compile fails: no pthread_spinlock_t
#[.gnulib-tests]test-pthread.obj : [.gnulib-tests]test-pthread.c

#[.gnulib-tests]test-pthread. : [.gnulib-tests]test-pthread.obj [.gnulib-tests]libtests.olb
#	link/exe=$(MMS$TARGET) [.gnulib-tests]test-pthread.obj, \
#		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
#		$(crtl_init)

[.gnulib-tests]test-pthread-mutex.obj : [.gnulib-tests]test-pthread-mutex.c

[.gnulib-tests]test-pthread-mutex. : [.gnulib-tests]test-pthread-mutex.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-pthread-mutex.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-pthread-thread.obj : [.gnulib-tests]test-pthread-thread.c

[.gnulib-tests]test-pthread-thread. : [.gnulib-tests]test-pthread-thread.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-pthread-thread.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-pthread_sigmask1.obj : [.gnulib-tests]test-pthread_sigmask1.c

[.gnulib-tests]test-pthread_sigmask1. : [.gnulib-tests]test-pthread_sigmask1.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-pthread_sigmask1.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# link failure: missing pthread_kill() function.
#[.gnulib-tests]test-pthread_sigmask2.obj : [.gnulib-tests]test-pthread_sigmask2.c

#[.gnulib-tests]test-pthread_sigmask2. : [.gnulib-tests]test-pthread_sigmask2.obj [.gnulib-tests]libtests.olb
#	link/exe=$(MMS$TARGET) [.gnulib-tests]test-pthread_sigmask2.obj, \
#		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
#		$(crtl_init)

[.gnulib-tests]test-quotearg-simple.obj : [.gnulib-tests]test-quotearg-simple.c

[.gnulib-tests]test-quotearg-simple. : [.gnulib-tests]test-quotearg-simple.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-quotearg-simple.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# ignore extra optional param
[.gnulib-tests]test-raise.obj : [.gnulib-tests]test-raise.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/nowarn$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-raise. : [.gnulib-tests]test-raise.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-raise.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-rand-isaac.obj : [.gnulib-tests]test-rand-isaac.c

[.gnulib-tests]test-rand-isaac. : [.gnulib-tests]test-rand-isaac.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-rand-isaac.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-read.obj : [.gnulib-tests]test-read.c

[.gnulib-tests]test-read. : [.gnulib-tests]test-read.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-read.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-readlink.obj : [.gnulib-tests]test-readlink.c

[.gnulib-tests]test-readlink. : [.gnulib-tests]test-readlink.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-readlink.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-realloc-gnu.obj : [.gnulib-tests]test-realloc-gnu.c

[.gnulib-tests]test-realloc-gnu. : [.gnulib-tests]test-realloc-gnu.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-realloc-gnu.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-reallocarray.obj : [.gnulib-tests]test-reallocarray.c

[.gnulib-tests]test-reallocarray. : [.gnulib-tests]test-reallocarray.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-reallocarray.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-regex.obj : [.gnulib-tests]test-regex.c

[.gnulib-tests]test-regex. : [.gnulib-tests]test-regex.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-regex.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-remove.obj : [.gnulib-tests]test-remove.c

[.gnulib-tests]test-remove. : [.gnulib-tests]test-remove.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-remove.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-rename.obj : [.gnulib-tests]test-rename.c \
	sys$disk:[.vms]vms_rename_hack.h

[.gnulib-tests]test-rename. : [.gnulib-tests]test-rename.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-rename.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-renameat.obj : [.gnulib-tests]test-renameat.c

[.gnulib-tests]test-renameat. : [.gnulib-tests]test-renameat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-renameat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-renameatu.obj : [.gnulib-tests]test-renameatu.c

[.gnulib-tests]test-renameatu. : [.gnulib-tests]test-renameatu.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-renameatu.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-rmdir.obj : [.gnulib-tests]test-rmdir.c

[.gnulib-tests]test-rmdir. : [.gnulib-tests]test-rmdir.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-rmdir.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sched.obj : [.gnulib-tests]test-sched.c lcl_root:[.lib]sched.h

[.gnulib-tests]test-sched. : [.gnulib-tests]test-sched.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sched.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-scratch-buffer.obj : [.gnulib-tests]test-scratch-buffer.c

[.gnulib-tests]test-scratch-buffer. : [.gnulib-tests]test-scratch-buffer.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-scratch-buffer.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-select.obj : [.gnulib-tests]test-select.c

[.gnulib-tests]test-select. : [.gnulib-tests]test-select.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-select.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-setenv.obj : [.gnulib-tests]test-setenv.c

[.gnulib-tests]test-setenv. : [.gnulib-tests]test-setenv.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-setenv.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-setlocale_null.obj : [.gnulib-tests]test-setlocale_null.c

[.gnulib-tests]test-setlocale_null. : [.gnulib-tests]test-setlocale_null.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-setlocale_null.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# ignore "missing return" warning.
[.gnulib-tests]test-setlocale_null-mt-one.obj : [.gnulib-tests]test-setlocale_null-mt-one.c
   $define/user glthread sys$disk:[.lib.glthread],sys$disk:[.gnulib-tests.glthread]
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/nowarn$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-setlocale_null-mt-one. : [.gnulib-tests]test-setlocale_null-mt-one.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-setlocale_null-mt-one.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# ignore "missing return" warning.
[.gnulib-tests]test-setlocale_null-mt-all.obj : [.gnulib-tests]test-setlocale_null-mt-all.c
   $define/user glthread sys$disk:[.lib.glthread],sys$disk:[.gnulib-tests.glthread]
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/nowarn$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-setlocale_null-mt-all. : [.gnulib-tests]test-setlocale_null-mt-all.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-setlocale_null-mt-all.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-setsockopt.obj : [.gnulib-tests]test-setsockopt.c

[.gnulib-tests]test-setsockopt. : [.gnulib-tests]test-setsockopt.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-setsockopt.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sigaction.obj : [.gnulib-tests]test-sigaction.c

[.gnulib-tests]test-sigaction. : [.gnulib-tests]test-sigaction.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sigaction.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-signal-h.obj : [.gnulib-tests]test-signal-h.c

[.gnulib-tests]test-signal-h. : [.gnulib-tests]test-signal-h.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-signal-h.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-signbit.obj : [.gnulib-tests]test-signbit.c

[.gnulib-tests]test-signbit. : [.gnulib-tests]test-signbit.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-signbit.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sigprocmask.obj : [.gnulib-tests]test-sigprocmask.c

[.gnulib-tests]test-sigprocmask. : [.gnulib-tests]test-sigprocmask.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sigprocmask.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sleep.obj : [.gnulib-tests]test-sleep.c

[.gnulib-tests]test-sleep. : [.gnulib-tests]test-sleep.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sleep.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-snprintf.obj : [.gnulib-tests]test-snprintf.c

[.gnulib-tests]test-snprintf. : [.gnulib-tests]test-snprintf.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-snprintf.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sockets.obj : [.gnulib-tests]test-sockets.c

[.gnulib-tests]test-sockets. : [.gnulib-tests]test-sockets.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sockets.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-stat.obj : [.gnulib-tests]test-stat.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/define=($(cdefs1),_POSIX_C_SOURCE=1)$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-stat. : [.gnulib-tests]test-stat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-stat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-stat-time.obj : [.gnulib-tests]test-stat-time.c

[.gnulib-tests]test-stat-time. : [.gnulib-tests]test-stat-time.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-stat-time.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-stdalign.obj : [.gnulib-tests]test-stdalign.c

[.gnulib-tests]test-stdalign. : [.gnulib-tests]test-stdalign.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-stdalign.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-stdbool.obj : [.gnulib-tests]test-stdbool.c

[.gnulib-tests]test-stdbool. : [.gnulib-tests]test-stdbool.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-stdbool.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-stddef.obj : [.gnulib-tests]test-stddef.c

[.gnulib-tests]test-stddef. : [.gnulib-tests]test-stddef.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-stddef.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-stdint.obj : [.gnulib-tests]test-stdint.c

[.gnulib-tests]test-stdint. : [.gnulib-tests]test-stdint.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-stdint.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-stdio.obj : [.gnulib-tests]test-stdio.c

[.gnulib-tests]test-stdio. : [.gnulib-tests]test-stdio.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-stdio.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-stdlib.obj : [.gnulib-tests]test-stdlib.c

[.gnulib-tests]test-stdlib. : [.gnulib-tests]test-stdlib.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-stdlib.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# ignore extended prototype warning
[.gnulib-tests]test-strerror.obj : [.gnulib-tests]test-strerror.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/nowarn$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-strerror. : [.gnulib-tests]test-strerror.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-strerror.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-strerror_r.obj : [.gnulib-tests]test-strerror_r.c

[.gnulib-tests]test-strerror_r. : [.gnulib-tests]test-strerror_r.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-strerror_r.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-striconv.obj : [.gnulib-tests]test-striconv.c

[.gnulib-tests]test-striconv. : [.gnulib-tests]test-striconv.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-striconv.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-string.obj : [.gnulib-tests]test-string.c

[.gnulib-tests]test-string. : [.gnulib-tests]test-string.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-string.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-strncat.obj : [.gnulib-tests]test-strncat.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user unistr sys$disk:[.gnulib-tests.unistr]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-strncat. : [.gnulib-tests]test-strncat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-strncat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-strnlen.obj : [.gnulib-tests]test-strnlen.c

[.gnulib-tests]test-strnlen. : [.gnulib-tests]test-strnlen.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-strnlen.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-strsignal.obj : [.gnulib-tests]test-strsignal.c

[.gnulib-tests]test-strsignal. : [.gnulib-tests]test-strsignal.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-strsignal.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-strtod.obj : [.gnulib-tests]test-strtod.c

[.gnulib-tests]test-strtod. : [.gnulib-tests]test-strtod.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-strtod.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-strtoimax.obj : [.gnulib-tests]test-strtoimax.c

[.gnulib-tests]test-strtoimax. : [.gnulib-tests]test-strtoimax.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-strtoimax.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-strtold.obj : [.gnulib-tests]test-strtold.c

[.gnulib-tests]test-strtold. : [.gnulib-tests]test-strtold.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-strtold.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# ignore trivial function prototype mismatch (__int64 == long long)
[.gnulib-tests]test-strtoll.obj : [.gnulib-tests]test-strtoll.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/nowarn$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-strtoll. : [.gnulib-tests]test-strtoll.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-strtoll.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# ignore trivial function prototype mismatch (__int64 == long long)
[.gnulib-tests]test-strtoull.obj : [.gnulib-tests]test-strtoull.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/nowarn$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-strtoull. : [.gnulib-tests]test-strtoull.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-strtoull.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-strtoumax.obj : [.gnulib-tests]test-strtoumax.c

[.gnulib-tests]test-strtoumax. : [.gnulib-tests]test-strtoumax.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-strtoumax.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-symlink.obj : [.gnulib-tests]test-symlink.c

[.gnulib-tests]test-symlink. : [.gnulib-tests]test-symlink.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-symlink.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-symlinkat.obj : [.gnulib-tests]test-symlinkat.c

[.gnulib-tests]test-symlinkat. : [.gnulib-tests]test-symlinkat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-symlinkat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sys_ioctl.obj : [.gnulib-tests]test-sys_ioctl.c

[.gnulib-tests]test-sys_ioctl. : [.gnulib-tests]test-sys_ioctl.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sys_ioctl.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sys_random.obj : [.gnulib-tests]test-sys_random.c

[.gnulib-tests]test-sys_random. : [.gnulib-tests]test-sys_random.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sys_random.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sys_resource.obj : [.gnulib-tests]test-sys_resource.c

[.gnulib-tests]test-sys_resource. : [.gnulib-tests]test-sys_resource.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sys_resource.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sys_select.obj : [.gnulib-tests]test-sys_select.c

[.gnulib-tests]test-sys_select. : [.gnulib-tests]test-sys_select.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sys_select.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sys_socket.obj : [.gnulib-tests]test-sys_socket.c

[.gnulib-tests]test-sys_socket. : [.gnulib-tests]test-sys_socket.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sys_socket.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sys_stat.obj : [.gnulib-tests]test-sys_stat.c

[.gnulib-tests]test-sys_stat. : [.gnulib-tests]test-sys_stat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sys_stat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sys_time.obj : [.gnulib-tests]test-sys_time.c

[.gnulib-tests]test-sys_time. : [.gnulib-tests]test-sys_time.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sys_time.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sys_types.obj : [.gnulib-tests]test-sys_types.c

[.gnulib-tests]test-sys_types. : [.gnulib-tests]test-sys_types.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sys_types.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sys_uio.obj : [.gnulib-tests]test-sys_uio.c

[.gnulib-tests]test-sys_uio. : [.gnulib-tests]test-sys_uio.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sys_uio.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sys_utsname.obj : [.gnulib-tests]test-sys_utsname.c

[.gnulib-tests]test-sys_utsname. : [.gnulib-tests]test-sys_utsname.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sys_utsname.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-sys_wait.obj : [.gnulib-tests]test-sys_wait.c

[.gnulib-tests]test-sys_wait. : [.gnulib-tests]test-sys_wait.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-sys_wait.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-termios.obj : [.gnulib-tests]test-termios.c

[.gnulib-tests]test-termios. : [.gnulib-tests]test-termios.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-termios.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-thread_self.obj : [.gnulib-tests]test-thread_self.c

[.gnulib-tests]test-thread_self. : [.gnulib-tests]test-thread_self.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-thread_self.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-thread_create.obj : [.gnulib-tests]test-thread_create.c

[.gnulib-tests]test-thread_create. : [.gnulib-tests]test-thread_create.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-thread_create.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# build failure: missing TIME_UTC declaration.
#[.gnulib-tests]test-time.obj : [.gnulib-tests]test-time.c

#[.gnulib-tests]test-time. : [.gnulib-tests]test-time.obj [.gnulib-tests]libtests.olb
#	link/exe=$(MMS$TARGET) [.gnulib-tests]test-time.obj, \
#		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
#		$(crtl_init)

[.gnulib-tests]test-timespec.obj : [.gnulib-tests]test-timespec.c

[.gnulib-tests]test-timespec. : [.gnulib-tests]test-timespec.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-timespec.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-tls.obj : [.gnulib-tests]test-tls.c

[.gnulib-tests]test-tls. : [.gnulib-tests]test-tls.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-tls.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-u64.obj : [.gnulib-tests]test-u64.c

[.gnulib-tests]test-u64. : [.gnulib-tests]test-u64.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-u64.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-uname.obj : [.gnulib-tests]test-uname.c

[.gnulib-tests]test-uname. : [.gnulib-tests]test-uname.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-uname.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-dup-safer.obj : [.gnulib-tests]test-dup-safer.c

[.gnulib-tests]test-dup-safer. : [.gnulib-tests]test-dup-safer.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-dup-safer.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-unistd.obj : [.gnulib-tests]test-unistd.c

[.gnulib-tests]test-unistd. : [.gnulib-tests]test-unistd.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-unistd.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests.unistr]test-u8-mbtoucr.obj : [.gnulib-tests.unistr]test-u8-mbtoucr.c

[.gnulib-tests.unistr]test-u8-mbtoucr. : [.gnulib-tests.unistr]test-u8-mbtoucr.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests.unistr]test-u8-mbtoucr.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests.unistr]test-u8-uctomb.obj : [.gnulib-tests.unistr]test-u8-uctomb.c

[.gnulib-tests.unistr]test-u8-uctomb. : [.gnulib-tests.unistr]test-u8-uctomb.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests.unistr]test-u8-uctomb.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests.uniwidth]test-uc_width.obj : [.gnulib-tests.uniwidth]test-uc_width.c

[.gnulib-tests.uniwidth]test-uc_width. : [.gnulib-tests.uniwidth]test-uc_width.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests.uniwidth]test-uc_width.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests.uniwidth]test-uc_width2.obj : [.gnulib-tests.uniwidth]test-uc_width2.c

[.gnulib-tests.uniwidth]test-uc_width2. : [.gnulib-tests.uniwidth]test-uc_width2.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests.uniwidth]test-uc_width2.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-unlink.obj : [.gnulib-tests]test-unlink.c

[.gnulib-tests]test-unlink. : [.gnulib-tests]test-unlink.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-unlink.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-unlinkat.obj : [.gnulib-tests]test-unlinkat.c

[.gnulib-tests]test-unlinkat. : [.gnulib-tests]test-unlinkat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-unlinkat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-unsetenv.obj : [.gnulib-tests]test-unsetenv.c

[.gnulib-tests]test-unsetenv. : [.gnulib-tests]test-unsetenv.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-unsetenv.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-userspec.obj : [.gnulib-tests]test-userspec.c \
	sys$disk:[.vms]vms_pwd_hack.h

[.gnulib-tests]test-userspec. : [.gnulib-tests]test-userspec.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-userspec.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-usleep.obj : [.gnulib-tests]test-usleep.c

[.gnulib-tests]test-usleep. : [.gnulib-tests]test-usleep.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-usleep.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-utime-h.obj : [.gnulib-tests]test-utime-h.c

[.gnulib-tests]test-utime-h. : [.gnulib-tests]test-utime-h.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-utime-h.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-utime.obj : [.gnulib-tests]test-utime.c

[.gnulib-tests]test-utime. : [.gnulib-tests]test-utime.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-utime.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-utimens.obj : [.gnulib-tests]test-utimens.c

[.gnulib-tests]test-utimens. : [.gnulib-tests]test-utimens.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-utimens.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-utimensat.obj : [.gnulib-tests]test-utimensat.c

[.gnulib-tests]test-utimensat. : [.gnulib-tests]test-utimensat.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-utimensat.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-vasnprintf.obj : [.gnulib-tests]test-vasnprintf.c

[.gnulib-tests]test-vasnprintf. : [.gnulib-tests]test-vasnprintf.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-vasnprintf.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

# ignore intentional divide by zero
[.gnulib-tests]test-vasprintf-posix.obj : [.gnulib-tests]test-vasprintf-posix.c
   $define/user sys sys$disk:[.lib.sys]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.lib.uniwidth],sys$disk:[.gnulib-tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms]
   $(CC)$(CFLAGS)/nowarn$(cmain)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.gnulib-tests]test-vasprintf-posix. : [.gnulib-tests]test-vasprintf-posix.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-vasprintf-posix.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-vasprintf.obj : [.gnulib-tests]test-vasprintf.c

[.gnulib-tests]test-vasprintf. : [.gnulib-tests]test-vasprintf.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-vasprintf.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-verify.obj : [.gnulib-tests]test-verify.c

[.gnulib-tests]test-verify. : [.gnulib-tests]test-verify.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-verify.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-wchar.obj : [.gnulib-tests]test-wchar.c

[.gnulib-tests]test-wchar. : [.gnulib-tests]test-wchar.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-wchar.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-wctype-h.obj : [.gnulib-tests]test-wctype-h.c

[.gnulib-tests]test-wctype-h. : [.gnulib-tests]test-wctype-h.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-wctype-h.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-wcwidth.obj : [.gnulib-tests]test-wcwidth.c

[.gnulib-tests]test-wcwidth. : [.gnulib-tests]test-wcwidth.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-wcwidth.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-write.obj : [.gnulib-tests]test-write.c

[.gnulib-tests]test-write. : [.gnulib-tests]test-write.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-write.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-xvasprintf.obj : [.gnulib-tests]test-xvasprintf.c

[.gnulib-tests]test-xvasprintf. : [.gnulib-tests]test-xvasprintf.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-xvasprintf.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)

[.gnulib-tests]test-yesno.obj : [.gnulib-tests]test-yesno.c

[.gnulib-tests]test-yesno. : [.gnulib-tests]test-yesno.obj [.gnulib-tests]libtests.olb
	link/exe=$(MMS$TARGET) [.gnulib-tests]test-yesno.obj, \
		sys$disk:[.gnulib-tests]libtests.olb/lib, sys$disk:[.lib]libcoreutils.olb/lib, \
		$(crtl_init)
