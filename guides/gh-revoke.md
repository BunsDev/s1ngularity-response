# Revoke GitHub PATs & OAuth Tokens (+ gh cli)

This covers personal access tokens (PATs) — both fine-grained and classic — plus OAuth app tokens (e.g., the GitHub CLI authorization) and GitHub Apps access. 

> Revoking an app’s authorization revokes its tokens.  ￼

## 🚀 Quick Start (Automated)
Run the automated GitHub credential revocation script:
```bash
npm run revoke:github
# or: ./scripts/credentials/revoke-github.sh
```

This script will:
- Generate new SSH keys with timestamp
- Guide you through GitHub CLI re-authentication
- Provide step-by-step manual instructions for token revocation
- Update your SSH configuration

# Quicklinks
  ### Developer Settings (PATs)
  - [/settings/developers](https://github.com/settings/developers)
  - [https://github.com/settings/personal-access-tokens](https://github.com/settings/personal-access-tokens)
  ### Classic (PATs)
  - [/settings/tokens](https://github.com/settings/tokens)
  # OAuth & GitHub Apps
  - [/settings/applications](https://github.com/settings/applications)

## I. Revoke fine-grained Personal Access Tokens (PATs)

  - [ ] Avatar (top-right) → Settings → Developer settings.
  - [ ] Personal access tokens → Fine-grained tokens.
  - [ ] For each token you don’t need: ⋯ → Delete (or Revoke if shown).
  - [ ] Re-create only the minimum tokens you truly need (least privilege).

> Reference steps and UI labels are documented by GitHub. Org owners: You can also review & revoke fine-grained PATs that access your org from Org → Settings → Personal access tokens.

## II. Revoke classic Personal Access Tokens

- [ ] Avatar → Settings → Developer settings.
- [ ] Personal access tokens → Tokens (classic).
- [ ] Click a token name → Delete (or Revoke).

> **Org policy (optional)**: Enforce org-wide rules restricting PAT access via Org → Settings → Personal access tokens.  ￼

## III. Revoke OAuth app tokens (incl. GitHub CLI)

- [ ] Avatar → Settings → Applications.
- [ ] Open the Authorized OAuth Apps tab.
- [ ] Locate apps you no longer use or don’t recognize — e.g., “GitHub CLI”.
- [ ] Click the app → Revoke access (or Revoke all to remove every token).

> **Effect**: Revoking an app’s authorization revokes its associated tokens.  ￼

## IV. Review/limit GitHub Apps access (not the same as OAuth apps)

- [ ] In Settings → Applications → Authorized GitHub Apps, review installed apps.
- [ ] Click an app → Revoke (or uninstall from your account/org if needed).

> **GitHub Docs** clarify where to find and revoke GitHub Apps access.  ￼

## V. (Optional) Use the Credential Revocation API for exposed tokens

If you find exposed PATs (yours or others’) on the internet, GitHub provides a Revocation REST API and a bulk revocation process to invalidate them quickly.
  - [ ] **Changelog overview (GA)**: bulk revocation for classic & fine-grained PATs.
  - [ ] **API docs**: “Revoke a list of credentials.”  ￼

> This API is for revoking exposed tokens (e.g., spotted in logs/gists). Personal token management for your account is via Settings.

### After Revoking
- [ ] Re-authenticate affected tools (git, CI, IDEs) using new tokens with the narrowest scopes needed.
- [ ] For orgs, audit which integrations relied on revoked tokens and update their credentials.

### 🔄 Additional Credential Rotation
Don't forget to rotate other credentials that may have been compromised:
```bash
# Rotate npm tokens
npm run revoke:npm
# or: ./scripts/credentials/revoke-npm.sh

# Rotate cloud and API credentials
npm run revoke:cloud
# or: ./scripts/credentials/revoke-cloud-apis.sh

# Run all credential revocation scripts
npm run revoke:all
```

---

# FAQ

**Q: Will revoking an OAuth app remove all its tokens?**
- Yes — revoking an app’s authorization invalidates its tokens.

**Q: Where do I find GitHub CLI’s authorization?**
- It appears under Settings → Applications → Authorized OAuth Apps as “GitHub CLI”; revoke it there.  ￼

**Q: Can org owners centrally nuke members’ personal tokens?**
- They can review/revoke fine-grained PATs that access the org and set policies that restrict PAT usage.
