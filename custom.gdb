# -*- mode: gdb-script; -*-

define kfree
  set $p = kmem.freelist
  set $len = 0
  while $p
    if $len < 10
        printf "%d:\t %p\n", $len, $p
    end
    set $p = $p->next
    set $len = $len + 1
  end
printf "total=%d\n", $len
end

define idx
    set $va = $arg0
    set $pdi = ($va >> 22) & 0x3ff
    set $pti = ($va >> 12) & 0x3ff
    set $off = ($va & 0xfff)
    printf "VA(0x%x): PDX=0x%x PTX=0x%x OFFSET=0x%x\n", $va, $pdi, $pti, $off
end

define ppn
    set $pte = $arg0
    set $ppn = $pte & ~0xfff
    set $flag = $pte & 0xfff
    printf "PTE(0x%x): PPN=0x%x FLAGS=0x%x\n", $pte, $ppn, $flag
end
