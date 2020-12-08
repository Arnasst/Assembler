;vartotojas iveda skaiciu
;(nuo 0 iki FFFFh) seka, kurios pabaigoje yra 0, ir programa suskaiciuoja
;kiek toje sekoje yra skaiciu, kuriu skaitmenu suma yra  mazesne uz 10 (0 ieina i seka).

%include 'yasmmac.inc'          ; Pagalbiniai makrosai
;---------------------------------------------------
org 100h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section.text
    
    startas:
    
    skaitom:
    macNewLine
    macPutString 'Iveskite skaiciu', crlf, '$'
    call procGetUInt16
    macNewLine
    
    call arSkSumaTinkama
    
    geras:
    call procPutUInt8
    
    mov ax, [skc]
    cmp ax, 0
    je pabaiga
    jmp skaitom
    
    
    pabaiga:
    mov ah, 0x4C
    int 0x21
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    arSkSumaTinkama:
    mov [skc] ,ax ;cia prisimenam
    mov bx, 0
    skaidymas:
    mov dx, 0
    mov cx, 10
    div cx
    add bx, dx
    cmp ax, 0
    jne skaidymas
    
    mov al, 1
    cmp bx, 10
    jb geras
    mov al, 0
    jmp geras
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%include 'yasmlib.asm'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section.data

      skc:
        dw 00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section.bss

        
        
