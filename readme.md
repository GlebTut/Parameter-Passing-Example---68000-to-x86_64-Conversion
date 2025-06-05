# Parameter Passing Example - 68000 to x86_64 Conversion

## Project Overview
This project converts a 68000 assembly program demonstrating parameter passing to x86_64 assembly. The program accepts user input for pairs of numbers, performs arithmetic operations, and maintains a running sum through three iterations.

## Security Improvements
The x86_64 implementation includes several security enhancements not present in the original 68000 code:

1. **Non-executable Stack**: Added `section .note.GNU-stack noexec` directive to mark the stack as non-executable, preventing code injection attacks where malicious input could be executed from the stack.

2. **Input Validation**: Implemented robust input checking using `scanf` return values to verify that input was successfully read and has the expected format.

3. **Overflow Detection**: Added overflow checking in the `register_adder` function using the `jo` (jump if overflow) instruction to detect and handle arithmetic overflow conditions.

4. **Attempt Limiting**: Implemented a retry counter that limits the number of invalid input attempts, preventing potential denial-of-service attacks through deliberate bad input.

5. **Input Buffer Management**: Created a more secure input handling mechanism with proper buffer flushing to prevent scanner issues and buffer overflow vulnerabilities.

## Key Conversion Considerations

### Register Mapping
The 68000 and x86_64 architectures have different register sets and calling conventions:

| 68000 Register | Purpose | x86_64 Equivalent |
|----------------|---------|-------------------|
| D1, D2 | Parameter passing | RDI, RSI (System V ABI) |
| D3 | Running sum | Memory variable |
| D4 | Loop counter | Memory variable |

### Stack Frame Management
- Implemented proper x86_64 stack frames with base pointer preservation
- Used 16-byte aligned stack allocation for System V ABI compliance

### System Calls
- Replaced 68000 TRAP instructions with calls to C library functions:
  - `printf` for output (replacing TRAP #15 display tasks)
  - `scanf` for input (replacing TRAP #15 input tasks)
  - `getchar` for input buffer management

### Function Calling Convention
- Converted BSR (Branch to Subroutine) to the x86_64 `call` instruction
- Implemented System V ABI parameter passing (first parameters in registers: RDI, RSI)
- Ensured proper register preservation across function calls

## Build and Run Instructions

### Prerequisites
- NASM (Netwide Assembler)
- GCC or compatible C compiler
- Linux or Unix-like environment

### Compilation
```bash
# Assemble the program
nasm -f elf64 param_passing_x86_64.asm -o param_passing_x86_64.o

# Link with C standard library
gcc -no-pie param_passing_x86_64.o -o param_passing_x86_64
```

### Execution
```bash
./param_passing_x86_64
```

### Expected Behavior
1. The program prompts for input three times
2. For each iteration:
   - Asks for two numbers
   - Adds them together
   - Adds result to running sum
   - Displays current sum
3. After three iterations, displays final sum

## Testing Approach
The following test cases verify the correctness and security features of the implementation:

1. **Basic Functionality Test**:
   - Input valid integers for all prompts
   - Verify correct calculation and display of running sum

2. **Input Validation Test**:
   - Input non-numeric values (e.g., letters, symbols)
   - Verify appropriate error messages and recovery

3. **Overflow Detection Test**:
   - Input very large integers (near INT64_MAX)
   - Verify that overflow is detected and handled

4. **Attempt Limiting Test**:
   - Repeatedly enter invalid input
   - Verify that the program limits attempts and continues execution

## Performance Optimizations
- Enhanced input buffer flushing with a more efficient implementation
- Simplified control flow for better branch prediction
- Used direct memory access for variables rather than repeatedly loading/storing
- Added skip_iteration logic to gracefully handle persistent invalid input

## Known Limitations
- Integer size is limited to 64-bit signed values (compared to 32-bit in the original 68000 version)
- Error messages are generalized rather than specific to the type of input error
- Program does not support internationalization or non-ASCII input

