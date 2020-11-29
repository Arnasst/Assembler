;Programa i?veda tik tas eilutes, kuriose pirmas laukas turi tik dvi raides 'A',
;trecias laukas yra neigiamas skaicius,
;ketvirto ir penkto skirtumas nesidalina is 11.   

%include 'yasmmac.inc'          ; Pagalbiniai makrosai
;---------------------------------------------------
org 100h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section.text
    
startas:
    ;------------------------------------------------;
   ;suvedame naudojamu failu vardus 
   ;macPutString 'Ivesk skaitomo failo varda', crlf, '$'
   ;mov al, 128                  ; ilgiausia eilute
   ;mov dx, skaitymoFailas      ; 
   ;call procGetStr              
   ;macNewLine
        
   ;prisistatymas 
   mov ah, 09
   mov dx, prisistatymas
   int 0x21
   
   macNewLine  
   
   xor bx, bx                   ;perkeliu prie ivesties turima failo pavadinima, kaip ivedamo failo pavadinima
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
        mov al, 128                  ; ilgiausia eilute
        mov dx, rasymoFailas      ; 
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
   
   .kitoFailoAtidarymas:            ;atidarome faila rasymui
        mov dx, rasymoFailas
        mov ah, 0x3D
        mov al, 0x01
        int 0x21
   
   mov [rasymoDesk], ax
   jnc .skaitymas
   macPutString 'Klaida atidarant faila rasymui', crlf, '$' 
   jmp .pab

   .skaitymas:                  ;skaitau kiekviena dali atskirai ir issaugau skirtingose atminties vietuose
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
   
   ;patikriname ar eilutes tik pirmi du simboliai 'A'
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
   
   
   
   ;patikriname ar trecias laukas yra neigiamas skaicius
   mov al, [dalis3+2]
   cmp al, '-'
   jne .skaitymas
   
   ;patikriname ar ketvirto ir penkto lauku skirtumas nesidalina is 11
   mov dx, dalis4+2
   call procParseInt16 
   push ax
   mov dx, dalis5+2
   call procParseInt16
   pop bx
   cmp ax, bx
   jg .axdaugiau        ;modulis, del liekanos gavimo
   xchg ax, bx
   .axdaugiau:
   sub ax, bx
   mov dx, 0
   mov bx, 11
   div bx
   ;mov ax, dx
   cmp dx, 0
   je .skaitymas 
   
   
   ;spausdinimas tinkamu daliu
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
   
   .uzdarymas: ;uzdarome skaitoma faila
        mov bx, [skaitymoDesk]
        mov ah, 0x3E
        int 0x21
   
   ;uzdarome rasoma faila
        mov bx, [rasymoDesk]
        mov ah, 0x3E
        int 0x21
        
   .pab:
        mov ah, 0x4C
        int 0x21
   
   .skaityti: ;paduodant reikia dx tureti kur skaityti(dx), ir ilgi(bx)
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
   
   .spausdinti: ;dx adresas kurio reikia spausdineti, bx kiek reikia tai kartot
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
    
    ;failu vardai
    skaitymoFailas:
        times 255 db 00
    rasymoFailas:
        times 255 db 00
    ;ju deskriptoriai
    skaitymoDesk: 
        dw 00
    rasymoDesk:
        dw 00
        ;duomenys
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
    db 'Arnas Stonkus ', 'Programu sistemos ', '3 grupe', 0x0A, 0x0D, '$'
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section.bss
        
        