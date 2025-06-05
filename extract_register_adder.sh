#!/bin/bash
# Script to extract just the register_adder function from param_passing_x86_64.asm

# Create the output file
OUTPUT_FILE="register_adder_only.asm"

# Start with the necessary header sections
cat > "$OUTPUT_FILE" << 'EOL'
; Extracted register_adder function for testing
; This file only contains the register_adder function from param_passing_x86_64.asm

section .note.GNU-stack noexec    ; Mark stack as non-executable for security

section .data
    ; String constants needed for the function
    overflow_msg  db "Invalid input. Please try again.", 10, 0  ; Error message for invalid input

section .text
    global register_adder       ; Export this function for testing
    extern printf              ; External C functions needed

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
EOL

echo "Extracted register_adder function to $OUTPUT_FILE"