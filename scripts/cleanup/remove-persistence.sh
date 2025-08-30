#!/bin/bash

# Remove malicious persistence mechanisms from S1ngularity attack
# Cleans shell configs and removes malicious files

set -euo pipefail

echo "🧹 Removing malicious persistence mechanisms..."

# Remove inventory files
echo "Removing inventory files:"
INVENTORY_FILES=("/tmp/inventory.txt" "/tmp/inventory.txt.bak")

for file in "${INVENTORY_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "Removing: $file"
        rm -f "$file"
        echo "✅ Removed: $file"
    else
        echo "✅ Not found: $file"
    fi
done

# Clean shell configurations
echo -e "\nCleaning shell configurations:"
SHELL_CONFIGS=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bash_profile")

for config in "${SHELL_CONFIGS[@]}"; do
    if [ -f "$config" ]; then
        echo "Checking $config..."
        
        # Create backup before modification
        cp "$config" "${config}.backup.$(date +%Y%m%d-%H%M%S)"
        
        # Remove malicious lines
        if grep -q "sudo shutdown -h 0" "$config" 2>/dev/null; then
            echo "🧹 Removing malicious lines from $config"
            grep -v "sudo shutdown -h 0" "$config" > "${config}.tmp"
            mv "${config}.tmp" "$config"
            echo "✅ Cleaned: $config"
        else
            echo "✅ Clean: $config"
            # Remove backup if no changes were made
            rm -f "${config}.backup.$(date +%Y%m%d-%H%M%S)"
        fi
    fi
done

# Remove any s1ngularity-related files
echo -e "\nRemoving s1ngularity-related files:"
find /tmp -name "*s1ngularity*" -type f -delete 2>/dev/null || echo "No s1ngularity files found in /tmp"

# Kill any suspicious processes
echo -e "\nChecking for suspicious processes:"
if pgrep -f "s1ngularity\|inventory\.txt" > /dev/null; then
    echo "🚨 Killing suspicious processes:"
    pkill -f "s1ngularity\|inventory\.txt" || echo "Failed to kill some processes"
else
    echo "✅ No suspicious processes found"
fi

echo -e "\n✅ Persistence removal complete"
echo "📋 Recommended: Restart your shell or run 'source ~/.bashrc' (or ~/.zshrc)"
