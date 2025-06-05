# Test Plan for Parameter Passing x86_64 Assembly Code

This document outlines the comprehensive test plan for verifying the correctness and functionality of the x86_64 assembly code converted from the original 68000 assembly program.

## Test Categories

The testing approach is divided into five main categories:

1. **Unit Testing** - Testing individual functions in isolation
2. **Boundary Testing** - Testing behavior at numeric limits
3. **Security Testing** - Verifying security enhancements work correctly
4. **Integration Testing** - Testing the complete program workflow
5. **Regression Testing** - Ensuring the x86_64 version maintains identical functionality to the 68000 version

## Test Environment Setup

### Prerequisites
- Linux environment (preferably Ubuntu 20.04 or newer)
- NASM assembler (version 2.14 or newer)
- GCC compiler (version 9.0 or newer)
- libcheck library (for test framework)
- make utility

### Testing Approaches

There are two main approaches to testing this project:

1. **Standalone Testing (Mock Implementation)**
   ```bash
   # Build and run the standalone tests (with mock C implementation)
   make test-standalone
   ```

2. **Assembly Function Testing**
   ```bash
   # Extract just the register_adder function from the assembly file
   ./extract_register_adder.sh
   
   # Build and run tests with the actual assembly implementation
   make test-with-asm
   ```

### Why Two Testing Approaches?

- **Standalone Testing**: Provides a known-good reference implementation to validate test cases
- **Assembly Function Testing**: Verifies that the actual assembly implementation matches expected behavior

## Test Cases

### 1. Unit Tests for register_adder Function

| Test ID | Description | Input | Expected Output | Rationale |
|---------|-------------|-------|----------------|-----------|
| UT-01 | Basic addition | 5, 10 | 15 | Verify basic addition works |
| UT-02 | Zero operands | 0, 0 | 0 | Edge case - zero values |
| UT-03 | Negative operands | -5, -10 | -15 | Verify handling of negative values |
| UT-04 | Mixed signs | -10, 15 | 5 | Verify correct handling of different signs |
| UT-05 | Large positive values | INT32_MAX, 1 | INT32_MAX+1 | Test large but non-overflowing values |
| UT-06 | Integer overflow | INT64_MAX, 1 | 0 | Verify overflow detection works |
| UT-07 | Integer underflow | INT64_MIN, -1 | 0 | Verify underflow detection works |

### 2. Input Validation Tests

| Test ID | Description | Input | Expected Output | Rationale |
|---------|-------------|-------|----------------|-----------|
| IV-01 | Alphabetic input | "abc" | Error message, retry prompt | Verify rejection of non-numeric input |
| IV-02 | Special characters | "!@#" | Error message, retry prompt | Verify rejection of special characters |
| IV-03 | Mixed alphanumeric | "123abc" | Error message, retry prompt | Verify rejection of mixed input |
| IV-04 | Empty input | [Enter key] | Error message, retry prompt | Verify handling of empty input |
| IV-05 | Excessive input length | Very long string | Error message, retry prompt | Verify buffer handling |

### 3. Security Feature Tests

| Test ID | Description | Input/Scenario | Expected Output | Rationale |
|---------|-------------|----------------|----------------|-----------|
| SEC-01 | Buffer overflow attempt | Input > 16 characters | Error handled gracefully | Verify buffer overflow protection |
| SEC-02 | Attempt limit | 4+ consecutive invalid inputs | Skip iteration message | Verify DOS protection works |
| SEC-03 | Arithmetic overflow | INT64_MAX, INT64_MAX | 0 (safe value) | Verify arithmetic overflow protection |
| SEC-04 | Stack execution | Memory inspection | Stack marked non-executable | Verify NX bit is set on stack |
| SEC-05 | Memory access | Improper memory access | Segmentation fault prevented | Verify memory protection |

### 4. Integration Tests

| Test ID | Description | Input Sequence | Expected Output | Rationale |
|---------|-------------|----------------|----------------|-----------|
| INT-01 | Happy path | 10, 20, 30, 40, 50, 60 | Running sum: 30, 100, 210 | Verify complete workflow |
| INT-02 | Partial invalid input | "abc", 10, 20, 30, 40, 50 | Error recovery, final sum calculation | Verify recovery from errors |
| INT-03 | Skip iteration | 3 invalid inputs, then valid inputs | Skip message, continue with iterations | Verify iteration skipping |
| INT-04 | All iterations with errors | Multiple invalid inputs for all iterations | All iterations skipped, sum=0 | Verify handling of persistent errors |

### 5. Regression Tests

| Test ID | Description | Input | Expected Same Output as 68000 | Rationale |
|---------|-------------|-------|-------------------------------|-----------|
| REG-01 | Small integers | 1-10 range | Yes | Verify identical results for small numbers |
| REG-02 | Large integers | Near INT32_MAX | Yes | Verify identical results for large values |
| REG-03 | Negative integers | Negative values | Yes | Verify identical results for negative values |
| REG-04 | User prompts | Valid inputs | Same prompt text | Verify user experience is identical |
| REG-05 | Error handling | Invalid inputs | Same or better error handling | Verify security is maintained or improved |

## Test Execution Plan

1. **Setup Phase**
   - Compile the assembly code with debugging symbols
   - Build the test program linking with the assembly object file
   - Set up input/output capture for automated testing

2. **Execution Phase**
   - Run unit tests for register_adder function
   - Run input validation tests
   - Run security feature tests
   - Run integration tests
   - Run regression tests comparing with 68000 version

3. **Reporting Phase**
   - Generate test results report
   - Document any failures or inconsistencies
   - Verify all test cases pass before submission

## Additional Security Verification

To specifically verify the security improvements:

1. **Static Analysis**
   - Use tools like objdump to verify stack is marked non-executable
   - Analyze disassembly to ensure proper protection mechanisms

2. **Dynamic Analysis**
   - Run the program with memory debugging tools (Valgrind)
   - Test with fuzzing tools to identify potential remaining vulnerabilities

## Test Automation

The provided `test_param_passing.c` file implements automated tests using:
1. Basic assertion testing with `assert.h`
2. Comprehensive testing with the `libcheck` framework
3. Automated program execution with input/output redirection

This allows for repeated, consistent testing to verify both the correctness of individual functions and the program as a whole.
