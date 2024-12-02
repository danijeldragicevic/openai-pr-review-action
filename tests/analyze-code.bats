#!/usr/bin/env bats

# Load Bats support for running commands and testing outputs
load 'libs/bats-support/load'
load 'libs/bats-assert/load'

# Source the script to make the functions available
source "./scripts/analyze-code.sh"

# Test: Validate input initialization
@test "initialize_inputs_success" {
  # Call the function
  run  initialize_inputs "test-key" "test-token" "test/repo" "123" "tmp/pr_diff.txt" "gpt-4o-mini" "500"

  # Expected output
  expected_output="test-key,test-token,test/repo,123,tmp/pr_diff.txt,gpt-4o-mini,500"

  # Assert the output
  [ "$status" -eq 0 ] || fail "Expected status 0, got $status"
  [ "$output" == "$expected_output" ] || fail "Expected output '$expected_output', got '$output'"
}

# Test: Validate error handling for missing inputs
@test "initialize_inputs_failure" {
  # Call the function (with missing parameters)
  run  initialize_inputs "test-key" "test-token" "test/repo" "123"

  # Expected output
  expected_output="Error: Missing required input parameters."

  # Assert the output
  [ "$status" -eq 1 ] || fail "Expected status 0, got $status"
  [ "$output" == "$expected_output" ] || fail "Expected output '$expected_output', got '$output'"
}

# Test: Validate prepare_prompt function
@test "prepare_prompt_success" {
  # Define the file path
  local diff_file_path="tmp/pr_diff.txt"

  # Create the directory if it doesn't exist
  mkdir -p "$(dirname "$diff_file_path")"

  # Create the mock diff file
  echo "Mock diff content" > "$diff_file_path"

  # Call the function
  run prepare_prompt "$diff_file_path"

  # Expected output (BEGIN)
  expected_output="Based on the code diff below, please provide a summary of the major insights derived. Also, check for any potential issues or improvements. The response should be a concise summary without any additional formatting, markdown, or characters outside the summary text.

Mock diff content"
  # Expected output (END)

  # Assert the output
  [ "$status" -eq 0 ] || fail "Expected status 0, got $status"
  [[ "$output" == "$expected_output" ]] || fail "Expected output '$expected_output', got '$output'"

  # Clean up: Remove the file and directory
  rm -rf "$(dirname "$diff_file_path")"
}

# Test: Validate prepare_prompt function fails when the output is unexpected
@test "prepare_prompt_failure" {
  # Define the file path
  local diff_file_path="tmp/pr_diff.txt"

  # Create the directory if it doesn't exist
  mkdir -p "$(dirname "$diff_file_path")"

  # Create the mock diff file
  echo "Mock diff content" > "$diff_file_path"

  # Call the function
  run prepare_prompt "$diff_file_path"

  # Expected output
  expected_output="This is an incorrect expected output for testing purposes"

  # Assert the output
  [ "$status" -eq 0 ] || fail "Expected status 0, got $status"
  [[ "$output" != "$expected_output" ]] || fail "Expected output '$expected_output', got '$output'"

  # Clean up: Remove the file and directory
  rm -rf "$(dirname "$diff_file_path")"
}

# Test: Validate call_openai_api function
@test "call_openai_api_success" {
  # Mock OpenAI API key and prompt
  local openai_api_key="test-api-key"
  local full_prompt="Test prompt for OpenAI API"
  local gpt_model="gpt-4o-mini"
  local max_tokens="500"

  # Mock response from the OpenAI API
  local mock_response='{
    "choices": [
      {
        "message": {
          "content": "Test response from OpenAI API"
        }
      }
    ]
  }'

  # Mock the curl command
  function curl() {
    echo "$mock_response"
  }

  # Call the function
  run call_openai_api "$openai_api_key" "$full_prompt" "$gpt_model" "$max_tokens"

  # Assert the output
  [ "$status" -eq 0 ] || fail "Expected status 0, got $status"
  [[ "$output" == "$mock_response" ]] || fail "Expected output '$mock_response', got '$output'"
}

# Test: Validate call_openai_api function handles API failure
@test "call_openai_api_failure" {
  # Mock OpenAI API key and prompt
  local openai_api_key="test-api-key"
  local full_prompt="Test prompt for OpenAI API"
  local gpt_model="gpt-4o-mini"
  local max_tokens="500"

  # Mock response from the OpenAI API
  local mock_error_response='{
    "error": {
      "message": "Invalid API key",
      "type": "authentication_error"
    }
  }'

  # Mock the curl command
  function curl() {
    echo "$mock_error_response"
    return 1
  }

  # Call the function
  run call_openai_api "$openai_api_key" "$full_prompt" "$gpt_model" "$max_tokens"

  # Assert the output
  [ "$status" -eq 1 ] || fail "Expected status 1, got $status"
  [[ "$output" == "$mock_error_response" ]] || fail "Expected output '$mock_error_response', got '$output'"
}

# Test: Validate extract_summary function
@test "extract_summary_success" {
  # Mock response from the OpenAI API
  local mock_response='{
    "choices": [
      {
        "message": {
          "content": "Test response from OpenAI API"
        }
      }
    ]
  }'

  # Call the function
  run extract_summary "$mock_response"

  # Expected output
  expected_output="Test response from OpenAI API"

  # Assert the output
  [ "$status" -eq 0 ] || fail "Expected status 0, got $status"
  [[ "$output" == "$expected_output" ]] || fail "Expected output '$expected_output', got '$output'"
}

# Test: Validate extract_summary function fails when the output is unexpected
@test "extract_summary_failure" {
  # Mock response from the OpenAI API
  local mock_response='{
    "choices": [
      {
        "message": {
          "content": "Test response from OpenAI API"
        }
      }
    ]
  }'

  # Call the function
  run extract_summary "$mock_response"

  # Expected output
  expected_output="This is an incorrect expected output for testing purposes"

  # Assert the output
  [ "$status" -eq 0 ] || fail "Expected status 0, got $status"
  [[ "$output" != "$expected_output" ]] || fail "Expected output '$expected_output', got '$output'"
}

# Test: Validate post_summary_to_github function
@test "post_summary_to_github_success" {
  # Mock GitHub token, repository, PR number, and summary
  local github_token="test-github-token"
  local repository="test/repo"
  local pr_number="123"
  local summary="Test summary for GitHub"

  # Mock the curl command
  function curl() {
    echo "Comment posted successfully"
  }

  # Call the function
  run post_summary_to_github "$github_token" "$repository" "$pr_number" "$summary"

  # Assert the output
  [ "$status" -eq 0 ] || fail "Expected status 0, got $status"
  [[ "$output" == "Comment posted successfully" ]] || fail "Expected output 'Comment posted successfully', got '$output'"
}

# Test: Validate post_summary_to_github function handles API failure
@test "post_summary_to_github_failure" {
  # Mock GitHub token, repository, PR number, and summary
  local github_token="test-github-token"
  local repository="test/repo"
  local pr_number="123"
  local summary="Test summary for GitHub"

  # Mock the curl command
  function curl() {
    echo "Error posting comment to GitHub"
    return 1
  }

  # Call the function
  run post_summary_to_github "$github_token" "$repository" "$pr_number" "$summary"

  # Assert the output
  [ "$status" -eq 1 ] || fail "Expected status 1, got $status"
  [[ "$output" == "Error posting comment to GitHub" ]] || fail "Expected output 'Error posting comment to GitHub', got '$output'"
}
























