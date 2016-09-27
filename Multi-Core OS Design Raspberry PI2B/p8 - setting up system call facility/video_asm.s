@@@@@@@@@@@@@@@@
@ Print Template
@@@@@@@@@@@@@@@@

@.globl print_this
@print_this:
@	push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
@	
@	mov r4,#20
@       ldr r10,=print_start
@       mov r11,#print_start-print_end
@
@	bl print_msg
@	pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}

.section .text

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ VIDEOCODE INIT
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.global init_video_code
init_video_code:

	push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
	@ Initialize the framebuffer
	mov r0,#1024
	mov r1,#768
	mov r2,#16
	bl InitialiseFrameBuffer
	teq r0,#0
	bne noError$
	@ Signal for a failed initialization	
	mov r0,#47
	mov r1,#1
	bl SetGpioFunction
	mov r0,#47
	mov r1,#1
	bl SetGpio
	error$:
		b error$
	noError$:
	fbInfoAddr .req r4
	mov fbInfoAddr,r0
        bl initiate_print
	pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Print Call for Printing through C..
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.globl print_c
print_c:
	push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
	
	mov r4,r2
        mov r10,r1
        mov r11,r3

	bl print_msg
	pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Enter Your Print Statements Here...
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.globl print_msg1
print_msg1:
	push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
	
	mov r4,#20
        ldr r10,=welcomescreen_start11
        mov r11,#welcomescreen_end11-welcomescreen_start11

	bl print_msg
	pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}




@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ This subroutine formats the text to be printed
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.globl print_msg
print_msg:
	push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}

	mov r12, #16
	ldr r5, =last_line
	str r4, [r5]
	mul r4, r12, r4
        add r12, r11, r10
        @ldr r12,=welcomescreen_end11

	push {r10,r11,r12}
	bl SetGraphicsAddress
	pop {r10,r11,r12}
	mov r0, r10
	mov r1, r11
	mov r2, r12
	
	ldr r5, =previous_start
	str r0, [r5]
	ldr r5, =previous_end
        str r1, [r5]

        @ldr r0,=welcomescreen_start
        @mov r1,#welcomescreen_end-welcomescreen_start
        @ldr r2,=welcomescreen_end
	lsr r3,r4,#4
	mov r10,r2

	bl FormatString
        bl flash_prompt

	@bl delay8
	@bl delay8
	@bl delay8
	@bl delay8
	@bl delay8

	pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ The following subroutine  calls DrawStrings 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.globl flash_prompt
 flash_prompt:

	push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}


	mov r1,r0
	mov r0,r10
	mov r2,#0
	mov r3,r4

	cmp r3,#768-16
	subhi r3,#768
	addhi r2,#256
	cmp r3,#768-16
	subhi r3,#768
	addhi r2,#256
	cmp r3,#768-16
	subhi r3,#768
	addhi r2,#256

	bl DrawString

        @bl blink_led_now

	pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ ENTER YOUR TEXT TO BE PRINTED HERE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ Syntax
@ print_start: 
@ .ascii "your message"
@ print_end

welcomescreen_start:
  .ascii "                                                      Welcome to TERP OS"
welcomescreen_end:

welcomescreen_start11:
  .ascii "                                                      Welcome to TERP OS11"
welcomescreen_end11:



@@@@@@@@@
@ Utility
@@@@@@@@@

.align 8
previous_start:
.int 0 
previous_end:
.int 0
last_line:
.int 0
.section .data
.align 4
FrameBufferInfo:
	.int 1024	/* #0 Width */
	.int 768	/* #4 Height */
	.int 1024	/* #8 vWidth */
	.int 768	/* #12 vHeight */
	.int 0		/* #16 GPU - Pitch */
	.int 16		/* #20 Bit Depth */
	.int 0		/* #24 X */
	.int 0		/* #28 Y */
	.int 0		/* #32 GPU - Pointer */
	.int 0		/* #36 GPU - Size */

.section .text
.globl InitialiseFrameBuffer
InitialiseFrameBuffer:
	width .req r0
	height .req r1
	bitDepth .req r2
	cmp width,#4096
	cmpls height,#4096
	cmpls bitDepth,#32
	result .req r0
	@ If any inputs are out of bounds move 0 into result and exit
	movhi result,#0
	movhi pc,lr

	push {r4,lr}	
	fbInfoAddr .req r4		
	ldr fbInfoAddr,=FrameBufferInfo+0x40000000
	@ Set width and height
	str width,[r4,#0]
	str height,[r4,#4]
	@ Virtual width and height
	str width,[r4,#8]
	str height,[r4,#12]
	str bitDepth,[r4,#20]
	.unreq width
	.unreq height
	.unreq bitDepth

	mov r0,fbInfoAddr
	@ Address must be physical address rather than virtual with L2 cache enabled
	@add r0,#0x40000000
	mov r1,#1
	bl MailboxWrite
	
	mov r0,#1
	bl MailboxRead
		
	teq result,#0
	movne result,#0
	popne {r4,pc}

	mov result,fbInfoAddr
	and result,result,#0x0FFFFFFF
	pop {r4,pc}
	.unreq result
	.unreq fbInfoAddr
.section .data
.align 8
font:
	.incbin "font.binary"

.align 1
backColour:
	.hword 0x0000

.align 1
foreColour:
	.hword 0xFFFF

.align 2
graphicsAddress:
	.int 0

.section .text

.globl SetBackColour
SetBackColour:
	cmp r0,#0x10000
	movhi pc,lr
	moveq pc,lr
	ldr r1,=backColour
	strh r0,[r1]
	mov pc,lr

.globl SetForeColour
SetForeColour:
	cmp r0,#0x10000
	movhi pc,lr
	moveq pc,lr
	ldr r1,=foreColour
	strh r0,[r1]
	mov pc,lr

.globl SetGraphicsAddress
SetGraphicsAddress:
	ldr r1,=graphicsAddress
	str r0,[r1]
	mov pc,lr


.globl DrawBlackPixel
DrawBlackPixel:
	px .req r0
	py .req r1
	addr .req r2
	@ Load the graphics address which is an unsigned integer
	ldr addr,=graphicsAddress
	ldr addr,[addr]
	height .req r3
	ldr height,[addr,#4]
	sub height,#1
	@ Make sure y axis is within range
	cmp py,height
	movhi pc,lr
	.unreq height

	width .req r3
	ldr width,[addr,#0]
	sub width,#1
	@ Make sure x axis is within range
	cmp px,width
	movhi pc,lr

	ldr addr,[addr,#32]
	@ Subtract the uncached bus access alias from the GPU pointer address
	sub addr, #0xC0000000
	add width,#1
	@ Multply y axis with width, add x axis and store in px
	mla px,py,width,px
	.unreq width
	.unreq py
	@ Logical shift left one position is effectively multiply by two, the pixel size
	add addr, px,lsl #1
	.unreq px

	fore .req r3
	@ Load the back color
	ldr fore,=backColour
	ldrh fore,[fore]

	@ Store it in the calculated pixel address.  This paints the pixel
	strh fore,[addr]
	.unreq fore
	.unreq addr
	mov pc,lr


.globl DrawPixel
DrawPixel:
	px .req r0
	py .req r1
	addr .req r2
	@ Load the graphics address which is an unsigned integer
	ldr addr,=graphicsAddress
	ldr addr,[addr]
	height .req r3
	ldr height,[addr,#4]
	sub height,#1
	@ Make sure y axis is within range
	cmp py,height
	movhi pc,lr
	.unreq height

	width .req r3
	ldr width,[addr,#0]
	sub width,#1
	@ Make sure x axis is within range
	cmp px,width
	movhi pc,lr

	ldr addr,[addr,#32]
	@ Subtract the uncached bus access alias from the GPU pointer address
	sub addr, #0xC0000000
	add width,#1
	@ Multply y axis with width, add x axis and store in px
	mla px,py,width,px
	.unreq width
	.unreq py
	@ Logical shift left one position is effectively multiply by two, the pixel size
	add addr, px,lsl #1
	.unreq px

	fore .req r3
	@ Load the fore color
	ldr fore,=foreColour
	ldrh fore,[fore]

	@ Store it in the calculated pixel address.  This paints the pixel
	strh fore,[addr]
	.unreq fore
	.unreq addr
	mov pc,lr


@ Bresenhams Line Algorithm
.globl DrawLine
DrawLine:
	push {r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
	x0 .req r4
	y0 .req r5
	x1 .req r6
	y1 .req r7

	deltax .req r8
	deltay .req r9
	stepx .req r10
	stepy .req r11
	error .req r12

	mov x0,r0
	mov y0,r1
	mov x1,r2
	mov y1,r3

	cmp x1,x0
	subge deltax,x1,x0
	movge stepx,#1
	sublt deltax,x0,x1
	movlt stepx,#-1

	cmp y1,y0
	subge deltay,y0,y1
	movge stepy,#-1
	sublt deltay,y1,y0
	movlt stepy,#1

	add error,deltax,deltay
	add x1,stepx
	add y1,stepy

	lineLoop$:
		teq x0,x1
		teqne y0,y1
		@ We are done
		popeq {r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}

		mov r0,x0
		mov r1,y0
		bl DrawPixel

		cmp deltax,error,lsl #1
		addge y0,stepy
		addge error,deltax

		@neg deltay,deltay
		cmp deltay,error,lsl #1
		addle x0,stepx
		addle error,deltay

		b lineLoop$

	.unreq x0
	.unreq x1
	.unreq y0
	.unreq y1
	.unreq deltax
	.unreq deltay
	.unreq stepx
	.unreq stepy
	.unreq error

.globl DrawCharacter
DrawCharacter:
	x .req r4
	y .req r5
	charAddr .req r6

	@ Check the range of ASCII values
	cmp r0,#0x7F
	bhi Debug
	movhi pc,lr

	mov x,r1
	mov y,r2

	push {r4,r5,r6,r7,r8,lr}
	ldr charAddr,=font
	@ Left shift the ASCII Number by 4 (16 bits) the size of a character
	add charAddr, r0,lsl #4
	
	push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12}
	charblackLoop$:
		bits .req r7
		bit .req r8
		ldrb bits,[charAddr]		
		mov bit,#8

		charPixelLoopb$:
			subs bit,#1
			blt charPixelLoopEndb$
			lsl bits,#1
			add r0,x,bit
			mov r1,y

			bl DrawBlackPixel

			teq bit,#0
			bne charPixelLoopb$
		charPixelLoopEndb$:

		.unreq bit
		.unreq bits
		add y,#1
		add charAddr,#1
		tst charAddr,#0b1111
		bne charblackLoop$
	pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12}

	charLoop$:
		bits .req r7
		bit .req r8
		ldrb bits,[charAddr]		
		mov bit,#8

		charPixelLoop$:
			subs bit,#1
			blt charPixelLoopEnd$
			lsl bits,#1
			add r0,x,bit
			mov r1,y
			tst bits,#0x100

			beq charPixelLoop$
			bl DrawPixel

			@beq charPixelLoop$
                        @
			@bl DrawPixel

			teq bit,#0
			bne charPixelLoop$
		charPixelLoopEnd$:

		.unreq bit
		.unreq bits
		add y,#1
		add charAddr,#1
		tst charAddr,#0b1111
		bne charLoop$

	.unreq x
	.unreq y
	.unreq charAddr

	width .req r0
	height .req r1
	mov width,#8
	mov height,#16

	pop {r4,r5,r6,r7,r8,pc}
	.unreq width
	.unreq height

.globl DrawString
DrawString:
	x .req r4
	y .req r5
	x0 .req r6
	string .req r7
	length .req r8
	char .req r9
	
	push {r4,r5,r6,r7,r8,r9,lr}

	mov string,r0
	mov x,r2
	mov x0,x
	mov y,r3
	mov length,r1

	stringLoop$:
		subs length,#1
		blt stringLoopEnd$

		ldrb char,[string]
		add string,#1

		mov r0,char
		mov r1,x
		mov r2,y
		bl DrawCharacter
		cwidth .req r0
		cheight .req r1

		teq char,#'\n'
		moveq x,x0
		addeq y,cheight
		beq stringLoop$

		teq char,#'\t'
		addne x,cwidth
		bne stringLoop$

		add cwidth, cwidth,lsl #2
		x1 .req r1
		mov x1,x0
			
		stringLoopTab$:
			add x1,cwidth
			cmp x,x1
			bge stringLoopTab$
		mov x,x1
		.unreq x1	
		b stringLoop$
	stringLoopEnd$:
	.unreq cwidth
	.unreq cheight
	
	pop {r4,r5,r6,r7,r8,r9,pc}
	.unreq x
	.unreq y
	.unreq x0
	.unreq string
	.unreq length
.globl GetMailboxBase
GetMailboxBase: 
	ldr r0,=0x3F00B880
	mov pc,lr

.globl MailboxWrite
MailboxWrite: 
	@ Validate the lower 4 bits of the mailbox channel are 0
	tst r0,#0b1111
	movne pc,lr
	@ r1 is a mailbox channel which must be less than 4 bits
	cmp r1,#15
	movhi pc,lr

	channel .req r1
	value .req r2
	mov value,r0
	push {lr}
	bl GetMailboxBase
	mailbox .req r0
		
	status .req r3
	wait1$:	
		@ Status contains the address of the status register
		@ Address 0x3F00B898 is the status mailbox
		ldr status,[mailbox,#0x18]	
		@ Check that bit 31 is clear (ready to write), if so proceed
		tst status,#0x80000000
		bne wait1$
	.unreq status

	@ Add the value and channel together, now the last 4 bits are filled with the channel
	add value,channel
	.unreq channel
	
	@ Address 0x3F0B8AC is the write mailbox
	str value,[mailbox,#0x20]
	.unreq value
	.unreq mailbox
	pop {pc}

.globl MailboxRead
MailboxRead: 
	@ r1 is a mailbox channel which must be less than 4 bits
	cmp r0,#15
	movhi pc,lr

	channel .req r1
	mov channel,r0
	push {lr}
	bl GetMailboxBase
	mailbox .req r0
	
	status .req r2
	rightmail$:
		wait2$:	
			@ Status contains the address of the status register
			@ Address 0x3F00B898 is the status mailbox
			ldr status,[mailbox,#0x18]		
			@ Check that bit 30 is clear (ready to read), if so proceed
			tst status,#0x40000000
			bne wait2$
		.unreq status
		
		
		mail .req r2
		@ Address 0x3F00B880 is the read mailbox
		ldr mail,[mailbox,#0]

		inchan .req r3
		@ The least significant 4 bits are the mailbox channel
		and inchan,mail,#0b1111
		@ Check that it's the channel we expect
		teq inchan,channel
		.unreq inchan
		bne rightmail$
	.unreq mailbox
	.unreq channel

	and r0,mail,#0xfffffff0
	.unreq mail
	pop {pc}
.globl DivideU32
DivideU32:
	result .req r0
	remainder .req r1
	shift .req r2
	current .req r3

	clz shift,r1
	clz r3,r0
	subs shift,r3
	lsl current,r1,shift
	mov remainder,r0
	mov result,#0
	blt divideU32Return$

	divideU32Loop$:

		cmp remainder,current
		blt divideU32LoopContinue$

		add result,result,#1
		subs remainder,current
		lsleq result,shift
		beq divideU32Return$

	divideU32LoopContinue$:

	subs shift,#1
	lsrge current,#1
	lslge result,#1
	bge divideU32Loop$


	divideU32Return$:
	.unreq current
	mov pc,lr

	.unreq result
	.unreq remainder
	.unreq shift
.globl SignedString
SignedString:
	val .req r0
	dest .req r1
	base .req r2
	cmp val,#0
	bge UnsignedString
	cmp dest,#0
	movgt r3,#'-'
	strgt r3,[dest]
	addgt dest,#1
	neg val, val
	push {lr}
	bl UnsignedString
	add val,#1
	pop {pc}
	.unreq val
	.unreq dest
	.unreq base

.globl UnsignedString
UnsignedString:
	val .req r0
	dest .req r5
	base .req r6
	length .req r7
	push {r4, r5, r6, r7, lr}

	mov length,#0
	mov base,r2
	mov dest,r1
	uSignloop$:
		mov r1,base
		bl DivideU32
		cmp r1,#10
	 	addhs r1,#'a'-10
	 	addlo r1,#'0'
	 	teq dest,#0
	 	strneb r1,[dest,length]
	 	add length,#1
	 	cmp val,#0
	 	bgt uSignloop$
	cmp dest,#0
	.unreq val
	.unreq base
	movhi r0,dest
	movhi r1,length
	blhi ReverseString
	mov r0,length
	pop {r4, r5, r6, r7, pc}
	.unreq dest
	.unreq length

.globl ReverseString
ReverseString:
	string .req r0
	length .req r1
	temp1 .req r2
	temp2 .req r3

	add length,string
	sub length,#1
	revLoop$:
		cmp length,string
		bls revDone$

		ldrb r2,[string]
		ldrb r3,[length]
		strb r3,[string]
		strb r2,[length]
		add string,#1
		sub length,#1
		b revLoop$
		
	revDone$:
		.unreq string
		.unreq length
		.unreq temp1
		.unreq temp2
		movls pc,lr


.globl FormatString
FormatString:
	format .req r4
	formatLength .req r5
	dest .req r6
	nextArg .req r7
	argList .req r8
	length .req r9

	push {r4,r5,r6,r7,r8,r9,lr}
	mov format,r0
	mov formatLength,r1
	mov dest,r2
	mov nextArg,r3
	add argList,sp,#7*4
	mov length,#0

	formatLoop$:
		subs formatLength,#1
		movlt r0,length
		poplt {r4,r5,r6,r7,r8,r9,pc}

		ldrb r0,[format]
		add format,#1
		teq r0,#'%'
		beq formatArg$

	formatChar$:
		teq dest,#0
		strneb r0,[dest]
		addne dest,#1
		add length,#1
		b formatLoop$

	formatArg$:
		subs formatLength,#1
		movlt r0,length
		poplt {r4,r5,r6,r7,r8,r9,pc}

		ldrb r0,[format]
		add format,#1
		teq r0,#'%'
		beq formatChar$

		teq r0,#'c'
		moveq r0,nextArg
		ldreq nextArg,[argList]
		addeq argList,#4
		beq formatChar$

		teq r0,#'s'
		beq formatString$

		teq r0,#'d'
		beq formatSigned$

		teq r0,#'u'
		teqne r0,#'x'
		teqne r0,#'b'
		teqne r0,#'o'
		beq formatUnsigned$

		b formatLoop$

	formatString$:
		ldrb r0,[nextArg]
		teq r0,#0x0
		ldreq nextArg,[argList]
		addeq argList,#4
		beq formatLoop$
		add length,#1
		teq dest,#0
		strneb r0,[dest]
		addne dest,#1
		add nextArg,#1
		b formatString$

	formatSigned$:
		mov r0,nextArg
		ldr nextArg,[argList]
		add argList,#4
		mov r1,dest
		mov r2,#10
		bl SignedString
		teq dest,#0
		addne dest,r0
		add length,r0
		b formatLoop$

	formatUnsigned$:
		teq r0,#'u'
		moveq r2,#10
		teq r0,#'x'
		moveq r2,#16
		teq r0,#'b'
		moveq r2,#2
		teq r0,#'o'
		moveq r2,#8
		mov r0,nextArg
		ldr nextArg,[argList]
		add argList,#4
		mov r1,dest
		bl UnsignedString
		teq dest,#0
		addne dest,r0
		add length,r0
		b formatLoop$



		
.globl GetGpioAddress
GetGpioAddress:
ldr r0,=0x3F200000
mov pc,lr

.globl SetGpioFunction
SetGpioFunction:
    @ Make sure pin number and function are valid
    cmp r0,#53
    cmpls r1,#7
    @ If invalid return back to the code that called
    movhi pc,lr

    @ Store the link register, the address to return to, in the stack
    push {lr}
    @ Put the pin number into r2
    mov r2,r0

    bl GetGpioAddress
    functionLoop$:
        cmp r2,#9
        subhi r2,#10
        addhi r0,#4
        bhi functionLoop$

    add r2, r2,lsl #1
    lsl r1,r2
    str r1,[r0]
    pop {pc}

.globl SetGpio
SetGpio:
    pinNum .req r0
    pinVal .req r1

    cmp pinNum,#53
    movhi pc,lr
    push {lr}
    mov r2,pinNum
    .unreq pinNum
    pinNum .req r2
    bl GetGpioAddress
    gpioAddr .req r0

    pinBank .req r3
    lsr pinBank,pinNum,#5
    lsl pinBank,#2
    add gpioAddr,pinBank
    .unreq pinBank

    and pinNum,#31
    setBit .req r3
    mov setBit,#1
    lsl setBit,pinNum
    .unreq pinNum

    teq pinVal,#0
    .unreq pinVal
    streq setBit,[gpioAddr,#40]
    strne setBit,[gpioAddr,#28]
    .unreq setBit
    .unreq gpioAddr
    pop {pc}

.globl Debug
Debug:
    @ Signal for a failed initialization
    @ Set the GPIO pin
    mov r0,#47
    mov r1,#1
    bl SetGpioFunction

    ptrn .req r4
    ldr ptrn,=pattern
    ldr ptrn,[ptrn]
    seq .req r5
    reset .req r6
    mov seq,#0

    @ Turn on the LED by setting the GPSET1 register
    @ With the 47th bit set
    @ Give processor a flash LED task
    xloop$:

        pinNum .req r0
        pinVal .req r1
        mov pinVal,#1
        lsl pinVal,seq
        and pinVal,ptrn
        mov pinNum,#47
        bl SetGpio
        .unreq pinNum
        .unreq pinVal

        @ Set the countdown timer
        delay .req r0
        ldr delay,=250000
        bl Wait
        .unreq delay

        add seq,seq,#1
        cmp seq,#32
        moveq seq,#0
        @ When timer expires turn on the LED by setting the GPSET1 register
    b xloop$

    .unreq seq

.section .data
.align 2
@TO-DO Create additional patterns to signal different errors
pattern:
.int 0b00000000010101011101110111010101
.globl GetSystemTimerAddress
GetSystemTimerAddress: 
	ldr r0,=0x3F003000
	mov pc,lr

.globl GetTimestamp
GetTimestamp:
	push {lr}
	bl GetSystemTimerAddress
	@ Get current the counter value
	ldrd r0,r1,[r0,#4]
	pop {pc}

.globl Wait
Wait:
	start .req r3
	period .req r2
	push {lr}
	mov period,r0
	bl GetTimestamp
	@ Start time in r3 (start), delay period in r2 (period)
	mov start,r0

	loop$:
		bl GetTimestamp
		elapsed .req r1
		@ Subtract start time from most recent timestamp to get elapsed time
		sub elapsed,r0,start
		cmp elapsed,period
		.unreq elapsed
		@ If elapsed time is less than wait period loop again
		bls loop$
	@ Elapsed time is greater than wait period so return	
	.unreq period
	.unreq start
	pop {pc}


.global xblink_led
xblink_led:

	push {r0, r1, r2, r3, r4,r5,r6,r7,r8,r9,lr}
@ Set the GPIO pin
pinNum .req r0
pinFunc .req r1
@ Put 47 in the for the pin number
mov pinNum,#47
@ We want to set the pin high, function 1
mov pinFunc,#1
bl SetGpioFunction
.unreq pinNum
.unreq pinFunc

@ Turn on the LED by setting the GPSET1 register
@ With the 47th bit set
@ Give processor a flash LED task
pinNum .req r0
pinVal .req r1
mov pinNum,#47
mov pinVal,#1
bl SetGpio
.unreq pinNum
.unreq pinVal

@ Set the countdown timer
mov r0,r5
delay .req r0
@ldr delay,=100000
bl Wait
.unreq delay

@ When timer expires turn off the LED by setting GPCLR1 register
pinNum .req r0
pinVal .req r1
mov pinNum,#47
mov pinVal,#0
bl SetGpio
.unreq pinNum
.unreq pinVal

@ Reset the countdown timer
mov r0,r5
delay .req r0
@ldr delay,=100000
bl Wait
.unreq delay

	pop {r0, r1, r2, r3, r4,r5,r6,r7,r8,r9,pc}
@ When timer expires turn on the LED by setting the GPSET1 register

.globl delay8_blink
delay8_blink:
	push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
	 bl blink_led_now
	 bl blink_led_now
	pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}

.globl delay8
delay8:
	push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
	 bl delay7
	 bl delay7
	pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}

.globl delay7
delay7:
push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
ldr r5,=500000
@ Set the countdown timer
mov r0,r5
bl Wait
pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}

.globl blink_led_now
blink_led_now:
push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
ldr r5,=250000
bl xblink_led
pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}


	


