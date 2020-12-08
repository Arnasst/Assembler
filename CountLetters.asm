;vartotojas iveda tekstine eilute (iki 100 simboliu) ir programa suskaiciuoja mazuju raidziu isskyrus 'x'
;skaiciu. Pvz., jeigu ivesta eilute LABAS labas xyz, tai atsakymas turi buti 7, o jeigu   XYZxYZ - 0.

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
        
        
