var
  p: NativeInt;
  b: uint32;
asm
    push    ebx
    push    esi
    push    edi

    xor     ebx, ebx
    mov     p, eax
    mov     edx, [ ebp + $0c ]

    cmp     edx, 0
    jl      @Lb000
    mov     b, 0
    jmp     @Lb000_1
  @Lb000:
    mov     eax, [ ebp + $08 ]
    neg     eax
    adc     edx, $00
    neg     edx
    mov     [ ebp + $08 ], eax
    mov     [ ebp + $0c ], edx
    mov     b, 1
  @Lb000_1:

    cmp     edx, 0
    je      @Lb009

    mov     eax, [ ebp + $08 ]
    cmp     edx, $00005af3    // 005FD0DF  817D0CF35A0000
    jnz     @Lb010    // 005FD0E6  7507
    cmp     eax, $107a4000    // 005FD0E8  817D0800407A10
  @Lb010:
    jb      @Lb011//$005fd17f    // 005FD0EF  0F828A000000
    cmp     edx, $002386f2    // 005FD0F5  817D0CF2862300
    jnz     @Lb012//$005fd105    // 005FD0FC  7507
    cmp     eax, $6fc10000    // 005FD0FE  817D080000C16F
  @Lb012:
    jb      @Lb013//$005fd161    // 005FD105  725A
    cmp     edx, $0de0b6b3    // 005FD107  817D0CB3B6E00D
    jnz     @Lb014//$005fd117    // 005FD10E  7507
    cmp     eax, $a7640000    // 005FD110  817D08000064A7
  @Lb014:
    jb      @Lb015//$005fd143    // 005FD117  722A
    cmp     edx, $8ac72304    // 005FD119  817D0C0423C78A
    jnz     @Lb016//$005fd129    // 005FD120  7507
    cmp     eax, $89e80000    // 005FD122  817D080000E889
  @Lb016:
    jb      @Lb025//$005fd137    // 005FD129  720C
    mov     bl, $14    // 005FD12B  C745F414000000
    jmp     @Lb017//$005fd1e0    // 005FD132  E9A9000000
  @Lb025:
    mov     bl, $13    // 005FD137  C745F413000000
    jmp     @Lb017    // 005FD13E  E99D000000
  @Lb015:
    cmp     edx, $01634578    // 005FD143  817D0C78456301
    jnz     @Lb018//$005fd153    // 005FD14A  7507
    cmp     eax, $5d8a0000    // 005FD14C  817D0800008A5D
  @Lb018:
    setnb   bl    // 005FD153  0F93C0
    add     bl, $11    // 005FD159  83C011
    jmp     @Lb017    // 005FD15F  EB7F
  @Lb013:
    cmp     edx, $00038d7e    // 005FD161  817D0C7E8D0300
    jnz     @Lb019//$005fd171    // 005FD168  7507
    cmp     eax, $a4c68000    // 005FD16A  817D080080C6A4
  @Lb019:
    setnb   bl    // 005FD171  0F93C0
    add     bl, $0f    // 005FD177  83C00F
    jmp     @Lb017    // 005FD17D  EB61
  @Lb011:
    cmp     edx, $000000e8    // 005FD17F  817D0CE8000000
    jnz     @Lb020//$005fd18f    // 005FD186  7507
    cmp     eax, $d4a51000    // 005FD188  817D080010A5D4
  @Lb020:
    jb      @Lb021//$005fd1af    // 005FD18F  721E
    cmp     edx, $00000918    // 005FD191  817D0C18090000
    jnz     @Lb022//$005fd1a1    // 005FD198  7507
    cmp     eax, $4e72a000    // 005FD19A  817D0800A0724E
  @Lb022:
    setnb   bl    // 005FD1A1  0F93C0
    add     bl,$0d    // 005FD1A7  83C00D
    jmp     @Lb017    // 005FD1AD  EB31
  @Lb021:
    cmp     edx, $02    // 005FD1AF  837D0C02
    jnz     @Lb023//$005fd1bc    // 005FD1B3  7507
    cmp     eax, $540be400    // 005FD1B5  817D0800E40B54
  @Lb023:
    jb      @Lb024//$005fd1d9    // 005FD1BC  721B
    cmp     edx,  $17    // 005FD1BE  837D0C17
    jnz     @Lb025_1//$005fd1cb    // 005FD1C2  7507
    cmp     eax, $4876e800    // 005FD1C4  817D0800E87648
  @Lb025_1:
    setnb   bl    // 005FD1CB  0F93C0
    add     bl, $0b    // 005FD1D1  83C00B
    jmp     @Lb017    // 005FD1D7  EB07
  @Lb024:
    mov     bl, $0a    // 005FD1D9  C745F40A000000
  @Lb017:
    add     ebx, b
    lea     eax, [ ebx + 2 + TKRStrRec_sz ]
    and     eax, $FFFFFFFE
    push    eax
    call    SysGetMem
    pop     ecx
    mov     word ptr [ eax + ecx - 2 ], 0
    mov     [ eax ].TKRStrRec.length, ebx
    mov     [ eax ].TKRStrRec.refCnt, 1
    mov     ecx, KRDefaultSystemCodePage
    mov     word ptr [ eax ].TKRStrRec.codePage, cx
    mov     word ptr [ eax ].TKRStrRec.elemSize, 1
    add     eax, TKRStrRec_sz
    mov     ecx, p
    mov     [ ecx ], eax
    mov     edi, eax
    sub     ebx, b
    mov     al, '-'
    mov     [ edi ], al
    add     edi, b
    mov     eax, [ebp+$08]
    mov     edx, [ebp+$0c]
  @Lb026:
    cmp     bl, 9
    jbe     @Lb006

    push    ebp
    push    ebx
    push    esi
    push    edi
    mov     ebx, $64   // low divisor
  @__lludiv@slow_ldiv:
    xor     ebp, ebp  // high divisor
    mov     ecx, 64
    xor     edi, edi
    xor     esi, esi
  @__lludiv@xloop:
    shl     eax, 1
    rcl     edx, 1
    rcl     esi, 1
    rcl     edi, 1
    cmp     edi, ebp
    jb      @__lludiv@nosub
    ja      @__lludiv@subtract
    cmp     esi, ebx
    jb      @__lludiv@nosub
  @__lludiv@subtract:
    sub     esi, ebx
    sbb     edi, ebp
    inc     eax
  @__lludiv@nosub:
    loop    @__lludiv@xloop
  @__lludiv@finish:
    mov     ecx, esi
    pop     edi
    pop     esi
    pop     ebx
    pop     ebp

    sub     bl, 2
    mov     cx, word ptr KRTwoDigitA[ ecx * 2 ]
    mov     [ edi + ebx ], cx
    jmp     @Lb026

  @Lb009:
    mov     esi, [ ebp + $08 ]
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
    add     ebx, b
    lea     eax, [ ebx + 2 + TKRStrRec_sz ]
    and     eax, $FFFFFFFE
    push    eax
    call    SysGetMem
    pop     ecx
    mov     word ptr [ eax + ecx - 2 ], 0
    mov     [ eax ].TKRStrRec.length, ebx
    mov     [ eax ].TKRStrRec.refCnt, 1
    mov     ecx, KRDefaultSystemCodePage
    mov     word ptr [ eax ].TKRStrRec.codePage, cx
    mov     word ptr [ eax ].TKRStrRec.elemSize, 1
    add     eax, TKRStrRec_sz
    mov     ecx, p
    mov     [ ecx ], eax
    mov     edi, eax
    sub     ebx, b
    mov     al, '-'
    mov     [ edi ], al
    add     edi, b
    mov     eax, esi
  @Lb006:
    cmp     bl, 2
    jbe     @Lb007
    mov     ecx, $00000064
    xor     edx, edx
    div     ecx
    sub     bl, 2
    mov     cx, word ptr KRTwoDigitA[ edx * 2 ]
    mov     [ edi + ebx ], cx
    jmp     @Lb006
  @Lb007:
    jne     @Lb008
    mov     cx, word ptr KRTwoDigitA[ eax * 2 ]
    mov     [ edi ], cx
    jmp     @Exit
  @Lb008:
    or      al, '0'
    mov     [ edi ], al

  @Exit:
    mov     eax, p
    pop     edi
    pop     esi
    pop     ebx
end;
