$! File: build_coreutils_man_pages.com
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
$if f$type(perl) .nes. "STRING"
$then
$    write sys$output "Perl is not set up."
$    exit 44
$endif
$!
$!
$!
$ open/read cf configure.
$config_loop:
$   read/end=config_loop_end cf line_in
$   if line_in .eqs. "" then goto config_loop
$   key = f$extract(0, 1, line_in)
$   if key .nes. "P" then goto config_loop
$   key = f$element(0, "=", line_in)
$   if key .eqs. "=" then goto config_loop
$   if key .nes. "PACKAGE_STRING" then goto config_loop
$   PACKAGE_STRING = f$element(1, "=", line_in) - "'" - "'"
$config_loop_end:
$ close cf
$!
$! Then loop through [.man]*.x with this command.
$!
$!perl [.man]help2man --source="GNU Coreutils 8.21" -
$! --include=man/arch.x --output=src/arch.1 [.src]arch
$!
$man_file_loop:
$   man_file = f$search("[.man]*.x", 1)
$   if man_file .eqs. "" then goto man_file_loop_end
$!
$   tool = f$parse(man_file,,,"NAME")
$!
$!  Test does not take --help or --version
$!  Hack - use GNV bash 4.2.45 or later to produce them.
$   if tool .eqs. "test"
$   then
$       perl [.vms]help2man_vms --source="''package_string'" -
        --include=man/'tool'.x --output=src/'tool'.1 [.src]^[
$       goto man_file_loop
$   endif
$   exe_file = f$search("[.src]''tool'.exe")
$   if exe_file .nes. ""
$   then
$       perl [.vms]help2man_vms --source="''package_string'" -
        --include=man/'tool'.x --output=src/'tool'.1 [.src]'tool'
$   endif
$   goto man_file_loop
$man_file_loop_end:
