#!/usr/bin/env bats

# Load Bats support for running commands and testing outputs
load 'libs/bats-support/load'
load 'libs/bats-assert/load'

# Path to the script to test
SCRIPT_PATH="../scripts/analyze-code.sh"

# Source the script to make the functions available
source "$SCRIPT_PATH"

# Test: Validate input initialization
@test "initialize_inputs function correctly validates and parses inputs" {
  # Call the function with valid inputs
  run  initialize_inputs "test-key" "test-token" "test/repo" "123"

  # Assert the output
  [ "$status" -eq 0 ]
  [ "$output" = "test-key,test-token,test/repo,123" ]
}

# Test: Validate error handling for missing inputs
@test "initialize_inputs function exits with an error on missing inputs" {
  # Missing the PR_NUMBER parameter
  run  initialize_inputs "test-key" "test-token" "test/repo"

  # Assert the output
  [ "$status" -ne 0 ]
  [[ "$output" == *"Error: Missing required input parameters."* ]]
}

# Test: Validate prepare_prompt function
@test "prepare_prompt function correctly combines instructions and diff content" {
  # Create a mock pr_diff.txt file
  echo "Mock diff content" > pr_diff.txt

  # Call the function
  run prepare_prompt

  # Expected output
  expected_output="Based on the code diff below, please provide a summary of the major insights derived. Also, check for any potential issues or improvements. The response should be a concise summary without any additional formatting, markdown, or characters outside the summary text.\n\nMock diff content"

  # Assert the output
  [ "$status" -eq 0 ]
  [[ "$output" == "$expected_output" ]]

  # Clean up
  rm pr_diff.txt
}