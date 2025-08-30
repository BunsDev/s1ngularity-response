#!/bin/bash

# Check for rogue GitHub repositories created by S1ngularity attack
# Looks for repos named s1ngularity-repository-*

set -euo pipefail

echo "🔍 Checking for rogue GitHub repositories..."

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed. Please install it first:"
    echo "   brew install gh"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI. Please run:"
    echo "   gh auth login"
    exit 1
fi

# Get current user
OWNER=$(gh api user --jq '.login')
echo "Checking repositories for user: $OWNER"

# Pattern to match malicious repos
PATTERN="^${OWNER}/s1ngularity-repository-"

echo "Searching for repositories matching pattern: s1ngularity-repository-*"

# List all public repos and filter for malicious pattern
MALICIOUS_REPOS=$(gh repo list "$OWNER" --visibility public -L 10000 --json nameWithOwner \
    --jq '.[] | .nameWithOwner | select(test("'"$PATTERN"'"))' 2>/dev/null || true)

if [ -z "$MALICIOUS_REPOS" ]; then
    echo "✅ No malicious repositories found"
else
    echo "🚨 MALICIOUS REPOSITORIES DETECTED:"
    echo "$MALICIOUS_REPOS"
    echo ""
    echo "These repositories likely contain stolen credentials!"
    echo "Run the secure-repos.sh script to make them private immediately."
    
    # Save to file for other scripts
    echo "$MALICIOUS_REPOS" > repos_to_secure.txt
    echo "Repository list saved to repos_to_secure.txt"
fi

echo -e "\n✅ GitHub repository check complete"
