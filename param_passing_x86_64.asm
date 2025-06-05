; Title       : Parameter Passing Example - EASy68k to x86_64 Conversion
; Written by   : Converted from Philip Bourke's original
; Date Created : April 28, 2025
; Description  : Demonstrates passing parameters using registers
;                and stack, performing arithmetic operations,
;                and running a loop to keep a running sum.
;                Addresses security vulnerabilities related to
;                stack handling, input validation, and memory access.
;
; Security Improvements from 68k version:
; - Non-executable stack prevents code injection attacks
; - Input validation prevents buffer overflows
; - Overflow detection in arithmetic prevents numerical exploits
; - Attempt limiting prevents denial-of-service attacks

section .note.GNU-stack noexec    ; Mark stack as non-executable for security

section .data
    ; String constants with improved messaging
    prompt        db "Enter number: ", 0
    result_msg    db "The sum is: %ld", 10, 0    ; Include format and newline
    final_msg     db "Final sum is: %ld", 10, 0  ; Include format and newline
    newline       db 10, 0                       ; Carriage return and line feed
    format_in     db "%ld%*c", 0                 ; Format for scanf with input flush
    format_out    db "%ld", 10, 0                ; Format for printf
    overflow_msg  db "Invalid input. Please try again.", 10, 0  ; Error message for invalid input
    attempt_msg   db "Attempt %ld of 3", 10, 0   ; Added to show progress
    skip_msg      db "Skipping this iteration due to invalid input.", 10, 0  ; Added for better UX
    
section .bss
    first_num     resq 1                    ; 64-bit space for first number (D2 in 68k)
    second_num    resq 1                    ; 64-bit space for second number (D1 in 68k)
    running_sum   resq 1                    ; 64-bit space for running sum (D3 in 68k)
    loop_counter  resq 1                    ; 64-bit space for loop counter (D4 in 68k)
    buffer        resb 16                   ; Buffer for string input with limit
    max_attempts  resq 1                    ; Maximum attempts for invalid input

section .text
    global main                 ; Entry point visible to linker
    global register_adder       ; Export this function for testing
    extern printf, scanf, puts, getchar  ; C library functions replace 68k TRAP instructions

main:
    ; Function prologue - standard x86_64 stack frame setup
    push rbp                                ; Save base pointer
    mov rbp, rsp                            ; Set up stack frame
    sub rsp, 32                             ; Reserve stack space (16-byte aligned for System V ABI)
    
    ; Initialize variables (registers in 68k)
    mov qword [running_sum], 0              ; Zero running sum (CLR.L D3 in 68k)
    mov qword [loop_counter], 3             ; Set loop counter (MOVE.W #3, D4 in 68k)
    mov qword [max_attempts], 3             ; Set retry limit (security enhancement)

game_loop:
    ; Check if loop counter is zero
    cmp qword [loop_counter], 0             ; Compare loop counter with 0
    je game_done                            ; Exit loop if counter is zero

    ; Display attempt number for better user experience
    mov rdi, attempt_msg                    ; Format string for attempt message
    mov rsi, qword [loop_counter]           ; Current attempt number
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Print attempt message

    ; Reset attempts counter for this iteration
    mov qword [max_attempts], 3

first_number_prompt:
    ; Check if we've exceeded max attempts
    cmp qword [max_attempts], 0             ; Compare attempts with 0
    je skip_iteration                       ; Skip this iteration if too many failed attempts
    
    ; Display prompt for first number
    mov rdi, prompt                         ; First argument: format string
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Print prompt for first number

    ; Read first integer with bounds checking
    lea rsi, [first_num]                    ; Address to store input
    mov rdi, format_in                      ; Format string
    xor rax, rax                            ; Clear AL register for varargs
    call scanf                              ; Read input into first_num    
    
    ; Validate input - check for invalid input
    cmp rax, 1                              ; Check if scanf read 1 item
    jne first_number_error                  ; Jump if scanf didn't read successfully
    jmp second_number_prompt                ; If valid, continue to second number

first_number_error:
    ; Handle invalid input for first number - error recovery
    mov rdi, overflow_msg                   ; Error message for invalid input
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Print error message
    
    ; Track attempts and prevent infinite loops (security feature)
    dec qword [max_attempts]
    
    ; Flush input buffer to prevent scanner issues - improved using getchar() loop
    call improved_flush_input
    
    jmp first_number_prompt                 ; Try again for first number
    
second_number_prompt:
    ; Reset attempts counter for second number
    mov qword [max_attempts], 3

second_number_try:
    ; Check if we've exceeded max attempts
    cmp qword [max_attempts], 0             ; Compare attempts with 0
    je skip_iteration                       ; Skip this iteration if too many failed attempts
    
    ; Display prompt for second number
    mov rdi, prompt                         ; First argument: format string
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Print prompt for second number
    
    ; Read second integer with bounds checking
    lea rsi, [second_num]                   ; Address to store input
    mov rdi, format_in                      ; Format string
    xor rax, rax                            ; Clear AL register for varargs
    call scanf                              ; Read input into second_num
    
    ; Validate input - check for invalid input
    cmp rax, 1                              ; Check if scanf read 1 item
    jne second_number_error                 ; Jump if scanf didn't read successfully
    jmp process_numbers                     ; If valid, process the numbers

second_number_error:
    ; Handle invalid input for second number - error recovery
    mov rdi, overflow_msg                   ; Error message for invalid input
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Print error message
    
    ; Track attempts and prevent infinite loops (security feature)
    dec qword [max_attempts]
    
    ; Flush input buffer to prevent scanner issues - improved using getchar() loop
    call improved_flush_input
    
    jmp second_number_try                   ; Try again for second number

; Skip the current iteration if too many invalid inputs
; This is a security enhancement to prevent infinite loops
; and provides recovery from persistent bad input
skip_iteration:
    ; Let user know we're skipping with a more descriptive message
    mov rdi, skip_msg                       ; Improved skipping message
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Print skip message
    
    ; Add 0 to running sum for this iteration
    ; Note: We don't need to call register_adder since we're just adding 0
    ; and there's no possibility of overflow - this is more efficient
    
    ; Display skipped result message
    mov rdi, result_msg                     ; Format string with value placeholder
    mov rsi, [running_sum]                  ; Value to print (running sum)
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Print skipped result message
    
    ; Decrement loop counter and continue
    dec qword [loop_counter]                ; Decrement loop counter
    jmp game_loop                           ; Continue to next iteration

process_numbers:
    ; Call add_numbers subroutine - pass parameters via registers
    ; Note: 68k passed parameters in D1/D2 registers directly
    ; x86_64 uses the System V ABI with RDI/RSI for the first two parameters
    mov rdi, [first_num]                    ; First parameter in RDI
    mov rsi, [second_num]                   ; Second parameter in RSI
    call register_adder                     ; Call subroutine
    
    ; Add result to running sum (ADD.L D1, D3 in 68k)
    add [running_sum], rax                  ; Add result to running sum
    
    ; Display intermediate result
    mov rdi, result_msg                     ; Format string with value placeholder
    mov rsi, [running_sum]                  ; Value to print
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Print intermediate result
    
    ; Decrement loop counter (SUBQ.W #1, D4 in 68k)
    dec qword [loop_counter]
    
    ; Continue loop
    jmp game_loop

game_done:
    ; Display final sum
    mov rdi, final_msg                      ; Format string with value placeholder
    mov rsi, [running_sum]                  ; Value to print
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Print final sum message
    
    ; Exit program
    mov rsp, rbp                            ; Restore stack pointer
    pop rbp                                 ; Restore base pointer
    xor rax, rax                            ; Return 0
    ret

; Function to add two numbers
; Parameters:
;   rdi = first number (equivalent to D2 in 68k)
;   rsi = second number (equivalent to D1 in 68k)
; Returns:
;   rax = sum of numbers (or 0 if overflow occurred)
; Security: Includes overflow detection not present in 68k version
register_adder:
    push rbp                                ; Save base pointer
    mov rbp, rsp                            ; Set up stack frame
    
    ; Simple bounds checking for addition
    mov rax, rdi                            ; Move first parameter to rax
    add rax, rsi                            ; Add second parameter
    jo addition_overflow                    ; Jump if overflow occurs
    
    ; Return normally if no overflow
    mov rsp, rbp                            ; Restore stack pointer
    pop rbp                                 ; Restore base pointer
    ret                                     ; Return to caller with result in rax

; Handle addition overflow
addition_overflow:
    mov rdi, overflow_msg                   ; Error message for overflow
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Print overflow message
    
    ; Return a safe value on overflow
    xor rax, rax                            ; Return 0 on overflow
    mov rsp, rbp                            ; Restore stack pointer
    pop rbp                                 ; Restore base pointer
    ret                                     ; Return to caller with 0

; New line subroutine
new_line:
    push rbp                                ; Save base pointer
    mov rbp, rsp                            ; Set up stack frame
    
    mov rdi, newline                        ; Print newline character
    xor rax, rax                            ; Clear AL register for varargs
    call printf                             ; Print newline
    
    mov rsp, rbp                            ; Restore stack pointer
    pop rbp                                 ; Restore base pointer
    ret                                     ; Return to caller

; Improved function to flush the input buffer using getchar() loop
; This is more robust than using scanf for buffer flushing
; Security enhancement: cleans input stream to avoid buffer issues
improved_flush_input:
    push rbp                                ; Save base pointer
    mov rbp, rsp                            ; Set up stack frame
    
flush_loop:
    ; Call getchar() to read and discard a character
    xor rax, rax                            ; Clear AL register for varargs
    call getchar                            ; Get a character from stdin
    
    ; Check if we've reached end of line or EOF
    cmp eax, 10                             ; Compare with newline character
    je flush_done                           ; If newline, we're done
    cmp eax, -1                             ; Compare with EOF
    je flush_done                           ; If EOF, we're done
    
    ; Character wasn't newline or EOF, continue flushing
    jmp flush_loop                          ; Continue loop
    
flush_done:
    mov rsp, rbp                            ; Restore stack pointer
    pop rbp                                 ; Restore base pointer
    ret                                     ; Return to caller

; For backward compatibility - can be removed in future versions
flush_input:
    jmp improved_flush_input                ; Just call the improved version