;�ó���Ϊ���װ�̰������Ϸ
;ʹ�÷���:������������������У�Ȼ��ͨ��������������ء�
    section   text
    bits   16
    ;��������������Ϣ
    Signature     db   "YANG"       ;ǩ����Ϣ
    Version       dw   1            ;��ʽ�汾
    Length        dw   end_of_text  ;�������򳤶�
    Start         dw   Begin        ;����������ڵ��ƫ��
    Zoneseg       dw   0088H        ;���������������ڴ�������ʼ��ֵ
    Reserved      dd   0            ;����
	
	S_PO  resb 0x80 												;С��λ��
	PORT_KEY_DAT   EQU   0x60
    PORT_KEY_STA   EQU   0x64
	GO_RIGHT EQU 31H												;С�ߵķ���
	GO_LEFT  EQU 32H
	GO_UP    EQU 33H
	GO_DOWN  EQU 34H
    S_LEN dw 5 														;С�߳�ʼ����
	STATE db GO_UP 													;С������״̬
	SCORE dw 0														;��ǰ�ķ���	
	SCORE_ADD dw 1													;���ӵķ���ֵ
	stone_state db 0;												;���ӵ�״̬
	stone_position db 0,0											;���ӵ�λ��
    wall1 db "###################################################"	;��ʾǽ��
		  db 0AH,0DH,0
    wall2 db '#' 													;��ʾǽ��
          db  "                                                 " 
          db '#',0AH,0DH,0	  										
	wel  db "Welcome to play this funny game! -- WSY :)",0			;��ʾ���滶ӭ��Ϣ
	wel2 db "Press any key to continue:",0							;��ʼ������ʾ��Ϣ
		 db 0AH,0DH,0
	faliure db "You have failed, TRY again! :)",0					;ʧ����ʾ��Ϣ
		 db 0AH,0DH,0
	scorestr db "score:"											;��ʾ����
	SCORE_STRING db 30H,0,0,0,0,0									;��ʾ����
	CurLin db 11													;�����Ϣ����ֵ
	CurCol db 6                 									;�����Ϣ����ֵ
	count    DB   1                 								;������
    old1ch   DD   0                 								;���ڱ���ԭ1CH���ж�����
	
	;���������
	Begin:
        MOV   AX, CS
        MOV   DS, AX  
        CLD   
		CALL CLEAR		;����
        CALL WELL_SHOW  ;��ʾǽ��
		CALL WELCOME_SHOW ;��ʾ��ӭ����
	WAIT_KEY:
		MOV   AH, 1
        INT   16H		;�ȴ��������û�����
		JZ	WAIT_KEY
		
		CALL CLEAR		;����
		CALL WELL_SHOW	;��ʾǽ��
		CALL INIT		;��ʼ���ߵ�����
		CALL KEY_BOARD
		CALL SHOW_TIME	
		CALL CLEAR		;����
		CALL FALIURE_SHOW
		RETF
;----------------------------------------------------------------------------
;�ӳ�������ADD_SCORE
;���ܣ�С�߳Ե�����֮�����ӷ���
;��ڲ�������
;���ڲ�������                    
;-----------------------------------------------------------------------------		
ADD_SCORE:
		PUSH DS
		MOV   AX, CS
        MOV   DS, AX
		MOV CX, [SCORE_ADD]
		ADD [SCORE],CX
		POP DS
		RET 
;----------------------------------------------------------------------------
;�ӳ�������SHOW_SCORE
;���ܣ���ʾ����
;��ڲ�������
;���ڲ�������                   
;-----------------------------------------------------------------------------	
SHOW_SCORE:
		PUSH DS
		MOV AX,CS
		MOV DS,AX
		MOV BX,  SCORE
		MOV DX,[BX]    
		MOV BX,  SCORE_STRING  
		CALL PRINT_DEC
		MOV AL,[CurCol]
		PUSH AX
		MOV AL,60
		MOV BYTE [CurCol],AL
		MOV AL,[CurLin]
		PUSH AX
		MOV BYTE [CurLin],1
		MOV DX,  scorestr
		CALL PutStr_Red
		POP AX
		MOV [CurLin],AL
		POP AX 
		MOV [CurCol],AL
		POP DS
		RET         
;----------------------------------------------------------------------------
;�ӳ�������PRINT_DEC
;���ܣ���������ת��Ϊʮ����
;��ڲ�����BX��DX
;���ڲ�������                  
;-----------------------------------------------------------------------------		
PRINT_DEC:    
        XOR CX,CX
		MOV AX,DX
    PR_LAB1:
		MOV DX,0
		CMP AX,0
		JE	END_DIV
		PUSH SI
		MOV SI,10
		DIV SI
		POP SI	
		PUSH DX
		INC CX
		JMP PR_LAB1
	END_DIV: 
        CMP CX,0
        JE  END_POP
        POP DX
        ADD DL,0X30
        MOV [BX],DL
        INC BX 
        DEC CX
        JMP END_DIV
	END_POP:
		RET  
;----------------------------------------------------------------------------
;�ӳ�������FALIURE_SHOW
;���ܣ����ʧ�ܽ���
;��ڲ�������
;���ڲ�������                  
;-----------------------------------------------------------------------------	
FALIURE_SHOW:
		MOV   AX, CS
        MOV   DS, AX  
		MOV  DX,faliure	
		CALL PutStr_Red
		JMP $
		RET 
;----------------------------------------------------------------------------
;�ӳ�������JUDGE
;���ܣ��ж��Ƿ���Ƿ�ײǽ���Ƿ���Լ�
;��ڲ�������
;���ڲ�����bool���ͱ������ж����Ǵ��                  
;-----------------------------------------------------------------------------		
	JUDGE:
		PUSH DS
		MOV AX,CS
		MOV DS,AX
		MOV SI,  S_PO	;����λ���ж��Ƿ�ײǽ
		MOV AH,[SI]
		MOV AL,[SI+1]
		CMP AH,0
		JLE  FALIURE
		CMP AH,20
		JGE  FALIURE
		CMP AL,0
		JLE  FALIURE
		CMP AL,50
		JGE  FALIURE
		
		MOV BX,  S_LEN
		MOV CX,[BX]   
		DEC CX
	SELF:		;�ж��Ƿ�Ե����Լ�
		ADD SI,2   
		MOV DH,[SI]
		MOV DL,[SI+1]
		CMP DH,AH
		JNE S_LAB1
		CMP DL,AL
		JNE S_LAB1
		JMP FALIURE
	   S_LAB1:
		LOOP SELF  
		MOV AX,0
		JMP SURVIVE
	  FALIURE:
		MOV AX,1
	  SURVIVE:
		POP DS
		RET
	
;----------------------------------------------------------------------------
;�ӳ�������CLEAR
;���ܣ�����ָ��
;��ڲ�������
;���ڲ�������                  
;-----------------------------------------------------------------------------
CLEAR:
		MOV AH,0X00                
		MOV AL,0X03
		INT 0X10
		RET 
;----------------------------------------------------------------------------
;�ӳ�������WELL_SHOW
;���ܣ���ʾǽ��
;��ڲ�������
;���ڲ�������                  
;-----------------------------------------------------------------------------
WELL_SHOW:
		MOV   DX,  wall1
        CALL  PutStr                
        ;     
        MOV   DX,  wall2 
        MOV  CX,10
 .LAB1:
        
        CALL PutStr
        LOOP  .LAB1     
		MOV CX,10
		MOV DX,wall2
 .LAB2:
        
        CALL PutStr
        LOOP   .LAB2
		
        MOV   DX,  wall1
        CALL  PutStr
		RET 
;----------------------------------------------------------------------------
;�ӳ�������WELCOME_SHOW
;���ܣ���ʾ�տ�ʼ�Ļ�ӭ�ַ���
;��ڲ�������
;���ڲ�������                  
;-----------------------------------------------------------------------------
WELCOME_SHOW:
		MOV DX,wel
		CALL PutStr_Red
		MOV AL,  [CurCol]
		ADD AL,5
		MOV [CurCol], AL
		MOV AL,  [CurLin]
		ADD AL,2
		MOV [CurLin], AL
		MOV DX,wel2
		CALL PutStr_Red
		RET 
;----------------------------------------------------------------------------
;�ӳ�������PUTSTR
;���ܣ���ʾ�ַ���
;��ڲ�����DX
;���ڲ�������                  
;-----------------------------------------------------------------------------		
 PutStr:                         ;��ʾ�ַ�������0��β��
        MOV   BH, 0
        MOV   SI, DX                ;DX=�ַ�����ʼ��ַƫ��
    LAB1:
        LODSB
        OR    AL, AL
        JZ    LAB2
        MOV   AH, 14
        INT   10H
        JMP   LAB1
    LAB2:
        RET
;----------------------------------------------------------------------------
;�ӳ�������PutStr_Red
;���ܣ�ָ��λ����ʾ�ַ���
;��ڲ������ַ����ĵ�ַ����ŵ�dx��
;���ڲ�������                  
;-----------------------------------------------------------------------------
PutStr_Red: ;��ʾ�ַ�������0��β��
		PUSH SI
		MOV SI,DX
		MOV DL ,[CurCol]
		MOV AL,[SI]
	Red_Lab1:
		MOV DH,[CurLin]
		MOV BL,0X07
		MOV BH,0
		MOV CX,1
		;
		MOV AH,2
		INT 10H
		;
		MOV AH,9
		INT 10H
		;
		INC DL
		INC BL
		INC SI
		MOV AL,[SI]
		OR AL,AL
		JNZ Red_Lab1
		MOV DH,23
		MOV DL,0
		MOV AH,2
		INT 10H
		
		POP SI
		RET 
;----------------------------------------------------------------------------
;�ӳ�������ENTRY_1CH
;���ܣ�ʱ�ӵ��ó���
;��ڲ�������
;���ڲ�������                  
;-----------------------------------------------------------------------------		
    Entry_1CH:
        DEC   BYTE  [CS:count]      ;��������1
        JZ    ETIME                 ;������Ϊ0����ʾʱ��
        IRET                        ;�����жϷ���
        ;
    ETIME:                          
        MOV   BYTE [CS:count], 6   ;�������ü�����ֵ
        ;
        STI                         ;���ж�
        PUSHA                       ;�����ֳ�
        CALL  get_time              ;��ȡ��ǰʱ��
        CALL  EchoTime              ;��ʾ��ǰʱ��
		call  EchoSnake
		call SHOW_SCORE
		call JUDGE
		CMP AX,1
		JNE .LAB1	
		CALL FALIURE_SHOW
		.LAB1:	
        POPA                        ;�ָ��ֳ�
        IRET                        ;�жϷ���
    ;------------------------------
    get_time:                       ;�򻯷�ʽ��ȡʵʱʱ�ӣ�ʱ���룩
        MOV   AL, 4                 ;׼����ȡʱֵ
        OUT   70H, AL
        IN    AL, 71H               ;��ȡʱֵ
        MOV   CH, AL                ;CH=ʱֵBCD��
        MOV   AL, 2                 ;׼����ȡ��ֵ
        OUT   70H, AL
        IN    AL, 71H               ;��ȡ��ֵ
        MOV   CL, AL                ;CL=��ֵBCD��
        MOV   AL, 0                 ;׼����ȡ��ֵ
        OUT   70H, AL
        IN    AL, 71H               ;��ȡ��ֵ
        MOV   DH, AL                ;DH=��ֵBCD��
        RET
    ;------------------------------
    %define   ROW     0            ;ʱ����ʾλ���к�
    %define   COLUMN  60            ;ʱ����ʾλ���к�
    EchoTime:                       ;��ʾ��ǰʱ�䣨ʱ���룩
        PUSH  SI
        ;-----                      ;������ʾʱ���λ��
        PUSH  DX                    ;������ڲ���
        PUSH  CX
        MOV   BH, 0
        MOV   AH, 3                 ;ȡ�õ�ǰ���λ��
        INT   10H
        MOV   SI, DX                ;���浱ǰ���λ��
        MOV   DX, (ROW<<8) + COLUMN
        MOV   AH, 2
        INT   10H                   ;���ù��λ��
        POP   CX
        POP   DX
        ;-----                      ;��ʾ��ǰʱ�䣨ʱ:��:�룩
        MOV   AL, CH
        CALL  EchoBCD               ;��ʾʱֵ
        MOV   AL, ':'
        CALL  PutChar
        MOV   AL, CL
        CALL  EchoBCD               ;��ʾ��ֵ
        MOV   AL, ':'
        CALL  PutChar
        MOV   AL, DH
        CALL  EchoBCD               ;��ʾ��ֵ
        ;-----                      ;�ָ����ԭ��λ��
        MOV   DX, SI
        MOV   AH, 2
        INT   10H
        POP   SI
        RET
    ;------------------------------ 
    EchoBCD:                        ;��ʾ2λBCD��ֵ
        PUSH  AX
        SHR   AL, 4
        ADD   AL, '0'
        CALL  PutChar
        POP   AX
        AND   AL, 0FH
        ADD   AL, '0'
        CALL  PutChar
        RET
    ;------------------------------
    PutChar:                        ;TTY��ʽ��ʾһ���ַ�
        MOV   BH, 0
        MOV   AH, 14
        INT   10H
        RET
    ;------------------------------
    SHOW_TIME:     
        MOV   AX, CS
        MOV   DS, AX                ;DS = CS
        MOV   SI, 1CH*4             ;1CH���ж��������ڵ�ַ
        MOV   AX, 0
        MOV   ES, AX                ;ES = 0
        ;����1CH���ж�����
        MOV   AX, [ES:SI]
        MOV   [old1ch], AX          ;��������֮ƫ��
        MOV   AX, [ES:SI+2]
        MOV   [old1ch+2], AX        ;��������֮��ֵ
        ;�����µ�1CH���ж�����
        CLI                         ;���ж�
        MOV   AX, Entry_1CH
        MOV   [ES:SI], AX           ;����������֮ƫ��
        MOV   AX, CS
        MOV   [ES:SI+2], AX         ;����������֮��ֵ
        STI                         ;���ж�
    Continue:  
		call show_stone
		call JUDGE_stone
		MOV   AH,1
		INT 16H
		JZ	Continue
		
		MOV   AH, 0
        INT   16H		;�����û�����
        PUSH DS
		PUSH AX
		MOV   AX, CS
		MOV   DS, AX  

		POP AX
        CMP AL,20H;D IS ->
        JE	LAB_RIGHT
		CMP AL,1EH;A IS <-
		JE  LAB_LEFT
		CMP AL,11H
		JE	LAB_UP
		CMP AL,1FH
		JNE NEXT
	LAB_DOWN:
		MOV AL,BYTE [STATE];֮ǰ�������ܰ��£�����ͬ��
		CMP AL,GO_UP
		JE NEXT
		MOV BYTE [STATE],GO_DOWN
		JMP NEXT
	LAB_RIGHT:
		MOV AL,BYTE [STATE]
		CMP AL,GO_LEFT
		JE NEXT
		MOV BYTE [STATE],GO_RIGHT
		JMP NEXT
	LAB_UP:
		MOV AL,BYTE [STATE]
		CMP AL,GO_DOWN
		JE NEXT
		MOV BYTE [STATE],GO_UP
		JMP NEXT
	LAB_LEFT:
		MOV AL,BYTE [STATE]
		CMP AL,GO_RIGHT
		JE NEXT
		MOV BYTE [STATE],GO_LEFT
		JMP NEXT
	NEXT:
		call  SNAKE_CLEAR
		call  MOVE
		call  SNAKE_SHOW 
		pop   DS	
        jmp    Continue
		
        MOV   EAX, [CS:old1ch]      ;��ȡ�����ԭ1CH���ж�����
        MOV   [ES:SI], EAX          ;�ָ�ԭ1CH���ж�����
        ;
        RET
	;----------------------------------------------------------------------------
;�ӳ�������EchoSnake
;���ܣ������ߵ���ʾ���ƶ�����պ������������ƶ��Ķ���
;��ڲ�������
;���ڲ�������                  
;-----------------------------------------------------------------------------	
EchoSnake:
		PUSH  SI
		call  SNAKE_CLEAR
		call  MOVE
		call  SNAKE_SHOW 
		;-------------------------
        POP   SI
        RET
;----------------------------------------------------------------------------
;�ӳ�������KEY_BOARD
;���ܣ������жϴ���������
;��ڲ�������
;���ڲ�������                  
;-----------------------------------------------------------------------------		
KEY_BOARD:                          
        MOV   AX, 0                     ;׼�������ж�����
        MOV   DS, AX
        CLI
        MOV   WORD [9*4], int09h_handler
        MOV   [9*4+2], CS               ;�����µļ����жϴ������
        STI
        ret                           ;���������ص���������
;-----------------------------------
    int09h_handler:                     ;�µ�9�ż����жϴ������������ֻ����ASDW�ĸ���
        PUSHA                           ;����ͨ�üĴ���
        ;
        MOV   AL, 0ADH
        OUT   PORT_KEY_STA, AL          ;��ֹ���̷������ݵ��ӿ�
        ;
        IN    AL, PORT_KEY_DAT          ;�Ӽ��̽ӿڶ�ȡ����ɨ����
        ;
        STI                             ;���ж�
        CALL  Int09hfun                 ;�����ع���
        ;
        CLI                             ;���ж�
        MOV   AL, 0AEH
        OUT   PORT_KEY_STA, AL          ;������̷������ݵ��ӿ�
        ;
        MOV   AL, 20H                   ;֪ͨ�жϿ�����8259A
        OUT   20H, AL                   ;��ǰ�жϴ����Ѿ�����
        ;
        POPA                            ;�ָ�ͨ�üĴ���
        ;
        IRET                            ;�жϷ���
    ;-----------------------------------
    Int09hfun:                          ;��ʾ9H���жϴ������ľ��幦��
    .LAB1:								;��ʶ����WASDʮ����
        CMP   AL, 1EH                   ;�ж���ĸA��ɨ����
        JB    .LAB4                    ;���ڣ���ֱ�Ӷ���
        CMP   AL, 20H                   ;�ж���ĸD��ɨ����
        JA    .LAB3                     
	.LAB5:	
        MOV   AH, AL                    ;����ɨ����
    .LAB2:
        CALL  Enqueue   
		jmp .LAB3
	.LAB4:
	    CMP AL,11H
		je .LAB5
    .LAB3:
        RET                          
	
    ;-----------------------------------
    Enqueue:                            ;��ɨ�����ASCII�������̻�����
		PUSH  DS                        ;����DS
        MOV   BX, 40H
        MOV   DS, BX                    ;DS=0040H
        MOV   BX, [001CH]               ;ȡ���е�βָ��
        MOV   SI, BX                    ;SI=����βָ��
        ADD   SI, 2                     ;SI=��һ������λ��
        CMP   SI, 003EH                 ;Խ������������
        JB    .LAB1                     ;û�У�ת
        MOV   SI, 001EH                 ;�ǵģ�ѭ����������ͷ��
    .LAB1:
        CMP   SI, [001AH]               ;�����ͷָ��Ƚ�
        JZ    .LAB2                     ;��ȱ�ʾ�������Ѿ���
        MOV   [BX], AX                  ;��ɨ�����ASCII���������
        MOV    [001CH], SI              ;�������βָ��
    .LAB2:
        POP   DS                        ;�ָ�DS
        RET                             ;����
;----------------------------------------------------------------------------
;�ӳ�������INIT
;���ܣ���ʼ��С�߳���
;��ڲ�������
;���ڲ�������                  
;-----------------------------------------------------------------------------	
INIT:   
		XOR SI,SI
		MOV BX, S_LEN
		MOV CX,[BX] 
		MOV BX, S_PO  
		MOV DH,12
	INIT_LAB1:
		MOV BYTE [BX+SI],12
		MOV BYTE [BX+SI+1],DH
		DEC DH    
		ADD SI,2
		LOOP  INIT_LAB1
		RET   
;----------------------------------------------------------------------------
;�ӳ�������SNAKE_SHOW
;���ܣ���ʾС��
;��ڲ�������
;���ڲ�������                  
;-----------------------------------------------------------------------------		
SNAKE_SHOW:
		PUSH DS
		MOV   AX, CS
		MOV   DS, AX  
		XOR SI,SI 
		MOV BX, S_LEN
		MOV CX,[BX] 
		MOV BX, S_PO
	SHOW_LAB1:
		MOV DH,[BX+SI]
		MOV DL,[BX+SI+1]
		MOV AL,'#'
		PUSH BX
		MOV BH,0
		MOV BL,04H
		PUSH CX 
		MOV CX,[SCORE] ;ÿ��4�ֻ�һ����ɫ
		SHR CX,2
		ADD BL,CL
		POP CX
		MOV AH,2
		INT 10H
		PUSH CX
		MOV CX,1
		MOV AH,9
		INT 10H
		POP CX
		POP BX
		ADD SI,2   
		LOOP SHOW_LAB1
		POP DS
		RET    
;----------------------------------------------------------------------------
;�ӳ�������MOVE
;���ܣ��ƶ�С�߳���
;��ڲ�������
;���ڲ�������                  
;-----------------------------------------------------------------------------   
MOVE:  
		PUSH DS
		MOV   AX, CS
		MOV   DS, AX  
		MOV BX, S_LEN
		MOV CX,[BX]        
		MOV SI, S_PO  
		MOV DI,SI 
		PUSH SI   ;���ȴ��������׵�ַ   
		SHL CX,1;CX*2 �Ǵ�С
		SUB CX,2;CX-2 ��ָ�������һ��Ԫ�ص�λ��
		ADD DI,CX;DIָ�����һ��Ԫ��
		SUB CX,2;CX�ټ�2
		ADD SI,CX ;SI��ŵ����ڶ���Ԫ�ص�λ��
		ADD CX,2  
		SHR CX,1  ;CX+2�ٳ���2֮��õ������ƶ��ĳ��ȣ�
	CPYMEM:
		MOV AX,[SI]
		MOV [DI],AX
		SUB SI,2
		SUB DI,2
		LOOP CPYMEM 
		POP SI   ;ȡ�����ȴ��������׵�ַ    
		MOV BX,  STATE  
		MOV CL,[BX] 
		CMP CL,GO_RIGHT
		JE  TURN_RIGHT
		CMP CL,GO_LEFT
		JE  TURN_LEFT
		CMP CL,GO_UP
		JE  TURN_UP  
		INC BYTE [SI]
		JMP   TURN_END 
		TURN_UP:  
		DEC BYTE [SI] 
		JMP   TURN_END 
		TURN_LEFT:
		DEC BYTE [SI+1]     
		JMP   TURN_END 
		TURN_RIGHT:    
		INC BYTE [SI+1]
		TURN_END:
		POP DS
		RET 	
;----------------------------------------------------------------------------
;�ӳ�������SNAKE_CLEAR
;���ܣ�����С�߳���
;��ڲ�������
;���ڲ�������                  
;-----------------------------------------------------------------------------	
SNAKE_CLEAR:
		PUSH DS
		MOV   AX, CS
		MOV   DS, AX  
		XOR SI,SI 
		MOV BX, S_LEN
		MOV CX,[BX] 
		MOV BX, S_PO
	.LAB1:
		MOV DH,[BX+SI]
		MOV DL,[BX+SI+1]
		MOV AL,' '
		PUSH BX
		MOV BH,0
		MOV BL,0
		MOV AH,2
		INT 10H
		PUSH CX
		MOV CX,1
		MOV AH,9
		INT 10H
		POP CX
		POP BX
		ADD SI,2   
		LOOP .LAB1
		POP DS
		RET
;----------------------------------------------------------------------------
;�ӳ�������RAND
;���ܣ������������
;��ڲ�������
;���ڲ�������                  
;-----------------------------------------------------------------------------	
RAND:
	  PUSH DS
	  MOV AX,CS
	  MOV DS,AX
      PUSH CX
      PUSH DX
      PUSH AX
      STI
      MOV AH,0             ;��ʱ�Ӽ�����ֵ
      INT 1AH
      MOV AX,DX            ;���6λ
      AND AH,3
      MOV CX,AX
      MOV DL,19           ;��19������0~19����
      DIV DL
      MOV BL,AH            
      INC BL               ;ʯͷ���д���BL
      MOV [stone_position],BL;
      MOV AX,CX;
      MOV DL,49           ;��49������0~49����
      DIV DL
      MOV BL,AH            
      INC BL               ;ʯͷ���д���BL
      MOV [stone_position+1],BL;
      POP AX
      POP DX
      POP CX
	  POP DS
      RET
;----------------------------------------------------------------------------
;�ӳ�������SHOW_STONE
;���ܣ���ʾ����
;��ڲ�������
;���ڲ�������                  
;-----------------------------------------------------------------------------
show_stone:
	  PUSH DS
	  MOV AX,CS
	  MOV DS,AX 
	  PUSH AX
	  PUSH BX
	  PUSH CX
	  PUSH DX
	  MOV AL,[stone_state]
	  CMP AL,0
	  JNE LABLE1
	  CALL RAND
	  MOV AL,1
	  MOV [stone_state],AL;
LABLE1:	  
      MOV BX,stone_position
      MOV DH,[BX]
      MOV DL,[BX+1]
      MOV AL,'$'
      MOV BH,0
      MOV BL,30H
	  PUSH CX 
	  MOV CX,[SCORE] ;ÿ��4�ֻ�һ����ɫ
	  SHR CX,2
	  ADD BL,CL
	  POP CX
      MOV AH,2
      INT 10H;
      MOV CX,1
      MOV AH,9H
      INT 10H
	  POP DX
	  POP CX
	  POP BX
	  POP AX
	  POP DS 
	  RET;
;----------------------------------------------------------------------------
;�ӳ�������SHOW_STONE
;���ܣ��ж�С���Ƿ�Ե�����
;��ڲ�������
;���ڲ�������                  
;-----------------------------------------------------------------------------
JUDGE_stone:
		PUSH DS
		MOV AX,CS
		MOV DS,AX
		MOV BX,[S_PO]
		MOV DI,BX;DI����ͷ��λ��
		MOV BX,[stone_position]
		MOV SI,BX;SI��ʯ�ӵ�λ��
		CMP SI,DI
		JNE NOT_EAT_STONE
		INC SI
		INC DI
		CMP SI,DI
		JNE NOT_EAT_STONE;
		MOV BX,[S_LEN]
		INC BX;
		MOV [S_LEN],BX;
		XOR BL,BL;
		MOV [stone_state],BL
		CALL ADD_SCORE
	NOT_EAT_STONE:
		POP DS
		RET
;---------------------
end_of_text:
