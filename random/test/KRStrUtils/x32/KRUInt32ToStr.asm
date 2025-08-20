var
  p: NativeInt;
asm
    push    ebx
    push    esi
    push    edi

    mov     esi, eax
    mov     p, edx
    xor     ebx, ebx

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
    lea     eax, [ ebx * 2 + 2 + TKRStrRec_sz ]
    push    eax
    call    SysGetMem
    pop     ecx
    mov     word ptr [ eax + ecx - 2 ], 0
    mov     [ eax ].TKRStrRec.length, ebx
    mov     [ eax ].TKRStrRec.refCnt, 1
    mov     ecx, KRDefaultUnicodeCodePage
    mov     word ptr [ eax ].TKRStrRec.codePage, cx
    mov     word ptr [ eax ].TKRStrRec.elemSize, 2
    add     eax, TKRStrRec_sz
    mov     ecx, p
    mov     [ ecx ], eax
    mov     edi, eax
    mov     eax, esi
  @Lb006:
    cmp     bl, 2
    jbe     @Lb007
    mov     ecx, $00000064
    xor     edx, edx
    div     ecx
    sub     bl, 2
    mov     ecx, dword ptr KRTwoDigit[ edx * 4 ]
    mov     [ edi + ebx * 2 ], ecx
    jmp     @Lb006
  @Lb007:
    jne     @Lb008
    mov     ecx, dword ptr KRTwoDigit[ eax * 4 ]
    mov     [ edi ], ecx
    jmp     @Lb009
  @Lb008:
    or      ax, '0'
    mov     [ edi ], ax
  @Lb009:

    mov     eax, p
    pop     edi
    pop     esi
    pop     ebx
end;
