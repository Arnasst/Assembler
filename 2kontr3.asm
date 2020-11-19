;Para?ykite  nasm/yasm program?, kurioje vartotojas ?veda skai?i?
;(nuo 0 iki FFFFh) sek?, kurios pabaigoje yra 0, ir programa suskai?iuoja
;kiek toje sekoje yra skai?i?, kuri? skaitmen? suma yra  ma?esn? u? 10 (0 ?eina ? sek?). Pvz., jeigu ?vesta seka

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

        
        