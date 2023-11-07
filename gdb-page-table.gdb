# -*- mode: gdb-script; -*-

define idx
  set $va = $arg0
  set $pdx = ($va >> 22) & 0x3ff
  set $ptx = ($va >> 12) & 0x3ff
  set $off = ($va & 0xfff)
  printf "VA(0x%x): PDX=0x%x PTX=0x%x OFFSET=0x%x\n", $va, $pdx, $ptx, $off
end

define ppn
  set $pte = $arg0
  set $ppn = $pte & ~0xfff
  set $flag = $pte & 0xfff
  printf "PTE(0x%x): PPN=0x%x FLAGS=0x%x\n", $pte, $ppn, $flag
end
