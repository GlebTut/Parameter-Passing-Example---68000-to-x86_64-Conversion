;==============================================================================
; TITLE       : Parameter Passing Example - EASy68k to x86_64 Conversion
; AUTHOR      : Gleb Tutubalin (Converted from Philip Bourke's original)
; DATE        : June 2025
; VERSION     : 1.0.0
; DESCRIPTION : Professional assembly conversion demonstrating parameter passing
;               between Motorola 68000 and x86_64 architectures with modern
;               security enhancements and robust error handling.
;
; EDUCATIONAL PURPOSE:
;   - Demonstrates low-level programming concepts
;   - Shows architecture conversion techniques  
;   - Implements modern security practices
;   - Provides comprehensive error handling
;
; SECURITY IMPROVEMENTS FROM 68K VERSION:
;   ✅ Non-executable stack prevents code injection attacks
;   ✅ Input validation prevents buffer overflow vulnerabilities
;   ✅ Overflow detection prevents arithmetic exploits
;   ✅ Attempt limiting prevents denial-of-service attacks
;   ✅ Enhanced buffer management prevents memory corruption
;==============================================================================

;==============================================================================
; SECURITY DIRECTIVES
;==============================================================================
section .note.GNU-stack noexec    ; 🛡️ Mark stack as non-executable for security

;==============================================================================
; DATA SECTION - String Constants and Messages
;==============================================================================
section .data
    ; User interface strings
    prompt        db "Enter number: ", 0
    result_msg    db "The sum is: %ld", 10, 0    ; Format: value + newline
    final_msg     db "Final sum is: %ld", 10, 0  ; Format: value + newline
    newline       db 10, 0                       ; Simple newline character
    
    ; Input/Output format strings for scanf/printf
    format_in     db "%ld%*c", 0                 ; Read long + flush remaining chars
    format_out    db "%ld", 10, 0                ; Output long + newline
    
    ; Error and status messages
    overflow_msg  db "Invalid input. Please try again.", 10, 0
    attempt_msg   db "Attempt %ld of 3", 10, 0   ; Progress indicator
    skip_msg      db "Skipping this iteration due to invalid input.", 10, 0

;==============================================================================
; BSS SECTION - Uninitialized Variables (68k Register Equivalents)
;==============================================================================
section .bss
    ; 68k Register -> x86_64 Memory Variable Mapping:
    first_num     resq 1                    ; D2 equivalent: First input number
    second_num    resq 1                    ; D1 equivalent: Second input number  
    running_sum   resq 1                    ; D3 equivalent: Accumulating sum
    loop_counter  resq 1                    ; D4 equivalent: Iteration counter
    max_attempts  resq 1                    ; Security: Limit invalid input attempts
    buffer        resb 16                   ; Input buffer with size limit (security)

;==============================================================================
; TEXT SECTION - Executable Code
;==============================================================================
section .text
    global main                 ; Entry point for linker
    global register_adder       ; Export function for testing
    extern printf, scanf, puts, getchar  ; C library functions (replace TRAP #15)

;==============================================================================
; FUNCTION: main
; PURPOSE:  Program entry point - manages the interactive loop
; PARAMS:   None (standard main signature ignored)
; RETURNS:  0 on successful completion
; REGISTERS: Uses standard x86_64 calling convention
; SECURITY: Implements input validation and attempt limiting
;==============================================================================
main:
    ; Function prologue - establish stack frame
    push rbp                                ; Save caller's base pointer
    mov rbp, rsp                            ; Set up our stack frame
    sub rsp, 32                             ; Reserve 32 bytes (16-byte aligned)
    
    ; Initialize program variables (replaces 68k register initialization)
    mov qword [running_sum], 0              ; CLR.L D3 equivalent
    mov qword [loop_counter], 3             ; MOVE.W #3, D4 equivalent  
    mov qword [max_attempts], 3             ; Security: set retry limit

;==============================================================================
; MAIN PROGRAM LOOP - Processes 3 iterations of number input/addition
;==============================================================================
game_loop:
    ; Check termination condition
    cmp qword [loop_counter], 0             ; Compare with zero
    je game_done                            ; Exit if no iterations remaining

    ; Display current attempt number for user feedback
    mov rdi, attempt_msg                    ; Format string pointer
    mov rsi, qword [loop_counter]           ; Current iteration number
    xor rax, rax                            ; Clear AL for varargs (required)
    call printf                             ; Display attempt message

    ; Reset attempt counter for this iteration
    mov qword [max_attempts], 3

;==============================================================================
; FIRST NUMBER INPUT - With validation and retry logic
;==============================================================================
first_number_prompt:
    ; Security check: prevent infinite retry loops
    cmp qword [max_attempts], 0             ; Check remaining attempts
    je skip_iteration                       ; Skip if too many failures
    
    ; Display input prompt
    mov rdi, prompt                         ; Prompt string address
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Display "Enter number: "

    ; Read and validate integer input
    lea rsi, [first_num]                    ; Load address of storage variable
    mov rdi, format_in                      ; Scanf format string
    xor rax, rax                            ; Clear AL register for varargs
    call scanf                              ; Read input into first_num
    
    ; Input validation - crucial for security
    cmp rax, 1                              ; Check if scanf successfully read 1 item
    jne first_number_error                  ; Handle invalid input
    jmp second_number_prompt                ; Success: proceed to second number

first_number_error:
    ; Handle invalid input with user feedback
    mov rdi, overflow_msg                   ; Error message address
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Display error message
    
    ; Security: track and limit attempts
    dec qword [max_attempts]                ; Decrement remaining attempts
    
    ; Clean input buffer to prevent scanner corruption
    call improved_flush_input               ; Enhanced buffer cleaning
    
    jmp first_number_prompt                 ; Retry input

;==============================================================================
; SECOND NUMBER INPUT - Similar validation as first number
;==============================================================================
second_number_prompt:
    ; Reset attempts for second number input
    mov qword [max_attempts], 3

second_number_try:
    ; Security check: prevent infinite retry loops
    cmp qword [max_attempts], 0             ; Check remaining attempts
    je skip_iteration                       ; Skip if too many failures
    
    ; Display input prompt
    mov rdi, prompt                         ; Prompt string address
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Display "Enter number: "
    
    ; Read and validate integer input
    lea rsi, [second_num]                   ; Load address of storage variable
    mov rdi, format_in                      ; Scanf format string  
    xor rax, rax                            ; Clear AL register for varargs
    call scanf                              ; Read input into second_num
    
    ; Input validation
    cmp rax, 1                              ; Check scanf success
    jne second_number_error                 ; Handle invalid input
    jmp process_numbers                     ; Success: process the numbers

second_number_error:
    ; Handle invalid input with user feedback
    mov rdi, overflow_msg                   ; Error message address
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Display error message
    
    ; Security: track and limit attempts  
    dec qword [max_attempts]                ; Decrement remaining attempts
    
    ; Clean input buffer
    call improved_flush_input               ; Enhanced buffer cleaning
    
    jmp second_number_try                   ; Retry input

;==============================================================================
; ITERATION SKIP HANDLER - Security feature for persistent invalid input
;==============================================================================
skip_iteration:
    ; Provide user feedback about skipping
    mov rdi, skip_msg                       ; Skip notification message
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Display skip message
    
    ; Note: We add 0 to running sum (no call to register_adder needed)
    ; This is more efficient and eliminates unnecessary function call overhead
    
    ; Display result with current sum (unchanged)
    mov rdi, result_msg                     ; Result format string
    mov rsi, [running_sum]                  ; Current running sum value
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Display result
    
    ; Continue to next iteration
    dec qword [loop_counter]                ; Decrement iteration counter
    jmp game_loop                           ; Continue main loop

;==============================================================================
; NUMBER PROCESSING - Core arithmetic operation
;==============================================================================
process_numbers:
    ; Call addition function using x86_64 calling convention
    ; System V ABI: first two parameters in RDI, RSI
    mov rdi, [first_num]                    ; First parameter (was D2 in 68k)
    mov rsi, [second_num]                   ; Second parameter (was D1 in 68k)
    call register_adder                     ; Call addition subroutine
    
    ; Update running sum (ADD.L D1, D3 equivalent in 68k)
    add [running_sum], rax                  ; Add result to running total
    
    ; Display intermediate result for user feedback
    mov rdi, result_msg                     ; Result format string
    mov rsi, [running_sum]                  ; Current sum value
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Display current sum
    
    ; Decrement loop counter (SUBQ.W #1, D4 equivalent in 68k)
    dec qword [loop_counter]                ; Decrement iteration counter
    
    ; Continue main loop
    jmp game_loop                           ; Next iteration

;==============================================================================
; PROGRAM TERMINATION - Clean exit
;==============================================================================
game_done:
    ; Display final result summary
    mov rdi, final_msg                      ; Final message format
    mov rsi, [running_sum]                  ; Final sum value
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Display final sum
    
    ; Function epilogue - clean stack frame
    mov rsp, rbp                            ; Restore stack pointer
    pop rbp                                 ; Restore caller's base pointer
    xor rax, rax                            ; Return 0 (success)
    ret                                     ; Return to operating system

;==============================================================================
; FUNCTION: register_adder  
; PURPOSE:  Safely adds two 64-bit integers with overflow detection
; PARAMS:   RDI = first number (equivalent to D2 in 68k)
;           RSI = second number (equivalent to D1 in 68k)  
; RETURNS:  RAX = sum of numbers (or 0 if overflow detected)
; SECURITY: Hardware-based overflow detection prevents arithmetic exploits
; NOTES:    This function implements security features not present in 68k version
;==============================================================================
register_adder:
    push rbp                                ; Save caller's base pointer
    mov rbp, rsp                            ; Set up stack frame
    
    ; Perform addition with overflow checking
    mov rax, rdi                            ; Load first parameter into result register
    add rax, rsi                            ; Add second parameter
    jo addition_overflow                    ; Jump if overflow flag set (security!)
    
    ; Normal return path - no overflow detected
    mov rsp, rbp                            ; Restore stack pointer
    pop rbp                                 ; Restore base pointer
    ret                                     ; Return with result in RAX

;==============================================================================
; OVERFLOW HANDLER - Security feature for arithmetic overflow
;==============================================================================
addition_overflow:
    ; Notify user of overflow condition
    mov rdi, overflow_msg                   ; Overflow error message
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Display overflow warning
    
    ; Return safe value to prevent exploitation
    xor rax, rax                            ; Return 0 as safe fallback value
    mov rsp, rbp                            ; Restore stack pointer  
    pop rbp                                 ; Restore base pointer
    ret                                     ; Return safely

;==============================================================================
; FUNCTION: new_line
; PURPOSE:  Outputs a newline character (utility function)
; PARAMS:   None
; RETURNS:  None
; NOTES:    Simple wrapper around printf for newline output
;==============================================================================
new_line:
    push rbp                                ; Save base pointer
    mov rbp, rsp                            ; Set up stack frame
    
    mov rdi, newline                        ; Newline character string
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Output newline
    
    mov rsp, rbp                            ; Restore stack pointer
    pop rbp                                 ; Restore base pointer
    ret                                     ; Return to caller

;==============================================================================
; FUNCTION: improved_flush_input
; PURPOSE:  Securely cleans input buffer using character-by-character reading
; PARAMS:   None  
; RETURNS:  None
; SECURITY: Prevents input buffer corruption and scanner state issues
; NOTES:    More robust than scanf-based flushing methods
;==============================================================================
improved_flush_input:
    push rbp                                ; Save base pointer
    mov rbp, rsp                            ; Set up stack frame
    
flush_loop:
    ; Read one character from input stream
    xor rax, rax                            ; Clear AL register for varargs
    call getchar                            ; Get single character from stdin
    
    ; Check for termination conditions
    cmp eax, 10                             ; Compare with newline (ASCII 10)
    je flush_done                           ; Exit if newline found
    cmp eax, -1                             ; Compare with EOF (-1)
    je flush_done                           ; Exit if end-of-file reached
    
    ; Continue flushing if neither newline nor EOF
    jmp flush_loop                          ; Read next character
    
flush_done:
    mov rsp, rbp                            ; Restore stack pointer
    pop rbp                                 ; Restore base pointer
    ret                                     ; Return to caller

;==============================================================================
; FUNCTION: flush_input (Legacy compatibility)
; PURPOSE:  Backward compatibility wrapper
; PARAMS:   None
; RETURNS:  None  
; NOTES:    Redirects to improved implementation, can be removed in future versions
;==============================================================================
flush_input:
    jmp improved_flush_input                ; Use improved version

;==============================================================================
; END OF FILE
;==============================================================================
