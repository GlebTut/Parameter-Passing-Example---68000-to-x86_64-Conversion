/**
 * Test Plan for Parameter Passing Example (x86_64 Assembly)
 * 
 * This file contains test cases for the x86_64 assembly conversion
 * of the parameter passing example. It uses both assert.h for basic
 * tests and libcheck for more comprehensive testing.
 */

 #include <stdio.h>
 #include <stdlib.h>
 #include <assert.h>
 #include <check.h>
 #include <signal.h>
 #include <limits.h>
 #include <unistd.h>
 #include <sys/wait.h>
 #include <stdint.h>
 #include <string.h>
 
 /*
  * When testing standalone, we need to implement our own version of register_adder
  * When testing with the assembly file, we'll use the external version instead
  */
 #ifdef TEST_STANDALONE
 // Mock implementation for standalone testing
 int64_t register_adder(int64_t first, int64_t second) {
     // Basic overflow checking
     if ((second > 0 && first > INT64_MAX - second) || 
         (second < 0 && first < INT64_MIN - second)) {
         // Overflow detected - return 0 as the assembly does
         return 0;
     }
     return first + second;
 }
 #else
 // When not in standalone mode, use the external function
 extern int64_t register_adder(int64_t first, int64_t second);
 #endif
 
 /**
  * Test Categories:
  * 1. Basic Functionality Tests - Verify that core functions work correctly
  * 2. Boundary Tests - Test behavior at numeric limits
  * 3. Security Tests - Test security features and protections
  */
 
 /******************************
  * Basic Functionality Tests
  ******************************/
 
 /* Basic test using assert.h */
 void test_register_adder_basic() {
     printf("Running basic register_adder tests...\n");
     
     // Test simple addition
     assert(register_adder(5, 10) == 15);
     assert(register_adder(0, 0) == 0);
     assert(register_adder(-5, 5) == 0);
     assert(register_adder(-10, -20) == -30);
     
     printf("Basic register_adder tests passed!\n");
 }
 
 /* Test with libcheck framework */
 START_TEST(test_register_adder_normal_values) {
     ck_assert_int_eq(register_adder(1, 1), 2);
     ck_assert_int_eq(register_adder(100, 200), 300);
     ck_assert_int_eq(register_adder(0, 100), 100);
     ck_assert_int_eq(register_adder(-50, 50), 0);
     ck_assert_int_eq(register_adder(-100, -100), -200);
 }
 END_TEST
 
 /******************************
  * Boundary Tests
  ******************************/
 
 /* Test behavior at numeric limits */
 START_TEST(test_register_adder_boundary_values) {
     // Test with large positive values
     ck_assert_int_eq(register_adder(INT32_MAX, 1), (int64_t)INT32_MAX + 1);
     
     // Test with large negative values
     ck_assert_int_eq(register_adder(INT32_MIN, -1), (int64_t)INT32_MIN - 1);
     
     // Test overflow detection
     // Note: Our assembly function should return 0 on overflow (as specified in code)
     ck_assert_int_eq(register_adder(INT64_MAX, 1), 0); // Should detect overflow
     ck_assert_int_eq(register_adder(INT64_MIN, -1), 0); // Should detect overflow
 }
 END_TEST
 
 /******************************
  * Security Tests
  ******************************/
 
 /* Test for proper handling of extreme values (security check) */
 START_TEST(test_register_adder_security) {
     // Test with values that might cause security issues if not handled properly
     int64_t result = register_adder(INT64_MAX, INT64_MAX);
     ck_assert_int_eq(result, 0); // Should detect overflow and return 0
     
     // Test with negative extreme values
     result = register_adder(INT64_MIN, INT64_MIN);
     ck_assert_int_eq(result, 0); // Should detect overflow and return 0
 }
 END_TEST
 
 /******************************
  * Setup Test Suites
  ******************************/
 
 Suite* register_adder_suite(void) {
     Suite* s = suite_create("RegisterAdder");
     
     // Basic functionality test case
     TCase* tc_basic = tcase_create("Basic");
     tcase_add_test(tc_basic, test_register_adder_normal_values);
     suite_add_tcase(s, tc_basic);
     
     // Boundary test case
     TCase* tc_boundary = tcase_create("Boundary");
     tcase_add_test(tc_boundary, test_register_adder_boundary_values);
     suite_add_tcase(s, tc_boundary);
     
     // Security test case
     TCase* tc_security = tcase_create("Security");
     tcase_add_test(tc_security, test_register_adder_security);
     suite_add_tcase(s, tc_security);
     
     return s;
 }
 
 /******************************
  * Main Function
  ******************************/
 
 int main(int argc, char* argv[]) {
     printf("=====================================\n");
     printf("Running Parameter Passing x86_64 Tests\n");
     printf("=====================================\n\n");
 
     // Run basic assert tests first
     test_register_adder_basic();
     
     // Run libcheck tests
     int number_failed = 0;
     
     // Create and run the register_adder test suite
     Suite* s1 = register_adder_suite();
     SRunner* sr1 = srunner_create(s1);
     srunner_run_all(sr1, CK_NORMAL);
     number_failed = srunner_ntests_failed(sr1);
     srunner_free(sr1);
     
     printf("\n=====================================\n");
     printf("Test Results: %d tests failed\n", number_failed);
     printf("=====================================\n");
     
     return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
 }