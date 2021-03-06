$! File: Clean_coreutils.com
$!
$! This procedure cleans up the Coreutils project of unneeded files.
$!
$! See the HELP section below for the parameters.
$!
$! Copyright 2013, John Malmberg
$!
$! Permission to use, copy, modify, and/or distribute this software for any
$! purpose with or without fee is hereby granted, provided that the above
$! copyright notice and this permission notice appear in all copies.
$!
$! THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
$! WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
$! MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
$! ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
$! WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
$! ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
$! OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
$!
$! 06-Oct-2013 J. Malmberg - Update for Coreutils 8.21
$!
$!============================================================================
$!
$p1 = f$edit(p1,"UPCASE,TRIM") - "-" - "-"
$if p1 .nes. "REALCLEAN" then goto clean
$!
$if ((p1 .eqs. "HELP") .or. (P1 .eqs. "?"))
$then
$   write sys$output "Clean_coreutils.com - Remove build files from project"
$   write sys$output ""
$   write sys$putout " The default action is to remove everything except the"
$   write sys$output " final coreutils binaries and debug files.
$   write sys$output ""
$   write sys$output " P1 = REALCLEAN, Also causes the Coreutils binaries to be"
$   write sys$output " removed."
$   write sys$output ""
$   write sys$output " P1 = HELP or ?, Prints out this help message.
$   write sys$output ""
$   goto all_exit
$endif
$!
$realclean:
$   file = "*"
$   if f$search("[...]''file'.EXE") .nes. "" then delete [...]'file'.EXE;*
$   if f$search("[...]''file'.OLB") .nes. "" then delete [...]'file'.OLB;*
$   file = "lcl_root:[...]*.1"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:gnv$coreutils_startup.com"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:*.pcsi$desc"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:*.pcsi$text"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:*.release_notes"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:*.bck"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:config.log"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:config.status"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[.sys]param.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]config_vms.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[.CXX_REPOSITORY]CXX$DEMANGLER_DB."
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]alloca.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]arg-nonnull.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]config.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]configmake.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]float_plus.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]fnmatch.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]getopt.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]isnan.c"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]sched.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]signbitd.c"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]signbitf.c"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]signbitl.c"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]stdalign.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]stdint.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]stdio_ext.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]unistr.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]unitypes.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]uniwidth.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]unused-parameter.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]utmp.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]vasnprintf.c"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]context.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]selinux.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]mount.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]split.c"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]version.c"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]version.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "lcl_root:[...]perldoc."
$   if f$search(file) .nes. "" then delete 'file';*
$!
$clean:
$   if f$search("[...]*.DSF") .nes. "" then delete lcl_root:[...]*.DSF;*
$   if f$search("[...]*.STB") .nes. "" then delete lcl_root:[...]*.STB;*
$   if f$search("[...]*.MAP") .nes. "" then delete lcl_root:[...]*.MAP;*
$   if f$search("[...]*.LIS") .nes. "" then delete lcl_root:[...]*.LIS;*
$   if f$search("[...]*.OBJ") .nes. "" then delete lcl_root:[...]*.OBJ;*
$!
$all_exit:
$  exit
