#!/bin/bash

# Emergency response script for S1ngularity attack
# Run this immediately if active compromise is detected

set -euo pipefail

echo "🚨 EMERGENCY S1NGULARITY RESPONSE INITIATED"
echo "Timestamp: $(date)"

# Create incident log
INCIDENT_LOG="incident-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$INCIDENT_LOG")
exec 2>&1

echo "📝 Logging to: $INCIDENT_LOG"

# Step 1: Immediate containment
echo -e "\n🔒 STEP 1: IMMEDIATE CONTAINMENT"
echo "Killing suspicious processes..."
pkill -f "s1ngularity\|inventory\.txt" 2>/dev/null || echo "No suspicious processes found"

echo "Disconnecting from network (manual step required):"
echo "  - Disconnect ethernet cable"
echo "  - Turn off WiFi"
echo "  - Or run: sudo ifconfig en0 down"

# Step 2: Quick assessment
echo -e "\n🔍 STEP 2: QUICK ASSESSMENT"
./scripts/detection/check-nx-versions.sh
./scripts/detection/check-local-indicators.sh

# Step 3: Immediate cleanup
echo -e "\n🧹 STEP 3: IMMEDIATE CLEANUP"
./scripts/cleanup/remove-persistence.sh

# Step 4: Credential revocation guidance
echo -e "\n🔑 STEP 4: CREDENTIAL REVOCATION (URGENT)"
echo "Run these scripts immediately:"
echo "  ./scripts/credentials/revoke-github.sh"
echo "  ./scripts/credentials/revoke-npm.sh"
echo "  ./scripts/credentials/revoke-cloud-apis.sh"

# Step 5: Repository security
echo -e "\n🔒 STEP 5: REPOSITORY SECURITY"
./scripts/detection/check-github-repos.sh
if [ -f "repos_to_secure.txt" ] && [ -s "repos_to_secure.txt" ]; then
    ./scripts/secure-repos.sh
fi

echo -e "\n✅ EMERGENCY RESPONSE COMPLETE"
echo "📋 NEXT STEPS:"
echo "1. Complete credential revocation using the scripts above"
echo "2. Contact your security team"
echo "3. Review the incident log: $INCIDENT_LOG"
echo "4. Run full security scan: ./scripts/monitoring/scan-for-secrets.sh"
echo "5. Monitor for 48 hours: ./scripts/monitoring/monitor-github-activity.sh"
