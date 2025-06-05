# Makefile for Parameter Passing x86_64 Assembly Project
# This makefile builds both the main program and test programs

# Compiler and assembler settings
ASM = nasm
ASMFLAGS = -f elf64
CC = gcc
CFLAGS = -Wall -g

# Target executable names
MAIN_TARGET = param_passing_x86_64
TEST_STANDALONE = test_standalone
TEST_WITH_ASM = test_with_asm

# Object files
MAIN_OBJ = param_passing_x86_64.o
FUNC_OBJ = register_adder_only.o
TEST_OBJ = test_param_passing.o

# Default target - build the main program
all: $(MAIN_TARGET)

# Build all test targets
tests: $(TEST_STANDALONE) $(TEST_WITH_ASM)

# Rule to build the main program
$(MAIN_TARGET): $(MAIN_OBJ)
	$(CC) $(CFLAGS) -o $@ $(MAIN_OBJ) -no-pie

# Rule to build the standalone test (with mock implementation)
$(TEST_STANDALONE): test_param_passing.c
	$(CC) $(CFLAGS) -DTEST_STANDALONE -o $@ $< -lcheck -lsubunit -lm -pthread

# Extract register_adder function to separate file
register_adder_only.asm: param_passing_x86_64.asm extract_register_adder.sh
	chmod +x extract_register_adder.sh
	./extract_register_adder.sh

# Rule to build the test with assembly functions
$(TEST_WITH_ASM): test_param_passing.c $(FUNC_OBJ)
	$(CC) $(CFLAGS) -o $@ $^ -lcheck -lsubunit -lm -pthread -no-pie

# Rule to assemble the assembly files
%.o: %.asm
	$(ASM) $(ASMFLAGS) $< -o $@

# Run the main program
run:
	./$(MAIN_TARGET)

# Run the standalone test
test-standalone: $(TEST_STANDALONE)
	./$(TEST_STANDALONE)

# Run the test with assembly
test-with-asm: $(TEST_WITH_ASM)
	./$(TEST_WITH_ASM)

# Run all tests
test: test-standalone test-with-asm
	@echo "All tests completed!"

# Clean up build artifacts
clean:
	rm -f $(MAIN_TARGET) $(TEST_STANDALONE) $(TEST_WITH_ASM) *.o register_adder_only.asm

# Phony targets
.PHONY: all tests run test test-standalone test-with-asm clean