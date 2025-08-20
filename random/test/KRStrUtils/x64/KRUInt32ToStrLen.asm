                                                           var
  p: NativeInt;
asm
    push    rbx
    push    rsi
    push    rdi

    mov     esi, edx
    mov     p, rcx
    xor     rbx, rbx

    cmp     esi, $00002710
    jb      @Lb003
    cmp     esi, $000f4240
    jb      @Lb002
    cmp     esi, $05f5e100
    jb      @Lb001
    cmp     esi, $3b9aca00
    setnb   bl
    add     bl, $09
    jmp     @Lb005
  @Lb001:
    cmp     esi, $00989680
    setnb   bl
    add     bl, $07
    jmp     @Lb005
  @Lb002:
    cmp     esi, $000186a0
    setnb   bl
    add     bl, $05
    jmp     @Lb005
  @Lb003:
    cmp     esi, $00000064
    jb      @Lb004
    cmp     esi, $000003e8
    setnb   bl
    add     bl, $03
    jmp     @Lb005
  @Lb004:
    cmp     esi, $0000000a
    setnb   bl
    inc     bl
  @Lb005:
    cmp     rbx, r8
    jnb     @Lb005_2
    mov	    rcx, r8
    shl     rcx, 1
    add     rcx, 2 + TKRStrRec_sz
    push    r8
    push    rcx
    call    SysGetMem
    pop     rcx
    pop     r8
    add     rcx, rax
    mov     word ptr [ rcx - 2 ], 0
    mov     [ rax ].TKRStrRec.length, r8d
    mov     [ rax ].TKRStrRec.refCnt, 1
    mov     ecx, KRDefaultUnicodeCodePage
    mov     word ptr [ rax ].TKRStrRec.codePage, cx
    mov     word ptr [ rax ].TKRStrRec.elemSize, 2
    add     rax, TKRStrRec_sz
    mov     rcx, p
    mov     [ rcx ], rax
    mov     rdi, rax
    mov     eax, esi
  @Lb005_1:
    mov     word ptr [ rdi ], '0'
    add     rdi, 2
    dec     r8
    cmp     rbx, r8
    jnb     @Lb006
    jmp     @Lb005_1
  @Lb005_2:
    mov	    rcx, rbx
    shl     rcx, 1
    add     rcx, 2 + TKRStrRec_sz
    push    rcx
    call    SysGetMem
    pop     rcx
    add     rcx, rax
    mov     word ptr [ rcx - 2 ], 0
    mov     [ rax ].TKRStrRec.length, ebx
    mov     [ rax ].TKRStrRec.refCnt, 1
    mov     ecx, KRDefaultUnicodeCodePage
    mov     word ptr [ rax ].TKRStrRec.codePage, cx
    mov     word ptr [ rax ].TKRStrRec.elemSize, 2
    add     rax, TKRStrRec_sz
    mov     rcx, p
    mov     [ rcx ], rax
    mov     rdi, rax
    mov     eax, esi
  @Lb006:
    cmp     bl, 2
    jbe     @Lb007
    mov     ecx, $00000064
    xor     rdx, rdx
    div     ecx
    sub     bl, 2
    shl     rdx, 2
    lea     rcx, KRTwoDigit
    add     rcx, rdx
    mov     ecx, [ rcx ]
    mov     [ rdi + rbx * 2 ], ecx
    jmp     @Lb006
  @Lb007:
    jne     @Lb008
    shl     rax, 2
    lea     rcx, KRTwoDigit
    add     rcx, rax
    mov     ecx, [ rcx ]
    mov     [ rdi ], ecx
    jmp     @Lb009
  @Lb008:
    or      ax, '0'
    mov     [ rdi ], ax
  @Lb009:

    mov     rax, p
    pop     rdi
    pop     rsi
    pop     rbx
end;
