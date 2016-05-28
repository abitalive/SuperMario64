// Prints a memory range in hexadecimal

arch n64.cpu
endian msb
//output "", create

include "LIB/N64.inc"
include "LIB/functions.inc"

origin 0x0
insert "LIB/Super Mario 64 (U) [!].z64"

constant Start(0xBFC007C0)
constant End(0xBFC00800)
constant XCoord(0x3A)
constant YCoord(0xB0)
constant LineLength(0x08)

origin 0x002D2C
base 0x80247D2C
nop
nop
jal PrintHex
nop

origin 0x039EAC
base 0x8027EEAC
PrintHex:
  addiu sp, -0x2C
  sw ra, 0x14 (sp)
  la t0, Start
  ori a1, r0, YCoord
  la a2, StringFormat
  PrintLine:
    ori a0, r0, XCoord
    addiu t1, t0, LineLength
    Loop:
      sw t0, 0x18 (sp)
      sw t1, 0x1C (sp)
      sw a0, 0x20 (sp)
      sw a1, 0x24 (sp)
      sw a2, 0x28 (sp)
      jal PrintInt
      lhu a3, 0 (t0)
      lw t0, 0x18 (sp)
      lw t1, 0x1C (sp)
      lw a0, 0x20 (sp)
      lw a1, 0x24 (sp)
      lw a2, 0x28 (sp)
      addiu a0, 0x30
      addiu t0, 0x02
      bne t0, t1, Loop
      nop
  addiu a1, -0x10
  la t2, End
  bne t0, t2, PrintLine
  nop
  lw ra, 0x14 (sp)
  jr ra
  addiu sp, 0x2C

StringFormat:
  db "%04x", 0x00
