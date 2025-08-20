asm
    push    edi
    push    ebx

    mov     edi, edx
    mov     ebx, eax
    and     ebx, $ff

    mov     eax, 4 + TKRStrRec_sz
    call    SysGetMem
    mov     word ptr [ eax + TKRStrRec_sz + 2 ], 0
    mov     [ eax ].TKRStrRec.length, 2
    mov     [ eax ].TKRStrRec.refCnt, 1
    mov     ecx, KRDefaultSystemCodePage
    mov     word ptr [ eax ].TKRStrRec.codePage, cx
    mov     word ptr [ eax ].TKRStrRec.elemSize, 1
    add     eax, TKRStrRec_sz
    mov     [ edi ], eax

    mov     cx, word ptr KRTwoHexAL[ ebx * 2 ]
    mov     [ eax ], cx

    mov     eax, edi
    pop     ebx
    pop     edi
end;
