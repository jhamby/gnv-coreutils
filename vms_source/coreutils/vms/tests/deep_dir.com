$defdir = f$environment("default")
$if p1 .eqs. "" goto all_exit
$!
$i = 1
$loop:
$    create/dir/prot=o:rwed [.sub'i']
$    set def [.sub'i']
$    i = i + 1
$    if i .gt. 'p1' then goto loop_end
$    goto loop
$loop_end:
$!
$all_exit:
$set default 'defdir'
