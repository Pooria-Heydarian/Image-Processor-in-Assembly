    sys_read     equ     0
    sys_write    equ     1
    sys_open     equ     2
    sys_close    equ     3
    
    sys_lseek    equ     8
    sys_create   equ     85
    sys_unlink   equ     87
      

    sys_mkdir       equ 83
    sys_makenewdir  equ 0q777


    sys_mmap     equ     9
    sys_mumap    equ     11
    sys_brk      equ     12
    
     
    sys_exit     equ     60
    
    stdin        equ     0
    stdout       equ     1
    stderr       equ     3

 
	PROT_NONE	  equ   0x0
    PROT_READ     equ   0x1
    PROT_WRITE    equ   0x2
    MAP_PRIVATE   equ   0x2
    MAP_ANONYMOUS equ   0x20
    
    ;access mode
    O_DIRECTORY equ     0q0200000
    O_RDONLY    equ     0q000000
    O_WRONLY    equ     0q000001
    O_RDWR      equ     0q000002
    O_CREAT     equ     0q000100
    O_APPEND    equ     0q002000


    BEG_FILE_POS    equ     0
    CURR_POS        equ     1
    END_FILE_POS    equ     2
    
; create permission mode
    sys_IRUSR     equ     0q400      ; user read permission
    sys_IWUSR     equ     0q200      ; user write permission

    NL            equ   0xA
    Space         equ   0x20

newLine:
   push   rax
   mov    rax, NL
   call   putc
   pop    rax
   ret

space:
   push   rax
   mov    rax, Space
   call   putc
   pop    rax
   ret

putc:	

   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

   push   ax
   mov    rsi, rsp    ; points to our char
   mov    rdx, 1      ; how many characters to print
   mov    rax, sys_write
   mov    rdi, stdout 
   syscall
   pop    ax

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx
   ret
writeNum:
   push   rax
   push   rbx
   push   rcx
   push   rdx

   sub    rdx, rdx
   mov    rbx, 10 
   sub    rcx, rcx
   cmp    rax, 0
   jge    wAgain
   push   rax 
   mov    al, '-'
   call   putc
   pop    rax
   neg    rax  

wAgain:
   cmp    rax, 9	
   jle    cEnd
   div    rbx
   push   rdx
   inc    rcx
   sub    rdx, rdx
   jmp    wAgain

cEnd:
   add    al, 0x30
   call   putc
   dec    rcx
   jl     wEnd
   pop    rax
   jmp    cEnd
wEnd:
   pop    rdx
   pop    rcx
   pop    rbx
   pop    rax
   ret

;;---------------------------------------------------------
getc:
   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

 
   sub    rsp, 1
   mov    rsi, rsp
   mov    rdx, 1
   mov    rax, sys_read
   mov    rdi, stdin
   syscall
   mov    al, [rsi]
   add    rsp, 1

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx

   ret
;---------------------------------------------------------

readNum:
   push   rcx
   push   rbx
   push   rdx

   mov    bl,0
   mov    rdx, 0
rAgain:
   xor    rax, rax
   call   getc
   cmp    al, '-'
   jne    sAgain
   mov    bl,1  
   jmp    rAgain
sAgain:
   cmp    al, NL
   je     rEnd
   cmp    al, ' ' ;Space
   je     rEnd
   sub    rax, 0x30
   imul   rdx, 10
   add    rdx,  rax
   xor    rax, rax
   call   getc
   jmp    sAgain
rEnd:
   mov    rax, rdx 
   cmp    bl, 0
   je     sEnd
   neg    rax 
sEnd:  
   pop    rdx
   pop    rbx
   pop    rcx
   ret
   ;------

printString:
   push    rax
   push    rcx
   push    rsi
   push    rdx
   push    rdi

   mov     rdi, rsi
   call    GetStrlen
   mov     rax, sys_write  
   mov     rdi, stdout
   syscall 
   
   pop     rdi
   pop     rdx
   pop     rsi
   pop     rcx
   pop     rax
   ret
;-------------------------------------------
; rdi : zero terminated string start 
GetStrlen:
   push    rbx
   push    rcx
   push    rax  

   xor     rcx, rcx
   not     rcx
   xor     rax, rax
   cld
         repne   scasb
   not     rcx
   lea     rdx, [rcx -1]  ; length in rdx

   pop     rax
   pop     rcx
   pop     rbx
   ret

print_file:
    mov eax, 5                       
    mov ecx, 577                     
    mov edx, 0644                    
    int 0x80                         
    mov [fd], eax                    

    ; Convert matrix dimensions to ASCII and write to the file
    mov eax, [height]
    call writeNum
    call newLine
    call int_to_ascii
    mov eax, 4                       
    mov ebx, [fd]                    
    int 0x80                         
    ; Write a space
    mov eax, 4                       
    mov ebx, [fd]                    
    mov ecx, spc                   
    mov edx, 1                     
    int 0x80                       
    ; Convert matrix width to ASCII and write to the file
    mov eax, [width]
    call writeNum
    call newLine
    call int_to_ascii
    mov eax, 4                     
    mov ebx, [fd]                  
    int 0x80                       

; Write a space
    mov eax, 4                       
    mov ebx, [fd]                    
    mov ecx, spc                   
    mov edx, 1                     
    int 0x80                       

    mov eax, [depth]
    call writeNum
    call newLine
    call int_to_ascii
    mov eax, 4                     
    mov ebx, [fd]                  
    int 0x80   
    ; Write a newline character
    mov eax, 4                     
    mov ebx, [fd]                  
    mov ecx, newlin                
    mov edx, 1                     
    int 0x80                       
    ; Iterate through the matrix
    xor r9, r9       
    xor r8 ,r8       
    xor r10,r10      
    xor rcx, rcx 
    xor rdx, rdx
iterate_rows:
    mov edx, [height]
    cmp rdx, r8
    je done                      
    xor r9,r9                    
iterate_columns:
    mov edx, [width]
    cmp rdx, r9 
    je next_row3                     

    mov eax, [rsi + 4 * r10]
    ; Convert the element to ASCII and write to buffer
    call int_to_ascii
    ; Write the ASCII representation to the file
    mov eax, 4                       
    mov ebx, [fd]                    
    int 0x80                         
    ; Write a space
    mov eax, 4                       
    mov ebx, [fd]                    
    mov ecx, spc                   
    mov edx, 1                     
    int 0x80                       
    ; Increment column index
    inc r9
    inc r10
    jmp iterate_columns
next_row3:
    ; Write a newline character
    mov eax, 4                     
    mov ebx, [fd]                  
    mov ecx, newlin                
    mov edx, 1                      
    int 0x80                        
    ; Increment row index
    inc r8
    jmp iterate_rows
done:
    ; Close the file
    mov eax, 6                      
    mov ebx, [fd]                   
    int 0x80                        

    ret



; Subroutine to convert integer to ASCII and calculate length
int_to_ascii:
    push rax
    mov rdi, buffer_write           
    
    add rdi, 30                     
    
    mov byte [rdi], 0               
    xor edx, edx                    
    mov ebx, 10
convert_loop:
    dec rdi
    xor edx, edx

    div ebx                          
    
    add dl, '0'                     
    mov [rdi], dl                   
    inc edx                         
    test eax, eax
    jnz convert_loop
    mov rdx, buffer_write
    add rdx, 30
    sub rdx, rdi

    mov ecx, edi                    
    pop rax
    ret

section .data
    menu_prompt             db "Image Processing Menu", 0xA, 0xD
                db "1. Open Photo and Convert to Matrix", 0xA, 0xD
                db "2. Reshape Matrix", 0xA, 0xD
                db "3. Resize Photo", 0xA, 0xD
                db "4. Convert to Grayscale", 0xA, 0xD
                db "5. Apply Convolution Filters", 0xA, 0xD
                db "6. Perform Pooling", 0xA, 0xD
                db "7. Add Noise", 0xA, 0xD
                db "8. Output Processed Matrix", 0xA, 0xD
                db "9. Exit", 0xA, 0xD
                db "Enter your choice: ", 0
    menu_prompt_size        equ $ - menu_prompt
    invalid_choice_msg      db "Invalid choice. Please enter a valid option.", 0xA, 0xD
    invalid_choice_msg_size equ $ - invalid_choice_msg

    prompt1_msg             db "Enter the address of the photo: ", 0
    prompt1_msg_size        equ $ - prompt1_msg
    python_interpreter      db '/usr/bin/python3', 0
    python_script           db './convert.py', 0
    exit_msg                db "Python script has completed processing.", 0xA, 0xD
    exit_msg_size           equ $ - exit_msg
    error_msg               db 'Error executing convert.py', 0xA, 0xD
    error_msg_size          equ $ - error_msg
    python_script_not_found db "Error: Python script not found or inaccessible.", 0xA, 0xD
    python_script_not_found_size equ $ - python_script_not_found


    input_filename          db 'matrix.txt', 0
    output_filename         db 'Reshaped_matrix.txt', 0
    prompt2_msg             db "Enter new dimension: ", 0
    prompt2_msg_size        equ $ - prompt2_msg
    error2_msg              db "Error processing file.", 0xA, 0xD
    error2_msg_size         equ $ - error2_msg
    reshaped_msg            db "Matrix reshaped successfully.", 0xA, 0xD
    success_msg2            db "File truncated successfully.", 0xA, 0xD
    success_msg2_size       equ $ - success_msg2
    mode                    db 'r+', 0

    prompt_new_height       db 'Enter new height: ', 0 
    prompt_new_width        db 'Enter new Width: ', 0
    scaling_factor_x        dd 0
    scaling_factor_y        dd 0 
    resized_filename        db 'resized.txt', 0
    
    fixed_299               dd 19530
    fixed_587               dd 38470
    fixed_114               dd 7471 
    gray_filename           db 'gray.txt', 0

    CNN_prompt             db "CNN Filters Menu", 0xA, 0xD
                           db "1. Sharpening", 0xA, 0xD
                           db "2. Emboss", 0xA, 0xD
                           db "Enter your choice: ", 0
    CNN_prompt_size  equ $ - CNN_prompt
    sharpen_kernel         dq 0,-1, 0,-1, 5,-1, 0,-1, 0 
    emboss_kernel          dq -2,-1,0,-1,1,1,0,1,2
    CNN_filename           db 'cnn.txt', 0

    Pool_prompt             db "Pooling Menu", 0xA, 0xD
                           db "1. Max Pooling", 0xA, 0xD
                           db "2. Averge Pooling", 0xA, 0xD
                           db "Enter your choice: ", 0
    Pool_prompt_size       equ $ - Pool_prompt
    prompt_New_size        db 'Enter desire size: ', 0
    size_prompt_new_size   equ  $ - prompt_New_size 
    pool_filename          db 'pool.txt', 0

    spc                    db ' ',0
    newlin                 db 10,0

    noisy_filename         db 'noise.txt', 0

    python_script_out      db './show.py', 0


section .bss

    choice          resb 2  ; Buffer to store user's choice
    photo_address   resb 100  ; Buffer to store the photo address
    args:           resd 4
    file_handle     resq 1  

    mat_len         resd 1 
    pooled_mat_len  resd 1
    resized_mat_len resd 1
 
    matrixr         resd 5000000
    matrixg         resd 5000000
    matrixb         resd 5000000
    matrix_gray     resd 5000000
    matrix_sharpen  resq 5000000
    matrix_convo    resq 5000000
    paded_matrix    resd 5000000
    pooled_matrix   resd 5000000
    matrix          resd 200000000
    resized_matrix  resd 200000000 
    buffer          resb 200000000  ; Buffer for reading lines from the file
    numbuffer       resb 10
    new_dimensions  resb 20  ; Buffer for new dimensions input

    height          resd 1
    width           resd 1
    depth           resd 1
    new_height      resd 1
    new_width       resd 1
    pool_width      resq 1
    pool_height     resq 1
    rows            resd 1
    file_size       resd 1

    fd resd 1
    buffer_write resb 30


section .text
    global _start

_start:
    jmp display_menu  ; Jump to display menu initially

; Function to display the menu
display_menu:
    mov eax, 4  
    mov ebx, 1  
    mov ecx, menu_prompt
    mov edx, menu_prompt_size
    int 0x80    

    ; Read user's choice
    mov eax, 3  
    mov ebx, 0  
    mov ecx, choice
    mov edx, 2  
    int 0x80    

    ; Process user's choice
    cmp byte [choice], '1'
    je open_photo_convert_matrix
    cmp byte [choice], '2'
    je reshape_matrix
    cmp byte [choice], '3'
    je resize_photo
    cmp byte [choice], '4'
    je convert_to_grayscale
    cmp byte [choice], '5'
    je apply_convolution_filters
    cmp byte [choice], '6'
    je perform_pooling
    cmp byte [choice], '7'
    je add_noise
    cmp byte [choice], '8'
    je output_processed_matrix
    cmp byte [choice], '9'
    je exit_program

    ; Invalid choice
    jmp invalid_choice

open_photo_convert_matrix:
    ; Display prompt to enter photo address
    mov eax, 4  
    mov ebx, 1  
    mov ecx, prompt1_msg
    mov edx, prompt1_msg_size
    int 0x80   

    ; Read photo address from user input (max byre = 100
    mov eax, 3  
    mov ebx, 0  
    mov ecx, photo_address
    mov edx, 100  
    int 0x80
    
    ; Remove newline character from input
    mov ecx, photo_address
remove_newline:
    cmp byte [ecx], 0xA 
    je newline_removed
    inc ecx
    jmp remove_newline

newline_removed:
    mov byte [ecx], 0   

    ; Call Python script to process the photo and generate matrix
    mov ecx, args
    mov dword [ecx], python_interpreter
    mov dword [ecx+4], python_script
    mov dword [ecx+8], photo_address
    mov dword [ecx+12], 0 

    ; Prepare envp (NULL)
    xor edx, edx  

    ; Call execve
    mov eax, 11         
    mov ebx, python_interpreter
    int 0x80   


    ; Prepare syscall waitpid
    mov eax, 0x7D 
    xor ebx, ebx 
    xor ecx, ecx 
    int 0x80 

    ; Display completion message
    mov eax, 4 
    mov ebx, 1 
    mov ecx, exit_msg
    mov edx, exit_msg_size
    int 0x80 


    jmp end_menu

reshape_matrix:
    ; Display prompt for new dimensions
    mov eax, 4  
    mov ebx, 1  
    mov ecx, prompt2_msg
    mov edx, prompt2_msg_size
    int 0x80    

    ; Read new dimensions from user input
    call readNum
    mov [new_dimensions], rax  

    ; Open the input file for reading
    mov eax, 5  
    mov ebx, input_filename 
    mov ecx, 0  
    int 0x80    
    jc error    
    
    mov esi, eax

    ; Read the first line (dimensions)
    mov eax, 3  
    mov ebx, esi  
    mov ecx, buffer  
    mov edx, 150  
    int 0x80    
    jc error    



    push rsi
    push rcx
    ; Parse the dimensions from the first line
    mov esi, buffer
    xor ecx, ecx 
    call parse_first_line
    pop rcx
    pop rsi 

    mov eax, [new_dimensions]
    mov ebx, [depth]
    cmp eax, ebx
    jg error

    
    ; claculate remain lines
    mov eax, [new_dimensions]
    ;call writeNum
    mov ebx, [height]
    mul rbx 
    inc rax
    mov [rows], rax
    ;skip rows
    mov eax, 5 
    mov ebx, input_filename 
    mov ecx, 0  
    int 0x80    
    jc error    
    mov esi, eax


    xor rcx, rcx  ; ECX will be our line counter
    xor rbx, rbx  ; EBX will be our file size counter

read_characters:
    ; Read a character from the file
    push rcx
    push rbx

    mov eax, 3  
    mov ebx, esi 
    mov ecx, buffer  
    mov edx, 1  
    int 0x80

    pop rbx
    pop rcx 
    

    ; Increment file size counter
    inc rbx

    ; Check if the character is a newline
    cmp byte [buffer], 0x0A  ; '\n'
    jne read_characters

    ; Increment line counter
    inc rcx

    ; Check if we've read N lines
    cmp ecx, dword [rows]
    jl read_characters

truncate_file:

    
    mov [file_size], ebx

    mov eax, 3                 
    mov ebx, esi               
    int 0x80

    ; Truncate the file after skipping N lines
    ; Open the input file for reading and writing
    mov rax, 2                 
    mov rdi, input_filename      
    mov rsi, 2                   
    syscall                      
    mov qword [file_handle], rax   

    ; Truncate the file to the specified size
    mov rax, 77                    
    mov rdi, qword [file_handle]   
    mov rsi, [file_size]              
    syscall                         

    ; Close the input file
    mov rax, 3                      
    mov rdi, qword [file_handle]   
    syscall                         


    ; Display success message
    mov eax, 4  
    mov ebx, 1  
    mov ecx, success_msg2
    mov edx, success_msg2_size
    int 0x80    


    jmp end_menu
error:

    mov eax, 4
    mov ebx, 1 
    mov ecx, error_msg
    mov edx, error_msg_size
    int 0x80   
    
    mov eax, 1  
    mov ebx, 1 
    int 0x80   


parse_first_line:
    call parse_integer
    mov [height], eax
    
    call parse_integer
    mov [width], eax
    
    
    call parse_integer
    mov [depth], eax
    
    ret


parse_integer:
    xor ebx, ebx  
    xor eax, eax  

    
parse_integer_loop:
    
    mov al, byte [esi + ecx]
    inc ecx
    
    cmp al, 0       
    je parse_integer_done
    cmp al, ' '   
    je parse_integer_done
    cmp al, 0xA
    je parse_integer_done
    sub al, '0'   
    imul ebx, 10  
    add ebx, eax  
    jmp parse_integer_loop
parse_integer_done:
    mov eax, ebx  
    ret



resize_photo:
    ; resizing
    ; 1- get matrix into n matrixes
    ; 	1.1 open file Done
    ; 	1.2 Read first line and set heigh and width and depth Done 
    ; 	1.3 Read each element from matrix done
    ; 	1.4 save matrix in memory Done
    
    ; 2- get size from user    Done 
    
    
    ; 3- make new matrix 
    ; 4- save new matrix in new file 	
    ; 	4.1 make and open a new  file 
    ; 	4.2 read from matrix and write in file 
    ; 		4.2.1 in first line write "new_height new_width new_depth"
    ; 		4.2.2 in rest line write each row in a line  
    
        ; Code to load and execute the program for resizing the photo
        ; This would involve loading the respective assembly code or calling it directly
        mov eax, 5  
        mov ebx, input_filename 
        mov ecx, 0  
        int 0x80    
        jc error    
        
        mov esi, eax
    
        ; Read the first line (dimensions)
        mov eax, 3  
        mov ebx, esi  
        mov ecx, buffer  
        mov edx, 150  
        int 0x80    
        jc error    
    
    
    
        push rsi
        push rcx
        ; Parse the dimensions from the first line
        mov esi, buffer
        xor ecx, ecx 
        call parse_first_line
        pop rcx
        pop rsi 
    
        push rax 
        push rdx
        push rbx 
        xor rax,rax
        xor rbx, rbx
        xor rdx,rdx
    
        mov eax , [height]
        mov ebx, [depth]
        imul rbx 
        mov [rows],rax
        mov ebx, [width]
        imul rbx
        mov [mat_len] , rax
        pop rax
        pop rdx 
        pop rbx
        
        mov eax, 5 
        mov ebx, input_filename 
        mov ecx, 0  
        int 0x80    
        jc error    
        mov esi, eax
    
        or rcx, rcx  ; ECX will be our line counter
        xor rbx, rbx 
    Find_size:
        ; Read a character from the file
        push rcx
        push rbx
    
        mov eax, 3  
        mov ebx, esi 
        mov ecx, buffer  
        mov edx, 1  
        int 0x80
    
        pop rbx
        pop rcx 
        
    
        ; Increment file size counter
        inc rbx
    
        ; Check if the character is a newline
        cmp byte [buffer], 0x0A  ; '\n'
        jne Find_size
    
        ; Increment line counter
        inc rcx
    
        ; Check if we've read N lines
        cmp ecx, dword [rows]
        jl Find_size
        
        mov [file_size], ebx
        
        mov eax, 5  
        mov ebx, input_filename 
        mov ecx, 0  
        int 0x80    
        jc error 
    
    
    ;   fill_matrix:
    
        mov esi, eax
        ; Read the first line (dimensions)
        mov eax, 3  
        mov ebx, esi  
        mov ecx, buffer  
        mov edx, [file_size]
        int 0x80    
        jc error   
        
        mov esi, buffer
        xor rcx, rcx 
        call parse_integer
        call parse_integer
        call parse_integer
        xor rax, rax
        xor rdx , rdx 
        mov edi, matrix
    
    put_element:
    
        xor rax, rax
        call parse_integer
    
        mov [rdi + 4*rdx ], eax
        inc rdx
        
        cmp edx, [mat_len]
        jl put_element
    
        ; Prompt user for new dimensions (new_height, new_width)
        mov eax, 4               ; syscall number for write
        mov ebx, 1               ; file descriptor (stdout)
        mov ecx, prompt_new_height   ; pointer to message
        mov edx, 18              ; length of message
        int 0x80                 ; syscall
    
        call readNum
        mov [new_height], rax
    
        ; Prompt user for new dimensions (new_height, new_width)
        mov eax, 4               ; syscall number for write
        mov ebx, 1               ; file descriptor (stdout)
        mov ecx, prompt_new_width   ; pointer to message
        mov edx, 17             ; length of message
        int 0x80                 ; syscall
    
        call readNum
        mov [new_width], rax 
    
        mov eax, [new_height]
        mov ebx, [new_width]
        imul  ebx
        mov ebx, [depth]
        imul ebx 
        mov [resized_mat_len], eax
        
    
    
    
        mov esi, matrix
        mov edi, resized_matrix
        xor ecx, ecx ;element counter for resized_matrix
    
    resizing:
        ; iterate over resized_matrix element and fill it 
        ;check if we are in the end of resized matrix
        push rbx
        mov ebx, [resized_mat_len]
        cmp ebx, ecx
        je end_resizing
        pop rbx  
    
        push rcx 
        xor rdx,rdx
        mov eax, ecx
    
        xor rdx,rdx
        mov ebx, [new_width]
        idiv ebx ; y=eax, x = edx
        

    
        push rax
        push rdx
    
        mov eax, edx 
        mov ebx, [width]
        imul eax, ebx
        cdq
        mov ebx, [new_width]
        idiv ebx
        mov r8, rax   ;r8 = x * x_facto
        pop rdx 
        pop rax
    
        mov ebx, [height]
        imul ebx     
        cdq
        mov ebx, [new_height]
        idiv ebx
        mov ebx, [width]
        imul ebx   

        add r8, rax  ;index mat is in eax
        ; push rax
        ; mov rax, r8
        ; call space
        ; call writeNum
        ; pop rax

        mov ebx, [rsi+r8*4]
        pop rcx 
        mov [rdi+4*rcx],ebx
        inc rcx
        push rax
        mov eax, ecx 
        pop rax
        ; jmp exit_program
        jmp resizing
    
         
    end_resizing:
    mov eax, [new_height]
    mov [height], eax
    mov eax, [new_width]
    mov [width], eax
    mov rsi, resized_matrix
    mov ebx, resized_filename
    call print_file
    jmp end_menu
        ; Open the file for writing
    




        
    
    

convert_to_grayscale:
    
    ;Oen file for Reading 
    mov eax, 5  
    mov ebx, input_filename 
    mov ecx, 0  
    int 0x80    
    jc error    
    
    mov esi, eax

    ; Read the first line (dimensions)
    mov eax, 3  
    mov ebx, esi  
    mov ecx, buffer  
    mov edx, 150  
    int 0x80    
    jc error    

    

    push rsi
    push rcx
    ; Parse the dimensions from the first line
    mov esi, buffer
    xor ecx, ecx 
    call parse_first_line
    pop rcx
    pop rsi 

    push rax 
    push rdx
    push rbx 
    xor rax,rax
    xor rbx, rbx
    xor rdx,rdx

    mov eax , [height]
    mov ebx, [depth]
    imul rbx 
    mov [rows],rax
    xor rax, rax
    xor rbx,rbx
    ;calculate each layer matric size
    mov eax , [height]
    mov ebx, [width]
    imul rbx
    mov [mat_len] , rax
    pop rax
    pop rdx 
    pop rbx
    
    
    mov eax, 5 
    mov ebx, input_filename 
    mov ecx, 0  
    int 0x80    
    jc error    
    mov esi, eax
    
    xor rcx, rcx  ; ECX will be our line counter
    xor rbx, rbx 
File_size:
    ; Read a character from the file
    push rcx
    push rbx

    mov eax, 3  
    mov ebx, esi 
    mov ecx, buffer  
    mov edx, 1  
    int 0x80

    pop rbx
    pop rcx 
    

    ; Increment file size counter
    inc rbx

    ; Check if the character is a newline
    cmp byte [buffer], 0x0A  ; '\n'
    jne File_size

    ; Increment line counter
    inc rcx

    ; Check if we've read N lines
    cmp ecx, dword [rows]
    jl File_size
    
    mov [file_size], ebx
    
    

    mov eax, 5  
    mov ebx, input_filename 
    mov ecx, 0  
    int 0x80    
    jc error 


;   fill_matrix:
    mov esi, eax
    ; Read the first line (dimensions)
    mov eax, 3  
    mov ebx, esi  
    mov ecx, buffer  
    mov edx, [file_size]
    int 0x80    
    jc error   
    
    mov esi, buffer
    xor rcx, rcx 
    call parse_integer
    call parse_integer
    call parse_integer
    xor rax, rax
    xor rdx , rdx 
    mov edi, matrixr

put_element_r:

    xor rax, rax
    call parse_integer

    mov [rdi + 4*rdx ], eax
    inc rdx
    
    cmp edx, [mat_len]
    jl put_element_r

    mov edi, matrixg
    xor rdx, rdx

    
put_element_g:

    xor rax, rax
    call parse_integer

    mov [rdi + 4*rdx ], eax
    inc rdx
    
    cmp edx, [mat_len]
    jl put_element_g

    mov edi, matrixb
    xor rdx, rdx

    
put_element_b:

    xor rax, rax
    call parse_integer

    mov [rdi + 4*rdx ], eax
    inc rdx
    
    cmp edx, [mat_len]
    jl put_element_b

    xor rdx, rdx 
    xor r8,r8
    xor rcx,rcx
grayScale:
    mov eax, [matrixr + 4*r8]
    ; call writeNum
    ; call newLine
    mov ebx, [fixed_299]
    mul ebx
    ; call writeNum
    ; call newLine
    mov ecx, eax
    mov eax, [matrixg + 4*r8]
    ; call writeNum
    ; call newLine
    mov ebx, [fixed_587]
    mul ebx
    ; call writeNum
    ; call newLine
    add ecx, eax
    mov eax, [matrixb + 4*r8]
    ; call writeNum
    ; call newLine
    mov ebx, [fixed_114]
    mul ebx
    ; call writeNum
    ; call newLine
    add ecx, eax
    shr ecx, 16
    mov [matrix_gray + 4*r8], ecx 
    ; push rax
    ; mov rax, r8
    ; call writeNum
    ; call space
    ; pop rax
    ; call exit_program
    inc r8
    cmp dword r8, [mat_len]
    jl grayScale
    
    ; save to file 
    mov dword[depth], 1
    mov rsi, matrix_gray
    mov ebx, gray_filename
    call print_file
    jmp end_menu


    
apply_convolution_filters:
    ; Code to load and execute the program for applying convolution filters
    ; This would involve loading the respective assembly code or calling it directly
    mov eax, 5  
    mov ebx, input_filename 
    mov ecx, 0  
    int 0x80    
    jc error    
    
    mov esi, eax

    ; Read the first line (dimensions)
    mov eax, 3  
    mov ebx, esi  
    mov ecx, buffer  
    mov edx, 150  
    int 0x80    
    jc error    

    

    push rsi
    push rcx
    ; Parse the dimensions from the first line
    mov esi, buffer
    xor ecx, ecx 
    call parse_first_line
    pop rcx
    pop rsi 

    push rax 
    push rdx
    push rbx 
    xor rax,rax
    xor rbx, rbx
    xor rdx,rdx

    mov eax , [height]
    mov ebx, [depth]
    imul rbx 
    mov [rows],rax
    xor rax, rax
    xor rbx,rbx
    ;calculate each layer matric size
    mov eax , [height]
    mov ebx, [width]
    imul rbx
    mov [mat_len] , rax
    pop rax
    pop rdx 
    pop rbx
    
    
    mov eax, 5 
    mov ebx, input_filename 
    mov ecx, 0  
    int 0x80    
    jc error    
    mov esi, eax
    
    xor rcx, rcx  ; ECX will be our line counter
    xor rbx, rbx 
Fil_size:
    ; Read a character from the file
    push rcx
    push rbx

    mov eax, 3  
    mov ebx, esi 
    mov ecx, buffer  
    mov edx, 1  
    int 0x80

    pop rbx
    pop rcx 
    

    ; Increment file size counter
    inc rbx

    ; Check if the character is a newline
    cmp byte [buffer], 0x0A  ; '\n'
    jne Fil_size

    ; Increment line counter
    inc rcx

    ; Check if we've read N lines
    cmp ecx, dword [rows]
    jl Fil_size
    
    mov [file_size], ebx
    
    

    mov eax, 5  
    mov ebx, input_filename 
    mov ecx, 0  
    int 0x80    
    jc error 


;   fill_matrix:
    mov esi, eax
    ; Read the first line (dimensions)
    mov eax, 3  
    mov ebx, esi  
    mov ecx, buffer  
    mov edx, [file_size]
    int 0x80    
    jc error   
    
    mov esi, buffer
    xor rcx, rcx 
    call parse_integer
    call parse_integer
    call parse_integer
    xor rax, rax
    xor rdx , rdx 
    mov edi, matrix

Fillmat:

    xor rax, rax
    call parse_integer

    mov [rdi + 4*rdx ], eax
    inc rdx
    
    cmp edx, [mat_len]
    jl Fillmat

        ; Initialize padded matrix with zeros
    mov rdi, paded_matrix
    push rax
    push rbx 
    push rdx
    xor rax, rax
    mov eax, [height]
    add eax, 2
    mov ebx, [width]
    add ebx, 2
    imul ebx
    mov  rcx, rax
    pop rdx
    pop rbx
    pop rax
    xor rax, rax
    rep stosd

    ; Copy original image into the center of the padded matrix
    mov rsi, matrix
    mov rdi, paded_matrix
    push rax
    xor rax, rax
    mov eax, [width]
    add eax, 2
    mov ebx, 4
    imul ebx  
    add rdi, rax
    add rdi, 4
    mov ecx, [height]   
.copy_rows:
    push rcx
    mov ecx, [width]         
.copy_cols:
    lodsd
    stosd
    loop .copy_cols
    add rdi, 8    
    pop rcx
    loop .copy_rows


CNN_menu:
    mov eax, 4  
    mov ebx, 1  
    mov ecx, CNN_prompt
    mov edx, CNN_prompt_size
    int 0x80    

    ; Read user's choice
    mov eax, 3  
    mov ebx, 0  
    mov ecx, choice
    mov edx, 2  
    int 0x80    

    ; Process user's choice
    cmp byte [choice], '1'
    je Sharpening
    cmp byte [choice], '2'
    je Emboss
    jmp invalid_choice
Sharpening:
    mov rsi, paded_matrix        ; Source image matrix
    mov rdi, matrix_convo      ; Destination output matrix



    ; Apply sharpening kernel
    ; Iterate over each pixel in the image matrix
    ;set start point for r
    xor rax, rax 
    xor rbx, rbx 
    xor rcx, rcx
    xor rdx, rdx
    xor r8 ,r8  ;store index for matrix
    xor r10, r10   ;store index for paded_matrix
    xor r9, r9    ; store (width + 2) * 4  
    xor r11,r11   ;check row is the end
    mov eax, [width]
    add rax, 2
    MOV ebx, 4
    imul ebx
    mov r9, rax   

    calculate_value:
    ;Calculate value for sharped matrix
        push rcx
        push r10 
        xor rcx , rcx   
        xor rax, rax 
        xor rbx, rbx 

        ; row one 
        mov ebx, [rsi + r10]
        movsx rax,dword [sharpen_kernel]
        
        imul rbx
        mov rcx ,rax
    

        mov ebx, [rsi + r10 + 4]
        movsx rax,dword [sharpen_kernel+8]
        imul rbx     
        add rcx, rax
        
        mov ebx, [rsi + r10 + 8]
        movsx rax,dword [sharpen_kernel+16]
        imul rbx     
        add rcx, rax

        ; row two
        add r10, r9   
        mov ebx, [rsi + r10]
        movsx rax,dword [sharpen_kernel+24]
        imul rbx     
        add rcx, rax

        mov ebx, [rsi + r10 + 4]
        movsx rax,dword [sharpen_kernel+32]
        imul rbx     
        add rcx, rax
        
        

        mov ebx, [rsi + r10 + 8]
        movsx rax,dword [sharpen_kernel+40]
        
        imul rbx    
        add rcx, rax
        

        ; row three
        add r10, r9  
        mov ebx, [rsi + r10 + 0]
        movsx rax,dword [sharpen_kernel+48]
        imul rbx     
        add rcx, rax

        mov ebx, [rsi + r10 + 4]
        movsx rax,dword [sharpen_kernel+56]
        imul rbx     
        add rcx, rax
        
        mov ebx, [rsi + r10 + 8]
        movsx rax,dword [sharpen_kernel+64]
        imul rbx     
        add rcx, rax
        
        mov rax, rcx

        

        pop r10
        add r10, 4
        
        
        pop rcx 
        cmp rax, 255
        jle check_neg
        mov rax, 255
        check_neg:
        cmp rax, 0
        jge ok
        mov rax, 0
        ok:
        mov [rdi+ 8*rcx] , rax
        inc rcx
        inc r11
        push rax
        ; mov rax,r11
        ; call writeNum
        ; call space
        pop rax
        mov rax, r11
        mov ebx, [width]
        cmp eax, ebx
        je nextrow
        jmp calculate_value

    nextrow: 
        ; mov rax,r10
        ; call writeNum
        ; call newLine
        ; call exit_program
        add r10,8
        xor r11,r11
        cmp rcx, [mat_len]
        jne calculate_value
    
    
    
    jmp end_menu

Emboss:
    mov rax, 1
    call writeNum
    mov rsi, paded_matrix        ; Source image matrix
    mov rdi, matrix_convo       ; Destination output matrix



    ; Apply sharpening kernel
    ; Iterate over each pixel in the image matrix
    ;set start point for r
    xor rax, rax 
    xor rbx, rbx 
    xor rcx, rcx
    xor rdx, rdx
    xor r8 ,r8  ;store index for matrix
    xor r10, r10   ;store index for paded_matrix
    xor r9, r9    ; store (width + 2) * 4  
    xor r11,r11   ;check row is the end
    mov eax, [width]
    add rax, 2
    MOV ebx, 4
    imul ebx
    mov r9, rax   

    .calculate_value:
    ;Calculate value for sharped matrix
        push rcx
        push r10 
        xor rcx , rcx   
        xor rax, rax 
        xor rbx, rbx 

        ; row one 
        mov ebx, [rsi + r10]
        movsx rax,dword [emboss_kernel]
        
        imul rbx
        mov rcx ,rax
    

        mov ebx, [rsi + r10 + 4]
        movsx rax,dword [emboss_kernel+8]
        imul rbx     
        add rcx, rax
        
        mov ebx, [rsi + r10 + 8]
        movsx rax,dword [emboss_kernel+16]
        imul rbx     
        add rcx, rax

        ; row two
        add r10, r9   
        mov ebx, [rsi + r10]
        movsx rax,dword [emboss_kernel+24]
        imul rbx     
        add rcx, rax

        mov ebx, [rsi + r10 + 4]
        movsx rax,dword [emboss_kernel+32]
        imul rbx     
        add rcx, rax
        
        

        mov ebx, [rsi + r10 + 8]
        movsx rax,dword [emboss_kernel+40]
        
        imul rbx    
        add rcx, rax
        

        ; row three
        add r10, r9  
        mov ebx, [rsi + r10 + 0]
        movsx rax,dword [emboss_kernel+48]
        imul rbx     
        add rcx, rax

        mov ebx, [rsi + r10 + 4]
        movsx rax,dword [emboss_kernel+56]
        imul rbx     
        add rcx, rax
        
        mov ebx, [rsi + r10 + 8]
        movsx rax,dword [emboss_kernel+64]
        imul rbx     
        add rcx, rax
        
        mov rax, rcx

        

        pop r10
        add r10, 4
        
        
        pop rcx 
        cmp rax, 255
        jle .check_neg
        mov rax, 255
        .check_neg:
        cmp rax, 0
        jge .ok
        mov rax, 0
        .ok:
        mov [rdi+ 8*rcx] , rax
        inc rcx
        inc r11
        push rax
        ; mov rax,r11
        ; call writeNum
        ; call space
        pop rax
        mov rax, r11
        mov ebx, [width]
        cmp eax, ebx
        je .nextrow
        jmp .calculate_value

    .nextrow: 
        ; mov rax,r10
        ; call writeNum
        ; call newLine
        ; call exit_program
        add r10,8
        xor r11,r11
        cmp rcx, [mat_len]
        jne .calculate_value



    mov dword[depth], 1
    mov rsi, matrix_convo
    mov ebx, CNN_filename
    call print_file2
    jmp end_menu



print_file2:
    mov eax, 5                       
    mov ecx, 577                     
    mov edx, 0644                    
    int 0x80                         
    mov [fd], eax                    

    ; Convert matrix dimensions to ASCII and write to the file
    mov eax, [height]
    call writeNum
    call newLine
    call int_to_ascii2
    mov eax, 4                       
    mov ebx, [fd]                    
    int 0x80                         
    ; Write a space
    mov eax, 4                       
    mov ebx, [fd]                    
    mov ecx, spc                   
    mov edx, 1                     
    int 0x80                       
    ; Convert matrix width to ASCII and write to the file
    mov eax, [width]
    call writeNum
    call newLine
    call int_to_ascii2
    mov eax, 4                     
    mov ebx, [fd]                  
    int 0x80                       

; Write a space
    mov eax, 4                       
    mov ebx, [fd]                    
    mov ecx, spc                   
    mov edx, 1                     
    int 0x80                       

    mov eax, [depth]
    call writeNum
    call newLine
    call int_to_ascii2
    mov eax, 4                     
    mov ebx, [fd]                  
    int 0x80   
    ; Write a newline character
    mov eax, 4                     
    mov ebx, [fd]                  
    mov ecx, newlin                
    mov edx, 1                     
    int 0x80                       
    ; Iterate through the matrix
    xor r9, r9       
    xor r8 ,r8       
    xor r10,r10      
    xor rcx, rcx 
    xor rdx, rdx
iterate_rows2:
    mov edx, [height]
    cmp rdx, r8
    je done2                      
    xor r9,r9                    
iterate_columns2:
    mov edx, [width]
    cmp rdx, r9 
    je next_row32                  

    mov rax, [rsi + 8 * r10]
    ; Convert the element to ASCII and write to buffer
    call int_to_ascii2
    ; Write the ASCII representation to the file
    mov eax, 4                       
    mov ebx, [fd]                    
    int 0x80                         
    ; Write a space
    mov eax, 4                       
    mov ebx, [fd]                    
    mov ecx, spc                   
    mov edx, 1                     
    int 0x80                       
    ; Increment column index
    inc r9
    inc r10
    jmp iterate_columns2
next_row32:
    ; Write a newline character
    mov eax, 4                     
    mov ebx, [fd]                  
    mov ecx, newlin                
    mov edx, 1                      
    int 0x80                        
    ; Increment row index
    inc r8
    jmp iterate_rows2
done2:
    ; Close the file
    mov eax, 6                      
    mov ebx, [fd]                   
    int 0x80                        

    ret



; Subroutine to convert integer to ASCII and calculate length
int_to_ascii2:
    push rax
    mov rdi, buffer_write           
    
    add rdi, 30                     
    
    mov byte [rdi], 0               
    xor rdx, rdx                    
    mov ebx, 10
convert_loop2:
    dec rdi
    xor rdx, rdx

    div ebx                          
    
    add dl, '0'                     
    mov [rdi], dl                   
    inc edx                         
    test rax, rax
    jnz convert_loop2
    mov rdx, buffer_write
    add rdx, 30
    sub rdx, rdi

    mov ecx, edi                    
    pop rax
    ret
    

perform_pooling:
    mov eax, 5  
    mov ebx, input_filename 
    mov ecx, 0  
    int 0x80    
    jc error    
    
    mov esi, eax

    ; Read the first line (dimensions)
    mov eax, 3  
    mov ebx, esi  
    mov ecx, buffer  
    mov edx, 150  
    int 0x80    
    jc error    

    

    push rsi
    push rcx
    ; Parse the dimensions from the first line
    mov esi, buffer
    xor ecx, ecx 
    call parse_first_line
    pop rcx
    pop rsi 

    push rax 
    push rdx
    push rbx 
    xor rax,rax
    xor rbx, rbx
    xor rdx,rdx

    mov eax , [height]
    mov ebx, [depth]
    imul rbx 
    mov [rows],rax
    xor rax, rax
    xor rbx,rbx
    ;calculate each layer matric size
    mov eax , [height]
    mov ebx, [width]
    imul rbx
    mov [mat_len] , rax
    pop rax
    pop rdx 
    pop rbx
    
    
    mov eax, 5 
    mov ebx, input_filename 
    mov ecx, 0  
    int 0x80    
    jc error    
    mov esi, eax
    
    xor rcx, rcx  ; ECX will be our line counter
    xor rbx, rbx 
Mat_Size:
    ; Read a character from the file
    push rcx
    push rbx

    mov eax, 3  
    mov ebx, esi 
    mov ecx, buffer  
    mov edx, 1  
    int 0x80

    pop rbx
    pop rcx 
    

    ; Increment file size counter
    inc rbx

    ; Check if the character is a newline
    cmp byte [buffer], 0x0A  ; '\n'
    jne Mat_Size

    ; Increment line counter
    inc rcx

    ; Check if we've read N lines
    cmp ecx, dword [rows]
    jl Mat_Size
    
    mov [file_size], ebx
    
    

    mov eax, 5  
    mov ebx, input_filename 
    mov ecx, 0  
    int 0x80    
    jc error 


;   fill_matrix:
    mov esi, eax
    ; Read the first line (dimensions)
    mov eax, 3  
    mov ebx, esi  
    mov ecx, buffer  
    mov edx, [file_size]
    int 0x80    
    jc error   
    
    mov esi, buffer
    xor rcx, rcx 
    call parse_integer
    call parse_integer
    call parse_integer
    xor rax, rax
    xor rdx , rdx 
    mov edi, matrix

Fill_mat:

    xor rax, rax
    call parse_integer

    mov [rdi + 4*rdx ], eax
    inc rdx
    
    cmp edx, [mat_len]
    jl Fill_mat
    

Pool_menu:
    mov eax, 4  
    mov ebx, 1  
    mov ecx, Pool_prompt
    mov edx, Pool_prompt_size
    int 0x80    

    ; Read user's choice
    mov eax, 3  
    mov ebx, 0  
    mov ecx, choice
    mov edx, 2  
    int 0x80    

    ; Process user's choice
    cmp byte [choice], '1'
    je Avg_Pool
    cmp byte [choice], '2'
    je Max_Pool
    jmp invalid_choice

Avg_Pool:
        mov eax, 4  
        mov ebx, 1  
        mov ecx, prompt_New_size
        mov edx, size_prompt_new_size
        int 0x80 

        call readNum

        mov r8, rax      ;store the desired size 
        xor r9,r9        ; store the index of matrix_i
        xor r11, r11     ; store the index matrix_j
        xor r10,r10      ; store the index of pooled matrix
        xor r15, r15     ; store width pooled matrix
        xor r14, r14     ; store height pooled matrix
        xor rcx, rcx     ; sotre iterator in small matrix_i
        xor r12, r12     ; store itarator in small matrix_j
        xor r13, r13     ; store num of elements that readed
        xor rax, rax 
        xor rbx, rbx
        xor rdx, rdx
    pooling1:
        push r11
        push r9
        xor rcx, rcx

        inner_loop:
        xor rax, rax

        mov edx, [width]
        cmp r9, rdx
        jge next_row

        mov edx, [mat_len]
        cmp r11, rdx
        jge calculate_avg

        push r9
        push r11
        push rbx
        push rcx 
        push rdx
        add r9, r11
        mov rax, r9
        mov rbx, 4
        imul rbx
        mov r9, rax
        xor rax, rax
        mov eax, [matrix + r9]
        pop rdx
        pop rcx
        pop rbx
        pop r11
        pop r9

        inc rcx 

        inc r9

        add ebx, eax
        inc r13

        cmp  rcx, r8        ;x element of row checked
        je next_row
        jmp inner_loop

        next_row:
        inc r12


        cmp r12, r8
        je calculate_avg
        mov edx, [width]
        add r11, rdx
        xor rcx, rcx

        pop r9
        push r9
        jmp inner_loop

        calculate_avg:
        mov eax, ebx
        mov rbx, r13
        xor rdx, rdx
        idiv ebx
        xor rdx, rdx
        jmp put_pooled_elements

    put_pooled_elements:
        mov [pooled_matrix + r10 * 4], eax
        xor rax,rax
        xor rbx, rbx

    next_block:
        xor r13, r13
        xor r12,r12
        inc r10
        pop r9
        pop r11
        add r9, r8
        inc r14
        mov edx, [width]
        cmp r9, rdx
        jl this_row
        inc r15
        push rax
        push rbx
        push rdx
        mov eax,[width]
        imul r8
        add r11, rax
        pop rdx
        pop rbx
        pop rax 
        xor r9, r9
        mov rax, r9
        add rax, r11
        mov [pool_height], r15
        mov [pool_width], r14
        mov edx, [mat_len]
        cmp rdx, rax
        jle end_pooling
        xor r14, r14
        this_row:
            push r9
            push r11

        jmp pooling1

Max_Pool:
        mov eax, 4  
        mov ebx, 1 
        mov ecx, prompt_New_size
        mov edx, size_prompt_new_size
        int 0x80 

        call readNum

        mov r8, rax      ;store the desired size 
        xor r9,r9        ; store the index of matrix_i
        xor r11, r11     ; store the index matrix_j
        xor r10,r10      ; store the index of pooled matrix
        xor r15, r15     ; store width pooled matrix
        xor r14, r14     ; store height pooled matrix
        xor rcx, rcx     ; sotre iterator in small matrix_i
        xor r12, r12     ; store itarator in small matrix_j
        xor r13, r13     ; store num of elements that readed
        xor rax, rax 
        xor rbx, rbx
        xor rdx, rdx
    pooling2:
        push r11
        push r9
        xor rcx, rcx

        inner_loop2:
        xor rax, rax

        mov edx, [width]
        cmp r9, rdx
        jge next_row2

        mov edx, [mat_len]
        cmp r11, rdx
        jge calculate_Max

        push r9
        push r11
        push rbx
        push rcx 
        push rdx
        add r9, r11
        mov rax, r9
        mov rbx, 4
        imul rbx
        mov r9, rax
        xor rax, rax
        mov eax, [matrix + r9]
        pop rdx
        pop rcx
        pop rbx
        pop r11
        pop r9

        inc rcx 

        inc r9
        cmp eax, ebx
        jle NO_change
        mov ebx, eax
        NO_change:

            cmp  rcx, r8        ;x element of row checked
            je next_row2
            jmp inner_loop2

        next_row2:
            inc r12
            cmp r12, r8
            je calculate_Max
            mov edx, [width]
            add r11, rdx
            xor rcx, rcx

            pop r9
            push r9
            jmp inner_loop2

        calculate_Max:
            mov eax, ebx
            jmp put_pooled_element

        put_pooled_element:
            mov [pooled_matrix + r10 * 4], eax
            xor rax,rax
            xor rbx, rbx

        next_block2:
            xor r12,r12
            inc r10
            pop r9
            pop r11
            add r9, r8
            inc r14
            mov edx, [width]
            cmp r9, rdx
            jl this_row2
            inc r15
            push rax
            push rbx
            push rdx
            mov eax,[width]
            imul r8
            add r11, rax
            pop rdx
            pop rbx
            pop rax 
            xor r9, r9
            mov rax, r9
            add rax, r11
            mov [pool_height], r15
            mov [pool_width], r14
            mov edx, [mat_len]
            cmp rdx, rax
            jle end_pooling
            xor r14, r14
            this_row2:
                push r9
                push r11

            jmp pooling2

        end_pooling:
            mov rax,[pool_height]
            mov [height], eax
            mov rax,[pool_width]
            mov [width], eax
            mov dword[depth], 1
            mov rsi, pooled_matrix
            mov ebx, pool_filename
            call print_file
            jmp end_menu
        
add_noise:
    mov eax, 5  
    mov ebx, input_filename 
    mov ecx, 0  
    int 0x80    
    jc error    
    
    mov esi, eax

    ; Read the first line (dimensions)
    mov eax, 3  
    mov ebx, esi  
    mov ecx, buffer  
    mov edx, 150  
    int 0x80    
    jc error    

    

    push rsi
    push rcx
    ; Parse the dimensions from the first line
    mov esi, buffer
    xor ecx, ecx 
    call parse_first_line
    pop rcx
    pop rsi 

    push rax 
    push rdx
    push rbx 
    xor rax,rax
    xor rbx, rbx
    xor rdx,rdx

    mov eax , [height]
    mov ebx, [depth]
    imul rbx 
    mov [rows],rax
    xor rax, rax
    xor rbx,rbx
    ;calculate each layer matric size
    mov eax , [height]
    mov ebx, [width]
    imul rbx
    mov [mat_len] , rax
    pop rax
    pop rdx 
    pop rbx
    
    
    mov eax, 5 
    mov ebx, input_filename 
    mov ecx, 0  
    int 0x80    
    jc error    
    mov esi, eax
    
    xor rcx, rcx  ; ECX will be our line counter
    xor rbx, rbx 
    Mat_Size2:
        ; Read a character from the file
        push rcx
        push rbx

        mov eax, 3  
        mov ebx, esi 
        mov ecx, buffer  
        mov edx, 1  
        int 0x80

        pop rbx
        pop rcx 


        ; Increment file size counter
        inc rbx

        ; Check if the character is a newline
        cmp byte [buffer], 0x0A  ; '\n'
        jne Mat_Size2

        ; Increment line counter
        inc rcx

        ; Check if we've read N lines
        cmp ecx, dword [rows]
        jl Mat_Size2

        mov [file_size], ebx



        mov eax, 5  
        mov ebx, input_filename 
        mov ecx, 0  
        int 0x80    
        jc error 


    ;   fill_matrix:
        mov esi, eax
        ; Read the first line (dimensions)
        mov eax, 3  
        mov ebx, esi  
        mov ecx, buffer  
        mov edx, [file_size]
        int 0x80    
        jc error   

        mov esi, buffer
        xor rcx, rcx 
        call parse_integer
        call parse_integer
        call parse_integer
        xor rax, rax
        xor rdx , rdx 
        mov edi, matrix

    Fill_mat2:

        xor rax, rax
        call parse_integer

        mov [rdi + 4*rdx ], eax
        inc rdx

        cmp edx, [mat_len]
        jl Fill_mat2

    xor r8,r8   ;index for iterate matrix
    SaltAndPepper:


        ; Load the arguments for getrandom syscall
        mov eax, 318              ; syscall number for getrandom
        mov edi, buffer          
        mov esi, 1                
        xor edx, edx            

        ; Perform the syscall
        syscall
        xor rax, rax
        movzx eax, byte[buffer]
        call writeNum
        call space

        cmp eax, 90
        jg end_Noise
        cmp eax, 45
        jl High_value
        mov dword [matrix + r8 * 4], 0
        jmp end_Noise
    High_value:
        mov dword[matrix + r8 * 4], 255
    end_Noise:
        inc r8
        xor rdx, rdx
        mov edx, [mat_len]
        cmp r8, rdx
        je end_process
        jmp SaltAndPepper


    end_process:
        mov rsi, matrix
        mov ebx, noisy_filename
        call print_file
        jmp end_menu
;     



    jmp end_menu

output_processed_matrix:
    ; Code to load and execute the program for outputting the processed matrix
    ; This would involve loading the respective assembly code or calling it directly

    ; Display prompt to enter photo address
    mov eax, 4  
    mov ebx, 1  
    mov ecx, prompt1_msg
    mov edx, prompt1_msg_size
    int 0x80   

    ; Read photo address from user input (max byre = 100
    mov eax, 3  
    mov ebx, 0  
    mov ecx, photo_address
    mov edx, 100  
    int 0x80
    
    ; Remove newline character from input
    mov ecx, photo_address
remove_newline1:
    cmp byte [ecx], 0xA 
    je newline_removed1
    inc ecx
    jmp remove_newline1

newline_removed1:
    mov byte [ecx], 0   

    ; Call Python script to process the photo and generate matrix
    mov ecx, args
    mov dword [ecx], python_interpreter
    mov dword [ecx+4], python_script_out
    mov dword [ecx+8], photo_address
    mov dword [ecx+12], 0 

    ; Prepare envp (NULL)
    xor edx, edx  

    ; Call execve
    mov eax, 11         
    mov ebx, python_interpreter
    int 0x80   


    ; Prepare syscall waitpid
    mov eax, 0x7D 
    xor ebx, ebx 
    xor ecx, ecx 
    int 0x80 

    ; Display completion message
    mov eax, 4 
    mov ebx, 1 
    mov ecx, exit_msg
    mov edx, exit_msg_size
    int 0x80 
    jmp end_menu

exit_program:
    ; Exit the program
    mov eax, 1  
    xor ebx, ebx 
    int 0x80    

invalid_choice:
    ; Invalid choice message
    mov eax, 4  
    mov ebx, 1  
    mov ecx, invalid_choice_msg
    mov edx, invalid_choice_msg_size
    int 0x80    

    ; Jump back to display_menu to show the menu again
    jmp display_menu

end_menu:
    jmp display_menu
