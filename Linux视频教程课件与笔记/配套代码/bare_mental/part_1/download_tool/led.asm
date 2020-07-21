
led.bin:     file format binary


Disassembly of section .data:

00000000 <.data>:
   0:	e3a0d321 	mov	sp, #-2080374784	; 0x84000000
   4:	ea000044 	b	0x11c
   8:	00001341 	andeq	r1, r0, r1, asr #6
   c:	61656100 	cmnvs	r5, r0, lsl #2
  10:	01006962 	tsteq	r0, r2, ror #18
  14:	00000009 	andeq	r0, r0, r9
  18:	01080106 	tsteq	r8, r6, lsl #2
  1c:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
  20:	e28db000 	add	fp, sp, #0
  24:	e24dd014 	sub	sp, sp, #20
  28:	e50b0008 	str	r0, [fp, #-8]
  2c:	e50b100c 	str	r1, [fp, #-12]
  30:	e50b2010 	str	r2, [fp, #-16]
  34:	e50b3014 	str	r3, [fp, #-20]	; 0xffffffec
  38:	e51b3008 	ldr	r3, [fp, #-8]
  3c:	e51b200c 	ldr	r2, [fp, #-12]
  40:	e202100f 	and	r1, r2, #15
  44:	e59b2008 	ldr	r2, [fp, #8]
  48:	e1a02202 	lsl	r2, r2, #4
  4c:	e2022010 	and	r2, r2, #16
  50:	e1812002 	orr	r2, r1, r2
  54:	e5832000 	str	r2, [r3]
  58:	e51b3010 	ldr	r3, [fp, #-16]
  5c:	e3530000 	cmp	r3, #0
  60:	0a000003 	beq	0x74
  64:	e51b3010 	ldr	r3, [fp, #-16]
  68:	e51b2014 	ldr	r2, [fp, #-20]	; 0xffffffec
  6c:	e2022007 	and	r2, r2, #7
  70:	e5832000 	str	r2, [r3]
  74:	e1a00000 	nop			; (mov r0, r0)
  78:	e28bd000 	add	sp, fp, #0
  7c:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
  80:	e12fff1e 	bx	lr
  84:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
  88:	e28db000 	add	fp, sp, #0
  8c:	e24dd014 	sub	sp, sp, #20
  90:	e50b0008 	str	r0, [fp, #-8]
  94:	e50b100c 	str	r1, [fp, #-12]
  98:	e50b2010 	str	r2, [fp, #-16]
  9c:	e50b3014 	str	r3, [fp, #-20]	; 0xffffffec
  a0:	e59b3004 	ldr	r3, [fp, #4]
  a4:	e3530000 	cmp	r3, #0
  a8:	0a000002 	beq	0xb8
  ac:	e59b3004 	ldr	r3, [fp, #4]
  b0:	e59b2008 	ldr	r2, [fp, #8]
  b4:	e5832000 	str	r2, [r3]
  b8:	e1a00000 	nop			; (mov r0, r0)
  bc:	e28bd000 	add	sp, fp, #0
  c0:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
  c4:	e12fff1e 	bx	lr
  c8:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
  cc:	e28db000 	add	fp, sp, #0
  d0:	e24dd014 	sub	sp, sp, #20
  d4:	e50b0010 	str	r0, [fp, #-16]
  d8:	e3a03000 	mov	r3, #0
  dc:	e50b3008 	str	r3, [fp, #-8]
  e0:	e3a03000 	mov	r3, #0
  e4:	e50b3008 	str	r3, [fp, #-8]
  e8:	ea000003 	b	0xfc
  ec:	e1a00000 	nop			; (mov r0, r0)
  f0:	e51b3008 	ldr	r3, [fp, #-8]
  f4:	e2833001 	add	r3, r3, #1
  f8:	e50b3008 	str	r3, [fp, #-8]
  fc:	e51b2008 	ldr	r2, [fp, #-8]
 100:	e51b3010 	ldr	r3, [fp, #-16]
 104:	e1520003 	cmp	r2, r3
 108:	3afffff7 	bcc	0xec
 10c:	e1a00000 	nop			; (mov r0, r0)
 110:	e28bd000 	add	sp, fp, #0
 114:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
 118:	e12fff1e 	bx	lr
 11c:	e92d4800 	push	{fp, lr}
 120:	e28db004 	add	fp, sp, #4
 124:	e24dd008 	sub	sp, sp, #8
 128:	e59f30b0 	ldr	r3, [pc, #176]	; 0x1e0
 12c:	e3e02000 	mvn	r2, #0
 130:	e583206c 	str	r2, [r3, #108]	; 0x6c
 134:	e3a03000 	mov	r3, #0
 138:	e58d3004 	str	r3, [sp, #4]
 13c:	e59f30a0 	ldr	r3, [pc, #160]	; 0x1e4
 140:	e58d3000 	str	r3, [sp]
 144:	e3a03000 	mov	r3, #0
 148:	e3a02000 	mov	r2, #0
 14c:	e3a01005 	mov	r1, #5
 150:	e59f0090 	ldr	r0, [pc, #144]	; 0x1e8
 154:	ebffffb0 	bl	0x1c
 158:	e59f308c 	ldr	r3, [pc, #140]	; 0x1ec
 15c:	e58d3004 	str	r3, [sp, #4]
 160:	e59f307c 	ldr	r3, [pc, #124]	; 0x1e4
 164:	e58d3000 	str	r3, [sp]
 168:	e3a03000 	mov	r3, #0
 16c:	e3a02000 	mov	r2, #0
 170:	e3a01005 	mov	r1, #5
 174:	e59f006c 	ldr	r0, [pc, #108]	; 0x1e8
 178:	ebffffc1 	bl	0x84
 17c:	e59f206c 	ldr	r2, [pc, #108]	; 0x1f0
 180:	e59f3068 	ldr	r3, [pc, #104]	; 0x1f0
 184:	e5933004 	ldr	r3, [r3, #4]
 188:	e3833010 	orr	r3, r3, #16
 18c:	e5823004 	str	r3, [r2, #4]
 190:	e59f2058 	ldr	r2, [pc, #88]	; 0x1f0
 194:	e59f3054 	ldr	r3, [pc, #84]	; 0x1f0
 198:	e5933000 	ldr	r3, [r3]
 19c:	e3833010 	orr	r3, r3, #16
 1a0:	e5823000 	str	r3, [r2]
 1a4:	e59f2044 	ldr	r2, [pc, #68]	; 0x1f0
 1a8:	e59f3040 	ldr	r3, [pc, #64]	; 0x1f0
 1ac:	e5933000 	ldr	r3, [r3]
 1b0:	e3c33010 	bic	r3, r3, #16
 1b4:	e5823000 	str	r3, [r2]
 1b8:	e59f0034 	ldr	r0, [pc, #52]	; 0x1f4
 1bc:	ebffffc1 	bl	0xc8
 1c0:	e59f2028 	ldr	r2, [pc, #40]	; 0x1f0
 1c4:	e59f3024 	ldr	r3, [pc, #36]	; 0x1f0
 1c8:	e5933000 	ldr	r3, [r3]
 1cc:	e3833010 	orr	r3, r3, #16
 1d0:	e5823000 	str	r3, [r2]
 1d4:	e59f0018 	ldr	r0, [pc, #24]	; 0x1f4
 1d8:	ebffffba 	bl	0xc8
 1dc:	eafffff0 	b	0x1a4
 1e0:	020c4000 	andeq	r4, ip, #0
 1e4:	020e02f8 	andeq	r0, lr, #248, 4	; 0x8000000f
 1e8:	020e006c 	andeq	r0, lr, #108	; 0x6c
 1ec:	000010b0 	strheq	r1, [r0], -r0
 1f0:	0209c000 	andeq	ip, r9, #0
 1f4:	000fffff 	strdeq	pc, [pc], -pc	; <UNPREDICTABLE>
