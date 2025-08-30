#!/bin/bash

# Revoke and rotate cloud and API credentials after S1ngularity attack

set -euo pipefail

echo "🔑 Revoking and rotating cloud & API credentials..."

echo "🚨 CRITICAL: Rotate ALL credentials that may have been stored locally"
echo ""

echo "📋 AWS Credentials:"
echo "1. Go to AWS IAM Console > My Security Credentials"
echo "2. Deactivate and delete ALL access keys"
echo "3. Create new access keys with minimal required permissions"
echo "4. Update ~/.aws/credentials and ~/.aws/config"
echo "5. Update all CI/CD systems and applications"
echo ""

echo "📋 Google Cloud Platform:"
echo "1. Go to GCP Console > IAM & Admin > Service Accounts"
echo "2. Regenerate keys for all service accounts"
echo "3. Update application default credentials: gcloud auth application-default login"
echo "4. Update all applications using service account keys"
echo ""

echo "📋 Azure:"
echo "1. Go to Azure Portal > App registrations"
echo "2. Regenerate client secrets for all applications"
echo "3. Update Azure CLI: az login"
echo "4. Update all applications and CI/CD systems"
echo ""

echo "📋 Common API Services to rotate:"
echo "• OpenAI API keys: https://platform.openai.com/api-keys"
echo "• Anthropic API keys: https://console.anthropic.com/"
echo "• Google APIs: https://console.cloud.google.com/apis/credentials"
echo "• Stripe: https://dashboard.stripe.com/apikeys"
echo "• Datadog: https://app.datadoghq.com/organization-settings/api-keys"
echo "• Slack: https://api.slack.com/apps"
echo "• Discord: https://discord.com/developers/applications"
echo "• Twilio: https://console.twilio.com/"
echo "• SendGrid: https://app.sendgrid.com/settings/api_keys"
echo ""

echo "📋 Database Credentials:"
echo "• Rotate passwords for all database users"
echo "• Update connection strings in applications"
echo "• Consider rotating database certificates"
echo ""

echo "📋 SSH Keys:"
echo "• Regenerate SSH keys for all servers"
echo "• Update authorized_keys on all servers"
echo "• Update deployment keys in repositories"
echo ""

echo "✅ Cloud & API credential rotation checklist provided"
echo "⚠️  This is a manual process - work through each service systematically"
