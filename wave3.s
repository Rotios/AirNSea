;;; -*-asm-*-
;;; TSUNAMI
;;; (c) 2015 Julia Goldman and Jose Rivas

	.requ	fift,r15
	.requ	WAPC,r13
	.requ	sixfs,r12
	.requ	scratch,r11
	.requ	src1,r9
	.requ	src2,r8
	.requ	src3,r5
	.requ	dest,r4
	.requ	instcheck,r0
	
	lea	WARM,r0
	trap	$SysOverlay
	mov	$0xFFFFFF,sixfs
	
nv:	add	$1, WAR15	;nv
loop:	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section

bl:	mov	WAR15,WAR14	;Branch & Link
	add	$1,WAR14
	
branch:	add	WARM(WAPC),WAR15 	;BRANCH
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section

gbase:	mov	WARM(WAPC),src1	;get the first source
	shr	$15,src1
	and	$15,src1	    ;found which register
	
gindex:	mov	WARM(WAPC),dest	;get destination
	shr	$19,dest
	and	$15,dest	

	test	$0x4000,WARM(WAPC)	;check if the 14th bit has a 1 in it
	je	value2		;if it does, then get the value
	
	mov	WARM(WAPC),src2	;otherwise find the second source
	shr	$6, src2
	and	$15, src2
	mov	WARGS(src2),src2 ;get the value of the second sourcee
	
	mov	WARM(WAPC),r1
	and	$0x3c00,r1
	mov	WASHFTB(r1), rip ;*getsource2*

value2:	mov	WARM(WAPC),src2	;get value
	and	$0x3FFF,src2
	shl	$18,src2
	sar	$18,src2
	
	mov	WAINST(r0),rip 	;..............CALL INSTRUCTION..............

gsrc1c:	mov	WARM(WAPC),src1	;get the first source
	shr	$15,src1
	and	$15,src1	    ;found which register

	mov	WARM(WAPC),r1
	and	$0x7c00,r1
	mov	WASHFT(r1),rip	
	
gsrc1:	mov	WARM(WAPC),src1	;get the first source
	shr	$15,src1
	and	$15,src1	    ;found which register

gdest:	mov	WARM(WAPC),dest	;get destination
	shr	$19,dest
	and	$15,dest

gsrc2:	mov	WARM(WAPC),r1
	and	$0x7c00,r1
	mov	WASHFT(r1),rip

lslv:	mov	WARM(WAPC),src2	;otherwise find the second source
	shr	$6, src2
	and	$15, src2
	mov	WARGS(src2),src2 ;get the value of the second source
	
lslv2:	mov	WARM(WAPC),scratch
	and	$0x3F,scratch
	shl	scratch,src2
	mov	WAINST(r0),rip ;..............CALL INSTRUCTION..............
	
lsrv:	mov	WARM(WAPC),src2	;otherwise find the second source
	shr	$6, src2
	and	$15, src2
	mov	WARGS(src2),src2 ;get the value of the second source
	
lsrv2:	mov	WARM(WAPC),scratch
	and	$0x3F,scratch
	shr	scratch,src2

	mov	WAINST(r0),rip ;..............CALL INSTRUCTION..............

asrv:	mov	WARM(WAPC),src2	;otherwise find the second source
	shr	$6, src2
	and	$15, src2
	mov	WARGS(src2),src2 ;get the value of the second source
	
asrv2:	mov	WARM(WAPC),scratch
	and	$0x3F,scratch
	sar	scratch,src2

	mov	WAINST(r0),rip ;..............CALL INSTRUCTION..............

rorv:	mov	WARM(WAPC),src2	;otherwise find the second source
	shr	$6, src2
	and	$15, src2
	mov	WARGS(src2),src2 ;get the value of the second source
	
rorv2:	mov	WARM(WAPC),scratch
	and	$31,scratch		;This gets the value to rotate by
	
	mov	src2,r1		;r1 is a copy of src2
	shr	scratch,src2		;shift the bottom r0 bits out of src2

	mov	$32,r2
	sub	scratch,r2		;32-r0
	shl	r2,r1		;shift copy of src2 <-- by 32-r0
	or	r1,src2
	
	mov	WAINST(r0),rip ;..............CALL INSTRUCTION..............

lslr:	mov	WARM(WAPC),src2	;otherwise find the second source
	shr	$6, src2
	and	$15, src2
	mov	WARGS(src2),src2 ;get the value of the second source
	
lslr2:	mov	WARM(WAPC),scratch
	and	$15,scratch
	shl	WARGS(scratch),src2

	mov	WAINST(r0),rip ;..............CALL INSTRUCTION..............

lsrr:	mov	WARM(WAPC),src2	;otherwise find the second source
	shr	$6, src2
	and	$15, src2
	mov	WARGS(src2),src2 ;get the value of the second source
	
lsrr2:	mov	WARM(WAPC),scratch
	and	$15,scratch
	shr	WARGS(scratch),src2

	mov	WAINST(r0),rip ;..............CALL INSTRUCTION..............

asrr:	mov	WARM(WAPC),src2	;otherwise find the second source
	shr	$6, src2
	and	$15, src2
	mov	WARGS(src2),src2 ;get the value of the second source
	
asrr2:	mov	WARM(WAPC),scratch
	and	$15,scratch
	sar	WARGS(scratch),src2

	mov	WAINST(r0),rip ;..............CALL INSTRUCTION..............

rorr:	mov	WARM(WAPC),src2	;otherwise find the second source
	shr	$6, src2
	and	$15, src2
	mov	WARGS(src2),src2 ;get the value of the second source
	
rorr2:	mov	WARM(WAPC),scratch
	and	$15,scratch
	mov	WARGS(scratch),scratch
	and	$31,scratch
	
	mov	src2,r1
	shr	scratch,src2
	mov	$32,r2
	sub	scratch,r2
	shl	r2,r1
	or	r1,src2

	mov	WAINST(r0),rip ;..............CALL INSTRUCTION..............

value:	mov	WARM(WAPC),src2	;get value

	mov	WARM(WAPC),r1	;Get the exponent
	shr	$9,r1		
	and	$0x1F,r1	;Exponent is in r1

	and	$0x1FF,src2	
	shl	r1,src2		;shift left by exponent

	mov	WAINST(r0),rip	;..............CALL INSTRUCTION..............

	
wadd:	add	WARGS(src1),src2 ;get the value at that register
	add	$1,WAR15	;add
	mov	src2, WARGS(dest)

	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wadc:	add	WARGS(src1),src2
	add	$1,WAR15	;add w/ carry
	mov	WACCR,r11
	and	$2,r11
	shr	$1,r11
	lea	0(r11,src2),WARGS(dest)

	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wsub:	mov	WARGS(src1),src1
	add	$1,WAR15	;subtract
	sub	src2,src1
	mov	src1,WARGS(dest)

	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section

wcmp:	mov	WARGS(src1),src1
	add	$1,WAR15		;compare
	cmp	src2,src1
	mov	ccr,WACCR

	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
weor:	xor	WARGS(src1),src2
	add	$1,WAR15		;xor
	mov	src2,WARGS(dest)

	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
worr:	or	WARGS(src1),src2
	add	$1,WAR15	;or
	mov	src2,WARGS(dest)

	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wand:	and	WARGS(src1),src2
	add	$1,WAR15	;and
	mov	src2,WARGS(dest)

	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section

wtst:	test	WARGS(src1),src2
	add	$1,WAR15	;test
	mov	ccr,WACCR

	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section

wmul:	mul	WARGS(src1),src2
	add	$1,WAR15	;multiply
	mov	src2,WARGS(dest)

	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section

wmla:	mov	WARM(WAPC),src3	;get the 3rd source if we need it
	and	$15,src3
	
	mov	WARM(WAPC),src1	;get the first source
	shr	$15,src1
	and	$15,src1	    ;found which register

	mov	WARM(WAPC),dest	;get destination
	shr	$19,dest
	and	$15,dest
	
	mov	WARM(WAPC),src2	;otherwise find the second source
	shr	$6, src2
	and	$15, src2
	mov	WARGS(src2),src2 ;get the value of the second source 
	
	mul	WARGS(src3),src2
	add	WARGS(src1),src2
	add	$1,WAR15	;multiply add
	mov	src2,WARGS(dest)

	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wdiv:	mov	WARGS(src1),src1
	add	$1,WAR15	;divide
	div	src2,src1
	mov	src1,WARGS(dest)

	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wmov:	add	$1,WAR15			;mov
	mov	src2,WARGS(dest)
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section

wmvn:	add	$1,WAR15	;mov negative
	xor	$0xFFFFFFFF,src2
	mov	src2,WARGS(dest)
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wstm:	mov	WARGS(dest),r2	;WSTM
	and	sixfs,r2 	
	
	add	$1,WAR15
		
	test	$0x8000,src2
	je	snxt1
	
	sub	$1,r2
	mov	WAR15,WARM(r2)

	mov	WACCR,r11
	shl	$28,r11
	or	r11,WARM(r2)
	
snxt1:	shl	$1,src2

	test	$0x8000,src2
	je	snxt2

	sub	$1,r2
	and	sixfs,r2 	
	mov	WAR14,WARM(r2)

snxt2:	shl	$1,src2

	test	$0x8000,src2
	je	snxt3

	sub	$1,r2
	and	sixfs,r2 	
	mov	WAR13,WARM(r2)

snxt3:	shl	$1,src2

	test	$0x8000,src2
	je	snxt4

	sub	$1,r2
	and	sixfs,r2 	
	mov	WAR12,WARM(r2)

snxt4:	shl	$1,src2

	test	$0x8000,src2
	je	snxt5

	sub	$1,r2
	and	sixfs,r2 	
	mov	WAR11,WARM(r2)

snxt5:	shl	$1,src2

	test	$0x8000,src2
	je	snxt6

	sub	$1,r2
	and	sixfs,r2 	
	mov	WAR10,WARM(r2)

snxt6:	shl	$1,src2

	test	$0x8000,src2
	je	snxt7

	sub	$1,r2
	and	sixfs,r2 	
	mov	WAR9,WARM(r2)

snxt7:	shl	$1,src2

	test	$0x8000,src2
	je	snxt8

	sub	$1,r2
	and	sixfs,r2 	
	mov	WAR8,WARM(r2)

snxt8:	shl	$1,src2

	test	$0x8000,src2
	je	snxt9

	sub	$1,r2
	and	sixfs,r2 	
	mov	WAR7,WARM(r2)

snxt9:	shl	$1,src2

	test	$0x8000,src2
	je	snxt10

	sub	$1,r2
	and	sixfs,r2 	
	mov	WAR6,WARM(r2)

snxt10:	shl	$1,src2

	test	$0x8000,src2
	je	snxt11

	sub	$1,r2
	and	sixfs,r2 	
	mov	WAR5,WARM(r2)

snxt11:	shl	$1,src2

	test	$0x8000,src2
	je	snxt12

	sub	$1,r2
	and	sixfs,r2 	
	mov	WAR4,WARM(r2)

snxt12:	shl	$1,src2

	test	$0x8000,src2
	je	snxt13

	sub	$1,r2
	and	sixfs,r2 	
	mov	WAR3,WARM(r2)

snxt13:	shl	$1,src2

	test	$0x8000,src2
	je	snxt14

	sub	$1,r2
	and	sixfs,r2 	
	mov	WAR2,WARM(r2)

snxt14:	shl	$1,src2

	test	$0x8000,src2
	je	snxt15

	sub	$1,r2
	and	sixfs,r2 	
	mov	WAR1,WARM(r2)

snxt15:	shl	$1,src2

	test	$0x8000,src2
	je	finsal

	sub	$1,r2
	and	sixfs,r2 	
	mov	WAR0,WARM(r2)

finsal:	mov	r2,WARGS(dest)
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
		
	
wldr:	add	WARGS(src1),src2
	and	sixfs,src2

	add	$1,WAR15
	
	mov	WARM(src2),WARGS(dest)
	
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wstr:	add	WARGS(src1),src2
	and	sixfs,src2

	add	$1,WAR15
	
	mov	WARGS(dest),WARM(src2)

	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wldu:	or	$0,src2		;LDU
	jl	negldu

	and	sixfs,WARGS(src1)
	mov	WARGS(src1),r11
	add	$1,WAR15
	mov	WARM(r11),WARGS(dest)
	add	src2,WARGS(src1)

	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
negldu:	add	WARGS(src1),src2 	;NEGLDU
	and	sixfs,src2

	add	$1,WAR15
	
	mov	WARM(src2),WARGS(dest)
	mov	src2,WARGS(src1)
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wstu:	or	$0,src2		;STU
	jl	negstu

	mov	WARGS(src1),r11
	and	sixfs,r11

	mov	WARGS(dest),WARM(r11)
	add	$1,WAR15
	add	src2,WARGS(src1)
	and	sixfs,WARGS(src1)
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
negstu:	add	WARGS(src1),src2 	;NEGSTU
	and	sixfs,src2
	
	mov	WARGS(dest),WARM(src2)
	add	$1,WAR15
	mov	src2,WARGS(src1)
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wadr:	add	WARGS(src1),src2
	and	sixfs, src2
	add	$1,WAR15
	mov	src2,WARGS(dest) 
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
		
swi:	mov	WAR0,r0		;TRAP
	trap	src2
	mov	r0,WAR0
	add	$1,WAR15
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wadds:	add	WARGS(src1),src2
	mov	ccr,WACCR
	add	$1,WAR15	;add set
	mov	src2,WARGS(dest)
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wadcs:	and	$2,WACCR	
	shr	$1,WACCR
	add	WACCR,src1
	mov	ccr,WACCR
	and	$3,WACCR
	add	WARGS(src1),src2
	mov	ccr,scratch
	or	scratch,WACCR
	add	$1,WAR15	;add w/ carry set
	mov	src2,WARGS(dest)
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wsubs:	mov	WARGS(src1),src1
	add	$1,WAR15	;subtract set
	sub	src2,src1
	mov	ccr,WACCR
	mov	src1,WARGS(dest)
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
weors:	xor	WARGS(src1),src2
	mov	ccr,WACCR
	add	$1,WAR15	;xor set	
	mov	src2,WARGS(dest)
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
worrs:	or	WARGS(src1),src2
	mov	ccr,WACCR
	add	$1,WAR15	;or set
	mov	src2,WARGS(dest)
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wands:	and	WARGS(src1),src2
	mov	ccr,WACCR
	add	$1,WAR15	;and set
	mov	src2,WARGS(dest)
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section

wmuls:	mul	WARGS(src1),src2
	mov	ccr,WACCR
	add	$1,WAR15	;multiply set
	mov	src2,WARGS(dest)
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section

wmlas:
	mov	WARM(WAPC),src3	;get the 3rd source if we need it
	and	$15,src3
	
	mov	WARM(WAPC),src1	;get the first source
	shr	$15,src1
	and	$15,src1	    ;found which register
	mov	WARGS(src1),src1 ;get the value at that register

	mov	WARM(WAPC),dest	;get destination
	shr	$19,dest
	and	$15,dest

	mov	WARM(WAPC),src2	;otherwise find the second source
	shr	$6, src2
	and	$15, src2
	mov	WARGS(src2),src2 ;get the value of the second source 
	
	mul	WARGS(src3),src2
	add	$1,WAR15	;multiply add set
	add	src2,src1
	mov	ccr,WACCR
	mov	src1,WARGS(dest)
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wdivs:	mov	WARGS(src1),src1
	add	$1,WAR15			;divide set
	div	src2,src1
	mov	ccr,WACCR
	mov	src1,WARGS(dest)
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wmovs:	add	$1,WAR15			;mov set
	mov	src2,WARGS(dest)
	or	$0,src2
	mov	ccr,WACCR
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section

wmvns:	add	$1,WAR15			;mov neg set
	xor	$0xFFFFFFFF,src2
	mov	src2,WARGS(dest)
	or	$0,src2
	mov	ccr,WACCR
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wldms:	add	$1,WAR15
	mov	WARGS(dest),r2 		;LDMS
	and	sixfs,r2
	test	$1,src2
	je	nxts1
	
	mov	WARM(r2),WAR0
	add	$1,r2
	and	sixfs,r2 	
	
nxts1:	shr	$1,src2
	test	$1,src2
	je	nxts2

	mov	WARM(r2),WAR1
	add	$1,r2
	and	sixfs,r2 	

nxts2:	shr	$1,src2
	test	$1,src2
	je	nxts3

	mov	WARM(r2),WAR2
	add	$1,r2
	and	sixfs,r2 	

nxts3:	shr	$1,src2
	test	$1,src2
	je	nxts4

	mov	WARM(r2),WAR3
	add	$1,r2
	and	sixfs,r2 	

nxts4:	shr	$1,src2
	test	$1,src2
	je	nxts5

	mov	WARM(r2),WAR4
	add	$1,r2
	and	sixfs,r2 	

nxts5:	shr	$1,src2
	test	$1,src2
	je	nxts6

	mov	WARM(r2),WAR5
	add	$1,r2
	and	sixfs,r2 	

nxts6:	shr	$1,src2
	test	$1,src2
	je	nxts7

	mov	WARM(r2),WAR6
	add	$1,r2
	and	sixfs,r2 	

nxts7:	shr	$1,src2
	test	$1,src2
	je	nxts8

	mov	WARM(r2),WAR7
	add	$1,r2
	and	sixfs,r2 	

nxts8:	shr	$1,src2
	test	$1,src2
	je	nxts9

	mov	WARM(r2),WAR8
	add	$1,r2
	and	sixfs,r2 	

nxts9:	shr	$1,src2
	test	$1,src2
	je	nxts10

	mov	WARM(r2),WAR9
	add	$1,r2
	and	sixfs,r2 	

nxts10:	shr	$1,src2
	test	$1,src2
	je	nxts11

	mov	WARM(r2),WAR10
	add	$1,r2
	and	sixfs,r2 	
	
nxts11:	shr	$1,src2
	test	$1,src2
	je	nxts12

	mov	WARM(r2),WAR11
	add	$1,r2
	and	sixfs,r2 	

nxts12:	shr	$1,src2
	test	$1,src2
	je	nxts13

	mov	WARM(r2),WAR12
	add	$1,r2
	and	sixfs,r2 	

nxts13:	shr	$1,src2
	test	$1,src2
	je	nxts14

	mov	WARM(r2),WAR13
	add	$1,r2
	and	sixfs,r2 	

nxts14:	shr	$1,src2
	test	$1,src2
	je	nxts15

	mov	WARM(r2),WAR14
	add	$1,r2
 	and	sixfs,r2

nxts15:	shr	$1,src2
	test	$1,src2
	jne	final2

	mov	r2,WARGS(dest)
	and	sixfs,WARGS(dest)
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section

final2:	mov	WARM(r2),WAR15

	mov	WARM(r2),scratch
	shr	$28,scratch
	mov	scratch,WACCR
	
	add	$1,r2
	and	sixfs,r2 	
	mov	r2,WARGS(dest)
	
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wldrs:	add	WARGS(src1),src2
	and	sixfs,src2

	add	$1,WAR15
	
	mov	WARM(src2),WARGS(dest)
	or	$0,WARGS(dest)
	mov	ccr,WACCR
	
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wstrs:	add	WARGS(src1),src2 	;STRS
	and	sixfs,src2

	mov	WARGS(dest),WARM(src2)

	add	$1,WAR15
	
	or	$0,WARGS(dest)
	mov	ccr,WACCR

	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
wldus:	or	$0,src2		;LDUS
	jl	negldus

	and	sixfs,WARGS(src1)
	mov	WARGS(src1),r11
	
	add	$1,WAR15
	
	mov	WARM(r11),WARGS(dest)
	add	src2,WARGS(src1)
	
	or 	$0,WARGS(dest)
	mov	ccr,WACCR
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
negldus:add	WARGS(src1),src2 	;LDUSNEG
	and	sixfs,src2

	add	$1,WAR15	
	
	mov	WARM(src2),WARGS(dest)
	
	or 	$0,WARGS(dest)
	mov	ccr,WACCR

	mov	src2,WARGS(src1)
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
	
wstus:	or	$0,src2		;LDU
	jl	negstus

	mov	WARGS(src1),r11
	and	sixfs,r11
	mov	WARGS(dest),WARM(r11)

	add	$1,WAR15
	
	or	$0,WARGS(dest)
	mov	ccr,WACCR
	
	add	src2,WARGS(src1)
	and	sixfs,WARGS(src1)
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
negstus:add	WARGS(src1),src2 	;NEGLDU
	and	sixfs,src2
	mov	WARGS(dest),WARM(src2)

	add	$1,WAR15
	
	or	$0,WARGS(dest)
	mov	ccr,WACCR
	
	mov	src2,WARGS(src1)
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section
	
	
swis:	mov	WAR0,r0		;TRAP
	trap	src2
	mov	r0,WAR0
	or	$0,r0
	mov	ccr,WACCR
	add	$1,WAR15
	
	and	sixfs,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,WAPC	     ;Assume number is too high already and just mask

	mov	WARM(WAPC),r0
	and	$0xFFF00000,r0
	or	WACCR,r0
	trap	$SysPLA
	mov	WADEC(r0),rip ;go to the correct opcode source decoding section

WAINST:				
	.data	wadd, wadc, wsub
	.bss	1
	.data	weor, worr, wand
	.bss	1
	.data	wmul, wmla, wdiv, wmov, wmvn, swi, wldms, wstm, wldr, wstr, wldu, wstu, wadr
	.bss	3
	.data	branch, branch, bl, bl
	.bss	4
	.data	wadds, wadcs, wsubs, wcmp, weors, worrs, wands, wtst, wmuls, wmlas, wdivs, wmovs, wmvns, swis
	.bss	2
	.data	wldrs, wstrs, wldus, wstus, wadr
	.bss	10
	.data	nv
	
WADEC:
	.data	gsrc1, gsrc1, gsrc1
	.bss	1
	.data	gsrc1, gsrc1, gsrc1
	.bss	1
	.data	gsrc1, wmla, gsrc1, gdest, gdest, gsrc2, gdest, gdest, gbase, gbase, gbase, gbase, gbase
	.bss	3
	.data	branch, branch, bl, bl
	.bss	4
	.data	gsrc1, gsrc1, gsrc1, gsrc1c, gsrc1, gsrc1, gsrc1, gsrc1, gsrc1, wmlas, gsrc1, gdest, gdest, gsrc2
	.bss	2
	.data	gbase, gbase, gbase, gbase, gbase
	.bss	10
	.data	nv
	
WASHFT:
	.data	value
	.bss	1023
	.data	value		;1024
	.bss	1023
	.data 	value		;2048
	.bss	1023		
	.data	value		;4096
	.bss	1023
	.data 	value
	.bss	1023
	.data	value
	.bss	1023
	.data	value
	.bss	1023
	.data	value
	.bss	1023
	.data	value
	.bss	1023
	.data	value
	.bss	1023
	.data	value
	.bss	1023
	.data	value
	.bss	1023
	.data	value
	.bss	1023
	.data	value
	.bss	1023
	.data	value
	.bss	1023
	.data	value
	.bss	1023
	.data	lslv
	.bss	1023
	.data	lsrv
	.bss	1023
	.data 	asrv
	.bss	1023
	.data 	rorv
	.bss	1023
	.data	lslr
	.bss	1023
	.data	lsrr
	.bss	1023
	.data	asrr
	.bss	1023
	.data	rorr

WASHFTB:
	.data	lslv2
	.bss	1023
	.data	lsrv2
	.bss	1023
	.data	asrv2
	.bss	1023
	.data	rorv2
	.bss	1023
	.data	lslr2
	.bss	1023
	.data	lsrr2
	.bss	1023
	.data	asrr2
	.bss	1023
	.data	rorr2
	
WARGS:
WAR0:
	.data	0
WAR1:
	.data 	0
WAR2:
	.data 	0
WAR3:
	.data	0
WAR4:
	.data 	0
WAR5:
	.data	0
WAR6:
	.data	0
WAR7:
	.data	0
WAR8:
	.data	0
WAR9:
	.data	0
WAR10:
	.data	0
WAR11:
	.data	0
WAR12:
	.data	0
WAR13:
	.data	0xFFFFFF
WAR14:
	.data 	0
WAR15:
	.data	-1
WACCR:
	.data	0

;WASETS:
;	.data	0,s
	
WARM:
