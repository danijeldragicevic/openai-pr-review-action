# Analyze Pull Request with OpenAI

This action automates the process of reviewing code from GitHub pull requests using OpenAI's API.

## Features

- Extracts code diffs from pull requests
- Generates a summary of the code changes using OpenAI's API
- Posts the summary as a comment on the pull request

## Prerequisites

- OpenAI API key
- GitHub repository
- GitHub token

## Usage
Create a GitHub Action workflow:
```
name: "Analyze Pull Request"

on:
  pull_request:
    types:
      - opened
      - reopened
      - synchronize

permissions:
  contents: write
  pull-requests: write

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 1

      - name: Analyze Pull Request with OpenAI
        uses: danijeldragicevic/openai-pr-review-action@v1
        with:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          REPOSITORY: ${{ github.repository }}
          PR_NUMBER: ${{ github.event.pull_request.number }}
          GPT_MODEL: 'gpt-4o-mini' # Optional
          MAX_TOKENS: '500' # Optional
```
The action expects the user to enter their own **GPT_MODEL** and **MAX_TOKENS**. The default values are **gpt-4o-mini** and **500** tokens, respectively.

## OpenAI API Playground
You can experiment with different GPT models using the [OpenAI API Playground](https://platform.openai.com/playground/chat?models=gpt-4o). 
This tool allows you to test various models and settings interactively, to check out which one works best for your use case. 

## Code testing
To test the script using BATs, follow these steps:  
1. Install BATs (Bash Automated Testing System) if you haven't already:  
```
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local
```
2. Run the tests:  
```
bats tests/analyze-code.bats
```


# Licence
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
