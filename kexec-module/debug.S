#include <linux/linkage.h>
#include <asm/assembler.h>

		.text

        .macro senduart, rd, rx
        strb \rd, [\rx, #0]
        .endm

/*
 * Useful debugging routines
 */
ENTRY(printhex8)
		mov	r1, #8
		b	printhex
ENDPROC(printhex8)

ENTRY(printhex4)
		mov	r1, #4
		b	printhex
ENDPROC(printhex4)

ENTRY(printhex2)
		mov	r1, #2
printhex:	adr	r2, hexbuf
		add	r3, r2, r1
		mov	r1, #0
		strb	r1, [r3]
1:		and	r1, r0, #15
		mov	r0, r0, lsr #4
		cmp	r1, #10
		addlt	r1, r1, #'0'
		addge	r1, r1, #'a' - 10
		strb	r1, [r3, #-1]!
		teq	r3, r2
		bne	1b
		mov	r0, r2
		b	printascii
ENDPROC(printhex2)

hexbuf:		.space 16

		.ltorg

ENTRY(printascii)
#		addruart_current r3, r1, r2
        ldr r3, =0xF7FC9000
		b	2f
#1:		waituart r2, r3
1:		senduart r1, r3
#		busyuart r2, r3
		teq	r1, #'\n'
		moveq	r1, #'\r'
		beq	1b
2:		teq	r0, #0
		ldrneb	r1, [r0], #1
		teqne	r1, #0
		bne	1b
		mov	pc, lr
ENDPROC(printascii)

ENTRY(printch)
#		addruart_current r3, r1, r2
		mov	r1, r0
		mov	r0, #0
		b	1b
ENDPROC(printch)
