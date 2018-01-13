/*
 * relocate_kernel.S - put the kernel image in place to boot
 */

#include <asm/kexec.h>
    
	.globl relocate_new_kernel

relocate_new_kernel:
    b start

__printhex:
    mov	r1, #8
    adr	r2, hexbuf
    add	r3, r2, r1
    mov	r1, #0
    strb	r1, [r3]
1:	and	r1, r0, #15
    mov	r0, r0, lsr #4
    cmp	r1, #10
    addlt	r1, r1, #'0'
    addge	r1, r1, #'a' - 10
    strb	r1, [r3, #-1]!
    teq	r3, r2
    bne	1b
    mov	r0, r2

    ldr r3, =0xF7FC9000     @ UART0 base addr
    b	2f
1:	strb r1, [r3, #0]
    teq	r1, #'\n'
    moveq	r1, #'\r'
    beq	1b
2:	teq	r0, #0
    ldrneb	r1, [r0], #1
    teqne	r1, #0
    bne	1b
    mov pc, lr
   
start:
    ldr	r0,kexec_indirection_page
	ldr	r1,kexec_start_address
    
/*
	 * If there is no indirection page (we are doing crashdumps)
	 * skip any relocation.
	 */
	cmp	r0, #0
	beq	2f

0:	/* top, read another word for the indirection page */
	ldr	r3, [r0],#4

	/* Is it a destination page. Put destination address to r4 */
	tst	r3,#1,0
	beq	1f
	bic	r4,r3,#1
	b	0b
1:
	/* Is it an indirection page */
	tst	r3,#2,0
	beq	1f
	bic	r0,r3,#2
	b	0b
1:

	/* are we done ? */
	tst	r3,#4,0
	beq	1f
	b	2f

1:
	/* is it source ? */
	tst	r3,#8,0
	beq	0b
	bic r3,r3,#8
	mov r6,#1024
9:
	ldr r5,[r3],#4
	str r5,[r4],#4
	subs r6,r6,#1
	bne 9b
	b 0b

2:
	/* Jump to relocated kernel */
	mov lr,r1
	mov r0,#0
	ldr r1,kexec_mach_type
	ldr r2,kexec_boot_atags
 ARM(	mov pc, lr	)
 THUMB(	bx lr		)

	.align

	.globl kexec_start_address
kexec_start_address:
	.long	0x0

	.globl kexec_indirection_page
kexec_indirection_page:
	.long	0x0

	.globl kexec_mach_type
kexec_mach_type:
	.long	0x0

	/* phy addr of the atags for the new kernel */
	.globl kexec_boot_atags
kexec_boot_atags:
	.long	0x0

    .macro senduart, rd, rx
    strb \rd, [\rx, #0]
    .endm

_printhex8:
		mov	r1, #8
		b	_printhex

_printhex4:
		mov	r1, #4
		b	_printhex

_printhex2:
		mov	r1, #2
_printhex:	adr	r2, hexbuf
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
		b	_printascii

hexbuf:	.space 16
		.ltorg

_printascii:
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

_printch:
#		addruart_current r3, r1, r2
		mov	r1, r0
		mov	r0, #0
		b	1b
relocate_new_kernel_end:

	.globl relocate_new_kernel_size
relocate_new_kernel_size:
	.long relocate_new_kernel_end - relocate_new_kernel
