$! File: coreutils_alias_setup.com
$!
$! The PCSI procedure needs a helper script to set up and remove aliases.
$!
$! If p1 starts with "R" then remove instead of install.
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
$! 13-Oct-2013  J. Malmberg
$!
$!===========================================================================
$!
$ mode = "install"
$ code = f$extract(0, 1, p1)
$ if code .eqs. "R" .or. code .eqs. "r" then mode = "remove"
$!
$ arch_type = f$getsyi("ARCH_NAME")
$ arch_code = f$extract(0, 1, arch_type)
$!
$ if arch_code .nes. "V"
$ then
$   set proc/parse=extended
$ endif
$!
$ bin_files1 = "arch,basename,cat,chcon,chgrp,chmod,chown,cp,cut,"
$ bin_files2 = "date,dd,df,echo,env,false,hostname,kill,link,ln,ls,"
$ bin_files3 = "mkdir,mknod,mktemp,mv,nice,pwd,readlink,rm,rmdir,"
$ bin_files4 = "sleep,sort,stty,sync,touch,true,uname,unlink"
$ bin_files = bin_files1 + bin_files2 + bin_files3 + bin_files4
$!
$ usr_bin1 = "base64,cksum,comm,csplit,dir,dircolors,dirname,du,"
$ usr_bin2 = "expand,expr,factor,fmt,fold,groups,head,hostid,id,"
$ usr_bin3 = "install,join,logname,md5sum,mkfifo,nl,nohup,nproc,"
$ usr_bin4 = "numfmt,od,paste,pathchk,pr,printenv,printf,"
$ usr_bin5 = "ptx,realpath,runcon,seq,sha1sum,sha224sum,sha256sum,"
$ usr_bin6 = "sha384sum,sha512sum,shred,shuf,split,stat,stdbuf,"
$ usr_bin7 = "sum,tac,tail,tee,test,timeout,tr,truncate,tsort,tty,"
$ usr_bin8 = "unexpand,uniq,uptime,vdir,wc,whoami,yes"
$ usr_bin = usr_bin1 + usr_bin2 + usr_bin3 + usr_bin4 + usr_bin5 + usr_bin6
$ usr_bin = usr_bin + usr_bin7 + usr_bin8
$!
$ usr_sbin = "chroot"
$!
$ if arch_code .nes. "V"
$ then
$!
$   call do_alias "lbracket" "[usr.bin]" "^["
$ endif
$!
$ list = bin_files
$ prefix = "[bin]"
$ gosub aliases_list
$!
$ list = usr_bin
$ prefix = "[usr.bin]"
$ gosub aliases_list
$!
$ list = usr_sbin
$ prefix = "[usr.sbin]"
$ gosub aliases_list
$!
$ exit
$!
$aliases_list:
$ i = 0
$alias_list_loop:
$   name = f$element(i, ",", list)
$   if name .eqs. "" then goto alias_list_loop_end
$   if name .eqs. "," then goto alias_list_loop_end
$   call do_alias "''name'" "''prefix'" "''name'"
$   i = i + 1
$   goto alias_list_loop
$alias_list_loop_end:
$ return
$!
$!
$do_alias: subroutine
$ if mode .eqs. "install"
$ then
$   call add_alias "''p1'" "''p2'" "''p3'"
$ else
$   call remove_alias "''p1'" "''p2'" "''p3'"
$ endif
$ exit
$ENDSUBROUTINE ! do_alias
$!
$!
$! P1 is the filename, p2 is the directory prefix
$add_alias: subroutine
$ file = "gnv$gnu:''p2'gnv$''p1'.EXE"
$ alias = "gnv$gnu:''p2'''p1'."
$ if f$search(file) .nes. ""
$ then
$   if f$search(alias) .eqs. ""
$   then
$       set file/enter='alias' 'file'
$   endif
$   alias1 = alias + "exe"
$   if f$search(alias1) .eqs. ""
$   then
$       set file/enter='alias1' 'file'
$   endif
$ endif
$ exit
$ENDSUBROUTINE ! add_alias
$!
$remove_alias: subroutine
$ file = "gnv$gnu:''p2'gnv''p1'.EXE"
$ file_fid = "No_file_fid"
$ alias = "gnv$gnu:''p2'''p1'."
$ if f$search(file) .nes. ""
$ then
$   fid = f$file_attributes(file, "FID")
$   if f$search(alias) .nes. ""
$   then
$       afid = f$file_attributes(alias, "FID")
$       if (afid .eqs. fid)
$       then
$           set file/remove 'alias';
$       endif
$   endif
$   alias1 = alias + "exe"
$   if f$search(alias1) .nes. ""
$   then
$       afid = f$file_attributes(alias1, "FID")
$       if (afid .eqs. fid)
$       then
$           set file/remove 'alias1';
$       endif
$   endif
$ endif
$ exit
$ENDSUBROUTINE ! remove_alias
