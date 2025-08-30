#!/bin/bash

# Remove malicious Nx packages and reinstall safe versions
# Based on S1ngularity attack remediation

set -euo pipefail

echo "🧹 Cleaning up malicious Nx installations..."

# Backup current package.json before changes
if [ -f "package.json" ]; then
    cp package.json package.json.backup.$(date +%Y%m%d-%H%M%S)
    echo "✅ Backed up package.json"
fi

# Clear all caches
echo "Clearing package manager caches..."
npm cache clean --force 2>/dev/null || echo "npm cache clean failed"
rm -rf ~/.npm/_npx 2>/dev/null || echo "npx cache clean failed"

# Clear yarn cache if yarn is present
if command -v yarn &> /dev/null; then
    yarn cache clean 2>/dev/null || echo "yarn cache clean failed"
fi

# Clear pnpm cache if pnpm is present
if command -v pnpm &> /dev/null; then
    pnpm store prune 2>/dev/null || echo "pnpm store prune failed"
fi

# Remove malicious Nx versions
echo "Removing potentially malicious Nx packages..."

# Uninstall nx and related packages
npm uninstall nx 2>/dev/null || echo "nx not found in package.json"
npm uninstall -g nx 2>/dev/null || echo "nx not found globally"

# Remove @nx packages that might be affected
NX_PACKAGES=(
    "@nx/workspace" "@nx/devkit" "@nx/eslint-plugin" "@nx/jest"
    "@nx/linter" "@nx/node" "@nx/react" "@nx/angular" "@nx/next"
    "@nx/express" "@nx/nest" "@nx/storybook" "@nx/cypress"
)

for package in "${NX_PACKAGES[@]}"; do
    npm uninstall "$package" 2>/dev/null || true
done

# Install safe version
echo "Installing safe Nx version (21.4.1)..."
npm install nx@21.4.1

# Clear cache again after installation
npm cache clean --force

echo "✅ Nx cleanup complete"
echo "📋 Recommended next steps:"
echo "   1. Update VS Code Nx Console extension to v18.66.0+"
echo "   2. Pin Nx version in package.json to avoid auto-updates"
echo "   3. Run 'npm audit' to check for other vulnerabilities"
