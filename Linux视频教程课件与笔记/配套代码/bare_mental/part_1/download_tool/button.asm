
button.bin:     file format binary


Disassembly of section .data:

00000000 <.data>:
   0:	e59ff0d4 	ldr	pc, [pc, #212]	; 0xdc
   4:	e59ff0d4 	ldr	pc, [pc, #212]	; 0xe0
   8:	e59ff0d4 	ldr	pc, [pc, #212]	; 0xe4
   c:	e59ff0d4 	ldr	pc, [pc, #212]	; 0xe8
  10:	e59ff0d4 	ldr	pc, [pc, #212]	; 0xec
  14:	00000000 	andeq	r0, r0, r0
  18:	e59ff0d0 	ldr	pc, [pc, #208]	; 0xf0
  1c:	e59ff0d0 	ldr	pc, [pc, #208]	; 0xf4
  20:	f10c0080 	cpsid	i
  24:	ee110f10 	mrc	15, 0, r0, cr1, cr0, {0}
  28:	e3c00a01 	bic	r0, r0, #4096	; 0x1000
  2c:	e3c00004 	bic	r0, r0, #4
  30:	e3c00002 	bic	r0, r0, #2
  34:	e3c00b02 	bic	r0, r0, #2048	; 0x800
  38:	e3c00001 	bic	r0, r0, #1
  3c:	ee010f10 	mcr	15, 0, r0, cr1, cr0, {0}
  40:	f1020012 	cps	#18
  44:	e59fd0ac 	ldr	sp, [pc, #172]	; 0xf8
  48:	f102001f 	cps	#31
  4c:	e59fd0a8 	ldr	sp, [pc, #168]	; 0xfc
  50:	f1020013 	cps	#19
  54:	e59fd0a0 	ldr	sp, [pc, #160]	; 0xfc
  58:	e59f20a0 	ldr	r2, [pc, #160]	; 0x100
  5c:	e12fff32 	blx	r2
  60:	f1080080 	cpsie	i
  64:	ea0000ca 	b	0x394
  68:	eafffffe 	b	0x68
  6c:	eafffffe 	b	0x6c
  70:	e59f006c 	ldr	r0, [pc, #108]	; 0xe4
  74:	e12fff10 	bx	r0
  78:	e59f0068 	ldr	r0, [pc, #104]	; 0xe8
  7c:	e12fff10 	bx	r0
  80:	e59f0064 	ldr	r0, [pc, #100]	; 0xec
  84:	e12fff10 	bx	r0
  88:	e52de004 	push	{lr}		; (str lr, [sp, #-4]!)
  8c:	e92d100f 	push	{r0, r1, r2, r3, ip}
  90:	e14f0000 	mrs	r0, SPSR
  94:	e52d0004 	push	{r0}		; (str r0, [sp, #-4]!)
  98:	ee9f1f10 	mrc	15, 4, r1, cr15, cr0, {0}
  9c:	e2811a02 	add	r1, r1, #8192	; 0x2000
  a0:	e591000c 	ldr	r0, [r1, #12]
  a4:	e92d0003 	push	{r0, r1}
  a8:	f1020013 	cps	#19
  ac:	e52de004 	push	{lr}		; (str lr, [sp, #-4]!)
  b0:	e59f204c 	ldr	r2, [pc, #76]	; 0x104
  b4:	e12fff32 	blx	r2
  b8:	e49de004 	pop	{lr}		; (ldr lr, [sp], #4)
  bc:	f1020012 	cps	#18
  c0:	e8bd0003 	pop	{r0, r1}
  c4:	e5810010 	str	r0, [r1, #16]
  c8:	e49d0004 	pop	{r0}		; (ldr r0, [sp], #4)
  cc:	e16ff000 	msr	SPSR_fsxc, r0
  d0:	e8bd100f 	pop	{r0, r1, r2, r3, ip}
  d4:	e49de004 	pop	{lr}		; (ldr lr, [sp], #4)
  d8:	e25ef004 	subs	pc, lr, #4
  dc:	80001020 	andhi	r1, r0, r0, lsr #32
  e0:	8000106c 	andhi	r1, r0, ip, rrx
  e4:	80001070 	andhi	r1, r0, r0, ror r0
  e8:	80001078 	andhi	r1, r0, r8, ror r0
  ec:	80001080 	andhi	r1, r0, r0, lsl #1
  f0:	80001088 	andhi	r1, r0, r8, lsl #1
  f4:	00000000 	andeq	r0, r0, r0
  f8:	9ff00000 	svcls	0x00f00000	; IMB
  fc:	9fe00000 	svcls	0x00e00000
 100:	800017c8 	andhi	r1, r0, r8, asr #15
 104:	80001b74 	andhi	r1, r0, r4, ror fp
 108:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
 10c:	e28db000 	add	fp, sp, #0
 110:	e24dd014 	sub	sp, sp, #20
 114:	e50b0008 	str	r0, [fp, #-8]
 118:	e50b100c 	str	r1, [fp, #-12]
 11c:	e50b2010 	str	r2, [fp, #-16]
 120:	e50b3014 	str	r3, [fp, #-20]	; 0xffffffec
 124:	e51b3008 	ldr	r3, [fp, #-8]
 128:	e51b200c 	ldr	r2, [fp, #-12]
 12c:	e202100f 	and	r1, r2, #15
 130:	e59b2008 	ldr	r2, [fp, #8]
 134:	e1a02202 	lsl	r2, r2, #4
 138:	e2022010 	and	r2, r2, #16
 13c:	e1812002 	orr	r2, r1, r2
 140:	e5832000 	str	r2, [r3]
 144:	e51b3010 	ldr	r3, [fp, #-16]
 148:	e3530000 	cmp	r3, #0
 14c:	0a000003 	beq	0x160
 150:	e51b3010 	ldr	r3, [fp, #-16]
 154:	e51b2014 	ldr	r2, [fp, #-20]	; 0xffffffec
 158:	e2022007 	and	r2, r2, #7
 15c:	e5832000 	str	r2, [r3]
 160:	e1a00000 	nop			; (mov r0, r0)
 164:	e28bd000 	add	sp, fp, #0
 168:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
 16c:	e12fff1e 	bx	lr
 170:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
 174:	e28db000 	add	fp, sp, #0
 178:	e24dd014 	sub	sp, sp, #20
 17c:	e50b0008 	str	r0, [fp, #-8]
 180:	e50b100c 	str	r1, [fp, #-12]
 184:	e50b2010 	str	r2, [fp, #-16]
 188:	e50b3014 	str	r3, [fp, #-20]	; 0xffffffec
 18c:	e59b3004 	ldr	r3, [fp, #4]
 190:	e3530000 	cmp	r3, #0
 194:	0a000002 	beq	0x1a4
 198:	e59b3004 	ldr	r3, [fp, #4]
 19c:	e59b2008 	ldr	r2, [fp, #8]
 1a0:	e5832000 	str	r2, [r3]
 1a4:	e1a00000 	nop			; (mov r0, r0)
 1a8:	e28bd000 	add	sp, fp, #0
 1ac:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
 1b0:	e12fff1e 	bx	lr
 1b4:	e92d4800 	push	{fp, lr}
 1b8:	e28db004 	add	fp, sp, #4
 1bc:	e24dd008 	sub	sp, sp, #8
 1c0:	e3a03000 	mov	r3, #0
 1c4:	e58d3004 	str	r3, [sp, #4]
 1c8:	e59f3150 	ldr	r3, [pc, #336]	; 0x320
 1cc:	e58d3000 	str	r3, [sp]
 1d0:	e3a03000 	mov	r3, #0
 1d4:	e3a02000 	mov	r2, #0
 1d8:	e3a01005 	mov	r1, #5
 1dc:	e59f0140 	ldr	r0, [pc, #320]	; 0x324
 1e0:	ebffffc8 	bl	0x108
 1e4:	e3a030b0 	mov	r3, #176	; 0xb0
 1e8:	e58d3004 	str	r3, [sp, #4]
 1ec:	e59f312c 	ldr	r3, [pc, #300]	; 0x320
 1f0:	e58d3000 	str	r3, [sp]
 1f4:	e3a03000 	mov	r3, #0
 1f8:	e3a02000 	mov	r2, #0
 1fc:	e3a01005 	mov	r1, #5
 200:	e59f011c 	ldr	r0, [pc, #284]	; 0x324
 204:	ebffffd9 	bl	0x170
 208:	e3a03000 	mov	r3, #0
 20c:	e58d3004 	str	r3, [sp, #4]
 210:	e59f3110 	ldr	r3, [pc, #272]	; 0x328
 214:	e58d3000 	str	r3, [sp]
 218:	e3a03000 	mov	r3, #0
 21c:	e3a02000 	mov	r2, #0
 220:	e3a01005 	mov	r1, #5
 224:	e59f0100 	ldr	r0, [pc, #256]	; 0x32c
 228:	ebffffb6 	bl	0x108
 22c:	e3a030b0 	mov	r3, #176	; 0xb0
 230:	e58d3004 	str	r3, [sp, #4]
 234:	e59f30ec 	ldr	r3, [pc, #236]	; 0x328
 238:	e58d3000 	str	r3, [sp]
 23c:	e3a03000 	mov	r3, #0
 240:	e3a02000 	mov	r2, #0
 244:	e3a01005 	mov	r1, #5
 248:	e59f00dc 	ldr	r0, [pc, #220]	; 0x32c
 24c:	ebffffc7 	bl	0x170
 250:	e3a03000 	mov	r3, #0
 254:	e58d3004 	str	r3, [sp, #4]
 258:	e59f30d0 	ldr	r3, [pc, #208]	; 0x330
 25c:	e58d3000 	str	r3, [sp]
 260:	e3a03000 	mov	r3, #0
 264:	e3a02000 	mov	r2, #0
 268:	e3a01005 	mov	r1, #5
 26c:	e59f00c0 	ldr	r0, [pc, #192]	; 0x334
 270:	ebffffa4 	bl	0x108
 274:	e3a030b0 	mov	r3, #176	; 0xb0
 278:	e58d3004 	str	r3, [sp, #4]
 27c:	e59f30ac 	ldr	r3, [pc, #172]	; 0x330
 280:	e58d3000 	str	r3, [sp]
 284:	e3a03000 	mov	r3, #0
 288:	e3a02000 	mov	r2, #0
 28c:	e3a01005 	mov	r1, #5
 290:	e59f009c 	ldr	r0, [pc, #156]	; 0x334
 294:	ebffffb5 	bl	0x170
 298:	e59f2098 	ldr	r2, [pc, #152]	; 0x338
 29c:	e59f3094 	ldr	r3, [pc, #148]	; 0x338
 2a0:	e5933004 	ldr	r3, [r3, #4]
 2a4:	e3833010 	orr	r3, r3, #16
 2a8:	e5823004 	str	r3, [r2, #4]
 2ac:	e59f2084 	ldr	r2, [pc, #132]	; 0x338
 2b0:	e59f3080 	ldr	r3, [pc, #128]	; 0x338
 2b4:	e5933000 	ldr	r3, [r3]
 2b8:	e3833010 	orr	r3, r3, #16
 2bc:	e5823000 	str	r3, [r2]
 2c0:	e59f2074 	ldr	r2, [pc, #116]	; 0x33c
 2c4:	e59f3070 	ldr	r3, [pc, #112]	; 0x33c
 2c8:	e5933004 	ldr	r3, [r3, #4]
 2cc:	e3833601 	orr	r3, r3, #1048576	; 0x100000
 2d0:	e5823004 	str	r3, [r2, #4]
 2d4:	e59f2060 	ldr	r2, [pc, #96]	; 0x33c
 2d8:	e59f305c 	ldr	r3, [pc, #92]	; 0x33c
 2dc:	e5933000 	ldr	r3, [r3]
 2e0:	e3833601 	orr	r3, r3, #1048576	; 0x100000
 2e4:	e5823000 	str	r3, [r2]
 2e8:	e59f204c 	ldr	r2, [pc, #76]	; 0x33c
 2ec:	e59f3048 	ldr	r3, [pc, #72]	; 0x33c
 2f0:	e5933004 	ldr	r3, [r3, #4]
 2f4:	e3833702 	orr	r3, r3, #524288	; 0x80000
 2f8:	e5823004 	str	r3, [r2, #4]
 2fc:	e59f2038 	ldr	r2, [pc, #56]	; 0x33c
 300:	e59f3034 	ldr	r3, [pc, #52]	; 0x33c
 304:	e5933000 	ldr	r3, [r3]
 308:	e3833702 	orr	r3, r3, #524288	; 0x80000
 30c:	e5823000 	str	r3, [r2]
 310:	e1a00000 	nop			; (mov r0, r0)
 314:	e24bd004 	sub	sp, fp, #4
 318:	e8bd4800 	pop	{fp, lr}
 31c:	e12fff1e 	bx	lr
 320:	020e02f8 	andeq	r0, lr, #248, 4	; 0x8000000f
 324:	020e006c 	andeq	r0, lr, #108	; 0x6c
 328:	020e046c 	andeq	r0, lr, #108, 8	; 0x6c000000
 32c:	020e01e0 	andeq	r0, lr, #224, 2	; 0x38
 330:	020e0468 	andeq	r0, lr, #104, 8	; 0x68000000
 334:	020e01dc 	andeq	r0, lr, #220, 2	; 0x37
 338:	0209c000 	andeq	ip, r9, #0
 33c:	020a8000 	andeq	r8, sl, #0
 340:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
 344:	e28db000 	add	fp, sp, #0
 348:	e24dd014 	sub	sp, sp, #20
 34c:	e50b0010 	str	r0, [fp, #-16]
 350:	e3a03000 	mov	r3, #0
 354:	e50b3008 	str	r3, [fp, #-8]
 358:	e3a03000 	mov	r3, #0
 35c:	e50b3008 	str	r3, [fp, #-8]
 360:	ea000003 	b	0x374
 364:	e1a00000 	nop			; (mov r0, r0)
 368:	e51b3008 	ldr	r3, [fp, #-8]
 36c:	e2833001 	add	r3, r3, #1
 370:	e50b3008 	str	r3, [fp, #-8]
 374:	e51b2008 	ldr	r2, [fp, #-8]
 378:	e51b3010 	ldr	r3, [fp, #-16]
 37c:	e1520003 	cmp	r2, r3
 380:	3afffff7 	bcc	0x364
 384:	e1a00000 	nop			; (mov r0, r0)
 388:	e28bd000 	add	sp, fp, #0
 38c:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
 390:	e12fff1e 	bx	lr
 394:	e92d4800 	push	{fp, lr}
 398:	e28db004 	add	fp, sp, #4
 39c:	e24dd008 	sub	sp, sp, #8
 3a0:	e3a03000 	mov	r3, #0
 3a4:	e50b3008 	str	r3, [fp, #-8]
 3a8:	ebffff81 	bl	0x1b4
 3ac:	eb00007e 	bl	0x5ac
 3b0:	e59f3060 	ldr	r3, [pc, #96]	; 0x418
 3b4:	e5d33000 	ldrb	r3, [r3]
 3b8:	e3530000 	cmp	r3, #0
 3bc:	0a00000a 	beq	0x3ec
 3c0:	e59f2054 	ldr	r2, [pc, #84]	; 0x41c
 3c4:	e59f3050 	ldr	r3, [pc, #80]	; 0x41c
 3c8:	e5933000 	ldr	r3, [r3]
 3cc:	e3833010 	orr	r3, r3, #16
 3d0:	e5823000 	str	r3, [r2]
 3d4:	e59f2044 	ldr	r2, [pc, #68]	; 0x420
 3d8:	e59f3040 	ldr	r3, [pc, #64]	; 0x420
 3dc:	e5933000 	ldr	r3, [r3]
 3e0:	e3c33601 	bic	r3, r3, #1048576	; 0x100000
 3e4:	e5823000 	str	r3, [r2]
 3e8:	eafffff0 	b	0x3b0
 3ec:	e59f202c 	ldr	r2, [pc, #44]	; 0x420
 3f0:	e59f3028 	ldr	r3, [pc, #40]	; 0x420
 3f4:	e5933000 	ldr	r3, [r3]
 3f8:	e3833601 	orr	r3, r3, #1048576	; 0x100000
 3fc:	e5823000 	str	r3, [r2]
 400:	e59f2014 	ldr	r2, [pc, #20]	; 0x41c
 404:	e59f3010 	ldr	r3, [pc, #16]	; 0x41c
 408:	e5933000 	ldr	r3, [r3]
 40c:	e3c33010 	bic	r3, r3, #16
 410:	e5823000 	str	r3, [r2]
 414:	eaffffe5 	b	0x3b0
 418:	80001c30 	andhi	r1, r0, r0, lsr ip
 41c:	0209c000 	andeq	ip, r9, #0
 420:	020a8000 	andeq	r8, sl, #0
 424:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
 428:	e28db000 	add	fp, sp, #0
 42c:	e24dd014 	sub	sp, sp, #20
 430:	e50b0008 	str	r0, [fp, #-8]
 434:	e50b100c 	str	r1, [fp, #-12]
 438:	e50b2010 	str	r2, [fp, #-16]
 43c:	e50b3014 	str	r3, [fp, #-20]	; 0xffffffec
 440:	e51b3008 	ldr	r3, [fp, #-8]
 444:	e51b200c 	ldr	r2, [fp, #-12]
 448:	e202100f 	and	r1, r2, #15
 44c:	e59b2008 	ldr	r2, [fp, #8]
 450:	e1a02202 	lsl	r2, r2, #4
 454:	e2022010 	and	r2, r2, #16
 458:	e1812002 	orr	r2, r1, r2
 45c:	e5832000 	str	r2, [r3]
 460:	e51b3010 	ldr	r3, [fp, #-16]
 464:	e3530000 	cmp	r3, #0
 468:	0a000003 	beq	0x47c
 46c:	e51b3010 	ldr	r3, [fp, #-16]
 470:	e51b2014 	ldr	r2, [fp, #-20]	; 0xffffffec
 474:	e2022007 	and	r2, r2, #7
 478:	e5832000 	str	r2, [r3]
 47c:	e1a00000 	nop			; (mov r0, r0)
 480:	e28bd000 	add	sp, fp, #0
 484:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
 488:	e12fff1e 	bx	lr
 48c:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
 490:	e28db000 	add	fp, sp, #0
 494:	e24dd014 	sub	sp, sp, #20
 498:	e50b0008 	str	r0, [fp, #-8]
 49c:	e50b100c 	str	r1, [fp, #-12]
 4a0:	e50b2010 	str	r2, [fp, #-16]
 4a4:	e50b3014 	str	r3, [fp, #-20]	; 0xffffffec
 4a8:	e59b3004 	ldr	r3, [fp, #4]
 4ac:	e3530000 	cmp	r3, #0
 4b0:	0a000002 	beq	0x4c0
 4b4:	e59b3004 	ldr	r3, [fp, #4]
 4b8:	e59b2008 	ldr	r2, [fp, #8]
 4bc:	e5832000 	str	r2, [r3]
 4c0:	e1a00000 	nop			; (mov r0, r0)
 4c4:	e28bd000 	add	sp, fp, #0
 4c8:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
 4cc:	e12fff1e 	bx	lr
 4d0:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
 4d4:	e28db000 	add	fp, sp, #0
 4d8:	e24dd014 	sub	sp, sp, #20
 4dc:	e50b0010 	str	r0, [fp, #-16]
 4e0:	e3a03000 	mov	r3, #0
 4e4:	e50b3008 	str	r3, [fp, #-8]
 4e8:	e3a03000 	mov	r3, #0
 4ec:	e50b3008 	str	r3, [fp, #-8]
 4f0:	ea000003 	b	0x504
 4f4:	e1a00000 	nop			; (mov r0, r0)
 4f8:	e51b3008 	ldr	r3, [fp, #-8]
 4fc:	e2833001 	add	r3, r3, #1
 500:	e50b3008 	str	r3, [fp, #-8]
 504:	e51b2008 	ldr	r2, [fp, #-8]
 508:	e51b3010 	ldr	r3, [fp, #-16]
 50c:	e1520003 	cmp	r2, r3
 510:	3afffff7 	bcc	0x4f4
 514:	e1a00000 	nop			; (mov r0, r0)
 518:	e28bd000 	add	sp, fp, #0
 51c:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
 520:	e12fff1e 	bx	lr
 524:	e92d4800 	push	{fp, lr}
 528:	e28db004 	add	fp, sp, #4
 52c:	e24dd008 	sub	sp, sp, #8
 530:	e3a03000 	mov	r3, #0
 534:	e58d3004 	str	r3, [sp, #4]
 538:	e59f305c 	ldr	r3, [pc, #92]	; 0x59c
 53c:	e58d3000 	str	r3, [sp]
 540:	e3a03000 	mov	r3, #0
 544:	e3a02000 	mov	r2, #0
 548:	e3a01005 	mov	r1, #5
 54c:	e59f004c 	ldr	r0, [pc, #76]	; 0x5a0
 550:	ebffffb3 	bl	0x424
 554:	e59f3048 	ldr	r3, [pc, #72]	; 0x5a4
 558:	e58d3004 	str	r3, [sp, #4]
 55c:	e59f3038 	ldr	r3, [pc, #56]	; 0x59c
 560:	e58d3000 	str	r3, [sp]
 564:	e3a03000 	mov	r3, #0
 568:	e3a02000 	mov	r2, #0
 56c:	e3a01005 	mov	r1, #5
 570:	e59f0028 	ldr	r0, [pc, #40]	; 0x5a0
 574:	ebffffc4 	bl	0x48c
 578:	e59f2028 	ldr	r2, [pc, #40]	; 0x5a8
 57c:	e59f3024 	ldr	r3, [pc, #36]	; 0x5a8
 580:	e5933004 	ldr	r3, [r3, #4]
 584:	e3c33002 	bic	r3, r3, #2
 588:	e5823004 	str	r3, [r2, #4]
 58c:	e1a00000 	nop			; (mov r0, r0)
 590:	e24bd004 	sub	sp, fp, #4
 594:	e8bd4800 	pop	{fp, lr}
 598:	e12fff1e 	bx	lr
 59c:	02290050 	eoreq	r0, r9, #80	; 0x50
 5a0:	0229000c 	eoreq	r0, r9, #12
 5a4:	000100b0 	strheq	r0, [r1], -r0	; <UNPREDICTABLE>
 5a8:	020ac000 	andeq	ip, sl, #0
 5ac:	e92d4800 	push	{fp, lr}
 5b0:	e28db004 	add	fp, sp, #4
 5b4:	e24dd020 	sub	sp, sp, #32
 5b8:	e3a03001 	mov	r3, #1
 5bc:	e50b3008 	str	r3, [fp, #-8]
 5c0:	e3a02000 	mov	r2, #0
 5c4:	e59f1134 	ldr	r1, [pc, #308]	; 0x700
 5c8:	e3a0006a 	mov	r0, #106	; 0x6a
 5cc:	eb000152 	bl	0xb1c
 5d0:	e3a0306a 	mov	r3, #106	; 0x6a
 5d4:	e14b30be 	strh	r3, [fp, #-14]
 5d8:	ee9f3f10 	mrc	15, 4, r3, cr15, cr0, {0}
 5dc:	e50b3014 	str	r3, [fp, #-20]	; 0xffffffec
 5e0:	e51b3014 	ldr	r3, [fp, #-20]	; 0xffffffec
 5e4:	e1a03823 	lsr	r3, r3, #16
 5e8:	e1a03803 	lsl	r3, r3, #16
 5ec:	e50b3018 	str	r3, [fp, #-24]	; 0xffffffe8
 5f0:	e15b30fe 	ldrsh	r3, [fp, #-14]
 5f4:	e1a022a3 	lsr	r2, r3, #5
 5f8:	e15b30be 	ldrh	r3, [fp, #-14]
 5fc:	e203301f 	and	r3, r3, #31
 600:	e3a01001 	mov	r1, #1
 604:	e1a01311 	lsl	r1, r1, r3
 608:	e51b3018 	ldr	r3, [fp, #-24]	; 0xffffffe8
 60c:	e2822d11 	add	r2, r2, #1088	; 0x440
 610:	e7831102 	str	r1, [r3, r2, lsl #2]
 614:	e3a03000 	mov	r3, #0
 618:	e58d3004 	str	r3, [sp, #4]
 61c:	e59f30e0 	ldr	r3, [pc, #224]	; 0x704
 620:	e58d3000 	str	r3, [sp]
 624:	e3a03000 	mov	r3, #0
 628:	e3a02000 	mov	r2, #0
 62c:	e3a01005 	mov	r1, #5
 630:	e59f00d0 	ldr	r0, [pc, #208]	; 0x708
 634:	ebffff7a 	bl	0x424
 638:	e59f30cc 	ldr	r3, [pc, #204]	; 0x70c
 63c:	e58d3004 	str	r3, [sp, #4]
 640:	e59f30bc 	ldr	r3, [pc, #188]	; 0x704
 644:	e58d3000 	str	r3, [sp]
 648:	e3a03000 	mov	r3, #0
 64c:	e3a02000 	mov	r2, #0
 650:	e3a01005 	mov	r1, #5
 654:	e59f00ac 	ldr	r0, [pc, #172]	; 0x708
 658:	ebffff8b 	bl	0x48c
 65c:	e59f20ac 	ldr	r2, [pc, #172]	; 0x710
 660:	e59f30a8 	ldr	r3, [pc, #168]	; 0x710
 664:	e5933014 	ldr	r3, [r3, #20]
 668:	e3c33002 	bic	r3, r3, #2
 66c:	e5823014 	str	r3, [r2, #20]
 670:	e59f2098 	ldr	r2, [pc, #152]	; 0x710
 674:	e59f3094 	ldr	r3, [pc, #148]	; 0x710
 678:	e5933004 	ldr	r3, [r3, #4]
 67c:	e3c33002 	bic	r3, r3, #2
 680:	e5823004 	str	r3, [r2, #4]
 684:	e59f2084 	ldr	r2, [pc, #132]	; 0x710
 688:	e59f3080 	ldr	r3, [pc, #128]	; 0x710
 68c:	e593301c 	ldr	r3, [r3, #28]
 690:	e3c33002 	bic	r3, r3, #2
 694:	e582301c 	str	r3, [r2, #28]
 698:	e59f3074 	ldr	r3, [pc, #116]	; 0x714
 69c:	e50b300c 	str	r3, [fp, #-12]
 6a0:	e51b300c 	ldr	r3, [fp, #-12]
 6a4:	e5932000 	ldr	r2, [r3]
 6a8:	e51b3008 	ldr	r3, [fp, #-8]
 6ac:	e1a03083 	lsl	r3, r3, #1
 6b0:	e3a01003 	mov	r1, #3
 6b4:	e1a03311 	lsl	r3, r1, r3
 6b8:	e1e03003 	mvn	r3, r3
 6bc:	e0022003 	and	r2, r2, r3
 6c0:	e51b3008 	ldr	r3, [fp, #-8]
 6c4:	e1a03083 	lsl	r3, r3, #1
 6c8:	e3a01002 	mov	r1, #2
 6cc:	e1a03311 	lsl	r3, r1, r3
 6d0:	e1822003 	orr	r2, r2, r3
 6d4:	e51b300c 	ldr	r3, [fp, #-12]
 6d8:	e5832000 	str	r2, [r3]
 6dc:	e59f202c 	ldr	r2, [pc, #44]	; 0x710
 6e0:	e59f3028 	ldr	r3, [pc, #40]	; 0x710
 6e4:	e5933014 	ldr	r3, [r3, #20]
 6e8:	e3833002 	orr	r3, r3, #2
 6ec:	e5823014 	str	r3, [r2, #20]
 6f0:	e1a00000 	nop			; (mov r0, r0)
 6f4:	e24bd004 	sub	sp, fp, #4
 6f8:	e8bd4800 	pop	{fp, lr}
 6fc:	e12fff1e 	bx	lr
 700:	80001770 	andhi	r1, r0, r0, ror r7
 704:	02290050 	eoreq	r0, r9, #80	; 0x50
 708:	0229000c 	eoreq	r0, r9, #12
 70c:	000100b0 	strheq	r0, [r1], -r0	; <UNPREDICTABLE>
 710:	020ac000 	andeq	ip, sl, #0
 714:	020ac00c 	andeq	ip, sl, #12
 718:	e92d4800 	push	{fp, lr}
 71c:	e28db004 	add	fp, sp, #4
 720:	e59f3044 	ldr	r3, [pc, #68]	; 0x76c
 724:	e5933000 	ldr	r3, [r3]
 728:	e2033002 	and	r3, r3, #2
 72c:	e3530000 	cmp	r3, #0
 730:	0a000008 	beq	0x758
 734:	e3a000ff 	mov	r0, #255	; 0xff
 738:	ebffff64 	bl	0x4d0
 73c:	e59f3028 	ldr	r3, [pc, #40]	; 0x76c
 740:	e5933000 	ldr	r3, [r3]
 744:	e2033002 	and	r3, r3, #2
 748:	e3530000 	cmp	r3, #0
 74c:	0a000001 	beq	0x758
 750:	e3a03001 	mov	r3, #1
 754:	ea000000 	b	0x75c
 758:	e3a03000 	mov	r3, #0
 75c:	e1a00003 	mov	r0, r3
 760:	e24bd004 	sub	sp, fp, #4
 764:	e8bd4800 	pop	{fp, lr}
 768:	e12fff1e 	bx	lr
 76c:	020ac000 	andeq	ip, sl, #0
 770:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
 774:	e28db000 	add	fp, sp, #0
 778:	e59f3040 	ldr	r3, [pc, #64]	; 0x7c0
 77c:	e3a02002 	mov	r2, #2
 780:	e5832018 	str	r2, [r3, #24]
 784:	e59f3038 	ldr	r3, [pc, #56]	; 0x7c4
 788:	e5d33000 	ldrb	r3, [r3]
 78c:	e3530000 	cmp	r3, #0
 790:	0a000003 	beq	0x7a4
 794:	e59f3028 	ldr	r3, [pc, #40]	; 0x7c4
 798:	e3a02000 	mov	r2, #0
 79c:	e5c32000 	strb	r2, [r3]
 7a0:	ea000002 	b	0x7b0
 7a4:	e59f3018 	ldr	r3, [pc, #24]	; 0x7c4
 7a8:	e3a02001 	mov	r2, #1
 7ac:	e5c32000 	strb	r2, [r3]
 7b0:	e1a00000 	nop			; (mov r0, r0)
 7b4:	e28bd000 	add	sp, fp, #0
 7b8:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
 7bc:	e12fff1e 	bx	lr
 7c0:	020ac000 	andeq	ip, sl, #0
 7c4:	80001c30 	andhi	r1, r0, r0, lsr ip
 7c8:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
 7cc:	e28db000 	add	fp, sp, #0
 7d0:	e24dd06c 	sub	sp, sp, #108	; 0x6c
 7d4:	e3a03000 	mov	r3, #0
 7d8:	ee073f15 	mcr	15, 0, r3, cr7, cr5, {0}
 7dc:	e3a03000 	mov	r3, #0
 7e0:	ee073fd5 	mcr	15, 0, r3, cr7, cr5, {6}
 7e4:	e3a03002 	mov	r3, #2
 7e8:	e50b3034 	str	r3, [fp, #-52]	; 0xffffffcc
 7ec:	ee303f30 	mrc	15, 1, r3, cr0, cr0, {1}
 7f0:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
 7f4:	e51b3038 	ldr	r3, [fp, #-56]	; 0xffffffc8
 7f8:	e50b303c 	str	r3, [fp, #-60]	; 0xffffffc4
 7fc:	e51b303c 	ldr	r3, [fp, #-60]	; 0xffffffc4
 800:	e1a03c23 	lsr	r3, r3, #24
 804:	e2033007 	and	r3, r3, #7
 808:	e50b3040 	str	r3, [fp, #-64]	; 0xffffffc0
 80c:	e3a03000 	mov	r3, #0
 810:	e50b3044 	str	r3, [fp, #-68]	; 0xffffffbc
 814:	ea00006a 	b	0x9c4
 818:	e51b2044 	ldr	r2, [fp, #-68]	; 0xffffffbc
 81c:	e1a03002 	mov	r3, r2
 820:	e1a03083 	lsl	r3, r3, #1
 824:	e0833002 	add	r3, r3, r2
 828:	e51b203c 	ldr	r2, [fp, #-60]	; 0xffffffc4
 82c:	e1a03332 	lsr	r3, r2, r3
 830:	e2033007 	and	r3, r3, #7
 834:	e50b3048 	str	r3, [fp, #-72]	; 0xffffffb8
 838:	e51b3048 	ldr	r3, [fp, #-72]	; 0xffffffb8
 83c:	e3530002 	cmp	r3, #2
 840:	0a000005 	beq	0x85c
 844:	e51b3048 	ldr	r3, [fp, #-72]	; 0xffffffb8
 848:	e3530003 	cmp	r3, #3
 84c:	0a000002 	beq	0x85c
 850:	e51b3048 	ldr	r3, [fp, #-72]	; 0xffffffb8
 854:	e3530004 	cmp	r3, #4
 858:	1a000056 	bne	0x9b8
 85c:	e51b3044 	ldr	r3, [fp, #-68]	; 0xffffffbc
 860:	e1a03083 	lsl	r3, r3, #1
 864:	ee403f10 	mcr	15, 2, r3, cr0, cr0, {0}
 868:	ee303f10 	mrc	15, 1, r3, cr0, cr0, {0}
 86c:	e50b304c 	str	r3, [fp, #-76]	; 0xffffffb4
 870:	e51b304c 	ldr	r3, [fp, #-76]	; 0xffffffb4
 874:	e50b3050 	str	r3, [fp, #-80]	; 0xffffffb0
 878:	e51b3050 	ldr	r3, [fp, #-80]	; 0xffffffb0
 87c:	e1a036a3 	lsr	r3, r3, #13
 880:	e1a03883 	lsl	r3, r3, #17
 884:	e1a038a3 	lsr	r3, r3, #17
 888:	e2833001 	add	r3, r3, #1
 88c:	e50b3054 	str	r3, [fp, #-84]	; 0xffffffac
 890:	e51b3050 	ldr	r3, [fp, #-80]	; 0xffffffb0
 894:	e1a031a3 	lsr	r3, r3, #3
 898:	e1a03b03 	lsl	r3, r3, #22
 89c:	e1a03b23 	lsr	r3, r3, #22
 8a0:	e2833001 	add	r3, r3, #1
 8a4:	e50b3058 	str	r3, [fp, #-88]	; 0xffffffa8
 8a8:	e51b3050 	ldr	r3, [fp, #-80]	; 0xffffffb0
 8ac:	e2033007 	and	r3, r3, #7
 8b0:	e2833004 	add	r3, r3, #4
 8b4:	e50b305c 	str	r3, [fp, #-92]	; 0xffffffa4
 8b8:	e3a03001 	mov	r3, #1
 8bc:	e50b3060 	str	r3, [fp, #-96]	; 0xffffffa0
 8c0:	ea000002 	b	0x8d0
 8c4:	e51b3060 	ldr	r3, [fp, #-96]	; 0xffffffa0
 8c8:	e2833001 	add	r3, r3, #1
 8cc:	e50b3060 	str	r3, [fp, #-96]	; 0xffffffa0
 8d0:	e51b3060 	ldr	r3, [fp, #-96]	; 0xffffffa0
 8d4:	e3530009 	cmp	r3, #9
 8d8:	8a000005 	bhi	0x8f4
 8dc:	e3a02001 	mov	r2, #1
 8e0:	e51b3060 	ldr	r3, [fp, #-96]	; 0xffffffa0
 8e4:	e1a03312 	lsl	r3, r2, r3
 8e8:	e51b2058 	ldr	r2, [fp, #-88]	; 0xffffffa8
 8ec:	e1520003 	cmp	r2, r3
 8f0:	8afffff3 	bhi	0x8c4
 8f4:	e51b3060 	ldr	r3, [fp, #-96]	; 0xffffffa0
 8f8:	e2633020 	rsb	r3, r3, #32
 8fc:	e50b3064 	str	r3, [fp, #-100]	; 0xffffff9c
 900:	e3a03000 	mov	r3, #0
 904:	e50b3060 	str	r3, [fp, #-96]	; 0xffffffa0
 908:	ea000026 	b	0x9a8
 90c:	e3a03000 	mov	r3, #0
 910:	e50b3068 	str	r3, [fp, #-104]	; 0xffffff98
 914:	ea00001c 	b	0x98c
 918:	e51b2060 	ldr	r2, [fp, #-96]	; 0xffffffa0
 91c:	e51b3064 	ldr	r3, [fp, #-100]	; 0xffffff9c
 920:	e1a02312 	lsl	r2, r2, r3
 924:	e51b1068 	ldr	r1, [fp, #-104]	; 0xffffff98
 928:	e51b305c 	ldr	r3, [fp, #-92]	; 0xffffffa4
 92c:	e1a03311 	lsl	r3, r1, r3
 930:	e1822003 	orr	r2, r2, r3
 934:	e51b3044 	ldr	r3, [fp, #-68]	; 0xffffffbc
 938:	e1a03083 	lsl	r3, r3, #1
 93c:	e1823003 	orr	r3, r2, r3
 940:	e50b306c 	str	r3, [fp, #-108]	; 0xffffff94
 944:	e51b3034 	ldr	r3, [fp, #-52]	; 0xffffffcc
 948:	e3530002 	cmp	r3, #2
 94c:	0a000006 	beq	0x96c
 950:	e3530003 	cmp	r3, #3
 954:	0a000007 	beq	0x978
 958:	e3530001 	cmp	r3, #1
 95c:	1a000007 	bne	0x980
 960:	e51b306c 	ldr	r3, [fp, #-108]	; 0xffffff94
 964:	ee073f5a 	mcr	15, 0, r3, cr7, cr10, {2}
 968:	ea000004 	b	0x980
 96c:	e51b306c 	ldr	r3, [fp, #-108]	; 0xffffff94
 970:	ee073f56 	mcr	15, 0, r3, cr7, cr6, {2}
 974:	ea000001 	b	0x980
 978:	e51b306c 	ldr	r3, [fp, #-108]	; 0xffffff94
 97c:	ee073f5e 	mcr	15, 0, r3, cr7, cr14, {2}
 980:	e51b3068 	ldr	r3, [fp, #-104]	; 0xffffff98
 984:	e2833001 	add	r3, r3, #1
 988:	e50b3068 	str	r3, [fp, #-104]	; 0xffffff98
 98c:	e51b2054 	ldr	r2, [fp, #-84]	; 0xffffffac
 990:	e51b3068 	ldr	r3, [fp, #-104]	; 0xffffff98
 994:	e1520003 	cmp	r2, r3
 998:	8affffde 	bhi	0x918
 99c:	e51b3060 	ldr	r3, [fp, #-96]	; 0xffffffa0
 9a0:	e2833001 	add	r3, r3, #1
 9a4:	e50b3060 	str	r3, [fp, #-96]	; 0xffffffa0
 9a8:	e51b2058 	ldr	r2, [fp, #-88]	; 0xffffffa8
 9ac:	e51b3060 	ldr	r3, [fp, #-96]	; 0xffffffa0
 9b0:	e1520003 	cmp	r2, r3
 9b4:	8affffd4 	bhi	0x90c
 9b8:	e51b3044 	ldr	r3, [fp, #-68]	; 0xffffffbc
 9bc:	e2833001 	add	r3, r3, #1
 9c0:	e50b3044 	str	r3, [fp, #-68]	; 0xffffffbc
 9c4:	e51b2040 	ldr	r2, [fp, #-64]	; 0xffffffc0
 9c8:	e51b3044 	ldr	r3, [fp, #-68]	; 0xffffffbc
 9cc:	e1520003 	cmp	r2, r3
 9d0:	8affff90 	bhi	0x818
 9d4:	ee113f30 	mrc	15, 0, r3, cr1, cr0, {1}
 9d8:	e50b3030 	str	r3, [fp, #-48]	; 0xffffffd0
 9dc:	e51b3030 	ldr	r3, [fp, #-48]	; 0xffffffd0
 9e0:	e50b3008 	str	r3, [fp, #-8]
 9e4:	e51b3008 	ldr	r3, [fp, #-8]
 9e8:	e3833040 	orr	r3, r3, #64	; 0x40
 9ec:	e50b3008 	str	r3, [fp, #-8]
 9f0:	e51b3008 	ldr	r3, [fp, #-8]
 9f4:	e50b302c 	str	r3, [fp, #-44]	; 0xffffffd4
 9f8:	e51b302c 	ldr	r3, [fp, #-44]	; 0xffffffd4
 9fc:	ee013f30 	mcr	15, 0, r3, cr1, cr0, {1}
 a00:	ee113f10 	mrc	15, 0, r3, cr1, cr0, {0}
 a04:	e50b3028 	str	r3, [fp, #-40]	; 0xffffffd8
 a08:	e51b3028 	ldr	r3, [fp, #-40]	; 0xffffffd8
 a0c:	e50b300c 	str	r3, [fp, #-12]
 a10:	e51b300c 	ldr	r3, [fp, #-12]
 a14:	e3c33b0e 	bic	r3, r3, #14336	; 0x3800
 a18:	e3c33027 	bic	r3, r3, #39	; 0x27
 a1c:	e3833b06 	orr	r3, r3, #6144	; 0x1800
 a20:	e3833024 	orr	r3, r3, #36	; 0x24
 a24:	e50b300c 	str	r3, [fp, #-12]
 a28:	e51b300c 	ldr	r3, [fp, #-12]
 a2c:	e50b3024 	str	r3, [fp, #-36]	; 0xffffffdc
 a30:	e51b3024 	ldr	r3, [fp, #-36]	; 0xffffffdc
 a34:	ee013f10 	mcr	15, 0, r3, cr1, cr0, {0}
 a38:	ee9f3f10 	mrc	15, 4, r3, cr15, cr0, {0}
 a3c:	e50b3014 	str	r3, [fp, #-20]	; 0xffffffec
 a40:	e51b3014 	ldr	r3, [fp, #-20]	; 0xffffffec
 a44:	e1a03823 	lsr	r3, r3, #16
 a48:	e1a03803 	lsl	r3, r3, #16
 a4c:	e50b3018 	str	r3, [fp, #-24]	; 0xffffffe8
 a50:	e51b3018 	ldr	r3, [fp, #-24]	; 0xffffffe8
 a54:	e2833a01 	add	r3, r3, #4096	; 0x1000
 a58:	e5933004 	ldr	r3, [r3, #4]
 a5c:	e203301f 	and	r3, r3, #31
 a60:	e2833001 	add	r3, r3, #1
 a64:	e50b301c 	str	r3, [fp, #-28]	; 0xffffffe4
 a68:	e3a03000 	mov	r3, #0
 a6c:	e50b3020 	str	r3, [fp, #-32]	; 0xffffffe0
 a70:	ea000007 	b	0xa94
 a74:	e51b3018 	ldr	r3, [fp, #-24]	; 0xffffffe8
 a78:	e51b2020 	ldr	r2, [fp, #-32]	; 0xffffffe0
 a7c:	e2822e46 	add	r2, r2, #1120	; 0x460
 a80:	e3e01000 	mvn	r1, #0
 a84:	e7831102 	str	r1, [r3, r2, lsl #2]
 a88:	e51b3020 	ldr	r3, [fp, #-32]	; 0xffffffe0
 a8c:	e2833001 	add	r3, r3, #1
 a90:	e50b3020 	str	r3, [fp, #-32]	; 0xffffffe0
 a94:	e51b201c 	ldr	r2, [fp, #-28]	; 0xffffffe4
 a98:	e51b3020 	ldr	r3, [fp, #-32]	; 0xffffffe0
 a9c:	e1520003 	cmp	r2, r3
 aa0:	8afffff3 	bhi	0xa74
 aa4:	e51b3018 	ldr	r3, [fp, #-24]	; 0xffffffe8
 aa8:	e2833a02 	add	r3, r3, #8192	; 0x2000
 aac:	e1a02003 	mov	r2, r3
 ab0:	e3a030f8 	mov	r3, #248	; 0xf8
 ab4:	e5823004 	str	r3, [r2, #4]
 ab8:	e51b3018 	ldr	r3, [fp, #-24]	; 0xffffffe8
 abc:	e2833a02 	add	r3, r3, #8192	; 0x2000
 ac0:	e1a02003 	mov	r2, r3
 ac4:	e3a03002 	mov	r3, #2
 ac8:	e5823008 	str	r3, [r2, #8]
 acc:	e51b3018 	ldr	r3, [fp, #-24]	; 0xffffffe8
 ad0:	e2833a01 	add	r3, r3, #4096	; 0x1000
 ad4:	e1a02003 	mov	r2, r3
 ad8:	e3a03001 	mov	r3, #1
 adc:	e5823000 	str	r3, [r2]
 ae0:	e51b3018 	ldr	r3, [fp, #-24]	; 0xffffffe8
 ae4:	e2833a02 	add	r3, r3, #8192	; 0x2000
 ae8:	e1a02003 	mov	r2, r3
 aec:	e3a03001 	mov	r3, #1
 af0:	e5823000 	str	r3, [r2]
 af4:	e59f301c 	ldr	r3, [pc, #28]	; 0xb18
 af8:	e5933000 	ldr	r3, [r3]
 afc:	e50b3010 	str	r3, [fp, #-16]
 b00:	e51b3010 	ldr	r3, [fp, #-16]
 b04:	ee0c3f10 	mcr	15, 0, r3, cr12, cr0, {0}
 b08:	e1a00000 	nop			; (mov r0, r0)
 b0c:	e28bd000 	add	sp, fp, #0
 b10:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
 b14:	e12fff1e 	bx	lr
 b18:	80001c28 	andhi	r1, r0, r8, lsr #24
 b1c:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
 b20:	e28db000 	add	fp, sp, #0
 b24:	e24dd014 	sub	sp, sp, #20
 b28:	e1a03000 	mov	r3, r0
 b2c:	e50b100c 	str	r1, [fp, #-12]
 b30:	e50b2010 	str	r2, [fp, #-16]
 b34:	e14b30b6 	strh	r3, [fp, #-6]
 b38:	e15b30f6 	ldrsh	r3, [fp, #-6]
 b3c:	e59f102c 	ldr	r1, [pc, #44]	; 0xb70
 b40:	e51b200c 	ldr	r2, [fp, #-12]
 b44:	e7812183 	str	r2, [r1, r3, lsl #3]
 b48:	e15b30f6 	ldrsh	r3, [fp, #-6]
 b4c:	e59f201c 	ldr	r2, [pc, #28]	; 0xb70
 b50:	e1a03183 	lsl	r3, r3, #3
 b54:	e0823003 	add	r3, r2, r3
 b58:	e51b2010 	ldr	r2, [fp, #-16]
 b5c:	e5832004 	str	r2, [r3, #4]
 b60:	e1a00000 	nop			; (mov r0, r0)
 b64:	e28bd000 	add	sp, fp, #0
 b68:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
 b6c:	e12fff1e 	bx	lr
 b70:	80001c34 	andhi	r1, r0, r4, lsr ip
 b74:	e92d4800 	push	{fp, lr}
 b78:	e28db004 	add	fp, sp, #4
 b7c:	e24dd010 	sub	sp, sp, #16
 b80:	e50b0010 	str	r0, [fp, #-16]
 b84:	e51b3010 	ldr	r3, [fp, #-16]
 b88:	e1a03b03 	lsl	r3, r3, #22
 b8c:	e1a03b23 	lsr	r3, r3, #22
 b90:	e50b3008 	str	r3, [fp, #-8]
 b94:	e51b3008 	ldr	r3, [fp, #-8]
 b98:	e59f207c 	ldr	r2, [pc, #124]	; 0xc1c
 b9c:	e1530002 	cmp	r3, r2
 ba0:	0a000019 	beq	0xc0c
 ba4:	e51b3008 	ldr	r3, [fp, #-8]
 ba8:	e353009f 	cmp	r3, #159	; 0x9f
 bac:	8a000016 	bhi	0xc0c
 bb0:	e59f3068 	ldr	r3, [pc, #104]	; 0xc20
 bb4:	e5933000 	ldr	r3, [r3]
 bb8:	e2833001 	add	r3, r3, #1
 bbc:	e59f205c 	ldr	r2, [pc, #92]	; 0xc20
 bc0:	e5823000 	str	r3, [r2]
 bc4:	e59f2058 	ldr	r2, [pc, #88]	; 0xc24
 bc8:	e51b3008 	ldr	r3, [fp, #-8]
 bcc:	e7922183 	ldr	r2, [r2, r3, lsl #3]
 bd0:	e59f104c 	ldr	r1, [pc, #76]	; 0xc24
 bd4:	e51b3008 	ldr	r3, [fp, #-8]
 bd8:	e1a03183 	lsl	r3, r3, #3
 bdc:	e0813003 	add	r3, r1, r3
 be0:	e5933004 	ldr	r3, [r3, #4]
 be4:	e1a01003 	mov	r1, r3
 be8:	e51b0010 	ldr	r0, [fp, #-16]
 bec:	e1a0e00f 	mov	lr, pc
 bf0:	e12fff12 	bx	r2
 bf4:	e59f3024 	ldr	r3, [pc, #36]	; 0xc20
 bf8:	e5933000 	ldr	r3, [r3]
 bfc:	e2433001 	sub	r3, r3, #1
 c00:	e59f2018 	ldr	r2, [pc, #24]	; 0xc20
 c04:	e5823000 	str	r3, [r2]
 c08:	ea000000 	b	0xc10
 c0c:	e1a00000 	nop			; (mov r0, r0)
 c10:	e24bd004 	sub	sp, fp, #4
 c14:	e8bd4800 	pop	{fp, lr}
 c18:	e12fff1e 	bx	lr
 c1c:	000003ff 	strdeq	r0, [r0], -pc	; <UNPREDICTABLE>
 c20:	80002134 	andhi	r2, r0, r4, lsr r1
 c24:	80001c34 	andhi	r1, r0, r4, lsr ip
 c28:	80001000 	andhi	r1, r0, r0
 c2c:	1f78a400 	svcne	0x0078a400
