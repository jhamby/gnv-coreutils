$! File: build_vms.com
$!
$! Procedure to build coreutils on VMS.
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
$!
$!
$!=========================================================================
$!
$if p1 .eqs. "CLEAN" .or. P1 .eqs. "REALCLEAN"
$then
$  @[.vms]clean_coreutils.com 'p1'
$  exit
$endif
$!
$!
$! First build binaries.
$if f$search("[.src]*.exe") .eqs. ""
$then
$   mmk/descript=[.vms]coreutils.mms
$else
$   write sys$output "Binaries already built."
$endif
$!
$! Create the man pages
$if f$search("[.src]*.1") .eqs. ""
$then
$   @[.vms]build_coreutils_man_pages.com
$else
$   write sys$output "Man pages already built."
$endif
$!
$!
$if f$trnlnm("new_gnu") .eqs. ""
$then
$   write sys$output "new_gnu: not defined, can not stage"
$   exit
$endif
$!
$write sys$output "Removing previously staged files"
$@[.vms]stage_coreutils_install.com remove
$write sys$output "Staging files to new_gnu:[...]"
$@[.vms]stage_coreutils_install.com
$!
$!
$gnv_pcsi_prod = f$trnlnm("GNV_PCSI_PRODUCER")
$gnv_pcsi_prod_fn = f$trnlnm("GNV_PCSI_PRODUCER_FULL_NAME")
$stage_root = f$trnlnm("STAGE_ROOT")
$if (gnv_pcsi_prod .eqs. "") .or. -
    (gnv_pcsi_prod_fn .eqs. "") .or. -
    (stage_root .eqs. "")
$then
$   if gnv_pcsi_prod .eqs. ""
$   then
$       msg = "GNV_PCSI_PRODUCER not defined, can not build a PCSI kit."
$       write sys$output msg
$   endif
$   if gnv_pcsi_prod_fn .eqs. ""
$   then
$     msg = "GNV_PCSI_PRODUCER_FULL_NAME not defined, can not build a PCSI kit."
$       write sys$output msg
$   endif
$   if stage_root .eqs. ""
$   then
$       write sys$output "STAGE_ROOT not defined, no place to put kits"
$   endif
$   exit
$endif
$!
$!
$@[.vms]pcsi_product_coreutils.com
$!
$exit
