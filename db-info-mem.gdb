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


define v2p
  set $va = $arg0
  set $pdx = ($va >> 22) & 0x3ff
  set $ptx = ($va >> 12) & 0x3ff
  set $off = ($va & 0xfff)
  printf "Prepare: VA=0x%08x PDX=0x%08x PTX=0x%08x OFFSET=0x%08x\n", $va, $pdx, $ptx, $off

  set $addr1 = $cr3 + ($pdx << 2)
  set $pde = *(pte_t *)($addr1 + 0x80000000)
  printf "Stage 1: CR3=0x%08x PDX=0x%08x ADDR1=0x%08x PDE=0x%08x\n", $cr3, $pdx, $addr1, $pde

  set $pnn = $pde & ~0xfff
  set $addr2 = $pnn + ($ptx << 2)
  set $pte = *(pte_t *)($addr2 + 0x80000000)
  printf "Stage 2: PNN=0x%08x PTX=0x%08x ADDR2=0x%08x PTE=0x%08x\n",  $pnn, $ptx, $addr2, $pte

  set $pnn2 = $pte & ~0xfff
  set $pa = $pnn2 | $off
  printf "Final  : PNN2=0x%08x OFFSET=0x%08x PA=0x%08x\n", $pnn2, $off, $pa

  printf "Summary: VA=0x%08x -> PA=0x%08x\n", $va, $pa
end
