# -*- mode: gdb-script; -*-
define xv-idx
  set $va = $arg0
  set $pdx = ($va >> 22) & 0x3ff
  set $ptx = ($va >> 12) & 0x3ff
  set $off = ($va & 0xfff)
  printf "VA(0x%x): PDX=0x%x PTX=0x%x OFFSET=0x%x\n", $va, $pdx, $ptx, $off
end

define xv-pte
  set $pte = $arg0
  set $ppn = $pte & ~0xfff
  set $flag = $pte & 0xfff
  printf "PTE(0x%x): PPN=0x%x FLAGS=0x%x\n", $pte, $ppn, $flag
end

define xv-v2p
  set $va = $arg0
  set $pdx = ($va >> 22) & 0x3ff
  set $ptx = ($va >> 12) & 0x3ff
  set $off = ($va & 0xfff)
  printf "Prepare: VA=0x%08x PDX=0x%08x PTX=0x%08x OFFSET=0x%08x\n", $va, $pdx, $ptx, $off

  set $addr1 = $cr3 + ($pdx << 2)
  set $pde = *(pte_t *)($addr1 + 0x80000000)
  printf "Stage 1: CR3=0x%08x PDX=0x%08x ADDR1=0x%08x PDE=0x%08x\n", $cr3, $pdx, $addr1, $pde

  set $ppn = $pde & ~0xfff
  set $addr2 = $ppn + ($ptx << 2)
  set $pte = *(pte_t *)($addr2 + 0x80000000)
  printf "Stage 2: PPN=0x%08x PTX=0x%08x ADDR2=0x%08x PTE=0x%08x\n",  $ppn, $ptx, $addr2, $pte

  set $ppn2 = $pte & ~0xfff
  set $pa = $ppn2 | $off
  printf "Final  : PPN2=0x%08x OFFSET=0x%08x PA=0x%08x\n", $ppn2, $off, $pa

  printf "Summary: VA=0x%08x -> PA=0x%08x\n", $va, $pa
end

define xv-freelist
  set $p = kmem.freelist
  set $len = 0
  printf "Dump top free pages ...\n"
  while $p
    if $len < 9
      printf "#%d: %p\n", 1+$len, $p
      # x/8x $p
      # p/x *($p)
    end
    set $p = $p->next
    set $len = $len + 1
  end

  set $fsz = $len * 4
  printf "Summary: %d pages, total %.2fMb\n", $len, (float) $fsz / 1024
end

define xv-bufs
  set $p = idequeue
  set $len = 0
  printf "Dump IDE Queue buf ...\n"
  while $p
    if $len < 9
      printf "#%d: dev=%d, blockno=%d, refcnt=%d\n", 1+$len, $p->dev, $p->blockno, $p->refcnt
      # x/8x $p
      # p/x *($p)
    end
    set $p = $p->next
    set $len = $len + 1
  end

  printf "Summary: %d bufs\n", $len
end

define xv-ps
  set $i = 0
  while $i < 64
    set var $p = ptable.proc[$i]
    if $p.pid > 0
      printf "ptable.proc[%d]: pid=%d state=%d name=%s\n", $i, $p.pid, $p.state, ptable.proc[$i].name
      # p $p
    end
    set $i = $i + 1
  end
end

define xv-ctx
  printf "ctx: cs=0x%x eip=0x%x ss=0x%x esp=0x%x eflags=0x%x\n", $cs, $eip, $ss, $esp, $eflags
end

define xv-list-cpus
  set $cpui = 0
  while $cpui < 8
    set $cpu = cpus[$cpui]

    printf "CPU %d: apicid:0x%x, started=%d, ncli=%d\n", $cpui, $cpu.apicid, $cpu.started, $cpu.ncli

    # p/x $cpu.proc
    # p/x $cpu.ts
    set $cpui = $cpui + 1
  end
end
