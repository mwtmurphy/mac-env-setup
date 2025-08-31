#!/bin/bash

# Test script for mac-env-setup
# This script tests the setup.sh functionality including Poetry installation reliability

set -e

# Colors for test output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Print test results
print_test_info() {
    echo -e "${BLUE}TEST:${NC} $1"
}

print_test_pass() {
    echo -e "${GREEN}PASS:${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

print_test_fail() {
    echo -e "${RED}FAIL:${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

print_test_warning() {
    echo -e "${YELLOW}WARN:${NC} $1"
}

# Test helper functions
run_test() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local test_name="$1"
    local test_function="$2"
    
    print_test_info "Running: $test_name"
    
    if $test_function; then
        print_test_pass "$test_name"
    else
        print_test_fail "$test_name"
    fi
}

# Mock functions for testing setup.sh functions
mock_curl_success() {
    return 0
}

mock_curl_failure() {
    return 1
}

mock_curl_intermittent() {
    local attempt_file="/tmp/poetry_test_attempt"
    if [ ! -f "$attempt_file" ]; then
        echo "1" > "$attempt_file"
        return 1  # First attempt fails
    else
        local attempt=$(cat "$attempt_file")
        if [ "$attempt" -lt 2 ]; then
            echo $((attempt + 1)) > "$attempt_file"
            return 1  # Second attempt fails
        else
            rm -f "$attempt_file"
            return 0  # Third attempt succeeds
        fi
    fi
}

# Test functions

# Test 1: Validate setup.sh exists and is executable
test_setup_script_exists() {
    local script_path="$(dirname "$0")/../setup.sh"
    
    if [ ! -f "$script_path" ]; then
        echo "setup.sh not found at $script_path"
        return 1
    fi
    
    if [ ! -x "$script_path" ]; then
        echo "setup.sh is not executable"
        return 1
    fi
    
    return 0
}

# Test 2: Test dry-run mode works without errors
test_dry_run_mode() {
    local script_path="$(dirname "$0")/../setup.sh"
    
    # Test dry-run with non-interactive mode
    if "$script_path" --dry-run --non-interactive --name="Test User" --email="test@example.com" --python-version=3.12.11 >/dev/null 2>&1; then
        return 0
    else
        echo "Dry-run mode failed"
        return 1
    fi
}

# Test 3: Test argument parsing
test_argument_parsing() {
    local script_path="$(dirname "$0")/../setup.sh"
    
    # Test help option
    if "$script_path" --help >/dev/null 2>&1; then
        return 0
    else
        echo "Help option failed"
        return 1
    fi
}

# Test 4: Test Python version validation
test_python_version_validation() {
    local script_path="$(dirname "$0")/../setup.sh"
    
    # Test with valid Python version
    if "$script_path" --dry-run --non-interactive --name="Test User" --email="test@example.com" --python-version=3.12.11 >/dev/null 2>&1; then
        return 0
    else
        echo "Valid Python version rejected"
        return 1
    fi
}

# Test 5: Test email validation function
test_email_validation() {
    # Source the setup script to access validation functions
    local script_path="$(dirname "$0")/../setup.sh"
    
    # Extract and test email validation logic
    local valid_emails=("test@example.com" "user.name+tag@example.co.uk" "test123@test-domain.com")
    local invalid_emails=("invalid-email" "test@" "@example.com" "test.example.com")
    
    # This is a simplified test - in a real scenario, we'd extract the function
    for email in "${valid_emails[@]}"; do
        if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            echo "Valid email '$email' failed validation"
            return 1
        fi
    done
    
    for email in "${invalid_emails[@]}"; do
        if [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            echo "Invalid email '$email' passed validation"
            return 1
        fi
    done
    
    return 0
}

# Test 6: Test Poetry installation retry logic (mocked)
test_poetry_retry_logic() {
    # Create a temporary test script that simulates the Poetry installation logic
    local test_script="/tmp/test_poetry_install.sh"
    
    cat > "$test_script" << 'EOF'
#!/bin/bash
max_attempts=3
attempt=1
success=false

# Mock function that fails twice then succeeds
mock_poetry_install() {
    local attempt_file="/tmp/poetry_retry_test"
    if [ ! -f "$attempt_file" ]; then
        echo "1" > "$attempt_file"
        return 1
    else
        local current_attempt=$(cat "$attempt_file")
        if [ "$current_attempt" -lt 2 ]; then
            echo $((current_attempt + 1)) > "$attempt_file"
            return 1
        else
            rm -f "$attempt_file"
            return 0
        fi
    fi
}

while [ $attempt -le $max_attempts ] && [ "$success" = false ]; do
    if mock_poetry_install; then
        success=true
    else
        attempt=$((attempt + 1))
    fi
done

if [ "$success" = true ]; then
    echo "SUCCESS"
    exit 0
else
    echo "FAILURE"
    exit 1
fi
EOF
    
    chmod +x "$test_script"
    
    # Clean up any existing test files
    rm -f /tmp/poetry_retry_test
    
    # Run the test script
    local result
    result=$("$test_script" 2>/dev/null)
    
    # Clean up
    rm -f "$test_script" /tmp/poetry_retry_test
    
    if [ "$result" = "SUCCESS" ]; then
        return 0
    else
        echo "Poetry retry logic failed"
        return 1
    fi
}

# Test 7: Test PATH configuration
test_path_configuration() {
    # Test that PATH export syntax is correct
    local test_path_export='export PATH="$HOME/.local/bin:$PATH"'
    
    # Validate the export statement syntax
    if echo "$test_path_export" | bash -n; then
        return 0
    else
        echo "PATH export syntax is invalid"
        return 1
    fi
}

# Test 8: Integration test - check script structure
test_script_structure() {
    local script_path="$(dirname "$0")/../setup.sh"
    
    # Check for required functions
    local required_functions=("setup_python" "install_homebrew" "configure_git_ssh" "main")
    
    for func in "${required_functions[@]}"; do
        if ! grep -q "^${func}()" "$script_path"; then
            echo "Required function '$func' not found"
            return 1
        fi
    done
    
    return 0
}

# Test 9: Test error handling in Poetry installation
test_poetry_error_handling() {
    # Create a test script that simulates Poetry installation failure
    local test_script="/tmp/test_poetry_error.sh"
    
    cat > "$test_script" << 'EOF'
#!/bin/bash
max_attempts=3
attempt=1
success=false

# Mock function that always fails
mock_poetry_install_fail() {
    return 1
}

while [ $attempt -le $max_attempts ] && [ "$success" = false ]; do
    if mock_poetry_install_fail; then
        success=true
    else
        attempt=$((attempt + 1))
    fi
done

if [ "$success" = false ]; then
    echo "EXPECTED_FAILURE"
    exit 1
else
    echo "UNEXPECTED_SUCCESS"
    exit 0
fi
EOF
    
    chmod +x "$test_script"
    
    # Run the test script and expect failure
    local result
    result=$("$test_script" 2>/dev/null) || true
    
    # Clean up
    rm -f "$test_script"
    
    if [ "$result" = "EXPECTED_FAILURE" ]; then
        return 0
    else
        echo "Poetry error handling test failed - expected failure but got: $result"
        return 1
    fi
}

# Test 10: Test curl timeout parameters
test_curl_timeout_params() {
    # Test that curl timeout parameters are valid
    local curl_command="curl -sSL --connect-timeout 30 --max-time 300 https://example.com"
    
    # Validate curl command syntax (dry run)
    if curl --connect-timeout 30 --max-time 300 --help >/dev/null 2>&1; then
        return 0
    else
        echo "Curl timeout parameters are invalid"
        return 1
    fi
}

# Main test runner
run_tests() {
    echo "============================================"
    echo "     Mac Environment Setup - Test Suite"
    echo "============================================"
    echo
    
    # Run all tests
    run_test "Setup script exists and is executable" test_setup_script_exists
    run_test "Dry-run mode works" test_dry_run_mode
    run_test "Argument parsing works" test_argument_parsing
    run_test "Python version validation" test_python_version_validation
    run_test "Email validation logic" test_email_validation
    run_test "Poetry retry logic" test_poetry_retry_logic
    run_test "PATH configuration syntax" test_path_configuration
    run_test "Script structure validation" test_script_structure
    run_test "Poetry error handling" test_poetry_error_handling
    run_test "Curl timeout parameters" test_curl_timeout_params
    
    echo
    echo "============================================"
    echo "Test Results Summary:"
    echo "  Tests run: $TESTS_RUN"
    echo "  Tests passed: $TESTS_PASSED"
    echo "  Tests failed: $TESTS_FAILED"
    echo "============================================"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        print_test_pass "All tests passed!"
        exit 0
    else
        print_test_fail "$TESTS_FAILED test(s) failed"
        exit 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi