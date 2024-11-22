#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to validate and initialize inputs
initialize_inputs() {
  local openai_api_key="$1"
  local github_token="$2"
  local repository="$3"
  local pr_number="$4"

  if [[ -z "$openai_api_key" || -z "$github_token" || -z "$repository" || -z "$pr_number" ]]; then
    echo "Error: Missing required input parameters."
    exit 1
  fi

  echo "$openai_api_key,$github_token,$repository,$pr_number"
}

# Function to prepare the prompt for ChatGPT
prepare_prompt() {
  local instructions="Based on the code diff below, please provide a summary of the major insights derived. Also, check for any potential issues or improvements. The response should be a concise summary without any additional formatting, markdown, or characters outside the summary text."
  local diff_content
  diff_content=$(cat pr_diff.txt)

  echo -e "$instructions\n\n$diff_content"
}

# Function to send the prompt to OpenAI API and get the response
call_openai_api() {
  local openai_api_key="$1"
  local full_prompt="$2"

  local messages_json
  messages_json=$(jq -n --arg body "$full_prompt" '[{"role": "user", "content": $body}]')

  curl -s -X POST "https://api.openai.com/v1/chat/completions" \
    -H "Authorization: Bearer $openai_api_key" \
    -H "Content-Type: application/json" \
    -d "{\"model\": \"gpt-3.5-turbo\", \"messages\": $messages_json, \"max_tokens\": 500}"
}

# Function to extract the summary from the OpenAI API response
extract_summary() {
  local response="$1"

  echo "$response" | jq -r '.choices[0].message.content'
}

# Function to post the summary as a comment on the pull request
post_summary_to_github() {
  local github_token="$1"
  local repository="$2"
  local pr_number="$3"
  local summary="$4"

  local comment_body
  comment_body=$(jq -n --arg body "$summary" '{body: $body}')

  curl -s -X POST \
    -H "Authorization: Bearer $github_token" \
    -H "Content-Type: application/json" \
    -d "$comment_body" \
    "https://api.github.com/repos/$repository/issues/$pr_number/comments"
}

# Main execution flow
main() {
  # Initialize inputs
  IFS=',' read -r OPENAI_API_KEY GITHUB_TOKEN REPOSITORY PR_NUMBER <<< "$(initialize_inputs "$@")"

  # Prepare prompt
  FULL_PROMPT=$(prepare_prompt)

  # Call OpenAI API and get the response
  RESPONSE=$(call_openai_api "$OPENAI_API_KEY" "$FULL_PROMPT")

  # Extract summary from the response
  SUMMARY=$(extract_summary "$RESPONSE")

  # Post the summary to GitHub as a comment
  post_summary_to_github "$GITHUB_TOKEN" "$REPOSITORY" "$PR_NUMBER" "$SUMMARY"
}

# Execute the script
main "$@"
