#!/bin/bash

# Scan for exposed secrets using GitGuardian tools
# Monitors for credential leaks related to S1ngularity attack

set -euo pipefail

echo "🔍 Scanning for exposed secrets..."

echo "📋 Recommended secret scanning tools:"
echo ""

echo "1. GitGuardian S1ngularity Scanner:"
echo "   https://github.com/GitGuardian/s1ngularity-scanner"
echo "   git clone https://github.com/GitGuardian/s1ngularity-scanner"
echo "   cd s1ngularity-scanner"
echo "   python3 scanner.py"
echo ""

echo "2. GitGuardian HasMySecretLeaked:"
echo "   https://www.gitguardian.com/hasmysecretleaked"
echo "   Check if your secrets have been exposed online"
echo ""

echo "3. Semgrep rules for malicious Nx detection:"
echo "   semgrep --config=auto ."
echo ""

echo "4. Manual checks for Base64 encoded data:"
echo "   Look for results.b64 files in malicious repositories"
echo "   Decode with: base64 -d results.b64 | base64 -d"
echo ""

echo "5. Local file scanning:"
echo "   grep -r 'ghp_\|github_pat_\|glpat-\|sk-' . --exclude-dir=.git 2>/dev/null || echo 'No obvious tokens found'"
echo ""

# Basic local scan for common token patterns
echo "🔍 Running basic local token scan..."
echo "Scanning for common token patterns (GitHub, GitLab, OpenAI):"

# GitHub tokens
if grep -r 'ghp_\|github_pat_' . --exclude-dir=.git --exclude-dir=node_modules 2>/dev/null; then
    echo "🚨 Potential GitHub tokens found!"
else
    echo "✅ No GitHub tokens detected"
fi

# GitLab tokens
if grep -r 'glpat-' . --exclude-dir=.git --exclude-dir=node_modules 2>/dev/null; then
    echo "🚨 Potential GitLab tokens found!"
else
    echo "✅ No GitLab tokens detected"
fi

# OpenAI tokens
if grep -r 'sk-' . --exclude-dir=.git --exclude-dir=node_modules 2>/dev/null; then
    echo "🚨 Potential OpenAI tokens found!"
else
    echo "✅ No OpenAI tokens detected"
fi

echo -e "\n✅ Secret scanning guidance provided"
echo "⚠️  Use the recommended tools above for comprehensive scanning"
