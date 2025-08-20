var
  p: NativeInt;
asm
    push    rbx
    push    rsi
    push    rdi

    mov     rsi, rdx
    mov     p, rcx
    xor     rbx, rbx

    mov     rax, $0000000100000000
    cmp     rsi, rax
    jb      @Lb027

    mov     rax, $00005af3107a4000    // 00000000006F3D0E  48B800407A10F35A0000    //
    cmp     rsi, rax    // 00000000006F3D18  48394558
    jb      @Lb022    // 00000000006F3D1C  0F8282000000
    // if AValue >= 10000000000000000 then
    mov     rax, $002386f26fc10000    // 00000000006F3D22  48B80000C16FF2862300    //
    cmp     rsi, rax    // 00000000006F3D2C  48394558
    jb      @Lb021    // 00000000006F3D30  7255
    // if AValue >= 1000000000000000000 then
    mov     rax, $0de0b6b3a7640000    // 00000000006F3D32  48B8000064A7B3B6E00D    //
    cmp     rsi, rax    // 00000000006F3D3C  48394558
    jb      @Lb020    // 00000000006F3D40  7228
    // if AValue >= 10000000000000000000 then _len := 20
    mov     rax, $8ac7230489e80000    // 00000000006F3D42  48B80000E8890423C78A    //
    cmp     rsi, rax    // 00000000006F3D4C  48394558
    jb      @Lb019    // 00000000006F3D50  720C
    mov     bl, $14    // 00000000006F3D52  C7453814000000
    jmp     @Lb025    // 00000000006F3D59  E9A7000000
  @Lb019:
    // else _len := 19
    mov     bl, $13    // 00000000006F3D5E  C7453813000000
    jmp     @Lb025    // 00000000006F3D65  E99B000000
  @Lb020:
    // else _len := 17 + Ord(AValue >= 100000000000000000)
    mov     rax, $016345785d8a0000    // 00000000006F3D6A  48B800008A5D78456301    //
    cmp     rsi, rax    // 00000000006F3D74  48394558
    setnb   bl    // 00000000006F3D78  0F93C0
    add     bl, $11    // 00000000006F3D7F  83C011
    jmp     @Lb025    // 00000000006F3D85  EB7E
  @Lb021:
    // else _len := 15 + Ord(AValue >= 1000000000000000)
    mov     rax, $00038d7ea4c68000    // 00000000006F3D87  48B80080C6A47E8D0300    //
    cmp     rsi, rax    // 00000000006F3D91  48394558
    setnb   bl    // 00000000006F3D95  0F93C0
    add     bl, $0f    // 00000000006F3D9C  83C00F
    jmp     @Lb025    // 00000000006F3DA2  EB61
  @Lb022:
    // else if AValue >= 1000000000000 then _len := 13 + Ord(AValue >= 10000000000000)    //
    mov     rax, $000000e8d4a51000    // 00000000006F3DA4  48B80010A5D4E8000000    //
    cmp     rsi, rax    // 00000000006F3DAE  48394558
    jb      @Lb023    // 00000000006F3DB2  721D
    mov     rax, $000009184e72a000    // 00000000006F3DB4  48B800A0724E18090000    //
    cmp     rsi, rax    // 00000000006F3DBE  48394558
    setnb   bl    // 00000000006F3DC2  0F93C0
    add     bl, $0d    // 00000000006F3DC9  83C00D
    jmp     @Lb025    // 00000000006F3DCF  EB34
  @Lb023:
    // else if AValue >= 10000000000 then _len := 11 + Ord(AValue >= _len := 10;    // 100000000000)  else
    mov     rax, $00000002540be400    // 00000000006F3DD1  48B800E40B5402000000    //
    cmp     rsi, rax    // 00000000006F3DDB  48394558
    jb      @Lb024
    mov     rax, $000000174876e800    // 00000000006F3DE1  48B800E8764817000000    //
    cmp     rsi, rax    // 00000000006F3DEB  48394558
    setnb   bl    // 00000000006F3DEF  0F93C0
    add     bl, $0b    // 00000000006F3DF6 83C00B
    jmp     @Lb025    // 00000000006F3DFC EB07
  @Lb024:
    mov     bl, $0a    // 00000000006F3DFE C745380A000000

  @Lb025:
    mov     rcx, 2 + TKRStrRec_sz
  	add     rcx, rbx
    and     ecx, $FFFFFFFE
    push    rcx
    call    SysGetMem
    pop     rcx
    add     rcx, rax
    mov     word ptr [ rcx - 2 ], 0
    mov     [ rax ].TKRStrRec.length, ebx
    mov     [ rax ].TKRStrRec.refCnt, 1
    mov     ecx, KRDefaultSystemCodePage
    mov     word ptr [ rax ].TKRStrRec.codePage, cx
    mov     word ptr [ rax ].TKRStrRec.elemSize, 1
    add     rax, TKRStrRec_sz
    mov     rcx, p
    mov     [ rcx ], rax
    mov     rdi, rax
    mov     rax, rsi
  @Lb026:
    cmp     bl, 9
    jbe     @Lb006
    mov     rcx, $00000064
    xor     rdx, rdx
    div     rcx
    sub     bl, 2
    shl     rdx, 1
    lea     rcx, KRTwoDigitA
    add     rcx, rdx
    mov     cx, [ rcx ]
    mov     [ rdi + rbx ], cx
    jmp     @Lb026

  @lb027:
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
    mov     rcx, 2 + TKRStrRec_sz
  	add     rcx, rbx
    and     ecx, $FFFFFFFE
    push    rcx
    call    SysGetMem
    pop     rcx
    add     rcx, rax
    mov     word ptr [ rcx - 2 ], 0
    mov     [ rax ].TKRStrRec.length, ebx
    mov     [ rax ].TKRStrRec.refCnt, 1
    mov     ecx, KRDefaultSystemCodePage
    mov     word ptr [ rax ].TKRStrRec.codePage, cx
    mov     word ptr [ rax ].TKRStrRec.elemSize, 1
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
    shl     rdx, 1
    lea     rcx, KRTwoDigitA
    add     rcx, rdx
    mov     cx, [ rcx ]
    mov     [ rdi + rbx ], cx
    jmp     @Lb006
  @Lb007:
    jne     @Lb008
    shl     rax, 1
    lea     rcx, KRTwoDigitA
    add     rcx, rax
    mov     cx, [ rcx ]
    mov     [ rdi ], cx
    jmp     @Lb009
  @Lb008:
    or      al, '0'
    mov     [ rdi ], al
  @Lb009:


    mov     rax, p
    pop     rdi
    pop     rsi
    pop     rbx

end;
