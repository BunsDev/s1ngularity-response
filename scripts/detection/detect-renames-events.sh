#!/bin/bash

# Script to detect repository renames using GitHub Events API
# Usage: ./detect-renames-events.sh [csv_file]
# This approach works when audit logs are not accessible

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default CSV file or use provided argument
CSV_FILE="${1:-events/rename-events.csv}"

echo "🔍 Detecting repository renames using GitHub Events API..."
echo "📋 CSV lookup file: $CSV_FILE"

# Get current user
CURRENT_USER=$(gh api user --jq .login)
echo "📋 Checking events for user: $CURRENT_USER"

# Fetch recent user events
echo "📡 Fetching recent user events..."
USER_EVENTS=$(gh api "users/$CURRENT_USER/events" --paginate 2>/dev/null || echo "[]")
TOTAL_EVENTS=$(echo "$USER_EVENTS" | jq 'length' 2>/dev/null || echo "0")
echo "📊 Found $TOTAL_EVENTS recent events"

# Look for repository rename events
echo ""
echo "🔍 Searching for repository rename events..."
RENAME_EVENTS=$(echo "$USER_EVENTS" | jq '
    map(select(.type == "RepositoryEvent" and .payload.action == "renamed"))
    | map({
        repo: .repo.name,
        from: .payload.rename.from,
        to: .payload.rename.to,
        created_at: .created_at,
        is_s1ngularity: (.payload.rename.to | test("s1ngularity-repository-"))
    })
' 2>/dev/null || echo "[]")

RENAME_COUNT=$(echo "$RENAME_EVENTS" | jq 'length' 2>/dev/null || echo "0")
echo "📋 Found $RENAME_COUNT rename events"

# Initialize S1NGULARITY_COUNT
S1NGULARITY_COUNT=0

if [ "$RENAME_COUNT" -gt 0 ]; then
    echo ""
    echo "🎯 Repository rename events found:"
    echo "$RENAME_EVENTS" | jq -r '
        .[] | "  • \(.repo): \(.from) → \(.to) (\(.created_at))"
    '
    
    # Filter S1ngularity renames
    S1NGULARITY_RENAMES=$(echo "$RENAME_EVENTS" | jq 'map(select(.is_s1ngularity))' 2>/dev/null || echo "[]")
    S1NGULARITY_COUNT=$(echo "$S1NGULARITY_RENAMES" | jq 'length' 2>/dev/null || echo "0")
    
    if [ "$S1NGULARITY_COUNT" -gt 0 ]; then
        echo ""
        echo "🚨 S1ngularity repositories made public:"
        
        # Create a lookup map from CSV data if available
        if [ -f "$CSV_FILE" ]; then
            echo "$S1NGULARITY_RENAMES" | jq -r '
                .[] | "  • \(.repo) (original: [lookup from CSV]) - \(.created_at)"
            ' | while read -r line; do
                repo_name=$(echo "$line" | sed -n 's/.*• \([^ ]*\) .*/\1/p')
                original_name=$(grep ",$repo_name," "$CSV_FILE" | cut -d',' -f4 | head -1)
                if [ -n "$original_name" ]; then
                    echo "$line" | sed "s/\[lookup from CSV\]/$original_name/"
                else
                    echo "$line" | sed "s/\[lookup from CSV\]/UNKNOWN/"
                fi
            done
        else
            echo "$S1NGULARITY_RENAMES" | jq -r '
                .[] | "  • \(.repo) (original: UNKNOWN - CSV not found) - \(.created_at)"
            '
        fi
        
        # Generate restoration mapping
        echo ""
        echo "📝 Generating restoration mapping..."
        echo "$S1NGULARITY_RENAMES" | jq -r '
            .[] | "\(.repo) -> \(.from) | https://github.com/\(.repo)"
        ' > s1ngularity-renames-detected.txt
        
        echo -e "${GREEN}✅ Restoration mapping saved to: s1ngularity-renames-detected.txt${NC}"
    else
        echo -e "${GREEN}✅ No S1ngularity renames detected in recent events${NC}"
    fi
else
    echo -e "${YELLOW}ℹ️  No repository rename events found in recent activity${NC}"
fi

# Look for PublicEvent (repositories being made public)
echo ""
echo "🔍 Searching for repositories made public (potential S1ngularity indicators)..."
PUBLIC_EVENTS=$(echo "$USER_EVENTS" | jq '
    map(select(.type == "PublicEvent" and (.repo.name | test("s1ngularity-repository-"))))
    | map({
        repo: .repo.name,
        created_at: .created_at,
        is_s1ngularity: true
    })
' 2>/dev/null || echo "[]")

PUBLIC_COUNT=$(echo "$PUBLIC_EVENTS" | jq 'length' 2>/dev/null || echo "0")
echo "📋 Found $PUBLIC_COUNT S1ngularity repositories made public"

if [ "$PUBLIC_COUNT" -gt 0 ]; then
    echo ""
    echo -e "${RED}🚨 S1ngularity repositories made public:${NC}"
    # Create a lookup map from CSV data if available
    if [ -f "$CSV_FILE" ]; then
        echo "$PUBLIC_EVENTS" | jq -r --arg csv_file "$CSV_FILE" '
            .[] as $event |
            ($csv_file | @sh) as $csv_path |
            "  • \($event.repo) (original: [lookup from CSV]) - \($event.created_at)"
        ' | while read -r line; do
            repo_name=$(echo "$line" | sed -n 's/.*• \([^ ]*\) .*/\1/p')
            original_name=$(grep ",$repo_name," "$CSV_FILE" | cut -d',' -f4 | head -1)
            if [ -n "$original_name" ]; then
                echo "$line" | sed "s/\[lookup from CSV\]/$original_name/"
            else
                echo "$line" | sed "s/\[lookup from CSV\]/UNKNOWN/"
            fi
        done
    else
        echo "$PUBLIC_EVENTS" | jq -r '
            .[] | "  • \(.repo) (original: UNKNOWN - CSV not found) - \(.created_at)"
        '
    fi
fi

# Summary
echo ""
echo "📊 Summary:"
echo "  • Total events analyzed: $TOTAL_EVENTS"
echo "  • Repository renames found: $RENAME_COUNT"
echo "  • S1ngularity renames detected: $S1NGULARITY_COUNT"
echo "  • S1ngularity repos made public: $PUBLIC_COUNT"

if [ "$S1NGULARITY_COUNT" -gt 0 ] || [ "$PUBLIC_COUNT" -gt 0 ]; then
    echo ""
    echo -e "${RED}⚠️  S1ngularity attack indicators detected!${NC}"
    echo -e "${BLUE}💡 Next steps:${NC}"
    echo "  1. Run the full repository mapping script: npm run repos:map"
    echo "  2. Review the generated mapping file"
    echo "  3. Restore original names: npm run repos:restore"
    exit 1
else
    echo ""
    echo -e "${GREEN}✅ No S1ngularity attack indicators found in recent events${NC}"
    exit 0
fi
