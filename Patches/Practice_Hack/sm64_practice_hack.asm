// Super Mario 64 Practice ROM Hack by Abitalive and Kaze

arch n64.cpu
endian msb
//output "", create

include "..\LIB\N64.inc"
include "..\LIB\macros.inc"

origin 0x0
insert "..\LIB\Super Mario 64 (J) [!].z64"

// Title Screen
origin 0xF0DE0
Asciiz("PRACROM")
origin 0xF0DE8
Asciiz("BETA 8")

// All Stars Yellow
origin 0xAC4F8
beq r0, r0, 0xAC51C // 812F14F8 1000
origin 0x65750
beq r0, r0, 0x65760 // 812AA750 1000

// Always Spawn MIPS in Basement
origin 0xB2480
bnez at, 0xB2454 // 812F7482 FFF4
origin 0xB2490
nop // 812F7490 2400

// Always Spawn Sub in DDD
origin 0x7C088
beq r0, r0, 0x7C09C // 812C1088 1000
origin 0xCD5D4
nop // 813125D4 2400
origin 0xFB6BC
nop // 8137FCAC 2400

// Always Spawn Switches Unpressed
origin 0x61748
beq r0, r0, 0x61778 // 812A6748 1000

// Always Spawn Toads with Stars
origin 0x31400
beq r0, r0, 0x31410 // 812769B0 1000
origin 0x31434
beq r0, r0, 0x31444 // 812769E4 1000
origin 0x31468
beq r0, r0, 0x31478 // 81276A18 1000

// Level Reset
origin 0x5771C
nop // 8129C71C 2400
origin 0x57740
nop // 8129C740 2400

// Manual Timer
origin 0x4658
sb k1, 0x9EEE (at) // 81249658 A03B
origin 0x4660
nop // 81249660 2400
origin 0x8ADC
sb r0, 0x00EE (t5) // 8124DADC A1A0 & 8124DADE 00EE

// Never Spawn Fat Race Penguin in CCM
origin 0xCB7FC
beq r0, r0, 0xCB83C // 813107FC 1000

// No Music
origin 0xD747C
addiu a1, r0, 0x0000 // 8131C47C 2405 & 8131C47E 0000

// Show Timer in Castle
origin 0x9DF18
nop // 812E2F18 2400

// Savestates 3.0
origin 0x856E0
constant Buttons(0x80349C30)
constant MemoryStart(0x80339E00)
constant MemoryEnd(0x80360928)
constant MarioSlot(0x8036FDE8)
constant CamPointer(0x8033B860)

or v0, ra, r0
lui t0, 0x8033 // Temp register
lui t1, 0x8036 // Temp register
lui t2, 0x8042 // Temp register
lui t3, 0x8034 // Check buttons
lh t8, Buttons (t3) // Check buttons
Save:
  ori t7, r0, 0x1000 // Save button(s)
  and t9, t8, t7 // Save button check
  lui a0, 0x8040 // Memory destination start (Save) 80400000
  ori a1, t2, 0x6B28 // Memory destination end (Save) 80426B28
  beq t9, t7, Copy // Branch to memory copy
  ori a2, t0, MemoryStart // Memory source start (Save)
Load:
  ori t7, r0, 0x000F // Load button(s)
  and t9, t8, t7 // Load button check
  ori a0, t0, MemoryStart // Memory destination start (Load)
  ori a1, t1, MemoryEnd // Memory destination end (Load)
  bne t9, t7, Skip // Branch to end if neither button(s) pressed
  lui a2, 0x8040 // Memory source start (Load) 80400000
Check:
  lw t4, 0x5FE8 (t2) // Mario slot pointer in state 80425FE8
  lw t5, MarioSlot (t1) // Mario slot pointer
  bne t5, t4, Skip // Branch to end if Mario slots don't match
Camera:
  lw t6, CamPointer (t3)
  sb r0, 0x0030 (t6)
Copy:
  lw a3, $0000 (a2) // Memory copy
  sw a3, $0000 (a0)
  addiu a0, a0, 0x0004
  bne a1, a0, Copy
  addiu a2, a2, 0x0004
Skip:
  jr v0
  nop

// Lag Frame Counter
origin 0xE1a2C
jal 0x8027EF18 // ROM 0x39F18
origin 0x3BB0 // Hijack BUF display
lui t8, 0x8034
lw t7, 0x9F20 (t8) // Read current value
lw t6, 0x9F24 (t8) // Read previous value
sw t7, 0x9F24 (t8) // Copy current value to previous value
subu t5, t7, t6 // Calculate difference between previous and current
lw a3, 0x9F28 (t8) // Load sum
addu a3, a3, t5 // Expect 2 frames difference
addiu a3, a3, 0xFFFE
origin 0x3BE4
sw a3, 0x9F28 (t8) // Save sum
origin 0x39F18 // RAM 0x8027EF18
lui t2,0x8034
lw t3,0x9F20(t2)
addiu t3, t3, 0x0001
sw t3, 0x9F20 (t2) // Add 1 to the video interrupt counter
j 0x80326C18 // Return to normal exception handling path
nop

// Hijack Resource Meter
origin 0x2CFC
nop
origin 0x2D04
jal 0x8027E0AC // ROM 0x390AC
origin 0x390AC // RAM 0x8027E0AC

// Level Select
lui t0, 0x8034
lui t1, 0x8028
addiu t1, t1, 0xEECC // ROM 0x39ECC
ArrayLoop:
  lb t2, 0x0000 (t1) // Load first byte of D1 value from array
  sll t2, t2, 0x8 // Shift first byte left
  lb t3, 0x0001 (t1) // Load second byte of D1 value from array
  or t2, t2, t3 // Combine D1 bytes
  beq t2, r0, Skip00 // Skip if no more values
  nop
  lb t4, 0x0002 (t1) // Load 80 value from array
  lh t5, 0x9C30 (t0) // Check buttons
  bne t5, t2, ArrayLoop // Check if D1 value matches current buttons, loop back if it doesn't
  addiu t1, t1, 0x0003 // Increment loop
  sb t4, 0x9ED9 (t0) // Store the level byte to 0x80339ED9
Skip00:

// Constant Writes
lui t0, 0x8020
lui t1, 0x8033
lui t2, 0x8034

// 120 Star File (Slot 3)
addiu v0, r0, 0x1F10
sh v0, 0x7BE8 (t0) // 81207BE8 1F10
addiu v0, r0, 0xFFCB
sh v0, 0x7BEA (t0) // 81207BEA FFCB
addiu v0, r0, 0x7FFF
sh v0, 0x7BEC (t0) // 81207BEC 7FFF
sh v0, 0x7BEE (t0) // 81207BEE 7FFF
addiu v0, r0, 0x7F7F
sh v0, 0x7BF0 (t0) // 80207BF0 007F & 80207BF1 007F
sh v0, 0x7BF2 (t0) // 80207BF2 007F & 80207BF3 007F
sh v0, 0x7BF4 (t0) // 80207BF4 007F & 80207BF5 007F
sh v0, 0x7BF6 (t0) // 80207BF6 007F & 80207BF7 007F
sh v0, 0x7BF8 (t0) // 80207BF8 007F & 80207BF9 007F
sb v0, 0x7BFA (t0) // 80207BFA 007F
addiu v0, r0, 0x0081
sb v0, 0x7BFB (t0) // 80207BFB 0081
addiu v0, r0, 0x0101
sh v0, 0x7BFC (t0) // 81207BFC 0101
addiu v0, r0, 0x0301
sh v0, 0x7BFE (t0) // 81207BFE 0301
addiu v0, r0, 0x0101
sh v0, 0x7C00 (t0) // 81207C00 0101
addiu v0, r0, 0x0181
sh v0, 0x7C02 (t0) // 81207C02 0181

// Hide BUF Text
addiu v0, r0, 0x2564
sh v0, 0x4A70 (t1) // 81334A70 2564
sb r0, 0x4A72 (t1) // 80334A72 0000

// Infinite Lives
addiu v0, r0, 0x0004
sb v0, 0x9EAD (t2) // 80339EAD 0004

// Remove Time Text
sh r0, 0x71C8 (t1) // 813371C8 0000

// Upstairs RTA (74-Star) Practice File (Slot 4)
addiu v0, r0, 0x7F7F
sh v0, 0x7C5C (t0) // 80207C5C 007F & 80207C5D 007F
sh v0, 0x7C5E (t0) // 80207C5E 007F & 80207C5F 007F
sh v0, 0x7C60 (t0) // 80207C60 007F & 80207C61 007F
sh v0, 0x7C62 (t0) // 80207C62 007F & 80207C63 007F
sb v0, 0x7C64 (t0) // 80207C64 007F
addiu v0, r0, 0x7F0F
sh v0, 0x7C6E (t0) // 81207C6E 7F0F

// Conditionals
lui t0, 0x8020
lui t1, 0x8028
lui t2, 0x8033
lui t3, 0x8034
lui t4, 0x8036

// Automatically Reset Timer at Star Select
lb at, 0x9EC9 (t3)
addiu v0, r0, 0x0004
bne at, v0, Skip01 // D0339EC9 0004
nop
sh r0, 0x9EFC (t3) // 81339EFC 0000
Skip01:

// Level Reset
lb at, 0x9C31 (t3)
addiu v0, r0, 0x0020
bne at, v0, Skip02 // D0339C31 0020
nop
addiu v0, r0, 0x0008
sb v0, 0x9EAE (t3) // 80339EAE 0008
sh r0, 0x9EF2 (t3) // 81339EF2 0000
sh r0, 0x9EA8 (t3) // 81339EA8 0000
addiu v0, r0, 0x0002
sb v0, 0x9ED8 (t3) // 80339ED8 0002
addiu v0, r0, 0x0005
sh v0, 0x00A4 (t4) // 813600A4 0005
Skip02:

// Level Reset Camera Fix
lb at, 0x9ED9 (t3)
addiu v0, r0, 0x001D
beq at, v0, Skip03 // D2339ED9 001D
nop
addiu v0, r0, 0x0001
sh v0, 0x6D2A (t1) // 81286D2A 0001
Skip03:
  bne at, v0, Skip04 // D0339ED9 001D
  nop
  sh r0, 0x6D2A (t1) // 81286D2A 0000
Skip04:

// Manual Timer
lb at, 0x9C31 (t3)
addiu v0, r0, 0x0020
bne at, v0, Skip05 // D0339C31 0020
nop
sh r0, 0x9EFC (t3) // 81339EFC 0000
Skip05:

// Soft Reset
lh at, 0x9C30 (t3)
addiu v0, r0, 0xF000
bne at, v0, Skip06 // D1339C30 F000
nop
addiu v0, r0, 0x0004
sh v0, 0x9EC8 (t3) // 81339EC8 0004
addiu v0, r0, 0x0101
sh v0, 0x9ED8 (t3) // 81339ED8 0101
Skip06:

// Star Select
lb at, 0x9C31 (t3)
addiu v0, r0, 0x0030
bne at, v0, Skip07 // D0339C31 0030
nop
addiu v0, r0, 0x0008
sb v0, 0x9EAE (t3) // 80339EAE 0008
addiu v0, r0, 0x0004
sh v0, 0x9EC8 (t3) // 81339EC8 0004
addiu v0, r0, 0x0002
sb v0, 0x9ED8 (t3) // 80339ED8 0002
sh r0, 0x9EFC (t3) // 81339EFC 0000
sw r0, 0xFED4 (t2) // 8132FED4 0000 & 8132FED6 0000
lb at, 0x9ED9 (t3)
addiu v0, r0, 0x000D
bne at, v0, Not_THI // D0339ED9 000D
nop
THI:
  addiu v0, r0, 0x020A
  sh v0, 0x9EDA (t3) // 81339EDA 020A
  beq r0, r0, Skip07
  nop
Not_THI:
  addiu v0, r0, 0x010A
  sh v0, 0x9EDA (t3) // 81339EDA 010A
Skip07:

// TTC Clock Speed
lb at, 0x9C31 (t3)
addiu v0, r0, 0x0028
bne at, v0, Skip08 // D0339C31 0028
nop
addiu v0, r0, 0x0001
sb v0, 0xFEE9 (t4) // 8035FEE9 0001
Skip08:
  addiu v0, r0, 0x0024
  bne at, v0, Skip09 // D0339C31 0024
  nop
  addiu v0, r0, 0x0003
  sb v0, 0xFEE9 (t4) // 8035FEE9 0003
Skip09:

// Upstairs RTA (74-Star) Practice File (Slot 4)
lb at, 0x7C5A (t0)
bne at, r0, Skip10 // D0207C5A 0000
nop
addiu v0, r0, 0xFF6B
sh v0, 0x7C5A (t0) // 81207C5A FF6B
Skip10:

// WDW Water Level
lh at, 0x9C30 (t3)
addiu v0, r0, 0x0820
bne at, v0, Skip11 // D1339C30 0820
nop
addiu v0, r0, 0x44CB
sh v0, 0xFFDC (t2) // 8132FFDC 44CB
Skip11:
  addiu v0, r0, 0x0120
  bne at, v0, Skip12 // D1339C30 0120
  nop
  addiu v0, r0, 0x44BB
  sh v0, 0xFFDC (t2) // 8132FFDC 44BB
Skip12:
  addiu v0, r0, 0x0420
  bne at, v0, Skip13 // D1339C30 0420
  nop
  addiu v0, r0, 0x44AB
  sh v0, 0xFFDC (t2) // 8132FFDC 44AB
Skip13:

// Lag Frame Counter
lb at, 0x9C31 (t3)
addiu v0, r0, 0x0020
bne at, v0, Skip14 // D0339C31 0020
nop
sw r0, 0x9F28 (t3) // 81339F28 0000 & 81339F2A 0000
Skip14:

// Automatically Reset Counter at Star Select
lb at, 0x9EC9 (t3)
addiu v0, r0, 0x0004
bne at, v0, Skip15 // D0339EC9 0004
nop
sw r0, 0x9F28 (t3) // 81339F28 0000 & 81339F2A 0000
Skip15:

// Return
jr ra
nop

// Level Select Array
origin 0x39ECC // RAM 0x8027EECC
dl 0x080809
dl 0x080118
dl 0x08040C
dl 0x080205
dl 0x88001D
dl 0x48001C
dl 0x010804
dl 0x010107
dl 0x010416
dl 0x010208
dl 0x810012
dl 0x410014
dl 0x040817
dl 0x04010A
dl 0x04040B
dl 0x040224
dl 0x84001F
dl 0x44001B
dl 0x02080D
dl 0x02010E
dl 0x02040F
dl 0x020211
dl 0x820013
dl 0x420015
dw 0x0000
