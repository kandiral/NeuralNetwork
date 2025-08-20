asm
    push    edi

    mov     edi, eax

    mov     eax, 18 + TKRStrRec_sz
    call    SysGetMem
    mov     word ptr [ eax + TKRStrRec_sz + 16 ], 0
    mov     [ eax ].TKRStrRec.length, 16
    mov     [ eax ].TKRStrRec.refCnt, 1
    mov     ecx, KRDefaultSystemCodePage
    mov     word ptr [ eax ].TKRStrRec.codePage, cx
    mov     word ptr [ eax ].TKRStrRec.elemSize, 1
    add     eax, TKRStrRec_sz
    mov     [ edi ], eax

    mov     edx, [ebp+$0c]
    mov     ecx, edx
    shr     ecx, 24
    mov     cx, word ptr KRTwoHexAL[ ecx * 2 ]
    mov     [ eax ], cx
    mov     ecx, edx
    shr     ecx, 16
    and     ecx, $ff
    mov     cx, word ptr KRTwoHexAL[ ecx * 2 ]
    add     eax, 2
    mov     [ eax ], cx
    mov     ecx, edx
    shr     ecx, 8
    and     ecx, $ff
    mov     cx, word ptr KRTwoHexAL[ ecx * 2 ]
    add     eax, 2
    mov     [ eax ], cx
    and     edx, $ff
    mov     cx, word ptr KRTwoHexAL[ edx * 2 ]
    add     eax, 2
    mov     [ eax ], cx

    mov     edx, [ebp+$08]
    mov     ecx, edx
    shr     ecx, 24
    mov     cx, word ptr KRTwoHexAL[ ecx * 2 ]
    add     eax, 2
    mov     [ eax ], cx
    mov     ecx, edx
    shr     ecx, 16
    and     ecx, $ff
    mov     cx, word ptr KRTwoHexAL[ ecx * 2 ]
    add     eax, 2
    mov     [ eax ], cx
    mov     ecx, edx
    shr     ecx, 8
    and     ecx, $ff
    mov     cx, word ptr KRTwoHexAL[ ecx * 2 ]
    add     eax, 2
    mov     [ eax ], cx
    and     edx, $ff
    mov     cx, word ptr KRTwoHexAL[ edx * 2 ]
    add     eax, 2
    mov     [ eax ], cx

    mov     eax, edi
    pop     edi
end;
