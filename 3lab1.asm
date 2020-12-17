%include 'yasmmac.inc' 
%define PERTRAUKIMAS 0x21       ;this program changes int 0x21 ah=40 function to create a file with a random name instead of the one you gave it when si = 0xffff
;------------------------------------------------------------------------
org 100h                       
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text                   
 
   startas:
   jmp Nustatymas
   
   file:
   db '********.tmp', 0   ; space for random name of file
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
        cmp dl, '9'   ; check if number or should it be converted from A-F
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
      call .print
      pop ds
      iret
      .toliau
      pushf
      call far [cs:SenasPertraukimas]   
      iret 
      
        .print: ;dx is what to print
        mov dx, sveikinimasis
        mov si, dx
        mov cx, 24 ;how many times to repeat(how many symbols)
        mov bx, [.rasymoDesk]
        cld
        .dar:
           lodsb
   push cx
   mov cx, 1
   mov [.baitas], al  ; this prints one symbol
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
        mov     al, PERTRAUKIMAS              ; we get the old interrupt
        int     21h
 
 
        ; Saugome sena vektoriu 
        mov     [cs:SenasPertraukimas], bx             ; save old ip   
        mov     [cs:SenasPertraukimas + 2], es         ; save old segment
 
        ; Nustatome nauja  vektoriu
        mov     dx, NaujasPertraukimas
        mov     ah, 0x25
        mov     al, PERTRAUKIMAS                       ; change interrupt
        int     21h
 
        macPutString "Pertraukimas pakeistas",  '$'
 
        mov dx, Nustatymas + 1
        int     27h                       ; makes the change permanent
 
%include 'yasmlib.asm'
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .bss                    
