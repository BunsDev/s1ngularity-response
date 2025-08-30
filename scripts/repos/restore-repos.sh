#!/bin/bash

# Restore original repository names using CSV data
# Usage: ./scripts/restore-repo-names.sh <csv_file>

set -euo pipefail

echo "🔄 Repository Name Restoration Tool (CSV-based)"
echo "=============================================="

# Check if CSV file is provided
if [ $# -ne 1 ]; then
    echo "❌ Usage: $0 <csv_file>"
    echo ""
    echo "Available CSV files:"
    find events/ -name "*.csv" -type f 2>/dev/null | sort
    exit 1
fi

CSV_FILE="$1"

# Check if CSV file exists
if [ ! -f "$CSV_FILE" ]; then
    echo "❌ CSV file not found: $CSV_FILE"
    exit 1
fi

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

echo "📋 Using CSV file: $CSV_FILE"

# Create restoration plan file
PLAN_FILE="restoration-plan-$(date +%Y%m%d-%H%M%S).txt"
echo "📝 Creating restoration plan: $PLAN_FILE"

echo "# Repository Restoration Plan" > "$PLAN_FILE"
echo "# Generated: $(date)" >> "$PLAN_FILE"
echo "# Source CSV: $CSV_FILE" >> "$PLAN_FILE"
echo "# Format: OWNER/CURRENT_NAME -> OWNER/TARGET_NAME" >> "$PLAN_FILE"
echo "" >> "$PLAN_FILE"

# Process CSV file (skip header)
restorable_count=0
total_count=0

while IFS=',' read -r timestamp org current_name target_name extra; do
    # Skip header row
    if [[ "$timestamp" == "@timestamp" ]]; then
        continue
    fi
    
    # Skip empty lines
    if [[ -z "$current_name" || -z "$target_name" ]]; then
        continue
    fi
    
    ((total_count++))
    
    # Clean up names (remove quotes and whitespace)
    current_name=$(echo "$current_name" | sed 's/^"//;s/"$//' | xargs)
    target_name=$(echo "$target_name" | sed 's/^"//;s/"$//' | xargs)
    org=$(echo "$org" | sed 's/^"//;s/"$//' | xargs)
    
    # Skip if target name is empty or invalid
    if [[ -z "$target_name" || "$target_name" == "UNKNOWN" ]]; then
        echo "# SKIP: $org/$current_name -> UNKNOWN_TARGET" >> "$PLAN_FILE"
        continue
    fi
    
    # Add to restoration plan
    echo "$org/$current_name -> $org/$target_name" >> "$PLAN_FILE"
    ((restorable_count++))
    
done < "$CSV_FILE"

echo "" >> "$PLAN_FILE"
echo "# Summary:" >> "$PLAN_FILE"
echo "# Total entries: $total_count" >> "$PLAN_FILE"
echo "# Restorable: $restorable_count" >> "$PLAN_FILE"
echo "# Skipped: $((total_count - restorable_count))" >> "$PLAN_FILE"

echo ""
echo "📊 Restoration Plan Summary:"
echo "   Total CSV entries: $total_count"
echo "   Restorable repositories: $restorable_count"
echo "   Skipped (unknown targets): $((total_count - restorable_count))"
echo ""

if [ "$restorable_count" -eq 0 ]; then
    echo "❌ No repositories can be restored from this CSV file"
    exit 1
fi

echo "📋 Restoration plan created: $PLAN_FILE"
echo ""
echo "Contents:"
echo "========="
cat "$PLAN_FILE"
echo "========="
echo ""

echo "⚠️  IMPORTANT: This will rename $restorable_count repositories!"
echo "Do you want to proceed with the restoration? (y/N)"
read -r confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "❌ Restoration cancelled"
    echo "📝 Plan saved to: $PLAN_FILE"
    exit 0
fi

# Execute restoration
RESTORE_LOG="restore-$(date +%Y%m%d-%H%M%S).log"
echo "📝 Logging to: $RESTORE_LOG"

echo -e "\n🔄 Executing repository restoration..."
restored_count=0
failed_count=0
skipped_count=0

while IFS= read -r line; do
    # Skip comments and empty lines
    if [[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]]; then
        continue
    fi
    
    # Parse line: OWNER/CURRENT_NAME -> OWNER/TARGET_NAME
    if [[ "$line" =~ ^(.+)\ -\>\ (.+)$ ]]; then
        current_repo="${BASH_REMATCH[1]// /}"
        target_repo="${BASH_REMATCH[2]// /}"
        
        # Extract owner and names
        current_owner=$(echo "$current_repo" | cut -d'/' -f1)
        current_name=$(echo "$current_repo" | cut -d'/' -f2)
        target_owner=$(echo "$target_repo" | cut -d'/' -f1)
        target_name=$(echo "$target_repo" | cut -d'/' -f2)
        
        # Verify owners match
        if [[ "$current_owner" != "$target_owner" ]]; then
            echo "❌ Owner mismatch: $current_repo -> $target_repo" | tee -a "$RESTORE_LOG"
            ((failed_count++))
            continue
        fi
        
        echo "🔄 Restoring $current_repo -> $target_name" | tee -a "$RESTORE_LOG"
        
        # Check if target name is available
        if gh repo view "$target_repo" &>/dev/null; then
            echo "❌ Repository $target_repo already exists - cannot restore" | tee -a "$RESTORE_LOG"
            ((failed_count++))
            continue
        fi
        
        # Attempt to rename the repository
        if gh repo edit "$current_repo" --name "$target_name"; then
            echo "✅ Successfully restored $current_repo to $target_repo" | tee -a "$RESTORE_LOG"
            ((restored_count++))
        else
            echo "❌ Failed to restore $current_repo" | tee -a "$RESTORE_LOG"
            ((failed_count++))
        fi
    else
        echo "⚠️  Skipping malformed line: $line" | tee -a "$RESTORE_LOG"
        ((skipped_count++))
    fi
done < "$PLAN_FILE"

echo -e "\n📊 Restoration Summary:" | tee -a "$RESTORE_LOG"
echo "✅ Successfully restored: $restored_count" | tee -a "$RESTORE_LOG"
echo "❌ Failed: $failed_count" | tee -a "$RESTORE_LOG"
echo "⏭️  Skipped: $skipped_count" | tee -a "$RESTORE_LOG"
echo "📝 Full log saved to: $RESTORE_LOG"
echo "📋 Plan file: $PLAN_FILE"

if [ $failed_count -gt 0 ] || [ $skipped_count -gt 0 ]; then
    echo ""
    echo "📋 Manual review required for failed/skipped repositories"
    echo "Check the log file for details: $RESTORE_LOG"
fi

echo -e "\n✅ Repository restoration process complete"
