# -*- mode: gdb-script; -*-

define freemem
  set $p = kmem.freelist
  set $len = 0
  while $p
    if $len < 9
      printf "%d\t: %p\n", 1+$len, $p
      # p/x *($p)
    end
    set $p = $p->next
    set $len = $len + 1
  end
  printf "total=%d\n", $len
end