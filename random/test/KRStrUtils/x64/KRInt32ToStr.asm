var
  p: NativeInt;
  b: NativeInt;
asm
    push    rbx
    push    rsi
    push    rdi

    mov     p, rcx
    xor     rbx, rbx

    cmp     edx, 0
    jl      @Lb000
    mov     esi, edx
    mov     b, 0
    jmp     @Lb000_1
  @Lb000:
    neg     edx
    mov     esi, edx
    mov     b, 1
  @Lb000_1:

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
    add     rbx, b
    mov     rcx, rbx
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
    sub     rbx, b
    mov     ax, '-'
    mov     [ rdi ], ax
    add     rdi, b
    add     rdi, b
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
