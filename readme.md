# Parameter Passing: 68000 to x86_64 Assembly Conversion

<div align="center">

![Assembly](https://img.shields.io/badge/Assembly-x86__64-blue?style=for-the-badge&logo=assembly)
![C](https://img.shields.io/badge/C-Testing-green?style=for-the-badge&logo=c)
![Security](https://img.shields.io/badge/Security-Enhanced-red?style=for-the-badge&logo=security)
![Tests](https://img.shields.io/badge/Tests-Passing-brightgreen?style=for-the-badge&logo=checkmarx)

**🏆 Professional assembly language conversion with modern security enhancements**

</div>

---

## 🎯 Project Overview

This project demonstrates the conversion of a **Motorola 68000 assembly program** to **x86_64 assembly**, showcasing parameter passing techniques while implementing modern security features. The program performs interactive arithmetic operations with robust input validation and overflow protection.

### ✨ Key Features
- 🔄 **Architecture Conversion**: Complete 68k → x86_64 port
- 🛡️ **Security Enhanced**: Modern protection mechanisms
- 🧪 **Dual Testing**: Comprehensive testing strategy
- 📊 **Interactive**: User-friendly number processing
- 🚀 **Performance**: Optimized assembly implementation

---

## 🏗️ Project Structure

```
📦 parameter-passing-x86_64/
├── 📄 param_passing_x86_64.asm     # Main assembly program
├── 📄 register_adder_only.asm      # Extracted function (auto-generated)
├── 🧪 test_param_passing.c         # Comprehensive test suite
├── 🔧 makefile                     # Build automation system
├── 📜 extract_register_adder.sh    # Function extraction utility
├── 📖 readme.md                    # Project documentation
├── 📋 test_plan.md                 # Detailed testing strategy
└── 📝 .gitignore                   # Git ignore rules
```

---

## 🚀 Quick Start

### Prerequisites
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install nasm gcc make libcheck-dev

# Fedora/RHEL
sudo dnf install nasm gcc make check-devel

# Arch Linux
sudo pacman -S nasm gcc make check
```

### Build and Run
```bash
# Clone the repository
git clone https://github.com/yourusername/parameter-passing-x86_64.git
cd parameter-passing-x86_64

# Build the main program
make all

# Run the interactive program
make run

# Run all tests
make test

# Clean build artifacts
make clean
```

---

## 📊 Program Demo

### Expected Output
```
Attempt 3 of 3
Enter number: 15
Enter number: 25
The sum is: 40

Attempt 2 of 3
Enter number: 10
Enter number: 30
The sum is: 80

Attempt 1 of 3
Enter number: 5
Enter number: 15
The sum is: 100

Final sum is: 100
```

### Error Handling Demo
```
Enter number: abc
Invalid input. Please try again.
Enter number: 123xyz
Invalid input. Please try again.
Enter number: 15
Enter number: 25
The sum is: 40
```

---

## 🔄 Architecture Conversion

### Register Mapping
```
┌─────────────────┬─────────────────┬──────────────────────┐
│ 68000 Feature   │ x86_64 Equivalent│ Implementation      │
├─────────────────┼─────────────────┼──────────────────────┤
│ D1, D2 (params) │ RDI, RSI        │ System V ABI        │
│ D3 (running sum)│ Memory variable │ [running_sum]       │
│ D4 (loop count) │ Memory variable │ [loop_counter]      │
│ TRAP #15        │ printf/scanf    │ C library calls     │
│ BSR instruction │ call instruction│ Function calls      │
│ No overflow     │ jo (jump overflow)│ Hardware detection │
└─────────────────┴─────────────────┴──────────────────────┘
```

### Security Improvements
```
┌─────────────────────┬─────────────────────┬─────────────────────┐
│ Security Feature    │ 68000 Version       │ x86_64 Enhanced     │
├─────────────────────┼─────────────────────┼─────────────────────┤
│ Stack Protection    │ ❌ Not Available    │ ✅ NX Stack         │
│ Input Validation    │ ❌ Basic/None       │ ✅ Robust Checking  │
│ Overflow Detection  │ ❌ Not Implemented  │ ✅ Hardware JO Flag │
│ DoS Prevention      │ ❌ Not Available    │ ✅ Attempt Limiting │
│ Buffer Management   │ ❌ Basic           │ ✅ Advanced Flushing │
└─────────────────────┴─────────────────────┴─────────────────────┘
```

---

## 🛡️ Security Features

### 1. **Non-Executable Stack**
```assembly
section .note.GNU-stack noexec    ; Prevents code injection attacks
```

### 2. **Overflow Detection**
```assembly
register_adder:
    mov rax, rdi                  ; First parameter
    add rax, rsi                  ; Add second parameter
    jo addition_overflow          ; Jump if overflow detected
    ret                           ; Return result
```

### 3. **Input Validation**
```assembly
call scanf                       ; Read input
cmp rax, 1                      ; Check if scanf read 1 item
jne handle_error                ; Jump if input invalid
```

### 4. **Denial-of-Service Prevention**
- Limits invalid input attempts to 3 per iteration
- Gracefully skips iterations after persistent invalid input
- Prevents infinite loops from malicious input

---

## 🧪 Testing Strategy

### Dual Testing Approach

#### 1. **Standalone Testing** (Mock Implementation)
```bash
make test-standalone
```
- Tests logic with C implementation
- Validates test cases themselves
- Quick feedback during development

#### 2. **Assembly Integration Testing**
```bash
make test-with-asm
```
- Tests actual assembly implementation
- Verifies register_adder function
- End-to-end validation

### Test Categories

| Category | Tests | Coverage |
|----------|-------|----------|
| **Unit Tests** | Basic arithmetic operations | ✅ Core functionality |
| **Boundary Tests** | INT64_MAX, INT64_MIN limits | ✅ Edge cases |
| **Security Tests** | Overflow detection, buffer safety | ✅ Security features |
| **Integration Tests** | Complete program workflow | ✅ User experience |
| **Regression Tests** | Comparison with 68k version | ✅ Compatibility |

---

## 📚 Technical Implementation

### Function Calling Convention
```assembly
; System V ABI Parameter Passing
register_adder:
    ; RDI = first parameter (was D2 in 68k)
    ; RSI = second parameter (was D1 in 68k)
    ; RAX = return value (was D1 in 68k)
```

### Memory Management
```assembly
; Proper stack frame setup
push rbp                         ; Save base pointer
mov rbp, rsp                     ; Setup stack frame
sub rsp, 32                      ; 16-byte aligned allocation
```

### Error Recovery
```assembly
improved_flush_input:
    call getchar                 ; Read character
    cmp eax, 10                  ; Check for newline
    je flush_done                ; Exit if newline found
    jmp flush_loop               ; Continue flushing
```

---

## 🔧 Build System

### Makefile Targets
```bash
make all           # Build main program
make tests         # Build all test executables
make run           # Execute main program
make test          # Run all tests
make clean         # Remove build artifacts
```

### Advanced Usage
```bash
# Build with debug symbols
make CFLAGS="-Wall -g -DDEBUG"

# Run specific tests
make test-standalone
make test-with-asm

# Extract function for testing
make register_adder_only.asm
```

---

## 🚧 Development Notes

### Known Limitations
- **Platform**: Linux/Unix systems only (uses System V ABI)
- **Architecture**: x86_64 only (64-bit Intel/AMD)
- **Input Range**: Limited to 64-bit signed integers
- **Locale**: ASCII input only (no internationalization)

### Future Enhancements
- [ ] Cross-platform support (Windows, macOS)
- [ ] GUI interface for demonstration
- [ ] Performance benchmarking vs 68k version
- [ ] Additional architecture targets (ARM64, RISC-V)

---

## 📖 Educational Value

This project demonstrates:

### **System Programming Concepts**
- Low-level processor architecture differences
- Assembly language programming techniques
- System call interfaces and ABI compliance
- Memory management and stack operations

### **Security Engineering**
- Modern CPU security features utilization
- Input validation and sanitization techniques
- Overflow detection and prevention methods
- Defensive programming practices

### **Software Testing**
- Unit testing for assembly functions
- Integration testing strategies
- Security testing methodologies
- Automated testing frameworks

---

## 🏆 Project Highlights

### **Technical Achievement**
- ✅ Complete architecture conversion (68k → x86_64)
- ✅ Enhanced security implementation
- ✅ Professional testing methodology
- ✅ Automated build and deployment

### **Educational Impact**
- 🎓 Demonstrates deep system programming knowledge
- 🎓 Shows understanding of processor architectures
- 🎓 Exhibits security-conscious development
- 🎓 Proves testing and documentation skills

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Gleb Tutubalin**
- 🎓 Software Development Student at SETU (Ireland)
- 💼 Specializing in system programming and security
- 📧 Contact: glebtutubalin@gmail.com
- 🔗 [GitHub](https://github.com/yourusername) | [LinkedIn](https://linkedin.com/in/yourusername)

---

## 🙏 Acknowledgments

- Original 68000 assembly program by Philip Bourke
- SETU University for educational support
- Assembly programming community for best practices
- Security research community for modern protection techniques

---

<div align="center">

**⭐ Star this repository if you found it helpful! ⭐**

*Built with ❤️ and Assembly*

</div>
