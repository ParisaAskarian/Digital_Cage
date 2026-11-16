
#make_bin#
.MODEL SMALL
.DATA


    PORT_KEYPAD      EQU 00h        
    PORT_LCD_CMD     EQU 04h        
    PORT_LCD_DATA    EQU 06h 
    PORT_VOICE_DATA  EQU 10h
    PORT_VOICE_STAT  EQU 12h       

    PASS_LENGTH      EQU 6          
    SAVED_PASSWORD   DB  6 DUP(0)  
    USER_INPUT       DB  6 DUP(0)
    SAVED_VOICE_SIGN DB  0 

.CODE
START:
    MOV AL, 82h
    OUT 06h,AL
    MOV AX, @DATA
    MOV DS, AX

SHOW_SET_CODE_MSG:
    MOV AL, 01h             
    OUT PORT_LCD_CMD, AL
                                                                 
    MOV AL, 'S'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'e'
    OUT PORT_LCD_DATA, AL
    MOV AL, 't'
    OUT PORT_LCD_DATA, AL
    MOV AL, ' '
    OUT PORT_LCD_DATA, AL
    MOV AL, 'C'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'o'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'd'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'e'
    OUT PORT_LCD_DATA, AL
    MOV AL, ':'
    OUT PORT_LCD_DATA, AL     
    MOV CX, PASS_LENGTH     
    MOV SI, 0               

RECORD_INITIAL_CODE:
    IN AL, PORT_KEYPAD      
    CMP AL, 0               
    JZ RECORD_INITIAL_CODE  
    
    CMP AL, 0Ah             
    JE RECORD_INITIAL_CODE  

    MOV SAVED_PASSWORD[SI], AL  

    ADD AL, 30h             
    OUT PORT_LCD_DATA, AL   
    
    INC SI                  
    CALL DELAY              
    LOOP RECORD_INITIAL_CODE 

SHOW_CONFIRM_PROMPT:
    MOV AL, ' '
    OUT PORT_LCD_DATA, AL
    MOV AL, '-'
    OUT PORT_LCD_DATA, AL
    MOV AL, '>'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'P'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'r'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'e'
    OUT PORT_LCD_DATA, AL
    MOV AL, 's'
    OUT PORT_LCD_DATA, AL
    MOV AL, 's'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'E'
    OUT PORT_LCD_DATA, AL

WAIT_FOR_CONFIRM_KEY:
    IN AL, PORT_KEYPAD      
    CMP AL, 0Ah             
    JNE WAIT_FOR_CONFIRM_KEY 
    
SETUP_VOICE_PHRASE:
    MOV AL, 01h             
    OUT PORT_LCD_CMD, AL
    
    MOV AL, 'S'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'a'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'y'
    OUT PORT_LCD_DATA, AL
    MOV AL, ' '
    OUT PORT_LCD_DATA, AL
    MOV AL, 'P'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'h'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'r'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'a'
    OUT PORT_LCD_DATA, AL
    MOV AL, 's'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'e'
    OUT PORT_LCD_DATA, AL
    MOV AL, ':'
    OUT PORT_LCD_DATA, AL

    MOV AL, 01h             
    OUT PORT_VOICE_DATA, AL

WAIT_FOR_VOICE_DIGITIZE:
    IN AL, PORT_VOICE_STAT  
    TEST AL, 02h            
    JZ WAIT_FOR_VOICE_DIGITIZE 

    IN AL, PORT_VOICE_DATA  
    
    MOV SAVED_VOICE_SIGN[0], AL 

WAIT_FOR_VOICE_CONFIRM:
    IN AL, PORT_KEYPAD      
    CMP AL, 0Ah             
    JNE WAIT_FOR_VOICE_CONFIRM 

    MOV AL, 01h             
    OUT PORT_LCD_CMD, AL
    MOV AL, 'S'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'U'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'C'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'C'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'E'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'S'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'S'
    OUT PORT_LCD_DATA, AL   
    
NORMAL_OPERATION_MODE:
    MOV AL, 01h             
    OUT PORT_LCD_CMD, AL

    CALL DELAY

    MOV AL, 'E'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'n'
    OUT PORT_LCD_DATA, AL
    MOV AL, 't'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'e'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'r'
    OUT PORT_LCD_DATA, AL
    MOV AL, ' '
    OUT PORT_LCD_DATA, AL
    MOV AL, 'C'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'o'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'd'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'e'
    OUT PORT_LCD_DATA, AL
    MOV AL, ':'
    OUT PORT_LCD_DATA, AL

    MOV CX, PASS_LENGTH     
    MOV SI, 0               

READ_UNLOCK_KEYPAD:
    IN AL, PORT_KEYPAD      
    CMP AL, 0               
    JZ READ_UNLOCK_KEYPAD   
    
    CMP AL, 0Ah             
    JE READ_UNLOCK_KEYPAD   

    MOV USER_INPUT[SI], AL  
    
    MOV AL, '*'             
    OUT PORT_LCD_DATA, AL   
    
    INC SI                  
    CALL DELAY              
    LOOP READ_UNLOCK_KEYPAD 

WAIT_FOR_UNLOCK_CONFIRM:
    IN AL, PORT_KEYPAD      
    CMP AL, 0Ah             
    JNE WAIT_FOR_UNLOCK_CONFIRM  
                                 
COMPARE_STORED_CODES:
    MOV CX, PASS_LENGTH     
    MOV SI, 0               

CHECK_DIGITS_LOOP:
    MOV AL, USER_INPUT[SI]      
    CMP AL, SAVED_PASSWORD[SI]  
    JNE UNLOCK_CODE_WRONG       
    
    INC SI                      
    LOOP CHECK_DIGITS_LOOP      

UNLOCK_CODE_RIGHT:
    MOV AL, 01h             
    OUT PORT_LCD_CMD, AL
    
    MOV AL, 'S'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'a'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'y'
    OUT PORT_LCD_DATA, AL
    MOV AL, ' '
    OUT PORT_LCD_DATA, AL
    MOV AL, 'P'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'h'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'r'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'a'
    OUT PORT_LCD_DATA, AL
    MOV AL, 's'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'e'
    OUT PORT_LCD_DATA, AL
    MOV AL, ':'
    OUT PORT_LCD_DATA, AL

    JMP UNLOCK_VOICE_PHASE      

UNLOCK_CODE_WRONG:
    MOV AL, 01h             
    OUT PORT_LCD_CMD, AL

    MOV AL, 'E'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'r'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'r'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'o'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'r'
    OUT PORT_LCD_DATA, AL
    MOV AL, ','
    OUT PORT_LCD_DATA, AL
    MOV AL, 'T'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'r'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'y'
    OUT PORT_LCD_DATA, AL
    
    CALL LONG_DELAY
    
    JMP NORMAL_OPERATION_MODE 
    
UNLOCK_VOICE_PHASE:
    MOV AL, 02h
    OUT PORT_VOICE_DATA, AL

WAIT_FOR_USER_SPEECH:
    IN AL, PORT_VOICE_STAT
    TEST AL, 02h                
    JZ WAIT_FOR_USER_SPEECH     

    IN AL, PORT_VOICE_DATA
    MOV BL, AL                  

WAIT_FOR_VOICE_UNLOCK_CONFIRM:
    IN AL, PORT_KEYPAD          
    CMP AL, 0Ah                 
    JNE WAIT_FOR_VOICE_UNLOCK_CONFIRM 

COMPARE_VOICE_SIGNATURES:
    CMP BL, SAVED_VOICE_SIGN[0] 
    JNE VOICE_PHRASE_WRONG      

SAFE_OPEN_SUCCESS:
    MOV AL, 01h             
    OUT PORT_LCD_CMD, AL

    MOV AL, 'C'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'o'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'n'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'g'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'r'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'a'
    OUT PORT_LCD_DATA, AL
    MOV AL, 't'
    OUT PORT_LCD_DATA, AL
    MOV AL, 's'
    OUT PORT_LCD_DATA, AL
    
    MOV AL, 01h
    JMP SYSTEM_EXIT

VOICE_PHRASE_WRONG:
    MOV AL, 01h             
    OUT PORT_LCD_CMD, AL

    MOV AL, 'W'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'r'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'o'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'n'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'g'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'V'
    OUT PORT_LCD_DATA, AL

    CALL LONG_DELAY

    MOV AL, 01h
    OUT PORT_LCD_CMD, AL
    
    MOV AL, 'S'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'a'
    OUT PORT_LCD_DATA, AL
    MOV AL, 'y'
    OUT PORT_LCD_DATA, AL
    MOV AL, ':'
    OUT PORT_LCD_DATA, AL

    JMP UNLOCK_VOICE_PHASE

SYSTEM_EXIT:
    JMP SYSTEM_EXIT
    
DELAY PROC
    PUSH CX
    MOV CX, 0FFFFh
D1:
    LOOP D1
    POP CX
    RET
DELAY ENDP

LONG_DELAY PROC
    PUSH CX
    MOV CX, 0Fh
L1:
    PUSH CX
    MOV CX, 0FFFFh
L2:
    LOOP L2
    POP CX
    LOOP L1
    POP CX
    RET
LONG_DELAY ENDP

END START

    
 



