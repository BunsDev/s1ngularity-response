#!/bin/bash

# Revoke and rotate GitHub credentials after S1ngularity attack
# Handles PATs, SSH keys, and OAuth tokens

set -euo pipefail

echo "🔑 Revoking and rotating GitHub credentials..."

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed. Please install it first:"
    echo "   brew install gh"
    exit 1
fi

# Check current auth status
echo "Current GitHub authentication status:"
gh auth status || echo "Not authenticated"

# List current SSH keys
echo -e "\nCurrent SSH keys:"
gh ssh-key list || echo "No SSH keys found or not authenticated"

# Generate new SSH key
echo -e "\nGenerating new SSH key..."
read -p "Enter your email address: " EMAIL
SSH_KEY_PATH="$HOME/.ssh/id_ed25519_github_$(date +%Y%m%d_%H%M%S)"

ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY_PATH" -N ''

# Start SSH agent and add key
eval "$(ssh-agent -s)"
ssh-add "$SSH_KEY_PATH"

# Add new key to GitHub
echo "Adding new SSH key to GitHub..."
gh ssh-key add "${SSH_KEY_PATH}.pub" -t "rotated-$(date +%Y%m%d-%H%M%S)"

echo -e "\n🚨 MANUAL STEPS REQUIRED:"
echo "1. Go to GitHub Settings > Developer settings > Personal access tokens"
echo "2. Revoke ALL existing tokens"
echo "3. Go to GitHub Settings > SSH and GPG keys"
echo "4. Delete OLD SSH keys (keep only the new one added today)"
echo "5. Go to GitHub Settings > Applications > Authorized OAuth Apps"
echo "6. Revoke access for any suspicious applications"
echo "7. Enable 2FA if not already enabled"

echo -e "\n📋 Update your git config to use the new SSH key:"
echo "   git config --global user.email \"$EMAIL\""
echo "   Add this to ~/.ssh/config:"
echo "   Host github.com"
echo "     HostName github.com"
echo "     User git"
echo "     IdentityFile $SSH_KEY_PATH"

echo -e "\n✅ GitHub credential rotation initiated"
echo "⚠️  Complete the manual steps above to finish the process"
