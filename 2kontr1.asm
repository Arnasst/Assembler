;Para?ykite  nasm/yasm program?, kurioje vartotojas ?veda tekstin? eilut? (iki 100 simboli?) ir programa suskai?iuoja ma??j? raid?i? i?skyrus ?x?
;skai?i?. Pvz., jeigu ?vesta eilute LABAS labas xyz, tai atsakymas turi b?ti 7, o jeigu   XYZxYZ - 0. Min?t? ma??j? raid?i? be ?x? radimui para?ykite atskir? proced?r?:

%include 'yasmmac.inc'          ; Pagalbiniai makrosai
;---------------------------------------------------
org 100h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section.text
    
    startas:
   mov al, 100                 ; ilgiausia eilute
   mov dx, eilute      
   call procGetStr
   
   cld
   mov si, eilute
    
   ;mov cx, [eilute+1]
   mov bx, 0
   .pliusavimas:
   lodsb 
   cmp al, 0
   je .pabaiga
   cmp al, 'x'
   je .pliusavimas
   cmp al, 'a'
   jb .pliusavimas
   cmp al, 'z'
   ja .pliusavimas
    
   .prideti:
    inc bx
    jmp .pliusavimas
 
   .pabaiga:
    macNewLine
    mov ax, bx
    call procPutInt16
    macNewLine
    mov ah, 0x4C
    int 0x21   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%include 'yasmlib.asm'    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    eilute:
       times 100 db 00
    ;eilute:
    ; db 0x52, 0x00, '**********************************************************************************' ; vieta ivesti
        
        