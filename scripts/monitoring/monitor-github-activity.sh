#!/bin/bash

# Monitor GitHub activity for signs of ongoing compromise
# Checks for new repositories, SSH keys, and suspicious activity

set -euo pipefail

echo "👁️  Monitoring GitHub activity for suspicious changes..."

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

OWNER=$(gh api user --jq '.login')
echo "Monitoring activity for user: $OWNER"

# Check for new repositories created in the last 7 days
echo -e "\n📊 Recent repositories (last 7 days):"
RECENT_REPOS=$(gh repo list "$OWNER" --json nameWithOwner,createdAt --jq '.[] | select(.createdAt > (now - 7*24*3600 | strftime("%Y-%m-%dT%H:%M:%SZ"))) | .nameWithOwner')

if [ -z "$RECENT_REPOS" ]; then
    echo "✅ No new repositories in the last 7 days"
else
    echo "🔍 Recent repositories found:"
    echo "$RECENT_REPOS"
    
    # Check if any match the s1ngularity pattern
    if echo "$RECENT_REPOS" | grep -q "s1ngularity-repository-"; then
        echo "🚨 WARNING: Found repositories matching s1ngularity pattern!"
    fi
fi

# Check SSH keys
echo -e "\n🔑 Current SSH keys:"
gh ssh-key list --json title,createdAt | jq -r '.[] | "\(.title) (created: \(.createdAt))"'

# Check for very recent SSH keys (last 24 hours)
RECENT_KEYS=$(gh ssh-key list --json title,createdAt --jq '.[] | select(.createdAt > (now - 24*3600 | strftime("%Y-%m-%dT%H:%M:%SZ"))) | .title')

if [ -n "$RECENT_KEYS" ]; then
    echo "🔍 SSH keys added in last 24 hours:"
    echo "$RECENT_KEYS"
fi

echo -e "\n📋 Manual checks recommended:"
echo "1. Review GitHub security log: https://github.com/settings/security-log"
echo "2. Check for unauthorized OAuth applications: https://github.com/settings/applications"
echo "3. Review organization audit logs (if applicable)"
echo "4. Monitor for unusual login locations/times"

echo -e "\n✅ GitHub activity monitoring complete"
