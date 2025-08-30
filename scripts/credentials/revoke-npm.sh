#!/bin/bash

# Revoke and rotate npm credentials after S1ngularity attack

set -euo pipefail

echo "🔑 Revoking and rotating npm credentials..."

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed"
    exit 1
fi

# Check current npm user
echo "Current npm user:"
npm whoami 2>/dev/null || echo "Not logged in to npm"

# List current tokens (if logged in)
echo -e "\nChecking npm authentication:"
if npm whoami &> /dev/null; then
    echo "✅ Currently logged in to npm"
    echo "🚨 You need to revoke all existing tokens manually"
else
    echo "ℹ️  Not currently logged in to npm"
fi

echo -e "\n🚨 MANUAL STEPS REQUIRED:"
echo "1. Go to https://www.npmjs.com/settings/tokens"
echo "2. Delete ALL existing tokens"
echo "3. Generate new tokens with minimal required scopes"
echo "4. Enable 2FA for publishing if not already enabled:"
echo "   npm profile enable-2fa auth-and-writes"
echo "5. Update your CI/CD systems with new tokens"

echo -e "\n📋 To logout and re-authenticate:"
echo "   npm logout"
echo "   npm login"

echo -e "\n✅ npm credential rotation guidance provided"
echo "⚠️  Complete the manual steps above to secure your npm account"
