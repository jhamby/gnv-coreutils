$! File: remove_old_coreutils.com
$!
$! This is a procedure to remove the old coreutils images that were installed
$! by the GNV kits and replace them with links to the new image.
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
$! 29-Sep-2013  J. Malmberg
$!
$!==========================================================================
$!
$vax = f$getsyi("HW_MODEL") .lt. 1024
$old_parse = ""
$if .not. VAX
$then
$   old_parse = f$getjpi("", "parse_style_perm")
$   set process/parse=extended
$endif
$!
$old_cutils1 = "arch,base64,basename,cat,chcon,chgrp,chmod,chown,chroot,"
$old_cutils2 = "cksum,cmp,comm,cp,csplit,cut,date,dd,df,dir,dircolor,"
$old_cutils3 = "dirname,du,echo,env,expand,expr,factor,false,fmt,fold,"
$old_cutils4 = "group,head,hostid,hostname,id,install,join,kill,link,ln,"
$old_cutils5 = "logname,ls,md5sum,mkdir,mkfifo,mknod,mktemp,mv,nice,nl,"
$old_cutils6 = "nohup,nproc,numfmt,od,paste,pinky,pathchk,printenv,"
$old_cutils7 = "printf,ptx,pwd,readlink,realpath,rm,rmdir,runcon,seq,"
$old_cutils8 = "sha1sum,sha224sum,sha256sum,sha384sum,sha512sum,shred,"
$old_cutils9 = "shuf,sleep,sort,split,stat,stdbuf,stty,sum,sync,tac,"
$old_cutils10 = "tail,tee,test,timeout,touch,tr,true,truncate,tsort,"
$old_cutils11 = "tty,uname,unexpand,uniq,unlink,users,vdir,wc,who,"
$old_cutils12 = "whoami,yes,"
$!
$old_cutils = old_cutils1 + old_cutils2 + old_cutils3 + old_cutils4
$old_cutils = old_cutils + old_cutils5 + old_cutils6 + old_cutils7
$old_cutils = old_cutils + old_cutils8 + old_cutils9 + old_cutils10
$old_cutils = old_cutils + old_cutils11 + old_cutils12
$!
$!
$ i = 0
$cutils_loop:
$   file = f$element(i, ",", old_cutils)
$   if file .eqs. "" then goto cutils_loop_end
$   if file .eqs. "," then goto cutils_loop_end
$   call update_old_image 'file'
$   i = i + 1
$   goto cutils_loop
$cutils_loop_end:
$!
$!
$if .not. VAX
$then
$   set process/parse='old_parse'
$endif
$!
$all_exit:
$  exit
$!
$! Remove old image or update it if needed.
$!-------------------------------------------
$update_old_image: subroutine
$!
$ file = p1
$! First get the FID of the new coreutils image.
$! Don't remove anything that matches it.
$ new_coreutils = f$search("GNV$GNU:[BIN]GNV$''file'.EXE")
$!
$ new_coreutils_fid = "No_new_coreutils_fid"
$ if new_coreutils .nes. ""
$ then
$   new_coreutils_fid = f$file_attributes(new_coreutils, "FID")
$ endif
$!
$!
$!
$! Now get check the "''file'." and "''file'.exe"
$! May be links or copies.
$! Ok to delete and replace.
$!
$!
$ old_coreutils_fid = "No_old_coreutils_fid"
$ old_coreutils = f$search("gnv$gnu:[bin]''file'.")
$ old_coreutils_exe_fid = "No_old_coreutils_fid"
$ old_coreutils_exe = f$search("gnv$gnu:[bin]''file'.exe")
$ if old_coreutils_exe .nes. ""
$ then
$   old_coreutils_exe_fid = f$file_attributes(old_coreutils_exe, "FID")
$ endif
$!
$ if old_coreutils .nes. ""
$ then
$   fid = f$file_attributes(old_coreutils, "FID")
$   if fid .nes. new_coreutils_fid
$   then
$       if fid .eqs. old_coreutils_exe_fid
$       then
$           set file/remove 'old_coreutils'
$       else
$           delete 'old_coreutils'
$       endif
$       if new_coreutils .nes. ""
$       then
$           set file/enter='old_coreutils' 'new_coreutils'
$       endif
$   endif
$ endif
$!
$ if old_coreutils_exe .nes. ""
$ then
$   if old_coreutils_fid .nes. new_coreutils_fid
$   then
$       delete 'old_coreutils_exe'
$       if new_coreutils .nes. ""
$       then
$           set file/enter='old_coreutils_exe' 'new_coreutils'
$       endif
$   endif
$ endif
$!
$ exit
$ENDSUBROUTINE ! Update old image
