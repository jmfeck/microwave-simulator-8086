    ORG 100h

    #start=DAS5332_Temp.exe#

  ;----------------------------------------------
  ; 
  ; Atribuicao do endereco dos tratadores de int 90h,
  ; int 91h,int 92h, int 93,
  ; na tabela de vetores de interrupcao
  ;                    
  ;----------------------------------------------
    MOV AX,CS
    MOV DS,AX   ; Segmento do vetor (0000h) em DS

    MOV DX,offset Adiciona30 ;Declaracao de interrupcao em 90h
    MOV AL,90H
    MOV AH,25H
    INT 21H  
             
    MOV DX,offset DecrementaPotencia ;Declaracao de interrupcao em 91h
    MOV AL,91H 
    INT 21H
    
    MOV DX,offset PausaCancelaTudo ;Declaracao de interrupcao em 92h
    MOV AL,92H 
    INT 21H  
    
      
  ;-----------------------------------------------
  ; Programa principal
  ;-----------------------------------------------       
    
    
Aguarda_Usuario:  

 
    CMP ESTADO_ATUAL,01h  
    JE Add30s
    CMP ESTADO_ATUAL,02h 
    JE VariaPot
    CMP CANCELAPAUSA,02h 
    JE Cancela_Tudo
    CMP CANCELAPAUSA,01h  
    JE Pausa_Timer
    CMP ESTADO_ATUAL,04h  
    JE verificaPausaCancela 
    CMP ESTADO_ATUAL,00h 
    JE Decrementador
    CMP ESTADO_ATUAL,0FFh 
    JE AtualizaRelogio   
    
    ;ESTADO_ATUAL 00h  =  Decrementador
    ;ESTADO_ATUAL 01h  =  Adiciona30s e liga 
    ;ESTADO_ATUAL 02h  =  Cancela programa atual, reseta tudo
    ;ESTADO_ATUAL 04h  =  Verifica se o botao pause foi clicado, se nao, pausa a contagem
        ;CANCELAPAUSA 01h  =  Pausa timer
        ;CANCELAPAUSA 02h  =  Reseta tudo
    ;ESTADO_ATUAL 0FFh =  Aguarda usuario e atualiza relogio 
        

  ;-----------------------------------------------
  ; Tratadores
  ;-----------------------------------------------       

Adiciona30:
    
    MOV AL, ESTADO_ATUAL
    MOV ESTADO_ANTERIOR, AL
    MOV ESTADO_ATUAL,01h 
    IRET  
    
DecrementaPotencia:
    
    MOV AL, ESTADO_ATUAL
    MOV ESTADO_ANTERIOR, AL
    MOV ESTADO_ATUAL,02h 
    IRET
    
PausaCancelaTudo:
    
    MOV AL, ESTADO_ATUAL
    MOV ESTADO_ANTERIOR, AL 
    MOV ESTADO_ATUAL,04h 
    IRET 

  ;-----------------------------------------------
  ; Funcoes
  ;----------------------------------------------- 

Add30s: 
    
    CMP CANCELAPAUSA, 01h
    MOV CANCELAPAUSA, 00h
    MOV ESTADO_ATUAL,00h
    JE Decrementador
    
    MOV AL,TIMER
    ADD AL,1Eh
    MOV TIMER,AL   

         
Decrementador:
    
    
    LEA BX, TELALED
    MOV AL, 00
    CALL CONVERT
    MOV [BX], 01Fh
    MOV [BX+1], AX 
    MOV AL, TIMER
    CALL CONVERT
    MOV [BX+4], AX
    MOV AL,01H
    OUT 21h,AL
    CMP ESTADO_ATUAL,00h
    JNE Aguarda_Usuario
    MOV CX, 0FH
    MOV DX, 4240H
    MOV AH,86h
    INT 15h
    MOV AL,TIMER 
    CMP AL,00h  
    JE Reseta_Tudo
    ADD AL,-01h
    MOV TIMER,AL
    JMP Decrementador    
  
    
VariaPot:
    
    CMP ESTADO_ANTERIOR, 0FFh
    MOV AL, ESTADO_ANTERIOR
    MOV ESTADO_ATUAL, AL
    JNE Aguarda_Usuario
    LEA BX, TELALED
    MOV [BX], 01010000b
    MOV [BX+1], 01001111b
    MOV [BX+2], 01010100b 
    ADD POTENCIA, -10d
    CMP POTENCIA, 00d 
    JE RestauraPot 
    MOV [BX+4], AX
    MOV AL, POTENCIA
    CALL CONVERT
    MOV ESTADO_ATUAL,0FFh
    JMP Aguarda_Usuario
       
       
RestauraPot:
    
    MOV POTENCIA, 100d
    MOV ESTADO_ATUAL,0FFh
    JMP Aguarda_Usuario    
         
         
Cancela_Tudo:  

    JMP Reseta_Tudo
              
              
verificaPausaCancela:

    CMP ESTADO_ANTERIOR,0FFH
    JE Reseta_Tudo  
    CMP CANCELAPAUSA , 00h
    JE setapausa 
    JNE setacancela
       
       
setapausa: 

    MOV CANCELAPAUSA, 01H
    MOV ESTADO_ATUAL,05H
    JMP Aguarda_Usuario 
        
        
setacancela: 

    MOV CANCELAPAUSA, 02H
    JMP Aguarda_Usuario     
        
        
Pausa_Timer:
    
    MOV AL,00H
    OUT 21h,AL
    CMP ESTADO_ATUAL,04H
    JE  verificaPausaCancela
    CMP ESTADO_ATUAL,01H
    JE  Aguarda_Usuario
    CMP CANCELAPAUSA,01H
    JE  Pausa_Timer
    JMP Reseta_Tudo
      
      
Reseta_Tudo:
    
    MOV POTENCIA, 100d
    MOV AL,00H
    OUT 21h,AL
    MOV TIMER,00h 
    MOV ESTADO_ATUAL,0FFh
    MOV ESTADO_ANTERIOR,0FFh 
    MOV CANCELAPAUSA,00H
    JMP Aguarda_Usuario
       
       
AtualizaRelogio:

    LEA BX, TELALED              ; BX = endereco offset da string TELALED
    CALL GET_TIME                ; chama funcao que pega hora do sistema
    MOV AL,TELALED
    MOV [BX], 01Fh 
    JMP Aguarda_Usuario
       
       
GET_TIME PROC
; entrada : BX=endereco offset da string TELALED
; saida : BX=hora do sistema

    PUSH AX                       ; PUSH AX na Pilha
    PUSH CX                       ; PUSH CX na Pilha 

    MOV AH, 2CH                   ; pega a hora do sistema
    INT 21H                       

    MOV AL, CH                    ; seta AL=CH , CH=horas
    CALL CONVERT                  ; chama CONVERT
    MOV [BX+1], AX                 ; seta [BX]=horas  , [BX] apontando pra horas
                                  ; na string TELALED

    MOV AL, CL                    ; seta AL=CL , CL=minutos
    CALL CONVERT                  ; chama CONVERT
    MOV [BX+4], AX                ; seta [BX+3]=minutos  , [BX] apontando pra minutos
                                  ; na string TELALED
                                                      
    POP CX                        ; POP para CX
    POP AX                        ; POP para AX

    RET                           
   GET_TIME ENDP                  
    
CONVERT PROC 
; entrada : AL=binary code
; saida : AX=ASCII code

    PUSH DX                       ; PUSH DX na Pilha 

    MOV AH, 0                     ; seta AH=0
    MOV DL, 10                    ; seta DL=10
    DIV DL                        ; seta AX=AX/DL
    OR AX, 3030H                  ; converte AX binario em ASCII

    POP DX                        ; POP DX 

    RET                           
   CONVERT ENDP                      
    
    
TIMER DB 00h                 ; 
CANCELAPAUSA DB 00h          ;
POTENCIA DB 100d             ;
ESTADO_ATUAL DB 0FFh         ;
ESTADO_ANTERIOR DB 0FFh      ;
TELALED DB ' 00:00$'         ; hr:min 

                