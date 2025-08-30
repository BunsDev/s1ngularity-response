#!/bin/bash

# Debug script to test audit log API calls for a single repository

set -euo pipefail

echo "🔍 Debugging Audit Log API for S1ngularity Repository"
echo "=================================================="

# Check if we have a test repository
if [ $# -eq 0 ]; then
    echo "Usage: $0 <repository-name>"
    echo "Example: $0 0xBuns/s1ngularity-repository-hkyoj"
    exit 1
fi

REPO_NAME="$1"
REPO_OWNER=$(echo "$REPO_NAME" | cut -d'/' -f1)
REPO_SHORT=$(echo "$REPO_NAME" | cut -d'/' -f2)

echo "Testing repository: $REPO_NAME"
echo "Owner: $REPO_OWNER"
echo "Short name: $REPO_SHORT"
echo ""

# Test 1: Check if we can access the repository
echo "🔍 Test 1: Repository access"
if gh repo view "$REPO_NAME" &>/dev/null; then
    echo "✅ Repository is accessible"
else
    echo "❌ Repository is not accessible or doesn't exist"
    exit 1
fi

# Test 2: Try GitHub Events API for user events
echo ""
echo "🔍 Test 2: GitHub Events API (user events)"
echo "Command: gh api users/\$(gh api user --jq .login)/events"
USER_EVENTS=$(gh api users/$(gh api user --jq .login)/events 2>/dev/null || echo "[]")
echo "Found $(echo "$USER_EVENTS" | jq 'length' 2>/dev/null || echo "0") recent events"

# Test 3: Look for repository rename events in user events
echo ""
echo "🔍 Test 3: Repository rename events from user events"
RENAME_EVENTS=$(echo "$USER_EVENTS" | jq --arg repo_short "$REPO_SHORT" '
    map(select(.type == "RepositoryEvent" and .payload.action == "renamed" and (.repo.name | contains($repo_short))))
    | map({repo: .repo.name, from: .payload.rename.from, to: .payload.rename.to, created_at: .created_at})
' 2>/dev/null || echo "[]")
echo "Rename events for this repo:"
echo "$RENAME_EVENTS" | jq '.' 2>/dev/null || echo "No rename events found"

# Test 4: Check for PublicEvent (repositories being made public)
echo ""
echo "🔍 Test 4: PublicEvent for this repo"
PUBLIC_EVENTS=$(echo "$USER_EVENTS" | jq --arg repo_short "$REPO_SHORT" '
    map(select(.type == "PublicEvent" and (.repo.name | contains($repo_short))))
    | map({repo: .repo.name, created_at: .created_at})
' 2>/dev/null || echo "[]")
echo "Public events for this repo:"
echo "$PUBLIC_EVENTS" | jq '.' 2>/dev/null || echo "No public events found"

# Test 5: Try user audit log API (fallback)
echo ""
echo "🔍 Test 5: User audit log API (fallback)"
echo "Command: gh api \"user/audit-log\" --field phrase=\"repo:$REPO_SHORT\" --field per_page=10"
AUDIT_RAW=$(gh api "user/audit-log" --field phrase="repo:$REPO_SHORT" --field per_page=10 2>/dev/null || echo "[]")
echo "Raw audit log response:"
echo "$AUDIT_RAW" | jq '.' 2>/dev/null || echo "Invalid JSON or empty response"

# Test 6: Look specifically for rename events in audit log
echo ""
echo "🔍 Test 6: Rename events from audit log"
AUDIT_RENAME_EVENTS=$(echo "$AUDIT_RAW" | jq --arg repo_short "$REPO_SHORT" '
    .[] | select(.action == "repo.rename")
' 2>/dev/null || echo "[]")
echo "Audit log rename events:"
echo "$AUDIT_RENAME_EVENTS"

# Test 7: Try organization audit log (if applicable)
echo ""
echo "🔍 Test 5: Organization audit log (if owner is an org)"
ORG_AUDIT=$(gh api "orgs/$REPO_OWNER/audit-log" --field phrase="repo:$REPO_SHORT" --field per_page=10 2>/dev/null || echo "[]")
if [ "$ORG_AUDIT" != "[]" ]; then
    echo "Organization audit log response:"
    echo "$ORG_AUDIT" | jq '.' 2>/dev/null || echo "Invalid JSON"
else
    echo "No organization audit log available (likely a personal account)"
fi

# Test 6: Try different audit log approaches
echo ""
echo "🔍 Test 6: Alternative audit log queries"

# Try without repo filter
echo "All recent user audit events:"
gh api "user/audit-log" --field per_page=5 2>/dev/null | jq '.[] | {action: .action, repo: .repo, created_at: .created_at}' 2>/dev/null || echo "No events"

# Test 7: Check repository events API
echo ""
echo "🔍 Test 7: Repository events API"
REPO_EVENTS=$(gh api "repos/$REPO_NAME/events" --paginate 2>/dev/null | head -20 || echo "[]")
echo "Recent repository events:"
echo "$REPO_EVENTS" | jq '.[0:3] | .[] | {type: .type, created_at: .created_at}' 2>/dev/null || echo "No events"

echo ""
echo "🔍 Debug complete. Check the output above to identify the issue."
