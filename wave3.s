;;; -*-asm-*-
;;; TSUNAMI
;;; (c) 2015 Julia Goldman and Jose Rivas
	
	.requ	curinst,r13
	.requ	instcheck,r11
	.requ	src1,r9
	.requ	src2,r8
	.requ	src3,r5
	.requ	dest,r4

	lea	WARM,r0
	trap	$SysOverlay

nv:
	add	$1, WAR15	;nv
loop:	
	and	$0xFFFFFF,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,r0	     ;Assume number is too high already and just mask
	mov	WARM(r0),curinst

	mov	curinst, r0
	shr	$29,r0
	mov	WACNDS(r0), rip

bl:
	mov	WAR15,WAR14	;Branch & Link
	add	$1,WAR14
	
branch:
	add	curinst,WAR15 	;BRANCH
	
	and	$0xFFFFFF,WAR15	 ;--------DECODING BEGINS--------
	mov	WAR15,r0	     ;Assume number is too high already and just mask
	mov	WARM(r0),curinst

	mov	curinst, r0
	shr	$29,r0
	mov	WACNDS(r0), rip	
	
eq:
	mov	WACCR,ccr
	jne	nv
	jmp	grab

ne:
	mov	WACCR,ccr
	je	nv
	jmp	grab

lt:
	mov	WACCR,ccr
	jge	nv
	jmp	grab

le:
	mov	WACCR,ccr
	jg	nv
	jmp	grab

gt:
	mov	WACCR,ccr
	jle	nv
	jmp	grab

ge:
	mov	WACCR,ccr
	jl	nv
	
always:	
grab:
	mov	curinst,instcheck ;************-INSTRUCTION****************
	shr	$23, instcheck
	and	$63, instcheck
	mov	WADEC(instcheck),rip ;go to the correct opcode decoding section

gsrc3:
	mov	curinst,src3	;get the 3rd source if we need it
	and	$15,src3
	mov	WARGS(src3),src3	
	
gsrc1:
	mov	curinst,src1	;get the first source
	shr	$15,src1
	and	$15,src1	    ;found which register
	mov	WARGS(src1),src1 ;get the value at that register

gdest:
	mov	curinst,dest	;get destination
	shr	$19,dest
	and	$15,dest
	
gsrc2:
	mov	curinst,r1	
	test	$0x4000,r1	;check if the 14th bit has a 1 in it
	je	value		;if it does, then get the value
	
	mov	curinst,src2	;otherwise find the second source
	shr	$6, src2
	and	$15, src2
	mov	WARGS(src2),src2 ;get the value of the second source

	mov	curinst,r1
	shr	$10,r1
	and	$15,r1
	mov	WASHFT(r1), rip

lslv:
	mov	curinst,r0	; shift left value
	and	$0x3F,r0
	shl	r0,src2
	mov	WAINST(instcheck),rip 
	
lsrv:
	mov	curinst,r0	;shift right value
	and	$0x3F,r0
	shr	r0,src2

	mov	WAINST(instcheck),rip 

asrv:
	mov	curinst,r0	;shift arithmetic right value
	and	$0x3F,r0
	sar	r0,src2

	mov	WAINST(instcheck),rip 

rorv:
	mov	curinst,r0	;rotate right value
	and	$31,r0		;This gets the value to rotate by
	
	mov	src2,r1		;r1 is a copy of src2
	shr	r0,src2		;shift the bottom r0 bits out of src2

	mov	$32,r2
	sub	r0,r2		;32-r0
	shl	r2,r1		;shift copy of src2 <-- by 32-r0
	or	r1,src2
	
	mov	WAINST(instcheck),rip 

lslr:
	mov	curinst,r0	;left shift reg	
	and	$15,r0
	shl	WARGS(r0),src2

	mov	WAINST(instcheck),rip 

lsrr:
	mov	curinst,r0	;right shift reg (log)
	and	$15,r0
	shr	WARGS(r0),src2

	mov	WAINST(instcheck),rip 

asrr:
	mov	curinst,r0	;right shift reg arithm
	and	$15,r0
	sar	WARGS(r0),src2

	mov	WAINST(instcheck),rip 

rorr:
	mov	curinst,r0	;rotate right reg
	and	$15,r0
	
	mov	src2,r1
	shr	WARGS(r0),src2
	mov	$32,r2
	sub	WARGS(r0),r2
	shl	r2,r1
	or	r1,src2

	mov	WAINST(instcheck),rip 

value:
	mov	curinst,src2	;get value

	mov	curinst,r1	;Get the exponent
	shr	$9,r1		
	and	$0x1F,r1	;Exponent is in r1

	and	$0x1FF,src2	
	shl	r1,src2		;shift left by exponent

check:	mov	WAINST(instcheck),rip 
	
wadd:
	add	$1,WAR15	;add
	add	src2,src1
	mov	src1,WARGS(dest)
	jmp	loop
	
wadc:
	add	$1,WAR15	;add w/ carry
	add	src2,src1
	mov	WACCR,r0
	and	$2,r0
	shr	$1,r0
	add	r0,src1
	mov	src1,WARGS(dest)
	jmp	loop
	
wsub:
	add	$1,WAR15	;subtract
	sub	src2,src1
	mov	src1,WARGS(dest)
	jmp	loop

wcmp:
	add	$1,WAR15		;compare
	cmp	src2,src1
	mov	ccr,WACCR
	jmp	loop
	
weor:
	add	$1,WAR15		;xor
	xor	src2,src1
	mov	src1,WARGS(dest)
	jmp	loop
	
worr:
	add	$1,WAR15	;or
	or	src2,src1
	mov	src1,WARGS(dest)
	jmp	loop
	
wand:
	add	$1,WAR15	;and
	and	src2,src1
	mov	src1,WARGS(dest)
	jmp	loop

wtst:
	add	$1,WAR15	;test
	test	src2,src1
	mov	ccr,WACCR
	jmp	loop

wmul:
	add	$1,WAR15	;multiply
	mul	src2,src1
	mov	src1,WARGS(dest)
	jmp	loop
wmla:
	add	$1,WAR15	;multiply add
	mul	src3,src2
	add	src2,src1
	mov	src1,WARGS(dest)
	jmp	loop
	
wdiv:
	add	$1,WAR15	;divide
	div	src2,src1
	mov	src1,WARGS(dest)
	jmp	loop
	
wmov:	
	add	$1,WAR15			;mov
	mov	src2,WARGS(dest)
	jmp	loop

wmvn:
	add	$1,WAR15	;mov negative
	xor	$0xFFFFFFFF,src2
	mov	src2,WARGS(dest)
	jmp	loop
	
wldm:
	mov	WARGS(dest),r2		;LDM
	and	$0xFFFFFF,r2
	mov	src2,r0		
	and	$1,r0
	je	next1
	
	mov	WARM(r2),WAR0
	add	$1,r2
	
next1:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	next2

	mov	WARM(r2),WAR1
	add	$1,r2

next2:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	next3

	mov	WARM(r2),WAR2
	add	$1,r2	

next3:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	next4

	mov	WARM(r2),WAR3
	add	$1,r2

next4:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	next5

	mov	WARM(r2),WAR4
	add	$1,r2

next5:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	next6

	mov	WARM(r2),WAR5
	add	$1,r2

next6:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	next7

	mov	WARM(r2),WAR6
	add	$1,r2

next7:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	next8

	mov	WARM(r2),WAR7
	add	$1,r2

next8:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	next9

	mov	WARM(r2),WAR8
	add	$1,r2

next9:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	next10

	mov	WARM(r2),WAR9
	add	$1,r2

next10:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	next11

	mov	WARM(r2),WAR10
	add	$1,r2	
	
next11:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	next12

	mov	WARM(r2),WAR11
	add	$1,r2

next12:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	next13

	mov	WARM(r2),WAR12
	add	$1,r2	

next13:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	next14

	mov	WARM(r2),WAR13
	add	$1,r2

next14:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	next15

	mov	WARM(r2),WAR14
	add	$1,r2

next15:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	jne	final

	add	$1,WAR15
	mov	r2,WARGS(dest)
	jmp	loop

final:
	mov	WARM(r2),WAR15
	add	$1,r2
	mov	r2,WARGS(dest)
	jmp 	loop
	
wstm:	
	mov	WARGS(dest),r2	;WSTM
	and	$0xFFFFFF,r2 	

	mov	src2,r0
	and	$0x8000,r0
	je	snxt1
	
	sub	$1,r2
	mov	WAR15,WARM(r2)

	mov	WACCR,r0
	shl	$28,r0
	or	r0,WARM(r2)
	
snxt1:
	shl	$1,src2

	mov	src2,r0
	and	$0x8000,r0
	je	snxt2

	sub	$1,r2
	mov	WAR14,WARM(r2)

snxt2:
	shl	$1,src2

	mov	src2,r0
	and	$0x8000,r0
	je	snxt3

	sub	$1,r2
	mov	WAR13,WARM(r2)

snxt3:
	shl	$1,src2

	mov	src2,r0
	and	$0x8000,r0
	je	snxt4

	sub	$1,r2
	mov	WAR12,WARM(r2)

snxt4:
	shl	$1,src2

	mov	src2,r0
	and	$0x8000,r0
	je	snxt5

	sub	$1,r2
	mov	WAR11,WARM(r2)

snxt5:	shl	$1,src2

	mov	src2,r0
	and	$0x8000,r0
	je	snxt6

	sub	$1,r2
	mov	WAR10,WARM(r2)

snxt6:	shl	$1,src2

	mov	src2,r0
	and	$0x8000,r0
	je	snxt7

	sub	$1,r2
	mov	WAR9,WARM(r2)

snxt7:	shl	$1,src2

	mov	src2,r0
	and	$0x8000,r0
	je	snxt8

	sub	$1,r2
	mov	WAR8,WARM(r2)

snxt8:	shl	$1,src2

	mov	src2,r0
	and	$0x8000,r0
	je	snxt9

	sub	$1,r2
	mov	WAR7,WARM(r2)

snxt9:	shl	$1,src2

	mov	src2,r0
	and	$0x8000,r0
	je	snxt10

	sub	$1,r2
	mov	WAR6,WARM(r2)

snxt10:	shl	$1,src2

	mov	src2,r0
	and	$0x8000,r0
	je	snxt11

	sub	$1,r2
	mov	WAR5,WARM(r2)

snxt11:	shl	$1,src2

	mov	src2,r0
	and	$0x8000,r0
	je	snxt12

	sub	$1,r2
	mov	WAR4,WARM(r2)

snxt12:	shl	$1,src2

	mov	src2,r0
	and	$0x8000,r0
	je	snxt13

	sub	$1,r2
	mov	WAR3,WARM(r2)

snxt13:	shl	$1,src2

	mov	src2,r0
	and	$0x8000,r0
	je	snxt14

	sub	$1,r2
	mov	WAR2,WARM(r2)

snxt14:	shl	$1,src2

	mov	src2,r0
	and	$0x8000,r0
	je	snxt15

	sub	$1,r2
	mov	WAR1,WARM(r2)

snxt15:	shl	$1,src2

	mov	src2,r0
	and	$0x8000,r0
	je	finsal

	sub	$1,r2
	mov	WAR0,WARM(r2)

finsal:
	add	$1,WAR15
	mov	r2,WARGS(dest)
	jmp	loop
		
	
	
wldr:
	mov	WARGS(src1),src1 	;LDR
	add	src1,src2
	and	$0xFFFFFF,src2

	add	$1,WAR15
	
	mov	WARM(src2),WARGS(dest)
	
	jmp	loop
	
wstr:
	mov	WARGS(src1),src1 	;STR
	add	src1,src2
	and	$0xFFFFFF,src2

	add	$1,WAR15
	
	mov	WARGS(dest),WARM(src2)

	jmp	loop
	
wldu:
	or	$0,src2		;LDU
	jl	negldu

	and	$0xFFFFFF,WARGS(src1)
	mov	WARGS(src1),r0
	add	$1,WAR15
	mov	WARM(r0),WARGS(dest)
	add	src2,WARGS(src1)

	jmp	loop
	
negldu:
	add	WARGS(src1),src2 	;NEGLDU
	and	$0xFFFFFF,src2

	add	$1,WAR15
	
	mov	WARM(src2),WARGS(dest)
	mov	src2,WARGS(src1)
	jmp	loop
	
wstu:
	or	$0,src2		;STU
	jl	negstu

	mov	WARGS(src1),r0
	and	$0xFFFFFF,r0

	mov	WARGS(dest),WARM(r0)
	add	$1,WAR15
	add	src2,WARGS(src1)
	and	$0xFFFFFF,WARGS(src1)
	jmp	loop
	
negstu:
	add	WARGS(src1),src2 	;NEGSTU
	and	$0xFFFFFF,src2
	
	mov	WARGS(dest),WARM(src2)
	add	$1,WAR15
	mov	src2,WARGS(src1)
	jmp	loop
	
wadr:
	mov	WARGS(src1),src1	;adr
	add	src1,src2
	and	$0xFFFFFF, src2
	add	$1,WAR15
	mov	src2,WARGS(dest) 
	jmp	loop
		
swi:
	mov	WAR0,r0		;TRAP
	trap	src2
	mov	r0,WAR0
	add	$1,WAR15
	jmp	loop
	
wadds:
	add	$1,WAR15	;add set
	add	src2,src1
	mov	ccr,WACCR
	mov	src1,WARGS(dest)
	jmp	loop
	
wadcs:
	add	$1,WAR15	;add w/ carry set
	add	src2,src1
	mov	WACCR,r0
	and	$2,r0
	shr	$1,r0
	add	r0,src1
	mov	ccr,WACCR
	mov	src1,WARGS(dest)
	jmp	loop
	
wsubs:
	add	$1,WAR15	;subtract set
	sub	src2,src1
	mov	ccr,WACCR
	mov	src1,WARGS(dest)
	jmp	loop
	
weors:
	add	$1,WAR15	;xor set
	xor	src2,src1
	mov	ccr,WACCR
	mov	src1,WARGS(dest)
	jmp	loop
	
worrs:
	add	$1,WAR15	;or set
	or	src2,src1
	mov	ccr,WACCR
	mov	src1,WARGS(dest)
	jmp	loop
	
wands:
	add	$1,WAR15	;and set
	and	src2,src1
	mov	ccr,WACCR
	mov	src1,WARGS(dest)
	jmp	loop

wmuls:
	add	$1,WAR15	;multiply set
	mul	src2,src1
	mov	ccr,WACCR
	mov	src1,WARGS(dest)
	jmp	loop

wmlas:
	add	$1,WAR15	;multiply add set
	mul	src3,src2
	add	src2,src1
	mov	ccr,WACCR
	mov	src1,WARGS(dest)
	jmp	loop
	
wdivs:
	add	$1,WAR15			;divide set
	div	src2,src1
	mov	ccr,WACCR
	mov	src1,WARGS(dest)
	jmp	loop
	
wmovs:	
	add	$1,WAR15			;mov set
	mov	src2,WARGS(dest)
	or	$0,src2
	mov	ccr,WACCR
	jmp	loop

wmvns:
	add	$1,WAR15			;mov neg set
	xor	$0xFFFFFFFF,src2
	mov	src2,WARGS(dest)
	or	$0,src2
	mov	ccr,WACCR
	jmp	loop
	
wldms:
	mov	WARGS(dest),r2 		;LDMS
	and	$0xFFFFFF,r2
	mov	src2,r0		
	and	$1,r0
	je	nxts1
	
	mov	WARM(r2),WAR0
	add	$1,r2
	
nxts1:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	nxts2

	mov	WARM(r2),WAR1
	add	$1,r2

nxts2:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	nxts3

	mov	WARM(r2),WAR2
	add	$1,r2	

nxts3:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	nxts4

	mov	WARM(r2),WAR3
	add	$1,r2

nxts4:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	nxts5

	mov	WARM(r2),WAR4
	add	$1,r2

nxts5:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	nxts6

	mov	WARM(r2),WAR5
	add	$1,r2

nxts6:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	nxts7

	mov	WARM(r2),WAR6
	add	$1,r2

nxts7:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	nxts8

	mov	WARM(r2),WAR7
	add	$1,r2

nxts8:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	nxts9

	mov	WARM(r2),WAR8
	add	$1,r2

nxts9:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	nxts10

	mov	WARM(r2),WAR9
	add	$1,r2

nxts10:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	nxts11

	mov	WARM(r2),WAR10
	add	$1,r2	
	
nxts11:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	nxts12

	mov	WARM(r2),WAR11
	add	$1,r2

nxts12:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	nxts13

	mov	WARM(r2),WAR12
	add	$1,r2	

nxts13:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	nxts14

	mov	WARM(r2),WAR13
	add	$1,r2

nxts14:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	je	nxts15

	mov	WARM(r2),WAR14
	add	$1,r2

nxts15:
	shr	$1,src2
	mov	src2,r0			
	and	$1,r0
	jne	final2

	add	$1,WAR15
	mov	r2,WARGS(dest)
	jmp	loop

final2:
	mov	WARM(r2),WAR15

	or	$0,WAR15
	mov	ccr,WACCR
	
	add	$1,r2
	mov	r2,WARGS(dest)
	jmp 	loop		
	
wldrs:
	mov	WARGS(src1), src1 	;LDRS
	add	src1,src2
	and	$0xFFFFFF,src2

	add	$1,WAR15
	
	mov	WARM(src2),WARGS(dest)
	or	$0,WARGS(dest)
	mov	ccr,WACCR
	
	jmp	loop
	
wstrs:
	add	WARGS(src1),src2 	;STRS
	and	$0xFFFFFF,src2

	mov	WARGS(dest),WARM(src2)

	add	$1,WAR15
	
	or	$0,WARGS(dest)
	mov	ccr,WACCR

	jmp	loop
	
wldus:
	or	$0,src2		;LDUS
	jl	negldus

	and	$0xFFFFFF,WARGS(src1)
	mov	WARGS(src1),r0
	
	add	$1,WAR15
	
	mov	WARM(r0),WARGS(dest)
	add	src2,WARGS(src1)
	
	or 	$0,WARGS(dest)
	mov	ccr,WACCR
	
	jmp	loop
	
negldus:
	add	WARGS(src1),src2 	;LDUSNEG
	and	$0xFFFFFF,src2

	add	$1,WAR15	
	
	mov	WARM(src2),WARGS(dest)
	
	or 	$0,WARGS(dest)
	mov	ccr,WACCR

	mov	src2,WARGS(src1)
	jmp	loop
	
	
wstus:
	or	$0,src2		;LDU
	jl	negstus

	mov	WARGS(src1),r0
	and	$0xFFFFFF,r0
	mov	WARGS(dest),WARM(r0)

	add	$1,WAR15
	
	or	$0,WARGS(dest)
	mov	ccr,WACCR
	
	add	src2,WARGS(src1)
	and	$0xFFFFFF,WARGS(src1)
	jmp	loop
	
negstus:
	add	WARGS(src1),src2 	;NEGLDU
	and	$0xFFFFFF,src2
	mov	WARGS(dest),WARM(src2)

	add	$1,WAR15
	
	or	$0,WARGS(dest)
	mov	ccr,WACCR
	
	mov	src2,WARGS(src1)
	jmp	loop
	
	
swis:
	mov	WAR0,r0		;TRAP
	trap	src2
	mov	r0,WAR0
	or	$0,r0
	mov	ccr,WACCR
	add	$1,WAR15
	jmp	loop
	
gbase:
	mov	curinst,src1	;get the first source
	shr	$15,src1
	and	$15,src1	    ;found which register
	
gindex:
	mov	curinst,dest	;get destination
	shr	$19,dest
	and	$15,dest	

	mov	curinst,r1	
	test	$0x4000,r1	;check if the 14th bit has a 1 in it
	je	value2		;if it does, then get the value
	
	mov	curinst,src2	;otherwise find the second source
	shr	$6, src2
	and	$15, src2
	mov	WARGS(src2),src2 ;get the value of the second source
	
	mov	curinst,r1
	shr	$10,r1
	and	$15,r1
	mov	WASHFT(r1), rip

value2:
	mov	curinst,src2	;get value
	and	$0x3FFF,src2
	shl	$18,src2
	sar	$18,src2
	
	mov	WAINST(instcheck),rip 
	

WAINST:				
	.data	wadd, wadc, wsub, wcmp, weor, worr, wand, wtst, wmul, wmla, wdiv, wmov, wmvn, swi, wldm, wstm, wldr, wstr, wldu, wstu, wadr, 0, 0, 0, branch, branch, bl, bl,0,0,0,0,wadds, wadcs, wsubs, wcmp, weors, worrs, wands, wtst, wmuls, wmlas, wdivs, wmovs, wmvns, swis, wldms, wstm, wldrs, wstrs, wldus, wstus, wadr, 0, 0, 0, branch, branch, bl, bl,0,0,0,0

WADEC:
	.data	gsrc1, gsrc1, gsrc1, gsrc1, gsrc1, gsrc1, gsrc1, gsrc1, gsrc1, gsrc3, gsrc1, gdest, gdest, gsrc2, gdest, gdest, gbase, gbase, gbase, gbase, gbase, 0, 0, 0, branch, branch, bl, bl,0,0,0,0,gsrc1, gsrc1, gsrc1, gsrc1, gsrc1, gsrc1, gsrc1, gsrc1, gsrc1, gsrc3, gsrc1, gdest, gdest, gsrc2, gdest, gdest, gbase, gbase, gbase, gbase, gbase, 0, 0, 0, branch, branch, bl, bl,0,0,0,0
	
WASHFT:
	.data	lslv,lsrv,asrv,rorv,lslr,lsrr,asrr,rorr,check,check,check,check,check,check,check,check
	
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

WACNDS:	
	.data	always,nv,eq,ne,lt,le,ge,gt

;WASETS:
;	.data	0,s
	
WARM: