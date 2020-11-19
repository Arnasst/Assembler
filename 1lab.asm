;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%include 'yasmmac.inc'
org 100h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text ;operacijos

    startas:
    ;introduction
   mov ah, 09
   mov dx, prisistatymas
   int 0x21
   
   macNewLine
   ;asks for input
   mov ah, 9
   mov dx, pranesimas1
   int 0x21
    
   ;takes input
   mov ah, 0x0A
   mov dx, buferisIvedimui
   int 0x21
   macNewLine
   ;Asks for 3 numbers
   macPutString 'Ivesk pirma skaiciu', crlf, '$'
   call procGetUInt16
   mov [a], ax
   macNewLine 

   macPutString 'Ivesk antra skaiciu', crlf, '$'
   call procGetUInt16
   mov [b], ax
   macNewLine

   macPutString 'Ivesk trecia skaiciu', crlf, '$'
   call procGetUInt16
   mov [c], ax
   macNewLine
    
   ;puts an empty line
   mov ah, 9
   mov dx, naujaEilute
   int 0x21
;----------------------------------------------------------------------------------------------------;
   ;first task: exchange 4'th and 8'th symbol, make 2'nd a percentage sign  
   mov al, [buferisIvedimui+5]           ; AL <- 4'th symbol
   mov ah, [buferisIvedimui+9]           ; AH <- 8'th symbol
   mov [buferisIvedimui+5], ah           ; 4'th symbol <- AH
   mov [buferisIvedimui+9], al           ; 8'th symbol <- AL
   mov al, [buferisIvedimui+3]
   mov [antras+2], al   
   mov byte [buferisIvedimui+3], '%'     ; 2'nd symbol <- %
    
   ;says it will write the answer
   mov ah, 09
   mov dx, pranesimas2
   int 0x21
    
   ;prepares to write the answer
   mov bx, 0
   mov bl, [buferisIvedimui+1]           ; bx <- length
   mov byte [buferisIvedimui+bx+3], 0x0a 
   mov byte [buferisIvedimui+bx+4], '$'  ; we add '$' so, 9'th function could be used  
   ;outputs the answer
   mov ah, 9
   mov dx, buferisIvedimui+2
   int 0x21
;---------------------------------------------------------------------------------------------------------;
   macNewLine
   ;second task
   
   macPutString '2) 3, 4 ir 9 bitu sumos yra:', crlf, '$'
   
   ;we bring back the old line
   mov al, [buferisIvedimui+5]          
   mov ah, [buferisIvedimui+9]          
   mov [buferisIvedimui+5], ah          
   mov [buferisIvedimui+9], al
   mov al, [antras+2]
   mov [buferisIvedimui+3], al           
   
   mov cx, 0
   mov cl, [buferisIvedimui+1]
   mov si, 0
   
   .ciklas:
   mov ax, 0
   mov dx, cx
   mov bx, [buferisIvedimui+2+si]
   and bx, 0x0200                         ; only 9'th bit unchanged 
   mov cl, 9                              ; we shift right 9 times
   shr bx, cl                       
   add ax, bx                             ; increment the answer

   mov bx, [buferisIvedimui+2+si]
   and bx, 0x0010                         ; only 4'th bit unchanged
   mov cl, 4                             
   shr bx, cl                             
   add ax, bx                         

   mov bx, [buferisIvedimui+2+si]
   and bx, 0x0008
   mov cl, 3
   shr bx, cl                             ; only 3'rd bit unchanged
   add ax, bx                           
   mov cx, dx
   
   inc si
   call procPutInt16
   loop .ciklas   

;---------------------------------------------------------------------------------------------------------;
   macNewLine    
   ;third task
   ;|a-15| + |b % 15 - 10| + max(c%10,b%10)
   ;first operation 
   mov ax, [a]
   mov bx, 0x0F
   cmp ax, bx
   sub ax, bx
   ja teig1 ;abs
   neg ax
   
   teig1:
   mov [operacija1], ax

   ;antra operacija
   mov dx, 0    
   mov ax, [b]
   mov bx, 0x0F
   div bx
   mov ax, dx   ;move the remainder
   mov bx, 0x0A
   cmp dx, bx
   sub dx, bx
   ja teig2
   neg dx
   
   teig2:
   mov [operacija2], dx
   
   ;trecia operacija
   mov dx, 0
   mov ax, [b]
   mov bx, 0x0A
   div bx
   mov ax, dx
   mov [b], ax ;remember the remainder
   mov dx, 0
   mov ax, [c]
   div bx
   mov ax, dx
   mov bx, [b]
   cmp ax, bx ; compare them
   jae .rezultatas
   mov ax, bx
   
   .rezultatas:
   mov [operacija3], ax ; puts in the bigger one as the result

   ;pabaigimas
   mov ax, [operacija1]
   mov bx, [operacija2] 
   add ax, bx           ;addition
   mov bx, [operacija3]
   add ax, bx           ;final answer
   
   ;rezulatu isvedimas
   macPutString crlf, '3)|a-15| + |b % 15 - 10| + max(c%10,b%10) Gautas rezultatas:  $';
   call procPutUInt16
   macNewLine    
   ;baigia programa
   mov ah, 0x4C
   int 0x21
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
%include 'yasmlib.asm'     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data ;duomenys
    ;pradzia
    prisistatymas:
        db 'Arnas Stonkus', 0x0D, 0x0A, 'Programu sistemos', 0x0D, 0x0A, '3grupe', '$'
    buferisIvedimui:
        db 0x52, 0x00, '**********************************************************************************' ; vieta ivesti
  ;pirmos uzduoties duomenys  
    pranesimas1:
        db 'iveskite teksto eilute:', 0x0D, 0x0A, '$'
        
    pranesimas2:
        db '1) gavome tokia eilute: ', 0x0D, 0x0A, '$'
        
    naujaEilute:
        db 0x0D, 0x0A, '$'
        
   ;2uzduoties duomenys 
   antras:
        db 0x02, 0x00, '****'   
   sk1:
       dw 00
   bitu_3_4_9_suma:
       dw 00
   ;3uzduoties duomenys     
   a:
       dw 00
   b:
       dw 00
   c:
       dw 00
   operacija1:
       dw 00
   operacija2:
       dw 00
   operacija3:
       dw 00
        
