#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Get inputs from the environment
OPENAI_API_KEY="$1"
GITHUB_TOKEN="$2"
REPOSITORY="$3"
PR_NUMBER="$4"

echo "OPENAI_API_KEY: $OPENAI_API_KEY"
echo "GITHUB_TOKEN: $GITHUB_TOKEN"
echo "REPOSITORY: $REPOSITORY"
echo "PR_NUMBER: $PR_NUMBER"

# Read the PR diff content from the workflow
DIFF_CONTENT=$(cat pr_diff.txt)
printf "DIFF_CONTENT:\n\n%s" "$DIFF_CONTENT"