# Makefile for Parameter Passing x86_64 Assembly Project
# This makefile builds both the main program and comprehensive test programs
# Author: Gleb Tutubalin
# Version: 1.0.0

# ==============================================================================
# Configuration Variables
# ==============================================================================

# Compiler and assembler settings
ASM = nasm
ASMFLAGS = -f elf64 -g -F dwarf
CC = gcc
CFLAGS = -Wall -Wextra -g -std=c99
LDFLAGS = -no-pie

# Target executable names
MAIN_TARGET = param_passing_x86_64
TEST_STANDALONE = test_standalone
TEST_WITH_ASM = test_with_asm

# Object files
MAIN_OBJ = param_passing_x86_64.o
FUNC_OBJ = register_adder_only.o
TEST_OBJ = test_param_passing.o

# Test libraries
TEST_LIBS = -lcheck -lsubunit -lm -lpthread

# Colors for output (optional, for better UX)
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

# ==============================================================================
# Default Targets
# ==============================================================================

# Default target - build the main program
all: $(MAIN_TARGET)
	@echo "$(GREEN)✅ Build completed successfully!$(NC)"
	@echo "$(BLUE)Run with: make run$(NC)"

# Build all test targets
tests: $(TEST_STANDALONE) $(TEST_WITH_ASM)
	@echo "$(GREEN)✅ All test executables built successfully!$(NC)"

# Help target
help:
	@echo "$(BLUE)Parameter Passing x86_64 Build System$(NC)"
	@echo "$(YELLOW)Available targets:$(NC)"
	@echo "  all              - Build main program (default)"
	@echo "  tests            - Build all test executables"
	@echo "  run              - Execute main program"
	@echo "  test             - Run all tests"
	@echo "  test-standalone  - Run standalone tests (mock implementation)"
	@echo "  test-with-asm    - Run tests with assembly implementation"
	@echo "  clean            - Remove all build artifacts"
	@echo "  debug            - Build with extra debug information"
	@echo "  install-deps     - Install required dependencies (Ubuntu/Debian)"
	@echo "  help             - Show this help message"

# ==============================================================================
# Main Build Targets
# ==============================================================================

# Rule to build the main program
$(MAIN_TARGET): $(MAIN_OBJ)
	@echo "$(YELLOW)🔗 Linking main program...$(NC)"
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	@echo "$(GREEN)✅ Main program built: $(MAIN_TARGET)$(NC)"

# Rule to build the standalone test (with mock implementation)
$(TEST_STANDALONE): test_param_passing.c
	@echo "$(YELLOW)🧪 Building standalone tests...$(NC)"
	$(CC) $(CFLAGS) -DTEST_STANDALONE -o $@ $< $(TEST_LIBS)
	@echo "$(GREEN)✅ Standalone tests built: $(TEST_STANDALONE)$(NC)"

# Extract register_adder function to separate file
register_adder_only.asm: param_passing_x86_64.asm extract_register_adder.sh
	@echo "$(YELLOW)📄 Extracting register_adder function...$(NC)"
	@chmod +x extract_register_adder.sh
	@./extract_register_adder.sh
	@echo "$(GREEN)✅ Function extracted: register_adder_only.asm$(NC)"

# Rule to build the test with assembly functions
$(TEST_WITH_ASM): test_param_passing.c $(FUNC_OBJ)
	@echo "$(YELLOW)🧪 Building assembly integration tests...$(NC)"
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(TEST_LIBS)
	@echo "$(GREEN)✅ Assembly tests built: $(TEST_WITH_ASM)$(NC)"

# ==============================================================================
# Assembly Rules
# ==============================================================================

# Rule to assemble the assembly files
%.o: %.asm
	@echo "$(YELLOW)⚙️  Assembling $<...$(NC)"
	$(ASM) $(ASMFLAGS) $< -o $@
	@echo "$(GREEN)✅ Assembled: $@$(NC)"

# ==============================================================================
# Execution Targets
# ==============================================================================

# Run the main program
run: $(MAIN_TARGET)
	@echo "$(BLUE)🚀 Running $(MAIN_TARGET)...$(NC)"
	@echo "$(YELLOW)=====================================$(NC)"
	./$(MAIN_TARGET)
	@echo "$(YELLOW)=====================================$(NC)"

# Run the standalone test
test-standalone: $(TEST_STANDALONE)
	@echo "$(BLUE)🧪 Running standalone tests...$(NC)"
	@echo "$(YELLOW)=====================================$(NC)"
	./$(TEST_STANDALONE)
	@echo "$(YELLOW)=====================================$(NC)"

# Run the test with assembly
test-with-asm: $(TEST_WITH_ASM)
	@echo "$(BLUE)🧪 Running assembly integration tests...$(NC)"
	@echo "$(YELLOW)=====================================$(NC)"
	./$(TEST_WITH_ASM)
	@echo "$(YELLOW)=====================================$(NC)"

# Run all tests
test: test-standalone test-with-asm
	@echo "$(GREEN)🎉 All tests completed successfully!$(NC)"

# ==============================================================================
# Debug and Development Targets
# ==============================================================================

# Debug build with extra information
debug: CFLAGS += -DDEBUG -O0 -ggdb3
debug: ASMFLAGS += -O0
debug: $(MAIN_TARGET)
	@echo "$(GREEN)🐛 Debug build completed!$(NC)"
	@echo "$(BLUE)Debug with: gdb ./$(MAIN_TARGET)$(NC)"

# Run with valgrind for memory checking
memcheck: $(MAIN_TARGET)
	@echo "$(BLUE)🔍 Running memory check...$(NC)"
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes ./$(MAIN_TARGET)

# Disassemble the main program
disasm: $(MAIN_TARGET)
	@echo "$(BLUE)📋 Disassembling $(MAIN_TARGET)...$(NC)"
	objdump -d -M intel $(MAIN_TARGET) > $(MAIN_TARGET).disasm
	@echo "$(GREEN)✅ Disassembly saved to: $(MAIN_TARGET).disasm$(NC)"

# ==============================================================================
# Installation and Dependencies
# ==============================================================================

# Install dependencies (Ubuntu/Debian)
install-deps:
	@echo "$(YELLOW)📦 Installing dependencies...$(NC)"
	sudo apt update
	sudo apt install -y nasm gcc make libcheck-dev valgrind gdb
	@echo "$(GREEN)✅ Dependencies installed!$(NC)"

# Install dependencies (Fedora/RHEL)
install-deps-fedora:
	@echo "$(YELLOW)📦 Installing dependencies (Fedora)...$(NC)"
	sudo dnf install -y nasm gcc make check-devel valgrind gdb
	@echo "$(GREEN)✅ Dependencies installed!$(NC)"

# ==============================================================================
# Quality Assurance
# ==============================================================================

# Check code style and potential issues
lint:
	@echo "$(BLUE)🔍 Running code analysis...$(NC)"
	@if command -v cppcheck >/dev/null 2>&1; then \
		cppcheck --enable=all --std=c99 test_param_passing.c; \
	else \
		echo "$(YELLOW)⚠️  cppcheck not installed, skipping lint$(NC)"; \
	fi

# Generate test coverage report
coverage: CFLAGS += --coverage
coverage: test
	@echo "$(BLUE)📊 Generating coverage report...$(NC)"
	@if command -v gcov >/dev/null 2>&1; then \
		gcov test_param_passing.c; \
		echo "$(GREEN)✅ Coverage report generated$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  gcov not available$(NC)"; \
	fi

# ==============================================================================
# Documentation
# ==============================================================================

# Generate documentation
docs:
	@echo "$(BLUE)📚 Documentation available:$(NC)"
	@echo "  - README.md       - Main project documentation"
	@echo "  - test_plan.md    - Comprehensive testing strategy"
	@echo "  - CHANGELOG.md    - Version history and changes"
	@echo "  - LICENSE         - MIT license information"

# ==============================================================================
# Packaging and Distribution
# ==============================================================================

# Create source package
package:
	@echo "$(YELLOW)📦 Creating source package...$(NC)"
	tar -czf parameter-passing-x86_64-v1.0.0.tar.gz \
		*.asm *.c *.md makefile *.sh LICENSE .gitignore
	@echo "$(GREEN)✅ Package created: parameter-passing-x86_64-v1.0.0.tar.gz$(NC)"

# ==============================================================================
# Cleanup Targets
# ==============================================================================

# Clean up build artifacts
clean:
	@echo "$(YELLOW)🧹 Cleaning build artifacts...$(NC)"
	rm -f $(MAIN_TARGET) $(TEST_STANDALONE) $(TEST_WITH_ASM)
	rm -f *.o register_adder_only.asm
	rm -f *.gcov *.gcda *.gcno
	rm -f *.disasm
	rm -f core core.*
	@echo "$(GREEN)✅ Cleanup completed!$(NC)"

# Deep clean including temporary files
distclean: clean
	@echo "$(YELLOW)🧹 Deep cleaning...$(NC)"
	rm -f *.tmp *.log *.bak *~
	rm -f parameter-passing-x86_64-*.tar.gz
	@echo "$(GREEN)✅ Deep cleanup completed!$(NC)"

# ==============================================================================
# Information Targets
# ==============================================================================

# Show build information
info:
	@echo "$(BLUE)📋 Build Information:$(NC)"
	@echo "  Assembler: $(ASM) $(ASMFLAGS)"
	@echo "  Compiler:  $(CC) $(CFLAGS)"
	@echo "  Linker:    $(LDFLAGS)"
	@echo "  Test Libs: $(TEST_LIBS)"
	@echo "  Targets:   $(MAIN_TARGET), $(TEST_STANDALONE), $(TEST_WITH_ASM)"

# Check if all tools are available
check-tools:
	@echo "$(BLUE)🔧 Checking required tools...$(NC)"
	@command -v $(ASM) >/dev/null 2>&1 || (echo "$(RED)❌ $(ASM) not found$(NC)"; exit 1)
	@command -v $(CC) >/dev/null 2>&1 || (echo "$(RED)❌ $(CC) not found$(NC)"; exit 1)
	@command -v make >/dev/null 2>&1 || (echo "$(RED)❌ make not found$(NC)"; exit 1)
	@echo "$(GREEN)✅ All required tools are available!$(NC)"

# ==============================================================================
# Phony Targets
# ==============================================================================

.PHONY: all tests run test test-standalone test-with-asm clean distclean
.PHONY: debug memcheck disasm install-deps install-deps-fedora
.PHONY: lint coverage docs package info check-tools help

# ==============================================================================
# Special Targets
# ==============================================================================

# Prevent deletion of intermediate files
.PRECIOUS: %.o register_adder_only.asm

# Default shell
SHELL := /bin/bash
