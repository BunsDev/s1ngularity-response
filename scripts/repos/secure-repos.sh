#!/bin/bash

# Secure malicious repositories created by S1ngularity attack
# Makes repositories private and audits for unauthorized changes

set -euo pipefail

echo "🔒 Securing malicious repositories..."

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

# Check if repos_to_secure.txt exists
if [ ! -f "repos_to_secure.txt" ]; then
    echo "📋 No repos_to_secure.txt found. Running repository check first..."
    ./scripts/detection/check-github-repos.sh
fi

if [ ! -f "repos_to_secure.txt" ] || [ ! -s "repos_to_secure.txt" ]; then
    echo "✅ No malicious repositories found to secure"
    exit 0
fi

echo "🔒 Making repositories private..."
while IFS= read -r repo; do
    if [ -n "$repo" ]; then
        echo "Making $repo private..."
        gh repo edit "$repo" --visibility private --accept-visibility-change-consequences || echo "Failed to make $repo private"
    fi
done < repos_to_secure.txt

echo -e "\n📋 MANUAL AUDIT REQUIRED:"
echo "For each repository, you should:"
echo "1. Review commit history for unauthorized changes"
echo "2. Check for unauthorized forks"
echo "3. Download and analyze the contents (especially results.b64)"
echo "4. Consider deleting the repositories entirely"
echo "5. File GitHub takedown requests if repositories were forked"

echo -e "\n📋 Organization audit (if applicable):"
echo "1. Review organization audit logs"
echo "2. Check for unauthorized repository renames"
echo "3. Look for added SSH keys or deploy keys"
echo "4. Review suspicious access patterns"

echo -e "\n✅ Repository security measures applied"
echo "⚠️  Complete the manual audit steps above"
