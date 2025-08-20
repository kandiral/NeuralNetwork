asm
    push    edi
    push    ebx

    mov     edi, edx
    mov     ebx, eax
    and     ebx, $ffff

    mov     eax, 6 + TKRStrRec_sz
    call    SysGetMem
    mov     word ptr [ eax + TKRStrRec_sz + 4 ], 0
    mov     [ eax ].TKRStrRec.length, 4
    mov     [ eax ].TKRStrRec.refCnt, 1
    mov     ecx, KRDefaultSystemCodePage
    mov     word ptr [ eax ].TKRStrRec.codePage, cx
    mov     word ptr [ eax ].TKRStrRec.elemSize, 1
    add     eax, TKRStrRec_sz
    mov     [ edi ], eax

    mov     ecx, ebx
    shr     ecx, 8
    mov     cx, word ptr KRTwoHexAU[ ecx * 2 ]
    mov     [ eax ], cx
    and     ebx, $ff
    mov     cx, word ptr KRTwoHexAU[ ebx * 2 ]
    add     eax, 2
    mov     [ eax ], cx

    mov     eax, edi
    pop     ebx
    pop     edi
end;
