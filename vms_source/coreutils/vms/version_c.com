$! File version_c.com
$!
$! Generate the version.c file
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
$! 19-Oct-2013  J.Malmberg
$!
$!=========================================================================
$!
$ open/read cf configure.
$config_loop:
$   read/end=config_loop_end cf line_in
$   if line_in .eqs. "" then goto config_loop
$   key = f$extract(0, 1, line_in)
$   if key .nes. "P" then goto config_loop
$   key = f$element(0, "=", line_in)
$   if key .eqs. "=" then goto config_loop
$   if key .nes. "PACKAGE_VERSION" then goto config_loop
$   PACKAGE_VERSION = f$element(1, "=", line_in) - "'" - "'"
$config_loop_end:
$ close cf
$!
$ file = "[.src]version.c"
$ if f$search(file) .nes. "" then delete 'file';*
$ create 'file'
$ open/append vf 'file'
$ write vf "#include ""config.h"""
$ write vf "char const *Version = """,PACKAGE_VERSION,""";"
$ close vf
$!
