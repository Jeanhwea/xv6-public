# -*- mode: gdb-script; -*-

define pva
    set $va = $arg0
    set $pdi = ($va >> 22) & 0x3ff
    set $pti = ($va >> 12) & 0x3ff
    set $off = ($va & 0xfff)
    printf "VA(0x%x): 0x%x 0x%x 0x%x\n", $va, $pdi, $pti, $off

    printf "CR3(0x%x)\n", $cr3
    x/4x $cr3
    printf "----------------------------------------\n"

    set $pdb = $cr3 + ($pdi * 4)
    printf "Dir Base: 0x%x:\n", $pdb
    x/4x $pdb
    set $pde = (unsigned int) *$pdb
    printf "Dir Entry: 0x%x\n", $pde

    printf "----------------------------------------\n"

    set $ptb = ($pde & ~0xfff) + ($pti * 4)
    printf "Table Base: 0x%x:\n", $ptb
    x/4x $ptb
    set $pte = (unsigned int) *$ptb
    printf "Table Entry: 0x%x\n", $pte

    set $pa = ($pte & ~0xfff) | $off
    printf "PA: 0x%x\n", $pa
end

define plist
  set $p = $arg0
  set $len = 0
  while $p
    printf "%d:\t %p\n", $len, $p
    # print *($p)
    set $p = $p->next
    set $len = $len + 1
  end
end
