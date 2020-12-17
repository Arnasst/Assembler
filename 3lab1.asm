%include 'yasmmac.inc' 
%define PERTRAUKIMAS 0x21
;------------------------------------------------------------------------
org 100h                        ; visos COM programos prasideda nuo 100h
                                ; Be to, DS=CS=ES=SS !
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text                   ; kodas prasideda cia 
 
   startas:
   jmp Nustatymas
   
   file:
   db '********.tmp', 0
   sveikinimasis:
   db 'Hello', 0x0A, 'You look beautiful'
   
   randomName:
        mov ah, 00h   ; interrupt to get system timer in CX:DX 
        INT 0x1A
        mov [.PRN], dx
        mov cx, 8
        mov bx, 0
        .magic8:
        push cx
        push bx
            mov ax, 25173          ; LCG Multiplier
            mul word [.PRN]     ; DX:AX = LCG multiplier * seed
            add ax, 13849          ; Add LCG increment value
            mov [.PRN], ax          ; Update seed = return value
        xor dx, dx
        mov cx, 16    
        div cx        ; here dx contains the remainder - from 0 to 15
        add dl, '0'   ; to ascii number
        cmp dl, '9'   ; check if number or is should it be converted from A-F
        jle .rasymas
   
        add dl, 7
        .rasymas:
        pop bx
        mov [file+bx], dl
        inc bx
        pop cx   
        loop .magic8
        ret
   .PRN:
   dw 00

   SenasPertraukimas:
      dw 0,0

        
   NaujasPertraukimas:
   jmp .darom
    .rasymoDesk:
    dw 00
      .darom:
      cmp ah, 0x3c
      jne .toliau
      cmp si, 0xffff
      jne .toliau
      push ds
      push cs
      pop ds
      call randomName   
        mov ah, 0x3c
        mov cx, 0
        mov dx, file
      pushf
      call far [cs:SenasPertraukimas]
      push cs
      pop ds
      mov [.rasymoDesk], ax    ;perkeliu file handle
      ;mov dx, sveikinimasis
      ;mov bx, 5
      call .spausdinti
      pop ds
      iret
      .toliau
      pushf
      call far [cs:SenasPertraukimas]   
      iret 
      
        .spausdinti: ;dx adresas kurio reikia spausdineti, bx kiek reikia tai kartot
        mov dx, sveikinimasis
        mov si, dx
        mov cx, 24 ;nuo dabar cx ilgis kiek kartoti
        mov bx, [.rasymoDesk]
        cld
        .dar:
           lodsb
   push cx
   mov cx, 1
   mov [.baitas], al
   mov dx, .baitas
   mov ah, 0x40
   int 0x21
   pop cx
           loop .dar
    ret
   .baitas:
   db 00
      
      
  Nustatymas:
        ; Gauname sena  vektoriu
        push    cs
        pop     ds
        mov     ah, 0x35
        mov     al, PERTRAUKIMAS              ; gauname sena pertraukimo vektoriu
        int     21h
 
 
        ; Saugome sena vektoriu 
        mov     [cs:SenasPertraukimas], bx             ; issaugome seno doroklio poslinki    
        mov     [cs:SenasPertraukimas + 2], es         ; issaugome seno doroklio segmenta
 
        ; Nustatome nauja  vektoriu
        mov     dx, NaujasPertraukimas
        mov     ah, 0x25
        mov     al, PERTRAUKIMAS                       ; nustatome pertraukimo vektoriu
        int     21h
 
        macPutString "Pertraukimas pakeistas",  '$'
 
        mov dx, Nustatymas + 1
        int     27h                       ; Padarome rezidentu
 
%include 'yasmlib.asm'
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .bss                    ; neinicializuoti duomenys  