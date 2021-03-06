$! File: Build_coreutils_release_notes.com
$!
$! Build the release note file from the three components:
$!    1. The coreutils_release_note_start.txt
$!    2. readme. file from the Coreutils distribution.
$!    3. The coreutils_build_steps.txt.
$!
$! Set the name of the release notes from the GNV_PCSI_FILENAME_BASE
$! logical name.
$!
$! Copyright 2011, John Malmberg
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
$! 15-Mar-2011  J. Malmberg
$!
$!===========================================================================
$!
$ base_file = f$trnlnm("GNV_PCSI_FILENAME_BASE")
$ if base_file .eqs. ""
$ then
$   write sys$output "@MAKE_PCSI_COREUTILS_KIT_NAME.COM has not been run."
$   goto all_exit
$ endif
$!
$ coreutils_readme = f$search("sys$disk:[]readme.")
$ if coreutils_readme .eqs. ""
$ then
$   coreutils_readme = f$search("sys$disk:[]$README.")
$ endif
$ if coreutils_readme .eqs. ""
$ then
$   write sys$output "Can not find coreutils readme file."
$   goto all_exit
$ endif
$!
$ coreutils_copying = f$search("sys$disk:[]copying.")
$ if coreutils_copying .eqs. ""
$ then
$   coreutils_copying = f$search("sys$disk:[]$COPYING.")
$ endif
$ if coreutils_copying .eqs. ""
$ then
$   write sys$output "Can not find coreutils copying file."
$   goto all_exit
$ endif
$!
$ type/noheader sys$disk:[.vms]coreutils_release_note_start.txt,-
        'coreutils_readme',-
        'coreutils_copying', -
        sys$disk:[.vms]coreutils_build_steps.txt -
        /out='base_file'.release_notes
$!
$ purge 'base_file'.release_notes
$ rename 'base_file.release_notes ;1
$!
$all_exit:
$   exit
