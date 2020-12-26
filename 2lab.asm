;Program outputs only these lines ,that have two 'A' symbols in it,
;third number is negative,
;fourth and fifth number's difference is not dividable by 11.   

%include 'yasmmac.inc'          ; Pagalbiniai makrosai
;---------------------------------------------------
org 100h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section.text
    
startas:
    ;------------------------------------------------;
   ;suvedame naudojamu failu vardus 
   ;macPutString 'Ivesk skaitomo failo varda', crlf, '$'
   ;mov al, 128                  ; longest line
   ;mov dx, skaitymoFailas      ; 
   ;call procGetStr              
   ;macNewLine
        
   ;prisistatymas 
   mov ah, 09
   mov dx, prisistatymas
   int 0x21
   
   macNewLine  
   
   xor bx, bx                  
   mov bl, [0x80]
   mov byte [bx+0x81], '$'
   xor bx, bx
   duotaSkaitymas:
        inc bx
        cmp byte [bx+81h], '$'
        je rezSkaitymas
        push cx
        xor cx,cx
        mov cl, [bx+81h]
        mov [skaitymoFailas+bx-1], cl
        pop cx
        jmp duotaSkaitymas
   
   rezSkaitymas:
        macPutString 'Ivesk rasomo failo varda', crlf, '$'
        mov al, 128                
        mov dx, rasymoFailas      
        call procGetStr              
        macNewLine
  
   ;atidarome faila skaitymui
   mov dx, skaitymoFailas
   mov ah, 0x3D
   mov al, 0x00
   int 0x21
   
   mov [skaitymoDesk], ax
   jnc .kitoFailoAtidarymas
   macPutString 'Klaida atidarant faila skaitymui', crlf, '$' 
   jmp .pab
   
   .kitoFailoAtidarymas:            ;open file for writing
        mov dx, rasymoFailas
        mov ah, 0x3D
        mov al, 0x01
        int 0x21
   
   mov [rasymoDesk], ax
   jnc .skaitymas
   macPutString 'Klaida atidarant faila rasymui', crlf, '$' 
   jmp .pab

   .skaitymas:                  ;i read every section of file as different, because there are 5 parts that i need to take into account
   mov dx, dalis1
   mov bx, 0
   call .skaityti
   mov [ilgis1], dx
   
   mov dx, dalis2
   mov bx, 0
   call .skaityti
   mov [ilgis2], dx
   
   mov dx, dalis3
   mov bx, 0
   call .skaityti
   mov [ilgis3], dx
   
   mov dx, dalis4
   mov bx, 0
   call .skaityti
   mov [ilgis4], dx
   
   mov dx, dalis5
   mov bx, 0
   call .skaityti
   mov [ilgis5], dx
   
   mov byte [Askc], 0
   
   ;check whether there are 2 'A'
   ;mov byte al, [dalis1+2]
   ;cmp al, 'A'
   ;jne .skaitymas
   ;mov byte al, [dalis1+3]
   ;cmp al, 'A'
   ;jne .skaitymas
   ;mov al, [dalis1+4]
   ;cmp al, ';'
   ;jne .skaitymas
   
   mov cx, [ilgis1]
   mov dx, 1
   sub cx, dx
   mov bx, 1
   .kartoti:
   inc bx
   mov al, [dalis1+bx]
   cmp al, 'A'
   jne .negeras
   ;mov dx, [Askc]
   ;inc dx
   ;mov [Askc], dx
   inc byte [Askc]
   
   .negeras: 
   loop .kartoti
   
   mov ah, [Askc]
   cmp ah, 2
   jne .skaitymas
   ;mov ah, 0
   ;mov al, [Askc]
   ;call procPutInt16
   
   
   
   ;check whether third field is a negative number
   mov al, [dalis3+2]
   cmp al, '-'
   jne .skaitymas
   
   ;check if fourth and fifth number's difference is not dividable by 11.
   mov dx, dalis4+2
   call procParseInt16 
   push ax
   mov dx, dalis5+2
   call procParseInt16
   pop bx
   cmp ax, bx
   jg .axdaugiau        ;abs
   xchg ax, bx
   .axdaugiau:
   sub ax, bx
   mov dx, 0
   mov bx, 11
   div bx
   ;mov ax, dx
   cmp dx, 0
   je .skaitymas 
   
   
   ;print results
   mov dx, dalis1
   mov bx, [ilgis1]
   call .spausdinti
   
   mov dx, dalis2
   mov bx, [ilgis2]
   call .spausdinti
   
   mov dx, dalis3
   mov bx, [ilgis3]
   call .spausdinti
   
   mov dx, dalis4
   mov bx, [ilgis4]
   call .spausdinti
   
   mov dx, dalis5
   mov bx, [ilgis5]
   call .spausdinti
   
   jmp .skaitymas
   
   .uzdarymas: ;close files
        mov bx, [skaitymoDesk]
        mov ah, 0x3E
        int 0x21
   
        mov bx, [rasymoDesk]
        mov ah, 0x3E
        int 0x21
        
   .pab:
        mov ah, 0x4C
        int 0x21
   
   .skaityti: ;where to read(dx), and length(bx)
        mov di, dx ;cia vieta kuria skaityt
        inc di
        inc di     ;du kart ++, nes nuo adresas+2 yra kintamasis
        mov dx, bx
        cld
        .vel:
        mov bx, [skaitymoDesk]
        call procFGetChar
        cmp ax, 0 ;jei neperskaite tai failo pabaiga
        je .uzdarymas
        mov al, cl
        stosb
        inc dx
        cmp cl, 0x0a ;tikrinu ar newline cia
        je .nustok
        cmp cl, ';' ;arba lauko pabaiga
        jne .vel
        .nustok:
        ret
   
   .spausdinti: ;where to print(dx), how many symbols(bx)
        mov si, dx
        inc si
        inc si
        mov cx, bx ;nuo dabar cx ilgis kiek kartoti
        mov bx, [rasymoDesk]
        cld
        .dar:
            lodsb
            call procFPutChar
            loop .dar
   
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%include 'yasmlib.asm'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section.data

    Askc:
        db 00
    
    ;file names
    skaitymoFailas:
        times 255 db 00
    rasymoFailas:
        times 255 db 00
    ;their descriptors
    skaitymoDesk: 
        dw 00
    rasymoDesk:
        dw 00
        ;data
    dalis1:
        db 0x1E, 0x00, '******************************'
    dalis2:
        db 0x1E, 0x00, '******************************'    
    dalis3:
        db 0x1E, 0x00, '******************************'
    dalis4:
        db 0x1E, 0x00, '******************************'    
    dalis5:
        db 0x1E, 0x00, '******************************'
    ilgis1:
        dw 00
    ilgis2:
        dw 00
    ilgis3:
        dw 00
    ilgis4:
        dw 00
    ilgis5:
        dw 00
    prisistatymas:
    db 'Arnas ', 'Software Engineering ', 0x0A, 0x0D, '$'
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section.bss
        
        
