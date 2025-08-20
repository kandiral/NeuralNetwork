asm
    push    edi
    push    ebx

    mov     edi, edx
    mov     ebx, eax

    mov     eax, 10 + TKRStrRec_sz
    call    SysGetMem
    mov     word ptr [ eax + TKRStrRec_sz + 8 ], 0
    mov     [ eax ].TKRStrRec.length, 8
    mov     [ eax ].TKRStrRec.refCnt, 1
    mov     ecx, KRDefaultSystemCodePage
    mov     word ptr [ eax ].TKRStrRec.codePage, cx
    mov     word ptr [ eax ].TKRStrRec.elemSize, 1
    add     eax, TKRStrRec_sz
    mov     [ edi ], eax

    mov     ecx, ebx
    shr     ecx, 24
    mov     cx, word ptr KRTwoHexAL[ ecx * 2 ]
    mov     [ eax ], cx
    mov     ecx, ebx
    shr     ecx, 16
    and     ecx, $ff
    mov     cx, word ptr KRTwoHexAL[ ecx * 2 ]
    add     eax, 2
    mov     [ eax ], cx
    mov     ecx, ebx
    shr     ecx, 8
    and     ecx, $ff
    mov     cx, word ptr KRTwoHexAL[ ecx * 2 ]
    add     eax, 2
    mov     [ eax ], cx
    and     ebx, $ff
    mov     cx, word ptr KRTwoHexAL[ ebx * 2 ]
    add     eax, 2
    mov     [ eax ], cx

    mov     eax, edi
    pop     ebx
    pop     edi
end;
