#!/bin/bash

# Check for malicious Nx versions
# Based on S1ngularity attack indicators

set -euo pipefail

echo "🔍 Checking for malicious Nx versions..."

# Check globally installed Nx
echo "Checking global Nx installation:"
npm ls -g nx 2>/dev/null || echo "No global Nx found"

# Check local Nx installation
echo -e "\nChecking local Nx installation:"
npm ls nx 2>/dev/null || echo "No local Nx found"

# Define malicious version ranges
MALICIOUS_VERSIONS=(
    "20.9.0" "20.10.0" "20.11.0" "20.12.0"
    "21.5.0" "21.6.0" "21.7.0" "21.8.0"
)

# Check package.json files
echo -e "\nScanning for malicious versions in package files..."
ROOT="${ROOT:-$(pwd)}"

# Find and check lockfiles
find "$ROOT" -type f \( -name 'package-lock.json' -o -name 'pnpm-lock.yaml' -o -name 'yarn.lock' \) \
    -exec grep -HnE 'nx@?(20\.(9|10|11|12)\.0|21\.[5-8]\.0)' {} + 2>/dev/null || echo "No malicious versions found in lockfiles"

# Check for @nx/* packages with malicious versions
echo -e "\nChecking for malicious @nx/* packages:"
find "$ROOT" -type f \( -name 'package-lock.json' -o -name 'pnpm-lock.yaml' -o -name 'yarn.lock' \) \
    -exec grep -HnE '@nx/.*"(20\.9\.0|21\.5\.0)"' {} + 2>/dev/null || echo "No malicious @nx/* packages found"

echo -e "\n✅ Nx version check complete"
