;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%include 'yasmmac.inc'
org 100h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text ;operacijos

    startas:
    ;prisistatymas 
   mov ah, 09
   mov dx, prisistatymas
   int 0x21
   
   macNewLine
   ;papraso ivesti duomenis
   mov ah, 9
   mov dx, pranesimas1
   int 0x21
    
   ;priema duomenis
   mov ah, 0x0A
   mov dx, buferisIvedimui
   int 0x21
   macNewLine
   ;paprasome 3 skaiciu
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
    
   ;isveda tuscia eilute
   mov ah, 9
   mov dx, naujaEilute
   int 0x21
;----------------------------------------------------------------------------------------------------;
   ;pirma uzduotis: apkeisti ketvirta ir astunta simbolius, o antra paversti procento zenklu 
   ;apkeicia ketvirta ir astuntas simbolius vietomis ir antra padaro procentu
   mov al, [buferisIvedimui+5]           ; AL <- ketvirtas simbolis
   mov ah, [buferisIvedimui+9]           ; AH <- astuntas simbolis
   mov [buferisIvedimui+5], ah           ; ketvirtas simbolis <- AH
   mov [buferisIvedimui+9], al           ; astuntas simbolis <- AL
   mov al, [buferisIvedimui+3]
   mov [antras+2], al   
   mov byte [buferisIvedimui+3], '%'
    
   ;pranesa, kad isves atsakyma
   mov ah, 09
   mov dx, pranesimas2
   int 0x21
    
   ;paruosia isvesti atsakyma 
   mov bx, 0
   mov bl, [buferisIvedimui+1]           ; bx <- kiek ivedeme baitu
   mov byte [buferisIvedimui+bx+3], 0x0a ; pridedame gale LF (CR jau ten yra) 
   mov byte [buferisIvedimui+bx+4], '$'  ; pridedame gale '$' tam, kad 9-a funkcija galetu atspausdinti  
   ;isveda ats
   mov ah, 9
   mov dx, buferisIvedimui+2
   int 0x21
;---------------------------------------------------------------------------------------------------------;
   macNewLine
   ;antra uzduotis
   
   macPutString '2) 3, 4 ir 9 bitu sumos yra:', crlf, '$'
   
   ;sugraziname sena eilute
   mov al, [buferisIvedimui+5]           ; AL <- ketvirtas simbolis
   mov ah, [buferisIvedimui+9]           ; AH <- astuntas simbolis
   mov [buferisIvedimui+5], ah           ; ketvirtas simbolis <- AH
   mov [buferisIvedimui+9], al
   mov al, [antras+2]
   mov [buferisIvedimui+3], al           ;antra atkeiciame i sena
   
   mov cx, 0
   mov cl, [buferisIvedimui+1]
   mov si, 0
   
   .ciklas:
   mov ax, 0
   mov dx, cx
   mov bx, [buferisIvedimui+2+si]
   and bx, 0x0200                         ; lieka nepakeistas tik 9-as bitas 
   mov cl, 9                              ; reikes stumti bx tiek kartu
   shr bx, cl                       
   add ax, bx                             ; didiname atsakyma, dabar issemiau word pries ax

   mov bx, [buferisIvedimui+2+si]
   and bx, 0x0010                         ; lieka nepakeistas tik 4-as bitas 
   mov cl, 4                              ; reikes stumtii bx tiek kartu
   shr bx, cl                             
   add ax, bx                             ; didiname atsakyma

   mov bx, [buferisIvedimui+2+si]
   and bx, 0x0008
   mov cl, 3
   shr bx, cl                             ; lieka nepakeistas tik 3-as bitas 
   add ax, bx                             ; didiname atsakyma
   mov cx, dx
   
   inc si
   call procPutInt16
   loop .ciklas   

;---------------------------------------------------------------------------------------------------------;
   macNewLine    
   ;trecia uzduotis:
   ;|a-15| + |b % 15 - 10| + max(c%10,b%10)
   ;pirma operacija 
   mov ax, [a]
   mov bx, 0x0F
   cmp ax, bx
   sub ax, bx
   ja teig1 ;modulis
   neg ax
   
   teig1:
   mov [operacija1], ax

   ;antra operacija
   mov dx, 0    ;reikia nunulinti pries dalinant
   mov ax, [b]
   mov bx, 0x0F
   div bx
   mov ax, dx   ;perkeliame liekana i ax
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
   mov [b], ax ;issaugau b liekana
   mov dx, 0
   mov ax, [c]
   div bx
   mov ax, dx
   mov bx, [b]
   cmp ax, bx ;sulyginu liekanas
   jae .rezultatas
   mov ax, bx
   
   .rezultatas:
   mov [operacija3], ax ; ikelia didesni kaip 3 operacijos rezultata

   ;pabaigimas
   mov ax, [operacija1]
   mov bx, [operacija2] 
   add ax, bx           ;sudetis operaciju
   mov bx, [operacija3]
   add ax, bx           ;galutine sudetis
   
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
        