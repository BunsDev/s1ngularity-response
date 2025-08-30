#!/bin/bash

# Check for local indicators of S1ngularity attack
# Looks for inventory files and shell persistence

set -euo pipefail

echo "🔍 Checking for local attack indicators..."

# Check for inventory files
echo "Checking for inventory files:"
INVENTORY_FILES=("/tmp/inventory.txt" "/tmp/inventory.txt.bak")

for file in "${INVENTORY_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "🚨 FOUND: $file"
        echo "   This file contains paths to sensitive files targeted by the malware"
        echo "   Contents preview:"
        head -10 "$file" 2>/dev/null || echo "   (Unable to read file)"
    else
        echo "✅ Not found: $file"
    fi
done

# Check for shell persistence
echo -e "\nChecking for shell persistence mechanisms:"
SHELL_CONFIGS=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bash_profile")

for config in "${SHELL_CONFIGS[@]}"; do
    if [ -f "$config" ]; then
        echo "Checking $config..."
        if grep -q "sudo shutdown -h 0" "$config" 2>/dev/null; then
            echo "🚨 MALICIOUS PERSISTENCE FOUND in $config"
            echo "   Line(s) containing malicious code:"
            grep -n "sudo shutdown -h 0" "$config"
            echo "   ⚠️  REMOVE THESE LINES IMMEDIATELY"
        else
            echo "✅ Clean: $config"
        fi
    fi
done

# Check for suspicious processes
echo -e "\nChecking for suspicious processes:"
if pgrep -f "s1ngularity\|inventory\.txt" > /dev/null; then
    echo "🚨 Suspicious processes found:"
    pgrep -fl "s1ngularity\|inventory\.txt"
else
    echo "✅ No suspicious processes detected"
fi

# Check recent file modifications in /tmp
echo -e "\nChecking recent suspicious files in /tmp:"
find /tmp -name "*s1ngularity*" -o -name "*inventory*" 2>/dev/null | head -10 || echo "✅ No suspicious files found"

echo -e "\n✅ Local indicators check complete"
